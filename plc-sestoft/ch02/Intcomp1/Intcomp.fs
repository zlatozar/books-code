(* 1. Evaluation, checking, and compilation of object language expressions *)
(* 2. Stack machines for expression evaluation                             *)

// p. 13
namespace Chapter02

module Intcomp1 =

    (* Object language expressions with variable bindings and nested scope *)

    type Expr =
        | CstI of int
        | Var of string
        | Let of string * Expr * Expr
        | Prim of string * Expr * Expr

    // _________________________________________________________________________
    //                     2.3.1 Expressions with Let-Bindings and Static Scope

    let rec lookup env x =
        match env with
        | []        -> failwith (x + " not found")
        | (y, v)::r -> if x=y then v else lookup r x

    let rec eval e (env : (string * int) list) : int =
        match e with
        | CstI i            -> i
        | Var x             -> lookup env x
        | Let(x, erhs, ebody) ->
            let xval = eval erhs env
            let env1 = (x, xval) :: env
            eval ebody env1
        | Prim("+", e1, e2) -> eval e1 env + eval e2 env
        | Prim("*", e1, e2) -> eval e1 env * eval e2 env
        | Prim("-", e1, e2) -> eval e1 env - eval e2 env
        | Prim _            -> failwith "unknown primitive"

    let run e = eval e []

    // _________________________________________________________________________
    //                                                 2.3.2 Closed Expressions

    // Checking whether an expression is closed. The 'vs' is a list of the bound variables
    let rec closedin (e: Expr) (vs: string list) :bool =
        match e with
        | CstI i              -> true
        | Var x               -> List.exists (fun y -> x=y) vs
        | Let(x, erhs, ebody) ->
            let vs1 = x :: vs
            closedin erhs vs && closedin ebody vs1
        | Prim(ope, e1, e2)   -> closedin e1 vs && closedin e2 vs

    (* Definition: An expression is closed if it is closed in the empty environment *)

    // Expression returns value that do not depend from the environment
    let closed1 e = closedin e []

    // _________________________________________________________________________
    //                                          2.3.3 The Set of Free Variables

    (* Operations on sets, represented as lists. Simple but inefficient;
       one could use binary trees, hashtables or splaytrees for efficiency.  *)

    // In book:
    // let mem x vs = List.exists (fun y -> x=y) vs

    let rec mem x vs =
        match vs with
        | []      -> false
        | v :: vr -> x=v || mem x vr

    // The set of all elements in 'xs' or 'ys', without duplicates
    let rec union (xs, ys) =
        match xs with
        | []    -> ys
        | x::xr -> if mem x ys then union(xr, ys)
                   else x :: union(xr, ys)

    // The set of all elements in 'xs' but not in 'ys'
    let rec minus (xs, ys) =
        match xs with
        | []    -> []
        | x::xr -> if mem x ys then minus(xr, ys)
                   else x :: minus (xr, ys)

    // Find all variables that occur free in expression 'e'
    let rec freevars e :string list =
        match e with
        | CstI i              -> []
        | Var x               -> [x]
        | Let(x, erhs, ebody) ->
            union (freevars erhs, minus (freevars ebody, [x]))
        | Prim(ope, e1, e2)   -> union (freevars e1, freevars e2)

    // Alternative definition of closed
    let closed2 e = List.isEmpty(freevars e)

    // _________________________________________________________________________
    //                   2.3.4 Substitution: Replacing Variables by Expressions

    // REMEMBER: Substitution should only replace free variables!

    // To implement a substitution function in F#, we need a version of lookup that
    // maps each variable present in the environment to the associated expression, and maps
    // absent variables to themselves.

    // This version of lookup returns a Var(x) expression if there is no
    // pair (x, e) in the list env - instead of failing with exception
    let rec lookOrSelf env x =
        match env with
        | []        -> Var x
        | (y, e)::r -> if x=y then e else lookOrSelf r x

    // Remove (x, _) from 'env'
    let rec remove env x =
        match env with
        | []        -> []
        | (y, e)::r -> if x=y then r else (y, e) :: remove r x

    // Naive(wrong) substitution, may capture free variables
    let rec nsubst (e: Expr) (env: (string * Expr) list) :Expr =
        match e with
        | CstI i -> e
        | Var x  -> lookOrSelf env x
        | Let(x, erhs, ebody) ->
            let newenv = remove env x
            Let(x, nsubst erhs env, nsubst ebody newenv)
        | Prim(ope, e1, e2)   -> Prim(ope, nsubst e1 env, nsubst e2 env)

    let newVar :string -> string =
        let n = ref 0
        let varMaker x = (n := 1 + !n; x + string (!n))
        varMaker

    (* Correct, capture-avoiding substitution *)

    let rec subst (e: Expr) (env: (string * Expr) list) :Expr =
        match e with
        | CstI i -> e
        | Var x  -> lookOrSelf env x
        | Let(x, erhs, ebody) ->   // We systematically rename bound vars to avoid capture of free vars
            let newx = newVar x
            let newenv = (x, Var newx) :: remove env x
            Let(newx, subst erhs env, subst ebody newenv)
        | Prim(ope, e1, e2)   -> Prim(ope, subst e1 env, subst e2 env)

    // _________________________________________________________________________
    // 5. Compilation to target expressions with numerical indexes instead of symbolic variable names

    type Texpr =                            (* target expressions *)
        | TCstI of int
        | TVar of int                       (* index into runtime environment *)
        | TLet of Texpr * Texpr             (* 'erhs' and 'ebody'             *)
        | TPrim of string * Texpr * Texpr

    // Map variable name to variable index at compile-time
    let rec getindex vs x =
        match vs with
        | []    -> failwith "Variable not found"
        | y::yr -> if x=y then 0 else 1 + getindex yr x

    // Compiling from Expr to Texpr. The compile-time environment cenv is a list of variable
    // names; the position of a variable in the list indicates its binding depth and hence the
    // position in the runtime environment. The integer giving the position is the same as a
    // deBruijn index in the lambda calculus: the number of binders between this occurrence of a
    // variable, and its binding.

    // Compiling from Expr to Texpr
    let rec tcomp (e: Expr) (cenv: string list) :Texpr =
        match e with
        | CstI i -> TCstI i
        | Var x  -> TVar (getindex cenv x)
        | Let(x, erhs, ebody) ->
            let cenv1 = x :: cenv
            TLet(tcomp erhs cenv, tcomp ebody cenv1)
        | Prim(ope, e1, e2) -> TPrim(ope, tcomp e1 cenv, tcomp e2 cenv)

    // Evaluation of target expressions with variable indexes.
    // The run-time environment 'renv' is a list of variable values (ints)
    let rec teval (e: Texpr) (renv: int list) :int =
        match e with
        | TCstI i -> i
        | TVar n  -> List.item n renv
        | TLet(erhs, ebody) ->
            let xval = teval erhs renv
            let renv1 = xval :: renv
            teval ebody renv1
        | TPrim("+", e1, e2) -> teval e1 renv + teval e2 renv
        | TPrim("*", e1, e2) -> teval e1 renv * teval e2 renv
        | TPrim("-", e1, e2) -> teval e1 renv - teval e2 renv
        | TPrim _            -> failwith "unknown primitive"

    (* Correctness: eval e []  equals  teval (tcomp e []) [] *)

    // _________________________________________________________________________
    //                                                        6. Stack machines

    // Stack machine instructions.
    // An expressions in postfix (reverse Polish) form is a list of stack machine instructions
    type Rinstr =
        | RCstI of int
        | RAdd
        | RSub
        | RMul
        | RDup
        | RSwap

    // Implementation:
    // Match current instruction (<current instr>::<rest of instructions>) and the stack.
    // Needed parameters are i1 or i1, i2 so they are represented i2::i1::<rest of the stack>

    // A simple stack machine for evaluation of variable-free expressions in postfix form
    let rec reval (inss: Rinstr list) (stack: int list) :int =
        match (inss, stack) with
        | ([], v :: _) -> v
        | ([], [])     -> failwith "reval: no result on stack!"
        | (RCstI i :: insr,             stk)  -> reval insr (i::stk)
        | (RAdd    :: insr, i2 :: i1 :: stkr) -> reval insr ((i1 + i2)::stkr)
        | (RSub    :: insr, i2 :: i1 :: stkr) -> reval insr ((i1 - i2)::stkr)
        | (RMul    :: insr, i2 :: i1 :: stkr) -> reval insr ((i1 * i2)::stkr)
        | (RDup    :: insr,       i1 :: stkr) -> reval insr (i1 :: i1 :: stkr)
        | (RSwap   :: insr, i2 :: i1 :: stkr) -> reval insr (i1 :: i2 :: stkr)
        | _            -> failwith "reval: too few operands on stack"

    // Compilation of a variable-free expression to a Rinstr list
    let rec rcomp (e: Expr) :Rinstr list =
        match e with
        | CstI i            -> [RCstI i]
        | Var _             -> failwith "rcomp cannot compile Var"
        | Let _             -> failwith "rcomp cannot compile Let"
        | Prim("+", e1, e2) -> rcomp e1 @ rcomp e2 @ [RAdd]
        | Prim("*", e1, e2) -> rcomp e1 @ rcomp e2 @ [RMul]
        | Prim("-", e1, e2) -> rcomp e1 @ rcomp e2 @ [RSub]
        | Prim _            -> failwith "unknown primitive"

    // _________________________________________________________________________
    //  6. Storing intermediate results and variable bindings in the same stack

    type Sinstr =
        | SCstI of int   (* push integer           *)
        | SVar of int    (* push variable from env *)   // new
        | SAdd           (* pop args, push sum     *)
        | SSub           (* pop args, push diff    *)
        | SMul           (* pop args, push product *)
        | SPop           (* pop value/unbind var from the left *)   // new
        | SSwap          (* exchange top and next  *)
        | SSt            (* shows the stack content*)   // need for debug

    // A compile-time variable environment representing the *state* of the run-time stack
    type Stackvalue =
        | Value             (* A computed value used to calculate the offset *)
        | Bound of string   (* A bound variable *)

    // Compilation to a list of instructions for a unified-stack machine
    // Note that this time we pass the environment
    let rec scomp (e: Expr) (cenv: Stackvalue list) :Sinstr list =
        match e with
        | CstI i -> [SCstI i]
        | Var x  -> [SVar (getindex cenv (Bound x))]  // new - map variable name to variable index at compile-time
        | Let(x, erhs, ebody) ->                      // new
            scomp erhs cenv @ scomp ebody (Bound x :: cenv) @ [SSwap; SPop] // [SSwap; SPop] to remove Let!!
        | Prim("+", e1, e2) ->
            scomp e1 cenv @ scomp e2 (Value :: cenv) @ [SAdd]  // adding Value on the second parameter we guarantee the correct offset
        | Prim("-", e1, e2) ->
            scomp e1 cenv @ scomp e2 (Value :: cenv) @ [SSub]
        | Prim("*", e1, e2) ->
            scomp e1 cenv @ scomp e2 (Value :: cenv) @ [SMul]
        | Prim _ -> failwith "scomp: unknown operator"

    let rec seval (inss: Sinstr list) (stack : int list) =
        match (inss, stack) with
        | ([], v :: _) -> v
        | ([], [])     -> failwith "seval: no result on stack"
        | (SCstI i :: insr,          stk) -> seval insr (i :: stk)
        | (SVar i  :: insr,          stk) -> seval insr ((List.item i stk) :: stk)  // new
        | (SAdd    :: insr, i2::i1::stkr) -> seval insr (i1+i2 :: stkr)
        | (SSub    :: insr, i2::i1::stkr) -> seval insr (i1-i2 :: stkr)
        | (SMul    :: insr, i2::i1::stkr) -> seval insr (i1*i2 :: stkr)
        | (SPop    :: insr,    _ :: stkr) -> seval insr stkr                        // new
        | (SSwap   :: insr, i2::i1::stkr) -> seval insr (i1::i2::stkr)
        | (SSt     :: insr, stkr)         -> printf "S-> %A\n" stkr; seval insr stkr
        | _            -> failwith "seval: too few operands on stack"

    // Correctness: eval e [] [] equals seval (scomp e []) [] for an expression with no free
    // variables.

    // Output the integers in list 'inss' to the text file called 'fname'
    let intsToFile (inss: int list) (fname: string) =
        let text = String.concat " " (List.map string inss)
        System.IO.File.WriteAllText(fname, text)
