(setq inhibit-startup-message t)

(menu-bar-mode -1)            ; no menu bar
(tool-bar-mode -1)            ; no tools bar
(scroll-bar-mode -1)          ; no scroll bars
(tooltip-mode -1)             ; no tooltips
(set-fringe-mode 10)          ; frame edges set to 10px
(column-number-mode 1)        ; modeline shows column number
(save-place-mode 1)           ; remember cursor position
(recentf-mode 1)              ; remember recent files
(savehist-mode 1)             ; enable history saving
(electric-pair-mode 1)        ; enable keep pairs balanced
(global-auto-revert-mode t)   ; Load external changes
(global-hl-line-mode 1)       ; Current line highlight
(delete-selection-mode t)     ; Overwrite/delete selected text

(setq display-line-numbers-type 'relative)
(dolist (mode '(prog-mode-hook
                conf-mode-hook))
(add-hook mode (lambda () (display-line-numbers-mode 1))))

(setq mouse-wheel-scroll-amount '(2 ((shift) . 1))
        mouse-wheel-progressive-speed nil
        mouse-wheel-follow-mouse 't
        scroll-step 1)

(fset 'yes-or-no-p 'y-or-n-p)

(setq use-dialog-box nil)

(setq dired-kill-when-opening-new-dired-buffer t)

(setq vc-follow-symlinks t)

(global-unset-key (kbd "C-z"))

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(setq custom-file (locate-user-emacs-file "custom.el"))
(load custom-file 'noerror 'nomessage)

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                        ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(unless package-archive-contents
(package-refresh-contents))

(unless (package-installed-p 'use-package)
(package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(use-package evil
:init
(setq evil-want-integration t
        evil-want-keybinding nil
        evil-vsplit-window-right t
        evil-split-window-below t
        evil-undo-system 'undo-redo)
(evil-mode))

(use-package evil-collection
:after evil
:config
(add-to-list 'evil-collection-mode-list 'help)
(evil-collection-init))

(use-package evil-terminal-cursor-changer
:ensure t
:config
(unless (display-graphic-p)
    (evil-terminal-cursor-changer-activate)))

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-moonlight t)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :hook
  (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-enable-word-count t))

(use-package diminish)
(diminish 'visual-line-mode "")
(diminish 'eldoc-mode "")
(diminish 'flyspell-mode "Spell")
(diminish 'evil-collection-unimpaired-mode "")

(use-package vertico
  :bind (:map vertico-map
              ("C-j" . vertico-next)
              ("C-k" . vertico-previous)
              ("C-f" . vertico-exit)
              :map minibuffer-local-map
              ("M-h" . backward-kill-word))
  :custom
  (vertico-cycle t)
  :init
  (vertico-mode))

(use-package marginalia
  :after vertico
  :init
  (marginalia-mode))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)))

(use-package consult)

(use-package which-key
  :defer 0
  :diminish
  :config
  (which-key-mode 1)
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-allow-imprecise-window-fit nil
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-description-length 25
        which-key-allow-imprecise-window-fit nil
        which-key-separator " → " ))

(use-package company
  :defer 2
  :diminish
  :init
  (add-hook 'after-init-hook 'global-company-mode)
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations t)
  (company-require-match nil)
  :config
  ;; TAB não navega nem completa no company
  (define-key company-active-map (kbd "TAB") nil)
  (define-key company-active-map (kbd "<tab>") nil)
  ;; ENTER aceita a seleção
  (define-key company-active-map (kbd "RET")
              #'company-complete-selection)
  ;; Priorizar snippets no menu
  (setq company-backends
        '((company-yasnippet company-capf company-files))))

(use-package company-box
  :diminish
  :hook (global-company-mode . company-box-mode))

(use-package rainbow-delimiters
  :hook ((prog-mode . rainbow-delimiters-mode))
  :config
  (set-face-foreground 'rainbow-delimiters-depth-1-face "#c66")
  (set-face-foreground 'rainbow-delimiters-depth-2-face "#6c6")
  (set-face-foreground 'rainbow-delimiters-depth-3-face "#69f")
  (set-face-foreground 'rainbow-delimiters-depth-4-face "#cc6")
  (set-face-foreground 'rainbow-delimiters-depth-5-face "#6cc")
  (set-face-foreground 'rainbow-delimiters-depth-6-face "#c6c")
  (set-face-foreground 'rainbow-delimiters-depth-7-face "#ccc")
  (set-face-foreground 'rainbow-delimiters-depth-8-face "#999")
  (set-face-foreground 'rainbow-delimiters-depth-9-face "#666"))

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode))

(use-package magit
  :defer 2
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package treemacs
  :ensure t
  :defer t
  :bind (("C-\\" . 'treemacs))
  :config
  ;; Ajustes visuais
  (setq treemacs-width 33
        treemacs-indentation 2
        treemacs-position 'right
	;; Usar 'M-x treemacs-select-window' para dar foco
        treemacs-is-never-other-window t
        treemacs-show-hidden-files t)
  ;; Ativar ícones (se tiver fonts compatíveis)
  (when (fboundp 'treemacs-resize-icons)
    (treemacs-resize-icons 14))
  :hook
  (treemacs-mode . treemacs-project-follow-mode))

(use-package treemacs-projectile
  :after (treemacs projectile))

(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :ensure t
  :config
  ;; Opções adicionais (customizáveis)
  (setq lsp-treemacs-error-list-current-project t)
  (setq lsp-treemacs-sync-mode t))

(use-package cc-mode
  :config
  (defun bmacs/c-mode-config ()
    "Configuração personalizada para C-mode."
    (c-set-style "k&r")
    (setq c-basic-offset 4
          indent-tabs-mode nil))
  :hook ((c-mode . bmacs/c-mode-config)))

(use-package flycheck
  :init (global-flycheck-mode))

(use-package lsp-mode
  :hook ((c-mode . lsp))
  :commands lsp
  :config
  (setq lsp-clients-clangd-executable "/usr/bin/clangd")
  (setq lsp-completion-provider :capf))

(use-package lsp-ui
  :commands lsp-ui-mode
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode))

(use-package yasnippet
  :init (setq yas-snippet-dirs '("~/.config/emacs/yas"))
  :hook ((prog-mode . yas-minor-mode)
	 (text-mode . yas-minor-mode))
  :config (yas-reload-all))

(set-face-attribute 'default nil :font "IBM Plex Mono 12")
(set-face-attribute 'variable-pitch nil :font "IBM Plex Mono 12")
(set-face-attribute 'fixed-pitch nil :font "IBM Plex Mono 12")

(set-face-attribute 'font-lock-comment-face nil :slant 'italic)
