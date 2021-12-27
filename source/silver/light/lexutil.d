module silver.light.lexutil;

import silver.light.lexer : TokenType;

public static int getUnaryOperatorPrecedence(TokenType type) {
    switch(type) {
        case TokenType.Plus:
        case TokenType.Minus:
            return 1;
        default:
            return 0;
    }
}

public static int getBinaryOperatorPrecedence(TokenType type) {
    switch(type) {
        case TokenType.Multiply:
        case TokenType.Divide:
            return 2;
        case TokenType.Plus:
        case TokenType.Minus:
            return 1;
        default:
            return 0;
    }
}