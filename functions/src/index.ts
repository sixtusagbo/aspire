import { onCall, HttpsError } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import OpenAI from "openai";

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

    // Check if API key is available
    const apiKey = openaiApiKey.value();
    if (!apiKey) {
      console.error("OpenAI API key is not set");
      throw new HttpsError("internal", "OpenAI API key is not configured");
    }
    console.log("API key length:", apiKey.length);

    const openai = new OpenAI({
      apiKey: apiKey,
    });

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

    try {
      console.log("Calling OpenAI API...");

      // Retry logic for transient connection errors
      let completion;
      let lastError;
      for (let attempt = 1; attempt <= 3; attempt++) {
        try {
          completion = await openai.chat.completions.create({
            model: "gpt-4o-mini",
            messages: [
              {
                role: "system",
                content:
                  "You are a helpful assistant that generates actionable micro-tasks. Always respond with valid JSON only.",
              },
              { role: "user", content: prompt },
            ],
            temperature: 0.7,
            max_tokens: 500,
          });
          break; // Success, exit retry loop
        } catch (e) {
          lastError = e;
          console.log(`OpenAI API attempt ${attempt} failed:`, (e as Error).message);
          if (attempt < 3) {
            // Wait before retrying (exponential backoff)
            await new Promise((resolve) => setTimeout(resolve, 1000 * attempt));
          }
        }
      }

      if (!completion) {
        throw lastError;
      }
      console.log("OpenAI API response received");

      const content = completion.choices[0]?.message?.content;
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
