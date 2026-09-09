;; -*- lexical-binding: t -*-

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

(defun nori/smart-home ()
  "Jump to beginning of line or first non-whitespace."
  (interactive)
  (let ((oldpos (point)))
    (beginning-of-visual-line 1)
    (skip-syntax-forward " " (line-end-position))
    (backward-prefix-chars)
    (and (= oldpos (point)) (beginning-of-visual-line))))

(defun nori/join-line ()
  (interactive)
  (join-line)
  (forward-line 1)
  (back-to-indentation))

(defun my/open-config ()
  "Opens Emacs configuration file"
  (interactive)
  (find-file "~/cfg/common/emacs/default.nix"))

(defun my/open-cfg ()
  "Opens common system configuration file"
  (interactive)
  (find-file "~/cfg/common/default.nix"))

(defun my/open-todo ()
  "Opens personal task list"
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar-local nori/typst-pin nil "Should this file be pinned automatically?")
(put 'nori/typst-pin 'safe-local-variable #'booleanp)

(defvar nori/typst-pins (make-hash-table) "Mapping of LSP PID -> pinned file.")

(defun nori/lsp-pid ()
  "Returns the PID of the LSP server attached to this buffer."
  (if-let* ((_ (fboundp 'lsp-workspaces))
            (ws (car (lsp-workspaces))))
      (lsp-process-id (lsp--workspace-cmd-proc ws))))

(defun nori/typst-pin ()
  "Pin or unpin the current Typst buffer."
  (interactive)
  (let* ((pid (nori/lsp-pid))
         (old (gethash pid nori/typst-pins))
         (cur buffer-file-name)
         (new (if (equal old cur) nil cur)))
    (puthash pid new nori/typst-pins)
    (lsp-send-execute-command "tinymist.pinMain" (vector new))
    (if new
      (message "Pinned Typst buffer %s!" new)
      (message "Unpinned Typst buffer %s!" old))))

