//
//  ContentView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

let groceryColor = Color.purple
let inventoryColor = Color.orange
let chatColor = Color.mint
let settingsColor = Color.blue
let notSelectedColor = Color.gray

struct ContentView: View {
    @StateObject private var sharedViewModel = ViewModel()
    @State private var selectedTab = 0
    @AppStorage("openAIAPIKey") private var apiKey: String = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                GroceryView(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Grocery", systemImage: "cart")
                    }
                    .tag(0)
                    .tint(selectedTab == 0 ? groceryColor : notSelectedColor)
                    .accentColor(selectedTab == 0 ? groceryColor : notSelectedColor)

                InventoryView(viewModel: sharedViewModel)
                    .tabItem {
                        Label("Inventory", systemImage: "archivebox")
                    }
                    .tag(1)
                    .tint(selectedTab == 1 ? inventoryColor : notSelectedColor)
                    .accentColor(selectedTab == 1 ? inventoryColor : notSelectedColor)

                Group {
                    if !sharedViewModel.apiKey.isEmpty {
                        ChatView(sharedViewModel: sharedViewModel)
                    } else {
                        APIKeyPromptView()
                    }

                }
                    .tabItem {
                        Label("Chat", systemImage: "bubble.left.and.bubble.right")
                    }
                    .tag(2)
                    .tint(selectedTab == 2 ? chatColor : notSelectedColor)
                    .accentColor(selectedTab == 2 ? chatColor : notSelectedColor)
                RecipeView(sharedViewModel: sharedViewModel)
                    .tabItem {
                        Label("Recipes", systemImage: "fork.knife")
                    }
                    .tag(3)
                    .tint(
                        selectedTab == 3 ? settingsColor : notSelectedColor
                    )
                    .accentColor(selectedTab == 3 ? settingsColor : notSelectedColor)
            }
                .toolbarBackground(.visible, for: .tabBar)
            
        }
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .accentColor(
            selectedTab == 0 ? groceryColor :
            selectedTab == 1 ? inventoryColor :
            selectedTab == 2 ? chatColor :
            selectedTab == 3 ? settingsColor :
            notSelectedColor
        )
    }
        
}

struct APIKeyPromptView: View {
    var body: some View {
        VStack {
            Text("Please enter your OpenAI API Key in the Settings tab to use the chat feature.")
                .multilineTextAlignment(.center)
                .padding()
            
            Image(systemName: "key")
                .font(.system(size: 50))
                .foregroundColor(.gray)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
