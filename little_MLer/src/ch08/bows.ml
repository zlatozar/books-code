#use "../ch07/people.ml";;

type 'a list =
    Empty
  | Cons of 'a * 'a list
;;

type orapl =
    Orange
  | Apple
;;

let eq_orapl a b =
  match (a, b) with
  | (Orange, Orange) -> true
  | (Apple, Apple)   -> true
  | _                -> false
;;

let rec subst_orapl n a = function
  | Empty       -> Empty
  | Cons (e, t) ->
      if eq_orapl a e
      then Cons (n, (subst_orapl n a t))
      else Cons (e, (subst_orapl n a t))
;;

let rec subst rel n a = function
  | Empty       -> Empty
  | Cons (e, t) ->
      if rel a e
      then Cons (n, (subst rel n a t))
      else Cons (e, (subst rel n a t))
;;

let ls_1 = Cons (15,
             (Cons (6,
               (Cons (15,
                 (Cons (17,
                   (Cons (15, (Cons (8, Empty)))))))))));;

let t_1 = subst eq_int 11 15 ls_1;;

let less_than (x: int) (y: int) =
  x < y
;;

let t_2 = subst less_than 11 15 ls_1;;

let in_range (small, large) x =
  (less_than small x) && (less_than x large)
;;

let t_3 = subst in_range 22 (11, 16) ls_1;;

let rec subst_pred pred n = function
  | Empty       -> Empty
  | Cons (e, t) ->
      if pred e
      then Cons (n, (subst_pred pred n t))
      else Cons (e, (subst_pred pred n t))
;;

let is_15' n = eq_int 15 n;;
let is_15'' = (fun x -> eq_int 15 x);;
let is_15 = eq_int 15;; (* Syntax sugar *)

let t_4 = subst_pred is_15 11 ls_1;;

let less_than_15 n = less_than n 15;;

let t_5 = subst_pred less_than_15 11 ls_1;;

let in_range_11_16 = in_range (11, 16);;

let t_6 = subst_pred in_range_11_16 22 ls_1;;

let in_range_c c = (in_range c);; (* curring, set one parameter and produce function that accept one parameter *)

let t_7 = subst_pred (in_range_c (11, 16)) 22 ls_1;;

let t_8 = subst_pred (in_range_c (3, 16)) 22 ls_1;;

(*
let rec combine = function
  | (Empty, Empty)               -> Empty
  | (Empty, Cons (b, l2))        -> Cons (b, l2)
  | (Cons (a, l1), Empty)        -> Cons (a, l1)
  | (Cons (a, l1), Cons (b, l2)) -> Cons (a, (combine (l1, Cons (b, l2))))
;;

 simplifies to ...

*)

(* Better name is 'append' *)
let rec combine = function
  | (Empty, l2)        -> l2
  | (Cons (a, l1), l2) -> Cons(a, (combine (l1, l2)))
;;

let ls_l = Cons (1,
                 Cons (2,
                       Cons (3, Empty)));;

let ls_r = Cons (12,
                 Cons (11,
                       Cons (5,
                             Cons (7, Empty))));;

let t_9 = combine (ls_l, ls_r);;

(*
 Consumes one list and produces a function that consumes a list and then produces the
 combined list.
 *)

let rec combine_c' l1 l2 = function
    Empty        -> (fun l2 -> l2)
  | Cons (a, l1) -> (fun l2 ->  Cons (a, combine_c' l1 l2))
;;

let c123' = combine_c' (Cons (1, Cons (2, Cons (3, Empty))));;
let try_c123' = c123' (Cons (4, Cons (5, Cons (6, Empty))));;

(* A function definition is like a fun , where a single argument is used in a pattern match. *)

let rec combine_c (l1: 'a list) (l2: 'a list) =
  match (l1, l2) with
  | (Empty, l2)        -> l2
  | (Cons (a, t1), l2) -> Cons (a, (combine_c t1 l2))
;;

(* A function that consumes a list and prefixes that list with 1, 2, and 3 *)
let c123 = combine_c (Cons (1, Cons (2, Cons (3, Empty))));;

let try_c123 = c123 (Cons (4, Cons (5, Cons (6, Empty))));;

let waiting_prefix_123 l2 =
  Cons (1,
    (combine_c (Cons (2, Cons (3, Empty))) l2))
;;

let base l2 : 'a list = l2;;

let rec combine_s = function
  | Empty        -> base
  | Cons (a, l1) -> make_cons a (combine_s l1)
and
  make_cons a f l2 = Cons (a, (f l2))
;;

let t_10 = combine_s ls_l;;
