(defvar my/temp-dir (concat user-emacs-directory "temp/"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun lsp-booster--advice-json-parse (old-fn &rest args)
  "Try to parse bytecode instead of json."
  (or
   (when (equal (following-char) ?#)
     (let ((bytecode (read (current-buffer))))
       (when (byte-code-function-p bytecode)
         (funcall bytecode))))
   (apply old-fn args)))

(defun lsp-booster--advice-final-command (old-fn cmd &optional test?)
  "Prepend emacs-lsp-booster command to lsp CMD."
  (let ((orig-result (funcall old-fn cmd test?)))
    (if (and (not test?)                             ;; for check lsp-server-present?
             (not (file-remote-p default-directory)) ;; see lsp-resolve-final-command, it would add extra shell wrapper
             lsp-use-plists
             (not (functionp 'json-rpc-connection))  ;; native json-rpc
             (executable-find "emacs-lsp-booster"))
      (progn
        (when-let ((command-from-exec-path (executable-find (car orig-result))))  ;; resolve command from exec-path (in case not found in $PATH)
          (setcar orig-result command-from-exec-path))
        (message "Using emacs-lsp-booster for %s!" orig-result)
        (cons "emacs-lsp-booster" orig-result))
      orig-result)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; https://www.masteringemacs.org/article/seamlessly-merge-multiple-documentation-sources-eldoc
(defun my/flycheck-eldoc (callback &rest _ignored)
  "Print flycheck messages at point by calling CALLBACK."
  (when-let ((flycheck-errors (and flycheck-mode (flycheck-overlay-errors-at (point)))))
    (mapc
     (lambda (err)
       (funcall callback
                (format "%s: %s"
                        (let ((level (flycheck-error-level err)))
                          (pcase level
                            ('info (propertize "I" 'face 'flycheck-error-list-info))
                            ('error (propertize "E" 'face 'flycheck-error-list-error))
                            ('warning (propertize "W" 'face 'flycheck-error-list-warning))
                            (_ level)))
                        (flycheck-error-message err))
                :thing (or (flycheck-error-id err)
                           (flycheck-error-group err))
                :face 'font-lock-doc-face))
     flycheck-errors)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(advice-add 'appt-check
  :before
  (lambda (&rest args)
    (org-agenda-to-appt t)))

(appt-activate t)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/open-config () "Opens Emacs configuration file"
  (interactive)
  (find-file "~/cfg/common/emacs/emacs.nix"))

(defun my/open-cfg () "Opens common system configuration file"
  (interactive)
  (find-file "~/cfg/common/default.nix"))

(defun my/open-todo () "Opens personal task list"
  (interactive)
  (find-file "~/org/todo.org"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun my/keyboard-config ()
  (when (display-graphic-p)
    (keyboard-translate ?\C-i ?\H-i)))

(add-hook 'after-make-frame-functions
  (lambda (frame)
    (with-selected-frame frame
      (my/keyboard-config))))

(my/keyboard-config)
