;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Sun Jul 24 19:25:39 2005
;;;; Contains: Aux file for BIT-* tests

(in-package :cl-test)

(defun bit-random-test-fn (bit-fn log-fn &key (reps 5000) (maxlen 256))
  (assert (typep maxlen '(integer 1)))
  (assert (typep reps 'unsigned-byte))
  (loop for len = (random maxlen)
	for twos = (make-list len :initial-element 2)
	for v1 = (map 'bit-vector #'random twos)
	for v2 = (map 'bit-vector #'random twos)
	for result = (funcall bit-fn v1 v2)
	repeat reps
	unless (and (= (length result) len)
		    (every #'(lambda (result-bit v1-bit v2-bit)
			       (= result-bit (logand 1 (funcall log-fn v1-bit v2-bit))))
			   result v1 v2))
     collect (list len v1 v2 result)))

(defun bit-random-test-fn1 (bit-fn log-fn &key (reps 5000) (maxlen 256))
  (assert (typep maxlen '(integer 1)))
  (assert (typep reps 'unsigned-byte))
  (loop
     for len = (random maxlen)
     for twos = (make-list len :initial-element 2)
     for vb = (make-array maxlen :element-type 'bit :initial-contents (mapcar 'random twos))
     for v1 = (make-array len :element-type 'bit :displaced-to vb :displaced-index-offset (random (- maxlen len)))
     for v2 = (make-array len :element-type 'bit :displaced-to vb :displaced-index-offset (random (- maxlen len)))
     for result = (funcall bit-fn v1 v2)
     repeat reps
     unless (and (= (length result) len)
		 (every #'(lambda (result-bit v1-bit v2-bit)
			    (= result-bit (logand 1 (funcall log-fn v1-bit v2-bit))))
			result v1 v2))
     collect (progn (print (setq lll (list len v1 v2 result))) (break))))


(defun bit-random-test-fn2 (bit-fn log-fn &key (reps 5000) (maxlen 256))
  (assert (typep maxlen '(integer 1)))
  (assert (typep reps 'unsigned-byte))
  (loop
     for len = (random maxlen)
     for twos = (make-list len :initial-element 2)
     for vb = (make-array maxlen :element-type 'bit :initial-contents (mapcar 'random twos))
     for v1 = (make-array len :element-type 'bit :displaced-to vb :displaced-index-offset (random (- maxlen len)))
     for v2 = (make-array len :element-type 'bit :displaced-to vb :displaced-index-offset (random (- maxlen len)))
     for vb1 = (make-array maxlen :element-type 'bit)
     for v3 = (make-array len :element-type 'bit :displaced-to vb1 :displaced-index-offset (random (- maxlen len)))
     for result = (funcall bit-fn v1 v2 v3)
     for correct = (map 'bit-vector log-fn v1 v2)
     for miss = (mismatch result correct)
     repeat reps
     when miss
     return (list v1 v2 result correct miss len (length result))))

(defun bmm (a b c)
  (let ((i -1))
    (map nil (lambda (a b c)
	       (incf i)
	       (unless (eql (logand a b) c)
		 (return-from bmm i))) a b c)))
