//
//  RecipesListView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/22/24.
//

import SwiftUI
import Foundation

struct Recipe: Identifiable, Codable {
    var id = UUID()
    var name: String
    var ingredients: [String]
    
    
    init(id: UUID = UUID(), name: String, ingredients: [String]) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
    }
}

struct RecipesListView: View {
    private let sharedViewModel: ViewModel
    @State private var isAddRecipeViewPresented = false


    @State private var recipes: [Recipe] = [
        Recipe(name: "Pasta Carbonara", ingredients: ["Spaghetti", "Eggs", "Pancetta", "Parmesan cheese", "Black pepper"]),
        Recipe(name: "Chicken Stir Fry", ingredients: ["Chicken breast", "Mixed vegetables", "Soy sauce", "Ginger", "Garlic"]),
        Recipe(name: "Beef Tacos", ingredients: ["Ground beef", "Taco shells", "Lettuce", "Tomatoes", "Cheddar cheese"]),
        Recipe(name: "Caesar Salad", ingredients: ["Romaine lettuce", "Croutons", "Caesar dressing", "Parmesan cheese", "Anchovies"]),
        Recipe(name: "Margherita Pizza", ingredients: ["Pizza dough", "Tomato sauce", "Fresh mozzarella", "Basil", "Olive oil"]),
        Recipe(name: "Mushroom Risotto", ingredients: ["Arborio rice", "Mushrooms", "Onion", "Parmesan cheese", "White wine"]),
        Recipe(name: "Grilled Salmon", ingredients: ["Salmon fillets", "Lemon", "Olive oil", "Garlic", "Fresh dill"]),
        Recipe(name: "Vegetable Curry", ingredients: ["Mixed vegetables", "Coconut milk", "Curry powder", "Onion", "Garlic"]),
    ]
        // Add more recipes as needed

    
    @State private var expandedRecipeId: UUID?
    let edgePadding: CGFloat = 20
    let interItemSpacing: CGFloat = 20
    
    init(sharedViewModel: ViewModel) {
        self.sharedViewModel = sharedViewModel
        
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ScrollView {
                    let availableWidth = geometry.size.width - (edgePadding * 2) - interItemSpacing
                    let itemWidth = (availableWidth / 2) + (interItemSpacing / 2) // Adjusted item width

                    LazyVGrid(
                        columns: [
                            GridItem(.fixed(itemWidth)),
                            GridItem(.fixed(itemWidth))
                        ],
                        spacing: interItemSpacing
                    ) {
                        ForEach(recipes) { recipe in
                            RecipeCard(recipe: recipe, isExpanded: expandedRecipeId == recipe.id)
                                .onTapGesture {
                                    withAnimation(.bouncy) {
                                        if expandedRecipeId == recipe.id {
                                            expandedRecipeId = nil
                                        } else {
                                            expandedRecipeId = recipe.id
                                        }
                                    }
                                }
                        }
                    }
                    .padding(.vertical, 10)
                }
            }
//            .navigatior
        }
    }
}

struct RecipeCard: View {
    let recipe: Recipe
    let isExpanded: Bool
    @State private var isAddRecipeViewPresented = false
    @State private var isInfoViewPresented = false
     
     var body: some View {
         VStack {
             if !isExpanded {
                 VStack {
                     Text(recipe.name)
                         .font(.headline)
                         .multilineTextAlignment(.center)
                         .lineLimit(3)
                         .minimumScaleFactor(0.7)
                         .frame(height: 60)
                 }
                 .padding(8)  // Reduced internal padding
                 .frame(width: 170, height: 100)
                 
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                    
                    Text("Ingredients:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    ForEach(recipe.ingredients.prefix(5), id: \.self) { ingredient in
                        Text("• \(ingredient)")
                            .font(.subheadline)
                    }
                    if recipe.ingredients.count > 5 {
                        Text("...")
                            .font(.subheadline)
                            .italic()
                    }
                    Button(action: {
                        isInfoViewPresented = true
                    }) {
                        Label("Recipe Info", systemImage: "info.circle.fill")
                    }
                    // Add Another button in hstack with first button to "cook now" and skip info panel
                }
                .padding()
                .frame(width: 170)
                .sheet(isPresented: $isInfoViewPresented) {
                    RecipeInfoView(recipe: recipe)
                        .presentationDetents([.fraction(0.5)])

                }
            }
        }
         .frame(maxWidth: .infinity)
         .aspectRatio(isExpanded ? nil : 1, contentMode: .fit)
         .background(LinearGradient(gradient: Gradient(colors: [Color.mint.opacity(0.5), Color.mint]), startPoint: .bottomLeading, endPoint: .topTrailing))
         .cornerRadius(12)

    }
}

struct RecipesListView_Previews: PreviewProvider {
    static var previews: some View {
        RecipesListView(sharedViewModel: ViewModel())
    }
}
