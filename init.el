(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/plugins/")
(add-to-list 'load-path "~/.emacs.d/modes/")

(load "~/.emacs.d/utils.el")

;; 设置字体
(set-face-attribute
 'default nil :font "Source Code Pro 14")

(set-fontset-font
 (frame-parameter nil 'font)
 'han
 (font-spec :family "黑体-简" :size 16))


;; 设置光标
(setq-default cursor-type 'line)


(require 'org)


(let ((value (* 1024 1024 1024 1024)))
  (setq max-lisp-eval-depth value
        max-specpdl-size value))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(show-paren-mode t)
 '(tool-bar-mode nil))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(bold-italic ((t (:slant italic :weight bold)))))


;; 全屏编辑器
(setq default-frame-alist
      '((top . 0)
        (left . 0)
        (width . 155)
        (height . 37)))


(add-to-list 'load-path "~/.emacs.d/plugins/color-theme/")
(load-file "~/.emacs.d/color-themes/blackboard-color-theme.el")
(load-file "~/.emacs.d/color-themes/my-color-theme.el")
(load-file "~/.emacs.d/color-themes/amy-color-theme.el")
(load-file "~/.emacs.d/color-themes/twilight-color-theme.el")
(load-file "~/.emacs.d/color-themes/zoo-color-theme.el")
(blackboard-color-theme)

(global-hl-line-mode t)
(set-face-background 'hl-line "#004")
(set-frame-parameter nil 'alpha 96)


;; 禁用鼠标拖拽自动复制
(setq mouse-drag-copy-region nil)

;; 自定义快捷键
(global-set-key [s-left] 'beginning-of-line)
(global-set-key [s-right] 'end-of-line)
(global-set-key [s-up] 'beginning-of-buffer)
(global-set-key [s-down] 'end-of-buffer)
(global-set-key [s-backspace] 'backward-kill-line)
(global-set-key [kp-delete] 'delete-char)
(global-set-key (kbd "M-C-3") 'comment-or-uncomment-region)
(global-set-key (kbd "M-#") 'comment-or-uncomment-region)
(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "s-=") 'increase-font-size)
(global-set-key (kbd "s--") 'decrease-font-size)

(global-set-key ; one line comment
 (kbd "s-/")
 '(lambda ()
    (interactive)
    (if (region-active-p)
        (comment-or-uncomment-region (region-beginning) (region-end))
      (save-excursion
        (let* ((tsart (progn (beginning-of-line) (point)))
               (end (progn (end-of-line) (point))))
          (comment-or-uncomment-region start end))))))

(setq ring-bell-function 'ignore)


(global-linum-mode t)

(require 'golden-ratio)
(golden-ratio-enable)

;(setq-default case-fold-search nil)
(setq-default case-replace nil)

(setq auto-save-default nil)

;; ÉèÖÃËõ½ø
(set-default-indent 4)

(setq c-default-style
      '((java-mode . "java") (awk-mode . "awk") (other . "K&R")))

(add-to-list 'load-path nil)
(setq-default make-backup-files nil)

(setq inhibit-startup-message t)
(setq gnus-inhibit-startup-message t)
(fset 'yes-or-no-p 'y-or-n-p)

;;À¨ºÅÆ¥ÅäÊ±ÏÔÊ¾ÁíÍâÒ»±ßµÄÀ¨ºÅ£¬¶ø²»ÊÇ·³ÈËµÄÌøµ½ÁíÒ»¸öÀ¨ºÅ¡£
(show-paren-mode t)
(setq show-paren-style 'parentheses)

;;·ÀÖ¹Ò³Ãæ¹ö¶¯Ê±Ìø¶¯£¬ scroll-margin 1 ¿ÉÒÔÔÚ¿¿½üÆÁÄ»±ßÑØ1ÐÐÊ±¾Í¿ªÊ¼¹ö¶¯£¬¿ÉÒÔºÜºÃµÄ¿´µ½ÉÏÏÂÎÄ¡£
(setq scroll-margin 1
      scroll-conservatively 10000)

;; ·ÀÖ¹¹öÂÖ¹ö¶¯¹ý¿ì
(setq mouse-wheel-scroll-amount '(2 ((shift) . 1)((control)))
      mouse-wheel-progressive-speed nil
      scroll-step 1)

;;Add php-mode
(load "php-mode")
(add-to-list 'auto-mode-alist '("\\.php[34]?\\|\\.phtml" . php-mode))

(load "haskell-mode/haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
;;(add-hook 'haskell-mode-hook 'turn-on-haskell-simple-indent)


(add-to-list 'auto-mode-alist '("\\.jinja[12]?\\|\\.vm\\|\\.jsp\\|\\.tpl" . web-mode))
(add-to-list 'auto-mode-alist '("\\.s[ac]ss" . css-mode))

(load "less-css-mode")
(add-to-list 'auto-mode-alist '("\\.less" . less-css-mode))

(load "yaml-mode")
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

(load "coffee-mode")
(add-to-list 'auto-mode-alist '("\\.coffee\\'" . coffee-mode))

(load "zencoding-mode")
(global-set-key [C-return] 'zencoding-expand-tag)
(global-set-key (kbd "RET") 'indent-on-newline)

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'set-goal-column 'disabled nil)
(put 'narrow-to-region 'disabled nil)


;; load orgtbl-mode for 'scratch'
(add-hook 'emacs-lisp-mode-hook (lambda () (orgtbl-mode)))



(add-to-list 'load-path "~/.emacs.d/modes/scala-mode2/")
(require 'scala-mode2)


;; following code for hs-minor-mode
(add-hook 'js-mode-hook 'hs-minor-mode)

(global-set-key (kbd "C-c C-c") 'hs-toggle-hiding)
(global-set-key (kbd "C-c H") 'hs-hide-block)
(global-set-key (kbd "C-c S") 'hs-show-block)

(require 'markdown-mode)

(require 'go-mode)

(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))

(setq web-mode-script-padding 4)
(setq web-mode-style-padding 4)
(setq web-mode-markup-indent-offset 4)
(setq web-mode-css-indent-offset 4)
(setq web-mode-code-indent-offset 4)
(setq web-mode-disable-css-colorization t)

(add-hook 'local-write-file-hooks
          (lambda ()
            (delete-trailing-whitespace)
            nil))


(require 'scss-mode)
(setq scss-compile-at-save nil)
(autoload 'scss-mode "scss-mode")
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))

(global-font-lock-mode 1)

;;; use groovy-mode when file ends in .groovy or has #!/bin/groovy at start
(autoload 'groovy-mode "groovy-mode" "Major mode for editing Groovy code." t)
(add-to-list 'auto-mode-alist '("\.groovy$\\|\.gradle$" . groovy-mode))
(add-to-list 'interpreter-mode-alist '("groovy" . groovy-mode))

;;; make Groovy mode electric by default.
(add-hook 'groovy-mode-hook
          '(lambda ()
             (require 'groovy-electric)
             (groovy-electric-mode)))



;; open scratch file
(find-file "~/.scratch.el")
(kill-buffer "*scratch*")
