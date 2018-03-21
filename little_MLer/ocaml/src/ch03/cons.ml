#use "../common/base.ml";;

(* The type system of ML is constructed from a basis of elementary types by applying certain *)
(* type constructors recursively. A type constructor is an operator that builds new types    *)
(* from simpler ones.                                                                        *)

type pizza =
  Crust
  | Cheese of pizza (* kind of decorator, add additional *)
  | Onion of pizza
  | Anchovy of pizza
  | Sausage of pizza
;;

(* Example of a type is: Cheese (Crust) *)

(* remove_anchovy : pizza -> pizza = <fun> *)
let rec remove_anchovy = function
  | Crust     -> Crust
  | Cheese x  -> Cheese  (remove_anchovy x)
  | Onion x   -> Onion   (remove_anchovy x)
  | Anchovy x -> remove_anchovy x           (* skip Anchovy, continue with others *)
  | Sausage x -> Sausage (remove_anchovy x)
;;

let noa = remove_anchovy (Cheese (Anchovy (Cheese Crust)));;

(* top_anchovy_with_cheese : pizza -> pizza = <fun> *)
let rec top_anchovy_with_cheese = function
  | Crust     -> Crust
  | Cheese x  -> Cheese (top_anchovy_with_cheese x)
  | Onion x   -> Onion  (top_anchovy_with_cheese x)
  | Anchovy x -> Cheese (Anchovy (top_anchovy_with_cheese x)) (* add Cheese for every Anchovy topping *)
  | Sausage x -> Sausage (top_anchovy_with_cheese x)
;;

(* Nice way to align code *)
let topped = top_anchovy_with_cheese (
  Onion (
    Anchovy (
      Cheese (
        Anchovy (
          Crust)))))
;;

(*
 NOTE: See what is `topped`:

 - : pizza = Onion (Cheese (Anchovy (Cheese (Cheese (Anchovy Crust)))))

It's type reminds CONSing!
*)

(* Another kind of function definition. More like function alias. *)
let subst_anchovy_by_cheese' x = remove_anchovy (top_anchovy_with_cheese x);;

let rec subst_anchovy_by_cheese = function
  | Crust     -> Crust
  | Cheese x  -> Cheese  (subst_anchovy_by_cheese x)
  | Onion x   -> Onion   (subst_anchovy_by_cheese x)
  | Anchovy x -> Cheese  (subst_anchovy_by_cheese x)
  | Sausage x -> Sausage (subst_anchovy_by_cheese x)
;;

(* The Third Moral *)

(* Functions that produce values of a datatype must use the associated constructors to *)
(* build data of that type.                                                            *)
