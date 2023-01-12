//
//  ReferencePromptsApp.swift
//  ReferencePrompts
//
//  Created by Nathanael Roberton on 1/9/23.
//

import SwiftUI

@main
struct ReferencePromptsApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
