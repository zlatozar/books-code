module Types

//_____________________________________________________________________________
//                                                                     Grammar

type variable = Var of string

type expression =
    | Constant of int
    | Contents of variable
    | Minus of (expression * expression)
    | Greater of (expression * expression)
    | Times of (expression * expression)

type command =
    | Assign of (variable * expression)
    | Sequence of (command * command)
    | Conditional of (expression * command * command)
    | While of (expression * command)

//_____________________________________________________________________________
//                                                                       Lexer

type token =
    | Ident of string
    | Symbol of string
    | Number of int

type input = string list
type label = string
type errormsg = string

/// Stores information about the parser position for error messages
type position = {
    currentLine: string
    line: int
    column: int
}

//_____________________________________________________________________________
//                                                                      Parser

// Result type
type Result<'a> =
    | Success of 'a
    | Failure of label * errormsg * position

/// A Parser structure has a parsing function & label
type Parser<'a> = {
    parseFn: (input -> Result<'a * input>)
    label:  label
}

//_____________________________________________________________________________
//                                                                   Interpret

type intvalue = Intval of int

type store = Store of (variable * intvalue)
