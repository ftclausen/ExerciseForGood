//
//  ConfettiView.swift
//  ExerciseForGood
//
//  Created by Friedrich Clausen on 29/6/2025.
//

import Foundation
import UIKit
import SwiftUI

struct ConfettiView: View {
    @State private var animate = false
    @State private var isVisible = true
    @State private var fallSpeed = Double.random(in: 1.5...3.5)
    @State private var horizontalDrift = Double.random(in: -50...50)
    @State private var rotation = Double.random(in: 0...360)
    @State private var yPosition: CGFloat = -50

    private let radius = CGFloat.random(in: 5...10)
    private let screenWidth = UIScreen.main.bounds.width
    private let screenHeight = UIScreen.main.bounds.height

    private let useRainbowColours: Bool = true

    private let rainbowColors: [Color] = [
        .red,
        .orange,
        .yellow,
        .green,
        .blue,
        Color(red: 0.29, green: 0, blue: 0.51), // Indigo
        .purple
    ]

    private func getRandomRainbowColor() -> Color {
        return rainbowColors.randomElement() ?? .orange
    }

    var body: some View {
        Group {
            if isVisible {
                Circle()
                    .fill(useRainbowColours ? getRandomRainbowColor() : .orange)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: CGFloat.random(in: 0...screenWidth), y: yPosition)
                    .rotationEffect(.degrees(rotation))
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        animate = true

        withAnimation(.linear(duration: fallSpeed)) {
            yPosition = screenHeight + 50
        }

        withAnimation(.linear(duration: fallSpeed)) {
            rotation += 360
        }

        // Remove the confetti piece after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + fallSpeed + 0.1) {
            isVisible = false
        }
    }
}
