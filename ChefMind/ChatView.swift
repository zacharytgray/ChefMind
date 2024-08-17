//
//  ChatView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI
import SwiftOpenAI

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let content: String
    let isUser: Bool
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
            lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
        }
}

class ChatViewModel: ObservableObject {
    @Published var UIMessages: [ChatMessage] = []
    private var memoryBuffer: [ChatCompletionParameters.Message]
    private let service: OpenAIService
    private let sharedViewModel: ViewModel
    
    init(apiKey: String, sharedViewModel: ViewModel) {
        self.service = OpenAIServiceFactory.service(apiKey: Config.apiKey)
        self.sharedViewModel = sharedViewModel
        
        var systemInstructions = "You are a helpful and enthusiastic cooking assistant on an app called ChefMind. You are about to be provided with a user's kitchen and pantry inventory, which they've entered in on this app. They can ask you anything about cooking, meal planning, etc. You are to stay on topic - do not deviate from the topic of cooking and ingredients. Use the provided inventory to help you answer any questions about recipe ideas, or to tell them if they have the right ingredients for a dish. Now, here are the user's inventory items:"
        
        // Append inventory items to systemInstructions
        sharedViewModel.inventoryItems.forEach { item in
            systemInstructions += "\n- Name: \(item.name), Qty: \(item.quantity)"
        }
            
        memoryBuffer = [ChatCompletionParameters.Message(role: .system, content: .text(systemInstructions))]
    }

    // Create new messages with: ChatCompletionParameters.Message(role: .system, content: .text(queryStr)

    func sendMessage(_ content: String) async {
        let userMessage = ChatMessage(content: content, isUser: true)
        
        // Update UI messages on the main thread
        DispatchQueue.main.async {
            self.UIMessages.append(userMessage)
        }

        let prompt = userMessage.content
        memoryBuffer.append(ChatCompletionParameters.Message(role: .user, content: .text(prompt)))
        let parameters = ChatCompletionParameters(messages: memoryBuffer, model: .gpt4omini)

        do {


            let chatCompletionObject = try await service.startChat(parameters: parameters)
            let chatCompletionStr = chatCompletionObject.choices[0].message.content
            
            memoryBuffer.append(ChatCompletionParameters.Message(role: .assistant, content: .text(chatCompletionStr!)))
                            
            let aiMessage = ChatMessage(content: chatCompletionStr!, isUser: false)
            
            // Update UI messages on the main thread
            DispatchQueue.main.async {
                self.UIMessages.append(aiMessage)
            }
        } catch {
            print("Failed to get response: \(error)")
        }
    }
}

struct ChatView: View {
    @StateObject private var chatViewModel: ChatViewModel
    @State private var newMessage: String = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastMessageId: UUID?
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardOffset: CGFloat = 0
    
    init(sharedViewModel: ViewModel) {
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(apiKey: Config.apiKey, sharedViewModel: sharedViewModel))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack {
                            ForEach(chatViewModel.UIMessages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                    .onChange(of: chatViewModel.UIMessages) { oldMessages, newMessages in
                        if let lastMessage = newMessages.last {
                            lastMessageId = lastMessage.id
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onAppear {
                        scrollProxy = proxy
                    }
                }
                
                HStack {
                    TextField("Type a message", text: $newMessage)
                        .textFieldStyle(.roundedBorder)
                        .padding(15)
                        .focused($isTextFieldFocused)
                    
                    Button(action: {
                        Task {
                            let query = newMessage
                            if !query.isEmpty {
                                newMessage = ""
                                await chatViewModel.sendMessage(query)
                            }
                        }
                    }) {
                        Image(systemName: "arrowshape.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.mint)
                    }
                    .padding(.trailing, 10)
                }
                .padding()
            }
            .navigationTitle("AI Chef Chat")
            .offset(y: -keyboardOffset)
            .animation(.easeOut(duration: 0.2), value: keyboardOffset)
        }
        .dismissKeyboardOnTap()
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(message.isUser ? Color.gray : Color.mint)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}

