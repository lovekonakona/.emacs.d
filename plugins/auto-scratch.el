;;; auto-scratch.el --- auto save scratch when killing emacs

;; Author: Jin Meng <lovekonakona@gmail.com>
;; Created: 4 Dec 2012
;; Version: 0.0.1

(defvar auto-scratch-buffer-name "*scratch*")
(defvar auto-scratch-store-filename "~/.emacs.d/auto-scratch.txt")
(defvar auto-scratching nil)

(defun auto-scratch-reading ()
  (let* ((scratch (get-buffer auto-scratch-buffer-name)))
    (if (and scratch
             (file-exists-p auto-scratch-store-filename))
        (progn
          (switch-to-buffer auto-scratch-buffer-name)
          (insert-file-contents auto-scratch-store-filename)
          (end-of-buffer)))))

(defun auto-scratch-writing ()
  (save-excursion
    (let* ((scratch (get-buffer auto-scratch-buffer-name))
           start end)
      (if scratch
          (progn
            (switch-to-buffer auto-scratch-buffer-name)
            (setq start (progn (beginning-of-buffer) (point))
                  end (progn (end-of-buffer) (point)))
            (write-region start end auto-scratch-store-filename))))))

(defun auto-scratch ()
  (if (not auto-scratching)
      (progn
        (setq auto-scratching t)
        (add-hook 'after-init-hook 'auto-scratch-reading)
        (add-hook 'kill-emacs-hook 'auto-scratch-writing))
    (progn
      (setq auto-scratching nil)
      (remove-hook 'after-init-hook 'auto-scratch-reading)
      (remove-hook 'kill-emacs-hook 'auto-scratch-writing))))

(provide 'auto-scratch)
