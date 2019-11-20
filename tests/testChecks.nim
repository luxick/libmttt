# This is just an example to get you started. You may wish to put all of your
# tests into a single file, or separate them into multiple `test1`, `test2`
# etc. files (better names are recommended, just make sure the name starts with
# the letter 't').
#
# To run these tests, simply execute `nimble test`.

import unittest

import libmttt

suite "Test the board result checker":
  setup:
    var
      player1 = Player(name: "Adam")
      player2 = Player(name: "Eve")
      game: GameState = newGameState(player1, player2)

  test "winning row":    
    game.board[0][0] = [
      [Mark.Free, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Player1, Mark.Player1],
      [Mark.Free, Mark.Free, Mark.Free]
    ]
    check checkBoard(game.board[0][0]) == Mark.Player1

  test "winning column":      
    game.board[0][0] = [
      [Mark.Player2, Mark.Free, Mark.Player1],
      [Mark.Player2, Mark.Player1, Mark.Free],
      [Mark.Player2, Mark.Player1, Mark.Free]
    ]
    check checkBoard(game.board[0][0]) == Mark.Player2

  test "winning diagonals":      
    game.board[0][0] = [
      [Mark.Free, Mark.Free, Mark.Player2],
      [Mark.Free, Mark.Player2, Mark.Free],
      [Mark.Player2, Mark.Free, Mark.Free]
    ]
    check(checkBoard(game.board[0][0]) == Mark.Player2)

    game.board[0][0] = [
      [Mark.Player1, Mark.Player2, Mark.Player2],
      [Mark.Player2, Mark.Player1, Mark.Player1],
      [Mark.Player2, Mark.Free, Mark.Player1]
    ]
    check(checkBoard(game.board[0][0]) == Mark.Player1)

  test "board is a draw":
    game.board[0][0] = [
      [Mark.Player1, Mark.Player2, Mark.Player1],
      [Mark.Player2, Mark.Player1, Mark.Player1],
      [Mark.Player2, Mark.Player1, Mark.Player2]
    ]
    check checkBoard(game.board[0][0]) == Mark.Draw

  test "board is open":      
    game.board[0][0] = [
      [Mark.Player1, Mark.Player2, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Player1],
      [Mark.Free, Mark.Player1, Mark.Player2]
    ]
    check checkBoard(game.board[0][0]) == Mark.Free

  test "free inital metaboard":
    check checkBoard(game.board) == Mark.Free
  
  test "winning metaboard row":
    game.board[1][0] = [
      [Mark.Player1, Mark.Player2, Mark.Free],
      [Mark.Player1, Mark.Player1, Mark.Player1],
      [Mark.Free, Mark.Player1, Mark.Player2]
    ]
    game.board[1][1] = [
      [Mark.Free, Mark.Free, Mark.Player1],
      [Mark.Free, Mark.Player1, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Free]
    ]
    game.board[1][2] = [
      [Mark.Free, Mark.Free, Mark.Player1],
      [Mark.Free, Mark.Free, Mark.Player1],
      [Mark.Free, Mark.Free, Mark.Player1]
    ]
    check checkBoard(game.board) == Mark.Player1

  test "winning metaboard column":
    game.board[0][1] = [
      [Mark.Player1, Mark.Player2, Mark.Free],
      [Mark.Player1, Mark.Player1, Mark.Player1],
      [Mark.Free, Mark.Player1, Mark.Player2]
    ]
    game.board[1][1] = [
      [Mark.Free, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Player1, Mark.Player1],
      [Mark.Free, Mark.Free, Mark.Free]
    ]
    game.board[2][1] = [
      [Mark.Player1, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Free],
      [Mark.Player1, Mark.Free, Mark.Free]
    ]
    check checkBoard(game.board) == Mark.Player1

  test "winning metaboard diagonal":
    game.board[0][0] = [
      [Mark.Player2, Mark.Player2, Mark.Free],
      [Mark.Player2, Mark.Player2, Mark.Player2],
      [Mark.Free, Mark.Player2, Mark.Player2]
    ]
    game.board[1][1] = [
      [Mark.Free, Mark.Free, Mark.Free],
      [Mark.Player2, Mark.Player2, Mark.Player2],
      [Mark.Free, Mark.Free, Mark.Free]
    ]
    game.board[2][2] = [
      [Mark.Player2, Mark.Free, Mark.Free],
      [Mark.Player2, Mark.Free, Mark.Free],
      [Mark.Player2, Mark.Free, Mark.Free]
    ]
    check checkBoard(game.board) == Mark.Player2

  test "winning metaboard with some boards in draw":
    let winner = [
      [Mark.Free, Mark.Free, Mark.Free],
      [Mark.Player2, Mark.Player2, Mark.Player2],
      [Mark.Free, Mark.Free, Mark.Free]
    ]
    let drawn =  [
      [Mark.Player2, Mark.Player2, Mark.Player1],
      [Mark.Player1, Mark.Player1, Mark.Player2],
      [Mark.Player2, Mark.Player1, Mark.Player2]
    ]
    game.board[0][0] = winner
    game.board[1][1] = winner
    game.board[2][2] = winner
    game.board[1][0] = drawn
    game.board[2][0] = drawn
    check checkBoard(game.board) == Mark.Player2
    
  test "metaboard is drawn":
    let drawn =  [
      [Mark.Player2, Mark.Player2, Mark.Player1],
      [Mark.Player1, Mark.Player1, Mark.Player2],
      [Mark.Player2, Mark.Player1, Mark.Player2]
    ]
    for x in 0 .. 2:
      for y in 0 .. 2:
        game.board[x][y] = drawn
    check checkBoard(game.board) == Mark.Draw

  test "illegal situation: both players win board":
    game.board[1][1] = [
      [Mark.Player1, Mark.Player1, Mark.Player1],
      [Mark.Player2, Mark.Player2, Mark.Player2],
      [Mark.Free, Mark.Free, Mark.Free]
    ]
    expect(Exception):
      discard checkBoard(game.board)