from AST import *
from Lexer import *

"""
Simple Grammer:

program: statement_list

statement_list: statement
                | (statement)+

statement: declaration_statement  
           | assignment_statement
           | empty

declaration_statement: var ID COLON type_spec # e.g var x: int

assignment_statement: variable ASSIGN expr

expr : term ((PLUS | MINUS) term)*

term : factor ((MUL | DIV) factor)*

factor : PLUS factor
       | MINUS factor
       | INTEGER_CONST
       | REAL_CONST
       | LPAREN expr RPAREN
       | variable

variable: ID

emprty : 

----------- code example -----------
var x:int
var y:int
var z:int
x = 12 + 2
y = 2*x - 1
z = x + (y - 3 * x)
------------------------------------
"""
class Parser(object):
    def __init__(self,lexer):
        self.lexer = lexer
        self.current_token = lexer.get_next_token()

    def error(self):
        raise Exception('Error parsing input')


    def eat(self, token_type):
        if self.current_token.type == token_type:
            self.current_token = self.lexer.get_next_token()
        else:
            self.error()

    def program(self):
        program = Program()
        statements = self.statement_list()
        program.statements.extend(statements)
        return program

    def statement_list(self):
        statements = [] # (statement)+

        node = None
        while self.current_token.type is not EOF:
            # declaration_statement: var ID COLON type_spec # e.g var x: int
            if self.current_token.type == VAR:
                node = self.declaration_statement()

            # assignment_statement: variable ASSIGN expr
            elif self.current_token.type == ID:
                node = self.assignment_statement()
            else:
                self.error()
            statements.append(node)
        return statements


    # declaration_statement: var ID COLON type_spec # e.g var x: int
    def declaration_statement(self):
        self.eat(VAR)
        var_node = Var(self.current_token)
        self.eat(ID)
        self.eat(COLON)
        type_node=self.type_spec()
        var_declaration = VarDecl(var_node,type_node)
        return var_declaration

    def type_spec(self):
        token = self.current_token
        if self.current_token.type == INTEGER:
            self.eat(INTEGER)
        else:
            self.eat(FLOAT)
        node = Type(token)
        return node

    # assignment_statement: variable ASSIGN expr
    def assignment_statement(self):
        left = self.variable()
        token = self.current_token # =
        self.eat(ASSIGN)
        right = self.expr()
        node = Assign(left,token,right)
        return node

    def variable(self):
        node = Var(self.current_token)
        self.eat(ID)
        return node

    def expr(self):
        node = self.term()

        while self.current_token.type in (PLUS, MINUS):
            token = self.current_token

            if token.type == PLUS:
                self.eat(PLUS)
            elif token.type == MINUS:
                self.eat(MINUS)
            node = BinOp(left=node,op=token,right=self.term())
        return node

    def term(self):
        node = self.factor()

        while self.current_token.type in (MUL,DIV):
            token = self.current_token
            if token.type == MUL:
                self.eat(MUL)
            elif token.type == DIV:
                self.eat(DIV)
            node = BinOp(left=node,op=token,right=self.factor())
        return node

    def factor(self):
        token = self.current_token

        if token.type == INTEGER:
            self.eat(INTEGER)
            return Num(token)
        elif token.type == FLOAT:
            self.eat(FLOAT)
            return Num(token)
        elif token.type == LPAREN:
            self.eat(LPAREN)
            node = self.expr()
            self.eat(RPAREN)
            return node
        else:
            node = self.variable()
            return node

    def parse(self):
        node = self.program()
        if self.current_token.type != EOF:
            self.error()

        return node
























