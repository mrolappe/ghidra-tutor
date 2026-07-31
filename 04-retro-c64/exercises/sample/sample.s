; sample.s -- shared demo program for 04-retro-c64 exercises 01, 02, 03, 05
; (and, via its built PRG, exercise 04's header walk). ca65 syntax.
;
; Not functional C64 software in the sense of doing anything useful -- each
; block exists purely to produce one recognition pattern from the
; corresponding guide, so every exercise in this module points at the same
; disassembly instead of five unrelated throwaway snippets.

.segment "CODE"

start:
    ; --- addressing-mode tour, see 01-6502-6510-recap.md ---
    lda #$05            ; Immediate
    sta $02              ; Zero page
    ldx #$00
    lda $10,x            ; Zero page,X
    lda $0400            ; Absolute (default screen memory)
    lda $0400,x          ; Absolute,X

    ; --- bank-switch write, see 02-memory-map-bank-switching.md ---
    ; $36 = %00110110: LORAM=0 (BASIC ROM banked OUT to RAM), HIRAM=1
    ; (KERNAL stays banked IN -- needed by the JSR $FFD2 below), CHAREN=1
    ; (I/O banked in at $D000-$DFFF, not Character ROM)
    lda #$36
    sta $01

    ; --- KERNAL CHROUT call, see 03-kernal-basic-rom-references.md ---
    lda #$0d             ; carriage return
    jsr $ffd2            ; CHROUT

    ; --- VIC-II / SID pokes, see 05-vic-sid-registers.md ---
    lda #$00
    sta $d020            ; EC: border color = black

    lda #$00
    sta $d400            ; voice 1 frequency, low byte
    lda #$10
    sta $d401            ; voice 1 frequency, high byte
    lda #$11             ; waveform=triangle (bit4), GATE=1 (bit0): start envelope
    sta $d404            ; voice 1 control register

    rts
