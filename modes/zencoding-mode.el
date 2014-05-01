;;; zencoding for Emacs

;; Author Jin Meng <lovekonakona@gmail.com>
;; Created 2012-09-30 15:23:02
;; Version v0.7.0

(defun is-in-string (string sub-string)
  (let* ((string-length (length string))
         (sub-string-length (length sub-string)))
    (if (< sub-string-length string-length)
        (if (equal sub-string (substring string 0 sub-string-length))
            t
          (is-in-string (substring string 1) sub-string))
      nil)))

(defun string-pos (string sub-string)
  (let ((not-match -1)
        (orig-length (length string))
        (sub-length (length sub-string))
        pos)
    (if (and (= 0 orig-length) (> 0 sub-length))
        not-match
      (if (= 0 sub-length)
          0
        (if (>= orig-length sub-length)
            (if (equal sub-string (substring string 0 sub-length))
                0
              (if (>= (- orig-length 1) sub-length)
                  (progn
                    (setq pos (string-pos (substring string 1) sub-string))
                    (if (> pos -1)
                        (+ 1 pos)
                      not-match))
                not-match))
          not-match)))))

(defvar zencoding-inline-tags
  '("a" "b" "i" "em" "span" "strong" "img"))

(defvar zencoding-self-closing-tags
  '("br" "hr" "img" "input" "link" "meta"))

(let* ((table (make-hash-table :test 'equal)))
  (puthash "a"      '(("href" "")) table)
  (puthash "img"    '(("src" "")) table)
  (puthash "form"   '(("action" "") ("method" "post")) table)
  (puthash "label"  '(("for" "")) table)
  (puthash "input"  '(("type" "")) table)
  (puthash "link"   '(("rel" "stylesheet") ("href" "")) table)
  (puthash "textarea" '(("name" "") ("id" "") ("cols" "") ("rows" "")) table)
  ;; (puthash "script" '(("type" "text/javascript")) table)
  ;; (puthash "style"  '(("type" "text/css")) table)
  (defvar zencoding-tag-default-attr table))

(defun zencoding-get-attr (attr-name attrs)
  (if (zencoding-is-legel-list attrs)
      (let* ((first-attr (nth 0 attrs))
             (first-attr-name (nth 0 first-attr))
             (first-attr-value (nth 1 first-attr)))
        (if (equal attr-name first-attr-name)
            first-attr-value
          (zencoding-get-attr attr-name (cdr attrs))))))

(defun zencoding-is-member (attr-name attrs)
  (if (zencoding-is-legel-list attrs)
      (let* ((fir-attr (nth 0 attrs)))
        (if (equal attr-name (nth 0 fir-attr))
            t
          (zencoding-is-member attr-name (cdr attrs))))
    nil))

(defun zencoding-merge-attrs (attrs1 attrs2)
  (if (zencoding-is-legel-list attrs1)
      (let* ((fir-attr (nth 0 attrs1)))
        (if (not (zencoding-is-member (nth 0 fir-attr) attrs2))
            (setq attrs2 (append attrs2 (list fir-attr))))
        (zencoding-merge-attrs (cdr attrs1) attrs2))
    attrs2))

(defun zencoding-is-legel-list (list_)
  "return t if list_ is a list and at least have one element or return nil"
  (and (listp list_)) (< 0 (length list_)))

(defun zencoding-compose-attr (name value)
  "Return string tag attribute"
  (format "%s=\"%s\"" name value))

(defun zencoding-compose-attrs (attrs)
  "Return string tag attributes"
  (if (zencoding-is-legel-list attrs)
      (let* ((string "")
             (attr (car attrs))
             (remain-attrs (cdr attrs)))
        (concat " " (zencoding-compose-attr (nth 0 attr) (nth 1 attr))
                (if (zencoding-is-legel-list remain-attrs)
                    (zencoding-compose-attrs remain-attrs)
                  "")))
    ""))

(defun zencoding-close-tag (tag-name)
  "Return a close tag string"
  (concat "</" tag-name ">"))

(defun zencoding-open-tag (tag-name attrs &optional do-close)
  "Return a open tag string"
  (concat "<" tag-name (zencoding-compose-attrs attrs) ">"
          (if (and (not (member tag-name zencoding-self-closing-tags)) do-close)
              (zencoding-close-tag tag-name) "")))

(defun zencoding-whole-tag (tag-name attrs &optional dont-close-self)
  "Return string a whole tag include intersting point with %s."

  (concat "<" tag-name (zencoding-compose-attrs attrs) ">%s"
          (if (or dont-close-self (not (member tag-name zencoding-self-closing-tags)))
              (concat "</" tag-name ">") "")))

(defun zencoding-append-attr (name value attrs)
  (let* ((demain-attrs attrs)
         attr
         done)
    (while (and (not done) (setq attr (car demain-attrs)))
      (let* ((attr-name (nth 0 attr))
             (attr-value (nth 1 attr)))
        (if (equal attr-name name)
            (progn
              (setq done t)
              (if (is-in-string (concat " " attr-value " ") value)
                  (setcdr attr (list (concat value " " attr-value)))))
          (setq demain-attrs (cdr demain-attrs)))))
    (if (not done)
        (setq attrs (append (list (list name value)) attrs)))
    attrs))

(defun zencoding-parse-attrs-with-square-brackets-without-brackets (string attrs)
  (if (string-match "\\[[ \t]*$" string)
      (list (substring string 0 (match-beginning 0)) attrs)
    (if (or (string-match "[ \t\[]\\([-_a-zA-Z0-9]+\\)[ \t]*=[ \t]*'\\(\\(\\\\\\\\\\|\\\\'\\|[^']+\\)*\\)'[ \t]*$" string)
            (string-match "[ \t\[]\\([-_a-zA-Z0-9]+\\)[ \t]*=[ \t]*\"\\(\\(\\\\\\\\\\|\\\\\"\\|[^\"]+\\)*\\)\"[ \t]*$" string)
            (string-match "[ \t\[]\\([-_a-zA-Z0-9]+\\)[ \t]*=[ \t]*\\([^\]\[ \t]+\\)[ \t]*$" string)
            (string-match "[ \t\[]\\([-_a-zA-Z0-9]+\\)[ \t]*\\(\\)$" string))
        (progn
          (setq attrs (zencoding-append-attr (substring string (match-beginning 1) (match-end 1))
                                             (substring string (match-beginning 2) (match-end 2))
                                             attrs)
                string (substring string 0 (match-beginning 1)))
          (zencoding-parse-attrs-with-square-brackets-without-brackets string attrs))
      (list string attrs))))

(defun zencoding-parse-attrs-with-square-brackets (string attrs)
  (if (string-match "\\]$" string)
      (progn
        (setq string (substring string 0 (- (length string) 1)))
        (zencoding-parse-attrs-with-square-brackets-without-brackets string attrs))
    (list string attrs)))

(defun zencoding-match-tag-attr (string attrs)
  (let* (match-beginning-pos
         match-end-pos
         matched)
    (if (string-match "#[-_a-zA-Z0-9$]+$" string)
        (progn
          (setq attrs (zencoding-append-attr "id" (substring string (+ 1 (match-beginning 0))) attrs)
                string (substring string 0 (match-beginning 0))
                matched t)))
    (if (string-match "\\.[-_a-zA-Z0-9$]+$" string)
        (progn
          (setq attrs (zencoding-append-attr "class" (substring string (+ 1 (match-beginning 0))) attrs)
                string (substring string 0 (match-beginning 0))
                matched t)))
    (if (string-match "\\]$" string)
        (let* ((result (zencoding-parse-attrs-with-square-brackets string attrs)))
          (setq string (nth 0 result)
                attrs (nth 1 result)
                matched t)))
    (if matched
        (zencoding-match-tag-attr string attrs)
      (list string attrs))))

(defun zencoding-format-num (num len)
    (if (and (< 1 len) (> len (length num)))
      (concat "0" (zencoding-format-num num (- len 1)))
    num))

(defun zencoding-replace-num (string num)
  (while (string-match "\\$+" string)
    (let* ((beginning (match-beginning 0))
           (end (match-end 0))
           (len (- end beginning)))
      (setq string (concat (substring string 0 beginning)
                           (zencoding-format-num (number-to-string num) len)
                           (substring string end)))))
  string)

(defun zencoding-remove-string (string remove-pattern)
  (while (string-match remove-pattern string)
    (setq string
          (concat
           (substring string 0 (match-beginning 0))
           (substring string (match-end 0)))))
  string)

(defun zencoding-mutiple-string (string mutiple-by &optional num)
  (if (not num) (setq num 1))
  (let* ((new-string (zencoding-replace-num string num))
         (num (+ num 1)))
    (if (> mutiple-by 1)
        (concat new-string "\n"
                (zencoding-remove-string (zencoding-mutiple-string string (- mutiple-by 1) num) "%s"))
      new-string)))

(defun zencoding-handle-add (fir-tag fir-html sec-tag sec-html)
  (concat fir-html "\n" (zencoding-remove-string sec-html "%s")))

(defun zencoding-handle-greater-than (fir-tag fir-html sec-tag sec-html &optional dont-break-line)
  (let* ((line-break (if (and (not dont-break-line)
                              (or
                               (string-match "\n" sec-html)
                               (not (member sec-tag zencoding-inline-tags))))
                         "\n")))
    (format fir-html (concat line-break sec-html line-break))))

(defvar zencoding-speical-child-list
  '(("ul\\+"
     "<ul>\n<li>%s</li>\n</ul>")
    ("dl\\+"
     "<dl>\n<dt></dt>\n<dd>%s</dd>\n</dl>")
    ("table\\+"
     "<table>\n<tbody>\n<tr>\n<td>%s</td>\n</tr>\n</tbody>\n</table>")
    ("link:css"
     "<link rel=\"stylesheet\" type=\"text/css\" href=\"%sstyle.css\">")
    ("html:xt"
     "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">\n<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\">\n<head>\n<meta http-equiv=\"Content-Type\" content=\"text/html;charset=UTF-8\" />\n<title></title>\n</head>\n<body>\n%s\n</body>\n</html>")
    ("html:5"
     "<!DOCTYPE HTML>\n<html lang=\"en-US\">\n<head>\n<meta charset=\"UTF-8\">\n<title></title>\n</head>\n<body>\n%s\n</body>\n</html>")
    ("input:text"
     "<input type=\"text\" id=\"\" name=\"%s\">")
    ("input:file"
     "<input type=\"file\" id=\"\" name=\"%s\">")
    ("input:hidden"
     "<input type=\"hidden\" id=\"\" name=\"%s\">")
    ("input:radio"
     "<input type=\"radio\" id=\"\" name=\"%s\">")
    ("input:checkbox"
     "<input type=\"checkbox\" id=\"\" name=\"%s\">")
    ("input:password"
     "<input type=\"password\" id=\"\" name=\"%s\">")
    ("input:submit"
     "<input type=\"submit\" value=\"%s\">")
    ("input:reset"
     "<input type=\"reset\" value=\"%s\">")
    ("button:submit"
     "<button type=\"submit\">%s</button>")
    ("button:reset"
     "<button type=\"reset\">%s</button>")
    ("script:src"
     "<script src=\"%s\"></script>")
    ("<!"
     "<!-- %s -->")))

(defun zencoding-speical-child (string &optional speical-child-list)
  (if (not speical-child-list)
      (setq speical-child-list zencoding-speical-child-list))
  (if (zencoding-is-legel-list speical-child-list)
      (let* ((fir-child (nth 0 speical-child-list))
             (demain-childs (cdr speical-child-list)))
        (if (string-match (format "\\(^\\|[^a-zA-Z]\\)\\(%s\\)$" (nth 0 fir-child)) string)
            (list (substring string 0 (match-beginning 2))
                  (nth 1 fir-child))
          (if demain-childs (zencoding-speical-child string demain-childs))))))

(defun zencoding-match-tag (string &optional matched-tag-name &optional matched-html &optional pass-filter)
  "Return a list (matched-string, demain-string)"
  (let* ((match-string "")
         (multiple-by 1)
         (attrs '())
         (html "")
         tag-name
         operator
         matched
         dont-match
         speical-match-html
         filter)
    
    (if matched-html
        (if (string-match "<[^>]+>$" string)
            (setq dont-match t)
          (if (string-match "[+>]$" string)
              (setq operator (match-string 0 string)
                    string (substring string 0 (match-beginning 0))))))
    (if pass-filter
        (setq filter pass-filter)
      (if (string-match "|\\([a-zA-Z0-9]+\\)$" string)
          (setq filter (substring string (match-beginning 1))
                string (substring string 0 (match-beginning 0)))))
    (let* ((result (zencoding-speical-child string))
           (html (nth 1 result)))
      (if (< 0 (length html))
          (setq string (nth 0 result)
                speical-match-html html
                matched t)))
    (if (and (not dont-match) (not matched))
        (progn
          (if (string-match "\\*[0-9]+$" string)
              (setq multiple-by (string-to-number (substring string (+ 1 (match-beginning 0))))
                    string (substring string 0 (match-beginning 0))))
          (let* ((result (zencoding-match-tag-attr string attrs)))
            (setq string (nth 0 result)
                  attrs (nth 1 result)))
          (if (string-match "[a-zA-Z]\\([a-zA-Z0-9]*\\)$" string)
              (setq tag-name (substring string (match-beginning 0))
                    string (substring string 0 (match-beginning 0))
                    matched t)
            (if attrs
                (setq tag-name "div"
                      matched t)))))
    (if matched
        (progn
          (setq attrs (zencoding-merge-attrs (gethash tag-name zencoding-tag-default-attr) attrs))
          (let* ((html (if speical-match-html speical-match-html (zencoding-whole-tag tag-name attrs (equal operator ">")))))
            (if (equal operator ">")
                (setq html (zencoding-handle-greater-than tag-name html matched-tag-name matched-html
                                                          (and speical-match-html (string-match "<body>\n*%s\n*</body>" speical-match-html)))))
            (if (equal filter "c") ; Process filter
                (let* ((id (zencoding-get-attr "id" attrs))
                       (class (zencoding-get-attr "class" attrs))
                       (comment (concat (if (and id (> (length id) 0)) (concat "#" id))
                                        (if (and class (> (length class) 0)) (concat "." class)))))
                  (if (< 0 (length comment))
                      (setq html (concat (format "<!-- %s -->\n" comment) html (format "\n<!-- /%s -->" comment))))))
            (setq html (zencoding-mutiple-string html multiple-by))
            (if (equal operator "+")
                (setq html (zencoding-handle-add tag-name html matched-tag-name matched-html)))
            (zencoding-match-tag string tag-name html filter)))
      (list string matched-html))))

(defun zencoding-expand-tag ()
  (interactive)
  (let* ((end (point))
         (beginning
          (save-excursion
            (beginning-of-line)
            (point)))
         (string (buffer-substring beginning end))
         (string-length (length string))
         (result (zencoding-match-tag string))
         (zencoding-exp-length (- string-length (length (nth 0 result))))
         (html (nth 1 result))
         (start (- end zencoding-exp-length))
         prev-html next-html)
    
    (if (> zencoding-exp-length 0)
        (progn
          (delete-region start end)
          (goto-char start)
          (if (string-match "%s" html)
              (progn
                (setq prev-html (substring html 0 (match-beginning 0))
                      next-html (substring html (match-end 0)))
                (let* (intersting-point)
                  (zencoding-insert-and-indent prev-html)
                  (setq intersting-point (point))
                  (zencoding-insert-and-indent next-html)
                  (goto-char intersting-point)
                  (indent-for-tab-command)))
            (zencoding-insert-and-indent html)))
      (message "not a legal ZenCoding syntax"))))

(defun zencoding-insert-and-indent (string)
  (let* ((start (point))
         (intenting t)
         printed-end
         has-next-line)
    (insert string)
    (setq printed-end (point))
    (save-excursion
      (goto-char start)
      (while intenting
        (save-excursion
          (end-of-line)
          (setq has-next-line
                (> (- (point-max) (point)) 0)))
        (if has-next-line
            (progn
              (next-line)
              (beginning-of-line)
              (if (< (point) printed-end)
                  (let* ((point-before-insert (point)))
                    (indent-for-tab-command)
                    (setq printed-end (+ printed-end (- (point) point-before-insert)))
                    )
                (setq intenting nil)))
          (setq intenting nil))))))
