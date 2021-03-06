;;; package --- Simple configuration for PHP + Js development
;;; Commentary:
;;; Code:
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

;; emacs window meneger setup
(require 'exwm)
(require 'exwm-config)
(exwm-config-example)
(require 'exwm-systemtray)
(exwm-systemtray-enable)

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
(setq-default indent-tabs-mode nil)

; store cutomizations in custom.el file
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file) (load custom-file))

;; Define custom variables
(defvar projectile-project-folder '("~/Projects/i4/"))

(global-linum-mode)
(display-time-mode t)
(setq display-time-day-and-date t)
(setq display-time-24hr-format t)
(setq linum-format "%4d \u2502")
(display-battery-mode 1)
(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
(put 'dired-find-alternate-file 'disabled nil)

;; Define global keybindings
(global-unset-key "\C-z")
(global-set-key "\C-z" 'advertised-undo)

;; Custom functions
;; ===============================================

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

(use-package helm-rg
  :ensure t
  :after helm-projectile
  :config
  (define-key projectile-mode-map (kbd "C-c p s s") 'helm-rg)
)
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
		(projectile-mode 1))

;; Dired extensions and utils
(use-package dired-sidebar
  :ensure t
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :commands (dired-sidebar-toggle-sidebar)
  :config
  (add-hook 'dired-sidebar-mode-hook
            (lambda () (linum-mode -1)))
  (setq dired-sidebar-theme 'nerd)
  (setq dired-sidebar-theme 'vscode)
  (setq dired-sidebar-subtree-line-prefix "  ")
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-width 38))

;; Icons for dired sidebar
(use-package vscode-icon
  :ensure t
  :after dired-sidebar
  )

;; Global customizations
;; ===============================================

;; An atom-one-dark theme for smart-mode-line
(use-package smart-mode-line-atom-one-dark-theme
  :ensure t)

;; smart-mode-line
(use-package smart-mode-line
  :config
  (setq sml/theme 'atom-one-dark)
  (sml/setup))

(use-package doom-themes
  :ensure t
  :config
  ;; Global settings (defaults)
  (load-theme 'doom-one t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config))


(set-frame-font
 "-SRC-Hack-normal-normal-normal-*-13-*-*-*-c-*-iso10646-1")

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


(use-package ac-php
  :ensure t
  :after php-mode
  :config
  (define-key php-mode-map (kbd "C-t f") 'ac-php-find-symbol-at-point)  ;; Jump to definition (optional)
  (define-key php-mode-map (kbd "C-t b") 'ac-php-location-stack-back))   ;; Return back (optional)

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
  :after php-mode
  :load-path ("~/.emacs.d/src/geben/")
  :config
  (setq geben-pause-at-entry-line nil
        geben-show-breakpoints-debugging-only -1)
  (define-key php-mode-map (kbd "<f9>") 'geben-add-current-line-to-predefined-breakpoints)
  (global-set-key (kbd "<f5>") 'geben)
  (global-set-key (kbd "<f10>") 'geben-end))

(use-package csv-mode
  :ensure t
  :config
  :mode (("\\.[Cc][Ss][Vv]\\'" . csv-mode)
         ("\\.[Cc][Ss][Vv]\\'" . csv-align-mode))
)

(use-package php-mode
        :ensure t
        :after ac-php
	:config
		(add-hook 'php-mode-hook
			  (lambda ()
                            (add-hook 'before-save-hook 'php-cs-fixer-before-save)
                            (add-hook 'before-save-hook 'delete-trailing-whitespace)
			    ;; Enable ElDoc support (optional)
			    (ac-php-core-eldoc-setup)
                            (company-mode t)
			    (set (make-local-variable 'company-backends)
				 '((company-ac-php-backend company-dabbrev-code)
				   company-capf company-files))))
		(setq whitespace-line-column 120) ;; limit line length
                (setq whitespace-style '(face lines-tail))
                (setq-default show-trailing-whitespace t)
                (setq php-cs-fixer-rules-level-part-options (quote ("@PSR2")))
                (setq php-cs-fixer-rules-fixer-part-options
                  (quote("no_multiline_whitespace_before_semicolons" "no_unused_imports")))
		(define-key php-mode-map (kbd "C-t f") 'ac-php-find-symbol-at-point)  ;; Jump to definition (optional)
		(define-key php-mode-map (kbd "C-t b") 'ac-php-location-stack-back)   ;; Return back (optional)
)

(use-package flycheck
  :ensure t
  :init (global-flycheck-mode))

;; Magit settings
;; ===============================================

(use-package magit
  :ensure t
  :config
  (global-set-key (kbd "C-x g") 'magit-status)
)

;; Styles section css
;; ===============================================
(use-package css-mode
  :config
  (setq auto-mode-alist
     (cons '("\\.css\\'" . css-mode) auto-mode-alist)))

(use-package com-css-sort
  :ensure t
  :after css-mode
  :config
  (setq com-css-sort-sort-type 'alphabetic-sort)
  ;; Sort attributes inside block.
  (define-key css-mode-map (kbd "C-c C-s") #'com-css-sort-attributes-block)
  ;; Sort attributes through the whole document.
  (define-key css-mode-map (kbd "C-c C-d") #'com-css-sort-attributes-document))

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
  :config
  (add-hook 'php-mode-hook 'whitespace-mode))

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
  (setq flycheck-eslintrc "~/.eslintrc"))

(provide 'init)
;;; init.el ends here
