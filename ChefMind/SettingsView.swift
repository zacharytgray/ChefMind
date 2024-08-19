//
//  SettingsView.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/18/24.
//

import SwiftUI

struct SettingsView: View {
//    @AppStorage("openAIAPIKey") private var apiKey: String = ""
    @ObservedObject var viewModel: ViewModel
    @State private var tempAPIKey: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("OpenAI API Key")) {
                    SecureField("Enter your API Key", text: $tempAPIKey)
                    Button("Save API Key") {
                        viewModel.saveAPIKey(tempAPIKey)
                        tempAPIKey = ""
                        showAlert = true
                    }
                }
                
                Section(header: Text("Current API Key")) {
                    if !viewModel.apiKey.isEmpty {
                         Text("API Key is set")
                             .foregroundColor(.green)
                         Button("Delete API Key") {
                             viewModel.deleteAPIKey()
                         }
                         .foregroundColor(.red)
                     } else {
                         Text("No API Key set")
                             .foregroundColor(.red)
                     }
                 
                }
            }
            .navigationTitle("Settings")
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("API Key Saved"),
                    message: Text("Your OpenAI API Key has been saved."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }.dismissKeyboardOnTap()
    }
}
