; sample.s — shared demo program for 03-retro-atari-st exercises 01-03.
;
; Not functional TOS software — no cleanup, no matching teardown. Each block
; exists purely to produce one recognition pattern from the corresponding
; guide, so every exercise in this module points at the same disassembly
; instead of unrelated throwaway snippets. Deliberately code-only (no data/
; bss section) so exercise 03's PRG header walk gets clean, predictable
; PRG_dsize=0/PRG_bsize=0 fields. vasm Motorola syntax (vasmm68k_mot).

    section text

start:
    ; --- basepage access pattern, see 01-amiga-atari-differences.md ---
    move.l  4(sp),a0                ; obtain pointer to basepage
    move.l  $0c(a0),d0              ; p_tlen: TEXT segment length
    move.l  $18(a0),d1              ; p_bbase: base of BSS segment

    ; --- Mshrink(), GEMDOS opcode 0x4A via TRAP #1 ---
    ; see 01-amiga-atari-differences.md / 02-gemdos-bios-xbios-calls.md
    move.w  #$4A,-(sp)
    trap    #1

    ; --- Super(), GEMDOS opcode 0x20 via TRAP #1 ---
    ; see 01-amiga-atari-differences.md
    move.w  #$20,-(sp)
    trap    #1

    rts
