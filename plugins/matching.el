(defconst +matching-opend-tag+ 0)
(defconst +matching-closed-tag+ 1)

(defvar matching-self-closing-tags
  '("br" "hr" "img" "input" "link" "meta"))



(defun matching-current-tag-opend ()
  (let* ((beg-of-point (buffer-substring 0 (point)))
         (end-of-point (buffer-substring (point))))
    (save-excursion
      ;; try to match a tag
      (if (not (string-match "^<" end-of-point))
          (when (string-match "<[^<]*$" beg-of-point)
            (goto-char (match-beginning))))
      (if (string-match "^<[ \t]*\\([a-zA-Z0-9]+\\)") ; is an open tag
          (if (member (buffer-substring (match-beginning 1) (match-end 1))
                      matching-self-closing-tags)
              )))
    (if (string-match "^<" end-of-point)
        (if (or (string-match "^<[ \t]*[a-zA-Z0-9]+.*[^/]\s*>" end-of-point)
                (save-excursion
                  (when (string-match "<[^<]*$" beg-of-point)
                    (goto-char (match-beginning))
                    
                    )
                  ))
            ;; is an opend tag
            (progn
              ;; find the closed tag
              )
          (progn ; is a closed tag
            ;; find the opend tag
            )
          )
      )
    ))

(defun matching-html ()
  (interactive)
  (let* ((cursor (point)))
    (save-excursion
      (message "%s__%s"
               (buffer-substring
                (progn (beginning-of-line) (point))
                cursor)
               (buffer-substring
                cursor
                (progn (end-of-line) (point))))
      )
    
    )
  
  )

(string-match "^<[ \t]*[a-zA-Z0-9]+.*[^/]\s*>" "<div id=\"\">")


(defun matching-prev-start-tag (cursor)
  (if (looking-at "<[ \t]*[a-z]")
      cursor
    (matching-next-start-tag (1- cursor))))

(defun matching-next-start-tag (cursor)
  (if (looking-at "<[ \t]*[a-z]")
      cursor
    (matching-next-start-tag (1+ cursor))))

(defun matching-tag (cursor &optional is-end-tag)
  (interactive)
  )


(defun matching-tag (string &optional is-end-tag)
  (interactive)
  (let* ((pattern (if is-end-tag
                      "<[ \t]*/[ \t]*\\([a-zA-Z][a-zA-Z0-9]*\\)[^>]*>"
                    "<[ \t]*\\([a-zA-Z][a-zA-Z0-9]*\\)[^>]*>"))
         (match (string-match pattern string)))
    (if (and match (= match 0))
        (substring string (match-beginning 1) (match-end 1)))))

(defun matching-open-tag (cursor &optional matching-cursor)
  "return an open tag name if current point in a html open tag,
otherwise return nil"
  (interactive)
  (matching-tag string nil))

(defun matching-close-tag (string)
  "return a end tag name if current point in a html open tag,
otherwise return nil"
  (interactive)
  (matching-tag string t))

(defun matching-start-tag-point (cursor)
  "return the point that start tag's position before cursor"
  (if (and (>= cursor (point-min)) (<= cursor (point-max)))
      (let* ((char (buffer-substring cursor (1+ cursor))))
        (if (equal char "<")
            cursor
          (matching-start-tag-point (1- cursor))))))

(defun matching-end-tag-point (cursor)
  "return the point that start tag's position before cursor"
  (if (and (>= cursor (point-min)) (<= cursor (point-max)))
      (let* ((char (buffer-substring cursor (1+ cursor))))
        (if (equal char ">")
            (1+ cursor)
          (matching-end-tag-point (1+ cursor))))))

(defun matching-whole-tag (cursor)
  (let* ((start (matching-start-tag-point cursor))
         (end (matching-end-tag-point cursor)))
    (if (and start end (> end start))
             (buffer-substring start end))))

(defun forward-html-sexp (&optional arg)
  (interactive)
  (let* ((cursor (point))
         (current-tag (matching-whole-tag cursor)))
    (if current-tag
        (message "%s" current-tag)
      (forward-sexp arg))
    ))
<div class="" id="" title="">
</div>


(forward-html-sexp)
(progn
  (string-match "^<[ \t]*\\([a-zA-Z][a-zA-Z0-9]*\\)[^>]*>" "")
  (match-beginning 0))
(string-match "^<[ \t]*\\([a-zA-Z][a-zA-Z0-9]*\\)[^>]*>" "(let ((cursor (point)))<div></div>")
