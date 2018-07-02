## Lexer

At the lexical level, the program text consists of `tokens`, `comments`, and
`blank space`.  The tokens are `literals`, `identifiers`/`names`, `operators`,
various `reserved words`, and various `punctuation marks`. _No reserved word may
be chosen as an identifier._

```
Program ::= (Token | Comment | Blank)*
```

\<Token\> **::=** \<Integer-Literal\> | \<String-Literal\> | \<Identifier\> | \<Operator\> | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;`int` | `char` | `if` | `else` | `while` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;`true` | `false` | `print` | `println` | `void` | `null` | `return` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;`=` | `&` | `(` | `)` | `{` | `}` | `[` |<br/>
&nbsp;&nbsp;&nbsp;&nbsp;`]` | `;` | `,`

\<Integer-Literal\> **::=** \<Digit\> \<Digit\>*

\<String-Literal\>  := `"`\<GraphicWithEscape\>*`"`

\<Identifier\>      **::=** \<Letter\> (\<Letter\> | \<Digit\>)*

\<Operator\>        **::=** \<Op-character\> \<Op-character\>*

\<Comment\>         **::=** `//` \<Graphic\>* EOF | `/*` \<Graphic\>* `*/`

\<Blank\>           **::=** space | tab | EOF

\<Graphic\>      **::=** \<Letter\> | \<Digit\> | \<Op-character\> | space | tab | \<ASCII
visible character\>

\<GraphicWithEscape\> **::=** \<Graphic\> | `\a` | `\b` | `\t` | `\n` | `\v` | `\f` | `\r` |`\"` | `\\` | `\ddd` | `\uxxxx`

\<Letter\>       **::=**  `A` | `B` | `C` | `D` | `E` | `F` | `G` | `H` | `I` | `J` | `K` | `L` | `M` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;`N` | `O` | `P` | `Q` | `R` | `S` | `T` | `U` | `V` | `W` | `X` | `Y` | `Z` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;`a` | `b` | `c` | `d` | `e` | `f` | `g` | `h` | `i` | `j` | `k` | `l` | `m` | <br/>
&nbsp;&nbsp;&nbsp;&nbsp;`n` | `o` | `p` | `q` | `r` | `s` | `t` | `u` | `v` | `w` | `x` | `y` | `z` <br/>

\<Digit\>        **::=**  `0` | `1` | `2` | `3` | `4` | `5` | `6` | `7` | `8` | `9` <br/>
\<Op-character\> **::=**  `+` | `-` | `*` | `/` | `%` | `!` | `=`| `<`  | `>`

## Parser

### EBNF

#### Program

\<Main\>  **::=** \<Top-Declaration-Sequence\> **EOF**<br/>

#### Top Declaration

\<Top-Declaration-Sequence\> **::=** \<empty\> | \<Top-Declaration\> \<Top-Declaration-Sequence\><br/>

\<Top-Declaration\>          **::=** \<Var-Declaration\> `;` \<Function-Declaration\><br/>

#### Variable or Parameter Declaration

\<Var-Declaration\> **::=** \<Type\> \<Var-Definition\><br/>

\<Var-Definition\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| NAME<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `*` \<Var-Definition\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `(` \<Var-Definition\> `)`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Var-Definition\> `[` `]`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Var-Definition\> `[` CSTINT `]`<br/>

#### Function Declaration

\<Function-Declaration\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `void` NAME `(` \<Formal-Param-Sequence\> `)` \<Block\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Type\> NAME `(` \<Formal-Param-Sequence\> `)` \<Block\><br/>

\<Formal-Param-Sequence\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<empty\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Formal-Param-List\><br/>

\<Formal-Param-List\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Var-Declaration\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Var-Declaration\> `,` \<Formal-Param-List\><br/>

#### Block (statement or variable declaration)

\<Block\> **::=** `{` \<Code\> `}`    // include local variable declaration<br/>

\<Code\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<empty\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Statement\> \<Code\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Var-Declaration\> `;` \<Code\><br/>

#### Statement

\<Statement\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Statement-Matched\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Statement-UnMatched\>      // with unmatched trailing `if-else`<br/>

\<Statement-Matched\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Expression\> `;`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **return** `;`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **return** \<Expression\> `;`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Block\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **if** `(` \<Expression\> `)` \<Statement-Matched\> **else** \<Statement-Matched\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **while** `(` \<Expression\> `)` \<Statement-Matched<br/>

\<Statement-Unmatched\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **if** `(` \<Expression\> `)` \<Statement-Matched\> \<else\> \<Statement-Unmatched\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **if** `(` \<Expression\> `)` \<Statement\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **while** `(` \<Expression\> `)` \<Statement-Unmatched\><br/>

#### Expressions

\<Expression\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Access\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Expr\>

\<Expr\> **::=**                                // expression not access<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Atomic-Expr\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Access\> = \<Expression\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| NAME ( \<Expression-Sequence\> )  // function call<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `!` \<Expression\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **print** \<Expression\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| **println**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Expression\> OP \<Expression\><br/>

\<Atomic-Expr\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Constant\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `(` \<Expr\> `)`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `&` \<Access\><br/>

\<Access\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| NAME                               // variable<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `(` \<Access\> `)`<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `*` \<Access\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `*` \<Atomic-Expr\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Access\> `[` \<Expression\> `]`  // array element access<br/>

\<Expression-Sequence\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<empty\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;|\<Expression-List\><br/>

\<Expression-List\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Expression\><br/>
&nbsp;&nbsp;&nbsp;&nbsp;| \<Expression\> , \<Expression-List\><br/>

\<Constant\> **::=**<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| CSTINT<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `-` CSTINT<br/>
&nbsp;&nbsp;&nbsp;&nbsp;| `null`<br/>

\<Type\> **::=** int | char<br/>
