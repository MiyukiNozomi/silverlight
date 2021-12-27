module silver.light.parser;

import std.conv : to;
import std.traits : OriginalType;

import silver.light.list;
import silver.light.lexer;
import silver.light.lexutil;
import silver.light.message;
import silver.light.syntaxtree;

/***/
public class Parser {
    
    /***/
    private int position;
    /***/
    private List!Token tokens;
    /***/
    private string filename;

    /***/
    private Token _Current() {return peek(0);}

    /**
        i mean, this is pretty much self-explanatory.

        before you ask, the only reason we take the filename here
        is when we need to write an error for example, other than that its useless.
    */
    public this(string filename, string content) {
        this.filename = filename;
        this.position = 0;
        this.tokens = new List!Token();

        Lexer lexer = new Lexer(filename, content);

        Token t;

        do {
            t = lexer.getNext();

            if (t.type != TokenType.Invalid) {
                tokens.add(t);
            }
        } while (t.type != TokenType.EndOfFile);

    }

    /** parsers the file specified in the constructor. */
    public ASyntaxTree parse() {
        ExpressionNode node = parseExpression();
        Token endOfFIle = match(TokenType.EndOfFile);
        return new ASyntaxTree(node, endOfFIle);
    }

    private ExpressionNode parseExpression(int parentPrecedence = 0) {
        ExpressionNode left;

        int unaryOperatorPrecedence = _Current.type.getUnaryOperatorPrecedence();

        if (unaryOperatorPrecedence != 0 && unaryOperatorPrecedence >= parentPrecedence) {
            Token operatorToken = nextToken();
            ExpressionNode operand = parseExpression(unaryOperatorPrecedence);
            left = new UnaryNode(operatorToken, operand);
        } else {
            left = parsePrimary();
        }

        while (true) {
            int precedence = getBinaryOperatorPrecedence(_Current.type);

            if (precedence == 0 || precedence <= parentPrecedence)
                break;

            Token operator = nextToken();
            ExpressionNode right = parseExpression(precedence);
            left = new BinaryNode(left, operator, right);
        }

        return left;
    }

    private ExpressionNode parsePrimary() {
        if (_Current.type == TokenType.LeftParen) {
            Token left = nextToken();
            ExpressionNode expression = parseExpression();
            Token right = match(TokenType.RightParen);

            return new ParenthesisExpression(left, expression, right);
        }
        return new LiteralNode(match(TokenType.IntegerLiteral));
    }

    private Token match(TokenType type) {
        if (_Current.type == type) {
            return nextToken();
        }
        _MessageManager.addError(Code.ExpectedToken, "Expected a Token of type: " ~
            to!string(cast(OriginalType!TokenType) type), filename, _Current.loc);

        //make a replacement token instead
        return new Token("", type, _Current.loc);
    }

    private Token nextToken() {
        Token current = _Current;
        position++;
        return current;
    }

    private Token peek(int offset) { 
        const int index = position + offset;
        if (index >= tokens.size()) {
            return tokens.get(cast(int) (tokens.size() - 1));
        }
        return tokens.get(index);
    }
}