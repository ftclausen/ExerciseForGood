//
//  ConfettiContainerView.swift
//  ExerciseForGood
//
//  Created by Friedrich Clausen on 29/6/2025.
//
import SwiftUI
import os.log

struct ConfettiContainerView: View {
    var count: Int = 70

    private let logger = Logger(subsystem: "uk.derfcloud.ExerciseForGood", category: "ConfettiContainerView")

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                ConfettiView()
                    .animation(.linear(duration: Double.random(in: 1.5...3.5)).delay(Double(index) * 0.05), value: true)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            logger.log(level: .info, "Finished rendering confetti with \(count) orange circles")
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
