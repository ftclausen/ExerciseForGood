//
//  ContentView.swift
//  ExerciseForGood
//
//  Created by Friedrich Clausen on 25/6/2025.
//
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Image(systemName: "target")
                    Text("Today")
                }
            
            ProgressView()
                .tabItem {
                    Image(systemName: "chart.bar")
                    Text("Progress")
                }
        }
        .accentColor(.orange)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PushUpDay.self, inMemory: true)
}
