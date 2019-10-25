import strformat
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
    mFree     ## This mark signals that a cell is empty

  BoardResult* = enum
    rPlayer1, ## The first player has won the board
    rPlayer2, ## The second player has won the board
    rDraw,    ## There is no winner. The board has ended in a draw
    rOpen     ## The game on this board is still ongoing

  GameState* = ref object
    ## Contains all state for a pint in the game
    board*: Board[Board[Mark]]
    players*: array[2, Player]
    currentPlayer*: Player
    result*: BoardResult
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