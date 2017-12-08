;;; rate-sx.el --- Show currency rates from rate.sx
;; Copyright 2017 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 0.01
;; Keywords: comm, currency, bitcoin, money
;; URL: https://github.com/davep/rate-sx.el

;; This program is free software: you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation, either version 3 of the License, or (at your
;; option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
;; Public License for more details.
;;
;; You should have received a copy of the GNU General Public License along
;; with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; rate-sx.el provides a command for showing currency rates from rate.sx.
;;
;; To do:
;;
;; The table borders just don't work. I need to figure out how to
;; convert/strip/handle them.

;;; Code:

(require 'ansi-color)

(defconst rate-sx-url "http://rate.sx/"
  "URL for rate.sx.")

(defconst rate-sx-user-agent "rate-sx.el (https://github.com/davep/rate-sx.el) (curl)"
  "User agent to send to the rate.sx server.")

(defconst rate-sx-buffer "*rate.sx*"
  "Name of the output buffer.")

(defun rate-sx-get ()
  "Get the output from rate.sx."
  (let* ((url-mime-accept-string "text/plain")
         (url-request-extra-headers `(("User-Agent" . ,rate-sx-user-agent)))
         (url-show-status nil))
    (with-temp-buffer
      (url-insert-file-contents rate-sx-url)
      (buffer-string))))

(defun rate-sx-unboxify (s)
  "Remove box drawing characters from S."
  (replace-regexp-in-string "\x1b(0.+?\x1b(B"
                            (lambda (match)
                              (make-string (- (length match) 6) ?.))
                            s))

(defun rate-sx ()
  "Show the current output of rate.sx in a new buffer."
  (interactive)
  (with-help-window rate-sx-buffer
    (with-current-buffer rate-sx-buffer
      (insert (rate-sx-unboxify (ansi-color-apply (rate-sx-get)))))))

(provide 'rate-sx)

;;; rate-sx.el ends here
