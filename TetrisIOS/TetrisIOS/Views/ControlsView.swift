import SwiftUI

// MARK: - ControlsView

struct ControlsView: View {
    let onLeft: () -> Void
    let onRight: () -> Void
    let onRotate: () -> Void
    let onSoftDrop: () -> Void
    let onHardDrop: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Left side: directional
            HStack(spacing: 12) {
                ControlButton(symbol: "arrow.left", label: "Left", action: onLeft)
                ControlButton(symbol: "arrow.down", label: "Down", action: onSoftDrop)
                ControlButton(symbol: "arrow.right", label: "Right", action: onRight)
            }

            Spacer()

            // Right side: rotate + hard drop
            HStack(spacing: 12) {
                ControlButton(symbol: "arrow.trianglehead.2.clockwise.rotate.90", label: "Rotate", action: onRotate)
                ControlButton(symbol: "arrow.down.to.line", label: "Drop", action: onHardDrop)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - ControlButton

struct ControlButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {
                Image(systemName: symbol)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(.white)
            .frame(width: 56, height: 56)
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
        }
        .buttonRepeatBehavior(.enabled)
    }
}
