import strformat

type
  Board*[T] =
    array[3, array[3, T]]

  Mark* = enum
    mPlayer1, # The mark of the fist player
    mPlayer2, # The mark of the second player
    mFree     # This mark signals that a cell is empty

  BoardResult* = enum
    rPlayer1, # The first player has won the board
    rPlayer2, # The second player has won the board
    rDraw,    # There is no winner. The board has ended in a draw
    rOpen     # The game on this board is still ongoing

proc newBoard[T](initial: T): Board[T] =
  result = [
    [initial, initial, initial],
    [initial, initial, initial],
    [initial, initial, initial]
  ]

proc newMetaBoard[T](val: T): Board[Board[T]] =
  [
    [newBoard(val), newBoard(val), newBoard(val)],
    [newBoard(val), newBoard(val), newBoard(val)],
    [newBoard(val), newBoard(val), newBoard(val)]
  ]

proc createBoard*(): Board[Board[Mark]] =
  newMetaBoard(mFree)

proc checkBoard*(board: Board[Mark]): BoardResult =
  for x in 0 ..< board.len:
    for y in 0 ..< board.len:
      echo fmt"Cell (x: {x}, y: {y}) = {board[x][y]}"

proc checkBoard*(board: Board[Board[Mark]]): BoardResult =
  rOpen

