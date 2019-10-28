import sets, strformat, options

type
  ## A game board is a simple 2 dimensional array.
  ## Markers of any type can be placed inside the cells
  Board*[T] = array[3, array[3, T]]

  Player* = ref object
    mark*: Mark
    name*: string

  Mark* = enum
    mPlayer1, ## The mark of the fist player
    mPlayer2, ## The mark of the second player
    mFree,    ## This mark signals that a cell is empty
    mDraw     ## Special mark to indicate the game has ended in a draw

  GameState* = ref object
    ## Contains all state for a pint in the game
    board*: Board[Board[Mark]]
    players*: array[2, Player]
    currentPlayer*: Player
    currentBoard*: Option[(int, int)]
    result*: Mark
    turn*: int

proc `$`*(player: Player): string = 
  $player.name

proc `$`*(game: GameState): string = 
  &"""
  Game is in turn {$game.turn}
  Players are: '{$game.players[0]}' and '{$game.players[1]}'
  Current player: '{$game.currentPlayer}'
  Game state is: {$game.result}
  """

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
    result: mFree,
    board: newMetaBoard(mFree))

###################################################
# Board Checking
###################################################

proc selectResult(states: HashSet[Mark]): Mark =
  ## Analyse a set of results and select the correct one
  if states.contains(mPlayer1) and
      states.contains(mPlayer2):
      raise newException(Exception, "Both players cannot win at the same time")

  if states.contains(mPlayer1):
    return mPlayer1
  if states.contains(mPlayer2):
    return mPlayer2
  if states.contains(mFree):
    return mFree
  return mDraw

proc checkRow(row: array[3, Mark]): Mark =
  var tokens = toHashSet(row)
  # A player has won
  if tokens.len == 1 and not tokens.contains(mFree):
    return tokens.pop()
  # The row is full
  if tokens.len == 2 and not tokens.contains(mFree):
    return mDraw
  # There are still cells free in this row
  return mFree

proc checkRows(board: Board[Mark]): Mark =
  ## Iterate over all rows of this board and return the result.
  var states: HashSet[Mark]
  states.init()
  for row in board:
    states.incl(checkRow(row))
  return states.selectResult()

proc checkDiagonals(board: Board[Mark]): Mark =
  var states: HashSet[Mark]
  states.init()
  var topToBottom: array[3, Mark]
  var bottomToTop: array[3, Mark]
  for x in 0 .. 2:
    topToBottom[x] = board[x][x]
    bottomToTop[x] = board[2-x][x]
  states.incl(checkRow(topToBottom))
  states.incl(checkRow(bottomToTop))
  return states.selectResult()

proc checkBoard*(board: Board[Mark]): Mark =
  ## Perform a check on a single sub board to see its result

  # Create a seconded, transposed board.
  # This way 'checkRows' can be used to check the columns 
  var transposed = newBoard(mFree);
  for x in 0 .. 2:
      for y in 0 .. 2:
        transposed[x][y] = board[y][x]

  var states: HashSet[Mark]
  states.init()
  states.incl(checkDiagonals(board))
  for b in [board, transposed]:
    states.incl(checkRows(b))

  return selectResult(states)
    

proc checkBoard*(board: Board[Board[Mark]]): Mark =
  ## Perform a check on a metaboard to see the overall game result

  # This temporary board will hold the intermediate results from each sub board
  var subResults = newBoard(mFree)
  var states: HashSet[Mark]
  states.init()
  for x in 0 .. 2:
    for y in 0 .. 2:
      subResults[x][y] = checkBoard(board[x][y])
  return checkBoard(subResults)
