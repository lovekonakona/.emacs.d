(defun set-default-indent (num)
  (setq js-indent-level num)
  (setq c-basic-offset num)
  (setq indent-tabs-mode nil)
  (set-default 'tab-width num)
  (setq tab-width num)
  (setq default-tab-width num)
  (setq-default tab-width num indent-tabs-mode nil)
  (setq sgml-basic-offset num)
  (setq tab-stop-list '(number-sequence num 120 num)))

(defun increase-font-size ()
  (interactive)
  (set-face-attribute
   'default nil
   :height (ceiling (* 1.10 (face-attribute 'default :height)))))

(defun decrease-font-size ()
  (interactive)
  (set-face-attribute
   'default nil
   :height (floor (* 0.9 (face-attribute 'default :height)))))

(defun backward-kill-line (arg)
  "Kill the region that begin of current line util current point"
  (interactive "p")
  (kill-line 0))

(defun indent-on-newline ()
  (interactive)
  (let* ((beginning
          (save-excursion
            (beginning-of-line)
            (point)))
         (end
          (save-excursion
            (end-of-line)
            (point)))
         (prev-string (buffer-substring beginning (point)))
         (next-string (buffer-substring (point) end)))
    (newline-and-indent)
    (if (string-match "</[^>]+>$" prev-string) ; if end of a html close tag, then indent it
        (save-excursion
          (previous-line)
          (indent-for-tab-command))
      (if (or
           (and (string-match "<[^>/][^>]*>[ \t]*$" prev-string)
                (string-match "^[ \t]*</[^>]+>" next-string))
           (and (string-match "{[ \t]*$" prev-string)
                (string-match "^[ \t]*}" next-string)))
          (progn
            (newline-and-indent)
            (previous-line)
            (indent-for-tab-command))))))

(defun indent-on-close-block ()
  (interactive)
  (let* ((end (point))
         (start (save-excursion
                  (beginning-of-line)
                  (point)))
         (buffer-string (buffer-substring start end)))
    (if (string-match "^[ \t]+}$" buffer-string)
        (indent-for-tab-command))))

(defun block-insert-char (char &optional char-after-cursor)
  (interactive)
  (let* ((char-after-cursor-pattern (if (member char-after-cursor '("[" "]"))
                                        (concat "\\" char-after-cursor)
                                      char-after-cursor)))
    (cond ((and (not char-after-cursor)
                (looking-at char))
           (forward-char 1))
          ((and (stringp char-after-cursor)
                (looking-at "[^[{(a-zA-Z0-9]\\|$"))
           (insert char)
           (save-excursion
             (insert char-after-cursor)))
          ((insert char)))))

(defun block-insert-quote (char)
  (interactive)
  (cond ((looking-at char)
         (forward-char 1))
        ((and (looking-at "[^[{(a-zA-Z0-9]\\|$")
              (looking-back "[^a-zA-Z0-9]\\|^")
              (not (looking-back char)))
         (insert char)
         (save-excursion
           (insert char)))
        ((insert char))))

(defun block-delete-char ()
  (interactive)
  (if (or (and (looking-back "{") (looking-at "}"))
          (and (looking-back "(") (looking-at ")"))
          (and (looking-back "\"") (looking-at "\""))
          (and (looking-back "'") (looking-at "'"))
          (and (looking-back "\\[") (looking-at "\\]")))
      (progn
        (backward-delete-char 1)
        (delete-char 1))
    (backward-delete-char-untabify 1)))


(defun kill-tailing-space ()
  (let* (start end string pos)
    (save-excursion
    (beginning-of-buffer)
    (end-of-line)
    (while (< (point) (save-excursion (end-of-buffer) (point)))
      (progn
        (setq end (point)
              start (save-excursion (beginning-of-line) (point))
              string (buffer-substring start end)
              pos (string-match "\s+$" string))

        (if pos (delete-region pos end))
        (next-line))))))

(defun open-files (&rest args)
  (let* ((proj-dir (car args))
         (files (cdr args))
         file)
    (loop for file in files do
          (find-file (concat proj-dir file)))))


(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file name new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))


(defun encode-gbk ()
  (interactive)
  (let ()
    (set-language-environment 'Chinese-gbk)
    (set-terminal-coding-system 'chinese-gbk)
    (set-selection-coding-system 'chinese-gbk)
    (set-keyboard-coding-system 'chinese-gbk)
    (set-clipboard-coding-system 'chinese-gbk)
    (set-buffer-file-coding-system 'chinese-gbk)
    (modify-coding-system-alist 'process "*" 'chinese-gbk)
    ))

(defun encode-utf8 ()
  (interactive)
  (let ()
    (set-language-environment "UTF-8")
    (set-terminal-coding-system 'utf-8)
    (set-keyboard-coding-system 'utf-8)
    (set-clipboard-coding-system 'utf-8)
    (set-buffer-file-coding-system 'utf-8)
    (set-selection-coding-system 'utf-8)
    (modify-coding-system-alist 'process "*" 'utf-8)))
