import std.stdio;
import std.file: readText;

import silver.light.lexer;
import silver.light.parser;
import silver.light.message;
import silver.light.syntaxtree;

void main() {
	initMessageManager();
	//writeln("Edit source/app.d to start your project.");

	Parser parser = new Parser("test.light", readText("test.light"));

	ASyntaxTree tree = parser.parse();
	prettyPrint(tree.root);

	_MessageManager.printAll();

	writeln("Process finished with:\n",
			"	", _MessageManager.getErrorCount, " Errors\n",
			"	", _MessageManager.getWarnCount, " Warningss\n",
			"	", _MessageManager.getInfoCount, " INfos\n");
}

/***/
void prettyPrint(Node node, string indent = "", bool isLast = true, bool isFirst = true) {
	string marker = "";
	
	if (!isFirst) {
		marker = isLast ? "'--" : "|--";
	}

	write(indent, marker, node.getType());

	if (node.getType() == NodeType.Token) {
		write(" ", (cast(Token) node).str);
	}

	writeln();

	//indent ~= "   ";

	if (!isFirst)
		indent ~= isLast ? "   " : "|  ";

	for (int i = 0; i < node.getChildren().size(); i++) {
		prettyPrint(node.getChildren().get(i), indent, (i == (node.getChildren().size() - 1)), false);
	}
}