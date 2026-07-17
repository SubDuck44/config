{ pkgs, lib, ... }: {
  home-manager.sharedModules = [{
    services.emacs = {
      enable = true;
      startWithUserSession = "graphical";
    };

    systemd.user.services.emacs.Service = {
      Environment = [ "LSP_USE_PLISTS=true" ];
      Restart = lib.mkForce "always";
    };

    programs.emacs.overrides = _: epkgs: {
      lsp-mode = epkgs.lsp-mode.overrideAttrs (old: {
        buildPhase = ''
          export LSP_USE_PLISTS=true
        '' + (old.buildPhase or "");
      });
    };

    aquaris = {
      persist = {
        ".config/emacs" = { };
      };

      emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;

        extraPackages = epkgs: with epkgs; [
          (treesit-grammars.with-grammars (g: with g; [
            tree-sitter-typst
            tree-sitter-qmljs
          ]))
        ];

        prelude = builtins.readFile ./prelude.el;

        postlude = ''
          (load "bootstrap")
        '';

        usePackage = {
          statistics = true;
        };

        config = {

          emacs = {
            hook = ''
              ; delete trailing whitespace on save
              (before-save . delete-trailing-whitespace)
            '';

            config = ''
              (require 'notifications)
              (global-auto-revert-mode 1)
              (cua-mode 1)
              (tool-bar-mode 0)
              (menu-bar-mode 0)
              (scroll-bar-mode 0)
              (global-display-fill-column-indicator-mode 1)
              (global-whitespace-newline-mode 1)
              (global-whitespace-mode 1)
              (electric-indent-mode nil)
              (set-frame-parameter nil 'alpha-background 50)
              (add-to-list 'default-frame-alist '(alpha-background . 50))
              (add-to-list 'default-frame-alist '(font . "monospace:size=14"))
              (put 'list-timers 'disable nil)
            '';

            bind' = ''
              ("C-a"     . nori/smart-home)
              ("C-s"     . save-buffer)

              ("C-x C-f" . find-file)
              ("C-x C-l" . scratch-buffer)
              ("C-x C-a" . mark-whole-buffer)
              ("C-c C-s" . sort-lines)

              ("C-#"   . (lambda () (interactive) (select-window (next-window))))
              ("M-#"   . (lambda () (interactive) (select-window (previous-window))))
              ("M-e"   . forward-word)
              ("M-f"   . forward-to-word)
              ("M-n"   . scroll-up-command)
              ("M-p"   . scroll-down-command)

              ("C-+" . text-scale-increase)
              ("C--" . text-scale-decrease)
              ("C-=" . text-scale-mode)

              ("C-´"     . other-window)
              ("M-="     . count-words)
              ("M-c"     . avy-goto-char-timer)
            '';

            custom = ''
              (recenter-positions '(middle top))
              (whitespace-style '(face trailing))
              (org-startup-indented t)
              (org-agenda-files "/home/melinda/org/toplevel.txt")
              (c-basic-offset 4)
              (tab-width 4)
              (auto-save-file-name-transforms `((".*" ,my/temp-dir t)))
              (backup-directory-alist         `((".". ,my/temp-dir  )))
              (lock-file-name-transforms      `((".*" ,my/temp-dir t)))
              (appt-message-warning-time 20)
              (appt-display-interval 5)
              (appt-disp-window-function
                (lambda (remaining new-time msg)
                  (notifications-notify
                   :title (format "In %s minutes" remaining)
                   :body (substring-no-properties msg)
                   :urgency 'critical)))
              (org-agenda-prefer-last-repeat t)
              (fill-column 80)
            '';
          };

          "00-theme" = {
            package = "gruvbox-theme";
            config = "(load-theme 'gruvbox-dark-medium t)";
          };

          consult = {
            bind' = ''
              ("C-h C-m" . consult-man)
              ("C-x C-b" . consult-bookmark)
              ("C-x C-i" . my/consult-imenu-or-outline)
              ("C-x C-m" . consult-minor-mode-menu)
              ("C-x C-r" . consult-ripgrep)
              ("C-x C-s" . consult-buffer)
              ("C-x C-v" . consult-fd)
              ("M-l"     . consult-goto-line)
              ("M-s"     . consult-line)
              ("M-v"     . consult-yank-from-kill-ring)
            '';
            custom = ''
              (xref-show-xrefs-function       'consult-xref)
              (xref-show-definitions-function 'consult-xref)
              (xref-prompt-for-identifier      nil)
            '';
          };

          flycheck = {
            hook = "prog-mode";
            custom = ''
              (flycheck-check-syntax-automatically '(mode-enabled save))
              (flycheck-display-errors-function nil)
              (flycheck-help-echo-function nil)
            '';
          };

          jinx = {
            hook = "typst-ts-mode org-mode text-mode";

            bind' = ''
              ("C-M-i" . jinx-correct)
            '';

            config = ''
              (require 'vertico-multiform)
              (add-to-list 'vertico-multiform-categories
                '(jinx grid (vertico-grid-annotate . 20) (vertico-count . 4)))
              (vertico-multiform-mode)
            '';
          };

          consult-flycheck = {
            bind' = ''
              ("C-x C-c" . consult-flycheck)
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

          uxntal-mode = { };

          go-mode = {
            defer = true;
            extraPackages = with pkgs; [ gopls ];
          };

          marginalia = {
            config = "(marginalia-mode t)";
          };

          crdt = {
            defer = true;
          };

          apheleia = {
            hook = "prog-mode typst-ts-mode";

            config = ''
              (add-to-list 'apheleia-mode-alist '(scheme-mode . lisp-indent))
              (setf (alist-get 'python-mode apheleia-mode-alist)
                    '(isort black))
              (add-to-list 'apheleia-mode-alist '(c-mode   . my/clang-format))
              (add-to-list 'apheleia-mode-alist '(c++-mode . my/clang-format))
              (add-to-list 'apheleia-formatters '(my/clang-format
                "clang-format" "--style=file:${./clang-format.yaml}"))
            '';
          };

          web-mode = {
            defer = true;

            hook = "html-mode css-mode";
          };

          typst-ts-mode = {
            defer = true;

            extraPackages = with pkgs; [
              prettypst
              tinymist
              typst
            ];

            config = ''
              (require 'lsp-mode)
              (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))
              (lsp-register-client
               (make-lsp-client
                :new-connection (lsp-stdio-connection "tinymist")
                :major-modes '(typst-ts-mode)
                :server-id 'tinymist))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(typst-ts-mode . prettypst))
              (add-to-list 'apheleia-formatters '(prettypst "prettypst" "--use-std-in" "--use-std-out"))
            '';

            custom = ''
              (typst-ts-mode-indent-offset 2)
            '';
          };

          avy = {
            bind' = ''
              ("M-c"   . avy-goto-char)
              ("C-M-c" . avy-goto-char-timer)
            '';

            custom = ''
              (avy-keys
               (nconc
                (number-sequence ?a ?z)
                (number-sequence ?0 ?9)))

              (avy-background t)
              (avy-case-fold-search nil) ; only caps trigger case matching
              (avy-style 'de-bruijn)
            '';

            config = ''
              (set-face-attribute 'avy-lead-face   nil :foreground "#fb4934" :background "#282828" :bold t) ; first
              (set-face-attribute 'avy-lead-face-0 nil :foreground "#b8bb26" :background "#282828" :bold t) ; second
              (set-face-attribute 'avy-lead-face-1 nil :foreground "#282828" :background "#282828" :bold t) ; matched
              (set-face-attribute 'avy-lead-face-2 nil :foreground "#83a598" :background "#282828" :bold t) ; third
            '';
          };

          typst-preview = {
            hook = "typst-ts-mode";

            custom = ''
              (typst-preview-invert-colors "never")
              (typst-preview-open-browser-automatically t)
            '';

            config = ''
              ;; always set master file to current buffer; skip manual input
              (advice-add 'typst-preview-start :before (lambda (&rest r)
                (setq typst-preview--master-file (f-canonical buffer-file-name))))
            '';
          };

          qml-ts-mode = {
            mode = ''"\\.qml\\'"'';

            config = ''
              (require 'lsp-mode)
              (add-to-list 'lsp-language-id-configuration '(qml-ts-mode . "qml-ts"))
              (lsp-register-client
               (make-lsp-client :new-connection (lsp-stdio-connection '("qmlls" "-E"))
                                :activation-fn (lsp-activate-on "qml-ts")
                                :server-id 'qmlls))
              (add-hook 'qml-ts-mode-hook (lambda ()
                                            (setq-local electric-indent-chars '(?\n ?\( ?\) ?{ ?} ?\[ ?\] ?\; ?,))
                                            (lsp-deferred)))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(qml-ts-mode . qmlformat))
              (add-to-list 'apheleia-formatters '(qmlformat "qmlformat" "--tabs" filepath))
            '';

            package = ep: ep.trivialBuild (drv: {
              pname = "qml-ts-mode";
              version = "0.1";

              src = pkgs.fetchFromGitHub {
                owner = "xhcoding";
                repo = drv.pname;
                rev = "b80c6663521b4d0083e416e6712ebc02d37b7aec";
                hash = "sha256-WXK/CdFF9E2kG+uIios4HtKcEMhILS9MddJfVDeRLh0=";
              };
            });

            extraPackages = with pkgs; [ kdePackages.qtdeclarative ];
          };

          lua-mode = {
            defer = true;
          };

          lsp-mode = {
            custom = ''
              (eldoc-idle-delay 0)
              (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)

              (lsp-headerline-breadcrumb-enable nil)
              (lsp-idle-delay 0)
              (lsp-enable-on-type-formatting nil)
              (lsp-clients-clangd-args '("--header-insertion=never"))

              ;; performance
              (lsp-log-io nil)
              (read-process-output-max (* 1024 1024))
            '';

            hook = ''
              (c-mode . lsp-deferred)
              (go-mode . lsp-deferred)
              (typst-ts-mode . lsp-deferred)

              (lsp-managed-mode . (lambda ()
                (add-hook 'eldoc-documentation-functions #'my/flycheck-eldoc 90 t)))
            '';

            config = ''
              (advice-add 'lsp-mode :before
                #'lsp-inline-completion-company-integration-mode)

              (advice-add 'json-parse-buffer :around
                #'lsp-booster--advice-json-parse)

              (advice-add 'lsp-resolve-final-command :around
                #'lsp-booster--advice-final-command)
            '';

            extraPackages = with pkgs; [
              emacs-lsp-booster
            ];
          };

          lsp-pyright = {
            defer = true;

            hook = ''
              (python-mode . (lambda ()
                (require 'lsp-pyright)
                (lsp-deferred)))
            '';

            custom = ''
              (lsp-pyright-langserver-command "basedpyright")
            '';

            extraPackages = with pkgs; [ basedpyright ];
          };

          yasnippet = {
            hook = "(lsp-mode . yas-minor-mode)";
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

          nix-mode = {
            extraPackages = with pkgs; [
              nixpkgs-fmt
            ];

            config = ''
              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(nix-mode . nixpkgs-fmt))
              (add-to-list 'apheleia-formatters '(nixpkgs-fmt "nixpkgs-fmt"))
            '';
          };

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

          indent-bars = {
            config = ''
              (define-globalized-minor-mode my/global-indent-bars-mode
                indent-bars-mode
                (lambda () (indent-bars-mode 1)))

              (my/global-indent-bars-mode 1)
            '';
          };

          multiple-cursors = {
            bind' = ''
              ("C-," . mc/mark-previous-like-this)
              ("C-." . mc/mark-next-like-this)
            '';
          };

          straight = {
            defer = true;
          };
        };
      };
    };
  }];
}
