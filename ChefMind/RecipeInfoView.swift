//
//  RecipeInfoView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/25/24.
//


import SwiftUI
struct RecipeInfoView: View {
    var recipe: Recipe
    
    @Environment(\.presentationMode) var presentationMode
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text(recipe.name)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .padding()
                Text("Ingredients")
                    .font(.headline)
                    .bold()
                ForEach(recipe.ingredients, id: \.self) { ingredient in
                    Text("• \(ingredient)")
                        .font(.subheadline)
                }
            }
            .frame(maxWidth: .infinity)
        }

    }

}
