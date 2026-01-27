import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as https from "https";

// Define the secret for OpenAI API key
const openaiApiKey = defineSecret("OPENAI_API_KEY");

interface ExistingAction {
  title: string;
  isCompleted: boolean;
}

interface GenerateActionsRequest {
  goalTitle: string;
  goalDescription?: string;
  category?: string;
  targetDate?: string;
  existingActions?: ExistingAction[];
  actionLimit: number;
}

interface MicroAction {
  title: string;
  sortOrder: number;
}

interface OpenAIResponse {
  choices: Array<{
    message: {
      content: string;
    };
  }>;
}

/**
 * Make a request to OpenAI API using native https module
 */
function callOpenAI(apiKey: string, messages: Array<{ role: string; content: string }>): Promise<OpenAIResponse> {
  return new Promise((resolve, reject) => {
    const data = JSON.stringify({
      model: "gpt-4o-mini",
      messages: messages,
      temperature: 0.7,
      max_tokens: 500,
    });

    const options: https.RequestOptions = {
      hostname: "api.openai.com",
      port: 443,
      path: "/v1/chat/completions",
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${apiKey}`,
        "Content-Length": Buffer.byteLength(data),
      },
      timeout: 30000,
    };

    const req = https.request(options, (res) => {
      let responseData = "";

      res.on("data", (chunk) => {
        responseData += chunk;
      });

      res.on("end", () => {
        if (res.statusCode && res.statusCode >= 200 && res.statusCode < 300) {
          try {
            const parsed = JSON.parse(responseData);
            resolve(parsed);
          } catch (e) {
            reject(new Error(`Failed to parse response: ${responseData}`));
          }
        } else {
          reject(new Error(`OpenAI API error (${res.statusCode}): ${responseData}`));
        }
      });
    });

    req.on("error", (e) => {
      reject(new Error(`Request failed: ${e.message}`));
    });

    req.on("timeout", () => {
      req.destroy();
      reject(new Error("Request timed out"));
    });

    req.write(data);
    req.end();
  });
}

/**
 * Generate micro-actions for a goal using OpenAI
 */
export const generateMicroActions = onCall(
  { secrets: [openaiApiKey] },
  async (request) => {
    console.log("generateMicroActions called");

    // Check if user is authenticated
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "You must be signed in to generate actions"
      );
    }
    console.log("User authenticated:", request.auth.uid);

    const data = request.data as GenerateActionsRequest;
    console.log("Request data:", JSON.stringify(data));

    if (!data.goalTitle) {
      throw new HttpsError("invalid-argument", "Goal title is required");
    }

    // Check if API key is available and trim any whitespace/newlines
    const apiKey = openaiApiKey.value()?.trim();
    if (!apiKey) {
      console.error("OpenAI API key is not set");
      throw new HttpsError("internal", "OpenAI API key is not configured");
    }
    console.log("API key length:", apiKey.length);

    // Build the prompt
    const categoryContext = data.category
      ? `This is a ${data.category} goal.`
      : "";
    const deadlineContext = data.targetDate
      ? `The target date is ${data.targetDate}.`
      : "";
    const descriptionContext = data.goalDescription
      ? `Additional context: ${data.goalDescription}`
      : "";

    const existingActions = data.existingActions || [];
    const hasExisting = existingActions.length > 0;
    const actionLimit = data.actionLimit || 5;

    let existingContext = "";
    let generationStrategy = "";

    if (hasExisting) {
      const existingList = existingActions
        .map((a) => `- ${a.title}${a.isCompleted ? " (completed)" : ""}`)
        .join("\n");
      existingContext = `\nExisting actions for this goal:\n${existingList}\n`;

      // Determine strategy based on existing actions
      const incompleteCount = existingActions.filter((a) => !a.isCompleted).length;
      const slotsAvailable = actionLimit - existingActions.length;

      if (slotsAvailable <= 0 || incompleteCount >= 3) {
        // Suggest replacement - generate fresh set
        generationStrategy = `The user has ${existingActions.length} existing actions. Generate ${actionLimit} NEW actions as a fresh replacement set. Don't duplicate existing ones - create better alternatives.`;
      } else {
        // Suggest append - generate complementary actions
        generationStrategy = `The user has ${existingActions.length} existing actions with ${slotsAvailable} slots available. Generate exactly ${slotsAvailable} NEW complementary actions that work alongside existing ones. Don't duplicate or overlap with existing actions.`;
      }
    }

    const prompt = `You are helping an ambitious woman break down her goal into small, actionable daily micro-actions.

Goal: "${data.goalTitle}"
${categoryContext}
${deadlineContext}
${descriptionContext}
${existingContext}
${generationStrategy || `Generate ${actionLimit} specific, actionable micro-actions.`}

Each action should be:
- Concrete and specific (not vague)
- Achievable in one sitting (5-15 minutes)
- Progressive (building towards the goal)
- Encouraging and empowering

Return a JSON object with:
- "actions": array of objects with "title" field
- "suggestedMode": "append" or "replace" (only if there are existing actions)

Example: {"actions": [{"title": "Research flight prices"}], "suggestedMode": "append"}`;

    const messages = [
      {
        role: "system",
        content:
          "You are a helpful assistant that generates actionable micro-tasks. Always respond with valid JSON only.",
      },
      { role: "user", content: prompt },
    ];

    try {
      console.log("Calling OpenAI API with native https...");

      // Retry logic for transient connection errors
      let response: OpenAIResponse | undefined;
      let lastError: Error | undefined;
      for (let attempt = 1; attempt <= 3; attempt++) {
        try {
          response = await callOpenAI(apiKey, messages);
          console.log("OpenAI API response received on attempt", attempt);
          break;
        } catch (e) {
          lastError = e as Error;
          console.log(`OpenAI API attempt ${attempt} failed:`, lastError.message);
          if (attempt < 3) {
            // Wait before retrying (exponential backoff)
            await new Promise((resolve) => setTimeout(resolve, 1000 * attempt));
          }
        }
      }

      if (!response) {
        throw lastError || new Error("No response from OpenAI");
      }

      const content = response.choices[0]?.message?.content;
      console.log("Response content:", content);
      if (!content) {
        throw new HttpsError("internal", "No response from AI");
      }

      // Parse the JSON response
      let parsedResponse: { actions: MicroAction[]; suggestedMode?: string };
      try {
        // Clean the response (remove markdown code blocks if present)
        const cleanContent = content
          .replace(/```json\n?/g, "")
          .replace(/```\n?/g, "")
          .trim();
        const parsed = JSON.parse(cleanContent);

        // Handle both old format (array) and new format (object with actions)
        if (Array.isArray(parsed)) {
          parsedResponse = { actions: parsed };
        } else {
          parsedResponse = parsed;
        }
      } catch {
        console.error("Failed to parse AI response:", content);
        throw new HttpsError("internal", "Failed to parse AI response");
      }

      // Add sort order and validate
      const validatedActions: MicroAction[] = parsedResponse.actions
        .filter((a) => a.title && typeof a.title === "string")
        .map((a, index) => ({
          title: a.title.trim(),
          sortOrder: index,
        }));

      if (validatedActions.length === 0) {
        throw new HttpsError("internal", "No valid actions generated");
      }

      // Determine suggested mode
      let suggestedMode = parsedResponse.suggestedMode || "append";
      if (hasExisting) {
        const slotsAvailable = actionLimit - existingActions.length;
        // If generating more than available slots, suggest replace
        if (validatedActions.length > slotsAvailable) {
          suggestedMode = "replace";
        }
      }

      return { actions: validatedActions, suggestedMode };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }
      // Log full error details
      const err = error as Error;
      console.error("OpenAI API error:", {
        name: err.name,
        message: err.message,
        stack: err.stack,
      });
      throw new HttpsError(
        "internal",
        `Failed to generate actions: ${err.message}`
      );
    }
  }
);
