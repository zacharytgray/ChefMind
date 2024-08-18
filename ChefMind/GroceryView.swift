//
//  GroceryView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct GroceryView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isAddItemViewPresented = false
    @State private var isEditViewPresented = false
    @State private var editingItem: GroceryItem?
    @State private var editedItemName: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.groceryItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        HStack(spacing: 5) {
                            Text("Qty: \(item.quantity) ")
                                .frame(minWidth: 25, alignment: .trailing)
                                .foregroundColor(.gray)
                            Stepper("", value: Binding(
                                get: { item.quantity },
                                set: { viewModel.updateQuantity(for: item, newQuantity: $0, in: .grocery) }
                            ), in: 0...99)
                            .labelsHidden()
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            viewModel.moveToInventory(item)
                        } label: {
                            Label("Purchased", systemImage: "cart.badge.plus")
                        }
                        .tint(.orange)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            if let index = viewModel.groceryItems.firstIndex(where: { $0.id == item.id }) {
                                viewModel.removeItem(at: IndexSet(integer: index), from: .grocery)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash.fill")
                        }
                        .tint(.red)
                        Button {
                            editingItem = item
                            editedItemName = item.name
                            isEditViewPresented = true
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }
                        .tint(.blue)
                    }
                }
            }
            .navigationTitle("Grocery List")
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        isAddItemViewPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.purple)
                    }.padding(.bottom, 40)
                }
            )
            .sheet(isPresented: $isAddItemViewPresented) {
                AddItemView(viewModel: viewModel, list: .grocery)
                    .presentationDetents([.fraction(0.5)])
            }
            .alert("Edit Item", isPresented: $isEditViewPresented) {
                TextField("Item Name", text: $editedItemName)
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    if let editingItem = editingItem,
                       let index = viewModel.groceryItems.firstIndex(where: { $0.id == editingItem.id }) {
                        var updatedItem = editingItem
                        updatedItem.name = editedItemName
                        viewModel.groceryItems[index] = updatedItem
                        viewModel.saveItems()
                    }
                }
            } message: {
                Text("Enter the new name for this item")
            }
        }
    }
}
