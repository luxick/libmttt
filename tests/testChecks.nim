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
      player1 = Player(name: "Max")
      player2 = Player(name: "Adam")
      state: GameState = newGame(player1, player2)

  test "winning row":    
    state.board[0][0] = [
      [mFree, mFree, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mFree, mFree]
    ]
    check checkBoard(state.board[0][0]) == mPlayer1

  test "winning column":      
    state.board[0][0] = [
      [mPlayer2, mFree, mPlayer1],
      [mPlayer2, mPlayer1, mFree],
      [mPlayer2, mPlayer1, mFree]
    ]
    check checkBoard(state.board[0][0]) == mPlayer2

  test "winning diagonals":      
    state.board[0][0] = [
      [mFree, mFree, mPlayer2],
      [mFree, mPlayer2, mFree],
      [mPlayer2, mFree, mFree]
    ]
    check(checkBoard(state.board[0][0]) == mPlayer2)

    state.board[0][0] = [
      [mPlayer1, mPlayer2, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer1],
      [mPlayer2, mFree, mPlayer1]
    ]
    check(checkBoard(state.board[0][0]) == mPlayer1)

  test "board is a draw":      
    state.board[0][0] = [
      [mPlayer1, mPlayer2, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    check checkBoard(state.board[0][0]) == mDraw

  test "board is open":      
    state.board[0][0] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mFree, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    check checkBoard(state.board[0][0]) == mFree

  test "free inital metaboard":
    check checkBoard(state.board) == mFree
  
  test "winning metaboard row":
    state.board[1][0] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    state.board[1][1] = [
      [mFree, mFree, mPlayer1],
      [mFree, mPlayer1, mFree],
      [mPlayer1, mFree, mFree]
    ]
    state.board[1][2] = [
      [mFree, mFree, mPlayer1],
      [mFree, mFree, mPlayer1],
      [mFree, mFree, mPlayer1]
    ]
    check checkBoard(state.board) == mPlayer1

  test "winning metaboard column":
    state.board[0][1] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    state.board[1][1] = [
      [mFree, mFree, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mFree, mFree]
    ]
    state.board[2][1] = [
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree],
      [mPlayer1, mFree, mFree]
    ]
    check checkBoard(state.board) == mPlayer1

  test "winning metaboard diagonal":
    state.board[0][0] = [
      [mPlayer2, mPlayer2, mFree],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mPlayer2, mPlayer2]
    ]
    state.board[1][1] = [
      [mFree, mFree, mFree],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mFree, mFree]
    ]
    state.board[2][2] = [
      [mPlayer2, mFree, mFree],
      [mPlayer2, mFree, mFree],
      [mPlayer2, mFree, mFree]
    ]
    check checkBoard(state.board) == mPlayer2

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
    state.board[0][0] = winner
    state.board[1][1] = winner
    state.board[2][2] = winner
    state.board[1][0] = drawn
    state.board[2][0] = drawn
    check checkBoard(state.board) == mPlayer2
    
  test "metaboard is drawn":
    let drawn =  [
      [mPlayer2, mPlayer2, mPlayer1],
      [mPlayer1, mPlayer1, mPlayer2],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    for x in 0 .. 2:
      for y in 0 .. 2:
        state.board[x][y] = drawn
    check checkBoard(state.board) == mDraw

  test "illegal situation: both players win board":
    state.board[1][1] = [
      [mPlayer1, mPlayer1, mPlayer1],
      [mPlayer2, mPlayer2, mPlayer2],
      [mFree, mFree, mFree]
    ]
    expect(Exception):
      discard checkBoard(state.board)