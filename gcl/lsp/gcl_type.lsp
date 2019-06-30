(in-package :si)

(export '(cmp-norm-tp
	  cmp-unnorm-tp
	  type-and type-or1 type>= type<= tp-not tp-and tp-or
	  atomic-tp tp-bnds object-tp
	  cmpt t-to-nil returs-exactly funcallable-symbol-function
	  infer-tp cnum creal long
	  sharp-t-reader +useful-types-alist+ +useful-type-list+))

(defun sharp-t-reader (stream subchar arg)
  (declare (ignore subchar arg))
  (let ((tp (cmp-norm-tp (read stream))))
    (if (constantp tp) tp `',tp)))
(set-dispatch-macro-character #\# #\t 'sharp-t-reader)


(defmacro cmpt (tp)  `(and (consp ,tp) (member (car ,tp) '(returns-exactly values))))

(defun t-to-nil (x) (unless (eq x t) x))
(setf (get 't-to-nil 'cmp-inline) t)

(deftype cnum nil `(or fixnum float fcomplex dcomplex))
(deftype creal nil `(and real cnum))
(deftype long nil 'fixnum)


(defconstant +vtps+ (mapcar (lambda (x) (list x (intern (string-concatenate "VECTOR-"  (string x))))) +array-types+))
(defconstant +atps+ (mapcar (lambda (x) (list x (intern (string-concatenate "ARRAY-"   (string x))))) +array-types+))
(defconstant +vtpsn+ `((nil vector-nil) ,@+vtps+))
(defconstant +atpsn+ `((nil array-nil) ,@+atps+))


#.`(progn
     ,@(mapcar (lambda (x &aux (s (cadr x))(x (car x))) 
		 `(deftype ,s (&optional d) `(vector ,',x ,d)))
	       +vtpsn+)
     ,@(mapcar (lambda (x &aux (s (cadr x))(x (car x))) 
		 `(deftype ,s (&optional d) `(and (array ,',x ,d) (not vector))))
	       +atpsn+))


(defun real-rep (x)
  (case x (integer 1) (ratio 1/2) (short-float 1.0s0) (long-float 1.0)))

(defun complex-rep (x)
  (let* ((s (symbolp x))
	 (r (real-rep (if s x (car x))))
	 (i (real-rep (if s x (cadr x)))))
    (complex r i)))


(defconstant +r+ `((immfix 1) 
		   (bfix  most-positive-fixnum)
		   (bignum (1+ most-positive-fixnum))
		   (ratio 1/2)
		   (short-float 1.0s0) 
		   (long-float 1.0)
		   ,@(mapcar (lambda (x &aux (v (complex-rep (car x))))
			       `(,(cadr x) ,v)) +ctps+)
		   (standard-char #\a)
		   (non-standard-base-char #\Return)
		   (structure (make-dummy-structure)) 
		   (std-instance (set-d-tt 1 (make-dummy-structure))) 
		   (non-logical-pathname (init-pathname nil nil nil nil nil nil ""))
		   (logical-pathname (set-d-tt 1 (init-pathname nil nil nil nil nil nil "")))
		   (hash-table-eq (make-hash-table :test 'eq))
		   (hash-table-eql (make-hash-table :test 'eql))
		   (hash-table-equal (make-hash-table :test 'equal))
		   (hash-table-equalp (make-hash-table :test 'equalp))
		   (package *package*)
		   (file-input-stream (open-int "/dev/null" :input 'character nil nil nil nil :default))
		   (file-output-stream (open-int "/dev/null" :output 'character nil nil nil nil :default))
		   (file-io-stream (open-int "/dev/null" :io 'character nil nil nil nil :default))
		   (file-probe-stream (open-int "/dev/null" :probe 'character nil nil nil nil :default))
		   (file-synonym-stream (make-synonym-stream '*standard-output*))
		   (non-file-synonym-stream *standard-input*)
		   (broadcast-stream (make-broadcast-stream))
		   (concatenated-stream (make-concatenated-stream))
		   (two-way-stream *terminal-io*)
		   (echo-stream (make-echo-stream *standard-output* *standard-output*))
		   (string-input-stream (make-string-input-stream ""))
		   (string-output-stream (make-string-output-stream));FIXME user defined, socket
		   (random-state (make-random-state)) 
		   (readtable (standard-readtable)) 
		   (non-standard-generic-compiled-function (function eq))
		   (non-standard-generic-interpreted-function (set-d-tt 2 (lambda nil nil)))
		   (standard-generic-compiled-function (set-d-tt 1 (lambda nil nil)))
		   (standard-generic-interpreted-function (set-d-tt 3 (lambda nil nil)))
		   ,@(mapcar (lambda (x) `(,(cadr x) (make-vector ',(car x) 1 nil nil nil 0 nil nil))) +vtps+)
		   ,@(mapcar (lambda (x) `(,(cadr x) (make-array1 ',(car x) nil nil nil 0 '(1 1) nil))) +atps+)
                   (spice (alloc-spice))
		   (cons '(1))
		   (keyword :a)
		   (null nil)
		   (true t)
		   (gsym 'a)))

(defconstant +btp-types+
  (lremove
   nil
   (mapcar
    (let (y)
      (lambda (x &aux (z y))
	(setq y (car (resolve-type (list 'or x y))))
	(car (resolve-type `(and ,x (not ,z))))))
    `((unsigned-byte 0)
      ,@(butlast
	 (mapcan (lambda (n &aux (m (1- n)))
		   (list `(unsigned-byte ,m) `(signed-byte ,n) `(unsigned-byte ,n)))
		 '(2 4 8 16 28 32 62 64)))
      (and bignum (integer * -1))
      (and bignum (integer 0))
      ,@(mapcan (lambda (x)
		  (mapcar (lambda (y) (cons x y))
			  '((* (-1))(-1 -1) ((-1) (0)) (0 0) ((0) (1)) (1 1) ((1) *))))
		'(ratio short-float long-float))
      proper-cons improper-cons (vector nil) (array nil);FIXME
      ,@(mapcar 'car +r+)))))

(defconstant +btp-length+ (length +btp-types+))

(defun make-btp (&optional (i 0)) (make-vector 'bit +btp-length+ nil nil nil 0 nil i))

(defvar *btps* (let ((i -1))
		 (mapcar (lambda (x &aux (z (make-btp)))
			   (setf (sbit z (incf i)) 1)
			   (list x (nprocess-type (normalize-type x)) z))
			 +btp-types+)))

(defvar *btpa* (let ((i -1)(z (make-vector t +btp-length+ nil nil nil 0 nil nil)))
		 (mapc (lambda (x) (setf (aref z (incf i)) x)) *btps*)
		 z))


(defvar *k-bv* (let ((i -1))
		 (lreduce (lambda (xx x &aux (z (assoc (caaar (cadr x)) xx)))
			    (unless z
			      (push (setq z (cons (caaar (cadr x)) (make-btp))) xx))
			  (setf (sbit (cdr z) (incf i)) 1)
			  xx) *btps* :initial-value nil)))
(defvar *nil-tp* (make-btp))
(defvar *t-tp* (make-btp 1))

(unless (fboundp 'logandc2) (defun logandc2 (x y) (boole boole-andc2 x y)))

(defconstant +bit-words+ (ceiling +btp-length+ fixnum-length))


(defun copy-btp (tp &aux (n (make-btp)))
  (dotimes (i +bit-words+ n)
    (*fixnum (c-array-self n) i t (*fixnum (c-array-self tp) i nil nil))))

(defun copy-tp (x m tp d)
  (cond ((unless (eql d 1)  (equal x *nil-tp*)) nil)
	((unless (eql d -1) (equal m *t-tp*))     t)
	((equal m x) (copy-btp x))
	(tp (list (copy-btp x) (copy-btp m) tp))))

(defun new-tp4 (k x m d z &aux (nz (unless (eql d -1) (ntp-not z)))(j 0));nz
  (dotimes (i +btp-length+ (progn  (unless (equal x m) z)));(print (list j 'ntp-and-calls d))
    (unless (zerop (sbit k i))
      (let ((a (aref *btpa* i)))
	(cond ((unless (eql d  1) (incf j) (eq +tp-nil+ (ntp-and (cadr a)  z)))
	       (setf (sbit x i) 0))
	      ((unless (eql d -1) (incf j) (eq +tp-nil+ (ntp-and (cadr a) nz)))
	       (setf (sbit m i) 1)))))))

(let ((p1 (make-btp))(p2 (make-btp)))
  (defun tp-mask (m1 x1 &optional (m2 nil m2p)(x2 nil x2p))
    (bit-xor m1 x1 p1)
    (if x2p
	(bit-and p1 (bit-xor m2 x2 p2) t)
      p1)))


#.`(defun atomic-type (tp)
     (when (consp tp)
       (case (car tp)
	     (,+range-types+
	      (let* ((d (cdr tp))(dd (cadr d))(da (car d)))
		(and (numberp da) (numberp dd) (eql da dd) d)))
	     ((member eql) (let ((d (cdr tp))) (unless (cdr d) d))))))

(defun singleton-listp (x) (unless (cdr x) (unless (eq t (car x)) x)))

(defun singleton-rangep (x) (when (singleton-listp x) (when (eql (caar x) (cdar x)) (car x))))

#.`(defun singleton-kingdomp (x);sync with member-ld
     (case (car x)
	   ((proper-cons improper-cons)
	    (let ((x (cddar (singleton-listp (cdr x)))))
	      (when (car x) x)))
	   (,+range-types+ (singleton-rangep (cdr x)))
	   (null '(nil));impossible if in +btp-types+
	   (true (cdr x));impossible if in +btp-types+
	   ((structure std-instance)
	    (when (singleton-listp (cdr x)) (unless (s-class-p (cadr x)) (cdr x))))
	   (,(mapcar 'cadr +atps+) (when (singleton-listp (cdr x)) (when (arrayp (cadr x)) (cdr x))))
	   (otherwise (singleton-listp (cdr x)))));FIXME others, array....

(defun atomic-ntp (ntp)
  (unless (cadr ntp)
    (when (singleton-listp (car ntp))
      (singleton-kingdomp (caar ntp)))))

(defun one-bit-btp (x &aux n)
  (dotimes (i +bit-words+ n)
    (let* ((y (*fixnum (c-array-self x) i nil nil))
	   (y (if (eql i #.(1- +bit-words+))
		  (& y #.(let ((z (<< 1 (mod +btp-length+ fixnum-length))))
			   (if (minusp z) most-positive-fixnum (1- z))))
		y)))
      (unless (zerop y)
	(let* ((l (1- (integer-length y)))(l (if (minusp y) (1+ l) l)))
	  (if (unless n (eql y (<< 1 l)))
	      (setq n (+ (* i fixnum-length) l))
	    (return nil)))))))

(defun atomic-tp (tp)
  (unless (or (eq tp '*) (when (listp tp) (member (car tp) '(returns-exactly values))));FIXME
    (when tp
      (unless (eq tp t)
	(let ((i (one-bit-btp (xtp tp))))
	  (when i
	    (if (atom tp)
		(cadr (assoc i *atomic-btp-alist*))
	      (atomic-ntp (caddr tp)))))))))

#.`(defun object-index (x)
     (etypecase x
      ,@(let ((i -1)) (mapcar (lambda (x) `(,(car x) ,(incf i))) *btps*))))


(defvar *cmp-verbose* nil)

(defvar *atomic-btp-alist* (let ((i -1))
		     (mapcan (lambda (x &aux (z (incf i)))
			       (when (atomic-type x)
				 (list (list z (cons (cadr x) (caddr x))))))
			     +btp-types+)))

(defun object-tp1 (x)
  (when *cmp-verbose* (print (list 'object-type x)))
  (if (isnan x)
      (cmp-norm-tp (car (member x '(long-float short-float) :test 'typep)));FIXME
    (let* ((i (object-index x))(z (caddr (svref *btpa* i))))
      (if (assoc i *atomic-btp-alist*) z
	(list z *nil-tp* (nprocess-type (normalize-type `(member ,x))))))))

(defvar *atomic-type-hash* (make-hash-table :test 'eql))

(let ((package-list (mapcar 'find-package '(:si :cl :keyword))))
  (defun hashable-atomp (thing)
    (cond ((integerp thing) (<= -512 thing 512))
	  ((symbolp thing)
	   (member (symbol-package thing) package-list)))))

(defun object-tp (x &aux (h (hashable-atomp x)))
  (multiple-value-bind
   (f r) (when h (gethash x *atomic-type-hash*))
   (if r f
     (let ((z (object-tp1 x)))
       (when h (setf (gethash x *atomic-type-hash*) z))
       z))))


(let ((m (make-btp))(x (make-btp)))
  (defun comp-tp0 (type &aux (z (nprocess-type (normalize-type type))))

    (when *cmp-verbose* (print (list 'computing type)))

    (bit-xor m m t)
    (bit-xor x x t)

    (when (cadr z)
      (bit-not m t)
      (bit-not x t))

    (dolist (k (car z))
      (let ((a (cdr (assoc (car k) *k-bv*))))
	(if (cadr z)
	    (bit-andc2 m a t)
	  (bit-ior x a t))))

    (copy-tp x m (new-tp4 (tp-mask m x) x m 0 z) 0)))

(defun comp-tp (type &aux (a (atomic-type type)))
  (if a (object-tp (car a)) (comp-tp0 type)))

(defun btp-count (x &aux (j 0))
  (dotimes (i +bit-words+ j)
    (let* ((y (*fixnum (c-array-self x) i nil nil))
	   (q (logcount y)))
      (incf j (if (minusp y) (- fixnum-length q) q)))))

;(defun btp-count (x) (count-if-not 'zerop x))

(defun btp-type2 (x &aux (z +tp-t+))
  (dotimes (i +btp-length+ (ntp-not z))
    (unless (zerop (sbit x i))
      (setq z (ntp-and (ntp-not (cadr (aref *btpa* i))) z)))))

(defun btp-type1 (x)
  (car (nreconstruct-type (btp-type2 x))))

(let ((nn (make-btp)))
  (defun btp-type (x &aux (n (>= (btp-count x) #.(ash +btp-length+ -1))))
    (if n `(not ,(btp-type1 (bit-not x nn))) (btp-type1 x))))

;(defun btp-type (x) (btp-type1 x))


(defun tp-type (x)
  (when x
    (cond ((eq x t))
	  ((atom x) (btp-type x))
	  ((car (nreconstruct-type (caddr x)))))))

(defun num-bnd (x) (if (listp x) (car x) x))

(defun max-bnd (x y op &aux (nx (num-bnd x)) (ny (num-bnd y)))
  (cond ((or (eq x '*) (eq y '*)) '*)
	((eql nx ny) (if (atom x) x y))
	((funcall op nx ny) x)
	(y)))

(defun rng-bnd2 (y x &aux (mx (car x))(xx (cdr x))(my (car y))(xy (cdr y)))
  (let ((rm (max-bnd mx my '<))(rx (max-bnd xx xy '>)))
    (cond ((and (eql rm mx) (eql rx xx)) x)
	  ((and (eql rm my) (eql rx xy)) y)
	  ((cons rm rx)))))

(defun rng-bnd (y x) (if y (rng-bnd2 y x) x))

(defvar *btp-bnds*
  (let ((i -1))
    (mapcan (lambda (x)
	      (incf i)
	      (when (member (when (listp x) (car x)) +range-types+)
		`((,i ,(cons (cadr x) (caddr x))))))
	    +btp-types+)))

(eval-when
 (compile load eval)
 (defun slow-sort (fn key)
   (do* ((x nil (lreduce (lambda (y x &aux (kx (funcall key x)))
			   (if (eq (max-bnd kx (funcall key y) fn) kx) x y))
			 r))
	 (r *btp-bnds* (lremove x r))
	 (n nil (cons x n)))
	((not r) (nreverse n)))))


(defvar *btp-bnds<* (slow-sort '< 'caadr))

(defvar *btp-bnds>* (slow-sort '> 'cdadr))

(defun btp-bnds< (x)
  (dolist (l *btp-bnds<*)
    (unless (zerop (sbit x (car l)))
      (return (caadr l)))))

(defun btp-bnds> (x)
  (dolist (l *btp-bnds>*)
    (unless (zerop (sbit x (car l)))
      (return (cdadr l)))))

(defun btp-bnds (z)
  (let ((m (btp-bnds< z))(x (btp-bnds> z)))
    (when (and m x) (cons m x))))

(defun ntp-bnds (x)
  (unless (cadr x)
    (lreduce (lambda (y x)
	       (lreduce 'rng-bnd
			(when (member (car x) +range-types+)
			  (if (eq (cadr x) t) (return-from ntp-bnds '(* . *))
			    (cdr x)))
			:initial-value y))
	     (car x) :initial-value nil)))

(defun tp-bnds (x)
  (when x
    (if (eq x t) '(* . *)
      (if (atom x) (btp-bnds x) (ntp-bnds (caddr x))))))

(defun xtp (tp) (if (listp tp) (car tp) tp))
(defun mtp (tp) (if (listp tp) (cadr tp) tp))

(defun ntp-op (op t1 t2)
  (ecase op
	 (and (ntp-and t1 t2))
	 (or (ntp-or t1 t2))))

(defun new-tp1 (op t1 t2 xp mp)
  (cond ;((atom t1) (break)(caddr t2));FIXME
	;((atom t2) (break)(caddr t1));FIXME
	((atom t1) (new-tp4 (tp-mask (pop t2) (pop t2)) xp mp (if (eq op 'and) -1 1)
			    (ntp-op op (btp-type2 t1) (car t2))))
	((atom t2) (new-tp4 (tp-mask (pop t1) (pop t1)) xp mp (if (eq op 'and) -1 1)
			    (ntp-op op (car t1) (btp-type2 t2))))
	((new-tp4 (tp-mask (pop t1) (pop t1) (pop t2) (pop t2)) xp mp (if (eq op 'and) -1 1)
		  (ntp-op op (car t1) (car t2))))))

(let ((xp (make-btp))(mp (make-btp)))
  (defun cmp-tp-and (t1 t2)
    (bit-and (xtp t1) (xtp t2) xp)
    (cond ((when (atom t1) (equal xp (xtp t2))) t2)
	  ((when (atom t2) (equal xp (xtp t1))) t1)
	  ((and (atom t1) (atom t2)) (copy-tp xp xp nil -1))
	  ((let ((type (new-tp1 'and t1 t2 xp (bit-and (mtp t1) (mtp t2) mp))))
	     (cond ((when (atom t1) (equal mp t1)) t1)
		   ((when (atom t2) (equal mp t2)) t2)
		   ((copy-tp xp mp type -1))))))))

(defun tp-and (t1 t2)
  (when (and t1 t2)
    (cond ((eq t1 t) t2)((eq t2 t) t1)
	  ((cmp-tp-and t1 t2)))))

(let ((xp (make-btp))(mp (make-btp)))
  (defun cmp-tp-or (t1 t2)
    (bit-ior (mtp t1) (mtp t2) mp)
    (cond ((when (atom t1) (equal mp (mtp t2))) t2)
	  ((when (atom t2) (equal mp (mtp t1))) t1)
	  ((and (atom t1) (atom t2)) (copy-tp mp mp nil 1))
	  ((let ((type (new-tp1 'or t1 t2 (bit-ior (xtp t1) (xtp t2) xp) mp)))
	     (cond ((when (atom t1) (equal xp t1)) t1)
		   ((when (atom t2) (equal xp t2)) t2)
		   ((copy-tp xp mp type 1))))))))

(defun tp-or (t1 t2)
  (cond ((eq t1 t))
	((eq t2 t))
	((not t1) t2)
	((not t2) t1)
	((cmp-tp-or t1 t2))))


(defun cmp-tp-not (tp)
  (if (atom tp)
      (bit-not tp (make-btp))
    (list (bit-not (cadr tp) (make-btp)) (bit-not (car tp) (make-btp)) (ntp-not (caddr tp)))))

(defun tp-not (tp)
  (unless (eq tp t)
    (or (not tp)
	(cmp-tp-not tp))))


(let ((p1 (make-btp))(p2 (make-btp)))
  (defun tp<= (t1 t2)
    (cond ((eq t2 t))
	  ((not t1))
	  ((or (not t2) (eq t1 t)) nil)
	  ((equal *nil-tp* (bit-andc2 (xtp t1) (mtp t2) p1)))
	  ((equal *nil-tp* (bit-andc2 p1 (bit-andc2 (xtp t2) (mtp t1) p2) t))
	   (eq +tp-nil+ (ntp-and (caddr t1) (ntp-not (caddr t2))))))))

(defun tp>= (t1 t2) (tp<= t2 t1))

(defun tp-p (x)
  (or (null x) (eq x t) (bit-vector-p x)
      (when (listp x)
	(and (bit-vector-p (car x))
	     (bit-vector-p (cadr x))
	     (consp (caddr x))))));FIXME

(defvar *nrm-hash* (make-hash-table :test 'equal))
(defvar *unnrm-hash* (make-hash-table :test 'eq))

(defun hashable-typep (x)
  (or (when (symbolp x)
	(unless (si-find-class x nil)
	  (let ((x (get x 's-data))) (if x (s-data-frozen x) t))))
      (when (listp x)
	(when (eq (car x) 'member)
	  (not (member-if-not 'integerp (cdr x)))))))

(defun comp-tp1 (x &aux (s (hashable-typep x)))
  (multiple-value-bind
   (r f) (when s (gethash x *nrm-hash*))
   (if f r
     (let ((y (comp-tp x)))
       (when (and s y)
	 (setf (gethash y *unnrm-hash*) x)
	 (setf (gethash x *nrm-hash*) y))
       y))))

(defun cmp-norm-tp (x)
  (cond ((tp-p x) x)
	((eq x '*) x)
	((when (listp x)
	   (case (car x)
		 ((returns-exactly values) (cons (car x) (mapcar 'cmp-norm-tp (cdr x)))))))
	((comp-tp1 x))))

(defun tp-type1 (x)
  (multiple-value-bind
   (r f) (gethash x *unnrm-hash*)
   (if f r (tp-type x))))

(defun cmp-unnorm-tp (x)
  (cond ((tp-p x) (tp-type1 x))
	((when (listp x)
	   (case (car x)
		 ((not returns-exactly values) (cons (car x) (mapcar 'cmp-unnorm-tp (cdr x)))))))
	(x)))

(defun null-list (x) (when (plusp x) (make-list x :initial-element #tnull)))

(defun type-and (x y)
  (cond ((eq x '*) y)
	((eq y '*) x)
	((and (cmpt x) (cmpt y))
	 (let ((lx (length x))(ly (length y)))
	   (cons (if (when (eql lx ly)
		       (when (eq (car x) (car y))
			 (eq (car x) 'returns-exactly)))
		     'returns-exactly 'values)
		 (mapcar 'type-and
			 (append (cdr x) (null-list (- ly lx)))
			 (append (cdr y) (null-list (- lx ly)))))))
	((cmpt x) (type-and (or (cadr x) #tnull) y))
	((cmpt y) (type-and x (or (cadr y) #tnull)))
	((tp-and x y))))

(defun type-or1 (x y)
  (cond ((eq x '*) x)
	((eq y '*) y)
	((and (cmpt x) (cmpt y))
	 (let ((lx (length x))(ly (length y)))
	   (cons (if (when (eql lx ly)
		    (when (eq (car x) (car y))
		      (eq (car x) 'returns-exactly)))
		  'returns-exactly 'values)
		 (mapcar 'type-or1
			 (append (cdr x) (null-list (- ly lx)))
			 (append (cdr y) (null-list (- lx ly)))))))
	((cmpt x) (type-or1 x `(returns-exactly ,y)))
	((cmpt y) (type-or1 `(returns-exactly ,x) y))
	((tp-or x y))))

(defun type<= (x y)
  (cond ((eq y '*))
	((eq x '*) nil)
	((and (cmpt x) (cmpt y))
	 (do ((x (cdr x) (cdr x))(y (cdr y) (cdr y)))
	     ((and (not x) (not y)) t)
	     (unless (type<= (if x (car x) #tnull) (if y (car y) #tnull))
	       (return nil))))
	((cmpt x) (type<= x `(returns-exactly ,y)))
	((cmpt y) (type<= `(returns-exactly ,x) y))
	((tp<= x y))))

(defun type>= (x y) (type<= y x))

















(defconstant +rn+ (mapcar (lambda (x) (cons (cmp-norm-tp (car x)) (cadr x))) +r+))

(defconstant +tfns1+ '(tp0 tp1 tp2 tp3 tp4 tp5 tp6 tp7 tp8))

(defconstant +rs+ (mapcar (lambda (x)
			    (cons x
				  (mapcar (lambda (y)
					    (cons (car y) (funcall x (eval (cdr y)))))
					  +rn+)))
			  +tfns1+))

(defconstant +kt+ (mapcar 'car +rn+))


(defun tps-ints (a rl)
  (lremove-duplicates (mapcar (lambda (x) (cdr (assoc (cadr x) rl))) a)))

(defun ints-tps (a rl)
  (lreduce (lambda (y x) (if (member (cdr x) a) (type-or1 y (car x)) y)) rl :initial-value nil))


(eval-when
 (compile eval)
 (defun msym (x) (intern (string-concatenate (string x) "-TYPE-PROPAGATOR") :si)))

(defun type-and-list (tps)
  (mapcan (lambda (x)
	    (mapcan (lambda (y &aux (z (type-and x y)))
		      (when z `((,x ,y ,z))))
		    +kt+))
	  tps))

(defun norm-tp-ints (tp rl)
   (cmp-norm-tp (cons 'member (tps-ints (type-and-list (list tp)) rl))))

#.`(progn;FIXME macrolet norm-tp-ints can only compile-file, not compile
     ,@(mapcar (lambda (x &aux (s (msym x))) 
		 `(let* ((rl (cdr (assoc ',x +rs+))))
		    (defun ,s (f x)
		      (declare (ignore f))
		      (norm-tp-ints x rl))
		    (setf (get ',x 'type-propagator) ',s)
		    (setf (get ',x 'c1no-side-effects) t)))
	       +tfns1+))



(defun best-type-of (c)
  (let* ((r (lreduce 'set-difference c :key 'car :initial-value +kt+))
	 (tps (nconc (mapcar 'car c) (list r))))
    (or (caar (member-if (lambda (x)
			   (let* ((f (pop x))
				  (z (mapcan
				      (lambda (y)
					(lremove-duplicates
					 (mapcar (lambda (z) (cdr (assoc z x))) y)))
				      tps)))
			     (eq z (lremove-duplicates z))))
			 +rs+))
	(caar +rs+))))

(defun calist2 (a)
  (let* ((subs (lremove-duplicates
		(mapcar 'cadr
			(lremove-if (lambda (x) (eq (cadr x) (caddr x))) a))))
	 (x (mapcar (lambda (x)
		      (cons (list x)
			    (mapcar (lambda (x) (cons (car x) (caddr x)))
				    (lremove-if-not (lambda (y) (eq (cadr y) x)) a))))
		    subs))
	 (ra (lremove-if (lambda (x) (member (cadr x) subs)) a))
	 (y (mapcar (lambda (x)
		      (list (mapcar 'cadr
				    (lremove-if-not (lambda (y) (eq x (car y))) ra))
			    (cons x nil)))
		    (lremove-duplicates (mapcar 'car ra)))))
    (nconc x y)))

(defun logandc2 (x y) (logand x (~ y)))


(defconstant +useful-type-list+ `(nil
				  null
				  boolean keyword symbol
				  proper-cons cons proper-list list
				  simple-vector string vector-fixnum vector array
				  proper-sequence sequence
				  zero one
				  bit rnkind non-negative-char unsigned-char signed-char char
				  non-negative-short unsigned-short signed-short short
				  seqind non-negative-fixnum
				  non-negative-integer
				  immfix tractable-fixnum fixnum bignum integer
				  negative-short-float positive-short-float
				  non-negative-short-float non-positive-short-float
				  short-float
				  negative-long-float positive-long-float
				  non-negative-long-float non-positive-long-float
				  long-float
				  negative-float positive-float
				  non-negative-float non-positive-float
				  float
				  negative-real positive-real
				  non-negative-real non-positive-real
				  real
				  fcomplex dcomplex
				  complex-integer complex-ratio
				  complex-ratio-integer complex-integer-ratio
				  complex
				  number
				  character structure package hash-table function
				  t))
;; (defconstant +useful-types+ (mapcar 'cmp-norm-tp +useful-type-list+))
(defconstant +useful-types-alist+ (mapcar (lambda (x) (cons x (cmp-norm-tp x))) +useful-type-list+))
