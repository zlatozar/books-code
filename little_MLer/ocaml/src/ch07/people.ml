let identity x = x;;

let true_maker _ = true;; (* even function could be passed *)

type bool_or_int =
  Hot of bool
  | Cold of int
;;

let hot_maker x = Hot x;;

(* ('a -> bool) -> bool_or_int - show that it accept function that produce Boolean *)
let help f =
  Hot (true_maker
         (if true_maker 5
          then f
          else true_maker)) (* unreachable *)
;;

let ident_five = help identity;; (* Hot (true_maker <any_function>) => Hot true *)

(* Note that there is no alternatives *)
type chain =
    Link of (int * (int -> chain)) (* first type definition that use ->, denotes that a function should be passed and it refers to itself *)
;;

(* Is this cause infinity - all integers? No! Link(n + 1, ints) do not calls `ints` again - it shows the type. *)
let rec ints n = Link (n + 1, ints);;    (* function in the tuple refers to itself *)
let rec skips n = Link (n + 2, skips);;

(* Tip: It is code convention to add 's' at the end of the functions that produce as many as there are *)

ints (5);; (* Link (6, <fun>). This is a lazy function - call next <fun> when it is needed  *)

let eq_int (a: int) (b: int) =
  (a = b)
;;

(* functions composition let n = f(g(n, c)) a.k.a chain and g(c, n) is lazy *)
let divides_evenly n c = eq_int (n mod c) 0;;

(* Define function with '= function' only when need to match parameters. 'function' has
built-in pattern matching or we can use 'match'. *)

let is_mod_5_or_7 n =
  if divides_evenly n 5
  then true
  else divides_evenly n 7
;;

let rec some_ints n =
  let next = (n + 1) in    (* define local scope with let ... in *)
  if is_mod_5_or_7 next
  then Link (next, some_ints)
  else some_ints next
;;

let n = some_ints 19;; (* => Link (20, <fun>) *)

(* Find the n-th element in Link (i, f)) *)
let rec chain_item n (Link (i, f)) =  (* Here is how directly construct 'chain' *)
  if eq_int n 1
  then i
  else chain_item (n - 1) (f i)       (* Lazy next result of function f *)
;;

(* Shows that order matters *)
let rec chain_item' (n:int) (ch:chain) =
  match n, ch with
    1, Link (i, _) ->  i
  | _, Link (i, f) ->  chain_item' (n - 1) (f i)
;;

let first_si = chain_item 1 (some_ints 0);;
let first_si' = chain_item' 1 (some_ints 0);;

let sixth_si = chain_item 6 (some_ints 0);;
let thirtyseventh_si = chain_item 37 (some_ints 0);;
let thirtyseventh_si' = chain_item' 37 (some_ints 0);;

let is_prime n =
  let rec has_no_divisors n c =           (* inner function *)
    if eq_int c 1
    then true
    else if divides_evenly n c
        then false
        else has_no_divisors n (c - 1)
  in
  has_no_divisors n (n - 1)
;;

let rec primes n =
  let next = (n + 1) in
  if is_prime next
  then Link (next, primes)
  else primes next
;;

let p12 = chain_item 12 (primes 1);;

let rec fibs n m = Link ((n + m), (fibs m));;

let fiblink0 = Link (0, (fibs 1));;

let fibs_1 m = Link ((1 + m), (fibs m));;
(* fibs_1 = fibs 1 *)

let fibs_2 = fibs 2;;


(* The Seventh Moral *)

(* Some functions consume values of arrow type; some produce values of arrow type. *)
