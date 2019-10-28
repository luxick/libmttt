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
      game: GameState = newGame(player1, player2)

  test "winning row":    
    game.board[0][0] = [
      [mFree, mFree, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mFree, mFree]
    ]
    check checkBoard(game.board[0][0]) == mPlayer1

  test "winning column":      
    game.board[0][0] = [
      [mPlayer2, mFree, mPlayer1],
      [mPlayer2, mPlayer1, mFree],
      [mPlayer2, mPlayer1, mFree]
    ]
    check checkBoard(game.board[0][0]) == mPlayer2

  test "winning diagonals":      
    game.board[0][0] = [
      [mFree, mFree, mPlayer2],
      [mFree, mPlayer2, mFree],
      [mPlayer2, mFree, mFree]
    ]
    check(checkBoard(game.board[0][0]) == mPlayer2)

    game.board[0][0] = [
      [mPlayer1, mPlayer2, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer1],
      [mPlayer2, mFree, mPlayer1]
    ]
    check(checkBoard(game.board[0][0]) == mPlayer1)

  test "board is a draw":      
    game.board[0][0] = [
      [mPlayer1, mPlayer2, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    check checkBoard(game.board[0][0]) == mDraw

  test "board is open":      
    game.board[0][0] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mFree, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    check checkBoard(game.board[0][0]) == mFree

  test "free inital metaboard":
    check checkBoard(game.board) == mFree
  
  test "winning metaboard row":
    game.board[1][0] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    game.board[1][1] = [
      [mFree, mFree, mPlayer1],
      [mFree, mPlayer1, mFree],
      [mPlayer1, mFree, mFree]
    ]
    game.board[1][2] = [
      [mFree, mFree, mPlayer1],
      [mFree, mFree, mPlayer1],
      [mFree, mFree, mPlayer1]
    ]
    check checkBoard(game.board) == mPlayer1

  test "winning metaboard column":
    game.board[0][1] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    game.board[1][1] = [
      [mFree, mFree, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mFree, mFree]
    ]
    game.board[2][1] = [
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree]
    ]
    check checkBoard(game.board) == mPlayer1

  test "winning metaboard diagonal":
    game.board[0][0] = [
      [mPlayer2, mPlayer2, mFree],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mPlayer2, mPlayer2]
    ]
    game.board[1][1] = [
      [mFree, mFree, mFree],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mFree, mFree]
    ]
    game.board[2][2] = [
      [mPlayer2, mFree, mFree],
      [mPlayer2, mFree, mFree],
      [mPlayer2, mFree, mFree]
    ]
    check checkBoard(game.board) == mPlayer2

  test "winning metaboard with some boards in draw":
    let winner = [
      [mFree, mFree, mFree],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mFree, mFree]
    ]
    let drawn =  [
      [mPlayer2, mPlayer2, mPlayer1],
      [mPlayer1, mPlayer1, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    game.board[0][0] = winner
    game.board[1][1] = winner
    game.board[2][2] = winner
    game.board[1][0] = drawn
    game.board[2][0] = drawn
    check checkBoard(game.board) == mPlayer2
    
  test "metaboard is drawn":
    let drawn =  [
      [mPlayer2, mPlayer2, mPlayer1],
      [mPlayer1, mPlayer1, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    for x in 0 .. 2:
      for y in 0 .. 2:
        game.board[x][y] = drawn
    check checkBoard(game.board) == mDraw

  test "illegal situation: both players win board":
    game.board[1][1] = [
      [mPlayer1, mPlayer1, mPlayer1],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mFree, mFree]
    ]
    expect(Exception):
      discard checkBoard(game.board)