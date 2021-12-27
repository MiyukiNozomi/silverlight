module silver.light.intermediate;

import silver.light.list;

public enum IntermediateKind {
    UnaryExpression,
    BinaryExpression,
    LiteralExpression,
}

public enum IntermediateBinaryOperatorType {
    Addition,
    Subtraction,
    Multiplication,
    Division,
}

public enum IntermediateUnaryOperatorType {
    Identity,
    Negation,
}

public abstract IntermediateNode {
    public abstract IntermediateKind getKind();
}

public abstract class IntermediateExpression : IntermediateNode {
    public abstract Type getType();
}

public class IntermediateLiteral : IntermediateExpression {

    public auto value;

    public this(auto value) {
        this.value = value;
    }

    public override IntermediateKind getKind() {
        return IntermediateKind.LiteralExpression;
    }

    public override Type getType() {
        return value.getType();
    }
}

public class IntermediateUnary : IntermediateExpression {
    
    private IntermediateUnaryOperatorType operatorType;
    private IntermediateExpression operand;

    public this(IntermediateUnaryOperatorType operatorType, IntermediateExpression operand) {
        this.operatorType = operatorType;
        this.operand = operand;
    }

    public override IntermediateKind getKind() {
        return IntermediateKind.UnaryExpression;
    }

    public override Type getType() {
        return this.operand.getType();
    }
}

public class IntermediateBinary : IntermediateExpression {
    
    private IntermediateExpression left;
    private IntermediateBinaryOperatorType operatorType;
    private IntermediateExpression right;

    public this(IntermediateExpression left, IntermediateBinaryOperatorType operatorType, IntermediateExpression right) {
        this.left = left;
        this.operatorType = operatorType;
        this.right = right;
    }

    public override IntermediateKind getKind() {
        return IntermediateKind.BinaryExpression;
    }

    public override Type getType() {
        return this.left.getType();
    }
}

import std.conv;

import silver.light.syntaxtree;

public class Binder {
    public IntermediateExpression bind(ExpressionNode syntax) {
        switch(syntax.getType()) {
            case NodeType.LiteralExpression:
                return bindLiteral(cast(LiteralNode) syntax);
            case NodeType.UnaryExpression:
                return bindUnary(cast(UnaryNode) syntax);
            case NodeType.BinaryExpression:
                return bindBinary(cast(BinaryNode) syntax);
            default:
                throw new Error("Unsupported NodeType: " ˜ to!string(cast(OriginalType!NodeType) syntax.getType()));
        }
    }

    private IntermediateExpression bindLiteral(LiteralNode node) {
        auto value = node.literalToken.str is null ? 0 : node.literalToken.str.parse!int();
        return new IntermediateLiteral(value);
    }

    private IntermediateExpression bindUnary(UnaryNode node) {
        IntermediateExpression operand = bindExpression(node.operand);
        IntermediateUnaryOperatorType operator = bindUnaryOperatorType(node.operator.type);
        return IntermediateUnary(operator, operand);
    }

    private IntermediateExpression bindBinary(BinaryNode node) {
        IntermediateExpression left = bindExpression(node.left);
        IntermediateBinaryOperatorType operator = bindBinaryOperatorType(node.operator.type);
        IntermediateExpression right = bindExpression(node.right);
        return new IntermediateBinary(left, operator, right);
    }

    private IntermediateUnaryOperatorType bindUnaryOperatorType(TokenType type) {
        switch(type) {
            
        }
    }  

    private IntermediateBinaryOperatorType bindBinaryOperatorType(TokenType) {

    }
}