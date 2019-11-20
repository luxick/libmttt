import sets, options, sequtils

type
  ## A game board is a 2 dimensional array.
  ## Markers of any type can be placed inside the cells
  Board*[T] = array[3, array[3, T]]

  ## A Position on a board
  Coordinate* = tuple[x: int, y:int]

  Player* = ref object
    mark*: Mark
    name*: string

  Mark* {.pure.} = enum
    Player1, ## The mark of the fist player
    Player2, ## The mark of the second player
    Free,    ## This mark signals that a cell is empty
    Draw     ## Special mark to indicate the game has ended in a draw

  GameState* = ref object
    ## Contains all state for a game
    board*: Board[Board[Mark]]
    players*: array[2, Player]
    currentPlayer*: Player
    currentBoard*: Option[Coordinate]
    result*: Mark
    turn*: int

  IllegalMoveError* = object of Exception
  IIlegalStateError* = object of Exception

###################################################
# Constructors
###################################################

proc newBoard[T](initial: T): Board[T] =
  ## Create a new game board filled with the initial value
  result = [
    [initial, initial, initial],
    [initial, initial, initial],
    [initial, initial, initial]
  ]

proc newGameState*(player1: var Player, player2: var Player): GameState =
  ## Initializes a new game state with the passed players
  player1.mark = Mark.Player1
  player2.mark = Mark.Player2
  GameState(
    players: [player1, player2],
    currentPlayer: player1,
    result: Mark.Free,
    board: newBoard(newBoard(Mark.Free))) # The meta board is a board of boards

###################################################
# Board Checking
###################################################

proc selectResult(states: HashSet[Mark]): Mark =
  ## Analyse a set of results and select the correct one
  if states.contains(Mark.Player1) and
      states.contains(Mark.Player2):
      raise newException(IIlegalStateError, "Both players cannot win at the same time")

  if states.contains(Mark.Player1):
    return Mark.Player1
  if states.contains(Mark.Player2):
    return Mark.Player2
  if states.contains(Mark.Free):
    return Mark.Free
  return Mark.Draw

proc transposed(board: Board): Board =
  ## Flip a board along the axis from top left to bottom right
  result = newBoard(Mark.Free);
  for x in 0 .. 2:
      for y in 0 .. 2:
        result[x][y] = board[y][x]

proc flipped(board: Board): Board = 
  ## Flip a board along the center horizonal axis
  result = newBoard(Mark.Free)
  for x in 0 .. 2:
    result[x] = board[2-x]

proc checkRow(row: array[3, Mark]): Mark =
  ## Evaluates a single row of a board
  var tokens = toHashSet(row)
  # A player has won
  if tokens.len == 1 and not tokens.contains(Mark.Free):
    return tokens.pop()
  # The row is full
  if tokens.len == 2 and not tokens.contains(Mark.Free):
    return Mark.Draw
  # There are still cells free in this row
  return Mark.Free

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
  # Construct a temporary row from the diagonal indices, so checkRow cann be used
  var row: array[3, Mark]
  # Flip the board so the other diagonal is checked too.
  for b in [board, board.flipped]:
    for x in 0 .. 2:
      row[x] = b[x][x]
    states.incl(checkRow(row))
  return states.selectResult()

proc checkBoard*(board: Board[Mark]): Mark =
  ## Perform a check on a single sub board to see its result
  var states: HashSet[Mark]
  states.init()
  states.incl(checkDiagonals(board))
  # Create a seconded, transposed board.
  # This way 'checkRows' can be used to check the columns
  for b in [board, board.transposed]:
    states.incl(checkRows(b))

  return selectResult(states)
    
proc checkBoard*(board: Board[Board[Mark]]): Mark =
  ## Perform a check on a metaboard to see the overall game result
  # This temporary board will hold the intermediate results from each sub board
  var subResults = newBoard(Mark.Free)
  for x in 0 .. 2:
    for y in 0 .. 2:
      subResults[x][y] = checkBoard(board[x][y])
  return checkBoard(subResults)

###################################################
# Process Player Moves
###################################################

proc makeMove*(state: GameState, cell: Coordinate): void =
  if state.result != Mark.Free:
    raise newException(IllegalMoveError, "The game has already ended")
  if cell.x > 2 or cell.y > 2:
    raise newException(IndexError, "Move target not in bounds of the board")
  if state.currentBoard.isNone:    
    raise newException(IllegalMoveError, "No board value passed")

  let board = state.currentBoard.get()
  var currBoard = state.board[board.x][board.y]

  if currBoard[cell.x][cell.y] != Mark.Free:
    raise newException(IllegalMoveError, "Chosen cell is not free")

  state.board[board.x][board.y][cell.x][cell.y] = state.currentPlayer.mark
  state.turn += 1  
  state.result = checkBoard(state.board)

  # Exit early. The game has ended.
  if state.result != Mark.Free:
    state.currentBoard = none(Coordinate)
    return

  let nextBoard = checkBoard(state.board[cell.x][cell.y])
  if nextBoard == Mark.Free:
    state.currentBoard = cell.some()
  else:
    state.currentBoard = none(Coordinate)

  state.currentPlayer = state.players.filter(proc (p: Player): bool = 
    p.mark != state.currentPlayer.mark)[0]

proc makeMove*(state: GameState, cell: Coordinate, boardChoice: Coordinate): void =
  if state.result != Mark.Free:
    raise newException(IllegalMoveError, "The game has already ended")
  if checkBoard(state.board[boardChoice.x][boardChoice.y]) != Mark.Free:
    raise newException(IllegalMoveError, "Player must choose an open board to play in")
  if state.currentBoard.isSome:
    raise newException(IllegalMoveError, "Player does not have free choice for board")
  state.currentBoard = boardChoice.some()
  state.makeMove(cell)