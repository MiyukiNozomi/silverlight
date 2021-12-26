module silver.light.message;

import std.stdio;

import silver.light.list;
import silver.light.lexer;

/**type of message*/
public enum MessageType {
    Info,
    Warning,
    Error,
}

/**message itself.*/
public class Message {
    /**sort of message identification code*/
    public string code;
    /**the file that the message originated from*/
    public string filename;
    /**the message of this message.*/
    public string message;
    /**the type of this message.*/
    public MessageType type;
    /**the location of this message.*/
    public Transformation location;

    /***/
    public this(MessageType type,string code, string message, string filename, Transformation t) {
        this.code = code;
        this.filename = filename;
        this.message = message;
        this.location = t;
        this.type = type;
    }

    /**writes this message.*/
    public void writeMessage() {
        writeln(type, " SL", code, " at ", filename, " in (", location.line, ":", location.column,") ", message);
    }
}

/**Global Message Manager*/
public MessageManager _MessageManager;

/**just initializes the global message manager,
(i just have this function so that i don't need to make a static constructor)*/
public static initMessageManager() {
    _MessageManager = new MessageManager();
}

/***/
public class MessageManager {
    private List!Message messages;
    private int errorCount, warnCount, infoCount;
    
    /***/
    public this() {
        this.messages = new List!Message();
        this.errorCount = 0;
        this.warnCount = 0;
        this.infoCount = 0;
    }
    /**creates a info type of message*/
    public void addInfo(string code, string message, string file, Token cause) {
        addInfo(code, message, file, cause.loc);
    }
    
    /**creates a warning type of message*/
    public void addWarning(string code, string message, string file, Token cause) {
        addWarning(code, message, file, cause.loc);
    }
    
    /**creates a error type of message*/
    public void addError(string code, string message, string file, Token cause) {
        addError(code, message, file, cause.loc);
    }

    /**creates a info type of message*/
    public void addInfo(string code, string message, string file, Transformation cause) {
        messages.add(new Message(MessageType.Info, code, message, file, cause));
    }

    /**creates a warning type of message*/
    public void addWarning(string code, string message, string file, Transformation cause) {
        messages.add(new Message(MessageType.Warning, code, message, file, cause));
    }

    /**creates a error type of message*/
    public void addError(string code, string message, string file, Transformation cause) {
        messages.add(new Message(MessageType.Error, code, message, file, cause));
    }

    /**adds a message that has been already created*/
    public void addMessage(Message message) {
        if (message.type == MessageType.Info) {
            infoCount++;
        } else if (message.type == MessageType.Warning) {
            warnCount++;
        } else {
            errorCount++;
        }

        messages.add(message);
    }

    /***/
    public int getErrorCount() {
        return errorCount;
    }
    /***/
    public int getWarnCount() {
        return warnCount;
    }
    /***/
    public int getInfoCount() {
        return infoCount;
    }
    /**prints every message loaded*/
    public void printAll() {
        for (int i = 0; i < messages.size(); i++) {
            Message m = messages.get(i);
            m.writeMessage();
        }
    }

    /**resets the global message manager*/
    public void reset() {
        this.errorCount = 0;
        this.warnCount = 0;
        this.infoCount = 0;

        this.messages.clear();
    }
}

/**an enum storing all code types of all messages.*/
public enum Code {
    InvalidToken = "40001",
    ExpectedToken = "40002"
}