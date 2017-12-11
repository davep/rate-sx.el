;;; rate-sx.el --- Show currency rates from rate.sx -*- lexical-binding: t -*-
;; Copyright 2017 by Dave Pearson <davep@davep.org>

;; Author: Dave Pearson <davep@davep.org>
;; Version: 1.2
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

;;; Code:

(require 'ansi-color)

(defconst rate-sx-url "http://%srate.sx/"
  "URL for rate.sx.")

(defconst rate-sx-user-agent "rate-sx.el (https://github.com/davep/rate-sx.el) (curl)"
  "User agent to send to the rate.sx server.")

(defconst rate-sx-buffer "*rate.sx*"
  "Name of the output buffer.")

(defconst rate-sx-currencies
  '(("USD" . "US Dollar")
    ("AUD" . "Australian Dollar")
    ("CAD" . "Canadian Dollar")
    ("CHF" . "Swiss Franc")
    ("CNY" . "Chinese Yuan")
    ("EUR" . "Euro")
    ("GBP" . "British Pound")
    ("IDR" . "Indonesian Rupiah")
    ("JPY" . "Japanese Yen")
    ("KRW" . "South Korean Won")
    ("RUB" . "Russian Ruble"))
  "List of currencies that rate.sx can convert to.

See http://rate.sx/:help for more details.")

(defvar rate-sx-default-currency nil
  "The default display currency when calling rate.sx.

If nil the default currency as used by rate.sx itself will be
used. See `rate-sx-currencies' or the help screen of rate.sx
itself for more currency options.")

(defun rate-sx-get (&optional currency)
  "Get the output from rate.sx.

Values will be acquired in CURRENCY, or the default currency of
rate.sx will be used if one isn't supplied."
  (let* ((url-mime-accept-string "text/plain")
         (url-request-extra-headers `(("User-Agent" . ,rate-sx-user-agent)))
         (url-show-status nil))
    (with-temp-buffer
      (url-insert-file-contents (format rate-sx-url
                                        (if currency
                                            (concat currency ".")
                                          "")))
      (buffer-string))))

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

(provide 'rate-sx)

;;; rate-sx.el ends here
