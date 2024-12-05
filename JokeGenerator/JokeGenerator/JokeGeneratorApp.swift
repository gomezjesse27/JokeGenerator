//
//  JokeGeneratorApp.swift
//  JokeGenerator
//
//  Created by Jaysen Gomez on 12/5/24.
//

import SwiftUI

@main
struct JokeGeneratorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
