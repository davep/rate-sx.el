;;; rate-sx.el --- Show currency rates from rate.sx -*- lexical-binding: t -*-
;; Copyright 2017-2018 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.4
;; Keywords: comm, currency, bitcoin, money
;; URL: https://github.com/davep/rate-sx.el
;; Package-Requires: ((emacs "24.4"))

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
;; `rate-sx.el' provides a main command, `rate-sx', which displays the
;; output of http://rate.sx in a buffer.
;;
;; Other commands provide ways to quickly calculate currency totals, they
;; include:
;;
;; `rate-sx-calc'
;;
;; Show the result of a currency calculation in the minibuffer. Calculations
;; are things like "1BTC+12ETH" (would show the total value, in the base
;; currency defined by `rate-sx-default-currency', of holding 1 BTC and 12
;; ETH).
;;
;; `rate-sx-calc-region'
;;
;; Same as above but takes the input from the content of the marked region.
;;
;; `rate-sx-calc-maybe-region'
;;
;; Same as above again, but performs `rate-sx-calc-region' if there is an
;; active mark, otherwise it performs `rate-sx-calc'.

;;; Code:

(require 'ansi-color)
(require 'url-util)

(defconst rate-sx-url "http://%srate.sx/%s"
  "URL for rate.sx.")

(defconst rate-sx-user-agent "rate-sx.el (https://github.com/davep/rate-sx.el) (curl)"
  "User agent to send to the rate.sx server.")

(defconst rate-sx-buffer "*rate.sx*"
  "Name of the output buffer.")

(defvar rate-sx-currencies nil
  "List of currencies that rate.sx can convert to.

Don't use this directly. Use the function `rate-sx-currencies'
instead.

See http://rate.sx/:help for more details.")

(defvar rate-sx-default-currency nil
  "The default display currency when calling rate.sx.

If nil the default currency as used by rate.sx itself will be
used. See function `rate-sx-currencies' or the help screen of rate.sx
itself for more currency options.")

(defun rate-sx-get (&optional currency params)
  "Get the output from rate.sx.

Values will be acquired in CURRENCY, or the default currency of
rate.sx will be used if one isn't supplied.

PARAMS will be added to the end of `rate-sx-url' if they are supplied."
  (let* ((url-mime-accept-string "text/plain")
         (url-request-extra-headers `(("User-Agent" . ,rate-sx-user-agent)))
         (url-show-status nil))
    (with-temp-buffer
      (url-insert-file-contents (format rate-sx-url
                                        (if currency
                                            (concat currency ".")
                                          "")
                                        (or params "")))
      (buffer-string))))

(defun rate-sx-currencies-to-alist (rates)
  "Convert RATES list from rate.sx into an assoc list."
  (let ((arates))
    (while rates
      (when (not (string= "" (car rates)))
        (setq arates (append arates (list (cons (car rates) (cadr rates))))))
      (setq rates (cddr rates)))
    arates))

(defun rate-sx-get-currencies ()
  "Get the currency list from the rate.sx site."
  (rate-sx-currencies-to-alist (split-string (rate-sx-get nil ":currencies") "\\(    \\|\n\\)")))

(defun rate-sx-currencies ()
  "Return the list of (non-crypto) currencies."
  (or rate-sx-currencies (setq rate-sx-currencies (rate-sx-get-currencies))))

;;;###autoload
(defun rate-sx (currency)
  "Show the current output of rate.sx in a new buffer.

If CURRENCY is non-nil, this command will prompt for a display currency."
  (interactive
   (list (if current-prefix-arg
             (completing-read "Currency: " rate-sx-currencies nil t)
           rate-sx-default-currency)))
  (with-help-window rate-sx-buffer
    (with-current-buffer rate-sx-buffer
      (insert (ansi-color-apply (rate-sx-get currency))))))

;;;###autoload
(defun rate-sx-calc (calc)
  "Evaluate CALC via rate.sx.

The result is given in `rate-sx-default-currency'."
  (interactive "sCalc: ")
  (message "Result: %s" (string-trim (rate-sx-get rate-sx-default-currency (url-hexify-string calc)))))

;;;###autoload
(defun rate-sx-calc-region (start end)
  "Perform `rate-sx-calc' on text in region START to END."
  (interactive "r")
  (rate-sx-calc (buffer-substring-no-properties start end)))

;;;###autoload
(defun rate-sx-calc-maybe-region ()
  "Perform a rate calculation on a region if one is active.

If one isn't active, prompt for the calculation."
  (interactive)
  (call-interactively (if mark-active #'rate-sx-calc-region #'rate-sx-calc)))

(provide 'rate-sx)

;;; rate-sx.el ends here
