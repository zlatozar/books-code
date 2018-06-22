Generating and compiling the micro-SQL lexer and parser (Usql/README.TXT)
-------------------------------------------------------------------------

To generate the micro-SQL lexer and parser, and load both into an
interactive F# session, do this from a command prompt:

In project:
mono ./packages/FsLexYacc/build/fslex.exe --unicode ExprLex.fsl
mono ./packages/FsLexYacc/build/fsyacc.exe --module ExprPar ExprPar.fsy

   fslex --unicode UsqlLex.fsl
   fsyacc --module UsqlPar UsqlPar.fsy
   fsharpi -r FsLexYacc.Runtime.dll Absyn.fs UsqlPar.fs UsqlLex.fs Parse.fs

Now you can exercise the lexer and parser from within the F# session:

   open Parse;;
   fromString "SELECT Employee.name, salary * (1 - taxrate) FROM Employee";;

   #q;;
