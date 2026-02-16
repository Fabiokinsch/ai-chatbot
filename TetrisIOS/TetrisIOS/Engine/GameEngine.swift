import Foundation
import SwiftUI

// MARK: - GameEngine

@Observable
final class GameEngine {
    private(set) var state = GameState()
    private var timer: Timer?

    // MARK: - Game lifecycle

    func startGame() {
        state = GameState()
        state.phase = .playing
        spawnPiece()
        startTimer()
    }

    func togglePause() {
        switch state.phase {
        case .playing:
            state.phase = .paused
            stopTimer()
        case .paused:
            state.phase = .playing
            startTimer()
        default:
            break
        }
    }

    func restart() {
        stopTimer()
        startGame()
    }

    // MARK: - Timer

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: state.dropInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    /// Single game tick: move current piece down by gravity.
    func tick() {
        guard state.phase == .playing else { return }
        moveDown()
    }

    // MARK: - Input actions

    func moveLeft() {
        tryMove(delta: Position(row: 0, col: -1))
    }

    func moveRight() {
        tryMove(delta: Position(row: 0, col: 1))
    }

    func moveDown() {
        guard var piece = state.currentPiece else { return }
        let moved = piece.moved(by: Position(row: 1, col: 0))
        if isValid(piece: moved) {
            state.currentPiece = moved
        } else {
            lockPiece()
        }
    }

    func softDrop() {
        moveDown()
        state.score += 1
    }

    func hardDrop() {
        guard var piece = state.currentPiece else { return }
        var rows = 0
        while isValid(piece: piece.moved(by: Position(row: 1, col: 0))) {
            piece = piece.moved(by: Position(row: 1, col: 0))
            rows += 1
        }
        state.currentPiece = piece
        state.score += rows * 2
        lockPiece()
    }

    func rotate(clockwise: Bool = true) {
        guard let piece = state.currentPiece else { return }
        let rotated = piece.rotated(clockwise: clockwise)

        // Try base rotation
        if isValid(piece: rotated) {
            state.currentPiece = rotated
            return
        }

        // Try wall kicks
        let kicks = WallKickData.kicks(
            for: piece.type,
            from: piece.rotationIndex,
            to: rotated.rotationIndex
        )
        for kick in kicks {
            let kicked = Tetromino(
                type: rotated.type,
                position: rotated.position + kick,
                rotationIndex: rotated.rotationIndex
            )
            if isValid(piece: kicked) {
                state.currentPiece = kicked
                return
            }
        }
        // Rotation failed — do nothing
    }

    // MARK: - Ghost piece (preview of hard drop landing)

    var ghostPiece: Tetromino? {
        guard var piece = state.currentPiece else { return nil }
        while isValid(piece: piece.moved(by: Position(row: 1, col: 0))) {
            piece = piece.moved(by: Position(row: 1, col: 0))
        }
        return piece
    }

    // MARK: - Internal logic

    private func tryMove(delta: Position) {
        guard let piece = state.currentPiece else { return }
        let moved = piece.moved(by: delta)
        if isValid(piece: moved) {
            state.currentPiece = moved
        }
    }

    func isValid(piece: Tetromino) -> Bool {
        for block in piece.blocks {
            if block.row < 0 || block.row >= GameState.rows { return false }
            if block.col < 0 || block.col >= GameState.cols { return false }
            if state.grid[block.row][block.col].filled { return false }
        }
        return true
    }

    private func lockPiece() {
        guard let piece = state.currentPiece else { return }
        for block in piece.blocks {
            guard block.row >= 0 && block.row < GameState.rows,
                  block.col >= 0 && block.col < GameState.cols else {
                // Piece locked above the visible grid → game over
                gameOver()
                return
            }
            state.grid[block.row][block.col] = Cell(filled: true, color: piece.color)
        }
        state.currentPiece = nil
        clearLines()
        spawnPiece()
    }

    func clearLines() {
        var cleared = 0
        var newGrid = state.grid.filter { row in
            let full = row.allSatisfy { $0.filled }
            if full { cleared += 1 }
            return !full
        }

        // Add empty rows at the top
        while newGrid.count < GameState.rows {
            newGrid.insert(Array(repeating: Cell(), count: GameState.cols), at: 0)
        }

        state.grid = newGrid
        if cleared > 0 {
            state.linesCleared += cleared
            state.score += lineScore(cleared)
            state.level = state.linesCleared / 10 + 1
            // Restart timer with new speed
            if state.phase == .playing {
                startTimer()
            }
        }
    }

    private func lineScore(_ lines: Int) -> Int {
        let base: [Int] = [0, 100, 300, 500, 800]
        let idx = min(lines, 4)
        return base[idx] * state.level
    }

    private func spawnPiece() {
        let type = state.nextPiece
        let spawn = GameState.spawnPosition(for: type)
        let piece = Tetromino(type: type, position: spawn)

        state.nextPiece = TetrominoType.allCases.randomElement()!

        if isValid(piece: piece) {
            state.currentPiece = piece
        } else {
            gameOver()
        }
    }

    private func gameOver() {
        state.phase = .gameOver
        state.currentPiece = nil
        stopTimer()
    }
}
