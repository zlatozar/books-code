(* Polymorphic type inference for a higher-order functional language.   *)
(* The operator (=) only requires that the arguments have the same type *)

(* NOTE: If this looks depressingly complicated, read Chapter 6 *)
(* NOTE2: A lot of functions here have side effects             *)

module TypeInference

open Absyn

// _____________________________________________________________________________
//                                                             Types definition


type 'v Env = (string * 'v) list

// A type is int, bool, function, or type variable
type Type =
    | TypI                                (* integers                     *)
    | TypB                                (* booleans                     *)
    | TypF of Type * Type                 (* (argument type, result type) *)
    | TypV of TypeVar                     (* type variable                *)

and TypeVarKind =
    | NoLink of string                    (* uninstantiated type variable *)
    | LinkTo of Type                      (* instantiated to Type         *)

and TypeVar =
    (TypeVarKind * int) ref               (* kind and binding level       *)

// A polymorphic type is represented by a type scheme, which is a list of type variables
// together with a type in which those type variables occurs.
type TypesScheme =
    | TypeScheme of TypeVar list * Type   (* type variables and type    *)

// A type environment maps a program variable name to a TypesScheme
type TEnv = TypesScheme Env


// _____________________________________________________________________________
//                                                               Implementation

let rec lookup env x =
    match env with
    | []        -> failwith (x + " not found")
    | (y, v)::r -> if x=y then v else lookup r x

(*
   Operations on sets of type variables, represented as lists. Inefficient but simple.
   Basically compares type variables on their string names. Correct so long as all type
   variable names are distinct.
*)

let rec mem x vs =
    match vs with
    | []      -> false
    | v :: vr -> x=v || mem x vr

// union(xs, ys) is the set of all elements in xs or ys, without duplicates
let rec union (xs, ys) =
    match xs with
    | []    -> ys
    | x::xr -> if mem x ys then union(xr, ys)
               else x :: union(xr, ys)

// unique xs  is the set of members of xs, without duplicates
let rec unique xs =
    match xs with
    | []    -> []
    | x::xr -> if mem x xr then unique xr else x :: unique xr

let setTvKind tyvar newKind =
    let (kind, lvl) = !tyvar
    tyvar := (newKind, lvl)

let setTvLevel tyvar newLevel =
    let (kind, lvl) = !tyvar
    tyvar := (kind, newLevel)

// FIND p. 107
// Normalize a type; make type variable point directly to the associated type (if any).
// This is the `find' operation, with path compression, in the union-find algorithm.
let rec normType t0 =
    match t0 with
    | TypV tyvar ->
        match !tyvar with
        | (LinkTo t1, _) -> let t2 = normType t1              // remove all hops
                            setTvKind tyvar (LinkTo t2)       //  ... and point directly to the type
                            t2
        | _ -> t0
    |  _ -> t0

// Find free type variables
let rec freeTypeVars t :TypeVar list =
    match normType t with
    | TypI        -> []
    | TypB        -> []
    | TypV tv     -> [tv]
    | TypF(t1,t2) -> union(freeTypeVars t1, freeTypeVars t2)

let occurCheck tyvar tyvars =
    if mem tyvar tyvars then failwith "type error: circularity" else ()

let pruneLevel maxLevel tvs =
    let reducelevel tyvar =
        let (_, level) = !tyvar
        setTvLevel tyvar (min level maxLevel)
    List.iter reducelevel tvs

(*
   Make type variable 'tyvar' equal to type 't' (by making 'tyvar' link to 't'), but first check
   that 'tyvar' does not occur in 't', and reduce the level of all type variables in 't' to that
   of 'tyvar'.  This is the `union' operation in the union-find algorithm.
*)

// UNION p. 107
// Given two nodes n1 and n2, join their equivalence classes into
// one equivalence class. In other words, force the two nodes to be equal.
let rec linkVarToType tyvar t =
    let (_, level) = !tyvar
    let fvs = freeTypeVars t
    occurCheck tyvar fvs
    pruneLevel level fvs
    setTvKind tyvar (LinkTo t)

let rec typeToString t :string =
    match t with
    | TypI         -> "int"
    | TypB         -> "bool"
    | TypV _       -> failwith "typeToString impossible"
    | TypF(t1, t2) -> "function"

// Unify two types, equating type variables with types as necessary
// See table on p. 106
let rec unify t1 t2 :unit =
    let t1' = normType t1
    let t2' = normType t2
    match (t1', t2') with
    | (TypI, TypI) -> ()
    | (TypB, TypB) -> ()
    // t1 is t11->t12 and t2 is t21->t22: Unify t11 with t21, and unify t12 with t22
    | (TypF(t11, t12), TypF(t21, t22)) -> unify t11 t21
                                          unify t12 t22
    | (TypV tv1, TypV tv2) ->      // make t1 to be equal to t2
        let (_, tv1level) = !tv1
        let (_, tv2level) = !tv2
        if tv1 = tv2 then ()
        else
            if tv1level < tv2level
              then linkVarToType tv1 t2'
              else linkVarToType tv2 t1'
    | (TypV tv1, _       ) -> linkVarToType tv1 t2'
    | (_,        TypV tv2) -> linkVarToType tv2 t1'
    | (TypI,     t) -> failwith ("type error: int and " + typeToString t)
    | (TypB,     t) -> failwith ("type error: bool and " + typeToString t)
    | (TypF _,   t) -> failwith ("type error: function and " + typeToString t)

// _____________________________________________________________________________
//                                                Generate fresh type variables

// mutable global variable
let tyvarno = ref 0

// NEW p. 107
// Every time when variable is met a new variable type should be associated
//
// Create a new node that is in its own one-element equivalence class
let newTypeVar level :TypeVar =
    let rec mkname i res =
        if i < 26 then char(97 + i) :: res
        else mkname (i/26 - 1) (char(97 + i%26) :: res)
    let intToName i = System.String(Array.ofList('\'' :: mkname i []))
    tyvarno := !tyvarno + 1
    ref (NoLink (intToName (!tyvarno)), level)   // note that it returns a reference

// There is an efficient way to decide whether a type variable can be generalized.  With
// every type variable we associate a binding level, where the outermost binding level is
// zero, and the binding level increases whenever we enter the right-hand side of a
// let-binding. When equating two type variables during type inference, we reduce the binding
// level of both type variables to the lowest (outermost) of their binding levels.

// Generalize over type variables not free in the context; that is, over those whose level
// is higher than the current level. p. 100
let generalize level (t: Type) :TypesScheme =
    let notfreeincontext tyvar =
        let (_, linkLevel) = !tyvar
        linkLevel > level
    let tvs = List.filter notfreeincontext (freeTypeVars t)
    TypeScheme(unique tvs, t)  // The unique call seems unnecessary because freeTypeVars has no duplicates??

// Copy a type, replacing bound type variables as dictated by 'tvenv',
// and non-bound ones by a copy of the type linked to
let rec copyType subst t :Type =
    match t with
    | TypV tyvar ->
        // Could this be rewritten so that loop does only the substitution?
        let rec loop subst1 =
            match subst1 with
            | (tyvar1, type1) :: rest -> if tyvar1 = tyvar
                                           then type1
                                           else loop rest
            | [] -> match !tyvar with
                    | (NoLink _, _)  -> t
                    | (LinkTo t1, _) -> copyType subst t1
        loop subst

    | TypF(t1,t2) -> TypF(copyType subst t1, copyType subst t2)
    | TypI        -> TypI
    | TypB        -> TypB

// A type scheme may be instantiated/crated (or specialized) by systematically replacing
// all occurrences in 't' of the type variables from 'tvs' with fresh type variables
let specialize level (TypeScheme(tvs, t)) :Type =
    let bindfresh tv = (tv, TypV(newTypeVar level))
    match tvs with
    | [] -> t
    | _  -> let subst = List.map bindfresh tvs
            copyType subst t

// Pretty-print type, using names 'a, 'b, ... for type variables
let rec showType t :string =
    let rec pr t =
        match normType t with
        | TypI         -> "int"
        | TypB         -> "bool"
        | TypV tyvar   ->
            match !tyvar with
            | (NoLink name, _) -> name
            | _                -> failwith "showType impossible"
        | TypF(t1, t2) -> "(" + pr t1 + " -> " + pr t2 + ")"
    pr t

// Returns the type of 'e' in 'env' at level 'lvl'. See rules on p. 104
let rec typ (lvl: int) (env: TEnv) (e: Expr) :Type =
    match e with
    | CstI i -> TypI
    | CstB b -> TypB
    | Var x  -> specialize lvl (lookup env x)
    | Prim(ope, e1, e2) ->
        let t1 = typ lvl env e1
        let t2 = typ lvl env e2
        match ope with
        | "*" -> (unify TypI t1; unify TypI t2; TypI)
        | "+" -> (unify TypI t1; unify TypI t2; TypI)
        | "-" -> (unify TypI t1; unify TypI t2; TypI)
        | "=" -> (unify t1 t2; TypB)
        | "<" -> (unify TypI t1; unify TypI t2; TypB)
        | "&" -> (unify TypB t1; unify TypB t2; TypB)
        | _   -> failwith ("unknown primitive " + ope)  // cover (p1)-(p5)

    | Let(x, eRhs, letBody) ->                          // (p6)
        let lvl1 = lvl + 1
        let resTy = typ lvl1 env eRhs
        let letEnv = (x, generalize lvl resTy) :: env
        typ lvl letEnv letBody

    | If(e1, e2, e3) ->                                 // (p7)
        let t2 = typ lvl env e2
        let t3 = typ lvl env e3
        unify TypB (typ lvl env e1)
        unify t2 t3;
        t2

    | Letfun(f, x, fBody, letBody) ->                   // (p8)
        let lvl1 = lvl + 1
        let fTyp = TypV(newTypeVar lvl1)
        let xTyp = TypV(newTypeVar lvl1)
        let fBodyEnv = (x, TypeScheme([], xTyp)) :: (f, TypeScheme([], fTyp)) :: env
        let rTyp = typ lvl1 fBodyEnv fBody
        unify fTyp (TypF(xTyp, rTyp)) |> ignore
        let bodyEnv = (f, generalize lvl fTyp) :: env
        typ lvl bodyEnv letBody

    | Call(eFun, eArg) ->                               // (p9)
        let tf = typ lvl env eFun
        let tx = typ lvl env eArg
        let tr = TypV(newTypeVar lvl)
        unify tf (TypF(tx, tr))
        tr

// Type inference: returns the type of e0, if any
let tyinf e0 = typ 0 [] e0

let inferType e =
    tyvarno := 0
    tyinf e |> showType
