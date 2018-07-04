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
