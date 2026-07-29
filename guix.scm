; SPDX-License-Identifier: MPL-2.0
;; guix.scm — GNU Guix package definition for gossamer
;; Usage: guix shell -f guix.scm

(use-modules (guix packages)
             (guix build-system gnu)
             (guix licenses))

(package
  (name "gossamer")
  (version "0.1.0")
  (source #f)
  (build-system gnu-build-system)
  (synopsis "gossamer")
  (description "gossamer — part of the hyperpolymath ecosystem.")
  (home-page "https://github.com/metadatastician/gossamer")
  (license mpl2.0))
