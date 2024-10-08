//
//  ViewModel.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/16/24.
//

import SwiftUI

class ViewModel: ObservableObject {
    @Published var groceryItems: [GroceryItem] = []
    @Published var inventoryItems: [GroceryItem] = []
    @Published var chatHistory: [ChatMessage] = []
    @Published var apiKey: String = ""
    
    private let apiKeyKey = "openAIAPIKey"

    init() {
        loadItems()
        loadChatHistory()
        loadAPIKey()
    }

    func addItem(_ item: GroceryItem, to list: ItemType) {
        switch list {
        case .grocery:
            if let index = groceryItems.firstIndex(where: { $0.name == item.name }) {
                groceryItems[index].quantity += item.quantity
            } else {
                groceryItems.append(item)
            }
        case .inventory:
            if let index = inventoryItems.firstIndex(where: { $0.name == item.name }) {
                inventoryItems[index].quantity += item.quantity
            } else {
                inventoryItems.append(item)
            }
        }
        saveItems()
    }

    func removeItem(at offsets: IndexSet, from list: ItemType) {
        switch list {
        case .grocery:
            groceryItems.remove(atOffsets: offsets)
        case .inventory:
            inventoryItems.remove(atOffsets: offsets)
        }
        saveItems()
    }
    
    func moveToInventory(_ item: GroceryItem) {
        if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
            groceryItems.remove(at: index)
            addItem(item, to: .inventory)
        }
    }
    
    func getInventoryItems() -> [GroceryItem] {
        return inventoryItems
    }

    func updateQuantity(for item: GroceryItem, newQuantity: Int, in list: ItemType) {
        switch list {
        case .grocery:
            if let index = groceryItems.firstIndex(where: { $0.id == item.id }) {
                groceryItems[index].quantity = newQuantity
                if groceryItems[index].quantity <= 0 {
                    groceryItems.remove(at: index)
                }
            }
        case .inventory:
            if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
                inventoryItems[index].quantity = newQuantity
                if inventoryItems[index].quantity <= 0 {
                    inventoryItems.remove(at: index)
                }
            }
        }
        saveItems()
    }
    
    func saveChatHistory(_ messages: [ChatMessage]) {
        chatHistory = messages
        if let encodedChat = try? JSONEncoder().encode(chatHistory) {
            UserDefaults.standard.set(encodedChat, forKey: "chatHistory")
        }
    }

    private func loadChatHistory() {
        if let savedChatHistory = UserDefaults.standard.data(forKey: "chatHistory"),
           let decodedChatHistory = try? JSONDecoder().decode([ChatMessage].self, from: savedChatHistory) {
            chatHistory = decodedChatHistory
        }
    }

    public func saveItems() {
        if let encodedGrocery = try? JSONEncoder().encode(groceryItems) {
            UserDefaults.standard.set(encodedGrocery, forKey: "groceryItems")
        }
        if let encodedInventory = try? JSONEncoder().encode(inventoryItems) {
            UserDefaults.standard.set(encodedInventory, forKey: "inventoryItems")
        }
    }

    private func loadItems() {
        if let savedGroceryItems = UserDefaults.standard.data(forKey: "groceryItems"),
           let decodedGroceryItems = try? JSONDecoder().decode([GroceryItem].self, from: savedGroceryItems) {
            groceryItems = decodedGroceryItems
        }
        
        if let savedInventoryItems = UserDefaults.standard.data(forKey: "inventoryItems"),
           let decodedInventoryItems = try? JSONDecoder().decode([GroceryItem].self, from: savedInventoryItems) {
            inventoryItems = decodedInventoryItems
        }
    }
    
//    func saveAPIKey(_ key: String) {
//        let data = key.data(using: .utf8)!
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: apiKeyKey,
//            kSecValueData as String: data
//        ]
//        
//        SecItemDelete(query as CFDictionary)
//        
//        let status = SecItemAdd(query as CFDictionary, nil)
//        if status == errSecSuccess {
//            DispatchQueue.main.async {
//                self.apiKey = key
//            }
//        }
//    }
    
//    func loadAPIKey() {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: apiKeyKey,
//            kSecReturnData as String: true
//        ]
//        
//        var result: AnyObject?
//        let status = SecItemCopyMatching(query as CFDictionary, &result)
//        
//        if status == errSecSuccess {
//            if let data = result as? Data,
//               let key = String(data: data, encoding: .utf8) {
//                DispatchQueue.main.async {
//                    self.apiKey = key
//                }
//            }
//        }
//    }
    
    func loadAPIKey() {
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
           let xml = FileManager.default.contents(atPath: path),
           let plist = try? PropertyListSerialization.propertyList(from: xml, options: .mutableContainersAndLeaves, format: nil) as? [String: Any] {
            
            if let apiKey = plist["APIKey"] as? String {
                self.apiKey = apiKey
            }
        }
    }
 
//    func deleteAPIKey() {
//        let query: [String: Any] = [
//            kSecClass as String: kSecClassGenericPassword,
//            kSecAttrAccount as String: apiKeyKey
//        ]
//        
//        let status = SecItemDelete(query as CFDictionary)
//        if status == errSecSuccess || status == errSecItemNotFound {
//            DispatchQueue.main.async {
//                self.apiKey = ""
//            }
//        }
//    }

}

enum ItemType {
    case grocery
    case inventory
}
