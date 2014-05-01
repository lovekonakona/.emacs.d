;;; emmet for Emacs

;; Author: Jin Meng <lovekonakona@gmail.com>
;; Created: 4 Dec 2012
;; Version: v0.7.0

(defvar %emmet-inline-tags%
  '("a" "b" "i" "em" "span" "strong" "img"))

(defvar %emmet-self-closing-tags%
  '("br" "hr" "img" "input" "link" "meta"))

(defvar %emmet-aliases% ())

(defvar %emmet-tag-list%
  '("a" "abbr" "acronym" "address" "applet" "area" "article" "aside" "audio" "b"
    "base" "basefont" "bdi" "bdo" "big" "blockquote" "body" "br" "button"
    "canvas" "caption" "center" "cite" "code" "col" "colgroup" "command"
    "datalist" "dd" "del" "details" "dfn" "dir" "div" "dl" "dt" "em" "embed"
    "fieldset" "figcaption" "figure" "font" "footer" "form" "frame" "frameset"
    "h1" "h2" "h3" "h4" "h5" "h6" "head" "header" "hgroup" "hr" "html" "i"
    "iframe" "img" "input" "ins" "isindex" "keygen" "kbd" "label" "legend" "li"
    "link" "map" "mark" "menu" "meta" "meter" "nav"
    ))

(defvar %emmet-default-tag% "div")
(defvar %emmet-operator-greater-than% ">")
(defvar %emmet-operator-plus% "+")

(defvar %emmet-regex-filter% "|\\([a-zA-Z]+\\)$")
(defvar %emmet-regex-class% ".\\([_-a-zA-Z0-9]+\\)$")
(defvar %emmet-regex-id% "#\\([_-a-zA-Z0-9]+\\)$")
(defvar %emmet-regex-custom-attrs% "")


(defun emmet-get-result (&optional is-match &optional last-string &optional result)
  "Return dict match meta"
  (let* ((result (make-hash-table :test 'equal)))
    (puthash :is-match (or is-match nil) result)
    (puthash :last-string (or last-string nil) result)
    (puthash :result (or result nil) result)
    result
    ))


(defun emmet-get-tag-meta ()
  (let* ((meta (make-hash-table :test 'equal)))
    (puthash :attrs   (make-hash-table :test 'equal) meta)
    (puthash :hasattr nil meta)
    (puthash :tag     nil meta)
    (puthash :repeat  1   meta)
    (puthash :text    nil meta)
    (puthash :child   nil meta)
    (puthash :next    nil meta)
    meta
    ))


(defun emmet-add-attribute (tag-meta attr value)
  (let* (attrs (gethash :attrs tag-meta))
    attrs
    )
  )

(defun emmet-match-attributes (string tag-meta)
  (let* ((result (emmet-get-result))
         matched)
    (if (string-match %emmet-regex-class% string)
        (progn
          (setq matched (substring string (match-beginning 1))
                string (substring string 0 (match-beginning 0))
                )
          (puthash :attributes tag-meta)
          )
      )
    ))

(emmet-match-attributes "div.abc" 123)

(defun emmet-match-repeat (string)
  )

(defun emmet-match-tag (string)
  )


(defun emmet-match-sub-expression (string)
  (let* ((result (emmet-get-result)))
    )
  )

(defun emmet-match-string (string)
  "Match the given string, return list [is-match, last-string, result]"

  (let* ((len (length string))
         (last-char (substring string (1- len)))
         result)
    
    ;; (if (equal last-char ")")
    ;;     (progn
    ;;       (setq result (emmet-match-sub-expression string))
    ;;       (if (gethash :is-match result)
    ;;           (set string (gethash :last-string result))
    ;;         )
    ;;       )
    ;;     )


    
    ))

(emmet-match-string "(abc)")

















(defun emmet-get-tag-node ()
  (let* ((tag-node (make-hash-table :test 'equal)))
    (puthash :attrs   (make-hash-table :test 'equal) tag-node)
    (puthash :hasattr nil tag-node)
    (puthash :tag     nil tag-node)
    (puthash :repeat  1   tag-node)
    (puthash :text    nil tag-node)
    (puthash :child   nil tag-node)
    (puthash :next    nil tag-node)
    tag-node))

(defun emmet-get-current-line ()
  "Return buffer start at beignning of current line, end at current point"
  (let* (start end)
    (save-excursion
      (setq end (point))
      (beginning-of-line)
      (setq start (point))
      (buffer-substring start end))))

(defun emmet-match-repeat (string tag-node)
  (let* ((repeat 1))
    (if (string-match "\\*[0-9]+$" string)
        (setq repeat (string-to-number
                      (substring string (1+ (match-beginning 0))))
              string (substring string 0 (match-beginning 0))))
    (puthash :repeat repeat tag-node) string))

(defun emmet-match-text (string tag-node)
  (let* (level start end char)
    (if (string-match "}$" string)
      (progn
        (setq end (match-beginning 0)
              start (1- end)
              level 1)
        (while (and (> start -1) (> level 0))
          (progn
            (setq char (substring string start (1+ start)))
            (if (equal char "}") (setq level (1+ level))
              (if (equal char "{") (setq level (1- level))))
            (setq start (1- start))))
        (setq start (+ 2 start))
        (if (= level 0)
            (progn
              (puthash :text (substring string start end) tag-node)
              (setq string (substring string 0 (1- start))))))) string))

(defun emmet-match-attributes (string tag-node)
  (let* (start end)
    (if (string-match "\\]$" string) string
        ;; match [attr=value]
      )
    ) string)

(defun emmet-match-tag-name (string tag-node)
  (let* (tag-name)
    (if (string-match "[a-zA-Z]+$" string)
        (progn
          (setq tag-name (substring string (match-beginning 0) (match-end 0)))
          (if (member tag-name %emmet-tag-list%)
              (progn
                (puthash :tag tag-name tag-node)
                (setq string (substring string 0 (match-beginning 0))))))) string))

(defun emmet-match-operator (string)
  (let* (operator)
    ;; avoid match pattern that "<div...>"
    (if (string-match "<[a-zA-Z0-9]+>" string)
      nil)
    
    (if (string-match "\\(>\\|\\+\\)$" string)
        (setq operator (substring string (match-beginning 0))))
    operator))

(defun emmet-match-string (string &optional prev-tag-node)
  (let* ((tag-node (emmet-get-tag-node))
         (old-string string)
         operator)
    (if prev-tag-node
        (setq operator (emmet-match-operator string)))

    (if operator
        (setq string (substring string 0 (- (length string) (length operator)))))
    
    (setq string (emmet-match-repeat     string tag-node)
          string (emmet-match-text       string tag-node)
          string (emmet-match-attributes string tag-node)
          string (emmet-match-tag-name    string tag-node))

    ;; if has attributes but not tag-name
    (if (and (gethash :hasattr tag-node)
             (not (gethash :text tag-node))
             (not (gethash :tag tag-node)))
        (puthash :tag %emmet-default-tag% tag-node))

    (if (or (gethash :tag tag-node)
            (gethash :text tag-node))
        (progn
          (if prev-tag-node
              (if (equal operator %emmet-operator-greater-than%)
                  (puthash :child prev-tag-node tag-node)
                (if (equal operator %emmet-operator-plus%)
                    (puthash :sibling prev-tag-node tag-node))))
          (emmet-match-string string tag-node))
      
      (if prev-tag-node prev-tag-node))))


(defun emmet-repeat-string (string count)
  string
  )

(defun emmet-parse-tag-node (tag-node)
  (let* ((tag         (gethash :tag  tag-node))
         (text        (gethash :text tag-node))
         (repeat      (gethash :repeat tag-node))
         (sibling     (gethash :sibling tag-node))
         (child       (gethash :child tag-node))
         (inlined     (member tag %emmet-inline-tags%))
         (self-close  (member tag %emmet-self-closing-tags%))
         (string      "")
         (count       1))
    
    (if (and (not tag) text) ; no tag name
        (setq string text)
      (if tag
          (progn
            (setq string (concat "<" tag ">"))
            
            (if (not self-close)
                (progn
                  (if text
                      (setq string (concat string text))
                    (if child
                        (setq string (concat string (emmet-parse-tag-node child)))))
                  (setq string (concat string "</" tag ">")))))))


    (if (> repeat 1)
        (progn (setq string (emmet-repeat-string string count)
                     count (+1 count))))

    (if sibling
        (setq string (concat string (emmet-parse-tag-node sibling))))
    
    string))

(gethash :tag (emmet-match-string "div>a{abc}*3"))

(defun emmet-expand ()
  (interactive)
  (let* ((cur-line (emmet-get-current-line))
         (tag-node (emmet-match-string cur-line))
         )
    (if tag-node
        (message (emmet-parse-tag-node tag-node))
      "")))


(div+abc)
;; div#nav>ul>li>(a+div)+img
