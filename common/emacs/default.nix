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

      reformatter = epkgs.trivialBuild {
        pname = "reformatter";
        version = "0";

        src = pkgs.writeText "reformatter.el" ''
          (defmacro reformatter-define (&rest args)
            '(defun nix-format-on-save-mode (&rest args)))

          (provide 'reformatter)
        '';
      };
    };

    aquaris = {
      persist = {
        ".config/emacs" = { };
      };

      # emacs config
      emacs = {
        enable = true;
        package = pkgs.emacs-pgtk;

        extraPackages = epkgs: with epkgs; [
          treesit-grammars.with-all-grammars
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

                           ; highlight space indents
                           (font-lock-mode . nori/highlight-indent)

                           ; highlight region, indent and trailing spaces
                           (server-after-make-frame . (lambda ()
                             (custom-set-faces
                               '(region                 ((t (:background "#712246"))))
                               '(whitespace-indentation ((t (:background "red"    ))))
                               '(whitespace-trailing    ((t (:background "red"    ))))
                               )))

                           ;; un-german agenda view
                           (server-after-make-frame . (lambda ()
                             (custom-set-faces
                               '(org-agenda-structure ((t
                                 (:inherit    font-lock-comment-face
                                  :foreground "#8ec07c"
                                  :underline  t))))
                               '(org-agenda-date-today ((t
                                 (:foreground "#fdf4c1"
                                  :slant      normal
                                  :weight     bold))))
                               '(org-scheduled-previously ((t
                                 (:foreground "#edbdbb2"))))
                               '(org-scheduled ((t
                                 (:foreground "#d3869b"))))
                               '(org-scheduled-today ((t
                                 (:foreground "#d3869b"))))
                               '(org-priority ((t
                                 (:inherit font-lock-keyword-face
                                  :foreground "#458588"))))
                               '(org-imminent-deadline ((t
              (:inherit   org-warning
              :foreground "#fb4934"
              :underline  t))))
                               )))
            '';

            config = ''
              (require 'notifications)
              (global-auto-revert-mode 1)
              (cua-mode 1)

              (blink-cursor-mode 0) ; no blinking cursor
              (menu-bar-mode     0) ; no menu bar
              (scroll-bar-mode   0) ; no scroll bar
              (tool-bar-mode     0) ; no tool bar

              (global-display-fill-column-indicator-mode 1)
              (global-whitespace-newline-mode 1)
              (global-whitespace-mode 1)
              (electric-indent-mode nil)
              (set-frame-parameter nil 'alpha-background 50)
              (add-to-list 'default-frame-alist '(alpha-background . 50))
              (add-to-list 'default-frame-alist '(font . "monospace:size=14"))
              (put 'list-timers 'disable nil)

              ;; org-mode config config
              (timeclock-reread-log)
              (timeclock-mode-line-display 1)
              (display-time-mode 1)

              (set-face-foreground 'org-agenda-structure "#8ec07c")
              (set-face-underline 'org-agenda-structure "#8ec07c")
              (set-face-foreground 'org-agenda-date-today "#b8bb26")
            '';

            bind' = ''
              ("C-a"     . nori/smart-home)
              ("C-s"     . save-buffer)

              ("C-x C-f" . find-file)
              ("C-x C-l" . scratch-buffer)
              ("C-x C-a" . mark-whole-buffer)
              ("C-x C-k" . kill-buffer)
              ("C-c C-s" . sort-lines)
              ("C-c C-x" . nori/align-regexp)

              ("C-x C-1" . delete-window)
              ("C-x C-2" . (lambda ()
                (interactive)
                (split-window-vertically)
                (balance-windows)
                (other-window 1)))
              ("C-x C-3" . (lambda ()
                (interactive)
                (split-window-horizontally)
                (balance-windows)
                (other-window 1)))
              ("C-x C-4" . delete-other-windows)

              ("C-#"   . (lambda () (interactive) (select-window (next-window))))
              ("M-#"   . (lambda () (interactive) (select-window (previous-window))))
              ("M-e"   . forward-word)
              ("M-f"   . forward-to-word)
              ("M-n"   . (lambda () (interactive) (scroll-down 1)))
              ("M-p"   . (lambda () (interactive) (scroll-up 1)))

              ("C-+" . text-scale-increase)
              ("C--" . text-scale-decrease)
              ("C-=" . text-scale-mode)

              ("C-´"     . other-window)
              ("M-="     . count-words)

              ("C-M-<backspace>" . nori/join-line)

              ("C-t C-i" . timeclock-in)
              ("C-t C-o" . timeclock-out)
              ("C-t C-p" . timeclock-change)
              ("C-t C-t" . (lambda () (interactive)
                (message (timeclock-status-string))))

              ("C-t <up>"   . org-priority-up)
              ("C-t <down>" . org-priority-down)
              ("C-c C-a"    . org-agenda)
              ("C-t C-c"    . org-capture)
              ("C-t C-s"    . org-todo)

              ("C-k" . consult-yank-from-kill-ring)
            '';

            custom = ''
              ;; org-mode custom config

              (org-startup-indented t)
              (org-agenda-files "/home/melinda/org/toplevel.txt")
              (org-agenda-prefer-last-repeat t)
              (org-return-follows-link t)
              (org-agenda-start-on-weekday nil)
              (org-agenda-start-day "-3d")

              (org-capture-templates
                '(("t" "Todo" entry (file+headline "~/org/todo.org" "Tasks")
                "* TODO [#B] %? :sterm:short:leisure:\n:Created: %T\n")
                ("r" "Recorring Task" entry (file+headline "~/org/todo.org" "Recurring")
                "* TODO [#B] %? :short:work:\n:Created: %T\n")
                ))

              (org-todo-keywords
                '((sequence "TODO(t)"
                            "WIP(w!)"
                            "BLOCKED(b@/!)"
                            "|"
                            "CANCELED(c@/!)"
                            "DONE(d@/!)")))

              (org-todo-keyword-faces '(
                ("TODO"     . (:foreground "#cc241d" :weight bold))
                ("WIP"      . (:foreground "#458588" :weight bold))
                ("BLOCKED"  . (:foreground "#d65d0e" :weight bold))
                ("CANCELED" . (:foreground "#928374" :weight bold))
                ("DONE"     . (:foreground "#98971a" :weight bold))))

              (org-tag-alist '(
                ;; task size
                (:startgroup . nil)
                ("small"     . nil)
                ("medium"    . nil)
                ("large"     . nil)
                (:endgroup   . nil)

                ;; urgency
                (:startgroup . nil)
                ("sterm"     . nil)
                ("mterm"     . nil)
                ("lterm"     . nil)
                (:endgroup   . nil)

                ;; field
                ("school"      . nil)
                ("leisure"     . nil)
                ("nori"        . nil)
                ("work"        . nil)
                ("programming" . nil)

                ;; misc
                ("afswe-relevant" . nil)
                ("financial"      . nil)
                ("recurring"      . nil)
              ))

              (org-tag-faces '(
                ("short"  . (:foreground "#b8bb26" :weight bold))
                ("medium" . (:foreground "#fabd2f" :weight bold))
                ("long"   . (:foreground "#fb4934" :weight bold))
                ("leisure". (:foreground "#bb77ff" :weight bold))))

              (recenter-positions '(middle top))

              (whitespace-style '(face trailing indentation tab-mark
                                  missing-newline-at-eof))

              (c-basic-offset 4)
              (tab-width 4)

              (auto-save-file-name-transforms `((".*" ,my/temp-dir t)))
              (backup-directory-alist         `((".". ,my/temp-dir  )))
              (lock-file-name-transforms      `((".*" ,my/temp-dir t)))

              (appt-message-warning-time 20)
              (appt-display-interval 5)
              (appt-display-mode-line nil)
              (appt-disp-window-function
                (lambda (remaining new-time msg)
                  (notifications-notify
                   :title (format "In %s minutes" remaining)
                   :body (substring-no-properties msg)
                   :urgency 'critical)))

              (fill-column 80)

              (timeclock-workday 3600)
              (timeclock-file "~/org/emacs-timelog")

              (mode-line-format
               '("%e" mode-line-front-space mode-line-mule-info mode-line-client
                 mode-line-modified mode-line-remote mode-line-window-dedicated
                 mode-line-frame-identification mode-line-buffer-identification
                 nori/modeline-typst-pin-segment "   " mode-line-position
                 (project-mode-line project-mode-line-format) (vc-mode vc-mode)
                 "  " mode-line-modes mode-line-misc-info mode-line-end-spaces))
            '';

            extraPackages = with pkgs; [
              bash-language-server
              shellcheck
            ];
          };

          # styling
          "00-theme" = {
            package = "gruvbox-theme";
            config = "(load-theme 'gruvbox-dark-medium t)";
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

          org-fancy-priorities = {
            hook = ''
              (org-mode . org-fancy-priorities-mode)
            '';

            custom = ''
              (org-fancy-priorities-list '(
                "DEFCON-1"
                "STANDARD"
                "ANYTIME"
              ))
            '';
          };

          # utility essentials
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

          posframe = {
            defer = true;

            config = ''
              (advice-add #'posframe-show :filter-args (lambda (args)
                (push '(alpha-background . 100)
                       (plist-get (cdr args) :override-parameters))
                args))
            '';
          };

          jinx = {
            hook = "typst-ts-mode org-mode text-mode";

            bind' = ''
              ("C-M-i" . jinx-correct)
              ("C-M-n" . jinx-next)
            '';

            config = ''
              (require 'vertico-multiform)
              (add-to-list 'vertico-multiform-categories
                '(jinx grid (vertico-grid-annotate . 20) (vertico-count . 4)))
              (vertico-multiform-mode)

              (add-to-list 'jinx-exclude-faces '(typst-ts-mode
                font-lock-comment-face font-lock-string-face font-lock-doc-face font-lock-doc-markup-face
                font-lock-warning-face font-lock-function-name-face font-lock-function-call-face
                font-lock-variable-name-face font-lock-variable-use-face font-lock-keyword-face
                font-lock-comment-delimiter-face font-lock-type-face font-lock-constant-face
                font-lock-builtin-face font-lock-preprocessor-face
                font-lock-negation-char-face font-lock-escape-face font-lock-number-face
                font-lock-operator-face font-lock-property-use-face font-lock-punctuation-face
                font-lock-bracket-face font-lock-delimiter-face font-lock-misc-punctuation-face
                typst-ts-markup-item-indicator-face typst-ts-markup-term-indicator-face
                typst-ts-markup-rawspan-indicator-face typst-ts-markup-rawspan-blob-face
                typst-ts-markup-rawblock-indicator-face typst-ts-markup-rawblock-lang-face
                typst-ts-markup-rawblock-blob-face
                typst-ts-error-face typst-ts-shorthand-face typst-ts-markup-linebreak-face
                typst-ts-markup-quote-face typst-ts-markup-url-face typst-ts-math-indicator-face))
            '';

            custom = ''
              (jinx-languages "de_DE en_US")
            '';
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

          marginalia = {
            config = "(marginalia-mode t)";
          };

          crdt = {
            defer = true;
          };

          flash = {
            bind' = ''
              ("M-c" . flash-jump)
            '';

            custom = ''
            '';

            custom-face = ''
              (flash-label ((t (:background "black" :foreground "white" :weight bold))))
            '';
          };

          visual-regexp-steroids = {
            custom = ''
              (vr/engine 'python)
            '';

            bind' = ''
              ("C-r C-r" . vr/query-replace)
            '';

            extraPackages = with pkgs; [
              python3
            ];
          };

          centaur-tabs = {
            demand = true;
            bind' = ''
              ("C-<next>" . centaur-tabs-forward)
              ("C-<prior>" . centaur-tabs-backward)
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

              (my/global-indent-bars-mode 0)
            '';
          };

          multiple-cursors = {
            bind' = ''
              ("C-," . mc/mark-previous-like-this)
              ("C-." . mc/mark-next-like-this)
            '';
          };

          org-typst-preview = {
            defer = true;

            package = ep: ep.trivialBuild (drv: {
              pname = "org-typst-preview";
              version = "0.3.1-unstable-2026-10-29";

              src = pkgs.fetchFromGitHub {
                owner = "roife";
                repo = drv.pname;
                rev = "46f22fc9a2f2259ead4a4253c511c935f3488195";
                hash = "sha256-IlSO+2/5fI4m7AQWEtf0i5J4m4kpG1mGv+e68gKSP+U=";
              };
            });

            commands = ''
              org-typst-preview-auto-mode
              org-typst-preview
            '';

            hook = ''
              (org-mode . (lambda ()
                (org-typst-preview-auto-mode)
                (org-typst-preview)))
            '';

            config = ''
              (advice-add 'org-edit-special :before-until 'nori/org-typst-edit)
            '';
          };

          smartparens = {
            hook = "prog-mode text-mode conf-mode";
            config = ''
              (require 'smartparens-config)

              (defun indent-between-pair (&rest _ignored)
                (newline)
                (indent-according-to-mode)
                (forward-line -1)
                (indent-according-to-mode))

              (sp-local-pair 'prog-mode "(" nil :post-handlers '((indent-between-pair "RET")))
              (sp-local-pair 'prog-mode "[" nil :post-handlers '((indent-between-pair "RET")))
              (sp-local-pair 'prog-mode "{" nil :post-handlers '((indent-between-pair "RET")))
            '';

            bind' = ''
              :map minibuffer-mode-map
              ("M-DEL" . sp-backward-kill-symbol)
            '';
          };

          org = {
            defer = true;

            package = null;

            bind = ''
              :map org-mode-map
              ("C-c C-#" . org-edit-special)

              :map org-src-mode-map
              ("C-c C-#" . org-edit-src-exit)
              ("C-s"     . org-edit-src-save)
            '';
          };


          org-super-agenda = {
            config = ''
              (require 'org-super-agenda)
              (org-super-agenda-mode 1)
            '';

            custom = ''
              (org-agenda-custom-commands '(
                 ("g" "Only Good View"
                  (
                   (agenda ""
                           (
                            (org-agenda-remove-tags t)
                            (org-agenda-span 7)
                            )
                           )

                   (alltodo ""
                            (
                             ;; Remove tags to make the view cleaner
                             (org-agenda-remove-tags nil)
                             (org-agenda-prefix-format "  %t  %s")
                             (org-agenda-overriding-header "CURRENT STATUS")

                             ;; Define the super agenda groups (sorts by order)
                             (org-super-agenda-groups
                              '(
                                (:name "Today"
                                  :date today)
                                (:discard (
                                  :tag "recurring"))
                                (:name "DEFCON 1 DO IT NOW"
                                  :priority "A"
                                )
                                (:name "In progress"
                                  :todo "WIP"
                                )
                                (:name "School"
                                  :tag "school"
                                )
                                (:name "Work"
                                  :tag "work")
                                (:name "Leisure"
                                  :tag "leisure"
                                  )
                                )
                              )
                             )
                            )
                   ))
                 ))
            '';
          };

          # straight

          straight = {
            defer = true;
          };

          # lsp stuff

          uxntal-mode = { };

          go-mode = {
            defer = true;
            extraPackages = with pkgs; [ gopls ];
          };

          apheleia = {
            hook = "prog-mode typst-ts-mode";

            config = ''
              (add-to-list 'apheleia-mode-alist '(sh-mode . shfmt))

              (add-to-list 'apheleia-mode-alist '(scheme-mode . lisp-indent))
              (setf (alist-get 'python-mode apheleia-mode-alist)
                    '(isort black))
              (add-to-list 'apheleia-mode-alist '(c-mode   . my/clang-format))
              (add-to-list 'apheleia-mode-alist '(c++-mode . my/clang-format))
              (add-to-list 'apheleia-formatters '(my/clang-format
                "clang-format" "--style=file:${./clang-format.yaml}"))
            '';

            extraPackages = with pkgs; [
              shfmt
            ];
          };

          web-mode = {
            hook = "html-mode css-mode";

            extraPackages = with pkgs; [
              prettier
              vscode-css-languageserver
              vscode-html-languageserver
            ];
          };

          typescript-mode = {
            defer = true;

            extraPackages = with pkgs; [
              typescript_5
              typescript-language-server
            ];
          };

          typst-ts-mode = {
            # TODO all of this just for a single patch...
            # elpaBuild, with which typst-ts-mode is built by default,
            # (afaik) does not support adding patches,
            # because it fetches & compiles the source in installPhase
            # fix: declare the entire package as trivialBuild
            package = ep: ep.trivialBuild {
              pname = "typst-ts-mode";
              version = "0.12.2";

              src = pkgs.fetchurl {
                url = "https://elpa.nongnu.org/nongnu/typst-ts-mode-0.12.2.tar";
                sha256 = "170q09ma08cksyg9bapfhid28f0xi46ssdv7bzdyiy3gc4x61i4b";
              };

              patches = [
                (pkgs.fetchpatch {
                  url = "https://codeberg.org/meow_king/typst-ts-mode/pulls/106.diff";
                  hash = "sha256-fKEN4+ZT9IMicd4ZSjSUhzHMwi1RM/IFglaVbkNB5/A=";
                })
              ];
            };

            mode = ''"\\.typ\\'"'';

            extraPackages = with pkgs; [
              prettypst
              tinymist
              typst
            ];

            hook = ''
              (typst-ts-mode . (lambda () (setq-local tab-width 2)))
            '';

            bind' = ''
              :map typst-ts-mode-map
              ("C-c C-p" . nori/typst-pin)
            '';

            config = ''
              (require 'lsp-typst)
              (lsp-register-client (make-lsp-client
                :server-id 'nori/tinymist
                :new-connection (lsp-stdio-connection "tinymist")
                :activation-fn (lsp-activate-on "typst")
                :initialized-fn
                  (lambda (workspace)
                    (with-lsp-workspace workspace
                      (lsp--set-configuration
                       (lsp-configuration-section "tinymist")))

                    (lsp-send-execute-command "tinymist.doStartBrowsingPreview"
                      (vector (vector "--host=127.0.0.1:0"
                                      "--control-plane-host=127.0.0.1:0"
                                      "--data-plane-host=127.0.0.1:0"
                                      "--open" buffer-file-name))))
                :synchronize-sections '("tinymist")
                :notification-handlers (ht ("tinymist/documentOutline" #'ignore))))

              (add-hook 'lsp-nori/tinymist-after-open-hook (lambda ()
                (when nori/typst-pin (nori/typst-pin))))

              (require 'apheleia)
              (add-to-list 'apheleia-mode-alist '(typst-ts-mode . prettypst))
              (add-to-list 'apheleia-formatters '(prettypst "prettypst" "--use-std-in" "--use-std-out"))
            '';

            custom = ''
              (typst-ts-mode-indent-offset 2)
              (typst-ts-enable-raw-blocks-highlight t)
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
            extraPackages = with pkgs; [ stylua ];
          };

          json-mode = {
            defer = true;
          };

          meson-mode = {
            defer = true;
          };

          lsp-mode = {
            custom = ''
              (eldoc-idle-delay 0)
              (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)

              (lsp-enable-on-type-formatting nil)
              (lsp-headerline-breadcrumb-enable nil)
              (lsp-idle-delay 0)
              (lsp-semantic-tokens-enable t)

              ;; performance
              (lsp-log-io nil)
              (read-process-output-max (* 1024 1024))

              (lsp-clients-clangd-args '("--header-insertion=never"))
              (lsp-clients-lua-language-server-command "lua-language-server")
            '';

            hook = ''
              (c-mode          . lsp-deferred)
              (go-mode         . lsp-deferred)
              (sh-mode         . lsp-deferred)
              (typescript-mode . lsp-deferred)
              (typst-ts-mode   . lsp-deferred)

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

              (advice-add 'lsp-clients-lua-language-server-test :override
                (lambda () t))
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
        };
      };
    };
  }];
}
