//
//  AddRecipeView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/22/24.
//

import SwiftUI
struct AddRecipeView {
    var recipe: Recipe = Recipe(id: UUID(), name: "", ingredients: [])
    let sharedViewModel: ViewModel
    
    init(sharedViewModel: ViewModel) {
        self.sharedViewModel = sharedViewModel
    }
    
    var body: some View {
        VStack {
            Text("Add Recipe")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
        }
    }

}
