;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: CL-USER; Base: 10 -*-

(in-package :cl-user)

(defpackage #:onlisp
  (:use :cl)
  (:export :mkstr
           :symb
           :longer
           :group
           :flatten
           :prune
           :most
           :best
           :mostn
           :mapa-b
           :map0-n
           :map1-n
           :map->
           :mappend
           :pprint-macro
           :when-bind
           :when-bind*
           :with-gensyms
           :condlet
           :condlet-clause
           :condlet-binds
           :nif
           :in
           :inq
           :in-if
           :>case
           :aif
           :awhen
           :awhile
           :aand
           :acond
           :alambda
           :ablock
           :aif2
           :awhen2
           :awhile2
           :acond2
           :dbind
           :destruc
           :with-array
           :with-struct
           :with-places))
