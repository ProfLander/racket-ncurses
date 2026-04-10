#lang racket/base

(require ffi/unsafe
         ffi/unsafe/define)

(require "ncurses.rkt")

(provide (all-defined-out))

(define _PANEL-pointer (_cpointer 'PANEL))

(define-ffi-definer define-panel (ffi-lib "libpanel" '("5" #f)))

;; Screen

(define-panel update_panels_sp (_fun _SCREEN-pointer -> _void))
(define-panel ground_panel (_fun _SCREEN-pointer -> _PANEL-pointer))
(define-panel ceiling_panel (_fun _SCREEN-pointer -> _PANEL-pointer))

;; Window

(define-panel new_panel (_fun _WINDOW-pointer -> _PANEL-pointer))

;; Panel

(define-panel panel_window (_fun _PANEL-pointer -> _WINDOW-pointer))
(define-panel hide_panel (_fun _PANEL-pointer -> _int))
(define-panel show_panel (_fun _PANEL-pointer -> _int))
(define-panel del_panel (_fun _PANEL-pointer -> _int))
(define-panel top_panel (_fun _PANEL-pointer -> _int))
(define-panel bottom_panel (_fun _PANEL-pointer -> _int))
(define-panel panel_above (_fun _PANEL-pointer -> _PANEL-pointer))
(define-panel panel_below (_fun _PANEL-pointer -> _PANEL-pointer))
(define-panel set_panel_userptr (_fun _PANEL-pointer _pointer -> _int))
(define-panel panel_userptr (_fun _PANEL-pointer -> _pointer))
(define-panel move_panel (_fun _PANEL-pointer _int _int -> _int))
(define-panel replace_panel (_fun _PANEL-pointer _WINDOW-pointer -> _int))
(define-panel panel_hidden (_fun _PANEL-pointer -> _bool))

