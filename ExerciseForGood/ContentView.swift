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
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor.gray
            
            // Keep selected color as orange (this will respect your .accentColor)
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor.orange
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.orange]
            
            UITabBar.appearance().standardAppearance = appearance
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: PushUpDay.self, inMemory: true)
}
