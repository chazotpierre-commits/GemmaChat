import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var inputText = ""
    @FocusState private var isFocused: Bool

    // Accent colors
    private let green  = Color(red: 0.25, green: 1.0, blue: 0.45)
    private let cyan   = Color(red: 0.25, green: 0.95, blue: 1.0)
    private let purple = Color(red: 0.70, green: 0.45, blue: 1.0)

    init() {
        // Dark keyboard
        UITextField.appearance().keyboardAppearance = .dark
    }

    var body: some View {
        ZStack {
            BackgroundMatrix(green: green, purple: purple)

            VStack(spacing: 0) {
                header

                Divider().overlay(green.opacity(0.22))

                messages
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                Divider().overlay(green.opacity(0.22))

                inputBar
            }
        }
        .preferredColorScheme(.dark)
        .tint(green)
        .task { await viewModel.setupModelIfNeeded() }
        .onAppear { isFocused = true }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Text("GEMMACHAT")
                .font(.system(.headline, design: .monospaced).weight(.bold))
                .foregroundStyle(green)
                .shadow(color: green.opacity(0.35), radius: 10)

            Text("• gemma3-1B-it-int4")
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(cyan.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer()

            statusPill
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.35))
    }

    private var statusPill: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .shadow(color: statusColor.opacity(0.6), radius: 8)

            Text(statusText)
                .font(.system(.caption, design: .monospaced).weight(.semibold))
                .foregroundStyle(Color.white.opacity(0.88))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.black.opacity(0.55), in: Capsule())
        .overlay(Capsule().stroke(green.opacity(0.22), lineWidth: 1))
    }

    private var statusText: String {
        if viewModel.isModelLoading { return "LOADING" }
        if viewModel.isGenerating { return "THINKING" }
        return "READY"
    }

    private var statusColor: Color {
        if viewModel.isModelLoading { return cyan }
        if viewModel.isGenerating { return purple }
        return green
    }

    // MARK: - Messages

    private var messages: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.messages) { msg in
                        TerminalMessageRow(
                            msg: msg,
                            userColor: cyan,
                            aiColor: green,
                            textColor: Color.white.opacity(0.9)
                        )
                        .id(msg.id)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
            .onChange(of: viewModel.messages.count) {
                guard let lastId = viewModel.messages.last?.id else { return }
                withAnimation(.linear(duration: 0.12)) {
                    proxy.scrollTo(lastId, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Input

    private var inputBar: some View {
        HStack(spacing: 10) {
            Text(">")
                .font(.system(.headline, design: .monospaced).weight(.bold))
                .foregroundStyle(green)

            ZStack(alignment: .leading) {
                if inputText.isEmpty {
                    Text("type a message…")
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(Color.white.opacity(0.35))
                }

                TextField("", text: $inputText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .focused($isFocused)
                    .disabled(viewModel.isModelLoading || viewModel.isGenerating)
                    .submitLabel(.send)
                    .onSubmit { send() }
            }

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.black)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle().fill(canSend ? green : Color.gray.opacity(0.35))
                    )
                    .shadow(color: green.opacity(canSend ? 0.35 : 0), radius: 10)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.55))
        .overlay(Rectangle().frame(height: 1).foregroundStyle(green.opacity(0.16)), alignment: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom) // ✅ keyboard-friendly
    }

    private var canSend: Bool {
        let t = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        return !t.isEmpty && !viewModel.isModelLoading && !viewModel.isGenerating
    }

    private func send() {
        let t = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return }
        inputText = ""
        viewModel.sendMessage(t)
    }
}

// MARK: - Row

private struct TerminalMessageRow: View {
    let msg: ChatMessage
    let userColor: Color
    let aiColor: Color
    let textColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(msg.isUser ? "USER>" : "AI>")
                .font(.system(.caption, design: .monospaced).weight(.bold))
                .foregroundStyle(msg.isUser ? userColor : aiColor)
                .shadow(color: (msg.isUser ? userColor : aiColor).opacity(0.35), radius: 8)

            Text(msg.text)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(textColor)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Background (responsive)

private struct BackgroundMatrix: View {
    let green: Color
    let purple: Color

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            ZStack {
                LinearGradient(
                    colors: [
                        Color.black,
                        Color(red: 0.03, green: 0.06, blue: 0.05),
                        Color.black
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Scanlines()
                    .opacity(0.12)
                    .ignoresSafeArea()

                // Responsive glows
                Circle()
                    .fill(green.opacity(0.08))
                    .frame(width: size * 0.9, height: size * 0.9)
                    .blur(radius: 40)
                    .offset(x: -size * 0.28, y: -size * 0.35)

                Circle()
                    .fill(purple.opacity(0.06))
                    .frame(width: size, height: size)
                    .blur(radius: 60)
                    .offset(x: size * 0.32, y: size * 0.40)
            }
        }
    }
}

// MARK: - Scanlines

private struct Scanlines: View {
    var body: some View {
        GeometryReader { geo in
            let h = geo.size.height
            let step: CGFloat = 3

            VStack(spacing: 0) {
                ForEach(0..<Int(h / step), id: \.self) { i in
                    Rectangle()
                        .fill(i.isMultiple(of: 2) ? Color.white.opacity(0.04) : Color.clear)
                        .frame(height: 1)
                    Rectangle().fill(Color.clear).frame(height: 2)
                }
            }
        }
        .blendMode(.overlay)
    }
}
