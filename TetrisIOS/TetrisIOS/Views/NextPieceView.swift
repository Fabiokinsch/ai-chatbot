import SwiftUI

struct NextPieceView: View {
    let type: TetrominoType

    var body: some View {
        VStack(spacing: 4) {
            Text("NEXT")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.gray)

            Canvas { context, size in
                let blocks = type.rotations[0]
                let cellSize: CGFloat = 14
                let offsetX = (size.width - cellSize * 4) / 2
                let offsetY = (size.height - cellSize * 4) / 2

                for block in blocks {
                    // Shift to positive coords: add 1 to row to center vertically
                    let rect = CGRect(
                        x: offsetX + CGFloat(block.col + 1) * cellSize,
                        y: offsetY + CGFloat(block.row + 1) * cellSize,
                        width: cellSize - 1,
                        height: cellSize - 1
                    )
                    context.fill(Path(rect), with: .color(type.color))
                }
            }
            .frame(width: 70, height: 50)
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(8)
    }
}
