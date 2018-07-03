module ParseExamples

open Parse

// _____________________________________________________________________________
//                                                     Micro-C parsing examples

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

let ex2 =
    fromString
      @"
// micro-C example 2

void main() {
  int *p;                               // pointer to int
  int i;                                // int
  int ia[10];                           // array of 10 ints
  int* ia2;                             // pointer to int
  int *ipa[10];                         // array of 10 pointers to int
  int (*iap)[10];                       // pointer to array of 10 ints
  print i;                              // ~1
  print p;                              // ~1
  p = &i;                               // now p points to i
  print p;                              // 1
  ia2 = ia;                             // now ia2 points to ia[0]
  print *ia2;                           // ~1
  *p = 227;                             // now i is 227
  print p; print i;                     // 1 227
  *&i = 12;                             // now i is 12
  print i;                              // 12
  p = &*p;                              // no change
  print *p;                             // 12
  p = ia;                               // now p points to ia[0]
  *ia = 14;                             // now ia[0] is 14
  print ia[0];                          // 14
  *(ia+9) = 114;                        // now ia[9] is 114
  print ia[9];                          // 114
  ipa[2] = p;                           // now ipa[2] points to i
  print ipa[2];                         // 2
  print (&*ipa[2] == &**(ipa+2));       // 1 (true)
  iap = &ia;                            // now iap points to ia
  print (&(*iap)[2] == &*((*iap)+2));   // 1 (true)
}
"

let ex9 =
    fromString
      @"
// micro-C example 9 -- return a result via a pointer argument

void main(int i) {
  int r;
  fac(i, &r);
  print r;
}

void fac(int n, int *res) {
  // print &n;			// Show n's address
  if (n == 0)
    *res = 1;
  else {
    int tmp;
    fac(n-1, &tmp);
    *res = tmp * n;
  }
}
"
