;-*- Mode:     Lisp -*-
;;;; Author:   Paul Dietz
;;;; Created:  Mon Mar 24 03:39:09 2003
;;;; Contains: Loader for CLOS-related test files

(compile-and-load "defclass-aux.lsp")
(load "defclass.lsp")
(load "defclass-01.lsp")
(load "defclass-02.lsp")
(load "defclass-03.lsp")
(load "defclass-errors.lsp")
(load "defclass-forward-reference.lsp")
(load "ensure-generic-function.lsp")
(load "allocate-instance.lsp")
(load "reinitialize-instance.lsp")
(load "shared-initialize.lsp")
