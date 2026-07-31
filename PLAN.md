# Ghidra Lernmaterialien — Curriculum-Aufbau

_Accepted plan, saved verbatim from `/Users/mrolappe/.claude/plans/ich-will-die-verwendung-modular-wilkinson.md` at Phase 0 completion. This is the reference for scope, phase breakdown, and conventions across all sessions — see [PROGRESS.md](PROGRESS.md) for live status._

## Context

Ziel ist es, in `/Users/mrolappe/studio/ghidra-lernen` (aktuell komplett leer, kein Git-Repo, keine bestehende Struktur) ein gestuftes, englischsprachiges Ghidra-Curriculum aufzubauen. Der Nutzer ist Ghidra-Anfänger, hat aber bereits Erfahrung mit mindestens einer Retro-CPU (68000 oder 6502) — reine Assembler-Grundlagen sind daher NICHT nötig, wohl aber kurze Architektur-Recaps beim Wechsel zwischen 68000- und 6502-Welt. Gewünschtes Format: vollständiger Kurs mit Übungen + Musterlösungen (nicht nur Referenzmaterial). Schwerpunkte: (1) schneller Einstieg + Alltags-Grundlagen, (2) Retro-Reverse-Engineering (Priorität: Amiga → Atari ST → C64), (3) Automatisierung/Scripting inkl. KI-Unterstützung via MCP (noch kein bestehendes MCP-Setup — muss recherchiert und empfohlen werden). Alle Fakten (Menüpfade, API-Namen, MCP-Projektnamen) müssen gegen aktuelle Ghidra-Doku/Web-Recherche verifiziert werden, nicht aus dem Gedächtnis generiert werden — Modellstärke ist hierfür ausreichend (Sonnet 5), die Sorgfaltspflicht liegt bei der Faktenprüfung, nicht bei der Modellwahl.

Rechtlicher Hinweis für Übungsmaterial: Für Retro-Phasen dürfen keine urheberrechtlich geschützten ROMs/Spiele verwendet werden. Stattdessen: selbst kompilierte Beispielprogramme (vasm/vbcc oder vasm+vlink für 68000, cc65 für 6502), Public-Domain-/Homebrew-/Freeware-Demoscene-Material, oder AROS (freier Kickstart-Ersatz) als Referenz.

## Struktur

```
ghidra-lernen/
  00-quickstart/                 # schneller Einstieg + Alltags-Basics
  01-core-workflows/             # generelle Ghidra-Workflows (nicht plattformspezifisch)
  02-retro-amiga/                # Schwerpunkt 1: Amiga (68000, AmigaOS)
  03-retro-atari-st/             # Schwerpunkt 2: Atari ST (68000, TOS)
  04-retro-c64/                  # Schwerpunkt 3: C64 (6502/6510)
  05-automation-scripting/       # Java/Jython/Ghidrathon/Headless-Analyzer
  06-ai-assisted-ghidra/         # MCP-Recherche + Setup + Workflows
  BACKLOG-future-topics.md       # vorgeschlagene weitere Meilensteine
```

Jedes Modul folgt dem Muster: nummerierte Markdown-Guides (Konzept + Schritt-für-Schritt) + `exercises/<slug>/{problem.md, sample/, solution.md}`. Spätere Module referenzieren explizit Begriffe/Setups aus früheren (z.B. „siehe 01-core-workflows/02 für Decompiler-Tuning" statt Wiederholung).

## Modul-Inhalte (Kurzfassung)

**00-quickstart** (Ziel: in kurzer Zeit produktiv, für regelmäßigen Gebrauch)
Installation/Setup, Projekt anlegen, Binary importieren + Auto-Analyse, UI-Tour (Listing, Decompiler, Symbol Tree, Data Type Manager, Function Graph), Basis-Annotationen (Umbenennen, Retyping, Kommentare), Cross-References/Bookmarks, Suche, Cheatsheet mit Shortcuts.

**01-core-workflows** (generelle Grundlagen für regelmäßige Nutzung, plattformunabhängig)
Data Types & Structures anlegen/importieren, Decompiler-Tuning (Calling Conventions, Function Signatures), Control-Flow- und Reference-Analyse, Function ID (FID) Datenbanken/Signaturen, Versionsvergleich (Version Tracking Grundzüge), kurzer Ausblick auf Scripting (Vertiefung in 05).

**02-retro-amiga**
68000-Recap (Kurz-Refresher, kein Vollkurs), Hunk-Executable-Format, exec.library/Kickstart-Grundlagen, Custom-Chip-Register (Agnus/Denise/Paula) im Disassembly erkennen, typische Copy-Protection-Patterns.

**03-retro-atari-st**
68000/TOS-Unterschiede zu Amiga, GEMDOS/BIOS/XBIOS-Calls erkennen, TOS-Executable-Format (PRG/TOS-Header).

**04-retro-c64**
6502/6510-Recap, Memory Map + Bank-Switching, KERNAL/BASIC-ROM-Referenzen im Disassembly, PRG-/Cartridge-Formate, VIC-II/SID-Register.

**05-automation-scripting**
Script Manager + Java-API-Grundlagen, Jython-Scripting, Ghidrathon (Python 3) als moderner Weg, Headless Analyzer für Batch-Verarbeitung.

**06-ai-assisted-ghidra**
Recherche + Empfehlung eines konkreten Ghidra-MCP-Servers (z.B. GhidraMCP-artige Projekte — vor Empfehlung aktuell verifizieren), Setup-Anleitung, sinnvolle KI-unterstützte RE-Workflows, Grenzen/Verifikationspflicht bei KI-Vorschlägen (Ghidra-Ausgaben von KI nie ungeprüft übernehmen).

## Vorgeschlagene weitere Themen (→ BACKLOG-future-topics.md, keine Inhalte jetzt)

Da der Nutzer explizit nach blinden Flecken gefragt hat, werden folgende Themen nur als kurze Vorschläge mit 1-2 Sätzen Begründung dokumentiert, nicht ausgearbeitet:
- Dynamische Analyse im Zusammenspiel mit Emulatoren (WinUAE/Hatari/VICE) neben Ghidras statischer Analyse
- BSim/Version Tracking vertieft für Patch-Diffing über mehrere Versionen
- Eigene SLEIGH-Prozessormodule schreiben (relevant für exotische/Custom-Silicon in Retro-Systemen)
- Ghidra Server / kollaborative Projekte für Teamarbeit
- Firmware-RE (ARM/MIPS) als Anschluss nach den 8/16-Bit-Retro-Systemen
- Malware-Analyse-Grundlagen inkl. sicherer Sandbox-Umgebung (falls Interesse über Retro-RE hinausgeht)
- Import proprietärer/undokumentierter Loader-Formate (eigene Loader schreiben)

## Modell-Empfehlung pro Schritt

Default für alle Schritte: **Sonnet 5** — Guide-Texte, Recherche/Faktencheck, Mermaid-Diagramme und einfache interaktive HTML-Demos sind textbasierte Fachtexterstellung + leichte Visualisierung, kein tiefes mehrstufiges Reasoning.

Einzige Ausnahme: **06-ai-assisted-ghidra**, Schritt „MCP-Projekt bewerten & empfehlen" — hier stehen mehrere konkurrierende Drittanbieter-MCP-Server zur Wahl, mit Abwägung von Wartungsstatus, Sicherheits-/Vertrauensgrenzen (ein LLM erhält Tool-Zugriff auf ein RE-Tool) und Zukunftssicherheit. Empfehlung: **Opus** für diesen einen Bewertungsschritt, wenn verfügbar — optional, kein Hard-Requirement, Sonnet 5 reicht auch hier im Zweifel.

## Visuelle & interaktive Materialien

Ergänzend zu den Markdown-Guides, wo es echten Mehrwert bringt (nicht in jedem Modul):

| Modul | Diagramm (Mermaid, inline in Markdown) | Interaktives HTML |
|---|---|---|
| 00-quickstart | Workflow-Pipeline: Import → Analyze → Browse → Annotate → Export | Durchsuchbares Shortcut-Cheatsheet |
| 01-core-workflows | Decompiler-Pipeline: Bytes → P-Code → Decompiler-Output | „Click-to-annotate"-Demo an einem Beispiel-Decompiler-Output (Variable anklicken → Erklärung) |
| 02-retro-amiga / 03-retro-atari-st | Hunk-/TOS-Executable-Layout | Custom-Chip-/Register-Explorer (Hover/Klick auf Adressbereich → Chip + Funktion) |
| 04-retro-c64 | PRG-Format-Layout | Memory-Map-Explorer $0000–$FFFF inkl. Bank-Switching-Zustände |
| 05-automation-scripting | Sequenzdiagramm Headless-Analyzer-Ablauf | — |
| 06-ai-assisted-ghidra | Architektur: Ghidra ↔ MCP-Server ↔ AI-Client ↔ Nutzer (inkl. Vertrauensgrenzen) | — |

HTML-Demos sind selbstständige, abhängigkeitsfreie Dateien (`*.html` im jeweiligen Modulordner), lokal im Browser nutzbar. Auf Wunsch kann einzelnes davon später zusätzlich als Artifact veröffentlicht werden (teilbarer Link) — Standard ist aber lokale Datei, da persönliches Kursmaterial.

**Zusätzlich vorgeschlagene Materialarten** (bringen laut Erfahrung Mehrwert, waren nicht explizit gefordert):
- **Flashcard-Deck** (Anki-importierbares CSV) für Shortcuts, Register-Namen, Format-Feldnamen — Spaced Repetition für Dinge, die man sich einfach merken muss.
- **Selbstchecks** (kurze Multiple-Choice-Fragen mit eingeklappter Lösung) am Ende jedes Guides, kein neues Werkzeug nötig, nur Markdown-Konvention.
- **Lab-Notebook-Template** (Markdown-Vorlage für strukturierte RE-Notizen pro Übung) — fördert von Anfang an gute Dokumentationsgewohnheiten.
- **Druckbares One-Page-Cheatsheet** pro Plattform (print-optimiertes Markdown/HTML).
- Nicht von mir erstellbar, nur als Hinweis: eigene Screen-Recordings/Video-Walkthroughs als optionale Ergänzung, falls visuelles Lernen zusätzlich helfen soll.

## Umsetzung

- Recherche-Schritte (Ghidra-Doku, MCP-Projektlandschaft) über die `research`-Skill-Logik: aktuelle Fakten sammeln, bevor Guides geschrieben werden — insbesondere für 06-ai-assisted-ghidra.
- Für Übungen mit Sample-Binaries: kleine Beispielprogramme selbst per Cross-Assembler/Compiler erzeugen (Build-Skript im `sample/`-Ordner mitliefern), keine urheberrechtlich geschützten ROMs/Spiele verwenden.
- Verifikation: jede Guide-Seite enthält nur Menüpfade/API-Namen/Shortcuts, die gegen offizielle Ghidra-Doku oder Ghidra-Sourcecode-Referenz geprüft wurden; bei Unsicherheit explizit als „zu prüfen mit installierter Version" kennzeichnen, da Ghidra hier noch nicht installiert ist.

## Session-/Kontext-Management: Repo & Phasen-Protokoll

Damit kein einzelner Schritt den Kontext einer Session sprengt, wird die Umsetzung in kleine, in sich abgeschlossene Phasen zerlegt — pro Phase eine eigene Session.

**Phase 0 — Repo-Setup (einmalig, vor allem anderen):**
1. `git init` im Projektverzeichnis `/Users/mrolappe/studio/ghidra-lernen`.
2. Öffentliches GitHub-Repo `ghidra-tutor` anlegen (z.B. via `gh repo create ghidra-tutor --public --source=. --remote=origin`).
3. Verzeichnisskelett (leere Modulordner gemäß Struktur oben), Root-`README.md` (Kursübersicht + Link auf `PROGRESS.md`), sowie `PROGRESS.md` als Fortschritts-/Übergabe-Log anlegen.
4. Initial-Commit, Push, dann **Stopp**.

**Phasen 1…N — Inhaltsaufbau**, jede Phase klein genug für eine Session, u.a.:

| # | Phase | Inhalt |
|---|---|---|
| 1 | 00-quickstart: Guides | Installation, Projekt/Import, UI-Tour, Cheatsheet |
| 2 | 00-quickstart: Übungen + Shortcut-HTML | Exercises/Solutions + interaktives Cheatsheet |
| 3 | 01-core-workflows: Guides + Diagramm | Data Types, Decompiler-Tuning, FID, Version Tracking |
| 4 | 01-core-workflows: Übungen + HTML-Demo | Exercises/Solutions + Click-to-annotate-Demo |
| 5 | 02-retro-amiga: Guides + Diagramm | 68000-Recap, Hunk-Format, exec.library/Kickstart |
| 6 | 02-retro-amiga: Übungen + Register-Explorer | Exercises/Solutions + Custom-Chip-HTML |
| 7 | 03-retro-atari-st: Guides + Diagramm | TOS/GEMDOS/BIOS/XBIOS, PRG-Format |
| 8 | 03-retro-atari-st: Übungen | Exercises/Solutions |
| 9 | 04-retro-c64: Guides + Diagramm | 6502-Recap, Memory Map, KERNAL-ROM |
| 10 | 04-retro-c64: Übungen + Memory-Map-Explorer | Exercises/Solutions + HTML |
| 11 | 05-automation-scripting: Guides + Diagramm + Übungen | Script Manager, Jython, Ghidrathon, Headless |
| 12 | 06-ai-assisted-ghidra: MCP-Recherche + Empfehlung + Architektur-Diagramm | (Opus-Kandidat, s.o.) |
| 13 | 06-ai-assisted-ghidra: Setup, Workflows, Verifikationsfallen + Übungen | |
| 14 | Querschnitt/Polish | BACKLOG.md, Flashcard-Deck, Lab-Notebook-Template, druckbare Cheatsheets, Root-README finalisieren |

Falls sich eine Phase beim tatsächlichen Schreiben doch als zu groß erweist (z.B. 05 oder 11), wird sie zur Laufzeit in weitere Teilschritte gesplittet — die Tabelle ist die Startaufteilung, keine starre Vorgabe.

**Abschlussprotokoll pro Phase** (verbindlich, jedes Mal):
1. `PROGRESS.md` aktualisieren: Abschnitt „Completed" (was in dieser Phase fertig wurde) + Abschnitt „Next" (genaue Bezeichnung der nächsten Phase aus obiger Tabelle, plus offene Punkte/Annahmen, falls vorhanden) + Abschnitt „Carried-forward notes" (Fakten/Entscheidungen, die mindestens eine Folgephase braucht).
2. `git add` + `git commit` (Commit-Message nennt die abgeschlossene Phase).
3. `git push` nach `origin`.
4. Danach **Sitzung beenden** — keine weitere Phase in derselben Session beginnen. Der Nutzer startet die nächste Phase in einer frischen Session (dort liefert `PROGRESS.md` den Einstiegspunkt).

**Delegation an Subagents:** Wird eine Phase (oder Teil davon) an einen Agent delegiert, bekommt dieser nur den für seine konkrete Teilaufgabe nötigen Ausschnitt (relevanter Modul-Scope aus diesem Plan + relevante Carried-forward-Notes aus PROGRESS.md + Ordner-/Datei-Konventionen) — nicht den gesamten Plan oder die volle Progress-Historie.
