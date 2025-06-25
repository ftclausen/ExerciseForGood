# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a fitness tracking iOS application built with SwiftUI and SwiftData for tracking daily push-up exercises. The app features a tab-based interface with circular progress tracking, gesture-based input, and monthly statistics views. Uses orange/black color scheme following Apple fitness app design patterns.

## Development Commands

### Building and Running
- Open `ExerciseForGood.xcodeproj` in Xcode to build and run the app
- Use Xcode's built-in build system (Cmd+B to build, Cmd+R to run)
- Target iOS devices or simulators through Xcode's scheme selector

### Testing
- Run unit tests: Use Xcode's Test Navigator or Cmd+U
- Unit tests are located in `ExerciseForGoodTests/ExerciseForGoodTests.swift`
- UI tests are in `ExerciseForGoodUITests/ExerciseForGoodUITests.swift`
- Both test suites use XCTest framework

## Architecture Overview

### Core Components
- **ExerciseForGoodApp.swift**: Main app entry point with SwiftData ModelContainer setup for PushUpDay model
- **ContentView.swift**: Root TabView containing Today and Progress tabs
- **TodayView.swift**: Main tracking interface with circular progress and drag gestures
- **ProgressView.swift**: Monthly statistics table with swipe navigation
- **PushUps.swift**: Data models and business logic for push-up tracking

### Data Layer
- **PushUpDay Model**: Core SwiftData entity tracking daily push-up data (date, target, completed, isRestDay)
- **PushUpManager**: ObservableObject managing daily target generation and push-up operations
- **Target Generation**: Random targets (70-230) generated on first daily app open, Sundays are rest days (0 target)
- **Badge System**: Real-time achievement tracking (25%, 50%, 75%, 100% completion levels)

### View Architecture
- **Tab-Based Navigation**: "Today" tab for daily tracking, "Progress" tab for monthly statistics
- **Circular Progress Interface**: Rotation-sensitive input (1/5/10 push-ups based on rotation speed)
- **Gesture Controls**: Clockwise rotation to add, counter-clockwise to subtract push-ups with haptic feedback
- **Monthly Table View**: Swipeable month navigation with historical data back to app install

### Key Patterns
- SwiftData @Model for fitness data persistence
- @ObservedObject for real-time progress updates
- Custom circular rotation gestures with angular velocity-based increment calculation
- Calendar-based data organization and rest day logic
- Badge system with enum-based achievement levels