## CHECKER

1. Checks whether the source program, represented by its AST, satisfies the
   language's scope rules and type rules.

2. Also decorates the AST as follows:
   (a) Each applied occurrence of an identifier or operator is linked to
       the corresponding declaration of that identifier or operator.
   (b) Each expression and value-or-variable-name is decorated by its type.
   (c) Each type identifier is replaced by the type it denotes.
 
3. Standard types are represented by small ASTs.

4. Reports that the identifier or operator used at a leaf of the AST has not been declared.


### Commands

- Check that the given command is well formed
- Always returns null and does not use the given subtree(phrase)


### Expression

- Checks that the expression is well formed
- Decorates the expression node with its inferred type
- Return that type


### Declaration

- Always returns null and does not use the given subtree(phrase)
- Enters all declared identifiers into the identification table


### Value or variable

- Checks that the value-or-variable-name is well-formed
- Decorates it with its inferred type
- Add indication of whether it is a variable or not
- The method's result is the inferred type


### Formal parameters

- Always returns null and does not use the given subtree(phrase)
- Enters all declared identifiers into the identification table


### Type denoters

- Return denoters (sub-tree)


#### Array aggregates

- Return type
- Decorate 'elemCount'


#### Literals, Identifiers and Operators

- Return bindings


#### Standard environment

- Creates 'small' ASTs to represent the standard types.
- Creates small ASTs to represent _"declarations"_ of standard types, constants, procedures, functions, and operators.
- Enters these _"declarations"_ in the identification table.
- This _"declaration"_ summarises the operator's type info.