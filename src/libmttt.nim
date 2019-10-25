import sets

include libmttt/types
include libmttt/checks

proc newBoard[T](initial: T): Board[T] =
  ## Create a new game board filled with the initial value
  result = [
    [initial, initial, initial],
    [initial, initial, initial],
    [initial, initial, initial]
  ]

proc newMetaBoard[T](val: T): Board[Board[T]] =
  ## Create the meta board, composed out of 9 normal boards.
  [
    [newBoard(val), newBoard(val), newBoard(val)],
    [newBoard(val), newBoard(val), newBoard(val)],
    [newBoard(val), newBoard(val), newBoard(val)]
  ]

proc newGame*(player1, player2: Player): GameState =
  ## Create a new game board
  GameState(
    players: [player1, player2],
    currentPlayer: player1,
    result: rOpen,
    board: newMetaBoard(mFree))

proc checkBoard*(board: Board[Mark]): BoardResult =
  ## Perform a check on a single sub board to see its result

  # Create a seconded, transposed board.
  # This way 'checkRows' can be used to check the columns 
  var transposed = newBoard(mFree);
  for x in 0 .. 2:
      for y in 0 .. 2:
        transposed[x][y] = board[y][x]

  var states: HashSet[BoardResult]
  states.init()    
  for b in [board, transposed]:
    states.incl(checkRows(b))
  return selectResult(states)
    

proc checkBoard*(board: Board[Board[Mark]]): BoardResult =
  ## Perform a check on a metaboard to see the overall game result
  rOpen
