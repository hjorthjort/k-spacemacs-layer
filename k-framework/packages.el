;;; packages.el --- k-framework layer packages file for Spacemacs.

(setq k-framework-packages
  '(
    (k3-mode :location local)
    markdown-mode
   )
)

(defun k-framework/init-k3-mode ()
  (use-package k3-mode
    :defer t
    :mode "\\.k\\'"
  )
  (use-package markdown-mode
    :config
    (setq markdown-code-lang-modes (cons '("k" . k3-mode) markdown-code-lang-modes))
    )
)

(defun k-framework/post-init-k3-mode ()
  (spacemacs/set-leader-keys-for-major-mode 'k3-mode
    "c" 'compile
    )
)


