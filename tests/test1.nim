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

  test "row checking":    
    state.board[0][0] = [
      [mFree, mFree, mFree],
      [mPlayer1, mPlayer1, mPlayer1],
      [mFree, mFree, mFree]
    ]
    check checkBoard(state.board[0][0]) == rPlayer1

  test "column checking":      
    state.board[0][0] = [
      [mPlayer2, mFree, mPlayer1],
      [mPlayer2, mPlayer1, mFree],
      [mPlayer2, mPlayer1, mFree]
    ]
    check checkBoard(state.board[0][0]) == rPlayer2

  test "check for draw":      
    state.board[0][0] = [
      [mPlayer1, mPlayer2, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer1],
      [mPlayer2, mPlayer1, mPlayer2]
    ]
    check checkBoard(state.board[0][0]) == rDraw

  test "check for open board":      
    state.board[0][0] = [
      [mPlayer1, mPlayer2, mFree],
      [mPlayer1, mFree, mPlayer1],
      [mFree, mPlayer1, mPlayer2]
    ]
    check checkBoard(state.board[0][0]) == rOpen