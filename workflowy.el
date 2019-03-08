;;; workflowy.el --- Bring workflowy's feature to emacs as an org-mode minor mode
;;; Version: 0.1.0
;;; Author: alaq
;;; URL: https://github.com/alaq/workflowy.el

;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; The project is hosted at https://github.com/alaq/workflowy.el
;; The latest version, and all the relevant information can be found there.

;;; Code:

;;;###autoload
(define-minor-mode workflowy-mode
    "Workflowy's features in an emacs minor mode for org-mode."
  nil nil nil
  (org-indent-mode)
  (add-hook 'org-mode-hook 'set-olivetti)
  (add-hook 'org-mode-hook 'org-indent-mode)
  (add-hook 'org-mode-hook #'org-bullet-mode)
  (define-key org-mode-map (kbd "C-<")
    'org-go-up-one-level)
  (define-key org-mode-map (kbd "C->")
    'org-go-down-one-level)
  (define-key org-mode-map (kbd "RET")
    'org-better-return)
  (setq header-line-format (concat "%b/" (org-format-outline-path(org-get-outline-path))))
  )

(defun org-go-up-one-level ()
  "go up one level, workflowy style"
  (interactive)
  (beginning-of-buffer)
  (widen)
  (setq header-line-format (concat "%b/" (org-format-outline-path(org-get-outline-path))))
  (save-excursion
    (org-up-element)
    (org-narrow-to-subtree))
  (recenter))

(add-hook 'org-mode-hook #'org-change-bullets-depending-on-children)
(add-hook 'org-mode-hook 'org-change-bullets-depending-on-children)

(defun org-go-down-one-level ()
  "drill down one level, workflowy style"
  (interactive)
  (org-narrow-to-subtree)
  (org-show-children)
  (setq header-line-format (concat "%b/" (org-format-outline-path(org-get-outline-path t)))))

(defun org-has-children-p ()
  (interactive)
  (save-excursion
    (org-goto-first-child)))

(defun org-has-parent-p ()
  (interactive)
  (save-excursion
    (org-up-element)))

(require 'olivetti)
(defun set-olivetti ()
  "olivetti mode with default values"
  (interactive)
  (setq header-line-format "%b/")
  (set-face-attribute 'header-line nil :background "#282c35")
  (olivetti-mode)
  (olivetti-set-width 100))

;; original idea from http://kitchingroup.cheme.cmu.edu/blog/2017/04/09/A-better-return-in-org-mode/
;; simplified below until a better one can be written
;; a good idea would be to look into https://github.com/calvinwyoung/org-autolist/blob/master/org-autolist.el
;; TODO RETURN in the middle of line should "cut" it
;; TODO double return should enter a note, and not a bullet
(defun org-better-return ()
  (interactive)
  (org-insert-heading-respect-content)
  (evil-insert-state))


;; ;; below is wip
(defun org-folded-p ()
  "Returns non-nil if point is on a folded headline."
  (and (org-at-heading-p)
       (save-excursion (org-goto-first-child))
       (invisible-p (point-at-eol))))

(defun is-folded ()
  "Interactive version of org-folded-p"
  (interactive)
  (if (org-folded-p) (message "yes") (message "no")))

;; replace bullets depending of the presence of child nodes or not
(defcustom org-content (string-to-char "◉")
  "Replacement for * as header prefixes."
  :type 'characterp
  :group 'org)

(defcustom org-no-content (string-to-char "○")
  "Replacement for * as header prefixes."
  :type 'characterp
  :group 'org)

(defun org-bullets-str ()
  (interactive)
  (if (save-excursion (org-goto-first-child)) org-bullet-with-folded-content org-bullet-no-content))

(define-minor-mode org-bullet-mode
  "Bullet for org-mode"
  nil nil nil
  (let* ((keyword
          `(("^\\*+ "
             (0 (let* ((level (- (match-end 0) (match-beginning 0) 1)))
                  (when (> level 1)
                    (put-text-property (match-beginning 0) (- (match-end 0) 2) 'display (make-string (1- level) org-no-content)))
                  (put-text-property (- (match-end 0) 2) (- (match-end 0) 1) 'display (string (if (save-excursion (org-goto-first-child)) org-content org-no-content)))
                  nil))))))
    (if org-bullet-mode
        (progn
          (font-lock-add-keywords nil keyword)
          (font-lock-fontify-buffer))
      (save-excursion
        (goto-char (point-min))
        (font-lock-remove-keywords nil keyword)
        (font-lock-fontify-buffer))
      )))


(provide 'workflowy)

;;; workflowy.el ends here
