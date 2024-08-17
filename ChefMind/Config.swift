//
//  Config.swift
//  ChefMind
//
//  Created by Zachary Gray on 8/17/24.
//

import Foundation

struct Config {
    static let apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist["APIKey"] as? String else {
            fatalError("Couldn't find 'Secrets.plist' or 'APIKey' in it.")
        }
        return value
    }()
}
