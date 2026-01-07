import SwiftUI

struct ContentView: View {
<<<<<<< HEAD
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    
    var body: some View {
        VStack {
            Text("Gemma-3 270M Chat")
                .font(.headline)
                .padding(.top)
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(0..<viewModel.messages.count, id: \.self) { index in
                            let msg = viewModel.messages[index]
                            chatBubble(msg: msg)
=======
    // 1. Declare the ViewModel
    @StateObject private var viewModel = ChatViewModel()
    
    var body: some View {
        VStack {
            // Header
            Text("AI_TERMINAL_V3")
                .font(.system(.headline, design: .monospaced))
                .padding()

            // 2. Message List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(viewModel.messages) { msg in
                            HStack(alignment: .top) {
                                Text(msg.isUser ? "USER>" : "AI>")
                                    .font(.system(.caption, design: .monospaced))
                                    .bold()
                                    .foregroundColor(msg.isUser ? .blue : .green)
                                
                                Text(msg.text)
                                    .font(.system(.body, design: .monospaced))
                            }
                            .id(msg.id)
>>>>>>> 60b3b5f (Fresh start without heavy files)
                        }
                    }
                    .padding()
                }
<<<<<<< HEAD
                .onChange(of: viewModel.messages.count) { _ in
                    withAnimation {
                        proxy.scrollTo(viewModel.messages.count - 1)
                    }
                }
            }
            
            HStack {
                TextField("Message Gemma...", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isGenerating)
                
                Button(action: {
                    let text = inputText
                    inputText = ""
                    viewModel.sendMessage(text)
                }) {
                    if viewModel.isGenerating {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(inputText.isEmpty || viewModel.isGenerating)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    func chatBubble(msg: (text: String, isUser: Bool)) -> some View {
        HStack {
            if msg.isUser { Spacer() }
            Text(msg.text)
                .padding(10)
                .background(msg.isUser ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(msg.isUser ? .white : .primary)
                .cornerRadius(12)
            if !msg.isUser { Spacer() }
        }
        .frame(maxWidth: .infinity, alignment: msg.isUser ? .trailing : .leading)
    }
}
=======
                // iOS 17 version of onChange
                .onChange(of: viewModel.messages.count) {
                    if let lastId = viewModel.messages.last?.id {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }

            // 3. Input Area
            HStack {
                // Use $ here because it's a Binding variable
                TextField("Enter command...", text: $viewModel.inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        viewModel.sendMessage() // NO $ HERE
                    }
                
                Button("SEND") {
                    viewModel.sendMessage() // NO $ HERE
                }
                .disabled(viewModel.isModelLoading)
            }
            .padding()
        }
        // 4. Initial Setup
        .onAppear {
            Task {
                // Call directly on viewModel without $
                await viewModel.setupModel()
            }
        }
    }
}
>>>>>>> 60b3b5f (Fresh start without heavy files)
