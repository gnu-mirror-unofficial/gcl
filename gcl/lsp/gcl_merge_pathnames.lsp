(in-package :si)

(defun merge-pathnames (p &optional (def *default-pathname-defaults*) (def-v :newest)
			  &aux dflt (pn (pathname p))(def-pn (pathname def)))
  (declare (optimize (safety 1)))
  (check-type p pathname-designator)
  (check-type def pathname-designator)
  (check-type def-v (or null (eql :newest) seqind))
  (labels ((def (x) (when x (setq dflt t) x)))
    (let ((h (or (pathname-host pn) (def (pathname-host def-pn))))
	  (c (or (pathname-device pn) (def (pathname-device def-pn))))
	  (d (let ((d (pathname-directory pn))(defd (pathname-directory def-pn)))
	       (or (def (when (and defd (eq (car d) :relative)) (append defd (cdr d)))) d (def defd))))
	  (n (or (pathname-name pn) (def (pathname-name def-pn))))
	  (p (or (pathname-type pn) (def (pathname-type def-pn))))
	  (v (or (pathname-version pn) (def (unless (pathname-name pn) (pathname-version def-pn))) (def def-v))))
      (if dflt
	  (make-pathname :host h :device c :directory d :name n :type p :version v)
	pn))))