## Chapter 4 p. 73

The main function of **syntactic analysis** is to parse the source program in order to discover its phrase structure.

### Grammar transformations

- Left factorization

Suppose that we have alternatives of the form: ```XY | XZ``` where X, Y, and Z are arbitrary (extended) REs.
We can replace these alternatives by the equivalent extended RE: ```X(Y|Z)```

```
single-Command ::= V-name := Expression
                | if Expression then single-Command
                | if Expression then single-Command
                     else single-Command
```
                     
This production rule can be left-factorized as follows:

```
single-Command ::= V-name : = Expression
                | if Expression then single-Command
                     (<empty> | else single-Command)
```                     

- Elimination of left recursion

Suppose that we have a production rule of the form: ```N ::= X | NY``` where ```N``` is a non-terminal symbol,
and X and Y are arbitrary extended REs. This production rule is **left-recursive**. We can replace it by the
equivalent _EBNF_ production rule: ```N ::= X(Y)*```

Example:

```
Identifier ::= Letter
            | Identifier Letter
            | Identifier Digit
```            

after _left factorization_

```
Identifier ::= Letter
            | Identifier (Letter | Digit)
```            

then remove _left recursion_

```
Identifier ::= Letter (Letter | Digit)*            
```

- Substitution of nonterminal symbols (a matter of convenience)

Given an _EBNF_ production rule ```N ::= X```, we may substitute X for any occurrence of N on the right-hand side
of another production rule. If we substitute ```X``` for every occurrence of ```N```, then we may eliminate the nonterminal
N and the production rule N ::= X altogether. In functional languages it is called: ```referential transparency```.

NOTE: This is possible, however, only if N ::= X is nonrecursive and is the only production rule for N.

### Parsing

Given an input string of terminal symbols, our task is to determine whether the input string is a sentence of the grammar,
and if so to discover its phrase structure.

With respect to a particular context-free grammar ```G```:

- Recognition of an input string is deciding whether or not the input string is a sentence of ```G```.
- Parsing of an input string is recognition of the input string plus determination of its **phrase structure**.
  The phrase structure can be represented by a syntax tree, or otherwise.
 
We assume that ```G``` is **unambiguous**, i.e., that every sentence of ```G``` has exactly one syntax tree.

- Bottom-up: **LR**
- Top-down: **Recursive descent**

### Recursive-Descent Parser
    
If the production rules are mutually recursive, then the parsing methods will also be mutually recursive.
For this reason (and because the parsing strategy is top-down), the algorithm is called **recursive descent**.

A recursive-descent parser can be _systematically_ developed:

1. Express the grammar in _EBNF_, with a single production rule for each nonterminal
   symbol, and perform any necessary grammar transformations. In particular, **always**
   eliminate _left recursion_, and _left-factorize_ wherever possible.
  
2. Transcribe each EBNF production rule ```N::=X``` to a parsing method parsed, whose body is determined by ```X```.

3. Make the parser consist of:
   • a private variable ```currentToken```
   • private parsing methods developed in **step 2**
   • private auxiliary methods ```accept``` and ```acceptIt```, both of which call the scanner
   • public ```parse``` method that calls ```parseS``` (where ```S``` is the start symbol of the grammar),
     having first called the scanner to store the first input token in ```currentToken```.
     
ATTENTION: Recursive-descent parsing is suitable only for ```LL(1) grammars```.