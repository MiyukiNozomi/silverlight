module silver.light.lexer;

import std.stdio;
import std.ascii;
import std.algorithm;
import std.math.traits;

import silver.light.list;
import silver.light.message;
import silver.light.helpers : getLocation;
import silver.light.syntaxtree : Node, NodeType;

/**token's type enumerator*/
public enum TokenType {
    Identifier,

    HexLiteral,
    StringLiteral,
    CharLiteral,
    IntegerLiteral,
    FloatLiteral,
    DoubleLiteral,
    BinaryLiteral,
    
    //symbols
    LeftParen,
    RightParen,
    LeftBrace,
    RightBrace,
    LeftBracket,
    RightBracket,
    Dot,
    DotRipoff, //idk how ',' is called
    Semicolon,
    
    //operators
    LessThan,
    LessThanEqual,
    MoreThan,
    MoreThanEqual,
    Equal,
    EqualEqual,
    Plus,
    PlusEqual,
    Minus,
    MinusEqual,
    Divide,
    DivideEqual,
    Multiply,
    MultiplyEqual,
    Percentage,
    PercentageEqual,

    ExclamationSign,
    AndAnd,
    Or,

    //keywords
    True,
    False,

    EndOfFile,
    Invalid,
}

/**token's location struct*/
public struct Transformation {
    /**token's line*/
    int line;
    /**token's column*/
    int column;
    /**token's length*/
    int length;
    /**token's index*/
    int index;
}

/** Token */
public class Token : Node {
    /**string representation of the token*/
    public string str;
    /**type of the token*/
    public TokenType type;
    /**Token's Transformation*/
    public Transformation loc;

    /***/
    public this(string str, TokenType type, Transformation loc) {
        this.str = str;
        this.type = type;
        this.loc = loc;
    }

    public override NodeType getType() {
        return NodeType.Token;
    }

    public override List!Node getChildren() {
        return List!Node.empty();
    }
}

/**
    Lexer based off didinele's  css gradient parsing thing
*/
public class Lexer {

    /**current index*/
    public int index;
    /**current input*/
    public string input;
    /**current char*/
    public char current;
    /**filename*/
    public string filename;
    /**last token*/
    public Token last;

    /**constructor, just here to grab the input. and filename*/
    public this(string filename, string input) {
        this.filename = filename;
        this.input = input;
        this.index = 0;
        this.current = next();
    }

    private Token makeToken(string str, TokenType type) {
        int line, column;
        //dscanner keeps asking me to turn these variables into immutable or a const integer,
        //and of course, if i do that i will just break the entirety of getLocation.
        //so, please ignore these 2 additional lines.
        line = 0;
        column = 0;
        getLocation(input, index, cast(int) str.length, line, column);
        Transformation transformation = Transformation(line, column, cast(int) str.length, index);
        return (last = new Token(str,type, transformation));
    }

    private char next() {
        if (index >= input.length) {
            index++; // before you ask "why you are incrementing it if the index is bigger than 0"?
                     // the reason behind that is to return a EOF after the input string ended, 
                     // as it only retuns EOF after the index is bigger than the input string's length.
                     // you can check that in the "getNext()" function.
            return ' '; 
        }

        return input[index++];
    }

    /** returns false if index has passed the input's size, returns true otherwise.*/
    public bool hasNext() {
        return (index <= input.length);
    }

    public Token getNext() {
        if (index > input.length) {
            return makeToken("\0",TokenType.EndOfFile);
        }
        
        if (isWhite(current)) { 
            while (isWhite(current)) { //ignore whitespace
                current = next();
            }
        }
        
        if (current == '/') {
            current = next();
            if (current == '/') {
                while (current != '\n') {
                    //skip comment
                    current = next();
                }
                while (isWhite(current)) { //remove any whitespace
                    current = next();
                }
            } else {
                if (current == '=') {
                    current = next();
                    return makeToken("/=", TokenType.DivideEqual);
                }
                return makeToken("/", TokenType.Divide);
            } 
        }

        if (isAlpha(current) || current == '_') {
            string acc = "";

            while (isAlpha(current) || current == '_' || isDigit(current)) {
                acc ~= current;
                current = next();                
            }
        
            return makeToken(acc, TokenType.Identifier);
        } else if (isDigit(current)) {
            string acc = current ~ "";

            current = next();

            if (current == 'x') { //hexadecimal
                current = next();
                acc ~= "x";

                while (isHexDigit(current)) {
                    acc ~= current;
                    current = next();
                } 

                return makeToken(acc, TokenType.HexLiteral);
            }

            while (isDigit(current) || current == '.' || current == 'i'
                   || current == 'd' || current == 'b' || current == 'f') {
                acc ~= current;
                current = next();
            }

            TokenType type = TokenType.IntegerLiteral;

            if (acc.endsWith('d')) {
                type = TokenType.DoubleLiteral;
            } else if (acc.endsWith('b')) {
                type = TokenType.BinaryLiteral;
            } else if (acc.endsWith('f')) {
                type = TokenType.FloatLiteral;
            }

            return makeToken(acc, type);
        } else if (current == '"') {
            string acc = "";

            while (true) {
                current = next();

                if (current == '\\') {
                    acc ~= current;    
                    current = next();
                    acc ~= current;
                    continue; 
                }

                if (current == '"') {
                    break;
                } else if (current == '\0') {
                    //give error, S3001 unterminated string.
                    return makeToken("invalid-string",TokenType.Invalid);
                }

                acc ~= current;
            }
            current = next();

            return makeToken(acc, TokenType.StringLiteral);
        } else if (current == '\'') {
            string acc = "";

            while (true) {
                current = next();

                if (current == '\\') {
                    acc ~= current;    
                    current = next();
                    acc ~= current;
                    continue; 
                }

                if (current == '\'') {
                    break;
                } else if (current == '\0') {
                    //give error, S3001 unterminated char.
                    return makeToken("invalid-char",TokenType.Invalid);
                }

                acc ~= current;
            }
            current = next();

            return makeToken(acc,TokenType.CharLiteral);
        } else {
            switch(current) {
                case ';': {
                    current = next();
                    return makeToken(";", TokenType.Semicolon);
                }
                case '.': {
                    current = next();
                    return makeToken(".", TokenType.Dot);
                }
                case '(': {
                    current = next();
                    return makeToken("(", TokenType.LeftParen);
                }
                case ')': {
                    current = next();
                    return makeToken(")", TokenType.RightParen);
                }
                case '[': {
                    current = next();
                    return makeToken("[", TokenType.LeftBracket);
                }
                case ']': {
                    current = next();
                    return makeToken("]", TokenType.RightBracket);
                }
                case '{': {
                    current = next();
                    return makeToken("{", TokenType.LeftBrace);
                }
                case '}': {
                    current = next();
                    return makeToken("}", TokenType.RightBrace);
                }
                case '<': {
                    current = next();
                    if (current == '<') {
                        current = next();
                        return makeToken("=<", TokenType.LessThanEqual);
                    }
                    return makeToken("<", TokenType.LessThan);
                }
                case '>': {
                    current = next();
                    if (current == '>') {
                        current = next();
                        return makeToken(">=", TokenType.MoreThanEqual);
                    }
                    return makeToken(">", TokenType.MoreThan);
                }
                case '=': {
                    current = next();
                    if (current == '=') {
                        current = next();
                        return makeToken("==", TokenType.EqualEqual);
                    }
                    return makeToken("=", TokenType.Equal);
                }
                case '+': {
                    current = next();
                    if (current == '=') {
                        current = next();
                        return makeToken("+=", TokenType.PlusEqual);
                    }
                    return makeToken("+", TokenType.Plus);
                }
                case '-': {
                    current = next();
                    if (current == '=') {
                        current = next();
                        return makeToken("-=", TokenType.MinusEqual);
                    }
                    return makeToken("-", TokenType.Minus);
                }
                case '*': {
                    current = next();
                    if (current == '=') {
                        current = next();
                        return makeToken("*=", TokenType.MultiplyEqual);
                    }
                    return makeToken("*", TokenType.Multiply);
                }
                case '%': {
                    current = next();
                    if (current == '=') {
                        current = next();
                        return makeToken("%=", TokenType.PercentageEqual);
                    }
                    return makeToken("%", TokenType.Percentage);
                }
                case '!': {
                    current = next();
                    return makeToken("!", TokenType.ExclamationSign);
                }
                case ',': {
                    current = next();
                    return makeToken(",", TokenType.DotRipoff);
                }
                case '&': {
                    current = next();
                    if (current == '&') {
                        current = next();
                        return makeToken("&&", TokenType.AndAnd);
                    }
                    break;
                }
                case '|': {
                    current = next();
                    if (current == '|') {
                        current = next();
                        return makeToken("||", TokenType.Or);
                    }
                    break;
                }
                default: {
                    break;
                }
            }
        }
 
        current = next();
        int line;
        int column;
        line = 0;
        column = 0;
        getLocation(input, index, 1, line, column);
        Transformation transformation = Transformation(line, column, 1, index);
        _MessageManager.addError(Code.InvalidToken, "Invalid token found! \"" ~ current ~ "\"",
                                 filename, transformation);
        return new Token("not-supported-token", TokenType.Invalid, transformation);
    }      
}