import XCTest
@testable import TetrisIOS

final class TetrisIOSTests: XCTestCase {

    // MARK: - Test 1: Tetromino rotation cycles back to original

    func testRotationCycle() {
        let piece = Tetromino(type: .T, position: Position(row: 5, col: 5), rotationIndex: 0)
        let rotated1 = piece.rotated()
        let rotated2 = rotated1.rotated()
        let rotated3 = rotated2.rotated()
        let rotated4 = rotated3.rotated()

        XCTAssertEqual(rotated4.rotationIndex, piece.rotationIndex, "4 clockwise rotations should return to original state")
        XCTAssertEqual(rotated4.blocks, piece.blocks)
    }

    // MARK: - Test 2: Collision with grid boundaries

    func testCollisionWithWalls() {
        let engine = GameEngine()
        engine.startGame()

        // Piece at far left should not move further left
        let leftPiece = Tetromino(type: .O, position: Position(row: 5, col: 0))
        XCTAssertTrue(engine.isValid(piece: leftPiece), "O-piece at col 0 should be valid")

        let outOfBounds = Tetromino(type: .O, position: Position(row: 5, col: -1))
        XCTAssertFalse(engine.isValid(piece: outOfBounds), "O-piece at col -1 should be invalid")
    }

    // MARK: - Test 3: Collision with floor

    func testCollisionWithFloor() {
        let engine = GameEngine()
        engine.startGame()

        // O-piece at bottom row (row 19 occupies rows 19-20 which is out of bounds)
        let floorPiece = Tetromino(type: .O, position: Position(row: 19, col: 4))
        XCTAssertFalse(engine.isValid(piece: floorPiece), "O-piece extending below row 19 should be invalid")

        let validFloor = Tetromino(type: .O, position: Position(row: 18, col: 4))
        XCTAssertTrue(engine.isValid(piece: validFloor), "O-piece at row 18 should be valid (occupies 18,19)")
    }

    // MARK: - Test 4: Line clearing

    func testLineClear() {
        let engine = GameEngine()
        engine.startGame()

        // Fill the bottom row completely
        for col in 0..<GameState.cols {
            engine.state.grid[GameState.rows - 1][col] = Cell(filled: true, color: .red)
        }

        let linesBefore = engine.state.linesCleared
        engine.clearLines()

        XCTAssertEqual(engine.state.linesCleared, linesBefore + 1, "Should clear exactly 1 line")
        // Bottom row should now be empty (shifted down)
        let bottomRowEmpty = engine.state.grid[0].allSatisfy { !$0.filled }
        XCTAssertTrue(bottomRowEmpty, "Top row should be empty after line clear")
    }

    // MARK: - Test 5: Score increases on line clear

    func testScoreOnLineClear() {
        let engine = GameEngine()
        engine.startGame()

        // Fill bottom row
        for col in 0..<GameState.cols {
            engine.state.grid[GameState.rows - 1][col] = Cell(filled: true, color: .blue)
        }

        let scoreBefore = engine.state.score
        engine.clearLines()

        XCTAssertGreaterThan(engine.state.score, scoreBefore, "Score should increase after clearing a line")
    }

    // MARK: - Test 6: Multiple line clear scoring

    func testMultipleLineClear() {
        let engine = GameEngine()
        engine.startGame()

        // Fill bottom 2 rows
        for row in (GameState.rows - 2)..<GameState.rows {
            for col in 0..<GameState.cols {
                engine.state.grid[row][col] = Cell(filled: true, color: .green)
            }
        }

        engine.clearLines()

        XCTAssertEqual(engine.state.linesCleared, 2, "Should clear 2 lines")
    }

    // MARK: - Test 7: Piece movement

    func testPieceMovement() {
        let piece = Tetromino(type: .I, position: Position(row: 5, col: 5))
        let movedRight = piece.moved(by: Position(row: 0, col: 1))
        let movedDown = piece.moved(by: Position(row: 1, col: 0))

        XCTAssertEqual(movedRight.position, Position(row: 5, col: 6))
        XCTAssertEqual(movedDown.position, Position(row: 6, col: 5))
    }

    // MARK: - Test 8: Game starts in correct state

    func testGameStartState() {
        let engine = GameEngine()
        engine.startGame()

        XCTAssertEqual(engine.state.phase, .playing)
        XCTAssertEqual(engine.state.score, 0)
        XCTAssertEqual(engine.state.level, 1)
        XCTAssertEqual(engine.state.linesCleared, 0)
        XCTAssertNotNil(engine.state.currentPiece)
    }

    // MARK: - Test 9: All tetromino types have 4 blocks

    func testAllTetrominosHave4Blocks() {
        for type in TetrominoType.allCases {
            for rotation in type.rotations {
                XCTAssertEqual(rotation.count, 4, "\(type) should have exactly 4 blocks in every rotation")
            }
        }
    }

    // MARK: - Test 10: Drop interval decreases with level

    func testDropIntervalDecreases() {
        var state = GameState()
        let interval1 = state.dropInterval
        state.level = 5
        let interval5 = state.dropInterval

        XCTAssertLessThan(interval5, interval1, "Higher level should have faster drop speed")
    }
}
