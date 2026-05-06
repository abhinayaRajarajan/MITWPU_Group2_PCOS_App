import Foundation
import MLXLMCommon

@MainActor
final class AIBrain {

    static let shared = AIBrain()
    private init() {}

    private let engine = LocalModelEngine.shared
    private let rag = RAGSearchEngine.shared

    /// Multi-turn chat session for Adira chatbot (managed by ChatSession)
    private var chatSession: ChatSession?

    // MARK: - System Prompt
    private var systemPrompt: String {
        """
        You are Adira, a warm PCOS health coach for Indian women. Be direct, confident, supportive.

        RULES:
        - Lead with the answer. Never start with "I'm sorry" or "Unfortunately".
        - NEVER start your response with "Adira:" or "Hello Adira". Just start talking normally.
        - Keep responses 3-5 sentences. Use **bold** for key foods and actions.
        - Recommend Indian foods with Hindi names: "flaxseed (alsi)", "fenugreek (methi)".
        - Never diagnose or prescribe medication doses.
        - Answer cycle questions directly using the context data provided.
        - For greetings like "hi" — just respond warmly, no health lecture.
        - Never mention weight loss if BMI is Normal or Underweight in the context.
        - Use data from [PCOS Research] and [Food] blocks when provided.
        - No emojis. No markdown code blocks. Plain text with **bold** for emphasis.
        """
    }

    // MARK: - Chat

    func sendChatMessage(_ text: String, context: String) async throws -> String {
        guard engine.isModelLoaded else {
            throw AIBrainError.modelUnavailable
        }

        // Detect casual/greeting AND short follow-up replies that rely on conversation memory
        let casualPhrases = [
            // Greetings
            "hey", "hi", "hello", "hii", "heyy", "how are you",
            "what's up", "sup", "good morning", "good night",
            "thanks", "thank you", "haha", "lol",
            // Short follow-ups that depend on conversation memory
            "yes", "no", "yeah", "nope", "sure", "okay", "ok",
            "please", "go ahead", "tell me", "yes please",
            "no thanks", "that's fine", "sounds good", "great",
            "not really", "maybe", "i think so", "definitely"
        ]

        let trimmed = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Match exact OR very short messages (under 2 words) that are follow-ups
        let wordCount = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }.count
        let isCasual = casualPhrases.contains(where: { trimmed == $0 || trimmed.hasPrefix($0 + " ") })
                      || wordCount <= 2  // ← short replies always rely on session memory, not fresh context

        let contextualMessage: String
        if isCasual {
            // No health context for small talk — just chat naturally
            contextualMessage = text
        } else {
            // Period hint for cycle questions
            let isPeriodQuestion = trimmed.contains("period") ||
                                   trimmed.contains("next cycle") ||
                                   trimmed.contains("ovulat")

            var periodHint = ""
            if isPeriodQuestion,
               let range = context.range(of: "Next period:"),
               let endRange = context.range(of: "\n", range: range.upperBound..<context.endIndex) {
                let periodLine = String(context[range.lowerBound..<endRange.lowerBound])
                periodHint = "\n[Relevant data: \(periodLine)]"
            }

            // Build RAG context from research + food databases
            let ragContext = rag.buildRAGContext(query: text)

            contextualMessage = """
            [BACKGROUND HEALTH DATA — use only if relevant to the question below:]
            \(context)\(periodHint)
            [END BACKGROUND DATA]

            \(ragContext)

            User's question: \(text)
            """
        }

        // Build message history for multi-turn chat
        // Always start with system prompt
        // Create chat session if needed
        if chatSession == nil {
            chatSession = engine.createChatSession(systemPrompt: systemPrompt)
        }

        guard let session = chatSession else {
            throw AIBrainError.modelUnavailable
        }

        do {
            let response = try await session.respond(to: contextualMessage)
            return response
        } catch {
            throw error
        }
    }
    
    //MARK: generate meal recommendations
    func generateMealRecommendations(context: String) async throws -> MealRecommendationOutput {
        guard engine.isModelLoaded else {
            throw AIBrainError.modelUnavailable
        }

        let instructions = """
        Generate exactly 3 personalized Indian meal suggestions based on the user's PCOS context.
        
        RULES:
        - Provide exactly 3 Indian food suggestions.
        - Do NOT repeat any food already logged today.
        - Focus on the biggest nutritional gap (protein, fibre, anti-inflammatory).
        - Use "Dish Name (Hindi Name)" format for food names.
        - primaryMacro: Must be a metric based on the true nutritional gap from the context (e.g. "Xg protein", "Yg fibre").
        - impactTag: Exactly 1 relevant PCOS tag (string, not array).
        - DO NOT repeat the nutritional gap or primaryMacro in the impactTag.
        - Assign colorHint: "pink" for first, "green" for second, "amber" for third.
        - observationLine: One short sentence referencing today's EXACT logged numbers from the context (e.g. "You have logged 0g protein against your 80g target").

        Return your response as a JSON object with this EXACT structure (no other text, no markdown):
        {
          "observationLine": "<write your observation here based on the true context>",
          "foods": [
            {
              "name": "<Food 1>",
              "primaryMacro": "<Macro 1>",
              "impactTag": "<Tag 1>",
              "colorHint": "pink"
            },
            {
              "name": "<Food 2>",
              "primaryMacro": "<Macro 2>",
              "impactTag": "<Tag 2>",
              "colorHint": "green"
            },
            {
              "name": "<Food 3>",
              "primaryMacro": "<Macro 3>",
              "impactTag": "<Tag 3>",
              "colorHint": "amber"
            }
          ]
        }

        Return ONLY the JSON. No explanation, no markdown, no code blocks.
        """

        // Extract protein target and logged dynamically
        var proteinGap = 30.0
        if let targetRange = context.range(of: "g protein"),
           let targetStart = context[..<targetRange.lowerBound].lastIndex(of: " "),
           let target = Double(context[targetStart..<targetRange.lowerBound].trimmingCharacters(in: .whitespaces)) {
            
            var logged = 0.0
            let afterTarget = context[targetRange.upperBound...]
            if let loggedRange = afterTarget.range(of: "g protein"),
               let loggedStart = afterTarget[..<loggedRange.lowerBound].lastIndex(of: " "),
               let loggedVal = Double(afterTarget[loggedStart..<loggedRange.lowerBound].trimmingCharacters(in: .whitespaces)) {
                logged = loggedVal
            }
            proteinGap = max(0, target - logged)
            if proteinGap == 0 { proteinGap = 20.0 } // default gap if none
        }

        // Add RAG context from food database
        let ragContext = rag.buildMealRAGContext(
            proteinGap: proteinGap, phenotype: nil, alreadyEaten: []
        )
        let enrichedContext = ragContext.isEmpty ? context : "\(context)\n\n\(ragContext)"

        let response = try await engine.generate(
            prompt: enrichedContext,
            systemPrompt: instructions,
            maxTokens: 300,
            temperature: 0.5
        )

        // Parse JSON from response
        return try parseJSON(MealRecommendationOutput.self, from: response)
    }


    func generateDailyGoals(context: String) async throws -> DailyGoalsOutput {
        guard engine.isModelLoaded else {
            throw AIBrainError.modelUnavailable
        }

        let instructions = """
        Generate exactly 2 personalized daily health goals for a woman with PCOS.

        PRIORITY ORDER — pick the top 2 that apply, in this order:
        1. Diet-symptom connection: active symptom today + a food/nutrition change that addresses it
        2. Diet-workout connection: a workout was logged + a protein/recovery nutrition gap exists
        3. Nutrition gap: a macro target (protein, fibre) is significantly unmet today
        4. Workout gap: no strength training or movement logged in the past 7 days

        HARD RULES:
        - CRITICAL: Use ONLY the exact numbers from the context. Read protein target from the "Targets: ...PXg..." line. Never invent or assume typical values.
        - Never generate a sleep goal — sleep is excluded entirely
        - ONLY generate goals based on data explicitly present in the context.
        - If "Symptoms today: none" — do not generate any symptom-based goal.
        - Never invent or assume symptoms, food logs, or patterns not in context.
        - Never suggest weight loss or calorie restriction if BMI is Underweight or Normal
        - Each goal must reference one real number from today's logs or 7-day patterns
        - Both goals must be different categories (nutrition / exercise / symptoms)
        - Sentences must be under 12 words
        - No vague goals — every goal must name a specific food or action

        Return your response as a JSON object with this EXACT structure (no other text, no markdown):
        {
          "goals": [
            {
              "title": "Boost protein",
              "sentence": "Only 20g protein logged — add moong dal or dahi.",
              "category": "nutrition"
            },
            {
              "title": "Strength training",
              "sentence": "No strength training in 7 days — add a 20-min session.",
              "category": "exercise"
            }
          ]
        }

        Return ONLY the JSON. No explanation, no markdown, no code blocks.
        """

        let response = try await engine.generate(
            prompt: context,
            systemPrompt: instructions,
            maxTokens: 250,
            temperature: 0.5
        )

        return try parseJSON(DailyGoalsOutput.self, from: response)
    }

    // MARK: - One-Shot Generation (for insights, meal analysis, food descriptions)

    /// Generic one-shot text generation — replaces all standalone LanguageModelSession calls.
    /// Used by CycleObservationsModel, SleepObservationsModel, SymptomInsightModel,
    /// DescribeFoodViewController, FoodScannerViewController, AddDescribedMealViewController.
    func generateRawText(prompt: String, instructions: String) async throws -> String {
        guard engine.isModelLoaded else {
            throw AIBrainError.modelUnavailable
        }

        return try await engine.generate(
            prompt: prompt,
            systemPrompt: instructions,
            maxTokens: 400,
            temperature: 0.6
        )
    }

    // MARK: - Reset
    func resetChat() {
        chatSession = nil
    }

    var isAvailable: Bool {
        engine.isModelLoaded
    }

    // MARK: - JSON Parsing Helper

    /// Parses a JSON object from a raw model response string.
    /// Handles common model quirks: markdown code blocks, trailing text, etc.
    private func parseJSON<T: Decodable>(_ type: T.Type, from response: String) throws -> T {
        var cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)

        // Strip markdown code fences if present
        if cleaned.hasPrefix("```json") {
            cleaned = String(cleaned.dropFirst(7))
        } else if cleaned.hasPrefix("```") {
            cleaned = String(cleaned.dropFirst(3))
        }
        if cleaned.hasSuffix("```") {
            cleaned = String(cleaned.dropLast(3))
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        // Try to find JSON object boundaries
        if let startIdx = cleaned.firstIndex(of: "{"),
           let endIdx = cleaned.lastIndex(of: "}") {
            cleaned = String(cleaned[startIdx...endIdx])
        }

        guard let data = cleaned.data(using: .utf8) else {
            throw AIBrainError.jsonParsingFailed
        }

        return try JSONDecoder().decode(type, from: data)
    }
}

// MARK: - Errors
enum AIBrainError: LocalizedError {
    case modelUnavailable
    case jsonParsingFailed

    var errorDescription: String? {
        switch self {
        case .modelUnavailable:
            return "AI model is not available. Please ensure the model has been downloaded."
        case .jsonParsingFailed:
            return "Failed to parse AI response. Please try again."
        }
    }
}
