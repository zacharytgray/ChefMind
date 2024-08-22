//
//  ChatView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI
import GoogleGenerativeAI


struct ChatMessage: Identifiable, Equatable, Codable {
    var id = UUID()
    let content: String
    let isUser: Bool
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
            lhs.id == rhs.id && lhs.content == rhs.content && lhs.isUser == rhs.isUser
        }
}

class ChatViewModel: ObservableObject {
    @Published var UIMessages: [ChatMessage] = []
    @Published var error: String?
    private var memoryBuffer: [ModelContent] = []
    private var model: GoogleGenerativeAI.GenerativeModel
    private let sharedViewModel: ViewModel
    @Published var currentStreamingMessage: String = ""
    

    init(apiKey: String, sharedViewModel: ViewModel) {
        self.sharedViewModel = sharedViewModel

        var systemInstructions = "You are a helpful and enthusiastic cooking assistant on an app called ChefMind. You are about to be provided with a user's kitchen and pantry inventory, which they've entered in on this app. They can ask you anything about cooking, meal planning, etc. You are to stay on topic - do not deviate from the topic of cooking and ingredients. Use the provided inventory to help you answer any questions about recipe ideas, or to tell them if they have the right ingredients for a dish. Now, here are the user's inventory items:"
        // Append inventory items to systemInstructions
        sharedViewModel.inventoryItems.forEach { item in
            systemInstructions += "\n- Name: \(item.name), Qty: \(item.quantity)"
        }
        self.model = GenerativeModel(name: "gemini-1.5-flash", apiKey: apiKey, systemInstruction: systemInstructions)
        
        // Load Chat History
        UIMessages = sharedViewModel.chatHistory

        if UIMessages.isEmpty {
            addWelcomeMessage()
        } else {
            // Reconstruct memory buffer from chat history
            for message in UIMessages {
                let role: String = message.isUser ? "user" : "model"
                memoryBuffer.append(ModelContent(role: role, parts: message.content))
            }
        }

    }
    
    
    private func addWelcomeMessage() {
        let welcomeStr = "Hey! I'm your AI Chef. I can see all your inventory items to help you plan your meals, prepare a particular dish, and suggest items to purchase. What can I do for you?"
        let aiWelcomeMsg = ChatMessage(content: welcomeStr, isUser: false)
        UIMessages.append(aiWelcomeMsg)
        memoryBuffer.append(ModelContent(role: "model", parts: welcomeStr))
        sharedViewModel.saveChatHistory(UIMessages)
    }

    func resetChat() {
        UIMessages = []
//        memoryBuffer = memoryBuffer.prefix(1).map { $0 } // Keep only the system message
        memoryBuffer = []
        addWelcomeMessage()
    }

    func sendMessage(_ content: String) async {
        await MainActor.run {
            let userMessage = ChatMessage(content: content, isUser: true)
            self.UIMessages.append(userMessage)
            self.sharedViewModel.saveChatHistory(self.UIMessages)
            self.currentStreamingMessage = "" // Reset streaming message
        }

        let prompt = content

        do {
            
            memoryBuffer.append(ModelContent(role: "user", parts: prompt))
            let chat = model.startChat(history: memoryBuffer)
            for try await chunk in chat.sendMessageStream(prompt) {
                if let text = chunk.text {
                    await MainActor.run {
                        self.currentStreamingMessage += text
                    }
                }
            }
//            let response = try await chat.sendMessage(prompt)
            let aiMessage = ChatMessage(content: currentStreamingMessage, isUser: false)
            
            await MainActor.run {
                self.UIMessages.append(aiMessage)
                memoryBuffer.append(ModelContent(role: "model", parts: aiMessage.content))
                self.currentStreamingMessage = ""
                self.sharedViewModel.saveChatHistory(self.UIMessages)
            }
        } catch {
            await MainActor.run {
                self.error = "Failed to get response: \(error.localizedDescription)"
            }
            print("Failed to get response: \(error)")
            let errorMessage = ChatMessage(content: "Failed to get response: Bad API Key.", isUser: false)
            await MainActor.run {
                self.UIMessages.append(errorMessage)
                self.sharedViewModel.saveChatHistory(self.UIMessages)
            }
            
        }
    }
    func updateAPIKey(_ newKey: String) {
        var systemInstructions = "You are a helpful and enthusiastic cooking assistant on an app called ChefMind. You are about to be provided with a user's kitchen and pantry inventory, which they've entered in on this app. They can ask you anything about cooking, meal planning, etc. You are to stay on topic - do not deviate from the topic of cooking and ingredients. Use the provided inventory to help you answer any questions about recipe ideas, or to tell them if they have the right ingredients for a dish. Now, here are the user's inventory items:"
        // Append inventory items to systemInstructions
        sharedViewModel.inventoryItems.forEach { item in
            systemInstructions += "\n- Name: \(item.name), Qty: \(item.quantity)"
        }

        self.model = GenerativeModel(name: "gemini-1.5-flash", apiKey: newKey, systemInstruction: systemInstructions)
     }
   }


struct ChatView: View {
    @ObservedObject var sharedViewModel: ViewModel
    @StateObject private var chatViewModel: ChatViewModel
    @State private var newMessage: String = ""
    @State private var scrollProxy: ScrollViewProxy?
    @State private var lastMessageId: UUID?
    @FocusState private var isTextFieldFocused: Bool
    @State private var keyboardOffset: CGFloat = 0
    @State private var isSending: Bool = false

    init(sharedViewModel: ViewModel) {
        self.sharedViewModel = sharedViewModel
        _chatViewModel = StateObject(wrappedValue: ChatViewModel(apiKey: sharedViewModel.apiKey, sharedViewModel: sharedViewModel))
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
                            // Display streaming message
                               if !chatViewModel.currentStreamingMessage.isEmpty {
                                   ChatBubble(message: ChatMessage(content: chatViewModel.currentStreamingMessage, isUser: false))
                                       .id("streaming")
                                       .transition(.opacity)
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
                        if let lastMessage = chatViewModel.UIMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
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
                            .foregroundColor(isSending ? .gray : .mint)

                    }
                    .padding(.trailing, 10)
                    .disabled(isSending || newMessage.isEmpty)
                }
                .padding()
            }
            .navigationTitle("ChefMind Chat")
            .navigationBarItems(trailing: Button("Reset") {
                chatViewModel.resetChat()
            })
        }
        .dismissKeyboardOnTap()
        .onChange(of: sharedViewModel.apiKey) {
            chatViewModel.updateAPIKey(sharedViewModel.apiKey)
        }
    }
    private func sendMessage() {
           guard !newMessage.isEmpty && !isSending else { return }
           
           let messageToSend = newMessage
           newMessage = ""
           isSending = true
           
           Task {
               await chatViewModel.sendMessage(messageToSend)
               DispatchQueue.main.async {
                   isSending = false
               }
           }
       }
       
       private func resetChat() {
           Task {
               await MainActor.run {
                   chatViewModel.resetChat()
               }
           }
       }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            Text(message.content)
                .padding()
                .background(
                    Group {
                        if message.content.hasPrefix("Failed to get response:") {
                            LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.5), Color.red]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        } else if message.isUser {
                            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        } else {
                            LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.5), Color.mint.opacity(0.8)]), startPoint: .bottomLeading, endPoint: .topTrailing)
                        }
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
