;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Wed Aug 28 20:53:24 2002
;;;; Contains: Tests for FIND-IF-NOT

(in-package :cl-test)

(deftest find-if-not-list.1
  (find-if-not #'identity ())
  nil)

(deftest find-if-not-list.2
  (find-if-not #'null '(a))
  a)

(deftest find-if-not-list.2a
  (find-if-not 'null '(a))
  a)

(deftest find-if-not-list.3
  (find-if-not #'oddp '(1 2 4 8 3 1 6 7))
  2)

(deftest find-if-not-list.4
  (find-if-not #'oddp '(1 2 4 8 3 1 6 7) :from-end t)
  6)

(deftest find-if-not-list.5
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start i))
  (2 2 4 8 6 6 6 nil))

(deftest find-if-not-list.6
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start i :end nil))
  (2 2 4 8 6 6 6 nil))

(deftest find-if-not-list.7
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start i :from-end t))
  (6 6 6 6 6 6 6 nil))

(deftest find-if-not-list.8
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start i :end nil :from-end t))
  (6 6 6 6 6 6 6 nil))

(deftest find-if-not-list.9
  (loop for i from 0 to 8 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :end i))
  (nil nil 2 2 2 2 2 2 2))

(deftest find-if-not-list.10
  (loop for i from 0 to 8 collect
	(find-if-not #'oddp '(1 2 4 8 3 1 6 7) :end i :from-end t))
  (nil nil 2 4 8 8 8 6 6))

(deftest find-if-not-list.11
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start j :end i)))
  ((nil 2 2 2 2 2 2 2)
   (2 2 2 2 2 2 2)
   (4 4 4 4 4 4)
   (8 8 8 8 8)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-list.12
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'oddp '(1 2 4 8 3 1 6 7) :start j :end i
		       :from-end t)))
  ((nil 2 4 8 8 8 6 6)
   (2 4 8 8 8 6 6)
   (4 8 8 8 6 6)
   (8 8 8 6 6)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-list.13
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp '(1 6 11 32 45 71 100) :key #'1+ :start i))
  (1 11 11 45 45 71 nil))

(deftest find-if-not-list.14
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp '(1 6 11 32 45 71 100) :key '1+ :start i :from-end t))
  (71 71 71 71 71 71 nil))

(deftest find-if-not-list.15
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp '(1 6 11 32 45 71 100) :key #'1+ :end i))
  (nil 1 1 1 1 1 1 1))

(deftest find-if-not-list.16
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp '(1 6 11 32 45 71 100) :key '1+ :end i :from-end t))
  (nil 1 1 11 11 45 71 71))

(deftest find-if-not-list.17
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'evenp '(1 2 4 8 3 1 6 7) :start j :end i :key #'1-)))
  ((nil 2 2 2 2 2 2 2)
   (2 2 2 2 2 2 2)
   (4 4 4 4 4 4)
   (8 8 8 8 8)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-list.18
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'evenp '(1 2 4 8 3 1 6 7) :start j :end i
		       :from-end t :key #'1+)))
  ((nil 2 4 8 8 8 6 6)
   (2 4 8 8 8 6 6)
   (4 8 8 8 6 6)
   (8 8 8 6 6)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

;;; tests for vectors

(deftest find-if-not-vector.1
  (find-if-not #'identity #())
  nil)

(deftest find-if-not-vector.2
  (find-if-not #'not #(a))
  a)

(deftest find-if-not-vector.2a
  (find-if-not 'null #(a))
  a)

(deftest find-if-not-vector.3
  (find-if-not #'oddp #(1 2 4 8 3 1 6 7))
  2)

(deftest find-if-not-vector.4
  (find-if-not #'oddp #(1 2 4 8 3 1 6 7) :from-end t)
  6)

(deftest find-if-not-vector.5
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start i))
  (2 2 4 8 6 6 6 nil))

(deftest find-if-not-vector.6
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start i :end nil))
  (2 2 4 8 6 6 6 nil))

(deftest find-if-not-vector.7
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start i :from-end t))
  (6 6 6 6 6 6 6 nil))

(deftest find-if-not-vector.8
  (loop for i from 0 to 7 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start i :end nil :from-end t))
  (6 6 6 6 6 6 6 nil))

(deftest find-if-not-vector.9
  (loop for i from 0 to 8 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :end i))
  (nil nil 2 2 2 2 2 2 2))

(deftest find-if-not-vector.10
  (loop for i from 0 to 8 collect
	(find-if-not #'oddp #(1 2 4 8 3 1 6 7) :end i :from-end t))
  (nil nil 2 4 8 8 8 6 6))

(deftest find-if-not-vector.11
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start j :end i)))
  ((nil 2 2 2 2 2 2 2)
   (2 2 2 2 2 2 2)
   (4 4 4 4 4 4)
   (8 8 8 8 8)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-vector.12
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'oddp #(1 2 4 8 3 1 6 7) :start j :end i
		       :from-end t)))
  ((nil 2 4 8 8 8 6 6)
   (2 4 8 8 8 6 6)
   (4 8 8 8 6 6)
   (8 8 8 6 6)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-vector.13
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp #(1 6 11 32 45 71 100) :key #'1+ :start i))
  (1 11 11 45 45 71 nil))

(deftest find-if-not-vector.14
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp #(1 6 11 32 45 71 100) :key '1+ :start i :from-end t))
  (71 71 71 71 71 71 nil))

(deftest find-if-not-vector.15
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp #(1 6 11 32 45 71 100) :key #'1+ :end i))
  (nil 1 1 1 1 1 1 1))

(deftest find-if-not-vector.16
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp #(1 6 11 32 45 71 100) :key '1+ :end i :from-end t))
  (nil 1 1 11 11 45 71 71))

(deftest find-if-not-vector.17
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'evenp #(1 2 4 8 3 1 6 7) :start j :end i :key #'1-)))
  ((nil 2 2 2 2 2 2 2)
   (2 2 2 2 2 2 2)
   (4 4 4 4 4 4)
   (8 8 8 8 8)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

(deftest find-if-not-vector.18
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'evenp #(1 2 4 8 3 1 6 7) :start j :end i
		       :from-end t :key #'1+)))
  ((nil 2 4 8 8 8 6 6)
   (2 4 8 8 8 6 6)
   (4 8 8 8 6 6)
   (8 8 8 6 6)
   (nil nil 6 6)
   (nil 6 6)
   (6 6)
   (nil)))

;;; Tests for bit vectors

(deftest find-if-not-bit-vector.1
  (find-if-not #'identity #*)
  nil)

(deftest find-if-not-bit-vector.2
  (find-if-not #'null #*1)
  1)

(deftest find-if-not-bit-vector.3
  (find-if-not #'not #*0)
  0)

(deftest find-if-not-bit-vector.4
  (loop for i from 0 to 6
	collect (loop for j from i to 7
		      collect (find-if-not #'oddp #*0110110 :start i :end j)))
  ((nil 0 0 0 0 0 0 0)
   (nil nil nil 0 0 0 0)
   (nil nil 0 0 0 0)
   (nil 0 0 0 0)
   (nil nil nil 0)
   (nil nil 0)
   (nil 0)))

(deftest find-if-not-bit-vector.5
  (loop for i from 0 to 6
	collect (loop for j from i to 7
		      collect (find-if-not #'oddp #*0110110 :start i :end j
				       :from-end t)))
  ((nil 0 0 0 0 0 0 0)
   (nil nil nil 0 0 0 0)
   (nil nil 0 0 0 0)
   (nil 0 0 0 0)
   (nil nil nil 0)
   (nil nil 0)
   (nil 0)))

(deftest find-if-not-bit-vector.6
  (loop for i from 0 to 6
	collect (loop for j from i to 7
		      collect (find-if-not #'evenp #*0110110 :start i :end j
				       :from-end t :key #'1+)))
  ((nil 0 0 0 0 0 0 0)
   (nil nil nil 0 0 0 0)
   (nil nil 0 0 0 0)
   (nil 0 0 0 0)
   (nil nil nil 0)
   (nil nil 0)
   (nil 0)))

(deftest find-if-not-bit-vector.7
  (loop for i from 0 to 6
	collect (loop for j from i to 7
		      collect (find-if-not #'evenp #*0110110 :start i :end j
				       :key '1-)))
  ((nil 0 0 0 0 0 0 0)
   (nil nil nil 0 0 0 0)
   (nil nil 0 0 0 0)
   (nil 0 0 0 0)
   (nil nil nil 0)
   (nil nil 0)
   (nil 0)))

;;; Tests for strings

(deftest find-if-not-string.1
  (find-if-not #'identity "")
  nil)

(deftest find-if-not-string.2
  (find-if-not #'null "a")
  #\a)

(deftest find-if-not-string.2a
  (find-if-not 'null "a")
  #\a)

(deftest find-if-not-string.3
  (find-if-not #'odddigitp "12483167")
  #\2)
  
(deftest find-if-not-string.3a
  (find-if-not #'oddp "12483167" :key #'(lambda (c) (read-from-string (string c))))
  #\2)

(deftest find-if-not-string.4
  (find-if-not #'odddigitp "12483167" :from-end t)
  #\6)

(deftest find-if-not-string.5
  (loop for i from 0 to 7 collect
	(find-if-not #'odddigitp "12483167" :start i))
  (#\2 #\2 #\4 #\8 #\6 #\6 #\6 nil))

(deftest find-if-not-string.6
  (loop for i from 0 to 7 collect
	(find-if-not #'odddigitp "12483167" :start i :end nil))
  (#\2 #\2 #\4 #\8 #\6 #\6 #\6 nil))

(deftest find-if-not-string.7
  (loop for i from 0 to 7 collect
	(find-if-not #'odddigitp "12483167" :start i :from-end t))
  (#\6 #\6 #\6 #\6 #\6 #\6 #\6 nil))

(deftest find-if-not-string.8
  (loop for i from 0 to 7 collect
	(find-if-not #'odddigitp "12483167" :start i :end nil :from-end t))
  (#\6 #\6 #\6 #\6 #\6 #\6 #\6 nil))

(deftest find-if-not-string.9
  (loop for i from 0 to 8 collect
	(find-if-not #'odddigitp "12483167" :end i))
  (nil nil #\2 #\2 #\2 #\2 #\2 #\2 #\2))

(deftest find-if-not-string.10
  (loop for i from 0 to 8 collect
	(find-if-not #'odddigitp "12483167" :end i :from-end t))
  (nil nil #\2 #\4 #\8 #\8 #\8 #\6 #\6))

(deftest find-if-not-string.11
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'odddigitp "12483167" :start j :end i)))
  ((nil #\2 #\2 #\2 #\2 #\2 #\2 #\2)
   (#\2 #\2 #\2 #\2 #\2 #\2 #\2)
   (#\4 #\4 #\4 #\4 #\4 #\4)
   (#\8 #\8 #\8 #\8 #\8)
   (nil nil #\6 #\6)
   (nil #\6 #\6)
   (#\6 #\6)
   (nil)))

(deftest find-if-not-string.12
  (loop for j from 0 to 7
	collect
	(loop for i from (1+ j) to 8 collect
	      (find-if-not #'odddigitp "12483167" :start j :end i
		       :from-end t)))
  ((nil #\2 #\4 #\8 #\8 #\8 #\6 #\6)
   (#\2 #\4 #\8 #\8 #\8 #\6 #\6)
   (#\4 #\8 #\8 #\8 #\6 #\6)
   (#\8 #\8 #\8 #\6 #\6)
   (nil nil #\6 #\6)
   (nil #\6 #\6)
   (#\6 #\6)
   (nil)))

(deftest find-if-not-string.13
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :start i))
  (#\4 #\4 #\8 #\8 #\8 #\6 #\6))

(deftest find-if-not-string.14
  (loop for i from 0 to 6
	collect
	(find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :start i :from-end t))
  (#\6 #\6 #\6 #\6 #\6 #\6 #\6))

(deftest find-if-not-string.15
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :end i))
  (nil nil #\4 #\4 #\4 #\4 #\4 #\4))

(deftest find-if-not-string.16
  (loop for i from 0 to 7
	collect
	(find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :end i :from-end t))
  (nil nil #\4 #\4 #\4 #\8 #\8 #\6))

(deftest find-if-not-string.17
  (loop for j from 0 to 6
	collect
	(loop for i from (1+ j) to 7 collect
	      (find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :start j :end i)))
  ((nil #\4 #\4 #\4 #\4 #\4 #\4)
   (#\4 #\4 #\4 #\4 #\4 #\4)
   (nil nil #\8 #\8 #\8)
   (nil #\8 #\8 #\8)
   (#\8 #\8 #\8)
   (nil #\6)
   (#\6)))  

(deftest find-if-not-string.18
  (loop for j from 0 to 6
	collect
	(loop for i from (1+ j) to 7 collect
	      (find-if-not #'oddp "1473816"
		 :key (compose #'read-from-string #'string)
		 :start j :end i
		 :from-end t)))
  ((nil #\4 #\4 #\4 #\8 #\8 #\6)
   (#\4 #\4 #\4 #\8 #\8 #\6)
   (nil nil #\8 #\8 #\6)
   (nil #\8 #\8 #\6)
   (#\8 #\8 #\6)
   (nil #\6)
   (#\6)))

;;; Error tests

(deftest find-if-not-error.1
  (handler-case (find-if-not #'null 'b)
		(type-error () :type-error)
		(error (c) c))
  :type-error)

(deftest find-if-not-error.2
  (handler-case (find-if-not #'identity 10)
		(type-error () :type-error)
		(error (c) c))
  :type-error)

(deftest find-if-not-error.3
  (handler-case (find-if-not '1+ 1.4)
		(type-error () :type-error)
		(error (c) c))
  :type-error)

(deftest find-if-not-error.4
  (locally (declare (optimize (safety 3)))
	   (handler-case (find-if-not 'identity '(a b c . d))
			 (type-error () :type-error)))
  :type-error)


		

