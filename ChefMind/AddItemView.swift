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
let darkPurple: Color = Color(red: 51/255, green: 0/255, blue: 102/255)
let darkOrange: Color = Color(red: 102/255, green: 51/255, blue: 0/255)

//newItemName.isEmpty && list == .grocery ? lightPurple :
//!newItemName.isEmpty && list == .grocery ? .purple :
//newItemName.isEmpty && list == .inventory ? lightOrange :
//!newItemName.isEmpty && list == .inventory ? .orange :
//Color.gray
//
//newItemName.isEmpty && list == .grocery ? lightPurple : Color.gray
//(condition) ? color1 : color2

struct AddItemView: View {
    @ObservedObject var viewModel: ViewModel
    var list: ItemType
    @State private var newItemName: String = ""
    @State private var newItemQuantity: Int = 1
    @FocusState private var isNameFieldFocused: Bool
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        let altPurple = (colorScheme == .dark ? darkPurple : lightPurple)
        let altOrange = (colorScheme == .dark ? darkOrange : lightOrange)

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
                viewModel.addItem(GroceryItem(name: newItemName, quantity: newItemQuantity), to: list)
                presentationMode.wrappedValue.dismiss()
                
            }) {
                Text("Add Item")
                    .font(.title2)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        newItemName.isEmpty && list == .grocery ? altPurple :
                        !newItemName.isEmpty && list == .grocery ? .purple :
                        newItemName.isEmpty && list == .inventory ? altOrange :
                        !newItemName.isEmpty && list == .inventory ? .orange :
                        Color.gray
                    )
                    .cornerRadius(10)
            }
            .disabled(newItemName.isEmpty)
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .frame(height: UIScreen.main.bounds.height / 2.5)  // Set height to half the screen
        .onAppear {
            isNameFieldFocused = true
        }
    }
}

