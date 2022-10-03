#!python
#cython: language_level=3


from setuptools import setup
from Cython.Build import cythonize

setup(
    name='board_cy',
    ext_modules=cythonize(['Board.pyx',
                           'BestMove.pyx',
                           'main.pyx',
                           'Cell.pyx'],
                          annotate=True, language_level = "3"),
    zip_safe=False,
)