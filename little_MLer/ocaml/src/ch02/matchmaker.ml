#use "../ch01/building.ml";;

(* __________________________________________________________________________ *)
(*                                                     OCaml code convention  *)

(* Token 	  	OCaml Naming Convention 	     Example     *)
(* --------------------------------------------------------------------- *)

(* Variables       Symbolic or initial lower case.                       *)
(*                 Use embedded caps for multiword names.    getItem     *)
(*                 Underscores are also occasionally used. 	         *)

(* Constructors   Initial upper case.                                    *)
(*                Use embedded caps for multi-word names.    EmptyQueue  *)

(* Types 	  All lower case.                                        *)
(*                Use underscores for multi-word names.   priority_queue *)

(* Signatures     All upper case.                                        *)
(*                Use underscores for multi-word names.   PRIORITY_QUEUE *)

(* Structures     Initial upper case. *)
(*                Use embedded caps for multi-word names.  PriorityQueue *)

(* Functors       Same as for structures,                                *)
(*                except Fn completes the name.          PriorityQueueFn *)

(* Contains four alternatives *)
type shish_kebab =
  Skewer
  | Onion of shish_kebab
  | Lamb of shish_kebab
  | Tomato of shish_kebab
;;

(* 'rec' means that function is recursive. *)
let rec only_onions = function
  (* Check in order of definitions - order matters *)
  | Skewer   -> true        (* shows that is allowed *)
  | Onion x  -> only_onions x
  | Lamb _   -> false       (* _ means "Whatever you pass" *)
  | Tomato _ -> false
;;

(* NOTE: There is no parameter after 'only_onions'. Here is how could be read: *)

(* Assign to 'only_onions' a recursicve function that accpept as paratemter many types (analogy is generic methods)   *)
(*  let only_onions =                                                                                                 *)
(*    function(Skewer _ {return  true}|Onion x {return only_onions(x)}|Lamb _ {return false}|Tomato _ return {false}) *)

(* Functions are expressions so we can bind them *)
let oo = only_onions (Onion (Onion Skewer));;
let no = only_onions (Onion (Lamb Skewer));;

let rec is_vegetarian = function
  | Skewer   -> true
  | Onion x  -> is_vegetarian x
  | Lamb _   -> false
  | Tomato x -> is_vegetarian x
;;

let iv = is_vegetarian (Tomato (Onion Skewer));;
let nv = is_vegetarian (Tomato (Onion (Lamb Skewer)));;

(* Identifiers beginning with the apostrophe ' are type variables. They can only refer to *)
(* types and cannot be bound to ordinary values.                                          *)
type 'a shish =
  Bottom of 'a
  | Onion of 'a shish
  | Lamb of 'a shish
  | Tomato of 'a shish
;;

(* First kind of `Bottom` *)
type rod =
  Dagger
  | Fork
  | Sword
;;

(* Second kind of `Bottom` *)
type plate =
  Gold_plate
  | Silver_plate
  | Brass_plate
;;

(* Matches arbitrary `Bottom` types e.g. rod shish, plate shish, int shish, num shish etc. *)
(* It works for all types we could possible think.                                         *)
let rec is_veggie = function
  | Bottom _ -> true
  | Onion x  -> is_veggie x
  | Lamb _   -> false
  | Tomato x -> is_veggie x
;;

let num_veggie = is_veggie (Onion
                              (Tomato
                                 (Bottom
                                    (One_more_than Zero))))
;;

let rec what_bottom = function
  Bottom x   -> x
  | Onion x  -> what_bottom x
  | Lamb x   -> what_bottom x
  | Tomato x -> what_bottom x
;;

let is_52 = what_bottom (Bottom 52);;
let is_sword = what_bottom (Bottom Sword);;
let is_52' = what_bottom (Tomato (Onion (Lamb (Bottom 52))));;

(* NOTE: When call function paranthesis are optional. *)

(* Second Moral *)

(* The number and order of the patterns in the definition of a function should match that of *)
(* the definition of the consumed type.                                                      *)
