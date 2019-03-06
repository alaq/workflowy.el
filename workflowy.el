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
  (add-hook 'org-mode-hook 'set-olivetti)
  (add-hook 'org-mode-hook 'org-indent-mode)
  (define-key org-mode-map (kbd "C-<")
    'org-go-up-one-level)
  (define-key org-mode-map (kbd "C->")
    'org-go-down-one-level)
  (define-key org-mode-map (kbd "RET")
    'org-better-return)
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

(provide 'workflowy)

;;; workflowy.el ends here
