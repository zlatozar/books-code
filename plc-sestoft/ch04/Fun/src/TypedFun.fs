module TypedFun

(* Environment operations *)

type 'v Env = (string * 'v) list

(* A type is int, bool or function *)

type Type =
  | TypeInt                                (* int                          *)
  | TypeBool                                (* bool                         *)
  | TypeFunc of Type * Type                 (* (argument type, result type) *)

(* New abstract syntax with explicit types. Some kind of meta-language. *)

type TypeExpr =
  | CstI of int
  | CstB of bool
  | Var of string
  | Let of string * TypeExpr * TypeExpr
  | Prim of string * TypeExpr * TypeExpr
  | If of TypeExpr * TypeExpr * TypeExpr
  | Letfun of string * string * Type * TypeExpr * Type * TypeExpr
          // (f,       x,       xType, fBody,    rType,  letBody)
  | Call of TypeExpr * TypeExpr

(* A runtime value is an integer or a function closure *)

type RValue =
  | Int of int
  | Closure of string * string * TypeExpr * RValue Env      // (f, x, fBody, fDeclEnv)

let rec lookup env x =
    match env with
    | []        -> failwith (x + " not found")
    | (y, v)::r -> if x=y then v else lookup r x

let rec eval (e: TypeExpr) (env: RValue Env) :int =
    match e with
    | CstI i -> i
    | CstB b -> if b then 1 else 0
    | Var x  ->
        match lookup env x with
        | Int i -> i
        | _     -> failwith "eval Var"

    | Prim(ope, e1, e2) ->
        let i1 = eval e1 env
        let i2 = eval e2 env
        match ope with
        | "*" -> i1 * i2
        | "+" -> i1 + i2
        | "-" -> i1 - i2
        | "=" -> if i1 = i2 then 1 else 0
        | "<" -> if i1 < i2 then 1 else 0
        | _   -> failwith "unknown primitive"

    | Let(x, eRhs, letBody) ->
        let xVal = Int(eval eRhs env)
        let bodyEnv = (x, xVal) :: env
        eval letBody bodyEnv

    | If(e1, e2, e3) ->
        let b = eval e1 env
        if b<>0 then eval e2 env else eval e3 env

    | Letfun(f, x, _, fBody, _, letBody) ->
        let bodyEnv = (f, Closure(f, x, fBody, env)) :: env
        eval letBody bodyEnv

    | Call(Var f, eArg) ->
        let fClosure = lookup env f
        match fClosure with
        | Closure (f, x, fBody, fDeclEnv) ->
            let xVal = Int(eval eArg env)
            let fBodyEnv = (x, xVal) :: (f, fClosure) :: fDeclEnv
            eval fBody fBodyEnv
        | _ -> failwith "eval Call: not a function"

    | Call _ -> failwith "illegal function in Call"

(* Type checking for the first-order functional language: *)

let rec typeInf (e: TypeExpr) (env: Type Env) :Type =
    match e with
    | CstI i -> TypeInt
    | CstB b -> TypeBool
    | Var x  -> lookup env x

    | Prim(ope, e1, e2) ->
        let t1 = typeInf e1 env
        let t2 = typeInf e2 env
        match (ope, t1, t2) with
        | ("*", TypeInt, TypeInt) -> TypeInt
        | ("+", TypeInt, TypeInt) -> TypeInt
        | ("-", TypeInt, TypeInt) -> TypeInt
        | ("=", TypeInt, TypeInt) -> TypeBool
        | ("<", TypeInt, TypeInt) -> TypeBool
        | ("&", TypeBool, TypeBool) -> TypeBool
        | _   -> failwith "unknown op, or type error"

    | Let(x, eRhs, letBody) ->
        let xType = typeInf eRhs env
        let letBodyEnv = (x, xType) :: env
        typeInf letBody letBodyEnv

    | If(e1, e2, e3) ->
        match typeInf e1 env with
        | TypeBool -> let t2 = typeInf e2 env
                      let t3 = typeInf e3 env
                      if t2 = t3
                        then t2
                        else failwith "If: branch types differ"
        | _    -> failwith "If: condition not boolean"

    | Letfun(f, x, xType, fBody, rType, letBody) ->
        let fType = TypeFunc(xType, rType)
        let fBodyEnv = (x, xType) :: (f, fType) :: env
        let letBodyEnv = (f, fType) :: env
        if typeInf fBody fBodyEnv = rType
          then typeInf letBody letBodyEnv
          else failwith ("Letfun: return type in " + f)

    | Call(Var f, eArg) ->
        match lookup env f with
        | TypeFunc(xTyp, rTyp) ->
            if typeInf eArg env = xTyp
              then rTyp
              else failwith "Call: wrong argument type"
        | _ -> failwith "Call: unknown function"

    | Call(_, eArg) -> failwith "Call: illegal function in call"

let typeCheck e = typeInf e []

(* Examples of successful type checking *)

let ex1 = Letfun("f1", "x", TypeInt, Prim("+", Var "x", CstI 1), TypeInt,
                 Call(Var "f1", CstI 12))

(* Factorial *)

let ex2 = Letfun("fac", "x", TypeInt,
                 If(Prim("=", Var "x", CstI 0),
                    CstI 1,
                    Prim("*", Var "x",
                              Call(Var "fac",
                                   Prim("-", Var "x", CstI 1)))),
                 TypeInt,
                 Let("n", CstI 7, Call(Var "fac", Var "n")))

let fac10 = eval ex2 []

let ex3 = Let("b", Prim("=", CstI 1, CstI 2),
              If(Var "b", CstI 3, CstI 4))

let ex4 = Let("b", Prim("=", CstI 1, CstI 2),
              If(Var "b", Var "b", CstB false))

let ex5 = If(Prim("=", CstI 11, CstI 12), CstI 111, CstI 666)

let ex6 = Letfun("inf", "x", TypeInt, Call(Var "inf", Var "x"), TypeInt,
                 Call(Var "inf", CstI 0))

let types = List.map typeCheck [ex1; ex2; ex3; ex4; ex5; ex6]

(* Examples of type errors; should throw exception when run: *)

let exErr1 = Let("b", Prim("=", CstI 1, CstI 2),
                 If(Var "b", Var "b", CstI 6))

let exErr2 = Letfun("f", "x", TypeBool, If(Var "x", CstI 11, CstI 22), TypeInt,
                    Call(Var "f", CstI 0))

let exErr3 = Letfun("f", "x", TypeBool, Call(Var "f", CstI 22), TypeInt,
                    Call(Var "f", CstB true))

let exErr4 = Letfun("f", "x", TypeBool, If(Var "x", CstI 11, CstI 22), TypeBool,
                    Call(Var "f", CstB true))
