//
//  salary_widgetApp.swift
//  salary-widget
//
//  Created by Airing on 2025/7/19.
//

import SwiftUI

@main
struct salary_widgetApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
