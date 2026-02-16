# TetrisIOS

A fully playable Tetris game for iPhone built with SwiftUI (iOS 17+). No external dependencies.

## Requirements

- **Xcode 15+** (with iOS 17 SDK)
- **iOS 17.0+** device or simulator
- **Swift 5.9+**

## How to Open and Run

### Option 1: Using XcodeGen (recommended if installed)

```bash
brew install xcodegen   # if not already installed
cd TetrisIOS
xcodegen generate
open TetrisIOS.xcodeproj
```

### Option 2: Create Xcode project manually

1. Open Xcode → **File → New → Project**
2. Select **iOS → App**, click Next
3. Set Product Name to `TetrisIOS`, Interface: **SwiftUI**, Language: **Swift**
4. Set minimum deployment target to **iOS 17.0**
5. Delete the generated `ContentView.swift` and `TetrisIOSApp.swift`
6. Drag the `TetrisIOS/` folder contents into the project navigator
7. Drag the `TetrisIOSTests/` folder and add it as a Unit Test target
8. Build and run on simulator or device (Cmd+R)

### Running on Simulator

1. Select an iPhone simulator (e.g., iPhone 15 Pro) from the scheme toolbar
2. Press **Cmd+R** to build and run
3. The game launches to the Start screen — tap **START** to play

### Running on iPhone

1. Connect your iPhone via USB
2. Select your device from the scheme toolbar
3. You may need to set a development team in **Signing & Capabilities**
4. Press **Cmd+R** to build and deploy

## Running Tests

Press **Cmd+U** in Xcode to run the unit test suite (10 tests covering rotation, collision, line clearing, scoring, etc.).

## Controls

| Control | Action |
|---------|--------|
| **← button** | Move piece left |
| **→ button** | Move piece right |
| **↓ button** | Soft drop (move down + 1 point) |
| **⟳ button** | Rotate clockwise |
| **⬇ button** | Hard drop (instant drop + 2 pts/row) |
| **Swipe left/right** | Move piece |
| **Swipe down** | Hard drop |
| **Swipe up** | Rotate |

## Adjusting Speed

The drop speed is controlled by the `dropInterval` computed property in `GameState.swift`:

```swift
var dropInterval: TimeInterval {
    max(0.1, 1.0 - Double(level - 1) * 0.08)
}
```

- **Starting speed**: `1.0` seconds per drop at level 1
- **Acceleration**: `0.08` seconds faster per level
- **Minimum cap**: `0.1` seconds (never faster than this)

To adjust:
- Change `1.0` to set the initial speed (higher = slower)
- Change `0.08` to set the acceleration rate per level
- Change `0.1` to set the fastest possible speed

## Scoring

| Lines Cleared | Points (× Level) |
|:---:|:---:|
| 1 | 100 |
| 2 | 300 |
| 3 | 500 |
| 4 (Tetris) | 800 |

Level increases every 10 lines cleared.

## Project Structure

```
TetrisIOS/
├── TetrisIOS/
│   ├── App/
│   │   └── TetrisIOSApp.swift        # App entry point
│   ├── Models/
│   │   ├── Tetromino.swift            # Piece types, rotations, wall kicks
│   │   └── GameState.swift            # Grid, score, level, game phase
│   ├── Engine/
│   │   └── GameEngine.swift           # Game loop, collision, input handling
│   ├── Views/
│   │   ├── GameView.swift             # Main game screen with all phases
│   │   ├── GameBoardView.swift        # Canvas-based grid renderer
│   │   ├── ControlsView.swift         # Touch control buttons
│   │   └── NextPieceView.swift        # Next piece preview
│   └── Info.plist
├── TetrisIOSTests/
│   └── TetrisIOSTests.swift           # 10 unit tests
├── project.yml                         # XcodeGen config
├── Package.swift                       # SPM config (alternative)
└── README.md
```
