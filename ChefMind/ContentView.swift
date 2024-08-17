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
let notSelectedColor = Color.gray

struct ContentView: View {
    @StateObject private var sharedViewModel = ViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
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

            ChatView(sharedViewModel: sharedViewModel)
                .tabItem {
                    Label("Chat", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(2)
                .tint(selectedTab == 2 ? chatColor : notSelectedColor)
                .accentColor(selectedTab == 2 ? chatColor : notSelectedColor)
                
        }
        .accentColor(
            selectedTab == 0 ? groceryColor :
            selectedTab == 1 ? inventoryColor :
            selectedTab == 2 ? chatColor : notSelectedColor
        )

    }
        
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
