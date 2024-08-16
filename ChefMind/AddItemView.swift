//
//  AddItemView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/16/24.
//

import SwiftUI

struct AddItemView: View {
    @ObservedObject var viewModel: ViewModel
    var list: ItemType
    @State private var newItemName: String = ""
    @State private var newItemQuantity: Int = 1
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Text("Add New Item")
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)
                .padding(.bottom, 30)

            HStack(alignment: .center) {
                TextField("Item Name", text: $newItemName)
                    .font(.title2)
                    .bold()
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .focused($isNameFieldFocused)
                    .padding(.horizontal)
                    .padding(.top, 20)

                VStack(alignment: .leading) {
                    Text("Qty:")
                        .font(.title2)
                        .foregroundColor(.gray)
                        .bold()
                        .padding(.leading, 28)

                    Picker("Quantity", selection: $newItemQuantity) {
                        ForEach(1...99, id: \.self) { number in
                            Text("\(number)")
                                .font(.title2)
                                .bold()
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.horizontal)
                    .padding(.top, -30)
                    .frame(width: 100, height: 120)
                }
                .padding(.top)
            }

            Spacer()

            Button(action: {
                viewModel.addItem(GroceryItem(name: newItemName, quantity: newItemQuantity), to: list)
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Add Item")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }
}
