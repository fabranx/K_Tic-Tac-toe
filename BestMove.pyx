from math import inf as infinity

def bestMoveMonteCarlo(board):
    cdef int bestscore = 0
    cdef int playoutpermove = 1000  # numero di giocate casuali effettuate per ogni cella libera
    cdef int move = 0
    cdef int score_avg = 0
    cdef int p
    bestmoveScore = -infinity
    turn = False

    cdef int free_cells = board.getEmptyCell()
    if free_cells > 40:
        playoutpermove = 1000
    elif 30 < free_cells <= 40:
        playoutpermove = 1500
    elif 20 < free_cells <= 30:
        playoutpermove = 3000
    elif 10 < free_cells <= 20:
        playoutpermove = 6000
    else:
        playoutpermove = 7000 
    
    if free_cells <=1:
        move = board.getEmptyCellListIdx()[0]
        return move

    for cell in board.getEmptyCellListIdx():
        board.makeMove(False, cell)
        turn = not turn

        # SAVE BOARD
        bkpcellsSymbol = board.getCellList()
        turncpy = turn

        score_avg = 0
        
        for p in range(playoutpermove):
            # continua fino a quando checkWinner() (e quindi result) NON ritorna False, se ritorna False il ciclo continua
            # se la partita è finita (se c'è un vincitore o un pareggio) il risultato viene salvato in result
            while True:
                board.makeMove(turn)
                turn = not turn
                result = checkWinner(board)
                if result is not None:
                    break

            score_avg += scores[result] * board.getEmptyCell()

            # RESTORE BOARD
            board.setCellList(bkpcellsSymbol)
            turn = turncpy

        score_avg /= playoutpermove
        if score_avg > bestmoveScore:
            bestmoveScore = score_avg
            move = cell

        board.undoMove(cell)
        turn = not turn

    return move


def bestMoveMinimax(board):
    cdef int DEPTH
    cdef int rowandcol = board.rowandcol

    cdef int free_cells = board.getEmptyCell()
    if free_cells > 45:
        DEPTH = 1
    elif 40 < free_cells <= 45:
        DEPTH = 2
    elif 28 < free_cells <= 40:
        DEPTH = 3
    elif 16 < free_cells <= 28:
        DEPTH = 4
    elif 12 < free_cells <= 16:
        DEPTH = 5
    else:
        DEPTH = 6

    alpha = -infinity
    beta = infinity
    bestscore = -infinity
    cdef int move = 0
    for cell in board.getEmptyCellListIdx():
        board.makeMove(False, cell)
        # score = minimax(DEPTH, True, board)
        score = minimize(DEPTH, alpha, beta, board)
        board.undoMove(cell)

        if score > bestscore:
            bestscore = score
            move = cell

    return move


scores = {"X": -10, "O": 10, "tie": 0}

def checkWinner(board):
    if board.checkVerticalWin(False)[0] or board.checkHorizzontalWin(False)[0] or board.checkDiagonalWin(False)[0]:
        return "O"
    elif board.checkVerticalWin(True)[0] or board.checkHorizzontalWin(True)[0] or board.checkDiagonalWin(True)[0]:
        return "X"
    elif board.getEmptyCell() == 0:
        return "tie"
    else:
        return None

def evaluate(board):
    return board.possiblewins(False) - board.possiblewins(True)

def minimize(d, alpha, beta, board):
    result = checkWinner(board)
    if result:
        return (d+1) * scores[result]
    if d == 0:
        return evaluate(board)

    vMin = infinity
    cdef int mval
    for cell in board.getEmptyCellListIdx():
        board.makeMove(True, cell)
        mval = maximize(d - 1, alpha, beta, board)
        vMin = min(mval, vMin)

        beta = min(mval, beta)

        board.undoMove(cell)

        if mval <= alpha:
            break

    return vMin

def maximize(d, alpha, beta, board):
    result = checkWinner(board)
    if result:
        return (d+1) * scores[result]

    if d == 0:
        return evaluate(board)

    vMax = -infinity
    cdef int mval
    for cell in board.getEmptyCellListIdx():
        board.makeMove(False, cell)
        mval = minimize(d - 1, alpha, beta, board)
        vMax = max(mval, vMax)

        alpha = max(mval, alpha)

        board.undoMove(cell)

        if mval >= beta:
            break

    return vMax

# def minimax(d, turn, board):
#     result = checkWinner(board)
#     if result:
#         # print(f"{d} : {result}")
#         return scores[result]

#     if d == 0:
#         return evaluate(board)

#     if turn:
#         bestscore = -infinity
#         for cell in board.getEmptyCellListIdx():
#             board.makeMove(False, cell)
#             score = minimax(d-1, False, board)
#             board.undoMove(cell)
#             bestscore = max(score, bestscore)
#         return bestscore
#     else:
#         bestscore = infinity
#         for cell in board.getEmptyCellListIdx():
#             board.makeMove(True, cell)
#             score = minimax(d-1, True, board)
#             board.undoMove(cell)
#             bestscore = min(score, bestscore)
#         return bestscore