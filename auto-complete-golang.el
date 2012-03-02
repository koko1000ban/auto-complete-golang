;;;  -*- coding: utf-8; mode: emacs-lisp; -*-
;;; auto-complete-golang.el -- auto-complete.el source for golang.

;; Copyright (C) 2012  tabi
;; Author: tabi <koko1000ban@gmail.com>
;; Keywords: autocomplete, golang

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Auto Completion source for golang. need gocode.

;;; Requirement:

;; * yasnippet.el

;;; Installation:

;; drop requirements and this file into a directory in your `load-path',
;; and put these lines into your .emacs file.

;; (require 'auto-complete-golang)
;; (add-hook 'go-mode-hook '(lambda () 
;;                            (add-to-list 'ac-sources 'ac-source-golang)))

(require 'auto-complete)

(defcustom ac-golang-gocode
  (executable-find "gocode")
  "*Location of gocode executable"
  :group 'auto-complete
  :type 'file)

(defcustom ac-golang-gocode-flags
  nil
  "*gocode extra flags"
  :group 'auto-complete)

(defvar ac-golang-debug t)

(defun ac-golang-log (m)
  (if (not ac-golang-debug)
      m
    (message "[log]%s" m)
    m))

(defface ac-golang-candidate-face
  '((t (:background "SteelBlue4" :foreground "white")))
  "Face for clang candidate"
  :group 'auto-complete)

(defface ac-golang-selection-face
  '((t (:background "black" :foreground "white")))
  "Face for the clang selected candidate."
  :group 'auto-complete)

(defun ac-golang-build-complete-args (pos)
  (append '("-f=emacs" "autocomplete")
          ac-golang-gocode-flags
          (list (int-to-string pos))))

(defconst ac-golang-candidate-pattern
  "^\\([^\s\n,]*\\),,\\(.*$\\)")

(defun ac-golang-parse-output ()
  (goto-char (point-min))
  (let (lst name summary)
    (while (re-search-forward ac-golang-candidate-pattern nil t)
      (setq name (match-string-no-properties 1))
      (setq summary (match-string-no-properties 2))
      (ac-golang-log (format "name:%s summary:%s" name summary))
      (push (propertize name 'summary summary) lst))
    (reverse lst)))

(defun ac-golang-invoke-complete (args)
  (if (not ac-golang-gocode)
      (message  "gocode cannot find! please install.")
    (ac-golang-log (format "execute %s %s" ac-golang-gocode args))
    (let ((buf (get-buffer-create "*gocode-output*"))
          res)
      (with-current-buffer buf (erase-buffer))
      (setq res 
            (apply 'call-process-region (point-min) (point-max) ac-golang-gocode nil buf nil args))
      (with-current-buffer buf
        (if (not (eq 0 res))
            (message "gocode failed with error %d: %s" res args) ;; handle error
          (ac-golang-log (format "%s" (buffer-string)))
          (ac-golang-log (ac-golang-parse-output))
          )))))


(defun ac-golang-candidate ()
  (ac-golang-log "start get candidates..")
  (save-restriction
    (widen)
    (ac-golang-invoke-complete 
     (ac-golang-build-complete-args (- (point) (length ac-prefix))))))

(defun ac-golang-action ()
  (let* ((sel (cdr ac-last-completion))
         (summary (get-text-property 0 'summary sel)))
    (ac-golang-log (format "selected summary : %s" summary))
    (cond ((featurep 'yasnippet)
           (when (string-match "^func(\\([^(]+\\))" summary)
             (let ((arg (match-string 1 summary))
                   (snp ""))
               (setq snp 
                     (mapconcat (lambda (s)
                                  (concat "${" (replace-regexp-in-string "\\(^[ \t\n\r]+\\|[ \t\n\r]+$\\)" "" s) "}"))
                                (split-string arg",")
                                ", "))
               
               (ac-golang-log (format "arg: %s snp: %s" arg snp))
               (yas/expand-snippet (concat "(" snp ")")))))
          (t
           (message "yasnippet not installed!!")))))

(ac-define-source golang
  '((candidates . ac-golang-candidate)
    (candidate-face . ac-golang-candidate-face)
    (selection-face . ac-golang-selection-face)
    (requires . 2)
    (action . ac-golang-action)
    (cache)
    (symbol . "g")
    ))

(provide 'auto-complete-golang)