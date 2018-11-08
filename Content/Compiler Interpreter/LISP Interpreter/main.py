EOF = 'EOF'
LPAREN = 'LPAREN'
RPAREN = 'RPAREN'
PLUS, MINUS, MUL, DIV = {
"PLUS", "MINUS", "MUL", "DIV"
}
INTEGER = "INTEGER"



class Token(object):
    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __str__(self):
        return 'Token({type},{value})'.format(type=self.type, value=repr(self.value))

    def __repr__(self):
        return self.__str__()


class AST(object):
    pass

class BinOp(AST):
    def __init__(self,left,op,right):
        self.left = left
        self.op = op
        self.right = right

class Num(AST):
    def __init__(self,token):
        self.token = token
        self.value = self.token.value

class Lexer(object):
    """just output Token, Lexer not care current token """
    def __init__(self, text):
        self.text = text
        self.pos = 0
        self.current_char = self.text[self.pos]

    def error(self):
        raise Exception('Error parsing input')

    def advance(self):
        self.pos += 1
        if self.pos > len(self.text) - 1:
            self.current_char = None
        else:
            self.current_char = self.text[self.pos]

    def skip_whitespace(self):
        while self.current_char is not None and self.current_char.isspace():
            self.advance()


    def integer(self):
        result = ''
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()

        return Token('INTEGER',int(result))

    def get_next_token(self):
        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue

            if self.current_char.isdigit():
                return self.integer()

            if self.current_char == "+":
                self.advance()
                return Token(PLUS,'+')

            if self.current_char == "-":
                self.advance()
                return Token(MINUS,'-')

            if self.current_char == "*":
                self.advance()
                return Token(MUL,'*')

            if self.current_char == "/":
                self.advance()
                return Token(DIV,'/')

            if self.current_char == "(":
                self.advance()
                return Token(LPAREN,'(')

            if self.current_char == ")":
                self.advance()
                return Token(RPAREN,')')

            self.error()
        return Token(EOF,None)

"""
Grammer:

List : LPAREN Expr RPAREN

Expr: (PLUS|MINUS|MUL|DIV) Atom Atom


Atom :  integer |
        List

(+ 2 (- (* 2 4) (/ 100 4)))
"""

class Parser(object):
    def __init__(self,lexer):
        self.lexer = lexer
        self.current_token = self.lexer.get_next_token()

    def error(self):
        raise Exception('Error parsing input')

    def eat(self, token_type):
        if self.current_token.type == token_type:
            self.current_token = self.lexer.get_next_token()
        else:
            self.error()

    def atom(self):
        token = self.current_token

        if token.type == INTEGER:
            self.eat(INTEGER)
            return Num(Token(INTEGER,token.value))
        elif token.type == LPAREN:
            return self.expr()

    def expr(self):
        self.eat(LPAREN)
        node = None
        while self.current_token.type in (PLUS, MINUS, MUL, DIV):
            token = self.current_token

            if token.type == PLUS:
                self.eat(PLUS)
            elif token.type == MINUS:
                self.eat(MINUS)
            elif token.type == DIV:
                self.eat(DIV)
            elif token.type == MUL:
                self.eat(MUL)
            leftNode = self.atom()
            node = BinOp(left=leftNode,op=token,right=self.atom())
            self.eat(RPAREN)

        return node


    def parse(self):
        node = self.expr()
        if self.current_token.type != EOF:
            self.error()

        return node

class NodeVisitor(object):
    def visit(self,node):
        method_name = 'visit_' + type(node).__name__
        visitor = getattr(self,method_name,self.generic_visit)
        return visitor(node)

    def generic_visit(self,node):
        raise Exception('No visit_{} method'.format(type(node).__name__))

class Interpreter(NodeVisitor):
    def __init__(self, parser):
        self.parser = parser

    def visit_Num(self,node):
        return node.value

    def visit_BinOp(self, node):
        if node.op.type == PLUS:
            return self.visit(node.left) + self.visit(node.right)
        elif node.op.type == MINUS:
            return self.visit(node.left) - self.visit(node.right)
        elif node.op.type == MUL:
            return self.visit(node.left) * self.visit(node.right)
        elif node.op.type == DIV:
            return self.visit(node.left) / self.visit(node.right)

    def interpret(self):
        tree = self.parser.parse()
        return self.visit(tree)

def main():
    file_object = open('source_code.txt')
    try:
        text = file_object.read()
        lexer = Lexer(text)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        print(interpreter.interpret())
    finally:
        file_object.close()

if __name__ == '__main__':
    main()

















































