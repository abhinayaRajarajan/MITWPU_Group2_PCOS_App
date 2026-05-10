import Foundation

@MainActor
final class CloudModelEngine: AIModelEngine {
    
    // Cloud is always ready to accept requests
    var isModelLoaded: Bool { return true }
    
    // Note: In production, store this securely (e.g. your backend or secure config)
    private let apiKey = Bundle.main.object(forInfoDictionaryKey: "GroqAPIKey") as? String ?? ""
    private let endpoint = URL(string: "https://api.groq.com/openai/v1/chat/completions")!
    
    func generate(prompt: String, systemPrompt: String, maxTokens: Int, temperature: Float) async throws -> String {
        return try await makeGroqRequest(
            messages: [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": prompt]
            ],
            maxTokens: maxTokens,
            temperature: temperature
        )
    }
    
    func createChatSession(systemPrompt: String) -> AIChatSession? {
        return CloudChatSession(engine: self, systemPrompt: systemPrompt)
    }
    
    func makeGroqRequest(messages: [[String: String]], maxTokens: Int, temperature: Float) async throws -> String {
        guard apiKey != "YOUR_GROQ_API_KEY" else {
            print("❌ Groq API Key is missing. Please set it in CloudModelEngine.swift.")
            throw CloudModelError.missingAPIKey
        }
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Use the larger parameter cloud model, maintaining Gemma consistency
        let body: [String: Any] = [
            "model": "meta-llama/llama-4-scout-17b-16e-instruct", // Or "gemma2-9b-it" depending on what Groq supports exactly
            "messages": messages,
            "max_tokens": maxTokens,
            "temperature": temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw CloudModelError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMsg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("Groq API Error (\(httpResponse.statusCode)): \(errorMsg)")
            throw CloudModelError.apiRequestFailed(statusCode: httpResponse.statusCode)
        }
        
        // Parse JSON (Standard OpenAI format)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw CloudModelError.parsingFailed
        }
        
        return content
    }
}

class CloudChatSession: AIChatSession {
    private let engine: CloudModelEngine
    private var messages: [[String: String]] = []
    
    init(engine: CloudModelEngine, systemPrompt: String) {
        self.engine = engine
        self.messages.append(["role": "system", "content": systemPrompt])
    }
    
    func respond(to prompt: String) async throws -> String {
        messages.append(["role": "user", "content": prompt])
        
        do {
            let response = try await engine.makeGroqRequest(
                messages: messages,
                maxTokens: 1024,
                temperature: 0.75
            )
            messages.append(["role": "assistant", "content": response])
            return response
        } catch {
            // Remove the user message if it failed, so the next attempt isn't duplicated
            messages.removeLast()
            throw error
        }
    }
}

enum CloudModelError: LocalizedError {
    case missingAPIKey
    case apiRequestFailed(statusCode: Int)
    case invalidResponse
    case parsingFailed
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey: return "Cloud AI API key is not configured."
        case .apiRequestFailed(let code): return "Cloud AI request failed with status \(code)."
        case .invalidResponse: return "Received invalid response from Cloud AI."
        case .parsingFailed: return "Failed to parse JSON response from Cloud AI."
        }
    }
}
