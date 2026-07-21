;;; vulpea-agenda.el --- Wraps org-agenda to dynamically add vulpea file notes to org-agenda-files  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Darlan Cavalcante Moreira

;; Author: Darlan Cavalcante Moreira <darcamo@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "30.2") (vulpea "2.5.0"))
;; Homepage: https://github.com/darcamo/vulpea-agenda

;; SPDX-License-Identifier: GPL-3.0-or-later

;; This file is not part of GNU Emacs

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Defines a wrapper around `org-agenda' that dynamically adds all vulpea file
;; notes with given tags to `org-agenda-files' before calling `org-agenda'. This
;; allows you to view all notes with specific tags in the agenda view.

;;; Code:
(require 'org)
(require 'emacsql)
(require 'vulpea-db)


;; Define the vulpea-agenda group
(defgroup vulpea-agenda nil
  "Settings for the vulpea-agenda package."
  :group 'vulpea
  :prefix "vulpea-agenda-")


(defcustom vulpea-agenda-tags '("agenda")
  "List of tags for notes that should be included in the agenda.

Any note with any of the tags in the list is included."
  :type '(repeat string)
  :group 'vulpea-agenda)


(defun vulpea-agenda--get-note-paths ()
  "Get the paths of all notes with tags in `vulpea-agenda-tags'."
  (seq-uniq
   (seq-map
    #'car
    (emacsql (vulpea-db) [:select
                          :distinct notes:path
                          :from notes
                          :inner :join tags
                          :on (= notes:id tags:note_id)
                          :where (in tags:tag $v1)
                          ;; :limit 4
                          ]
             (vconcat vulpea-agenda-tags)))))


;;;###autoload (autoload 'vulpea-agenda-wrapper "vulpea-agenda")
(defun vulpea-agenda-wrapper ()
  "Add notes to variable `org-agenda-files' and call `org-agenda'."
  (interactive)
  (let ((org-agenda-files
         (delete-dups
          (append (org-agenda-files) (vulpea-agenda--get-note-paths)))))
    (org-agenda)))


(provide 'vulpea-agenda)
;;; vulpea-agenda.el ends here
