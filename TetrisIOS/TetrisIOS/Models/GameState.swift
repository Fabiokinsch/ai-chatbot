import SwiftUI

// MARK: - Game Phase

enum GamePhase: Equatable {
    case start
    case playing
    case paused
    case gameOver
}

// MARK: - Cell

struct Cell: Equatable {
    var filled: Bool = false
    var color: Color = .clear
}

// MARK: - GameState

struct GameState: Equatable {
    static let rows = 20
    static let cols = 10

    var grid: [[Cell]]
    var currentPiece: Tetromino?
    var nextPiece: TetrominoType
    var phase: GamePhase = .start
    var score: Int = 0
    var linesCleared: Int = 0
    var level: Int = 1

    /// Gravity interval in seconds for the current level.
    var dropInterval: TimeInterval {
        max(0.1, 1.0 - Double(level - 1) * 0.08)
    }

    init() {
        grid = Self.emptyGrid()
        nextPiece = TetrominoType.allCases.randomElement()!
    }

    static func emptyGrid() -> [[Cell]] {
        Array(repeating: Array(repeating: Cell(), count: cols), count: rows)
    }

    /// Spawn position: top-center of the board.
    static func spawnPosition(for type: TetrominoType) -> Position {
        Position(row: 1, col: cols / 2)
    }
}
