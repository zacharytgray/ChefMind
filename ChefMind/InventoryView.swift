//
//  InventoryView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct InventoryItem: Identifiable {
    let id = UUID()
    var name: String
    var quantity: Int
}

class InventoryViewModel: ObservableObject {
    @Published var items: [InventoryItem] = []
    
    func addItem(_ item: GroceryItem) {
        let name = item.name
        let quantity = item.quantity
        
        if let index = items.firstIndex(where: { $0.name == name }) {
            items[index].quantity += quantity
        } else {
            items.append(InventoryItem(name: name, quantity: quantity))
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func updateQuantity(for item: InventoryItem, newQuantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity = newQuantity
            if items[index].quantity <= 0 {
                items.remove(at: index)
            }
        }
    }
}

struct InventoryView: View {
    @ObservedObject var viewModel: InventoryViewModel
    @State private var newItemName: String = ""
    @State private var newItemQuantity: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.items) { item in
                        HStack {
                            Text(item.name)
                            Spacer()
                            Text("Qty: \(item.quantity)")
                            Stepper("", value: Binding(
                                get: { item.quantity },
                                set: { viewModel.updateQuantity(for: item, newQuantity: $0) }
                            ), in: 0...100)
                        }
                        .swipeActions(edge: .leading) {
                                                    Button(role: .destructive) {
                                                        if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                            viewModel.removeItem(at: IndexSet(integer: index))
                                                        }
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                }
                    }
                    .onDelete(perform: viewModel.removeItem)
                }
                .dismissKeyboardOnTap()
                
                
                HStack {
                    TextField("New item", text: $newItemName)
                    TextField("Qty", text: $newItemQuantity)
                        .keyboardType(.numberPad)
                    Button("Add") {
                        if let quantity = Int(newItemQuantity), !newItemName.isEmpty {
                            viewModel.addItem(GroceryItem(name:newItemName, quantity: quantity))
                            newItemName = ""
                            newItemQuantity = ""
                        }
                    }
                }
                .padding()
                .background(Color.secondary.opacity(0.1))
            }
            .navigationTitle("Inventory")
        }
    }
}
