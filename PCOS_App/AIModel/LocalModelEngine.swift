//
//  LocalModelEngine.swift
//  PCOS_App
//
//  On-device LLM engine powered by MLX Swift + MedMobile 3.8B.
//  Handles model download, loading, and text generation.
//

import Foundation
import MLX
import MLXLLM
import MLXLMCommon

// MARK: - Model State

enum ModelState: Equatable {
    case idle                           // Not loaded, not downloading
    case downloading(progress: Double)  // Downloading from HuggingFace
    case loading                        // Loading into GPU memory
    case ready                          // Ready for inference
    case failed(String)                 // Error state

    static func == (lhs: ModelState, rhs: ModelState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.ready, .ready): return true
        case (.downloading(let a), .downloading(let b)): return a == b
        case (.failed(let a), .failed(let b)): return a == b
        default: return false
        }
    }
}

// MARK: - Local Model Engine

@MainActor
final class LocalModelEngine: ObservableObject {

    static let shared = LocalModelEngine()
    private init() {}

    // ── Public State ──────────────────────────────────────────────────────

    @Published private(set) var state: ModelState = .idle

    var isModelLoaded: Bool { state == .ready }

    var isDownloading: Bool {
        if case .downloading = state { return true }
        return false
    }

    var downloadProgress: Double {
        if case .downloading(let p) = state { return p }
        return 0
    }

    // ── Private Properties ────────────────────────────────────────────────

    private var modelContainer: ModelContainer?

    /// The HuggingFace model ID for MedMobile 3.8B (4-bit quantized, MLX format).
    /// ⚠️ IMPORTANT: Replace this with YOUR uploaded model repo after running the conversion.
    /// For testing, you can use a smaller model like "mlx-community/Qwen3-1.7B-4bit"
    private let modelConfiguration = ModelConfiguration(
        id: "mlx-community/Phi-3.5-mini-instruct-4bit"  // ← REPLACE with your MedMobile repo
    )

    // ── Model Lifecycle ───────────────────────────────────────────────────

    /// Downloads (if needed) and loads the model into GPU memory.
    /// Call this on app launch or when the user explicitly requests it.
    func loadModel() async throws {
        guard state != .ready && state != .loading else { return }

        state = .loading

        do {
            let container = try await LLMModelFactory.shared.loadContainer(
                configuration: modelConfiguration
            ) { progress in
                Task { @MainActor in
                    self.state = .downloading(progress: progress.fractionCompleted)
                }
            }

            self.modelContainer = container
            state = .ready
            print("✅ MedMobile model loaded successfully")
        } catch {
            state = .failed(error.localizedDescription)
            print("❌ Model loading failed: \(error)")
            throw error
        }
    }

    /// Unloads the model from memory — call when app is backgrounded to free RAM.
    func unloadModel() {
        modelContainer = nil
        state = .idle
        print("🔄 Model unloaded from memory")
    }

    // ── Text Generation ───────────────────────────────────────────────────

    /// One-shot text generation with a system prompt and user prompt.
    /// Used for insights, meal analysis, food descriptions, and structured JSON output.
    func generate(
        prompt: String,
        systemPrompt: String,
        maxTokens: Int = 1024,
        temperature: Float = 0.6
    ) async throws -> String {

        guard let container = modelContainer else {
            throw LocalModelError.modelNotLoaded
        }

        let messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": prompt]
        ]

        // Tokenize using the model's chat template
        let promptTokens = try await container.perform { context in
            try context.tokenizer.applyChatTemplate(messages: messages)
        }

        // Generate response
        let result = try await container.perform { context in
            try MLXLMCommon.generate(
                promptTokens: promptTokens,
                parameters: .init(temperature: temperature, topP: 0.9),
                model: context.model,
                tokenizer: context.tokenizer,
                extraEOSTokens: nil
            ) { tokens in
                if tokens.count >= maxTokens {
                    return .stop
                }
                return .more
            }
        }

        return result.output
    }

    /// Multi-turn chat generation. Takes full message history.
    /// Used by the Adira chatbot for conversational context.
    func chat(
        messages: [[String: String]],
        maxTokens: Int = 1024,
        temperature: Float = 0.7
    ) async throws -> String {

        guard let container = modelContainer else {
            throw LocalModelError.modelNotLoaded
        }

        let promptTokens = try await container.perform { context in
            try context.tokenizer.applyChatTemplate(messages: messages)
        }

        let result = try await container.perform { context in
            try MLXLMCommon.generate(
                promptTokens: promptTokens,
                parameters: .init(temperature: temperature, topP: 0.9),
                model: context.model,
                tokenizer: context.tokenizer,
                extraEOSTokens: nil
            ) { tokens in
                if tokens.count >= maxTokens {
                    return .stop
                }
                return .more
            }
        }

        return result.output
    }

    // ── Device Capability Check ───────────────────────────────────────────

    /// Returns true if this device has enough RAM to run the model.
    /// MedMobile 3.8B (4-bit) needs ~3-4 GB — requires 6 GB+ devices (iPhone 13 Pro+).
    static var isDeviceCapable: Bool {
        let totalMemory = ProcessInfo.processInfo.physicalMemory
        let totalGB = Double(totalMemory) / (1024 * 1024 * 1024)
        return totalGB >= 5.5  // 6 GB devices report ~5.6 GB usable
    }
}

// MARK: - Errors

enum LocalModelError: LocalizedError {
    case modelNotLoaded
    case deviceNotCapable

    var errorDescription: String? {
        switch self {
        case .modelNotLoaded:
            return "AI model is not loaded. Please wait for the model to finish downloading."
        case .deviceNotCapable:
            return "This device doesn't have enough memory to run the AI model."
        }
    }
}
