//
//  GroceryListView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct GroceryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    var isChecked: Bool = false
    
    init(id: UUID = UUID(), name: String, quantity: Int, isChecked: Bool = false) {
            self.id = id
            self.name = name
            self.quantity = quantity
            self.isChecked = isChecked
        }
}

class GroceryListViewModel: ObservableObject {
    @Published var items: [GroceryItem] = [] {
        didSet {
            saveItems()
        }
    }
    var onMoveToInventory: ((GroceryItem) -> Void)?
    
    init() {
        loadItems()
    }
 
    func addItem(_ name: String, quantity: Int = 1) {
        if let index = items.firstIndex(where: {$0.name == name }) {
            items[index].quantity += quantity
        } else {
            items.append(GroceryItem(name: name, quantity: quantity))
        }
    }
    
    func removeItem(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveToInventory(_ item: GroceryItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            onMoveToInventory?(item)
        }
    }
    
    func updateQuantity(for item: GroceryItem, newQuantity: Int) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].quantity = newQuantity
            if items[index].quantity <= 0 {
                items.remove(at: index)
            }
        }
    }
    
    private func saveItems() {
        if let encodedData = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encodedData, forKey: "groceryItems")
        }
    }
    
    private func loadItems() {
        if let savedItems = UserDefaults.standard.data(forKey: "groceryItems"),
           let decodedItems = try? JSONDecoder().decode([GroceryItem].self, from: savedItems) {
            items = decodedItems
        }
    }
}

struct GroceryListView: View {
    @ObservedObject var viewModel: GroceryListViewModel
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
                            Spacer()
                        }
                        .swipeActions(edge: .trailing) {
                            Button(action: {
                                viewModel.moveToInventory(item)
                            }) {
                                Label("Move to Inventory", systemImage: "cart.badge.plus")
                            }
                            .tint(.blue)
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
                        if !newItemName.isEmpty { // If the name field has text in it
                            
                            if newItemQuantity.isEmpty { // If qty field is empty
                                viewModel.addItem(newItemName, quantity: 1)
                            } else if let quantity = Int(newItemQuantity) { // If qty is not empty and can be converted to an Int
                                viewModel.addItem(newItemName, quantity: quantity)
                            } else {
                                // Handle the case where the quantity is not empty but is not a valid integer.
                                print("Invalid quantity")
                            }
                            
                            newItemName = ""
                            newItemQuantity = ""
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                }
                .navigationTitle("Grocery List")
            }
        }
    }
}
