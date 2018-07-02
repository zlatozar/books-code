## Scanner

### Lexicon

At the lexical level, the program text consists of ```tokens```, ```comments```, and ```blank space```.
The tokens are ```literals```, ```identifiers```, ```operators```, various ```reserved words```, and various
```punctuation marks```. _No reserved word may be chosen as an identifier._

Comments and blank space have no significance, but may be used freely to improve
the readability of the program text. However, two consecutive tokens that would
otherwise be confused must be separated by comments and/or blank space.

Program ::= (Token | Comment | Blank)*

Token ::= Integer-Literal | Character-Literal | Identifier | Operator | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
```array``` | ```begin``` | ```const``` | ```do``` | ```else``` | ```end``` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```func``` | ```if``` | ```in``` | ```let``` | ```of``` | ```proc``` | ```record``` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```then``` | ```type``` | ```var``` | ```while``` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```.```| ```:``` | ```;``` | ```,``` | ```:=``` | ```~``` | ```(``` | ```)``` | ```[``` | ```]``` | ```{``` | ```}```<br/>
                  
Integer-Literal   ::= Digit Digit*

Character-Literal ::= 'Graphic'

Identifier ::= Letter (Letter | Digit)*

Operator ::= Op-character Op-character*

Comment ::= ```!``` Graphic* end-of-line

Blank ::= space | tab | end-of-line

Graphic ::= Letter | Digit | Op-character | space | tab | ```.``` | ```:``` | ```;``` | ```,``` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```~``` | ```(``` | ```)``` | ```[``` | ```]``` | ```{``` | ```}``` | ```_``` | ```|``` | ```!``` | ```'``` | `\` | ```"``` | ```#``` | ```$```
                      
Letter ::=  ```A``` | ```B``` | ```C``` | ```D``` | ```E``` | ```F``` | ```G``` | ```H``` | ```I``` | ```J``` | ```K``` | ```L``` | ```M``` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```N``` | ```O``` | ```P``` | ```Q``` | ```R``` | ```S``` | ```T``` | ```U``` | ```V``` | ```W``` | ```X``` | ```Y``` | ```Z``` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```a``` | ```b``` | ```c``` | ```d``` | ```e``` | ```f``` | ```g``` | ```h``` | ```i``` | ```j``` | ```k``` | ```l``` | ```m``` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```n``` | ```o``` | ```p``` | ```q``` | ```r``` | ```s``` | ```t``` | ```u``` | ```v``` | ```w``` | ```x``` | ```y``` | ```z``` <br/>
                          
Digit ::=  ```0``` | ```1``` | ```2``` | ```3``` | ```4``` | ```5``` | ```6``` | ```7``` | ```8``` | ```9``` <br/>
Op-character ::=  ```+``` | ```-``` | ```*``` | ```/``` | ```<``` | ```=``` | ```>``` | ```\``` | ```&``` | ```@``` | ```%``` | ```^``` | ```?```                       

## Parser

The following sorts of entity can be declared and used in Triangle:

- A ```value``` is a truth value, integer, character, record, or array.

- A ```variable``` is an entity that may contain a value and that can be updated. Each variable
has a well-defined lifetime.

- A ```procedure``` is an entity whose body may be executed in order to update variables. A
procedure may have constant, variable, procedural, and functional parameters.

- A ```function``` is an entity whose body may be evaluated in order to _yield a value_. A
function may have constant, variable, procedural, and functional parameters.

- A ```type``` is an entity that determines a set of values. Each value, variable, and function
has a specific type.


### Commands

A command is executed in order to _update variables_. (This includes input-output.)

#### Syntax

A single-command is a restricted form of command.
A command must be enclosed between ```begin ... end``` brackets in places where only a single-command is allowed.

Command ::= single-Command <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Command ```;``` single-Command <br/>
         
single-Command ::= <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Identifier ( rest-of-V-name ```:=``` Expression |  ```(``` Actual-Parameter-Sequence ```)```)<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```begin``` Command ```end```<br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```let``` Declaration ```in``` single-Command <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```if``` Expression ```then``` single-Command <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;```else``` single-Command <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```while``` Expression ```do``` single-Command <br/>
                
                
NOTE: The first form of single-command is empty. <br/>
NOTE2: See p. 126 how this transformation is made

#### Semantics

• The skip command ' ' has no effect when executed.

• The assignment command 'V := E' is executed as follows. The expression E is
evaluated to yield a value; then the variable identified by V is updated with this value.
(The types of V and E must be equivalent.)

• The procedure calling command 'I(APS)' is executed as follows. The actual-
parameter-sequence APS is evaluated to yield an argument list; then the procedure
bound to I is called with that argument list. (I must be bound to a procedure. APS
must be compatible with that procedure's formal-parameter-sequence.)

• The sequential command 'C1; C2' is executed as follows. C1 is executed first; then
C2 is executed.

• The bracketed command 'begin C end' is executed simply by executing C.

• The block command 'let D in C' is executed as follows. The declaration D is
elaborated; then C is executed, in the environment of the block command overlaid by
the bindings produced by D. The bindings produced by D have no effect outside the
block command.

• The if-command 'if E then C1 else C2' is executed as follows. The expression E
is evaluated; if its value is true, then C1 is executed; if its value is false, then C2 is
executed. (The type of E must be Boolean.)

• The while-command 'while E do C' is executed as follows. The expression E is
evaluated; if its value is true, then C is executed, and then the while-command is
executed again; if its value is false, then execution of the while-command is 
completed. (The type of E must be Boolean.)

### Expressions

_An expression is evaluated to yield a value_. A ```record-aggregate``` is evaluated to construct
a record value from its component values. An ```array-aggregate``` is evaluated to construct
an array value from its component values.

#### Syntax

A ```secondary-expression``` and a ```primary-expression``` are progressively more restricted
forms of expression. (An expression must be enclosed between parentheses in places
where only a primary-expression is allowed.)

Expression ::= secondary-Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```let``` Declaration ```in``` Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```if``` Expression ```then``` Expression ```else``` Expression <br/>
                          
secondary-Expression ::= primary-Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  secondary-Expression Operator primary-Expression <br/>

primary-Expression ::= Integer-Literal <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Character-Literal <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Identifier ( rest-of-V-name |  ```(``` Actual-Parameter-Sequence ```)```) <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Operator primary-Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```(``` Expression ```)``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```{``` Record-Aggregate ```}``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```[``` Array-Aggregate ```]``` <br/>
                      
Record-Aggregate   ::= Identifier ```~``` Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Identifier ```~``` Expression , Record-Aggregate <br/>

Array-Aggregate ::= Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Expression , Array-Aggregate <br/>
                 
### Value-or-variable names
                 
A ```value-or-variable-name``` identifies a value or variable.

#### Syntax

V-name ::= Identifier rest-of-V-name <br/>
rest-of-V-name ::= ( ```.``` Identifier  |  ```[``` Expression ```]``` )* <br/>
                 
#### Semantics

• The simple value-or-variable-name 'I' identifies the value or variable bound to I.
(I must be bound to a value or variable. The type of the value-or-variable-name is the
type of that value or variable.)

• The qualified value-or-variable-name ' V.I' identifies the field I of the record value or
variable identified by V. (The type of V must be a record type with a field I. The type
of the value-or-variable-name is the type of that field.)

• The indexed value-or-variable-name 'V[E]' identifies that component, of the array
value or variable identified by V, whose index is the value yielded by the expression
E. If the array has no such index, the program fails.
(The type of E must be Integer, and the type of V must be an array type. The type of the 
value-or-variable-name is the component type of that array type.)

### Declarations

A ```declaration``` is elaborated to produce bindings. _Elaborating a declaration may also have
the side effect of creating and updating variables._

#### Syntax

A single-declaration is just a restricted form of declaration.

Declaration ::= single-Declaration <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Declaration ```;``` single-Declaration <br/>
                   
single-Declaration ::= ```const``` Identifier ```~``` Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```var``` Identifier ```:``` Type-denoter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  proc Identifier ```(``` Formal-Parameter-Sequence ```)``` ```~``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; single-Command <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```func``` Identifier ```(``` Formal-Parameter-Sequence ```)``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ```:``` Type-denoter ~ Expression , <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```type``` Identifier ```~``` Type-denoter <br/>
                    
                    
### Parameters
                    
```Formal-parameters``` are used to parameterize a procedure or function with respect to
(some of) the free identifiers in its body. On calling a procedure or function, the formal-
parameters are associated with the corresponding arguments, which may be values,
variables, procedures, or functions. These arguments are yielded by ```actual-parameters```.
                    
#### Syntax
                    
Formal-Parameter-Sequence ::= <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  proper-Formal-Parameter-Sequence <br/>

proper-Formal-Parameter-Sequence ::= Formal-Parameter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  Formal-Parameter, proper-Formal-Parameter-Sequence <br/>
                                  
Formal-Parameter ::= Identifier : Type-denoter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  ```var``` Identifier ```:``` Type-denoter <br/> 
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  ```proc``` Identifier ```(``` Formal-Parameter-Sequence ```)``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |  ```func``` Identifier ```(``` Formal-Parameter-Sequence ```)``` <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ```:``` Type-denoter <br/>
                             
Actual-Parameter-Sequence ::= <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;| proper-Actual-Parameter-Sequence <br/>
                           
proper-Actual-Parameter-Sequence ::=  <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Actual-Parameter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Actual-Parameter , proper-Actual-Parameter-Sequence <br/>
                                  
Actual-Parameter ::= Expression <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```var``` V-name <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```proc``` Identifier <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```func``` Identifier <br/>

NOTE: The first form-of ```actual-parameter-sequence``` and the first form of ```formal-parameter-sequence``` are empty


### Type-denoters

A ```type-denoter``` denotes a data type. Every value, constant, variable, and function has a
specified type. A ```record-type-denoter``` denotes the structure of a record type.

Type-denoter ::= Identifier <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```array``` Integer-Literal ```of``` Type-denoter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  ```record``` Record-Type-denoter ```end``` <br/>
              
Record-Type-denoter ::= Identifier ```:``` Type-denoter <br/>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|  Identifier ```:``` Type-denoter , Record-Type-denoter <br/>