;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: BOOK; Base: 10 -*-

;;; Copyright (c) 2008, Matthew Swank
;;; All rights reserved.

;;; File book-code.lisp: Contains functions defined in book

(in-package :book)

;;; ____________________________________________________________________________
;;;                                                                   Chapter 1

;; 1.56
(defun teacupo (x)
  (conde ((== 'tea x) +succeed+)
         ((== 'cup x) +succeed+)
         (else +fail+)))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 2

;; Here is the idea of naming `caro' and `cdro'
;;
;; First argument is called 'cons' because represent cons, second is 'q' because this is
;; the query parameter and result of `caro' will be assigned to it.

;; 2.9
(defun caro (cons q)
  (fresh (cdr)
    (== (cons q cdr) cons))) ; What is the value of 'car' such that consing with
                                        ; 'cdr'(could be anything) will give you given cons?
                                        ; Actually both 'q' and 'cdr' are discovered but only query parameter 'q' will be returned.

;; 2.16
(defun cdro (cons q)
  (fresh (car)
    (== (cons car q) cons)))

;; 2.28
(defun conso (car cdr q)
  (== (cons car cdr) q))

;; 2.35
(defun nullo (object)
  (== '() object))

;; 2.40
(defun eqo (x y)
  (== x y))

;; 2.53
(defun pairo (q)
  (fresh (car cdr)
    (conso car cdr q))) ; Do exist car and cdr such that (cons car cdr) to be equal to pair?

;;; ____________________________________________________________________________
;;;                                                                   Chapter 3

;; 3.5. `listo' has goals as questions and answers
(defun listo (list)
  (conde ((nullo list) +succeed+)
         ((pairo list)
          (fresh (d)       ; It is an unnesting of (list? (cdr l)). First we
            (cdro list d)  ; take the cdr of l and associate it with a fresh
            (listo d)))    ; variable d, and then we use d in the
         (else +fail+)))   ; recursive call.

;; The First Commandment
;; ---------------------
;; To transform a function whose value is a Boolean
;; into a function whose value is a goal, replace cond
;; with cond e and unnest each question and answer.
;; Unnest the answer #t (or #f) by replacing it with #s
;; (or #u).

;; 3.17 lolo - list of lists
(defun lolo (list)
  (conde ((nullo list) +succeed+)
         ;; these two fresh clauses could be consolidated into one
         ((fresh (a)
            (caro list a)
            (listo a))
          (fresh (d)
            (cdro list d)
            (lolo d)))
         (else +fail+)))

;; 3.31
(defun twinso-0 (s)
  (fresh (x y)
    (conso x y s)      ; to exist to x and y
    (conso x () y)))   ; such that adding nothing to x to have y

;; 3.36
(defun twinso-1 (s)
  (fresh (x)
    (== `(,x ,x) s)))

(setf (symbol-function 'twinso) #'twinso-1)

;; 3.37 loto - list-of-twins
(defun loto (list)
  (conde ((nullo list)
          +succeed+)
         ((fresh (a)
            (caro list a)
            (twinso a))
          (fresh (d)
            (cdro list d)
            (loto d)))
         (else +fail+)))

;; 3.48
(defun listofo (predo list)
  (conde ((nullo list)
          +succeed+)
         ((fresh (a)
            (caro list a)
            (funcall predo a))
          (fresh (d)
            (cdro list d)
            (listofo predo d)))
         (else +fail+)))

;; 3.50
(defun loto-1 (list)
  (listofo #'twinso list))

;; 3.54
(defun eq-caro (list x)
  (caro list x))

;; 3.54
(defun membero (x list)
  (conde ((nullo list) +fail+)
         ((eq-caro list x) +succeed+)
         (else (fresh (d)
                 (cdro list d)
                 (membero x d)))))

;; 3.65
(defun list-identity (list)
  (run* (y)
    (membero y list)))

;; What should the cdr be when we find this value?

;; It should be the empty list if we find the
;; value at the end of the list.

;; 3.80
(defun pmembero-0 (x list)
  (conde ((nullo list) +fail+)
         ((eq-caro list x) (cdro list '())) ; ***
         (else (fresh (d)
                 (cdro list d)
                 (pmembero-0 x d)))))

;; 3.83
(defun pmembero-1 (x list)
  (conde ((nullo list) +fail+)
         ((eq-caro list x) (cdro list '()))
         ((eq-caro list x) +succeed+)
         (else (fresh (d)
                 (cdro list d)
                 (pmembero-1 x d)))))

;; 3.86
(defun pmembero-2 (x list)
  (conde ((nullo list) +fail+)
         ((eq-caro list x) (cdro list '()))
         ((eq-caro list x)
          (fresh (a d)
            (cdro list `(,a . ,d))))
         (else (fresh (d)
                 (cdro list d)
                 (pmembero-2 x d)))))

;; 3.93
(defun pmembero-3 (x list)
  (conde ((eq-caro list x)
          (fresh (a d)
            (cdro list `(,a . ,d))))
         ((eq-caro list x) (cdro list '()))
         (else (fresh (d)
                 (cdro list d)
                 (pmembero-3 x d)))))

;; 3.95
(defun first-value (list)
  (run 1 (y)
    (membero y list)))

;; 3.98
(defun memberrevo (x list)
  (conde ((nullo list) +fail+)
         (+succeed+
          (fresh (d)
            (cdro list d)
            (memberrevo x d)))
         (else (eq-caro list x))))

;; 3.101
(defun reverse-list (list)
  (run* (y)
    (memberrevo y list)))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 4

(defun memo-0 (x list out)
  (conde ((nullo list) +fail+)
         ((eq-caro list x) (== list out))
         (else (fresh (d)
                 (cdro list d)
                 (memo-0 x d out)))))

(defun memo-1 (x list out)
  (conde ((eq-caro list x) (== list out))
         (else (fresh (d)
                 (cdro list d)
                 (memo-1 x d out)))))

(defun remembero (x list out)
  (conde ((nullo list) (== '() out))
         ((eq-caro list x)
          (cdro list out))
         (else (fresh (a d result)
                 (conso a d list)
                 (remembero x d result)
                 (conso a result out)))))

(defun surpriseo (s)
  (remembero s '(a b c) '(a b c)))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 5

(defun appendo-0 (list rest out)
  (conde ((nullo list) (== rest out))
         (else (fresh (a d result)
                 (caro list a)
                 (cdro list d)
                 (appendo-0 d rest result)
                 (conso a result out)))))

(defun appendo-1 (list rest out)
  (conde ((nullo list) (== rest out))
         (else (fresh (a d result)
                 (conso a d list)
                 (appendo-1 d rest result)
                 (conso a result out)))))

(defun appendo-2 (list rest out)
  (conde ((nullo list) (== rest out))
         (else (fresh (a d result)
                 (conso a d list)
                 (conso a result out)
                 (appendo-2 d rest result)))))

;; alias
(setf (symbol-function 'appendo) #'appendo-2)

(defun swappendo (list rest out)
  (conde (+succeed+ (fresh (a d result)
                      (conso a d list)
                      (conso a result out)
                      (swappendo d rest result)))
         (else (nullo list) (== rest out))))

(defun unwrapo-0 (x out)
  (conde ((pairo x)
          (fresh (a)
            (caro x a)
            (unwrapo-0 a out)))
         (else (== x out))))

(defun unwrapo-1 (x out)
  (conde (+succeed+ (== x out))
         (else (fresh (a) ; note absence of 'pairo'
                 (caro x a)
                 (unwrapo-1 a out)))))

(defun brancho (x tree)
  (fresh (car cdr)
    (conso car cdr tree)
    (conde ((nullo tree) +fail+)
           ((== car x) +succeed+)
           ((brancho x car))
           (else (brancho x cdr)))))

(defun flatteno (list? out)
  (conde ((nullo list?) (== '() out))
         ((pairo list?)
          (fresh (a d result-car result-cdr)
            (conso a d list?)
            (flatteno a result-car)
            (flatteno d result-cdr)
            (appendo result-car result-cdr out)))
         (else (conso list? '() out))))

(defun flattenrevo (list? out)
  (conde (+succeed+ (conso list? '() out))
         ((nullo list?) (== '() out))
         (else
           (fresh (a d result-car result-cdr)
             (conso a d list?)
             (flattenrevo a result-car)
             (flattenrevo d result-cdr)
             (appendo result-car result-cdr out)))))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 6

;; 6.1
(defun anyo (goal)
  (conde (goal +succeed+)
         (else (anyo goal))))

;; 6.4
(defvar +never+ (anyo +fail+))

;; 6.7
(defvar +always+ (anyo +succeed+))

;; 6.12
(defvar +sal+ #'(lambda (goal)
                  (conde (+succeed+ +succeed+)
                         (else goal))))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 7

(defun bit-xoro (x y r)
  (conde ((== 0 x) (== 0 y) (== 0 r))
         ((== 1 x) (== 0 y) (== 1 r))
         ((== 0 x) (== 1 y) (== 1 r))
         ((== 1 x) (== 1 y) (== 0 r))
         (else +fail+)))

(defun bit-nando (x y r)
  (conde ((== 0 x) (== 0 y) (== 1 r))
         ((== 1 x) (== 0 y) (== 1 r))
         ((== 0 x) (== 1 y) (== 1 r))
         ((== 1 x) (== 1 y) (== 0 r))
         (else +fail+)))

(defun bit-ando (x y r)
  (conde ((== 0 x) (== 0 y) (== 0 r))
         ((== 1 x) (== 0 y) (== 0 r))
         ((== 0 x) (== 1 y) (== 0 r))
         ((== 1 x) (== 1 y) (== 1 r))
         (else +fail+)))

(defun half-addero (x y r c)
  (all (bit-xoro x y r)
       (bit-ando x y c)))

(defun full-addero (b x y r c)
  (fresh (w xy wz)
    (half-addero x y w xy)
    (half-addero w b r wz)
    (bit-xoro xy wz c)))

(defun build-num (n)
  (cond ((zerop n) '())
        ((oddp n) `(1 . ,(build-num (/ (- n 1) 2))))
        ((and (evenp n) (not (zerop n)))
         `(0 . ,(build-num (/ n 2))))))

(defun poso (n)
  (fresh (a d)
    (== `(,a . ,d) n)))

(defun >1o (n)
  (fresh (a ad dd)
    (== `(,a ,ad . ,dd) n)))

(defun addero (d n m r)
  (condi ((== 0 d) (== '() m) (== n r))
         ((== 0 d) (== '() n) (== m r)
          (poso m))
         ((== 1 d) (== '() m)
          (addero 0 n '(1) r))
         ((== 1 d) (== '() n)
          (addero 0 '(1) m r))
         ((== '(1) n) (== '(1) m)
          (fresh (a c)
            (== `(,a ,c) r)
            (full-addero d 1 1 a c)))
         ((== '(1) n) (gen-addero d n m r))
         ((== '(1) m) (>1o n) (>1o r)
          (addero d '(1) n r))
         ((>1o n) (gen-addero d n m r))
         (else +fail+)))

(defun gen-addero (d n m r)
  (fresh (a b c e x y z)
    (== `(,a . ,x) n)
    (== `(,b . ,y) m) (poso y)
    (== `(,c . ,z) r) (poso z)
    (alli (full-addero d a b c e)
          (addero e x y z))))

(defun +o (n m k)
  (addero 0 n m k))

(defun -o (n m k)
  (+o m k n))

;;; ____________________________________________________________________________
;;;                                                                   Chapter 8

;;; ____________________________________________________________________________
;;;                                                                   Chapter 9


;;; (just forms not already in the reference implementation)
(defun occurs-check (x v subst)
  (let ((v (walk v subst)))
    (cond
      ((id-p v) (eq v x))
      ((consp v)
       (or (occurs-check x (car v) subst)
           (occurs-check x (cdr v) subst)))
      (t nil))))

(defun ext-s-check (rhs lhs subst)
  (cond ((occurs-check rhs lhs subst) +fail+)
        (t (extend-subst rhs lhs subst))))

(defun unify-check (v w subst)
  (let ((v (walk v subst))
        (w (walk w subst)))
    (cond ((eq v w) subst)
          ((id-p v)
           (ext-s-check v w subst))
          ((id-p w)
           (ext-s-check w v subst))
          ((and (consp v) (consp w))
           (let ((subst (unify-check (car v) (car w) subst)))
             (if (not (eq subst +fail+))
                 (unify-check (cdr v) (cdr w) subst)
                 +fail+)))
          ((equal v w) subst)
          (t +fail+))))

(defun ==-check (v w)
  #'(lambda (subst)
      (let ((subst-1 (unify-check v w subst)))
        (if (not (eq subst-1 +fail+))
            (funcall +succeed+ subst-1)
            (funcall +fail+ subst)))))

;;; ____________________________________________________________________________
;;;                                                                  Chapter 10

(defun not-pastao (x)
  (conda ((== 'pasta x) +fail+)
         (else +succeed+)))

(defun onceo (goal)
  (condu (goal +succeed+)
         (else +fail+)))

(defun bumpo (n x)
  (conde ((== n x) +succeed+)
         (else (fresh (m)
                 (-o n `(1) m)
                 (bumpo m x)))))

(defun gen&testo (op i j k)
  (onceo (fresh (x y z)
           (funcall op x y z)
           (== i x)
           (== j y)
           (== k z))))

(defun enumerateo (op r n)
  (fresh (i j k)
    (bumpo n i)
    (bumpo n j)
    (funcall op i j k)
    (gen&testo op i j k)
    (== `(,i ,j ,k) r)))

(defun gen-addero-1 (d n m r)
  (fresh (a b c e x y z)
    (== `(,a . ,x) n)
    (== `(,b . ,y) m) (poso y)
    (== `(,c . ,z) r) (poso z)
    (all (full-addero d a b c e)
         (addero e x y z))))
