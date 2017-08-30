;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: STUDY-KANREN; Base: 10 -*-

;;; File lec02.lisp

(in-package :study-kanren)

;; Constants
(defconst +exist+ '(:|_.0|))
(defconst +nothing+ '())

;; Programs succeed by attempting a goal in a particular state, resulting in a stream of
;; achieving states.

;;; ____________________________________________________________________________
;;;                                                                       CONDE

;; CONDE, which resembles COND syntactically, is used to produce multiple
;; answers. Logically, conde can be thought of as disjunctive normal form: each clause
;; represents a disjunct, and is independent of the other clauses, with the relations
;; within a clause acting as the conjuncts.

(deftest lec01 ()
  (check

    (equal (run 1 (q)
             (== 5 5))
           +exist+)

    ;; With second parameter of `run' we point number of answers to be returned
    (equal (run 2 (q)
             (== 5 6))
           +nothing+)

    (equal (run 1 (q)
             (== 5 6))
           +nothing+)

    ;; `run*' means any number of answers
    (equal (run* (q)
             (== 5 5))
           +exist+)

    ;; We need `conde' operator to have multiple answers for q
    (equal (run* (q)
             (conde
               ;; run individual clause independently!
               ((== q 5))
               ((== q 6))))
           '(5 6))

    ;; The Law of CONDE
    ;; ----------------
    ;; To get more values from CONDE, pretend that the successful CONDE line has failed,
    ;; refreshing all variables that got an association from that line.

    ;; CONDE is logical OR (no short circular)
    (equal (run* (q)
             (conde
               ((== q 5) (== 4 q)) ; fail (could have more that one goal, acting as AND)
               ((== q 6))          ; succeed  q = 6
               ((== q 7))))        ; succeed  q = 7
           '(6 7))

    ;; Order matters
    (equal (run* (q)
             (conde
               ((== q 7))
               ((== q 6))
               ((== q 5) (== 4 q))))
           '(7 6))
    ))

;; >
;; (7 6)
;; > (run* (q)
;;     (conde
;;       [(== q 6)]
;;       [(== q 7)]
;;       [(== q 5) (== 4 q)]))
;; (6 7)
;; > (run 1 (q)
;;     (conde
;;       [(== q 6)]
;;       [(== q 7)]
;;       [(== q 5) (== 4 q)]))
;; (6)
;; > (run 1 (q)
;;     (conde
;;       [(== q 7)]
;;       [(== q 5) (== 4 q)]
;;       [(== q 6)]))
;; (7)
;; > (run* (q)
;;     (conde
;;       [(== q 7)]
;;       [(== q 5) (== 4 q)]
;;       [(== q 6)]))
;; (7 6)
;; > (run* (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7 6)
;; > (run* (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7 6)
;; > (run 1 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7)
;; > (run 2 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7 6)
;; > (run 3 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7 6)
;; > (run 1 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7)
;; > (run 2 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7 6)
;; > (run 2 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 6)]
;;       [(== q 7)]))
;; (6 7)
;; > (run 1 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 6)]
;;       [(== q 7)]))
;; (6)
;; > (run 1 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7)
;; > (run 1 (q)
;;     (conde
;;       [(== q 5) (== 4 q)]
;;       [(== q 7)]
;;       [(== q 6)]))
;; (7)
;; > (run 1 (q)
;;     (fresh (x y)
;;       (== (list x 5 y) q)))
;; ((_.0 5 _.1)) ; reified answers
;; > 5
;; 5
;; > (run 1 (q)
;;     (fresh (x y)
;;       (== (list x 5 y) q)))
;; ((_.0 5 _.1))
;; > (run 1 (q x y)
;;     (== (list x 5 y) q))
;; (((_.0 5 _.1) _.0 _.1))
;; > (run 1 (q)
;;     (fresh (x y)
;;       (== (list x 5 y) q)))
;; ((_.0 5 _.1))
;; > (run 1 (q)
;;     (fresh (x y)
;;       (== (list x 5 y) q)
;;       (== 7 y)))
;; ((_.0 5 7))
;; > (run 1 (q)
;;     (fresh (x y)
;;       (== (list x 5 y) q)
;;       (== 7 y)))
;; ((_.0 5 7))
;; > (run 1 (q)
;;     (fresh ()
;;       (== (list 4 5 6) q)
;;       (== 7 y)))
;; Unhandled exception
;;  Condition components:
;;    1. &undefined
;;    2. &who: eval
;;    3. &message: "unbound variable"
;;    4. &irritants: (y)
;; > (run 1 (q)
;;     (fresh ()
;;       (== (list 4 5 6) q)))
;; ((4 5 6))
;; > (run 1 (q)
;;     (fresh ()
;;       (== (list 4 5 6) q)
;;       (== 7 7)))
;; ((4 5 6))
;; > (run 1 (q)
;;     (== (list 4 5 6) q)
;;     (== 7 7))
;; ((4 5 6))
;; > (run 1 (???)
;;     (fresh (q)
;;       (== ??? q)
;;       (== (list 4 5 6) q)
;;       (== 7 7)))
;; ((4 5 6))
;; > (run 1 (???)
;;     (fresh (q)
;;       (== ??? q)
;;       (== (list 4 5 6) q)
;;       (== 7 7)))
;; ((4 5 6))
;; >

;; Core miniKanren

;; conjunction  (and)           fresh/run/within a single conde clause
;; disjunction  (or)            conde
;; equality     (==)            ==
;; introducing fresh variable   fresh
;; --------------------------
;; interface/collecting answers   (run)

;; Host language:
;; values (numbers, boolean constants, symbols, lists)
;; define, lambda, macros, recursion

;; > (run 1 (q) (== 5 5))
;; (_.0)
;; > (run 1 (q) (== '_.0 q))
;; (_.0)
;; > (run 1 (q) (== '_.1 q))
;; (_.1)
;; > (run 1 (q) (== '_.999 q))
;; (_.999)
;; > (run 1 (q) (== '_.0 q))
;; (_.0)
;; > (run 1 (q) (== '_.0 q) (== 5 q))
;; ()
;; > (run 1 (q) (== '_.0 q))
;; (_.0)
;; > (run* (q) (symbolo q))
;; ((_.0 (sym _.0)))
;; > (run* (q) (numbero q))
;; ((_.0 (num _.0)))
;; > (run* (q) (numbero q) (== 'foo q))
;; ()
;; > (run* (q) (numbero q) (== 5 q))
;; (5)
;; >
