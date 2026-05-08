//
//  LocalModelEngine.swift
//  PCOS_App
//
//  On-device LLM engine powered by MLX Swift LM v3 + MedMobile 3.8B.
//  Handles model download, loading, and text generation.
//
//  Adapted from Apple's official LLMEval example:
//  https://github.com/ml-explore/mlx-swift-examples/blob/main/Applications/LLMEval
//

import Combine
import Foundation
import Hub
import HuggingFace
import MLX
import MLXHuggingFace
import MLXLLM
import MLXLMCommon
import Tokenizers

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

// MARK: - Model Configuration

extension ModelConfiguration {
    /// Gemma 4 E2B Instruct — Google's Absolute Latest Edge Model (Released April 2026)
    /// This is the exact model expected for the "Gemma for Good" Kaggle Hackathon.
    /// E2B is optimized specifically for mobile/IoT devices.
    /// 4-bit quantized, MLX format. Guaranteed compatibility with iOS MLX framework.
    static let pcosCoach = ModelConfiguration(
        id: "mlx-community/gemma-4-e2b-it-4bit",
        defaultPrompt: "What foods help with PCOS?"
    )
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

    // ── Model Lifecycle ───────────────────────────────────────────────────

    /// Downloads (if needed) and loads the model into GPU memory.
    /// Call this on app launch or when the user explicitly requests it.
    func loadModel() async throws {
        guard state != .ready && state != .loading else { return }

        // MLX Swift requires a real Metal GPU — skip on Simulator
        #if targetEnvironment(simulator)
        print("⚠️ MLX Swift does not work on the iOS Simulator. Skipping model load.")
        state = .failed("AI requires a physical device (not Simulator)")
        return
        #else

        state = .downloading(progress: 0)

        // Limit Metal buffer cache to conserve memory on mobile
        Memory.cacheLimit = 20 * 1024 * 1024

        // Retry up to 3 times — large downloads can timeout on slow WiFi.
        // The HF downloader caches partial downloads, so retries resume (not restart).
        let maxRetries = 3
        var lastError: Error?

        for attempt in 1...maxRetries {
            do {
                print("🤖 [AI] Download attempt \(attempt)/\(maxRetries)...")

                // Step 1: Download model files from HuggingFace (cached after first download)
                let downloader = #hubDownloader()

                let resolved = try await resolve(
                    configuration: .pcosCoach,
                    from: downloader,
                    useLatest: false
                ) { [weak self] progress in
                    Task { @MainActor in
                        let fraction = progress.fractionCompleted
                        self?.state = .downloading(progress: fraction)
                    }
                }

                // Step 2: Load model weights + tokenizer into GPU memory
                state = .loading
                print("🤖 [AI] Download complete. Loading model into GPU...")

                let container = try await LLMModelFactory.shared.loadContainer(
                    from: resolved.modelDirectory,
                    using: #huggingFaceTokenizerLoader()
                )

                self.modelContainer = container
                state = .ready
                print("✅ AI model loaded successfully (Gemma 4 Edge)")
                return  // Success — exit the retry loop

            } catch {
                lastError = error
                let isTimeout = (error as NSError).code == -1001
                print("⚠️ [AI] Attempt \(attempt) failed: \(isTimeout ? "timeout" : error.localizedDescription)")

                if attempt < maxRetries && isTimeout {
                    // Wait before retrying (2s, 5s)
                    let delay = attempt == 1 ? 2 : 5
                    print("🤖 [AI] Retrying in \(delay) seconds...")
                    state = .downloading(progress: 0)
                    try? await Task.sleep(for: .seconds(delay))
                }
            }
        }

        // All retries exhausted
        if let error = lastError {
            state = .failed(error.localizedDescription)
            print("❌ Model loading failed after \(maxRetries) attempts: \(error)")
            throw error
        }
        #endif  // targetEnvironment(simulator)
    }

    /// Unloads the model from memory — call when app is backgrounded to free RAM.
    func unloadModel() {
        modelContainer = nil
        state = .idle
        print("🔄 Model unloaded from memory")
    }

    // ── Text Generation (One-Shot) ────────────────────────────────────────

    /// One-shot text generation with a system prompt and user prompt.
    /// Creates a fresh ChatSession for each call — no history retained.
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

        // Create a one-shot ChatSession with system instructions
        let session = ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                maxTokens: maxTokens,
                temperature: temperature,
                topP: 0.9,
                repetitionPenalty: 1.15,
                repetitionContextSize: 30
            )
        )

        let response = try await session.respond(to: prompt)
        return response
    }

    // ── Chat Session Factory ──────────────────────────────────────────────

    /// Creates a new ChatSession for multi-turn conversation.
    /// The caller (AIBrain) manages the session lifecycle.
    func createChatSession(systemPrompt: String) -> ChatSession? {
        guard let container = modelContainer else { return nil }

        return ChatSession(
            container,
            instructions: systemPrompt,
            generateParameters: GenerateParameters(
                maxTokens: 1024,
                temperature: 0.75,
                topP: 0.9,
                repetitionPenalty: 1.15,
                repetitionContextSize: 30
            )
        )
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
