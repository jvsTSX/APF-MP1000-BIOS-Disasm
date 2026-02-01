
; some notes about this machine

; 0000~03FF - RAM (1KB) (shared with motorola VDG)
; - 0000~01FF = doesn't affect video             (text mode) or holds graphics tilemap (graphics mode)
; - 0200~03FF = holds text and semigraphics data (text mode) or holds tile graphics    (graphics mode)
;
; 2000~2003 - PIA ports and registers
; 
; 4000~47FF - BIOS ROM (2KB) (reads appear to not decode)
;
; 6000~7FFF - unmapped (used by imagination machine control hardware and part of the BASIC ROM, can be used by the cartridge)
;
; 8000~9FFF - cartridge space 1 (8KB)
;
; A000~BFFF - cartridge space 2 (8KB) (used for imagination machine RAM)
;
; C000~DFFF - unmapped (can be used by the cartridge hardware)
;
; E000~FFFF - BIOS ROM mirror (2KB) (reads appear to not decode)

; addresses are decoded with a 74LS138 demultiplexer, using the 3 highest address lines on the CPU as the selector
; sourced from the schematics at https://www.orphanedgames.com/APF/apf_programming/apf_specific_documentation/APF_Programming_and_Technical_Assistance_Manual.pdf

; unless said otherwise, regions in-between are filled with mirrors of the previous region
; PIA will appear again at 2004~2007 and so on until 4000

; for some reason beyond my understanding, the BIOS is treated as being in $4000 range
; so the mirror at the end of the memory are only for the special exception vectors
; who designed this????

; there are more things that get added to the memory map when you equip the expansion to turn your MP1000
; into the imagination machine, but that has its own BIOS it seems so i'll not comment a lot about it here

; if you're wanting to develop your own mapper, just beware that it's around the $6000 range where
; the imagination machine memory things get mapped into, as well as extra RAM in between the cartridge
; and BIOS mirror ($A000~$DFFF)

; you can absol do that, but it will be an 'odyssey2 the voice' situation where your game won't work
; if the expansion is present

; ---------------------

; this firmware will display a menu at first
; if it doesn't see a cartridge, or a valid cartridge, it starts the built-in game 'Rocket Patrol'

; if it sees your game, it will carry out this sequence:
; 1. draw the rocket patrol menu BEFORE checking for your cartridge validity
; 2. check for the validity byte at $8000, it must be precisely $BB
; 3. take the bytes in $8001 and $8002 to point at a string that is printed over the rocket patrol title (terminated by $FF)
; 4. check the amount of games you have specified in $8003 (ASCII number 1~9)
;     - to proceed, the player must press a number that is less than specified, but not zero
; 5. check the amount of players you have specified in $8004 (ASCII number 1~9)
;     - if you specify 0 (literal 0, not ASCII) players, it will not prompt you and start the game already, or else it does the same as the game numbers
;     - if you have an actual number here, it will redraw the rocket patrol screen, but with "HOW MANY PLAYERS?" replacing the title
; 6. then finally, it clears the screen and jumps to to your cartridge at $8005

; the interrupt hook is taken over by the BIOS, but you can abuse a jump hook to make it
; jump into your own handler for your game

; SWI and NMI will reset the machine, because they're both set to the same place as the reset vector ($4000)

; latency isn't a big worry because this only ever happens on VBlank start or end (PIA controls this) 
; the vector will either take an indirect jump to one of two locations or increment seconds

.MEMORYMAP
DEFAULTSLOT 0
SLOT 0 START $4000 SIZE $800
.ENDME

.ROMBANKMAP
BANKSTOTAL 1
BANKSIZE $800
BANKS 1
.ENDRO

; i would do a RAM section but the way RAM is laid out here is painful
.DEFINE Keys_BitCnt          $01E5
.DEFINE Keys_RowCnt          $01EB
.DEFINE Keys_PlayerPtr       $01EC
.DEFINE Keys_KeyCodePtrHigh  $01F0
.DEFINE Keys_KeyCodePtrLow   $01F1
.DEFINE Keys_Current         $01F2
.DEFINE Keys_P1LastRow       $01F3
.DEFINE Keys_P1LastKey       $01F4
.DEFINE Keys_P2LastRow       $01F5
.DEFINE Keys_P2LastKey       $01F6
.DEFINE Keys_CurRowSel       $01F7

; semigraphics function (APF logo)
.DEFINE PrintSG_Source        $01E6
.DEFINE PrintSG_Dest          $01E8
.DEFINE PrintSG_PrintLength   $01EA
.DEFINE PrintSG_FrameLength   $01EB
.DEFINE PrintSG_NewLineLength $01ED
.DEFINE PrintSG_WorkSource    $04

; 16-bit add/sub functions
.DEFINE Math_TempHigh $01EE
.DEFINE Math_TempLow  $01EF

; string function
.DEFINE PrintStr_Dest   $04
.DEFINE PrintStr_Source $06

; interrupt vectors
.DEFINE I60J   $01C5
.DEFINE I60    $01FC
.DEFINE ISECJ  $01C7
.DEFINE ISEC   $01FD
.DEFINE T60    $01F8
.DEFINE TIME   $01FB
.DEFINE SECOND $01F9
.DEFINE MINUTE $01FA
; these are the official names as seen on the manual linked near the start of this file
; they're not very descriptive... but i hope to make it easier to search for them

; score keeping and game control
.DEFINE Score_P1            $018F
.DEFINE Score_P2            $018E
.DEFINE Score_HUDPtrHigh    $0192
.DEFINE Score_HUDPtrLow     $0193
.DEFINE ScoreSound_WaitCnt  $015C
.DEFINE PlayerStatePtr      $0190

; player missile
.DEFINE Missile_XPos       $015D
.DEFINE Missile_ShootTime  $015F
.DEFINE Missile_TileAddr   $0158
.DEFINE Missile_ShipPos    $015A

; spaceships (rockets?)
.DEFINE Ship_TempPtr        $0140
.DEFINE Ship_BottomVars     $0142
.DEFINE Ship_MiddleVars     $014C
.DEFINE Ship_TopVars        $0152
.DEFINE Ship_TempNewPos     $015A
.DEFINE Ship_TempNewPosLow  $015B
.DEFINE Ship_BottomResetPos $0144
.DEFINE Ship_MiddleResetPos $014E
.DEFINE Ship_TopResetPos    $0154

; star background
.DEFINE Stars_TempPtr $01C9
.DEFINE Stars_BaseVar $0181
.DEFINE Stars_TileNum $015A

; misc
.DEFINE PosSound_WaitCnt $01EC ; missile positioning sound
.DEFINE PopSlide_SaveStack $01E8
.DEFINE PopSlide_SourcePtr $01E6
.DEFINE Temp_High          $01E8
.DEFINE Temp_Low           $01E9

.BANK 0 SLOT 0
.ORGA $4000
NMI:
SWI_J:
START:
; reset and other unused vectors (NMI and SWI)
		clra 
		staa I60.w
		staa ISEC.w
		lds  #$01E4
		sei  
		ldab #$35
		stab $2003
		ldaa #-1;#$FF
		staa $2002
		clr  $2003
		staa $2002
		stab $2003
		ldab #$34
		stab $2001
		ldaa #-17;#$EF
		staa Keys_CurRowSel.w
		clr  Keys_P1LastKey.w
		clr  Keys_P2LastKey.w
		ldaa #$1F
		staa $2002
		cli  
	jmp  SystemInitDone

Sub_DrawInitialScreen:
	jsr  ClearScreen ; subroutine
		ldx  #GFX_APF_Logo
		stx  PrintSG_Source.w
		ldx  #$0208 ; VRAM (row 0, 1/4 col)
		ldaa #$06
	jsr  Sub_PrintSemigraphics
		ldx  #String_RocketMenu
		stx  PrintStr_Source    ; source pointer
		ldx  #$0268 ; VRAM (row 3, 1/4 col))
	jmp  Sub_PrintString

SystemInitDone:
	bsr  Sub_DrawInitialScreen
		ldaa $8000 ; first byte from cartridge
		cmpa #-69;#$BB  ; presence check, if not this byte, then assume no cartridge is inserted
	bne  CartSignatureFail
		ldx  $8001 ; second and third bytes from cartridge
		stx  PrintStr_Source
		ldx  #$02C0 ; VRAM position (same as rocket patrol's title)
		stx  PrintStr_Dest
	jsr  Sub_PrintString@Loop

@KeysLoop:
	bsr  Sub_WaitForPlayerInput
		cmpa #$30  ; 
	beq  @KeysLoop
		cmpa $8003 ; how many games this cartridge has?
	bgt  @KeysLoop 
		anda #$0F ; de-asciifies it to just 01~09
		staa $00
		ldaa $8004 ; how many players? if this value is 0 on the cartridge, it skips the prompt
	beq  @SkipPlayersPrompt
	bsr  Sub_DrawInitialScreen
		ldx  #String_Players
		stx  PrintStr_Source
		ldx  #$02C0
	jsr  Sub_PrintString

@KeysLoop2:
	bsr  Sub_WaitForPlayerInput
		cmpa #$30
	ble  @KeysLoop2
		cmpa $8004
	bgt  @KeysLoop2
		ldaa #$0F
		anda Keys_Current ; de-asciifies it to just 01~09
		staa $01
@SkipPlayersPrompt:
	jsr  ClearScreen
	jmp  $8005 ; cartridge!!!!!

; $8000: byte containing $BB
; $8001: string pointer high
; $8002: string pointer low
; $8003: amount of games in this cartridge
; $8004: amount of players (displays HOW MANY PLAYERS prompt if not set to 0)
; $8005: start of user program

; note  : the amount constants are in ASCII numbers, so if you want a 1, you specify $31
; note 2: the 0 to skip amount of players prompt is literal 0 ($00)


CartSignatureFail:
	bsr  Sub_WaitForPlayerInput ; no cartridge :(
		anda #$03
		staa $00
	jmp  InitRocketPatrol



Sub_WaitForPlayerInput:
@Wait:
	jsr  Sub_GetButtonPlayer2
	bcs  @InputDetected
	jsr  Sub_GetButtonPlayer1
	bcc  @Wait
@InputDetected:
		ldaa Keys_Current.w
JumpReturn:
	rts  


String_Players:
.db "HOW`MANY`PLAYERS?", $FF

Sub_PrintSemigraphics:
		staa PrintSG_PrintLength
		stx  PrintSG_Dest
		ldaa #$20
		suba PrintSG_PrintLength
		staa PrintSG_NewLineLength ; line width - length
@loop:
		ldx  PrintSG_Source
		ldaa $00,x
		cmpa #-1;#$FF
	beq JumpReturn ; terminator reached, exit... only happens outside of data frame context
		staa PrintSG_FrameLength
		inx  
		stx  PrintSG_Source
		ldab PrintSG_PrintLength
@loop2:
		ldaa $00,x ; grab another at next position
		inx  
		stx  PrintSG_WorkSource
		ldx  PrintSG_Dest
		staa $00,x
		inx  
		stx  PrintSG_Dest
		ldx  PrintSG_WorkSource
		decb       ; using line length as loop count
	bne @loop2
		ldaa PrintSG_NewLineLength
		ldx  PrintSG_Dest
	jsr Sub_AddByteToPointer ; advance scanline
		stx  PrintSG_Dest
		ldx  PrintSG_Source
		ldab PrintSG_PrintLength
		dec  PrintSG_FrameLength
	bne @loop2
		ldx  PrintSG_WorkSource
		stx  PrintSG_Source
	bra @loop ; gets next frame

;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; called from above
Sub_AddByteToPointer:
		stx  Math_TempHigh
		adda Math_TempLow
		staa Math_TempLow
	bcc  @NoCarry
		inc  Math_TempHigh
@NoCarry
		ldx  Math_TempHigh
	rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sub_SubtractBFromX:
		psha 
		stx  Math_TempHigh
		ldaa Math_TempLow ; low byte of stored X
		sba        ; a=a-b
		staa Math_TempLow
	bcc  @NoCarry
		dec  Math_TempHigh
@NoCarry:
		ldx  Math_TempHigh
		pula 
	rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; called from three places, one is a subroutine
Sub_PrintString:
		stx  PrintStr_Dest   ; store destination pointer
@Loop:
	bsr  Sub_GetTextChar ; get character
		ldx  PrintStr_Source   ; source pointer
		ldaa $00,x
		cmpa #-1;#$FF  ; terminator is $FF
	bne  @Loop
	rts  

Sub_GetTextChar:
	bsr  @CheckTextChar ; called from above
	blt  @ControlChar ; this branch will only be taken if the current value is $80 and above
		ldx  PrintStr_Dest   ; destination pointer
		oraa #$40  ; force text invert bit on %SICC CCCC
		staa $00,x
		inx  
		stx  PrintStr_Dest
	bra  Sub_GetTextChar ; increment VRAM dest and repeat

@CheckTextChar:
		ldx  PrintStr_Source    ; check for terminator byte
		ldaa $00,x  ; get source pointer
		cmpa #-1;#$FF   ; check if accumulator is positive or negative
	beq  @CharIsTerminator  ; if it's the terminator, leave and don't increment the source
		inx  
		stx  PrintStr_Source
@CharIsTerminator:
		tab  
	rts  ; that's 4 levels until here, oof


; control char for text sequences
@ControlChar:
		cmpa #-1;#$FF  ; if it's $FF, it's a terminator
	beq  @Done
		anda #$1F  ; isolate 5-bit parameter
		andb #$60  ; isolate 2-bit command
		lsrb
		lsrb 
		lsrb 
		lsrb 
		lsrb       ; B= ------xx
	beq  @Done ; (00) do nothing (unused? for fool proofing purposes?)
		decb 
	beq  Sub_GetTextChar ; (01) go back to normal decode loop (unused?)
		decb 
	beq  @GetByteToPrint ; (10) print a parameter amount of the next byte in the text sequence
		ldab  #$20  ; (11) print a parameter amount of spaces
@LoopStoreX:
		ldx  PrintStr_Dest
@ReptLoop:
		stab  $00,x
		inx  
		deca 
	bne  @ReptLoop ; print it X times.. ah
		stx  PrintStr_Dest ; store back destination
@Done:
	rts  

@GetByteToPrint:
		ldx  PrintStr_Source ; source pointer
		ldab  $00,x
		inx  
		stx  PrintStr_Source
	bra  @LoopStoreX

; control code summaries:
; binary     | hex   | description
; %100x xxxx - 8x 9x - unused? returns like some kind of NOP
; %101x xxxx - Ax Bx - unused? jumps back at the loop without a return
; %110x xxxx - Cx Dx - print the literal byte ahead X times
; %111x xxxx - Ex Fx - print a space (dark green) X times

; always have MSB set to 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; this routine reads the player inputs

; this is what the key matrix looks like

; 7 6 5 4   3 2 1 0  -  bit positions read from $2000

; 7 4 0 1   7 4 0 1
; < ^ > v   < ^ > v
; 9 6 ? 3   9 6 ? 3
; 8 5 ! 2   8 5 ! 2

; Player1   Player2

; the buttons are active low so 1 means released, pretty standard

; the physical controller looks like this

;    ^
;  <   >
;    v
;
; 7 8 9 0
; 4 5 6 ?
; 1 2 3 !

; but is wired in a weird messy way for... reasons?

; ? = Cl key
; ! = En key


Data_ControllerKeyCodes:
.db "1047SENW3?692!58"

Sub_PrepareButtonLoop:
		ldaa #$04
		staa Keys_RowCnt ; loop counter
		stx  Keys_PlayerPtr ; X pointer for current player
		ldaa $01,x ; 01F4 or 01F6 ... previous button press? these are cleared on start
	bne  @ThereWasKey
		ldaa #-9;#$0F7  ;11110111 row select byte
		staa $00,x
@ThereWasKey:
		ldaa $00,x
		staa Keys_CurRowSel
	rts  

Sub_GetButtonPlayer1:
		ldx  #Keys_P1LastRow ; check player 1
	bsr  Sub_PrepareButtonLoop
@Loop:
	bsr  SubFn_SetKeyMatrixRowAndAdjustPointer
		ldaa $2000  ; read the row
		lsra        ; player 1 bits are at the MSB, so shift-right them to low nybble
		lsra 
		lsra 
		lsra 
		cmpa #$0F
	bne  SubFn_ButtonInRowDetected
	bsr  SubFn_PrepareNextRow
		dec  Keys_RowCnt ; iterate all 4 rows
	bne  @Loop
	bra  SubFn_NoButtonsDetected

Sub_GetButtonPlayer2:
		ldx  #Keys_P2LastRow ; check player 2
	bsr  Sub_PrepareButtonLoop
@Loop:
	bsr  SubFn_SetKeyMatrixRowAndAdjustPointer
		ldaa $2000
		anda #$0F
		cmpa #$0F
	bne  SubFn_ButtonInRowDetected
	bsr  SubFn_PrepareNextRow
		dec  Keys_RowCnt ; iterate all 4 rows
	bne  @Loop

SubFn_NoButtonsDetected:
		ldx  Keys_PlayerPtr ; X pointer for current player
		clr  $01,x
		clc  
	rts  

SubFn_ButtonInRowDetected:
		ldab #$03 ; limit 3 bits
	bsr  Sub_CountSetBits
		addb Keys_KeyCodePtrLow
		stab Keys_KeyCodePtrLow
		ldx  Keys_KeyCodePtrHigh ; get key code
		ldab $00,x
		ldx  Keys_PlayerPtr ; X pointer for current player
		cmpb $01,x
	beq  @SameKey ; equal to last frame's press?
		ldaa Keys_CurRowSel
		staa $00,x
		stab $01,x
@ReportNewPress:
		stab Keys_Current ; seems to be where the controller code is stored at
		sec  
	rts  
@SameKey:
		cmpb #$45 ; letter E for East, letters have a higher code than the numbers and ?! symbols
	bge  @ReportNewPress ; so, if it's the directions, and they match what they were the last frame, report as new button pressed through the carry flag
		clc  ; or else it's the other keys, and report them as not pressed if detected the same one again
	rts  
		nop  ; nop


SubFn_SetKeyMatrixRowAndAdjustPointer:
		ldaa #-32;#$E0
		anda $2002 ; control row selector and VDG control
		staa Keys_KeyCodePtrHigh ; row selector with all lines selected (active low)
		ldaa #$1F
		anda Keys_CurRowSel
		oraa Keys_KeyCodePtrHigh
		staa $2002 ; select row

		ldab #$04 ; limit 4 bits
	bsr  Sub_CountSetBits
		ldx  #Data_ControllerKeyCodes
		stx  Keys_KeyCodePtrHigh ; sets 01F1
		clc  
		aslb 
		aslb 
		addb Keys_KeyCodePtrLow
		stab Keys_KeyCodePtrLow
	bcc  @NoCarry
		inc  Keys_KeyCodePtrHigh
@NoCarry:
	rts  

SubFn_PrepareNextRow:
		ldab Keys_CurRowSel
		sec  
		rorb 
	bcc  @LastShift
@Exit:
		stab Keys_CurRowSel
	rts  
@LastShift:
		ldab #-9;#$F7
	bra  @Exit

Sub_CountSetBits:
		clr  Keys_BitCnt
		sec  
@Loop:
		lsra 
	bcc  @ZeroFound
		inc  Keys_BitCnt
		decb 
	bne  @Loop
@ZeroFound:
		ldab Keys_BitCnt
	rts  

; variables because this is too messy to keep track
; 01E5 = bit counting loop
; 01EB = controller rows counter
; 01EC ~ 01ED = long pointer for specified player variables
; 01F0 ~ 01F1 = long pointer for table of key codes, 01F0 is also a temp variable
; 01F2 = resulting key code (return value)
; 01F3 = player 1 last row
; 01F4 = player 1 last key code
; 01F5 = player 2 last row
; 01F6 = player 2 last key code
; 01F7 = current row selected

; if you're not completely confused by now, congratulations
; this took me way too long to figure out

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

		ldab #$05 ; 426C - unused instruction
Sub_PlayerMoveSound:
		stab PosSound_WaitCnt ; wait reload
	bsr  Sub_ToggleSoundLatch
@Wait1:
		decb 
	bne  @Wait1 ; wait for one level of the waveform
	bsr  Sub_ToggleSoundLatch
		inc  PosSound_WaitCnt ; increase period (lowers frequency)
		ldab PosSound_WaitCnt
@Wait2:
		decb 
	bne  @Wait2 ; wait for the other level of the waveform
		ldab PosSound_WaitCnt ; doesn't increase to make one full square cycle before raising period
	bsr  Sub_ToggleSoundLatch
		cmpb #$5F
	bne  @Wait1
	rts  

; suspiciously sound generation shaped
; it is sound!
Sub_ToggleSoundLatch:
		sei  
		ldaa $2003 ; control reg B (PIA)
		eora #$08  ; toggle CB2 (audio latch)
		staa $2003
		cli  
	rts  

ClearScreen:
		ldaa #-128;#$80
ClearScreenNoImm:
		ldx  #$0400 ; clears vram/gtiles in decrementing order
@Loop:
		dex  
		staa $00,x
		cpx  #$0200
	bne  @Loop
	rts  



;    //////////////////////////////////////////////////////
;   ///             global interrupt vector            ///
;  //////////////////////////////////////////////////////
IRQ:
		ldaa $2002 ; acknowledge the interrupt, or else it'll fire again when returning
		tst  I60 ; set this to anything non-zero
	beq  @SkipRedirect
		ldx  I60J ; and set your game's interrupt handler pointer here
	jsr  $00,x ; return by discarding the return address
@SkipRedirect:
		inc  T60
	bvc  @NoResetCounter ; wraps to 0 at $7F
		clr  T60
@NoResetCounter:
		inc  TIME
		ldaa #59
		cmpa TIME
	bgt  @Exit
		tst  ISEC
	beq  @SkipRedirect2
		ldx  ISECJ ; second interrupt hook, rocket patrol doesn't use it
	jsr  $00,x
@SkipRedirect2:
		clr  TIME ; clear 60-frame counter
		clc  

		ldaa SECOND ; seconds counter
		cmpa #$59
	beq  @OneMinute
		adda #$01
		daa  
		staa SECOND
@Exit:
	rti  

@OneMinute:
		clr  SECOND
		ldaa MINUTE ; minutes counter
		cmpa #-103;#$99
	beq  IRQ_HundredMinutes
		adda #$01
		daa  
		staa MINUTE
	rti  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; unrelated subroutine
Sub_Popslide:
		psha 
		sei  
		sts  PopSlide_SaveStack
		lds  PopSlide_SourcePtr
		des  
@Loop:
		pula 
		staa $00,x
		inx  
		decb 
	bne  @Loop
		lds  PopSlide_SaveStack
		cli  
		pula 
	rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IRQ_HundredMinutes:
		clr  MINUTE
	rti

; end of IRQ

GFX_APF_Logo:
.db $01, $EC, $EA, $EE, $EA, $EE, $E8
.db $01, $9E, $9A, $9E, $98, $9E, $98
.db $01, $DC, $D8, $D8, $80, $D8, $80, $FF

String_RocketMenu:
.db "TV MICRO-COMPUTER",      $CF, $80 ; print (the ahead char) 16 times, char ahead is black semigraphics with green chroma
.db "COPYRIGHT APF1978",      $DB, $80, $CC, $80, $E8 ; print the remaining black semigraphics, then print ascii spaces (dark green)
.db "ROCKET PATROL",          $F4, $F7 ; print the remaining spaces
.db "1. TWO PLAYER",          $D3, $8F ; fill the rest of the line with green semigraphics
.db "2. PLAYER AND COMPUTER", $CA, $8F, $FF ; fill the rest of the line with green semigraphics, end of string


; 33 subroutines, oof
; someone at APF really liked subroutines

; shotgun disasm shot me!
; manually solve 4380
;437f: ff b6 20  stx  $B620
;4382: 02        illegal

; graphics tiles list:
; 200 - part of the hud, not used as graphics
; 210 - part of the hud, part 1 of ship explosion
; 220 - part of the hud, part 2 of ship explosion
; 230 - part of the hud, part 3 of ship explosion
; 240 - part of the hud, part 4 of ship explosion
; 250 - part of the hud
; 260 - part of the hud
; 270 - part of the hud
; 280 - part 1 of the ship sprite
; 290 - part 2 of the ship sprite
; 2A0 - part 3 of the ship sprite
; 2B0 - part 4 of the ship sprite
; 2C0 - part 5 of the ship sprite
; 2D0 - 
; 2E0 - 
; 2F0 - 
; 300 - 
; 310 - 
; 320 - 
; 330 - 
; 340 - empty background tiles
; 350 - background with star
; 360 - 
; 370 - player missile
; 380 - 
; 390 - 
; 3A0 - 
; 3B0 - 
; 3C0 - 
; 3D0 - 
; 3E0 - 
; 3F0 - 

; first g-tile rows are covered by a semigraphics hud

; !!! WARNING !!!
; POTENTIAL BAD EMULATION FROM MAME
; G-TILEMAP STARTS AT $000 NORMALLY, BUT TYPICAL
; MONOCHROME GRAPHICS GAMES WILL ADD A TEXT HUD THAT
; MAY CAUSE THE VDG ADDRESS INCREMENTER TO BEHAVE WEIRD

; MAME ALWAYS ASSUME AN OFFSET CORRESPONDING TO SPACE PATROL'S HUD
; USE COLOR GRAPHICS FOR HOMEBREW BECAUSE IT ASSUMES NO OFFSET

; or convince MAME devs about this... my best wishes to you

; each row is 32 tiles, each row is 16 pixels tall

; with that in mind, we now know that variables can only exist at $180 and onwards until $200 (128 bytes of WRAM)

; and 140~1FF for this game specifically (192 bytes of WRAM)

; notes:
; - the missile climbs up to 6 tiles until it disappears
; - there are 6 rows of stars
; - there are 3 rows of ships

; game variable activity only appears to happen at
; $140~15F and $180~19F


;    //////////////////////////////////////////////////////
;   ///           built-in game initialization         ///
;  //////////////////////////////////////////////////////
InitRocketPatrol:
		ldaa $2002
		anda #$3F
		oraa #-64;#$C0
		staa $2002
		ldaa $2001
		anda #-57;#$C7  ;11000111
		oraa #$38       ;00111000 could be ored directly, but could be a 'just in case' scenario where another configuration is needed
		staa $2001      ; this sets CA2 to mpu-controlled output mode and to a level of 1, which will turn text orange and the ships white
		clra 
	jsr  ClearScreenNoImm ; that area becomes tile data now so clear it to 0 instead of black semigraphics
		ldx  #String_RocketPatrolHUD
		stx  PrintStr_Source
		ldx  #$0200
	jsr  Sub_PrintString

		ldx  #PlayerIsPlayer2
		ldaa $00 ; check if the player entered 1 (2 players)
		deca 
	beq  @TwoPlayers
		ldx  #String_COMPUTER
		ldab #$08 ; length of string (just computer)
		ldaa #$31
	jsr  Sub_HUDPrintString
		ldx  #PlayerIsComputer
@TwoPlayers:
		stx  PlayerStatePtr

; blanks out the entire graphics tilemap area, assuming no HUD offset
		ldx  #$0000
		ldaa #$54
@InitGTileMap:
		staa $00,x
		inx  
		cpx  #$0180
	bne  @InitGTileMap

		clra 
		ldab #$1E
		ldx  #Ship_BottomVars
	jsr  Sub_FillLoop ; clear RAM until $160
		ldx  #Interrupt_FrameEnd
		stx  I60J ; initializes interrupt call 1

; initialize missile
		ldx  #$012F ; bottom center of g-tilemap
		ldaa #$02
		staa Score_HUDPtrHigh
		stx  Missile_XPos
	bsr  Sub_InitMissileGraphics

; initialize stars
		ldaa #-64;#$C0
		ldx  #$0350 ; star tile
		staa $07,x
		ldx  #GFX_StarsData
		stx  PopSlide_SourcePtr
		ldx  #Stars_BaseVar
		ldab #$0C
	jsr  Sub_Popslide
	jsr  Sub_DrawStarField

; initialize ships
		ldx  #GFX_ShipData
		stx  PopSlide_SourcePtr
		ldx  #Ship_BottomVars
		ldab #$0A
	jsr  Sub_Popslide ; initial state for bottom ship and RAM ship header
		inc  I60
		clr  MINUTE
		clr  SECOND
		clr  Score_P2
		clr  Score_P1
		ldx  #Ship_BottomVars
		stx  Ship_TempPtr
	jsr  Sub_ResetAndDrawShips



;    //////////////////////////////////////////////////////
;   ///          player logic and main loop            ///
;  //////////////////////////////////////////////////////

Main_Loop:
		ldaa MINUTE ; minutes* counter
		cmpa #$02
	blt  Main_FiringMissile
		cmpa #$03
	bgt  GameEnd
		ldx  #PlayerIsPlayer1 ; after 2 half-minutes, the game changes to player 1's turn
		stx  PlayerStatePtr

Main_FiringMissile:
		ldab Missile_ShootTime
	beq  Main_NoMissile
	jsr  Sub_ToggleSoundLatch
		ldab #-33;#$DF
@ToneWaitLoop:
		decb 
	bne  @ToneWaitLoop
	bra  Main_FiringMissile

Main_NoMissile:
	bsr  Sub_InitMissileGraphics
		ldx  PlayerStatePtr
	jsr  $00,x ; handle player vector
	bra  Main_Loop

; * this game seems to fire on both edges of vblank so it counts half-seconds

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sub_InitMissileGraphics:
		ldx  #$0770 ; location of graphics tile 17, going to a mirror of $370 for some weird reason
	jsr  Sub_ZeroFill_16
		ldaa #$18
		staa $077C
		ldaa #$7E
		staa $077D
		ldx  Missile_XPos
		ldaa #$57 ; tile entry corresponding to the missile
		staa $00,x
	rts  

; 0770 masked out by 10 bits gives 370

; 0140 = pointer to the RAM variable base of the current ship to process
; 0142 = RAM variable base of bottom ship
; 0148 = pointer to where ship graphics are in ROM
; 014A = pointer to where ship tile data is located in RAM
; 014C = RAM variable base of middle ship
; 0152 = RAM variable base of top ship

; 015C = square wave counter
; 015A = ship collision compare address
; 0158 = player missile address

; 018E = player 2 score
; 018F = player 1 score
; 0190 = player state pointer
; 0192 = HUD address for printing score

; 01C9 = stars address

GameEnd:
		clr  MINUTE

@Wait:
		ldaa #$07 ; wait around 3 minutes before disabling the game to not burn it on your TV
		cmpa MINUTE
	bne  @Wait
		
		clr  I60 ; disable redirect flag
		
		ldaa $2002 ; set text/semigraphics
		anda #$7F
		staa $2002
		
		ldaa #-128;#$80
	jsr  ClearScreenNoImm
@LockLoop:
	bra  @LockLoop ; screensaver lock


Sub_HUDPrintString:
		staa Temp_Low
		ldaa #$02
		staa Temp_High
		stx  PopSlide_SourcePtr
		ldx  Temp_High
	jmp  Sub_Popslide


DisplayScore:
		staa Temp_High
		lsra ; isolate high digit
		lsra 
		lsra 
		lsra 
	beq  @UpperDigitIsZero
		aba  

@DispLowerDigit:
		staa $00,x
		ldaa Temp_High
		anda #$0F
		aba  
		staa $01,x
	rts  ; aaaaand done, that jumped all over the place

@UpperDigitIsZero:
		ldaa #$60 ; space (inverted)
	bra  @DispLowerDigit


CommonReturn1:
	rts  


PlayerIsPlayer2:
	jsr  Sub_GetButtonPlayer2
@NoInputs:
		ldaa #-113;#$8F
		ldab #-49;#$CF
	bsr  DrawCurrentPlayerIndicator
		ldab #$3D ; HUD address low byte
		ldx  #Score_P2
	bcs  CheckPlayerInput
	bra  PlayerHasScored

PlayerIsPlayer1:
	jsr  Sub_GetButtonPlayer1
		ldaa #-49;#$CF
		ldab #-113;#$8F
	bsr  DrawCurrentPlayerIndicator
		ldab #$21 ; HUD address low byte
		ldx  #Score_P1
	bcs  CheckPlayerInput

PlayerHasScored:
		ldaa ScoreSound_WaitCnt
	beq  CommonReturn1
@SoundLoop:
	jsr  Sub_ToggleSoundLatch
		ldaa #$70
@Wait:
		deca 
	bne  @Wait
		dec  ScoreSound_WaitCnt
	bne  @SoundLoop
		
		ldaa $00,x
		adda #$01
		daa  
		staa $00,x
		stab Score_HUDPtrLow
		ldx  Score_HUDPtrHigh
		ldab #$70
	bra  DisplayScore

; called from above
DrawCurrentPlayerIndicator:
		ldx  #$0200
		staa $20,x
		stab $3C,x
	rts  

CheckPlayerInput:
		ldx  Missile_XPos
		ldaa Keys_Current ; current key code
		cmpa #'E'
	beq  Player_PressedRight
		cmpa #'!'
	beq  Player_PressedFire
		cmpa #'W'
	bne  CommonReturn1

; player pressed left
		dex  
		cpx  #$0125
	beq  CommonReturn1
		ldaa #$54
		staa $01,x


WritePosAndSound:
		stx  Missile_XPos
		ldaa #$57
		staa $00,x
		ldab #$50
	jsr  Sub_PlayerMoveSound
CommonReturn2:
	rts


Player_PressedRight:
		cpx  #$013A
	beq  CommonReturn2
		ldaa #$54
		staa $00,x
		inx  
	bra  WritePosAndSound



Player_PressedFire:
		ldaa #-59;#$C5
		staa Missile_ShootTime
		ldx  Missile_XPos
		stx  Missile_TileAddr
		ldaa #$57
		staa $00,x
		ldx  #String_FIRE
		ldaa #$2C
		ldab #$04
	jmp  Sub_HUDPrintString

PlayerIsComputer:
		ldaa #$06
		bita T60
	beq  @NoFire
	bsr  Player_PressedFire
@NoFire:
	jmp  PlayerIsPlayer2@NoInputs



;    //////////////////////////////////////////////////////
;   ///                interrupt code                  ///
;  //////////////////////////////////////////////////////

; one of the locals loaded into X from the IRQ vector
Interrupt_FrameEnd:
		ldaa $2003 ; interrupts configuration (CB1)
		anda #-4;#$FC ; 1111 1100
		oraa #$03
		staa $2003
		ldx  #Interrupt_FrameStart
		stx  I60J
	jsr  Sub_ScrollStarField
	bra  MoveAndCheckMissile

Interrupt_FrameStart:
		ldx  #Interrupt_FrameEnd
		stx  I60J
		ldaa $2003 ; same as above, with only LSB set
		anda #-4;#$FC ; 1111 1100
		oraa #$01
		staa $2003
		ldx  #$0064
@Wait1:
		dex  
	bne  @Wait1
		ldaa $2002 ; enable text for the hud
		anda #$7F
		staa $2002
		ldx  #$01A0
@Wait2:
		dex  
	bne  @Wait2
		ldaa $2002 ; enable graphics mode
		oraa #-128;#$80
		staa $2002
	jsr  Sub_ScrollSpriteRow
		ldaa #$01
		bita MINUTE ; speed ships up during odd minutes/half-minutes
	beq  CommonReturn3
	jsr  Sub_ScrollSpriteRow
CommonReturn3:
	rts  



;    //////////////////////////////////////////////////////
;   ///                handle missile                  ///
;  //////////////////////////////////////////////////////
MoveAndCheckMissile:
		ldaa Missile_ShootTime
	beq  CommonReturn3
		dec  Missile_ShootTime
	bne  MissileMidScreen
		ldx  Missile_TileAddr
		ldab #$54 ; blank tile
		stab $00,x
	bra  MissileDespawned

MissileMidScreen:
		ldx  #Ship_BottomVars
	bsr  Sub_CheckMissileCollision ; check against bottom ship
		ldx  #Ship_MiddleVars
	bsr  Sub_CheckMissileCollision ; and middle ship
		ldx  #Ship_TopVars
	bsr  Sub_CheckMissileCollision ; and top ship

		anda #$03
	bne  MissileDone ; only move missile every 4 frames
		ldx  #$0770
		ldaa $00,x
	bne  MissileMoveTile

@Loop:
		ldaa $02,x
		staa $00,x
		clr  $02,x
		inx  
		cpx  #$077E
	bne  @Loop
	rts  

Sub_CheckMissileCollision:
		stx  Missile_ShipPos
		ldx  $00,x
		inx  
		ldab #$04
@loop:
		cpx  Missile_TileAddr
	beq  MissileHitShip
		inx  
		decb 
	bne  @loop
	rts  

MissileMoveTile:
		ldaa $00,x ; wrap the missile graphics
		staa $0E,x
		ldaa $01,x
		staa $0F,x
		clr  $00,x
		clr  $01,x
		ldx  Missile_TileAddr ; and move the missile tile up the tilemap
		ldaa #$54
		staa $00,x
		ldab #$20
	jsr  Sub_SubtractBFromX
		stx  Missile_TileAddr
		ldaa #$57
		staa $00,x
	rts  

MissileHitShip:
		ldx  Missile_ShipPos
		ldab #-65;#$BF
		stab ScoreSound_WaitCnt
		ldab #$20
		stab $04,x ; force ship "position" to going offscreen left
		clr  $05,x ; initial ship tile (explosion)
		clr  Missile_ShootTime

MissileDespawned:
		ldx  #$8F8F ; it replaces the HUD positions where "FIRE" is printed at by four green semigraphic squares
		stx  $022C
		stx  $022E
MissileDone:
	rts  



;    //////////////////////////////////////////////////////
;   ///                 handle stars                   ///
;  //////////////////////////////////////////////////////
Sub_ScrollStarField:
		ldx  #$0350 ; star g-tile location
		clc  
		ror  $07,x
	bcs  @MoveStarTiles ; shift stars until they get into the carry, if they look a bit uneven when moving, that's why
	rts  

@MoveStarTiles:
		ldaa #-64;#$C0
		staa $07,x
		ldaa #$54 ; blank tile, i assume it's cleaning the trail of stars?
	bsr  Sub_ClearStarField

; move stars forwards
		ldx  #Stars_BaseVar
		ldab #$06
@MoveLoop:
		ldaa $01,x
		anda #$1F
		cmpa #$1F
	bne  @NoWrap
		ldaa $01,x ; wrap it around back to $0x0
		anda #-32;#$E0
		staa $01,x ; that's why stars don't appear near the missile, it's $1xx range down there
@NoWrap:
		inc  $01,x
		inx  
		inx  
		decb 
	bne  @MoveLoop

Sub_DrawStarField:
		ldaa #$55 ; star gtile index

Sub_ClearStarField:
		ldab #$06 ; iterating through all 6 pairs
		ldx  #Stars_BaseVar ; ram base location of stars
		stx  Stars_TempPtr
		staa Stars_TileNum
@DrawLoop:
		ldx  $00,x ; reference location
		ldaa $00,x
		cmpa #$55 ; check if it's a star or blank tile
	beq  @CanDraw
		cmpa #$54
	bne  @CannotDraw ; if it's a ship or the missile, don't draw over
@CanDraw:
		ldaa Stars_TileNum
		staa $00,x
@CannotDraw:
		ldx  Stars_TempPtr
		inx  
		inx  
		stx  Stars_TempPtr
		decb 
	bne  @DrawLoop
	rts  



;    //////////////////////////////////////////////////////
;   ///                 handle ships                   ///
;  //////////////////////////////////////////////////////
Sub_ScrollSpriteRow:
		ldx  #Ship_BottomVars ; first ship and header
		stx  Ship_TempPtr
		ldx  $08,x ; g-tile RAM base location
		ldab #$10 ; scroll the ship tile graphics
@Loop:
		clc  
		rol  $40,x
		rol  $30,x
		rol  $20,x
		rol  $10,x
		rol  $00,x
	bcs  MoveShipTiles ; if the tip of the ship reaches the carry, move tilemap
		inx  
		decb 
	bne  @Loop
CommonReturn4:
	rts  

MoveShipTiles:
		ldx  Ship_TempPtr

Sub_ResetAndDrawShips:
		ldx  $08,x ; g-tile RAM
	jsr  Sub_ZeroFill_16 ; clear the front tile's graphics
		ldx  Ship_TempPtr
		ldx  $06,x ; ship sprite ROM location
		stx  PopSlide_SourcePtr
		ldx  Ship_TempPtr
		ldx  $08,x
		ldaa #$10 ; skip the first tile that was cleared
	jsr  Sub_AddByteToPointer
		ldab #$40
	jsr  Sub_Popslide ; copy ship into RAM


		ldx  #Ship_BottomVars ; bottom ship
		stx  Ship_TempPtr
	bsr  MoveTilesAndDrawShips

		ldx  #Ship_MiddleVars ; middle ship
		ldaa $00,x
		adda $01,x
	beq  @SkipShip ; skip drawing it if it's at 0000 (initial state)
		stx  Ship_TempPtr
	bsr  MoveTilesAndDrawShips

@SkipShip:
		ldx  #Ship_TopVars ; top ship
		tst  $01,x
	beq  InitializeOtherShips
		stx  Ship_TempPtr
	bra  MoveTilesAndDrawShips



InitializeOtherShips:
		ldx  #Ship_BottomVars
		ldaa $04,x
		cmpa #$08
	bne  @TopShip
		ldx  #$00DF ; initialize middle ship
		stx  Ship_MiddleVars
		stx  Ship_MiddleResetPos
		ldx  #Ship_MiddleVars
	bra  @FinishInit

@TopShip:
		cmpa #$0C
	bne  CommonReturn4
		ldx  #$00BF ; initialize top ship
		stx  Ship_TopVars
		stx  Ship_TopResetPos
		ldx  #Ship_TopVars
@FinishInit:
		ldaa #$48
		staa $05,x
	bra  MoveTilesAndDrawShips@DrawOnly



MoveTilesAndDrawShips:
		ldx  $00,x ; get ship address
		dex  
		stx  Ship_TempNewPos
		ldx  Ship_TempPtr
		ldaa Ship_TempNewPos
		staa $00,x
		ldaa Ship_TempNewPosLow
		staa $01,x ; decrements the currently selected ship position

@FirstDraw:
		ldx  Ship_TempPtr

@DrawOnly:
		ldaa $05,x ; starting tile index for ship sprite
		ldab $04,x
		inc  $04,x
		cmpb #$1F
	bgt  ShipOffscreenLeft
		decb 
	blt  @Draw1
	beq  @Draw2
		decb 
	beq  @Draw3
		decb 
	beq  @Draw4
		inca ; draw all 5 ship tiles
@Draw4:
		inca 
@Draw3:
		inca 
@Draw2:
		inca
@Draw1:

		ldab $05,x ; ship offscreen right
		ldx  $00,x
@DrawLoopRight:
		stab $00,x
		inx  
		incb 
		cba  ; draws forwards until the target tile is greater or equal to the reference tile
	bge  @DrawLoopRight
		ldaa #$54 ; empty tile
		staa $00,x
	rts  

ShipOffscreenLeft:
		subb #$1F
		cmpb #$05
	beq  @ResetShip ; is it fully offscreen already?
		aba        ; A is the reference tile, each increment means one less tile drawn
		ldab $05,x ; current tile
		addb #$04  ; go to the last one, because the ship is drawn backwards in this path
		pshb 
		ldx  $00,x ; now pointing to gtilemap
		ldab #$54  ; clear last ship position
		stab $05,x
		pulb 
@DrawLoopLeft:
		stab $04,x
		dex  
		decb 
		cba  ; A-B, B being LE to A will exit this loop
	ble  @DrawLoopLeft
	rts  

; when a ship gets hit, its duration is set it so that this routine thinks
; it's offscreen, the duration will cut the ship draw size every tile
; but since the gtilemap address is where it was, it will do it where the
; ship have been struck, it also doubles as resetting the ship faster

; reset ship
@ResetShip:
		ldx  $00,x
		ldaa #$54 ; place empty tile on last ship position
		staa $05,x

		ldx  Ship_TempPtr
		ldaa #$48 ; first ship tile
		staa $05,x
		clr  $04,x ; ship duration on-screen (X pos equivalent)
		ldaa $02,x ; ship address position reload high
		staa $00,x ; ship current address position high
		ldaa $03,x ; ship address position reload low
		staa $01,x ; ship current address position low
	bra  MoveTilesAndDrawShips@FirstDraw

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Sub_ZeroFill_16:
		clra 
		ldab #$10

Sub_FillLoop:
		staa $00,x
		inx  
		decb 
	bne  Sub_FillLoop
	rts  


;    //////////////////////////////////////////////////////
;   ///                  other data                    ///
;  //////////////////////////////////////////////////////
String_RocketPatrolHUD:
.db $DF, $83 ; prints 32 semigraphics cells, only two bottom blocks set, green chroma
.db $C1, $83
.db $DF, $8F ; prints 32 semigraphics cells, all squares set, green chroma
.db $C1, $8F
.db $DF, $8C ; prints 32 semigraphics cells, only top two blocks set, green chroma
.db $C1, $8C
.db $DF, $80 ; prints 32 semigraphics cells, all blocks black, green chroma
.db $C1, $80
.db $FF

String_COMPUTER:
.db "COMPUTER"

String_FIRE:
.db "FIRE" 

; scrolling pattern of the stars in the background
; notice that one of the gtile rows have no star, while the last has two
GFX_StarsData:
.dw $0045
.dw $0074
.dw $0089
.dw $00D9
.dw $00E7
.dw $00F2

GFX_ShipData:
.db $01, $00 ; current address of bottom ship
.db $00, $FF ; reload address of bottom ship
.db $00      ; X duration number of bottom ship
.db $48      ; starting tile number for the ship tiles (H in HIJKL)
; ship header data
.dw GFX_ShipSprite
.dw $0280 ; starting location in g-tile RAM for the ship to be copied into

GFX_ShipSprite:
.db %00000000
.db %00000000
.db %00000000
.db %00000000
.db %00000000
.db %00000000
.db %00000000
.db %00000011
.db %00001111
.db %11111111
.db %00001111
.db %00000111
.db %00000000
.db %00000000
.db %00000000
.db %00000000

.db %11111111
.db %11000000
.db %00000000
.db %00000001
.db %00000011
.db %00000111
.db %00111111
.db %11111111
.db %11111111
.db %11111111
.db %11111111
.db %11111111
.db %00111111
.db %00000001
.db %11000000
.db %11111111

.db %11111111
.db %00111111
.db %01111111
.db %11111110
.db %11111011
.db %11111110
.db %11111011
.db %11111111
.db %11111111
.db %11111111
.db %11111111
.db %11111111
.db %11111111
.db %11111110
.db %00111011
.db %11111111

.db %11110000
.db %11000000
.db %11000000
.db %10000000
.db %01000000
.db %10000000
.db %01000000
.db %11000111
.db %10001111
.db %11111111
.db %11111000
.db %11001000
.db %11000011
.db %10000000
.db %10000000
.db %11110000

.ORGA $47F6
.dw $FF00 ; unused bytes
.dw IRQ
.dw NMI
.dw SWI_J
.dw START
