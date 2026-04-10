#lang racket/base

(require racket/match)

(require "constants.rkt")
(require (prefix-in ncurses: "ffi/ncurses.rkt"))

(provide (all-from-out "constants.rkt"))
(provide (all-defined-out))

(define (fold-attrs . attrs)
  (foldr bitwise-ior 0 attrs))

(define current-screen (make-parameter #f))
(define current-window (make-parameter #f))

(define stdin (make-parameter #f))
(define stdout (make-parameter #f))

;; Globals

(define color-pair ncurses:COLOR_PAIR)

(define (new-screen [type #f])
  (ncurses:newterm type ncurses:stdout ncurses:stdin))

;; Screen

; Constructors

(define (new-window #:x x
                    #:y y
                    #:width width
                    #:height height
                    #:screen [screen (current-screen)]) 
  (ncurses:newwin_sp screen height width y x))

(define (new-pad #:width width
                 #:height height
                 #:screen [screen (current-screen)]) 
  (ncurses:newpad_sp screen height width))

; Predicates

(define (has-colors? #:screen [screen (current-screen)])
  (ncurses:has_colors_sp screen))

(define (has-mouse? #:screen [screen (current-screen)])
  (ncurses:has_mouse_sp screen))

(define (can-change-color? #:screen [screen (current-screen)])
  (ncurses:can_change_color_sp screen))

; State

(define (set-screen! #:screen [screen (current-screen)])
  (ncurses:set_term screen))

(define (set-echo! on #:screen [screen (current-screen)])
  (if on 
      (ncurses:echo_sp screen)
      (ncurses:noecho_sp screen)))

(define (set-c-break! on #:screen [screen (current-screen)])
  (if on 
      (ncurses:cbreak_sp screen)
      (ncurses:nocbreak_sp screen)))

(define (set-cursor! visibility #:screen [screen (current-screen)]) 
  (ncurses:curs_set_sp screen visibility))

(define (set-nap-millis! ms #:screen [screen (current-screen)]) 
  (ncurses:napms_sp screen ms))

(define (baud-rate #:screen [screen (current-screen)]) 
  (ncurses:baudrate_sp screen))

; Mouse

(define (%mouse-mask #:screen [screen (current-screen)] . masks) 
  (ncurses:mousemask_sp screen (foldr bitwise-ior 0 masks)))

(define (set-mouse-interval! interval #:screen [screen (current-screen)]) 
  (ncurses:mouseinterval_sp screen interval))

(define (get-mouse #:screen [screen (current-screen)])
  (let-values ([(id x y z bstate) (ncurses:getmouse_sp screen)])
    (list id x y z bstate)))

(define (unget-mouse event #:screen [screen (current-screen)])
  (ncurses:ungetmouse_sp screen event))

(define (set-mouse! on #:screen [screen (current-screen)])
  (if on
      (begin 
        (%mouse-mask #:screen screen 
                     ALL_MOUSE_EVENTS REPORT_MOUSE_POSITION)
        (fprintf (stdout) "\033[?1003h\n"))
      (begin 
        (fprintf (stdout) "\033[?1003l\n")
        (%mouse-mask #:screen screen 
                     0))))

; Styling

(define (start-color! #:screen [screen (current-screen)])
  (ncurses:start_color_sp screen))

(define (set-color-pair! id #:fg fg
                            #:bg bg
                            #:screen [screen (current-screen)])
  (ncurses:init_pair_sp screen id fg bg))

(define (assume-default-colors! #:screen [screen (current-screen)]
                                #:fg fg
                                #:bg bg)
  (ncurses:assume_default_colors_sp screen fg bg))

(define (color-content! #:color color
                        #:r r
                        #:g g
                        #:b b
                        #:screen [screen (current-screen)])
  (ncurses:color_content_sp screen color r g b))

; Effects

(define (do-update #:screen [screen (current-screen)]) 
  (ncurses:doupdate_sp screen))

(define (reset-screen #:screen [screen (current-screen)])
  (ncurses:endwin_sp screen))

(define (beep #:screen [screen (current-screen)])
  (ncurses:beep_sp screen))

;; Window

(define (copy-window #:from from #:to to 
                     #:from-x from-x #:from-y from-y 
                     #:to-x to-x #:to-y to-y 
                     #:width width #:height height 
                     #:overlay? overlay?)
  (ncurses:copywin from to 
                   from-y from-x 
                   to-y to-x 
                   height width 
                   overlay?))

(define (sub-window #:x x
                    #:y y
                    #:width width
                    #:height height
                    #:window [window (current-window)])
  (ncurses:subwin window height width y x))

(define (derive-window #:x x
                       #:y y
                       #:width width
                       #:height height
                       #:window [window (current-window)])
  (ncurses:derwin window height width y x))

; Destructor

(define (delete-window #:window [window (current-window)]) 
  (ncurses:delwin window))

; State

(define (set-keypad! on #:window [window (current-window)]) 
  (ncurses:keypad window on))

(define (set-no-delay! on #:window [window (current-window)])
  (ncurses:nodelay window on))

(define (window-x [window (current-window)])
  (ncurses:getbegx window))

(define (window-y [window (current-window)])
  (ncurses:getbegy window))

(define (window-position [window (current-window)])
  (cons (window-x window) (window-y window)))

(define (window-width [window (current-window)])
  (ncurses:getmaxx window))

(define (window-height [window (current-window)])
  (ncurses:getmaxy window))

(define (window-size [window (current-window)])
  (cons (window-width) (window-height)))

; Styling

(define (set-window-color! color 
                           #:window [window (current-window)])
  (ncurses:wcolor_set window color))

(define (attr-get #:window [window (current-window)])
  (let-values ([(attr pair opts) (ncurses:wattr_get window)])
    (cons attr pair)))

(define (attr-set! #:window [window (current-window)] . attrs)
  (ncurses:wattrset window (apply fold-attrs attrs)))

(define (attr-on! #:window [window (current-window)] . attrs)
  (ncurses:wattron window (apply fold-attrs attrs)))

(define (attr-off! #:window [window (current-window)] . attrs)
  (ncurses:wattroff window (apply fold-attrs attrs)))

(define (set-window-background! bg 
                                #:window [window (current-window)]
                                #:replace [replace #f])
  (if replace 
      (ncurses:wbkgd window bg)
      (ncurses:wbkgdset window bg)))

(define (change-window-attr n attr pair 
                            #:window [window (current-window)])
  (ncurses:wchgat window n attr pair #f))

; Input

(define (get-char #:window [window (current-window)])
  (ncurses:wgetch window))

; Output

(define (addch ch 
               #:window [window (current-window)]
               . attrs)
  (let* ([attrs (apply fold-attrs attrs)] 
         [ch (bitwise-ior (char->integer ch) attrs)])
    (ncurses:waddch window ch)))

(define (addchstr str
                  #:window [window (current-window)]
                  . attrs)
  (let* ([attrs (apply fold-attrs attrs)]
         [chlist (for/list ([ch (string->list str)])
                   (bitwise-ior (char->integer ch) attrs))]) 
    (ncurses:waddchstr window (ncurses:chlist->chstr chlist))))

(define (add-string! str
                     #:window [window (current-window)])
    (ncurses:waddwstr window str))

(define (border-set! #:window  [window (current-window)]
                     #:char-l  [sl #\│]
                     #:char-r  [sr #\│]
                     #:char-u  [su #\─]
                     #:char-d  [sd #\─]
                     #:char-ul [ul #\┌]
                     #:char-ur [ur #\┐]
                     #:char-dl [dl #\└]
                     #:char-dr [dr #\┘])

  (match-define (cons attr pair) (attr-get #:window window))

  (ncurses:wborder_set window
    (ncurses:setcchar (char->integer sl) attr pair #f) 
    (ncurses:setcchar (char->integer sr) attr pair #f) 
    (ncurses:setcchar (char->integer su) attr pair #f) 
    (ncurses:setcchar (char->integer sd) attr pair #f)
    (ncurses:setcchar (char->integer ul) attr pair #f) 
    (ncurses:setcchar (char->integer ur) attr pair #f) 
    (ncurses:setcchar (char->integer dl) attr pair #f) 
    (ncurses:setcchar (char->integer dr) attr pair #f)))

; Effects

(define (clear! #:window [window (current-window)])
  (ncurses:wclear window))

(define (blit! #:window [window (current-window)])
  (ncurses:wnoutrefresh window))

(define (refresh! #:window [window (current-window)])
  (ncurses:wrefresh window))

(define (set-leave-cursor! on
                           #:window [window (current-window)])
  (ncurses:leaveok window on))

(define (set-full-redraw! on
                          #:window [window (current-window)])
  (ncurses:clearok window on))

(define (clear-to-bottom! #:window [window (current-window)])
  (ncurses:wclrtobot window))

(define (clear-to-end-of-line! #:window [window (current-window)])
  (ncurses:wclrtoeol window))

; Cursor

(define (get-cursor #:window [window (current-window)])
  (cons (ncurses:getcurx window) (ncurses:getcury window)))

(define (move #:x x
              #:y y
              #:window [window (current-window)])
  (ncurses:wmove window y x))

; Mouse

(define (window-encloses? #:x x 
                          #:y y 
                          #:window [window (current-window)])
  (ncurses:wenclose window y x))

(define (transform-coord #:x x 
                         #:y y 
                         #:to-screen? to-screen? 
                         #:window [window (current-window)])
  (ncurses:wmouse_trafo window y x to-screen?))

