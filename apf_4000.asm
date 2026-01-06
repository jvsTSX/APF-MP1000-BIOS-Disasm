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
4034: 7e 40 53  jmp  $4053
4037: bd 42 96  jsr  $4296
403a: ce 43 0a  ldx  #$430A
403d: ff 01 e6  stx  $01E6
4040: ce 02 08  ldx  #$0208
4043: 86 06     lda  #$06
4045: bd 40 cb  jsr  $40CB
4048: ce 43 20  ldx  #$4320
404b: df 06     stx  $06
404d: ce 02 68  ldx  #$0268
4050: 7e 41 44  jmp  $4144
4053: 8d e2     bsr  $4037
4055: b6 80 00  lda  $8000
4058: 81 bb     cmpa #$BB
405a: 26 46     bne  $40A2
405c: fe 80 01  ldx  $8001
405f: df 06     stx  $06
4061: ce 02 c0  ldx  #$02C0
4064: df 04     stx  $04
4066: bd 41 46  jsr  $4146
4069: 8d 40     bsr  $40AB
406b: 81 30     cmpa #$30
406d: 27 fa     beq  $4069
406f: b1 80 03  cmpa $8003
4072: 2e f5     bgt  $4069
4074: 84 0f     anda #$0F
4076: 97 00     sta  $00
4078: b6 80 04  lda  $8004
407b: 27 1f     beq  $409C
407d: 8d b8     bsr  $4037
407f: ce 40 b9  ldx  #$40B9
4082: df 06     stx  $06
4084: ce 02 c0  ldx  #$02C0
4087: bd 41 44  jsr  $4144
408a: 8d 1f     bsr  $40AB
408c: 81 30     cmpa #$30
408e: 2f fa     ble  $408A
4090: b1 80 04  cmpa $8004
4093: 2e f5     bgt  $408A
4095: 86 0f     lda  #$0F
4097: b4 01 f2  anda $01F2
409a: 97 01     sta  $01
409c: bd 42 96  jsr  $4296
409f: 7e 80 05  jmp  $8005
40a2: 8d 07     bsr  $40AB
40a4: 84 03     anda #$03
40a6: 97 00     sta  $00
40a8: 7e 43 80  jmp  $4380
40ab: bd 41 d9  jsr  $41D9
40ae: 25 05     bcs  $40B5
40b0: bd 41 be  jsr  $41BE
40b3: 24 f6     bcc  $40AB
40b5: b6 01 f2  lda  $01F2
40b8: 39        rts  
40b9: 48        asla 
40ba: 4f        clra 
40bb: 57        asrb 
40bc: 60 4d     neg  $4D,x
40be: 41        illegal
40bf: 4e        illegal
40c0: 59        rolb 
40c1: 60 50     neg  $50,x
40c3: 4c        inca 
40c4: 41        illegal
40c5: 59        rolb 
40c6: 45        illegal
40c7: 52        illegal
40c8: 53        comb 
40c9: 3f        swi  
40ca: ff b7 01  stx  $B701
40cd: ea ff     orb  $FF,x
40cf: 01        nop  
40d0: e8 86     eorb $86,x
40d2: 20 b0     bra  $4084
40d4: 01        nop  
40d5: ea b7     orb  $B7,x
40d7: 01        nop  
40d8: ed        illegal
40d9: fe 01 e6  ldx  $01E6
40dc: a6 00     lda  $00,x
40de: 81 ff     cmpa #$FF
40e0: 27 d6     beq  $40B8
40e2: b7 01 eb  sta  $01EB
40e5: 08        inx  
40e6: ff 01 e6  stx  $01E6
40e9: f6 01 ea  ldb  $01EA
40ec: a6 00     lda  $00,x
40ee: 08        inx  
40ef: df 04     stx  $04
40f1: fe 01 e8  ldx  $01E8
40f4: a7 00     sta  $00,x
40f6: 08        inx  
40f7: ff 01 e8  stx  $01E8
40fa: de 04     ldx  $04
40fc: 5a        decb 
40fd: 26 ed     bne  $40EC
40ff: b6 01 ed  lda  $01ED
4102: fe 01 e8  ldx  $01E8
4105: bd 41 1d  jsr  $411D
4108: ff 01 e8  stx  $01E8
410b: fe 01 e6  ldx  $01E6
410e: f6 01 ea  ldb  $01EA
4111: 7a 01 eb  dec  $01EB
4114: 26 d6     bne  $40EC
4116: de 04     ldx  $04
4118: ff 01 e6  stx  $01E6
411b: 20 bc     bra  $40D9
411d: ff 01 ee  stx  $01EE
4120: bb 01 ef  adda $01EF
4123: b7 01 ef  sta  $01EF
4126: 24 03     bcc  $412B
4128: 7c 01 ee  inc  $01EE
412b: fe 01 ee  ldx  $01EE
412e: 39        rts  
412f: 36        psha 
4130: ff 01 ee  stx  $01EE
4133: b6 01 ef  lda  $01EF
4136: 10        sba  
4137: b7 01 ef  sta  $01EF
413a: 24 03     bcc  $413F
413c: 7a 01 ee  dec  $01EE
413f: fe 01 ee  ldx  $01EE
4142: 32        pula 
4143: 39        rts  
4144: df 04     stx  $04
4146: 8d 09     bsr  $4151
4148: de 06     ldx  $06
414a: a6 00     lda  $00,x
414c: 81 ff     cmpa #$FF
414e: 26 f6     bne  $4146
4150: 39        rts  
4151: 8d 0d     bsr  $4160
4153: 2d 18     blt  $416D
4155: de 04     ldx  $04
4157: 8a 40     ora  #$40
4159: a7 00     sta  $00,x
415b: 08        inx  
415c: df 04     stx  $04
415e: 20 f1     bra  $4151
4160: de 06     ldx  $06
4162: a6 00     lda  $00,x
4164: 81 ff     cmpa #$FF
4166: 27 03     beq  $416B
4168: 08        inx  
4169: df 06     stx  $06
416b: 16        tab  
416c: 39        rts  
416d: 81 ff     cmpa #$FF
416f: 27 1d     beq  $418E
4171: 84 1f     anda #$1F
4173: c4 60     andb #$60
4175: 54        lsrb 
4176: 54        lsrb 
4177: 54        lsrb 
4178: 54        lsrb 
4179: 54        lsrb 
417a: 27 12     beq  $418E
417c: 5a        decb 
417d: 27 d2     beq  $4151
417f: 5a        decb 
4180: 27 0d     beq  $418F
4182: c6 20     ldb  #$20
4184: de 04     ldx  $04
4186: e7 00     stb  $00,x
4188: 08        inx  
4189: 4a        deca 
418a: 26 fa     bne  $4186
418c: df 04     stx  $04
418e: 39        rts  
418f: de 06     ldx  $06
4191: e6 00     ldb  $00,x
4193: 08        inx  
4194: df 06     stx  $06
4196: 20 ec     bra  $4184
4198: 31        ins  
4199: 30        tsx  
419a: 34        des  
419b: 37        pshb 
419c: 53        comb 
419d: 45        illegal
419e: 4e        illegal
419f: 57        asrb 
41a0: 33        pulb 
41a1: 3f        swi  
41a2: 36        psha 
41a3: 39        rts  
41a4: 32        pula 
41a5: 21 35     brn  $41DC
41a7: 38        illegal
41a8: 86 04     lda  #$04
41aa: b7 01 eb  sta  $01EB
41ad: ff 01 ec  stx  $01EC
41b0: a6 01     lda  $01,x
41b2: 26 04     bne  $41B8
41b4: 86 f7     lda  #$F7
41b6: a7 00     sta  $00,x
41b8: a6 00     lda  $00,x
41ba: b7 01 f7  sta  $01F7
41bd: 39        rts  
41be: ce 01 f3  ldx  #$01F3
41c1: 8d e5     bsr  $41A8
41c3: 8d 5b     bsr  $4220
41c5: b6 20 00  lda  $2000
41c8: 44        lsra 
41c9: 44        lsra 
41ca: 44        lsra 
41cb: 44        lsra 
41cc: 81 0f     cmpa #$0F
41ce: 26 27     bne  $41F7
41d0: 8d 7a     bsr  $424C
41d2: 7a 01 eb  dec  $01EB
41d5: 26 ec     bne  $41C3
41d7: 20 17     bra  $41F0
41d9: ce 01 f5  ldx  #$01F5
41dc: 8d ca     bsr  $41A8
41de: 8d 40     bsr  $4220
41e0: b6 20 00  lda  $2000
41e3: 84 0f     anda #$0F
41e5: 81 0f     cmpa #$0F
41e7: 26 0e     bne  $41F7
41e9: 8d 61     bsr  $424C
41eb: 7a 01 eb  dec  $01EB
41ee: 26 ee     bne  $41DE
41f0: fe 01 ec  ldx  $01EC
41f3: 6f 01     clr  $01,x
41f5: 0c        clc  
41f6: 39        rts  
41f7: c6 03     ldb  #$03
41f9: 8d 60     bsr  $425B
41fb: fb 01 f1  addb $01F1
41fe: f7 01 f1  stb  $01F1
4201: fe 01 f0  ldx  $01F0
4204: e6 00     ldb  $00,x
4206: fe 01 ec  ldx  $01EC
4209: e1 01     cmpb $01,x
420b: 27 0c     beq  $4219
420d: b6 01 f7  lda  $01F7
4210: a7 00     sta  $00,x
4212: e7 01     stb  $01,x
4214: f7 01 f2  stb  $01F2
4217: 0d        sec  
4218: 39        rts  
4219: c1 45     cmpb #$45
421b: 2c f7     bge  $4214
421d: 0c        clc  
421e: 39        rts  
421f: 01        nop  
4220: 86 e0     lda  #$E0
4222: b4 20 02  anda $2002
4225: b7 01 f0  sta  $01F0
4228: 86 1f     lda  #$1F
422a: b4 01 f7  anda $01F7
422d: ba 01 f0  ora  $01F0
4230: b7 20 02  sta  $2002
4233: c6 04     ldb  #$04
4235: 8d 24     bsr  $425B
4237: ce 41 98  ldx  #$4198
423a: ff 01 f0  stx  $01F0
423d: 0c        clc  
423e: 58        aslb 
423f: 58        aslb 
4240: fb 01 f1  addb $01F1
4243: f7 01 f1  stb  $01F1
4246: 24 03     bcc  $424B
4248: 7c 01 f0  inc  $01F0
424b: 39        rts  
424c: f6 01 f7  ldb  $01F7
424f: 0d        sec  
4250: 56        rorb 
4251: 24 04     bcc  $4257
4253: f7 01 f7  stb  $01F7
4256: 39        rts  
4257: c6 f7     ldb  #$F7
4259: 20 f8     bra  $4253
425b: 7f 01 e5  clr  $01E5
425e: 0d        sec  
425f: 44        lsra 
4260: 24 06     bcc  $4268
4262: 7c 01 e5  inc  $01E5
4265: 5a        decb 
4266: 26 f7     bne  $425F
4268: f6 01 e5  ldb  $01E5
426b: 39        rts  
426c: c6 05     ldb  #$05
426e: f7 01 ec  stb  $01EC
4271: 8d 18     bsr  $428B
4273: 5a        decb 
4274: 26 fd     bne  $4273
4276: 8d 13     bsr  $428B
4278: 7c 01 ec  inc  $01EC
427b: f6 01 ec  ldb  $01EC
427e: 5a        decb 
427f: 26 fd     bne  $427E
4281: f6 01 ec  ldb  $01EC
4284: 8d 05     bsr  $428B
4286: c1 5f     cmpb #$5F
4288: 26 e9     bne  $4273
428a: 39        rts  
428b: 0f        sei  
428c: b6 20 03  lda  $2003
428f: 88 08     eora #$08
4291: b7 20 03  sta  $2003
4294: 0e        cli  
4295: 39        rts  
4296: 86 80     lda  #$80
4298: ce 04 00  ldx  #$0400
429b: 09        dex  
429c: a7 00     sta  $00,x
429e: 8c 02 00  cmpx #$0200
42a1: 26 f8     bne  $429B
42a3: 39        rts  
42a4: b6 20 02  lda  $2002
42a7: 7d 01 fc  tst  $01FC
42aa: 27 05     beq  $42B1
42ac: fe 01 c5  ldx  $01C5
42af: ad 00     jsr  $00,x
42b1: 7c 01 f8  inc  $01F8
42b4: 28 03     bvc  $42B9
42b6: 7f 01 f8  clr  $01F8
42b9: 7c 01 fb  inc  $01FB
42bc: 86 3b     lda  #$3B
42be: b1 01 fb  cmpa $01FB
42c1: 2e 1b     bgt  $42DE
42c3: 7d 01 fd  tst  $01FD
42c6: 27 05     beq  $42CD
42c8: fe 01 c7  ldx  $01C7
42cb: ad 00     jsr  $00,x
42cd: 7f 01 fb  clr  $01FB
42d0: 0c        clc  
42d1: b6 01 f9  lda  $01F9
42d4: 81 59     cmpa #$59
42d6: 27 07     beq  $42DF
42d8: 8b 01     adda #$01
42da: 19        daa  
42db: b7 01 f9  sta  $01F9
42de: 3b        rti  
42df: 7f 01 f9  clr  $01F9
42e2: b6 01 fa  lda  $01FA
42e5: 81 99     cmpa #$99
42e7: 27 1d     beq  $4306
42e9: 8b 01     adda #$01
42eb: 19        daa  
42ec: b7 01 fa  sta  $01FA
42ef: 3b        rti  
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
4306: 7f 01 fa  clr  $01FA
4309: 3b        rti  
430a: 01        nop  
430b: ec        illegal
430c: ea ee     orb  $EE,x
430e: ea ee     orb  $EE,x
4310: e8 01     eorb $01,x
4312: 9e 9a     lds  $9A
4314: 9e 98     lds  $98
4316: 9e 98     lds  $98
4318: 01        nop  
4319: dc        illegal
431a: d8 d8     eorb $D8
431c: 80 d8     suba #$D8
431e: 80 ff     suba #$FF
4320: 54        lsrb 
4321: 56        rorb 
4322: 20 4d     bra  $4371
4324: 49        rola 
4325: 43        coma 
4326: 52        illegal
4327: 4f        clra 
4328: 2d 43     blt  $436D
432a: 4f        clra 
432b: 4d        tsta 
432c: 50        negb 
432d: 55        illegal
432e: 54        lsrb 
432f: 45        illegal
4330: 52        illegal
4331: cf 80 43  stx  #$8043
4334: 4f        clra 
4335: 50        negb 
4336: 59        rolb 
4337: 52        illegal
4338: 49        rola 
4339: 47        asra 
433a: 48        asla 
433b: 54        lsrb 
433c: 20 41     bra  $437F
433e: 50        negb 
433f: 46        rora 
4340: 31        ins  
4341: 39        rts  
4342: 37        pshb 
4343: 38        illegal
4344: db 80     addb $80
4346: cc        illegal
4347: 80 e8     suba #$E8
4349: 52        illegal
434a: 4f        clra 
434b: 43        coma 
434c: 4b        illegal
434d: 45        illegal
434e: 54        lsrb 
434f: 20 50     bra  $43A1
4351: 41        illegal
4352: 54        lsrb 
4353: 52        illegal
4354: 4f        clra 
4355: 4c        inca 
4356: f4 f7 31  andb $F731
4359: 2e 20     bgt  $437B
435b: 54        lsrb 
435c: 57        asrb 
435d: 4f        clra 
435e: 20 50     bra  $43B0
4360: 4c        inca 
4361: 41        illegal
4362: 59        rolb 
4363: 45        illegal
4364: 52        illegal
4365: d3        illegal
4366: 8f 32 2e  sts  #$322E
4369: 20 50     bra  $43BB
436b: 4c        inca 
436c: 41        illegal
436d: 59        rolb 
436e: 45        illegal
436f: 52        illegal
4370: 20 41     bra  $43B3
4372: 4e        illegal
4373: 44        lsra 
4374: 20 43     bra  $43B9
4376: 4f        clra 
4377: 4d        tsta 
4378: 50        negb 
4379: 55        illegal
437a: 54        lsrb 
437b: 45        illegal
437c: 52        illegal
437d: ca 8f     orb  #$8F
437f: ff b6 20  stx  $B620
4382: 02        illegal
4383: 84 3f     anda #$3F
4385: 8a c0     ora  #$C0
4387: b7 20 02  sta  $2002
438a: b6 20 01  lda  $2001
438d: 84 c7     anda #$C7
438f: 8a 38     ora  #$38
4391: b7 20 01  sta  $2001
4394: 4f        clra 
4395: bd 42 98  jsr  $4298
4398: ce 47 83  ldx  #$4783
439b: df 06     stx  $06
439d: ce 02 00  ldx  #$0200
43a0: bd 41 44  jsr  $4144
43a3: ce 44 aa  ldx  #$44AA
43a6: 96 00     lda  $00
43a8: 4a        deca 
43a9: 27 0d     beq  $43B8
43ab: ce 47 94  ldx  #$4794
43ae: c6 08     ldb  #$08
43b0: 86 31     lda  #$31
43b2: bd 44 7f  jsr  $447F
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
43ce: bd 47 7c  jsr  $477C
43d1: ce 45 51  ldx  #$4551
43d4: ff 01 c5  stx  $01C5
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
43f6: bd 42 f0  jsr  $42F0
43f9: bd 46 52  jsr  $4652
43fc: ce 47 ac  ldx  #$47AC
43ff: ff 01 e6  stx  $01E6
4402: ce 01 42  ldx  #$0142
4405: c6 0a     ldb  #$0A
4407: bd 42 f0  jsr  $42F0
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
442b: 2e 36     bgt  $4463
442d: ce 44 bc  ldx  #$44BC
4430: ff 01 90  stx  $0190
4433: f6 01 5f  ldb  $015F
4436: 27 0a     beq  $4442
4438: bd 42 8b  jsr  $428B
443b: c6 df     ldb  #$DF
443d: 5a        decb 
443e: 26 fd     bne  $443D
4440: 20 f1     bra  $4433
4442: 8d 07     bsr  $444B
4444: fe 01 90  ldx  $0190
4447: ad 00     jsr  $00,x
4449: 20 d7     bra  $4422
444b: ce 07 70  ldx  #$0770
444e: bd 47 79  jsr  $4779
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
447d: 20 fe     bra  $447D
447f: b7 01 e9  sta  $01E9
4482: 86 02     lda  #$02
4484: b7 01 e8  sta  $01E8
4487: ff 01 e6  stx  $01E6
448a: fe 01 e8  ldx  $01E8
448d: 7e 42 f0  jmp  $42F0
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
44d1: bd 42 8b  jsr  $428B
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
4551: b6 20 03  lda  $2003
4554: 84 fc     anda #$FC
4556: 8a 03     ora  #$03
4558: b7 20 03  sta  $2003
455b: ce 45 66  ldx  #$4566
455e: ff 01 c5  stx  $01C5
4561: bd 46 27  jsr  $4627
4564: 20 3a     bra  $45A0
4566: ce 45 51  ldx  #$4551
4569: ff 01 c5  stx  $01C5
456c: b6 20 03  lda  $2003
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
4592: bd 46 7c  jsr  $467C
4595: 86 01     lda  #$01
4597: b5 01 fa  bita $01FA
459a: 27 03     beq  $459F
459c: bd 46 7c  jsr  $467C
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
4601: bd 41 2f  jsr  $412F
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
4636: 8d 1c     bsr  $4654
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
4698: fe 01 40  ldx  $0140
469b: ee 08     ldx  $08,x
469d: bd 47 79  jsr  $4779
46a0: fe 01 40  ldx  $0140
46a3: ee 06     ldx  $06,x
46a5: ff 01 e6  stx  $01E6
46a8: fe 01 40  ldx  $0140
46ab: ee 08     ldx  $08,x
46ad: 86 10     lda  #$10
46af: bd 41 1d  jsr  $411D
46b2: c6 40     ldb  #$40
46b4: bd 42 f0  jsr  $42F0
46b7: ce 01 42  ldx  #$0142
46ba: ff 01 40  stx  $0140
46bd: 8d 47     bsr  $4706
46bf: ce 01 4c  ldx  #$014C
46c2: a6 00     lda  $00,x
46c4: ab 01     adda $01,x
46c6: 27 05     beq  $46CD
46c8: ff 01 40  stx  $0140
46cb: 8d 39     bsr  $4706
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
4779: 4f        clra 
477a: c6 10     ldb  #$10
477c: a7 00     sta  $00,x
477e: 08        inx  
477f: 5a        decb 
4780: 26 fa     bne  $477C
4782: 39        rts  
4783: df 83     stx  $83
4785: c1 83     cmpb #$83
4787: df 8f     stx  $8F
4789: c1 8f     cmpb #$8F
478b: df 8c     stx  $8C
478d: c1 8c     cmpb #$8C
478f: df 80     stx  $80
4791: c1 80     cmpb #$80
4793: ff 43 4f  stx  $434F
4796: 4d        tsta 
4797: 50        negb 
4798: 55        illegal
4799: 54        lsrb 
479a: 45        illegal
479b: 52        illegal
479c: 46        rora 
479d: 49        rola 
479e: 52        illegal
479f: 45        illegal
47a0: 00        illegal
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
47b6: 00        illegal
47b7: 00        illegal
47b8: 00        illegal
47b9: 00        illegal
47ba: 00        illegal
47bb: 00        illegal
47bc: 00        illegal
47bd: 03        illegal
47be: 0f        sei  
47bf: ff 0f 07  stx  $0F07
47c2: 00        illegal
47c3: 00        illegal
47c4: 00        illegal
47c5: 00        illegal
47c6: ff c0 00  stx  $C000
47c9: 01        nop  
47ca: 03        illegal
47cb: 07        tpa  
47cc: 3f        swi  
47cd: ff ff ff  stx  $FFFF
47d0: ff ff 3f  stx  $FF3F
47d3: 01        nop  
47d4: c0 ff     subb #$FF
47d6: ff 3f 7f  stx  $3F7F
47d9: fe fb fe  ldx  $FBFE
47dc: fb ff ff  addb $FFFF
47df: ff ff ff  stx  $FFFF
47e2: ff fe 3b  stx  $FE3B
47e5: ff f0 c0  stx  $F0C0
47e8: c0 80     subb #$80
47ea: 40        nega 
47eb: 80 40     suba #$40
47ed: c7 8f     stb  #$8F
47ef: ff f8 c8  stx  $F8C8
47f2: c3        illegal
47f3: 80 80     suba #$80
47f5: f0 ff 00  subb $FF00
47f8: 42        illegal
47f9: a4 40     anda $40,x
47fb: 00        illegal
47fc: 40        nega 
47fd: 00        illegal
47fe: 40        nega 
47ff: 00        illegal
