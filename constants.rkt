#lang racket/base

(provide (all-defined-out))

; Constants

(define NCURSES_ATTR_SHIFT 8)
(define (NCURSES_BITS mask shift) 
  (arithmetic-shift mask (+ shift NCURSES_ATTR_SHIFT)))

(define A_NORMAL                    0)
(define A_ATTRIBUTES                (NCURSES_BITS (bitwise-not 0) 0))
(define A_CHARTEXT                  (- (NCURSES_BITS 1 0) 1))
(define A_COLOR                     (NCURSES_BITS (- (arithmetic-shift 1 8) 1) 0))
(define A_STANDOUT                  (NCURSES_BITS 1 8))
(define A_UNDERLINE                 (NCURSES_BITS 1 9))
(define A_REVERSE                   (NCURSES_BITS 1 10))
(define A_BLINK                     (NCURSES_BITS 1 11))
(define A_DIM                       (NCURSES_BITS 1 12))
(define A_BOLD                      (NCURSES_BITS 1 13))
(define A_ALTCHARSET                (NCURSES_BITS 1 14))
(define A_INVIS                     (NCURSES_BITS 1 15))
(define A_PROTECT                   (NCURSES_BITS 1 16))
(define A_HORIZONTAL                (NCURSES_BITS 1 17))
(define A_LEFT                      (NCURSES_BITS 1 18))
(define A_LOW                       (NCURSES_BITS 1 19))
(define A_RIGHT                     (NCURSES_BITS 1 20))
(define A_TOP                       (NCURSES_BITS 1 21))
(define A_VERTICAL                  (NCURSES_BITS 1 22))

(define A_ITALIC                    (NCURSES_BITS 1 23))

(define COLOR_NONE                 -1)
(define COLOR_BLACK                 0)
(define COLOR_RED                   1)
(define COLOR_GREEN                 2)
(define COLOR_YELLOW                3)
(define COLOR_BLUE                  4)
(define COLOR_MAGENTA               5)
(define COLOR_CYAN                  6)
(define COLOR_WHITE                 7)

(define KEY_DOWN                    #o402)            ; down-arrow key ;
(define KEY_UP                      #o403)            ; up-arrow key ;
(define KEY_LEFT                    #o404)            ; left-arrow key ;
(define KEY_RIGHT                   #o405)            ; right-arrow key ;
(define KEY_HOME                    #o406)            ; home key ;
(define KEY_BACKSPACE               #o407)            ; backspace key ;
(define KEY_F0                      #o410)            ; Function keys.  Space for 64 ;
(define KEY_DL                      #o510)            ; delete-line key ;
(define KEY_IL                      #o511)            ; insert-line key ;
(define KEY_DC                      #o512)            ; delete-character key ;
(define KEY_IC                      #o513)            ; insert-character key ;
(define KEY_EIC                     #o514)            ; sent by rmir or smir in insert mode ;
(define KEY_CLEAR                   #o515)            ; clear-screen or erase key ;
(define KEY_EOS                     #o516)            ; clear-to-end-of-screen key ;
(define KEY_EOL                     #o517)            ; clear-to-end-of-line key ;
(define KEY_SF                      #o520)            ; scroll-forward key ;
(define KEY_SR                      #o521)            ; scroll-backward key ;
(define KEY_NPAGE                   #o522)            ; next-page key ;
(define KEY_PPAGE                   #o523)            ; previous-page key ;
(define KEY_STAB                    #o524)            ; set-tab key ;
(define KEY_CTAB                    #o525)            ; clear-tab key ;
(define KEY_CATAB                   #o526)            ; clear-all-tabs key ;
(define KEY_ENTER                   #o527)            ; enter;send key ;
(define KEY_PRINT                   #o532)            ; print key ;
(define KEY_LL                      #o533)            ; lower-left key (home down) ;
(define KEY_A1                      #o534)            ; upper left of keypad ;
(define KEY_A3                      #o535)            ; upper right of keypad ;
(define KEY_B2                      #o536)            ; center of keypad ;
(define KEY_C1                      #o537)            ; lower left of keypad ;
(define KEY_C3                      #o540)            ; lower right of keypad ;
(define KEY_BTAB                    #o541)            ; back-tab key ;
(define KEY_BEG                     #o542)            ; begin key ;
(define KEY_CANCEL                  #o543)            ; cancel key ;
(define KEY_CLOSE                   #o544)            ; close key ;
(define KEY_COMMAND                 #o545)            ; command key ;
(define KEY_COPY                    #o546)            ; copy key ;
(define KEY_CREATE                  #o547)            ; create key ;
(define KEY_END                     #o550)            ; end key ;
(define KEY_EXIT                    #o551)            ; exit key ;
(define KEY_FIND                    #o552)            ; find key ;
(define KEY_HELP                    #o553)            ; help key ;
(define KEY_MARK                    #o554)            ; mark key ;
(define KEY_MESSAGE                 #o555)            ; message key ;
(define KEY_MOVE                    #o556)            ; move key ;
(define KEY_NEXT                    #o557)            ; next key ;
(define KEY_OPEN                    #o560)            ; open key ;
(define KEY_OPTIONS                 #o561)            ; options key ;
(define KEY_PREVIOUS                #o562)            ; previous key ;
(define KEY_REDO                    #o563)            ; redo key ;
(define KEY_REFERENCE               #o564)            ; reference key ;
(define KEY_REFRESH                 #o565)            ; refresh key ;
(define KEY_REPLACE                 #o566)            ; replace key ;
(define KEY_RESTART                 #o567)            ; restart key ;
(define KEY_RESUME                  #o570)            ; resume key ;
(define KEY_SAVE                    #o571)            ; save key ;
(define KEY_SBEG                    #o572)            ; shifted begin key ;
(define KEY_SCANCEL                 #o573)            ; shifted cancel key ;
(define KEY_SCOMMAND                #o574)            ; shifted command key ;
(define KEY_SCOPY                   #o575)            ; shifted copy key ;
(define KEY_SCREATE                 #o576)            ; shifted create key ;
(define KEY_SDC                     #o577)            ; shifted delete-character key ;
(define KEY_SDL                     #o600)            ; shifted delete-line key ;
(define KEY_SELECT                  #o601)            ; select key ;
(define KEY_SEND                    #o602)            ; shifted end key ;
(define KEY_SEOL                    #o603)            ; shifted clear-to-end-of-line key ;
(define KEY_SEXIT                   #o604)            ; shifted exit key ;
(define KEY_SFIND                   #o605)            ; shifted find key ;
(define KEY_SHELP                   #o606)            ; shifted help key ;
(define KEY_SHOME                   #o607)            ; shifted home key ;
(define KEY_SIC                     #o610)            ; shifted insert-character key ;
(define KEY_SLEFT                   #o611)            ; shifted left-arrow key ;
(define KEY_SMESSAGE                #o612)            ; shifted message key ;
(define KEY_SMOVE                   #o613)            ; shifted move key ;
(define KEY_SNEXT                   #o614)            ; shifted next key ;
(define KEY_SOPTIONS                #o615)            ; shifted options key ;
(define KEY_SPREVIOUS               #o616)            ; shifted previous key ;
(define KEY_SPRINT                  #o617)            ; shifted print key ;
(define KEY_SREDO                   #o620)            ; shifted redo key ;
(define KEY_SREPLACE                #o621)            ; shifted replace key ;
(define KEY_SRIGHT                  #o622)            ; shifted right-arrow key ;
(define KEY_SRSUME                  #o623)            ; shifted resume key ;
(define KEY_SSAVE                   #o624)            ; shifted save key ;
(define KEY_SSUSPEND                #o625)            ; shifted suspend key ;
(define KEY_SUNDO                   #o626)            ; shifted undo key ;
(define KEY_SUSPEND                 #o627)            ; suspend key ;
(define KEY_UNDO                    #o630)            ; undo key ;
(define KEY_MOUSE                   #o631)            ; Mouse event has occurred ;
(define KEY_RESIZE                  #o632)            ; Terminal resize event ;

(define (NCURSES_MOUSE_MASK b m)
  (arithmetic-shift m (* (- b 1) 5)))

(define	NCURSES_BUTTON_RELEASED     #o01)
(define	NCURSES_BUTTON_PRESSED      #o02)
(define	NCURSES_BUTTON_CLICKED      #o04)
(define	NCURSES_DOUBLE_CLICKED      #o10)
(define	NCURSES_TRIPLE_CLICKED      #o20)
(define	NCURSES_RESERVED_EVENT      #o40)

(define	BUTTON1_RELEASED            (NCURSES_MOUSE_MASK 1 NCURSES_BUTTON_RELEASED))
(define	BUTTON1_PRESSED             (NCURSES_MOUSE_MASK 1 NCURSES_BUTTON_PRESSED))
(define	BUTTON1_CLICKED             (NCURSES_MOUSE_MASK 1 NCURSES_BUTTON_CLICKED))
(define	BUTTON1_DOUBLE_CLICKED      (NCURSES_MOUSE_MASK 1 NCURSES_DOUBLE_CLICKED))
(define	BUTTON1_TRIPLE_CLICKED      (NCURSES_MOUSE_MASK 1 NCURSES_TRIPLE_CLICKED))

(define	BUTTON2_RELEASED            (NCURSES_MOUSE_MASK 2 NCURSES_BUTTON_RELEASED))
(define	BUTTON2_PRESSED             (NCURSES_MOUSE_MASK 2 NCURSES_BUTTON_PRESSED))
(define	BUTTON2_CLICKED             (NCURSES_MOUSE_MASK 2 NCURSES_BUTTON_CLICKED))
(define	BUTTON2_DOUBLE_CLICKED      (NCURSES_MOUSE_MASK 2 NCURSES_DOUBLE_CLICKED))
(define	BUTTON2_TRIPLE_CLICKED      (NCURSES_MOUSE_MASK 2 NCURSES_TRIPLE_CLICKED))

(define	BUTTON3_RELEASED            (NCURSES_MOUSE_MASK 3 NCURSES_BUTTON_RELEASED))
(define	BUTTON3_PRESSED             (NCURSES_MOUSE_MASK 3 NCURSES_BUTTON_PRESSED))
(define	BUTTON3_CLICKED             (NCURSES_MOUSE_MASK 3 NCURSES_BUTTON_CLICKED))
(define	BUTTON3_DOUBLE_CLICKED      (NCURSES_MOUSE_MASK 3 NCURSES_DOUBLE_CLICKED))
(define	BUTTON3_TRIPLE_CLICKED      (NCURSES_MOUSE_MASK 3 NCURSES_TRIPLE_CLICKED))

(define	BUTTON4_RELEASED            (NCURSES_MOUSE_MASK 4 NCURSES_BUTTON_RELEASED))
(define	BUTTON4_PRESSED             (NCURSES_MOUSE_MASK 4 NCURSES_BUTTON_PRESSED))
(define	BUTTON4_CLICKED             (NCURSES_MOUSE_MASK 4 NCURSES_BUTTON_CLICKED))
(define	BUTTON4_DOUBLE_CLICKED      (NCURSES_MOUSE_MASK 4 NCURSES_DOUBLE_CLICKED))
(define	BUTTON4_TRIPLE_CLICKED      (NCURSES_MOUSE_MASK 4 NCURSES_TRIPLE_CLICKED))

(define	BUTTON5_RELEASED            (NCURSES_MOUSE_MASK 5 NCURSES_BUTTON_RELEASED))
(define	BUTTON5_PRESSED             (NCURSES_MOUSE_MASK 5 NCURSES_BUTTON_PRESSED))
(define	BUTTON5_CLICKED             (NCURSES_MOUSE_MASK 5 NCURSES_BUTTON_CLICKED))
(define	BUTTON5_DOUBLE_CLICKED      (NCURSES_MOUSE_MASK 5 NCURSES_DOUBLE_CLICKED))
(define	BUTTON5_TRIPLE_CLICKED      (NCURSES_MOUSE_MASK 5 NCURSES_TRIPLE_CLICKED))

(define	BUTTON_CTRL                 (NCURSES_MOUSE_MASK 6 #o01))
(define	BUTTON_SHIFT                (NCURSES_MOUSE_MASK 6 #o02))
(define	BUTTON_ALT                  (NCURSES_MOUSE_MASK 6 #o04))
(define	REPORT_MOUSE_POSITION       (NCURSES_MOUSE_MASK 6 #o10))

(define	ALL_MOUSE_EVENTS	          (- REPORT_MOUSE_POSITION 1))

(define	(BUTTON_RELEASE e x)        (bitwise-and e (NCURSES_MOUSE_MASK x #o01)))
(define	(BUTTON_PRESS e x)          (bitwise-and e (NCURSES_MOUSE_MASK x #o02)))
(define	(BUTTON_CLICK e x)          (bitwise-and e (NCURSES_MOUSE_MASK x #o04)))
(define	(BUTTON_DOUBLE_CLICK e x)   (bitwise-and e (NCURSES_MOUSE_MASK x #o10)))
(define	(BUTTON_TRIPLE_CLICK e x)   (bitwise-and e (NCURSES_MOUSE_MASK x #o20)))
(define	(BUTTON_RESERVED_EVENT e x) (bitwise-and e (NCURSES_MOUSE_MASK x #o40)))

