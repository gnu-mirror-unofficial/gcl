;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Tue Aug 20 23:25:29 2002
;;;; Contains: Test cases for LENGTH

(in-package :cl-test)

(deftest length-list.1
  (length nil)
  0)

(deftest length-list.2
  (length '(a b c d e))
  5)

(deftest length-vector.1
  (length #())
  0)

(deftest length-vector.2
  (length #(a))
  1)

(deftest length-vector.3
  (length #(a b))
  2)

(deftest length-vector.4
  (length #(a b c))
  3)

(deftest length-nonsimple-vector.1
  (length (make-array 10 :fill-pointer t :adjustable t))
  10)

(deftest length-nonsimple-vector.2
  (let ((a (make-array 10 :fill-pointer t :adjustable t)))
    (setf (fill-pointer a) 5)
    (length a))
  5)

(deftest length-bitstring.1
  (length #*)
  0)

(deftest length-bitstring.2
  (length #*1)
  1)

(deftest length-bitstring.3
  (length #*0)
  1)

(deftest length-bitstring.4
  (length #*010101)
  6)

(deftest length-string.1
  (length "")
  0)

(deftest length-string.2
  (length "a")
  1)

(deftest length-string.3
  (length "abcdefghijklm")
  13)

(deftest length-string.4
  (length "\ ")
  1)

(deftest length-error.1
  (catch-type-error (length 'a))
  type-error)

(deftest length-error.2
  (catch-type-error (length 10))
  type-error)

(deftest length-error.3
  (catch-type-error (length 1.0))
  type-error)

(deftest length-error.4
  (catch-type-error (length #\a))
  type-error)

(deftest length-error.5
  (catch-type-error (length 10/3))
  type-error)
