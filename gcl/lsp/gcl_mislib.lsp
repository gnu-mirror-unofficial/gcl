;; -*-Lisp-*-
;; Copyright (C) 1994 M. Hagiya, W. Schelter, T. Yuasa

;; This file is part of GNU Common Lisp, herein referred to as GCL
;;
;; GCL is free software; you can redistribute it and/or modify it under
;;  the terms of the GNU LIBRARY GENERAL PUBLIC LICENSE as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.
;; 
;; GCL is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Library General Public 
;; License for more details.
;; 
;; You should have received a copy of the GNU Library General Public License 
;; along with GCL; see the file COPYING.  If not, write to the Free Software
;; Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.


;;;; This file is IMPLEMENTATION-DEPENDENT.


(in-package 'lisp)


(export 'time)
(export '(function-lambda-expression
	  reset-sys-paths decode-universal-time
	  encode-universal-time compile-file-pathname complement constantly))


(in-package 'system)


;(proclaim '(optimize (safety 2) (space 3)))


(defmacro time (form)
  (declare (optimize (safety 1)))
  (let ((real-start (gensym)) (real-end (gensym)) (gbc-time-start (gensym))
	(gbc-time (gensym)) (x (gensym)) (run-start (gensym)) (run-end (gensym))
	(child-run-start (gensym)) (child-run-end (gensym)))
  `(let (,real-start ,real-end (,gbc-time-start (si::gbc-time)) ,gbc-time ,x)
     (setq ,real-start (get-internal-real-time))
     (multiple-value-bind (,run-start ,child-run-start) (get-internal-run-time)
       (si::gbc-time 0)
       (setq ,x (multiple-value-list ,form))
       (setq ,gbc-time (si::gbc-time))
       (si::gbc-time (+ ,gbc-time-start ,gbc-time))
       (multiple-value-bind (,run-end ,child-run-end) (get-internal-run-time)
	 (setq ,real-end (get-internal-real-time))
	 (fresh-line *trace-output*)
	 (format *trace-output*
		 "real time       : ~10,3F secs~%~
                  run-gbc time    : ~10,3F secs~%~
                  child run time  : ~10,3F secs~%~
                  gbc time        : ~10,3F secs~%"
		 (/ (- ,real-end ,real-start) internal-time-units-per-second)
		 (/ (- (- ,run-end ,run-start) ,gbc-time) internal-time-units-per-second)
		 (/ (- ,child-run-end ,child-run-start) internal-time-units-per-second)
		 (/ ,gbc-time internal-time-units-per-second))))
       (values-list ,x))))


(defconstant month-days-list '(31 28 31 30 31 30 31 31 30 31 30 31))
(defconstant seconds-per-day #.(* 24 3600))

(defun leap-year-p (y)
  (and (zerop (mod y 4))
       (or (not (zerop (mod y 100))) (zerop (mod y 400)))))

(defun number-of-days-from-1900 (y)
  (let ((y1 (1- y)))
    (+ (* (- y 1900) 365)
       (floor y1 4) (- (floor y1 100)) (floor y1 400)
       -460)))

(defun decode-universal-time (ut &optional (tz *default-time-zone*))
  (declare (optimize (safety 1)))
  (let (sec min h d m y dow)
    (decf ut (* tz 3600))
    (multiple-value-setq (d ut) (floor ut seconds-per-day))
    (setq dow (mod d 7))
    (multiple-value-setq (h ut) (floor ut 3600))
    (multiple-value-setq (min sec) (floor ut 60))
    (setq y (+ 1900 (floor d 366)))  ; Guess!
    (do ((x))
        ((< (setq x (- d (number-of-days-from-1900 y)))
            (if (leap-year-p y) 366 365))
         (setq d (1+ x)))
      (incf y))
    (when (leap-year-p y)
          (when (= d 60)
                (return-from decode-universal-time
                             (values sec min h 29 2 y dow nil tz)))
          (when (> d 60) (decf d)))
    (do ((l month-days-list (cdr l)))
        ((<= d (car l)) (setq m (- 13 (length l))))
      (decf d (car l)))
    (values sec min h d m y dow nil tz)))

(defun encode-universal-time (sec min h d m y
                              &optional (tz *default-time-zone*))
  (declare (optimize (safety 1)))
  (incf h tz)
  (when (<= 0 y 99)
        (multiple-value-bind (sec min h d m y1 dow dstp tz)
            (get-decoded-time)
          (declare (ignore sec min h d m dow dstp tz))
          (incf y (- y1 (mod y1 100)))
          (cond ((< (- y y1) -50) (incf y 100))
                ((>= (- y y1) 50) (decf y 100)))))
  (unless (and (leap-year-p y) (> m 2)) (decf d 1))
  (+ (* (apply #'+ d (number-of-days-from-1900 y)
               (butlast month-days-list (- 13 m)))
        seconds-per-day)
     (* h 3600) (* min 60) sec))

; Courtesy Paul Dietz
(defun compile-file-pathname (pathname)
  (declare (optimize (safety 1)))
  (make-pathname :defaults pathname :type "o"))
(defun constantly (x)
  (declare (optimize (safety 1)))
  (lambda (&rest args)
    (declare (ignore args) (dynamic-extent args))
    x))
(defun complement (fn)
  (declare (optimize (safety 1)))
  (lambda (&rest args) (not (apply fn args))))

(defun default-system-banner ()
  (let (gpled-modules)
    (dolist (l '(:unexec :bfd :readline))
      (when (member l *features*)
	(push l gpled-modules)))
    (format nil "GCL (GNU Common Lisp)  ~a.~a.~a ~a  ~a  ~a~%~a~%~a ~a~%~a~%~a~%~%~a~%" 
	    *gcl-major-version* *gcl-minor-version* *gcl-extra-version*
	    (if (member :ansi-cl *features*) "ANSI" "CLtL1")
	    (if (member :gprof *features*) "profiling" "")
	    (si::gcl-compile-time)
	    "Source License: LGPL(gcl,gmp,pargcl), GPL(unexec,bfd)"
	    "Binary License: "
	    (if gpled-modules (format nil "GPL due to GPL'ed components: ~a" gpled-modules)
	      "LGPL")
	    "Modifications of this banner must retain notice of a compatible license"
	    "Dedicated to the memory of W. Schelter"
	    "Use (help) to get some basic information on how to use GCL.")))

 (defun lisp-implementation-version nil
   (declare (optimize (safety 1)))
   (format nil "GCL ~a.~a.~a"
	   si::*gcl-major-version*
	   si::*gcl-minor-version*
	   si::*gcl-extra-version*))

(defun objlt (x y)
  (declare (object x y))
  (let ((x (si::address x)) (y (si::address y)))
    (declare (fixnum x y))
    (if (< y 0)
	(if (< x 0) (< x y) t)
      (if (< x 0) nil (< x y)))))

(defun reset-sys-paths (s)
  (declare (string s))
  (setq si::*lib-directory* s)
  (setq si::*system-directory* (si::string-concatenate s "unixport/"))
  (let (nl)
    (dolist (l '("cmpnew/" "gcl-tk/" "lsp/"))
      (push (si::string-concatenate s l) nl))
    (setq si::*load-path* nl))
  nil)

(defun function-lambda-expression (x) 
  (if (typep x 'interpreted-function) 
      (let* ((x (si::interpreted-function-lambda x)))
	(case (car x)
	      (lambda (values x nil nil))
	      (lambda-block (values (cons 'lambda (cddr x))  nil (cadr x)))
	      (lambda-closure (values (cons 'lambda (cddr (cddr x)))  (not (not (cadr x)))  nil))
	      (lambda-block-closure (values (cons 'lambda (cdr (cddr (cddr x))))  (not (not (cadr x))) (fifth x)))
	      (otherwise (values nil t nil))))
    (values nil t nil)))

(defun heaprep nil
  
  (let ((f (list
	    "word size:            ~a bits~%"
	    "page size:            ~a bytes~%"
	    "heap start:           0x~x~%"
	    "heap max :            0x~x~%"
	    "shared library start: 0x~x~%"
	    "cstack start:         0x~x~%"
	    "cstack mark offset:   ~a bytes~%"
	    "cstack direction:     ~[downward~;upward~;~]~%"
	    "cstack alignment:     ~a bytes~%"
	    "cstack max:           ~a bytes~%"
	    "immfix start:         0x~x~%"
	    "immfix size:          ~a fixnums~%"))
	(v (multiple-value-list (si::heap-report))))
    
    (do ((v v (cdr v)) (f f (cdr f))) ((not (car v)))
	(format t (car f) 
		(let ((x (car v))) 
		  (cond ((>= x 0) x) 
			((+ x (* 2 (1+ most-positive-fixnum))))))))))

(defun room (&optional x)
  (declare (ignore x))
  (let ((l (multiple-value-list (si:room-report)))
        maxpage holepage leftpage ncbpage maxcbpage ncb cbgbccount npage
        rbused rbfree nrbpage rbgbccount
        info-list link-alist)
    (setq maxpage (nth 0 l) leftpage (nth 1 l)
          ncbpage (nth 2 l) maxcbpage (nth 3 l) ncb (nth 4 l)
          cbgbccount (nth 5 l)
          holepage (nth 6 l)
          rbused (nth 7 l) rbfree (nth 8 l) nrbpage (nth 9 l)
          rbgbccount (nth 10 l)
          l (nthcdr 11 l))
    (do ((l l (nthcdr 7 l))
         (i 0 (+ i (if (nth 3 l) (nth 3 l) 0))))
        ((null l) (setq npage i))
      (let ((typename (intern (nth 0 l)))
            (nused (nth 1 l))
            (nfree (nth 2 l))
            (npage (nth 3 l))
            (maxpage (nth 4 l))
            (gbccount (nth 5 l))
            (ws (nth 6 l)))
        (if nused
            (push (list typename ws npage maxpage
                        (if (zerop (+ nused nfree))
                            0
                            (/ nused 0.01 (+ nused nfree)))
                        (if (zerop gbccount) nil gbccount))
                  info-list)
            (let* ((nfree (intern nfree))
		   (a (assoc nfree link-alist)))
                 (if a
                     (nconc a (list typename))
                     (push (list nfree typename)
                           link-alist))))))
    (terpri)
    (format t "~@[~2A~]~8@A/~A~14T~6@A%~@[~8@A~]~30T~{~A~^ ~}~%~%" "WS" "UP" "MP" "FI" "GC" '("TYPES"))
    (dolist (info (reverse info-list))
      (apply #'format t "~@[~2D~]~8D/~D~14T~6,1F%~@[~8D~]~30T~{~A~^ ~}"
             (append (cdr info)
                     (if  (assoc (car info) link-alist)
                          (list (assoc (car info) link-alist))
                          (list (list (car info))))))
      (terpri)
      )
    (terpri)
    (format t "~10D/~D~19T~@[~8D~]~30Tcontiguous (~D blocks)~%"
            ncbpage maxcbpage (if (zerop cbgbccount) nil cbgbccount) ncb)
    (format t "~11T~D~30Thole~%" holepage)
    (format t "~11T~D~14T~6,1F%~@[~8D~]~30Trelocatable~%~%"
            nrbpage (/ rbused 0.01 (+ rbused rbfree))
            (if (zerop rbgbccount) nil rbgbccount))
    (format t "~10D pages for cells~%" npage)
    (format t "~10D total pages~%" (+ npage ncbpage holepage nrbpage))
    (format t "~10D pages available~%" leftpage)
    (format t "~10D pages in heap but not gc'd + pages needed for gc marking~%"
	    (- maxpage (+ npage ncbpage holepage nrbpage leftpage)))
    (format t "~10D maximum pages~%" maxpage)
    (values)
    )
  (format t "~%~%")
  (format t "Key:~%~%WS: words per struct~%UP: allocated pages~%MP: maximum pages~%FI: fraction of cells in use on allocated pages~%GC: number of gc triggers allocating this type~%~%")
  (heaprep)
  (values))
