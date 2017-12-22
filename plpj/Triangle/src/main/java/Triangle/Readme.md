## Visitor pattern

### Formal definition

Put an ```operation``` to be performed on the elements of an object ```structure``` in a separate class.
Separate the algorithm from the data structure. Algorithm **doesn't know** the structure so we have to be
careful and guide it through ```ast.<filed>```.

### Loose explanation

_Visitor pattern_ is very difficult to be explained but let's try.

  Imagine that you are a scout and have to pass a labyrinth. You don't know how but you have a map.
In our case this is the EBNF and to be helpful during labyrinth passage EBNF should not contain cycles,
right? The problem is more complex because we have to outline the path so the next teams could go through
and do their jobs. How to proceed?
  Your job is done by _parser_. If you look at _Parser.java_ it strictly keeps to the EBNF rules and
outlines the path as creating the **AST**. Here is some code illustration:
 
Here is what EBNF says (left side recursion is eliminated):
```
Command ::= single-Command
         | Command ; single-Command 
```
and how we proceed: 
 
```java
Command parseCommand() throws SyntaxError {
    Command commandAST
    
    commandAST = parseSingleCommand();
 
    // Command ::= single-Command (; single-Command)*
    while (currentToken.kind == Token.SEMICOLON) {
        acceptIt();
        Command c2AST = parseSingleCommand();
        commandAST = new SequentialCommand(commandAST, c2AST);
    }
    return commandAST;
}
```     

In other words we _"enter the labyrinth"_ (aka the program) and when an unknown is found we consult the map (aka EBNF)
what to do. There is a catch: during development we dealing with test programs so it is very important to cover all
the ways in tests! Wait a minute! Where is the Visitor Pattern in this picture?
 
Here is the entry point of the parser:
   
```java
public Program parseProgram() {

    Program programAST;

    // initialize, because everything starts from here
    previousTokenPosition.start = 0;
    previousTokenPosition.finish = 0;

    currentToken = lexicalAnalyser.scan();

    try {
        Command cAST = parseCommand();
        programAST = new Program(cAST, previousTokenPosition);

        if (currentToken.kind != Token.EOT) {
            syntacticError("\"%\" not expected after end of program", currentToken.spelling);
        }

    } catch (SyntaxError s) {
        return null;
    }

    return programAST;
}
```
   
Method returns the _Program_ object witch contains the traced path. This is the AST (aka. the map for others teams).
AST only outlines the path and data that we can stumble on during this passage.
 
The AST is build from objects that implement Visitor Pattern. Let's see how they look
like (nothing special by the way note that the fields are **public**):

```java
public abstract class AST {

   ....
   public abstract Object visit(Visitor v, Object o);
}

public class Program extends AST {
    public Command C;

    public Program(Command cAST, SourcePosition thePosition) {
        super(thePosition);
        this.C = cAST;
    }

    @Override
    public Object visit(Visitor v, Object o) {
        return v.visitProgram(this, o);
    }
}

```

There is a one "special" method **visit**(with two parameters). _This method is used to point
the next step during passage._ That's it!

  Having this following team has to enter using the AST as a map. Next step is_contextual analyzer._
It should not worry about directions and data, it only cary logic.

Let's look _Checker.java_(note that it implements _Visitor.java_ interface) fragment:

```java
public Object visitCallExpression(CallExpression callExpression, Object _) {

    Declaration binding = (Declaration) callExpression.I.visit(this, null);

    if (binding == null) {
        reportUndeclared(callExpression.I);
        callExpression.type = StdEnvironment.errorType;

    } else if (binding instanceof FuncDeclaration) {
        callExpression.APS.visit(this, ((FuncDeclaration) binding).FPS);
        callExpression.type = ((FuncDeclaration) binding).T;

        .......
        
    } else {
       reporter.reportError("\"%\" is not a function identifier", ....);
    }

    return callExpression.type;
}
```
To be sure that all paths are cover you should call the **visit** method to every field of the passed object
(_CallExpression_ in our case). Depending of the returned data proper logic is implemented.

NOTE: Second passed object is not obliged. In some cases when you do next step (call the *visit* method) some
information (from previous steps) may need to be passed to fulfil the logic requirements. 

   
   
   
 
