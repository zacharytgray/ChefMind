//
//  InventoryView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/15/24.
//

import SwiftUI

struct InventoryView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var isAddItemViewPresented = false
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.inventoryItems) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        HStack(spacing: 5) {
                            Text("Qty: \(item.quantity) ")
                                .frame(minWidth: 25, alignment: .trailing)
                                .foregroundColor(.gray)
                            Stepper("", value: Binding(
                                get: { item.quantity },
                                set: { newQuantity in
                                    viewModel.updateQuantity(for: item, newQuantity: newQuantity, in: .inventory)
                                }
                            ), in: 0...99)
                            .labelsHidden()
                        }
                    }
                }
                .onDelete { indexSet in
                    viewModel.removeItem(at: indexSet, from: .inventory)
                }
            }
            .navigationTitle("Inventory")
            .overlay(
                VStack {
                    Spacer()
                    Button(action: {
                        isAddItemViewPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.orange)
                    }.padding(.bottom, 40)
                    }
                )
            .sheet(isPresented: $isAddItemViewPresented) {
                AddItemView(viewModel: viewModel, list: .inventory)
                    .presentationDetents([.fraction(0.5)]) // This limits the sheet to 50% the screen height

            }
        }
    }
}
