from Lexer import *

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
        self.GLOBAL_SCOPE = {}

    def visit_VarDecl(self, node):
        pass

    def visit_Type(self, node):
        pass

    def visit_Var(self, node):
        var_name = node.value
        val = self.GLOBAL_SCOPE[var_name]
        if val is None:
            raise NameError(repr(var_name))
        else:
            return val

    def visit_NoOp(self, node):
        pass

    def visit_BinOp(self, node):
        if node.op.type == PLUS:
            return self.visit(node.left) + self.visit(node.right)
        elif node.op.type == MINUS:
            return self.visit(node.left) - self.visit(node.right)
        elif node.op.type == MUL:
            return self.visit(node.left) * self.visit(node.right)
        elif node.op.type == DIV:
            return self.visit(node.left) / self.visit(node.right)

    def visit_Num(self, node):
        return node.value

    def visit_Assign(self, node):
        var_name = node.left.value
        self.GLOBAL_SCOPE[var_name] = self.visit(node.right)

    def visit_CondBlock(self,node):

        for condBranch in node.condBranchs:
            excuted = self.visit(condBranch) # TODO must has break
            if excuted == 1:
                # mean satisfy condition and excute the block , so quit
                break

    def visit_WhileBlock(self,node):
        cond_node = node.condition
        block = node.block

        while(self.visit(cond_node)) :
            self.visit(block)

    def visit_CondBranchDecl(self,node):
        cond_node = node.condition
        block_node = node.block

        excuted = 0
        isSatisfy = 1
        if cond_node is not None:
            # this is else block
            isSatisfy = self.visit(cond_node)

        if isSatisfy != 0 :
            excuted = 1
            self.visit(block_node)
        return excuted

    def visit_Condition(self,node):
        op = node.op
        leftValue = self.visit(node.left)
        rightValue = self.visit(node.right)

        ret = 0
        if op.type == GREATER:
            ret = leftValue > rightValue
        elif op.type == EQUAL:
            ret = leftValue == rightValue
        elif op.type == LESS:
            ret = leftValue < rightValue

        return ret


    def visit_Program(self, node):
        for statement in node.statements:
            self.visit(statement)

    def interpret(self):
        tree = self.parser.parse()
        return self.visit(tree)