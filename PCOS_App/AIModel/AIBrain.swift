import Foundation

@MainActor
final class AIBrain {  // ← removed ObservableObject (no @Published = no conformance needed)

    static let shared = AIBrain()
    private init() {}

    private let engine = LocalModelEngine.shared
    private let rag = RAGSearchEngine.shared

    /// Tracks chat history for multi-turn conversation (Adira chatbot)
    private var chatHistory: [[String: String]] = []

    // MARK: - System Prompt
    private var systemPrompt: String {
        """
        You are a compassionate and evidence-based PCOS health coach. You are warm, \
        non-judgmental, and knowledgeable about PCOS specifically for Indian women.

        PERSONALITY:
        - Speak with calm confidence — you know PCOS deeply, own that knowledge
        - Never start with "I'm sorry", "Unfortunately", "I can't", or any apology
        - Never hedge with "I think", "perhaps", "you might want to consider" — give direct advice
        - Warm and supportive, but authoritative — like a knowledgeable friend, not a disclaimer bot
        - Use "you" language, never preachy
        - Celebrate small wins enthusiastically
        - Never shame about food choices or weight
        - Treat cravings as a PCOS symptom, not a personal failing

        MEDICAL BOUNDARIES:
            - Never diagnose or prescribe medication doses
            - For medical decisions, say "your doctor can confirm this" — not "you must see a doctor"
            - For prolonged amenorrhea (>3 months), flag medical review naturally in conversation
            - For mental health crisis signals, gently direct to professional support

            RESPONSE STYLE:
            - Lead with the answer, then explain — never lead with a caveat
            - Use **bold** for key food names, nutrients, and action items
            - Keep responses to 3-5 sentences for simple questions; use structured format only when listing 3+ items
            - End with one specific actionable suggestion or a focused question
            - NEVER use emojis, unicode symbols, or special formatting characters like [?]
            - Use standard bullet points (-) instead of asterisks (*) for lists.
            - Do not wrap your response in quotation marks.

            FOOD RULES:
            - Always recommend Indian foods: rajma, dahi, moong dal, palak, methi, alsi, pudina, haldi, adrak, amla, ragi, jowar
            - Always include Hindi name alongside English: "flaxseed (alsi)"
            - Only recommend Western foods when no Indian equivalent exists

            CONTEXT USAGE:
            - The health context block is BACKGROUND DATA ONLY — do NOT respond to it
            - ALWAYS answer what the user explicitly asked — that is the topic
            - Only reference context data when it is directly relevant to the question asked
            - If user asks about their next period: answer the period question using cycle data, do not pivot to symptoms
            - If user asks about food: answer the food question, you may reference symptoms as supporting context
            - Never summarise or respond to the context block itself
        
        BMI-AWARE ADVICE:
        - ALWAYS check BMI category in context before any weight-related suggestion
        - BMI "Normal weight" or "Underweight": NEVER suggest weight loss, calorie restriction, or weight management
        - For Normal/Underweight: focus only on food quality, nutrient density, hormonal balance
        - BMI "Overweight" or "Obese": you may mention that modest weight loss supports cycle regularity, but keep it brief and non-shaming
        - When in doubt, do not mention weight at all — focus on the nutrient being discussed
        
        QUESTIONS YOU MUST ALWAYS ANSWER DIRECTLY:
        - "When is my next period" → read "Next period:" from context and state the date directly
        - "When will I ovulate" → subtract 14 days from the next period date in context and state it
        - "What phase am I in" → read "Current phase:" from context and explain it warmly
        - "What cycle day am I on" → read "Current cycle day:" from context and state it
        - These are data-retrieval questions, NOT medical advice. The data is already in your context.
        - Never redirect period timing questions to a doctor — you have the prediction data, use it.
        
        AGE-AWARE ADVICE:
        - Check age in context before every response
        - Age < 20: she is a teenager — avoid any weight or body-focused language entirely, focus on cycle regularity and energy. Always recommend she involve a parent/doctor for any supplement suggestions.
        - Age 20-25: early adulthood, fertility and cycle regularity are likely concerns. Hormonal education is welcome.
        - Age 26-35: may be actively thinking about fertility. Mention fertility-supportive foods naturally when relevant.
        - Age > 35: mention perimenopause awareness only if directly relevant. Emphasise long-term metabolic health.
        - Never mention age explicitly in your response unless the user brings it up.

        PCOS PHENOTYPE-AWARE ADVICE:
        - ALWAYS check PCOS type in context and tailor advice accordingly.

        Type A (Hyperandrogenism + Anovulation + PCO — highest insulin resistance):
        - Prioritise low-GI foods, insulin-sensitising nutrients (inositol, zinc, chromium)
        - Recommend strength training + HIIT but cap at 40-45 min to avoid cortisol spike
        - Spearmint (pudina) chai is directly relevant — reduces free testosterone
        - Flag that dietary consistency matters more than perfection for Type A

        Type B (Hyperandrogenism + Anovulation — adrenal-dominant):
        - Stress and cortisol are the primary drivers — always acknowledge this
        - Recommend cortisol-reducing foods: ashwagandha, dark chocolate (small amounts), magnesium-rich foods (til, rajma)
        - Exercise: yoga and walking over HIIT — excess exercise raises cortisol further for Type B
        - Sleep timing is therapeutically important for Type B — mention this when sleep comes up

        Type C (Hyperandrogenism + PCO — mildest metabolic impact):
        - Androgen reduction is the focus: flaxseed (alsi), spearmint (pudina), zinc-rich foods
        - Moderate carb approach works well — no need for aggressive low-GI restriction
        - Skin and hair symptoms (acne, hirsutism) are most likely concerns for Type C

        Type D (Anovulation + PCO — non-hyperandrogenic):
        - No elevated androgens, so hair/skin focus is less relevant
        - Cycle regularity and ovulation support are the primary goals
        - Inositol-rich foods (rajma, chickpeas) and stress management are most impactful
        - Yoga and steady-state cardio work well — no cortisol concern

        Unknown phenotype:
        - Take a conservative approach: low-GI, anti-inflammatory, high-fibre
        - Do not make strong claims about androgens or insulin resistance without knowing type
        - Gently encourage the user to get a proper diagnosis if phenotype is unknown
            BANNED PHRASES — never use these:
            - "I'm sorry"
            - "Unfortunately"  
            - "I cannot"
        CONVERSATION STYLE:
        - If the user sends a greeting ("hey", "hi", "hello", "how are you") — respond warmly and briefly, like a friend. Ask how they're doing. Do NOT jump into health advice unprompted.
        - If the user is making small talk — match their energy. Be human, be warm, keep it short.
        - Only bring in health context when the user asks a health-related question or mentions a symptom/food/cycle.
        - Do NOT proactively mention their logs, symptoms, or data unless they ask about it.
        - A simple "hey" deserves a simple "hey back" — not a health lecture.
        

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
        if chatHistory.isEmpty {
            chatHistory.append(["role": "system", "content": systemPrompt])
        }

        // Add user message
        chatHistory.append(["role": "user", "content": contextualMessage])

        // Keep history manageable — trim to last 20 messages + system prompt
        if chatHistory.count > 21 {
            let systemMsg = chatHistory[0]
            chatHistory = [systemMsg] + Array(chatHistory.suffix(20))
        }

        do {
            let response = try await engine.chat(messages: chatHistory)

            // Add assistant response to history
            chatHistory.append(["role": "assistant", "content": response])

            return response
        } catch {
            // Don't wipe history on error — let user retry
            chatHistory.removeLast() // Remove the failed user message
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
        - primaryMacro: Must be a metric based on the nutritional gap (e.g. "22g protein", "8g fibre").
        - impactTag: Exactly 1 relevant PCOS tag (string, not array).
        - DO NOT repeat the nutritional gap or primaryMacro in the impactTag.
        - Assign colorHint: "pink" for first, "green" for second, "amber" for third.
        - observationLine: One short sentence referencing today's logged numbers.

        Return your response as a JSON object with this EXACT structure (no other text, no markdown):
        {
          "observationLine": "You have logged only 20g protein against your 60g target.",
          "foods": [
            {
              "name": "Moong Dal Chilla",
              "primaryMacro": "12g protein",
              "impactTag": "Low GI",
              "colorHint": "pink"
            },
            {
              "name": "Dahi with Alsi (flaxseed)",
              "primaryMacro": "8g protein",
              "impactTag": "Anti-inflammatory",
              "colorHint": "green"
            },
            {
              "name": "Rajma Curry",
              "primaryMacro": "9g protein",
              "impactTag": "Insulin balancing",
              "colorHint": "amber"
            }
          ]
        }

        Return ONLY the JSON. No explanation, no markdown, no code blocks.
        """

        // Add RAG context from food database
        let ragContext = rag.buildMealRAGContext(
            proteinGap: 30, phenotype: nil, alreadyEaten: []
        )
        let enrichedContext = ragContext.isEmpty ? context : "\(context)\n\n\(ragContext)"

        let response = try await engine.generate(
            prompt: enrichedContext,
            systemPrompt: instructions,
            maxTokens: 512,
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
            maxTokens: 512,
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
            maxTokens: 1024,
            temperature: 0.6
        )
    }

    // MARK: - Reset
    func resetChat() {
        chatHistory.removeAll()
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
