(require 'color-theme)
(require 'zenburn)
(zenburn)

(require 'ido)
(ido-mode t)

(require 'undo-tree)
(require 'evil)
(define-key evil-normal-state-map "q" 'lgrep) 
(define-key evil-normal-state-map "Q" 'compile) 
(define-key evil-normal-state-map "'" 'vc-dir) 
(define-key evil-normal-state-map "\"" 'vc-next-action) 
(define-key evil-normal-state-map [escape] 'keyboard-quit)
(define-key evil-visual-state-map [escape] 'keyboard-quit)
(defun minibuffer-keyboard-quit ()
  (interactive)
  (if (and delete-selection-mode transient-mark-mode mark-active)
      (setq deactivation-mark t)
    (when (get-buffer "*Completions*") (delete-windows-on "*Completions"))
    (abort-recursive-edit)))
(define-key minibuffer-local-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-ns-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-completion-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-must-match-map [escape] 'minibuffer-keyboard-quit)
(define-key minibuffer-local-isearch-map [escape] 'minibuffer-keyboard-quit)
(global-set-key [escape] 'keyboard-quit)

(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)
(require 'linum-relative)
(setq linum-relative-current-symbol ">>")
(setq linum-relative t)
(global-linum-mode 1)

(define-minor-mode comma-mode
  "mode that hangs off the comma key in evil command mode"
  :keymap (make-sparse-keymap))

(define-key evil-normal-state-map "," comma-mode-map)
(define-key comma-mode-map "b" 'ido-switch-buffer)
(define-key comma-mode-map "e" 'ido-find-file)

(evil-mode 1)

(add-to-list 'load-path "/u/jimmy/.emacs.d/site-lisp/rosemacs")
(require 'rosemacs)
(invoke-rosemacs)

(add-to-list 'load-path "/u/jimmy/.emacs.d/site-lisp")
(require 'stumpwm-mode)

(setq inferior-lisp-program "sbcl") 
(add-to-list 'load-path "/usr/share/emacs/site-lisp/slime/")
(require 'slime)

(slime-setup '(slime-fancy slime-asdf slime-ros))

(define-key evil-normal-state-map ";" ros-keymap)

(setq ros-completion-function 'ido-completing-read)

(set-default-font "Terminus-9")
(setq default-frame-alist '((font . "Terminus-9")))

(menu-bar-mode -1)
(tool-bar-mode -1)

(add-to-list 'load-path "~/.emacs.d/site-lisp/jade-mode")
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl$" . sws-mode))
(add-to-list 'auto-mode-alist '("\\.jade$" . jade-mode))

(defun c-lineup-arglist-tabs-only (ignored)
  "Line up argument lists by tabs, not spaces"
  (let* ((anchor (c-langelem-pos c-syntactic-element))
	 (column (c-langelem-2nd-pos c-syntactic-element))
	 (offset (- (1+ column) anchor))
	 (steps (floor offset c-basic-offset)))
    (* (max steps 1)
       c-basic-offset)))

(add-hook 'c-mode-common-hook
          (lambda ()
            ;; Add kernel style
            (c-add-style
             "linux-tabs-only"
             '("linux" (c-offsets-alist
                        (arglist-cont-nonempty
                         c-lineup-gcc-asm-reg
                         c-lineup-arglist-tabs-only))))))

(add-hook 'c-mode-hook
          (lambda ()
            (let ((filename (buffer-file-name)))
              ;; Enable kernel mode for the appropriate files
              (when (and filename
                         (string-match (expand-file-name "~/src/linux-trees")
                                       filename))
                (setq indent-tabs-mode t)
                (c-set-style "linux-tabs-only")))))
