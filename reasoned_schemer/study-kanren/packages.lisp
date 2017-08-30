;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

;;; Copyright (c) 2008, Matthew Swank
;;; All rights reserved.

(defpackage :mini-kanren
  (:documentation "miniKanren implementation")
  (:use #:cl)
  (:import-from :alexandria
                #:with-gensyms)

  (:export #:unify
           #:walk*
           #:walk
           #:walk-impl
           #:reify-subst
           #:equivp
           #:unify-impl
           #:reify-subst-impl
           #:defconst
           #:id-p

           ;; user-interface
           #:else
           #:+succeed+ ;; #s
           #:+fail+    ;; #u
           #:jog
           #:project
           #:run
           #:run*
           #:==
           #:fresh
           #:conde
           #:condi
           #:condu
           #:all
           #:alli
           #:conda

           ;; lib-functions
           #:choice-case
           #:map-choice
           #:make-nary-relation
           #:permute-binary-relation
           #:make-binary-relation
           #:permute-ternary-relation
           #:make-ternary-relation))

(defpackage #:pcl-test
  (:documentation "Use defined in the book 'Practical Common Lisp' test framework
to test mini-kanren implementation.")
  (:use #:cl)
  (:export #:deftest
           #:check))

(defpackage :book
  (:documentation "Contains 'The Reasoned Schemer' book code")
  (:use :cl
        :pcl-test
        :mini-kanren)
  ;; Tests
  (:export #:ch1-tests
           #:ch2-tests
           #:ch3-tests
           #:ch6-tests
           #:ch9-tests
           #:ch10-tests)
  (:export ;; ch2
           #:caro
           #:cdro
           #:conso
           #:nullo
           #:eqo
           #:pairo
           ;; ch3
           #:listo
           #:eq-caro
           #:membero
           #:list-identity
           #:reverse-list
           ;; ch4
           #:remembero
           ;; ch5
           #:appendo
           #:brancho
           #:flatteno
           ;; ch6
           #:anyo
           #:+never+
           #:+always+
           #:+sal+
           #:addero
           ;; ch9
           #:==-check
           ;; ch10
           #:onceo
           #:gen&testo
           #:enumerateo))

(defpackage :study-kanren
  (:documentation "Contains code from 'miniKanren uncourse")
  (:use #:cl
        #:pcl-test
        #:mini-kanren
        #:book))

;;; ____________________________________________________________________________
;;;                                                                      Public

(defpackage :cl-kanren
  (:documentation "Expose functions defined in 'The Reasoned Schemer' book")
  (:use #:cl
        #:mini-kanren
        #:book)
  ;; `mini-kanren'
  (:export #:else
           #:+succeed+
           #:+fail+
           #:jog
           #:run
           #:run*
           #:==
           #:fresh
           #:conde
           #:condi
           #:condu
           #:all
           #:alli
           #:conda)
  ;; `book'
  (:export ;; ch2
           #:caro
           #:cdro
           #:conso
           #:nullo
           #:eqo
           #:pairo
           ;; ch3
           #:listo
           #:eq-caro
           #:membero
           #:list-identity
           #:reverse-list
           ;; ch4
           #:remembero
           ;; ch5
           #:appendo
           #:brancho
           #:flatteno
           ;; ch6
           #:anyo
           #:+never+
           #:+always+
           #:+sal+
           #:addero
           ;; ch9
           #:==-check
           ;; ch10
           #:onceo
           #:gen&testo
           #:enumerateo
           ))
