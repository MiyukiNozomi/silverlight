module silver.light.ast;

import silver.light.list;
import silver.light.lexer;

/***/
public enum NodeType {
    Node,
    Token,
    Literal,
    UnaryExpression,
    BinaryExpression,
    ParenthesisExpression,
}

/**a expression node*/
public abstract class ExpressionNode : Node {
}

/** a node that holds a value*/
public class LiteralNode : ExpressionNode {

    /***/
    public Token literalToken;

    /***/
    public this(Token literalToken) {
        this.literalToken = literalToken;
    }

    public override NodeType getType() {
        return NodeType.Literal;
    }

    public override List!Node getChildren() {
        return List!Node.yield([literalToken]);
    }
}

/**holds a parenthesized expression */
public class ParenthesisExpression : ExpressionNode {
    
    /***/
    public Token openToken;
    /***/
    public ExpressionNode expression;
    /***/
    public Token closeToken;

    /***/
    public this(Token openToken, ExpressionNode expression, Token closeToken) {
        this.openToken = openToken;
        this.expression = expression;
        this.closeToken = closeToken;
    }

    public override NodeType getType() {
        return NodeType.ParenthesisExpression;
    }

    public override List!Node getChildren() {
        return List!Node.yield([openToken, expression, closeToken]);
    }
}

/**holds a binary expression */
public class BinaryNode : ExpressionNode {
    
    /***/
    public ExpressionNode left;
    /***/
    public Token operator;
    /***/
    public ExpressionNode right;

    /***/
    public this(ExpressionNode left, Token operator, ExpressionNode right) {
        this.left = left;
        this.operator = operator;
        this.right = right;
    }

    public override NodeType getType() {
        return NodeType.BinaryExpression;
    }

    public override List!Node getChildren() {
        return List!Node.yield([left, operator, right]);
    }
}


/**holds a unary expression */
public class UnaryNode : ExpressionNode {
    /***/
    public Token operator;
    /***/
    public ExpressionNode operand;

    /***/
    public this(Token operator, ExpressionNode operand) {
        this.operand = operand;
        this.operator = operator;
    }

    public override NodeType getType() {
        return NodeType.UnaryExpression;
    }

    public override List!Node getChildren() {
        return List!Node.yield([operator, operand]);
    }
}

/** the abstract syntax tree thing*/
public class ASyntaxTree {

    /**the root node of the tree*/
    public ExpressionNode root;
    /**the last token of the file*/
    public Token endOfFile;

    /***/
    public this(ExpressionNode root, Token endOfFile) {
        this.root = root;
        this.endOfFile = endOfFile;
    }
}

/**a AST node*/
public abstract class Node {
    /**returns the type of this node*/
    public abstract NodeType getType();
    /**returns the children of this node*/
    public abstract List!Node getChildren();
}