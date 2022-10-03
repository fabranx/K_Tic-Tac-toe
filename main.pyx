import pygame
from pygame.locals import *
import sys
from Board import Board
from BestMove import bestMoveMinimax, bestMoveMonteCarlo
import time
import random


def main(n_forwin=4, n_cells=5, ai_type='MONTECARLO'):

    cdef int FPS = 20
    cdef int WINHEIGHT = 400
    cdef int WINWIDTH = 400
    cdef int N_FORWIN = n_forwin
    cdef int ROWANDCOL = n_cells
  
    TURN = random.choices([True, False])[0]  # true player1 - false player2 or IA
    print(f"First to play: {'player' if TURN else 'AI'}")
    randomAIFirstMove = False # random.choices([True, False])[0]
    gameover = False
    aiwin = False
    playerwin = False
    AI_TYPE = ai_type  # 'MONTECARLO' or 'MINIMAX'

    pygame.init()
    FPSCLOCK = pygame.time.Clock()
    pygame.display.set_caption('Game')

    DISPLAYSURF = pygame.display.set_mode((WINWIDTH, WINHEIGHT))
    board = Board(DISPLAYSURF, WINWIDTH, WINHEIGHT, ROWANDCOL, N_FORWIN)
    board.displayBoard(DISPLAYSURF)
    
    pygame.display.update()
    FPSCLOCK.tick(FPS)

    while True:
        if aiwin:
            print("AI WIN")
            board.displayText("AI WIN", (WINWIDTH/2, WINHEIGHT/2))
            ret = eventwait()
            print(ret)
            pygame.display.update()
            return ret
        if playerwin:
            print("PLAYER WIN")
            board.displayText("YOU WIN", (WINWIDTH/2, WINHEIGHT/2))
            ret = eventwait()
            print(ret)
            pygame.display.update()
            return ret

        if board.getEmptyCell() == 0:
            print("GAMEOVER")
            gameover = True
            pygame.display.update()

        if gameover:
            board.displayText("DRAW", (WINWIDTH / 2, WINHEIGHT / 2))
            ret = eventwait()
            print(ret)
            pygame.display.update()
            return ret

        for event in pygame.event.get():  # event handling loop
            if event.type == QUIT:
                pygame.quit()
                sys.exit()

            if TURN:
                pygame.event.set_allowed(pygame.MOUSEBUTTONDOWN)
                if event.type == MOUSEBUTTONDOWN:
                    mouseposition = event.pos
                    moveState = board.displayMove(TURN, pos=mouseposition)
                    mouseposition = None
                    if moveState:
                        TURN = not TURN
                        playerwin = board.CheckWinner(True)

            else:
                pygame.event.set_blocked(pygame.MOUSEBUTTONDOWN)
                if randomAIFirstMove:  # la prima mossa è casuale
                    moveState = board.displayMove(TURN)
                    randomAIFirstMove = False
                else:
                    start = time.time()
                    if AI_TYPE == 'MONTECARLO':
                        move = bestMoveMonteCarlo(board)
                    elif AI_TYPE == 'MINIMAX':
                        move = bestMoveMinimax(board)
                    else:
                        print("AI_TYPE ERROR")
                        pygame.quit()
                        sys.exit()

                    end = time.time()
                    print(f"AI time for play: {int(end-start)}s")
                    moveState = board.displayMove(TURN, index=move)

                if moveState:
                    TURN = not TURN
                    aiwin = board.CheckWinner(False)
                    
        pygame.display.update()
        FPSCLOCK.tick(FPS)


def eventwait():
    pygame.event.set_allowed(MOUSEBUTTONDOWN)
    while True:
        ev = pygame.event.wait()
        if ev.type == QUIT:
            pygame.quit()
            sys.exit()
        if ev.type == KEYDOWN:
            if ev.key == K_ESCAPE:
                pygame.quit()
                return False  # return False = exit
        if ev.type == MOUSEBUTTONDOWN:  # return True = new game
            return True

