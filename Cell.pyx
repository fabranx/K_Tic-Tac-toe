class Cell:
    def __init__(self):
        self.__symbol = ' '

    def isEmpty(self):
        if self.__symbol == ' ':
            return True
        else:
            return False

    def getSymbol(self):
        return self.__symbol

    def setSymbol(self, symbol):
        self.__symbol = symbol

    def __str__(self):
        return f"{self.getSymbol()}"
