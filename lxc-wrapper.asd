;; -*- mode: common-lisp -*-
(asdf:defsystem #:lxc-wrapper
  :description "An opinionated LXC wrapper"
  :author "Florian Margaine <florian@margaine.com>"
  :license "MIT License"
  :serial t
  :depends-on ("external-program" "cl-ppcre" "alexandria" "apply-argv")
  :components ((:file "package")
	       (:file "cli")
	       (:file "lxc-wrapper")
	       (:file "ip")
	       (:file "lxc")))
