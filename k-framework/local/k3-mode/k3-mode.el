;;; k3-mode.el -- Emacs mode for the K Framework

;; Updated from k-mode.el to support the new keywords in K3

;; Usage: add the below to your .emacs file:
;;     (setq load-path (cons "path/to/this/file" load-path))
;;     (load-library "k3-mode")
;;     (add-to-list 'auto-mode-alist '("\\.k$" . k3-mode)) ;; to launch k3-mode for .k files
;;     (setq markdown-code-lang-modes (cons '("k" . k3-mode) '(markdown-code-lang-modes))) ;; Use C-c C-x C-f to turn on highlighting within code block in Markdown mode

;; Currently has syntax highlighting for:
;;  - keywords
;;  - cells and rewrites
;;  - comments
;;  - declarations (e.g. ops, syntax, etc)
;;  - quoted identifiers (e.g. for terminals in the syntax)
;;  - annotations
;;  - matching-logic symbols
;;  - some common symbols from the standard library
;; Also has a menu and compilation through C-c C-c


;; Author: Michael Ilseman

(require 'comint)

;;;; Options ;;;;
(defvar k-dash-comments nil
  "Set to make \"--\" be used as a beginning of a line comment
   (emacs's syntax table is unable to differentiate 3 character long comment beginners)"
)
(defvar k-path "~/k-framework"
  "Path to the k-framework. Set if you wish to use kompile from emacs. Defaults to ~/k-framework.
   Currently doesn't do anything."
)

;;;; Syntax Highlighting ;;;;
(setq k-keywords '("syntax" "priorities" "left" "right" "non-assoc" "module" "endmodule" "imports" "sort" "op" "subsort" "rule" "context" "eq" "ceq" "load" "when" "require" "configuration" "context" "requires" "ensures" ))

(setq k-annotations '("alias" "alias-rec" "anywhere" "bracket" "concrete" "context" "cool" "freshGenerator" "function" "functional" "heat" "hook" "hybrid" "klabel" "macro" "macro-rec" "memo" "owise" "result" "seqstrict" "simplification" "smtlib" "strict" "symbol" "token" "unboundVariables"))

(setq k-common-words '("andBool" "orBool" "notBool"))

;; Set up the regexes

;; Metalanguage.
(setq k-keywords-regex (regexp-opt k-keywords 'words)
      k-annotations-regex (regexp-opt k-annotations 'symbols)
      k-keywords-special-regex "::=\\||"
      k-declarations "\\(syntax\\|sort\\|op\\) \\([a-zA-Z{}\\-]+\\)"
      k-rewrites-regex "=>\\|<[^ ]+>")

;; Common constructs.
(setq k-syntax-terminals-regex "\\.\\.\\.\\|~>\\||->\\|\\.\\s-\\|`\\w+"
      k-common-words-regex (regexp-opt k-common-words 'words)
      k-hash-symbols-regex  "#And\\|#Ceil\\|#Equals\\|#Exists\\|#False\\|#Or\\|#Not\\|#True\\|#as\\|#fun\\|#if\\|#then\\|#else\\|#fi")

;; Put them all together
;;
(setq k-font-lock-keywords
      `((,k-rewrites-regex         . font-lock-type-face)
        (,k-syntax-terminals-regex . font-lock-constant-face)
        (,k-hash-symbols-regex       . font-lock-constant-face)
        (,k-common-words-regex     . font-lock-constant-face)
        (,k-declarations           2 font-lock-function-name-face)
        (,k-keywords-regex         . font-lock-keyword-face)
        (,k-keywords-special-regex . font-lock-keyword-face)
        (,k-annotations-regex      . font-lock-builtin-face)))

;; Handle comments
(defun set-comment-highlighting ()
  "Set up comment highlighting"

  ;; comment style "// ..." and "/* ... */"
  (modify-syntax-entry ?\/ ". 124b" k3-mode-syntax-table)
  (modify-syntax-entry ?\n "> b" k3-mode-syntax-table)
  (modify-syntax-entry ?* ". 23" k3-mode-syntax-table)

  ;; comment style "-- ..."
  (if k-dash-comments (modify-syntax-entry ?- ". 1b2b" k3-mode-syntax-table))
)


;;;; K Bindings and menu ;;;;
(defvar k-prev-load-file nil
  "Record the last directory and file used in loading or compiling"
)
(defcustom k-source-modes '(k3-mode)
  "Determine if a buffer represents a k file"
)
;; (defun k3-mode-kompile (cmd)
;;   ;; (interactive (comint-get-source "Kompile k file: " k-prev-load-file k-source-modes nil))
;;   ;; (comint-check-source file-name) ; check to see if buffer has been modified and not saved
;;   ;; (setq k-prev-load-file (cons (file-name-directory file-name)
;;   ;;                              (file-name-nondirectory file-name)))
;;   ;; ;; (comint-send-string (inferior-lisp-proc)
;; 	;; ;; 	      (format inferior-lisp-load-command file-name))
;;   ;; ;; (switch-to-lisp t))
;;   ;; (message file-name)
;;   ;; (setq kompile-buffer (make-comint "Kompile" "zsh" nil))
;;   ;; (comint-send-string kompile-buffer "cd" nil (file-name-directory file-name))
;;   ;; (comint-send-string kompile-buffer "~/k-framework/tools/kompile.pl" nil (file-name-nondirectory file-name))
;;   (interactive "scmd")
;;   (compile cmd)
;;   nil
;; )
(defun k3-mode-about ()
  (interactive)
  (message "k3-mode for the K Framework")
)

(defun setup-k3-mode-map ()
  (setq k3-mode-map (make-sparse-keymap))

  ;; Keyboard shortcuts
  (define-key k3-mode-map (kbd "C-c C-c") 'compile)

  ;; Define the menu
  (define-key k3-mode-map [menu-bar] (make-sparse-keymap))

  (let ((menuMap (make-sparse-keymap "K Framework")))
    (define-key k3-mode-map [menu-bar k] (cons "K Framework" menuMap))
    (define-key menuMap [about]
      '("About k3-mode" . k3-mode-about))
    ;; (define-key menuMap [customize]
    ;;   '("Customize k3-mode" . k-customize))
    (define-key menuMap [separator]
      '("--"))
    (define-key menuMap [kompile]
      '("kompile" . compile)))
)





;;;; K Mode ;;;;

(define-derived-mode k3-mode fundamental-mode
  "k3 mode"
  "Major Mode for the K3 framwork"
  (setq font-lock-defaults '((k-font-lock-keywords)))

  ;; Comment entries
  (set-comment-highlighting)

  ;; Set comment start characters
  (setq comment-start "//")

  ;; Shortcuts and menu
  (setup-k3-mode-map)
  (use-local-map k3-mode-map)

  ;; Clear up memory
  ;;(setq k-keywords nil k-keywords-regex nil)
)

(provide 'k3-mode)
