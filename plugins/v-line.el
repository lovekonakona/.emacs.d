(defun indent-vline ()
  (interactive)
  (funcall
   (lambda (x z)
     (font-lock-add-keywords
      nil `((,x
             (0 (if (save-excursion
                      (skip-chars-backward " ")
                      (bolp))
                    (let* ((p2 (point)) (p1 (1- p2)))
                      (if (overlays-at p1)
                          nil   ;; (move-overlay (car (overlays-at p1)) p1 p2)
                        (overlay-put
                         (make-overlay p1 p2) 'face ',z))
                      nil)))))))
   "   \\( \\)"  '(:background "gray30")))