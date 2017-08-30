type meza =
  Shrimp
  | Calamari
  | Escargots
  | Hummus
;;

type main =
  Steak
  | Ravioli
  | Chicken
  | Eggplant
;;

type salad =
  Green
  | Cucumber
  | Greek
;;

type dessert =
  Sundae
  | Mousse
  | Torte
;;

(* Tupels, they could contain different types: meza, main, salad, and dessert. *)
let meal_1 = (Calamari, Ravioli, Greek, Sundae);;
let meal_2 = (Hummus, Steak, Green, Torte);;

let mealb_1 = (Torte, Hummus, Steak, Sundae);;

let tinymeal_1 = (Shrimp, Sundae);;

(* Type constructions could be used in the code! Also note `fun` for function definition *)
let add_a_steak1 : meza -> meza * main =
  fun x -> (x, Steak)
;;

(* It is better to use the more specific one is more accurate,               *)
(* so using it will reveal nonsense more often. Here is how to specify type. *)
let add_a_steak (x : meza) = (x, Steak);;

let eq_main1 =  function
    Steak, Steak -> true
  | Ravioli, Ravioli -> true
  | Chicken, Chicken -> true
  | Eggplant, Eggplant -> true
  | a_main, another_main -> false (* Compiler will warn us that there are unused, better to replace with `_` *)
;;

let eq_main2 = function
  | (Steak, Steak)       -> true
  | (Ravioli, Ravioli)   -> true
  | (Chicken, Chicken)   -> true
  | (Eggplant, Eggplant) -> true
  | _                    -> false (* everything else but too general *)
;;

(* Narrow the possibilities as specify type *)
let eq_main ((a : main), (b : main)) =
  a = b
;;

let has_steak1 : (meza * main * dessert) -> bool =  function
    (a, Steak, d) -> true
  | (a, ns, d) -> false
;;

let has_steak = function
  | ((_ : meza), Steak, (_ : dessert)) -> true   (* it is important to specify type of the tuple member *)
  | _                                  -> false
;;

(* The Fourth Moral *)

(* Some functions consume values of star type; some produce values of star type. *)
