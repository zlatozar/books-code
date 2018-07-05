module InterpExamples

open Parse
open Interp

let ex1 =
    fromString
      @"
     // micro-C example 1

     void main(int n) {
       while (n > 0) {
         print n;
         n = n - 1;
      }
      println;
    }
   "
let run1 = run ex1

// gloEnv:

// ([], [(main, ([(TypI, n)], Block
//   [Stmt
//      (While
//         (Prim2 (">",Access (AccVar "n"),CstI 0),
//          Block
//            [Stmt (Expr (Prim1 ("printi",Access (AccVar "n"))));
//             Stmt
//               (Expr (Assign (AccVar "n",Prim2 ("-",Access (AccVar "n"),CstI 1))))]));
//    Stmt (Expr (Prim1 ("printc",CstI 10)))]))])

// locEnv: ([(n, 0)], 1)  'n' is in position 0, next available is 1

// store: 17, 16, 15, ....
