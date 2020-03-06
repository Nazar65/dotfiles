(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("e1ecb0536abec692b5a5e845067d75273fe36f24d01210bf0aa5842f2a7e029f" default)))
 '(package-selected-packages
   (quote
    (ag dired-sidebar peep-dired dired-hacks-utils helm-org-rifle helm-swoop helm-describe-modes helm-projectile helm-ag helm-descbinds helm projectile company-php doom-themes ac-php php-mode use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(use-package php-mode :ensure t)
(unless (package-installed-p 'ac-php)
    (package-refresh-contents)
    (package-install 'ac-php))
(require 'php-mode)
(add-hook 'php-mode-hook
          '(lambda ()
             ;; Enable company-mode
             (company-mode t)
             (require 'company-php)

             ;; Enable ElDoc support (optional)
             (ac-php-core-eldoc-setup)

             (set (make-local-variable 'company-backends)
                  '((company-ac-php-backend company-dabbrev-code)
                    company-capf company-files))

             ;; Jump to definition (optional)
             (define-key php-mode-map (kbd "M-]")
               'ac-php-find-symbol-at-point)

             ;; Return back (optional)
             (define-key php-mode-map (kbd "M-[")
               'ac-php-location-stack-back)))
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
  (setq doom-themes-treemacs-theme "doom-colors") ; use the colorful treemacs theme
  (doom-themes-treemacs-config)
  
  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))

; Working with projects

;projectile path to project folders
(defvar projectile-project-folder '("~/Projects/"))
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
	:hook
		(projectile-mode . helm-projectile-on)
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

; Efficiently hopping squeezed lines powered by Emacs helm interface
(use-package helm-swoop
	:ensure t
	:defer 0.2
	:after helm
	:config
	; need to setup
)

;Rifle through your Org-mode buffers and acquire your target
(use-package helm-org-rifle
	:ensure t
	:after org)

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

;; Disabling things
;;-----------------------------------------------------------------------
(menu-bar-mode -1) 
(toggle-scroll-bar -1) 
(tool-bar-mode -1) 
(global-unset-key "\C-z")
(global-set-key "\C-z" 'advertised-undo)
