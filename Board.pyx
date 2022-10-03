import pygame
from Cell import Cell
import random


#        R    G    B
GRAY = (100, 100, 100)
GREEN = (0, 255, 0)
NAVYBLUE = (60, 60, 100)
YELLOW = (255, 255, 0)
# WHITE = (255, 255, 255)
# RED = (255, 0, 0)
# BLUE = (0, 0, 255)
# ORANGE = (255, 128, 0)
# PURPLE = (255, 0, 255)
# CYAN = (0, 255, 255)


class Board:
    def __init__(self, displaysurf, int width, int height, int rowandcol, int n_forwin):
        self.width = width
        self.height = height
        self.rowandcol = rowandcol
        self.cell_size = int(self.width / self.rowandcol)  # dimensione x,y della cella
        self.displaysurf = displaysurf
        self.n_forwin = n_forwin
        self.__cells = []


        self.displaysurf.fill(GRAY)
        self.Xplayer = pygame.image.load('images/cross.png')
        self.Xplayer = pygame.transform.smoothscale(self.Xplayer, (self.cell_size, self.cell_size))
        self.Oplayer = pygame.image.load('images/circle.png')
        self.Oplayer = pygame.transform.smoothscale(self.Oplayer, (self.cell_size, self.cell_size))
        for i in range(self.rowandcol * self.rowandcol):
            self.__cells.append(Cell())

    def displayBoard(self, displaysurf):
        v_dist_line = self.width / self.rowandcol
        h_dist_line = self.height / self.rowandcol
        for rowcol in range(self.rowandcol - 1):
            v_line_start = (0, rowcol * v_dist_line + v_dist_line)
            v_line_end = (self.height, rowcol * v_dist_line + v_dist_line)
            h_line_start = (rowcol * h_dist_line + h_dist_line, 0)
            h_line_end = (rowcol * h_dist_line + h_dist_line, self.width)
            pygame.draw.line(self.displaysurf, NAVYBLUE, v_line_start, v_line_end, width=2)
            pygame.draw.line(self.displaysurf, NAVYBLUE, h_line_start, h_line_end, width=2)

    def displayMove(self, turn, index=None, pos=None):
        if turn:
            quadrantX = self.posToCell(pos)
            index = quadrantX[0] * self.rowandcol + quadrantX[1]

            if not self.__cells[index].isEmpty():
                return False
            else:
                # self.__cells[index].setSymbol('X')
                self.makeMove(True, index)
                self.displaysurf.blit(self.Xplayer, (self.cell_size * quadrantX[1], self.cell_size * quadrantX[0]))  # ES. quadrante 5 (1,2) cell_size=200 => x=200*2 , y=200*1

        else:
            if index is None:
                emptycellsidx = self.getEmptyCellListIdx()
                index = random.choice(emptycellsidx)  # sceglie indice casuale dalla liste delle celle, tra le celle vuote
            quadrantO = [int(index / self.rowandcol), index % self.rowandcol]  # conversione indice array monodimensionale a indice array bidimensionale (y,x)
            self.makeMove(False, index)
            self.displaysurf.blit(self.Oplayer, (self.cell_size * quadrantO[1], self.cell_size * quadrantO[0]))
        return True

    def makeMove(self, player, index=None):
        if player:
            piece = 'X'
        else:
            piece = 'O'
        if index is None:  # per scelta cella casuale
            try:
                emptycellsidx = self.getEmptyCellListIdx()
                index = random.choice(emptycellsidx)
            except IndexError:
                print(emptycellsidx)
                print(index)

        self.__cells[index].setSymbol(piece)

    def undoMove(self, index):
        self.__cells[index].setSymbol(' ')

    def displayText(self, text, position, font="georgia", dimfont=46, color=GREEN):
        font = pygame.font.SysFont(font, dimfont)
        img = font.render(str(text), True, color)
        rect = img.get_rect()
        rect.center = position
        self.displaysurf.blit(img, (rect.x, rect.y))
        pygame.display.update()

    def posToCell(self, pos):
        quadrant_X = int(pos[0] / self.cell_size)
        quadrant_Y = int(pos[1] / self.cell_size)
        return quadrant_Y, quadrant_X

    def getEmptyCell(self):
        counter = 0
        for cell in self.__cells:
            if cell.isEmpty():
                counter += 1
        return counter

    def getEmptyCellListIdx(self):
        return [i for (i, cell) in enumerate(self.__cells) if cell.getSymbol() == ' ']

    def getCellList(self):
        return [cell.getSymbol() for cell in self.__cells]

    def getObjCellList(self):
        return self.__cells

    def setCellList(self, cell_list):
        if len(cell_list) == len(self.__cells):
            for i, cell in enumerate(cell_list):
                self.__cells[i].setSymbol(cell)

    def CheckWinner(self, player):
        cdef int cell_size = self.cell_size
        cdef double offset = (cell_size / 2)
        checkvert = self.checkVerticalWin(player)
        if checkvert[0]: # se c'è una vittoria verticale 
            startpos = checkvert[1]
            endpos = checkvert[2]
            start = (cell_size * startpos[0] + offset, cell_size * startpos[1] + offset)
            end = (cell_size * endpos[0] + offset, cell_size * endpos[1] + offset)
            pygame.draw.line(self.displaysurf, YELLOW, start, end, width=4)

            return True

        checkhoriz = self.checkHorizzontalWin(player)
        if checkhoriz[0]: # se c'è una vittoria orizzontale 
            startpos = checkhoriz[1]
            endpos = checkhoriz[2]
            pygame.draw.line(self.displaysurf, YELLOW,
                             (cell_size * startpos[0] + offset, cell_size * startpos[1] + offset),
                             (cell_size * endpos[0] + offset, cell_size * endpos[1] + offset), width=4)
            return True

        checkdiagonal = self.checkDiagonalWin(player)
        if checkdiagonal[0]:
            startpos = checkdiagonal[1]
            endpos = checkdiagonal[2]
            pygame.draw.line(self.displaysurf, YELLOW,
                             (cell_size * startpos[0] + offset, cell_size * startpos[1] + offset),
                             (cell_size * endpos[0] + offset, cell_size * endpos[1] + offset), width=4)
            return True

        return False

    def checkVerticalWin(self, player):
        if player:
            piece = 'X'
        else:
            piece = 'O'

        cdef int col = 0
        cdef int count
        cdef int start_cell
        cdef int i
        cdef int rowandcol = self.rowandcol
        cdef int n_forwin = self.n_forwin
        for col in range(0, rowandcol): # se c'è una vittoria diagonale
            count = 0
            start_cell = 0
            for i, cell in enumerate(self.__cells):
                if i % rowandcol == col:
                    if cell.getSymbol() == piece:
                        count += 1
                    else:
                        count = 0
                        start_cell = (i // rowandcol) +1
                    if count >= n_forwin:
                        return True, (col, start_cell), (col, start_cell+count-1)

        return (False,)

    def checkHorizzontalWin(self, player):
        if player:
            piece = 'X'
        else:
            piece = 'O'

        cdef int row = 0
        cdef int count
        cdef int i
        cdef int start_cell
        cdef int n_forwin = self.n_forwin
        cdef int rowandcol = self.rowandcol
        for row in range(0, rowandcol):
            # per ogni riga (indice inizio riga = row*self.rowandcol),
            # considera tutta la riga (indice fine riga = (row+1)*self.rowandcol)
            therow = self.__cells[row * rowandcol: (row + 1) * rowandcol]
            therow = [cell.getSymbol() for cell in therow]

            count = 0
            start_cell = 0
            for i, cell in enumerate(therow):
                if cell == piece:
                    count += 1
                else:
                    count = 0
                    start_cell = i+1
                if count >= n_forwin:
                    return True, (start_cell, row), (start_cell + count - 1, row)

        return (False,)

    def checkDiagonalWin(self, player):
        if player:
            piece = 'X'
        else:
            piece = 'O'
        cdef int rowandcol = self.rowandcol
        cdef int n_forwin = self.n_forwin
        cdef int diag_offset = rowandcol - n_forwin + 1
        cdef int n, m, count, start_cell, i
        for n in range(diag_offset):

            diag_row1 = []  # \ diagonale la cui cella di partenza varia in base al numero di riga n
            diag_col1 = []  # \ diagonale la cui cella di partenza varia in base al numero di colonna n
            diag_row2 = []  # / diagonale la cui cella di partenza varia in base al numero di riga n
            diag_col2 = []  # / diagonale la cui cella di partenza varia in base al numero di colonna n

            for m in range(rowandcol - n):
                diag_row1.append(self.__cells[m * (rowandcol+1) + (rowandcol * n)].getSymbol())  #   Diagonale che parte dalla riga n posizione 0 -> @ # # # #   e per ogni riga m aggiunge la cella calcolata
                diag_row2.append(self.__cells[m * (rowandcol-1) + (rowandcol * (n+1) - 1)].getSymbol())  # Diagonale che parte dalla riga n posizione self.rowandcol-1  # # # # @ <-    e per ogni riga m aggiunge la cella calcolata
                diag_col1.append(self.__cells[m * (rowandcol + 1) + n].getSymbol())
                diag_col2.append(self.__cells[m * (rowandcol - 1) + rowandcol-1 - n].getSymbol())

            count = 0
            start_cell = 0
            for i, cell in enumerate(diag_row1):
                if cell == piece:
                    count += 1
                else:
                    count = 0
                    start_cell = i+1
                if count >= n_forwin:
                    return True, (start_cell, start_cell + n), \
                           (start_cell + count-1, start_cell + n + count-1)


            count = 0
            start_cell = 0
            for i, cell in enumerate(diag_row2):
                if cell == piece:
                    count += 1
                else:
                    count = 0
                    start_cell = i+1
                if count >= n_forwin:
                    return True, (rowandcol-1 - start_cell , start_cell + n), \
                           (rowandcol-1 - start_cell - count+1, start_cell + n + count-1)

            count = 0
            start_cell = 0
            for i, cell in enumerate(diag_col1):
                if cell == piece:
                    count += 1
                else:
                    count = 0
                    start_cell = i+1
                if count >= n_forwin:
                    return True, (start_cell + n, start_cell), \
                           (start_cell + n + count-1, start_cell + count-1)

            count = 0
            start_cell = 0
            for i, cell in enumerate(diag_col2):
                if cell == piece:
                    count += 1
                else:
                    count = 0
                    start_cell = i+1
                if count >= n_forwin:
                    return True, (rowandcol-1 - start_cell - n, start_cell), \
                           (rowandcol-1 - start_cell - n - count+1, start_cell + count-1)

        return (False,)

    def possiblewins(self, player):

        if player:
            piece = 'X'
            opponent = 'O'
        else:
            piece = 'O'
            opponent = 'X'

        cdef int win_count = 0
        cdef int n_forwin = self.n_forwin

        # POSSIBILITÀ DI VITTORIE VERTICALI
        cdef int countsimilar = 0
        cdef int col = 0
        cdef int rowandcol = self.rowandcol
        for col in range(0, rowandcol):
            countsimilar = 0
            for i, cell in enumerate(self.__cells):
                if i % self.rowandcol == col:
                    if cell.getSymbol() != opponent:
                        countsimilar += 1
                    else:
                        countsimilar = 0

            if countsimilar >= n_forwin:
                win_count += 1

        # POSSIBILITÀ DI VITTORIE ORIZZONTALI
        cdef int row = 0 
        for row in range(0, rowandcol):
            canwin = True
            countsimilar = 0
            # per ogni riga (indice inizio riga = row*self.rowandcol), considera tutta la riga (indice fine riga = (row+1)*self.rowandcol)
            therow = self.__cells[row * rowandcol: (row + 1) * rowandcol]
            therow = [cell.getSymbol() for cell in therow]

            for cell in therow:
                if cell != opponent:
                    countsimilar += 1
                else:
                    countsimilar = 0

            if countsimilar >= n_forwin:
                win_count += 1

        # POSSIBILITÀ DI VITTORIE DIAGONALI
        cdef int diag_offset = rowandcol - n_forwin + 1
        cdef int n = 0
        cdef int m

        for n in range(diag_offset):
            diag_row1 = [] 
            diag_row2 = [] 
            diag_col1 = [] 
            diag_col2 = [] 

            for m in range(rowandcol - n):
                diag_row1.append(self.__cells[m * (rowandcol+1) + (rowandcol * n)].getSymbol())
                diag_row2.append(self.__cells[m * (rowandcol-1) + (rowandcol * (n+1) - 1)].getSymbol())
                diag_col1.append(self.__cells[m * (rowandcol + 1) + n].getSymbol())
                diag_col2.append(self.__cells[m * (rowandcol - 1) + rowandcol-1 - n].getSymbol())


            countsimilar = 0
            for cell in diag_row1:
                if cell != opponent:
                    countsimilar += 1
                else:
                    countsimilar = 0
            if countsimilar >= n_forwin:
                win_count += 1


            countsimilar = 0
            for cell in diag_row2:
                if cell != opponent:
                    countsimilar += 1
                else:
                    countsimilar = 0
            if countsimilar >= n_forwin:
                win_count += 1


            countsimilar = 0
            for cell in diag_col1:
                if cell != opponent:
                    countsimilar += 1
                else:
                    countsimilar = 0
            if countsimilar  >= n_forwin:
                win_count += 1


            countsimilar = 0
            for cell in diag_col2:
                if cell != opponent:
                    countsimilar += 1
                else:
                    countsimilar = 0
            if countsimilar >= n_forwin:
                win_count += 1

        return win_count