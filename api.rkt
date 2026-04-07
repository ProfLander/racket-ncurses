#lang racket/base

(require racket/match)

(require (prefix-in ncurses: "bindings/ncurses.rkt"))
(require (prefix-in panel: "bindings/panel.rkt"))
(require "constants.rkt")

(provide (all-from-out "constants.rkt"))
(provide (all-defined-out))

(define (fold-attrs attrs)
  (foldr bitwise-ior 0 attrs))

(define stdscr (make-parameter #f))

(define (attron #:win [win (stdscr)] . attrs)
  (ncurses:wattron win (fold-attrs attrs)))

(define (attroff #:win [win (stdscr)] . attrs)
  (ncurses:wattroff win (fold-attrs attrs)))

(define (attr-get)
  (match-let ([(list attr pair opts) (ncurses:attr_get)])
    (list attr pair)))

(define (attr-set! attr pair)
  (ncurses:attr_set attr pair #f))

(define (addstr str
                #:win [win (stdscr)]
                #:y   [y (ncurses:getcury win)]
                #:x   [x (ncurses:getcurx win)]
                #:n   [n -1]
                . attrs)
  (match-let* ([(list attr pair) (attr-get)])
    (parameterize ([stdscr win])
      (apply attron attrs)
      (ncurses:mvwaddnstr win y x str n)
      (attr-set! attr pair))))

(define (addchstr str
                  #:win [win (stdscr)]
                  #:y   [y (ncurses:getcury win)]
                  #:x   [x (ncurses:getcurx win)]
                  . attrs)
  (let* ([attrs (fold-attrs attrs)]
         [chlist (for/list ([ch (string->list str)])
                   (bitwise-ior (char->integer ch) attrs))]) 
    (ncurses:mvwaddchstr win y x (ncurses:chlist->chstr chlist))))

(define (addch ch #:win [win (stdscr)]
               #:y [y (ncurses:getcury win)]
               #:x [x (ncurses:getcurx win)]
               . attrs)
  (let* ([attrs (fold-attrs attrs)] 
         [ch (bitwise-ior (char->integer ch) attrs)])
    (ncurses:mvwaddch win y x ch)))

(define (getch #:win [win (stdscr)])
  (let ([byte (ncurses:wgetch win)])
    (if (< -1 byte) 
        (integer->char byte)
        #f)))

(define (border #:win     [win (stdscr)]
                #:char-l  [sl #\│] 
                #:char-r  [sr #\│] 
                #:char-u  [su #\─] 
                #:char-d  [sd #\─]
                #:char-ul [ul #\╭] 
                #:char-ur [ur #\╮] 
                #:char-dl [dl #\╰] 
                #:char-dr [dr #\╯])
  (ncurses:wborder_set win
    (ncurses:setcchar (char->integer sl) 0 0 #f) 
    (ncurses:setcchar (char->integer sr) 0 0 #f) 
    (ncurses:setcchar (char->integer su) 0 0 #f) 
    (ncurses:setcchar (char->integer sd) 0 0 #f)
    (ncurses:setcchar (char->integer ul) 0 0 #f) 
    (ncurses:setcchar (char->integer ur) 0 0 #f) 
    (ncurses:setcchar (char->integer dl) 0 0 #f) 
    (ncurses:setcchar (char->integer dr) 0 0 #f)))

(define (getmaxxy [win (stdscr)])
  (values (ncurses:getmaxx win) (ncurses:getmaxy win)))

(define (getmaxyx [win (stdscr)])
  (values (ncurses:getmaxy win) (ncurses:getmaxx win)))

(define (get-curxy win)
  (values (ncurses:getcurx win) (ncurses:getcury win)))

(define (get-curyx win)
  (values (ncurses:getcury win) (ncurses:getcurx win)))

(define echo! ncurses:echo)
(define noecho! ncurses:noecho)
(define nodelay ncurses:nodelay)

(define curs-set ncurses:curs_set)
(define newwin ncurses:newwin)
(define delwin ncurses:delwin)
(define keypad ncurses:keypad)
(define init-pair! ncurses:init_pair)

(define (refresh #:win [win (stdscr)])
  (ncurses:wrefresh win))

(define (color-pair n)
  (arithmetic-shift n 8))

(define (%with-ncurses func)
  (stdscr (ncurses:initscr))

  (when (ncurses:has_colors)
    (ncurses:start_color))

  (define init? #t)

  (define (cleanup!)
    (when init?
      (ncurses:endwin)
      (set! init? #f)))

  (call-with-exception-handler

    (lambda (exn)
      (cleanup!)
      exn)

    (lambda ()
      (call-with-continuation-barrier
        (lambda ()
          (dynamic-wind
            void
            (λ () (void (func)))
            cleanup!))))))

(define-syntax-rule (with-ncurses body ...)
  (%with-ncurses 
    (lambda () 
      body ...)))
