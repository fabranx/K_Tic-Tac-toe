
from main import main

if __name__ == '__main__':
    newgame = True
    board_config = {
        '1': { 'n_forwin': 3, 'n_cells': 3 },
        '2': { 'n_forwin': 4, 'n_cells': 4 },
        '3': { 'n_forwin': 4, 'n_cells': 5 },
        '4': { 'n_forwin': 4, 'n_cells': 6 },

    }
    ai_config={
        '1': 'MONTECARLO',
        '2': 'MINIMAX'
    }

    while True:
        selected_board = input(
            f'Select board configuration: (default: 1)\n\
            1) table: 3x3 - cells for win: 3\n\
            2) table: 4x4 - cells for win: 4\n\
            3) table: 5x5 - cells for win: 4\n\
            4) table: 6x6 - cells for win: 4\n'         
        ) or '1'
        if 1 <= int(selected_board) <= 6:
            break
    while True:
        selected_ai = input('Select AI type: (default: 1)\n\
            1) Montecarlo\n\
            2) Minimax\n'
        ) or '1'
        if 1 <= int(selected_ai) <= 2:
            break
        
    n_forwin = board_config[selected_board]['n_forwin']
    n_cells = board_config[selected_board]['n_cells']
    ai_type = ai_config[selected_ai]

    while newgame:
        newgame = main(n_forwin, n_cells, ai_type)