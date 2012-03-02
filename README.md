auto-complete-golang
======================

Overview
------------
 [auto-complete.el](https://github.com/m2ym/auto-complete) source for golang with gocode.
 
Installation
------------
 drop requirements and `auto-complete-golang.el` into a directory in your `load-path`. If you have `install-elisp` or `auto-install`, you also be able to install
`auto-complete-golang.el` like:

	;; install-elisp
    (install-elisp "https://raw.github.com/koko1000ban/auto-complete-golang/master/auto-complete-golang.el")

    ;; auto-install
    (auto-install-from-url "https://raw.github.com/koko1000ban/auto-complete-golang/master/auto-complete-golang.el")

And then put these lines into your .emacs file.

	(require 'auto-complete-golang)
	(add-hook 'go-mode-hook '(lambda () 
	                            (add-to-list 'ac-sources 'ac-source-golang)))

