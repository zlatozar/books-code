;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: BOOK; Base: 10 -*-

;;; Copyright (c) 2008, Matthew Swank
;;; All rights reserved.

(in-package :book)

;;; ____________________________________________________________________________
;;;                                                                   Chapter 1

;; +succeed+ (or #t in book) is a goal that succeeds.
;; +fail+    (#f in the book) is a goal that fails.

(deftest ch1-tests ()
  (check

    ;; 1.10
    (equal (run* (q)
             +fail+)
           '())     ; it returns () because goal fails

    ;; 1.11
    (equal (run* (q)
             (== 't q))
           '(t))

    ;; 1.12
    (equal (run* (q)
             +fail+ ; this always fail
             (== 't q))
           '())     ; to succeed all goals should succeed

    ;; 1.13-14
    (equal (run* (q)
             +succeed+
             (== 't q)) ; succeeds as associates q with t
           '(t))

    ;; 1.15-16
    (equal (run* (r)
             +succeed+
             (== 'corn r))
           '(corn))

    ;; 1.17
    (equal (run* (r)
             +fail+
             (== 'corn r))
           '())

    ;; 1.18
    (equal (run* (q)
             +succeed+
             (== 'nil q)) ; #f in Scheme is nil in CL
           '(nil))

    ;; 1.20
    (equal (run* (q)
             (let ((x 't))  ; we could use bindings in miniKanren
               (== nil x)))
           '())

    ;;1.21
    (equal (run* (q)
             (let ((x nil))
               (== nil x)))
           '(:_.0))     ; succeeds but there is no value
                                        ; associated with the goal

    ;; 1.22
    (equal (run* (x)
             (let ((x 'nil))
               (== 't x)))
           '())

    ;; 1.23
    (equal (run* (q)
             (fresh (x)
               (== 't x)
               (== 't q)))
           '(t))

    ;;     The Law of Fresh
    ;;     ----------------
    ;;     If X is fresh, then (≡ V X) succeeds
    ;;     and associates X with V.

    ;; It is kind of assignment

    ;; 1.26
    (equal (run* (q)
             (fresh (x)
               (== x 't)
               (== 't q))) ; What value is associated with q?
           '(t))

    ;; 1.27
    (equal (run* (q)
             (fresh (x)
               (== x 't)
               (== q 't)))
           '(t))

    ;;     The Law of ≡
    ;;     ------------
    ;;     (≡ V W) is the same as (≡ W V).

    ;; Order doesn't matter

    ;; 1.28
    (equal (run* (x)
             +succeed+)
           '(:_.0))

    ;; 1.29 Note the scope of fresh variables
    (equal (run* (x)
             (let ((x 'nil))
               (declare (ignorable x)) ; to avoid warnings in CL
               (fresh (x)
                 (== 't x))))
           '(:_.0))   ; Yes, there is a solution but there is no fresh variable
                                        ; associated with it.

    ;; 1.30 Note that there is association but x and y could be anything
    ;;      that's why (:_.0 :_.1)
    (equal (run* (r)
             (fresh (x y)
               (== (cons x (cons y '())) r))) ; could be written as `(,x ,y). See 2.2.

           '((:_.0 :_.1))) ; For each different fresh variable there is a
                                        ; symbol with an underscore followed by a
                                        ; numeric subscript - (:_.0 :_.1)

    ;; 1.31
    (equal (run* (s)
             (fresh (tee u)
               (== (cons tee (cons u '())) s)))
           '((:_.0 :_.1))) ; This entity is not a variable but rather
                                        ; is a way of showing that the variable was fresh.
                                        ; We say that such a variable has been reified.

    ;; 1.32
    (equal (run* (r)
             (fresh (x)
               (let ((y x))
                 (fresh (x)
                   (== (cons y (cons x (cons y '()))) r)))))
           '((:_.0 :_.1 :_.0))) ; Note that first and last fresh variables have
                                        ; equal values

    ;; 1.33
    (equal (run* (r)
             (fresh (x)
               (let ((y x))
                 (fresh (x)
                   (== (cons x (cons y (cons x '()))) r)))))
           '((:_.0 :_.1 :_.0)))

    ;; To succeeds all goals should succeed!

    ;; 1.34
    (equal (run* (q)
             (== 'nil q)  ; If variable is in a goal it is not fresh anymore
             (== 't q))   ; it is not fresh (has value 'nil) so can't succeed. See 1.47
           '())

    ;; 1.35
    (equal (run* (q)
             (== 'nil q)
             (== 'nil q)) ; but with it's value succeeds here
           '(nil))

    ;; 1.36
    (equal (run* (q)
             (let ((x q))
               (== 't x)))
           '(t))

    ;; 1.37 Because r starts out fresh and then r gets
    ;;      whatever association that x gets, but both
    ;;      x and r remain fresh. When one variable
    ;;      is associated with another, we say they
    ;;      co-refer or share.
    (equal (run* (r)
             (fresh (x)
               (== x r))) ; both x and r "point" to the potential value. See 1.39
           '(:_.0)) ; because r could be anything

    ;; 1.38
    (equal (run* (q)
             (fresh (x)
               (== 't x)
               (== x q)))
           '(t))

    ;; 1.39
    (equal (run* (q)
             (fresh (x)
               (== x q)   ; q gets x's association.
               (== 't x)))
           '(t))

    ;; 1.40 Are q and x different variables in:
    (equal (run* (q)
             (fresh (x)
               (== 't x)
               (== x q))) ; Yes, because two fresh variables are not equal.
           '(t))

    (equal (run* (q)
             (fresh (x)
               (== (eq x q) q)))
           '(nil))

    (equal (run* (q)
             (let ((x q))
               (fresh (q)
                 (== (eq x q) x))))
           '(nil))

    ;; 1.43
    (equal (run* (q)
             (cond (nil +succeed+)
                   (t +fail+)) ; t instead of else like in Scheme
             (== 't q))
           '())

    ;; CONDE, which resembles COND syntactically, is used to produce multiple
    ;; answers.

    ;; 1.44
    (equal (run* (q)
             (conde (+fail+ +succeed+)
                    (else +fail+)) ; like in Scheme
             (== 't q))
           '()) ; because all fail

    ;; 1.45
    (equal (run* (q)
             (conde (+fail+ +fail+)    ; or |
                    (else +succeed+))  ; or | AND
             (== 't q))                ;    |
           '(t))

    ;; 1.46
    (equal (run* (q)
             (conde (+succeed+ +succeed+)
                    (else +fail+))
             (== 't q))
           '(t))

    ;; 1.47. Forget about 1.34 when use CONDE
    (equal (run* (x)
             (conde ((== 'olive x) +succeed+) ; To get the second
                    ((== 'oil x) +succeed+)   ; value, we pretend that (== olive x) fails;
                    (else +fail+)))           ; this imagined failure refreshes x.
           '(olive oil))

    ;;    The Law of CONDE
    ;;    ----------------
    ;; To get more values from CONDE, pretend that the successful CONDE line has failed,
    ;; refreshing all variables that got an association from that line.

    ;; 1.49 You can tell `run' number of solutions to be returned
    (equal (run 1 (x)
             (conde ((== 'olive x) +succeed+)
                    ((== 'oil x) +succeed+)
                    (else +fail+)))
           '(olive))

    ;; 1.50
    (equal (run* (x)
             (conde ((== 'virgin x) +fail+)
                    ((== 'olive x) +succeed+)
                    (+succeed+ +succeed+)    ; always that's why :_.0
                    ((== 'oil x) +succeed+)
                    (else +fail+)))
           '(olive :_.0 oil))

    ;; 1.52
    (equal (run 2 (x)
             (conde ((== 'extra x) +succeed+)
                    ((== 'virgin x) +fail+)
                    ((== 'olive x) +succeed+)
                    ((== 'oil x) +succeed+)
                    (else +fail+)))
           '(extra olive)) ; return 2 instead of 3 results, because of `run' parameter

    ;; 1.53
    (equal (run* (r)
             (fresh (x y)
               (== 'split x)
               (== 'pea y)
               (== (cons x (cons y '())) r)))
           '((split pea)))

    ;; 1.54
    (equal (run* (r)
             (fresh (x y)
               (conde ((== 'split x) (== 'pea y)) ; every |
                      ((== 'navy x) (== 'bean y)) ; every | OR
                      (else +fail+))              ;       |
               (== (cons x (cons y '())) r)))
           '((split pea) (navy bean)))

    ;; 1.55
    (equal (run* (r)
             (fresh (x y)
               (conde ((== 'split x) (== 'pea y))
                      ((== 'navy x) (== 'bean y))
                      (else +fail+))
               (== (cons x (cons y (cons 'soup '()))) r))) ; add soup on every result
           '((split pea soup) (navy bean soup)))

    ;; 1.56
    (equal (run* (x)
             (teacupo x))
           '(tea cup))

    ;; 1.57. This is tricky!
    (equal (run* (r)
             (fresh (x y)
               ;; Here x has two associations tee and cup, so this first line
               ;; of CONDE are actually two lines!
               (conde ((teacupo x) (== 't y) +succeed+)
                      ((== 'nil x) (== 't y))
                      (else +fail+))
               (== (cons x (cons y '())) r)))
           '((tea t) (cup t) (nil t)))

    ;; 1.58. Fresh could be everywhere
    (equal (run* (r)
             (fresh (x y z)
               (conde ((== y x) (fresh (x) (== z x))) ; (:_.0 :_.1)
                      ((fresh (x) (== y x)) (== z x)) ; again (:_.0 :_.1) but do they are the same?
                      (else +fail+))
               (== (cons y (cons z '())) r)))
           '((:_.0 :_.1) (:_.0 :_.1)))

    ;; 1.59
    (equal (run* (r)
             (fresh (x y z)
               (conde ((== y x) (fresh (x) (== z x)))
                      ((fresh (x) (== y x)) (== z x))
                      (else +fail+))
               (== 'nil x)                      ; intentionally bind x to see it's position
               (== (cons y (cons z '())) r)))
           '((nil :_.0) (:_.0 nil))) ; see 1.58

    ;; 1.60
    (equal (run* (q)
             (let ((a (== 't q))
                   (b (== 'nil q)))
               (declare (ignorable a))
               b))
           '(nil))

    ;; REMEMBER: that (≡ . . . ), (fresh . . . ), and (conde . . . ) are expressions, each of
    ;; whose value is a goal. But, here we only treat the fresh expression's value, b, as a goal.

    ;; 1.61
    (equal (run* (q)
             (let ((a (== 't q))
                   (b (fresh (x)
                        (== x q)
                        (== 'nil x)))
                   (c (conde ((== 't q) +succeed+)
                             (else (== 'nil q)))))
               (declare (ignorable a c))
               b))
           '(nil))
    ))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 2

(deftest ch2-tests ()
  (check

    ;; 2.2
    (equal (run* (r)
             (fresh (y x)
               (== `(,x ,y) r))) ; `(,x ,y) => (cons x (cons y ()))
           '((:_.0 :_.1)))

    ;; 2.3
    (equal (run* (r)
             (fresh (v w)
               (== (let ((x v)  ; x and y are now fresh
                         (y w))
                     `(,x ,y))
                   r)))
           '((:_.0 :_.1))) ; r is associated with (x y) that could be anything

    ;; 2.6
    (equal (run* (r)
             (caro '(a c o r n) r)) ; caro is like car but accepts two parameters
           '(a))

    ;; 2.7
    (equal (run* (q)
             (caro '(a c o r n) 'a)
             (== 't q))
           '(t))

    ;; 2.8
    (equal (run* (r)
             (fresh (x y)
               (caro `(,r ,y) x)  ; Since x is associated with the car of ( r y)) ,
               (== 'pear x)))     ; which is the fresh variable r . Then x is
           '(pear))               ; associated with pear, which in turn
                                        ; associates r with pear.
    ;; 2.11
    (equal (run* (r)
             (fresh (x y)
               (caro '(grape raisin pear) x)
               (caro '((a) (b) (c)) y)
               (== (cons x y) r))) ; no need to write `(,x ,y) because they are quoted
           '((grape a))) ; from every goal

    ;; 2.15
    (equal (run* (r)
             (fresh (v)
               (cdro '(a c o r n) v) ; like cdr but with two parameters, v is '(c o r n) now
               (caro v r))) ; v is not fresh anymore
           '(c))

    ;; The process of transforming (car (cdr l)) into (cdro l v) and (caro v r) is
    ;; called unnesting. There is similarity between unnesting and continuation-passing style.

    ;; 2.18. Because variables introduced by fresh are
    ;;       values, we can use CL constructions in miniKanren.
    (equal (run* (r)
             (fresh (x y)
               (cdro '(grape raisin pear) x)
               (caro '((a) (b) (c)) y)
               (== (cons x y) r)))
           '(((raisin pear) a)))

    ;; 2.19
    (equal (run* (q)
             (cdro '(a c o r n) '(c o r n))
             (== 't q))
           '(t))

    ;; 2.20
    (equal (run* (x)
             (cdro '(c o r n) `(,x r n)))
           '(o)) ; miniKanren program returns value of query variable

    ;; 2.21 Because if the cdr of l is (c o r n) , then l
    ;;      must be the list (A c o r n) , where A is the
    ;;      fresh variable introduced in the definition
    ;;      of `cdro'.
    (equal (run* (l)
             (fresh (x)
               (cdro l '(c o r n)) ; l is something (:_.0) which cdr is '(c o r n)
               (caro l x)
               (== 'a x)))
           '((a c o r n)))

    ;; 2.22
    (equal (run* (l)
             (conso '(a b c) '(d e) l))
           '(((a b c) d e)))

    ;; 2.23
    (equal (run* (x)
             (conso x '(a b c) '(d a b c))) ; What value can we associate with x so
           '(d))                            ; that (cons x (a x c))) is (d a x c))?
                                        ; Obviously, d is the value.
    ;; 2.24
    (equal (run* (r)
             (fresh (x y z)
               (== `(e a d ,x) r)       ; r is (e a d (:_.0)) here
               (conso y `(a ,z c) r)))  ; What is the value of y such that (conso y (a (:_.0) c)) give (e a d (:_.0))
           '((e a d c)))                ; First add e, then a ,z first (:_.0) is associated with d and ,x second (:_.0) with c

    ;; 2.25
    (equal (run* (x)
             (conso x `(a ,x c) `(d a ,x c)))
           '(d))

    ;; X[:_.0] represents fresh logical variable X

    ;; 2.26
    (equal (run* (l)
             (fresh (x)
               (== `(d a ,x c) l)      ; l is (d a X[:_.0] c))
               (conso x `(a ,x c) l))) ; Find x in (== (conso x (a X[:_.0] c)) (d a X[:_.0] c)) => d a ?? c
           '((d a d c)))               ; X is in both places! Because `conso' associate x with d at the beginning
                                        ; X[:_.0] is d. The result will be (d a d c)

    ;; 2.27
    (equal (run* (l)
             (fresh (x)
               (conso x `(a ,x c) l) ; l is (X[:_.0] a X[:_.0] c)
               (== `(d a ,x c) l)))  ; X[:_.0] is associated with d, so result is (d a d c)
           '((d a d c)))

    ;; 2.29. That is hard...
    (equal (run* (l)
             (fresh (d x y w s)
               (conso w '(a n s) s) ;1.  s is (W[:_.0] a n s)
               (cdro l s)           ;2.  s is cdr(L[:_.0])
               (caro l x)           ;3.  x is car(L[:_.0])
               (== 'b x)            ;4.  x should be equal to 'b => l should have 'b as first element, because of p.3
               (cdro l d)           ;5.  d contains rest of l (excludes 'b)
               (caro d y)           ;6.  y is car d
               (== 'e y)))          ;7.  y is 'e  => d starts with 'e, because of p.6
           '((b e a n s)))          ;
                                        ; Now backwards. Remember we search for value of l!
                                        ; y -> 'e, d -> ('e ...) p.7 p.6
                                        ; l -> (... D['e ...]) p.5
                                        ; x is 'b p.4
                                        ; s -> ('b D['e ...]) => l -> (... 'b D['e ...])  because p.2. We need rest of s!
                                        ; s is (conso W[:_.0] '(a n s) ('b D['e ...])) which means w is '(b e) and rest of s is '(a n s)
                                        ; now l is (... b e a n s) and because of p.2 we discover that the result is '(b e a n s)
    ;; 2.32
    (equal (run* (q)
             (nullo '(grape raisin pear))
             (== 't q))
           '())

    ;; 2.33
    (equal (run* (q)
             (nullo '())
             (== 't q))
           '(t))

    ;; 2.34
    (equal (run* (x)
             (nullo x))
           '(()))

    ;; 2.38
    (equal (run* (q)
             (eqo 'pear 'plum)
             (== 't q))
           '())

    ;; 2.39
    (equal (run* (q)
             (eqo 'plum 'plum)
             (== 't q))
           '(t))

    ;; 2.52
    (equal (run* (r)
             (fresh (x y)
               (== (cons x (cons y 'salad)) r)))
           '((:_.0 :_.1 . salad)))

    ;; 2.54
    (equal (run* (q)
             (pairo (cons q q))
             (== 't q))
           '(t))

    ;; 2.55
    (equal (run* (q)
             (pairo '())
             (== 't q))
           '())

    ;; 2.56
    (equal (run* (q)
             (pairo 'pair)
             (== 't q))
           '())

    ;; 2.57
    (equal (run* (x)
             (pairo x))
           '((:_.0 . :_.1))) ; note the dot. (cons 'a 'b) ;=> (A . B)

    ;; 2.58
    (equal (run* (r)
             (pairo (cons r 'pear)))
           '(:_.0))
    ))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 3

(deftest ch3-tests ()
  (check

    ;; When determining the goal returned by `listo',
    ;; it is not necessary to determine the value of
    ;; x . Therefore x remains fresh, which means
    ;; that the goal returned from the call to `listo'
    ;; succeeds for all values associated with x .

    ;; 3.7
    (equal (run* (x)
             (listo `(a b ,x d)))
           '(:_.0))

    ;; 3.10
    (equal (run 1 (x)
             (listo `(a b c . ,x)))
           '(())) ; Because (a b c . x) is a proper list when x is the empty list!

    ;; Returns infinite stream - try bigger and bigger list
    ;; (run* (x)
    ;;          (listo `(a b c . ,x)))

    ;; 3.14
    (equal (run 5 (x)
             (listo `(a b c . ,x)))
           '(()
             (:_.0)
             (:_.0 :_.1)
             (:_.0 :_.1 :_.2)
             (:_.0 :_.1 :_.2 :_.3)))

    ;; Describe what we have seen in transforming list? into `listo'.

    ;; In list? each cond line results in a value, whereas in list o each cond e line results in
    ;; a goal. To have each cond e result in a goal, we unnest each cond question and each cond
    ;; answer. Used with recursion, a cond e expression can produce an unbounded number of
    ;; values. We have used an upper bound, 5 in the previous frame, to keep from creating a list
    ;; with an unbounded number of values.

    ;; 3.20
    (equal (run 1 (l)
             (lolo l)) ; Since l is fresh, (nullo l) succeeds and in
           '(()))      ; the process associates l with () .

    ;; 3.21
    (equal (run* (q)
             (fresh (x y)
               (lolo `((a b) (,x c) (d ,y))) ; succeeds and x and y could be anything
               (== 't q)))
           '(t))

    ;; 3.22
    (equal (run 1 (q)   ; note that we request only one answer
             (fresh (x)
               (lolo `((a b) . ,x)) ; yes there is a solution if x is (). See 3.23
               (== 't q)))
           '(t))

    ;; 3.23
    (equal (run 1 (x)
             (lolo `((a b) (c d) . ,x)))
           '(()))

    ;; 3.24
    (equal (run 5 (x)
             (lolo `((a b) (c d) . ,x)))
           '(()         ; ((a b)) (c d)) (() () () ())) => ((a b)) (c d)) () () () ())
             (())
             (() ())
             (() () ())
             (() () () ())))

    ;; 3.32. What is a twin? List of two identical values.
    ;;       Is (( g g)) (tofu tofu))) a list of twins?
    ;;       Yes, since both (g g) and (tofu tofu) are twins.
    (equal (run* (q)
             (twinso-0 '(tofu tofu))
             (== 't q))
           '(t))

    (equal (run* (q)
             (twinso-1 '(tofu tofu))
             (== 't q))
           '(t))

    ;; 3.33
    (equal (run* (z)
             (twinso-0 `(,z tofu)))
           '(tofu))

    (equal (run* (z)
             (twinso-1 `(,z tofu)))
           '(tofu))

    ;; 3.38
    (equal (run 1 (z)
             (loto `((g g) . ,z))) ; ((g g) . ()) is list of twins
           '(()))

    ;; 3.42
    (equal (run 5 (z)
             (loto `((g g) . ,z))) ; because ((g g) . ((:_.0 :_.0) (:_.1 :_.1))) is
           '(()                    ; ((g g) (:_.0 :_.0) (:_.1 :_.1)) and so on
             ((:_.0 :_.0))
             ((:_.0 :_.0) (:_.1 :_.1))
             ((:_.0 :_.0) (:_.1 :_.1) (:_.2 :_.2))
             ((:_.0 :_.0) (:_.1 :_.1) (:_.2 :_.2) (:_.3 :_.3))))

    ;; 3:45
    (equal (run 5 (r)
             (fresh (w x y z)
               (loto `((g g) (e ,w) (,x ,y) . ,z)) ; note that here there is no r. See 3.47
               (== `(,w (,x ,y) ,z) r))) ; obviously w is 'e, x and y are the same -> (:_.0 :_.0)
                                        ; z is (), ((:_.1 :_.1))....see 3.42
           '((e (:_.0 :_.0) ())
             (e (:_.0 :_.0) ((:_.1 :_.1)))
             (e (:_.0 :_.0) ((:_.1 :_.1) (:_.2 :_.2)))
             (e (:_.0 :_.0) ((:_.1 :_.1) (:_.2 :_.2) (:_.3 :_.3)))
             (e (:_.0 :_.0) ((:_.1 :_.1) (:_.2 :_.2) (:_.3 :_.3) (:_.4 :_.4)))))

    ;; 3.47
    (equal (run 3 (out)
             (fresh (w x y z)
               (== `((g g) (e ,w) (,x ,y) . ,z) out)
               (loto out))) ; we force out to be only twins
           '(((g g) (e e) (:_.0 :_.0))
             ((g g) (e e) (:_.0 :_.0) (:_.1 :_.1))
             ((g g) (e e) (:_.0 :_.0) (:_.1 :_.1) (:_.2 :_.2))))

    ;; 3.49
    (equal (run 3 (out)
             (fresh (w x y z)
               (== `((g g) (e ,w) (,x ,y) . ,z) out)
               (listofo #'twinso out)))

           '(((g g) (e e) (:_.0 :_.0))
             ((g g) (e e) (:_.0 :_.0) (:_.1 :_.1))
             ((g g) (e e) (:_.0 :_.0) (:_.1 :_.1) (:_.2 :_.2))))

    ;; 3.57
    (equal (run* (q)
             (membero 'olive '(virgin olive oil))
             (== 't q))
           '(t))

    ;; 3.58
    (equal (run 1 (y)
             (membero y '(hummus with pita))) ; We request one result so `membero' associate first one!
           '(hummus))

    ;; 3.59
    (equal (run 1 (y)
             (membero y '(with pita)))
           '(with))

    ;; 3.60
    (equal (run 1 (y)
             (membero y '(pita)))
           '(pita))

    ;; 3.61
    (equal (run 1 (y)
             (membero y '()))
           '())

    ;; 3.62
    (equal (run* (y)
             (membero y '(hummus with pita)))
           '(hummus with pita))

    ;; 3.66
    (equal (run* (x)
             (membero 'e `(pasta ,x fagioli))) ; The `membero' function determines that x's value should be e to succeed
           '(e))

    ;; 3.69. Tricky!
    (equal (run* (x)
             (membero 'e `(pasta e ,x fagioli)))
           '(:_.0 e)) ; because the recursion succeeds before it gets to the variable x .

    ;; 3.70. Tricky!
    (equal (run* (x)
             (membero 'e `(pasta ,x e fagioli)))
           '(e :_.0)) ; because the recursion succeeds when it gets to the variable x .

    ;; 3.71
    (equal (run* (r)
             (fresh (x y)
               (membero 'e `(pasta ,x fagioli ,y)) ; x is 'e, Y[:_.0] but also could be X[:_.0] and y is 'e
               (== `(,x ,y) r)))
           '((e :_.0) (:_.0 e)))

    ;; 3.73 Remember!
    (equal (run 1 (l)
             (membero 'tofu l))
           '((tofu . :_.0))) ; Represents every list whose car is tofu.

    ;; 3.76
    (equal (run 5 (l)
             (membero 'tofu l))
           '((tofu . :_.0)
             (:_.0 tofu . :_.1)
             (:_.0 :_.1 tofu . :_.2)
             (:_.0 :_.1 :_.2 tofu . :_.3)
             (:_.0 :_.1 :_.2 :_.3 tofu . :_.4))) ; if car contains tofu goal succeeds

    ;; Is it possible to remove the dotted variable at the end of each list, making it proper?
    ;; See `pmembero-0'

    (equal (run 5 (l)
             (pmembero-0 'tofu l))
           '((tofu)
             (:_.0 tofu)
             (:_.0 :_.1 tofu)
             (:_.0 :_.1 :_.2 tofu)
             (:_.0 :_.1 :_.2 :_.3 tofu)))
    ))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 4


;;; ____________________________________________________________________________
;;;                                                                   Chapter 6

(deftest ch6-tests ()
  (check

    ;; 6.24
    (equal (run 5 (r)
             (condi ((teacupo r) +succeed+)
                    ((== nil r) +succeed+)
                    (else +fail+)))
           '(tea nil cup))


    ;; 6.24
    (equal (run 5 (q)
             (condi ((== 'nil q) +always+)
                    ((== 't q) +always+)
                    (else +fail+))
             (== 't q))
           '(t t t t t))
    ))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 9

(deftest ch9-tests ()

  ;; 9.64
  (equal (run* (q)
           (==-check q `(,q)))
         '()))

;;; ____________________________________________________________________________
;;;                                                                  Chapter 10

(deftest ch10-tests ()
  (check

    ;; 10.1
    (equal (run* (q)
             (conda (+fail+ +succeed+)
                    (else +fail+)))
           '())

    ;; 10.2
    (equal (run* (q)
             (conda (+fail+ +succeed+)
                    (else +succeed+)))
           '(:_.0))

    ;; 10.3
    (equal (run* (q)
             (conda (+succeed+ +fail+)
                    (else +succeed+)))
           '())

    ;; 10.4
    (equal (run* (q)
             (conda (+succeed+ +succeed+)
                    (else +fail+)))
           '(:_.0))

    ;; 10.5
    (equal (run* (x)
             (conda ((== 'olive x) +succeed+)
                    ((== 'oil x) +succeed+)
                    (else +fail+)))
           '(olive))

    ;; 10.7
    (equal (run* (x)
             (conda ((== 'virgin x) +fail+)
                    ((== 'olive x) +succeed+)
                    ((== 'oil x) +succeed+)
                    (else +fail+)))
           '())

    ;; 10.14
    (equal (run* (q)
             (condu (+always+ +succeed+)
                    (else +fail+))
             (== 't q))
           '(t))

    ;; 10.18
    (equal (run 1 (q)
             (condu (+always+ +succeed+)
                    (else +fail+))
             +fail+
             (== 't q))
           '())

    ))
