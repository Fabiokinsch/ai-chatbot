import SwiftUI

// MARK: - GameView (main game screen)

struct GameView: View {
    @State private var engine = GameEngine()

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            switch engine.state.phase {
            case .start:
                startScreen
            case .playing, .paused:
                playingScreen
            case .gameOver:
                gameOverScreen
            }
        }
        .gesture(swipeGesture)
    }

    // MARK: - Start Screen

    private var startScreen: some View {
        VStack(spacing: 30) {
            Text("TETRIS")
                .font(.system(size: 48, weight: .black, design: .monospaced))
                .foregroundColor(.cyan)

            Text("SwiftUI Edition")
                .font(.subheadline)
                .foregroundColor(.gray)

            Button(action: { engine.startGame() }) {
                Text("START")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 14)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Playing Screen

    private var playingScreen: some View {
        VStack(spacing: 8) {
            // Top bar: score, level, next piece
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Score: \(engine.state.score)")
                        .font(.system(.body, design: .monospaced))
                    Text("Level: \(engine.state.level)")
                        .font(.system(.caption, design: .monospaced))
                    Text("Lines: \(engine.state.linesCleared)")
                        .font(.system(.caption, design: .monospaced))
                }
                .foregroundColor(.white)

                Spacer()

                NextPieceView(type: engine.state.nextPiece)

                Spacer()

                Button(action: { engine.togglePause() }) {
                    Image(systemName: engine.state.phase == .paused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)

            // Game board
            GameBoardView(
                grid: engine.state.grid,
                currentPiece: engine.state.currentPiece,
                ghostPiece: engine.ghostPiece
            )
            .aspectRatio(CGFloat(GameState.cols) / CGFloat(GameState.rows), contentMode: .fit)
            .padding(.horizontal, 8)

            // Pause overlay
            if engine.state.phase == .paused {
                pauseOverlay
            }

            // Controls
            ControlsView(
                onLeft: { engine.moveLeft() },
                onRight: { engine.moveRight() },
                onRotate: { engine.rotate() },
                onSoftDrop: { engine.softDrop() },
                onHardDrop: { engine.hardDrop() }
            )
            .padding(.bottom, 8)
        }
    }

    private var pauseOverlay: some View {
        VStack(spacing: 16) {
            Text("PAUSED")
                .font(.system(size: 32, weight: .black, design: .monospaced))
                .foregroundColor(.white)

            Button("Resume") { engine.togglePause() }
                .font(.title3.bold())
                .foregroundColor(.cyan)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.7))
    }

    // MARK: - Game Over Screen

    private var gameOverScreen: some View {
        VStack(spacing: 20) {
            Text("GAME OVER")
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(.red)

            VStack(spacing: 6) {
                Text("Score: \(engine.state.score)")
                    .font(.title2.monospaced())
                Text("Lines: \(engine.state.linesCleared)")
                    .font(.body.monospaced())
                Text("Level: \(engine.state.level)")
                    .font(.body.monospaced())
            }
            .foregroundColor(.white)

            Button(action: { engine.restart() }) {
                Text("PLAY AGAIN")
                    .font(.title3.bold())
                    .foregroundColor(.black)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .background(Color.cyan)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Swipe gesture (optional control)

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                guard engine.state.phase == .playing else { return }
                let dx = value.translation.width
                let dy = value.translation.height

                if abs(dx) > abs(dy) {
                    // Horizontal swipe
                    if dx < 0 { engine.moveLeft() }
                    else { engine.moveRight() }
                } else {
                    // Vertical swipe
                    if dy > 0 { engine.hardDrop() }
                    else { engine.rotate() }
                }
            }
    }
}

#Preview {
    GameView()
}
