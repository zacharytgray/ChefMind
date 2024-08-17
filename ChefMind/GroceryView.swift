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
                }
                .onDelete { indexSet in
                    viewModel.removeItem(at: indexSet, from: .grocery)
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
                    .presentationDetents([.fraction(0.5)]) // This limits the sheet to 50% the screen height
            }
        }
    }
}
