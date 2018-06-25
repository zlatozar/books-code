(* Lexing and parsing of micro-SQL SELECT statements using 'fslex' and 'fsyacc' *)

module Parse

open System
open System.IO
open Microsoft.FSharp.Text.Lexing

open Absyn

(* Plain parsing from a string, with poor error reporting *)

let fromString (str: string) :Stmt =
    let lexbuf = LexBuffer<char>.FromString(str)
    try
      UsqlPar.Main UsqlLex.Token lexbuf

    with
      | exn -> let pos = lexbuf.EndPos
               failwithf "%s near line %d, column %d\n"
                  (exn.Message) (pos.Line + 1) pos.Column

(* Parsing from a file *)

let fromFile (filename: string) =
    use reader = new StreamReader(filename)
    let lexbuf = LexBuffer<char>.FromTextReader reader
    try
      UsqlPar.Main UsqlLex.Token lexbuf

    with
      | exn -> let pos = lexbuf.EndPos
               failwithf "%s in file %s near line %d, column %d\n"
                  (exn.Message) filename (pos.Line + 1) pos.Column

(* Examples *)

// fsharpi -r FsLexYacc.Runtime.dll Absyn.fs UsqlPar.fs UsqlLex.fs Parse.fs

// open Parse;;
// fromString "SELECT department, AVG(salary * (1 - taxrate)) FROM Employee";;
// fromString "SELECT name, salary * (1 - taxrate) FROM Employee";;
