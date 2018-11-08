from Interpreter import *
from Parser import  *
from Lexer import  *

def main():
    file_object = open('source_code.txt')
    try:
        text = file_object.read()
        lexer = Lexer(text)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        interpreter.interpret()
        print(interpreter.GLOBAL_SCOPE)

    finally:
        file_object.close()


if __name__ == '__main__':
    main()