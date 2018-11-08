from collections import OrderedDict

"""
Grammer:

program : PROGRAM variable SEMI block DOT

block : declarations compound_statement

declarations : VAR (variable_declaration SEMI)+
             | empty

variable_declaration : ID (COMMA ID)* COLON type_spec

type_spec : INTEGER

compound_statement : BEGIN statement_list END

statement_list : statement
               | statement SEMI statement_list

statement : compound_statement
          | assignment_statement
          | empty

assignment_statement : variable ASSIGN expr

empty :

expr : term ((PLUS | MINUS) term)*

term : factor ((MUL | INTEGER_DIV | FLOAT_DIV) factor)*

factor : PLUS factor
       | MINUS factor
       | INTEGER_CONST
       | REAL_CONST
       | LPAREN expr RPAREN
       | variable

variable: ID

"""

INTEGER_CONST, REAL_CONST, VAR, PROGRAM, BEGIN, END, INTEGER, REAL, PLUS, MINUS, MUL, DIV, LPAREN, RPAREN, ID, ASSIGN, SEMI, DOT, COLON, COMMA, FLOAT_DIV, INTEGER_DIV, EOF = (
     "INTEGER_CONST", "REAL_CONST", "VAR", "PROGRAM", "BEGIN","END","INTEGER","REAL","PLUS", "MINUS", "MUL", "DIV", "(", ")", "ID", ":=", ";", ".",":",",","/","INTEGER_DIV","EOF"
)
PROCEDURE = 'PROCEDURE'

class Token(object):
    def __init__(self, type, value):
        self.type = type
        # token value : 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, '+' or none
        self.value = value

    def __str__(self):
        return 'Token({type},{value})'.format(type=self.type, value=repr(self.value))

    def __repr__(self):
        return self.__str__()



class AST(object):
    pass

class Program(AST):
    def __init__(self, name, block):
        self.name = name
        self.block = block

class Block(AST):
    def __init__(self, declarations, compound_statement):
        # declare statment like : var x:integer
        self.declarations = declarations
        self.compound_statement = compound_statement

# like x y z
class VarDecl(AST):
    def __init__(self,var_node,type_node):
        self.var_node = var_node
        self.type_node = type_node

# INTEGER OR REAL
class Type(AST):
    def __init__(self,token):
        self.token = token
        self.value = token.value

class Compound(AST):
    def __init__(self):
        self.children = []

class Assign(AST):
    def __init__(self,left,op,right):
        self.left = left  # var
        self.token =self.op = op # :=
        self.right = right # expr

class Var(AST):
    def __init__(self,token):
        self.token = token   # Token is ID type
        self.value = token.value

class NoOp(AST):
    pass

class UnaryOp(AST):
    def __init__(self, op, expr):
        self.token = self.op = op
        self.expr = expr
class ProcedureDecl(AST):
    def __init__(self, proc_name, params, block_node):
        self.proc_name = proc_name
        self.params = params
        self.block_node = block_node

class BinOp(AST):
    def __init__(self,left,op,right):
        self.left = left
        self.op = op
        self.right = right

class Num(AST):
    def __init__(self,token):
        self.token = token
        self.value = self.token.value

class Params(AST):
    def __init__(self,var_node,type_node):
        self.var_node = var_node
        self.type_node = type_node

RESERVED_KEYWORDS = {
    'BEGIN': Token('BEGIN', 'BEGIN'),
    'END': Token('END', 'END'),
    'PROGRAM':Token('PROGRAM','PROGRAM'),
    'VAR':Token('VAR','VAR'),
    'DIV':Token('INTEGER_DIV','DIV'),
    'INTEGER':Token('INTEGER','INTEGER'),
    'REAL':Token('REAL','REAL'),
    'PROCEDURE':Token('PROCEDURE','PROCEDURE')
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
        while self.current_char != '}':
            self.advance()
        self.advance()

    def number(self):
        result = ''
        while self.current_char is not None and self.current_char.isdigit():
            result += self.current_char
            self.advance()
        if self.current_char == '.':
            result += self.current_char
            self.advance() # jump the symbol '.'
            while self.current_char is not None and self.current_char.isdigit():
                result += self.current_char
                self.advance()
            token = Token('REAL_CONST',float(result))
        else:
            token = Token('INTEGER_CONST',int(result))

        return token


    def get_next_token(self):

        while self.current_char is not None:
            if self.current_char.isspace():
                self.skip_whitespace()
                continue
            if self.current_char == '{':
                self.advance() # skip the {
                self.skip_comment()
                continue
            if self.current_char.isdigit():
                return self.number()

            if self.current_char.isalpha():
                return self._id()

            if self.current_char == ":" and self.peek() == "=" :
                self.advance()
                self.advance()
                return Token(ASSIGN, ":=")

            if self.current_char == ':':
                self.advance()
                return Token(COLON,':')

            if self.current_char == ',':
                self.advance()
                return Token(COMMA, ',')

            if self.current_char == '/':
                self.advance()
                return Token(FLOAT_DIV, '/')

            if self.current_char == ";":
                self.advance()
                return Token(SEMI, ';')

            if self.current_char == ".":
                self.advance()
                return Token(DOT, ';')

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

class Symbol(object):
    def __init__(self, name, type= None):
        self.name = name
        self.type = type

class BuiltinTypeSymbol(Symbol):
    def __init__(self,name):
        super(BuiltinTypeSymbol,self).__init__(name);

    def __str__(self):
        return self.name

    __repr__ = __str__

class VarSymbol(Symbol):
    def __init__(self,name,type):
        super(VarSymbol,self).__init__(name,type);

    def __str__(self):
        return '<{name}:{type}>'.format(name=self.name,type=self.type)

    __repr__ = __str__

# as function declaration/name
class ProcedureSymbol(Symbol):
    def __init__(self, name, params=None):
        super(ProcedureSymbol, self).__init__(name)
        # a list of formal parameters
        self.params = params if params is not None else []

    def __str__(self):
        return '<{class_name}(name={name}, parameters={params})>'.format(
            class_name=self.__class__.__name__,
            name=self.name,
            params=self.params,
        )

    __repr__ = __str__

class ScopedSymbolTable(object):
    def __init__(self,scope_name,scope_level,enclosing_scope=None):
        self._symbols = OrderedDict()
        self.scope_name = scope_name
        self.scope_level = scope_level
        self.enclosing_scope = enclosing_scope
        self._init_builtins()

    def _init_builtins(self):
        self.insert(BuiltinTypeSymbol('INTEGER'))
        self.insert(BuiltinTypeSymbol('REAL'))

    def __str__(self):
        h1 = 'SCOPE (SCOPED SYMBOL TABLE)'
        lines = ['\n', h1, '=' * len(h1)]
        for header_name, header_value in (
            ('Scope name', self.scope_name),
            ('Scope level', self.scope_level),
        ):
            lines.append('%-15s: %s' % (header_name, header_value))
        h2 = 'Scope (Scoped symbol table) contents'
        lines.extend([h2, '-' * len(h2)])
        lines.extend(
            ('%7s: %r' % (key, value))
            for key, value in self._symbols.items()
        )
        lines.append('\n')
        s = '\n'.join(lines)
        return s

    __repr__ = __str__

    def insert(self, symbol):
        print('Define:%s' % symbol)
        self._symbols[symbol.name] = symbol

    def lookup(self, name):
        print('Lookup:%s' % name)
        symbol = self._symbols.get(name)

        if symbol is not None:
            return symbol

        if self.enclosing_scope is not None:
            return self.enclosing_scope.lookup(name)


class Parser(object):
    def __init__(self, lexer):
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
        self.eat(PROGRAM)
        #type is ID value is the name
        var_node = self.variable()
        prog_name = var_node.value
        self.eat(SEMI)
        # block contains  var_declarations and compound_statements
        block_node = self.block()
        program_node = Program(prog_name, block_node)
        self.eat(DOT) # '.' symbol
        return program_node

    def block(self):
        declaration_nodes = self.declarations()
        compound_statment_node = self.compound_statement()
        node = Block(declaration_nodes,compound_statment_node)
        return node

    def declarations(self):
        # VAR(variable_declaration SEMI)+
        # use ; as the splite symbol
        # But one delcaration may contains multi-variable-declaration
        # like var x,y,z:integer
        declarations = []
        if self.current_token.type == VAR:
            self.eat(VAR)
            while self.current_token.type == ID:
                var_decl = self.variable_declaration()
                declarations.extend(var_decl)
                self.eat(SEMI)

        while self.current_token.type == PROCEDURE:
            self.eat(PROCEDURE)
            proc_name = self.current_token.value
            self.eat(ID) # eat the function name
            formal_parameter_list = None

            if self.current_token.type == LPAREN:
                self.eat(LPAREN)
                formal_parameter_list = self.formal_parameter_list()
                self.eat(RPAREN)

            self.eat(SEMI) # procedure Foo;  procedure Foo(a : INTEGER); procedure Foo(a, b : INTEGER; c : REAL);
            block_node = self.block()
            proc_decl = ProcedureDecl(proc_name, formal_parameter_list,block_node)
            declarations.append(proc_decl)
            self.eat(SEMI)


        return declarations

    def formal_parameter_list(self):
        param_nodes = []

        param_nodes.extend(self.variable_declaration())

        while self.current_token.type == SEMI :
            self.eat(SEMI)
            param_nodes.extend(self.variable_declaration())
        return param_nodes

    def variable_declaration(self):
        var_nodes = [Var(self.current_token)]
        self.eat(ID)

        # , as splite symbol
        while self.current_token.type == COMMA:
            self.eat(COMMA)
            var_nodes.append(Var(self.current_token))
            self.eat(ID)
        self.eat(COLON)
        type_node = self.type_spec()
        var_delarations = [VarDecl(var_node,type_node) for var_node in var_nodes]
        return var_delarations

    def type_spec(self):
        token = self.current_token
        if self.current_token.type == INTEGER:
            self.eat(INTEGER)
        else:
            self.eat(REAL)
        node = Type(token)
        return node


    def compound_statement(self):
        self.eat(BEGIN)
        nodes = self.statement_list()
        self.eat(END)

        root = Compound()
        for node in nodes:
            root.children.append(node)
        return root


    def statement_list(self):
        # get first statement, use ";" as splite symbol
        node = self.statement()
        results = [node]
        while self.current_token.type == SEMI:
            self.eat(SEMI)
            results.append(self.statement())

        if self.current_token.type == ID:
            self.error()
        return results

    def statement(self):
        if self.current_token.type == BEGIN:
            node = self.compound_statement()
        elif self.current_token.type == ID:
            node = self.assignment_statement()
        else:
            node = self.empty()
        return node

    def assignment_statement(self):
        left = self.variable()
        token = self.current_token
        self.eat(ASSIGN)
        right = self.expr()
        node = Assign(left,token,right)
        return node

    def variable(self):
        node = Var(self.current_token)
        self.eat(ID)
        return node

    def empty(self):
        return NoOp()

    def factor(self):
        token = self.current_token
        if token.type == PLUS:
            self.eat(PLUS)
            node = UnaryOp(token,self.factor())
            return node
        elif token.type == MINUS:
            self.eat(MINUS)
            node = UnaryOp(token,self.factor())
            return node
        elif token.type == INTEGER_CONST :
            self.eat(INTEGER_CONST)
            return Num(token)
        elif token.type == REAL_CONST :
            self.eat(REAL_CONST)
            return Num(token)
        elif token.type == LPAREN:
            self.eat(LPAREN)
            node = self.expr()
            self.eat(RPAREN)
        else:
            node = self.variable()
            return node

    def term(self):
        node = self.factor()
        while self.current_token.type in (MUL, INTEGER_DIV, FLOAT_DIV):
            """* or / symbol"""
            token = self.current_token

            if token.type == MUL:
                self.eat(MUL)
            elif token.type == INTEGER_DIV:
                self.eat(INTEGER_DIV)
            elif token.type == FLOAT_DIV:
                self.eat(FLOAT_DIV)

            node = BinOp(left=node,op=token,right=self.factor())

        return node

    def expr(self):

        node = self.term()

        while self.current_token.type in (PLUS, MINUS):
            """* or / symbol"""
            token = self.current_token

            if token.type == PLUS:
                self.eat(PLUS)
            elif token.type == MINUS:
                self.eat(MINUS)
            node = BinOp(left=node,op=token,right=self.term())
        return node

    def parse(self):
        node = self.program()
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
        # self.scope = ScopedSymbolTable(scope_name='global', scope_level=1)
        self.current_scope = None
        self.parser = parser
        self.GLOBAL_SCOPE = {}

    def visit_Program(self,node):
        print('ENTER scope: global')
        global_scope = ScopedSymbolTable(
            scope_name='global',
            scope_level=1,
            enclosing_scope=self.current_scope,#none
        )
        self.current_scope = global_scope

        # visit subtree
        self.visit(node.block)

        print(global_scope)
        self.current_scope = self.current_scope.enclosing_scope
        print('LEAVE scope: global')

    def visit_ProcedureDecl(self,node):
        proc_name = node.proc_name
        proc_symbol = ProcedureSymbol(proc_name)
        self.current_scope.insert(proc_symbol)

        print('ENTER scope: %s' % proc_name)
        # Scope for parameters and local variables
        procedure_scope = ScopedSymbolTable(
            scope_name=proc_name,
            scope_level=self.current_scope.scope_level + 1,
            enclosing_scope=self.current_scope
        )
        self.current_scope = procedure_scope

        for param in node.params:
            param_type = self.current_scope.lookup(param.type_node.value)
            param_name = param.var_node.value
            var_symbol = VarSymbol(param_name, param_type)
            self.current_scope.insert(var_symbol)
            proc_symbol.params.append(var_symbol)

        self.visit(node.block_node)
        print(procedure_scope)
        self.current_scope = self.current_scope.enclosing_scope
        print('LEAVE scope: %s' % proc_name)


    def visit_Block(self,node):
        for declaration in node.declarations:
            self.visit(declaration)
        self.visit(node.compound_statement)

    def visit_VarDecl(self,node):
        type_name = node.type_node.value
        # look up builtin type
        type_symbol = self.current_scope.lookup(type_name)
        var_name = node.var_node.value
        # create new variable, and define into symtab
        var_symbol = VarSymbol(var_name, type_symbol)
        self.current_scope.insert(var_symbol)

    def visit_Type(self, node):
        pass

    def visit_Compound(self,node):
        for child in node.children:
            # we do not need ouput result  just interpret
            self.visit(child)

    def visit_NoOp(self,node):
        pass

    def visit_Assign(self,node):
        var_name = node.left.value
        var_symbol = self.current_scope.lookup(var_name)
        if var_symbol is None:
            raise NameError(repr(var_name))

        self.GLOBAL_SCOPE[var_name] = self.visit(node.right)

    def visit_Var(self, node):
        var_name = node.value
        var_symbol = self.current_scope.lookup(var_name)

        if var_symbol is None:
            raise NameError(repr(var_name))

        val = self.GLOBAL_SCOPE[var_name]
        if val is None:
            raise NameError(repr(var_name))
        else:
            return val



    def visit_BinOp(self,node):
        if node.op.type == PLUS:
            return self.visit(node.left) + self.visit(node.right)
        elif node.op.type == MINUS:
            return self.visit(node.left) - self.visit(node.right)
        elif node.op.type == MUL:
            return self.visit(node.left) * self.visit(node.right)
        elif node.op.type == INTEGER_DIV:
            return self.visit(node.left) // self.visit(node.right)
        elif node.op.type == FLOAT_DIV:
            return float(self.visit(node.left)) / float(self.visit(node.right))

    def visit_Num(self,node):
        return node.value

    def visit_UnaryOp(self,node):
        op = node.op.type
        if op == PLUS:
            return +self.visit(node.expr)
        elif op == MINUS:
            return -self.visit(node.expr)

    def interpret(self):
        tree = self.parser.parse()
        return self.visit(tree)

def main():
    # while True:
    #     try:
    #         try:
    #             text = raw_input('spi> ')
    #         except NameError:
    #             text = input('spi> ')
    #     except EOFError:
    #         break
    #     if not text:
    #         continue
    #     lexer = Lexer(text)
    #     parser = Parser(lexer)
    #     interpreter = Interpreter(parser)
    #     interpreter.interpret()
    #     print(interpreter.GLOBAL_SCOPE)
    file_object = open('source_code.txt')
    try:
        text = file_object.read()
        lexer = Lexer(text)
        parser = Parser(lexer)
        interpreter = Interpreter(parser)
        interpreter.interpret()
        print(interpreter.scope)
        print(interpreter.GLOBAL_SCOPE)

    finally:
        file_object.close()


if __name__ == '__main__':
    main()
