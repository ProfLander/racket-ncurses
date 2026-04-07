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

(define (border #:win [win (stdscr)]
                #:ch0 [ch0 0] #:ch1 [ch1 0] #:ch2 [ch2 0] #:ch3 [ch3 0]
                #:ch4 [ch4 0] #:ch5 [ch5 0] #:ch6 [ch6 0] #:ch7 [ch7 0])
  (ncurses:wborder win ch0 ch1 ch2 ch3 ch4 ch5 ch6 ch7))

(define (getmaxyx [win (stdscr)])
  (values (ncurses:getmaxy win) (ncurses:getmaxx win)))
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

(define (with-ncurses func
                      #:start-color? [start-color? #t])
  (stdscr (ncurses:initscr))
  (when (and (ncurses:has_colors) start-color?)
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
