#use "../ch01/building.ml";;

type 'a pizza =
  Bottom
  | Topping of ('a * ('a pizza))
;;

type fish =
  Anchovy
  | Lox
  | Tuna
;;

(*

Ungrammatical definition of the idea:

type fish pizza =
  Bottom
  | Topping of (fish * (fish pizza))
;;

*)

let rec rem_anchovy1 = function
  | Bottom               -> Bottom
  | Topping (Anchovy, x) -> rem_anchovy1 x  (* take rest(cdr) in our case x *)
  | Topping (Tuna, x)    -> Topping (Tuna, rem_anchovy1 x)
  | Topping (Lox, x)     -> Topping (Lox, rem_anchovy1 x)
;;

(* Shorter version - add another parameter f. We can't use '_' because f is used in body part. *)
let rec rem_anchovy = function
  | Bottom               -> Bottom
  | Topping (Anchovy, x) -> rem_anchovy x
  | Topping (f, x)       -> Topping (f, rem_anchovy x)
;;

let noa = rem_anchovy (
  Topping(Lox,
          Topping(Anchovy,
                  Topping(Tuna,
                          Topping(Anchovy,
                                  Bottom)))));;

(* TIP: Always ordered the patterns according to the alternatives in the corresponding *)
(*      datatype definition.                                                           *)

let rec rem_tuna = function
  | Bottom            -> Bottom
  | Topping (Tuna, x) -> rem_tuna x
  | Topping (f, x)    -> Topping (f, rem_tuna x)
;;

(* Let's generalize *)

let eq_fish1 =  function
    (Anchovy, Anchovy)     -> true
  | (Lox, Lox)             -> true
  | (Tuna, Tuna)           -> true
  | (a_fish, another_fish) -> false (* too much *)
;;

let eq_fish = function
  | (Anchovy, Anchovy)       -> true
  | (Lox, Lox)               -> true
  | (Tuna, Tuna)             -> true
  | ((_ : fish), (_ : fish)) -> false
;;

(* It is important to specify type otherwise OCaml complains *)
let rec (remove_fish1 : (fish * (fish pizza)) -> fish pizza) = function
    x, Bottom        -> Bottom
  | x, Topping(t, p) ->
      if eq_fish(t, x)
      then remove_fish1(x, p)
      else Topping(t, (remove_fish1(x, p)))
;;

(*
 * Could be written using 'match' and do not use `eq_fish`. Basically it 'match' is a dispatcher.
 * We have to know on what to dispatch - it is the parameter that we have to reduce in the recursion.
 *)

(* The type of f is deduced from `rem_fish2` function*)
let rec rem_fish2 f p =
  match p with
  | Bottom          -> Bottom
  | Topping (f', x) ->
      if f' = f
      then rem_fish2 f x
      else Topping (f', (rem_fish2 f x))
;;

(* Cool OCaml style *)
let rec rem_fish3 (f : fish) p =
  match p with
  | Bottom                      -> Bottom
  | Topping (f', x) when f' = f -> rem_fish3 f x
  | Topping (f', x)             -> Topping (f', (rem_fish3 f x))
;;

(* Three things could be met in `rem_fish3`: *)

(*  1. Using of match                                          *)
(*  2. Parameters are next to function name                    *)
(*  3. Introducing f' (can't use same name twice in a pattern) *)

let eq_fish (a: fish) (b: fish) = (* 'function' here is missing *)
  a = b
;;

let rec rem_fish f p =
  match p with
  | Bottom                            -> Bottom
  | Topping (f', x) when eq_fish f' f -> rem_fish f x
  | Topping (f', x)                   -> Topping (f', (rem_fish f x))
;;

let ch05_t1 =
  rem_fish Anchovy (Topping (Anchovy, Bottom));; (* => Bottom *)

let ch05_t2 = rem_fish Tuna
  (Topping (Anchovy,
            Topping (Tuna,
                     Topping (Anchovy, Bottom))));; (* => (Topping (Anchovy, (Topping (Anchovy, Bottom)))) *)

let eq_int (a : int) (b : int) =
  a = b
;;

let rec rem_int1 (n : int) p =
  match p with
  | Bottom                      -> Bottom
  | Topping (n', x) when n' = n -> rem_int1 n x
  | Topping (n', x)             -> Topping (n', (rem_int1 n x))
;;

let rec rem_int x p =
  match p with
  | Bottom          -> Bottom
  | Topping (n, p') ->
      if eq_int n x then rem_int x p'
      else Topping (n, (rem_int x p'))
;;

let rint = rem_int 3
  (Topping (3,
    Topping (2,
      Topping (3,
        Topping (2, Bottom)))))
;;

let rec subst_fish new_fish old_fish p =
  match p with
  | Bottom                            -> Bottom
  | Topping (f, p') when f = old_fish -> Topping (new_fish, (subst_fish new_fish old_fish p'))
  | Topping (f, p')                   -> Topping (f, (subst_fish new_fish old_fish p'))
;;

let refished = subst_fish Lox Anchovy
    (Topping (Anchovy,
              Topping (Tuna,
                       Topping (Anchovy, Bottom))))
;;

let rec subst_int new_n old_n p =
  match p with
  | Bottom                         -> Bottom
  | Topping (f, p') when f = old_n -> Topping (new_n, (subst_int new_n old_n p'))
  | Topping (f, p')                -> Topping (f, (subst_int new_n old_n p'))
;;

let rec eq_num (a: num) (b: num) =
  match (a, b) with
  | (Zero, Zero)                       -> true
  | (One_more_than a, One_more_than b) -> eq_num a b
  | _                                  -> false
;;

let z0 = eq_num Zero Zero;;
let z1 = eq_num Zero (One_more_than Zero);;
let z2 = eq_num Zero (One_more_than (One_more_than Zero));;

(* The Fifth Moral *)

(* Write the first draft of a function following all the morals. When it is correct and no *)
(* sooner, simplify.                                                                       *)
