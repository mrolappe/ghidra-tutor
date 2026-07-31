; sample.s — shared demo program for 02-retro-amiga exercises 01, 03, 04
; (and, in its linked Hunk form, exercise 02's block-structure walk).
;
; Not functional Amiga software — it never runs, and OpenLibrary is called
; with no matching CloseLibrary/cleanup. Each block below exists purely to
; produce one recognition pattern from the corresponding guide, so every
; exercise in this module points at the same disassembly instead of five
; unrelated throwaway snippets. vasm Motorola syntax (vasmm68k_mot).

    section code,code

start:
    movem.l d2-d4/a2-a3,-(a7)      ; callee-saved spill, see 01-68000-recap.md
    link    a5,#-8                 ; stack frame, 8 bytes of locals

    ; --- exec.library / Kickstart pattern, see 03-exec-library-kickstart.md ---
    move.l  4.w,a6                 ; SysBase from the one fixed pointer at address 4
    lea     libname.l,a1           ; absolute long — cross-hunk refs need this,
                                    ; not (pc)-relative, since hunks can load
                                    ; at independent, non-adjacent addresses
    moveq   #0,d0
    jsr     -552(a6)               ; LVO OpenLibrary
    move.l  d0,-4(a5)

    ; --- custom chip register pokes, see 04-custom-chip-registers.md ---
    lea     $dff000,a0
    move.w  #$8200,$096(a0)        ; DMACON (write): bit15 SET/CLR=1 (set, not
                                    ; clear) + bit9 DMAEN=1 -> enable master DMA
    move.w  #$0040,$0a8(a0)        ; AUD0VOL (write): channel 0 volume
    move.w  #$0000,$09a(a0)        ; INTENA (write): clear interrupt enables

    ; --- a spread of addressing modes for the 68000-recap tour ---
    moveq   #4,d0
    move.l  (a5),d1                ; Register Indirect
    move.l  8(a5),d2                ; Register Indirect with Displacement
    move.l  0(a5,d0.w),d3           ; Address Register Indirect with Index
    move.l  #$1234,d4               ; Immediate

    unlk    a5
    movem.l (a7)+,d2-d4/a2-a3
    rts

    section data,data

libname:
    dc.b    'graphics.library',0
    even
