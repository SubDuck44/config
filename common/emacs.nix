{ pkgs, ... }: let inherit (pkgs.lib) remove; in {
  aquaris = {
    emacs = {
      enable = true;
      package = pkgs.emacs-pgtk;

      prelude = ''
        (defvar my/temp-dir (concat user-emacs-directory "temp/"))
      '';

      usePackage = {
        statistics = true;
      };

      config = {
        inhibit-mouse = {
          custom = ''
            (inhibit-mouse-adjust-mouse-highlight t)
            (inhibit-mouse-adjust-show-help-function t)
          '';

          config = ''
            (if (daemonp)
                (add-hook 'server-after-make-frame-hook #'inhibit-mouse-mode)
                (inhibit-mouse-mode 1))
          '';
        };

        consult = {
          bind' = ''
            ("C-b" . consult-buffer)
            ("C-r" . consult-goto-line)
            ("C-s" . consult-line)
            ("M-v" . consult-yank-from-kill-ring)
            ("M-g" . consult-grep)
          '';
          custom = ''
            (xref-show-xrefs-function       'consult-xref)
						(xref-show-definitions-function 'consult-xref)
						(xref-prompt-for-identifier      nil)
          '';
        };

        vertico = {
          init = "(vertico-mode)";
        };

        vertico-prescient = {
          config = "(vertico-prescient-mode t)";
        };

        prescient = {
          config = "(prescient-persist-mode t)";
        };

        uxntal-mode = {};

        marginalia = {
          config = "(marginalia-mode t)";
        };

        lsp-mode = {
          custom = ''
            (lsp-idle-delay 0)
            (lsp-enable-on-type-formatting nil)
          '';
          hook = ''
            (c-mode . lsp-deferred)
          '';
        };

        company = {
          custom = ''
            (company-dabbrev-downcase nil)
            (company-dabbrev-ignore-case t)
            (company-idle-delay 0)
            (company-minimum-prefix-length 1)
            (company-show-numbers t)
          '';
        };

        direnv = {
          config = "(direnv-mode 1)";
          custom = "(direnv-always-show-summary nil)";
        };

        nix-mode = {};

        rainbow-delimiters = {
          config = ''
            (set-face-foreground 'rainbow-delimiters-depth-1-face "#67a9ef")
            (set-face-foreground 'rainbow-delimiters-depth-2-face "#9349d1")
            (set-face-foreground 'rainbow-delimiters-depth-3-face "#e0dc04")
            (set-face-foreground 'rainbow-delimiters-depth-4-face "#29ce31")

            (define-globalized-minor-mode my/global-rainbow-delimiters-mode
              rainbow-delimiters-mode
              (lambda () (rainbow-delimiters-mode 1)))
            (my/global-rainbow-delimiters-mode 1)
          '';
          custom = "(rainbow-delimiters-max-face-count 4)";
        };

        centaur-tabs = {
          demand = true;
          bind' = ''
            ("C-<prior>" . centaur-tabs-forward)
            ("C-<next>" . centaur-tabs-backward)
          '';
          config = ''
            (centaur-tabs-mode 1)
            (centaur-tabs-change-fonts "monospace" 100)
            (centaur-tabs-headline-match)
          '';
          custom = ''
            (centaur-tabs-cycle-scope 'tabs)
            (centaur-tabs-modified-marker "*")
            (centaur-tabs-set-bar 'under)
            (centaur-tabs-show-new-tab-button nil)
            (centaur-tabs-set-close-button nil)
            (centaur-tabs-set-icons t)
            (centaur-tabs-set-modified-marker t)
            (centaur-tabs-style "bar")
          '';
        };

        display-line-numbers = {
          config = ''
            (global-display-line-numbers-mode t)
            (set-face-background 'line-number nil)
            (set-face-foreground 'line-number "#ebdbb2")
          '';
          custom = "(display-line-numbers-type 'visual)";
        };

        highlight-indent-guides = {
          hook = "prog-mode";
          config = ''
            (set-face-background 'highlight-indent-guides-odd-face "#ffffff")
            (set-face-background 'highlight-indent-guides-even-face "#b2b2b2")
            (set-face-foreground 'highlight-indent-guides-character-face "#b2b2b2")
          '';
          custom = ''
            (highlight-indent-guides-auto-enabled nil)
            (highlight-indent-guides-method 'bitmap)
            (highlight-indent-guides-responsive 'top)
          '';
        };

        multiple-cursors = {
          bind' = ''
            ("C-a" . mc/edit-lines)
            ("C-," . mc/mark-previous-like-this)
            ("C-." . mc/mark-next-like-this)
          '';
        };

        emacs = {
          config = ''
            (require 'notifications)
            (global-auto-revert-mode 1)
            (cua-mode 1)
            (tool-bar-mode 0)
            (menu-bar-mode 0)
            (scroll-bar-mode 0)
            (global-whitespace-newline-mode 1)
            (global-whitespace-mode 1)
            (electric-indent-mode nil)
            (set-frame-parameter nil 'alpha-background 50)
            (add-to-list 'default-frame-alist '(alpha-background . 50))
            (add-to-list 'default-frame-alist '(font . "monospace:size=12"))
            (put 'list-timers 'disable nil)
						(load-theme 'wheatgrass t)

            (advice-add 'appt-check
              :before
              (lambda (&rest args)
                (org-agenda-to-appt t)))
            (appt-activate t)

            (defun my/open-config () "Opens Emacs configuration file"
              (interactive)
              (find-file "~/cfg/common/emacs.nix"))

            (defun my/open-cfg () "Opens common system configuration file"
              (interactive)
              (find-file "~/cfg/common/default.nix"))

            (defun my/open-todo () "Opens personal task list"
              (interactive)
              (find-file "~/org/todo.org"))
          '';
          bind' = ''
            ("C-j" . next-line)
            ("C-i" . previous-line)
            ("C-f" . backward-char)
            ("C-e" . forward-char)
            ("M-j" . scroll-up-command)
            ("M-i" . scroll-down-command)
            ("M-f" . backward-word)
            ("M-e" . forward-word)
            ("C-q" . beginning-of-line)
            ("C-w" . end-of-line)
            ("C-l" . recenter)
            ("C-´" . other-window)
            ("C-<tab>" . (lambda () (interactive) (insert-char 9)))
          '';
          custom = ''
            (whitespace-style '(face trailing))
            (org-startup-indented t)
            (org-agenda-files "/home/melinda/org/toplevel.txt")
            (c-basic-offset 2)
            (tab-width 2)
            (auto-save-file-name-transforms `((".*" ,my/temp-dir t)))
            (backup-directory-alist         `((".". ,my/temp-dir  )))
            (lock-file-name-transforms      `((".*" ,my/temp-dir t)))
            (eldoc-idle-delay 0)
            (appt-message-warning-time 20)
            (appt-display-interval 5)
            (appt-disp-window-function
              (lambda (remaining new-time msg)
                (notifications-notify
                 :title (format "In %s minutes" remaining)
                 :body msg
                 :urgency 'critical)))
            (org-agenda-prefer-last-repeat t)
          '';
        };
      };
    };
  };
}
