<<<<<<< HEAD
=======
//
//  ChatViewModel.swift
//  GemmaChat
//
//  Created by Pierre Chazot on 18/12/2025.
//

>>>>>>> 60b3b5f (Fresh start without heavy files)
import SwiftUI
import Combine
import MediaPipeTasksGenAI
import MediaPipeTasksGenAIC

<<<<<<< HEAD
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
=======
struct ChatMessage: Identifiable {
    let id = UUID()
    var text: String
    let isUser: Bool
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published var isModelLoading = false
    
    // This is the function the View was complaining about
    @MainActor
    func setupModel() async {
        print("DEBUG: OS_READY")
    }

    func sendMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isModelLoading else { return }
        
        isModelLoading = true
        messages.append(ChatMessage(text: text, isUser: true))
        messages.append(ChatMessage(text: "ANALYZING...", isUser: false))
        
        let lastIdx = messages.count - 1
        inputText = ""
        
        Task.detached(priority: .userInitiated) {
            do {
                guard let modelPath = Bundle.main.path(forResource: "gemma3-1B-it-int4", ofType: "task") else { return }
                
                let options = LlmInference.Options(modelPath: modelPath)
                options.maxTokens = 256
                
                let engine = try LlmInference(options: options)
                let prompt = "<start_of_turn>user\n\(text)<end_of_turn>\n<start_of_turn>model\n"
                let stream = engine.generateResponseAsync(inputText: prompt)
                
                var currentText = ""
                for try await partial in stream {
                    currentText += partial
                    let textToUpdate = currentText
                    
                    await MainActor.run {
                        // Crucial: Check indices to avoid crashes
                        if self.messages.indices.contains(lastIdx) {
                            self.messages[lastIdx].text = textToUpdate
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    if self.messages.indices.contains(lastIdx) {
                        self.messages[lastIdx].text = "ERROR: \(error.localizedDescription)"
                    }
                }
            }
            await MainActor.run { self.isModelLoading = false }
>>>>>>> 60b3b5f (Fresh start without heavy files)
        }
    }
}
