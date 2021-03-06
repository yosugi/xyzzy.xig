; xig-mode
; xyzzy interface for git
; author yosugi

(provide "xig/common")

(in-package "xig")

(defvar *xig-common-map* nil)
(unless *xig-common-map*
  (setq *xig-common-map* (make-sparse-keymap))
  (define-key *xig-common-map* '#\h 'backward-char)
  (define-key *xig-common-map* '#\j 'next-line)
  (define-key *xig-common-map* '#\k 'previous-line)
  (define-key *xig-common-map* '#\l 'forward-char)
  (define-key *xig-common-map* '#\0 #'(lambda () (interactive) (goto-bol)))
  (define-key *xig-common-map* '#\$ #'(lambda () (interactive) (goto-eol)))
  (define-key *xig-common-map* '#\g #'(lambda () (interactive) (goto-char (point-min))))
  (define-key *xig-common-map* '#\G #'(lambda () (interactive) (goto-char (point-max)) (goto-bol)))
  (define-key *xig-common-map* '#\TAB 'other-window)
  (define-key *xig-common-map* '#\f 'next-page)
  (define-key *xig-common-map* '#\SPC 'next-page)
  (define-key *xig-common-map* '#\b 'previous-page)
  )

(defun xig-run-git (command &optional (buffer (selected-buffer)))
  (execute-shell-command
   (concat (map-slash-to-backslash (get-short-path-name *xig-git-path*)) " " command)
   nil
   buffer))

(defun xig-call-git (command)
  (call-process
   (concat (map-slash-to-backslash (get-short-path-name *xig-git-path*)) " " command)
   :wait t
   :show :hide))

(defun xig-get-current-line ()
  (let (from to)
    (save-excursion
      (goto-bol)
      (setq from (point))
      (goto-eol)
      (setq to (point))
      (buffer-substring from to))))

(defun xig-between (x min max)
  (and (>= x min) (<= x max)))

