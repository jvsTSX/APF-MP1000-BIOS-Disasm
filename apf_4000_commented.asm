
; some notes about this machine

; 0000~03FF - RAM (1KB)
;   0000~01FF user RAM
;   0200~03FF video display RAM
; 
; 2000~2003 - PIA ports and registers
; 
; 4000~47FF - BIOS ROM (2KB)
;
; 8000~9FFF - cartridge space (8KB)
;
; E000~FFFF - BIOS ROM mirror (2KB)

; unless said otherwise, regions in-between are filled with mirrors of the previous region
; PIA will appear again at 2004~2007 and so on until 4000

; for some reason beyond my understanding, the BIOS is treated as being in $4000 range
; so the mirror at the end of the memory are for the special exception vectors
; who designed this????

; there are more things that get added to the memory map when you equip the expansion to turn your MP1000
; into the imagination machine, but that has its own BIOS it seems so i'll not comment a lot about it here

; if you're wanting to develop your own mapper, just beware that it's around the $6000 range where
; the imagination machine memory things get mapped into, as well as extra RAM in between the cartridge
; and BIOS mirror ($A000~$DFFF)

; you can absol do that, but it will be an odyssey2 the voice situation where you can't use the expansion
; and your game simultaneously

; ---------------------

; this firmware will display a menu at first
; if it doesn't see a cartridge, or a valid cartridge, it starts the built-in game "rocket patrol"
; if it sees your game.... good question, i can only get my programs in currently by making the BIOS crash

; if it sees your game, it will carry out this sequence:
; 1. draw the rocket patrol menu BEFORE checking for your cartridge validity
; 2. check for the validity byte at $8000, it must be precisely $BB
; 3. take the bytes in $8001 and $8002 to point at a string that is printed over the rocket patrol title (terminated by $FF)
; 4. check the amount of games you have specified in $8003 (ASCII number 1~9)
;     - to proceed, the player must press a number that is less than specified, but not zero
; 5. check the amount of players you have specified in $8004 (ASCII number 0~9)
;     - if you specify 0 players, it will not prompt you and start the game already, or else it does the same as the game numbers
;     - if you have an actual number here, it will redraw the rocket patrol screen, but with "HOW MANY PLAYERS" replacing the title
; 6. then finally, it clears the screen and jumps to to your cartridge at $8005

; the interrupt hook is taken over by the BIOS, but you can abuse a jump hook to make it
; jump into your own handler for your game

; SWI and NMI will reset the machine, because they're both set to the same place as the reset vector ($4000)

; latency isn't a big worry because this only ever happens on VBlank, but i have no idea what the hook does
; and whatever it does, it does a lot of things... not good for a 800KHz CPU



; brought to you by MAME
; and another machine, one that looks like an eevee

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
; 0~6 general scratch stuff usually
; 1E5~1FF specific function variables

; 1C5~1C6: interrupt vector location, it will call here if the variable below is non-zero
; 1FC: interrupt hook, if 0, use the stuff for the built-in game

; wtf?

.BANK 0 SLOT 0
.ORGA $4000
NMI:
SWI:
START:
; reset and other unused vectors (NMI and SWI)
4000: 4f        clra 
4001: b7 01 fc  sta  $01FC
4004: b7 01 fd  sta  $01FD
4007: 8e 01 e4  lds  #$01E4
400a: 0f        sei  
400b: c6 35     ldb  #$35
400d: f7 20 03  stb  $2003
4010: 86 ff     lda  #$FF
4012: b7 20 02  sta  $2002
4015: 7f 20 03  clr  $2003
4018: b7 20 02  sta  $2002
401b: f7 20 03  stb  $2003
401e: c6 34     ldb  #$34
4020: f7 20 01  stb  $2001
4023: 86 ef     lda  #$EF
4025: b7 01 f7  sta  $01F7
4028: 7f 01 f4  clr  $01F4
402b: 7f 01 f6  clr  $01F6
402e: 86 1f     lda  #$1F
4030: b7 20 02  sta  $2002
4033: 0e        cli  
4034: 7e 40 53  jmp  SystemInitDone

Sub_DrawInitialScreen:
4037: bd 42 96  jsr  ClearScreen ; subroutine
403a: ce 43 0a  ldx  #GFX_APF_Logo
403d: ff 01 e6  stx  $01E6  ; source pointer
4040: ce 02 08  ldx  #$0208 ; VRAM (row 0, 1/4 col)
4043: 86 06     lda  #$06
4045: bd 40 cb  jsr  Sub_PrintSemigraphics
4048: ce 43 20  ldx  #String_RocketMenu
404b: df 06     stx  $06    ; source pointer
404d: ce 02 68  ldx  #$0268 ; VRAM (row 3, 1/4 col))
4050: 7e 41 44  jmp  Sub_PrintString

SystemInitDone:
4053: 8d e2     bsr  Sub_DrawInitialScreen
4055: b6 80 00  lda  $8000 ; first byte from cartridge
4058: 81 bb     cmpa #$BB  ; presence check, if not this byte, then assume no cartridge is inserted
405a: 26 46     bne  CartSignatureFail
405c: fe 80 01  ldx  $8001 ; second and third bytes from cartridge
405f: df 06     stx  $06
4061: ce 02 c0  ldx  #$02C0 ; some sort of splash string for your game
4064: df 04     stx  $04
4066: bd 41 46  jsr  Sub_PrintString@Loop
@KeysLoop:
4069: 8d 40     bsr  Sub_WaitForPlayerInput
406b: 81 30     cmpa #$30  ; 
406d: 27 fa     beq  @KeysLoop
406f: b1 80 03  cmpa $8003 ; how many games this cartridge has?
4072: 2e f5     bgt  @KeysLoop 
4074: 84 0f     anda #$0F ; de-asciifies it to just 01~09
4076: 97 00     sta  $00
4078: b6 80 04  lda  $8004 ; how many players? if this value is 0 on the cartridge, it skips the prompt
407b: 27 1f     beq  @SkipPlayersPrompt
407d: 8d b8     bsr  Sub_DrawInitialScreen
407f: ce 40 b9  ldx  #String_Players
4082: df 06     stx  $06
4084: ce 02 c0  ldx  #$02C0
4087: bd 41 44  jsr  Sub_PrintString
@KeysLoop2:
408a: 8d 1f     bsr  Sub_WaitForPlayerInput
408c: 81 30     cmpa #$30
408e: 2f fa     ble  @KeysLoop2
4090: b1 80 04  cmpa $8004
4093: 2e f5     bgt  @KeysLoop2
4095: 86 0f     lda  #$0F
4097: b4 01 f2  anda $01F2 ; de-asciifies it to just 01~09
409a: 97 01     sta  $01
@SkipPlayersPrompt:
409c: bd 42 96  jsr  ClearScreen
409f: 7e 80 05  jmp  $8005 ; cartridge!!!!!

; $8000: byte containing $BB
; $8001: string pointer high
; $8002: string pointer low
; $8003: amount of games in this cartridge
; $8004: amount of players (displays HOW MANY PLAYERS prompt if not set to 0)
; $8005: start of user program

; note: the amount constants are in ASCII numbers, so if you want a 0, you have to specify $30


CartSignatureFail:
40a2: 8d 07     bsr  Sub_WaitForPlayerInput ; no cartridge :(
40a4: 84 03     anda #$03
40a6: 97 00     sta  $00
40a8: 7e 43 80  jmp  InitRocketPatrol

Sub_WaitForPlayerInput:
@Wait:
40ab: bd 41 d9  jsr  Sub_GetButtonPlayer2
40ae: 25 05     bcs  @InputDetected
40b0: bd 41 be  jsr  Sub_GetButtonPlayer1
40b3: 24 f6     bcc  @Wait
@InputDetected:
40b5: b6 01 f2  lda  $01F2
JumpReturn:
40b8: 39        rts  


String_Players:
.db "HOW`MANY`PLAYERS?", $FF

Sub_PrintSemigraphics:
40cb: b7 01 ea  staa $01ea ; length of SG lines
40ce: ff 01 e8  stx  $01e8 ; destination pointer
40d1: 86 20     ldaa #$20
40d3: b0 01 ea  suba $01ea ; length of SG lines
40d6: b7 01 ed  staa $01ed ; line width - length
@loop:
40d9: fe 01 e6  ldx  $01E6 ; source pointer
40dc: a6 00     lda  $00,x
40de: 81 ff     cmpa #$FF
40e0: 27 d6     beq  JumpReturn ; terminator reached, exit... only happens outside of data frame context
40e2: b7 01 eb  sta  $01EB ; data frame length
40e5: 08        inx  
40e6: ff 01 e6  stx  $01E6 ; source pointer
40e9: f6 01 ea  ldb  $01EA ; length of SG lines
@loop2:
40ec: a6 00     lda  $00,x ; grab another at next position
40ee: 08        inx  
40ef: df 04     stx  $04
40f1: fe 01 e8  ldx  $01E8 ; destination pointer
40f4: a7 00     sta  $00,x
40f6: 08        inx  
40f7: ff 01 e8  stx  $01E8 ; destination pointer
40fa: de 04     ldx  $04
40fc: 5a        decb       ; using line length as loop count
40fd: 26 ed     bne  @loop2
40ff: b6 01 ed  lda  $01ED ; line width - length
4102: fe 01 e8  ldx  $01E8 ; destination pointer
4105: bd 41 1d  jsr  Sub_AddByteToPointer ; advance scanline
4108: ff 01 e8  stx  $01E8 ; destination pointer
410b: fe 01 e6  ldx  $01E6 ; source pointer
410e: f6 01 ea  ldb  $01EA ; length of SG lines
4111: 7a 01 eb  dec  $01EB ; data frame length
4114: 26 d6     bne  @loop2
4116: de 04     ldx  $04
4118: ff 01 e6  stx  $01E6 ; source pointer
411b: 20 bc     bra  @loop ; gets next frame


; called from above
Sub_AddByteToPointer:
411d: ff 01 ee  stx  $01EE
4120: bb 01 ef  adda $01EF
4123: b7 01 ef  sta  $01EF
4126: 24 03     bcc  @NoCarry
4128: 7c 01 ee  inc  $01EE
@NoCarry
412b: fe 01 ee  ldx  $01EE
412e: 39        rts  




Sub_SubtractBFromX:
412f: 36        psha 
4130: ff 01 ee  stx  $01EE
4133: b6 01 ef  lda  $01EF ; low byte of stored X
4136: 10        sba        ; a=a-b
4137: b7 01 ef  sta  $01EF
413a: 24 03     bcc  @NoCarry
413c: 7a 01 ee  dec  $01EE
@NoCarry:
413f: fe 01 ee  ldx  $01EE ; ah, it's some kind of down-counter, this decs the msbyte on underflow
4142: 32        pula 
4143: 39        rts  


; called from three places, one is a subroutine
Sub_PrintString:
4144: df 04     stx  $04   ; store destination pointer
@Loop:
4146: 8d 09     bsr  Sub_GetTextChar ; get character
4148: de 06     ldx  $06   ; source pointer
414a: a6 00     lda  $00,x
414c: 81 ff     cmpa #$FF  ; terminator is $FF
414e: 26 f6     bne  @Loop
4150: 39        rts  

Sub_GetTextChar:
4151: 8d 0d     bsr  @CheckTextChar ; called from above
4153: 2d 18     blt  @ControlChar ; this branch will only be taken if the current value is $80 and above
4155: de 04     ldx  $04   ; destination pointer
4157: 8a 40     ora  #$40  ; force text invert bit on %SICC CCCC
4159: a7 00     sta  $00,x
415b: 08        inx  
415c: df 04     stx  $04
415e: 20 f1     bra  Sub_GetTextChar ; increment VRAM dest and repeat

@CheckTextChar:
4160: de 06     ldx  $06    ; check for terminator byte
4162: a6 00     lda  $00,x  ; get source pointer
4164: 81 ff     cmpa #$FF   ; check if accumulator is positive or negative
4166: 27 03     beq  @CharIsTerminator  ; if it's the terminator, leave and don't increment the source
4168: 08        inx  
4169: df 06     stx  $06
@CharIsTerminator:
416b: 16        tab  
416c: 39        rts  ; that's 4 levels until here, oof


; control char for text sequences
@ControlChar:
416d: 81 ff     cmpa #$FF  ; if it's $FF, it's a terminator
416f: 27 1d     beq  @Done
4171: 84 1f     anda #$1F  ; isolate 5-bit parameter
4173: c4 60     andb #$60  ; isolate 2-bit command
4175: 54        lsrb
4176: 54        lsrb 
4177: 54        lsrb 
4178: 54        lsrb 
4179: 54        lsrb       ; B= ------xx
417a: 27 12     beq  @Done ; (00) do nothing (unused? for fool proofing purposes?)
417c: 5a        decb 
417d: 27 d2     beq  Sub_GetTextChar ; (01) go back to normal decode loop (unused?)
417f: 5a        decb 
4180: 27 0d     beq  @GetByteToPrint ; (10) print a parameter amount of the next byte in the text sequence
4182: c6 20     ldb  #$20  ; (11) print a parameter amount of spaces
@LoopStoreX:
4184: de 04     ldx  $04
@ReptLoop:
4186: e7 00     stb  $00,x
4188: 08        inx  
4189: 4a        deca 
418a: 26 fa     bne  @ReptLoop ; print it X times.. ah
418c: df 04     stx  $04 ; store back destination
@Done:
418e: 39        rts  

@GetByteToPrint:
418f: de 06     ldx  $06 ; source pointer
4191: e6 00     ldb  $00,x
4193: 08        inx  
4194: df 06     stx  $06
4196: 20 ec     bra  @LoopStoreX

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; data?
;4198: 31        ins  
;4199: 30        tsx  
;419a: 34        des  
;419b: 37        pshb 
;419c: 53        comb 
;419d: 45        illegal
;419e: 4e        illegal
;419f: 57        asrb 
;41a0: 33        pulb 
;41a1: 3f        swi  
;41a2: 36        psha 
;41a3: 39        rts  
;41a4: 32        pula 
;41a5: 21 35     brn  $41DC
;41a7: 38        illegal


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
41a8: 86 04     lda  #$04
41aa: b7 01 eb  sta  $01EB ; loop counter
41ad: ff 01 ec  stx  $01EC ; X pointer for current player
41b0: a6 01     lda  $01,x ; 01F4 or 01F6 ... previous button press? these are cleared on start
41b2: 26 04     bne  @ThereWasKey
41b4: 86 f7     lda  #$F7  ;11110111 row select byte
41b6: a7 00     sta  $00,x
@ThereWasKey:
41b8: a6 00     lda  $00,x
41ba: b7 01 f7  sta  $01F7
41bd: 39        rts  

Sub_GetButtonPlayer1:
41be: ce 01 f3  ldx  #$01F3 ; check player 1
41c1: 8d e5     bsr  Sub_PrepareButtonLoop
@Loop:
41c3: 8d 5b     bsr  SubFn_SetKeyMatrixRowAndAdjustPointer
41c5: b6 20 00  lda  $2000  ; read the row
41c8: 44        lsra        ; player 1 bits are at the MSB, so shift-right them to low nybble
41c9: 44        lsra 
41ca: 44        lsra 
41cb: 44        lsra 
41cc: 81 0f     cmpa #$0F
41ce: 26 27     bne  SubFn_ButtonInRowDetected
41d0: 8d 7a     bsr  SubFn_PrepareNextRow
41d2: 7a 01 eb  dec  $01EB ; iterate all 4 rows
41d5: 26 ec     bne  @Loop
41d7: 20 17     bra  SubFn_NoButtonsDetected

Sub_GetButtonPlayer2:
41d9: ce 01 f5  ldx  #$01F5 ; check player 2
41dc: 8d ca     bsr  Sub_PrepareButtonLoop
@Loop:
41de: 8d 40     bsr  SubFn_SetKeyMatrixRowAndAdjustPointer
41e0: b6 20 00  lda  $2000
41e3: 84 0f     anda #$0F
41e5: 81 0f     cmpa #$0F
41e7: 26 0e     bne  SubFn_ButtonInRowDetected
41e9: 8d 61     bsr  SubFn_PrepareNextRow
41eb: 7a 01 eb  dec  $01EB ; iterate all 4 rows
41ee: 26 ee     bne  @Loop

SubFn_NoButtonsDetected:
41f0: fe 01 ec  ldx  $01EC ; X pointer for current player
41f3: 6f 01     clr  $01,x
41f5: 0c        clc  
41f6: 39        rts  

SubFn_ButtonInRowDetected:
41f7: c6 03     ldb  #$03 ; limit 3 bits
41f9: 8d 60     bsr  Sub_CountSetBits
41fb: fb 01 f1  addb $01F1
41fe: f7 01 f1  stb  $01F1
4201: fe 01 f0  ldx  $01F0 ; get key code
4204: e6 00     ldb  $00,x
4206: fe 01 ec  ldx  $01EC ; X pointer for current player
4209: e1 01     cmpb $01,x
420b: 27 0c     beq  @SameKey ; equal to last frame's press?
420d: b6 01 f7  lda  $01F7
4210: a7 00     sta  $00,x
4212: e7 01     stb  $01,x
@ReportNewPress:
4214: f7 01 f2  stb  $01F2 ; seems to be where the controller code is stored at
4217: 0d        sec  
4218: 39        rts  
@SameKey:
4219: c1 45     cmpb #$45 ; letter E for East, letters have a higher code than the numbers and ?! symbols
421b: 2c f7     bge  @ReportNewPress ; so, if it's the directions, and they match what they were the last frame, report as new button pressed through the carry flag
421d: 0c        clc  ; or else it's the other keys, and report them as not pressed if detected the same one again
421e: 39        rts  
421f: 01        nop  


SubFn_SetKeyMatrixRowAndAdjustPointer:
4220: 86 e0     lda  #$E0
4222: b4 20 02  anda $2002 ; control row selector and VDG control
4225: b7 01 f0  sta  $01F0 ; row selector with all lines selected (active low)
4228: 86 1f     lda  #$1F
422a: b4 01 f7  anda $01F7
422d: ba 01 f0  ora  $01F0
4230: b7 20 02  sta  $2002 ; select row

4233: c6 04     ldb  #$04 ; limit 4 bits
4235: 8d 24     bsr  Sub_CountSetBits
4237: ce 41 98  ldx  #Data_ControllerKeyCodes
423a: ff 01 f0  stx  $01F0 ; sets 01F1
423d: 0c        clc  
423e: 58        aslb 
423f: 58        aslb 
4240: fb 01 f1  addb $01F1
4243: f7 01 f1  stb  $01F1
4246: 24 03     bcc  @NoCarry
4248: 7c 01 f0  inc  $01F0 
@NoCarry:
424b: 39        rts  

SubFn_PrepareNextRow:
424c: f6 01 f7  ldb  $01F7
424f: 0d        sec  
4250: 56        rorb 
4251: 24 04     bcc  @LastShift
@Exit:
4253: f7 01 f7  stb  $01F7
4256: 39        rts  
@LastShift:
4257: c6 f7     ldb  #$F7
4259: 20 f8     bra  @Exit

Sub_CountSetBits:
425b: 7f 01 e5  clr  $01E5
425e: 0d        sec  
@Loop:
425f: 44        lsra 
4260: 24 06     bcc  @ZeroFound
4262: 7c 01 e5  inc  $01E5
4265: 5a        decb 
4266: 26 f7     bne  @Loop
@ZeroFound:
4268: f6 01 e5  ldb  $01E5
426b: 39        rts  

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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; aaaaaaaaaaaaaaaaaaaaa

; is this segment never called?
426C: c6 05     ldb  #$05
426e: f7 01 ec  stb  $01EC
4271: 8d 18     bsr  Sub_ToggleSoundLatch
4273: 5a        decb 
4274: 26 fd     bne  $4273
4276: 8d 13     bsr  Sub_ToggleSoundLatch
4278: 7c 01 ec  inc  $01EC
427b: f6 01 ec  ldb  $01EC
427e: 5a        decb 
427f: 26 fd     bne  $427E
4281: f6 01 ec  ldb  $01EC
4284: 8d 05     bsr  Sub_ToggleSoundLatch
4286: c1 5f     cmpb #$5F
4288: 26 e9     bne  $4273
428a: 39        rts  


; suspiciously sound generation shaped
; it is sound!
Sub_ToggleSoundLatch:
428b: 0f        sei  
428c: b6 20 03  lda  $2003 ; control reg B (PIA)
428f: 88 08     eora #$08  ; toggle CB2 (audio latch)
4291: b7 20 03  sta  $2003
4294: 0e        cli  
4295: 39        rts  


ClearScreen:
4296: 86 80     lda  #$80
4298: ce 04 00  ldx  #$0400 ; clears vee!ram
429b: 09        dex  
429c: a7 00     sta  $00,x
429e: 8c 02 00  cmpx #$0200
42a1: 26 f8     bne  $429B
42a3: 39        rts  



; IRQ vector here ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IRQ:
42a4: b6 20 02  lda  $2002 ; ???? this is normally set to write-only no?
42a7: 7d 01 fc  tst  $01FC ; set this to anything non-zero
42aa: 27 05     beq  @SkipRedirect
42ac: fe 01 c5  ldx  $01C5 ; and set your game's interrupt handler pointer here
42af: ad 00     jsr  $00,x ; return by discarding the return address
@SkipRedirect:
42b1: 7c 01 f8  inc  $01F8
42b4: 28 03     bvc  @NoResetCounter
42b6: 7f 01 f8  clr  $01F8
@NoResetCounter:
42b9: 7c 01 fb  inc  $01FB
42bc: 86 3b     lda  #$3B
42be: b1 01 fb  cmpa $01FB
42c1: 2e 1b     bgt  @Exit
42c3: 7d 01 fd  tst  $01FD
42c6: 27 05     beq  @SkipRedirect2
42c8: fe 01 c7  ldx  $01C7 ; huh?
42cb: ad 00     jsr  $00,x
@SkipRedirect2:
42cd: 7f 01 fb  clr  $01FB
42d0: 0c        clc  
42d1: b6 01 f9  lda  $01F9
42d4: 81 59     cmpa #$59
42d6: 27 07     beq  @OneSecond
42d8: 8b 01     adda #$01
42da: 19        daa  
42db: b7 01 f9  sta  $01F9
@Exit:
42de: 3b        rti  

@OneSecond:
42df: 7f 01 f9  clr  $01F9
42e2: b6 01 fa  lda  $01FA
42e5: 81 99     cmpa #$99
42e7: 27 1d     beq  @HundredSeconds
42e9: 8b 01     adda #$01
42eb: 19        daa  
42ec: b7 01 fa  sta  $01FA
42ef: 3b        rti  


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unrelated subroutine

Sub_Popslide:
42f0: 36        psha 
42f1: 0f        sei  
42f2: bf 01 e8  sts  $01E8
42f5: be 01 e6  lds  $01E6
42f8: 34        des  
42f9: 32        pula 
42fa: a7 00     sta  $00,x
42fc: 08        inx  
42fd: 5a        decb 
42fe: 26 f9     bne  $42F9
4300: be 01 e8  lds  $01E8
4303: 0e        cli  
4304: 32        pula 
4305: 39        rts  

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

@HundredSeconds:
4306: 7f 01 fa  clr  $01FA
4309: 3b        rti  ; end of IRQ ;;;;;;;;;;;;;;


GFX_APF_Logo:
.DB $01, $EC, $EA, $EE, $EA, $EE, $E8
.DB $01, $9E, $9A, $9E, $98, $9E, $98
.DB $01, $DC, $D8, $D8, $80, $D8, $80, $FF

String_RocketMenu:
.db "TV MICRO-COMPUTER",      $CF, $80
.db "COPYRIGHT APF1978",      $DB, $80, $CC, $80, E8
.db "ROCKET PATROL",          $F4, $F7
.db "1. TWO PLAYER",          $D3, $8F
.db "2. PLAYER AND COMPUTER", $CA, $8F, $FF


; 33 subroutines, oof
; someone at APF really liked subroutines

; shotgun disasm shot me!
; manually solve 4380
;437f: ff b6 20  stx  $B620
;4382: 02        illegal

InitRocketPatrol:
4380: b6 20 02  ldaa $2002 ; done
4383: 84 3f     anda #$3F
4385: 8a c0     ora  #$C0
4387: b7 20 02  sta  $2002
438a: b6 20 01  lda  $2001 ; veeeeeeeeeeeeeveeevev
438d: 84 c7     anda #$C7
438f: 8a 38     ora  #$38
4391: b7 20 01  sta  $2001 ; aaaaaaaaaa
4394: 4f        clra 
4395: bd 42 98  jsr  $4298
4398: ce 47 83  ldx  #$4783
439b: df 06     stx  $06
439d: ce 02 00  ldx  #$0200
43a0: bd 41 44  jsr  Sub_PrintString
43a3: ce 44 aa  ldx  #$44AA
43a6: 96 00     lda  $00
43a8: 4a        deca 
43a9: 27 0d     beq  $43B8
43ab: ce 47 94  ldx  #$4794 ; computer fire string
43ae: c6 08     ldb  #$08
43b0: 86 31     lda  #$31
43b2: bd 44 7f  jsr  $447F ; wait is this calling the popslide??? really???
43b5: ce 45 45  ldx  #$4545
43b8: ff 01 90  stx  $0190
43bb: ce 00 00  ldx  #$0000
43be: 86 54     lda  #$54
43c0: a7 00     sta  $00,x
43c2: 08        inx  
43c3: 8c 01 80  cmpx #$0180
43c6: 26 f8     bne  $43C0
43c8: 4f        clra 
43c9: c6 1e     ldb  #$1E
43cb: ce 01 42  ldx  #$0142
43ce: bd 47 7c  jsr  Sub_FillLoop
43d1: ce 45 51  ldx  #$4551
43d4: ff 01 c5  stx  $01C5 ; initializes interrupt call 1
43d7: ce 01 2f  ldx  #$012F
43da: 86 02     lda  #$02
43dc: b7 01 92  sta  $0192
43df: ff 01 5d  stx  $015D
43e2: 8d 67     bsr  $444B
43e4: 86 c0     lda  #$C0
43e6: ce 03 50  ldx  #$0350
43e9: a7 07     sta  $07,x
43eb: ce 47 a0  ldx  #$47A0
43ee: ff 01 e6  stx  $01E6
43f1: ce 01 81  ldx  #$0181
43f4: c6 0c     ldb  #$0C
43f6: bd 42 f0  jsr  Sub_Popslide
43f9: bd 46 52  jsr  $4652
43fc: ce 47 ac  ldx  #$47AC
43ff: ff 01 e6  stx  $01E6
4402: ce 01 42  ldx  #$0142
4405: c6 0a     ldb  #$0A
4407: bd 42 f0  jsr  Sub_Popslide
440a: 7c 01 fc  inc  $01FC
440d: 7f 01 fa  clr  $01FA
4410: 7f 01 f9  clr  $01F9
4413: 7f 01 8e  clr  $018E
4416: 7f 01 8f  clr  $018F
4419: ce 01 42  ldx  #$0142
441c: ff 01 40  stx  $0140
441f: bd 46 9b  jsr  $469B
4422: b6 01 fa  lda  $01FA
4425: 81 02     cmpa #$02
4427: 2d 0a     blt  $4433
4429: 81 03     cmpa #$03
442b: 2e 36     bgt  $4463 ; lock check?
442d: ce 44 bc  ldx  #$44BC
4430: ff 01 90  stx  $0190
4433: f6 01 5f  ldb  $015F
4436: 27 0a     beq  $4442
4438: bd 42 8b  jsr  Sub_ToggleSoundLatch
443b: c6 df     ldb  #$DF
443d: 5a        decb 
443e: 26 fd     bne  $443D
4440: 20 f1     bra  $4433
4442: 8d 07     bsr  $444B
4444: fe 01 90  ldx  $0190
4447: ad 00     jsr  $00,x
4449: 20 d7     bra  $4422



444b: ce 07 70  ldx  #$0770
444e: bd 47 79  jsr  Sub_ZeroFill_16
4451: 86 18     lda  #$18
4453: b7 07 7c  sta  $077C
4456: 86 7e     lda  #$7E
4458: b7 07 7d  sta  $077D
445b: fe 01 5d  ldx  $015D
445e: 86 57     lda  #$57
4460: a7 00     sta  $00,x
4462: 39        rts  


4463: 7f 01 fa  clr  $01FA
4466: 86 07     lda  #$07
4468: b1 01 fa  cmpa $01FA
446b: 26 f9     bne  $4466
446d: 7f 01 fc  clr  $01FC
4470: b6 20 02  lda  $2002
4473: 84 7f     anda #$7F
4475: b7 20 02  sta  $2002
4478: 86 80     lda  #$80
447a: bd 42 98  jsr  $4298
447d: 20 fe     bra  $447D ; lock loop (main loop?)


447f: b7 01 e9  sta  $01E9
4482: 86 02     lda  #$02
4484: b7 01 e8  sta  $01E8
4487: ff 01 e6  stx  $01E6
448a: fe 01 e8  ldx  $01E8
448d: 7e 42 f0  jmp  Sub_Popslide



4490: b7 01 e8  sta  $01E8
4493: 44        lsra 
4494: 44        lsra 
4495: 44        lsra 
4496: 44        lsra 
4497: 27 0c     beq  $44A5
4499: 1b        aba  
449a: a7 00     sta  $00,x
449c: b6 01 e8  lda  $01E8
449f: 84 0f     anda #$0F
44a1: 1b        aba  
44a2: a7 01     sta  $01,x
44a4: 39        rts  
44a5: 86 60     lda  #$60
44a7: 20 f1     bra  $449A
44a9: 39        rts  


44aa: bd 41 d9  jsr  $41D9
44ad: 86 8f     lda  #$8F
44af: c6 cf     ldb  #$CF
44b1: 8d 3c     bsr  $44EF
44b3: c6 3d     ldb  #$3D
44b5: ce 01 8e  ldx  #$018E
44b8: 25 3d     bcs  $44F7
44ba: 20 10     bra  $44CC
44bc: bd 41 be  jsr  $41BE
44bf: 86 cf     lda  #$CF
44c1: c6 8f     ldb  #$8F
44c3: 8d 2a     bsr  $44EF
44c5: c6 21     ldb  #$21
44c7: ce 01 8f  ldx  #$018F
44ca: 25 2b     bcs  $44F7
44cc: b6 01 5c  lda  $015C
44cf: 27 d8     beq  $44A9
44d1: bd 42 8b  jsr  Sub_ToggleSoundLatch
44d4: 86 70     lda  #$70
44d6: 4a        deca 
44d7: 26 fd     bne  $44D6
44d9: 7a 01 5c  dec  $015C
44dc: 26 f3     bne  $44D1
44de: a6 00     lda  $00,x
44e0: 8b 01     adda #$01
44e2: 19        daa  
44e3: a7 00     sta  $00,x
44e5: f7 01 93  stb  $0193
44e8: fe 01 92  ldx  $0192
44eb: c6 70     ldb  #$70
44ed: 20 a1     bra  $4490


44ef: ce 02 00  ldx  #$0200
44f2: a7 20     sta  $20,x
44f4: e7 3c     stb  $3C,x
44f6: 39        rts  


44f7: fe 01 5d  ldx  $015D
44fa: b6 01 f2  lda  $01F2
44fd: 81 45     cmpa #$45
44ff: 27 1f     beq  $4520
4501: 81 21     cmpa #$21
4503: 27 27     beq  $452C
4505: 81 57     cmpa #$57
4507: 26 a0     bne  $44A9
4509: 09        dex  
450a: 8c 01 25  cmpx #$0125
450d: 27 9a     beq  $44A9
450f: 86 54     lda  #$54
4511: a7 01     sta  $01,x
4513: ff 01 5d  stx  $015D
4516: 86 57     lda  #$57
4518: a7 00     sta  $00,x
451a: c6 50     ldb  #$50
451c: bd 42 6e  jsr  $426E
451f: 39        rts  


4520: 8c 01 3a  cmpx #$013A
4523: 27 fa     beq  $451F
4525: 86 54     lda  #$54
4527: a7 00     sta  $00,x
4529: 08        inx  
452a: 20 e7     bra  $4513
452c: 86 c5     lda  #$C5
452e: b7 01 5f  sta  $015F
4531: fe 01 5d  ldx  $015D
4534: ff 01 58  stx  $0158
4537: 86 57     lda  #$57
4539: a7 00     sta  $00,x
453b: ce 47 9c  ldx  #$479C
453e: 86 2c     lda  #$2C
4540: c6 04     ldb  #$04
4542: 7e 44 7f  jmp  $447F
4545: 86 06     lda  #$06
4547: b5 01 f8  bita $01F8
454a: 27 02     beq  $454E
454c: 8d de     bsr  $452C
454e: 7e 44 ad  jmp  $44AD

; one of the locals loaded into X from the IRQ vector
4551: b6 20 03  lda  $2003 ; interrupts configuration (CB1)
4554: 84 fc     anda #$FC
4556: 8a 03     ora  #$03
4558: b7 20 03  sta  $2003
455b: ce 45 66  ldx  #$4566
455e: ff 01 c5  stx  $01C5
4561: bd 46 27  jsr  $4627
4564: 20 3a     bra  $45A0
4566: ce 45 51  ldx  #$4551
4569: ff 01 c5  stx  $01C5
456c: b6 20 03  lda  $2003 ; same as above, with only LSB set
456f: 84 fc     anda #$FC
4571: 8a 01     ora  #$01
4573: b7 20 03  sta  $2003
4576: ce 00 64  ldx  #$0064
4579: 09        dex  
457a: 26 fd     bne  $4579
457c: b6 20 02  lda  $2002
457f: 84 7f     anda #$7F
4581: b7 20 02  sta  $2002
4584: ce 01 a0  ldx  #$01A0
4587: 09        dex  
4588: 26 fd     bne  $4587
458a: b6 20 02  lda  $2002
458d: 8a 80     ora  #$80
458f: b7 20 02  sta  $2002
4592: bd 46 7c  jsr  Sub_ScrollSpriteRow
4595: 86 01     lda  #$01
4597: b5 01 fa  bita $01FA
459a: 27 03     beq  $459F
459c: bd 46 7c  jsr  Sub_ScrollSpriteRow
459f: 39        rts  


45a0: b6 01 5f  lda  $015F
45a3: 27 fa     beq  $459F
45a5: 7a 01 5f  dec  $015F
45a8: 26 09     bne  $45B3
45aa: fe 01 58  ldx  $0158
45ad: c6 54     ldb  #$54
45af: e7 00     stb  $00,x
45b1: 20 6a     bra  $461D
45b3: ce 01 42  ldx  #$0142
45b6: 8d 22     bsr  $45DA
45b8: ce 01 4c  ldx  #$014C
45bb: 8d 1d     bsr  $45DA
45bd: ce 01 52  ldx  #$0152
45c0: 8d 18     bsr  $45DA
45c2: 84 03     anda #$03
45c4: 26 60     bne  $4626
45c6: ce 07 70  ldx  #$0770
45c9: a6 00     lda  $00,x
45cb: 26 1f     bne  $45EC
45cd: a6 02     lda  $02,x
45cf: a7 00     sta  $00,x
45d1: 6f 02     clr  $02,x
45d3: 08        inx  
45d4: 8c 07 7e  cmpx #$077E
45d7: 26 f4     bne  $45CD
45d9: 39        rts  


45da: ff 01 5a  stx  $015A
45dd: ee 00     ldx  $00,x
45df: 08        inx  
45e0: c6 04     ldb  #$04
45e2: bc 01 58  cmpx $0158
45e5: 27 25     beq  $460C
45e7: 08        inx  
45e8: 5a        decb 
45e9: 26 f7     bne  $45E2
45eb: 39        rts  


45ec: a6 00     lda  $00,x
45ee: a7 0e     sta  $0E,x
45f0: a6 01     lda  $01,x
45f2: a7 0f     sta  $0F,x
45f4: 6f 00     clr  $00,x
45f6: 6f 01     clr  $01,x
45f8: fe 01 58  ldx  $0158
45fb: 86 54     lda  #$54
45fd: a7 00     sta  $00,x
45ff: c6 20     ldb  #$20
4601: bd 41 2f  jsr  Sub_SubtractBFromX
4604: ff 01 58  stx  $0158
4607: 86 57     lda  #$57
4609: a7 00     sta  $00,x
460b: 39        rts  


460c: fe 01 5a  ldx  $015A
460f: c6 bf     ldb  #$BF
4611: f7 01 5c  stb  $015C
4614: c6 20     ldb  #$20
4616: e7 04     stb  $04,x
4618: 6f 05     clr  $05,x
461a: 7f 01 5f  clr  $015F
461d: ce 8f 8f  ldx  #$8F8F
4620: ff 02 2c  stx  $022C
4623: ff 02 2e  stx  $022E
4626: 39        rts  


4627: ce 03 50  ldx  #$0350
462a: 0c        clc  
462b: 66 07     ror  $07,x
462d: 25 01     bcs  $4630
462f: 39        rts  
4630: 86 c0     lda  #$C0
4632: a7 07     sta  $07,x
4634: 86 54     lda  #$54
4636: 8d 1c     bsr  $4654 ; it's.... calling a path that it's falling into after it completes????
4638: ce 01 81  ldx  #$0181
463b: c6 06     ldb  #$06
463d: a6 01     lda  $01,x
463f: 84 1f     anda #$1F
4641: 81 1f     cmpa #$1F
4643: 26 06     bne  $464B
4645: a6 01     lda  $01,x
4647: 84 e0     anda #$E0
4649: a7 01     sta  $01,x
464b: 6c 01     inc  $01,x
464d: 08        inx  
464e: 08        inx  
464f: 5a        decb 
4650: 26 eb     bne  $463D
4652: 86 55     lda  #$55
4654: c6 06     ldb  #$06
4656: ce 01 81  ldx  #$0181
4659: ff 01 c9  stx  $01C9
465c: b7 01 5a  sta  $015A
465f: ee 00     ldx  $00,x
4661: a6 00     lda  $00,x
4663: 81 55     cmpa #$55
4665: 27 04     beq  $466B
4667: 81 54     cmpa #$54
4669: 26 05     bne  $4670
466b: b6 01 5a  lda  $015A
466e: a7 00     sta  $00,x
4670: fe 01 c9  ldx  $01C9
4673: 08        inx  
4674: 08        inx  
4675: ff 01 c9  stx  $01C9
4678: 5a        decb 
4679: 26 e4     bne  $465F
467b: 39        rts  


Sub_ScrollSpriteRow:
467c: ce 01 42  ldx  #$0142
467f: ff 01 40  stx  $0140
4682: ee 08     ldx  $08,x
4684: c6 10     ldb  #$10
4686: 0c        clc  
4687: 69 40     rol  $40,x
4689: 69 30     rol  $30,x
468b: 69 20     rol  $20,x
468d: 69 10     rol  $10,x
468f: 69 00     rol  $00,x
4691: 25 05     bcs  $4698
4693: 08        inx  
4694: 5a        decb 
4695: 26 ef     bne  $4686
4697: 39        rts  


4698: fe 01 40  ldx  $0140 ; big fucking block
469b: ee 08     ldx  $08,x
469d: bd 47 79  jsr  Sub_ZeroFill_16
46a0: fe 01 40  ldx  $0140
46a3: ee 06     ldx  $06,x
46a5: ff 01 e6  stx  $01E6
46a8: fe 01 40  ldx  $0140
46ab: ee 08     ldx  $08,x
46ad: 86 10     lda  #$10
46af: bd 41 1d  jsr  Sub_AddByteToPointer
46b2: c6 40     ldb  #$40
46b4: bd 42 f0  jsr  Sub_Popslide
46b7: ce 01 42  ldx  #$0142
46ba: ff 01 40  stx  $0140
46bd: 8d 47     bsr  $4706 ; calling a path it falls into
46bf: ce 01 4c  ldx  #$014C
46c2: a6 00     lda  $00,x
46c4: ab 01     adda $01,x
46c6: 27 05     beq  $46CD
46c8: ff 01 40  stx  $0140
46cb: 8d 39     bsr  $4706 ; same as above
46cd: ce 01 52  ldx  #$0152
46d0: 6d 01     tst  $01,x
46d2: 27 05     beq  $46D9
46d4: ff 01 40  stx  $0140
46d7: 20 2d     bra  $4706
46d9: ce 01 42  ldx  #$0142
46dc: a6 04     lda  $04,x
46de: 81 08     cmpa #$08
46e0: 26 0e     bne  $46F0
46e2: ce 00 df  ldx  #$00DF
46e5: ff 01 4c  stx  $014C
46e8: ff 01 4e  stx  $014E
46eb: ce 01 4c  ldx  #$014C
46ee: 20 10     bra  $4700
46f0: 81 0c     cmpa #$0C
46f2: 26 a3     bne  $4697
46f4: ce 00 bf  ldx  #$00BF
46f7: ff 01 52  stx  $0152
46fa: ff 01 54  stx  $0154
46fd: ce 01 52  ldx  #$0152
4700: 86 48     lda  #$48
4702: a7 05     sta  $05,x
4704: 20 16     bra  $471C
4706: ee 00     ldx  $00,x
4708: 09        dex  
4709: ff 01 5a  stx  $015A
470c: fe 01 40  ldx  $0140
470f: b6 01 5a  lda  $015A
4712: a7 00     sta  $00,x
4714: b6 01 5b  lda  $015B
4717: a7 01     sta  $01,x
4719: fe 01 40  ldx  $0140
471c: a6 05     lda  $05,x
471e: e6 04     ldb  $04,x
4720: 6c 04     inc  $04,x
4722: c1 1f     cmpb #$1F
4724: 2e 1f     bgt  $4745
4726: 5a        decb 
4727: 2d 0c     blt  $4735
4729: 27 09     beq  $4734
472b: 5a        decb 
472c: 27 05     beq  $4733
472e: 5a        decb 
472f: 27 01     beq  $4732
4731: 4c        inca 
4732: 4c        inca 
4733: 4c        inca 
4734: 4c        inca 
4735: e6 05     ldb  $05,x
4737: ee 00     ldx  $00,x
4739: e7 00     stb  $00,x
473b: 08        inx  
473c: 5c        incb 
473d: 11        cba  
473e: 2c f9     bge  $4739
4740: 86 54     lda  #$54
4742: a7 00     sta  $00,x
4744: 39        rts  

4745: c0 1f     subb #$1F
4747: c1 05     cmpb #$05
4749: 27 15     beq  $4760
474b: 1b        aba  
474c: e6 05     ldb  $05,x
474e: cb 04     addb #$04
4750: 37        pshb 
4751: ee 00     ldx  $00,x
4753: c6 54     ldb  #$54
4755: e7 05     stb  $05,x
4757: 33        pulb 
4758: e7 04     stb  $04,x
475a: 09        dex  
475b: 5a        decb 
475c: 11        cba  
475d: 2f f9     ble  $4758
475f: 39        rts  

4760: ee 00     ldx  $00,x
4762: 86 54     lda  #$54
4764: a7 05     sta  $05,x
4766: fe 01 40  ldx  $0140
4769: 86 48     lda  #$48
476b: a7 05     sta  $05,x
476d: 6f 04     clr  $04,x
476f: a6 02     lda  $02,x
4771: a7 00     sta  $00,x
4773: a6 03     lda  $03,x
4775: a7 01     sta  $01,x
4777: 20 a0     bra  $4719


Sub_ZeroFill_16: ; someone at APF really likes subroutines
4779: 4f        clra 
477a: c6 10     ldb  #$10

Sub_FillLoop:
477c: a7 00     sta  $00,x
477e: 08        inx  
477f: 5a        decb 
4780: 26 fa     bne  $477C
4782: 39        rts  


; data segment
4783: df 83     stx  $83
4785: c1 83     cmpb #$83
4787: df 8f     stx  $8F
4789: c1 8f     cmpb #$8F
478b: df 8c     stx  $8C
478d: c1 8c     cmpb #$8C
478f: df 80     stx  $80
4791: c1 80     cmpb #$80
;4793: ff 43 4f  stx  $434F
;4796: 4d        tsta 
;4797: 50        negb 
;4798: 55        illegal
;4799: 54        lsrb 
;479a: 45        illegal
;479b: 52        illegal
;479c: 46        rora 
;479d: 49        rola 
;479e: 52        illegal
;479f: 45        illegal
;47a0: 00        illegal
4793: ff        db $ff
4794: "COMPUTERFIRE", 0
47a1: 45        illegal
47a2: 00        illegal
47a3: 74 00 89  lsr  $0089
47a6: 00        illegal
47a7: d9 00     adcb $00
47a9: e7 00     stb  $00,x
47ab: f2 01 00  sbcb $0100
47ae: 00        illegal
47af: ff 00 48  stx  $0048
47b2: 47        asra 
47b3: b6 02 80  lda  $0280

; 47B6

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
.dw $FF00
.dw IRQ
.dw NMI
.dw SWI
.dw START