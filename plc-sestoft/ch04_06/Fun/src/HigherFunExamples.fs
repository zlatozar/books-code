module HigherFunExamples

open Parse

// _____________________________________________________________________________
//                        Examples of higher-order programs, in concrete syntax

let ex5 =
    fromString
     @"let tw g = let app x = g (g x) in app end
       in let mul3 x = 3 * x
       in let quad = tw mul3
       in quad 7 end end end"

let ex6 =
    fromString
     @"let tw g = let app x = g (g x) in app end
       in let mul3 x = 3 * x
       in let quad = tw mul3
       in quad end end end"

let ex7 =
    fromString
     @"let rep n =
           let rep1 g =
               let rep2 x = if n=0 then x else rep (n-1) g (g x)
               in rep2 end
           in rep1 end
       in let mul3 x = 3 * x
       in let tw = rep 2
       in let quad = tw mul3
       in quad 7 end end end end"

let ex8 =
    fromString
     @"let rep n =
           let rep1 g =
               let rep2 x = if n=0 then x else rep (n-1) g (g x)
               in rep2 end
           in rep1 end
       in let mul3 x = 3 * x
       in let twototen = rep 10 mul3
       in twototen 7 end end end"

let ex9 =
    fromString
     @"let rep n =
           let rep1 g =
               let rep2 x = if n=0 then x else rep (n-1) g (g x)
               in rep2 end
           in rep1 end
       in let mul3 x = 3 * x
       in let twototen = (rep 10) mul3
       in twototen 7 end end end"
