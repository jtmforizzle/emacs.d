;;
;; General config options
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen 1)
(winner-mode)
(show-paren-mode 1)
(setq make-backup-files nil)


(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
		("marmalade" . "http://marmalade-repo.org/packages/")
		("melpa" . "http://melpa.org/packages/")))
(package-initialize)

;; Bootstrap the use-package install process
(unless (package-installed-p 'use-package)
  (progn
    (unless package-archive-contents
      (package-refresh-contents))
    (package-install 'use-package)))

(setq use-package-always-ensure t)
(require 'use-package)


;; avy - jump to things in emacs tree-style
(use-package avy
  :bind
  (("C-;" . avy-goto-char-2)
  ("C-:" . avy-goto-line)))

;; vim keybindings
(use-package evil
  :init
  (setq evil-want-C-u-scroll t)
  (setq evil-search-module 'evil-search)
  (setq evil-want-fine-undo nil)
  :config
  (evil-mode t)
  (modify-syntax-entry ?_ "w")
  ;; Add modes to evil-emacs-state-modes to have that mode start in
  ;; emacs mode instead of evil mode
  ;;(add-to-list 'evil-emacs-state-modes 'magit-mode)
  )

;; Bind the vim escape key to custom sequence
(use-package evil-escape
  :after evil
  :init
  (setq evil-escape-key-sequence "jk")
  (setq evil-escape-delay .1)
  :config
  (evil-escape-mode 1))

;; fixes some compatibility issues between magit and evil-mode
;; not sure if i really need this
(use-package evil-magit
  :after (evil magit)
  :init
  (setq evil-magit-use-y-for-yank t))


;; for incremental completeness and selection narrowing
(use-package helm)

(use-package helm-ag)

(use-package helm-projectile
  :disabled t
  :after projectile
  :config
  (helm-projectile-on))

(use-package ido
  :config
  (setq ido-enable-flex-matching t)
  (setq ido-use-faces nil)
  (ido-mode t)
  (ido-everywhere t))

(use-package magit
  :bind
  (("<f9>" . magit-status)))

(use-package projectile
  :disabled t
  :init
  (setq projectile-enable-caching t)
  :config
  (projectile-global-mode nil))

(use-package org
  :init
  (setq org-startup-indented t)
  (setq org-agenda-files (list "~/notes/todo.org"))
  (bind-key "C-c l" 'org-store-link)
  (bind-key "C-c a" 'org-agenda)
  :config
  (bind-key "<S-left>" 'windmove-left org-mode-map)
  (bind-key "<S-right>" 'windmove-right org-mode-map)
  (bind-key "<S-down>" 'windmove-down org-mode-map)
  (bind-key "<S-up>" 'windmove-up org-mode-map))

;; smart M-x enhancements
(use-package smex
  :bind
  (("M-x" . smex)))

;; for easily jumping between windows. Normally this just
;; uses <S-left>, <S-right>, etc, but add hjkl to get vim movements
(use-package windmove
  :init
  (setq framemove-hook-into-windmove t)
  :config
  (windmove-default-keybindings)
  :bind
  (("C-S-h" . windmove-left)
   ("C-S-l" . windmove-right)
   ("C-S-k" . windmove-up)
   ("C-S-j" . windmove-down)))

(use-package monokai-theme
  :config
  (set-face-attribute 'default nil :height 115))


;; These packages are ignored on windows
(unless (eq system-type 'windows-nt)
  (use-package exec-path-from-shell
    :init
    (setq exec-path-from-shell-variables '("PATH" "NDK"))
    :config
    (exec-path-from-shell-initialize))

  (use-package gtags
    :init
    (setq gtags-suggested-key-mapping t))
)


;; Only set up ocaml stuff if it's installed
(if (file-exists-p (expand-file-name "~/.opam"))
    (progn
      ;; Setup environment variables using opam
      (dolist (var (car (read-from-string
                         (shell-command-to-string "opam config env --sexp"))))
        (setenv (car var) (cadr var)))

      ;; Update the emacs path
      (setq exec-path (append (parse-colon-path (getenv "PATH"))
                              (list exec-directory)))

      (setq opam-share (substring (shell-command-to-string "opam config var share 2> /dev/null") 0 -1))
      (add-to-list 'load-path (concat opam-share "/emacs/site-lisp")
                   )

      (use-package tuareg
        :config
        (add-hook 'tuareg-mode-hook 'utop-minor-mode)
        (add-hook 'tuareg-mode-hook 'merlin-mode))

      ;; utop
      (use-package utop
        :ensure t
        :config
        (autoload 'utop "utop" "Toplevel for OCaml" t)
        (autoload 'utop-minor-mode "utop" "Minor mode for utop" t)
        )

      ;; merlin
      (use-package merlin
        :config
        (add-hook 'tuareg-mode-hook 'merlin-mode t)
        (add-hook 'caml-mode-hook 'merlin-mode t)
        (setq merlin-use-auto-complete-mode 'easy)
        (setq merlin-command 'opam))
      ))


;;
;; Editing settings
;;
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq-default c-basic-offset 4)
(setq-default truncate-lines t)
(setq-default show-paren-delay 0)
(show-paren-mode 1)

;;
;; Global keybindings unrelated to a package
;;
(global-set-key (kbd "C-x C-b") 'ibuffer)
(global-set-key (kbd "<f7>")  'compile)

(when (eq system-type 'windows-nt)
	(set-face-attribute 'default nil :family "Consolas" :height 115))

(when (eq system-type 'gnu/linux)
   ;; Mimic gnome-terminal
   (global-set-key (kbd "C-S-v") 'x-clipboard-yank)
   (global-set-key (kbd "C-S-c") 'clipboard-kill-ring-save)

   ;; Use system clipboard for cut and paste
   (setq x-select-enable-clipboard nil))


;; os x key bindings
(when (eq system-type 'darwin) ;; mac specific settings
  (setq mac-option-modifier 'alt)
  (setq mac-command-modifier 'meta)
  (global-set-key [kp-delete] 'delete-char) ;; sets fn-delete to be right-delete
  (global-set-key (kbd "M-c") 'clipboard-kill-ring-save)
  (global-set-key (kbd "M-v") 'clipboard-yank)
  )
