import Foundation
import MLXLMCommon
import MLXLLM

// MARK: - AI Chat Session Protocol
public protocol AIChatSession {
    func respond(to prompt: String) async throws -> String
}

// Removed direct extension of ChatSession. We will wrap it instead.

// MARK: - AI Engine Protocol
public protocol AIModelEngine {
    var isModelLoaded: Bool { get }
    func generate(prompt: String, systemPrompt: String, maxTokens: Int, temperature: Float) async throws -> String
    func createChatSession(systemPrompt: String) -> AIChatSession?
}
