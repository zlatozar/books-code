;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: STUDY-KANREN; Base: 10 -*-

(in-package :study-kanren)

;; A domain-specific language (DSL) is a programming language or executable specification
;; language that offers, through appropriate notations and abstractions, expressive power
;; focused on, and usually restricted to, a particular problem domain.

;; (:|_.0|) is a symbol representing a fresh variable
(defconst +exist+ '(:|_.0|))
(defconst +nothing+ '())

;; In miniKanren programs are goals(could have sub-goals) that returns stream of answers.

;;; ____________________________________________________________________________
;;;                                                                Introduction

;; What is a relation? It is generalization of a function and it doesn't distinguish input and output.
;; A relation is simply a function that returns a goal as its value. A goal can either succeed or fail.
;; In logic programming we define rules that establish relation between variables.

;; `run' is the connection with the Common Lisp. It executes miniKanren program.
;; `run' succeeds IFF the conjunction of the provided goal expressions succeed.

(deftest lec01 ()
  (check

    ;; Returned value represents the value of 'q'. 'q' is called - query parameter.
    (equal (run 1 (q)
             ;; ≡ unifies two terms. It is a goal constructor
             (== '(3 ((((4)))) 5) '(3 ((((4)))) 5)))
           ;; The value returned is a list containing the single value (_.0); we say that
           ;; _.0 is the reified value of the unbound query variable 'q' and thus represents
           ;; any value.
           +exist+)

    ;; A run expression can return the empty list, indicating that the body of the
    ;; expression is logically inconsistent.
    (equal (run 1 (q)
             (== 5 6))
           ;; there isn't 'q' that satisfy ==
           +nothing+)

    ;; Is there any value of 'q' such that (== 5 q)
    (equal (run 1 (q)
             (== 5 q))
           '(5))

    ;; 'q' is a fresh variable also
    (equal (run 1 (q)
             (== q q))
           +exist+)

    ;; We can think of == as constraint, that should be satisfied

    (equal (run 1 (q)
             ;; we can place 'q' everywhere
             (== `(3 ,q) '(3 4)))
           '(4))

    (equal (run 1 (q)
             (== `(,q 4)
                 `(3 ,q)))
           +nothing+)

    (equal (run 1 (q)
             (== q '(3)))
           '((3)))

    ;; Common lisp implementation fails here! When 'q' and the list that contains 'q'
    ;; should be equal? This cause infinite recursion but should say that there is not
    ;; solution.

    ;; (equal (run nil (q)
    ;;          (== q `(,q))))

    ;; Shows that there is a solution, but this solution should be associated
    ;; with 'q'.
    (equal (run 1 (q)
             (fresh (x y)    ; *** adding local variables
               (== `(3 ,x)
                   `(,y 4))))
           +exist+)

    ;; Explicitly add another query to find out 'q' based on 'x' and 'y'
    (equal (run 1 (q)
             (fresh (x y)
               (== `(3 ,x)
                   `(,y 4))
               (== `(,x ,y) q)))
           ;; note that the order is defined by (x y)
           '((4 3)))

    ;; Fresh variable is kind of place holder for solutions(values of query variable)

    (equal (run 1 (q)
             (fresh (x y)
               (== `(lambda (,x) ,x) `(lambda (,y) ,y))
               (== `(,x ,y) q)))
           '((:|_.0| :|_.0|)))

    (equal (run 1 (q)
             (fresh (x y)
               (fresh (t1 t2)
                 (== `(lambda (,x) ,x) t1)
                 (== `(lambda (,y) ,y) t2)
                 (== `(,x ,y) q))))
           ;; (:|_.0| :|_.1|) means t1 and t2 potentially could be different
           '((:|_.0| :|_.1|)))

    ;; If we want t1 and t2 to be the same:
    (equal (run 1 (q)
             (fresh (x y)
               (fresh (t1 t2)
                 (== `(lambda (,x) ,x) t1)
                 (== `(lambda (,y) ,y) t2)
                 (== t1 t2)        ; ***
                 (== `(,x ,y) q))))
           '((:|_.0| :|_.0|)))

    (equal (run 1 (q)
             (fresh (x y)
               ;; Clever way to say that 'x' and 'y' must be equal
               (== `(lambda (,x) ,x) `(lambda (,x) ,y)) ; *** see there is no t1 and t2
               (== `(,x ,y) q)))
           '((:|_.0| :|_.0|)))
    ))
