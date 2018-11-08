from Token import *

ID, VAR, INTEGER, FLOAT = ('ID', 'VAR', 'INTEGER', 'FLOAT')
ASSIGN, COLON, COMMA, SEMI, EOF = ('=', ':', ',', ';', 'EOF')
LPAREN, RPAREN = ("(",")")
PLUS, MINUS, MUL, DIV = ('+', '-', '*', '/')


# some id variable has been reserved by language
# for example : int/float/var and so on
RESERVED_KEYWORDS = {
    'int': Token(INTEGER, 'int'),
    'float': Token(FLOAT, 'float'),
    'var': Token(VAR, 'var')
}

class Lexer(object):

    """just output Token, Lexer not care current token """
    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.current_char = self.text[self.pos]

    def error(self):
        raise Exception('Error parsing input')

    # not inc pos value
    def peek(self):
        peek_pos = self.pos + 1
        if peek_pos > len(self.text) - 1:
            return None
        else:
            return self.text[peek_pos]

    def _id(self):
        result = ''
        while self.current_char is not None and self.current_char.isalnum():
            result += self.current_char
            self.advance()
        token = RESERVED_KEYWORDS.get(result,Token(ID,result))
        return token

    def advance(self):
        self.pos += 1
        if self.pos > len(self.text) - 1:
            self.current_char = None
        else:
            self.current_char = self.text[self.pos]

    def skip_whitespace(self):
        while self.current_char is not None and self.current_char.isspace():
            self.advance()

    def skip_comment(self):
        pass

    def number(self):
        result = ''
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()

        if self.current_char == '.':
            result += self.current_char
            self.advance()
            while self.current_char is not None and self.current_char.isdigit():
                result += self.current_char
                self.advance()
            token = Token(FLOAT, float(result))
        else:
            token = Token(INTEGER, int(result))
        return token

    def get_next_token(self):
        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue

            # return number
            if self.current_char.isdigit():
                return self.number()

            if self.current_char.isalpha():
                return self._id()

            if self.current_char == ':':
                self.advance()
                return Token(COLON,':')

            if self.current_char == '=':
                self.advance()
                return Token(ASSIGN,'=')

            if self.current_char == ';':
                self.advance()
                return Token(COMMA,';')

            if self.current_char == '*':
                self.advance()
                return Token(MUL, '*')

            if self.current_char == '/':
                self.advance()
                return Token(DIV, '/')

            if self.current_char == '+':
                self.advance()
                return Token(PLUS, '+')

            if self.current_char == '-':
                self.advance()
                return Token(MINUS, '-')

            if self.current_char == "(":
                self.advance()
                return Token(LPAREN, '(')

            if self.current_char == ")":
                self.advance()
                return Token(RPAREN, ')')
            self.error()
        return Token(EOF, None)