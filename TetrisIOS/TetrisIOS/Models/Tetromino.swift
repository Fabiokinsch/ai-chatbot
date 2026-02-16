import SwiftUI

// MARK: - Position

struct Position: Equatable, Hashable {
    var row: Int
    var col: Int

    static func + (lhs: Position, rhs: Position) -> Position {
        Position(row: lhs.row + rhs.row, col: lhs.col + rhs.col)
    }
}

// MARK: - TetrominoType

enum TetrominoType: Int, CaseIterable {
    case I, O, T, S, Z, J, L

    var color: Color {
        switch self {
        case .I: return .cyan
        case .O: return .yellow
        case .T: return .purple
        case .S: return .green
        case .Z: return .red
        case .J: return .blue
        case .L: return .orange
        }
    }

    /// Each tetromino defined as offsets from pivot in all 4 rotation states.
    /// Simplified SRS: 4 rotation states (0, R, 2, L).
    var rotations: [[Position]] {
        switch self {
        case .I:
            return [
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 0, col: 2)],
                [Position(row: -1, col: 1), Position(row: 0, col: 1), Position(row: 1, col: 1), Position(row: 2, col: 1)],
                [Position(row: 1, col: -1), Position(row: 1, col: 0), Position(row: 1, col: 1), Position(row: 1, col: 2)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 2, col: 0)],
            ]
        case .O:
            let base = [Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: 0), Position(row: 1, col: 1)]
            return [base, base, base, base]
        case .T:
            return [
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: -1, col: 0)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 0, col: 1)],
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: 0)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 0, col: -1)],
            ]
        case .S:
            return [
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: -1, col: 0), Position(row: -1, col: 1)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: 1)],
                [Position(row: 1, col: -1), Position(row: 1, col: 0), Position(row: 0, col: 0), Position(row: 0, col: 1)],
                [Position(row: -1, col: -1), Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 1, col: 0)],
            ]
        case .Z:
            return [
                [Position(row: -1, col: -1), Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 0, col: 1)],
                [Position(row: -1, col: 1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: 0)],
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 1, col: 1)],
                [Position(row: 0, col: 0), Position(row: 0, col: -1), Position(row: 1, col: -1), Position(row: -1, col: 0)],
            ]
        case .J:
            return [
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: -1, col: -1)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: -1, col: 1)],
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: 1)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 1, col: -1)],
            ]
        case .L:
            return [
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: -1, col: 1)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: 1, col: 1)],
                [Position(row: 0, col: -1), Position(row: 0, col: 0), Position(row: 0, col: 1), Position(row: 1, col: -1)],
                [Position(row: -1, col: 0), Position(row: 0, col: 0), Position(row: 1, col: 0), Position(row: -1, col: -1)],
            ]
        }
    }
}

// MARK: - Tetromino (active piece)

struct Tetromino: Equatable {
    var type: TetrominoType
    var position: Position  // pivot position on the grid
    var rotationIndex: Int = 0

    var blocks: [Position] {
        type.rotations[rotationIndex].map { $0 + position }
    }

    var color: Color { type.color }

    func rotated(clockwise: Bool = true) -> Tetromino {
        let count = type.rotations.count
        let next = clockwise
            ? (rotationIndex + 1) % count
            : (rotationIndex + count - 1) % count
        return Tetromino(type: type, position: position, rotationIndex: next)
    }

    func moved(by delta: Position) -> Tetromino {
        Tetromino(type: type, position: position + delta, rotationIndex: rotationIndex)
    }
}

// MARK: - Wall Kick Data (simplified SRS)

struct WallKickData {
    /// Basic wall kick offsets to try after rotation.
    static func kicks(for type: TetrominoType, from: Int, to: Int) -> [Position] {
        if type == .I {
            return iKicks(from: from, to: to)
        }
        return standardKicks(from: from, to: to)
    }

    private static func standardKicks(from: Int, to: Int) -> [Position] {
        // Standard JLSTZ kicks (simplified)
        let table: [String: [Position]] = [
            "0>1": [Position(row: 0, col: -1), Position(row: -1, col: -1), Position(row: 2, col: 0), Position(row: 2, col: -1)],
            "1>0": [Position(row: 0, col: 1), Position(row: 1, col: 1), Position(row: -2, col: 0), Position(row: -2, col: 1)],
            "1>2": [Position(row: 0, col: 1), Position(row: 1, col: 1), Position(row: -2, col: 0), Position(row: -2, col: 1)],
            "2>1": [Position(row: 0, col: -1), Position(row: -1, col: -1), Position(row: 2, col: 0), Position(row: 2, col: -1)],
            "2>3": [Position(row: 0, col: 1), Position(row: -1, col: 1), Position(row: 2, col: 0), Position(row: 2, col: 1)],
            "3>2": [Position(row: 0, col: -1), Position(row: 1, col: -1), Position(row: -2, col: 0), Position(row: -2, col: -1)],
            "3>0": [Position(row: 0, col: -1), Position(row: 1, col: -1), Position(row: -2, col: 0), Position(row: -2, col: -1)],
            "0>3": [Position(row: 0, col: 1), Position(row: -1, col: 1), Position(row: 2, col: 0), Position(row: 2, col: 1)],
        ]
        return table["\(from)>\(to)"] ?? []
    }

    private static func iKicks(from: Int, to: Int) -> [Position] {
        let table: [String: [Position]] = [
            "0>1": [Position(row: 0, col: -2), Position(row: 0, col: 1), Position(row: 1, col: -2), Position(row: -2, col: 1)],
            "1>0": [Position(row: 0, col: 2), Position(row: 0, col: -1), Position(row: -1, col: 2), Position(row: 2, col: -1)],
            "1>2": [Position(row: 0, col: -1), Position(row: 0, col: 2), Position(row: -2, col: -1), Position(row: 1, col: 2)],
            "2>1": [Position(row: 0, col: 1), Position(row: 0, col: -2), Position(row: 2, col: 1), Position(row: -1, col: -2)],
            "2>3": [Position(row: 0, col: 2), Position(row: 0, col: -1), Position(row: -1, col: 2), Position(row: 2, col: -1)],
            "3>2": [Position(row: 0, col: -2), Position(row: 0, col: 1), Position(row: 1, col: -2), Position(row: -2, col: 1)],
            "3>0": [Position(row: 0, col: 1), Position(row: 0, col: -2), Position(row: 2, col: 1), Position(row: -1, col: -2)],
            "0>3": [Position(row: 0, col: -1), Position(row: 0, col: 2), Position(row: -2, col: -1), Position(row: 1, col: 2)],
        ]
        return table["\(from)>\(to)"] ?? []
    }
}
