;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Mon Sep  1 13:49:18 2003
;;;; Contains: Tests of RATIONAL

(in-package :cl-test)

(deftest rational.error.1
  (classify-error (rational))
  program-error)

(deftest rational.error.2
  (classify-error (rational 0 nil))
  program-error)

(deftest rational.error.3
  (classify-error (rational 0 0))
  program-error)

(deftest rational.error.4
  (loop for x in *mini-universe*
	unless (or (realp x)
		   (eq (eval `(classify-error (rational (quote ,x))))
		       'type-error))
	collect x)
  nil)

(deftest rational.1
  (loop for x in *reals*
	for r = (rational x)
	unless (and (rationalp r)
		    (if (floatp x)
			(= (float r x) x)
		      (eql x r)))
	collect (list x r))
  nil)

(deftest rational.2
  (loop for type in '(short-float single-float double-float long-float)
	collect
	(loop for i from -10000 to 10000
	      for x = (coerce i type)
	      for r = (rational x)
	      count (not (eql r i))))
  (0 0 0 0))

(deftest rational.3
  (loop for type in '(short-float single-float double-float long-float)
	for bound in '(1.0s5 1.0f10 1.0d20 1.0l30)
	nconc
	(loop for x = (random-from-interval bound)
	      for r = (rational x)
	      for x2 = (float r x)
	      repeat 1000
	      unless (and (rationalp r) (= x x2))
	      collect (list x r x2)))
  nil)