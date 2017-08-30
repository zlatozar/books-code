type fruit =
    Peach
  | Apple
  | Pear
  | Lemon
  | Fig
;;

(* Contains 3 alternatives *)
type tree =
    Bud
  | Flat of fruit * tree
  | Split of tree * tree  (* Every split could be a tree !!! *)
;;

(* flat_only : tree -> bool *)
let rec flat_only1 =  function
    Bud          -> true
  | Flat (f, t)  -> flat_only1 t  (* Reduce the tree and continue to search Flat *)
  | Split (s, t) -> false         (* Compiler warn us that the s and t and unused so we can use _ *)
;;

let rec flat_only = function
    Bud         -> true
  | Flat (_, t) -> flat_only t
  | _           -> false
;;

(* split_only : tree -> bool *)
let rec split_only = function
    Bud           -> true
  | Split (t, t') -> split_only t && split_only t' (* we have to check both branches *)
  | _             -> false
;;

(* Do not contains fruit *)
let splitted_tree = split_only (Split
                                  (Split
                                     (Bud, (
                                        Split (Bud, Bud))),
                                   Split
                                     (Bud, (
                                        Split (Bud, Bud)))))
;;

let rec contains_fruit1 = function
  Bud          -> false
  | Split(s,t) ->
      if contains_fruit1(s)
      then true
      else contains_fruit1(t)
  | Flat(f,t)  -> true
;;

let rec contains_fruit = function
    Bud           -> false
  | Split (t, t') -> contains_fruit t || contains_fruit t'
  | Flat (f, t)   -> true
;;

(* If you apply DeMorgan rule *)
let contains_fruit' t = not (split_only t);;

let larger_of (x, y) : int = if x > y then x else y;;

(* The height of a tree is the distance from the root to the highest bud in the tree. *)
let rec height = function
    Bud -> 0
  | Flat (_, t)   -> 1 + (height t)                             (* Continue with the rest *)
  | Split (t, t') -> 1 + (larger_of ((height t), (height t')))  (* Check the two branches and took larger one *)
;;

let h1 = height (Split (Bud, Bud));;
let h2 = height(Split
                  (Split(
                     Bud,
                     Bud),
                   Flat(Fig,
                        Flat(Lemon,
                             Flat(Apple,
                                  Bud)))));;

(* fruit * fruit -> bool *)
let eq_fruit1 = function
    Peach, Peach     -> true
  | Apple, Apple     -> true
  | Pear, Pear       -> true
  | Lemon, Lemon     -> true
  | Fig, Fig         -> true
  | a_fruit, b_fruit -> false
;;

(* fruit * fruit * tree -> tree *)
let rec subst_in_tree1 =  function
    n, a, Bud         -> Bud
  | n, a, Flat (f, t) ->
      if eq_fruit1 (f, a)
      then Flat (n, subst_in_tree1 (n, a, t))
      else Flat (f, subst_in_tree1 (n, a, t))
  | n, a, Split (s, t) ->
      Split (subst_in_tree1 (n, a, s), subst_in_tree1 (n, a, t))
;;

let s1 = subst_in_tree1 (Apple, Fig, Split
                           (Split(
                              Flat(Fig,
                                   Bud),
                              Flat(Fig,
                                   Bud)),
                            Flat(Fig,
                                 Flat(Lemon,
                                      Flat(Apple,
                                           Bud)))));;

(* TIP: Can't match multiple arguments as such, but you can match tuples *)

(* fruit -> fruit -> bool *)
let eq_fruit (a: fruit) (b: fruit) =
  a = b
;;

(* fruit -> fruit -> tree -> bool *)
let rec subst_in_tree (newf: fruit) (oldf: fruit) (tree: tree) =
  match tree with
  | Bud           -> Bud
  | Flat (f, t)   ->
      if eq_fruit oldf f
      then (Flat (newf, (subst_in_tree newf oldf t)))
      else (Flat (f,    (subst_in_tree newf oldf t)))
  | Split (t, t') -> Split ((subst_in_tree newf oldf t), (subst_in_tree newf oldf t'))
;;

(* Call `subst_in_tree` is different *)
let s = subst_in_tree Apple Fig (Split (Split           (* use () to group tree - third parameter, otherwise will be recognized as two trees *)
                                          (Flat(Fig,
                                                Bud),
                                           Flat(Fig,
                                                Bud)),
                                        Flat(Fig,
                                             Flat(Lemon,
                                                  Flat(Apple,
                                                       Bud)))));;

let rec occurs fruit tree =
  match tree with
  | Bud                        -> 0
  | Flat (f, t) when f = fruit -> 1 + (occurs fruit t)
  | Flat (_, t)                -> occurs fruit t
  | Split (t, t')              -> (occurs fruit t) + (occurs fruit t')
;;

type 'a slist =
  Empty
  | Scons of (('a sexp) * ('a slist))
and
  'a sexp = An_atom of 'a
  | A_slist of ('a slist)   (* mutual recursion *)
;;

(* Tip: Follow the type structure *)
let rec occurs_in_slist fruit ls =
  match ls with
  Empty          -> 0
  | Scons (s, y) -> (occurs_in_sexp fruit s) + (occurs_in_slist fruit y)
and
  occurs_in_sexp fruit ls =
  match ls with
  | An_atom f -> if eq_fruit f fruit then 1 else 0
  | A_slist y -> occurs_in_slist fruit y
;;

let fruit_occ = occurs_in_slist Fig (Scons(A_slist
                                             (Scons(An_atom (Fig),
                                                    Scons(An_atom(Peach),
                                                          Empty))),
                                           Scons(An_atom(Fig),
                                                 Scons(An_atom(Lemon),
                                                       Empty))));;

(* NOTE: We can do some analogy with Lisp: An_atom(Fig) is regular Lisp atom with type that is before it *)

let rec subst_in_slist (newf: fruit) (oldf: fruit) (ls: fruit slist) : fruit slist =
  match ls with
  | Empty          -> Empty
  | Scons (f, ls') -> Scons ((subst_in_sexp newf oldf f), (subst_in_slist newf oldf ls'))
and
  subst_in_sexp newf oldf s =
  match s with
  | An_atom f      -> if eq_fruit f oldf then An_atom newf else An_atom f
  | A_slist y      -> A_slist (subst_in_slist newf oldf y)
;;

(* Consume a 'fruit' and a 'fruit sexp' and determines whether the latter is an atom *)
(* constructed from the given 'fruit'. *)
let eq_fruit_in_atom a = function
  | An_atom f  -> eq_fruit a f    (* let atom_maker = An_atom f *)
  | A_slist _  -> false
;;

(* NOTE:
   1. Only the first parameter is defined next to the name
   2. An_atom(Fig) is a call to constructor that creates An_atom type. A_slist(Fig) wont succeed.
*)

(* After we have designed a program that naturally follows the datatype definitions, we can *)
(* considerably improve it by focusing on its weaknesses and carefully rearranging its      *)
(* pieces.                                                                                  *)

(* fruit -> fruit slist -> fruit slist *)
let rec rem_from_slist1 a = function
  | Empty          -> Empty
  | Scons (hd, tl) ->
      if eq_fruit_in_atom a hd
      then rem_from_slist1 a tl
      else Scons (rem_from_sexp1 a hd, (rem_from_slist1 a tl))
and
  rem_from_sexp1 a = function
  | An_atom f -> An_atom f
  | A_slist y -> A_slist (rem_from_slist1 a y)
;;

let rem1 = rem_from_slist1 Fig (Scons (An_atom(Fig),
                                     Empty));;

let rem1' = rem_from_slist1 Fig (Scons(A_slist
                                       (Scons(An_atom (Fig),
                                              Scons(An_atom(Peach),
                                                    Empty))),
                                     Scons(An_atom(Fig),
                                           Scons(An_atom(Lemon),
                                                 Empty))));;

let rec rem_from_slist a = function
  | Empty                    -> Empty
  | Scons ((An_atom hd), tl) ->        (* Narrow match so we can use `eq_fruit` directly and first element is 'An_atom' *)
      if eq_fruit a hd
      then rem_from_slist a tl
      else Scons ((An_atom hd), (rem_from_slist a tl))
  | Scons ((A_slist ls), tl) -> Scons ((A_slist (rem_from_slist a ls)), (rem_from_slist a tl))
;;

let rem = rem_from_slist Fig (Scons (An_atom(Fig),
                                     Empty));;

let rem' = rem_from_slist Fig (Scons(A_slist
                                       (Scons(An_atom (Fig),
                                              Scons(An_atom(Peach),
                                                    Empty))),
                                     Scons(An_atom(Fig),
                                           Scons(An_atom(Lemon),
                                                 Empty))));;

(* The Sixth Moral *)

(* As datatype definitions get more complicated, so do the functions over them. *)
