import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""

    var body: some View {
        VStack(spacing: 0) {
            Text("GemmaChat")
                .font(.headline)
                .padding(.vertical, 12)

            Divider()

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.messages) { msg in
                            chatBubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: viewModel.messages.count) {
                    guard let lastId = viewModel.messages.last?.id else { return }
                    withAnimation {
                        proxy.scrollTo(lastId, anchor: .bottom)
                    }
                }
            }

            Divider()

            HStack(spacing: 10) {
                TextField("Message…", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                    .disabled(viewModel.isGenerating || viewModel.isModelLoading)
                    .onSubmit { send() }

                Button(action: send) {
                    if viewModel.isGenerating || viewModel.isModelLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                          || viewModel.isGenerating
                          || viewModel.isModelLoading)
            }
            .padding()
        }
        .task {
            await viewModel.setupModelIfNeeded()
        }
    }

    private func send() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        viewModel.sendMessage(text)
    }

    @ViewBuilder
    private func chatBubble(_ msg: ChatMessage) -> some View {
        HStack {
            if msg.isUser { Spacer(minLength: 40) }

            Text(msg.text)
                .padding(10)
                .background(msg.isUser ? Color.blue : Color.gray.opacity(0.15))
                .foregroundColor(msg.isUser ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            if !msg.isUser { Spacer(minLength: 40) }
        }
        .frame(maxWidth: .infinity, alignment: msg.isUser ? .trailing : .leading)
    }
}
