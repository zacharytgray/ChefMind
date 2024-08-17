//
//  AddItemView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/16/24.
//

import SwiftUI

// Colors

let lightPurple: Color = Color(red: 229/255, green: 204/255, blue: 255/255)
let lightOrange: Color = Color(red: 255/255, green: 229/255, blue: 204/255)


struct AddItemView: View {
    @ObservedObject var viewModel: ViewModel
    var list: ItemType
    @State private var newItemName: String = ""
    @State private var newItemQuantity: Int = 1
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode


    var body: some View {
        VStack {
            Text(list == .grocery ? "Add to Grocery List" : "Add to Inventory")
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
//                        .bold()
                        .padding(.leading, 25)

                    Picker("Quantity", selection: $newItemQuantity) {
                        ForEach(1...99, id: \.self) { number in
                            Text("\(number)")
                                .font(.title2)
//                                .bold()
                        }
                    }
                    .pickerStyle(.wheel)
                    .padding(.trailing)
                    .padding(.top, -30)
                    .frame(width: 100, height: 120)
                }
                .padding(.top)
            }.padding(.bottom, 10)

            Spacer()

            Button(action: {
                if (!newItemName.isEmpty) {
                    viewModel.addItem(GroceryItem(name: newItemName, quantity: newItemQuantity), to: list)
                    presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("Add Item")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        newItemName.isEmpty && list == .grocery ? lightPurple :
                        !newItemName.isEmpty && list == .grocery ? .purple :
                        newItemName.isEmpty && list == .inventory ? lightOrange :
                        !newItemName.isEmpty && list == .inventory ? .orange :
                        Color.gray
                    )
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(height: UIScreen.main.bounds.height / 2.5)  // Set height to half the screen
        .onAppear {
            isNameFieldFocused = true
        }
    }
}

