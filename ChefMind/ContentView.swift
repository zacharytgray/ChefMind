//
//  ContentView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var inventoryViewModel = InventoryViewModel()
    @StateObject private var groceryListViewModel = GroceryListViewModel()
    
    var body: some View {
        TabView {
            GroceryListView(viewModel: groceryListViewModel)
                .tabItem {
                    Label("Grocery", systemImage: "cart")
                }
            
            InventoryView(viewModel: inventoryViewModel)
                .tabItem {
                    Label("Inventory", systemImage: "cube.box")
                }
            
            ChatView()
                .tabItem {
                    Label("Chat", systemImage: "message")
                }
        }
        .onAppear {
            groceryListViewModel.onMoveToInventory = { itemName in
                inventoryViewModel.addItem(itemName)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
