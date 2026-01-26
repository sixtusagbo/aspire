import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as https from "https";

// Define the secret for OpenAI API key
const openaiApiKey = defineSecret("OPENAI_API_KEY");

interface GenerateActionsRequest {
  goalTitle: string;
  goalDescription?: string;
  category?: string;
  targetDate?: string;
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

    const prompt = `You are helping an ambitious woman break down her goal into small, actionable daily micro-actions.

Goal: "${data.goalTitle}"
${categoryContext}
${deadlineContext}
${descriptionContext}

Generate 5-7 specific, actionable micro-actions that can each be completed in 5-15 minutes.
Each action should be:
- Concrete and specific (not vague)
- Achievable in one sitting
- Progressive (building towards the goal)
- Encouraging and empowering

Return ONLY a JSON array of objects with "title" field. No markdown, no explanation.
Example: [{"title": "Research flight prices to destination"},{"title": "Set up automatic savings transfer of $50"}]`;

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
      let actions: MicroAction[];
      try {
        // Clean the response (remove markdown code blocks if present)
        const cleanContent = content
          .replace(/```json\n?/g, "")
          .replace(/```\n?/g, "")
          .trim();
        actions = JSON.parse(cleanContent);
      } catch {
        console.error("Failed to parse AI response:", content);
        throw new HttpsError("internal", "Failed to parse AI response");
      }

      // Add sort order and validate
      const validatedActions: MicroAction[] = actions
        .filter((a) => a.title && typeof a.title === "string")
        .map((a, index) => ({
          title: a.title.trim(),
          sortOrder: index,
        }));

      if (validatedActions.length === 0) {
        throw new HttpsError("internal", "No valid actions generated");
      }

      return { actions: validatedActions };
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
