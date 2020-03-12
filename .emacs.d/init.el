; -*- lexical-binding: t; -*-
;; Speed up startup
(setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))

(setq file-name-handler-alist nil)

(require 'package)

(customize-set-variable 'package-archives
                        `(,@package-archives
                          ("melpa" . "https://melpa.org/packages/")
                          ;; ("marmalade" . "https://marmalade-repo.org/packages/")
                          ("org" . "https://orgmode.org/elpa/")
                          ;; ("user42" . "https://download.tuxfamily.org/user42/elpa/packages/")
                          ;; ("emacswiki" . "https://mirrors.tuna.tsinghua.edu.cn/elpa/emacswiki/")
                          ;; ("sunrise" . "http://joseito.republika.pl/sunrise-commander/")
                          ))
(setq package-enable-at-startup nil)

(setq frame-inhibit-implied-resize t)

(package-initialize)

(setq-default use-package-always-ensure nil ; Auto-download package if not exists
              use-package-always-defer nil ; Always defer load package to speed up startup
              use-package-verbose t ; Don't report loading details
              use-package-expand-minimally t  ; make the expanded code as minimal as possible
              use-package-enable-imenu-support t) ; Let imenu finds use-package definitions


; unless use-package is already installed
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(put 'use-package 'lisp-indent-function 1)

(use-package use-package-core
  :custom
  ;; (use-package-verbose t)
  ;; (use-package-minimum-reported-time 0.005)
  (use-package-enable-imenu-support t))

; Basics
; settings for backup, auto save and lock files
(setq create-lockfiles nil)
(setq backup-directory-alist '((".*" . "~/.emacs.d/backups/")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/backups/" t)))

; store cutomizations in custom.el file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file) (load custom-file))

;; Define custom variables
(defvar projectile-project-folder '("~/Projects/"))

(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)

;; Define global keybindings
(global-unset-key "\C-z")
(global-set-key "\C-z" 'advertised-undo)


;; Custom functions
;; ===============================================

(defun copy-line (arg)
      "Copy lines (as many as prefix argument) in the kill ring"
      (interactive "p")
      (kill-ring-save (line-beginning-position)
                      (line-beginning-position (+ 1 arg)))
      (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

(global-set-key "\C-c\C-k" 'copy-line)

;; use xclip to copy/paste in emacs-nox
(unless window-system
  (when (getenv "DISPLAY")
    (defun xclip-cut-function (text &optional push)
      (with-temp-buffer
	(insert text)
	(call-process-region (point-min) (point-max) "xclip" nil 0 nil "-i" "-selection" "clipboard")))
    (defun xclip-paste-function()
      (let ((xclip-output (shell-command-to-string "xclip -o -selection clipboard")))
	(unless (string= (car kill-ring) xclip-output)
	  xclip-output )))
    (setq interprogram-cut-function 'xclip-cut-function)
    (setq interprogram-paste-function 'xclip-paste-function)
    ))

;;Move backups file to another folder
(setq emacs-persistence-directory 
  (expand-file-name "var" user-emacs-directory))
(let ((dir (expand-file-name "backup" emacs-persistence-directory)))
  (unless (file-directory-p dir)
    (make-directory dir t))
  (setq backup-directory-alist `(("." . ,dir))))

(let ((backup-dir (concat emacs-persistence-directory "tramp-backup/")))
  (setq tramp-persistency-file-name (concat emacs-persistence-directory
                                            "tramp")
        tramp-backup-directory-alist `(("." . ,backup-dir))
        tramp-auto-save-directory (concat emacs-persistence-directory
                                          "tramp-auto-save/"))
  (dolist (d (list tramp-auto-save-directory backup-dir))
    (unless (file-exists-p d)
      (make-directory d t))))


;; System packages
;; ===============================================

; Enforce a sneaky Garbage Collection strategy 
; to minimize GC interference with the activity.
(use-package gcmh
	:ensure t
	:diminish
	:init
		(gcmh-mode 1))

(use-package system-packages
	:ensure t
	:custom
		(system-packages-noconfirm t))

(use-package use-package-ensure-system-package :ensure t)

; Hide minor modes in modeline
(use-package diminish :ensure t :defer 0.1)

; Make bindings that stick around.
(use-package hydra :ensure t :defer 0.1)

; Treat undo history as a tree
(use-package undo-tree
	:ensure t
	:defer 0.1
	:diminish
	:config
		(global-set-key (kbd "C-?") 'undo-tree-redo))

; The long lost Emacs string manipulation library.
(use-package s
	:demand
	:ensure t)

; Modern API for working with files and directories
(use-package f
	:demand
	:ensure t)

; A modern list library for Emacs
(use-package dash
	:demand
	:ensure t)

;; HELM - Emacs incremental completion and selection narrowing framework
; ----------
(use-package helm
	:ensure t
	:diminish
	:bind (("C-x b" . 'helm-mini)
	       ("C-x f" . 'helm-find-files))
	:config
		(define-key global-map [remap find-file] 'helm-find-files)
		(define-key global-map [remap occur] 'helm-occur)
		(define-key global-map [remap list-buffers] 'helm-buffers-list)
		(define-key global-map [remap dabbrev-expand] 'helm-dabbrev)
		(define-key global-map [remap execute-extended-command] 'helm-M-x)

		(global-set-key (kbd "M-x") 'helm-M-x)
		(global-set-key (kbd "M-y") 'helm-show-kill-ring)

		(setq helm-split-window-in-side-p t
			  helm-M-x-fuzzy-match t
			  helm-locate-fuzzy-match t
			  helm-semantic-fuzzy-match t
			  helm-apropos-fuzzy-match t
			  helm-etag-fuzzy-match t
			  helm-buffers-fuzzy-matching t
			  helm-recentf-fuzzy-match t

			  helm-autoresize-min-height 20
		)
		(require 'helm-config)
		(helm-mode 1))

; A helm frontend for describe-bindings.
(use-package helm-descbinds
	:ensure t
	:defer 0.2
	:after helm
	:bind(("<f1> b" . helm-descbinds))
)

;The silver searcher with helm interface
(use-package helm-ag
	:ensure t
	:defer 0.2
	:after helm)

; projectile extension for Helm
(use-package helm-projectile
	:ensure t
	:defer t
	:after helm
	:diminish
	:hook (projectile-mode . helm-projectile-on)
	:commands helm-projectile
	:config
	(helm-projectile-on))

; helm interface for describe mode
(use-package helm-describe-modes
	:ensure t
	:defer 0.2
	:after helm
	:config
		(global-set-key [remap describe-mode] #'helm-describe-modes))

;; Projectile mode and extensions
(use-package projectile
	:ensure t
	:after helm
	:config
		(setq projectile-enable-caching nil
			  projectile-project-search-path projectile-project-folder
			  projectile-globally-ignored-file-suffixes '("#" "~" ".swp" ".o" ".so" ".pyc" ".jar" "*.class")
			  projectile-globally-ignored-directories '(".git" "node_modules" "__pycache__" ".mypy_cache")
			  projectile-globally-ignored-files '("TAGS" "tags" ".DS_Store" "GTAGS")
			  projectile-mode-line-prefix " - "
			  projectile-tags-command "ctags -R -e --languages=php --fields=afiklmnst --file-scope=yes --format=2"
		)
		
		(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
		(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
		(projectile-global-mode 1))


;; Editor extensions
(use-package crux
	:ensure t
	:defer 0.5
	:diminish
	:config
		(global-set-key (kbd "C-k") 'crux-smart-kill-line)
		(global-set-key (kbd "C-M-RET") 'crux-smart-open-line-above) ; need to check
		(global-set-key (kbd "M-RET") 'crux-smart-open-line)
		(global-set-key (kbd "C-x 4 t") 'crux-transpose-windows)
		(global-set-key (kbd "C-c d") 'crux-duplicate-current-line-or-region)
		(global-set-key (kbd "C-c M-d") 'crux-duplicate-and-comment-current-line-or-region)
		(global-set-key (kbd "C-c R") 'crux-rename-file-and-buffer)
		(global-set-key (kbd "C-c I") 'crux-find-user-init-file)
	  )


;; Dired extensions and utils
; ----------
; utilities and helpers for dired-hacks collection
(use-package dired-hacks-utils
	:ensure t
	:after dired
	:config
		(bind-key "<tab>" #'dired-subtree-toggle dired-mode-map)
		(bind-key "<backtab>" #'dired-subtree-cycle dired-mode-map))

; peep at files in another window from dired buffers
(use-package peep-dired
	:ensure t
	:after dired)

; tree browser leveraging dired
(use-package dired-sidebar
	:ensure t
	:defer t
	:bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
	:commands (dired-sidebar-toggle-sidebar)
	:config
		(setq dired-sidebar-subtree-line-prefix "__")
		(setq dired-sidebar-width 38)
		(setq dired-sidebar-theme 'nerd))


;; Global customizations
;; ===============================================
(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  
  ;; Enable custom neotree theme (all-the-icons must be installed!)
  (doom-themes-neotree-config)
  ;; or for treemacs users
  (setq doom-themes-treemacs-theme "doom-one") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

(use-package powerline
  :ensure t
  :config
  (powerline-default-theme))

;; Global programming packages
;; ===============================================
(use-package company
  :ensure t
  :config
  (global-company-mode t))

(use-package company-php
  :ensure t
  :after company)

(use-package php-cs-fixer
	:ensure t
	:after php-mode
	:config
	;; Just in case
	:load-path ("~/.emacs.d/src/php-cs-fix/")
)
(use-package ac-php :ensure t)

;; PHP settings
;; ===============================================
(use-package phpunit
  :ensure t
  :after php-mode
  :config
		;phpunit settings
                (setq phpunit-root-directory "./")
                (setq phpunit-configuration-file "./dev/tests/unit/phpunit.xml.dist")
		(define-key php-mode-map (kbd "C-t t") 'phpunit-current-test)
		(define-key php-mode-map (kbd "C-t c") 'phpunit-current-class)
		(define-key php-mode-map (kbd "C-t p") 'phpunit-current-project)
)

(use-package geben
  :ensure t
  :after php-mode
  :config
  (setq eben-show-breakpoints-debugging-only nil)
  (global-set-key (kbd "<f5>") 'geben)
  (global-set-key (kbd "<f10>") 'geben-stop)
  (global-set-key (kbd "<f12>") 'geben-set-breakpoint-line)

)

(use-package php-mode
        :ensure t
	:requires ac-php
	:defer t
	:config
		(add-hook 'php-mode-hook
				  (lambda () (add-hook 'before-save-hook #'php-cs-fixer--fix nil 'local)
		
		;; Enable ElDoc support (optional)
		(ac-php-core-eldoc-setup)
		
		(set (make-local-variable 'company-backends)
			 '((company-ac-php-backend company-dabbrev-code)
			   company-capf company-files))))
		
		(define-key php-mode-map (kbd "C-t f") 'ac-php-find-symbol-at-point)  ;; Jump to definition (optional)
		(define-key php-mode-map (kbd "C-t b") 'ac-php-location-stack-back)   ;; Return back (optional)
)

(use-package flymake-php
	:ensure t
	:after php-mode
	:config
	(add-hook 'php-mode-hook 'flymake-php-load)
)
;; Magit settings
;; ===============================================

(global-set-key (kbd "C-x g") 'magit-status)

;; Nxml settings
;; ===============================================

;; Ident xml files
(add-hook 'hack-local-variables-hook
   (lambda ()
     (save-excursion
       (goto-char (point-min))
       (when (search-forward-regexp "^<\\?xml" 6 0)
         (nxml-mode)
 ))))

;; set nxml line identation
(setq nxml-child-indent 4 nxml-attribute-indent 4)

;; Javascript setting
;; ==============================================

;; General javascript mode
(use-package js2-mode
  :ensure t
  )

;; Autocomplete mode for javascript
(use-package ac-js2
  :ensure t
  :after js2-mode
  :config
  (add-to-list 'company-backends 'ac-js2-company)
  (add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-to-list 'company-backends 'ac-js2-company)
  )
;; Run jscs sniffer to fix edited file
(use-package jscs
  :ensure t
  :config
  (add-hook 'js2-mode-hook #'jscs-fix-run-before-save)
  (add-hook 'js2-mode-hook
  (lambda ()
    (flymake-eslint-enable)))
)


