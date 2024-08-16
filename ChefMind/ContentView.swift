//
//  ContentView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sharedViewModel = ViewModel()
    
    var body: some View {
        TabView {
            GroceryView(viewModel: sharedViewModel)
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }
            
            InventoryView(viewModel: sharedViewModel)
                .tabItem {
                    Label("Inventory", systemImage: "cube.box")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
