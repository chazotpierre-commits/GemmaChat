//
//  ChatViewModel.swift
//  GemmaChat
//
//  Created by Pierre Chazot on 18/12/2025.
//
import Foundation
import SwiftUI
import Combine
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
}

actor GemmaEngine {
    private var llm: LlmInference?

    func loadModel() throws {
        guard let modelPath = Bundle.main.path(forResource: "gemma3-1B-it-int4", ofType: "task") else {
            throw NSError(domain: "GemmaChat", code: 1, userInfo: [
                NSLocalizedDescriptionKey: "Model file not found in app bundle."
            ])
        }

        let options = LlmInference.Options(modelPath: modelPath)
        options.maxTokens = 512
        llm = try LlmInference(options: options)
    }

    func generate(_ prompt: String) throws -> String {
        guard let llm else {
            throw NSError(domain: "GemmaChat", code: 2, userInfo: [
                NSLocalizedDescriptionKey: "Model not loaded."
            ])
        }
        return try llm.generateResponse(inputText: prompt)
    }
}

@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isGenerating = false
    @Published var isModelLoading = false

    private let engine = GemmaEngine()
    private var didSetup = false

    func setupModelIfNeeded() async {
        guard !didSetup else { return }
        didSetup = true

        isModelLoading = true
        defer { isModelLoading = false }

        do {
            try await engine.loadModel()
            messages.append(ChatMessage(text: "✅ Model loaded.", isUser: false))
        } catch {
            messages.append(ChatMessage(text: "❌ Model load failed: \(error.localizedDescription)", isUser: false))
        }
    }

    func sendMessage(_ text: String) {
        messages.append(ChatMessage(text: text, isUser: true))
        isGenerating = true

        let prompt = """
        <start_of_turn>user
        \(text)
        <end_of_turn>
        <start_of_turn>model
        """

        Task {
            do {
                let response = try await engine.generate(prompt)
                messages.append(ChatMessage(text: response, isUser: false))
            } catch {
                messages.append(ChatMessage(text: "❌ Error: \(error.localizedDescription)", isUser: false))
            }
            isGenerating = false
        }
    }
}
