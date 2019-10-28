import unittest, options

import libmttt

suite "Test the move procedures":
  setup:
    var
      player1 = Player(name: "Adam")
      player2 = Player(name: "Eve")
      game: GameState = newGame(player1, player2)

  test "Inital state":
    check game.currentPlayer == player1
    check game.players == [player1, player2]
    check game.turn == 0
    check game.currentBoard.isNone
    check game.result == mFree

  test "First move":
    game = game.makeMove((1, 1), (1, 1))
    check game.currentPlayer == player2
    check game.turn == 1
    check game.currentBoard == (1, 1).some()
    check game.result == mFree

  test "Second move":
    game = game.makeMove((1, 1), (1, 1))
    game = game.makeMove((0, 0))
    check game.currentPlayer == player1
    check game.turn == 2
    check game.currentBoard == (0, 0).some()
    check game.result == mFree

  test "Move on wrong board":
    game = game.makeMove((1, 1), (1, 1))
    expect(IllegalMoveError):
      game = game.makeMove((0, 0), (2, 2))

  test "Move on a taken cell":
    game = game.makeMove((1, 1), (1, 1))
    expect(IllegalMoveError):
      game = game.makeMove((1, 1))

  test "Move out of bounds":
    expect(IndexError):
      game = game.makeMove((3, 0), (0, 0))

  test "Player 1 wins the game":
    let winner = [
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree]
    ]
    game.board[0][0] = winner
    game.board[1][1] = winner

    game.board[2][2] = [
          [mPlayer1, mFree, mFree],
          [mFree, mFree, mFree],
          [mPlayer1, mFree, mFree]
        ]
    check checkBoard(game.board) == mFree
    game = game.makeMove((1, 0), (2, 2))
    check game.result == mPlayer1
    check game.currentPlayer == player1

  test "The game ends in a draw":
    let drawn =  [
      [mPlayer2, mPlayer2, mPlayer1],
      [mPlayer1, mPlayer1, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    for x in 0 .. 2:
      for y in 0 .. 2:
        game.board[x][y] = drawn

    game.board[2][2] = [
      [mPlayer2, mPlayer2, mPlayer1],
      [mPlayer1, mPlayer1, mPlayer2],
      [mPlayer2, mFree, mPlayer2]
    ]
    check checkBoard(game.board) == mFree
    game = game.makeMove((2, 1), (2, 2))
    check game.result == mDraw
    check game.currentPlayer == player1