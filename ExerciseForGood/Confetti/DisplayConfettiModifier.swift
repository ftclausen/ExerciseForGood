//
//  DisplayConfettiModifier.swift
//  ExerciseForGood
//
//  Created by Friedrich Clausen on 29/6/2025.
//
import SwiftUI

struct DisplayConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    @State private var opacity = 1.0

    private let animationTime = 3.0
    private let fadeTime = 2.0

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .overlay(
                    Group {
                        if isActive {
                            ConfettiContainerView()
                                .opacity(opacity)
                        }
                    }
                )
                .sensoryFeedback(.success, trigger: isActive)
                .onChange(of: isActive) { _, newValue in
                    if newValue {
                        startConfettiSequence()
                    } else {
                        opacity = 1.0 // Reset for next time
                    }
                }
        } else {
            content
                .overlay(
                    Group {
                        if isActive {
                            ConfettiContainerView()
                                .opacity(opacity)
                        }
                    }
                )
                .onChange(of: isActive) { newValue in
                    if newValue {
                        startConfettiSequence()
                    } else {
                        opacity = 1.0 // Reset for next time
                    }
                }
        }
    }

    private func startConfettiSequence() {
        opacity = 1.0

        Task {
            do {
                // Wait for confetti animation time
                try await Task.sleep(nanoseconds: UInt64(animationTime * 1_000_000_000))

                // Fade out the entire confetti container
                await MainActor.run {
                    withAnimation(.easeOut(duration: fadeTime)) {
                        opacity = 0
                    }
                }

                // Wait for fade to complete, then deactivate
                try await Task.sleep(nanoseconds: UInt64(fadeTime * 1_000_000_000))

                await MainActor.run {
                    isActive = false
                }

            } catch {
                // Handle cancellation gracefully
                await MainActor.run {
                    isActive = false
                }
            }
        }
    }
}

extension View {
    func displayConfetti(isActive: Binding<Bool>) -> some View {
        self.modifier(DisplayConfettiModifier(isActive: isActive))
    }
}
