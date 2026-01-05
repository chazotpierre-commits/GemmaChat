import SwiftUI

struct ContentView: View {
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
                        }
                    }
                    .padding()
                }
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