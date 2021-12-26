module silver.light.ast;

import silver.light.list;

/***/
public enum NodeType {
    Node,
}

/**a AST node*/
public abstract class Node {
    /**returns the type of this node*/
    public abstract NodeType getType();
    /**returns the children of this node*/
    public abstract List!Node getChildren();
}