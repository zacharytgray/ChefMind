//
//  GroceryItem.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/16/24.
//

import Foundation

struct GroceryItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var quantity: Int
    
    init(id: UUID = UUID(), name: String, quantity: Int) {
        self.id = id
        self.name = name
        self.quantity = quantity
    }
}
