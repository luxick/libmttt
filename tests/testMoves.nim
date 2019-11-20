import unittest, options

import libmttt

suite "Test the move procedures":
  setup:
    var
      player1 = Player(name: "Adam")
      player2 = Player(name: "Eve")
      game: GameState = newGameState(player1, player2)

  test "Inital state":
    check game.currentPlayer == player1
    check game.players == [player1, player2]
    check game.turn == 0
    check game.currentBoard.isNone
    check game.result == Mark.Free

  test "First move":
    game.makeMove((1, 1), (1, 1))
    check game.currentPlayer == player2
    check game.turn == 1
    check game.currentBoard == (1, 1).some()
    check game.result == Mark.Free

  test "Second move":
    game.makeMove((1, 1), (1, 1))
    game.makeMove((0, 0))
    check game.currentPlayer == player1
    check game.turn == 2
    check game.currentBoard == (0, 0).some()
    check game.result == Mark.Free

  test "Move on wrong board":
    game.makeMove((1, 1), (1, 1))
    expect(IllegalMoveError):
      game.makeMove((0, 0), (2, 2))

  test "Move on a taken cell":
    game.makeMove((1, 1), (1, 1))
    expect(IllegalMoveError):
      game.makeMove((1, 1))

  test "Move out of bounds":
    expect(IndexError):
      game.makeMove((3, 0), (0, 0))

  test "Player 1 wins the game":
    let winner = [
      [Mark.Player1, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Free]
    ]
    game.board[0][0] = winner
    game.board[1][1] = winner

    game.board[2][2] = [
          [Mark.Player1, Mark.Free, Mark.Free],
          [Mark.Free, Mark.Free, Mark.Free],
          [Mark.Player1, Mark.Free, Mark.Free]
        ]
    check checkBoard(game.board) == Mark.Free
    game.makeMove((1, 0), (2, 2))
    check game.result == Mark.Player1
    check game.currentPlayer == player1

  test "The game ends in a draw":
    let drawn =  [
      [Mark.Player2, Mark.Player2, Mark.Player1],
      [Mark.Player1, Mark.Player1, Mark.Player2],
      [Mark.Player2, Mark.Player1, Mark.Player2]
    ]
    for x in 0 .. 2:
      for y in 0 .. 2:
        game.board[x][y] = drawn

    game.board[2][2] = [
      [Mark.Player2, Mark.Player2, Mark.Player1],
      [Mark.Player1, Mark.Player1, Mark.Player2],
      [Mark.Player2, Mark.Free, Mark.Player2]
    ]
    check checkBoard(game.board) == Mark.Free
    game.makeMove((2, 1), (2, 2))
    check game.result == Mark.Draw
    check game.currentPlayer == player1