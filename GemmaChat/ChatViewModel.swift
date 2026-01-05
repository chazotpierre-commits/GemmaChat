import SwiftUI
import Combine
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [(text: String, isUser: Bool)] = []
    @Published var isGenerating = false
    
    // FIX: Add ' = nil' here to initialize the property immediately
    private var llmInference: LlmInference? = nil 
    
    init() {
        // Now self is "fully initialized" and you can call this:
        setupModel()
    }
    
    private func setupModel() {
        // MATCH YOUR EXACT FILENAME: gemma-3-270m-it-int8.task
        guard let modelPath = Bundle.main.path(forResource: "gemma-3-270m-it-int8", ofType: "task") else {
            print("ERROR: File 'gemma-3-270m-it-int8.task' not found in bundle.")
            return
        }
        
        // 2025 SDK syntax: Initialize Options with modelPath
        let options = LlmInference.Options(modelPath: modelPath)
        options.maxTokens = 1024
        
        do {
            llmInference = try LlmInference(options: options)
            print("Gemma-3 270M initialized successfully!")
        } catch {
            print("Failed to initialize LlmInference: \(error)")
        }
    }
    
    func sendMessage(_ text: String) {
        guard let llmInference = llmInference, !text.isEmpty else { return }
        
        messages.append((text: text, isUser: true))
        isGenerating = true
        
        Task {
            do {
                // Run inference on a background thread to prevent UI freezing
                let response = try await Task.detached(priority: .userInitiated) {
                    try llmInference.generateResponse(inputText: text)
                }.value
                
                await MainActor.run {
                    messages.append((text: response, isUser: false))
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    messages.append((text: "Error: \(error.localizedDescription)", isUser: false))
                    isGenerating = false
                }
            }
        }
    }
}
