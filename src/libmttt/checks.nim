import sets

import types

proc selectResult(states: HashSet[BoardResult]): BoardResult =
  ## Analyse a set of results and select the correct one
  if states.contains(rPlayer1) and
      states.contains(rPlayer2):
      raise newException(Exception, "Both players cannot win at the same time")

  if states.contains(rPlayer1):
    return rPlayer1
  if states.contains(rPlayer2):
    return rPlayer2
  if states.contains(rOpen):
    return rOpen
  return rDraw

proc checkRow(row: array[3, Mark]): BoardResult =
  var tokens = toHashSet(row)
  # A player has won
  if tokens.len == 1 and not tokens.contains(mFree):
    let rowResult = tokens.pop()
    if rowResult == mPlayer1:
      return rPlayer1
    else:
      return rPlayer2
  # The row is full
  if tokens.len == 2 and not tokens.contains(mFree):
    return rDraw
  # There are still cells free in this row
  else:
    return rOpen

proc checkRows(board: Board[Mark]): BoardResult =
  ## Iterate over all rows of this board and return the result.
  var states: HashSet[BoardResult]
  states.init()
  for row in board:
    states.incl(checkRow(row))
  return states.selectResult()
  