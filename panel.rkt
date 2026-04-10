#lang racket/base

(require "curses.rkt")

(require (prefix-in panel: "ffi/panel.rkt"))

(provide (all-defined-out))

(define current-panel (make-parameter #f))

;; Screen

(define (update-panels #:screen [screen (current-screen)]) 
  (panel:update_panels_sp screen))

;; Window

(define (new-panel #:window [window (current-window)]) 
  (panel:new_panel window))

;; Panel

(define (panel-window [panel (current-panel)])
  (panel:panel_window panel))

(define (hide-panel [panel (current-panel)]) 
  (panel:hide_panel panel))

(define (show-panel [panel (current-panel)]) 
  (panel:show_panel panel))

(define (delete-panel [panel (current-panel)]) 
  (panel:del_panel panel))

(define (top-panel [panel (current-panel)]) 
  (panel:top_panel panel))

(define (bottom-panel [panel (current-panel)]) 
  (panel:bottom_panel panel))

(define (panel-above [panel (current-panel)]) 
  (panel:panel_above panel))

(define (panel-below [panel (current-panel)]) 
  (panel:panel_below panel))

(define (set-panel-user-pointer pointer #:panel [panel (current-panel)]) 
  (panel:set_panel_userptr panel pointer))

(define (panel-user-pointer [panel (current-panel)]) 
  (panel:panel_userptr panel))

(define (move-panel #:panel [panel (current-panel)]
                    #:x x
                    #:y y) 
  (panel:move_panel panel y x))

(define (replace-panel window #:panel [panel (current-panel)]) 
  (panel:replace_panel panel window))

(define (panel-hidden? [panel (current-panel)]) 
  (panel:panel_hidden panel))

;; Syntax

(define (%with-panel panel proc)
  (parameterize ([current-panel panel])
    (proc)))

(define-syntax-rule (with-panel panel body ...)
  (%with-panel panel
    (lambda ()
      body ...)))

