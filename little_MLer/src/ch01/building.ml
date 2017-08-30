#use "../common/base.ml";;

type seasoning =
    Salt
  | Pepper
;;

type num =
    Zero
  | One_more_than of num
;;

(* Zero is just Zero - like in Prolog. *)
One_more_than
  (One_more_than
     (One_more_than
        (One_more_than(Zero))));;

(* TIP: Resulting type is 'num'. C-c C-t to show type  *)

(* NOTE:                                                                    *)
(*                                                                          *)
(* What is an element of this new type? It is Zero!                         *)

(* It is recursive type definition. One_more_than could contains Zero or      *)
(* One_more_than but Zero can't - it is just a Zero. That's why you can't do: *)
(*                                                                            *)
(* Zero(One_more_than (Zero))                                                 *)

(* Like Java Generics. 'a is analog of <T> *)
type 'a open_faced_sandwich =
    Bread of 'a
  | Slice of 'a open_faced_sandwich
;;

(* ATTENTION: Everything that you use for definition should be defined before that. *)

(* The First Moral *)

(* Use datatype to describe types. When a type contains lots of values, *)
(* the datatype definition refers to itself. Use 'a with datatype       *)
(* to define shapes(represents many different datatypes).               *)
