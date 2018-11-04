INTEGER, PLUS, MINUS, MUL, DIV, EOF = 'INTEGER', 'PLUS', 'MINUS', "MUL", "DIV", 'EOF'

class Token(object):

    def __init__(self, type, value):
        self.type = type
        self.value = value

    def __str__(self):
    	return 'Token({type},{value})'.format(type=self.type,value=repr(self.value))

    def __repr__(self):
    	return self.__str__()

class Lexer(object):
	"""docstring for Lexer"""
	def __init__(self, text):
		self.text = text
		self.pos = 0
		self.current_char = self.text[self.pos]

	def error(self):
		raise Exception('Invalid character')
	
	def advance(self):
		self.pos += 1
		if self.pos > len(self.text) - 1:
			self.current_char = None
		else:
			self.current_char = self.text[self.pos]	

	def integer(self):
		result = ''
		while self.current_char is not None and self.current_char.isdigit():
			result += self.current_char;
			self.advance()
		return int(result)

	def skip_whitespace(self):
		while self.current_char is not None and self.current_char.isspace():
			self.advance()

	def get_next_token(self):

		while self.current_char is not None:
			
			if self.current_char.isspace():
				self.skip_whitespace()
				continue

			if self.current_char.isdigit():
				return Token(INTEGER, self.integer())

			if self.current_char == '*':
				self.advance()
				return Token(MUL, '*')

			if self.current_char == '/':
				self.advance()
				return Token(DIV, '/')

			# if self.current_char == '+':
			# 	self.advance()
			# 	return Token(PLUS, '+')

			# if self.current_char == '-':
			# 	self.advance()
			# 	return Token(MINUS, '-')
			self.error()
				
		return Token(EOF,None)

class Interpreter(object):
	"""docstring for Interpreter"""
	def __init__(self, lexer):
		self.lexer = lexer
		self.current_token = None

	def factor(self):
		token = self.current_token
		self.eat(INTEGER)
		return token.value

	def error(self):
		raise Exception('Error parsing input')

	def eat(self, token_type):
		if self.current_token.type == token_type:
			self.current_token = self.lexer.get_next_token()
		else:
			self.error()

	def expr(self):
		"""move current_token point to new now is Integer"""
		self.current_token = self.lexer.get_next_token()

		"""
		eat term(integer) mean move current_token to next new current_token
		indirect move current_char to next new char
		"""
		result = self.factor()# now current_token is point to next

		while self.current_token.type in (MUL, DIV):	
			token = self.current_token
			if token.type == MUL:
				self.eat(MUL) # move to next, in the case is integer
				result *= self.factor()	# move to next , in the case is another term
			elif token.type == DIV:
				self.eat(DIV)
				result /= self.factor()
		
		return result

def main():
	while True:
		try:
			text = raw_input('calc> ')
		except EOFError:
			break
		if not text:
			continue
		lexer = Lexer(text)
		interpreter = Interpreter(lexer)
		result = interpreter.expr()
		print(result)


if __name__ == '__main__':
    main()