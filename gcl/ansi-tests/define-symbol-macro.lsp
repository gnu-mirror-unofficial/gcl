;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Sun Apr 20 12:55:05 2003
;;;; Contains: Tests of DEFINE-SYMBOL-MACRO

(in-package :cl-test)

(deftest define-symbol-macro.error.1
  (classify-error (funcall (macro-function 'define-symbol-macro)))
  program-error)

(deftest define-symbol-macro.error.2
  (classify-error (funcall (macro-function 'define-symbol-macro)
			   '(define-symbol-macro
			      nonexistent-symbol-macro nil)))
  program-error)

(deftest define-symbol-macro.error.3
  (classify-error (funcall (macro-function 'define-symbol-macro)
			   '(define-symbol-macro
			      nonexistent-symbol-macro nil)
			   nil nil))
  program-error)
