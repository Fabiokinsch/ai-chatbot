import SwiftUI

// MARK: - GameBoardView

struct GameBoardView: View {
    let grid: [[Cell]]
    let currentPiece: Tetromino?
    let ghostPiece: Tetromino?

    private let rows = GameState.rows
    private let cols = GameState.cols

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(
                geo.size.width / CGFloat(cols),
                geo.size.height / CGFloat(rows)
            )
            let boardWidth = cellSize * CGFloat(cols)
            let boardHeight = cellSize * CGFloat(rows)

            Canvas { context, size in
                let offsetX = (size.width - boardWidth) / 2
                let offsetY = (size.height - boardHeight) / 2

                // Draw grid background
                for row in 0..<rows {
                    for col in 0..<cols {
                        let rect = CGRect(
                            x: offsetX + CGFloat(col) * cellSize,
                            y: offsetY + CGFloat(row) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )
                        let cell = grid[row][col]
                        if cell.filled {
                            context.fill(Path(rect), with: .color(cell.color))
                        } else {
                            context.fill(Path(rect), with: .color(.black))
                        }
                        // Grid lines
                        context.stroke(Path(rect), with: .color(.gray.opacity(0.3)), lineWidth: 0.5)
                    }
                }

                // Draw ghost piece
                if let ghost = ghostPiece {
                    for block in ghost.blocks where block.row >= 0 && block.row < rows && block.col >= 0 && block.col < cols {
                        let rect = CGRect(
                            x: offsetX + CGFloat(block.col) * cellSize + 1,
                            y: offsetY + CGFloat(block.row) * cellSize + 1,
                            width: cellSize - 2,
                            height: cellSize - 2
                        )
                        context.stroke(Path(rect), with: .color(ghost.color.opacity(0.4)), lineWidth: 1.5)
                    }
                }

                // Draw current piece
                if let piece = currentPiece {
                    for block in piece.blocks where block.row >= 0 && block.row < rows && block.col >= 0 && block.col < cols {
                        let rect = CGRect(
                            x: offsetX + CGFloat(block.col) * cellSize,
                            y: offsetY + CGFloat(block.row) * cellSize,
                            width: cellSize,
                            height: cellSize
                        )
                        context.fill(Path(rect), with: .color(piece.color))
                        // Inner highlight
                        let inset = rect.insetBy(dx: 1, dy: 1)
                        context.fill(Path(inset), with: .color(piece.color.opacity(0.8)))
                        context.stroke(Path(rect), with: .color(.white.opacity(0.3)), lineWidth: 0.5)
                    }
                }

                // Board border
                let boardRect = CGRect(x: offsetX, y: offsetY, width: boardWidth, height: boardHeight)
                context.stroke(Path(boardRect), with: .color(.white), lineWidth: 2)
            }
        }
    }
}
