//
//  ExerciseForGoodApp.swift
//  ExerciseForGood
//
//  Created by Fred Clausen on 22/6/2025.
//

import SwiftUI
import SwiftData

@main
struct ExerciseForGoodApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PushUpDay.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
