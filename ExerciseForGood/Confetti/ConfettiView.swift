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
    @State var animate = false
    @State var fallSpeed = Double.random(in: 1.5...3.5)
    @State var horizontalDrift = Double.random(in: -50...50)
    @State var rotation = Double.random(in: 0...360)
    @State var yPosition: CGFloat = -50
    
    let radius = CGFloat.random(in: 5...10)
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    var body: some View {
        Circle()
            .fill(Color.orange)
            .frame(width: radius * 2, height: radius * 2)
            .position(x: CGFloat.random(in: 0...screenWidth), y: yPosition)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                animate = true
                withAnimation(.linear(duration: fallSpeed)) {
                    yPosition = screenHeight + 50
                }
                withAnimation(.linear(duration: fallSpeed)) {
                    rotation += 360
                }
            }
    }
}
