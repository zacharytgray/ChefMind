//
//  ChatView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
}

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    
    func sendMessage(_ content: String) {
        let userMessage = ChatMessage(content: content, isUser: true)
        messages.append(userMessage)
        
        // Placeholder for API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let response = "This is a placeholder response. In the future, this will use the OpenAI API to suggest recipes based on your inventory."
            let aiMessage = ChatMessage(content: response, isUser: false)
            self.messages.append(aiMessage)
        }
    }
}

struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @State private var newMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    ForEach(viewModel.messages) { message in
                        ChatBubble(message: message)
                    }
                }
                
                HStack {
                    TextField("Type a message", text: $newMessage)
                    Button("Send") {
                        viewModel.sendMessage(newMessage)
                        newMessage = ""
                    }
                }
                .padding()
            }
            .navigationTitle("Recipe Chat")
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
                .background(message.isUser ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(10)
            if !message.isUser { Spacer() }
        }
        .padding(.horizontal)
    }
}
