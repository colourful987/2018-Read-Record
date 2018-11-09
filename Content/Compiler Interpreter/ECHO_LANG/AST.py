class AST(object):
    pass

class Program(AST):
    def __init__(self):
        self.statements = []

# if-else condition declaration
class CondBlock(AST):
    def __init__(self):
        self.condBranchs = []

# condition + expr()
# note: now the block node is program
class CondBranchDecl(AST):
    def __init__(self,condition_node,block_node):
        self.condtion = condition_node
        self.block = block_node

# expr </==/> expr
class Condition(AST):
    def __init__(self,left,op,right):
        self.left = left
        self.op = op
        self.right = right

# variable declaration, var x : int
# in abstract tree this is ":" COLON symbol
class VarDecl(AST):
    def __init__(self,var_node, type_node):
        self.var_node = var_node
        self.type_node = type_node

class Assign(AST):
    def __init__(self,left,op,right):
        self.left = left  # var
        self.token =self.op = op # =
        self.right = right # expr

class Type(AST):
    def __init__(self,token):
        self.token = token
        self.value = token.value # "int" "float" string as value

class Var(AST):
    def __init__(self,token):
        self.token = token
        self.value = token.value # x(10)

class NoOp(AST):
    pass

class BinOp(AST):
    # + - * /
    def __init__(self,left,op,right):
        self.left = left
        self.op = op
        self.right = right

class Num(AST):
    def __init__(self,token):
        self.token = token
        self.value = self.token.value