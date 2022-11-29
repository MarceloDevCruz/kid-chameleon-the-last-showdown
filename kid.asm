; ===========================================================================
; Disassembly for Kid Chameleon
; See https://github.com/sonicretro/kid-chameleon-disasm for the latest
; version.
; 
; Many macros and other stuff have been taken from the Sonic 2 disassembly,
; credit goes to their respective authors:
; https://github.com/sonicretro/s2disasm
; ===========================================================================
	CPU 68000	; uses 68008 by default
	padding off	; we don't want AS padding out dc.b instructions
	supmode on	; we don't need warnings about privileged instructions
; ===========================================================================
; Set to 1 to compile all instances of 0(ax) as (ax)
; (Takes less space but is not bit-perfect.)
zeroOffsetOptimization = 0
; Set to 1 to add a level/helmet select to the game.
insertLevelSelect = 1
; Introduce type of scripted platform that starts the script only once the
; kid stands on the platform.
; In the layout, such a platform is used when the platform parameter t=1.
; (See doc/Kid Chameleon hacking.txt, Section "Moving platforms".)
platforms_newtype = 1
; ===========================================================================
Start_LevelID = 0 ; Level ID for first level: Blue Lake Woods 1
Final_LevelID = $33 ; Level ID for final level: Plethora
WarpCheatStart_LevelID = 1 ; Level in which to activate warp cheat
WarpCheatDest_LevelID = $32 ; Level whose ending screen we get after warp cheat
HundredKTripStart_LevelID = 4 ; 100K trip start level
HundredKTripDest_LevelID = $1F ; 100K trip destination level
FirstElsewhere_LevelID = $5C ; from this level on name everything 'Elsewhere'.
	; More specifically, all levels with a higher LevelID 
	; use the title from the level with this LevelID.
TotalNumberLevels = $6D	; to tell the level select how many to display

BagelBrothers_HitPointsPerHead = $1B
BoomerangBoss_HitPointsPerHead = $16
ShishkaBoss_HitPointsPerHead = $11
; don't load flag for these levels until boss is killed:
Boss1_LevelID = $10
Boss2_LevelID = $1E
Boss3_LevelID = $2A
Boss4_LevelID = $33

; Variable names for RAM locations
	include	"variables.asm"

; Default Options that are selected 
; $00xxxxxx / $FFxxxxxx: 1st/2nd controller for second player
; $xx00xxxx / $xxFFxxxx: slow/fast action, press speed button for fast/slow
; $xxxx000Y: Y between 0 and 5 determines which keys do what. A/B/C:
	; 0: Speed/Jump/Special
	; 1: Speed/Special/Jump
	; 2: Jump/Speed/Special
	; 3: Jump/Special/Speed
	; 4: Special/Speed/Jump
	; 5: Special/Jump/Speed
Default_Options = $00000000
; ===========================================================================
	include "constants.asm"
	include "macros.asm"
; ===========================================================================
StartOfROM:
Vectors:
	dc.l Initial_stack	; Initial stack pointer value
	dc.l EntryPoint		; Start of program
	dc.l BusError		; Bus error
	dc.l AddressError		; Address error (4)
	dc.l IllegalInstruction        ; Illegal instruction
	dc.l DivisionByZero        ; Division by zero
	dc.l ChkException        ; CHK exception
	dc.l TRAPVException        ; TRAPV exception (8)
off_20:	dc.l PrivilegeViolation    ; Privilege violation
	dc.l TraceException        ; TRACE exception
	dc.l LineAEmulator        ; Line-A emulator
	dc.l LineFEmulator        ; Line-F emulator (12)
	dc.l Vector13        ; Unused (reserved)
	dc.l Vector14        ; Unused (reserved)
	dc.l Vector15        ; Unused (reserved)
	dc.l Vector16        ; Unused (reserved) (16)	
	dc.l Vector17        ; Unused (reserved)
	dc.l Vector18        ; Unused (reserved)
	dc.l Vector19        ; Unused (reserved)
	dc.l Vector20        ; Unused (reserved) (20)
	dc.l Vector21        ; Unused (reserved)
	dc.l Vector22        ; Unused (reserved)
	dc.l Vector23        ; Unused (reserved)
	dc.l Vector24        ; Unused (reserved) (24)
	dc.l SpuriousException        ; Spurious exception
	dc.l IRQLevel1        ; IRQ level 1
	dc.l IRQLevel2        ; IRQ level 2
	dc.l IRQLevel3        ; IRQ level 3 (28)
	dc.l H_Int          ; IRQ level 4 (horizontal retrace interrupt)
	dc.l IRQLevel5        ; IRQ level 5
	dc.l V_Int          ; IRQ level 6 (vertical retrace interrupt)
	dc.l EntryPoint		; IRQ level 7 (32)
	dc.l Trap00Exception        ; TRAP #00 exception
	dc.l Trap01Exception        ; TRAP #01 exception
	dc.l Trap02Exception        ; TRAP #02 exception
	dc.l Trap03Exception        ; TRAP #03 exception (36)
	dc.l Trap04Exception        ; TRAP #04 exception
	dc.l Trap05Exception        ; TRAP #05 exception
	dc.l Trap06Exception        ; TRAP #06 exception
	dc.l Trap07Exception        ; TRAP #07 exception (40)
	dc.l Trap08Exception        ; TRAP #08 exception
	dc.l Trap09Exception        ; TRAP #09 exception
	dc.l Trap10Exception        ; TRAP #10 exception
	dc.l Trap11Exception        ; TRAP #11 exception (44)
	dc.l Trap12Exception        ; TRAP #12 exception
	dc.l Trap13Exception        ; TRAP #13 exception
	dc.l Trap14Exception        ; TRAP #14 exception
	dc.l Trap15Exception        ; TRAP #15 exception (48)
	dc.l Vector49        ; Unused (reserved)
	dc.l Vector50        ; Unused (reserved)
	dc.l Vector51        ; Unused (reserved)
	dc.l Vector52        ; Unused (reserved) (52)
	dc.l Vector53        ; Unused (reserved)
	dc.l Vector54        ; Unused (reserved)
	dc.l Vector55        ; Unused (reserved)
	dc.l Vector56        ; Unused (reserved) (56)
	dc.l Vector57        ; Unused (reserved)
	dc.l Vector58        ; Unused (reserved)
	dc.l Vector59        ; Unused (reserved)
	dc.l Vector60        ; Unused (reserved) (60)
	dc.l Vector61        ; Unused (reserved)
	dc.l Vector62        ; Unused (reserved)
	dc.l Vector63        ; Unused (reserved)
	dc.l Vector64        ; Unused (reserved) (64)
ROM_Header:	dc.b "SEGA MEGA DRIVE "
	dc.b "(C)SEGA 1991 DEC"
	dc.b "KID CHAMELEON                                   "
	dc.b "KID CHAMELEON                                   "
	dc.b "GM MK-1010 -00"
	dc.w $24F4
	dc.b "J               "
	dc.l StartOfROM
	dc.l EndOfROM-1
	dc.l $FF0000
	dc.l $FFFFFF
	dc.b "    "
	dc.l $20202020
	dc.l $20202020
	dc.b "            "
	dc.b "                                        "
	dc.b "JUE             "
; ===========================================================================
j_EntryPoint: ;200
	jmp	EntryPoint(pc)
; ===========================================================================
j_loc_6E2: ;204
	jmp	loc_6E2(pc)
; ===========================================================================
j_sub_914: ;208
	jmp	sub_914(pc)
; ===========================================================================
j_sub_924: ;20C
	jmp	sub_924(pc)
; ===========================================================================
j_WaitForVint: ;210
	jmp	WaitForVint(pc)
; ---------------------------------------------------------------------------
	jmp	loc_964(pc)
; ===========================================================================
j_Palette_to_VRAM: ;218
	jmp	Palette_to_VRAM(pc)
; ===========================================================================
j_Init_RNG: ;21C
	jmp	Init_RNG(pc)
; ===========================================================================
j_Get_RandomNumber_byte: ;220
	jmp	Get_RandomNumber_byte(pc)
; ===========================================================================
j_Get_RandomNumber_word: ;224
	jmp	Get_RandomNumber_word(pc)
; ===========================================================================
j_Get_RandomNumber_long: ;228
	jmp	Get_RandomNumber_long(pc)
; ===========================================================================
j_sub_B52: ;22C
	jmp	sub_B52(pc)
; ===========================================================================
j_Transfer_SpriteAndKidToVRAM: ;230
	jmp	Transfer_SpriteAndKidToVRAM(pc)
; ===========================================================================
j_ReadJoypad: ;234
	jmp	ReadJoypad(pc)
; ---------------------------------------------------------------------------
	jmp	Initialize_ObjectSlots(pc)
; ===========================================================================
j_Allocate_ObjectSlot: ;23C
	jmp	Allocate_ObjectSlot(pc)
; ===========================================================================
j_sub_E02: ;240
	jmp	sub_E02(pc)
; ---------------------------------------------------------------------------
j_Execute_Objects: ;244
	jmp	Execute_Objects(pc)
; ===========================================================================
j_Hibernate_Object: ;248
	jmp	Hibernate_Object(pc)
; ===========================================================================
j_Hibernate_Object_1Frame: ;24C
	jmp	Hibernate_Object_1Frame(pc)
; ===========================================================================
j_Delete_Object_a0: ;250
	jmp	Delete_Object_a0(pc)
; ===========================================================================
j_Delete_AllButCurrentObject: ;254
	jmp	Delete_AllButCurrentObject(pc)
; ===========================================================================
j_Delete_CurrentObject: ;258
	jmp	Delete_CurrentObject(pc)
; ---------------------------------------------------------------------------
	jmp	Initialize_GfxObjectSlots(pc)
; ===========================================================================
j_Load_GfxObjectSlot: ;260
	jmp	Load_GfxObjectSlot(pc)
; ===========================================================================
j_Allocate_GfxObjectSlot_a1: ;264
	jmp	Allocate_GfxObjectSlot_a1(pc)
; ===========================================================================
j_Make_SpritesFromGfxObjects: ;268
	jmp	Make_SpritesFromGfxObjects(pc)
; ===========================================================================
j_sub_FF6: ;26C
	jmp	sub_FF6(pc)
; ===========================================================================
j_nullsub_2: ;270
	jmp	nullsub_2(pc)
; ===========================================================================
j_Init_Animation: ;274
	jmp	Init_Animation(pc)
; ===========================================================================
j_sub_105E: ;278
	jmp	sub_105E(pc)
; ===========================================================================
j_loc_1078: ;27C
	jmp	loc_1078(pc)
; ---------------------------------------------------------------------------
	jmp	GfxObject_Move(pc)
; ---------------------------------------------------------------------------
	jmp	GfxObject_Animate(pc)
; ===========================================================================
j_Make_SpriteFromGfxObject: ;288
	jmp	Make_SpriteFromGfxObject(pc)
; ---------------------------------------------------------------------------
	jmp	loc_1698(pc)
; ===========================================================================
j_GfxObjects_Collision: ;290
	jmp	GfxObjects_Collision(pc)
; ---------------------------------------------------------------------------
	jmp	GfxObjects_CollisionKid(pc)
; ---------------------------------------------------------------------------
	jmp	sub_219C(pc)
; ===========================================================================
j_Allocate_PlatformSlot: ;29C
	jmp	Allocate_PlatformSlot(pc)
; ===========================================================================
j_Deallocate_PlatformSlot: ;2A0
	jmp	Deallocate_PlatformSlot(pc)
; ===========================================================================
j_sub_292E: ;2A4
	jmp	sub_292E(pc)
; ---------------------------------------------------------------------------
	jmp	PlatformLayout_BaseAddress(pc)
; ===========================================================================
j_sub_8E0: ;2AC
	jmp	sub_8E0(pc)
; ===========================================================================
j_Initialize_Platforms: ;2B0
	jmp	Initialize_Platforms(pc)
; ===========================================================================
j_sub_28FC: ;2B4
	jmp	sub_28FC(pc)
; ===========================================================================
j_sub_44B0: ;2B8
	jmp	sub_44B0(pc)
; ===========================================================================
j_Init_Timer_and_Bonus_Flags: ;2BC
	jmp	Init_Timer_and_Bonus_Flags(pc)
; ---------------------------------------------------------------------------
	jmp	sub_8A4(pc)
; ===========================================================================
j_sub_8C2: ;2C4
	jmp	sub_8C2(pc)
; ===========================================================================
j_Do_Nothing: ;2C8
	jmp	Do_Nothing(pc)
; ---------------------------------------------------------------------------
j_sub_14C0: ;2CC
	jmp	sub_14C0(pc)
; ---------------------------------------------------------------------------
returnFromException:
	rte
; ---------------------------------------------------------------------------
BusError:
	move.w	#2,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
AddressError:
	move.w	#3,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
IllegalInstruction:
	move.w	#4,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
DivisionByZero:
	move.w	#5,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
ChkException:
	move.w	#6,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
TRAPVException:
	move.w	#7,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
PrivilegeViolation:
	move.w	#8,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
TraceException:
	move.w	#9,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
LineAEmulator:
	move.w	#$A,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
LineFEmulator:
	move.w	#$B,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector13:
	move.w	#$C,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector14:
	move.w	#$D,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector15:
	move.w	#$E,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector16:
	move.w	#$F,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector17:
	move.w	#$10,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector18:
	move.w	#$11,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector19:
	move.w	#$12,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector20:
	move.w	#$13,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector21:
	move.w	#$14,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector22:
	move.w	#$15,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector23:
	move.w	#$16,d0
	bra.s	returnFromException
; ---------------------------------------------------------------------------
Vector24:
	move.w	#$17,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
SpuriousException:
	move.w	#$18,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
IRQLevel1:
	move.w	#$19,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
IRQLevel2:
	move.w	#$1A,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
IRQLevel3:
	move.w	#$1B,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
IRQLevel5:
	move.w	#$1C,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
	move.w	#$1D,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap00Exception:
	move.w	#$1E,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap01Exception:
	move.w	#$1F,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap02Exception:
	move.w	#$20,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap03Exception:
	move.w	#$21,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap04Exception:
	move.w	#$22,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap05Exception:
	move.w	#$23,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap06Exception:
	move.w	#$24,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap07Exception:
	move.w	#$25,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap08Exception:
	move.w	#$26,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap09Exception:
	move.w	#$27,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap10Exception:
	move.w	#$28,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap11Exception:
	move.w	#$29,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap12Exception:
	move.w	#$2A,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap13Exception:
	move.w	#$2B,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap14Exception:
	move.w	#$2C,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Trap15Exception:
	move.w	#$2D,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector49:
	move.w	#$2E,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector50:
	move.w	#$2F,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector51:
	move.w	#$30,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector52:
	move.w	#$31,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector53:
	move.w	#$32,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector54:
	move.w	#$33,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector55:
	move.w	#$34,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector56:
	move.w	#$35,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector57:
	move.w	#$36,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector58:
	move.w	#$37,d0
loc_454:
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector59:
	move.w	#$38,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector60:
	move.w	#$39,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector61:
	move.w	#$3A,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector62:
	move.w	#$3B,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector63:
	move.w	#$3C,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
Vector64:
	move.w	#$3D,d0
	bra.w	returnFromException
; ---------------------------------------------------------------------------
V_Int:
	addq.l	#1,(V_Int_counter).w
	st	(V_Int_Done).w
	rte
; ---------------------------------------------------------------------------
H_Int:
	andi.w	#$F0FF,(sp)
	ori.w	#$500,(sp)
	rte
; ---------------------------------------------------------------------------
VDPGameInitValues:
	dc.b $14		; Command $8014 - HInt on, Enable HV counter read
	dc.b $74		; Command $8174 - Display on, VInt on, DMA on, PAL off
	dc.b   0		; Command $8200 - Scroll A Address $0000
	dc.b   0		; Command $8300 - Window Address $0000
	dc.b   7		; Command $8407 - Scroll B Address $E000
	dc.b   8		; Command $8508 - Sprite Table Address $1000
	dc.b   0		; Command $8600 - Null
	dc.b   0		; Command $8700 - Background color Pal 0 Color 0
	dc.b   0		; Command $8800 - Null
	dc.b   0		; Command $8900 - Null
	dc.b   0		; Command $8A00 - Hint timing 0 scanlines
	dc.b   3		; Command $8B03 - Ext Int off, VScroll full, HScroll single pixel rows
	dc.b $81		; Command $8C81 - 40 cell mode, shadow/highlight off, no interlace
	dc.b   5		; Command $8D05 - HScroll Table Address $1400
	dc.b   0		; Command $8E00 - Null
	dc.b   2		; Command $8F02 - VDP auto increment 2 bytes
	dc.b   1		; Command $9001 - 64x32 cell scroll size
	dc.b   0		; Command $9100 - Window H left side, Base Point 0
	dc.b   0		; Command $9200 - Window V upside, Base Point 0
	dc.b   0		; Command $9300 - DMA Length Counter $0
; ---------------------------------------------------------------------------

EntryPoint:
	tst.l	(HW_Port_1_Control-1).l	; test ports A and B control
	bne.s	PortA_Ok	; If so, branch.
	tst.w	(HW_Expansion_Control-1).l	; test port C control

PortA_Ok:
	bne.s	PortC_OK ; skip the VDP and Z80 setup code if port A, B or C is ok...?
	lea	SetupValues(pc),a5	; Load setup values array address.
	movem.w	(a5)+,d5-d7
	movem.l	(a5)+,a0-a4
	move.b	HW_Version-Z80_Bus_Request(a1),d0	; get hardware version
	andi.b	#$F,d0	; Compare
	beq.s	SkipSecurity	; If the console has no TMSS, skip the security stuff.
	move.l	#'SEGA',Security_Addr-Z80_Bus_Request(a1) ; Satisfy the TMSS

SkipSecurity:
	move.w	(a4),d0	; check if VDP works
	moveq	#0,d0	; clear d0
	move.l	d0,a6	; clear a6
	move	a6,usp	; set usp to $0
	moveq	#VDPInitValues_End-VDPInitValues-1,d1 ; run the following loop $18 times

VDPInitLoop:
	move.b	(a5)+,d5	; add $8000 to value
	move.w	d5,(a4)	; move value to VDP register
	add.w	d7,d5	; next register
	dbf	d1,VDPInitLoop
	
	move.l	(a5)+,(a4)	; set VRAM write mode
	move.w	d0,(a3)	; clear the screen
	move.w	d7,(a1)	; stop the Z80
	move.w	d7,(a2)	; reset the Z80

WaitForZ80:
	btst	d0,(a1)	; has the Z80 stopped?
	bne.s	WaitForZ80	; if not, branch
	moveq	#Z80StartupCodeEnd-Z80StartupCodeBegin-1,d2

Z80InitLoop:
	move.b	(a5)+,(a0)+
	dbf	d2,Z80InitLoop
	
	move.w	d0,(a2)
	move.w	d0,(a1)	; start the Z80
	move.w	d7,(a2)	; reset the Z80

ClrRAMLoop:
	move.l	d0,-(a6)	; clear 4 bytes of RAM
	dbf	d6,ClrRAMLoop	; repeat until the entire RAM is clear
	move.l	(a5)+,(a4)	; set VDP display mode and increment mode
	move.l	(a5)+,(a4)	; set VDP to CRAM write
	moveq	#bytesToLcnt($80),d3	; set repeat times

ClrCRAMLoop:
	move.l	d0,(a3)	; clear 2 palettes
	dbf	d3,ClrCRAMLoop	; repeat until the entire CRAM is clear
	move.l	(a5)+,(a4)	; set VDP to VSRAM write
	moveq	#bytesToLcnt($50),d4	; set repeat times

ClrVSRAMLoop:
	move.l	d0,(a3)	; clear 4 bytes of VSRAM.
	dbf	d4,ClrVSRAMLoop	; repeat until the entire VSRAM is clear
	moveq	#PSGInitValues_End-PSGInitValues-1,d5	; set repeat times

PSGInitLoop:
	move.b	(a5)+,PSG_input-VDP_data_port(a3) ; reset the PSG
	dbf	d5,PSGInitLoop	; repeat for other channels
	move.w	d0,(a2)
	movem.l	(a6),d0-a6	; clear all registers
	move	#$2700,sr	; set the sr

PortC_OK:
	bra.s	GameProgram	; Branch to game program.
; ---------------------------------------------------------------------------
SetupValues:
	dc.w	$8000,bytesToLcnt($10000),$100

	dc.l	Z80_RAM
	dc.l	Z80_Bus_Request
	dc.l	Z80_Reset
	dc.l	VDP_data_port, VDP_control_port

VDPInitValues:	; values for VDP registers
	dc.b 4			; Command $8004 - HInt off, Enable HV counter read
	dc.b $14		; Command $8114 - Display off, VInt off, DMA on, PAL off
	dc.b $30		; Command $8230 - Scroll A Address $C000
	dc.b $3C		; Command $833C - Window Address $F000
	dc.b 7			; Command $8407 - Scroll B Address $E000
	dc.b $6C		; Command $856C - Sprite Table Address $D800
	dc.b 0			; Command $8600 - Null
	dc.b 0			; Command $8700 - Background color Pal 0 Color 0
	dc.b 0			; Command $8800 - Null
	dc.b 0			; Command $8900 - Null
	dc.b $FF		; Command $8AFF - Hint timing $FF scanlines
	dc.b 0			; Command $8B00 - Ext Int off, VScroll full, HScroll full
	dc.b $81		; Command $8C81 - 40 cell mode, shadow/highlight off, no interlace
	dc.b $37		; Command $8D37 - HScroll Table Address $DC00
	dc.b 0			; Command $8E00 - Null
	dc.b 1			; Command $8F01 - VDP auto increment 1 byte
	dc.b 1			; Command $9001 - 64x32 cell scroll size
	dc.b 0			; Command $9100 - Window H left side, Base Point 0
	dc.b 0			; Command $9200 - Window V upside, Base Point 0
	dc.b $FF		; Command $93FF - DMA Length Counter $FFFF
	dc.b $FF		; Command $94FF - See above
	dc.b 0			; Command $9500 - DMA Source Address $0
	dc.b 0			; Command $9600 - See above
	dc.b $80		; Command $9780	- See above + VRAM fill mode
VDPInitValues_End:

	dc.l	vdpComm($0000,VRAM,DMA) ; value for VRAM write mode
	
	; Z80 instructions (not the sound driver; that gets loaded later)
Z80StartupCodeBegin: ; loc_2CA:
    if (*)+$26 < $10000
    save
    CPU Z80 ; start assembling Z80 code
    phase 0 ; pretend we're at address 0
	xor	a	; clear a to 0
	ld	bc,((Z80_RAM_End-Z80_RAM)-zStartupCodeEndLoc)-1 ; prepare to loop this many times
	ld	de,zStartupCodeEndLoc+1	; initial destination address
	ld	hl,zStartupCodeEndLoc	; initial source address
	ld	sp,hl	; set the address the stack starts at
	ld	(hl),a	; set first byte of the stack to 0
	ldir		; loop to fill the stack (entire remaining available Z80 RAM) with 0
	pop	ix	; clear ix
	pop	iy	; clear iy
	ld	i,a	; clear i
	ld	r,a	; clear r
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ex	af,af'	; swap af with af'
	exx		; swap bc/de/hl with their shadow registers too
	pop	bc	; clear bc
	pop	de	; clear de
	pop	hl	; clear hl
	pop	af	; clear af
	ld	sp,hl	; clear sp
	di		; clear iff1 (for interrupt handler)
	im	1	; interrupt handling mode = 1
	ld	(hl),0E9h ; replace the first instruction with a jump to itself
	jp	(hl)	  ; jump to the first instruction (to stay there forever)
zStartupCodeEndLoc:
    dephase ; stop pretending
	restore
    padding off ; unfortunately our flags got reset so we have to set them again...
    else ; due to an address range limitation I could work around but don't think is worth doing so:
	message "Warning: using pre-assembled Z80 startup code."
	dc.w $AF01,$D91F,$1127,$0021,$2600,$F977,$EDB0,$DDE1,$FDE1,$ED47,$ED4F,$D1E1,$F108,$D9C1,$D1E1,$F1F9,$F3ED,$5636,$E9E9
    endif
Z80StartupCodeEnd:

	dc.w	$8104	; value for VDP display mode
	dc.w	$8F02	; value for VDP increment
	dc.l	vdpComm($0000,CRAM,WRITE)	; value for CRAM write mode
	dc.l	vdpComm($0000,VSRAM,WRITE)	; value for VSRAM write mode

PSGInitValues:
	dc.b	$9F,$BF,$DF,$FF	; values for PSG channel volumes
PSGInitValues_End:
; ---------------------------------------------------------------------------

GameProgram:
	tst.w	(VDP_control_port).l
	move	#$2700,sr	; Initialise stack (already done in the init routine though
	lea	($FFFFF7FE).w,sp
	lea	(VDP_data_port).l,a6
	moveq	#$40,d0
	move.b	d0,(HW_Port_1_Control).l
	move.b	d0,(HW_Port_2_Control).l
	move.b	#$1F,(HW_Expansion_Control).l
	move.b	#$7F,(HW_Expansion_Data).l
	lea	VDPGameInitValues(pc),a0
	moveq	#$12,d0
	move.w	#$8000,d1

loc_5E6:
	move.b	(a0)+,d1
	move.w	d1,4(a6)
	addi.w	#$100,d1
	dbf	d0,loc_5E6
	move.l	(Options_Suboption_2PController).w,d7
	lea	(Sprite_Table).l,a0

loc_5FE:
	; clear entire RAM, except selected option (Options_Suboption_2PController, 4 bytes)
	move.w	#$3FFF,d0
	moveq	#0,d1
loc_604:
	move.l	d1,(a0)+
	dbf	d0,loc_604
	move.l	d7,(Options_Suboption_2PController).w
	cmpi.w	#5,d7
  if Default_Options = 0
	bls.s	loc_61C
	move.l	#0,(Options_Suboption_2PController).w
  else
	nop	; not strictly necessary, but avoids shifting stuff
	move.l	#Default_Options,(Options_Suboption_2PController).w
  endif

loc_61C:
	; clear entire	VRAM
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	move.w	#$3FFF,d0
	moveq	#0,d1
loc_62A:
	move.l	d1,(a6)
	dbf	d0,loc_62A
	move.l	#vdpComm($1400,VRAM,WRITE),4(a6)
	moveq	#0,d0
	move.w	d0,(a6)
	move.w	d0,(a6)
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d0,(a6)
	move.w	d0,(a6)
	move.w	#$FFFF,($FFFFFC32).w
	jsr	(j_StopMusic).l
	move.b	#2,($FFFFFC82).w

loc_65C:
	move.b	#1,($FFFFF805).w
	jsr	(j_sub_924).w
	jsr	(j_Init_RNG).w
	clr.w	(Game_Mode).w
	sf	(Check_Helmet_Change).w
	sf	($FFFFFBCE).w
	sf	($FFFFFC29).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w
	sf	(Two_player_flag).w
	sf	($FFFFFBC8).w
	sf	(Demo_Mode_flag).w
	move.w	(MapHeader_BaseAddress).l,(Player_1_LevelID).w
	move.w	#3,(Player_1_Lives).w
	clr.l	(Player_1_Score).w
	clr.w	(Player_1_Helmet).w
	move.w	#2,(Player_1_Hitpoints).w
	move.w	#3,(Player_1_Continues).w
	move.w	#$FFFF,($FFFFFC84).w
	move.w	(MapHeader_BaseAddress).l,(Player_2_LevelID).w
	move.w	#3,(Player_2_Lives).w
	clr.l	(Player_2_Score).w
	clr.w	(Player_2_Helmet).w
	move.w	#2,(Player_2_Hitpoints).w
	move.w	#3,(Player_2_Continues).w
	move.w	#$FFFF,($FFFFFD26).w
	bsr.w	sub_6E24


loc_6E2:
	lea	($FFFFF7FE).w,sp
	move.w	#$8200,4(a6)
	move.w	#$8407,4(a6)
	tst.b	($FFFFFBCE).w
	beq.s	loc_700
	bsr.w	Pal_FadeOut
	clr.w	($FFFFFBCC).w

loc_700:
	; clear entire	VRAM
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6) 
	move.w	#$3FFF,d0
	moveq	#0,d1
loc_70E:
	move.l	d1,(a6)
	dbf	d0,loc_70E
	lea	(Sprite_Table).l,a0
	move.w	#$7DE0,d0
	moveq	#0,d1

loc_720:
	move.w	d1,(a0)+
	dbf	d0,loc_720
	bsr.w	Initialize_ObjectSlots
	bsr.w	Initialize_GfxObjectSlots
	bsr.w	sub_8A4
	jsr	(j_LoadGameModeData).l

MainGameLoop:
	bsr.w	WaitForVint
	move.w	(Game_Mode).w,d0
	jsr	GameModesArray(pc,d0.w)
	bra.s	MainGameLoop
; ---------------------------------------------------------------------------

GameModesArray:
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Level
	bra.w	Mode_Level
	bra.w	Mode_Options_End
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Standard
	bra.w	Mode_Options_End
; ---------------------------------------------------------------------------

Mode_Standard:
	bsr.w	Do_Nothing
	bsr.w	Palette_to_VRAM
	bsr.w	Transfer_SpriteAndKidToVRAM
	jsr	(j_Transfer_ScrollDataToVRAM).l
	bsr.w	sub_1596
	bsr.w	Execute_Objects
	bsr.w	GfxObjects_MoveAndAnimate
	bsr.w	ReadJoypad
	bsr.w	Make_SpritesFromGfxObjects
	bsr.w	sub_14C0
	rts
; ---------------------------------------------------------------------------

Mode_Options_End:
	bsr.w	Do_Nothing
	bsr.w	Palette_to_VRAM
	bsr.w	Transfer_SpriteAndKidToVRAM
	bsr.w	Execute_Objects
	bsr.w	GfxObjects_MoveAndAnimate
	bsr.w	ReadJoypad
	bsr.w	Make_SpritesFromGfxObjects
	bsr.w	sub_14C0
	rts
; ---------------------------------------------------------------------------

Mode_Level:
	bsr.w	Transfer_SpriteAndKidToVRAM
	bsr.w	Palette_to_VRAM
	jsr	(j_Transfer_ScrollDataToVRAM).l
	bsr.w	sub_1596
	bsr.w	sub_6874
	jsr	(j_Make_SpriteAttr_HUD).w
	bsr.w	Execute_Objects
	bsr.w	sub_21F8
	tst.b	($FFFFFB49).w
	bne.s	loc_80C
	jsr	(j_DiamondPower_Run).l
	jsr	(j_sub_DFB0).l

loc_7FC:
	jsr	(j_sub_F7E0).l
	bsr.w	sub_6034

loc_806:
	jsr	(j_sub_F096).l

loc_80C:
	bsr.w	sub_44DC
	jsr	(j_Manage_EnemyLoading).l
	bsr.w	GfxObjects_MoveAndAnimate
	jsr	(j_ReadJoypad).w
	bsr.w	sub_5E02
	bsr.w	Manage_PlatformLoading
	bsr.w	Execute_ScriptedPlatforms
	bsr.w	Platforms_CheckCollision
	lea	($FFFFF86A).w,a2
	bsr.w	GfxObjects_Collision
	lea	(Addr_GfxObject_KidProjectile).w,a2
	bsr.w	GfxObjects_Collision
	move.b	(Just_received_damage).w,($FFFFFC28).w
	move.b	($FFFFFA75).w,($FFFFFA74).w
	sf	($FFFFFA75).w
	lea	(Addr_GfxObject_KidProjectile).w,a2
	bsr.w	GfxObjects_CollisionKid
	bsr.w	sub_1F52
	bsr.w	sub_219C
	bsr.w	sub_226A
	lea	($FFFFF86A).w,a2
	bsr.w	GfxObjects_CollisionKid
	lea	($FFFFF86E).w,a2
	bsr.w	GfxObjects_CollisionKid
	bsr.w	sub_1D76
	bsr.w	sub_1FA2
	bsr.w	sub_2A4C
	bsr.w	Make_SpritesFromGfxObjects
	tst.b	($FFFFFB49).w
	bne.s	loc_892
	jsr	(j_DiamondPower_CompileSprites).l
	bsr.w	Make_SpritesFromPlatforms

loc_892:
	jsr	(j_sub_30194).l
	jsr	(j_loc_3038A).l
	bsr.w	sub_14C0
	rts

; =============== S U B	R O U T	I N E =======================================


sub_8A4:

	lea	(Player_1_Lives).w,a0
	tst.b	($FFFFFC39).w
	beq.w	loc_8B4
	lea	(Player_2_Lives).w,a0

loc_8B4:
	moveq	#$A,d0
	lea	(Number_Lives).w,a1

loc_8BA:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_8BA
	rts
; End of function sub_8A4


; =============== S U B	R O U T	I N E =======================================


sub_8C2:
	lea	(Player_1_Lives).w,a0
	tst.b	($FFFFFC39).w
	beq.w	loc_8D2
	lea	(Player_2_Lives).w,a0

loc_8D2:
	moveq	#$A,d0
	lea	(Number_Lives).w,a1

loc_8D8:
	move.w	(a1)+,(a0)+
	dbf	d0,loc_8D8
	rts
; End of function sub_8C2


; =============== S U B	R O U T	I N E =======================================


sub_8E0:
	bsr.w	sub_5E02
	bsr.w	Make_SpritesFromGfxObjects
	bsr.w	Make_SpritesFromPlatforms
	bsr.w	WaitForVint
	bsr.w	Transfer_SpriteAndKidToVRAM
	bsr.w	Palette_to_VRAM
	move.b	#4,($FFFFFAD6).w

loc_8FE:
	jsr	(j_Transfer_ScrollDataToVRAM).l
	bsr.w	sub_1596
	jsr	(j_Make_SpriteAttr_HUD).w
	move.b	#1,($FFFFFAD6).w
	rts
; End of function sub_8E0


; =============== S U B	R O U T	I N E =======================================


sub_914:
	addq.b	#1,($FFFFF805).w
	move	#$2700,sr
	jsr	(j_Stop_z80).l
	rts
; End of function sub_914


; =============== S U B	R O U T	I N E =======================================


sub_924:
	subq.b	#1,($FFFFF805).w
	bgt.s	return_938
	clr.b	($FFFFF805).w
	move	#$2500,sr
	jsr	(j_Start_z80).l

return_938:
	rts
; End of function sub_924


; =============== S U B	R O U T	I N E =======================================


WaitForVint:
	sf	(V_Int_Done).w
-
	tst.b	(V_Int_Done).w
	beq.s	-
	tst.b	($FFFFFC80).w
	beq.w	return_954
	move.w	#$4C9,d0

loc_950:
	dbf	d0,loc_950

return_954:
	rts
; End of function WaitForVint


; =============== S U B	R O U T	I N E =======================================

;956
Do_Nothing:
	move.w	d0,-(sp)
	move.w	#$264,d0
-
	dbf	d0,-
	move.w	(sp)+,d0
	rts
; End of function Do_Nothing

; ---------------------------------------------------------------------------

loc_964:

	move.w	4(a6),d6
	btst	#1,d6
	bne.s	loc_964
	rts

; =============== S U B	R O U T	I N E =======================================

;970
Palette_to_VRAM:
	tst.b	(PaletteToDMA_Flag).w
	bne.s	+
	jsr	(j_Stop_z80).l
	dma68kToVDP	Palette_Buffer,$0000,$80,CRAM
	jsr	(j_Start_z80).l
+
	rts

; =============== S U B	R O U T	I N E =======================================

;sub_9AE
Init_RNG:
	lea	(RNG_RAM_Start).w,a0
	lea	RNG_Seed(pc),a1
	moveq	#RNG_RAM_Length-1,d0
-
	move.b	(a1)+,(a0)+
	dbf	d0,-
	move.w	#-RNG_RAM_Length,(RNG_Offset).w
	rts
; End of function Init_RNG

; ---------------------------------------------------------------------------
;unk_9C6
RNG_Seed:
	dc.b $89
	dc.b $72
	dc.b $2D
	dc.b $8D
	dc.b $66
	dc.b $4F
	dc.b $80
	dc.b $62
	dc.b $CA
	dc.b $5D
	dc.b $30
	dc.b $30
	dc.b $9D
	dc.b $9E
	dc.b $21
	dc.b $B8
	dc.b $93
	dc.b $77
	dc.b $7F
	dc.b $E4
	dc.b $2B
	dc.b $BE
	dc.b $8D
	dc.b $9E
	dc.b $56
	dc.b $AA
	dc.b $DD
	dc.b $C2
	dc.b $A8
	dc.b $10
	dc.b $BF
	dc.b   8
	dc.b $B2
	dc.b $9B
	dc.b $8A
	dc.b $CF
	dc.b $AC
	dc.b $64
	dc.b $59
	dc.b  $E
	dc.b $18
	dc.b $4B
	dc.b $C4
	dc.b $F4
	dc.b $89
	dc.b $6C
	dc.b $50
	dc.b $FD
	dc.b $99
	dc.b $5F
	dc.b $92
	dc.b $D8
	dc.b $D0
	dc.b $90
	dc.b $68
	dc.b   0

; =============== S U B	R O U T	I N E =======================================
; Get a random number and write it to d7

;sub_9FE
Get_RandomNumber_byte:
	move.l	a0,-(sp)
	move.l	a1,-(sp)
	lea	(RNG_RAM_End).w,a0
	move.w	(RNG_Offset).w,d7
	addq.w	#1,d7
	bne.s	+
	moveq	#-RNG_RAM_Length,d7
+
	move.w	d7,(RNG_Offset).w
	lea	(a0,d7.w),a1
	addi.w	#$1F,d7
	bcc.s	+
	subi.w	#RNG_RAM_Length,d7
+
	lea	(a0,d7.w),a0
	moveq	#0,d7
	move.b	(a1),d7
	sub.b	(a0),d7
	move.b	d7,(a1)
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	rts
; End of function Get_RandomNumber_byte


; =============== S U B	R O U T	I N E =======================================

;sub_A34
Get_RandomNumber_word:
	jsr	(j_Get_RandomNumber_byte).w
	move.b	d7,(RNG_Buffer).w
	jsr	(j_Get_RandomNumber_byte).w
	move.b	d7,(RNG_Buffer+1).w
	move.w	(RNG_Buffer).w,d7
	rts
; End of function Get_RandomNumber_word


; =============== S U B	R O U T	I N E =======================================

;sub_A4A
Get_RandomNumber_long:
	jsr	(j_Get_RandomNumber_word).w
	move.w	d7,(RNG_Buffer+2).w
	jsr	(j_Get_RandomNumber_word).w
	move.l	(RNG_Buffer).w,d7
	rts
; End of function Get_RandomNumber_long


; =============== S U B	R O U T	I N E =======================================
; DMA sprites and uncompressed Kid art to VRAM
;sub_A5C
Transfer_SpriteAndKidToVRAM:
	move.l	(Addr_NextSpriteSlot).w,d7
	cmpi.l	#$FFFF0000,d7
	beq.w	loc_B42
	move.l	d7,a4
	sf	-5(a4)

loc_A70:
	jsr	(j_Stop_z80).l
	dma68kToVDP	Sprite_Table,$1000,$280,VRAM
	jsr	(j_Start_z80).l
	jsr	(j_Stop_z80).l
	tst.b	($FFFFFB49).w
	bne.w	loc_B36
	move.l	($FFFFF838).w,a0
	move.l	a0,d0
	bne.s	loc_AC2
	lea	($FFFF0500).l,a0

loc_AC2:
	move.w	#0,(a0)
	lea	4(a6),a5
	lea	($FFFF0500).l,a0
	move.w	#$C4A0,d2	; d2 = DMA destination address
				; This is the VRAM address of the Kid

loc_AD4:
	move.w	(a0)+,d0	; d0 = DMA length in tiles
	beq.s	loc_B36
	move.l	(a0)+,d1	; d1 = DMA source address
	lsl.w	#4,d0		; DMA length in words
	move.w	#$9300,d3
	move.b	d0,d3
	move.w	d3,(a5)
	move.w	d0,d3
	lsr.w	#8,d3
	addi.w	#$9400,d3
	move.w	d3,(a5)
	lsr.l	#1,d1
	move.w	#$9500,d3
	move.b	d1,d3
	move.w	d3,(a5)
	move.w	d1,d3
	lsr.w	#8,d3
	addi.w	#$9600,d3
	move.w	d3,(a5)
	move.w	#$9700,d3
	swap	d1
	move.b	d1,d3
	move.w	d3,(a5)
	move.w	d2,d3
	rol.w	#2,d3
	andi.w	#3,d3
	move.w	d2,d4
	andi.w	#$3FFF,d4
	swap	d4
	move.w	d3,d4
	addi.l	#$40000080,d4

loc_B24:
	move.l	d4,($FFFFF800).w
	move.w	($FFFFF800).w,(a5)
	move.w	($FFFFF802).w,(a5)
	add.w	d0,d2
	add.w	d0,d2
	bra.s	loc_AD4
; ---------------------------------------------------------------------------

loc_B36:
	jsr	(j_Start_z80).l
	jsr	(j_sub_B52).w
	rts
; ---------------------------------------------------------------------------

loc_B42:
	clr.l	(Sprite_Table).l
	clr.l	($FFFF0004).l
	bra.w	loc_A70
; End of function Transfer_SpriteAndKidToVRAM


; =============== S U B	R O U T	I N E =======================================


sub_B52:
	clr.b	(Number_Sprites).w
	lea	(Sprite_Table).l,a4
	move.l	a4,(Addr_NextSpriteSlot).w
	lea	($FFFF0500).l,a4
	move.l	a4,($FFFFF838).w
	rts
; End of function sub_B52


; =============== S U B	R O U T	I N E =======================================


ReadJoypad:
	tst.b	(Options_Suboption_2PController).w
	beq.w	loc_B8C
	tst.b	($FFFFFC39).w
	beq.w	loc_B8C
	move.b	(Ctrl_Held).w,(Ctrl_2_Held).w
	move.b	(Ctrl_Pressed).w,(Ctrl_2_Pressed).w
	bra.w	loc_B98
; ---------------------------------------------------------------------------

loc_B8C:
	move.b	(Ctrl_Held).w,(Ctrl_1_Held).w
	move.b	(Ctrl_Pressed).w,(Ctrl_1_Pressed).w

loc_B98:
	tst.w	(word_7190).w
	beq.s	loc_BB6
	tst.b	($FFFFFB49).w
	cmpi.b	#$C0,(Ctrl_1_Held).w
	bne.s	loc_BB6
	cmpi.b	#$10,(Ctrl_2_Held).w
	bne.s	loc_BB6

loc_BB2:
	st	(LevelSkip_Cheat).w

loc_BB6:
	jsr	(j_sub_914).w
	lea	($A10003).l,a0
	bsr.w	Joypad_ReadFromHardware
	bsr.w	Permute_ABCButtons
	move.b	d0,(Ctrl_1).w
	move.b	d0,d2
	lea	($A10005).l,a0
	bsr.w	Joypad_ReadFromHardware
	bsr.w	Permute_ABCButtons
	move.b	d0,(Ctrl_2).w
	jsr	(j_sub_924).w
	tst.b	(Demo_Mode_flag).w
	beq.w	loc_C4E		; held keys new
	move.w	($FFFFFBC2).w,d7
	cmpi.w	#$3F2,d7
	blt.w	loc_C22
	move.w	#0,(Game_Mode).w
	sf	(Demo_Mode_flag).w
	st	($FFFFFBCE).w
	st	($FFFFFC36).w

loc_C0A:
	move.w	#$82A,($FFFFFBCC).w
	clr.w	(Current_LevelID).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
	jmp	loc_6E2(pc)
; ---------------------------------------------------------------------------

loc_C22:
	addq.w	#1,d7
	move.w	d7,($FFFFFBC2).w
	move.l	(Addr_Current_Demo_Keypress).w,a4
	move.b	(a4),d6
	andi.b	#$80,d2
	bclr	#7,d6
	or.b	d2,d6
	move.b	d6,(Ctrl_1).w
	andi.w	#1,d7
	bne.w	loc_C4E		; held keys new
	addq.w	#1,a4
	move.l	a4,(Addr_Current_Demo_Keypress).w
	bra.w	*+4

loc_C4E:
	move.b	(Ctrl_1).w,d0 ; held	keys new
	move.b	(Ctrl_1_Held).w,d1 ; held	keys old
	eor.b	d1,d0		; keys held _either_ old or new
	and.b	(Ctrl_1).w,d0 ; newly pressed keys
	or.b	d0,(Ctrl_1_Pressed).w
	move.b	(Ctrl_1).w,(Ctrl_1_Held).w
	move.b	(Ctrl_2).w,d0
	move.b	(Ctrl_2_Held).w,d1
	eor.b	d1,d0
	and.b	(Ctrl_2).w,d0
	or.b	d0,(Ctrl_2_Pressed).w
	move.b	(Ctrl_2).w,(Ctrl_2_Held).w
	tst.b	(Options_Suboption_2PController).w
	beq.w	loc_C9C
	tst.b	($FFFFFC39).w
	beq.w	loc_C9C
	move.b	(Ctrl_2_Held).w,(Ctrl_Held).w
	move.b	(Ctrl_2_Pressed).w,(Ctrl_Pressed).w
	rts
; ---------------------------------------------------------------------------

loc_C9C:
	move.b	(Ctrl_1_Held).w,(Ctrl_Held).w
	move.b	(Ctrl_1_Pressed).w,(Ctrl_Pressed).w
	rts
; End of function ReadJoypad


; =============== S U B	R O U T	I N E =======================================

;sub_CAA
Joypad_ReadFromHardware:
	move.b	#0,(a0)
	nop
	nop
	move.b	(a0),d0
	lsl.b	#2,d0
	andi.b	#$C0,d0
	move.b	#$40,(a0)
	nop
	nop
	move.b	(a0),d1
	andi.b	#$3F,d1
	or.b	d1,d0
	not.b	d0
	rts
; End of function Joypad_ReadFromHardware


; =============== S U B	R O U T	I N E =======================================

; permute input bits depending on player's input button settings
;sub_CCE
Permute_ABCButtons:
	tst.b	(Demo_Mode_flag).w
	bne.w	return_D7C
	move.w	(Options_Suboption_Controls).w,d7
	beq.w	return_D7C
	subq.w	#1,d7
	add.w	d7,d7
	moveq	#0,d6
	jmp	loc_CE8(pc,d7.w)
; ---------------------------------------------------------------------------
loc_CE8:
	bra.s	loc_CF2
; ---------------------------------------------------------------------------
	bra.s	loc_D0A
; ---------------------------------------------------------------------------
	bra.s	loc_D22
; ---------------------------------------------------------------------------
	bra.s	loc_D44
; ---------------------------------------------------------------------------
	bra.s	loc_D66
; ---------------------------------------------------------------------------

loc_CF2:
	bclr	#4,d0
	beq.s	loc_CFC
	bset	#5,d6

loc_CFC:
	bclr	#5,d0
	beq.s	loc_D7A
	bset	#4,d6
	bra.w	loc_D7A
; ---------------------------------------------------------------------------

loc_D0A:
	bclr	#6,d0
	beq.s	loc_D14
	bset	#4,d6

loc_D14:
	bclr	#4,d0
	beq.s	loc_D7A
	bset	#6,d6
	bra.w	loc_D7A
; ---------------------------------------------------------------------------

loc_D22:
	bclr	#6,d0
	beq.s	loc_D2C
	bset	#4,d6

loc_D2C:
	bclr	#4,d0
	beq.s	loc_D36
	bset	#5,d6

loc_D36:
	bclr	#5,d0
	beq.s	loc_D7A
	bset	#6,d6
	bra.w	loc_D7A
; ---------------------------------------------------------------------------

loc_D44:
	bclr	#6,d0
	beq.s	loc_D4E
	bset	#5,d6

loc_D4E:
	bclr	#4,d0
	beq.s	loc_D58
	bset	#6,d6

loc_D58:
	bclr	#5,d0
	beq.s	loc_D7A
	bset	#4,d6
	bra.w	loc_D7A
; ---------------------------------------------------------------------------

loc_D66:
	bclr	#6,d0
	beq.s	loc_D70
	bset	#5,d6

loc_D70:
	bclr	#5,d0
	beq.s	loc_D7A
	bset	#6,d6

loc_D7A:
	or.b	d6,d0

return_D7C:
	rts
; End of function Permute_ABCButtons


; =============== S U B	R O U T	I N E =======================================

; initialize empty objects at FF0DA0 (Object_RAM)
;sub_D7E
Initialize_ObjectSlots:
	lea	(Object_RAM).l,a0
	move.l	a0,(Addr_NextFreeObjectSlot).w
	moveq	#$30,d0

-
	lea	$74(a0),a1
	_move.l	a1,0(a0)
	move.l	a1,a0
	dbf	d0,-
	_clr.l	0(a0)
	lea	(Addr_FirstObjectSlot).w,a0
	clr.l	(a0)
	move.l	a0,(Addr_CurrentObject).w
	clr.w	(Number_Objects).w
	rts
; End of function Initialize_ObjectSlots


; =============== S U B	R O U T	I N E =======================================

; allocate next empty object slot to new object
;sub_DAC
Allocate_ObjectSlot:
	movem.l	d4-d6/a1,-(sp)
	move.w	a0,d6
	move.l	(Addr_NextFreeObjectSlot).w,a0
	_move.l	0(a0),(Addr_NextFreeObjectSlot).w
	move.l	a0,a1

	; clear object data
	moveq	#0,d5
	move.w	#$1C,d4
-	move.l	d5,(a1)+
	dbf	d4,-

	move.w	#1,8(a0)
	addq.w	#1,(Number_Objects).w
	move.l	a5,$A(a0)
	lea	(Addr_FirstObjectSlot).w,a1
	move.w	d6,$E(a0)

loc_DE0:
	_move.l	0(a1),d4
	beq.s	loc_DF2
	move.l	a1,d5
	move.l	d4,a1
	cmp.w	$E(a1),d6
	bhi.s	loc_DE0
	move.l	d5,a1

loc_DF2:
	_move.l	0(a1),0(a0)
	_move.l	a0,0(a1)
	movem.l	(sp)+,d4-d6/a1
	rts
; End of function Allocate_ObjectSlot


; =============== S U B	R O U T	I N E =======================================


sub_E02:
	bsr.s	Allocate_ObjectSlot
	bsr.w	Allocate_GfxObjectSlot_a1
	move.l	a0,$C(a1)

loc_E0C:
	move.l	a1,$36(a0)
	rts
; End of function sub_E02


; =============== S U B	R O U T	I N E =======================================

;sub_E12
Execute_Objects:
	jsr	(j_Get_RandomNumber_long).w
	move.l	sp,($FFFFF84C).w	; save address where this was called from
	lea	(Addr_FirstObjectSlot).w,a5	; address of first object

loc_E1E:
	move.l	(a5),d0	; get address of next object
	beq.s	loc_E58	; if 0, quit executing objects, we're done
	move.l	d0,a5	; a5 is now address of object
	tst.b	(SamuraiHazeActive).w
	beq.w	loc_E3E
	tst.b	$10(a5)
	beq.w	loc_E3E
	move.w	(Time_Frames).w,d0
	andi.w	#3,d0
	bne.s	loc_E1E

loc_E3E:
	subq.w	#1,8(a5)	; decrement hibernation counter
	bne.s	loc_E1E		; if not 0, don't execute object
	; execute this object
	move.l	a5,(Addr_CurrentObject).w
	movem.l	$16(a5),d0-d3/a0-a3	; unpack object status into registers
	move.l	($FFFFF84C).w,sp
	; the next two lines are equivalent to jmp 4(a5)
	move.l	4(a5),-(sp)	; put code address onto stack
	rts	; go to that address
; ---------------------------------------------------------------------------

loc_E58:
	move.l	($FFFFF84C).w,sp	; load address where this was called from
	rts	; go back to there

; =============== S U B	R O U T	I N E =======================================

; Hibernate Object
; Before calling this routine, put hibernation time (word) onto stack.
; remember position in code, counter, variables, and stop executing object
;sub_E5E
Hibernate_Object:	
	move.l	(Addr_CurrentObject).w,a5
	move.l	(sp)+,4(a5)	; address where this was called from is address where to continue executing next time
	move.w	(sp)+,8(a5)	; save hibernation counter from stack
	movem.l	d0-d3/a0-a3,$16(a5)	; pack object status from registers
	move.l	($FFFFF84C).w,sp
	bra.s	loc_E1E
; End of function Hibernate_Object

; =============== S U B	R O U T	I N E =======================================

; same as Hibernate_Object, but hibernation time is set to 1 frame
; automatically and doesn't need to be written onto stack.

;sub_E76
Hibernate_Object_1Frame:
	move.l	(Addr_CurrentObject).w,a5
	move.l	(sp)+,4(a5)
	move.w	#1,8(a5)
	movem.l	d0-d3/a0-a3,$16(a5)
	move.l	($FFFFF84C).w,sp
	bra.s	loc_E1E
; End of function Hibernate_Object_1Frame

; =============== S U B	R O U T	I N E =======================================

; a0 is address of object to be deleted
Delete_Object_a0:
	move.l	a5,-(sp)
	move.l	a0,a5
	bsr.s	Deallocate_ObjectSlot
	move.l	(sp)+,a5
	rts
; End of function Delete_Object_a0


; =============== S U B	R O U T	I N E =======================================

; a5 is address of object to be deleted (i.e. current object)
;sub_E9A
Deallocate_ObjectSlot:
	movem.l	d0/a0/a3,-(sp)
	lea	(Addr_FirstObjectSlot).w,a0

	; find our current object in the list
loc_EA2:
	_move.l	0(a0),d0	; d0 = next object in list
	beq.s	loc_EF0
	cmp.l	d0,a5	; have we found our object?
	beq.s	loc_EB0	; yes
	move.l	d0,a0	; next one in list
	bra.s	loc_EA2
; ---------------------------------------------------------------------------
; remove current object from list
; a0 is the object in the list before a5 (current object)
loc_EB0:
	_move.l	0(a5),0(a0)
	_move.l	(Addr_NextFreeObjectSlot).w,0(a5)
	move.l	a5,(Addr_NextFreeObjectSlot).w
	subq.w	#1,(Number_Objects).w
	move.l	$36(a5),d0
	beq.s	+
	move.l	d0,a3
	bsr.w	Deallocate_GfxObject
+
	move.l	$3A(a5),d0
	beq.s	+
	move.l	d0,a3
	bsr.w	Deallocate_GfxObject
+
	move.l	$3E(a5),d0
	beq.s	+
	move.l	d0,a3
	bsr.w	Deallocate_GfxObject
+
	move.l	a0,a5
	movem.l	(sp)+,d0/a0/a3
	rts
; ---------------------------------------------------------------------------

loc_EF0:
	move.l	(Addr_CurrentObject).w,a5
	movem.l	(sp)+,d0/a0/a3
	rts
; End of function Deallocate_ObjectSlot


; =============== S U B	R O U T	I N E =======================================

;sub_EFA
Delete_AllButCurrentObject:
	movem.l	d0/a0/a5,-(sp)

loc_EFE:
	lea	(Addr_FirstObjectSlot).w,a5

loc_F02:
	_move.l	0(a5),d0
	beq.s	loc_F14
	move.l	d0,a5
	cmp.l	(Addr_CurrentObject).w,a5
	beq.s	loc_F02
	bsr.s	Deallocate_ObjectSlot
	bra.s	loc_F02
; ---------------------------------------------------------------------------

loc_F14:
	movem.l	(sp)+,d0/a0/a5
	rts
; End of function Delete_AllButCurrentObject


; =============== S U B	R O U T	I N E =======================================

;sub_F1A
Delete_CurrentObject:
	move.l	(Addr_CurrentObject).w,a5
	bsr.w	Deallocate_ObjectSlot
	bra.w	loc_E1E
; End of function Delete_CurrentObject


; =============== S U B	R O U T	I N E =======================================

;sub_F26
Initialize_GfxObjectSlots:
	lea	(GfxObject_RAM).l,a0
	move.l	a0,(Addr_NextFreeGfxObjectSlot).w
	moveq	#$4B,d0
-
	lea	$4C(a0),a1
	_move.l	a1,0(a0)
	move.l	a1,a0
	dbf	d0,-
	_clr.l	0(a0)
	clr.l	(Addr_FirstGfxObjectSlot).w
	clr.w	(Number_GfxObjects).w
	clr.l	(Addr_GfxObject_KidProjectile).w
	clr.l	($FFFFF86A).w
	clr.l	($FFFFF86E).w
	clr.l	($FFFFF872).w
	rts
; End of function Initialize_GfxObjectSlots


; =============== S U B	R O U T	I N E =======================================

; allocates a gfx object slot for the current object.
;sub_F5E
Load_GfxObjectSlot:
	bsr.s	Allocate_GfxObjectSlot
	move.l	a3,$36(a5)
	rts
; End of function Load_GfxObjectSlot


; =============== S U B	R O U T	I N E =======================================

;sub_F66
Allocate_GfxObjectSlot_a1:
	exg	a1,a3
	bsr.s	Allocate_GfxObjectSlot
	exg	a1,a3
	rts
; End of function Allocate_GfxObjectSlot_a1


; =============== S U B	R O U T	I N E =======================================

;sub_F6E
Allocate_GfxObjectSlot:
	movem.l	d4-d6/a4,-(sp)
	move.l	a3,d5
	move.l	(Addr_NextFreeGfxObjectSlot).w,a3	; get next available object slot
	_move.l	0(a3),(Addr_NextFreeGfxObjectSlot).w	; next object in the list is available
	move.l	a3,a4

	; clear the data from the object slot
	moveq	#0,d6
	move.w	#$12,d4
-	move.l	d6,(a4)+
	dbf	d4,-

	move.w	d5,8(a3)
	beq.s	loc_FBE
	subq.w	#1,d5
	bne.s	loc_F9C
	lea	(Addr_GfxObject_KidProjectile).w,a4
	bra.s	loc_FB8
; ---------------------------------------------------------------------------

loc_F9C:
	subq.w	#1,d5
	bne.s	loc_FA6
	lea	($FFFFF86A).w,a4
	bra.s	loc_FB8
; ---------------------------------------------------------------------------

loc_FA6:
	subq.w	#1,d5
	bne.s	loc_FB0
	lea	($FFFFF86E).w,a4
	bra.s	loc_FB8
; ---------------------------------------------------------------------------

loc_FB0:
	subq.w	#1,d5
	bne.s	loc_FBE
	lea	($FFFFF872).w,a4

loc_FB8:
	move.l	(a4),4(a3)
	move.l	a3,(a4)

loc_FBE:
	swap	d5
	move.w	d5,$A(a3)
	addq.w	#1,(Number_GfxObjects).w
	move.l	a5,$C(a3)
	lea	(Addr_FirstGfxObjectSlot).w,a4
	move.w	$A(a3),d5

loc_FD4:
	_move.l	0(a4),d4
	beq.s	loc_FE6
	move.l	a4,d6
	move.l	d4,a4
	cmp.w	$A(a4),d5
	bls.s	loc_FD4
	move.l	d6,a4

loc_FE6:
	_move.l	0(a4),0(a3)
	_move.l	a3,0(a4)
	movem.l	(sp)+,d4-d6/a4
	rts
; End of function Allocate_GfxObjectSlot


; =============== S U B	R O U T	I N E =======================================


sub_FF6:
	movem.l	d4-d6/a4,-(sp)
	lea	(Addr_FirstGfxObjectSlot).w,a4

loc_FFE:
	_cmp.l	0(a4),a3
	beq.s	loc_100E

loc_1004:
	_move.l	0(a4),d4
	beq.s	loc_1038
	move.l	d4,a4
	bra.s	loc_FFE
; ---------------------------------------------------------------------------

loc_100E:
	_move.l	0(a3),0(a4)
	lea	(Addr_FirstGfxObjectSlot).w,a4
	move.w	$A(a3),d5

loc_101C:
	_move.l	0(a4),d4
	beq.s	loc_102E
	move.l	a4,d6
	move.l	d4,a4
	cmp.w	$A(a4),d5
	bls.s	loc_101C
	move.l	d6,a4

loc_102E:
	_move.l	0(a4),0(a3)
	_move.l	a3,0(a4)

loc_1038:
	movem.l	(sp)+,d4-d6/a4
	rts
; End of function sub_FF6


; =============== S U B	R O U T	I N E =======================================


nullsub_2:
	rts
; End of function nullsub_2


; =============== S U B	R O U T	I N E =======================================

;sub_1040
Init_Animation:
	move.l	d7,$2E(a3)
	move.w	#1,animation_timer(a3)
	st	is_animated(a3)
	sf	$18(a3)
	exg	d7,a0
	move.w	2(a0),addroffset_sprite(a3)
	exg	d7,a0
	rts
; End of function Init_Animation


; =============== S U B	R O U T	I N E =======================================


sub_105E:
	move.l	(sp)+,$12(a5)

loc_1062:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$18(a3)
	beq.s	loc_1062
	move.l	$12(a5),-(sp)
	rts
; End of function sub_105E


; =============== S U B	R O U T	I N E =======================================

;sub_1072
Deallocate_GfxObject:
	movem.l	d0/a0,-(sp)
	bra.s	loc_10B6
; ---------------------------------------------------------------------------

loc_1078:
	movem.l	d0/a0,-(sp)
	move.l	a5,d0
	btst	#0,d0
	bne.s	loc_10B6
	andi.l	#$FFFFFF,d0
	cmpi.l	#$FF0000,d0
	blt.s	loc_10B6
	move.l	d0,a5
	cmp.l	$36(a5),a3
	bne.s	loc_10A0
	clr.l	$36(a5)
	bra.s	loc_10B6
; ---------------------------------------------------------------------------

loc_10A0:
	cmp.l	$3A(a5),a3
	bne.s	loc_10AC
	clr.l	$3A(a5)
	bra.s	loc_10B6
; ---------------------------------------------------------------------------

loc_10AC:
	cmp.l	$3E(a5),a3
	bne.s	loc_10B6
	clr.l	$3E(a5)

loc_10B6:
	lea	(Addr_FirstGfxObjectSlot).w,a0

loc_10BA:
	move.l	(a0),d0
	beq.s	loc_111A
	cmp.l	d0,a3
	beq.s	loc_10C6
	move.l	d0,a0
	bra.s	loc_10BA
; ---------------------------------------------------------------------------

loc_10C6:
	_move.l	0(a3),0(a0)
	_move.l	(Addr_NextFreeGfxObjectSlot).w,0(a3)
	move.l	a3,(Addr_NextFreeGfxObjectSlot).w
	subq.w	#1,(Number_GfxObjects).w
	move.w	8(a3),d0
	beq.s	loc_111A
	subq.w	#1,d0
	bne.s	loc_10EA
	lea	($FFFFF862).w,a0
	bra.s	loc_1106
; ---------------------------------------------------------------------------

loc_10EA:
	subq.w	#1,d0
	bne.s	loc_10F4
	lea	(Addr_GfxObject_KidProjectile).w,a0
	bra.s	loc_1106
; ---------------------------------------------------------------------------

loc_10F4:
	subq.w	#1,d0
	bne.s	loc_10FE
	lea	($FFFFF86A).w,a0
	bra.s	loc_1106
; ---------------------------------------------------------------------------

loc_10FE:
	subq.w	#1,d0
	bne.s	loc_111A
	lea	($FFFFF86E).w,a0

loc_1106:
	move.l	4(a0),d0
	beq.s	loc_111A
	cmp.l	d0,a3
	beq.s	loc_1114
	move.l	d0,a0
	bra.s	loc_1106
; ---------------------------------------------------------------------------

loc_1114:
	move.l	4(a3),4(a0)

loc_111A:
	movem.l	(sp)+,d0/a0
	rts
; End of function Deallocate_GfxObject


; =============== S U B	R O U T	I N E =======================================

; adds velocity to position
;sub_1120
GfxObject_Move:
	tst.b	($FFFFF80B).w
	bne.s	return_113C
	tst.b	is_moved(a3)
	beq.s	return_113C
	move.l	x_vel(a3),d0
	add.l	d0,x_pos(a3)
	move.l	y_vel(a3),d0
	add.l	d0,y_pos(a3)

return_113C:
	rts
; End of function GfxObject_Move


; =============== S U B	R O U T	I N E =======================================

; process animation of object, e.g. whether to go to next animation, etc
;sub_113E
GfxObject_Animate:
	move.l	a2,-(sp)
	tst.b	($FFFFF80B).w
	bne.w	loc_1172
	tst.b	is_animated(a3)
	beq.s	loc_1172
	move.l	$2E(a3),a2
	subq.w	#1,animation_timer(a3)
	bne.s	loc_1166

loc_1158:
	moveq	#0,d7
	move.b	(a2)+,d7
	add.w	d7,d7
	add.w	d7,d7
	move.l	off_1176(pc,d7.w),-(sp)
	rts
; ---------------------------------------------------------------------------

loc_1166:
	cmpi.w	#1,animation_timer(a3)
	bne.s	loc_1172
	tst.b	(a2)
	beq.s	loc_1182

loc_1172:
	move.l	(sp)+,a2
	rts
; ---------------------------------------------------------------------------
off_1176:
	dc.l loc_1182	; stop animation
	dc.l sub_1194	; animate normally
	dc.l sub_11AC	; go back XX bytes in animation list
; ---------------------------------------------------------------------------

loc_1182:
	st	$18(a3)
	sf	is_animated(a3)
	move.w	#1,animation_timer(a3)
	move.l	(sp)+,a2
	rts
; End of function GfxObject_Animate


; =============== S U B	R O U T	I N E =======================================


sub_1194:
	moveq	#0,d7
	move.b	(a2)+,d7
	move.w	d7,animation_timer(a3)
	move.w	(a2)+,d7
	move.w	d7,addroffset_sprite(a3)
	jsr	(j_nullsub_2).w
	move.l	a2,$2E(a3)
	bra.s	loc_1166
; End of function sub_1194


; =============== S U B	R O U T	I N E =======================================


sub_11AC:
	move.b	(a2),d7
	ext.w	d7
	ext.l	d7
	suba.l	d7,a2
	bra.s	loc_1158
; End of function sub_11AC


; =============== S U B	R O U T	I N E =======================================

;sub_11B6
Make_SpriteFromGfxObject:
	st	$19(a3)
	tst.b	$13(a3)
	beq.w	return_129C
	lea	(Data_Index).l,a4
	move.w	addroffset_sprite(a3),d7
	move.l	(a4,d7.w),d7
	beq.w	return_129C
	move.l	d7,a4
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	tst.b	$12(a3)
	bne.s	loc_11EA
	move.w	6(a4),d6
	bra.s	loc_11EE
; ---------------------------------------------------------------------------

loc_11EA:
	move.w	4(a4),d6

loc_11EE:
	sub.w	d6,d7
	cmpi.w	#$160,d7
	bgt.w	return_129C
	cmpi.w	#$FF80,d7
	blt.w	return_129C
	move.w	x_pos(a3),d6
	sub.w	(Camera_X_pos).w,d6
	cmpi.w	#$160,d6
	bgt.w	return_129C
	cmpi.w	#$FFC0,d6
	blt.w	return_129C
	sf	$19(a3)
	moveq	#0,d0
	move.b	palette_line(a3),d0
	ror.w	#3,d0
	cmpi.b	#1,priority(a3)
	bcs.s	loc_1238
	beq.s	loc_1234
	tst.b	($FFFFF896).w
	beq.s	loc_1238

loc_1234:
	ori.w	#$8000,d0

loc_1238:
	tst.b	$12(a3)
	bne.s	loc_1246
	add.w	(a4)+,d0
	add.w	vram_tile(a3),d0
	bra.s	loc_124A
; ---------------------------------------------------------------------------

loc_1246:
	add.w	($FFFFF83C).w,d0

loc_124A:
	move.w	d0,($FFFFF830).w
	tst.b	$17(a3)
	beq.w	loc_1292
	bset	#4,($FFFFF830).w
	cmp.l	(Addr_GfxObject_Kid).w,a3
	bne.w	loc_1286
	move.w	addroffset_sprite(a3),d1
	subi.w	#LnkTo_unk_A978A-Data_Index,d1	; Skycutter frames
	asr.w	#1,d1
	sub.w	unk_1276(pc,d1.w),d7
	bra.w	loc_1292
; ---------------------------------------------------------------------------
unk_1276:
	dc.w   0
	dc.w   2
	dc.w   2
	dc.w   4
	dc.w   2
	dc.w   0
	dc.w   2
	dc.w  $D
; ---------------------------------------------------------------------------

loc_1286:
	cmpi.w	#(LnkTo_unk_A59AA-Data_Index),addroffset_sprite(a3)
	bne.w	loc_1292
	subq.w	#6,d7

loc_1292:
	tst.b	x_direction(a3)
	bne.w	loc_132A
	bra.s	loc_129E
; ---------------------------------------------------------------------------

return_129C:
	rts
; ---------------------------------------------------------------------------
; sprite in normal orientation (not x-flipped)
loc_129E:
	move.b	(a4)+,d0
	ext.w	d0
	sub.w	d0,d6
	addi.w	#$80,d6
	move.b	(a4)+,d0
	ext.w	d0
	add.w	d0,d7
	addi.w	#$80,d7
	move.w	(a4)+,d4
	move.w	(a4)+,d5
	moveq	#$20,d1

loc_12B8:
	cmp.w	d1,d5
	blt.s	loc_12EC
	move.w	d6,d3
	move.w	d4,d2

loc_12C0:
	cmp.w	d1,d2
	blt.s	loc_12D0
	moveq	#$F,d0
	bsr.w	sub_13C0
	sub.w	d1,d2
	add.w	d1,d3
	bra.s	loc_12C0
; ---------------------------------------------------------------------------

loc_12D0:
	addq.w	#7,d2
	andi.w	#$F8,d2
	beq.s	loc_12E6
	move.w	d2,d0
	subq.w	#8,d0
	lsr.w	#1,d0
	ori.w	#3,d0
	bsr.w	sub_13C0

loc_12E6:
	sub.w	d1,d5
	add.w	d1,d7
	bra.s	loc_12B8
; ---------------------------------------------------------------------------

loc_12EC:
	addq.w	#7,d5
	andi.w	#$F8,d5
	beq.s	return_1328

loc_12F4:
	cmp.w	d1,d4
	blt.s	loc_130E
	move.w	d5,d0
	subq.w	#8,d0
	lsr.w	#3,d0
	ori.w	#$C,d0
	move.w	d6,d3
	bsr.w	sub_13C0
	sub.w	d1,d4
	add.w	d1,d6
	bra.s	loc_12F4
; ---------------------------------------------------------------------------

loc_130E:
	addq.w	#7,d4
	andi.w	#$F8,d4
	beq.s	return_1328
	move.w	d6,d3
	move.w	d4,d0
	subq.w	#8,d0
	lsr.w	#1,d0
	subq.w	#8,d5
	lsr.w	#3,d5
	or.w	d5,d0
	bsr.w	sub_13C0

return_1328:
	rts
; ---------------------------------------------------------------------------
; x-flipped sprite
loc_132A:
	bset	#3,($FFFFF830).w
	move.b	(a4)+,d0
	ext.w	d0
	add.w	d0,d6
	addi.w	#$80,d6
	move.b	(a4)+,d1
	ext.w	d1
	add.w	d1,d7
	addi.w	#$80,d7
	move.w	(a4)+,d4
	move.w	(a4)+,d5
	moveq	#$20,d1

loc_134A:
	cmp.w	d1,d5
	blt.s	loc_1380
	move.w	d6,d3
	move.w	d4,d2

loc_1352:
	cmp.w	d1,d2
	blt.s	loc_1362
	sub.w	d1,d3
	moveq	#$F,d0
	bsr.w	sub_13C0
	sub.w	d1,d2
	bra.s	loc_1352
; ---------------------------------------------------------------------------

loc_1362:
	addq.w	#7,d2
	andi.w	#$F8,d2
	beq.s	loc_137A
	sub.w	d2,d3
	move.w	d2,d0
	subq.w	#8,d0
	lsr.w	#1,d0
	ori.w	#3,d0
	bsr.w	sub_13C0

loc_137A:
	sub.w	d1,d5
	add.w	d1,d7
	bra.s	loc_134A
; ---------------------------------------------------------------------------

loc_1380:
	addq.w	#7,d5
	andi.w	#$F8,d5
	beq.s	return_13BE

loc_1388:
	cmp.w	d1,d4
	blt.s	loc_13A2
	sub.w	d1,d6
	move.w	d5,d0
	subq.w	#8,d0
	lsr.w	#3,d0
	ori.w	#$C,d0
	move.w	d6,d3
	bsr.w	sub_13C0
	sub.w	d1,d4
	bra.s	loc_1388
; ---------------------------------------------------------------------------

loc_13A2:
	addq.w	#7,d4
	andi.w	#$F8,d4
	beq.s	return_13BE
	sub.w	d4,d6
	move.w	d6,d3
	move.w	d4,d0
	subq.w	#8,d0
	lsr.w	#1,d0
	subq.w	#8,d5
	lsr.w	#3,d5
	or.w	d5,d0
	bsr.w	sub_13C0

return_13BE:
	rts
; End of function Make_SpriteFromGfxObject


; =============== S U B	R O U T	I N E =======================================


sub_13C0:
	move.w	d3,6(a0)
	_move.w	d7,0(a0)
	move.b	d0,2(a0)
	addq.b	#1,(Number_Sprites).w
	move.b	(Number_Sprites).w,3(a0)
	tst.b	$12(a3)
	bne.s	loc_141A
	move.w	($FFFFF830).w,4(a0)
	moveq	#0,d0
	move.b	2(a0),d0
	add.w	d0,d0
	move.w	NumberTilesPerSpriteSize(pc,d0.w),d0
	addq.w	#1,d0
	add.w	d0,($FFFFF830).w
	lea	8(a0),a0
	rts
; ---------------------------------------------------------------------------
	; number of tiles taken by each of the 16 different sprite sizes
;unk_13FA:
NumberTilesPerSpriteSize:
	dc.w   0
	dc.w   1
	dc.w   2
	dc.w   3
	dc.w   1
	dc.w   3
	dc.w   5
	dc.w   7
	dc.w   2
	dc.w   5
	dc.w   8
	dc.w  $B
	dc.w   3
	dc.w   7
	dc.w  $B
	dc.w  $F
; ---------------------------------------------------------------------------

loc_141A:
	move.w	($FFFFF830).w,4(a0)
	moveq	#0,d0
	move.b	2(a0),d0
	add.w	d0,d0
	move.w	NumberTilesPerSpriteSize(pc,d0.w),d0
	addq.w	#1,d0
	add.w	d0,($FFFFF830).w
	add.w	d0,($FFFFF83C).w
	; add length and start address to DMA queue
	move.w	d0,(a1)+
	move.l	a4,(a1)+
	lsl.w	#5,d0
	add.w	d0,a4	; end of art to be DMA'd
	lea	8(a0),a0	; next slot in sprite table
	rts
; End of function sub_13C0


; =============== S U B	R O U T	I N E =======================================

;sub_1444
GfxObjects_MoveAndAnimate:
	tst.b	(SamuraiHazeActive).w
	bne.s	loc_1462
	lea	(Addr_FirstGfxObjectSlot).w,a3

loc_144E:
	_move.l	0(a3),d0
	beq.s	return_1460
	move.l	d0,a3
	bsr.w	GfxObject_Move
	bsr.w	GfxObject_Animate
	bra.s	loc_144E
; ---------------------------------------------------------------------------

return_1460:
	rts
; ---------------------------------------------------------------------------

loc_1462:
	lea	(Addr_FirstGfxObjectSlot).w,a3

loc_1466:
	_move.l	0(a3),d0
	beq.s	return_1460
	move.l	d0,a3
	cmpi.w	#2,8(a3)
	beq.s	loc_147E
	cmpi.w	#3,8(a3)
	bne.s	loc_1488

loc_147E:
	move.w	(Time_Frames).w,d0
	andi.w	#3,d0
	bne.s	loc_1466

loc_1488:
	bsr.w	GfxObject_Move
	bsr.w	GfxObject_Animate
	bra.s	loc_1466
; End of function GfxObjects_MoveAndAnimate


; =============== S U B	R O U T	I N E =======================================

;sub_1492
Make_SpritesFromGfxObjects:
	move.l	(Addr_NextSpriteSlot).w,a0
	move.l	($FFFFF838).w,a1
	move.w	#$625,($FFFFF83C).w
	lea	(Addr_FirstGfxObjectSlot).w,a3

loc_14A4:
	_move.l	0(a3),d0
	beq.s	loc_14B2
	move.l	d0,a3
	jsr	(j_Make_SpriteFromGfxObject).w
	bra.s	loc_14A4
; ---------------------------------------------------------------------------

loc_14B2:
	move.l	a0,(Addr_NextSpriteSlot).w
	move.l	a1,($FFFFF838).w
	move.w	#0,(a1)
	rts
; End of function Make_SpritesFromGfxObjects


; =============== S U B	R O U T	I N E =======================================


sub_14C0:
	move.l	($FFFFF888).w,d7
	move.l	($FFFFF88C).w,d6
	or.l	d7,d6
	bne.s	loc_14CE
	rts
; ---------------------------------------------------------------------------

loc_14CE:
	move.l	#$100,d0
	sub.w	($FFFFF876).w,d0
	ror.l	#4,d0
	swap	d0
	move.l	d0,d1
	ror.l	#3,d1
	addi.l	#$8000,d0
	lea	($FFFFF878).w,a0
	move.l	a0,a3
	moveq	#$E,d2

loc_14EE:
	sub.l	d1,d0
	swap	d0
	move.b	d0,(a0)+
	swap	d0
	dbf	d2,loc_14EE
	moveq	#$F,d4
	lea	($FFFF4ED8).l,a0
	lea	($FFFF4F58).l,a1
	lea	(Palette_Buffer).l,a2
	tst.l	d7
	beq.s	loc_1518
	clr.l	($FFFFF888).w
	bsr.s	sub_1536

loc_1518:
	lea	($FFFF4F18).l,a0
	lea	($FFFF4F98).l,a1
	lea	(Palette_Buffer+$40).l,a2
	lea	($FFFFF88C).w,a4
	move.l	(a4),d7
	bne.s	loc_1534
	rts
; ---------------------------------------------------------------------------

loc_1534:
	clr.l	(a4)
; End of function sub_14C0


; =============== S U B	R O U T	I N E =======================================


sub_1536:
	moveq	#$1F,d6

loc_1538:
	move.w	(a0)+,d0
	move.w	(a1)+,d1
	andi.w	#$EEE,d0
	andi.w	#$EEE,d1
	btst	d6,d7
	beq.s	loc_158E
	move.w	d0,d2
	and.w	d4,d2
	move.w	d1,d3
	and.w	d4,d3
	sub.w	d2,d3
	asr.w	#1,d3
	sub.b	7(a3,d3.w),d2
	moveq	#0,d5
	move.b	d2,d5
	lsr.w	#4,d0
	move.w	d0,d2
	and.w	d4,d2
	lsr.w	#4,d1
	move.w	d1,d3
	and.w	d4,d3
	sub.w	d2,d3
	asr.w	#1,d3
	sub.b	7(a3,d3.w),d2
	ror.w	#4,d5
	or.b	d2,d5
	lsr.w	#4,d0
	lsr.w	#4,d1
	sub.w	d0,d1
	asr.w	#1,d1
	sub.b	7(a3,d1.w),d0
	ror.w	#4,d5
	or.b	d0,d5
	ror.w	#8,d5
	move.w	d5,(a2)+
	dbf	d6,loc_1538
	rts
; ---------------------------------------------------------------------------

loc_158E:
	addq.w	#2,a2
	dbf	d6,loc_1538
	rts
; End of function sub_1536


; =============== S U B	R O U T	I N E =======================================


sub_1596:
	lea	4(a6),a5
	move.l	($FFFFF8B2).w,d0
	beq.s	loc_15D2
	move.l	d0,a0
	move.w	#$FFFF,(a0)
	moveq	#0,d1
	move.w	#$4000,d2
	move.w	#$80,d3
	lea	($FFFF43BC).l,a0
	bra.s	loc_15C8
; ---------------------------------------------------------------------------

loc_15B8:
	or.w	d2,d0
	move.w	d0,(a5)
	move.w	d1,(a5)
	move.l	(a0)+,(a6)
	add.w	d3,d0
	move.w	d0,(a5)
	move.w	d1,(a5)
	move.l	(a0)+,(a6)

loc_15C8:
	move.w	(a0)+,d0
	bpl.s	loc_15B8
	moveq	#0,d0
	move.l	d0,($FFFFF8B2).w

loc_15D2:
	move.l	($FFFFF8B6).w,d0
	beq.w	loc_1686
	cmpi.w	#$47A6,d0
	beq.w	loc_1686
	move.l	d0,a0
	move.w	#$FFFF,(a0)
	lea	($FFFF47A6).l,a0
	move.l	(Addr_ThemeMappings).w,a1
	lea	(Block_Mappings).l,a2
	move.w	(Camera_X_pos).w,d4
	lsr.w	#4,d4
	move.w	d4,d6
	addi.w	#$14,d6
	move.w	(Camera_Y_pos).w,d5
	lsr.w	#4,d5
	move.w	d5,d7
	addi.w	#$E,d7
	moveq	#0,d3
	move.w	(a0)+,d0

loc_1614:
	move.w	(a0)+,d1
	cmp.w	d4,d0
	blt.s	loc_167A
	cmp.w	d6,d0
	bgt.s	loc_167A
	cmp.w	d5,d1
	blt.s	loc_167A
	cmp.w	d7,d1
	bgt.s	loc_167A
	add.w	d0,d0
	add.w	d0,d0
	andi.w	#$7C,d0
	lsl.w	#8,d1
	andi.w	#$F00,d1
	add.w	d0,d1
	ori.w	#$4000,d1
	move.w	d1,(a5)
	move.w	d3,(a5)
	move.w	(a0)+,d0
	bmi.s	loc_165E
	andi.w	#$FF,d0
	lsl.w	#3,d0
	move.l	(a1,d0.w),(a6)
	addi.w	#$80,d1
	move.w	d1,(a5)
	move.w	d3,(a5)
	move.l	4(a1,d0.w),(a6)
	move.w	(a0)+,d0
	bpl.s	loc_1614
	bra.s	loc_1680
; ---------------------------------------------------------------------------

loc_165E:
	andi.w	#$FF,d0
	lsl.w	#3,d0
	move.l	(a2,d0.w),(a6)
	addi.w	#$80,d1
	move.w	d1,(a5)
	move.w	d3,(a5)
	move.l	4(a2,d0.w),(a6)
	move.w	(a0)+,d0
	bpl.s	loc_1614
	bra.s	loc_1680
; ---------------------------------------------------------------------------

loc_167A:
	addq.w	#2,a0
	move.w	(a0)+,d0
	bpl.s	loc_1614

loc_1680:
	moveq	#0,d0
	move.l	d0,($FFFFF8B6).w

loc_1686:
	move.l	#$FFFF43BC,($FFFFF8B2).w
	move.l	#$FFFF47A6,($FFFFF8B6).w
	rts
; End of function sub_1596

; ---------------------------------------------------------------------------

loc_1698:
	movem.l	d0/a0,-(sp)
	jsr	(j_sub_914).w
	move.l	4(a6),d0
	move.l	#$FE0000,a0
	move.w	#$3F,d0
	move.l	#$20,4(a6)

loc_16B6:
	move.w	(a6),(a0)+
	dbf	d0,loc_16B6
	move.w	#$27,d0
	move.l	#$2625A0A,4(a6)

loc_16C8:
	move.w	(a6),(a0)+
	dbf	d0,loc_16C8
	move.l	#$FD0000,a0
	move.w	#$7FFF,d0
	move.l	#0,4(a6)

loc_16E0:
	move.w	(a6),(a0)+
	dbf	d0,loc_16E0
	jsr	(j_sub_924).w
	movem.l	(sp)+,d0/a0
	rts

; =============== S U B	R O U T	I N E =======================================

; Collide GfxObject(s) in a2 with terrain?
;sub_16F0:
GfxObjects_Collision:
	movem.l	d0-a6,-(sp)
	subq.w	#4,sp
	lea	($FFFF4A04).l,a0

;loc_16FC
GfxObjects_Collision_Loop:
	move.l	4(a2),d0
	beq.w	loc_17BE
	move.l	d0,a2
	tst.b	$3C(a2)
	beq.s	GfxObjects_Collision_Loop
	move.w	$22(a2),d0
	asr.w	#1,d0
	lea	(CollisionSize_Index).l,a4
	add.w	(a4,d0.w),a4

;loc_171C
; a sprite can be composed of multiple hitboxes
GfxObjects_Collision_SubBoxLoop:
	move.l	a4,a1
	move.w	(a4)+,d0	; first entry 0 mean there's no collision
	beq.s	GfxObjects_Collision_Loop
	tst.b	$16(a2)		; sprite x-flipped?
	bne.s	+
	add.w	$1A(a2),d0	; d0 = left edge of hitbox
	move.w	d0,d1
	add.w	(a4)+,d1	; d1 = right edge of hitbox
	bra.w	GfxObjects_Collision_ChkBoundaries

;loc_1734
+	; sprite is flipped
	neg.w	d0
	add.w	$1A(a2),d0
	move.w	d0,d1		; d1 = right edge of hitbox
	sub.w	(a4)+,d0	; d0 = left edge of hitbox

;loc_173E
GfxObjects_Collision_ChkBoundaries:
	tst.w	d0
	bmi.w	GfxObjects_Collision_LeftBoundary	; left level boundary
	cmp.w	(Level_width_pixels).w,d1
	bge.w	GfxObjects_Collision_RightBoundary	; right level boundary
	move.w	d0,d2
	andi.w	#$FFF0,d2	; left edge in pixels rounded to full block
	move.w	d2,a6
	move.w	d0,d4
	move.w	d1,d5
	asr.w	#4,d4	; d4 = left edge in blocks
	asr.w	#4,d5
	sub.w	d4,d5	; d5 = difference between right and left block
	add.w	d4,d4
	swap	d0
	swap	d1
	move.w	(a4)+,d0
	add.w	$1E(a2),d0	; d0 = top edge of hitbox
	bmi.w	GfxObjects_Collision_TopBoundary	; top level boundary
	move.w	d0,d1
	add.w	(a4)+,d1	; d1 = bottom edge of hitbox
	cmp.w	(Level_height_blocks).w,d1
	bge.w	GfxObjects_Collision_BottomBoundary	; bottom level boundary
	move.w	d0,d3
	andi.w	#$FFF0,d3
	move.w	d1,d6	; bottom edge in pixels
	move.w	d0,d7	; top edge in pixels
	asr.w	#4,d6	; bottom edge in blocks
	asr.w	#4,d7	; d7 = top edge in blocks
	sub.w	d7,d6	; d6 = difference between bottom and top block
	add.w	d7,d7
	move.w	(a0,d7.w),a3	; get pointer to row of tiles in Level_Layout
	add.w	d4,a3	; get pointer to tile in Level_layout

; this double loop checks for collision with every tiles that overlaps the hitbox
;loc_1792
GfxObjects_Collision_Tiles_Loop:
	move.w	d5,d4	; difference between right and left block
	move.w	a6,d2	; left edge in pixels rounded to full block

;loc_1796
GfxObjects_Collision_Tiles_RowLoop:
	move.w	(a3)+,d7	; get tile
	andi.w	#$4000,d7	; is there collision?
	bne.w	loc_17C6	; yes --> go there

;loc_17A0
GfxObjects_Collision_Tiles_Continue:
	addi.w	#$10,d2
	dbf	d4,GfxObjects_Collision_Tiles_RowLoop

	addi.w	#$10,d3
	add.w	(Level_width_tiles).w,a3
	subq.w	#2,a3
	suba.w	d5,a3
	suba.w	d5,a3
	dbf	d6,GfxObjects_Collision_Tiles_Loop

	bra.w	GfxObjects_Collision_SubBoxLoop
; ---------------------------------------------------------------------------

loc_17BE:
	addq.w	#4,sp
	movem.l	(sp)+,d0-a6
	rts
; ---------------------------------------------------------------------------
; collision at the current tile
loc_17C6:
	move.w	-2(a3),d7	; get tile again
	andi.w	#$7000,d7	; only get collision bits
	cmpi.w	#$7000,d7	; spikes?
	beq.s	GfxObjects_Collision_Tiles_Continue	; we ignore spikes
	cmpi.w	#$6000,d7	; solid?
	beq.w	GfxObjects_Collision_Solid
	cmpi.w	#$4000,d7	; up slope?
	beq.w	GfxObjects_Collision_UpSlope
	bra.w	GfxObjects_Collision_DownSlope	; $5000 = down slope
; ---------------------------------------------------------------------------
	nop

GfxObjects_Collision_UpSlope:
	movem.l	d0-d1,-(sp)
	move.w	d1,d0
	swap	d1
	move.w	d1,d7
	andi.w	#$FFF0,d7
	cmp.w	d7,d2
	bne.w	loc_180E
	sub.w	d3,d0
	neg.w	d0
	addi.w	#$E,d0
	sub.w	d2,d1
	cmp.w	d0,d1
	bgt.w	loc_1814

loc_180E:
	movem.l	(sp)+,d0-d1
	bra.s	GfxObjects_Collision_Tiles_Continue
; ---------------------------------------------------------------------------

loc_1814:
	subq.w	#2,a3
	move.w	a3,($FFFFFB6C).w
	addq.w	#8,sp
	bra.w	GfxObjects_Collision_ChkUpSlope
; ---------------------------------------------------------------------------
;loc_1820
GfxObjects_Collision_DownSlope:
	movem.l	d0-d1,-(sp)
	swap	d0
	sub.w	d3,d1
	sub.w	d2,d0
	cmp.w	d1,d0
	ble.w	loc_1838
	movem.l	(sp)+,d0-d1
	bra.w	GfxObjects_Collision_Tiles_Continue
; ---------------------------------------------------------------------------

loc_1838:
	subq.w	#2,a3
	move.w	a3,($FFFFFB6C).w
	addq.w	#8,sp
	bra.w	GfxObjects_Collision_ChkDownSlope
; ---------------------------------------------------------------------------

GfxObjects_Collision_Solid:
	subq.w	#2,a3
	move.l	a3,a5
	move.w	a3,($FFFFFB6C).w
	move.w	d0,d5
	move.w	d1,d6
	swap	d1
	move.w	d1,d4
	swap	d0
	move.w	d2,d1
	move.w	d3,d2
	move.w	d0,d3
	move.w	d1,(sp)
	move.w	d2,2(sp)
	move.l	$26(a2),d0
	bmi.w	GfxObjects_Collision_Solid_MovingLeft
	;moving right
	lsr.l	#8,d0
	move.l	$2A(a2),d7
	bmi.w	GfxObjects_Collision_Solid_MovingRightUp
;GfxObjects_Collision_Solid_MovingRightDown
	lsr.l	#8,d7
	move.w	-2(a5),d3	; get tile to the left
	andi.w	#$7000,d3
	cmpi.w	#$6000,d3
	beq.w	loc_1A12	; tile to the left is solid
	suba.w	(Level_width_tiles).w,a5
	move.w	(a5),d3	; get tile above
	andi.w	#$7000,d3
	cmpi.w	#$6000,d3
	beq.w	loc_1966	; tile above is solid
	sub.w	d1,d4
	sub.w	d2,d6
	muls.w	d0,d6
	muls.w	d7,d4
	cmp.l	d4,d6
	bgt.w	loc_1966
	bra.w	loc_1A12
; ---------------------------------------------------------------------------
;loc_18AA
GfxObjects_Collision_Solid_MovingRightUp:
	lsr.l	#8,d7
	move.w	-2(a5),d3
	andi.w	#$7000,d3
	cmpi.w	#$6000,d3
	beq.w	loc_1A6C
	add.w	(Level_width_tiles).w,a5
	move.w	(a5),d3
	andi.w	#$7000,d3
	cmpi.w	#$6000,d3
	beq.w	loc_1966
	addi.w	#$10,d2
	sub.w	d1,d4
	sub.w	d2,d5
	muls.w	d0,d5
	muls.w	d7,d4
	cmp.l	d4,d5
	blt.w	loc_1966
	bra.w	loc_1A6C
; ---------------------------------------------------------------------------
;loc_18E4
GfxObjects_Collision_Solid_MovingLeft:
	lsr.l	#8,d0
	move.l	$2A(a2),d7
	bmi.w	GfxObjects_Collision_Solid_MovingLeftUp
;GfxObjects_Collision_Solid_MovingLeftDown:
	lsr.l	#8,d7
	move.w	2(a5),d4
	andi.w	#$7000,d4
	cmpi.w	#$6000,d4
	beq.w	loc_1A12
	suba.w	(Level_width_tiles).w,a5
	move.w	(a5),d4
	andi.w	#$7000,d4
	cmpi.w	#$6000,d4
	beq.w	loc_19BA
	addi.w	#$10,d1
	sub.w	d1,d3
	sub.w	d2,d6
	muls.w	d0,d6
	muls.w	d7,d3
	cmp.l	d3,d6
	blt.w	loc_19BA
	bra.w	loc_1A12
; ---------------------------------------------------------------------------
;loc_1928
GfxObjects_Collision_Solid_MovingLeftUp:
	lsr.l	#8,d7
	move.w	2(a5),d4
	andi.w	#$7000,d4
	cmpi.w	#$6000,d4
	beq.w	loc_1A6C
	add.w	(Level_width_tiles).w,a5
	move.w	(a5),d4
	andi.w	#$7000,d4
	cmpi.w	#$6000,d4
	beq.w	loc_19BA
	addi.w	#$10,d1
	addi.w	#$10,d2
	sub.w	d1,d3
	sub.w	d2,d5
	muls.w	d0,d5
	muls.w	d7,d3
	cmp.l	d3,d5
	bgt.w	loc_19BA
	bra.w	loc_1A6C
; ---------------------------------------------------------------------------

loc_1966:
	move.w	-2(a3),d7
	andi.w	#$7000,d7
	cmpi.w	#$4000,d7
	bne.w	loc_197E
	subq.w	#2,($FFFFFB6C).w
	bra.w	GfxObjects_Collision_ChkUpSlope
; ---------------------------------------------------------------------------

loc_197E:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.w	loc_1ADA
	move.w	#colid_rightwall,$38(a2)
	move.w	(sp),d7
	tst.b	$16(a2)
	beq.w	loc_19A8
	add.w	(a1)+,d7
	subq.w	#1,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_19A8:
	sub.w	(a1)+,d7
	sub.w	(a1)+,d7
	subq.w	#1,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_19BA:
	move.w	2(a3),d7
	andi.w	#$7000,d7
	cmpi.w	#$5000,d7
	bne.w	loc_19D2
	addq.w	#2,($FFFFFB6C).w
	bra.w	GfxObjects_Collision_ChkDownSlope
; ---------------------------------------------------------------------------

loc_19D2:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.w	loc_1ADA
	move.w	#colid_leftwall,$38(a2)
	move.w	(sp),d7
	tst.b	$16(a2)
	beq.w	loc_1A00
	add.w	(a1)+,d7
	add.w	(a1)+,d7
	addi.w	#$10,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_1A00:
	sub.w	(a1)+,d7
	addi.w	#$10,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_1A12:
	suba.w	(Level_width_tiles).w,a3
	move.w	(a3),d7
	andi.w	#$7000,d7
	cmpi.w	#$4000,d7
	bne.w	loc_1A30
	move.w	(Level_width_tiles).w,d7
	sub.w	d7,($FFFFFB6C).w
	bra.w	GfxObjects_Collision_ChkUpSlope
; ---------------------------------------------------------------------------

loc_1A30:
	cmpi.w	#$5000,d7
	bne.w	loc_1A44
	move.w	(Level_width_tiles).w,d7
	sub.w	d7,($FFFFFB6C).w
	bra.w	GfxObjects_Collision_ChkDownSlope
; ---------------------------------------------------------------------------

loc_1A44:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.w	loc_1ADA
	move.w	#colid_floor,$38(a2)
	move.w	2(sp),d7
	addq.w	#4,a1
	sub.w	(a1)+,d7
	sub.w	(a1)+,d7
	subq.w	#1,d7
	move.w	d7,$1E(a2)
	clr.w	$20(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_1A6C:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.w	loc_1ADA
	move.w	#colid_ceiling,$38(a2)
	move.w	2(sp),d7
	addq.w	#4,a1
	sub.w	(a1)+,d7
	addi.w	#$10,d7
	move.w	d7,$1E(a2)
	clr.w	$20(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------
;loc_1A94
GfxObjects_Collision_ChkUpSlope:
	tst.l	$2A(a2)
	bpl.w	+
	move.l	$26(a2),d7
	bmi.w	GfxObjects_Collision_Loop
	neg.l	d7
	cmp.l	$2A(a2),d7
	bgt.w	GfxObjects_Collision_Loop
+
	move.w	#colid_slopeup,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------
;loc_1AB8
GfxObjects_Collision_ChkDownSlope:
	tst.l	$2A(a2)
	bpl.w	+
	move.l	$26(a2),d7
	bpl.w	GfxObjects_Collision_Loop
	cmp.l	$2A(a2),d7
	bgt.w	GfxObjects_Collision_Loop
+
	move.w	#colid_slopedown,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------

loc_1ADA:
	addq.w	#4,sp
	movem.l	(sp)+,d0-a6
	rts
; ---------------------------------------------------------------------------
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
;loc_1AEA
GfxObjects_Collision_LeftBoundary:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.s	loc_1ADA
	move.w	$1A(a2),d7
	sub.w	d0,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	move.w	#colid_leftwall,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------
; loc_1B0A
GfxObjects_Collision_RightBoundary:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.s	loc_1ADA
	sub.w	$1A(a2),d1
	move.w	(Level_width_pixels).w,d7
	sub.w	d1,d7
	subq.w	#1,d7
	move.w	d7,$1A(a2)
	clr.w	$1C(a2)
	move.w	#colid_rightwall,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------
;loc_1B30
GfxObjects_Collision_TopBoundary:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.s	loc_1ADA
	move.w	$1E(a2),d7
	sub.w	d0,d7
	move.w	d7,$1E(a2)
	clr.w	$20(a2)
	move.w	#colid_ceiling,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; ---------------------------------------------------------------------------
;loc_1B50
GfxObjects_Collision_BottomBoundary:
	move.l	(Addr_GfxObject_Kid).w,d7
	cmp.l	a2,d7
	beq.s	loc_1ADA
	sub.w	$1E(a2),d1
	move.w	(Level_height_blocks).w,d7
	sub.w	d1,d7
	subq.w	#1,d7
	move.w	d7,$1E(a2)
	clr.w	$20(a2)
	move.w	#colid_floor,$38(a2)
	bra.w	GfxObjects_Collision_Loop
; End of function GfxObjects_Collision


; =============== S U B	R O U T	I N E =======================================

;sub_1B76
GfxObjects_CollisionKid:
	tst.b	($FFFFFA64).w
	beq.w	*+4
	subq.w	#2,sp
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	(Kid_hitbox_left).w,d0
	move.w	(Kid_hitbox_right).w,d1
	move.w	(Kid_hitbox_top).w,d2
	move.w	(Kid_hitbox_bottom).w,d3

;loc_1B94
GfxObjects_CollisionKid_Loop:
	move.l	4(a2),d4
	beq.w	loc_1D00
	move.l	d4,a2
	tst.b	$3D(a2)
	bne.s	GfxObjects_CollisionKid_Loop
	move.w	$22(a2),d4
	asr.w	#1,d4
	lea	(CollisionSize_Index).l,a3
	add.w	(a3,d4.w),a3
	subq.w	#8,a3
	tst.b	$16(a2)
	bne.s	GfxObjects_CollisionKid_SubBoxLoop_Flipped

GfxObjects_CollisionKid_SubBoxLoop:	; sprite is not flipped
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	GfxObjects_CollisionKid_Loop	; processed all hitboxes
	add.w	$1A(a2),d4	; left boundary
	cmp.w	d1,d4	; is left boundary of sprite less than right boundary of kid?
	bgt.s	GfxObjects_CollisionKid_SubBoxLoop
	add.w	2(a3),d4	; right boundary
	cmp.w	d0,d4
	blt.s	GfxObjects_CollisionKid_SubBoxLoop
	move.w	4(a3),d5
	add.w	$1E(a2),d5	; top boundary
	move.w	d5,(sp)
	cmp.w	d3,d5
	bgt.s	GfxObjects_CollisionKid_SubBoxLoop
	add.w	6(a3),d5	; bottom boundary
	cmp.w	d2,d5
	blt.s	GfxObjects_CollisionKid_SubBoxLoop
	bra.s	GfxObjects_CollisionKid_Collide
; ---------------------------------------------------------------------------

GfxObjects_CollisionKid_SubBoxLoop_Flipped:	; sprite is flipped
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	GfxObjects_CollisionKid_Loop
	neg.w	d4
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	blt.s	GfxObjects_CollisionKid_SubBoxLoop_Flipped
	sub.w	2(a3),d4
	cmp.w	d1,d4
	bgt.s	GfxObjects_CollisionKid_SubBoxLoop_Flipped
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	move.w	d5,(sp)
	cmp.w	d3,d5
	bgt.s	GfxObjects_CollisionKid_SubBoxLoop_Flipped
	add.w	6(a3),d5
	cmp.w	d2,d5
	blt.s	GfxObjects_CollisionKid_SubBoxLoop_Flipped

;loc_1C18
;the kid's hitbox and the object hitbox overlap
GfxObjects_CollisionKid_Collide:
	cmpi.w	#4,8(a2)
	beq.w	loc_1D5A
	cmpi.w	#3,8(a2)
	beq.w	loc_1D46
	st	($FFFFFA75).w
	tst.b	($FFFFFA74).w
	bne.w	loc_1D4C
	tst.b	$16(a2)
	bne.s	loc_1C42
	sub.w	2(a3),d4

loc_1C42:
	move.l	$26(a2),d6
	sub.l	$26(a0),d6	; x_vel of object minus x_vel of kid
	bmi.w	loc_1C94	; if kid has faster x_vel than object --> branch
	lsl.l	#8,d6
	swap	d6
	move.l	$2A(a2),d7	; y_vel of object minus y_vel of kid
	sub.l	$2A(a0),d7	; if kid has faster y_vel than object --> branch
	bmi.s	loc_1C76
	; object has faster x and y velocity
	lsl.l	#8,d7
	swap	d7
	add.w	2(a3),d4	; right edge of object hitbox
	sub.w	d0,d4	; minus left edge of kid hitbox = size of x overlap (in pixels)
	sub.w	d2,d5	; size of y overlap (in pixels)
	muls.w	d7,d4	; multiply with $100 times x_vel
	muls.w	d6,d5	; multiply with $100 times y_vel
	cmp.l	d4,d5
	bgt.w	loc_1CD2	; y overlap * y_vel > x overlap * x_vel
	bra.w	loc_1CDE	; y overlap * y_vel < x overlap * x_vel
; ---------------------------------------------------------------------------

loc_1C76:
	; object has faster x velocity and slower y velocity
	lsl.l	#8,d7
	swap	d7
	add.w	2(a3),d4
	sub.w	6(a3),d5
	sub.w	d0,d4
	sub.w	d3,d5
	muls.w	d7,d4
	muls.w	d6,d5
	cmp.l	d4,d5
	blt.w	loc_1CD2	; y overlap * y_vel > x overlap * x_vel
	bra.w	loc_1CE4	; y overlap * y_vel < x overlap * x_vel
; ---------------------------------------------------------------------------

loc_1C94:
	; object has slower x velocity
	lsl.l	#8,d6
	swap	d6
	move.l	$2A(a2),d7	; y_vel of object minus y_vel of kid
	sub.l	$2A(a0),d7	; if kid has faster y_vel than object --> branch
	bmi.s	loc_1CB8
	; object has faster y velocity and slower x velocity
	lsl.l	#8,d7
	swap	d7
	sub.w	d1,d4
	sub.w	d2,d5
	muls.w	d7,d4
	muls.w	d6,d5
	cmp.l	d4,d5
	blt.w	loc_1CD8
	bra.w	loc_1CDE
; ---------------------------------------------------------------------------

loc_1CB8:
	; object has slower x and y velocity
	lsl.l	#8,d7
	swap	d7
	sub.w	d1,d4
	sub.w	6(a3),d5
	sub.w	d3,d5
	muls.w	d7,d4
	muls.w	d6,d5
	cmp.l	d4,d5
	bgt.w	loc_1CD8
	bra.w	loc_1CE4
; ---------------------------------------------------------------------------

loc_1CD2:
	move.w	#colid_kidright,d7
	bra.s	loc_1CF2
; ---------------------------------------------------------------------------

loc_1CD8:
	move.w	#colid_kidleft,d7
	bra.s	loc_1CF2
; ---------------------------------------------------------------------------

loc_1CDE:
	move.w	#colid_kidbelow,d7
	bra.s	loc_1CF2
; ---------------------------------------------------------------------------

loc_1CE4:
	move.w	#colid_kidabove,d7
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	bne.w	loc_1D4C

loc_1CF2:
	move.w	d7,$38(a0)
	move.w	d7,$38(a2)
	move.w	$3A(a2),$3A(a0)

loc_1D00:
	addq.w	#2,sp
	tst.b	(KidIsInvulnerable).w
	beq.w	return_1D32
	move.w	$38(a0),d7
	beq.w	return_1D32
	cmpi.w	#$2C,d7
	beq.w	loc_1D34
	move.w	$3A(a0),d7
	bclr	#$F,d7
	bclr	#$E,d7
	cmpi.w	#$64,d7
	bge.w	return_1D32
	clr.w	$38(a0)

return_1D32:
	rts
; ---------------------------------------------------------------------------

loc_1D34:
	move.w	$3A(a0),d7
	bclr	#$F,d7
	bclr	#$E,d7
	move.w	d7,$3A(a0)
	rts
; ---------------------------------------------------------------------------

loc_1D46:
	move.w	#colid_kidbelow,$38(a2)

loc_1D4C:
	move.w	#colid_kidbelow,$38(a0)
	move.w	$3A(a2),$3A(a0)
	bra.s	loc_1D00
; ---------------------------------------------------------------------------

loc_1D5A:
	move.w	$3A(a2),d6
	cmpi.w	#$64,d6

loc_1D62:
	blt.s	loc_1D62
	move.w	d6,$3A(a0)
	move.w	#colid_kidbelow,$38(a0)
	move.w	#colid_kidbelow,$38(a2)
	bra.s	loc_1D00
; End of function GfxObjects_CollisionKid


; =============== S U B	R O U T	I N E =======================================


sub_1D76:
	lea	($FFFFF862).w,a0
	moveq	#0,d7
	bsr.s	sub_1D84
	lea	($FFFFF5A0).w,a0
	moveq	#1,d7
; End of function sub_1D76


; =============== S U B	R O U T	I N E =======================================


sub_1D84:
	move.l	4(a0),d0
	beq.w	return_1E9E
	move.l	d0,a0
	move.w	$22(a0),d0
	beq.s	sub_1D84
	lea	(CollisionSize_Index).l,a1
	asr.w	#1,d0
	add.w	(a1,d0.w),a1
	move.w	(a1)+,d0
	beq.s	sub_1D84
	tst.b	$16(a0)
	bne.s	loc_1DB4
	add.w	$1A(a0),d0
	move.w	d0,d1
	add.w	(a1)+,d1
	bra.s	loc_1DBE
; ---------------------------------------------------------------------------

loc_1DB4:
	neg.w	d0
	add.w	$1A(a0),d0
	move.w	d0,d1
	sub.w	(a1)+,d0

loc_1DBE:
	move.w	(a1)+,d2
	add.w	$1E(a0),d2
	move.w	d2,d3
	add.w	(a1)+,d3
	lea	(Addr_GfxObject_KidProjectile).w,a2

loc_1DCC:
	move.l	4(a2),d4
	beq.s	sub_1D84
	move.l	d4,a2
	tst.b	$3D(a2)
	bne.s	loc_1DCC
	move.w	$22(a2),d4
	asr.w	#1,d4
	lea	(CollisionSize_Index).l,a3
	add.w	(a3,d4.w),a3
	subq.w	#8,a3
	tst.b	$16(a2)
	bne.s	loc_1E1E

loc_1DF2:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_1DCC
	add.w	$1A(a2),d4
	cmp.w	d1,d4
	bgt.s	loc_1DF2
	add.w	2(a3),d4
	cmp.w	d0,d4
	blt.s	loc_1DF2
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	cmp.w	d3,d5
	bgt.s	loc_1DF2
	add.w	6(a3),d5
	cmp.w	d2,d5
	blt.s	loc_1DF2
	bra.s	loc_1E4A
; ---------------------------------------------------------------------------

loc_1E1E:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_1DCC
	neg.w	d4
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	blt.s	loc_1E1E
	sub.w	2(a3),d4
	cmp.w	d1,d4
	bgt.s	loc_1E1E
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	cmp.w	d3,d5
	bgt.s	loc_1E1E
	add.w	6(a3),d5
	cmp.w	d2,d5
	blt.s	loc_1E1E

loc_1E4A:
	tst.w	d7
	bne.s	loc_1EA0
	cmpi.w	#(LnkTo3_NULL-Data_Index),$22(a0)
	blt.s	loc_1E5E
	cmpi.w	#(LnkTo4_NULL-Data_Index),$22(a0)
	ble.s	loc_1EA0

loc_1E5E:
	exg	a0,a1
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1F08,4(a0)
	exg	a0,a1
	move.w	$1A(a0),$44(a1)
	move.w	$1E(a0),$46(a1)
	move.w	#colid_hurt,$38(a2)	; hurt by e.g. red stealth sword, axe, skull
	cmpi.w	#$3C,$3A(a0)
	bne.w	loc_1E94
	move.w	#$FFFF,$38(a2)

loc_1E94:
	move.w	#4,$38(a0)
	bra.w	sub_1D84
; ---------------------------------------------------------------------------

return_1E9E:
	rts
; ---------------------------------------------------------------------------

loc_1EA0:
	swap	d7
	move.w	$3A(a2),d7
	andi.w	#$FF,d7
	add.w	d7,d7
	move.w	unk_1EBE(pc,d7.w),$38(a2)
	swap	d7
	move.w	#colid_rightwall,$38(a0)
	bra.w	sub_1D84
; End of function sub_1D84

; ---------------------------------------------------------------------------
unk_1EBE:
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_empty
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_kidabove
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w colid_hurt
	dc.w $FFFF
	dc.w $FFFF
	dc.w $FFFF
	dc.w $FFFF
	dc.w $FFFF
; ---------------------------------------------------------------------------
; explosion object?
loc_1F08:
	move.l	#$3000401,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	st	$13(a3)
	move.b	#1,priority(a3)
	move.b	#3,palette_line(a3)
	move.l	#stru_1F40,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_1F40:
	anim_frame	  1,   2, LnkTo_unk_E0F2E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F36-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F3E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F46-Data_Index
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_1F52:
	lea	($FFFFF202).w,a0

loc_1F56:
	addq.w	#8,a0
	move.w	(a0),d0
	beq.w	return_1F8C
	cmp.w	(Kid_hitbox_right).w,d0
	bgt.s	loc_1F56
	move.w	2(a0),d0
	cmp.w	(Kid_hitbox_left).w,d0
	blt.s	loc_1F56
	move.w	4(a0),d0
	cmp.w	(Kid_hitbox_bottom).w,d0
	bgt.s	loc_1F56
	move.w	6(a0),d0
	cmp.w	(Kid_hitbox_top).w,d0
	blt.s	loc_1F56
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	#colid_kidbelow,$38(a0)

return_1F8C:
	rts
; End of function sub_1F52


; =============== S U B	R O U T	I N E =======================================


sub_1F8E:
	moveq	#0,d5
	move.w	d7,d5
	subi.w	#Level_Layout&$FFFF,d5
	divu.w	(Level_width_tiles).w,d5
	move.w	d5,d6
	swap	d5
	lsr.w	#1,d5
	rts
; End of function sub_1F8E


; =============== S U B	R O U T	I N E =======================================


sub_1FA2:
	sf	($FFFFFAA6).w
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$1A(a0),-(sp)
	move.w	$1E(a0),-(sp)

loc_1FB2:
	tst.b	($FFFFFA64).w
	bne.w	loc_200C
	tst.l	(Addr_GfxObject_Kid).w
	beq.w	loc_200C
	move.w	(Kid_hitbox_top).w,d0
	move.w	(Kid_hitbox_bottom).w,d1
	asr.w	#4,d0
	asr.w	#4,d1
	sub.w	d0,d1
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	(Kid_hitbox_left).w,d0
	move.w	(Kid_hitbox_right).w,d2
	asr.w	#4,d0
	asr.w	#4,d2
	sub.w	d0,d2
	add.w	d0,d0
	add.w	d0,a0

loc_1FEE:
	move.w	d2,d3
	move.w	a0,a1

loc_1FF2:
	move.w	(a1)+,d0
	andi.w	#$7000,d0
	cmpi.w	#$6000,d0
	bge.w	loc_2010
	dbf	d3,loc_1FF2
	add.w	(Level_width_tiles).w,a0
	dbf	d1,loc_1FEE

loc_200C:
	addq.w	#4,sp
	rts
; ---------------------------------------------------------------------------

loc_2010:
	move.w	-2(a1),d0
	bsr.w	j_Palette_to_VRAM0
	bne.w	loc_211C

loc_201C:
	tst.b	($FFFFFAA6).w
	bne.w	loc_2156
	move.w	(a1)+,d0
	bsr.w	j_Palette_to_VRAM0
	beq.s	loc_201C
	subq.w	#4,a1
	move.w	a1,d7
	bsr.w	sub_1F8E
	moveq	#0,d2
	move.w	d5,d2
	lsl.w	#4,d2
	move.l	d2,d1
	addi.w	#$F,d2

loc_2040:
	move.w	-(a1),d0
	bsr.w	j_Palette_to_VRAM0
	bne.w	loc_2050
	subi.w	#$10,d1
	bra.s	loc_2040
; ---------------------------------------------------------------------------

loc_2050:
	addq.w	#2,a1
	move.w	(Level_width_tiles).w,d3

loc_2056:
	suba.w	d3,a1
	move.w	(a1),d0
	bsr.w	j_Palette_to_VRAM0
	beq.s	loc_2056
	add.w	d3,a1
	move.w	a1,d7
	bsr.w	sub_1F8E
	swap	d1
	swap	d2
	move.w	d6,d1
	lsl.w	#4,d1
	move.w	d1,d2
	subq.w	#1,d2

loc_2074:
	add.w	d3,a1
	addi.w	#$10,d2
	move.w	(a1),d0
	bsr.w	j_Palette_to_VRAM0
	beq.s	loc_2074
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	d2,d7
	sub.w	d1,d7
	swap	d1
	swap	d2
	move.w	d2,d6
	sub.w	d1,d6
	cmp.w	d6,d7
	bgt.w	loc_20DC
	st	($FFFFFAA6).w
	swap	d1
	swap	d2
	sub.w	(Kid_hitbox_top).w,d2
	move.w	(Kid_hitbox_bottom).w,d3
	sub.w	d1,d3
	cmp.w	d2,d3
	ble.w	loc_20C6
	addq.w	#1,d2
	add.w	d2,(Kid_hitbox_top).w
	add.w	d2,(Kid_hitbox_bottom).w
	add.w	d2,$1E(a0)
	clr.w	$20(a0)
	bra.w	loc_1FB2
; ---------------------------------------------------------------------------

loc_20C6:
	addq.w	#1,d3
	sub.w	d3,(Kid_hitbox_top).w
	sub.w	d3,(Kid_hitbox_bottom).w
	sub.w	d3,$1E(a0)
	clr.w	$20(a0)
	bra.w	loc_1FB2
; ---------------------------------------------------------------------------

loc_20DC:
	st	($FFFFFAA6).w
	sub.w	(Kid_hitbox_left).w,d2
	move.w	(Kid_hitbox_right).w,d3
	sub.w	d1,d3
	cmp.w	d2,d3
	ble.w	loc_2106
	addq.w	#1,d2
	add.w	d2,(Kid_hitbox_left).w
	add.w	d2,(Kid_hitbox_right).w
	add.w	d2,$1A(a0)
	clr.w	$1C(a0)
	bra.w	loc_1FB2
; ---------------------------------------------------------------------------

loc_2106:
	addq.w	#1,d3
	sub.w	d3,(Kid_hitbox_left).w
	sub.w	d3,(Kid_hitbox_right).w
	sub.w	d3,$1A(a0)
	clr.w	$1C(a0)
	bra.w	loc_1FB2
; ---------------------------------------------------------------------------

loc_211C:
	move.w	(a1),d0
	andi.w	#$7000,d0
	cmpi.w	#$5000,d0
	beq.w	loc_216A
	move.w	-4(a1),d0
	andi.w	#$7000,d0
	cmpi.w	#$4000,d0
	beq.w	loc_216A
	suba.w	(Level_width_tiles).w,a1
	subq.w	#2,a1
	move.w	(a1),d0
	andi.w	#$7000,d0
	cmpi.w	#$5000,d0
	beq.w	loc_216A
	cmpi.w	#$4000,d0
	beq.w	loc_216A

loc_2156:
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	#4,$38(a0)
	move.w	(sp)+,$1E(a0)
	move.w	(sp)+,$1A(a0)
	rts
; ---------------------------------------------------------------------------

loc_216A:
	cmpi.w	#6,($FFFFFA56).w
	beq.w	loc_200C
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	beq.w	loc_200C
	bra.s	loc_2156
; End of function sub_1FA2


; =============== S U B	R O U T	I N E =======================================


j_Palette_to_VRAM0:
	bclr	#$F,d0
	beq.w	loc_2198
	andi.w	#$F00,d0
	cmpi.w	#$300,d0
	bne.w	loc_2198
	moveq	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_2198:
	moveq	#1,d0
	rts
; End of function j_Palette_to_VRAM0


; =============== S U B	R O U T	I N E =======================================


sub_219C:

	movem.l	d0-d4/a0-a4,-(sp)
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	(Kid_hitbox_left).w,d0
	move.w	(Kid_hitbox_right).w,d1
	move.w	(Kid_hitbox_top).w,d2
	move.w	(Kid_hitbox_bottom).w,d3
	lea	($FFFFF8C0).w,a2

loc_21B8:
	move.w	$A(a2),d7
	beq.w	loc_21F2
	move.w	a2,a3
	move.w	d7,a2
	move.w	2(a2),d4
	cmp.w	d0,d4
	ble.s	loc_21B8
	cmp.w	d1,d4
	bge.s	loc_21B8
	move.w	4(a2),d4
	cmp.w	d2,d4
	ble.s	loc_21B8
	cmp.w	d3,d4
	bge.s	loc_21B8
	move.w	#$20,$38(a0)
	move.w	$A(a2),$A(a3)
	move.w	($FFFFF8CC).w,$A(a2)
	move.w	a2,($FFFFF8CC).w

loc_21F2:
	movem.l	(sp)+,d0-d4/a0-a4
	rts
; End of function sub_219C


; =============== S U B	R O U T	I N E =======================================


sub_21F8:
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$22(a0),d0
	beq.w	loc_2252
	lea	(CollisionSize_Index).l,a4
	move.l	a4,a1
	asr.w	#1,d0
	add.w	(a1,d0.w),a1
	move.w	(a1)+,d0
	beq.w	loc_224C
	tst.b	$16(a0)
	bne.s	loc_2228
	add.w	$1A(a0),d0
	move.w	d0,d1
	add.w	(a1)+,d1
	bra.s	loc_2232
; ---------------------------------------------------------------------------

loc_2228:
	neg.w	d0
	add.w	$1A(a0),d0
	move.w	d0,d1
	sub.w	(a1)+,d0

loc_2232:
	move.w	(a1)+,d2
	add.w	$1E(a0),d2
	move.w	d2,d3
	add.w	(a1)+,d3
	move.w	d0,(Kid_hitbox_left).w
	move.w	d1,(Kid_hitbox_right).w
	move.w	d2,(Kid_hitbox_top).w
	move.w	d3,(Kid_hitbox_bottom).w

loc_224C:
	move.l	a1,($FFFFFA82).w
	rts
; ---------------------------------------------------------------------------

loc_2252:
	move.w	$1A(a0),(Kid_hitbox_left).w
	move.w	(Kid_hitbox_left).w,(Kid_hitbox_right).w
	move.w	$1E(a0),(Kid_hitbox_top).w
	move.w	(Kid_hitbox_top).w,(Kid_hitbox_bottom).w
; End of function sub_21F8


; =============== S U B	R O U T	I N E =======================================


sub_226A:
	lea	($FFFFF8C0).w,a0

loc_226E:
	move.w	$A(a0),d7
	beq.w	return_231A
	move.w	a0,a1
	move.w	d7,a0
	move.w	2(a0),d0
	move.w	4(a0),d1
	lea	(Addr_GfxObject_KidProjectile).w,a2

loc_2286:
	move.l	4(a2),d4
	beq.s	loc_226E
	move.l	d4,a2
	move.w	$22(a2),d4
	asr.w	#1,d4
	lea	(CollisionSize_Index).l,a3
	add.w	(a3,d4.w),a3
	subq.w	#8,a3
	tst.b	$16(a2)
	bne.s	loc_22D2

loc_22A6:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_2286
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	bgt.s	loc_22A6
	add.w	2(a3),d4
	cmp.w	d0,d4
	ble.s	loc_22A6
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	cmp.w	d1,d5
	bgt.s	loc_22A6
	add.w	6(a3),d5
	cmp.w	d1,d5
	ble.s	loc_22A6
	bra.s	loc_22FE
; ---------------------------------------------------------------------------

loc_22D2:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_2286
	neg.w	d4
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	ble.s	loc_22D2
	sub.w	2(a3),d4
	cmp.w	d0,d4
	bgt.s	loc_22D2
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	cmp.w	d1,d5
	bgt.s	loc_22D2
	add.w	6(a3),d5
	cmp.w	d1,d5
	ble.s	loc_22D2

loc_22FE:
	move.w	#colid_hurt,$38(a2)	; hurt by shooter block bullet
	move.w	$A(a0),$A(a1)
	move.w	($FFFFF8CC).w,$A(a0)
	move.w	a0,($FFFFF8CC).w
	move.w	a1,a0
	bra.w	loc_226E
; ---------------------------------------------------------------------------

return_231A:
	rts
; End of function sub_226A


; =============== S U B	R O U T	I N E =======================================

;sub_231C
Initialize_Platforms:
	lea	($FFFFEDBA).w,a0
	move.w	a0,(Addr_NextFreePlatformSlot).w
	moveq	#$10,d0
-
	lea	$22(a0),a1
	_move.w	a1,0(a0)
	move.w	a1,a0
	dbf	d0,-
	_clr.w	0(a0)
	clr.w	(Addr_FirstPlatformSlot).w
	clr.w	(Number_Platforms).w
	clr.w	(PlatformLoader_Offset).w
	bsr.w	Get_PlatformLayoutAddress
	move.w	#$1280,d0
	lea	ArtComp_5B92(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$D5C0,d0
	lea	ArtComp_5C83(pc),a0
	jsr	(j_DecompressToVRAM).l
	rts
; End of function Initialize_Platforms


; =============== S U B	R O U T	I N E =======================================

;sub_2366
Get_PlatformLayoutAddress:
	move.w	(Current_LevelID).w,d7
	move.l	(LnkTo_MapOrder_Index).l,a4
	move.b	(a4,d7.w),d7
	ext.w	d7
	lea	MapPtfmLayout_Index(pc),a4
	add.w	d7,d7
	move.w	(a4,d7.w),d7
	ext.l	d7
	addi.l	#PlatformLayout_BaseAddress,d7
	move.l	d7,(Addr_PlatformLayout).w
	rts
; End of function Get_PlatformLayoutAddress


; =============== S U B	R O U T	I N E =======================================
; load a platform to the front of list
;sub_238E
Allocate_PlatformSlot:
	move.w	(Addr_NextFreePlatformSlot).w,d7
	beq.w	loc_23AE
	move.w	d7,a3
	_move.w	0(a3),(Addr_NextFreePlatformSlot).w
	_move.w	(Addr_FirstPlatformSlot).w,0(a3)
	move.w	a3,(Addr_FirstPlatformSlot).w
	addq.w	#1,(Number_Platforms).w
	rts
; ---------------------------------------------------------------------------

loc_23AE:
	jmp	loc_6E2(pc)
; End of function Allocate_PlatformSlot

; ---------------------------------------------------------------------------
	bra.s	loc_23AE

; =============== S U B	R O U T	I N E =======================================

;sub_23B4
Deallocate_PlatformSlot:
	move.l	a4,-(sp)
	lea	(Addr_FirstPlatformSlot).w,a4

loc_23BA:
	_move.w	0(a4),d7
	beq.w	loc_23E4
	cmp.w	d7,a3
	beq.w	loc_23CC
	move.w	d7,a4
	bra.s	loc_23BA
; ---------------------------------------------------------------------------

loc_23CC:
	_move.w	0(a3),0(a4)
	_move.w	(Addr_NextFreePlatformSlot).w,0(a3)
	move.w	a3,(Addr_NextFreePlatformSlot).w
	subq.w	#1,(Number_Platforms).w
	move.l	(sp)+,a4
	rts
; ---------------------------------------------------------------------------

loc_23E4:
	jmp	loc_6E2(pc)
; End of function Deallocate_PlatformSlot

; ---------------------------------------------------------------------------
	bra.s	loc_23E4

; =============== S U B	R O U T	I N E =======================================

; process platforms that have a platform preset
;sub_23EA
Execute_ScriptedPlatforms:
	tst.b	($FFFFFA64).w
	bne.w	return_2442

loc_23F2:
	lea	(Addr_FirstPlatformSlot).w,a2

Execute_ScriptedPlatforms_Loop:
	_move.w	0(a2),d7	; next one in list
	beq.w	return_2442	; quit if it was last one
	move.w	d7,a2		; next one becomes current one
	tst.b	$1F(a2)		; scripted or special platform?
	bmi.s	Execute_ScriptedPlatforms_Loop
    if platforms_newtype = 1
	btst	#4,$1F(a2)
	bne.s	ScriptedPlatform_CheckActivate
    endif
	move.l	$A(a2),d7
	add.l	d7,2(a2)	; Add x_vel to x_pos
	move.l	$E(a2),d7
	add.l	d7,6(a2)	; Add y_vel to y_pos
	subi.w	#1,$16(a2)	; count down (from duration)
	bne.s	Execute_ScriptedPlatforms_Loop
	move.l	$12(a2),a4	; address in platform script

loc_2422:
	move.w	(a4)+,d3	; read next entry of platform script
	bmi.w	loc_243E	; if FFFF, read address and save that as platform script address
	move.w	d3,$16(a2)	; duration
	move.l	(a4)+,d3
	move.l	d3,$A(a2)	; x vel
	move.l	(a4)+,d3
	move.l	d3,$E(a2)	; y vel
	move.l	a4,$12(a2)
	bra.s	Execute_ScriptedPlatforms_Loop
; ---------------------------------------------------------------------------

loc_243E:
	move.l	(a4),a4
	bra.s	loc_2422
; ---------------------------------------------------------------------------

return_2442:
	rts
; End of function Execute_ScriptedPlatforms

    if platforms_newtype = 1

ScriptedPlatform_CheckActivate:
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.s	Execute_ScriptedPlatforms_Loop
	cmp.w	a2,d7
	bne.s	Execute_ScriptedPlatforms_Loop
	bclr	#4,$1F(a2)	; activate platform
	bra.s	Execute_ScriptedPlatforms_Loop
    endif

; =============== S U B	R O U T	I N E =======================================

;2444
Make_SpritesFromPlatforms:
	lea	(Addr_FirstPlatformSlot).w,a2
	move.l	(Addr_NextSpriteSlot).w,a0

loc_244C:
	_move.w	0(a2),d7
	beq.w	loc_256E
	move.w	d7,a2
	move.w	2(a2),d7
	sub.w	(Camera_X_pos).w,d7
	cmpi.w	#$140,d7
	bge.s	loc_244C
	move.w	d7,d6
	move.w	$1A(a2),d0
	add.w	d0,d6
	bmi.s	loc_244C
	addi.w	#$80,d7
	move.w	6(a2),d6
	sub.w	(Camera_Y_pos).w,d6
	cmpi.w	#$E0,d6
	bge.s	loc_244C
	move.w	d6,d5
	move.w	$1C(a2),d1
	add.w	d1,d5
	bmi.s	loc_244C
	addi.w	#$80,d6
	move.w	#$500,d2
	move.w	$18(a2),a4
	asr.w	#4,d0
	asr.w	#4,d1
	moveq	#0,d3
	move.b	$1F(a2),d3
    if platforms_newtype = 0
	bclr	#7,d3
    else
	and.b	#$F,d3
    endif
	add.w	d3,d3
	move.l	off_24AC(pc,d3.w),a3
	jmp	(a3)
; ---------------------------------------------------------------------------
off_24AC:
	dc.l loc_24CC
	dc.l loc_24F0
	dc.l loc_251C
	dc.l loc_24D4
	dc.l loc_24C0
; ---------------------------------------------------------------------------

loc_24C0:
	move.w	#$400,d2
	move.w	d7,d4
	bsr.w	loc_2548
	bra.s	loc_244C
; ---------------------------------------------------------------------------

loc_24CC:
	move.w	#$700,d2
	moveq	#0,d1
	subq.w	#2,d6

loc_24D4:

	move.w	d0,d3
	move.w	d7,d4

loc_24D8:
	bsr.w	loc_2548
	addi.w	#$10,d4
	dbf	d3,loc_24D8
	addi.w	#$10,d6
	dbf	d1,loc_24D4
	bra.w	loc_244C
; ---------------------------------------------------------------------------

loc_24F0:
	move.w	d7,d4
	bsr.w	loc_2548
	addq.w	#4,a4
	addi.w	#$10,d4
	subq.w	#1,d0
	beq.w	loc_2512
	move.w	d0,d1
	subq.w	#1,d1

loc_2506:
	bsr.w	loc_2548
	addi.w	#$10,d4
	dbf	d1,loc_2506

loc_2512:
	addq.w	#4,a4
	bsr.w	loc_2548
	bra.w	loc_244C
; ---------------------------------------------------------------------------

loc_251C:
	move.w	d7,d4
	bsr.w	loc_2548
	addq.w	#4,a4
	addi.w	#$10,d6
	subq.w	#1,d1
	beq.w	loc_253E
	move.w	d1,d0
	subq.w	#1,d0

loc_2532:
	bsr.w	loc_2548
	addi.w	#$10,d6
	dbf	d0,loc_2532

loc_253E:
	addq.w	#4,a4
	bsr.w	loc_2548
	bra.w	loc_244C
; ---------------------------------------------------------------------------

loc_2548:
	move.w	d4,6(a0)
	_move.w	d6,0(a0)
	move.w	d2,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	#$8000,d5
	add.w	a4,d5
	move.w	d5,4(a0)
	lea	8(a0),a0
	rts
; ---------------------------------------------------------------------------

loc_256E:
	move.l	a0,(Addr_NextSpriteSlot).w
	rts
; End of function Make_SpritesFromPlatforms


; =============== S U B	R O U T	I N E =======================================

;sub_2574
Platforms_CheckCollision:
	tst.b	($FFFFFA64).w
	beq.w	loc_257E
	rts
; ---------------------------------------------------------------------------

loc_257E:
	movem.l	d0-d4/a0-a4,-(sp)
	subq.w	#8,sp
	clr.l	($FFFFFAA2).w
	lea	(Addr_FirstPlatformSlot).w,a2
	move.l	(Addr_GfxObject_Kid).w,a0

loc_2590:
	move.w	(Kid_hitbox_left).w,d0
	move.w	(Kid_hitbox_right).w,d1
	move.w	(Kid_hitbox_top).w,d2
	move.w	(Kid_hitbox_bottom).w,d3

loc_25A0:
	_move.w	0(a2),d4
	beq.w	loc_2720
	move.w	d4,a2
	move.w	2(a2),d4
	cmp.w	d1,d4
	bgt.s	loc_25A0
	_move.w	d4,0(sp)
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	blt.s	loc_25A0
	move.w	d4,2(sp)
	move.w	6(a2),d4
	cmp.w	d3,d4
	bgt.s	loc_25A0
	move.w	d4,4(sp)
	add.w	$1C(a2),d4
	cmp.w	d2,d4
	blt.s	loc_25A0
	move.w	d4,6(sp)
	; left/right/top/bottom boundary of platform now on stack
	_cmp.w	0(sp),d0
	bgt.w	loc_25EE
	_move.w	0(sp),d7
	sub.w	d1,d7
	subq.w	#1,d7
	bra.w	loc_261E
; ---------------------------------------------------------------------------

loc_25EE:
	cmp.w	2(sp),d1
	bgt.w	loc_2616
	_move.w	0(sp),d5
	sub.w	d1,d5
	subq.w	#1,d5
	move.w	2(sp),d6
	sub.w	d0,d6
	addq.w	#1,d6
	move.w	d5,d7
	neg.w	d5
	cmp.w	d6,d5
	blt.w	loc_261E
	move.w	d6,d7
	bra.w	loc_261E
; ---------------------------------------------------------------------------

loc_2616:
	move.w	2(sp),d7
	sub.w	d0,d7
	addq.w	#1,d7

loc_261E:
	cmp.w	4(sp),d2
	bgt.w	loc_2632
	move.w	4(sp),d6
	sub.w	d3,d6
	subq.w	#1,d6
	bra.w	loc_2662
; ---------------------------------------------------------------------------

loc_2632:
	cmp.w	6(sp),d3
	bgt.w	loc_265A
	move.w	4(sp),d4
	sub.w	d3,d4
	subq.w	#1,d4
	move.w	6(sp),d5
	sub.w	d2,d5
	addq.w	#1,d5
	move.w	d4,d6
	neg.w	d4
	cmp.w	d5,d4
	blt.w	loc_2662
	move.w	d5,d6
	bra.w	loc_2662
; ---------------------------------------------------------------------------

loc_265A:
	move.w	6(sp),d6
	sub.w	d2,d6
	addq.w	#1,d6

loc_2662:
	move.w	d7,d5
	bpl.w	loc_266A
	neg.w	d5

loc_266A:
	move.w	d6,d4
	bpl.w	loc_2672
	neg.w	d4

loc_2672:
	cmp.w	d5,d4
	blt.w	loc_26D4
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	bne.w	loc_2686
	move.w	a2,($FFFFFA96).w

loc_2686:
	add.w	d7,(Kid_hitbox_left).w
	add.w	d7,(Kid_hitbox_right).w
	add.w	d7,$1A(a0)
	tst.w	d7
	bmi.w	loc_26B6
	move.l	$A(a2),d7
	bpl.w	loc_26A2
	moveq	#0,d7

loc_26A2:
	move.l	d7,$26(a0)
	st	($FFFFFAA3).w
	tst.b	($FFFFFAA2).w
	bne.w	loc_271A
	bra.w	loc_2590
; ---------------------------------------------------------------------------

loc_26B6:
	move.l	$A(a2),d7
	bmi.w	loc_26C0
	moveq	#0,d7

loc_26C0:
	move.l	d7,$26(a0)
	st	($FFFFFAA2).w
	tst.b	($FFFFFAA3).w
	bne.w	loc_271A
	bra.w	loc_2590
; ---------------------------------------------------------------------------

loc_26D4:
	add.w	d6,(Kid_hitbox_top).w
	add.w	d6,(Kid_hitbox_bottom).w
	add.w	d6,$1E(a0)
	tst.w	d6
	bpl.w	loc_26FE
	clr.l	y_vel(a3)
	move.w	a2,(Addr_PlatformStandingOn).w
	st	($FFFFFAA4).w
	tst.b	($FFFFFAA5).w
	bne.w	loc_271A
	bra.w	loc_2590
; ---------------------------------------------------------------------------

loc_26FE:
	move.l	$E(a2),d7
	addi.l	#$4000,d7
	move.l	d7,$2A(a0)
	st	($FFFFFAA5).w
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	beq.w	loc_2590

loc_271A:
	move.w	#4,$38(a0)

loc_2720:
	addq.w	#8,sp
	movem.l	(sp)+,d0-d4/a0-a4
	rts
; End of function Platforms_CheckCollision


; =============== S U B	R O U T	I N E =======================================


sub_2728:
	lea	(Addr_FirstPlatformSlot).w,a2

loc_272C:
	_move.w	0(a2),d7
	beq.w	loc_2740
	move.w	d7,a2
	cmp.w	$20(a2),d5
	bne.s	loc_272C
	tst.w	d7
	rts
; ---------------------------------------------------------------------------

loc_2740:
	moveq	#0,d7
	rts
; End of function sub_2728


; =============== S U B	R O U T	I N E =======================================

;sub_2744
Manage_PlatformLoading:
	move.l	(Addr_PlatformLayout).w,d5
	beq.w	return_2874
	move.l	d5,a4	; pointer to start of platform list
	move.w	(PlatformLoader_Offset).w,d5
	lea	(a4,d5.w),a4	; pointer to some platform in platform list
	move.w	(a4),d7
	bpl.w	loc_2762
	; we're at the end of the platform list, go back to beginning.
	clr.w	(PlatformLoader_Offset).w
	bra.s	Manage_PlatformLoading
; ---------------------------------------------------------------------------

loc_2762:
	move.l	(Addr_GfxObject_Kid).w,d7
	beq.w	return_2874
	move.l	d7,a1
	move.w	$1A(a1),d6	; Kid X pos
	moveq	#0,d7
	move.b	4(a4),d7	; Buffer absolute left edge (LL*2)
	asl.w	#5,d7		; times $20
	cmp.w	d6,d7		; compare to kid's X pos
	bgt.w	loc_2850	; platform out of range (left)
	moveq	#0,d7
	move.b	5(a4),d7
	asl.w	#5,d7
	cmp.w	d6,d7
	blt.w	loc_2850	; platform out of range (right)
	move.w	$1E(a1),d6	; Kid y pos
	moveq	#0,d7
	move.b	6(a4),d7
	asl.w	#5,d7
	cmp.w	d6,d7
	bgt.w	loc_2850	; platform out of range (top)
	moveq	#0,d7
	move.b	7(a4),d7
	asl.w	#5,d7
	cmp.w	d6,d7
	blt.w	loc_2850	; platform out of range (bottom)
	bsr.w	sub_2728
	bne.w	loc_286E
	bsr.w	Allocate_PlatformSlot	; load platform to list
	move.w	(PlatformLoader_Offset).w,$20(a3)	; --> a3
	clr.l	$A(a3)
	clr.l	$E(a3)
	move.w	#1,x_direction(a3)
	_move.w	0(a4),d7
	asl.w	#4,d7
	move.w	d7,2(a3)	; load x pos from platform layout
	clr.w	4(a3)
	move.w	2(a4),d7
	asl.w	#4,d7
	move.w	d7,6(a3)	; y pos
	clr.w	8(a3)
	moveq	#0,d7
	move.b	9(a4),d7	; horizontal/vertical size in blocks
	move.l	d7,d6
	andi.w	#$F,d6
	addq.w	#1,d6
	asl.w	#4,d6
	subq.w	#1,d6
	andi.w	#$F0,d7
	addi.w	#$10,d7
	subq.w	#1,d7
	move.w	d7,x_pos(a3)	; x size in pixels
	move.w	d6,$1C(a3)	; y size in pixels
	move.b	8(a4),d7
	move.b	d7,$1F(a3)	; t/s bits from platform layout
    if platforms_newtype = 0
	bclr	#7,d7
    else
	and.b	#$F,d7
    endif
	ext.w	d7
	bne.w	loc_2822
	subq.w	#2,$1C(a3)

loc_2822:
	move.w	PlatformArtAddr_Table(pc,d7.w),d7
	move.w	d7,$18(a3)
	bra.w	loc_2836
; ---------------------------------------------------------------------------
; VRAM addresses for platform art for each type of special platform
;word_282E
PlatformArtAddr_Table:
	dc.w $6AE
	dc.w $94
	dc.w $6AE
	dc.w $25A
; ---------------------------------------------------------------------------

loc_2836:
	tst.b	$1F(a3)
	bmi.w	loc_2876
	; scripted platform
	move.l	#PlatformScript_BaseAddress,d7
	add.w	$A(a4),d7
	move.l	d7,$12(a3)
	bra.w	loc_286E
; ---------------------------------------------------------------------------

loc_2850:
	bsr.w	sub_2728
	beq.w	loc_286E
	move.w	a2,a3
	tst.b	$1F(a3)
	bpl.w	loc_286A
	st	$12(a3)
	bra.w	loc_286E
; ---------------------------------------------------------------------------

loc_286A:
	bsr.w	Deallocate_PlatformSlot

loc_286E:
	addi.w	#$C,(PlatformLoader_Offset).w

return_2874:
	rts
; ---------------------------------------------------------------------------

loc_2876:	; special platform
	move.l	#off_40D2,a0
	add.w	$A(a4),a0
	move.l	(a0),d7	; code address for special platform
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	d7,4(a0)	; code for object
	move.w	a3,$44(a0)
	sf	$12(a3)
	bra.s	loc_286E
; End of function Manage_PlatformLoading


; =============== S U B	R O U T	I N E =======================================


Pal_FadeOut:
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_28A6:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_28A6
	moveq	#$3F,d0
	move.w	($FFFFFBCC).w,d1
	lea	($FFFF4F58).l,a0

loc_28B8:
	move.w	d1,(a0)+
	dbf	d0,loc_28B8
	move.w	#$100,($FFFFF876).w
	bra.s	loc_28DE
; ---------------------------------------------------------------------------

loc_28C6:
	bsr.w	WaitForVint
	bsr.w	Do_Nothing
	bsr.w	Palette_to_VRAM
	bsr.w	sub_14C0
	subi.w	#$10,($FFFFF876).w
	bmi.s	loc_28EA

loc_28DE:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_28C6
; ---------------------------------------------------------------------------

loc_28EA:
	bsr.w	WaitForVint
	bsr.w	Do_Nothing
	bsr.w	Palette_to_VRAM
	bsr.w	sub_14C0
	rts
; End of function Pal_FadeOut


; =============== S U B	R O U T	I N E =======================================


sub_28FC:
	lea	($FFFFF01E).w,a0
	move.w	#$7A,d7
	moveq	#0,d6

loc_2906:
	move.l	d6,(a0)+
	dbf	d7,loc_2906
	lea	($FFFFF01E).w,a1
	move.w	a1,($FFFFFA9C).w
	clr.w	($FFFFFA9E).w
	move.w	#6,($FFFFFAA0).w
	rts
; End of function sub_28FC

; ---------------------------------------------------------------------------
	move.w	($FFFFFA9C).w,a0
	move.w	a0,a1
	st	(a0)

loc_2928:
	st	1(a0)
	bra.s	loc_293A

; =============== S U B	R O U T	I N E =======================================


sub_292E:
	move.w	($FFFFFA9C).w,a0
	move.w	a0,a1
	st	(a0)
	sf	1(a0)

loc_293A:
	addq.w	#2,a1
	moveq	#4,d7
	lea	(unk_29E8).l,a5
	lea	(unk_29F2).l,a4
	movem.l	a6,-(sp)
	cmpi.w	#2,d6
	beq.s	loc_2988
	tst.w	d6
	beq.s	loc_297A
	cmpi.w	#1,d6
	beq.s	loc_296C
	lea	(unk_2A24).l,a6
	lea	(unk_2A2E).l,a2
	bra.s	loc_2994
; ---------------------------------------------------------------------------

loc_296C:
	lea	(unk_2A38).l,a6
	lea	(unk_2A42).l,a2
	bra.s	loc_2994
; ---------------------------------------------------------------------------

loc_297A:
	lea	(unk_2A10).l,a6
	lea	(unk_2A1A).l,a2
	bra.s	loc_2994
; ---------------------------------------------------------------------------

loc_2988:
	lea	(unk_29FC).l,a6
	lea	(unk_2A06).l,a2

loc_2994:
	move.w	x_pos(a3),d4
	move.w	d7,d0
	add.w	d0,d0
	add.w	(a5,d0.w),d4
	move.w	d4,$C(a1)
	move.w	y_pos(a3),d5
	add.w	(a4,d0.w),d5
	move.w	d5,4(a1)
	move.w	(a6,d0.w),8(a1)
	_move.w	(a2,d0.w),0(a1)
	addi.w	#$10,a1
	dbf	d7,loc_2994
	movem.l	(sp)+,a6
	subq.w	#1,($FFFFFAA0).w
	bne.s	loc_29DE
	lea	($FFFFF01E).w,a1
	move.w	a1,($FFFFFA9C).w
	move.w	#6,($FFFFFAA0).w
	rts
; ---------------------------------------------------------------------------

loc_29DE:
	lea	$52(a0),a0
	move.w	a0,($FFFFFA9C).w
	rts
; End of function sub_292E

; ---------------------------------------------------------------------------
unk_29E8:	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   4
unk_29F2:	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   4
unk_29FC:	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
unk_2A06:	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $FB ; �
unk_2A10:	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FE ; �
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b $FF
	dc.b $FF
unk_2A1A:	dc.b $FF
	dc.b $FE ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FE ; �
unk_2A24:	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   1
unk_2A2E:	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
unk_2A38:	dc.b $FF
	dc.b $FB ; �
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FE ; �
	dc.b $FF
	dc.b $FF
unk_2A42:	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �
	dc.b $FF
	dc.b $FD ; �

; =============== S U B	R O U T	I N E =======================================


sub_2A4C:
	move.w	#6,($FFFFFA9E).w
	lea	($FFFFF01E).w,a0

loc_2A56:
	move.w	a0,a1
	tst.b	(a0)
	beq.w	loc_2BA6
	addq.w	#2,a1
	move.l	(Addr_NextSpriteSlot).w,a2
	moveq	#0,d0
	move.b	(Number_Sprites).w,d0
	move.w	#$8228,d4
	move.w	(Camera_Y_pos).w,d1
	move.w	(Camera_X_pos).w,d2
	move.w	#$80,d3
	move.l	#$36B0,d7
	_move.l	0(a1),d6
	add.l	d6,4(a1)
	move.l	8(a1),d5
	add.l	d5,$C(a1)
	_add.l	d7,0(a1)
	move.w	4(a1),d6
	sub.w	d1,d6
	cmpi.w	#$FF9C,d6
	blt.w	loc_2B9C
	cmpi.w	#$E0,d6
	bge.w	loc_2B9C
	add.w	d3,d6
	move.w	$C(a1),d5
	sub.w	d2,d5
	bmi.w	loc_2B9C
	cmpi.w	#$140,d5
	bge.w	loc_2B9C
	add.w	d3,d5
	move.w	d6,(a2)+
	addq.w	#1,d0
	move.w	d0,(a2)+
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	addi.w	#$10,a1
	_move.l	0(a1),d6
	add.l	d6,4(a1)
	move.l	8(a1),d5
	add.l	d5,$C(a1)
	_add.l	d7,0(a1)
	move.w	4(a1),d6
	sub.w	d1,d6
	add.w	d3,d6
	move.w	$C(a1),d5
	sub.w	d2,d5
	add.w	d3,d5
	move.w	d6,(a2)+
	addq.w	#1,d0
	move.w	d0,(a2)+
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	addi.w	#$10,a1
	_move.l	0(a1),d6
	add.l	d6,4(a1)
	move.l	8(a1),d5
	add.l	d5,$C(a1)
	_add.l	d7,0(a1)
	move.w	4(a1),d6
	sub.w	d1,d6
	add.w	d3,d6
	move.w	$C(a1),d5
	sub.w	d2,d5
	add.w	d3,d5
	move.w	d6,(a2)+
	addq.w	#1,d0
	move.w	d0,(a2)+
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	addi.w	#$10,a1
	_move.l	0(a1),d6
	add.l	d6,4(a1)
	move.l	8(a1),d5
	add.l	d5,$C(a1)
	_add.l	d7,0(a1)
	move.w	4(a1),d6
	sub.w	d1,d6
	add.w	d3,d6
	move.w	$C(a1),d5
	sub.w	d2,d5
	add.w	d3,d5
	move.w	d6,(a2)+
	addq.w	#1,d0
	move.w	d0,(a2)+
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	addi.w	#$10,a1
	_move.l	0(a1),d6
	add.l	d6,4(a1)
	move.l	8(a1),d5
	add.l	d5,$C(a1)
	_add.l	d7,0(a1)
	move.w	4(a1),d6
	sub.w	d1,d6
	add.w	d3,d6
	move.w	$C(a1),d5
	sub.w	d2,d5
	cmpi.w	#$1EF,d5
	bge.w	loc_2B9C
	add.w	d3,d5
	move.w	d6,(a2)+
	addq.w	#1,d0
	move.w	d0,(a2)+
	move.w	d4,(a2)+
	move.w	d5,(a2)+
	bra.s	loc_2B9E
; ---------------------------------------------------------------------------

loc_2B9C:
	sf	(a0)

loc_2B9E:
	move.l	a2,(Addr_NextSpriteSlot).w
	move.b	d0,(Number_Sprites).w

loc_2BA6:
	subq.w	#1,($FFFFFA9E).w
	beq.s	return_2BB4
	lea	$52(a0),a0
	bra.w	loc_2A56
; ---------------------------------------------------------------------------

return_2BB4:
	rts
; End of function sub_2A4C

; ---------------------------------------------------------------------------
; Include all relevant platform layouts into the disasm
; 2BB6
PlatformLayout_BaseAddress:
	include    "level/platform_includes.asm"

;PlatformScript_BaseAddress:
;PlatformScript_3602:
	include	"level/platform_scripts.asm"

off_40D2:
	dc.l SoftPlatform_Init	; soft platform
	dc.l TrapPlatformDown_Init	; trap platform down
	dc.l TrapPlatformUp_Init	; trap platform up
	dc.l PlatformChain_Init	; chain, like in The Black Pit
; ---------------------------------------------------------------------------
;loc_40E2
SoftPlatform_Init:
	move.w	$44(a5),a3	; get corresponding platform object
	move.l	(Addr_GfxObject_Kid).w,a2	; Kid Gfx Object
	move.w	6(a3),d0	; y pos of platform

SoftPlatform_WaitLoop:
	move.l	$2A(a2),d1	; kid y velocity
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a3)
	bne.w	SoftPlatform_Delete	; delete platform and object
	bsr.w	SoftPlatform_Move	; add y vel to y pos
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.s	SoftPlatform_WaitLoop
	cmp.w	a3,d7
	bne.s	SoftPlatform_WaitLoop
	; Kid is currently standing on THIS platform
	cmpi.w	#Iron_Knight,(Current_Helmet).w
	beq.w	+
	asr.l	#1,d1	; for everything but iron knight, divide by 2
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.w	+
	asr.l	#1,d1	; for micromax, divide by 4
+
	move.l	d1,$E(a3)	; assign as platform's y vel

SoftPlatform_BounceLoop:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	SoftPlatform_Move
	move.l	$E(a3),d7
	subi.l	#$7000,d7
	cmpi.l	#-$18000,d7
	bgt.w	+
	move.l	#-$18000,d7
+
	move.l	d7,$E(a3)
	cmp.w	6(a3),d0	;compare to original y pos
	blt.s	SoftPlatform_BounceLoop
	move.w	d0,6(a3)	; if higher up than that, set it to original y pos
	clr.w	8(a3)		; clear subpixels
	clr.l	$E(a3)		; clear speed

loc_4160:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.s	SoftPlatform_WaitLoop
	cmp.w	a3,d7
	bne.s	SoftPlatform_WaitLoop
	bra.s	loc_4160

; =============== S U B	R O U T	I N E =======================================

SoftPlatform_Move:
	move.l	$E(a3),d7
	add.l	d7,6(a3)
	rts
; End of function SoftPlatform_Move

; ---------------------------------------------------------------------------

SoftPlatform_Delete:
	bsr.w	Deallocate_PlatformSlot
	jmp	Delete_CurrentObject(pc)
; ---------------------------------------------------------------------------
;loc_4182
TrapPlatformDown_Init:
	move.w	$44(a5),a3	; platform object
	move.l	(Addr_GfxObject_Kid).w,a2	; kid gfxobject

TrapPlatformDown_WaitLoop:
	move.l	$2A(a2),d1
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a3)
	bne.w	TrapPlatformDown_Delete
	bsr.w	TrapPlatformDown_Move
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.s	TrapPlatformDown_WaitLoop
	cmp.w	a3,d7
	bne.s	TrapPlatformDown_WaitLoop
	; Kid is currently standing on THIS platform
	asr.l	#2,d1
	move.l	d1,$E(a3)

TrapPlatformDown_MoveLoop:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	TrapPlatformDown_Move
	move.l	$E(a3),d7
	addi.l	#$4000,d7
	cmpi.l	#$40000,d7
	blt.w	+
	move.l	#$20000,d7	; this is a bug. Should be $40000
+
	move.l	d7,$E(a3)
	move.w	6(a3),d7
	sub.w	$1E(a2),d7
	cmpi.w	#$E0,d7
	blt.s	TrapPlatformDown_MoveLoop
	clr.l	$E(a3)
	move.l	#$800,2(a3)

loc_41EE:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a3)
	beq.s	loc_41EE

TrapPlatformDown_Delete:
	bsr.w	Deallocate_PlatformSlot
	jmp	Delete_CurrentObject(pc)

; =============== S U B	R O U T	I N E =======================================


TrapPlatformDown_Move:
	move.l	$E(a3),d7
	add.l	d7,6(a3)
	rts
; End of function TrapPlatformDown_Move


; =============== S U B	R O U T	I N E =======================================

;sub_420A
TrapPlatformUp_Init:
	move.w	$44(a5),a3
	move.l	(Addr_GfxObject_Kid).w,a2

TrapPlatformUp_Loop:
	move.l	$2A(a2),d1
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a3)
	bne.w	TrapPlatformUp_Delete
	bsr.w	TrapPlatformUp_Move
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.s	TrapPlatformUp_Loop
	cmp.w	a3,d7
	bne.s	TrapPlatformUp_Loop
	; Kid is currently standing on THIS platform
loc_4230:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	TrapPlatformUp_Move
	move.l	$E(a3),d7
	subi.l	#$4000,d7
	cmpi.l	#-$40000,d7
	bgt.w	+
	move.l	#-$40000,d7
+
	move.l	d7,$E(a3)
	move.w	6(a3),d7
	sub.w	$1E(a2),d7
	cmpi.w	#-$E0,d7
	bgt.s	loc_4230
	clr.l	$E(a3)
	move.l	#$800,2(a3)

loc_4270:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a3)
	beq.s	loc_4270

TrapPlatformUp_Delete:
	bsr.w	Deallocate_PlatformSlot
	jmp	Delete_CurrentObject(pc)
; End of function TrapPlatformUp_Init


; =============== S U B	R O U T	I N E =======================================

TrapPlatformUp_Move:
	move.l	$E(a3),d7
	add.l	d7,6(a3)
	rts
; End of function TrapPlatformUp_Move


; =============== S U B	R O U T	I N E =======================================

;sub_428C
PlatformChain_Init:
	lea	$44(a5),a1	; platform object
	move.w	(a1)+,a0	; next platform object --> to be filled with pointers to the platforms in the chain
	move.w	$1A(a0),d6	; horizontal size
	addq.w	#1,d6
	move.w	2(a0),d4	; x pos
	moveq	#5,d5		; load 6 new platform objects
-
	add.w	d6,d4
	bsr.w	PlatformChain_LoadPlatform
	dbf	d5,-
	bsr.w	PlatformChain_SetMoveDown
	moveq	#$3C,d0

PlatformChain_DownLoop:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a0)
	bne.w	PlatformChain_Delete
	bsr.w	PlatformChain_MovePlatforms
	dbf	d0,PlatformChain_DownLoop
	bsr.w	PlatformChain_SetMoveUp
	moveq	#$78,d0

PlatformChain_UpLoop:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$12(a0)
	bne.w	PlatformChain_Delete
	bsr.w	PlatformChain_MovePlatforms
	dbf	d0,PlatformChain_UpLoop
	bsr.w	PlatformChain_SetMoveDown
	moveq	#$78,d0
	bra.s	PlatformChain_DownLoop
; ---------------------------------------------------------------------------
; deallocate the 6 platform objects and delete object
;loc_42E4
PlatformChain_Delete:
	lea	$44(a5),a4
	moveq	#6,d6
-
	move.w	(a4)+,a3
	bsr.w	Deallocate_PlatformSlot
	dbf	d6,-
	jmp	Delete_CurrentObject(pc)
; End of function PlatformChain_Init


; =============== S U B	R O U T	I N E =======================================
; set Y vel of platforms to move down
;sub_42F8
PlatformChain_SetMoveDown:
	lea	$44(a5),a4
	lea	PlatformChain_YVelocities(pc),a2
	moveq	#6,d6
-
	move.w	(a4)+,a3
	move.l	(a2)+,$E(a3)
	dbf	d6,-
	rts
; End of function PlatformChain_SetMoveDown


; =============== S U B	R O U T	I N E =======================================
; set Y vel of platforms to move up
;sub_430E
PlatformChain_SetMoveUp:
	lea	$44(a5),a4
	lea	PlatformChain_YVelocities(pc),a2
	moveq	#6,d6
-
	move.w	(a4)+,a3
	move.l	(a2)+,d7
	neg.l	d7
	move.l	d7,$E(a3)
	dbf	d6,-
	rts
; End of function PlatformChain_SetMoveUp


; =============== S U B	R O U T	I N E =======================================

;sub_4328
PlatformChain_LoadPlatform:
	bsr.w	Allocate_PlatformSlot
	move.w	a3,(a1)+
	move.b	$1F(a0),$1F(a3)
	move.w	d4,2(a3)
	move.w	6(a0),6(a3)
	move.w	#1,$20(a3)
	move.w	$1A(a0),x_pos(a3)
	move.w	$1C(a0),$1C(a3)
	move.w	$18(a0),$18(a3)
	rts
; End of function PlatformChain_LoadPlatform


; =============== S U B	R O U T	I N E =======================================

;sub_4358
PlatformChain_MovePlatforms:
	lea	$44(a5),a4
	moveq	#6,d6
-
	move.w	(a4)+,a3
	move.l	$E(a3),d7
	add.l	d7,6(a3)
	dbf	d6,-
	rts
; End of function PlatformChain_MovePlatforms

; ---------------------------------------------------------------------------
;unk_436E
PlatformChain_YVelocities:
	dc.l	 $4000
	dc.l	 $8000
	dc.l	$10000
	dc.l	$14000
	dc.l	$10000
	dc.l	 $8000
	dc.l	 $4000
	; from here on unused
	dc.l	 $4000
	dc.l	 $8000
	dc.l	$10000
	dc.l	$14000
	dc.l	$10000
	dc.l	 $8000
	dc.l	 $4000

; For each map, which platform layout to use.
; If it is PlatformLayout_Blank, then use layout level/platform/00.asm which
; contains no platforms.
MapPtfmLayout_Index:
	include    "level/platform_index.asm"

PlatformLayout_Blank:   include    "level/platform/00.asm"

; =============== S U B	R O U T	I N E =======================================


sub_44B0:
	move.b	#1,($FFFFFA58).w
	move.b	#2,($FFFFFA5C).w
	move.b	#3,($FFFFFA5B).w
	move.b	#4,($FFFFFA59).w
	move.b	#5,($FFFFFA5A).w
	rts
; End of function sub_44B0


; =============== S U B	R O U T	I N E =======================================


sub_44D0:
	move.w	#$1F,d6

loc_44D4:
	move.l	(a4)+,(a6)
	dbf	d6,loc_44D4
	rts
; End of function sub_44D0


; =============== S U B	R O U T	I N E =======================================


sub_44DC:
	move.b	($FFFFFA5B).w,d7
	ext.w	d7
	subq.w	#1,d7
	bne.w	loc_4546
	move.b	($FFFFFA60).w,d7
	ext.w	d7
	addq.w	#2,d7
	move.b	d7,($FFFFFA60).w

loc_44F4:
	lea	AniArt_Coin(pc,d7.w),a4
	move.b	(a4)+,d7
	bpl.w	loc_4534
	moveq	#0,d7
	move.b	d7,($FFFFFA60).w
	bra.s	loc_44F4
; ---------------------------------------------------------------------------
ANIART_COIN_SIZE	= $80
AniArt_Coin:	dc.b   6
	dc.b   0
	dc.b   6
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b $14
	dc.b   6
	dc.b $10
	dc.b   6
	dc.b  $C
	dc.b   6
	dc.b $10
	dc.b   6
	dc.b $14
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b   4
	dc.b $FF
	dc.b $FF
off_451C:	dc.l ArtUnc_4992
	dc.l ArtUnc_4992+1*ANIART_COIN_SIZE
	dc.l ArtUnc_4992+2*ANIART_COIN_SIZE
	dc.l ArtUnc_4992+3*ANIART_COIN_SIZE
	dc.l ArtUnc_4992+4*ANIART_COIN_SIZE
	dc.l ArtUnc_4992+5*ANIART_COIN_SIZE
; ---------------------------------------------------------------------------

loc_4534:
	move.b	(a4),d6
	ext.w	d6
	move.l	off_451C(pc,d6.w),a4
	move.l	#vdpComm($4720,VRAM,WRITE),4(a6)
	bsr.s	sub_44D0

loc_4546:
	move.b	d7,($FFFFFA5B).w
	move.b	($FFFFFA59).w,d7
	ext.w	d7
	subq.w	#1,d7
	bne.w	loc_459A
	move.b	($FFFFFA5E).w,d7
	ext.w	d7
	addq.w	#2,d7

loc_455E:
	move.b	d7,($FFFFFA5E).w
	lea	AniArt_LifeIcon(pc,d7.w),a4
	move.b	(a4)+,d7
	bpl.w	loc_4586
	moveq	#0,d7
	bra.s	loc_455E
; ---------------------------------------------------------------------------
ANIART_LIFEICON_SIZE	= $80
AniArt_LifeIcon:dc.b $48 ; H
	dc.b   0
	dc.b   6
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b   4
	dc.b $FF
	dc.b $FF
off_457A:	dc.l ArtUnc_4692
	dc.l ArtUnc_4692+1*ANIART_LIFEICON_SIZE
	dc.l ArtUnc_4692+2*ANIART_LIFEICON_SIZE
; ---------------------------------------------------------------------------

loc_4586:
	move.b	(a4),d6
	ext.w	d6
	move.l	off_457A(pc,d6.w),a4
	move.l	#vdpComm($4620,VRAM,WRITE),4(a6)
	bsr.w	sub_44D0

loc_459A:
	move.b	d7,($FFFFFA59).w
	move.b	($FFFFFA5A).w,d7
	ext.w	d7
	subq.w	#1,d7
	bne.w	loc_45EE
	move.b	($FFFFFA5F).w,d7
	ext.w	d7
	addq.w	#2,d7

loc_45B2:
	move.b	d7,($FFFFFA5F).w
	lea	AniArt_Clock(pc,d7.w),a4
	move.b	(a4)+,d7
	bpl.w	loc_45DA
	moveq	#0,d7
	bra.s	loc_45B2
; ---------------------------------------------------------------------------
ANIART_CLOCK_SIZE	= $80
AniArt_Clock:	dc.b $48 ; H
	dc.b   0
	dc.b   6
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b   4
	dc.b $FF
	dc.b $FF
off_45CE:	dc.l ArtUnc_4812
	dc.l ArtUnc_4812+1*ANIART_CLOCK_SIZE
	dc.l ArtUnc_4812+2*ANIART_CLOCK_SIZE
; ---------------------------------------------------------------------------

loc_45DA:
	move.b	(a4),d6
	ext.w	d6
	move.l	off_45CE(pc,d6.w),a4
	move.l	#vdpComm($46A0,VRAM,WRITE),4(a6)
	bsr.w	sub_44D0

loc_45EE:
	move.b	d7,($FFFFFA5A).w
	move.b	($FFFFFA58).w,d7
	ext.w	d7
	subq.w	#1,d7
	bne.w	loc_4630
	move.b	($FFFFFA5D).w,d7
	ext.w	d7
	addq.w	#2,d7
	move.b	d7,($FFFFFA5D).w

loc_460A:
	lea	unk_461C(pc,d7.w),a4
	move.b	(a4)+,d7
	bpl.w	loc_4626
	moveq	#0,d7
	move.b	d7,($FFFFFA5D).w
	bra.s	loc_460A
; ---------------------------------------------------------------------------
unk_461C:	dc.b   6
	dc.b   0
	dc.b   6
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b  $C
	dc.b $FF
	dc.b $FF
; ---------------------------------------------------------------------------

loc_4626:
	move.b	(a4),d6
	ext.w	d6
	move.w	d6,a0
	bsr.w	sub_5D4A

loc_4630:
	move.b	d7,($FFFFFA58).w
	move.b	($FFFFFA5C).w,d7
	ext.w	d7
	subq.w	#1,d7
	bne.w	loc_468C
	move.b	($FFFFFA61).w,d7
	ext.w	d7
	addq.w	#2,d7

loc_4648:
	move.b	d7,($FFFFFA61).w
	lea	AniArt_Flag(pc,d7.w),a4
	move.b	(a4)+,d7
	bpl.w	loc_4680
	moveq	#0,d7
	bra.s	loc_4648
; ---------------------------------------------------------------------------
ANIART_FLAG_SIZE	= $280
AniArt_Flag:	dc.b   6
	dc.b   0
	dc.b   6
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   6
	dc.b  $C
	dc.b   6
	dc.b $10
	dc.b   6
	dc.b $14
	dc.b $FF
	dc.b $FF
off_4668:	dc.l ArtUnc_4C92
	dc.l ArtUnc_4C92+1*ANIART_FLAG_SIZE
	dc.l ArtUnc_4C92+2*ANIART_FLAG_SIZE
	dc.l ArtUnc_4C92+3*ANIART_FLAG_SIZE
	dc.l ArtUnc_4C92+4*ANIART_FLAG_SIZE
	dc.l ArtUnc_4C92+5*ANIART_FLAG_SIZE
; ---------------------------------------------------------------------------

loc_4680:
	move.b	(a4),d6
	ext.w	d6
	move.l	off_4668(pc,d6.w),a1
	bsr.w	sub_5DA6

loc_468C:
	move.b	d7,($FFFFFA5C).w
	rts
; End of function sub_44DC

; ---------------------------------------------------------------------------
ArtUnc_4692:   binclude    "ingame/artunc/Life_icon_(3_frames).bin"
ArtUnc_4812:   binclude    "ingame/artunc/Clock_icon_(3_frames).bin"
ArtUnc_4992:   binclude    "ingame/artunc/Coin_continue_icon_(6_frames).bin"
	align_dmasafe	(6*ANIART_FLAG_SIZE)
ArtUnc_4C92:   binclude    "ingame/artunc/End_of_level_Flag_(6_frames).bin"
ArtComp_5B92:   binclude    "ingame/artcomp/Horizontal_platform.bin"
ArtComp_5C83:   binclude    "ingame/artcomp/Vertical_platform.bin"
	align	2
; =============== S U B	R O U T	I N E =======================================
ANIART_DIAMOND_SIZE	= $200

sub_5D4A:
	addi.l	#off_7B0AC,a0
	move.l	(a0),d1
	addq.l	#2,d1		; d1 = DMA source address
	jsr	(j_Stop_z80).l
	move.l	#(($9300|((ANIART_DIAMOND_SIZE&$1FE)>>1))<<16)|($9400|(ANIART_DIAMOND_SIZE>>9)),4(a6)	; DMA length
	move.l	d1,d0
	lsr.l	#1,d0
	move.w	d0,d1
	andi.w	#$FF,d1

loc_5D6C:
	addi.w	#$9500,d1
	move.w	d1,4(a6)
	move.w	d0,d1
	lsr.w	#8,d1
	addi.w	#$9600,d1
	move.w	d1,4(a6)
	swap	d0
	addi.w	#$9700,d0
	move.w	d0,4(a6)
	move.l	#vdpComm($DD40,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	rts
; End of function sub_5D4A


; =============== S U B	R O U T	I N E =======================================


sub_5DA6:
	move.l	a1,d1		; d1 = DMA source address
	jsr	(j_Stop_z80).l
	move.l	#(($9300|((ANIART_FLAG_SIZE&$1FE)>>1))<<16)|($9400|(ANIART_FLAG_SIZE>>9)),4(a6)	; DMA length
	move.l	d1,d0
	lsr.l	#1,d0
	move.w	d0,d1
	andi.w	#$FF,d1
	addi.w	#$9500,d1
	move.w	d1,4(a6)
	move.w	d0,d1
	lsr.w	#8,d1
	addi.w	#$9600,d1
	move.w	d1,4(a6)
	swap	d0
	addi.w	#$9700,d0
	move.w	d0,4(a6)
	move.l	#vdpComm($D340,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	rts
; End of function sub_5DA6

; ---------------------------------------------------------------------------
unk_5DFA:	dc.b $A2 ; �
	dc.b $FB ; �
	dc.b $A3 ; �
	dc.b $1F
	dc.b $A3 ; �
	dc.b $43 ; C
	dc.b $A3 ; �
	dc.b $67 ; g

; =============== S U B	R O U T	I N E =======================================


sub_5E02:
	tst.b	(MurderWall_flag).w
	beq.w	return_5F68
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	($FFFFFAC4).w,d0
	tst.b	(MurderWall_flag2).w
	beq.s	loc_5E24
	addi.w	#$110,d0
	sub.w	(Kid_hitbox_right).w,d0
	ble.s	loc_5E34
	bra.s	loc_5E3A
; ---------------------------------------------------------------------------

loc_5E24:
	addi.w	#$30,d0
	sub.w	(Kid_hitbox_left).w,d0
	blt.s	loc_5E3A
	move.w	#$30,$3A(a0)

loc_5E34:
	move.w	#4,$38(a0)

loc_5E3A:
	move.w	(Camera_X_pos).w,d3
	sub.w	($FFFFFAC4).w,d3
	tst.b	(MurderWall_flag2).w
	beq.s	loc_5E4A
	neg.w	d3

loc_5E4A:
	cmpi.w	#$30,d3
	blt.s	loc_5E52
	rts
; ---------------------------------------------------------------------------

loc_5E52:
	move.w	#$80,d6
	tst.b	(MurderWall_flag2).w
	beq.s	loc_5E64
	addi.w	#$110,d6
	add.w	d3,d6
	bra.s	loc_5E66
; ---------------------------------------------------------------------------

loc_5E64:
	sub.w	d3,d6

loc_5E66:
	move.w	#$80,d7
	clr.l	d5
	move.w	(Camera_Y_pos).w,d5
	divu.w	#$30,d5
	swap	d5
	sub.w	d5,d7
	move.w	d7,d4
	subi.b	#1,($FFFFFAC0).w
	bne.s	loc_5E94
	move.b	#5,($FFFFFAC0).w
	addi.b	#1,($FFFFFABF).w
	andi.b	#3,($FFFFFABF).w

loc_5E94:
	move.b	($FFFFFABF).w,d2
	add.b	d2,d2
	ext.w	d2
	lea	unk_5DFA(pc),a1
	move.w	(a1,d2.w),d3
	moveq	#5,d0
	move.l	(Addr_NextSpriteSlot).w,a0
	tst.b	(MurderWall_flag2).w
	bne.w	loc_5F6A

loc_5EB2:
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#9,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	dbf	d0,loc_5EB2
	move.w	d4,d7
	addi.w	#$18,d6
	moveq	#5,d0

loc_5F0C:
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$12,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$1B,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	dbf	d0,loc_5F0C
	move.l	a0,(Addr_NextSpriteSlot).w

return_5F68:
	rts
; ---------------------------------------------------------------------------

loc_5F6A:
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$812,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$81B,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	dbf	d0,loc_5F6A
	move.w	d4,d7
	addi.w	#$18,d6
	moveq	#5,d0

loc_5FCA:
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$809,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	move.w	d6,6(a0)
	_move.w	d7,0(a0)
	move.w	#$A00,d5
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d5
	move.w	d5,2(a0)
	move.w	d3,d2
	addi.w	#$800,d2
	move.w	d2,4(a0)
	lea	8(a0),a0
	addi.w	#$18,d7
	dbf	d0,loc_5FCA
	move.l	a0,(Addr_NextSpriteSlot).w
	rts
; End of function sub_5E02

; ---------------------------------------------------------------------------
dword_6028:	dc.l 0
	dc.l sub_6048
	dc.l sub_6048

; =============== S U B	R O U T	I N E =======================================


sub_6034:
	move.w	(Level_Special_Effects).w,d0
	subq.w	#1,d0
	ble.s	return_6046
	add.w	d0,d0
	add.w	d0,d0
	move.l	dword_6028(pc,d0.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------

return_6046:
	rts
; End of function sub_6034


; =============== S U B	R O U T	I N E =======================================


sub_6048:
	move.w	(Frame_Counter).w,d6
	cmpi.w	#$4B0,d6 ; Timer: 0x04B0, decimal 1200/60=20 seconds (triggers storm theme) 
	bls.w	loc_61C2
	move.w	($FFFFFADA).w,($FFFFF876).w
	beq.w	loc_60EE
	move.b	#$7F,($FFFFF88B).w
	move.b	#$80,($FFFFF888).w
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1
	move.w	#$1F,d0

loc_607A:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_607A
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4F58).l,a1
	move.w	#$1F,d0

loc_6090:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_6090
	move.l	($FFFFFADE).w,a0
	lea	($FFFF4F8A).l,a1
	moveq	#6,d0
	cmpi.w	#Mountain,(Foreground_theme).w
	beq.s	loc_60C0

loc_60AA:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_60AA
	move.w	#0,($FFFF4F58).l
	subq.w	#4,($FFFFFADA).w
	bra.w	loc_61C2
; ---------------------------------------------------------------------------

loc_60C0:
	move.w	(a0)+,($FFFF4F58).l

loc_60C6:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_60C6
	move.w	#$FFFF,($FFFFF888).w
	move.l	(LnkTo_Pal_7B774).l,a0
	lea	($FFFF4F5A).l,a1
	moveq	#$E,d0

loc_60E0:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_60E0
	subq.w	#4,($FFFFFADA).w
	bra.w	loc_61C2
; ---------------------------------------------------------------------------

loc_60EE:
	cmpi.w	#WeatherID_Storm_and_Hail,(Level_Special_Effects).w
	bgt.s	loc_6172
	cmpi.w	#Mountain,(Background_theme).w
	bne.s	loc_6172
	cmpi.w	#$5DC,d6 ; Timer: 0x05DC, decimal 1500/60=25 seconds (triggers thunder storm)
	bls.w	loc_61C2
	subi.w	#1,($FFFFFADC).w
	bmi.s	loc_613E
	bne.s	loc_6172
	move.l	d0,-(sp)
	moveq	#sfx_Thunderstorm,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	#0,($FFFFFADC).w
	move.l	(LnkTo_Pal_7B86C).l,a0
	move.w	(a0)+,(Palette_Buffer).l
	lea	(Palette_Buffer+$32).l,a1
	moveq	#6,d0

loc_6136:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_6136
	bra.s	loc_6172
; ---------------------------------------------------------------------------

loc_613E:
	cmpi.w	#$FFE5,($FFFFFADC).w
	bne.s	loc_6172
	move.w	#$F7,($FFFFFADC).w
	jsr	(j_Get_RandomNumber_byte).w
	andi.b	#$F5,d7
	sub.w	d7,($FFFFFADC).w
	move.l	(LnkTo_Pal_7B85C).l,a0
	move.w	(a0)+,(Palette_Buffer).l
	lea	(Palette_Buffer+$32).l,a1
	moveq	#6,d0

loc_616C:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_616C

loc_6172:
	cmpi.w	#$834,d6 ; Timer: 0x0834, decimal 2100/60=35 seconds (triggers snow)
	bls.s	loc_61C2
	cmpi.w	#WeatherID_Storm_and_Hail,(Level_Special_Effects).w
	bne.s	return_61C0
	cmpi.w	#$873,(Frame_Counter).w ; Timer: 0x0873, decimal 2163/60=36 seconds (triggers ice balls)
	bls.s	return_61C0
	subi.w	#1,($FFFFFB52).w
	bne.s	loc_61A8
	tst.b	($FFFFFB54).w
	bne.s	loc_619C
	move.w	#$258,($FFFFFB52).w

loc_619C:
	addi.w	#$258,($FFFFFB52).w
	eori.b	#$FF,($FFFFFB54).w

loc_61A8:
	tst.b	($FFFFFB54).w
	bne.s	loc_61BC
	cmpi.b	#5,($FFFFFB3D).w
	beq.s	return_61C0
	move.b	#2,($FFFFFB3C).w

loc_61BC:
	bsr.w	sub_61CA

return_61C0:
	rts
; ---------------------------------------------------------------------------

loc_61C2:
	move.b	#4,($FFFFFAD6).w
	rts
; End of function sub_6048


; =============== S U B	R O U T	I N E =======================================


sub_61CA:
	move.w	(Camera_X_pos).w,d0
	subi.w	#$10,d0
	move.w	(Camera_Y_pos).w,d1
	addi.w	#$E0,d1
	lea	($FFFFFAE2).w,a0
	move.l	a0,a1
	moveq	#4,d5

loc_61E2:
	tst.w	(a0)
	bmi.s	loc_621C
	addi.w	#4,(a0)
	subi.w	#1,2(a0)
	subi.b	#1,4(a0)
	bne.s	loc_6212
	move.b	#6,4(a0)
	cmpi.b	#5,5(a0)
	blt.s	loc_620C
	move.b	#$FF,5(a0)

loc_620C:
	addi.b	#1,5(a0)

loc_6212:
	cmp.w	(a0),d1
	blt.s	loc_6226
	cmp.w	2(a0),d0
	bgt.s	loc_6226

loc_621C:
	lea	6(a0),a0
	dbf	d5,loc_61E2
	bra.s	loc_623A
; ---------------------------------------------------------------------------

loc_6226:
	move.l	#$FFFFFFFF,(a0)
	addi.b	#1,($FFFFFB3D).w
	lea	6(a0),a0
	dbf	d5,loc_61E2

loc_623A:
	subq.b	#1,($FFFFFB3C).w
	bne.w	loc_62CE
	move.b	#$25,($FFFFFB3C).w
	jsr	(j_Get_RandomNumber_byte).w
	andi.b	#$F,d7
	sub.b	d7,($FFFFFB3C).w
	tst.b	($FFFFFB3D).w
	beq.s	loc_62CE
	moveq	#4,d5
	move.l	a1,a0

loc_625E:
	move.w	(a0),d0
	bmi.s	loc_626C
	lea	6(a0),a0
	dbf	d5,loc_625E
	bra.s	loc_62CE
; ---------------------------------------------------------------------------

loc_626C:
	jsr	(j_Get_RandomNumber_byte).w
	andi.w	#$FF,d7
	add.w	(Camera_X_pos).w,d7
	addi.w	#$28,d7
	move.w	(Camera_Y_pos).w,d6
	move.w	d7,d2
	swap	d2
	move.w	d6,d2
	clr.b	d0
	addi.w	#$F,d6
	lsr.w	#4,d6
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	move.w	d7,d6
	addi.w	#$F,d6
	lsr.w	#4,d6
	lsr.w	#4,d7
	cmp.w	d7,d6
	beq.s	loc_62AA
	st	d0

loc_62AA:
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4)+,d6
	andi.w	#$F,d6
	bne.s	loc_62CE
	tst.b	d0
	beq.s	loc_62C2
	move.w	(a4),d6
	andi.w	#$FF,d6
	bne.s	loc_62CE

loc_62C2:
	subi.b	#1,($FFFFFB3D).w
	move.w	d2,(a0)+
	swap	d2
	move.w	d2,(a0)+

loc_62CE:
	moveq	#4,d5
	move.l	(Addr_GfxObject_Kid).w,a5
	move.l	a1,a0

loc_62D6:
	move.w	(a0),d0
	bmi.s	loc_630C
	addi.w	#2,d0
	cmp.w	(Kid_hitbox_top).w,d0
	blt.s	loc_630C
	addi.w	#$C,d0
	cmp.w	(Kid_hitbox_bottom).w,d0
	bgt.s	loc_630C
	move.w	2(a0),d0
	addi.w	#2,d0
	cmp.w	(Kid_hitbox_right).w,d0
	bgt.s	loc_630C
	addi.w	#$C,d0
	cmp.w	(Kid_hitbox_left).w,d0
	blt.s	loc_630C
	move.w	#$28,$38(a5)

loc_630C:
	lea	6(a0),a0
	dbf	d5,loc_62D6
	moveq	#4,d5
	move.l	a1,a0

loc_6318:
	lea	($FFFFFB00).w,a2
	clr.b	d0
	move.w	(a0),d7
	bmi.s	loc_6384
	move.w	2(a0),d6
	addi.w	#$F,d7
	lsr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	d6,d7
	addi.w	#$F,d7
	lsr.w	#4,d7
	lsr.w	#4,d6
	cmp.w	d6,d7
	beq.s	loc_6348
	st	d0

loc_6348:
	add.w	d6,d6
	add.w	d6,a4
	move.w	(a4)+,d7
	andi.w	#$7000,d7
	beq.s	loc_6384
	cmpi.w	#$4000,d7
	beq.s	loc_638E
	cmpi.w	#$5000,d7
	beq.s	loc_638E

loc_6360:
	tst.w	(a2)
	bmi.s	loc_636A
	lea	6(a2),a2
	bra.s	loc_6360
; ---------------------------------------------------------------------------

loc_636A:
	move.w	(a0),(a2)
	move.w	2(a0),2(a2)
	move.w	#$600,4(a2)
	move.l	#$FFFFFFFF,(a0)
	addi.b	#1,($FFFFFB3D).w

loc_6384:
	lea	6(a0),a0
	dbf	d5,loc_6318
	bra.s	loc_63BE
; ---------------------------------------------------------------------------

loc_638E:
	tst.w	(a2)
	bmi.s	loc_6398
	lea	6(a2),a2
	bra.s	loc_638E
; ---------------------------------------------------------------------------

loc_6398:
	move.w	(a0),(a2)
	addi.w	#$C,(a2)
	move.w	2(a0),2(a2)
	move.w	#$600,4(a2)
	move.l	#$FFFFFFFF,(a0)
	addi.b	#1,($FFFFFB3D).w
	lea	6(a0),a0
	dbf	d5,loc_6318

loc_63BE:
	lea	($FFFFFB00).w,a0
	moveq	#9,d5

loc_63C4:
	move.w	(a0),d7
	bmi.w	loc_6456
	move.w	2(a0),d6
	subi.b	#1,4(a0)
	bne.s	loc_6402
	subi.w	#4,(a0)
	subi.w	#4,2(a0)
	move.b	#6,4(a0)
	addi.b	#1,5(a0)
	cmpi.b	#2,5(a0)
	blt.s	loc_6402
	move.l	#$FFFFFFFF,(a0)
	move.w	#$100,4(a0)
	bra.s	loc_6456
; ---------------------------------------------------------------------------

loc_6402:
	sub.w	(Camera_Y_pos).w,d7
	addi.w	#$80,d7
	sub.w	(Camera_X_pos).w,d6
	addi.w	#$80,d6
	move.l	(Addr_NextSpriteSlot).w,a4
	move.w	d6,6(a4)
	_move.w	d7,0(a4)
	tst.b	5(a0)
	bne.s	loc_642C
	move.w	#$A3CD,4(a4)
	bra.s	loc_6432
; ---------------------------------------------------------------------------

loc_642C:
	move.w	#$A3D1,4(a4)

loc_6432:
	clr.w	d6
	tst.b	5(a0)
	beq.s	loc_643E
	move.w	#$500,d6

loc_643E:
	addi.w	#$500,d6
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d6
	move.w	d6,2(a4)
	lea	8(a4),a4
	move.l	a4,(Addr_NextSpriteSlot).w

loc_6456:
	lea	6(a0),a0
	dbf	d5,loc_63C4
	moveq	#4,d5
	move.l	a1,a0

loc_6462:
	move.w	(a0),d7
	bmi.s	loc_64AE
	move.w	2(a0),d6
	sub.w	(Camera_Y_pos).w,d7
	addi.w	#$80,d7
	sub.w	(Camera_X_pos).w,d6
	addi.w	#$80,d6
	move.l	(Addr_NextSpriteSlot).w,a4
	move.w	d6,6(a4)
	_move.w	d7,0(a4)
	move.w	4(a0),d0
	andi.w	#$FF,d0
	add.w	d0,d0
	move.w	unk_64BC(pc,d0.w),4(a4)
	move.w	#$500,d6
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d6
	move.w	d6,2(a4)
	lea	8(a4),a4
	move.l	a4,(Addr_NextSpriteSlot).w

loc_64AE:
	lea	6(a0),a0
	dbf	d5,loc_6462
	rts
; End of function sub_61CA

; ---------------------------------------------------------------------------
	dc.b $A3 ; �
	dc.b $CD ; �
	dc.b $A3 ; �
	dc.b $D1 ; �
unk_64BC:	dc.b $A3 ; �
	dc.b $B5 ; �
	dc.b $A3 ; �
	dc.b $B9 ; �
	dc.b $A3 ; �
	dc.b $BD ; �
	dc.b $A3 ; �
	dc.b $C1 ; �
	dc.b $A3 ; �
	dc.b $C5 ; �
	dc.b $A3 ; �
	dc.b $C9 ; �
	dc.b $43 ; C
	dc.b $F9 ; �
	dc.b $FF
	dc.b $FF
	dc.b   2
	dc.b $80 ; �
	dc.b $72 ; r
	dc.b   0
; ---------------------------------------------------------------------------

loc_64D0:
	moveq	#0,d2

loc_64D2:
	move.b	(a0,d1.w),d3
	lsl.b	#4,d3
	or.b	(a0,d2.w),d3
	move.b	d3,(a1)+
	addq.w	#1,d2
	cmpi.w	#$10,d2
	bne.s	loc_64D2
	addq.w	#1,d1
	cmpi.w	#$10,d1
	bne.s	loc_64D0
	lea	($FFFF0280).l,a0
	move.w	d7,d1
	addq.w	#1,d1
	lsl.w	#2,d1
	subq.w	#1,d1
	lea	($FFFF0380).l,a1
	moveq	#0,d2

loc_6504:
	move.b	(a4)+,d2
	move.b	(a0,d2.w),(a1)+
	dbf	d1,loc_6504
	lea	($FFFF0380).l,a4
	rts
; ---------------------------------------------------------------------------
	dc.b   0
	dc.b   1
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b   6
	dc.b  $A
	dc.b   9
	dc.b  $D
	dc.b   7
	dc.b  $E
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   8
	dc.b  $F

; =============== S U B	R O U T	I N E =======================================


Init_Timer_and_Bonus_Flags:
	tst.b	($FFFFFC36).w
	beq.w	return_6550
	sf	($FFFFFC36).w
	clr.w	(Time_Seconds_low_digit).w
	clr.w	(Time_Seconds_high_digit).w
	move.w	#3,(Time_Minutes).w	; Starting timer is 3 minutes
	clr.w	(Clocks_collected).w
	sf	(NoHit_Bonus_Flag).w
	sf	(NoPrize_Bonus_Flag).w
	clr.w	(Time_Frames).w

return_6550:
	rts
; End of function Init_Timer_and_Bonus_Flags

; ---------------------------------------------------------------------------
word_6552:	dc.w $19
	binclude    "ingame/artunc/Pause_menu.bin"

; =============== S U B	R O U T	I N E =======================================


sub_6874:
	tst.b	($FFFFFAD0).w
	bne.s	loc_687C
	rts
; ---------------------------------------------------------------------------

loc_687C:
	bsr.w	sub_6C54
	bsr.w	Palette_to_VRAM
	jsr	(sub_E1334).l
	cmpi.b	#3,($FFFFFAD0).w
	bne.s	loc_6894
	rts
; ---------------------------------------------------------------------------

loc_6894:
	bsr.w	WaitForVint
	lea	(Sprite_Table).l,a0
	move.w	#$676,d6
	move.w	d6,d5
	addi.w	#$18,d5
	move.w	#$50,d3

loc_68AC:
	move.w	4(a0),d7
	andi.w	#$7FF,d7
	cmp.w	d6,d7
	blt.s	loc_68C0
	cmp.w	d5,d7
	bgt.s	loc_68C0
	move.w	#0,(a0)

loc_68C0:
	addq.w	#8,a0
	dbf	d3,loc_68AC
	jsr	(j_Stop_z80).l
	dma68kToVDP	Sprite_Table,$1000,$280,VRAM
	jsr	(j_Start_z80).l
	lea	word_6552(pc),a0
	move.w	(a0)+,d0
	subq.w	#1,d0
	move.l	#vdpComm($CEC0,VRAM,WRITE),4(a6)

loc_690C:
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	dbf	d0,loc_690C
	move.w	(Camera_X_pos).w,d0
	addi.w	#$60,d0
	lsr.w	#3,d0
	andi.w	#$3F,d0
	cmpi.w	#$30,d0
	bgt.s	loc_693A
	moveq	#8,d1
	moveq	#-1,d2
	bra.s	loc_6948
; ---------------------------------------------------------------------------

loc_693A:
	moveq	#$40,d1
	sub.w	d0,d1
	moveq	#$10,d2
	sub.w	d1,d2
	swap	d2
	move.w	d1,d2
	swap	d2

loc_6948:
	move.w	(Camera_Y_pos).w,d7
	addi.w	#$40,d7
	lea	(Decompression_Buffer).l,a1
	moveq	#4,d5
	add.w	d0,d0
	move.w	d0,d6

loc_695C:
	move.w	d7,d3
	lsr.w	#3,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	move.w	d6,d0
	add.w	d3,d0
	ori.w	#0,d0
	swap	d0
	move.w	#0,d0
	move.l	d0,4(a6)
	tst.w	d2
	bpl.s	loc_69A0
	jsr	(j_sub_914).w
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	move.l	(a6),(a1)+
	jsr	(j_sub_924).w
	addi.w	#8,d7
	dbf	d5,loc_695C
	bra.w	loc_69D2
; ---------------------------------------------------------------------------

loc_69A0:
	move.w	d2,d4
	swap	d2
	move.w	d2,d1
	swap	d2
	jsr	(j_sub_914).w
	subq.w	#1,d1

loc_69AE:
	move.w	(a6),(a1)+
	dbf	d1,loc_69AE
	andi.l	#$FF80FFFF,d0
	move.l	d0,4(a6)
	subq.w	#1,d4

loc_69C0:
	move.w	(a6),(a1)+
	dbf	d4,loc_69C0
	jsr	(j_sub_924).w
	addi.w	#8,d7
	dbf	d5,loc_695C

loc_69D2:
	move.w	(Camera_X_pos).w,d0
	addi.w	#$60,d0
	lsr.w	#3,d0
	andi.w	#$3F,d0
	cmpi.w	#$30,d0
	bgt.s	loc_69EC
	moveq	#8,d1
	moveq	#-1,d2
	bra.s	restart_text
; ---------------------------------------------------------------------------

loc_69EC:
	moveq	#$40,d1
	sub.w	d0,d1
	moveq	#$10,d2
	sub.w	d1,d2
	swap	d2
	move.w	d1,d2
	swap	d2

restart_text:							; Restart Round dialog
	move.w	(Camera_Y_pos).w,d7
	addi.w	#$40,d7
	cmpi.w	#1,(Number_Lives).w		; Check if lives > 1
	bgt.s	+							; Branch to set text to "Restart Round"
	lea	(unk_6CE4).l,a1				; Sets text to "Give Up"
	bra.s	++							; Branch to done
; ---------------------------------------------------------------------------

+
	lea	(unk_6D84).l,a1				; Sets text to "Restart Round"

+
	moveq	#4,d5
	add.w	d0,d0
	move.w	d0,d6

loc_6A1E:
	move.w	d7,d3
	lsr.w	#3,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	move.w	d6,d0
	add.w	d3,d0
	ori.w	#$4000,d0
	swap	d0
	move.w	#0,d0
	move.l	d0,4(a6)
	tst.w	d2
	bpl.s	loc_6A5A
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	addi.w	#8,d7
	dbf	d5,loc_6A1E
	bra.w	loc_6A84
; ---------------------------------------------------------------------------

loc_6A5A:
	move.w	d2,d4
	swap	d2
	move.w	d2,d1
	swap	d2
	subq.w	#1,d1

loc_6A64:
	move.w	(a1)+,(a6)
	dbf	d1,loc_6A64
	andi.l	#$FF80FFFF,d0
	move.l	d0,4(a6)
	subq.w	#1,d4

loc_6A76:
	move.w	(a1)+,(a6)
	dbf	d4,loc_6A76
	addi.w	#8,d7
	dbf	d5,loc_6A1E

loc_6A84:
	bclr	#Button_Up,(Ctrl_Pressed).w
	bclr	#Button_Down,(Ctrl_Pressed).w
	move.b	#0,(Pause_Option).w
	move.w	(Camera_X_pos).w,d0
	addi.w	#$68,d0
	lsr.w	#3,d0
	andi.w	#$3F,d0
	add.w	d0,d0
	move.w	d0,d1
	move.w	(Camera_Y_pos).w,d3
	addi.w	#$48,d3
	lsr.w	#3,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	add.w	d3,d0
	ori.w	#$4000,d0
	swap	d0
	move.w	#0,d0
	move.w	(Camera_Y_pos).w,d3
	addi.w	#$58,d3
	lsr.w	#3,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	add.w	d3,d1
	ori.w	#$4000,d1
	swap	d1
	move.w	#0,d1

;6AE0
Game_Paused_Loop:
	jsr	(j_WaitForVint).w
	jsr	(j_ReadJoypad).w
	bclr	#Button_Up,(Ctrl_Pressed).w
	beq.s	loc_6B0E
	; up pressed
	tst.b	(Pause_Option).w
	beq.s	Game_Paused_ChkStart
	; move cursor up
	move.l	d0,4(a6)
	move.w	#$867C,(a6)
	move.l	d1,4(a6)
	move.w	#$8678,(a6)
	subi.b	#1,(Pause_Option).w
	bra.s	Game_Paused_ChkStart
; ---------------------------------------------------------------------------

loc_6B0E:
	bclr	#Button_Down,(Ctrl_Pressed).w
	beq.s	Game_Paused_ChkStart
	; down pressed
	tst.b	(Pause_Option).w
	bne.s	Game_Paused_ChkStart
	; move cursor down
	move.l	d0,4(a6)
	move.w	#$8678,(a6)
	move.l	d1,4(a6)
	move.w	#$867C,(a6)
	addi.b	#1,(Pause_Option).w

Game_Paused_ChkStart:
	bclr	#Button_Start,(Ctrl_Pressed).w ; keyboard key (Enter) start
	beq.s	Game_Paused_Loop
	; start pressed
	tst.b	(Pause_Option).w
	beq.s	loc_6B68
	; restart level/give up
	subi.w	#1,(Number_Lives).w
	beq.s	loc_6B62
	; lives left --> restart level
	clr.w	(Extra_hitpoint_slots).w
	clr.w	(Current_Helmet).w
	move.w	#2,(Number_Hitpoints).w
	st	($FFFFFC36).w
	jsr	(j_sub_8C2).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_6B62:	; this was the last life
	move.b	#3,($FFFFFAD0).w

loc_6B68:	; continue game
	move.w	(Camera_X_pos).w,d0
	addi.w	#$60,d0
	lsr.w	#3,d0
	andi.w	#$3F,d0
	cmpi.w	#$30,d0
	bgt.s	loc_6B82
	moveq	#8,d1
	moveq	#-1,d2
	bra.s	loc_6B90
; ---------------------------------------------------------------------------

loc_6B82:
	moveq	#$40,d1
	sub.w	d0,d1
	moveq	#$10,d2
	sub.w	d1,d2
	swap	d2
	move.w	d1,d2
	swap	d2

loc_6B90:
	move.w	(Camera_Y_pos).w,d7
	addi.w	#$40,d7
	lea	(Decompression_Buffer).l,a1
	moveq	#4,d5
	add.w	d0,d0
	move.w	d0,d6

loc_6BA4:
	move.w	d7,d3
	lsr.w	#3,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	move.w	d6,d0
	add.w	d3,d0
	ori.w	#$4000,d0
	swap	d0
	move.w	#0,d0
	move.l	d0,4(a6)
	tst.w	d2
	bpl.s	loc_6BE0
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	addi.w	#8,d7
	dbf	d5,loc_6BA4
	bra.w	loc_6C0A
; ---------------------------------------------------------------------------

loc_6BE0:
	move.w	d2,d4
	swap	d2
	move.w	d2,d1
	swap	d2
	subq.w	#1,d1

loc_6BEA:
	move.w	(a1)+,(a6)
	dbf	d1,loc_6BEA
	andi.l	#$FF80FFFF,d0
	move.l	d0,4(a6)
	subq.w	#1,d4

loc_6BFC:
	move.w	(a1)+,(a6)
	dbf	d4,loc_6BFC
	addi.w	#8,d7
	dbf	d5,loc_6BA4

loc_6C0A:
	bsr.w	sub_6CCA
	cmpi.b	#3,($FFFFFAD0).w
	bne.s	loc_6C3E
	move.l	d0,-(sp)
	moveq	#sfx_Voice_bummer,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	(Addr_GfxObject_Kid).w,a4
	move.w	#4,$38(a4)
	move.w	#$30,$3A(a4)
	move.w	#1,(Number_Lives).w
	sf	($FFFFFAD0).w
	rts
; ---------------------------------------------------------------------------

loc_6C3E:
	sf	($FFFFFAD0).w
	jsr	(sub_E1338).l
	lea	(off_1194C).l,a0
	move.l	(a0),a0
	jsr	(a0)
	rts
; End of function sub_6874


; =============== S U B	R O U T	I N E =======================================


sub_6C54:
	lea	(Palette_Buffer).l,a4
	lea	($FFFF7D8E).l,a3
	moveq	#$1F,d7

loc_6C62:
	move.l	(a4)+,(a3)+
	dbf	d7,loc_6C62
	lea	(Palette_Buffer).l,a4
	moveq	#$E,d7

loc_6C70:
	move.w	(a4),d6
	move.w	d6,d5
	andi.w	#$F,d6
	lsr.w	#1,d6
	move.w	d5,d4
	andi.w	#$F0,d4
	lsr.w	#1,d4
	andi.w	#$F0,d4
	andi.w	#$F00,d5
	lsr.w	#1,d5
	andi.w	#$F00,d5
	or.w	d4,d5
	or.w	d5,d6
	move.w	d6,(a4)+
	dbf	d7,loc_6C70
	addq.w	#2,a4
	moveq	#$2F,d7

loc_6C9E:
	move.w	(a4),d6
	move.w	d6,d5
	andi.w	#$F,d6
	lsr.w	#1,d6
	move.w	d5,d4
	andi.w	#$F0,d4
	lsr.w	#1,d4
	andi.w	#$F0,d4
	andi.w	#$F00,d5
	lsr.w	#1,d5
	andi.w	#$F00,d5
	or.w	d4,d5
	or.w	d5,d6
	move.w	d6,(a4)+
	dbf	d7,loc_6C9E
	rts
; End of function sub_6C54


; =============== S U B	R O U T	I N E =======================================


sub_6CCA:
	lea	(Palette_Buffer).l,a4
	lea	($FFFF7D8E).l,a3
	moveq	#$1F,d7

loc_6CD8:
	move.l	(a3)+,(a4)+
	dbf	d7,loc_6CD8
	bsr.w	Palette_to_VRAM
	rts
; End of function sub_6CCA

; ---------------------------------------------------------------------------
unk_6CE4:
	dc.b $86 ; �
	dc.b $76 ; v
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $8E ; �
	dc.b $76 ; v
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7C ; |
	dc.b $86 ; �
	dc.b $82 ; �
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $80 ; �
	dc.b $86 ; �
	dc.b $7D ; }
	dc.b $86 ; �
	dc.b $85 ; �
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $84 ; �
	dc.b $86 ; �
	dc.b $8A ; �
	dc.b $86 ; �
	dc.b $83 ; �
	dc.b $86 ; �
	dc.b $89 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $7A ; z
	dc.b $86 ; �
	dc.b $7E ; ~
	dc.b $86 ; �
	dc.b $7F ; 
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $7D ; }
	dc.b $86 ; �
	dc.b $84 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $96 ; �
	dc.b $76 ; v
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $9E ; �
	dc.b $76 ; v
unk_6D84:
	dc.b $86 ; �
	dc.b $76 ; v
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $86 ; �
	dc.b $77 ; w
	dc.b $8E ; �
	dc.b $76 ; v
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7C ; |
	dc.b $86 ; �
	dc.b $82 ; �
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $80 ; �
	dc.b $86 ; �
	dc.b $7D ; }
	dc.b $86 ; �
	dc.b $85 ; �
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $84 ; �
	dc.b $86 ; �
	dc.b $8A ; �
	dc.b $86 ; �
	dc.b $83 ; �
	dc.b $86 ; �
	dc.b $89 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $7B ; {
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $82 ; �
	dc.b $86 ; �
	dc.b $81 ; �
	dc.b $86 ; �
	dc.b $80 ; �
	dc.b $86 ; �
	dc.b $88 ; �
	dc.b $86 ; �
	dc.b $83 ; �
	dc.b $86 ; �
	dc.b $82 ; �
	dc.b $86 ; �
	dc.b $88 ; �
	dc.b $86 ; �
	dc.b $78 ; x
	dc.b $86 ; �
	dc.b $82 ; �
	dc.b $86 ; �
	dc.b $86 ; �
	dc.b $86 ; �
	dc.b $7D ; }
	dc.b $86 ; �
	dc.b $87 ; �
	dc.b $86 ; �
	dc.b $79 ; y
	dc.b $8E ; �
	dc.b $7B ; {
	dc.b $96 ; �
	dc.b $76 ; v
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $96 ; �
	dc.b $77 ; w
	dc.b $9E ; �
	dc.b $76 ; v

; =============== S U B	R O U T	I N E =======================================


sub_6E24:
	jsr	(j_sub_914).w
	move.b	($A10001).l,d0
	btst	#7,d0
	seq	($FFFFFC81).w
	btst	#6,d0
	sne	($FFFFFC80).w
	jsr	(j_sub_924).w
	rts
; End of function sub_6E24

; ---------------------------------------------------------------------------


	if insertLevelSelect = 0
; filler
    rept 814
	dc.b	$FF
    endm

	else
LevelSelect_Start:
; LevelSelect_Loop_Pre:
	include	"scenes/levelselect.asm"
LevelSelect_End:
	; pad with $FF. Not really necessary but this ensures
	; consistency with the existing binary patch
    rept 814-(LevelSelect_End-LevelSelect_Start)
    	dc.b	$FF
    endm
	endif


; =============== S U B	R O U T	I N E =======================================

;7172
j_sub_7196:
	jmp	sub_7196(pc)
; ---------------------------------------------------------------------------
;7176
j_Make_SpriteAttr_HUD:
	jmp	Make_SpriteAttr_HUD(pc)
; ---------------------------------------------------------------------------
	jmp	sub_71E4(pc)
; ---------------------------------------------------------------------------
	jmp	loc_D052(pc)
; ---------------------------------------------------------------------------
	jmp	loc_BC34(pc)
; ---------------------------------------------------------------------------
Addr_HoloBG:	dc.l ArtComp_C65A_HoloBG
off_718A:	dc.w MapEni_CC0E-ArtComp_C65A_HoloBG
	dc.w Pal_D00C-ArtComp_C65A_HoloBG
off_718E:	dc.w ArtComp_CAB2_HoloBlocks-ArtComp_C65A_HoloBG
word_7190:	dc.w 0
off_7192:	dc.l Teleport

; =============== S U B	R O U T	I N E =======================================


sub_7196:
	sf	($FFFFF897).w
	st	(PaletteToDMA_Flag).w
	move.w	#$2000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_7508,4(a0)
	move.w	#1,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_7452,4(a0)
	move.w	#$FFFC,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_BC34,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_73D0,4(a0)
	bsr.w	Flagpole_Boss
	rts
; End of function sub_7196


; =============== S U B	R O U T	I N E =======================================


sub_71E4:
	movem.l	d0-d3/a0-a3,-(sp)
	move.l	(Addr_GfxObject_Kid).w,d7

loc_71EC:
	beq.w	loc_73C2
	move.l	d7,a0
	move.w	($FFFFF892).w,d2
	move.w	($FFFFF894).w,d3
	move.w	(Level_width_pixels).w,d1
	subi.w	#$140,d1
	move.w	$1A(a0),d0
	subi.w	#$A0,d0
	bcc.s	loc_720E
	moveq	#0,d0

loc_720E:
	cmp.w	d1,d0
	bcs.s	loc_7214
	move.w	d1,d0

loc_7214:
	move.w	(Camera_X_pos).w,d4
	cmpi.w	#4,d4
	bgt.s	loc_7226
	cmp.w	d4,d0
	bge.s	loc_7226
	moveq	#-1,d2
	bra.s	loc_723E
; ---------------------------------------------------------------------------

loc_7226:
	subq.w	#4,d1
	cmp.w	d1,d4
	blt.s	loc_7234
	cmp.w	d4,d0
	ble.s	loc_7234
	moveq	#1,d2
	bra.s	loc_723E
; ---------------------------------------------------------------------------

loc_7234:
	sub.w	(Camera_X_pos).w,d0
	addq.w	#4,d0
	asr.w	#3,d0
	move.w	d0,d2

loc_723E:
	cmpi.w	#8,d2
	blt.s	loc_7246
	moveq	#8,d2

loc_7246:
	cmpi.w	#$FFF8,d2
	bgt.s	loc_724E
	moveq	#-8,d2

loc_724E:
	add.w	d2,(Camera_X_pos).w
	move.w	(Level_height_blocks).w,d1
	subi.w	#$E0,d1
	move.w	$1E(a0),d0
	subi.w	#$A0,d0
	bcc.s	loc_7266
	moveq	#0,d0

loc_7266:
	cmp.w	d1,d0
	bcs.s	loc_726C
	move.w	d1,d0

loc_726C:
	move.w	$1E(a0),d7
	tst.w	d0
	bne.s	loc_727E
	cmp.w	($FFFFFA2E).w,d7
	bge.s	loc_727E
	subq.w	#2,($FFFFFB58).w

loc_727E:
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#$20,d7
	bge.s	loc_728C
	subq.w	#1,($FFFFFB58).w

loc_728C:
	cmpi.w	#$1E,($FFFFFB58).w
	blt.s	loc_72A8
	add.w	($FFFFFB58).w,d0
	subi.w	#$1E,d0
	cmp.w	d1,d0
	bcs.s	loc_72A8
	move.w	d1,d0
	subi.w	#1,($FFFFFB58).w

loc_72A8:
	move.w	(Camera_Y_pos).w,d4
	cmpi.w	#4,d4
	bgt.s	loc_72BA
	cmp.w	d4,d0
	bge.s	loc_72BA
	moveq	#-1,d3
	bra.s	loc_72D2
; ---------------------------------------------------------------------------

loc_72BA:
	subq.w	#4,d1
	cmp.w	d1,d4
	blt.s	loc_72C8
	cmp.w	d4,d0
	ble.s	loc_72C8
	moveq	#1,d3
	bra.s	loc_72D2
; ---------------------------------------------------------------------------

loc_72C8:
	sub.w	(Camera_Y_pos).w,d0
	addq.w	#4,d0
	asr.w	#3,d0
	move.w	d0,d3

loc_72D2:
	cmpi.w	#8,d3
	blt.s	loc_72DA
	moveq	#8,d3

loc_72DA:
	cmpi.w	#$FFF8,d3
	bgt.s	loc_72E2
	moveq	#-8,d3

loc_72E2:
	add.w	d3,(Camera_Y_pos).w
	move.l	(Camera_X_pos).w,d0
	lsr.l	#2,d0
	move.l	d0,(Camera_BG_X_pos).w
	move.l	(Camera_Y_pos).w,d0
	lsr.l	#2,d0
	move.l	d0,(Camera_BG_Y_pos).w
	tst.b	(MurderWall_flag).w
	beq.w	loc_73C2
	clr.l	d1
	tst.b	(MurderWall_flag2).w
	bne.s	loc_736E
	cmpi.w	#8,(Current_LevelID).w
	bne.s	loc_7316
	move.w	#$80,d1

loc_7316:
	addi.w	#$80,d1
	addi.l	#$100,(MurderWall_speed).w
	move.l	(MurderWall_speed).w,d7
	cmp.l	(MurderWall_max_speed).w,d7
	blt.s	loc_7334
	move.l	(MurderWall_max_speed).w,d7
	move.l	d7,(MurderWall_speed).w

loc_7334:
	add.l	d7,($FFFFFAC4).w
	move.w	(Camera_max_X_pos).w,d0
	cmp.w	($FFFFFAC4).w,d0
	bgt.s	loc_7346
	move.w	d0,($FFFFFAC4).w

loc_7346:
	move.w	(Camera_X_pos).w,d0
	sub.w	($FFFFFAC4).w,d0
	ble.s	loc_7364
	cmp.w	d1,d0
	blt.w	loc_73C2
	move.w	(Camera_X_pos).w,($FFFFFAC4).w
	sub.w	d1,($FFFFFAC4).w
	bra.w	loc_73C2
; ---------------------------------------------------------------------------

loc_7364:
	move.w	($FFFFFAC4).w,(Camera_X_pos).w
	bra.w	loc_73C2
; ---------------------------------------------------------------------------

loc_736E:
	addi.l	#$100,(MurderWall_speed).w
	move.l	(MurderWall_speed).w,d7
	cmp.l	(MurderWall_max_speed).w,d7
	blt.s	loc_7388
	move.l	(MurderWall_max_speed).w,d7
	move.l	d7,(MurderWall_speed).w

loc_7388:
	sub.l	d7,($FFFFFAC4).w
	bgt.s	loc_7396
	move.l	#0,($FFFFFAC4).w

loc_7396:
	move.w	(Camera_X_pos).w,d0
	sub.w	($FFFFFAC4).w,d0
	bge.s	loc_73B8

loc_73A0:
	cmpi.w	#$FF80,d0
	bgt.w	loc_73C2
	move.w	(Camera_X_pos).w,($FFFFFAC4).w
	addi.w	#$80,($FFFFFAC4).w
	bra.w	loc_73C2
; ---------------------------------------------------------------------------

loc_73B8:
	move.w	($FFFFFAC4).w,(Camera_X_pos).w
	bra.w	*+4

loc_73C2:
	move.w	d2,($FFFFF892).w
	move.w	d3,($FFFFF894).w
	movem.l	(sp)+,d0-d3/a0-a3
	rts
; End of function sub_71E4


; =============== S U B	R O U T	I N E =======================================


sub_73D0:
	sf	(PaletteToDMA_Flag).w
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_73E2:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_73E2
	moveq	#$3F,d0
	move.w	($FFFFFBCC).w,d1
	lea	($FFFF4F58).l,a0

loc_73F4:
	move.w	d1,(a0)+
	dbf	d0,loc_73F4
	move.w	#0,($FFFFF876).w
	bra.s	loc_7414
; ---------------------------------------------------------------------------

loc_7402:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.w	#$10,($FFFFF876).w
	cmpi.w	#$100,($FFFFF876).w
	bgt.s	loc_7420

loc_7414:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_7402
; ---------------------------------------------------------------------------

loc_7420:
	st	($FFFFFB56).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_73D0


; =============== S U B	R O U T	I N E =======================================


sub_7428:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.w	return_7450
	btst	#Button_Start,(Ctrl_Held).w ; keyboard key (Enter) start
	beq.s	return_7450
	btst	#Button_A,(Ctrl_Held).w ; keyboard key (A) run
	beq.w	return_7450
	cmpi.w	#5,(Number_Diamonds).w
	blt.s	return_7450
	st	(FiveWayShotReady).w

return_7450:
	rts
; End of function sub_7428

; ---------------------------------------------------------------------------

loc_7452:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	($FFFFFB4C).w
	beq.s	loc_7464
	subq.w	#1,($FFFFFB4C).w
	beq.w	loc_D980

loc_7464:
	move.b	(Ctrl_Held).w,d0
	lea	(Ctrl_A_Held).w,a0
	add.b	d0,d0
	add.b	d0,d0
	scs	(a0)+
	add.b	d0,d0
	scs	(a0)+
	add.b	d0,d0
	scs	(a0)+
	add.b	d0,d0
	scs	(a0)+
	add.b	d0,d0
	scs	(a0)+
	add.b	d0,d0
	scs	(a0)+
	sne	(a0)
	tst.b	(Ctrl_Left_Held).w
	beq.w	loc_749C
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_749C
	sf	(Ctrl_Right_Held).w

loc_749C:
	tst.b	(Demo_Mode_flag).w
	bne.w	loc_74B0
	tst.b	(Options_Suboption_Speed).w
	beq.w	loc_74B0
	not.b	(Ctrl_A_Held).w

loc_74B0:
	bclr	#Button_Start,(Ctrl_Pressed).w ; keyboard key (Enter) start
	beq.s	loc_7452
	tst.b	(LevelSkip_Cheat).w
	beq.s	loc_74C8
	btst	#Button_C,(Ctrl_Held).w ; keyboard key (D) special
	bne.w	loc_74E0

loc_74C8:
	btst	#Button_A,(Ctrl_Held).w ; keyboard key (A) run
	bne.s	loc_7452
	tst.b	($FFFFFB56).w
	beq.w	loc_7452
	st	($FFFFFAD0).w
	bra.w	loc_7452
; ---------------------------------------------------------------------------

loc_74E0:
	btst	#Button_A,(Ctrl_Held).w ; keyboard key (A) run
	beq.w	loc_7452
	addq.w	#1,(Current_LevelID).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w
	st	($FFFFFBCE).w
	jsr	(j_sub_8C2).w
	move.w	#8,(Game_Mode).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_7508:
	move.w	(Current_Helmet).w,d0
	add.w	d0,d0
	lea	(Data_Index).l,a0
	lea	off_80F2(pc),a1
	add.w	(a1,d0.w),a0
	move.l	(a0),a0
	lea	(Palette_Buffer+$62).l,a1
	moveq	#$B,d0

loc_7526:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_7526
	moveq	#1,d0
	move.l	a5,($FFFFF850).w
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	a3,(Addr_GfxObject_Kid).w
	st	$13(a3)
	move.b	#3,palette_line(a3)
	move.b	#0,priority(a3)
	move.b	#1,$12(a3)
	move.w	(PlayerStart_X_pos).w,x_pos(a3)
	move.w	(PlayerStart_Y_pos).w,y_pos(a3)
	subq.w	#1,y_pos(a3)
	move.l	#$2010000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,($FFFFF862).w
	st	$13(a1)
	move.b	#3,$11(a1)

loc_757E:
	move.b	#0,$10(a1)
	move.b	#1,$12(a1)
	move.w	(PlayerStart_X_pos).w,$1A(a1)
	move.w	(PlayerStart_Y_pos).w,$1E(a1)
	subq.w	#1,$1E(a1)
	bsr.w	sub_B41C
	clr.w	($FFFFFB70).w
	move.w	($FFFFFA78).w,d7
	moveq	#$10,d6
	move.w	(Current_Helmet_Available).w,d5
	cmpi.w	#9,d5
	beq.w	loc_75C0
	cmpi.w	#5,d5
	beq.w	loc_75C0
	addi.w	#$10,d6

loc_75C0:
	bsr.w	sub_7B30
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.w	loc_75D4
	move.w	#(LnkTo_unk_BEDF0-Data_Index),$22(a1)
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_75D4:
	move.w	#MoveID_Standingstill,(Character_Movement).w
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	clr.l	($FFFFFA98).w
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	bsr.w	sub_7ACC
	move.w	(Current_Helmet).w,d0
	cmpi.w	#1,d0
	beq.w	loc_8C12

loc_7606:
	bsr.w	sub_7428
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_7650
	move.b	(Ctrl_Held).w,d0
	andi.b	#$C0,d0
	cmpi.b	#$C0,d0
	bne.s	loc_7650
	tst.w	($FFFFFAB8).w
	bne.s	loc_7650
	cmpi.w	#2,(Number_Diamonds).w
	blt.s	loc_7650
	move.w	#$8001,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w
	move.l	#stru_8B36,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Eyeclops_hard_lightbeam,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_7650:
	tst.b	(Ctrl_Down_Held).w
	bne.s	loc_7664
	subi.w	#8,($FFFFFB58).w
	bge.s	loc_7664
	move.w	#0,($FFFFFB58).w

loc_7664:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bne.w	loc_A426
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_7772
	cmpi.w	#Iron_Knight,(Current_Helmet).w
	bne.w	loc_76B0
	move.w	x_pos(a3),d7
	move.w	($FFFFFA78).w,d6
	addq.w	#1,d6
	tst.b	x_direction(a3)
	beq.w	loc_7696
	neg.w	d6

loc_7696:
	add.w	d6,d7
	bmi.w	loc_7772
	cmp.w	(Level_width_pixels).w,d7
	bge.w	loc_7772
	bsr.w	sub_922C
	beq.w	loc_7772
	bra.w	loc_A276
; ---------------------------------------------------------------------------

loc_76B0:
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	bne.w	loc_76E4
	tst.b	(Red_Stealth_sword_swing).w
	bne.w	loc_76E4
	move.l	#stru_8B3C,d7
	jsr	(j_Init_Animation).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_868E,4(a0)
	st	(Red_Stealth_sword_swing).w
	bra.w	loc_7772
; ---------------------------------------------------------------------------

loc_76E4:
	cmpi.w	#Maniaxe,(Current_Helmet).w
	bne.w	loc_7718
	tst.b	(Maniaxe_throwing_axe).w
	bne.w	loc_7772
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_89D2,4(a0)
	move.l	#stru_8B4E,d7
	jsr	(j_Init_Animation).w
	st	(Maniaxe_throwing_axe).w
	bra.w	loc_7772
; ---------------------------------------------------------------------------

loc_7718:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.s	loc_7742
	tst.b	is_animated(a3)
	bne.s	loc_7772
	cmpi.w	#8,($FFFFFB70).w
	bge.w	loc_7772
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w

loc_7738:
	move.l	#sub_86FA,4(a0)
	bra.s	loc_7772
; ---------------------------------------------------------------------------

loc_7742:
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_7772
	tst.w	($FFFFFAB8).w
	bne.s	loc_7772
	move.w	#1,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w
	move.l	#stru_8B36,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Eyeclops_normal_lightbeam,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_7772:
	tst.b	(Ctrl_Down_Held).w
	beq.s	loc_779C
	tst.b	(KidGrabbedByHand).w
	bne.w	loc_779C
	addq.w	#1,($FFFFFB58).w
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.s	loc_779C
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.s	loc_779C
	bsr.w	sub_7A10
	beq.w	loc_83BC

loc_779C:
	tst.b	(Maniaxe_throwing_axe).w
	bne.w	loc_7828
	move.w	($FFFFFA78).w,d0
	move.w	x_pos(a3),d7
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_77E6
	add.w	d0,d7
	addq.w	#1,d7
	bsr.w	sub_922C
	beq.s	loc_77C2
	sf	x_direction(a3)
	bra.s	loc_7828
; ---------------------------------------------------------------------------

loc_77C2:
	move.w	(Current_Helmet).w,d7
	move.w	#%1011000101,d6
	btst	d7,d6
	bne.w	loc_7820
	moveq	#1,d7
	moveq	#-1,d6
	bsr.w	sub_B55C
	cmpi.w	#$4000,d5
	bne.w	loc_7820
	sf	x_direction(a3)
	bra.s	loc_7828
; ---------------------------------------------------------------------------

loc_77E6:
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_7828
	sub.w	d0,d7
	subq.w	#1,d7
	bsr.w	sub_922C
	beq.s	loc_77FC
	st	x_direction(a3)
	bra.s	loc_7828
; ---------------------------------------------------------------------------

loc_77FC:
	move.w	(Current_Helmet).w,d7
	move.w	#%1011000101,d6
	btst	d7,d6
	bne.w	loc_7820
	moveq	#-1,d7
	moveq	#-1,d6
	bsr.w	sub_B55C
	cmpi.w	#$5000,d5
	bne.w	loc_7820
	st	x_direction(a3)
	bra.s	loc_7828
; ---------------------------------------------------------------------------

loc_7820:
	clr.w	($FFFFF8F0).w
	bra.w	loc_8D72
; ---------------------------------------------------------------------------

loc_7828:
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.w	loc_78C6
	move.w	d7,a4
	move.l	$A(a4),x_vel(a3)
	move.w	4(a4),$1C(a3)
	bsr.w	sub_8F26
	move.w	(Addr_PlatformStandingOn).w,a4
	move.l	$E(a4),y_vel(a3)
	move.l	6(a4),y_pos(a3)
	subq.w	#1,y_pos(a3)
	bsr.w	sub_902A
	beq.w	loc_7886
	bmi.w	loc_78A8
	cmpi.w	#2,d7
	beq.w	loc_78C0
	clr.w	(Addr_PlatformStandingOn).w
	tst.l	x_vel(a3)
	beq.w	loc_787E
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_787E:
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_7886:
	bsr.w	sub_8ED0
	beq.w	loc_789C
	move.w	#MoveID_Jump,(Character_Movement).w
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_789C:
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_78A8:
	move.w	(Addr_PlatformStandingOn).w,a4
	tst.l	$E(a4)
	bmi.w	loc_78C0
	clr.w	(Addr_PlatformStandingOn).w
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_78C0:
	moveq	#0,d7
	bra.w	Death
; ---------------------------------------------------------------------------

loc_78C6:
	moveq	#0,d0
	move.l	d0,x_vel(a3)
	move.l	d0,y_vel(a3)
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B43A
	bmi.w	loc_BC80
	beq.w	loc_B5F6
	bsr.w	sub_78E8
	bra.w	loc_75D4
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_78E8:
	move.l	($FFFFF862).w,a2
	move.w	(Current_Helmet).w,d0
	cmpi.w	#5,d0
	beq.w	loc_7988
	cmpi.w	#9,d0
	beq.s	loc_7962
	cmpi.w	#1,d0
	beq.w	loc_79AC
	cmpi.w	#8,d0
	bne.w	loc_7920
	tst.b	(Maniaxe_throwing_axe).w
	beq.w	loc_794C
	tst.b	$18(a3)
	bne.w	loc_794C
	rts
; ---------------------------------------------------------------------------

loc_7920:
	cmpi.w	#4,d0
	bne.w	loc_7932
	tst.b	is_animated(a3)
	beq.w	loc_794C
	rts
; ---------------------------------------------------------------------------

loc_7932:
	cmpi.w	#3,d0
	bne.w	loc_794C
	tst.b	(Red_Stealth_sword_swing).w
	beq.w	loc_794C
	tst.b	$18(a3)
	bne.w	loc_794C
	rts
; ---------------------------------------------------------------------------

loc_794C:
	sf	(Maniaxe_throwing_axe).w
	sf	(Red_Stealth_sword_swing).w
	add.w	d0,d0
	lea	off_79B2(pc),a0
	add.w	d0,a0
	move.w	(a0),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_7962:
	addq.w	#1,($FFFFF8F0).w
	move.w	($FFFFF8F0).w,d0
	cmpi.w	#8,d0
	blt.s	loc_7974
	clr.w	($FFFFF8F0).w

loc_7974:
	move.w	#LnkTo_unk_ABDE0-Data_Index,d1
	cmpi.w	#5,d0
	bge.s	loc_7982
	move.w	#LnkTo_unk_ABEA6-Data_Index,d1

loc_7982:
	move.w	d1,addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_7988:
	tst.b	is_animated(a3)
	beq.w	loc_7998
	tst.b	$18(a3)
	beq.w	loc_79A2

loc_7998:
	move.w	#(LnkTo_unk_C0246-Data_Index),addroffset_sprite(a3)
	sf	is_animated(a3)

loc_79A2:
	move.l	($FFFFF862).w,a4
	bsr.w	sub_975C
	rts
; ---------------------------------------------------------------------------

loc_79AC:
	bsr.w	sub_98F2
	rts
; End of function sub_78E8

; ---------------------------------------------------------------------------
off_79B2:	dc.w LnkTo_unk_A3E72-Data_Index
	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_BB304-Data_Index
	dc.w LnkTo_unk_B4E82-Data_Index
	dc.w LnkTo_unk_B7EC0-Data_Index
	dc.w LnkTo_unk_BEDF0-Data_Index
	dc.w LnkTo_unk_C2E62-Data_Index
	dc.w LnkTo_unk_B0994-Data_Index
	dc.w LnkTo_unk_A65B4-Data_Index
	dc.w LnkTo_unk_ABDE0-Data_Index
; ---------------------------------------------------------------------------
	move.w	#$47C,d0
	move.w	($FFFFFA20).w,d1
	beq.s	loc_79E6
	cmpi.w	#8,d1
	bne.s	loc_79DE
	move.w	#(LnkTo_unk_C0552-Data_Index),addroffset_sprite(a3)
	bra.s	loc_7A02
; ---------------------------------------------------------------------------

loc_79DE:
	move.w	#(LnkTo_unk_C0552-Data_Index),addroffset_sprite(a3)
	bra.s	loc_7A02
; ---------------------------------------------------------------------------

loc_79E6:
	move.w	d0,$22(a2)
	move.w	x_pos(a3),$1A(a2)
	move.w	y_pos(a3),$1E(a2)
	move.w	x_direction(a3),$16(a2)
	move.w	#(LnkTo_unk_BF0FC-Data_Index),addroffset_sprite(a3)

loc_7A02:
	clr.b	($FFFFFA0D).w
	move.l	#$96D4,($FFFFFA0E).w
	rts

; =============== S U B	R O U T	I N E =======================================


sub_7A10:
	clr.w	$1C(a3)
	move.w	x_pos(a3),-(sp)
	move.w	#$E,d4
	move.w	x_pos(a3),d7
	sub.w	d4,d7
	bmi.w	loc_7A60
	move.w	d4,d7
	neg.w	d7
	moveq	#0,d6
	bsr.w	sub_B55C
	move.w	(a4),d7
	andi.w	#$4000,d7
	bne.w	loc_7A60
	move.w	d4,d7
	add.w	x_pos(a3),d7
	cmp.w	(Level_width_pixels).w,d7
	bge.w	loc_7A98
	move.w	#$E,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	move.w	(a4),d7
	andi.w	#$4000,d7
	bne.w	loc_7A98
	bra.w	loc_7AC6
; ---------------------------------------------------------------------------

loc_7A60:
	move.w	x_pos(a3),d7
	sub.w	d4,d7
	andi.w	#$FFF0,d7
	addi.w	#$10,d7
	add.w	d4,d7
	move.w	d7,x_pos(a3)
	add.w	d4,d7
	cmp.w	(Level_width_pixels).w,d7
	bge.w	loc_7A90
	move.w	d4,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	move.w	(a4),d7
	andi.w	#$4000,d7
	beq.w	loc_7AC6

loc_7A90:
	move.w	(sp)+,x_pos(a3)
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_7A98:
	move.w	x_pos(a3),d7
	add.w	d4,d7
	andi.w	#$F,d7
	addq.w	#1,d7
	sub.w	d7,x_pos(a3)
	move.w	x_pos(a3),d7
	sub.w	d4,d7
	bmi.s	loc_7A90
	move.w	d4,d7
	neg.w	d7
	moveq	#0,d6
	bsr.w	sub_B55C
	move.w	(a4),d7
	andi.w	#$4000,d7
	beq.w	loc_7AC6
	bra.s	loc_7A90
; ---------------------------------------------------------------------------

loc_7AC6:
	addq.w	#2,sp
	moveq	#0,d7
	rts
; End of function sub_7A10


; =============== S U B	R O U T	I N E =======================================


sub_7ACC:
	tst.b	(Check_Helmet_Change).w
	bne.s	loc_7AD6
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_7AD6:
	cmpi.w	#6,($FFFFFA56).w
	beq.w	loc_7B12
	move.w	(Current_Helmet_Available).w,d5
	add.w	d5,d5
	lea	unk_B408(pc),a4
	add.w	d5,a4
	moveq	#0,d7
	move.b	(a4)+,d7
	moveq	#$10,d6
	move.w	(Current_Helmet_Available).w,d5
	cmpi.w	#9,d5
	beq.w	loc_7B0A
	cmpi.w	#5,d5
	beq.w	loc_7B0A
	addi.w	#$10,d6

loc_7B0A:
	bsr.w	sub_7B30
	bne.w	loc_7B1A

loc_7B12:
	bra.w	Kid_Transform
; ---------------------------------------------------------------------------
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_7B1A:
	tst.w	(Current_Helmet).w
	beq.w	loc_7B28
	moveq	#0,d7
	bra.w	Death
; ---------------------------------------------------------------------------

loc_7B28:
	sf	(Check_Helmet_Change).w
	moveq	#0,d7
	rts
; End of function sub_7ACC


; =============== S U B	R O U T	I N E =======================================


sub_7B30:

	move.l	x_pos(a3),d0
	move.l	y_pos(a3),d1
	subq.w	#4,sp
	move.w	d7,(sp)
	moveq	#0,d5
	cmpi.w	#$10,d6
	beq.w	loc_7B48
	moveq	#1,d5

loc_7B48:
	move.w	y_pos(a3),d4
	andi.w	#$F,d4
	cmpi.w	#$F,d4
	beq.w	loc_7B5A
	addq.w	#1,d5

loc_7B5A:
	move.w	d5,2(sp)
	move.w	x_pos(a3),d6
	sub.w	d7,d6
	bpl.w	loc_7B74
	move.w	(sp),d6
	move.w	d6,x_pos(a3)
	add.w	d6,d6
	bra.w	loc_7BB6
; ---------------------------------------------------------------------------

loc_7B74:
	move.w	d6,d4
	move.w	2(sp),d7
	bsr.w	sub_7BEA
	bne.w	loc_7BA4
	move.w	(sp),d6
	add.w	x_pos(a3),d6
	move.w	d6,d4
	cmp.w	(Level_width_pixels).w,d6
	bge.w	loc_7BCE
	move.w	2(sp),d7
	bsr.w	sub_7BEA
	bne.w	loc_7BCE

loc_7B9E:
	moveq	#0,d7
	addq.w	#4,sp
	rts
; ---------------------------------------------------------------------------

loc_7BA4:
	andi.w	#$FFF0,d4
	addi.w	#$10,d4
	add.w	(sp),d4
	move.w	d4,x_pos(a3)
	add.w	(sp),d4
	move.w	d4,d6

loc_7BB6:
	move.w	2(sp),d7
	bsr.w	sub_7BEA
	beq.s	loc_7B9E

loc_7BC0:
	moveq	#1,d7
	addq.w	#4,sp
	move.l	d0,x_pos(a3)
	move.l	d1,y_pos(a3)
	rts
; ---------------------------------------------------------------------------

loc_7BCE:
	andi.w	#$FFF0,d4
	subq.w	#1,d4
	sub.w	(sp),d4
	move.w	d4,x_pos(a3)
	sub.w	(sp),d4
	move.w	d4,d6
	move.w	2(sp),d7
	bsr.w	sub_7BEA
	beq.s	loc_7B9E
	bra.s	loc_7BC0
; End of function sub_7B30


; =============== S U B	R O U T	I N E =======================================


sub_7BEA:
	move.w	y_pos(a3),d5
	asr.w	#4,d5
	add.w	d5,d5
	lea	($FFFF4A04).l,a4
	move.w	(a4,d5.w),a4
	asr.w	#4,d6
	add.w	d6,d6
	add.w	d6,a4

loc_7C02:
	move.w	(a4),d6
	andi.w	#$4000,d6
	bne.w	loc_7C18
	suba.w	(Level_width_tiles).w,a4
	dbf	d7,loc_7C02
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_7C18:
	moveq	#1,d7
	rts
; End of function sub_7BEA


; =============== S U B	R O U T	I N E =======================================


sub_7C1C:
	movem.l	d7-a0,-(sp)
	lea	($FFFFF862).w,a0

loc_7C24:
	move.l	4(a0),d7
	beq.w	loc_7C3A
	move.l	d7,a0
	move.l	$C(a0),a0
	jsr	(j_Delete_Object_a0).w
	move.l	d7,a0
	bra.s	loc_7C24
; ---------------------------------------------------------------------------

loc_7C3A:
	movem.l	(sp)+,d7-a0
	rts
; End of function sub_7C1C


; =============== S U B	R O U T	I N E =======================================

;7C40
Kid_Transform:
	move.l	($FFFFF862).w,a4
	sf	$17(a4)
	sf	$17(a3)
	st	(Currently_transforming).w
	st	$13(a3)
	move.l	(sp)+,$44(a5)
	; save last 3 colors onto stack
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a4)+,-(sp)
	move.w	(a4)+,-(sp)
	move.w	(a4)+,-(sp)
	bsr.s	sub_7C1C
	tst.b	($FFFFFA64).w
	bne.w	loc_7C76
	move.w	(Current_Helmet_Available).w,d0
	bsr.w	sub_7EB2

loc_7C76:
	move.w	(Current_Helmet).w,d7
	beq.w	loc_7CD0
	cmp.w	(Current_Helmet_Available).w,d7
	bne.w	loc_7C96
	move.l	d0,-(sp)
	moveq	#sfx_Replenish_Health,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bra.w	loc_7E14
; ---------------------------------------------------------------------------

loc_7C96:
	addq.w	#1,d7
	add.w	d7,d7
	lea	off_7EE2(pc),a0
	move.w	(a0,d7.w),d7
	subq.w	#2,d7
	add.w	d7,a0

loc_7CA6:
	move.w	-(a0),d7
	bmi.w	loc_7CD0
	move.w	-(a0),d6
	move.w	d6,d0
	lsr.w	#8,d0
	subq.w	#1,d0
	andi.w	#$FF,d6
	move.l	off_7D34(pc,d6.w),a4
	jsr	(a4)

loc_7CBE:
	movem.l	d0-a5,-(sp)
	jsr	(j_sub_8E0).w
	movem.l	(sp)+,d0-a5
	dbf	d0,loc_7CBE
	bra.s	loc_7CA6
; ---------------------------------------------------------------------------

loc_7CD0:
	move.w	(Current_Helmet_Available).w,(Current_Helmet).w
	beq.w	loc_7E14
	move.w	(Current_Helmet).w,d7
	tst.b	(Demo_Mode_flag).w
	bne.s	loc_7CFE
	jsr	(sub_E1334).l
	moveq	#0,d0
	lea	unk_7ED8(pc),a4
	move.b	(a4,d7.w),d0
	beq.w	loc_7CFE
	jsr	(j_PlaySound).l

loc_7CFE:
	add.w	d7,d7
	lea	off_7EE2(pc),a0
	move.w	(a0,d7.w),d7
	add.w	d7,a0

loc_7D0A:
	move.w	(a0)+,d7
	bmi.w	loc_7E14
	move.w	d7,d0
	lsr.w	#8,d0
	subq.w	#1,d0
	andi.w	#$FF,d7
	move.l	off_7D34(pc,d7.w),a4
	move.w	(a0)+,d7
	jsr	(a4)

loc_7D22:
	movem.l	d0-a5,-(sp)
	jsr	(j_sub_8E0).w
	movem.l	(sp)+,d0-a5
	dbf	d0,loc_7D22
	bra.s	loc_7D0A
; ---------------------------------------------------------------------------
off_7D34:	dc.l loc_7D80
	dc.l loc_7D44
	dc.l loc_7D5A
	dc.l loc_7D7C
; ---------------------------------------------------------------------------

loc_7D44:
	move.l	($FFFFF862).w,a4
	sf	$13(a4)
	move.w	d7,addroffset_sprite(a3)
	move.w	(Current_Helmet).w,d7
	bsr.w	sub_8106
	rts
; ---------------------------------------------------------------------------

loc_7D5A:
	move.l	($FFFFF862).w,a4
	sf	$13(a4)
	move.w	(Current_Helmet).w,d7
	add.w	d7,d7
	lea	off_79B2(pc),a4
	add.w	d7,a4
	move.w	(a4),addroffset_sprite(a3)
	move.w	(Current_Helmet).w,d7
	bsr.w	sub_80D0
	rts
; ---------------------------------------------------------------------------

loc_7D7C:
	ori.w	#$8000,d7

loc_7D80:
	move.w	d7,d6
	move.l	($FFFFF862).w,a4
	sf	$13(a4)
	bclr	#$F,d6
	beq.w	loc_7DF0
	move.w	x_pos(a3),x_pos(a4)
	move.w	y_pos(a3),y_pos(a4)
	subi.w	#$E,y_pos(a4)
	st	$13(a4)
	sf	$15(a4)
	sf	$14(a4)
	move.b	x_direction(a3),$16(a4)
	move.w	(Current_Helmet).w,d7
	cmpi.w	#3,d7
	beq.w	loc_7DD6
	cmpi.w	#6,d7
	beq.w	loc_7DD6
	cmpi.w	#7,d7
	beq.w	loc_7DD6
	bra.w	loc_7DDA
; ---------------------------------------------------------------------------

loc_7DD6:
	not.b	$16(a4)

loc_7DDA:
	move.b	palette_line(a3),$11(a4)
	move.w	(Current_Helmet).w,d7
	add.w	d7,d7
	lea	off_8176(pc),a2
	move.w	(a2,d7.w),$22(a4)

loc_7DF0:
	move.w	d6,addroffset_sprite(a3)
	moveq	#0,d7
	bsr.w	sub_80D0
	bsr.w	sub_813C
	rts
; ---------------------------------------------------------------------------
	dc.b   0
	dc.b $FD ; �
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b $FF
	dc.b $E8 ; �
	dc.b $E8 ; �
	dc.b $E8 ; �
	dc.b $EE ; �
	dc.b $EB ; �
	dc.b $E8 ; �
	dc.b $E8 ; �
	dc.b $F3 ; �
	dc.b $E8 ; �
	dc.b $F3 ; �
; ---------------------------------------------------------------------------

loc_7E14:
	lea	unk_7ECC(pc),a4
	moveq	#0,d0
	move.w	(Foreground_theme).w,d0
	tst.b	(MurderWall_flag).w
	beq.s	loc_7E26
	moveq	#$B,d0

loc_7E26:
	move.b	(a4,d0.w),d0
	jsr	(sub_E1330).l
	jsr	(sub_E1338).l
	move.w	(Current_Helmet).w,d7
	bne.s	loc_7E48
	move.l	d0,-(sp)
	moveq	#sfx_Voice_bummer,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_7E48:
	bsr.w	sub_80D0
	moveq	#1,d0
	bsr.w	sub_B41C
	bsr.w	sub_DB22
	clr.w	($FFFFFB70).w
	move.l	(Addr_GfxObject_Kid).w,a4
	clr.w	$22(a4)
	sf	$17(a4)
	move.l	($FFFFF862).w,a4
	clr.w	$22(a4)
	sf	$17(a4)
	sf	$13(a4)
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.s	loc_7E8C
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.s	loc_7E90
	move.w	#(LnkTo_unk_BEDF0-Data_Index),$22(a4)

loc_7E8C:
	st	$13(a4)

loc_7E90:
	sf	(Check_Helmet_Change).w
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	(Currently_transforming).w
	lea	($FFFF4ED8).l,a4
	move.w	(sp)+,-(a4)
	move.w	(sp)+,-(a4)
	move.w	(sp)+,-(a4)
	move.l	$44(a5),-(sp)
	rts
; End of function Kid_Transform


; =============== S U B	R O U T	I N E =======================================


sub_7EB2:
	move.b	unk_7EC2(pc,d0.w),d0
	ext.w	d0
	add.w	(Extra_hitpoint_slots).w,d0
	move.w	d0,(Number_Hitpoints).w
	rts
; End of function sub_7EB2

; ---------------------------------------------------------------------------
; Initial number of hitpoints for each helmet
unk_7EC2:
	dc.b   2	; the kid
	dc.b   3	; skycutter
	dc.b   3	; cyclone
	dc.b   3	; red stealth
	dc.b   3	; eyeclops
	dc.b   3	; juggernaut
	dc.b   5	; iron knight
	dc.b   3	; berzerker
	dc.b   3	; maniaxe
	dc.b   3	; micromax
unk_7ECC:
	dc.b   0
	dc.b $7E
	dc.b $7A
	dc.b $87
	dc.b $78
	dc.b $6C
	dc.b $78
	dc.b $7D
	dc.b $74
	dc.b $78
	dc.b $68
	dc.b $76
unk_7ED8:
	dc.b   0
	dc.b sfx_Skycutter_transform
	dc.b sfx_Cyclone_transform
	dc.b sfx_Red_Stealth_transform
	dc.b sfx_Eyeclops_transform
	dc.b sfx_Juggernaut_transform
	dc.b sfx_Iron_Knight_transform
	dc.b sfx_Berzerker_transform
	dc.b sfx_Maniaxe_transform
	dc.b sfx_Micromax_transform
off_7EE2:
	dc.w off_7EE2-off_7EE2
	dc.w stru_7EFA-off_7EE2
	dc.w stru_7F30-off_7EE2
	dc.w stru_7F5A-off_7EE2
	dc.w stru_7F90-off_7EE2
	dc.w stru_7FCA-off_7EE2
	dc.w stru_7FF8-off_7EE2
	dc.w stru_803A-off_7EE2
	dc.w stru_8064-off_7EE2
	dc.w stru_808A-off_7EE2
	dc.w sub_80BC-off_7EE2
	dc.b $FF
	dc.b $FF
stru_7EFA:
	anim_frame	  8,  $C, LnkTo_unk_A4BA8-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AA88C-Data_Index
	anim_frame	  4,  $C, LnkTo_unk_A4BA8-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AA88C-Data_Index
	anim_frame	  4,  $C, LnkTo_unk_A4BA8-Data_Index
	anim_frame	  2,   4, LnkTo_unk_AA88C-Data_Index
	anim_frame	  2,   4, LnkTo_unk_AAA92-Data_Index
	anim_frame	  2,   4, LnkTo_unk_AADB8-Data_Index
	anim_frame	  3,   4, LnkTo_unk_AAA92-Data_Index
	anim_frame	  3,   4, LnkTo_unk_AADB8-Data_Index
	anim_frame	  3,   4, LnkTo_unk_AAA92-Data_Index
	anim_frame	  3,   4, LnkTo_unk_AA88C-Data_Index
	anim_frame	  5,   4, LnkTo_unk_AB3BE-Data_Index
	dc.b $FF
	dc.b $FF
stru_7F30:
	anim_frame	$10, 0, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_BB48A-Data_Index
	anim_frame	  8, 0, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_BB48A-Data_Index
	anim_frame	  4,   4, LnkTo_unk_BB710-Data_Index
	anim_frame	  4,   4, LnkTo_unk_BB48A-Data_Index
	anim_frame	  4,   4, LnkTo_unk_BB710-Data_Index
	anim_frame	  8,   8, 0
	anim_frame	  4,   4, LnkTo_unk_BB710-Data_Index
	anim_frame	$10,   8, 0
	dc.b $FF
	dc.b $FF
stru_7F5A:
	anim_frame	  4,   4, LnkTo_unk_B5088-Data_Index
	anim_frame	  8,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B5088-Data_Index
	anim_frame	  4,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  2,   4, LnkTo_unk_B5088-Data_Index
	anim_frame	  2,   4, LnkTo_unk_B580E-Data_Index
	anim_frame	  3,   4, LnkTo_unk_B5088-Data_Index
	anim_frame	  3,   4, LnkTo_unk_B580E-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B5088-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B580E-Data_Index
	anim_frame	  3,   8, 0
	anim_frame	  5,   4, LnkTo_unk_B580E-Data_Index
	anim_frame	  8,   8, 0
	dc.b $FF
	dc.b $FF
stru_7F90:
	anim_frame	$18,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B8146-Data_Index
	anim_frame	 $C,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B8146-Data_Index
	anim_frame	  6,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B8146-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B85CC-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B8A52-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B85CC-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B8A52-Data_Index
	anim_frame	  8,   8, 0
	anim_frame	  4,   4, LnkTo_unk_B8A52-Data_Index
	anim_frame	  8,   8, 0
	anim_frame	  3,   4, LnkTo_unk_B8A52-Data_Index
	dc.b $FF
	dc.b $FF
stru_7FCA:
	anim_frame	  3,   4, LnkTo_unk_C085E-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0B84-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0EAA-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C1270-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0EAA-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0B84-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C085E-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0B84-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0EAA-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C1270-Data_Index
	anim_frame	  3,   4, LnkTo_unk_C0EAA-Data_Index
	dc.b $FF
	dc.b $FF
stru_7FF8:
	anim_frame	  7,   4, LnkTo_unk_C30E8-Data_Index
	anim_frame	  6,   4, LnkTo_unk_C354E-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C30E8-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C354E-Data_Index
	anim_frame	  4,   4, LnkTo_unk_C39B4-Data_Index
	anim_frame	  4,   4, LnkTo_unk_C354E-Data_Index
	anim_frame	  4,   4, LnkTo_unk_C39B4-Data_Index
	anim_frame	  4,   4, LnkTo_unk_C3FBA-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C39B4-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C3FBA-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C39B4-Data_Index
	anim_frame	  5,   4, LnkTo_unk_C3FBA-Data_Index
	anim_frame	  5,   8, 0
	anim_frame	  5,   4, LnkTo_unk_C3FBA-Data_Index
	anim_frame	  9,   8, 0
	anim_frame	  3,   4, LnkTo_unk_C3FBA-Data_Index
	dc.b $FF
	dc.b $FF
stru_803A:
	anim_frame	 $F,  $C, LnkTo_unk_A4EB4-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B0C1A-Data_Index
	anim_frame	  4,  $C, LnkTo_unk_A4EB4-Data_Index
	anim_frame	  2,   4, LnkTo_unk_B0C1A-Data_Index
	anim_frame	  2,   4, LnkTo_unk_B0EA0-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B0C1A-Data_Index
	anim_frame	  4,   4, LnkTo_unk_B0EA0-Data_Index
	anim_frame	  3,   8, 0
	anim_frame	  5,   4, LnkTo_unk_B0EA0-Data_Index
	anim_frame	  8,   8, 0
	dc.b $FF
	dc.b $FF
stru_8064:
	anim_frame	  8,   4, LnkTo_unk_A67BA-Data_Index
	anim_frame	  3,   4, LnkTo_unk_A6A40-Data_Index
	anim_frame	  6,   4, LnkTo_unk_A67BA-Data_Index
	anim_frame	  3,   4, LnkTo_unk_A6A40-Data_Index
	anim_frame	  4,   4, LnkTo_unk_A6CC6-Data_Index
	anim_frame	  4,   4, LnkTo_unk_A6A40-Data_Index
	anim_frame	  6,   4, LnkTo_unk_A6CC6-Data_Index
	anim_frame	  3,   4, LnkTo_unk_A6A40-Data_Index
	anim_frame	  8,   4, LnkTo_unk_A6CC6-Data_Index
	dc.b $FF
	dc.b $FF
stru_808A:
	anim_frame	 $F,  $C, LnkTo_unk_A4A22-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AC3D0-Data_Index
	anim_frame	  4,  $C, LnkTo_unk_A4EB4-Data_Index
	anim_frame	  2,   4, LnkTo_unk_AC3D0-Data_Index
	anim_frame	  2,   4, LnkTo_unk_AC656-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AC85C-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AC656-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AC85C-Data_Index
	anim_frame	  4,   4, LnkTo_unk_AC656-Data_Index
	anim_frame	  3,   8, 0
	anim_frame	  5,   4, LnkTo_unk_AC85C-Data_Index
	anim_frame	  8,   8, 0
	dc.b $FF
	dc.b $FF

; =============== S U B	R O U T	I N E =======================================


sub_80BC:

	lea	(Palette_Buffer+$62).l,a2
	moveq	#$B,d7
	move.w	#$FFF,d6

loc_80C8:
	move.w	d6,(a2)+
	dbf	d7,loc_80C8
	rts
; End of function sub_80BC


; =============== S U B	R O U T	I N E =======================================


sub_80D0:
	move.l	a2,-(sp)
	add.w	d7,d7
	lea	(Data_Index).l,a4
	add.w	off_80F2(pc,d7.w),a4
	move.l	(a4),a4
	lea	(Palette_Buffer+$62).l,a2
	moveq	#$B,d7

loc_80E8:
	move.w	(a4)+,(a2)+
	dbf	d7,loc_80E8
	move.l	(sp)+,a2
	rts
; End of function sub_80D0

; ---------------------------------------------------------------------------
off_80F2:	dc.w LnkTo_Pal_A1C72-Data_Index
	dc.w LnkTo_Pal_A1CE4-Data_Index
	dc.w LnkTo_Pal_A1E1C-Data_Index
	dc.w LnkTo_Pal_A1DA4-Data_Index
	dc.w LnkTo_Pal_A1DE0-Data_Index
	dc.w LnkTo_Pal_A1E58-Data_Index
	dc.w LnkTo_Pal_A1E94-Data_Index
	dc.w LnkTo_Pal_A1D68-Data_Index
	dc.w LnkTo_Pal_A1C8A-Data_Index
	dc.w LnkTo_Pal_A1D26-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_8106:
	move.l	a2,-(sp)
	add.w	d7,d7
	lea	(Data_Index).l,a4
	add.w	off_8128(pc,d7.w),a4
	move.l	(a4),a4
	lea	(Palette_Buffer+$62).l,a2
	moveq	#$E,d7

loc_811E:
	move.w	(a4)+,(a2)+
	dbf	d7,loc_811E
	move.l	(sp)+,a2
	rts
; End of function sub_8106

; ---------------------------------------------------------------------------
off_8128:	dc.w LnkTo_Pal_A1C72-Data_Index
	dc.w LnkTo_Pal_A1D08-Data_Index
	dc.w LnkTo_Pal_A1E3A-Data_Index
	dc.w LnkTo_Pal_A1DC2-Data_Index
	dc.w LnkTo_Pal_A1DFE-Data_Index
	dc.w LnkTo_Pal_A1E76-Data_Index
	dc.w LnkTo_Pal_A1EB2-Data_Index
	dc.w LnkTo_Pal_A1D86-Data_Index
	dc.w LnkTo_Pal_A1CA8-Data_Index
	dc.w LnkTo_Pal_A1D4A-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_813C:
	move.l	a2,-(sp)
	move.w	(Current_Helmet).w,d7
	add.w	d7,d7
	move.w	off_8162(pc,d7.w),d7
	lea	(Data_Index).l,a4
	move.l	(a4,d7.w),a4
	lea	(Palette_Buffer+$7A).l,a2
	move.w	(a4)+,(a2)+
	move.w	(a4)+,(a2)+
	move.w	(a4)+,(a2)+
	move.l	(sp)+,a2
	rts
; End of function sub_813C

; ---------------------------------------------------------------------------
off_8162:	dc.w LnkTo_Pal_A1C72-Data_Index
	dc.w LnkTo_Pal_A1D02-Data_Index
	dc.w LnkTo_Pal_A1E34-Data_Index
	dc.w LnkTo_Pal_A1DBC-Data_Index
	dc.w LnkTo_Pal_A1DF8-Data_Index
	dc.w LnkTo_Pal_A1E70-Data_Index
	dc.w LnkTo_Pal_A1EAC-Data_Index
	dc.w LnkTo_Pal_A1D80-Data_Index
	dc.w LnkTo_Pal_A1CA2-Data_Index
	dc.w LnkTo_Pal_A1D44-Data_Index
off_8176:	dc.w Data_Index-Data_Index
	dc.w LnkTo_unk_A96C4-Data_Index
	dc.w LnkTo_unk_BACEC-Data_Index
	dc.w LnkTo_unk_B3FB8-Data_Index
	dc.w LnkTo_unk_B7668-Data_Index
	dc.w LnkTo_unk_C1A5C-Data_Index
	dc.w LnkTo_unk_C2324-Data_Index
	dc.w LnkTo_unk_AFF56-Data_Index
	dc.w LnkTo_unk_A5AB6-Data_Index
	dc.w LnkTo_unk_ABA68-Data_Index
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_818A:
	moveq	#-$11,d7
	bsr.w	sub_B43A
	beq.w	loc_819A
	addi.w	#$10,y_pos(a3)

loc_819A:
	sf	(Cyclone_flying).w
	bsr.w	sub_B41C
	move.w	#MoveID_Jump,(Character_Movement).w
	sf	(Cyclone_flying).w
	bsr.w	sub_B270
	bra.w	loc_A6F8
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_81B4:
	moveq	#-$10,d6
	moveq	#-$E,d7
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_81D8
	moveq	#-$10,d6
	moveq	#$E,d7
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_81FA
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_81D8:
	bsr.w	sub_B41C
	moveq	#-$E,d7
	add.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$F,d7
	sub.w	($FFFFFA78).w,d7
	swap	d7
	clr.w	d7
	move.l	d7,x_pos(a3)
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_81FA:
	bsr.w	sub_B41C
	moveq	#$E,d7
	add.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	add.w	($FFFFFA78).w,d7
	swap	d7
	clr.w	d7
	move.l	d7,x_pos(a3)
	moveq	#0,d7
	rts
; End of function sub_81B4

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_8218:
	move.w	#MoveID_Crawling,(Character_Movement).w
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#$E,($FFFFFA78).w
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	bsr.w	sub_7ACC
	beq.s	loc_825C
	move.w	(Current_Helmet).w,d0
	cmpi.w	#9,d0
	beq.s	loc_8252
	cmpi.w	#5,d0
	bne.s	loc_825C

loc_8252:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bra.w	loc_8E16
; ---------------------------------------------------------------------------

loc_825C:
	tst.b	(Ctrl_Down_Held).w
	bne.s	loc_82D8
	subi.w	#8,($FFFFFB58).w
	bge.s	loc_8270
	move.w	#0,($FFFFFB58).w

loc_8270:
	bsr.w	sub_DAA6
	bne.w	loc_82D8
	moveq	#-$11,d7
	bsr.w	sub_B43A
	beq.w	loc_8298
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.w	loc_82D8
	bsr.w	sub_81B4
	bne.w	loc_82D8
	bra.w	loc_829C
; ---------------------------------------------------------------------------

loc_8298:
	bsr.w	sub_B41C

loc_829C:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_82BA
	move.w	#MoveID_Walking,(Character_Movement).w
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_82BA:
	tst.l	x_vel(a3)
	beq.w	loc_82CA
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_82CA:
	clr.w	($FFFFF8F0).w
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bra.w	loc_8E3E
; ---------------------------------------------------------------------------

loc_82D8:
	addq.w	#1,($FFFFFB58).w
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.w	loc_8382
	move.w	d7,a4
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_9A0A
	move.l	d0,($FFFFFA98).w
	add.l	$A(a4),d0
	move.l	d0,x_vel(a3)
	bsr.w	sub_8F26
	beq.w	loc_8306
	clr.l	($FFFFFA98).w

loc_8306:
	move.w	(Addr_PlatformStandingOn).w,a4
	move.l	$E(a4),y_vel(a3)
	move.l	6(a4),y_pos(a3)
	subq.w	#1,y_pos(a3)
	bsr.w	sub_902A
	beq.w	loc_833E
	cmpi.w	#2,d7
	beq.w	loc_837C
	clr.w	(Addr_PlatformStandingOn).w
	clr.l	y_vel(a3)
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_8446
	bra.w	loc_8218
; ---------------------------------------------------------------------------

loc_833E:
	bsr.w	sub_8ED0
	beq.w	loc_8370
	bsr.w	sub_B43A
	beq.w	loc_818A
	clr.w	(Addr_PlatformStandingOn).w
	move.l	x_vel(a3),d0
	bsr.w	sub_8446
	bra.w	loc_8218
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	bsr.w	sub_B41C
	move.w	#MoveID_Jump,(Character_Movement).w
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_8370:
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_8446
	bra.w	loc_8218
; ---------------------------------------------------------------------------

loc_837C:
	moveq	#0,d7
	bra.w	Death
; ---------------------------------------------------------------------------

loc_8382:
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B43A
	bmi.w	loc_BC80
	beq.w	loc_818A
	moveq	#-$10,d0
	moveq	#$F,d1
	bsr.w	sub_8600
	move.l	x_vel(a3),d0
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_83B4
	bsr.w	sub_9A0A
	move.l	d0,x_vel(a3)
	bra.w	loc_83BC
; ---------------------------------------------------------------------------

loc_83B4:
	bsr.w	sub_8506
	move.l	d0,x_vel(a3)

loc_83BC:
	bsr.w	sub_8F26
	bne.w	loc_83D8
	bsr.w	sub_83E6
	bne.w	loc_83D8
	move.l	x_vel(a3),d0
	bsr.w	sub_8446
	bra.w	loc_8218
; ---------------------------------------------------------------------------

loc_83D8:
	moveq	#0,d0
	move.l	d0,x_vel(a3)
	bsr.w	sub_8446
	bra.w	loc_8218
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_83E6:
	move.w	($FFFFFA78).w,d7
	move.l	x_vel(a3),d6
	bmi.w	loc_841A
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$4000,d5
	bne.w	loc_8442
	move.w	($FFFFFA78).w,d7
	add.w	x_pos(a3),d7
	andi.w	#$F,d7
	addq.w	#1,d7
	sub.w	d7,x_pos(a3)
	clr.w	$1C(a3)
	moveq	#1,d6
	rts
; ---------------------------------------------------------------------------

loc_841A:
	neg.w	d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$5000,d5
	bne.w	loc_8442
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	add.w	($FFFFFA78).w,d7
	move.w	d7,x_pos(a3)
	clr.w	$1C(a3)
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_8442:
	moveq	#0,d7
	rts
; End of function sub_83E6


; =============== S U B	R O U T	I N E =======================================


sub_8446:
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_8456
	bsr.w	sub_98F2
	rts
; ---------------------------------------------------------------------------

loc_8456:
	move.w	($FFFFF8F0).w,d2
	tst.l	d0
	bpl.s	loc_8460
	neg.l	d0

loc_8460:
	swap	d0
	rol.l	#5,d0
	add.w	d0,d2
	cmpi.w	#$300,d2
	bcs.s	loc_8470
	subi.w	#$300,d2

loc_8470:
	move.w	d2,($FFFFF8F0).w
	move.w	(Current_Helmet).w,d0
	lsl.w	#2,d0
	lea	off_84A2(pc),a0
	move.l	(a0,d0.w),a0
	lsr.w	#8,d2
	add.w	d2,d2
	add.w	d2,a0
	move.w	(a0),addroffset_sprite(a3)
	rts
; End of function sub_8446

; ---------------------------------------------------------------------------
unk_848E:	dc.b   0
	dc.b $8C ; �
	dc.b   1
	dc.b $28 ; (
	dc.b   3
	dc.b $D8 ; �
	dc.b   3
	dc.b $14
	dc.b   3
	dc.b $78 ; x
	dc.b   4
	dc.b $74 ; t
	dc.b   4
	dc.b $FC ; �
	dc.b   2
	dc.b $94 ; �
	dc.b   1
	dc.b   4
	dc.b   0
	dc.b   0
off_84A2:	dc.l off_84CA
	dc.l off_84D0
	dc.l off_84D6
	dc.l off_84DC
	dc.l off_84E2
	dc.l 0
	dc.l off_84E8
	dc.l off_84EE
	dc.l off_84F4
	dc.l 0
off_84CA:	dc.w LnkTo_unk_A54CC-Data_Index
	dc.w LnkTo_unk_A5612-Data_Index
	dc.w LnkTo_unk_A5758-Data_Index
off_84D0:	dc.w LnkTo_unk_A94AC-Data_Index
	dc.w LnkTo_unk_A94AC-Data_Index
	dc.w LnkTo_unk_A94AC-Data_Index
off_84D6:	dc.w LnkTo_unk_BC2BA-Data_Index
	dc.w LnkTo_unk_BC400-Data_Index
	dc.w LnkTo_unk_BC546-Data_Index
off_84DC:	dc.w LnkTo_unk_B6AF8-Data_Index
	dc.w LnkTo_unk_B6C3E-Data_Index
	dc.w LnkTo_unk_B6D84-Data_Index
off_84E2:	dc.w LnkTo_unk_B9CFC-Data_Index
	dc.w LnkTo_unk_B9E42-Data_Index
	dc.w LnkTo_unk_B9F88-Data_Index
off_84E8:	dc.w LnkTo_unk_C5344-Data_Index
	dc.w LnkTo_unk_C548A-Data_Index
	dc.w LnkTo_unk_C55D0-Data_Index
off_84EE:	dc.w LnkTo_unk_B1E6A-Data_Index
	dc.w LnkTo_unk_B1FB0-Data_Index
	dc.w LnkTo_unk_B20F6-Data_Index
off_84F4:	dc.w LnkTo_unk_A8768-Data_Index
	dc.w LnkTo_unk_A88AE-Data_Index
	dc.w LnkTo_unk_A89B4-Data_Index
off_84FA:	dc.l unk_85C4
	dc.l unk_85EC
	dc.l unk_85D8

; =============== S U B	R O U T	I N E =======================================


sub_8506:
	move.w	($FFFFFA0A).w,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	off_84FA(pc,d1.w),a0
	tst.b	x_direction(a3)
	bne.s	loc_8560

loc_8518:
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_8524
	st	x_direction(a3)
	bra.s	loc_8572
; ---------------------------------------------------------------------------

loc_8524:
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_85AC

loc_852C:
	tst.l	d0
	bpl.s	loc_8536
	add.l	$10(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_8536:
	cmpi.l	#$38000,d0
	ble.s	loc_8544
	move.l	#$38000,d0

loc_8544:
	cmp.l	(a0),d0
	bge.s	loc_8554
	add.l	4(a0),d0
	cmp.l	(a0),d0
	ble.s	return_8552
	move.l	(a0),d0

return_8552:
	rts
; ---------------------------------------------------------------------------

loc_8554:
	sub.l	8(a0),d0
	cmp.l	(a0),d0
	bge.s	return_855E
	move.l	(a0),d0

return_855E:
	rts
; ---------------------------------------------------------------------------

loc_8560:
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_856C
	sf	x_direction(a3)
	bra.s	loc_852C
; ---------------------------------------------------------------------------

loc_856C:
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_85AC

loc_8572:
	tst.l	d0
	bmi.s	loc_857C
	sub.l	$10(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_857C:
	neg.l	d0
	cmpi.l	#$38000,d0
	ble.s	loc_858C
	move.l	#$38000,d0

loc_858C:
	cmp.l	(a0),d0
	bge.s	loc_859E

loc_8590:
	add.l	4(a0),d0
	cmp.l	(a0),d0
	ble.s	loc_859A
	move.l	(a0),d0

loc_859A:
	neg.l	d0
	rts
; ---------------------------------------------------------------------------

loc_859E:
	sub.l	8(a0),d0
	cmp.l	(a0),d0
	bge.s	loc_85A8
	move.l	(a0),d0

loc_85A8:
	neg.l	d0
	rts
; ---------------------------------------------------------------------------

loc_85AC:
	tst.l	d0
	bpl.s	loc_85B8
	add.l	$C(a0),d0
	bpl.s	loc_85C0
	rts
; ---------------------------------------------------------------------------

loc_85B8:
	sub.l	$C(a0),d0
	bmi.s	loc_85C0
	rts
; ---------------------------------------------------------------------------

loc_85C0:
	moveq	#0,d0
	rts
; End of function sub_8506

; ---------------------------------------------------------------------------
unk_85C4:	; on normal terrain
	dc.l   $10000	; max crawling speed
	dc.l    $1000	; crawling acceleration (when pressing left/right)
	dc.l    $1000	; crawling deceleration (when going faster than max speed)
	dc.l    $1800	; ?
	dc.l    $4000	; crawling acceleration (when changing direction)
unk_85D8:	; on ice
	dc.l    $8000	; max crawling speed
	dc.l    $2000	; crawling acceleration (when pressing left/right)
	dc.l    $1000	; crawling deceleration (when going faster than max speed)
	dc.l    $3000	; ?
	dc.l    $8000	; crawling acceleration (when changing direction)
unk_85EC:	; on rubber blocks
	dc.l   $18000	; max crawling speed
	dc.l     $200	; crawling acceleration (when pressing left/right)
	dc.l     $200	; crawling deceleration (when going faster than max speed)
	dc.l     $100	; ?
	dc.l     $800	; crawling acceleration (when changing direction)
; =============== S U B	R O U T	I N E =======================================


sub_8600:
	move.w	($FFFFFA0A).w,($FFFFFA22).w
	move.w	($FFFFFA78).w,d0
	move.w	d0,d1
	neg.w	d0
	add.w	x_pos(a3),d0
	bpl.s	loc_8616
	moveq	#0,d0

loc_8616:
	add.w	x_pos(a3),d1
	cmp.w	(Level_width_pixels).w,d1
	blt.s	loc_8626
	move.w	(Level_width_pixels).w,d1
	subq.w	#1,d1

loc_8626:
	lsr.w	#4,d0
	lsr.w	#4,d1
	sub.w	d0,d1
	move.w	y_pos(a3),d2
	addq.w	#1,d2
	lsr.w	#4,d2
	add.w	d2,d2
	lea	($FFFF4A04).l,a0
	move.w	(a0,d2.w),a0
	add.w	d0,d0
	add.w	d0,a0
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4

loc_864A:
	move.w	(a0),d0
	andi.w	#$6000,d0
	cmpi.w	#$6000,d0
	bne.s	loc_8658
	addq.w	#1,d4

loc_8658:
	move.w	(a0)+,d0
	bpl.s	loc_8672
	andi.w	#$F00,d0
	cmpi.w	#$200,d0
	bne.s	loc_866A
	addq.w	#1,d2
	bra.s	loc_8672
; ---------------------------------------------------------------------------

loc_866A:
	cmpi.w	#$600,d0
	bne.s	loc_8672
	addq.w	#1,d3

loc_8672:
	dbf	d1,loc_864A
	moveq	#0,d0
	add.w	d2,d2
	cmp.w	d4,d2
	ble.s	loc_8680
	moveq	#1,d0

loc_8680:
	add.w	d3,d3
	cmp.w	d4,d3
	blt.s	loc_8688
	moveq	#2,d0

loc_8688:
	move.w	d0,($FFFFFA0A).w
	rts
; End of function sub_8600


; =============== S U B	R O U T	I N E =======================================


sub_868E:
	move.l	d0,-(sp)
	moveq	#sfx_Red_Stealth_sword_swinging,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	#$3000001,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	#(LnkTo1_NULL-Data_Index),addroffset_sprite(a3)
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$1E(a0),d7
	subi.w	#$A,d7
	move.w	d7,y_pos(a3)
	moveq	#$1C,d7
	tst.b	$16(a0)
	beq.w	loc_86CE
	moveq	#-$1C,d7

loc_86CE:
	add.w	$1A(a0),d7
	move.w	d7,x_pos(a3)
	moveq	#3,d0

loc_86D8:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	bne.w	loc_86EC
	dbf	d0,loc_86D8

loc_86E8:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_86EC:
	move.l	d0,-(sp)
	moveq	#sfx_Red_Stealth_hitting_a_target,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bra.s	loc_86E8
; End of function sub_868E


; =============== S U B	R O U T	I N E =======================================


sub_86FA:
	move.l	d0,-(sp)
	moveq	#sfx_Juggernaut_shoot,d0 ; NO SOUND!
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$3000001,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#1,$12(a3)
	move.b	#3,palette_line(a3)
	move.l	(Addr_GfxObject_Kid).w,a2
	exg	a2,a3
	move.l	#stru_8BD8,d7
	jsr	(j_Init_Animation).w
	exg	a2,a3
	tst.b	($FFFFFA6C).w
	bne.w	loc_874C
	move.l	($FFFFF862).w,a4
	exg	a4,a3
	move.l	#stru_8BD2,d7
	jsr	(j_Init_Animation).w
	exg	a4,a3

loc_874C:
	move.l	$1A(a2),x_pos(a3)
	move.l	$1E(a2),y_pos(a3)
	move.b	$16(a2),x_direction(a3)
	move.l	#stru_8BA2,d7
	jsr	(j_Init_Animation).w
	moveq	#3,d0

loc_876A:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.w	loc_879A
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_87B0,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.b	x_direction(a3),$48(a0)
	move.w	#$64,d0

loc_879A:
	move.l	$1A(a2),x_pos(a3)

loc_87A0:
	move.l	$1E(a2),y_pos(a3)
	tst.b	$18(a3)
	beq.s	loc_876A
	jmp	(j_Delete_CurrentObject).w
; End of function sub_86FA


; =============== S U B	R O U T	I N E =======================================


sub_87B0:
	addq.w	#1,($FFFFFB70).w
	move.l	#$3000001,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#3,palette_line(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	subi.w	#8,y_pos(a3)
	moveq	#$1A,d6
	moveq	#4,d7
	move.b	$48(a5),x_direction(a3)
	beq.w	loc_87EC
	moveq	#-$4,d7
	moveq	#-$1A,d6

loc_87EC:
	move.w	d7,x_vel(a3)
	add.w	d6,x_pos(a3)
	moveq	#4,d0
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_899C
	move.l	#stru_8B98,d7
	jsr	(j_Init_Animation).w

loc_8810:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$19(a3)
	bne.w	loc_899C
	tst.w	collision_type(a3)
	bne.w	loc_899C
	addi.l	#$1000,y_vel(a3)
	move.w	x_pos(a3),d6
	move.w	d6,d5
	move.w	x_vel(a3),d7
	bmi.w	loc_887A
	addq.w	#1,d6
	neg.w	d6
	andi.w	#$F,d6
	cmp.w	d6,d7
	bgt.w	loc_8852
	add.w	d5,d7
	move.w	d7,x_pos(a3)
	bra.w	loc_88E6
; ---------------------------------------------------------------------------

loc_8852:
	add.w	d5,d7
	move.w	d7,x_pos(a3)
	moveq	#0,d6
	moveq	#0,d7
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5

loc_8864:
	bne.w	loc_88E6
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	subq.w	#1,d7
	move.w	d7,x_pos(a3)
	bra.w	loc_88B6
; ---------------------------------------------------------------------------

loc_887A:
	andi.w	#$F,d6
	neg.w	d7
	cmp.w	d6,d7
	bgt.w	loc_8890
	sub.w	d7,d5
	move.w	d5,x_pos(a3)
	bra.w	loc_88E6
; ---------------------------------------------------------------------------

loc_8890:
	sub.w	d7,d5
	move.w	d5,x_pos(a3)
	moveq	#0,d6
	moveq	#0,d7
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_88E6
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$10,d7
	move.w	d7,x_pos(a3)

loc_88B6:
	subq.w	#1,d0
	beq.w	loc_899C
	move.w	x_vel(a3),d7
	bmi.w	loc_88D2
	cmpi.w	#1,d7
	beq.w	loc_88DC
	subq.w	#1,d7
	bra.w	loc_88DC
; ---------------------------------------------------------------------------

loc_88D2:
	cmpi.w	#$FFFF,d7
	beq.w	loc_88DC
	addq.w	#1,d7

loc_88DC:
	neg.w	d7
	move.w	d7,x_vel(a3)
	not.b	x_direction(a3)

loc_88E6:
	move.l	y_pos(a3),d7
	move.l	d7,d6
	move.l	d6,d5
	move.l	y_vel(a3),d4
	bmi.w	loc_893C
	swap	d7
	addq.w	#1,d7
	neg.w	d7
	andi.w	#$F,d7
	add.l	d4,d6
	move.l	d6,y_pos(a3)
	swap	d6
	swap	d5
	sub.w	d5,d6
	cmp.w	d7,d5
	bgt.w	loc_8916
	bra.w	loc_8810
; ---------------------------------------------------------------------------

loc_8916:
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_8810
	move.w	y_pos(a3),d7
	clr.w	$20(a3)
	andi.w	#$FFF0,d7
	subq.w	#1,d7
	move.w	d7,y_pos(a3)
	bra.w	loc_897C
; ---------------------------------------------------------------------------

loc_893C:
	swap	d7
	andi.w	#$F,d7
	add.l	d4,d6
	move.l	d6,y_pos(a3)
	swap	d6
	swap	d5
	sub.w	d6,d5
	cmp.w	d7,d5
	bgt.w	loc_8958
	bra.w	loc_8810
; ---------------------------------------------------------------------------

loc_8958:
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_8810
	move.w	y_pos(a3),d7
	clr.w	$20(a3)
	andi.w	#$FFF0,d7
	addi.w	#$10,d7
	move.w	d7,y_pos(a3)

loc_897C:
	move.w	d0,-(sp)
	move.w	(sp)+,d0
	subq.w	#1,d0
	beq.w	loc_899C
	move.l	y_vel(a3),d7
	neg.l	d7
	asr.l	#1,d7
	move.l	d7,d6
	asr.l	#1,d6
	add.l	d6,d7
	move.l	d7,y_vel(a3)
	bra.w	loc_8810
; ---------------------------------------------------------------------------

loc_899C:
	tst.w	($FFFFFB70).w
	beq.s	loc_89A8
	bmi.s	loc_89A8
	subq.w	#1,($FFFFFB70).w

loc_89A8:
	sf	is_moved(a3)
	clr.b	$12(a3)
	clr.b	palette_line(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Juggernaut_skull_explode,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_8BDE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_87B0


; =============== S U B	R O U T	I N E =======================================


sub_89D2:
	move.w	($FFFFFA56).w,d0
	move.w	#6,-(sp)
	jsr	(j_Hibernate_Object).w
	tst.b	(Maniaxe_throwing_axe).w
	beq.w	loc_8ABC
	move.l	#$3000001,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	#stru_8B86,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Maniaxe_throw_axe,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$1A(a0),x_pos(a3)
	move.w	$1E(a0),d7
	subi.w	#$10,d7
	move.w	d7,y_pos(a3)
	move.b	$16(a0),x_direction(a3)
	move.b	#1,$12(a3)
	move.b	#3,palette_line(a3)
	st	$13(a3)
	st	is_moved(a3)
	moveq	#5,d7
	tst.b	x_direction(a3)
	beq.w	loc_8A42
	moveq	#-5,d7

loc_8A42:
	add.w	$26(a0),d7
	move.w	d7,x_vel(a3)
	moveq	#$C,d0
	move.b	x_direction(a3),$3E(a3)

loc_8A52:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	$18(a3)
	beq.w	loc_8A74
	move.l	#stru_8B86,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Maniaxe_throw_axe,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_8A74:
	subq.w	#1,d0
	bne.w	loc_8A84
	not.b	x_direction(a3)
	not.b	$17(a3)
	moveq	#$C,d0

loc_8A84:
	move.w	x_pos(a3),d7
	asr.w	#4,d7
	add.w	d7,d7
	move.w	y_pos(a3),d6
	asr.w	#4,d6
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	add.w	d7,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	beq.w	loc_8ACC
	bsr.w	sub_8AF6
	bne.w	loc_8AF2
	tst.w	collision_type(a3)
	beq.s	loc_8A52

loc_8ABC:
	move.l	d0,-(sp)
	moveq	#sfx_Maniaxe_hitting_enemy,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_8ACC:
	clr.w	x_vel(a3)
	clr.b	$12(a3)
	clr.b	palette_line(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Maniaxe_hitting_enemy,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_8BDE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w

loc_8AF2:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_89D2


; =============== S U B	R O U T	I N E =======================================


sub_8AF6:
	move.w	x_pos(a3),d7
	move.w	(Camera_X_pos).w,d6
	subi.w	#$10,d6
	cmp.w	d6,d7
	blt.w	loc_8B32
	addi.w	#$160,d6
	cmp.w	d6,d7
	bgt.w	loc_8B32
	move.w	y_pos(a3),d7
	move.w	(Camera_Y_pos).w,d6
	subi.w	#$10,d6
	cmp.w	d6,d7
	blt.w	loc_8B32
	addi.w	#$100,d6
	cmp.w	d6,d7
	bgt.w	loc_8B32
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_8B32:
	moveq	#1,d7
	rts
; End of function sub_8AF6

; ---------------------------------------------------------------------------
stru_8B36:
	anim_frame	1, $A, LnkTo_unk_B8ED8-Data_Index 
	dc.b   0
	dc.b   0
stru_8B3C:
	anim_frame	  1,   3, LnkTo_unk_B3520-Data_Index
	anim_frame	  1,   3, LnkTo_unk_B3706-Data_Index
	anim_frame	  1,   2, LnkTo_unk_B3A2C-Data_Index
	anim_frame	  1,   4, LnkTo_unk_B3CB2-Data_Index
	dc.b   0
	dc.b   0
stru_8B4E:
	anim_frame	  1,   3, LnkTo_unk_A6FEC-Data_Index
	anim_frame	  1,   2, LnkTo_unk_A73B2-Data_Index
	anim_frame	  1,   2, LnkTo_unk_A7778-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_A79FE-Data_Index
	dc.b   0
	dc.b   0
stru_8B60:
	anim_frame	  1,   5, LnkTo_unk_A5E02-Data_Index
	anim_frame	  1,  $C, LnkTo_unk_A6128-Data_Index
	dc.b   0
	dc.b   0
stru_8B6A:
	anim_frame	  1,   4, LnkTo_unk_ABF6C-Data_Index
	anim_frame	  1,   4, LnkTo_unk_AC032-Data_Index
	dc.b   2
	dc.b   9
stru_8B74:
	anim_frame	  1,   6, LnkTo_unk_AC0F8-Data_Index
	anim_frame	  1,   6, LnkTo_unk_AC17E-Data_Index
	anim_frame	  1,   6, LnkTo_unk_AC244-Data_Index
	anim_frame	  1,   6, LnkTo_unk_AC30A-Data_Index
	dc.b   0
	dc.b   0
stru_8B86:
	anim_frame	  1,   2, LnkTo_unk_A589E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_A5924-Data_Index
	anim_frame	  1,   2, LnkTo_unk_A59AA-Data_Index
	anim_frame	  1,   2, LnkTo_unk_A5A30-Data_Index
	dc.b   0
	dc.b   0
stru_8B98:
	anim_frame	  1,   7, LnkTo_unk_C1B82-Data_Index
	anim_frame	  1,   7, LnkTo_unk_C1B8A-Data_Index
	dc.b   2
	dc.b   9
stru_8BA2:
	anim_frame	  1,   3, LnkTo_unk_BDF14-Data_Index
	anim_frame	  1,   2, LnkTo_unk_BE09A-Data_Index
	anim_frame	  1,   2, LnkTo_unk_BE320-Data_Index
	anim_frame	  1,   4, LnkTo_unk_BE09A-Data_Index
	dc.b   0
	dc.b   0
stru_8BB4:
	anim_frame	  1,   3, LnkTo_unk_A2E76-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A307C-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A3202-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A3408-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A358E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A3794-Data_Index
	anim_frame	  1,   3, LnkTo_unk_A391A-Data_Index
	dc.b   0
	dc.b   0
stru_8BD2:
	anim_frame	1, $B, LnkTo_unk_BE838-Data_Index 
	dc.b   0
	dc.b   0
stru_8BD8:
	anim_frame	1, $B, LnkTo_unk_BF714-Data_Index 
	dc.b   0
	dc.b   0
stru_8BDE:
	anim_frame	  1,   2, LnkTo_unk_E0F2E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F36-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F3E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F46-Data_Index
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_8BF0:
	move.w	#MoveID_Walking,(Character_Movement).w
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	bsr.w	sub_7ACC

loc_8C12:
	tst.b	(Ctrl_Down_Held).w
	bne.s	loc_8C26
	subi.w	#8,($FFFFFB58).w
	bge.s	loc_8C26
	move.w	#0,($FFFFFB58).w

loc_8C26:
	bsr.w	sub_7428
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_8C70
	move.b	(Ctrl_Held).w,d0
	andi.b	#$C0,d0
	cmpi.b	#$C0,d0
	bne.s	loc_8C70
	tst.w	($FFFFFAB8).w
	bne.s	loc_8C70
	cmpi.w	#2,(Number_Diamonds).w
	blt.s	loc_8C70
	move.w	#$8001,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w
	move.l	#stru_8B36,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Eyeclops_hard_lightbeam,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_8C70:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bne.w	loc_A426
	tst.b	(Ctrl_Down_Held).w
	beq.s	loc_8CB6
	tst.b	(KidGrabbedByHand).w
	bne.w	loc_8CB6
	addq.w	#1,($FFFFFB58).w
	move.w	(Current_Helmet).w,d0
	cmpi.w	#9,d0
	beq.s	loc_8CB6
	cmpi.w	#5,d0
	beq.s	loc_8CB6
	bsr.w	sub_7A10
	bne.w	loc_8CB6
	move.l	x_vel(a3),d0
	move.w	#MoveID_Crawling,(Character_Movement).w
	bsr.w	sub_8446
	bra.w	loc_8218
; ---------------------------------------------------------------------------

loc_8CB6:
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_8D72
	cmpi.w	#Maniaxe,(Current_Helmet).w
	bne.w	loc_8CF8
	tst.b	(Maniaxe_throwing_axe).w
	bne.w	loc_8D72
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_89D2,4(a0)
	move.l	#stru_8B4E,d7
	jsr	(j_Init_Animation).w
	clr.l	x_vel(a3)
	st	(Maniaxe_throwing_axe).w
	bra.w	loc_8D72
; ---------------------------------------------------------------------------

loc_8CF8:
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	bne.w	loc_8D2C
	tst.b	(Red_Stealth_sword_swing).w
	bne.w	loc_8D72
	move.l	#stru_8B3C,d7
	jsr	(j_Init_Animation).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_868E,4(a0)
	st	(Red_Stealth_sword_swing).w
	bra.w	loc_8D72
; ---------------------------------------------------------------------------

loc_8D2C:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.w	loc_8D58
	tst.b	is_animated(a3)
	bne.w	loc_8D72
	cmpi.w	#8,($FFFFFB70).w
	bge.w	loc_8D72
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_86FA,4(a0)

loc_8D58:
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_8D72
	tst.w	($FFFFFAB8).w
	bne.s	loc_8D72
	move.w	#1,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w

loc_8D72:
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.w	loc_8E06
	move.w	d7,a4
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_9A0A
	move.l	d0,($FFFFFA98).w
	beq.w	loc_8DFC
	add.l	$A(a4),d0
	move.l	d0,x_vel(a3)
	bsr.w	sub_8F26
	beq.w	loc_8DA0
	clr.l	($FFFFFA98).w

loc_8DA0:
	move.w	(Addr_PlatformStandingOn).w,a4
	move.l	$E(a4),y_vel(a3)
	move.l	6(a4),y_pos(a3)
	subq.w	#1,y_pos(a3)
	bsr.w	sub_902A
	beq.w	loc_8DD4
	cmpi.w	#2,d7
	beq.w	loc_8DF6
	clr.w	(Addr_PlatformStandingOn).w
	clr.l	y_vel(a3)
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_8DD4:
	bsr.w	sub_8ED0
	beq.w	loc_8DEA
	move.w	#MoveID_Jump,(Character_Movement).w
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_8DEA:
	move.l	($FFFFFA98).w,d0
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_8DF6:
	moveq	#0,d7
	bra.w	Death
; ---------------------------------------------------------------------------

loc_8DFC:
	move.w	#MoveID_Standingstill,(Character_Movement).w
	bra.w	loc_7606
; ---------------------------------------------------------------------------

loc_8E06:
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B43A
	bmi.w	loc_BC80
	beq.w	loc_B5F6

loc_8E16:
	bsr.w	sub_8600
	move.l	x_vel(a3),d0
	bsr.w	sub_9A0A
	move.l	d0,x_vel(a3)
	bne.w	loc_8E3E
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.w	loc_8E3E
	move.w	#MoveID_Standingstill,(Character_Movement).w
	bra.w	loc_7606
; ---------------------------------------------------------------------------

loc_8E3E:
	bsr.w	sub_8F26
	bne.w	loc_8E5A
	bsr.w	sub_9386
	bne.w	loc_8E80

loc_8E4E:
	move.l	x_vel(a3),d0
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_8E5A:
	bmi.w	loc_8E74
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.s	loc_8E4E
	move.w	#MoveID_Standingstill,(Character_Movement).w
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_8E74:
	move.l	x_vel(a3),d0
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_8E80:
	bmi.w	loc_8E98
	move.w	(Current_Helmet).w,d7
	cmpi.w	#1,d7
	beq.s	loc_8E4E
	cmpi.w	#5,d7
	beq.s	loc_8E4E
	bra.w	loc_9D22
; ---------------------------------------------------------------------------

loc_8E98:
	move.w	(Current_Helmet).w,d7
	move.w	#$2C5,d6
	btst	d7,d6
	bne.w	loc_9D22
	clr.w	$1C(a3)
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	subq.w	#1,d7
	move.w	d7,x_pos(a3)
	move.l	x_vel(a3),d6
	bpl.w	loc_8EC8
	addi.w	#$11,d7
	move.w	d7,x_pos(a3)

loc_8EC8:
	bsr.w	sub_78E8
	bra.w	loc_75D4
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_8ED0:
	move.w	(Addr_PlatformStandingOn).w,d7
	beq.w	loc_8F1C
	move.w	d7,a4
	move.w	x_pos(a3),d7
	move.w	($FFFFFA78).w,d6
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	bne.w	loc_8EFA
	moveq	#7,d6
	cmpi.w	#The_Kid,(Current_Helmet).w
	bne.w	loc_8EFA
	moveq	#5,d6

loc_8EFA:
	move.w	2(a4),d5
	add.w	d6,d7
	cmp.w	d5,d7
	blt.w	loc_8F18
	sub.w	d6,d7
	sub.w	d6,d7
	sub.w	x_pos(a4),d7
	cmp.w	d5,d7
	bgt.w	loc_8F18
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_8F18:
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_8F1C:
	move.w	#4,collision_type(a3)
	bra.s	loc_8F18
; End of function sub_8ED0

; ---------------------------------------------------------------------------
	bra.s	loc_8F1C

; =============== S U B	R O U T	I N E =======================================


sub_8F26:
	move.l	x_pos(a3),d7
	move.l	d7,d4
	move.l	x_vel(a3),d0
	bmi.w	loc_8FAC
	add.l	d0,d4
	move.l	d4,x_pos(a3)
	swap	d4
	swap	d7
	sub.w	d7,d4
	add.w	($FFFFFA78).w,d7
	move.w	d7,d0
	addq.w	#1,d0
	neg.w	d0
	andi.w	#$F,d0
	cmp.w	d0,d4
	ble.w	loc_9022
	add.w	d4,d7
	cmp.w	(Level_width_pixels).w,d7
	bge.w	loc_8F86
	bsr.w	sub_922C
	beq.w	loc_9022
	move.l	x_vel(a3),d6
	clr.l	x_vel(a3)
	sub.w	d0,d4
	sub.w	d4,x_pos(a3)
	clr.w	$1C(a3)
	tst.w	d7
	bmi.w	loc_8F98
	sf	($FFFFFA72).w
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_8F86:
	clr.l	x_vel(a3)
	sub.w	d0,d4
	sub.w	d4,x_pos(a3)
	clr.w	$1C(a3)
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_8F98:
	cmpi.l	#$8000,d6
	blt.w	loc_901E
	neg.l	d6
	move.l	d6,x_vel(a3)
	bra.w	loc_901E
; ---------------------------------------------------------------------------

loc_8FAC:
	add.l	d0,d4
	move.l	d4,x_pos(a3)
	swap	d4
	swap	d7
	sub.w	d7,d4
	neg.l	d4
	sub.w	($FFFFFA78).w,d7
	move.w	d7,d0
	andi.w	#$F,d0
	cmp.w	d0,d4
	ble.w	loc_9022
	sub.w	d4,d7
	bmi.w	loc_8FF8
	bsr.w	sub_922C
	beq.w	loc_9022
	move.l	x_vel(a3),d6
	clr.l	x_vel(a3)
	sub.w	d0,d4
	add.w	d4,x_pos(a3)
	clr.w	$1C(a3)
	tst.w	d7
	bmi.w	loc_900A
	st	($FFFFFA72).w
	moveq	#2,d7
	rts
; ---------------------------------------------------------------------------

loc_8FF8:
	clr.l	x_vel(a3)
	sub.w	d0,d4
	add.w	d4,x_pos(a3)
	clr.w	$1C(a3)
	moveq	#0,d6
	rts
; ---------------------------------------------------------------------------

loc_900A:
	neg.l	d6
	cmpi.l	#$8000,d6
	blt.w	loc_901E
	move.l	d6,x_vel(a3)
	bra.w	*+4

loc_901E:
	moveq	#-1,d7
	rts
; ---------------------------------------------------------------------------

loc_9022:
	moveq	#0,d7
	rts
; End of function sub_8F26

; ---------------------------------------------------------------------------
	moveq	#1,d7
	rts

; =============== S U B	R O U T	I N E =======================================


sub_902A:
	move.l	y_pos(a3),d7
	move.l	d7,d4
	move.l	y_vel(a3),d0
	bmi.w	loc_908C
	add.l	d0,d4
	move.l	d4,y_pos(a3)
	swap	d4
	swap	d7
	sub.w	d7,d4
	move.w	d7,d0
	addq.w	#1,d0
	neg.w	d0
	andi.w	#$F,d0
	cmp.w	d0,d4
	ble.w	loc_913A
	add.w	d4,d7
	cmp.w	(Level_height_blocks).w,d7
	bge.w	loc_9142
	bsr.w	sub_914A
	beq.w	loc_913A
	move.l	y_vel(a3),d6
	clr.l	y_vel(a3)
	sub.w	d0,d4
	sub.w	d4,y_pos(a3)
	clr.w	$20(a3)
	tst.w	d7
	bmi.w	loc_9082
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_9082:
	neg.l	d6
	move.l	d6,y_vel(a3)
	moveq	#-1,d7
	rts
; ---------------------------------------------------------------------------

loc_908C:
	add.l	d0,d4
	move.l	d4,y_pos(a3)
	swap	d4
	swap	d7
	sub.w	d7,d4
	neg.w	d4
	subi.w	#$F,d7
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	beq.w	loc_90C0
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_90C0
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_90C0
	subi.w	#$10,d7

loc_90C0:
	move.w	d7,d0
	andi.w	#$F,d0
	cmp.w	d0,d4
	ble.w	loc_913A
	sub.w	d4,d7
	bmi.w	loc_90F6
	bsr.w	sub_914A
	beq.w	loc_913A
	move.l	y_vel(a3),d6
	clr.l	y_vel(a3)
	sub.w	d0,d4
	add.w	d4,y_pos(a3)
	clr.w	$20(a3)
	tst.w	d7
	bmi.w	loc_9130
	moveq	#2,d7
	rts
; ---------------------------------------------------------------------------

loc_90F6:
	tst.b	($FFFFFA6A).w
	bne.w	loc_9114
	move.l	y_vel(a3),d6
	clr.l	y_vel(a3)
	sub.w	d0,d4
	add.w	d4,y_pos(a3)
	clr.w	$20(a3)
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_9114:
	move.b	#1,($FFFFFA69).w
	sub.w	d0,d4
	add.w	d4,y_pos(a3)
	clr.w	$20(a3)
	move.l	#$30000,y_vel(a3)
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_9130:
	neg.l	d6
	move.l	d6,y_vel(a3)
	moveq	#-1,d7
	rts
; ---------------------------------------------------------------------------

loc_913A:
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_9142:
	addq.w	#4,sp
	moveq	#1,d7
	bra.w	Death
; End of function sub_902A


; =============== S U B	R O U T	I N E =======================================


sub_914A:


	clr.w	($FFFFFB6C).w
	subq.w	#2,sp
	move.w	x_pos(a3),d6
	sub.w	($FFFFFA78).w,d6
	asr.w	#4,d6
	move.w	d6,d5
	add.w	d6,d6
	asr.w	#4,d7
	bmi.w	loc_9226
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	add.w	d6,a4
	move.w	x_pos(a3),d7
	add.w	($FFFFFA78).w,d7
	asr.w	#4,d7
	sub.w	d5,d7
	exg	d5,d7
	dc.l	$51EF0000	; bindary for opcode _sf	0(sp)
	sf	1(sp)

loc_9188:
	move.w	(a4)+,d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	beq.w	loc_91AC
	cmpi.w	#$7000,d7
	beq.w	loc_91A6

loc_919E:
	dbf	d5,loc_9188
	bra.w	loc_9204
; ---------------------------------------------------------------------------

loc_91A6:
	move.w	#colid_kidbelow,collision_type(a3)

loc_91AC:
	st	1(sp)
	tst.w	($FFFFFB6C).w
	bne.w	loc_91C0
	move.w	a4,d7
	subq.w	#2,d7
	move.w	d7,($FFFFFB6C).w

loc_91C0:
	move.w	-2(a4),d7
	bclr	#$F,d7
	beq.s	loc_919E
	andi.w	#$F00,d7
	asr.w	#6,d7
	cmpi.w	#$18,d7
	bne.s	loc_919E
	dc.l	$50EF0000	; bindary for opcode _st	0(sp)
	move.l	a4,-(sp)
	movem.w	d0-d7,-(sp)
	move.l	a4,d3
	subq.w	#2,d3
	moveq	#0,d6
	jsr	(j_sub_FACE).l
	tst.l	y_vel(a3)
	bpl.w	loc_91F6
	moveq	#2,d6

loc_91F6:
	jsr	(j_loc_10DA4).l
	movem.w	(sp)+,d0-d7
	move.l	(sp)+,a4
	bra.s	loc_919E
; ---------------------------------------------------------------------------

loc_9204:
	_tst.b	0(sp)
	beq.w	loc_9212
	moveq	#-1,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------

loc_9212:
	tst.b	1(sp)
	beq.w	loc_9220
	moveq	#1,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------

loc_9220:
	moveq	#0,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------

loc_9226:
	moveq	#1,d7
	addq.w	#2,sp
	rts
; End of function sub_914A


; =============== S U B	R O U T	I N E =======================================


sub_922C:


	subq.w	#2,sp
	move.w	y_pos(a3),d6
	asr.w	#4,d6
	move.w	d6,d5
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	asr.w	#4,d7
	bmi.w	loc_9380
	add.w	d7,d7
	cmp.w	(Level_width_tiles).w,d7
	bgt.w	loc_9380
	add.w	d7,a4
	move.w	y_pos(a3),d7
	subi.w	#$F,d7
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	beq.w	loc_9288
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_9288
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_9288
	cmpi.w	#(LnkTo_unk_A94AC-Data_Index),addroffset_sprite(a3)
	beq.w	loc_9288
	subi.w	#$10,d7

loc_9288:
	asr.w	#4,d7
	sub.w	d7,d5
	dc.l	$51EF0000	; bindary for opcode _sf	0(sp)
	sf	1(sp)

loc_9294:
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	beq.w	loc_92BC
	cmpi.w	#$7000,d7
	beq.w	loc_92B6

loc_92AA:
	suba.w	(Level_width_tiles).w,a4
	dbf	d5,loc_9294
	bra.w	loc_9318
; ---------------------------------------------------------------------------

loc_92B6:
	move.w	#colid_kidbelow,collision_type(a3)

loc_92BC:
	st	1(sp)
	move.w	(a4),d7
	bclr	#$F,d7
	beq.s	loc_92AA
	andi.w	#$F00,d7
	asr.w	#6,d7
	cmpi.w	#$18,d7
	bne.w	loc_92DE
	dc.l	$50EF0000	; bindary for opcode _st	0(sp)
	bra.w	loc_92EC
; ---------------------------------------------------------------------------

loc_92DE:
	tst.b	(Berzerker_charging).w
	beq.s	loc_92AA
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	beq.s	loc_92AA

loc_92EC:
	move.l	a4,-(sp)
	movem.w	d0-d7,-(sp)
	lea	off_933E(pc),a2
	move.l	(a2,d7.w),a2
	move.l	a4,d3
	moveq	#3,d6
	jsr	(j_sub_FACE).l
	tst.l	x_vel(a3)
	bpl.w	loc_930E
	moveq	#1,d6

loc_930E:
	jsr	(a2)
	movem.w	(sp)+,d0-d7
	move.l	(sp)+,a4
	bra.s	loc_92AA
; ---------------------------------------------------------------------------

loc_9318:
	_tst.b	0(sp)
	beq.w	loc_9326
	moveq	#-1,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------

loc_9326:
	tst.b	1(sp)
	beq.w	loc_9338
	sf	(Berzerker_charging).w
	moveq	#1,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------

loc_9338:
	moveq	#0,d7
	addq.w	#2,sp
	rts
; ---------------------------------------------------------------------------
off_933E:	dc.l j_sub_10E86
	dc.l j_sub_10E86
	dc.l j_sub_10F44
	dc.l return_937E
	dc.l return_937E
	dc.l j_loc_111F4
	dc.l j_loc_10DA4
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
	dc.l return_937E
; ---------------------------------------------------------------------------

return_937E:
	rts
; ---------------------------------------------------------------------------

loc_9380:
	moveq	#1,d7
	addq.w	#2,sp
	rts
; End of function sub_922C


; =============== S U B	R O U T	I N E =======================================


sub_9386:
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$4000,d5
	bne.w	loc_93AE
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	add.w	y_pos(a3),d7
	move.w	d7,($FFFFFA24).w
	sf	($FFFFFA26).w
	moveq	#-1,d7
	rts
; ---------------------------------------------------------------------------

loc_93AE:
	cmpi.w	#$5000,d5
	bne.w	loc_93D4
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$F,d7
	sub.w	y_pos(a3),d7
	neg.w	d7
	move.w	d7,($FFFFFA24).w
	st	($FFFFFA26).w
	moveq	#-1,d7
	rts
; ---------------------------------------------------------------------------

loc_93D4:
	add.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$4000,d7
	bne.w	loc_9402
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$10,d7
	add.w	y_pos(a3),d7
	move.w	d7,($FFFFFA24).w
	sf	($FFFFFA26).w
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_9402:
	cmpi.w	#$5000,d7
	bne.w	loc_9426
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	subq.w	#1,d7
	sub.w	y_pos(a3),d7
	neg.w	d7
	move.w	d7,($FFFFFA24).w
	st	($FFFFFA26).w
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_9426:
	moveq	#0,d7
	rts
; End of function sub_9386


; =============== S U B	R O U T	I N E =======================================


sub_942A:
	move.l	($FFFFF862).w,a2
	sf	$3C(a2)
	move.w	(Current_Helmet).w,d1
	move.w	($FFFFF8F0).w,d2
	cmpi.w	#8,d1
	bne.w	loc_9454
	tst.b	(Maniaxe_throwing_axe).w
	beq.w	loc_9454
	tst.b	$18(a3)
	bne.w	loc_9454
	rts
; ---------------------------------------------------------------------------

loc_9454:
	sf	(Maniaxe_throwing_axe).w
	cmpi.w	#3,d1
	bne.w	loc_9472
	tst.b	(Red_Stealth_sword_swing).w
	beq.w	loc_9472
	tst.b	$18(a3)
	bne.w	loc_9472
	rts
; ---------------------------------------------------------------------------

loc_9472:
	sf	(Red_Stealth_sword_swing).w
	cmpi.w	#1,d1
	bne.w	loc_9484
	bsr.w	sub_98F2
	rts
; ---------------------------------------------------------------------------

loc_9484:
	cmpi.w	#5,d1
	bne.w	loc_94F6
	move.w	($FFFFF8F0).w,d2
	move.l	($FFFFF862).w,a4
	move.l	x_vel(a3),d0
	bpl.s	loc_949C
	neg.l	d0

loc_949C:
	swap	d0
	rol.l	#4,d0
	add.w	d0,d2
	cmpi.w	#9,d1
	bne.s	loc_94AA
	add.w	d0,d2

loc_94AA:
	cmpi.w	#$600,d2
	bcs.s	loc_94B4
	subi.w	#$600,d2

loc_94B4:
	move.w	d2,($FFFFF8F0).w
	move.w	d1,d0
	lsl.w	#2,d0
	lea	(off_94E6).l,a0
	lsr.w	#8,d2
	add.w	d2,d2
	add.w	d2,a0
	tst.b	is_animated(a3)
	beq.w	loc_94D8
	tst.b	$18(a3)
	beq.w	loc_94E0

loc_94D8:
	move.w	(a0),addroffset_sprite(a3)
	sf	is_animated(a3)

loc_94E0:
	bsr.w	sub_975C
	rts
; ---------------------------------------------------------------------------
off_94E6:	dc.w LnkTo_unk_C0246-Data_Index
	dc.w LnkTo_unk_C03CC-Data_Index
	dc.w LnkTo_unk_C0552-Data_Index
	dc.w LnkTo_unk_C06D8-Data_Index
	dc.w LnkTo_unk_C0246-Data_Index
	dc.w LnkTo_unk_C03CC-Data_Index
	dc.w LnkTo_unk_C0552-Data_Index
	dc.w LnkTo_unk_C06D8-Data_Index
; ---------------------------------------------------------------------------

loc_94F6:
	cmpi.w	#7,d1
	bne.w	loc_9580
	tst.l	d0
	bmi.s	loc_950A
	tst.b	x_direction(a3)
	bne.s	loc_957C
	bra.s	loc_9512
; ---------------------------------------------------------------------------

loc_950A:
	tst.b	x_direction(a3)
	beq.s	loc_957C
	neg.l	d0

loc_9512:
	cmpi.w	#1,($FFFFFA0A).w
	bne.s	loc_9526
	tst.b	(Ctrl_Left_Held).w
	bne.s	loc_9526
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_957C

loc_9526:
	cmpi.l	#$10000,d0
	blt.s	loc_957C
	addi.b	#$10,($FFFFFA13).w
	bcc.s	loc_9580
	move.b	#$FF,($FFFFFA13).w
	move.w	($FFFFF8F0).w,d2
	cmpi.w	#1,($FFFFFA0A).w
	beq.s	loc_9556
	rol.l	#2,d0
	move.l	d0,d1
	rol.l	#2,d0
	add.l	d1,d0
	swap	d0
	add.w	d0,d2
	bra.s	loc_955A
; ---------------------------------------------------------------------------

loc_9556:
	addi.w	#$40,d2

loc_955A:
	cmpi.w	#$600,d2
	bcs.s	loc_9564
	subi.w	#$600,d2

loc_9564:
	move.w	d2,($FFFFF8F0).w
	st	(Berzerker_charging).w
	lea	off_9688(pc),a0
	lsr.w	#8,d2
	add.w	d2,d2
	add.w	d2,a0
	move.w	(a0),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_957C:
	clr.b	($FFFFFA13).w

loc_9580:
	sf	(Berzerker_charging).w
	cmpi.w	#0,d1
	bne.s	loc_95A4
	tst.l	d0
	bpl.s	loc_9596
	tst.b	x_direction(a3)
	bne.s	loc_95A4
	bra.s	loc_959C
; ---------------------------------------------------------------------------

loc_9596:
	tst.b	x_direction(a3)
	beq.s	loc_95A4

loc_959C:
	move.w	#(LnkTo_unk_A5346-Data_Index),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_95A4:
	cmpi.w	#1,($FFFFFA0A).w
	bne.s	loc_95DA
	addi.w	#$40,d2
	cmpi.w	#$600,d2
	bcs.s	loc_95BA
	subi.w	#$600,d2

loc_95BA:
	move.w	d2,($FFFFF8F0).w
	tst.b	(Ctrl_Left_Held).w
	bne.s	loc_9600
	tst.b	(Ctrl_Right_Held).w
	bne.s	loc_9600
	move.w	d1,d0
	add.w	d0,d0
	lea	off_79B2(pc),a0
	add.w	d0,a0
	move.w	(a0),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_95DA:
	move.w	($FFFFF8F0).w,d2
	tst.l	d0
	bpl.s	loc_95E4
	neg.l	d0

loc_95E4:
	swap	d0
	rol.l	#5,d0
	add.w	d0,d2
	cmpi.w	#9,d1
	bne.s	loc_95F2
	add.w	d0,d2

loc_95F2:
	cmpi.w	#$600,d2
	bcs.s	loc_95FC
	subi.w	#$600,d2

loc_95FC:
	move.w	d2,($FFFFF8F0).w

loc_9600:
	move.w	d1,d0
	lsl.w	#2,d0
	lea	off_9618(pc),a0
	move.l	(a0,d0.w),a0
	lsr.w	#8,d2
	add.w	d2,d2
	add.w	d2,a0
	move.w	(a0),addroffset_sprite(a3)
	rts
; End of function sub_942A

; ---------------------------------------------------------------------------
off_9618:	dc.l off_9640
	dc.l 0
	dc.l off_964C
	dc.l off_9658
	dc.l off_9664
	dc.l 0
	dc.l off_9670
	dc.l off_967C
	dc.l off_9694
	dc.l off_96A0
off_9640:	dc.w LnkTo_unk_A4A22-Data_Index
	dc.w LnkTo_unk_A4BA8-Data_Index
	dc.w LnkTo_unk_A4D2E-Data_Index
	dc.w LnkTo_unk_A4EB4-Data_Index
	dc.w LnkTo_unk_A503A-Data_Index
	dc.w LnkTo_unk_A51C0-Data_Index
off_964C:	dc.w LnkTo_unk_BB996-Data_Index
	dc.w LnkTo_unk_BBB1C-Data_Index
	dc.w LnkTo_unk_BBCA2-Data_Index
	dc.w LnkTo_unk_BBE28-Data_Index
	dc.w LnkTo_unk_BBFAE-Data_Index
	dc.w LnkTo_unk_BC134-Data_Index
off_9658:	dc.w LnkTo_unk_B5F94-Data_Index
	dc.w LnkTo_unk_B617A-Data_Index
	dc.w LnkTo_unk_B6360-Data_Index
	dc.w LnkTo_unk_B6546-Data_Index
	dc.w LnkTo_unk_B672C-Data_Index
	dc.w LnkTo_unk_B6912-Data_Index
off_9664:	dc.w LnkTo_unk_B8ED8-Data_Index
	dc.w LnkTo_unk_B915E-Data_Index
	dc.w LnkTo_unk_B9364-Data_Index
	dc.w LnkTo_unk_B95EA-Data_Index
	dc.w LnkTo_unk_B9870-Data_Index
	dc.w LnkTo_unk_B9A76-Data_Index
off_9670:	dc.w LnkTo_unk_C4420-Data_Index
	dc.w LnkTo_unk_C46A6-Data_Index
	dc.w LnkTo_unk_C492C-Data_Index
	dc.w LnkTo_unk_C4BB2-Data_Index
	dc.w LnkTo_unk_C4E38-Data_Index
	dc.w LnkTo_unk_C50BE-Data_Index
off_967C:	dc.w LnkTo_unk_AE24E-Data_Index
	dc.w LnkTo_unk_AE4D4-Data_Index
	dc.w LnkTo_unk_AE75A-Data_Index
	dc.w LnkTo_unk_AE9E0-Data_Index
	dc.w LnkTo_unk_AEC66-Data_Index
	dc.w LnkTo_unk_AEEEC-Data_Index
off_9688:	dc.w LnkTo_unk_AD32A-Data_Index
	dc.w LnkTo_unk_AD5B0-Data_Index
	dc.w LnkTo_unk_AD836-Data_Index
	dc.w LnkTo_unk_ADABC-Data_Index
	dc.w LnkTo_unk_ADD42-Data_Index
	dc.w LnkTo_unk_ADFC8-Data_Index
off_9694:	dc.w LnkTo_unk_A7C04-Data_Index
	dc.w LnkTo_unk_A7E0A-Data_Index
	dc.w LnkTo_unk_A8090-Data_Index
	dc.w LnkTo_unk_A8276-Data_Index
	dc.w LnkTo_unk_A83FC-Data_Index
	dc.w LnkTo_unk_A85E2-Data_Index
off_96A0:	dc.w LnkTo_unk_ACE86-Data_Index
	dc.w LnkTo_unk_ACF4C-Data_Index
	dc.w LnkTo_unk_AD012-Data_Index
	dc.w LnkTo_unk_AD0D8-Data_Index
	dc.w LnkTo_unk_AD19E-Data_Index
	dc.w LnkTo_unk_AD264-Data_Index
unk_96AC:	dc.b   0
	dc.b   6
	dc.b   1
	dc.b  $A
	dc.b   2
	dc.b $1E
	dc.b   3
	dc.b $14
	dc.b   4
	dc.b   6
	dc.b   5
	dc.b  $A
	dc.b   0
	dc.b  $A
	dc.b   1
	dc.b   8
	dc.b   2
	dc.b  $C
	dc.b   3
	dc.b   8
	dc.b   4
	dc.b  $A
	dc.b   5
	dc.b  $C
	dc.b   0
	dc.b  $F
	dc.b   1
	dc.b  $F
	dc.b   2
	dc.b $19
	dc.b   3
	dc.b  $F
	dc.b   4
	dc.b $19
	dc.b   5
	dc.b  $A
unk_96D0:	dc.b   0
	dc.b  $F
	dc.b   1
	dc.b $19
	dc.b   2
	dc.b  $A
	dc.b   3
	dc.b   6
	dc.b   4
	dc.b  $A
	dc.b   5
	dc.b $1E
	dc.b   0
	dc.b  $F
	dc.b   1
	dc.b   6
	dc.b   2
	dc.b $19
	dc.b   3
	dc.b  $A
	dc.b   4
	dc.b  $F
	dc.b   5
	dc.b $19

; =============== S U B	R O U T	I N E =======================================


sub_96E8:
	movem.l	a0-a1,-(sp)
	move.w	y_pos(a3),d5
	move.w	d5,d6
	subi.w	#$1F,d5
	subi.w	#$10,d6
	asr.w	#4,d5
	asr.w	#4,d6
	sub.w	d5,d6
	add.w	d5,d5
	lea	($FFFF4A04).l,a0
	move.w	(a0,d5.w),a0
	moveq	#$B,d5
	moveq	#4,d7
	tst.b	x_direction(a3)
	beq.w	loc_971A
	exg	d5,d7

loc_971A:
	sub.w	x_pos(a3),d5
	neg.w	d5
	add.w	x_pos(a3),d7
	asr.w	#4,d5
	asr.w	#4,d7
	sub.w	d5,d7
	add.w	d5,d5
	add.w	d5,a0

loc_972E:
	move.w	d7,d4
	move.w	a0,a1

loc_9732:
	move.w	(a1)+,d5
	andi.w	#$7000,d5
	cmpi.w	#$6000,d5
	beq.w	loc_9754
	dbf	d4,loc_9732
	add.w	(Level_width_tiles).w,a0
	dbf	d6,loc_972E
	movem.l	(sp)+,a0-a1
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_9754:
	movem.l	(sp)+,a0-a1
	moveq	#1,d7
	rts
; End of function sub_96E8


; =============== S U B	R O U T	I N E =======================================


sub_975C:
	tst.b	$15(a4)
	beq.w	loc_976C
	tst.b	$18(a4)
	beq.w	loc_97FE

loc_976C:
	sf	$15(a4)
	tst.b	($FFFFFA6C).w
	beq.w	loc_97A6
	bsr.w	sub_96E8
	bne.w	loc_97FE
	bsr.w	sub_9832
	bne.w	loc_97FE
	tst.b	(Ctrl_Down_Held).w
	bne.w	loc_97FE
	move.l	#stru_9812,d7
	exg	a3,a4
	jsr	(j_Init_Animation).w
	exg	a3,a4
	sf	($FFFFFA6C).w
	bra.w	loc_97FE
; ---------------------------------------------------------------------------

loc_97A6:
	bsr.w	sub_96E8
	bne.w	loc_97BE
	bsr.w	sub_9832
	bne.w	loc_97BE
	tst.b	(Ctrl_Down_Held).w
	beq.w	loc_97D4

loc_97BE:
	move.l	#stru_981C,d7
	exg	a3,a4
	jsr	(j_Init_Animation).w
	exg	a3,a4
	st	($FFFFFA6C).w
	bra.w	loc_97FE
; ---------------------------------------------------------------------------

loc_97D4:
	cmpi.w	#MoveID_Standingstill,(Character_Movement).w
	bne.w	loc_97E8
	move.w	#(LnkTo_unk_BEDF0-Data_Index),$22(a4)
	bra.w	loc_97FE
; ---------------------------------------------------------------------------

loc_97E8:
	cmpi.w	#MoveID_Walking,(Character_Movement).w
	bne.w	loc_97FE
	lea	(off_9826).l,a0
	add.w	d2,a0
	move.w	(a0),$22(a4)

loc_97FE:
	move.l	x_pos(a3),x_pos(a4)
	move.l	y_pos(a3),y_pos(a4)
	move.b	x_direction(a3),$16(a4)
	rts
; End of function sub_975C

; ---------------------------------------------------------------------------
stru_9812:
	anim_frame	  1,   5, LnkTo_unk_BE772-Data_Index
	anim_frame	  1,   5, LnkTo_unk_BEDF0-Data_Index
	dc.w 0
stru_981C:
	anim_frame	  1,   5, LnkTo_unk_BE772-Data_Index
	anim_frame	  1,   5, LnkTo_unk_BE6A6-Data_Index
	dc.w 0
off_9826:	dc.w LnkTo_unk_BEDF0-Data_Index
	dc.w LnkTo_unk_BEF76-Data_Index
	dc.w LnkTo_unk_BF0FC-Data_Index
	dc.w LnkTo_unk_BF282-Data_Index
	dc.w LnkTo_unk_BF408-Data_Index
	dc.w LnkTo_unk_BF58E-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_9832:
	movem.l	d0-d3,-(sp)
	move.w	x_pos(a3),d0
	move.w	d0,d1
	subi.w	#$28,d0
	addi.w	#$28,d1
	move.w	y_pos(a3),d2
	subi.w	#$1F,d2
	move.w	d2,d3
	addi.w	#$10,d3
	movem.l	a2-a3,-(sp)
	lea	($FFFFF86A).w,a2

loc_985A:
	move.l	4(a2),d4
	beq.w	loc_98E4
	move.l	d4,a2
	tst.b	$3D(a2)
	bne.s	loc_985A
	move.w	$22(a2),d4
	asr.w	#1,d4
	lea	(CollisionSize_Index).l,a3
	add.w	(a3,d4.w),a3
	subq.w	#8,a3
	tst.b	$16(a2)
	bne.s	loc_98B0

loc_9882:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_985A
	add.w	$1A(a2),d4
	cmp.w	d1,d4
	bgt.s	loc_9882
	add.w	2(a3),d4
	cmp.w	d0,d4
	blt.s	loc_9882
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	move.w	d5,(sp)
	cmp.w	d3,d5
	bgt.s	loc_9882
	add.w	6(a3),d5
	cmp.w	d2,d5
	blt.s	loc_9882
	bra.s	loc_98DE
; ---------------------------------------------------------------------------

loc_98B0:
	addq.w	#8,a3
	move.w	(a3),d4
	beq.s	loc_985A
	neg.w	d4
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	blt.s	loc_98B0
	sub.w	2(a3),d4
	cmp.w	d1,d4
	bgt.s	loc_98B0
	move.w	4(a3),d5
	add.w	$1E(a2),d5
	move.w	d5,(sp)
	cmp.w	d3,d5
	bgt.s	loc_98B0
	add.w	6(a3),d5
	cmp.w	d2,d5
	blt.s	loc_98B0

loc_98DE:
	moveq	#1,d7
	bra.w	loc_98E6
; ---------------------------------------------------------------------------

loc_98E4:
	moveq	#0,d7

loc_98E6:
	movem.l	(sp)+,a2-a3
	movem.l	(sp)+,d0-d3
	tst.w	d7
	rts
; End of function sub_9832


; =============== S U B	R O U T	I N E =======================================


sub_98F2:
	tst.b	($FFFFFA69).w
	beq.w	loc_9942
	move.l	($FFFFF862).w,a4
	clr.w	$22(a4)
	moveq	#0,d7
	move.b	($FFFFFA69).w,d7
	addq.w	#2,d7
	cmpi.w	#$20,d7
	blt.w	loc_991A
	clr.b	($FFFFFA69).w
	bra.w	loc_9942
; ---------------------------------------------------------------------------

loc_991A:
	cmpi.w	#$11,d7
	bne.w	loc_992A
	not.b	($FFFFFA6A).w
	not.b	$17(a3)

loc_992A:
	move.b	d7,($FFFFFA69).w
	asr.w	#3,d7
	add.w	d7,d7
	move.w	off_993A(pc,d7.w),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------
off_993A:	dc.w LnkTo_unk_AA3AE-Data_Index
	dc.w LnkTo_unk_AA5B4-Data_Index
	dc.w LnkTo_unk_AA5B4-Data_Index
	dc.w LnkTo_unk_AA3AE-Data_Index
; ---------------------------------------------------------------------------

loc_9942:
	move.l	x_vel(a3),d7
	movem.l	a0-a2,-(sp)
	move.w	($FFFFF8F0).w,d6
	subq.b	#1,($FFFFFA0D).w
	bgt.s	loc_9974
	move.l	($FFFFFA0E).w,a0
	lea	unk_96AC(pc),a1
	lea	unk_96D0(pc),a2
	cmp.l	a1,a0
	blt.s	loc_9968
	cmp.l	a2,a0
	blt.s	loc_996A

loc_9968:
	move.l	a1,a0

loc_996A:
	move.b	(a0)+,d6
	move.b	(a0)+,($FFFFFA0D).w
	move.l	a0,($FFFFFA0E).w

loc_9974:
	moveq	#$10,d7
	tst.b	(Ctrl_A_Held).w
	beq.s	loc_997E
	moveq	#$20,d7

loc_997E:
	add.b	d7,($FFFFFA0C).w
	cmpi.w	#6,d6
	bcs.s	loc_998A
	moveq	#0,d6

loc_998A:
	move.w	d6,($FFFFF8F0).w
	add.w	d6,d6
	move.l	($FFFFF862).w,a2
	move.w	off_99FE(pc,d6.w),d7
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	bne.w	loc_99A6
	move.w	#(LnkTo_unk_A94AC-Data_Index),d7

loc_99A6:
	move.w	d7,addroffset_sprite(a3)
	move.l	x_pos(a3),$1A(a2)
	move.l	y_pos(a3),$1E(a2)
	move.l	x_vel(a3),$26(a2)
	move.l	y_vel(a3),$2A(a2)
	move.w	x_direction(a3),$16(a2)
	move.w	#$12C,d7
	move.b	($FFFFFA0C).w,d5
	add.b	d5,d5
	cmpi.b	#$55,d5
	bcs.s	loc_99E6
	move.w	#$130,d7
	cmpi.b	#$AA,d5
	bcs.s	loc_99E6
	move.w	#$134,d7

loc_99E6:
	move.w	d7,$22(a2)
	tst.b	($FFFFFA6A).w
	beq.w	loc_99F8
	subi.w	#$1A,$1E(a2)

loc_99F8:
	movem.l	(sp)+,a0-a2
	rts
; End of function sub_98F2

; ---------------------------------------------------------------------------
off_99FE:	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_A9990-Data_Index
	dc.w LnkTo_unk_A9B96-Data_Index
	dc.w LnkTo_unk_A9D9C-Data_Index
	dc.w LnkTo_unk_A9FA2-Data_Index
	dc.w LnkTo_unk_AA1A8-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_9A0A:

; FUNCTION CHUNK AT 00009AE0 SIZE 0000012A BYTES

	tst.b	(Maniaxe_throwing_axe).w
	beq.w	loc_9A14
	rts
; ---------------------------------------------------------------------------

loc_9A14:
	move.w	(Current_Helmet).w,d3
	cmpi.w	#1,d3
	bne.w	loc_9AE0
; End of function sub_9A0A


; =============== S U B	R O U T	I N E =======================================


sub_9A20:
	tst.b	x_direction(a3)
	bne.s	loc_9A84
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_9A32
	st	x_direction(a3)
	bra.s	loc_9A90
; ---------------------------------------------------------------------------

loc_9A32:
	tst.b	(Ctrl_A_Held).w
	bne.s	loc_9A6E
	cmpi.l	#$20000,d0
	bge.s	loc_9A56
	addi.l	#$2000,d0
	cmpi.l	#$20000,d0
	ble.s	return_9A54
	move.l	#$20000,d0

return_9A54:
	rts
; ---------------------------------------------------------------------------

loc_9A56:
	cmpi.l	#$40000,d0
	bgt.s	loc_9A66
	subi.l	#$2000,d0
	rts
; ---------------------------------------------------------------------------

loc_9A66:
	move.l	#$40000,d0
	rts
; ---------------------------------------------------------------------------

loc_9A6E:
	addi.l	#$4000,d0
	cmpi.l	#$40000,d0
	ble.s	return_9ADE
	move.l	#$40000,d0
	rts
; ---------------------------------------------------------------------------

loc_9A84:
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_9A90
	sf	x_direction(a3)
	bra.s	loc_9A32
; ---------------------------------------------------------------------------

loc_9A90:
	tst.b	(Ctrl_A_Held).w
	bne.s	loc_9ACA
	cmpi.l	#$FFFE0000,d0
	ble.s	loc_9AB2
	subi.l	#$2000,d0
	cmpi.l	#$FFFE0000,d0
	bge.s	return_9ADE
	move.l	#$FFFE0000,d0

loc_9AB2:
	cmpi.l	#$FFFC0000,d0
	blt.s	loc_9AC2
	addi.l	#$2000,d0
	rts
; ---------------------------------------------------------------------------

loc_9AC2:
	move.l	#$FFFC0000,d0
	rts
; ---------------------------------------------------------------------------

loc_9ACA:
	subi.l	#$4000,d0
	cmpi.l	#$FFFC0000,d0
	bge.s	return_9ADE
	move.l	#$FFFC0000,d0

return_9ADE:
	rts
; End of function sub_9A20

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_9A0A

loc_9AE0:
	lea	unk_9C0A(pc),a0
	move.w	($FFFFFA0A).w,d2
	cmpi.w	#2,d2
	bne.s	loc_9AF2
	lea	unk_9C7A(pc),a0

loc_9AF2:
	cmpi.w	#1,d2
	bne.s	loc_9AFC
	lea	unk_9CCE(pc),a0

loc_9AFC:
	cmpi.w	#Micromax,(Current_Helmet).w	; micromax
	bne.s	loc_9B08
	lea	$1C(a0),a0

loc_9B08:
	cmpi.w	#Juggernaut,(Current_Helmet).w	; juggernaut
	bne.s	loc_9B14
	lea	$38(a0),a0

loc_9B14:
	tst.b	x_direction(a3)
	bne.s	loc_9B7E
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_9B26
	st	x_direction(a3)
	bra.s	loc_9B90
; ---------------------------------------------------------------------------

loc_9B26:
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_9BEE

loc_9B2E:
	tst.b	(Ctrl_A_Held).w
	bne.s	loc_9B62
	tst.l	d0
	bmi.s	loc_9B5C
	cmp.l	$10(a0),d0
	ble.s	loc_9B44
	move.l	$10(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9B44:
	cmp.l	(a0),d0
	ble.s	loc_9B4E
	sub.l	8(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9B4E:
	add.l	4(a0),d0
	cmp.l	(a0),d0
	bcs.w	return_9B5A
	move.l	(a0),d0

return_9B5A:
	rts
; ---------------------------------------------------------------------------

loc_9B5C:
	add.l	$C(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9B62:
	tst.l	d0
	bmi.s	loc_9B78
	add.l	$14(a0),d0
	cmp.l	$10(a0),d0
	bcs.w	return_9B76
	move.l	$10(a0),d0

return_9B76:
	rts
; ---------------------------------------------------------------------------

loc_9B78:
	add.l	$18(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9B7E:
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_9B8A
	sf	x_direction(a3)
	bra.s	loc_9B2E
; ---------------------------------------------------------------------------

loc_9B8A:
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_9BEE

loc_9B90:
	tst.b	(Ctrl_A_Held).w
	bne.s	loc_9BCE
	tst.l	d0
	bpl.s	loc_9BC8
	move.l	d0,d1
	neg.l	d1
	cmp.l	$10(a0),d1
	ble.s	loc_9BAC
	move.l	$10(a0),d0
	neg.l	d0
	rts
; ---------------------------------------------------------------------------

loc_9BAC:
	cmp.l	(a0),d1
	ble.s	loc_9BB6
	add.l	8(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9BB6:
	sub.l	4(a0),d0
	move.l	d0,d1
	neg.l	d1
	cmp.l	(a0),d1
	ble.s	return_9BC6
	move.l	(a0),d0
	neg.l	d0

return_9BC6:
	rts
; ---------------------------------------------------------------------------

loc_9BC8:
	sub.l	$18(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9BCE:
	tst.l	d0
	bpl.s	loc_9BE8
	sub.l	$14(a0),d0
	move.l	d0,d1
	neg.l	d1
	cmp.l	$10(a0),d1
	ble.s	return_9BE6
	move.l	$10(a0),d0
	neg.l	d0

return_9BE6:
	rts
; ---------------------------------------------------------------------------

loc_9BE8:
	sub.l	$18(a0),d0
	rts
; ---------------------------------------------------------------------------

loc_9BEE:
	tst.l	d0
	bpl.s	loc_9BFC
	add.l	8(a0),d0
	bpl.w	loc_9C06
	rts
; ---------------------------------------------------------------------------

loc_9BFC:
	sub.l	8(a0),d0
	bmi.w	loc_9C06
	rts
; ---------------------------------------------------------------------------

loc_9C06:
	moveq	#0,d0
	rts
; END OF FUNCTION CHUNK	FOR sub_9A0A
; ---------------------------------------------------------------------------
unk_9C0A:	; The below properties when the kid is walking on normal terrain
	dc.l	$20000	; Max walking speed
	dc.l	 $1000	; Acceleration walking rate
	dc.l	 $2800	; Deceleration walking/running rate
	dc.l	 $2000	; Brake walking-left rate
	dc.l	$38000	; Max running speed
	dc.l	 $1C00	; Acceleration running rate
	dc.l	 $3000	; Brake walking-right/running rate
	dc.l	$10000	; Micromax: Max walking speed
	dc.l	  $800	; Micromax: Acceleration walking rate
	dc.l	 $1400	; Micromax: Deceleration walking/running rate
	dc.l	 $1000	; Micromax: Brake walking-left rate
	dc.l	$20000	; Micromax: Max running speed
	dc.l	 $1000	; Micromax: Acceleration running rate
	dc.l	 $1800	; Micromax: Brake walking-right/running rate
	dc.l	$18000	; Juggernaut: Max walking speed
	dc.l	 $2000	; Juggernaut: Acceleration walking rate
	dc.l	 $5000	; Juggernaut: Deceleration walking/running rate
	dc.l	 $4000	; Juggernaut: Brake walking-left rate
	dc.l	$30000	; Juggernaut: Max running speed
	dc.l	 $3800	; Juggernaut: Acceleration running rate
	dc.l	 $6000	; Juggernaut: Brake walking-right/running rate
	dc.l	$20000
	dc.l	 $4000
	dc.l	 $2800
	dc.l	 $4000
	dc.l	$30000
	dc.l	 $3800
	dc.l	 $6000
unk_9C7A:	; The below properties when the kid is walking on ice
	dc.l	$18000	; Max walking speed
	dc.l	 $2000	; Acceleration walking rate
	dc.l	 $5000	; Deceleration walking/running rate
	dc.l	 $4000	; Brake walking-left rate
	dc.l	$28000	; Max running speed
	dc.l	 $3800	; Acceleration running rate
	dc.l	 $6000	; Brake walking-right/running rate
	dc.l	 $C000	; Micromax: Max walking speed
	dc.l	 $1000	; Micromax: Acceleration walking rate
	dc.l	 $2800	; Micromax: Deceleration walking/running rate
	dc.l	 $2000	; Micromax: Brake walking-left rate
	dc.l	$18000	; Micromax: Max running speed
	dc.l	 $2000	; Micromax: Acceleration running rate
	dc.l	 $3000	; Micromax: Brake walking-right/running rate
	dc.l	$14000	; Juggernaut: Max walking speed
	dc.l	 $4000	; Juggernaut: Acceleration walking rate
	dc.l	 $A000	; Juggernaut: Deceleration walking/running rate
	dc.l	 $8000	; Juggernaut: Brake walking-left rate
	dc.l	$20000	; Juggernaut: Max running speed
	dc.l	 $7000	; Juggernaut: Acceleration running rate
	dc.l	 $C000	; Juggernaut: Brake walking-right/running rate
unk_9CCE:	; The below properties when the kid is walking on rubber blocks
	dc.l	$40000	; Max walking speed
	dc.l	  $200	; Acceleration walking rate
	dc.l	  $100	; Deceleration walking/running rate
	dc.l	  $400	; Brake walking-left rate
	dc.l	$70000	; Max running speed
	dc.l	  $380	; Acceleration running rate
	dc.l	  $680	; Brake walking-right/running rate
	dc.l	$20000	; Micromax: Max walking speed
	dc.l	  $100	; Micromax: Acceleration walking rate
	dc.l	   $80	; Micromax: Deceleration walking/running rate
	dc.l	  $200	; Micromax: Brake walking-left rate
	dc.l	$40000	; Micromax: Max running speed
	dc.l	  $200	; Micromax: Acceleration running rate
	dc.l	  $380	; Micromax: Brake walking-right/running rate
	dc.l	$30000	; Juggernaut: Max walking speed
	dc.l	  $400	; Juggernaut: Acceleration walking rate
	dc.l	  $200	; Juggernaut: Deceleration walking/running rate
	dc.l	  $800	; Juggernaut: Brake walking-left rate
	dc.l	$58000	; Juggernaut: Max running speed
	dc.l	  $700	; Juggernaut: Acceleration running rate
	dc.l	  $D00	; Juggernaut: Brake walking-right/running rate
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_9D22:
	move.l	x_vel(a3),d0
	tst.b	($FFFFFA26).w
	bne.s	loc_9D2E
	neg.l	d0

loc_9D2E:
	move.l	d0,y_vel(a3)
	move.w	#6,($FFFFFA56).w
	bsr.w	sub_71E4
	sf	(Berzerker_charging).w
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_7ACC
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w

loc_9D58:
	cmpi.w	#Eyeclops,(Current_Helmet).w
	beq.w	loc_9E6C
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	beq.w	loc_9E6C
	cmpi.w	#Maniaxe,(Current_Helmet).w
	beq.w	loc_9E6C
	lea	unk_9EB0(pc),a0
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.s	loc_9D86
	lea	unk_9EE4(pc),a0

loc_9D86:
	lea	$14(a0),a1
	tst.b	(Ctrl_A_Held).w
	beq.s	loc_9D94
	lea	$10(a1),a1

loc_9D94:
	move.l	x_vel(a3),d0
	move.b	(Ctrl_Right_Held).w,d1
	move.b	(Ctrl_Left_Held).w,d2
	tst.b	($FFFFFA26).w
	beq.s	loc_9DAA
	neg.l	d0
	exg	d1,d2

loc_9DAA:
	tst.b	d1
	bne.s	loc_9DC0
	tst.b	d2
	bne.s	loc_9DF2
	tst.b	(Ctrl_Up_Held).w
	bne.s	loc_9DC0
	tst.b	(Ctrl_Down_Held).w
	bne.s	loc_9DF2
	bra.s	loc_9E2E
; ---------------------------------------------------------------------------

loc_9DC0:
	move.b	($FFFFFA26).w,x_direction(a3)
	tst.l	d0
	bpl.s	loc_9DD4
	add.l	4(a1),d0
	add.l	4(a1),d0
	bra.s	loc_9DEE
; ---------------------------------------------------------------------------

loc_9DD4:
	cmp.l	(a1),d0
	bgt.s	loc_9DE4
	add.l	4(a1),d0
	cmp.l	(a1),d0
	ble.s	loc_9DEE
	move.l	(a1),d0
	bra.s	loc_9DEE
; ---------------------------------------------------------------------------

loc_9DE4:
	sub.l	8(a0),d0
	cmp.l	(a0),d0
	ble.s	loc_9DEE
	move.l	(a0),d0

loc_9DEE:
	bra.w	loc_9E5C
; ---------------------------------------------------------------------------

loc_9DF2:
	tst.b	($FFFFFA26).w
	seq	x_direction(a3)
	tst.l	d0
	bmi.s	loc_9E08
	sub.l	$C(a1),d0
	sub.l	$C(a1),d0
	bra.s	loc_9E5C
; ---------------------------------------------------------------------------

loc_9E08:
	cmp.l	8(a1),d0
	blt.s	loc_9E1E
	sub.l	$C(a1),d0
	cmp.l	8(a1),d0
	bge.s	loc_9E5C
	move.l	8(a1),d0
	bra.s	loc_9E5C
; ---------------------------------------------------------------------------

loc_9E1E:
	add.l	8(a0),d0
	cmp.l	4(a0),d0
	bge.s	loc_9E5C
	move.l	4(a0),d0
	bra.s	loc_9E5C
; ---------------------------------------------------------------------------

loc_9E2E:
	move.l	$10(a0),d1
	cmp.l	d1,d0
	bge.s	loc_9E42
	add.l	$C(a0),d0
	cmp.l	d1,d0
	ble.s	loc_9E4C
	move.l	d1,d0
	bra.s	loc_9E4C
; ---------------------------------------------------------------------------

loc_9E42:
	sub.l	$C(a0),d0
	cmp.l	d1,d0
	bge.s	loc_9E4C
	move.l	d1,d0

loc_9E4C:
	move.b	($FFFFFA26).w,d1
	tst.l	d0
	bpl.s	loc_9E58
	eori.b	#$FF,d1

loc_9E58:
	move.b	d1,x_direction(a3)

loc_9E5C:
	tst.b	($FFFFFA26).w
	beq.s	loc_9E64
	neg.l	d0

loc_9E64:
	move.l	d0,x_vel(a3)
	bra.w	loc_9F18
; ---------------------------------------------------------------------------

loc_9E6C:
	move.l	x_vel(a3),d7
	tst.b	($FFFFFA26).w
	beq.w	loc_9E94
	addi.l	#$1000,d7
	bpl.w	loc_9E88
	move.l	#$1000,d7

loc_9E88:
	sf	x_direction(a3)
	move.l	d7,x_vel(a3)
	bra.w	loc_9F18
; ---------------------------------------------------------------------------

loc_9E94:
	subi.l	#$1000,d7
	bmi.w	loc_9EA4
	move.l	#$FFFFF000,d7

loc_9EA4:
	st	x_direction(a3)
	move.l	d7,x_vel(a3)
	bra.w	loc_9F18
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
unk_9EB0:	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $40 ; @
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FE ; �
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $FF
	dc.b $FD ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $40 ; @
	dc.b   0
unk_9EE4:	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FE ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $40 ; @
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $C0 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $40 ; @
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $40 ; @
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $FF
	dc.b $FE ; �
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b   0
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_9F18:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bne.w	loc_B580
	move.l	#$40000,d1
	move.l	x_vel(a3),d0
	cmp.l	d1,d0
	ble.s	loc_9F32
	move.l	d1,d0

loc_9F32:
	neg.l	d1
	cmp.l	d1,d0
	bge.s	loc_9F3A
	move.l	d1,d0

loc_9F3A:
	move.l	d0,x_vel(a3)
	add.l	x_pos(a3),d0
	move.l	d0,x_pos(a3)
	bsr.w	sub_A254
	tst.b	($FFFFFA26).w
	bne.w	loc_A04C
	move.w	y_pos(a3),d0
	lsr.w	#4,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	lsr.w	#4,d0
	add.w	d0,d0
	add.w	d0,a0
	move.w	(a0),d0
	andi.w	#$7000,d0
	cmpi.w	#$4000,d0
	beq.s	loc_9FE4
	cmpi.w	#$6000,d0
	beq.w	loc_9FBC
	tst.l	x_vel(a3)
	bpl.w	loc_9FBC
	clr.w	$1C(a3)
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$F,d7
	sub.w	($FFFFFA78).w,d7
	move.w	d7,x_pos(a3)
	move.l	y_vel(a3),d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	sf	($FFFFFA72).w
	st	has_level_collision(a3)
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_9FBC:
	move.w	y_pos(a3),d0
	andi.w	#$FFF0,d0
	tst.w	x_vel(a3)
	bmi.s	loc_9FCE
	addi.w	#$10,d0

loc_9FCE:
	subq.w	#1,d0
	move.w	d0,y_pos(a3)
	move.l	x_vel(a3),d0
	clr.l	y_vel(a3)
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_9FE4:
	tst.w	x_vel(a3)
	bmi.s	loc_A048
	move.w	x_pos(a3),d0
	andi.w	#$F,d0
	moveq	#8,d1
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.s	loc_9FFE
	moveq	#$A,d1

loc_9FFE:
	cmp.w	d1,d0
	ble.s	loc_A048
	move.w	y_pos(a3),d0
	subq.w	#1,d0
	lsr.w	#4,d0
	subq.w	#1,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	lsr.w	#4,d0
	addq.w	#1,d0
	cmp.w	(Level_width_blocks).w,d0
	bge.s	loc_A036
	add.w	d0,d0
	add.w	d0,a0
	move.w	(a0),d0
	andi.w	#$7000,d0
	cmpi.w	#$6000,d0
	bne.s	loc_A048

loc_A036:
	move.w	x_pos(a3),d0
	andi.w	#$FFF0,d0
	or.w	d1,d0
	move.w	d0,x_pos(a3)
	bsr.w	sub_A254

loc_A048:
	bra.w	loc_A13A
; ---------------------------------------------------------------------------

loc_A04C:
	move.w	y_pos(a3),d0
	lsr.w	#4,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	lsr.w	#4,d0
	add.w	d0,d0
	add.w	d0,a0
	move.w	(a0),d0
	andi.w	#$7000,d0
	cmpi.w	#$5000,d0
	beq.s	loc_A0DC
	cmpi.w	#$6000,d0
	beq.w	loc_A0B4
	tst.l	x_vel(a3)
	bmi.w	loc_A0B4
	clr.w	$1C(a3)
	move.w	x_pos(a3),d7
	andi.w	#$FFF0,d7
	add.w	($FFFFFA78).w,d7
	move.w	d7,x_pos(a3)
	move.l	y_vel(a3),d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	st	($FFFFFA72).w
	st	has_level_collision(a3)
	subq.w	#4,sp
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A0B4:
	move.w	y_pos(a3),d0
	andi.w	#$FFF0,d0
	tst.w	x_vel(a3)
	bpl.s	loc_A0C6
	addi.w	#$10,d0

loc_A0C6:
	subq.w	#1,d0
	move.w	d0,y_pos(a3)
	move.l	x_vel(a3),d0
	clr.l	y_vel(a3)
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_A0DC:
	tst.w	x_vel(a3)
	bpl.s	loc_A13A
	move.w	x_pos(a3),d0
	andi.w	#$F,d0
	moveq	#8,d1
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.s	loc_A0F6
	moveq	#6,d1

loc_A0F6:
	cmp.w	d1,d0
	bge.s	loc_A13A
	move.w	y_pos(a3),d0
	lsr.w	#4,d0
	subq.w	#1,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	lsr.w	#4,d0
	subq.w	#1,d0
	bmi.s	loc_A128
	add.w	d0,d0
	add.w	d0,a0
	move.w	(a0),d0
	andi.w	#$7000,d0
	cmpi.w	#$6000,d0
	bne.s	loc_A13A

loc_A128:
	move.w	x_pos(a3),d0
	andi.w	#$FFF0,d0
	or.w	d1,d0
	move.w	d0,x_pos(a3)
	bsr.w	sub_A254

loc_A13A:
	move.w	(Current_Helmet).w,d7
	asl.w	#2,d7
	move.l	off_A190(pc,d7.w),a0
	move.l	x_vel(a3),d0
	move.w	($FFFFF8F0).w,d2
	move.b	x_direction(a3),d1
	tst.b	($FFFFFA26).w
	beq.s	loc_A15C
	eori.b	#$FF,d1
	neg.l	d0

loc_A15C:
	tst.b	d1
	bne.s	loc_A16C
	moveq	#$40,d0
	tst.b	(Ctrl_A_Held).w
	beq.s	loc_A172
	moveq	#$50,d0
	bra.s	loc_A172
; ---------------------------------------------------------------------------

loc_A16C:
	lea	$C(a0),a0
	moveq	#$40,d0

loc_A172:
	add.w	d0,d2
	cmpi.w	#$600,d2
	bcs.s	loc_A17E
	subi.w	#$600,d2

loc_A17E:
	move.w	d2,($FFFFF8F0).w
	lsr.w	#8,d2
	add.w	d2,d2
	move.w	(a0,d2.w),addroffset_sprite(a3)
	bra.w	loc_9D22
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
off_A190:	dc.l off_A1B8
	dc.l off_A1B8
	dc.l off_A218
	dc.l off_A230
	dc.l off_A224
	dc.l off_A1B8
	dc.l off_A200
	dc.l off_A1E8
	dc.l off_A23C
	dc.l off_A1D0
off_A1B8:	dc.w LnkTo_unk_A41FE-Data_Index
	dc.w LnkTo_unk_A43E4-Data_Index
	dc.w LnkTo_unk_A44EA-Data_Index
	dc.w LnkTo_unk_A4630-Data_Index
	dc.w LnkTo_unk_A4816-Data_Index
	dc.w LnkTo_unk_A491C-Data_Index
	dc.w LnkTo_unk_A23CC-Data_Index
	dc.w LnkTo_unk_A2552-Data_Index
	dc.w LnkTo_unk_A26D8-Data_Index
	dc.w LnkTo_unk_A285E-Data_Index
	dc.w LnkTo_unk_A29E4-Data_Index
	dc.w LnkTo_unk_A2B6A-Data_Index
off_A1D0:	dc.w LnkTo_unk_AC9E2-Data_Index
	dc.w LnkTo_unk_ACAA8-Data_Index
	dc.w LnkTo_unk_ACB6E-Data_Index
	dc.w LnkTo_unk_ACC34-Data_Index
	dc.w LnkTo_unk_ACCFA-Data_Index
	dc.w LnkTo_unk_ACDC0-Data_Index
	dc.w LnkTo_unk_AB5C4-Data_Index
	dc.w LnkTo_unk_AB68A-Data_Index
	dc.w LnkTo_unk_AB750-Data_Index
	dc.w LnkTo_unk_AB816-Data_Index
	dc.w LnkTo_unk_AB8DC-Data_Index
	dc.w LnkTo_unk_AB9A2-Data_Index
off_A1E8:	dc.w LnkTo_unk_B1126-Data_Index
	dc.w LnkTo_unk_B130C-Data_Index
	dc.w LnkTo_unk_B14F2-Data_Index
	dc.w LnkTo_unk_B1778-Data_Index
	dc.w LnkTo_unk_B19FE-Data_Index
	dc.w LnkTo_unk_B1C84-Data_Index
	dc.w LnkTo_unk_AF172-Data_Index
	dc.w LnkTo_unk_AF3F8-Data_Index
	dc.w LnkTo_unk_AF67E-Data_Index
	dc.w LnkTo_unk_AF904-Data_Index
	dc.w LnkTo_unk_AFAEA-Data_Index
	dc.w LnkTo_unk_AFCD0-Data_Index
off_A200:	dc.w LnkTo_unk_C663A-Data_Index
	dc.w LnkTo_unk_C68C0-Data_Index
	dc.w LnkTo_unk_C6B46-Data_Index
	dc.w LnkTo_unk_C6DCC-Data_Index
	dc.w LnkTo_unk_C7052-Data_Index
	dc.w LnkTo_unk_C72D8-Data_Index
	dc.w LnkTo_unk_C5716-Data_Index
	dc.w LnkTo_unk_C599C-Data_Index
	dc.w LnkTo_unk_C5C22-Data_Index
	dc.w LnkTo_unk_C5EA8-Data_Index
	dc.w LnkTo_unk_C612E-Data_Index
	dc.w LnkTo_unk_C63B4-Data_Index
off_A218:	dc.w LnkTo_unk_BD1F0-Data_Index
	dc.w LnkTo_unk_BD3F6-Data_Index
	dc.w LnkTo_unk_BD5FC-Data_Index
	dc.w LnkTo_unk_BD882-Data_Index
	dc.w LnkTo_unk_BDA88-Data_Index
	dc.w LnkTo_unk_BDC8E-Data_Index
off_A224:	dc.w LnkTo_unk_BC68C-Data_Index
	dc.w LnkTo_unk_BC872-Data_Index
	dc.w LnkTo_unk_BCA58-Data_Index
	dc.w LnkTo_unk_BCC3E-Data_Index
	dc.w LnkTo_unk_BCE24-Data_Index
	dc.w LnkTo_unk_BD00A-Data_Index
off_A230:	dc.w LnkTo_unk_BA0CE-Data_Index
	dc.w LnkTo_unk_BA354-Data_Index
	dc.w LnkTo_unk_BA354-Data_Index
	dc.w LnkTo_unk_BA0CE-Data_Index
	dc.w LnkTo_unk_BA354-Data_Index
	dc.w LnkTo_unk_BA354-Data_Index
off_A23C:	dc.w LnkTo_unk_B6ECA-Data_Index
	dc.w LnkTo_unk_B7150-Data_Index
	dc.w LnkTo_unk_B7150-Data_Index
	dc.w LnkTo_unk_B6ECA-Data_Index
	dc.w LnkTo_unk_B7150-Data_Index
	dc.w LnkTo_unk_B7150-Data_Index
	dc.w LnkTo_unk_A8AFA-Data_Index
	dc.w LnkTo_unk_A8F80-Data_Index
	dc.w LnkTo_unk_A8F80-Data_Index
	dc.w LnkTo_unk_A8AFA-Data_Index
	dc.w LnkTo_unk_A8F80-Data_Index
	dc.w LnkTo_unk_A8F80-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_A254:
	tst.b	($FFFFFA26).w
	bne.s	loc_A268
	move.w	($FFFFFA24).w,d0
	sub.w	x_pos(a3),d0
	move.w	d0,y_pos(a3)
	rts
; ---------------------------------------------------------------------------

loc_A268:
	move.w	($FFFFFA24).w,d0
	add.w	x_pos(a3),d0
	move.w	d0,y_pos(a3)
	rts
; End of function sub_A254

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_A276:
	st	($FFFFFA62).w
	moveq	#0,d3
	move.w	#0,(Cyclone_YAcceleration).w
	move.l	#$FFFFC000,y_vel(a3)

loc_A28A:
	move.w	#MoveID_Wall_Climbing,(Character_Movement).w
	clr.w	(Addr_PlatformStandingOn).w
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	(Addr_PlatformStandingOn).w,d7
	bne.w	loc_A9AA
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	bsr.w	sub_7ACC
	bne.w	loc_A6F8
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bne.w	loc_A426
	tst.b	x_direction(a3)
	beq.w	loc_A2E2
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_A2F6
	sf	x_direction(a3)
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A2E2:
	tst.b	(Ctrl_Left_Held).w
	beq.w	loc_A2F6
	st	x_direction(a3)
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A2F6:
	bsr.w	Get_RandomNumber_wordC
	move.w	($FFFFFA78).w,d7
	addq.w	#1,d7
	tst.b	x_direction(a3)
	beq.w	loc_A30A
	neg.w	d7

loc_A30A:
	moveq	#-$18,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_A328
	move.l	#$FFFC0000,y_vel(a3)
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A328:
	bsr.w	sub_902A
	bne.w	loc_A338

loc_A330:
	bsr.w	sub_A3BC
	bra.w	loc_A28A
; ---------------------------------------------------------------------------

loc_A338:
	cmpi.w	#2,d7
	bge.s	loc_A330
	bsr.w	sub_78E8
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bra.w	loc_75D4
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


Get_RandomNumber_wordC:
	moveq	#0,d6
	move.w	(Cyclone_YAcceleration).w,d7
	addi.w	#$80,d7
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_A382
	move.l	d0,-(sp)
	moveq	#sfx_Iron_Knight_wall_climbing,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	moveq	#1,d6
	subi.w	#$1800,d7
	cmpi.w	#$F800,d7
	bgt.w	loc_A38E
	move.w	#$F800,d7
	bra.w	loc_A38E
; ---------------------------------------------------------------------------

loc_A382:
	cmpi.w	#$1800,d7
	ble.w	loc_A38E
	move.w	#$1800,d7

loc_A38E:
	move.w	d7,(Cyclone_YAcceleration).w
	ext.l	d7
	add.l	y_vel(a3),d7
	cmpi.l	#$FFFE8000,d7
	bgt.s	loc_A3A6
	move.l	#$FFFE8000,d7

loc_A3A6:
	cmpi.l	#$40000,d7
	blt.s	loc_A3B4
	move.l	#$40000,d7

loc_A3B4:
	move.l	d7,y_vel(a3)
	tst.w	d6
	rts
; End of function Get_RandomNumber_wordC


; =============== S U B	R O U T	I N E =======================================


sub_A3BC:
	move.w	d3,d7
	move.l	y_vel(a3),d6
	asl.l	#3,d6
	swap	d6
	add.w	d6,d7
	bmi.w	loc_A3DA
	cmpi.w	#$BF,d7
	blt.w	loc_A3DE
	moveq	#0,d7
	bra.w	loc_A3DE
; ---------------------------------------------------------------------------

loc_A3DA:
	move.w	#$BF,d7

loc_A3DE:
	move.w	d7,d3
	asr.w	#2,d7
	move.b	unk_A3F0(pc,d7.w),d7
	ext.w	d7
	move.w	off_A420(pc,d7.w),addroffset_sprite(a3)
	rts
; End of function sub_A3BC

; ---------------------------------------------------------------------------
unk_A3F0:	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
off_A420:	dc.w LnkTo_unk_C1B92-Data_Index
	dc.w LnkTo_unk_C1E18-Data_Index
	dc.w LnkTo_unk_C209E-Data_Index
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_A426:
	sf	(Cyclone_flying).w
	bsr.w	sub_A432
	bra.w	loc_A75A
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_A432:
	move.w	#$2000,(Cyclone_YAcceleration).w
	move.w	(Current_Helmet).w,d0
	add.w	d0,d0
	move.w	unk_A49E(pc,d0.w),d0
	move.l	x_vel(a3),d1
	bpl.s	loc_A44A
	neg.l	d1

loc_A44A:
	lsl.l	#4,d1
	swap	d1
	addi.w	#$100,d1
	mulu.w	d1,d0
	lsl.l	#4,d0
	neg.l	d0
	tst.b	(KidGrabbedByHand).w
	beq.w	loc_A466
	addi.l	#$20000,d0

loc_A466:
	move.l	d0,y_vel(a3)
	move.l	d0,($FFFFFAAA).w
	tst.l	y_pos(a3)
	bpl.s	loc_A480
	moveq	#0,d0
	move.w	(Level_height_blocks).w,d0
	swap	d0
	move.l	d0,y_pos(a3)

loc_A480:
	move.l	x_vel(a3),d0
	asr.l	#1,d0
	move.l	d0,d1
	asr.l	#1,d1
	add.l	d1,d0
	move.l	d0,x_vel(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Jump,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; End of function sub_A432

; ---------------------------------------------------------------------------
; Maximum jump height
unk_A49E:
	dc.w $42	; kid
	dc.w $42	; skycutter
	dc.w $42	; cyclone
	dc.w $4A	; red stealth
	dc.w $42	; eyeclops
	dc.w $42	; juggernaut
	dc.w $42	; iron knight
	dc.w $42	; berzerker
	dc.w $42	; maniaxe
	dc.w $42	; micromax
; Horizontal acceleration when jumping (due to pressing left/right)
unk_A4B2:
	dc.w $2B00	; kid
	dc.w $3400	; skycutter
	dc.w $2B00	; cyclone
	dc.w $4000	; red stealth
	dc.w $2B00	; eyeclops
	dc.w $2B00	; juggernaut
	dc.w $2B00	; iron knight
	dc.w $2B00	; berzerker
	dc.w $2B00	; maniaxe
	dc.w $2B00	; micromax
; Maximum horizontal jump speed
unk_A4C6:
	dc.l $2A000	; kid
	dc.l $32000	; skycutter
	dc.l $2A000	; cyclone
	dc.l $2A000	; red stealth
	dc.l $2A000	; eyeclops
	dc.l $2A000	; juggernaut
	dc.l $2A000	; iron knight
	dc.l $2A000	; berzerker
	dc.l $2A000	; maniaxe
	dc.l $2A000	; micromax
; =============== S U B	R O U T	I N E =======================================


sub_A4EE:
	st	has_level_collision(a3)
	move.l	x_pos(a3),d5
	move.l	y_pos(a3),d6
	move.l	d5,d7
	add.l	x_vel(a3),d7
	move.l	d7,x_pos(a3)
	move.l	d6,d7
	add.l	y_vel(a3),d7
	move.l	d7,y_pos(a3)
	move.l	a2,-(sp)
	lea	(Addr_FirstGfxObjectSlot+2).w,a2
	jsr	(j_GfxObjects_Collision).w
	move.l	(sp)+,a2
	move.w	collision_type(a3),d7
	beq.w	loc_A532
	cmpi.w	#$14,d7
	beq.w	loc_A53C
	cmpi.w	#$18,d7
	beq.w	loc_A594

loc_A532:
	move.l	d5,x_pos(a3)
	move.l	d6,y_pos(a3)
	rts
; ---------------------------------------------------------------------------

loc_A53C:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_A556
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.w	loc_A556
	addq.w	#4,sp
	bra.w	loc_B9A2
; ---------------------------------------------------------------------------

loc_A556:
	clr.w	collision_type(a3)
	move.l	#$FFFE0000,d7
	move.l	d7,x_vel(a3)
	move.l	d7,y_vel(a3)
	move.w	($FFFFFB6C).w,d3
	jsr	(j_sub_FACE).l
	asl.w	#4,d1
	asl.w	#4,d2
	add.w	d2,d1
	addi.w	#$F,d1
	move.w	x_pos(a3),d7
	add.w	($FFFFFA78).w,d7
	sub.w	d7,d1
	move.w	d1,y_pos(a3)
	addq.w	#4,sp
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A594:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_A5AE
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.w	loc_A5AE
	addq.w	#4,sp
	bra.w	loc_BA5A
; ---------------------------------------------------------------------------

loc_A5AE:
	clr.w	collision_type(a3)
	move.l	#$FFFE0000,d7
	move.l	d7,y_vel(a3)
	neg.l	d7
	move.l	d7,x_vel(a3)
	move.w	($FFFFFB6C).w,d3
	jsr	(j_sub_FACE).l
	asl.w	#4,d1
	asl.w	#4,d2
	sub.w	d2,d1
	neg.w	d1
	sub.w	($FFFFFA78).w,d1
	add.w	x_pos(a3),d1
	move.w	d1,y_pos(a3)
	addq.w	#4,sp
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A5EA:
	move.l	#stru_8B6A,d7
	jsr	(j_Init_Animation).w
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	move.w	d7,a4
	clr.l	($FFFFFA98).w
	move.b	($FFFFFAA3).w,($FFFFFA72).w

loc_A606:
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	(Addr_PlatformStandingOn).w,d7
	bne.w	loc_A9AA
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	move.w	($FFFFFA96).w,a4
	move.l	$A(a4),x_vel(a3)
	move.l	($FFFFFA98).w,d7
	addi.l	#$800,d7
	move.l	d7,($FFFFFA98).w
	add.l	$E(a4),d7
	move.l	d7,y_vel(a3)
	bsr.w	sub_902A
	beq.w	loc_A656
	clr.w	($FFFFFA96).w
	bra.w	loc_A8F6
; ---------------------------------------------------------------------------

loc_A656:
	bsr.w	sub_8F26
	beq.w	loc_A666
	clr.w	($FFFFFA96).w
	bra.w	loc_A8DE
; ---------------------------------------------------------------------------

loc_A666:
	move.w	($FFFFFA96).w,a4
	move.w	6(a4),d7
	move.w	y_pos(a3),d6
	cmp.w	d7,d6
	blt.w	loc_A6F8
	subi.w	#$F,d6
	add.w	$1C(a4),d7
	cmp.w	d7,d6
	bgt.w	loc_A6F8
	tst.b	($FFFFFA72).w
	bne.w	loc_A69E
	tst.b	(Ctrl_Left_Held).w
	beq.w	loc_A6AE
	st	x_direction(a3)
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A69E:
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_A6AE
	sf	x_direction(a3)
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A6AE:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	beq.w	loc_A6F4
	move.l	#$FFFC0000,y_vel(a3)
	move.l	#$FFFE0000,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_A6D0
	neg.l	d7

loc_A6D0:
	move.l	d7,x_vel(a3)
	sf	($FFFFFA66).w
	st	($FFFFFA67).w
	move.l	#stru_8B74,d7
	jsr	(j_Init_Animation).w
	move.b	($FFFFFA72).w,d7
	not.b	d7
	move.b	d7,x_direction(a3)
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A6F4:
	bra.w	loc_A606
; ---------------------------------------------------------------------------

loc_A6F8:
	sf	($FFFFFA66).w
	move.w	#MoveID_Jump,(Character_Movement).w
	clr.w	(Addr_PlatformStandingOn).w
	clr.w	($FFFFFA96).w
	move.w	#$5A,(Telepad_timer).w
	bsr.w	sub_71E4
	sf	(Berzerker_charging).w
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	(Addr_PlatformStandingOn).w,d7
	bne.w	loc_A9AA
	move.w	($FFFFFA96).w,d7
	beq.w	loc_A73A
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_A5EA
	clr.w	($FFFFFA96).w

loc_A73A:
	bsr.w	sub_7ACC
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w

loc_A74E:
	bsr.w	sub_B084
	bsr.w	sub_B168
	bsr.w	sub_A4EE

loc_A75A:
	bsr.w	sub_902A
	bne.w	loc_A8F6

loc_A762:
	bsr.w	sub_8F26
	bne.w	loc_A8DE

loc_A76A:
	bsr.w	sub_7428
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_A7B4
	move.b	(Ctrl_Held).w,d0
	andi.b	#$C0,d0
	cmpi.b	#$C0,d0
	bne.s	loc_A7B4
	tst.w	($FFFFFAB8).w
	bne.s	loc_A7B4
	cmpi.w	#2,(Number_Diamonds).w
	blt.s	loc_A7B4
	move.w	#$8001,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w
	move.l	#stru_8B36,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Eyeclops_hard_lightbeam,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_A7B4:
	move.w	(Current_Helmet).w,d7
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	beq.w	loc_A7F8
	tst.b	($FFFFFA6A).w
	beq.w	loc_A7F8
	moveq	#-$21,d7
	move.l	d7,d6
	add.w	y_pos(a3),d6
	bmi.w	loc_A7DE
	bsr.w	sub_B43A
	beq.w	loc_A7F8

loc_A7DE:
	move.l	x_vel(a3),d6
	bpl.w	loc_A7E8
	neg.l	d6

loc_A7E8:
	asr.l	#1,d6
	addi.l	#$30000,d6
	move.l	d6,y_vel(a3)
	bra.w	loc_A8D6
; ---------------------------------------------------------------------------

loc_A7F8:
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_A8D6
	cmpi.w	#8,d7
	bne.w	loc_A830
	tst.b	(Maniaxe_throwing_axe).w
	bne.w	loc_A8D6
	st	(Maniaxe_throwing_axe).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_89D2,4(a0)
	move.l	#stru_8B60,d7
	jsr	(j_Init_Animation).w

loc_A830:
	cmpi.w	#2,d7
	bne.w	loc_A840
	st	(Cyclone_flying).w
	bra.w	loc_A8D6
; ---------------------------------------------------------------------------

loc_A840:
	cmpi.w	#1,d7
	bne.w	loc_A87A
	tst.b	($FFFFFA6A).w
	beq.w	loc_A864
	moveq	#-$21,d7
	move.l	d7,d6
	add.w	y_pos(a3),d6
	bmi.w	loc_A8D6
	bsr.w	sub_B43A
	bne.w	loc_A8D6

loc_A864:
	move.b	#1,($FFFFFA69).w
	move.l	d0,-(sp)
	moveq	#sfx_Skycutter_flipboard,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bra.w	loc_A8D6
; ---------------------------------------------------------------------------

loc_A87A:
	cmpi.w	#Juggernaut,(Current_Helmet).w
	bne.w	loc_A8A6
	tst.b	is_animated(a3)
	bne.w	loc_A8D6
	cmpi.w	#8,($FFFFFB70).w
	bge.w	loc_A8D6
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_86FA,4(a0)

loc_A8A6:
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.s	loc_A8D6
	tst.w	($FFFFFAB8).w
	bne.s	loc_A8D6
	move.w	#1,($FFFFFAB8).w
	move.b	x_direction(a3),($FFFFFABE).w
	move.l	#stru_8B36,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_Eyeclops_normal_lightbeam,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_A8D6:
	bsr.w	sub_B270
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_A8DE:
	bmi.w	loc_A76A
	sf	($FFFFFA72).w
	cmpi.w	#2,d7
	blt.w	loc_A9E4
	st	($FFFFFA72).w
	bra.w	loc_A9E4
; ---------------------------------------------------------------------------

loc_A8F6:
	bpl.w	loc_A912
	sf	(Maniaxe_throwing_axe).w
	sf	is_animated(a3)
	sf	($FFFFFA66).w
	sf	($FFFFFA67).w
	sf	is_animated(a3)
	bra.w	loc_A762
; ---------------------------------------------------------------------------

loc_A912:
	clr.b	($FFFFFA69).w
	cmpi.w	#2,d7
	bge.w	loc_A92E
	tst.b	($FFFFFA6A).w
	beq.w	loc_A94E
	bsr.w	sub_BB54
	bra.w	loc_A762
; ---------------------------------------------------------------------------

loc_A92E:
	bne.w	loc_A942
	tst.b	($FFFFFA6A).w
	bne.w	loc_A762
	bsr.w	sub_BB54
	bra.w	loc_A762
; ---------------------------------------------------------------------------

loc_A942:
	move.w	#4,collision_type(a3)
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------
	bra.s	loc_A942
; ---------------------------------------------------------------------------

loc_A94E:
	bsr.w	sub_B000
	bne.w	loc_A762
	bsr.w	sub_AF7A
	bne.w	loc_A762
	bsr.w	sub_DB22
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	cmpi.w	#Iron_Knight,(Current_Helmet).w
	bne.w	loc_A984
	move.l	d0,-(sp)
	moveq	#sfx_Jump_on_enemy,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_A984:
	cmpi.w	#Skycutter,(Current_Helmet).w
	beq.w	loc_A99E
	tst.l	x_vel(a3)
	bne.w	loc_A99E
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_A99E:
	move.l	x_vel(a3),d0
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_A9AA:
	tst.b	($FFFFFA6A).w
	beq.w	loc_A9BE
	clr.l	y_vel(a3)
	clr.w	(Addr_PlatformStandingOn).w
	bra.w	loc_A74E
; ---------------------------------------------------------------------------

loc_A9BE:
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	bsr.w	sub_DB22
	move.w	d7,a4
	move.l	x_vel(a3),d7
	sub.l	$A(a4),d7
	move.l	d7,($FFFFFA98).w
	clr.w	($FFFFFA0A).w
	bra.w	loc_8D72
; ---------------------------------------------------------------------------

loc_A9E4:
	bsr.w	sub_B270
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.w	loc_AA22
	move.l	d0,-(sp)
	moveq	#sfx_Micromax_sticking,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	tst.l	y_vel(a3)
	bmi.w	loc_AA22
	clr.l	y_vel(a3)
	st	($FFFFFA66).w
	move.l	#stru_8B6A,d7
	jsr	(j_Init_Animation).w
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bra.w	*+4

loc_AA22:
	move.w	#MoveID_Jump,(Character_Movement).w
	clr.w	(Addr_PlatformStandingOn).w
	bsr.w	sub_71E4
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	(Addr_PlatformStandingOn).w,d7
	bne.w	loc_A9AA
	bsr.w	sub_7ACC
	bne.w	loc_A74E
	bsr.w	Character_CheckCollision
	move.w	x_pos(a3),($FFFFFA2C).w
	move.w	y_pos(a3),($FFFFFA2E).w
	bsr.w	sub_B168
	bsr.w	sub_A4EE
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.w	loc_AA8E
	tst.b	($FFFFFA66).w
	bne.w	loc_AA8E
	tst.l	y_vel(a3)
	bmi.w	loc_AA8E
	clr.l	y_vel(a3)
	st	($FFFFFA66).w
	move.l	#stru_8B6A,d7
	jsr	(j_Init_Animation).w
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump

loc_AA8E:
	move.w	y_pos(a3),($FFFFFB5C).w
	bsr.w	sub_902A
	bne.w	loc_AD68

loc_AA9C:
	tst.b	($FFFFFA72).w
	bne.w	loc_AAB8
	tst.b	(Ctrl_Left_Held).w
	bne.w	loc_AD34
	tst.b	(Ctrl_Right_Held).w
	beq.w	kid_flip
	bra.w	loc_AAC8
; ---------------------------------------------------------------------------

loc_AAB8:
	tst.b	(Ctrl_Right_Held).w
	bne.w	loc_AD34
	tst.b	(Ctrl_Left_Held).w
	beq.w	kid_flip

loc_AAC8:
	tst.l	y_vel(a3)
	bmi.w	loc_AB22
	bsr.w	sub_ADB8
	bne.w	kid_flip
	move.w	($FFFFFB5C).w,d7
	andi.w	#$FFF0,d7
	moveq	#$F,d6
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_AAF8
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_AAF8
	moveq	#$1F,d6

loc_AAF8:
	add.w	d6,d7
	move.w	d7,y_pos(a3)
	moveq	#1,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_AB0A
	moveq	#-1,d7

loc_AB0A:
	add.w	d7,x_pos(a3)
	clr.l	y_vel(a3)
	tst.b	($FFFFFA6A).w
	bne.w	loc_A6F8
	bsr.w	sub_DB22
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_AB22:
	bsr.w	sub_AE6E
	bne.w	kid_flip
	move.w	y_pos(a3),d7
	andi.w	#$FFF0,d7
	addi.w	#$F,d7
	move.w	d7,y_pos(a3)
	clr.w	$20(a3)
	moveq	#1,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_AB4A
	moveq	#-1,d7

loc_AB4A:
	add.w	d7,x_pos(a3)
	clr.l	y_vel(a3)
	tst.b	($FFFFFA6A).w
	bne.w	loc_A6F8
	bsr.w	sub_DB22
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

kid_flip:
	bsr.w	sub_7428
	bsr.w	sub_AF10
	beq.w	loc_AD34
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	beq.w	loc_ACB0
	cmpi.w	#The_Kid,(Current_Helmet).w
	bne.w	loc_AC42
	tst.b	(KidGrabbedByHand).w
	bne.w	loc_AC42
	move.w	($FFFFFA78).w,d7
	addq.w	#5,d7
	move.b	($FFFFFA72).w,d6
	cmp.b	x_direction(a3),d6
	bne.w	loc_AD2C
	tst.b	d6
	beq.w	loc_ABA4
	neg.w	d7

loc_ABA4:
	move.w	d7,d4
	moveq	#-$14,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	bge.w	loc_AD2C
	move.w	a4,a2
	suba.w	(Level_width_tiles).w,a2
	move.w	(a2),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.w	loc_AD2C
	moveq	#-2,d7
	tst.b	x_direction(a3)
	beq.w	loc_ABD4
	moveq	#2,d7

loc_ABD4:
	add.w	d7,a2
	move.w	(a2),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.w	loc_AD2C
	move.w	y_pos(a3),d6
	subi.w	#$14,d6
	andi.w	#$FFF0,d6

loc_ABF0:
	add.w	(Level_width_tiles).w,a4
	addi.w	#$10,d6
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	blt.s	loc_ABF0
	subq.w	#1,d6
	cmpi.w	#$F,d6
	ble.w	loc_AD2C
	move.w	d6,y_pos(a3)
	add.w	d4,x_pos(a3)
	move.l	#stru_8BB4,d7
	jsr	(j_Init_Animation).w
	move.l	d0,-(sp)
	moveq	#sfx_The_Kid_pullup,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	jsr	(j_sub_105E).w
	clr.l	y_vel(a3)
	move.w	#MoveID_Standingstill,(Character_Movement).w
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_AC42:
	cmpi.w	#Micromax,(Current_Helmet).w
	bne.w	loc_AC88
	move.l	#$FFFC0000,y_vel(a3)
	move.l	#$FFFE0000,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_AC64
	neg.l	d7

loc_AC64:
	move.l	d7,x_vel(a3)
	sf	($FFFFFA66).w
	st	($FFFFFA67).w
	move.l	#stru_8B74,d7
	jsr	(j_Init_Animation).w
	move.b	($FFFFFA72).w,d7
	not.b	d7
	move.b	d7,x_direction(a3)
	bra.w	loc_A6F8
; ---------------------------------------------------------------------------

loc_AC88:
	tst.b	($FFFFFA6A).w
	beq.w	loc_AD2C
	moveq	#-$21,d7
	move.l	d7,d6
	add.w	y_pos(a3),d6
	bmi.w	loc_ACA4
	bsr.w	sub_B43A
	beq.w	loc_AD2C

loc_ACA4:
	move.l	#$30000,y_vel(a3)
	bra.w	loc_AD2C
; ---------------------------------------------------------------------------

loc_ACB0:
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_AD2C
	cmpi.w	#Cyclone,(Current_Helmet).w
	bne.w	loc_ACCC
	st	(Cyclone_flying).w
	bra.w	loc_AD2C
; ---------------------------------------------------------------------------

loc_ACCC:
	cmpi.w	#Maniaxe,(Current_Helmet).w
	bne.w	loc_AD00
	tst.b	(Maniaxe_throwing_axe).w
	bne.w	loc_AD2C
	st	(Maniaxe_throwing_axe).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_89D2,4(a0)
	move.l	#stru_8B60,d7
	jsr	(j_Init_Animation).w
	bra.w	loc_AD2C
; ---------------------------------------------------------------------------

loc_AD00:
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_AD2C
	tst.b	($FFFFFA6A).w
	beq.w	loc_AD26
	moveq	#-$21,d7
	move.l	d7,d6
	add.w	y_pos(a3),d6
	bmi.w	loc_AD2C
	bsr.w	sub_B43A
	bne.w	loc_AD2C

loc_AD26:
	move.b	#1,($FFFFFA69).w

loc_AD2C:
	bsr.w	sub_B270
	bra.w	loc_AA22
; ---------------------------------------------------------------------------

loc_AD34:
	sf	is_animated(a3)
	sf	($FFFFFA66).w
	sf	($FFFFFA67).w
	tst.b	($FFFFFA72).w
	beq.w	loc_AD58
	tst.b	(Ctrl_Left_Held).w
	beq.w	loc_A76A
	subq.w	#1,x_pos(a3)
	bra.w	loc_A76A
; ---------------------------------------------------------------------------

loc_AD58:
	tst.b	(Ctrl_Right_Held).w
	beq.w	loc_A76A
	addq.w	#1,x_pos(a3)
	bra.w	loc_A76A
; ---------------------------------------------------------------------------

loc_AD68:
	bpl.w	loc_AD7C
	sf	($FFFFFA66).w
	sf	($FFFFFA67).w
	sf	is_animated(a3)
	bra.w	loc_A762
; ---------------------------------------------------------------------------

loc_AD7C:
	clr.b	($FFFFFA69).w
	cmpi.w	#2,d7
	bge.w	loc_AD98
	tst.b	($FFFFFA6A).w
	beq.w	loc_A94E
	bsr.w	sub_BB54
	bra.w	loc_AA9C
; ---------------------------------------------------------------------------

loc_AD98:
	bne.w	loc_ADAC
	tst.b	($FFFFFA6A).w
	bne.w	loc_AA9C
	bsr.w	sub_BB54
	bra.w	loc_AA9C
; ---------------------------------------------------------------------------

loc_ADAC:
	move.w	#4,collision_type(a3)
	bra.w	loc_AA22
; End of function sub_A4EE

; ---------------------------------------------------------------------------
	bra.s	loc_ADAC

; =============== S U B	R O U T	I N E =======================================


sub_ADB8:
	move.w	y_pos(a3),d7
	move.w	d7,d6
	sub.w	($FFFFFB5C).w,d6
	moveq	#$F,d5
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_ADDA
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_ADDA
	moveq	#$1F,d5

loc_ADDA:
	sub.w	d5,d7
	move.w	d7,d5
	move.w	d5,($FFFFFB5C).w
	andi.w	#$F,d5
	cmp.w	d6,d5
	blt.w	loc_ADF0

loc_ADEC:
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_ADF0:
	asr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	($FFFFFA78).w,d7
	addq.w	#1,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_AE0E
	neg.w	d7

loc_AE0E:
	add.w	x_pos(a3),d7
	asr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.s	loc_ADEC
	move.w	a4,a0
	suba.w	(Level_width_tiles).w,a0
	move.w	(a0),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	blt.s	loc_ADEC
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_AE5A
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_AE5A
	add.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.s	loc_ADEC

loc_AE5A:
	add.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	blt.s	loc_ADEC
	moveq	#0,d7
	rts
; End of function sub_ADB8


; =============== S U B	R O U T	I N E =======================================


sub_AE6E:
	move.w	y_pos(a3),d7
	move.w	d7,d6
	sub.w	($FFFFFB5C).w,d6
	neg.w	d6
	addq.w	#1,d7
	neg.w	d7
	andi.w	#$F,d7
	cmp.w	d6,d7
	blt.w	loc_AE8C

loc_AE88:
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_AE8C:
	move.w	y_pos(a3),d7
	asr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	($FFFFFA78).w,d7
	addq.w	#1,d7
	tst.b	($FFFFFA72).w
	beq.w	loc_AEAE
	neg.w	d7

loc_AEAE:
	add.w	x_pos(a3),d7
	asr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.s	loc_AE88
	move.w	a4,a0
	add.w	(Level_width_tiles).w,a0
	move.w	(a0),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	blt.s	loc_AE88
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_AEFA
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_AEFA
	suba.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bge.s	loc_AE88

loc_AEFA:
	suba.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	blt.w	loc_AE88
	moveq	#0,d7
	rts
; End of function sub_AE6E


; =============== S U B	R O U T	I N E =======================================


sub_AF10:
	move.w	y_pos(a3),d7
	move.w	d7,d6
	moveq	#$F,d5
	cmpi.w	#Micromax,(Current_Helmet).w
	beq.w	loc_AF2E
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_AF2E
	moveq	#$1F,d5

loc_AF2E:
	sub.w	d5,d6
	asr.w	#4,d7
	asr.w	#4,d6
	sub.w	d6,d7
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	move.w	($FFFFFA78).w,d6
	addq.w	#1,d6
	tst.b	($FFFFFA72).w
	beq.w	loc_AF52
	neg.w	d6

loc_AF52:
	add.w	x_pos(a3),d6
	asr.w	#4,d6
	add.w	d6,d6
	add.w	d6,a4

loc_AF5C:
	move.w	(a4),d6
	andi.w	#$7000,d6
	cmpi.w	#$6000,d6
	bge.w	loc_AF76
	add.w	(Level_width_tiles).w,a4
	dbf	d7,loc_AF5C
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_AF76:
	moveq	#1,d7
	rts
; End of function sub_AF10


; =============== S U B	R O U T	I N E =======================================


sub_AF7A:
	cmpi.w	#Iron_Knight,(Current_Helmet).w
	bne.w	loc_AFD0
	tst.b	(Iron_Knight_block_breaker).w
	bne.w	loc_AF96
	cmpi.l	#$48000,d6
	blt.w	loc_AFD0

loc_AF96:
	st	(Iron_Knight_block_breaker).w
	movem.w	d0-d3,-(sp)
	move.l	a2,-(sp)
	bsr.w	sub_BBE2
	beq.w	loc_AFCA
	cmpi.w	#$14,d7
	bgt.w	loc_AFCA
	moveq	#0,d6
	move.l	off_AFD8(pc,d7.w),a4
	jsr	(a4)
	move.l	(sp)+,a2
	movem.w	(sp)+,d0-d3
	move.l	#$FFFF8000,y_vel(a3)
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_AFCA:
	move.l	(sp)+,a2
	movem.w	(sp)+,d0-d3

loc_AFD0:
	moveq	#0,d7
	rts
; End of function sub_AF7A


; =============== S U B	R O U T	I N E =======================================


sub_AFD4:
	addq.w	#4,sp
	bra.s	loc_AFCA
; End of function sub_AFD4

; ---------------------------------------------------------------------------
off_AFD8:	dc.l loc_AFF0
	dc.l j_loc_1002E
	dc.l j_sub_10F44
	dc.l sub_AFD4
	dc.l sub_AFD4
	dc.l j_loc_110D0
; ---------------------------------------------------------------------------

loc_AFF0:
	moveq	#2,d6
	jmp	(j_sub_10E86).l
; ---------------------------------------------------------------------------
	moveq	#2,d6
	jmp	(j_sub_10F44).l

; =============== S U B	R O U T	I N E =======================================


sub_B000:
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	bne.w	loc_B080
	tst.b	(Red_Stealth_sword_swing).w
	beq.w	loc_B080
	moveq	#0,d7
	tst.b	x_direction(a3)
	beq.w	loc_B01E
	neg.w	d7

loc_B01E:
	moveq	#1,d6
	bsr.w	sub_B55C
	move.w	(a4),d7
	bclr	#$F,d7
	beq.w	loc_B080
	move.w	a4,d3
	jsr	(j_sub_FACE).l
	moveq	#0,d6
	andi.w	#$F00,d7
	asr.w	#6,d7
	cmpi.w	#$14,d7
	bgt.w	loc_B080
	move.l	off_B058(pc,d7.w),a4
	jsr	(a4)
	move.l	#$FFFC8000,y_vel(a3)
	moveq	#1,d7

return_B056:
	rts
; ---------------------------------------------------------------------------
off_B058:	dc.l loc_B070
	dc.l j_loc_1002E
	dc.l j_sub_10F44
	dc.l return_B056
	dc.l return_B056
	dc.l j_loc_110D0
; ---------------------------------------------------------------------------

loc_B070:
	moveq	#2,d6
	jmp	(j_sub_10E86).l
; ---------------------------------------------------------------------------
	moveq	#2,d6
	jmp	(j_sub_10F44).l
; ---------------------------------------------------------------------------

loc_B080:
	moveq	#0,d7
	rts
; End of function sub_B000


; =============== S U B	R O U T	I N E =======================================


sub_B084:
	move.w	(Current_Helmet).w,d0
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_B09E
	move.l	x_vel(a3),d0
	bsr.w	sub_9A20
	bra.w	loc_B118
; ---------------------------------------------------------------------------

loc_B09E:
	add.w	d0,d0
	lea	unk_A4B2(pc),a0
	move.w	(a0,d0.w),d1
	ext.l	d1
	tst.b	(Ctrl_A_Held).w
	beq.s	loc_B0B6
	move.l	d1,d2
	asr.l	#1,d2
	add.l	d2,d1

loc_B0B6:
	lea	unk_A4C6(pc),a0
	add.w	d0,d0
	move.l	(a0,d0.w),d2
	move.l	x_vel(a3),d0
	tst.b	(Ctrl_Left_Held).w
	beq.s	loc_B0E2
	st	x_direction(a3)
	sub.l	d1,d0
	bpl.s	loc_B118
	neg.l	d2
	cmp.l	d0,d2
	ble.s	loc_B118
	add.l	d1,d0
	addi.l	#$100,d0
	bra.s	loc_B118
; ---------------------------------------------------------------------------

loc_B0E2:
	tst.b	(Ctrl_Right_Held).w
	beq.s	loc_B0FE
	sf	x_direction(a3)
	add.l	d1,d0
	bmi.s	loc_B118
	cmp.l	d0,d2
	bge.s	loc_B118
	sub.l	d1,d0
	subi.l	#$100,d0
	bra.s	loc_B118
; ---------------------------------------------------------------------------

loc_B0FE:
	tst.l	d0
	bmi.s	loc_B10E
	subi.l	#$400,d0
	bpl.s	loc_B118
	moveq	#0,d0
	bra.s	loc_B118
; ---------------------------------------------------------------------------

loc_B10E:
	addi.l	#$400,d0
	bmi.s	loc_B118
	moveq	#0,d0

loc_B118:
	move.l	d0,x_vel(a3)
	rts
; End of function sub_B084

; ---------------------------------------------------------------------------
	add.l	x_pos(a3),d0
	move.l	d0,x_pos(a3)
	swap	d0
	move.w	d0,d7
	sub.w	($FFFFFA78).w,d7
	bmi.w	loc_B140
	add.w	($FFFFFA78).w,d0
	cmp.w	(Level_width_pixels).w,d0
	bge.w	loc_B150
	rts
; ---------------------------------------------------------------------------

loc_B140:
	move.w	($FFFFFA78).w,x_pos(a3)
	clr.w	$1C(a3)
	clr.l	x_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_B150:
	move.w	(Level_width_pixels).w,d7
	subq.w	#1,d7
	sub.w	($FFFFFA78).w,d7
	move.w	d7,x_pos(a3)
	clr.w	$1C(a3)
	clr.l	x_vel(a3)
	rts

; =============== S U B	R O U T	I N E =======================================


sub_B168:
	tst.b	($FFFFFA66).w
	beq.w	loc_B18A
	move.l	y_vel(a3),d7
	addi.l	#$600,d7
	cmpi.l	#$10000,d7
	bgt.w	loc_B18A
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_B18A:
	cmpi.w	#Cyclone,(Current_Helmet).w
	bne.w	loc_B19C
	tst.b	(Cyclone_flying).w
	bne.w	loc_B214

loc_B19C:
	tst.b	($FFFFFA6A).w
	beq.w	loc_B1D4
	move.l	y_vel(a3),d7
	move.l	#$2000,d6
	tst.w	(Ctrl_B_Held).w
	bne.w	loc_B1BC
	move.l	#$4000,d6

loc_B1BC:
	sub.l	d6,d7
	cmpi.l	#$FFF88000,d7
	bgt.w	loc_B1CE
	move.l	#$FFF88000,d7

loc_B1CE:
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_B1D4:
	move.l	y_vel(a3),d7
	bpl.s	loc_B1E0
	tst.b	(Ctrl_B_Held).w
	bne.s	loc_B1E8

loc_B1E0:
	addi.l	#$4000,d7
	bra.s	loc_B1EE
; ---------------------------------------------------------------------------

loc_B1E8:
	addi.l	#$2000,d7

loc_B1EE:
	cmpi.l	#$80000,d7
	ble.s	loc_B200
	move.l	#$80000,d7
	bra.w	loc_B20E
; ---------------------------------------------------------------------------

loc_B200:
	cmpi.l	#$FFF80000,d7
	bge.s	loc_B20E
	move.l	#$FFF80000,d7

loc_B20E:
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_B214:	; Cyclone is flying
	move.w	(Cyclone_YAcceleration).w,d7
	addi.w	#$400,d7
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	beq.w	loc_B23A
	; flying button was pressed
	subi.w	#$3000,d7
	cmpi.w	#$8001,d7
	bgt.w	loc_B246
	move.w	#$8001,d7
	bra.w	loc_B246
; ---------------------------------------------------------------------------

loc_B23A:	; flying button not pressed.
	cmpi.w	#$1200,d7
	ble.w	loc_B246
	move.w	#$1200,d7

loc_B246:
	move.w	d7,(Cyclone_YAcceleration).w
	ext.l	d7
	add.l	y_vel(a3),d7

	; y-speed at most 2.5 px/frame downwards
	cmpi.l	#$28000,d7
	ble.s	loc_B25E
	move.l	#$28000,d7

loc_B25E:	; y-speed at most 3 px/frame upwards
	cmpi.l	#-$30000,d7
	bgt.s	loc_B26C
	move.l	#-$30000,d7

loc_B26C:
	move.l	d7,y_vel(a3)
; End of function sub_B168


; =============== S U B	R O U T	I N E =======================================


sub_B270:
	cmpi.w	#Eyeclops,(Current_Helmet).w
	bne.w	loc_B284
	tst.b	is_animated(a3)
	beq.w	loc_B304
	rts
; ---------------------------------------------------------------------------

loc_B284:
	tst.b	($FFFFFA66).w
	beq.w	loc_B28E
	rts
; ---------------------------------------------------------------------------

loc_B28E:
	tst.b	($FFFFFA67).w
	beq.w	loc_B2A0
	tst.b	$18(a3)
	bne.w	loc_B2A0
	rts
; ---------------------------------------------------------------------------

loc_B2A0:
	sf	($FFFFFA67).w
	tst.b	(Cyclone_flying).w
	beq.w	loc_B2DE
	move.w	(Cyclone_YAcceleration).w,d7
	neg.w	d7
	addi.w	#$2000,d7
	asl.w	#2,d7
	lsr.w	#8,d7
	add.w	($FFFFF8F0).w,d7
	cmpi.w	#$300,d7
	blt.w	loc_B2CA
	subi.w	#$300,d7

loc_B2CA:
	move.w	d7,($FFFFF8F0).w
	asr.w	#8,d7
	add.w	d7,d7
	add.w	d7,d7
	addi.w	#LnkTo_unk_BA55A-Data_Index,d7
	move.w	d7,addroffset_sprite(a3)

return_B2DC:
	rts
; ---------------------------------------------------------------------------

loc_B2DE:
	move.w	(Current_Helmet).w,d7
	cmpi.w	#5,d7
	bne.w	loc_B304
	move.l	($FFFFF862).w,a4
	bsr.w	sub_975C
	tst.b	is_animated(a3)
	beq.w	loc_B304
	tst.b	$18(a3)
	beq.s	return_B2DC
	sf	is_animated(a3)

loc_B304:
	move.w	(Current_Helmet).w,d7
	cmpi.w	#1,d7
	beq.w	loc_B3B2
	lsl.w	#3,d7
	lea	off_B3B8(pc),a4
	add.w	d7,a4
	cmpi.w	#Maniaxe,(Current_Helmet).w
	bne.w	loc_B334
	tst.b	(Maniaxe_throwing_axe).w
	beq.w	loc_B334
	tst.b	$18(a3)
	bne.w	loc_B334
	rts
; ---------------------------------------------------------------------------

loc_B334:
	sf	(Maniaxe_throwing_axe).w
	move.l	($FFFFFAAA).w,d7
	move.l	y_vel(a3),d6
	lsl.l	#2,d6
	bpl.s	loc_B350
	cmp.l	d7,d6
	ble.w	loc_B3A8
	addq.w	#2,a4
	bra.w	loc_B3A8
; ---------------------------------------------------------------------------

loc_B350:
	addq.w	#4,a4
	cmp.l	d7,d6
	ble.s	loc_B3A8
	addq.w	#2,a4
	cmpi.w	#Red_Stealth,(Current_Helmet).w
	bne.w	loc_B3A8
	tst.b	(Ctrl_C_Held).w
	beq.w	loc_B3A8
	moveq	#0,d7
	move.b	(Red_Stealth_sword_swing).w,d7
	addi.w	#$10,d7
	cmpi.w	#$7F,d7
	ble.w	loc_B380
	move.w	#$7F,d7

loc_B380:
	move.b	d7,(Red_Stealth_sword_swing).w
	asr.w	#5,d7
	add.w	d7,d7
	add.w	d7,d7
	addi.w	#LnkTo_unk_B40DE-Data_Index,d7
	move.w	d7,addroffset_sprite(a3)
	cmpi.b	#$10,(Red_Stealth_sword_swing).w
	bne.s	return_B3A6
	move.l	d0,-(sp)
	moveq	#sfx_Red_Stealth_attack_down,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

return_B3A6:
	rts
; ---------------------------------------------------------------------------

loc_B3A8:
	sf	(Red_Stealth_sword_swing).w
	move.w	(a4),addroffset_sprite(a3)
	rts
; ---------------------------------------------------------------------------

loc_B3B2:
	bsr.w	sub_98F2
	rts
; End of function sub_B270

; ---------------------------------------------------------------------------
off_B3B8:
	dc.w LnkTo_unk_A3B66-Data_Index
	dc.w LnkTo_unk_A3B66-Data_Index
	dc.w LnkTo_unk_A3CEC-Data_Index
	dc.w LnkTo_unk_A3CEC-Data_Index
	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_A978A-Data_Index
	dc.w LnkTo_unk_BADB2-Data_Index
	dc.w LnkTo_unk_BAF98-Data_Index
	dc.w LnkTo_unk_BAF98-Data_Index
	dc.w LnkTo_unk_BB11E-Data_Index
	dc.w LnkTo_unk_B4AB6-Data_Index
	dc.w LnkTo_unk_B4AB6-Data_Index
	dc.w LnkTo_unk_B4C9C-Data_Index
	dc.w LnkTo_unk_B4C9C-Data_Index
	dc.w LnkTo_unk_B772E-Data_Index
	dc.w LnkTo_unk_B772E-Data_Index
	dc.w LnkTo_unk_B79B4-Data_Index
	dc.w LnkTo_unk_B79B4-Data_Index
	dc.w LnkTo_unk_BFAE0-Data_Index
	dc.w LnkTo_unk_BFD26-Data_Index
	dc.w LnkTo_unk_BFD26-Data_Index
	dc.w LnkTo_unk_C0000-Data_Index
	dc.w LnkTo_unk_C244A-Data_Index
	dc.w LnkTo_unk_C26D0-Data_Index
	dc.w LnkTo_unk_C26D0-Data_Index
	dc.w LnkTo_unk_C2956-Data_Index
	dc.w LnkTo_unk_B007C-Data_Index
	dc.w LnkTo_unk_B0282-Data_Index
	dc.w LnkTo_unk_B0282-Data_Index
	dc.w LnkTo_unk_B0508-Data_Index
	dc.w LnkTo_unk_A5B7C-Data_Index
	dc.w LnkTo_unk_A5B7C-Data_Index
	dc.w LnkTo_unk_A63AE-Data_Index
	dc.w LnkTo_unk_A63AE-Data_Index
	dc.w LnkTo_unk_ABB8E-Data_Index
	dc.w LnkTo_unk_ABC54-Data_Index
	dc.w LnkTo_unk_ABC54-Data_Index
	dc.w LnkTo_unk_ABD1A-Data_Index
unk_B408:	dc.b   5
	dc.b   5
	dc.b  $A
	dc.b  $A
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b $17
	dc.b $17
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   4
	dc.b   4

; =============== S U B	R O U T	I N E =======================================


sub_B41C:
	movem.l	d7/a4,-(sp)
	move.w	(Current_Helmet).w,d7
	add.w	d7,d7
	lea	unk_B408(pc),a4
	add.w	d7,a4
	moveq	#0,d7
	move.b	(a4)+,d7
	move.w	d7,($FFFFFA78).w
	movem.l	(sp)+,d7/a4
	rts
; End of function sub_B41C


; =============== S U B	R O U T	I N E =======================================


sub_B43A:
	move.w	x_pos(a3),d4
	swap	d4
	move.w	y_pos(a3),d4
	move.w	($FFFFFA78).w,d1
	cmpi.w	#MoveID_Crawling,(Character_Movement).w
	bne.w	loc_B4A0
	move.w	(Current_LevelID).w,d5
	subq.w	#WarpCheatStart_LevelID,d5
	bne.w	loc_B482
	cmpi.l	#$9D3005F,d4 ; ; x-pos=09D3 y-pos=005F in number of pixels (RAM 0xFA2C.w 0xFA2E.w)
	bne.w	loc_B482
	btst	#Button_B,(Ctrl_Held).w ; keyboard key (S) jump
	beq.w	loc_B482
	move.w	#WarpCheatDest_LevelID,(Current_LevelID).w
	move.w	#colid_kidbelow,collision_type(a3)
	move.w	#$A0,object_meta(a3)

loc_B482:
	moveq	#7,d1
	cmpi.w	#The_Kid,(Current_Helmet).w
	bne.w	loc_B494
	moveq	#5,d1
	bra.w	loc_B4A0
; ---------------------------------------------------------------------------

loc_B494:
	cmpi.w	#Skycutter,(Current_Helmet).w
	bne.w	loc_B4A0
	moveq	#$A,d1

loc_B4A0:
	move.w	d1,d2
	neg.w	d1
	move.w	x_pos(a3),d0
	add.w	d0,d1
	add.w	d0,d2
	asr.w	#4,d1
	bpl.s	loc_B4B2
	moveq	#0,d1

loc_B4B2:
	asr.w	#4,d2
	cmp.w	(Level_width_blocks).w,d2
	ble.s	loc_B4C0
	move.w	(Level_width_blocks).w,d2
	subq.w	#1,d2

loc_B4C0:
	sub.w	d1,d2
	move.w	y_pos(a3),d0
	addq.w	#1,d0
	add.w	d7,d0
	lsr.w	#4,d0
	lea	($FFFF4A04).l,a0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	add.w	d1,d1
	add.w	d1,a0
	move.l	a0,a4
	moveq	#0,d7

loc_B4E0:
	move.w	(a0)+,d0
	andi.w	#$7000,d0
	cmpi.w	#$6000,d0
	beq.w	loc_B4FA
	cmpi.w	#$7000,d0
	bne.s	loc_B514
	move.w	#colid_kidbelow,collision_type(a3)

loc_B4FA:
	moveq	#1,d7
	move.w	-2(a0),d0
	bclr	#$F,d0
	beq.w	loc_B514
	andi.w	#$F00,d0
	cmpi.w	#$400,d0
	beq.w	loc_B522

loc_B514:
	dbf	d2,loc_B4E0
	move.w	#$5A,(Telepad_timer).w

loc_B51E:
	tst.w	d7
	rts
; ---------------------------------------------------------------------------

loc_B522:
	subi.w	#1,(Telepad_timer).w
	bne.s	loc_B51E
	moveq	#-1,d7
	subq.w	#2,a0
	move.w	a0,($FFFFFA86).w
	rts
; End of function sub_B43A

; ---------------------------------------------------------------------------
	move.w	y_pos(a3),d7
	subi.w	#$22,d7
	asr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	x_pos(a3),d7
	asr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d7
	andi.w	#$4000,d7
	rts

; =============== S U B	R O U T	I N E =======================================


sub_B55C:
	add.w	x_pos(a3),d7
	add.w	y_pos(a3),d6
	asr.w	#4,d6
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	lsr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d5
	andi.w	#$7000,d5
	rts
; End of function sub_B55C

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_B580:
	clr.l	y_vel(a3)
	bra.w	loc_A426
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	st	has_level_collision(a3)
	bsr.w	sub_A432
	bsr.w	sub_B270
	move.l	y_pos(a3),d7

loc_B598:
	lea	(Addr_FirstGfxObjectSlot+2).w,a2
	jsr	(j_GfxObjects_Collision).w
	cmpi.w	#colid_ceiling,collision_type(a3)
	bne.w	loc_A6F8
	clr.w	collision_type(a3)
	subi.l	#$30000,d7
	move.l	d7,y_pos(a3)
	bra.s	loc_B598
; ---------------------------------------------------------------------------
	tst.l	y_vel(a3)
	bmi.w	loc_A426
	moveq	#8,d4
	tst.b	($FFFFFA26).w
	beq.w	loc_B5CE
	moveq	#-8,d4

loc_B5CE:
	move.w	d4,d7
	moveq	#0,d6
	bsr.s	sub_B55C
	cmpi.w	#$6000,d5
	bne.w	loc_A426
	move.w	d4,d7
	moveq	#-$10,d6
	bsr.w	sub_B55C
	andi.w	#$4000,d5
	bne.w	loc_A426
	andi.w	#$FFF0,y_pos(a3)
	bra.w	loc_A426
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_B5F6:
	addq.w	#1,y_pos(a3)
	st	has_level_collision(a3)
	sf	(Cyclone_flying).w
	move.w	#MoveID_Jump,(Character_Movement).w
	bsr.w	sub_B270
	bra.w	loc_A6F8
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================
; Added some first basic labels for Character_CheckCollision

Character_CheckCollision:
	move.w	collision_type(a3),d7
	beq.w	return_B63E
	clr.w	collision_type(a3)
	move.w	object_meta(a3),d5
	move.w	d5,d6
	bclr	#$F,d5
	bclr	#$E,d5
	clr.w	object_meta(a3)
	cmpi.w	#$64,d5
	bge.w	loc_B8E6
	subq.w	#4,d7
	move.l	off_B640(pc,d7.w),a4
	jmp	(a4)
; ---------------------------------------------------------------------------

return_B63E:
	rts
; ---------------------------------------------------------------------------
off_B640:
	dc.l Crushed_to_Death
	dc.l loc_B672
	dc.l loc_B672
	dc.l loc_B672
	dc.l loc_B672
	dc.l loc_B672
	dc.l Check_for_recent_damge
	dc.l loc_B678	; kid right of enemy
	dc.l loc_B678	; kid left of enemy
	dc.l Check_for_recent_damge	; kid below enemy
	dc.l Jump_On_Enemy	; kid above enemy
; ---------------------------------------------------------------------------

Crushed_to_Death:
	moveq	#0,d7
	bra.w	Death
; ---------------------------------------------------------------------------

loc_B672:

	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
	bra.s	loc_B672 ; Restart current level not losing a live and time doesn't reset?!
; ---------------------------------------------------------------------------

loc_B678:
	cmpi.w	#$18,d5	; is the enemy a tornado?
	beq.w	loc_B69E
	tst.b	(Berzerker_charging).w
	beq.w	Check_for_recent_damge
	bclr	#$F,d6
	bne.w	loc_B692

return_B690:
	rts
; ---------------------------------------------------------------------------

loc_B692:	; negate x velocity
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	d7,x_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_B69E:
	tst.b	(Cyclone_flying).w
	bne.s	return_B690
	bra.w	Check_for_recent_damge
; ---------------------------------------------------------------------------

Jump_On_Enemy:
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	bne.w	Check_for_recent_damge
	move.l	d0,-(sp)
	moveq	#sfx_Jump_on_enemy,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	($FFFFFA2C).w,x_pos(a3)
	move.w	($FFFFFA2E).w,y_pos(a3)
	move.l	#$FFFC0000,d7
	tst.b	($FFFFFA6A).w
	beq.w	loc_B6DA
	moveq	#0,d7

loc_B6DA:
	move.l	d7,y_vel(a3)
	move.l	x_vel(a3),d7
	sub.l	d7,x_pos(a3)
	asr.l	#1,d7
	add.l	d7,x_vel(a3)
	bclr	#$E,d6
	bne.w	Check_for_recent_damge
	rts
; ---------------------------------------------------------------------------

Check_for_recent_damge:
	tst.b	(Just_received_damage).w
	beq.w	loc_B700
	rts
; ---------------------------------------------------------------------------

loc_B700:
	move.l	a0,-(sp)
	moveq	#0,d7
	lea	HelmetHitpoint_Table(pc),a0
	move.w	(Current_Helmet).w,d7
	move.b	(a0,d7.w),d7
	add.w	(Extra_hitpoint_slots).w,d7
	move.l	(sp)+,a0
	tst.w	(Number_Hitpoints).w
	bgt.s	loc_B722
	move.w	#1,(Number_Hitpoints).w

loc_B722:
	cmp.w	(Number_Hitpoints).w,d7
	bge.s	loc_B72C
	move.w	d7,(Number_Hitpoints).w

loc_B72C:
	st	(NoHit_Bonus_Flag).w
	st	(Just_received_damage).w
	subq.w	#1,(Number_Hitpoints).w
	beq.w	loc_B786

loc_B73C:
	cmpi.w	#$50,d5 ; compare with enemy ID
	bne.s	loc_B750
	move.l	d0,-(sp)
	moveq	#sfx_Voice_ouch_1,d0 ; original recording
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; ---------------------------------------------------------------------------

loc_B750:
	cmpi.w	#$40,d5 ; compare with enemy ID
	bne.s	loc_B764
	move.l	d0,-(sp)
	moveq	#sfx_Voice_ouch_2,d0 ; slowed down
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; ---------------------------------------------------------------------------

loc_B764:
	cmpi.w	#$30,d5 ; compare with enemy ID
	bne.s	loc_B778
	move.l	d0,-(sp)
	moveq	#sfx_Voice_ouch_3,d0 ; slowed down
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; ---------------------------------------------------------------------------

loc_B778:
	move.l	d0,-(sp)
	moveq	#sfx_Voice_ouch,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; ---------------------------------------------------------------------------

loc_B786:
	moveq	#0,d7
	tst.w	(Current_Helmet).w
	
	; Player dies if he doesn't have a helmet
	beq.w	Death
	
	; Lose the helmet
	st	(Check_Helmet_Change).w
	clr.w	(Current_Helmet_Available).w
	bra.s	loc_B73C
; ---------------------------------------------------------------------------
	rts
; ---------------------------------------------------------------------------

Death:
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	clr.w	(Extra_hitpoint_slots).w
	move.l	($FFFFF862).w,a4
	sf	$13(a4)
	sf	has_level_collision(a3)
	sf	is_moved(a3)
	st	($FFFFFA64).w
	tst.w	d7
	beq.w	loc_B7EA
	move.l	y_vel(a3),d0

loc_B7CA:
	add.l	d0,y_pos(a3)
	addi.l	#$4000,d0
	movem.l	d0-a5,-(sp)
	jsr	(j_sub_8E0).w
	movem.l	(sp)+,d0-a5
	tst.b	$19(a3)
	beq.s	loc_B7CA
	bra.w	lose_life
; ---------------------------------------------------------------------------

loc_B7EA:
	tst.w	(Current_Helmet).w
	beq.w	loc_B7FA
	clr.w	(Current_Helmet_Available).w
	bsr.w	Kid_Transform

loc_B7FA:
	move.l	#$8000,d0
	move.l	#$FFFC0000,d1
	move.w	#(LnkTo_unk_A3FF8-Data_Index),addroffset_sprite(a3)

loc_B80C:
	movem.l	d0-a5,-(sp)
	jsr	(j_sub_8E0).w
	movem.l	(sp)+,d0-a5
	tst.b	$19(a3)
	bne.w	lose_life
	addi.l	#$3000,d1
	add.l	d0,x_pos(a3)
	add.l	d1,y_pos(a3)
	bra.s	loc_B80C
; ---------------------------------------------------------------------------

lose_life:							; Death management
	clr.w	(Extra_hitpoint_slots).w
	clr.w	(Current_Helmet).w		; Clears current helmet
	subq.w	#1,(Number_Lives).w		; Subtracts 1 from Number_Lives
	beq.w	loc_D052
	move.w	#2,(Number_Hitpoints).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w

Teleport:
	sf	($FFFFFB56).w
	jsr	(sub_E1334).l
	cmpi.w	#$FFFB,d6
	bne.s	+
	move.l	d0,-(sp)
	moveq	#sfx_Teleport,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

+
	st	($FFFFFBCE).w
	jsr	(j_sub_8C2).w
	tst.b	(Two_player_flag).w
	bne.w	loc_B894
	tst.b	($FFFFFC29).w
	bne.w	+
	move.w	#8,(Game_Mode).w

+
	tst.w	(Player_1_Lives).w
	beq.w	loc_B8E2
	bra.w	loc_B8DE
; ---------------------------------------------------------------------------

loc_B894:
	tst.w	(Player_1_Lives).w
	beq.w	loc_B8D0
	tst.w	(Player_2_Lives).w
	bne.w	loc_B8BA
	sf	($FFFFFC39).w

loc_B8A8:
	tst.b	($FFFFFC29).w
	bne.w	loc_B8DE
	move.w	#8,(Game_Mode).w
	bra.w	loc_B8DE
; ---------------------------------------------------------------------------

loc_B8BA:
	tst.b	($FFFFFC29).w
	bne.w	loc_B8DE
	move.w	#8,(Game_Mode).w
	not.b	($FFFFFC39).w
	bra.w	loc_B8DE
; ---------------------------------------------------------------------------

loc_B8D0:
	tst.w	(Player_2_Lives).w
	beq.w	loc_B8E2
	st	($FFFFFC39).w
	bra.s	loc_B8A8
; ---------------------------------------------------------------------------

loc_B8DE:
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_B8E2:
	jmp	(j_EntryPoint).w
; ---------------------------------------------------------------------------

loc_B8E6:
	bgt.w	Assign_ID_to_Helmet
	st	(NoPrize_Bonus_Flag).w
	rts
; ---------------------------------------------------------------------------
word_B8F0:
	dc.w	 1
	dc.w	 1
	dc.w	 2
	dc.w	 3
	dc.w	 4
	dc.w	 5
	dc.w	 6
	dc.w	 7
	dc.w	 8
	dc.w	 9
	dc.w	$A
; ---------------------------------------------------------------------------

Assign_ID_to_Helmet:
	cmpi.w	#$90,d5
	bge.w	loc_B93A ; No helmet prize continue other
	st	(NoPrize_Bonus_Flag).w
	move.w	d5,d7
	subi.w	#$68,d7
	asr.w	#1,d7
	move.w	word_B8F0(pc,d7.w),(Current_Helmet_Available).w
	st	(Check_Helmet_Change).w
	rts
; ---------------------------------------------------------------------------
off_B926:
	dc.l Ankh
	dc.l Clock
	dc.l Coin
	dc.l loc_B972
	dc.l Flagpole
; ---------------------------------------------------------------------------

loc_B93A:
	subi.w	#$90,d5
	move.l	off_B926(pc,d5.w),a4
	jmp	(a4)
; End of function Character_CheckCollision


; =============== S U B	R O U T	I N E =======================================


Ankh:
	st	(NoPrize_Bonus_Flag).w
	move.l	d0,-(sp)
	moveq	#sfx_Ankh_prize,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; End of function Ankh


; =============== S U B	R O U T	I N E =======================================


Clock:
	st	(NoPrize_Bonus_Flag).w
	rts
; End of function Clock

; ---------------------------------------------------------------------------

Coin:
	st	(NoPrize_Bonus_Flag).w
	addq.w	#1,(Number_Continues).w
	move.l	d0,-(sp)
	moveq	#sfx_Coin_prize,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; ---------------------------------------------------------------------------

loc_B972:
	st	(NoPrize_Bonus_Flag).w
	rts
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_B978:
	clr.w	$20(a3)
	andi.w	#$FFF0,y_pos(a3)
	subq.w	#1,y_pos(a3)
	tst.l	x_vel(a3)
	bne.w	loc_B996
	bsr.w	sub_78E8
	bra.w	loc_75D4
; ---------------------------------------------------------------------------

loc_B996:
	move.l	x_vel(a3),d0
	bsr.w	sub_942A
	bra.w	loc_8BF0
; ---------------------------------------------------------------------------

loc_B9A2:
	bsr.w	sub_DB22
	clr.w	collision_type(a3)
	clr.w	$1C(a3)
	clr.w	$20(a3)
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_BB08
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	sf	has_level_collision(a3)
	sf	($FFFFFA26).w
	move.w	($FFFFFB6C).w,d3
	jsr	(j_sub_FACE).l
	asl.w	#4,d1
	asl.w	#4,d2
	add.w	d2,d1
	addi.w	#$F,d1
	move.w	x_pos(a3),d3
	swap	d3
	move.w	y_pos(a3),d3
	move.w	d1,($FFFFFA24).w
	sub.w	x_pos(a3),d1
	move.w	d1,y_pos(a3)
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_B978
	cmpi.w	#$4000,d5
	bne.w	loc_BA1C
	move.w	#6,($FFFFFA56).w
	bra.w	loc_9D58
; ---------------------------------------------------------------------------

loc_BA1C:
	move.w	d3,y_pos(a3)
	swap	d3
	andi.w	#$FFF0,d3
	addi.w	#$F,d3
	sub.w	($FFFFFA78).w,d3
	move.w	d3,x_pos(a3)
	clr.l	x_vel(a3)
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_B978
	sf	($FFFFFA72).w
	st	has_level_collision(a3)
	bsr.w	sub_B270
	bra.w	loc_AA22
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	bra.w	loc_B978
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_BA5A:
	bsr.w	sub_DB22
	clr.w	collision_type(a3)
	clr.w	$1C(a3)
	clr.w	$20(a3)
	cmpi.w	#Juggernaut,(Current_Helmet).w
	beq.w	loc_BB30
	bclr	#Button_B,(Ctrl_Pressed).w ; keyboard key (S) jump
	bclr	#Button_C,(Ctrl_Pressed).w ; keyboard key (D) special
	sf	has_level_collision(a3)
	st	($FFFFFA26).w
	move.w	($FFFFFB6C).w,d3
	jsr	(j_sub_FACE).l
	asl.w	#4,d1
	asl.w	#4,d2
	sub.w	d2,d1
	neg.w	d1
	move.w	d1,($FFFFFA24).w
	move.w	x_pos(a3),d3
	swap	d3
	move.w	y_pos(a3),d3
	add.w	x_pos(a3),d1
	move.w	d1,y_pos(a3)
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_B978
	cmpi.w	#$5000,d5
	bne.w	loc_BAD2
	move.w	#6,($FFFFFA56).w
	bra.w	loc_9D58
; ---------------------------------------------------------------------------

loc_BAD2:
	move.w	d3,y_pos(a3)
	swap	d3
	andi.w	#$FFF0,d3
	add.w	($FFFFFA78).w,d3
	move.w	d3,x_pos(a3)
	clr.l	x_vel(a3)
	moveq	#0,d7
	moveq	#0,d6
	bsr.w	sub_B55C
	cmpi.w	#$6000,d5
	beq.w	loc_B978
	st	($FFFFFA72).w
	st	has_level_collision(a3)
	bsr.w	sub_B270
	bra.w	loc_AA22
; ---------------------------------------------------------------------------

loc_BB08:
	move.l	#$FFFE0000,x_vel(a3)
	move.l	#$FFFE0000,y_vel(a3)
	rts
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	neg.l	d7
	move.l	y_vel(a3),d6
	neg.l	d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_BB30:
	move.l	#$20000,x_vel(a3)
	move.l	#$FFFE0000,y_vel(a3)
	rts
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	move.l	x_vel(a3),d7
	move.l	y_vel(a3),d6
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)
	rts

; =============== S U B	R O U T	I N E =======================================


sub_BB54:
	movem.w	d0-d3,-(sp)
	move.l	a2,-(sp)
	bsr.w	sub_BBE2
	beq.w	loc_BB74
	moveq	#2,d6
	tst.b	($FFFFFA6A).w
	beq.w	loc_BB6E
	moveq	#0,d6

loc_BB6E:
	move.l	off_BB80(pc,d7.w),a4
	jsr	(a4)

loc_BB74:
	move.l	(sp)+,a2
	movem.w	(sp)+,d0-d3
	clr.l	y_vel(a3)
	rts
; End of function sub_BB54

; ---------------------------------------------------------------------------
off_BB80:	dc.l j_sub_10E86
	dc.l j_loc_1002E
	dc.l j_sub_10F44
	dc.l return_BBC0
	dc.l return_BBC0
	dc.l j_loc_110D0
	dc.l return_BBC0
	dc.l loc_BBD2
	dc.l j_return_1142E
	dc.l loc_BBC2
	dc.l return_BBC0
	dc.l j_loc_FAFE
	dc.l return_BBC0
	dc.l return_BBC0
	dc.l return_BBC0
	dc.l return_BBC0
; ---------------------------------------------------------------------------

return_BBC0:
	rts
; ---------------------------------------------------------------------------

loc_BBC2:
	tst.b	($FFFFFA6A).w
	bne.w	return_BBD0
	jmp	(j_loc_11430).l
; ---------------------------------------------------------------------------

return_BBD0:
	rts
; ---------------------------------------------------------------------------

loc_BBD2:
	tst.b	($FFFFFA6A).w
	bne.w	return_BBE0
	jmp	(j_loc_11364).l
; ---------------------------------------------------------------------------

return_BBE0:
	rts

; =============== S U B	R O U T	I N E =======================================


sub_BBE2:
	move.w	($FFFFFB6C).w,d3
	move.w	d3,a4
	jsr	(j_sub_FACE).l
	move.w	x_pos(a3),d7
	asr.w	#4,d7
	cmp.w	d1,d7
	ble.w	loc_BC1C
	move.w	2(a4),d7
	move.w	d7,d6
	andi.w	#$7000,d6
	cmpi.w	#$6000,d6
	bne.w	loc_BC1C
	bclr	#$F,d7
	beq.w	loc_BC30
	addq.w	#2,d3
	addq.w	#1,d1
	bra.w	loc_BC26
; ---------------------------------------------------------------------------

loc_BC1C:
	move.w	(a4),d7
	bclr	#$F,d7
	beq.w	loc_BC30

loc_BC26:
	andi.w	#$F00,d7
	asr.w	#6,d7
	tst.w	d3
	rts
; ---------------------------------------------------------------------------

loc_BC30:
	moveq	#0,d3
	rts
; End of function sub_BBE2

; ---------------------------------------------------------------------------

loc_BC34:
	move.l	(Addr_GfxObject_Kid).w,a3
	move.b	palette_line(a3),d1
	move.b	d1,d0
	addq.w	#2,d0

loc_BC40:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	($FFFFFA64).w
	bne.s	loc_BC40
	tst.b	(Just_received_damage).w
	bne.w	loc_BC54
	bra.s	loc_BC40
; ---------------------------------------------------------------------------

loc_BC54:
	moveq	#$A,d3

loc_BC56:
	bsr.w	sub_80BC
	moveq	#1,d2

loc_BC5C:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d2,loc_BC5C
	move.w	(Current_Helmet).w,d7
	bsr.w	sub_80D0
	moveq	#3,d2

loc_BC6E:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d2,loc_BC6E
	dbf	d3,loc_BC56
	sf	(Just_received_damage).w
	bra.s	loc_BC40
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_BC80:
	move.w	($FFFFF8DE).w,d7
	beq.w	loc_BCAC
	subq.w	#1,d7
	move.w	($FFFFFA86).w,d6
	move.w	d6,d5
	subq.w	#2,d5
	move.l	($FFFFF8E0).w,a4

loc_BC96:
	move.w	(a4),d4
	cmp.w	d4,d6
	beq.w	loc_BCB2
	cmp.w	d4,d5
	beq.w	loc_BCB2
	addi.w	#$A,a4
	dbf	d7,loc_BC96

loc_BCAC:
	jmp	(j_loc_6E2).w
; END OF FUNCTION CHUNK	FOR sub_A4EE
; ---------------------------------------------------------------------------
	bra.s	loc_BCAC
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_A4EE

loc_BCB2:
	addq.w	#6,a4
	move.w	(a4),d7
	andi.w	#$FF,d7
	asl.w	#4,d7
	move.w	d7,(PlayerStart_Y_pos).w
	move.w	2(a4),d7
	asl.w	#4,d7
	move.w	d7,(PlayerStart_X_pos).w
	move.w	(a4),d7
	asr.w	#8,d7
	moveq	#0,d6
	move.l	(LnkTo_MapOrder_Index).l,a4

loc_BCD6:
	move.b	(a4)+,d5
	ext.w	d5
	cmpi.w	#$FFFF,d5	; have we reached the end?
	beq.s	loc_BCAC
	cmp.w	d5,d7
	beq.w	loc_BCEA
	addq.w	#1,d6		; next level
	bra.s	loc_BCD6
; ---------------------------------------------------------------------------

loc_BCEA:
	cmp.w	(Current_LevelID).w,d6
	beq.w	loc_BCF6
	st	($FFFFFC36).w

loc_BCF6:
	move.w	d6,(Current_LevelID).w
	st	($FFFFFC29).w
	move.w	#$EE,($FFFFFBCC).w	; yellow from teleport warp?
	moveq	#-5,d6
	bra.w	Teleport
; END OF FUNCTION CHUNK	FOR sub_A4EE

; =============== S U B	R O U T	I N E =======================================


sub_BD0A:
	bne.w	loc_BD38
	lea	unk_BD8E(pc),a4
	move.w	#$90,d7
	move.w	(a4)+,$1E(a0)
	move.w	d7,$18(a0)
	move.w	(a4)+,$26(a0)
	move.w	d7,$20(a0)
	move.w	(a4)+,$2E(a0)
	move.w	d7,$28(a0)
	move.w	(a4),$36(a0)
	move.w	d7,$30(a0)
	rts
; ---------------------------------------------------------------------------

loc_BD38:
	tst.b	($FFFFFB4B).w
	beq.s	loc_BD40
	rts
; ---------------------------------------------------------------------------

loc_BD40:
	move.l	(Addr_GfxObject_Kid).w,a2
	move.w	$1A(a2),d5
	sub.w	(Camera_X_pos).w,d5
	addi.w	#$80,d5
	move.w	$1E(a2),d6
	sub.w	(Camera_Y_pos).w,d6
	subi.w	#$2C,d6
	addi.w	#$80,d6
	lea	unk_BD8A(pc),a4
	move.w	#1,$1E(a0)
	move.w	#1,$26(a0)
	move.w	d6,$28(a0)
	move.w	(a4)+,d7
	add.w	d5,d7
	move.w	d7,$2E(a0)
	move.w	d6,$30(a0)
	move.w	(a4),d7
	add.w	d5,d7
	move.w	d7,$36(a0)
	rts
; End of function sub_BD0A

; ---------------------------------------------------------------------------
unk_BD8A:
	dc.w  -7
	dc.w   1
unk_BD8E:
	dc.w $90
	dc.w $98
	dc.w $9D
	dc.w $A5
; ---------------------------------------------------------------------------
	tst.b	(Check_Helmet_Change).w
	bne.s	Transform_Character
	rts
; ---------------------------------------------------------------------------

Transform_Character:
	move.w	(Current_Helmet_Available).w,(Current_Helmet).w
	rts
; ---------------------------------------------------------------------------
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   2
	dc.b   4
	dc.b   6
	dc.b   8
	dc.b   3
	dc.b   6
	dc.b   9
	dc.b  $C
	dc.b   4
	dc.b   8
	dc.b  $C
	dc.b $10

;unk_BDB6
HelmetHitpoint_Table:
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   5
	dc.b   3
	dc.b   3
	dc.b   3

; =============== S U B	R O U T	I N E =======================================

;sub_BDC0
Make_SpriteAttr_HUD:
	lea	(Sprite_Table).l,a0
	move.w	#$A,$4A(a0)
	move.l	#Sprite_Table+$50,a2
	move.b	#$A,d4
	move.w	(Number_Hitpoints).w,d0
	move.w	(Current_Helmet).w,d2
	tst.b	(Currently_transforming).w
	bne.w	loc_BE82
	moveq	#0,d1
	move.b	HelmetHitpoint_Table(pc,d2.w),d1
	add.w	(Extra_hitpoint_slots).w,d1
	move.w	#$80,d2
	tst.b	($FFFFFB49).w
	beq.s	loc_BE08
	move.w	(Time_Frames).w,d3
	cmpi.w	#$50,d3
	ble.s	loc_BE06
	moveq	#$50,d3

loc_BE06:
	sub.w	d3,d2

loc_BE08:
	move.w	#$A4,d3

loc_BE0C:
	addq.w	#1,d4
	addi.w	#$10,d2
	subq.w	#2,d1
	subq.w	#2,d0
	bge.s	loc_BE20
	cmpi.w	#$FFFF,d0
	beq.s	loc_BE34
	bra.s	loc_BE5C
; ---------------------------------------------------------------------------

loc_BE20:
	move.w	d3,(a2)+
	move.b	#4,(a2)+
	move.b	d4,(a2)+
	move.w	#$822D,(a2)+
	move.w	d2,(a2)+
	tst.w	d1
	bgt.s	loc_BE0C
	bra.s	loc_BE82
; ---------------------------------------------------------------------------

loc_BE34:
	tst.w	d1
	bmi.s	loc_BE4C
	move.w	d3,(a2)+
	move.b	#4,(a2)+
	move.b	d4,(a2)+
	move.w	#$822E,(a2)+
	move.w	d2,(a2)+
	tst.w	d1
	bgt.s	loc_BE0C
	bra.s	loc_BE82
; ---------------------------------------------------------------------------

loc_BE4C:
	move.w	d3,(a2)+
	move.b	#0,(a2)+
	move.b	d4,(a2)+
	move.w	#$822D,(a2)+
	move.w	d2,(a2)+
	bra.s	loc_BE82
; ---------------------------------------------------------------------------

loc_BE5C:
	tst.w	d1
	bmi.s	loc_BE74
	move.w	d3,(a2)+
	move.b	#4,(a2)+
	move.b	d4,(a2)+
	move.w	#$822F,(a2)+
	move.w	d2,(a2)+
	tst.w	d1
	bgt.s	loc_BE0C
	bra.s	loc_BE82
; ---------------------------------------------------------------------------

loc_BE74:
	move.w	d3,(a2)+
	move.b	#0,(a2)+
	move.b	d4,(a2)+
	move.w	#$822F,(a2)+
	move.w	d2,(a2)+

loc_BE82:
	move.b	d4,(Number_Sprites).w
	move.l	a2,(Addr_NextSpriteSlot).w
	
	tst.b	(Currently_transforming).w
	bne.w	End_Decrease_Time_Left	; Time left does not decrease while transforming
	tst.b	($FFFFFB4B).w
	bne.w	End_Decrease_Time_Left
	
	; Handle the math for decreasing the time left
	subq.w	#1,(Time_SubSeconds).w
	bne.w	End_Decrease_Time_Left
	move.w	#$3C,(Time_SubSeconds).w
	subq.w	#1,(Time_Seconds_low_digit).w
	bpl.s	loc_BEE8
	move.w	#9,(Time_Seconds_low_digit).w
	subq.w	#1,(Time_Seconds_high_digit).w
	bpl.s	loc_BEE8
	move.w	#5,(Time_Seconds_high_digit).w
	subq.w	#1,(Time_Minutes).w
	bpl.s	loc_BEE8
	
	; No time left
	clr.w	(Time_Seconds_low_digit).w
	clr.w	(Time_Seconds_high_digit).w
	clr.w	(Time_Minutes).w
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	#4,collision_type(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Voice_no_time,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_BEE8:
	move.w	(Time_Seconds_low_digit).w,d0
	addi.w	#$86BA,d0
	move.w	d0,$34(a0)
	move.w	(Time_Seconds_high_digit).w,d0
	addi.w	#$86BA,d0
	move.w	d0,$2C(a0)
	move.w	(Time_Minutes).w,d0
	addi.w	#$86BA,d0
	move.w	d0,$1C(a0)
	moveq	#0,d7
	bsr.w	sub_BD0A

End_Decrease_Time_Left:
	tst.w	(Time_Minutes).w
	bne.w	loc_BF2A
	cmpi.w	#2,(Time_Seconds_high_digit).w
	bgt.w	loc_BF2A
	moveq	#1,d7
	bsr.w	sub_BD0A

loc_BF2A:
	move.w	(Number_Lives).w,d0
	cmpi.w	#$64,d0
	blt.s	life_display
	moveq	#$63,d0
	move.w	d0,(Number_Lives).w

life_display:							; Lives display
	cmp.w	(Number_Lives_prev).w,d0
	beq.s	diamond_display
	swap	d0
	clr.w	d0
	swap	d0
	move.w	(Number_Lives).w,(Number_Lives_prev).w
	bsr.w	calc_display_number
	move.w	d1,$C(a0)
	swap	d1
	move.w	d1,$14(a0)

diamond_display:
	move.w	(Number_Diamonds).w,d0
	cmp.w	(Number_Diamonds_prev).w,d0
	beq.w	return_BF80
	swap	d0
	clr.w	d0
	swap	d0
	move.w	(Number_Diamonds).w,(Number_Diamonds_prev).w
	bsr.w	calc_display_number			; Create diamond number in d1
	move.w	d1,$44(a0)					; Put d1.w at $44(a0)
	swap	d1							; Flip d1
	move.w	d1,$4C(a0)					; Put d1.w at $4C(a0)

return_BF80:
	rts
; End of function Make_SpriteAttr_HUD


; =============== S U B	R O U T	I N E =======================================

; Get VRAM tile ID for a given 2-digit number
; Input: d0 - number to process
; Output: d1 - VRAM tile ID for each of the 2 digits of d0.
calc_display_number:
	move.w	#$86BA,d6			; Moves something to d6
	move.w	d6,d1				; Moves what's in d6 to d1
	swap	d1					; 
	move.w	d6,d1				; By here d1 contains $86BA86BA
	cmpi.w	#$A,d0				; Compares the number of diamonds (d0) to 10
	bge.s	split_double_digit	; If >= 10 diamonds, go to split_double_digit
	add.w	d0,d1				; Add d0 to d1
	swap	d1					; Flip d1 again
	addi.w	#$B,d1				; Add 11 to d1
	swap	d1					; Flip d1 again
	rts							; return
; ---------------------------------------------------------------------------

split_double_digit:
	divu.w	#$A,d0		; Divides d0 by 10
	add.l	d0,d1		; Adds the modulus/divided d0 to d1
	rts					; Return
; End of function calc_display_number


; =============== S U B	R O U T	I N E =======================================


Flagpole_Boss:
	move.l	#$FF0004,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,a3
	move.l	a1,($FFFFFA30).w
	move.w	(Flag_X_pos).w,x_pos(a3)
	move.w	(Flag_Y_pos).w,y_pos(a3)
	move.b	($FFFFFAD2).w,d5
	lsl.w	#4,d5
	add.w	d5,y_pos(a3)
	st	$13(a3)
	move.w	#$A0,object_meta(a3)
	move.b	#1,priority(a3)
	move.w	#(LnkTo_unk_E0FDE-Data_Index),addroffset_sprite(a3)
	move.l	a1,a4
	move.l	#$FF0004,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,a3
	move.l	a1,$3E(a4)
	move.w	(Flag_X_pos).w,x_pos(a3)
	move.w	(Flag_Y_pos).w,y_pos(a3)
	move.b	($FFFFFAD2).w,d5
	lsl.w	#4,d5
	add.w	d5,y_pos(a3)
	st	$13(a3)
	move.b	#1,priority(a3)
	move.w	#(LnkTo_unk_E0FFE-Data_Index),addroffset_sprite(a3)
	cmpi.w	#Boss1_LevelID,(Current_LevelID).w
	beq.s	loc_C03A
	cmpi.w	#Boss2_LevelID,(Current_LevelID).w
	beq.s	loc_C03A
	cmpi.w	#Boss3_LevelID,(Current_LevelID).w
	beq.s	loc_C03A
	cmpi.w	#Boss4_LevelID,(Current_LevelID).w
	bne.s	return_C046

loc_C03A:
	sf	$13(a4)
	sf	$13(a3)
	st	$3D(a4)

return_C046:
	rts
; End of function Flagpole_Boss


; =============== S U B	R O U T	I N E =======================================


Flagpole:

; FUNCTION CHUNK AT 0000D468 SIZE 0000042C BYTES

	jsr	(j_StopMusic).l
	st	($FFFFFB4B).w
	lea	(Addr_FirstObjectSlot).w,a0

loc_C056:
	_move.l	0(a0),d0
	beq.s	loc_C070
	move.l	d0,a0
	cmp.l	a5,a0
	beq.s	loc_C056
	clr.l	$36(a0)
	clr.l	$3A(a0)
	clr.l	$3E(a0)
	bra.s	loc_C056
; ---------------------------------------------------------------------------

loc_C070:
	jsr	(j_Delete_AllButCurrentObject).w
	st	($FFFFFB6A).w
	move.w	#$8200,4(a6)
	move.w	#$8407,4(a6)
	clr.w	(Level_Special_Effects).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C2F2,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_C378,4(a0)
	move.w	#$24,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	(Addr_FirstGfxObjectSlot).w,d0
	beq.s	loc_C0CC

loc_C0B6:
	move.l	d0,a3
	_move.l	0(a3),d0
	move.l	d0,-(sp)
	cmp.l	(Addr_GfxObject_Kid).w,a3
	beq.s	loc_C0C8
	jsr	(j_loc_1078).w

loc_C0C8:
	move.l	(sp)+,d0
	bne.s	loc_C0B6

loc_C0CC:
	jsr	(j_Hibernate_Object_1Frame).w
	st	($FFFFFB49).w
	st	(Background_NoScrollFlag).w
	move.w	(Time_Seconds_low_digit).w,d0
	move.w	(Time_Seconds_high_digit).w,d1
	mulu.w	#$A,d1
	add.w	d1,d0
	move.w	(Time_Minutes).w,d1
	mulu.w	#$3C,d1
	add.w	d1,d0
	neg.w	d0
	addi.w	#$B4,d0
	move.w	(Clocks_collected).w,d1
	mulu.w	#$B4,d1
	add.w	d1,d0
	cmpi.w	#$FF,d0
	ble.s	loc_C10A
	move.w	#$FF,d0

loc_C10A:
	move.b	d0,(Level_completion_time).w
	clr.w	(Time_Frames).w
	clr.b	(MurderWall_flag).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C326,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C428,4(a0)
	move.w	#$5F60,d0
	lea	ArtComp_C65A_HoloBG(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$8120,d0
	lea	ArtComp_CAB2_HoloBlocks(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A2E0,d0
	move.l	(LnkTo_unk_E06B5).l,a0 ; level finished texts
	jsr	(j_DecompressToVRAM).l
	move.w	#$42FB,d0
	lea	MapEni_CC0E(pc),a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	moveq	#$1B,d1
	lea	(Decompression_Buffer).l,a0

loc_C186:
	moveq	#$27,d0

loc_C188:
	move.w	(a0)+,(a6)
	dbf	d0,loc_C188
	moveq	#$17,d0

loc_C190:
	move.w	#0,(a6)
	dbf	d0,loc_C190
	dbf	d1,loc_C186
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_C1AA:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_C1AA
	moveq	#$E,d0
	lea	Pal_D00C(pc),a0
	lea	($FFFF4F9A).l,a1

loc_C1BC:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_C1BC
	clr.w	($FFFF4F58).l
	move.w	#$100,($FFFFF876).w
	bra.s	loc_C1DC
; ---------------------------------------------------------------------------

loc_C1D0:
	jsr	(j_Hibernate_Object_1Frame).w
	subi.w	#$10,($FFFFF876).w
	bmi.s	loc_C1EE

loc_C1DC:
	move.l	#$8000FFFF,($FFFFF888).w
	move.l	#$FFFF0000,($FFFFF88C).w
	bra.s	loc_C1D0
; ---------------------------------------------------------------------------

loc_C1EE:
	move.w	(Camera_X_pos).w,d0
	move.w	d0,d2
	addi.w	#$13F,d2
	move.w	(Camera_Y_pos).w,d1
	move.w	d1,d3
	addi.w	#$DF,d3
	lsr.w	#4,d0
	lsr.w	#4,d1
	lsr.w	#4,d2
	lsr.w	#4,d3
	sub.w	d0,d2
	move.w	d2,$44(a5)
	move.w	d2,$46(a5)
	sub.w	d1,d3
	move.w	d3,$48(a5)
	move.w	d0,$4A(a5)

loc_C21E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFF8B2).w,a0
	moveq	#$C,d7

loc_C228:
	bsr.w	sub_C254
	bmi.s	Score_Board
	tst.w	d7
	bge.s	loc_C228
	move.l	a0,($FFFFF8B2).w
	bra.s	loc_C21E
; ---------------------------------------------------------------------------

Score_Board:
	move.l	a0,($FFFFF8B2).w
	move.w	#$14,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	#bgm_Score_Board,d0
	jsr	(j_PlaySound).l
	bra.w	loc_D468
; End of function Flagpole


; =============== S U B	R O U T	I N E =======================================


sub_C254:
	move.w	d0,d2
	andi.w	#$1F,d2
	move.w	d1,d3
	andi.w	#$F,d3
	lsl.w	#8,d3
	lsl.w	#2,d2
	add.w	d2,d3
	move.w	d3,(a0)+
	lea	($FFFF4A04).l,a1
	move.w	d1,d3
	add.w	d3,d3
	move.w	(a1,d3.w),a1
	move.w	d0,d3
	add.w	d3,d3
	add.w	d3,a1
	lea	unk_C2EA(pc),a2
	move.w	(a1),d3
	bpl.s	loc_C288
	subq.w	#6,d7
	bra.s	loc_C2A4
; ---------------------------------------------------------------------------

loc_C288:
	lea	unk_C2C2(pc),a2
	btst	#$E,d3
	bne.s	loc_C296
	subq.w	#2,d7
	bra.s	loc_C2A4
; ---------------------------------------------------------------------------

loc_C296:
	andi.w	#$3000,d3
	rol.w	#7,d3
	lea	unk_C2CA(pc),a2
	add.w	d3,a2
	subq.w	#6,d7

loc_C2A4:
	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	addq.w	#1,d0
	subq.w	#1,$44(a5)
	bpl.s	return_C2C0
	move.w	$4A(a5),d0
	move.w	$46(a5),$44(a5)
	addq.w	#1,d1
	subq.w	#1,$48(a5)

return_C2C0:
	rts
; End of function sub_C254

; ---------------------------------------------------------------------------
unk_C2C2:	dc.b $44 ; D
	dc.b   9
	dc.b $44 ; D
	dc.b   9
	dc.b $44 ; D
	dc.b   9
	dc.b $44 ; D
	dc.b   9
unk_C2CA:	dc.b $44 ; D
	dc.b   9
	dc.b $44 ; D
	dc.b $11
	dc.b $44 ; D
	dc.b $12
	dc.b $44 ; D
	dc.b  $D
	dc.b $44 ; D
	dc.b  $E
	dc.b $44 ; D
	dc.b   9
	dc.b $44 ; D
	dc.b  $F
	dc.b $44 ; D
	dc.b $10
	dc.b $44 ; D
	dc.b  $A
	dc.b $44 ; D
	dc.b  $B
	dc.b $44 ; D
	dc.b  $C
	dc.b $44 ; D
	dc.b  $D
	dc.b $44 ; D
	dc.b $13
	dc.b $44 ; D
	dc.b $14
	dc.b $44 ; D
	dc.b $15
	dc.b $44 ; D
	dc.b $16
unk_C2EA:	dc.b $44 ; D
	dc.b $17
	dc.b $44 ; D
	dc.b $18
	dc.b $44 ; D
	dc.b $19
	dc.b $44 ; D
	dc.b $1A
; ---------------------------------------------------------------------------

loc_C2F2:
	moveq	#0,d0

loc_C2F4:
	move.w	#4,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$2FB,d1
	move.w	#$10E,d2
	bsr.s	sub_C346
	move.w	#$409,d1
	move.w	#$10E,d2
	bsr.s	sub_C346
	move.w	#$517,d1
	move.w	#$10E,d2
	bsr.s	sub_C346
	addq.w	#1,d0
	cmpi.w	#8,d0
	bne.s	loc_C2F4
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_C326:
	moveq	#0,d0

loc_C328:
	move.w	#4,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$625,d1
	move.w	#$48,d2
	bsr.s	sub_C346
	addq.w	#1,d0
	cmpi.w	#8,d0
	bne.s	loc_C328
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_C346:
	lsl.w	#3,d1
	add.w	d0,d1
	lsl.w	#2,d1
	subq.w	#1,d2

loc_C34E:
	move.w	d1,d3
	rol.w	#2,d3
	andi.w	#3,d3
	move.w	d1,d4
	andi.w	#$3FFF,d4
	ori.w	#$4000,d4
	swap	d4
	move.w	d3,d4
	move.l	d4,4(a6)
	move.l	#0,(a6)
	addi.w	#$20,d1
	dbf	d2,loc_C34E
	rts
; End of function sub_C346


; =============== S U B	R O U T	I N E =======================================


sub_C378:
	move.l	#vdpComm($F000,VRAM,READ),4(a6)
	lea	(Decompression_Buffer).l,a0
	move.w	#$3FF,d0

loc_C38A:
	move.l	(a6),(a0)+
	dbf	d0,loc_C38A
	moveq	#0,d0

loc_C392:
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$80,d2
	lea	(Decompression_Buffer).l,a0
	bsr.w	sub_C3DA
	move.l	#vdpComm($F000,VRAM,WRITE),4(a6)
	lea	(Decompression_Buffer).l,a0
	move.w	#$7F,d3

loc_C3BA:
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	dbf	d3,loc_C3BA
	addq.w	#1,d0
	cmpi.w	#$10,d0
	bne.s	loc_C392
	jmp	(j_Delete_CurrentObject).w
; End of function sub_C378


; =============== S U B	R O U T	I N E =======================================


sub_C3DA:
	subq.w	#1,d2
	moveq	#0,d3
	move.b	unk_C418(pc,d0.w),d3
	bsr.w	sub_C3F6
	addq.w	#4,d3
	bsr.w	sub_C3F6
	addi.w	#$1C,d3
	bsr.w	sub_C3F6
	addq.w	#4,d3
; End of function sub_C3DA


; =============== S U B	R O U T	I N E =======================================


sub_C3F6:
	movem.l	d2-d3/a0,-(sp)
	move.w	#$F0,d4
	lsr.w	#1,d3
	bcs.s	loc_C406
	move.w	#$F,d4

loc_C406:
	add.w	d3,a0

loc_C408:
	and.b	d4,(a0)
	addi.w	#$20,a0
	dbf	d2,loc_C408
	movem.l	(sp)+,d2-d3/a0
	rts
; End of function sub_C3F6

; ---------------------------------------------------------------------------
unk_C418:	dc.b   0
	dc.b $12
	dc.b   2
	dc.b $10
	dc.b   9
	dc.b $1B
	dc.b  $B
	dc.b $19
	dc.b   1
	dc.b $13
	dc.b   3
	dc.b $11
	dc.b   8
	dc.b $1A
	dc.b  $A
	dc.b $18
; ---------------------------------------------------------------------------

loc_C428:

	jsr	(j_Hibernate_Object_1Frame).w
	lea	($FFFF0006).l,a0
	moveq	#9,d0
	moveq	#0,d1

loc_C436:
	move.w	(a0),d2
	cmpi.w	#$70,d2
	ble.s	loc_C452
	cmpi.w	#$1D0,d2
	bge.s	loc_C452
	moveq	#1,d1
	cmpi.w	#$120,d2
	bge.s	loc_C450
	subq.w	#1,(a0)
	bra.s	loc_C452
; ---------------------------------------------------------------------------

loc_C450:
	addq.w	#1,(a0)

loc_C452:
	addq.w	#8,a0
	dbf	d0,loc_C436
	tst.w	d1
	bne.s	loc_C428
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_C460:
	lea	$44(a5),a4
	moveq	#6,d7

loc_C466:
	move.l	#$2000004,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,(a4)+
	st	$13(a1)
	move.b	#2,$11(a1)
	move.b	#1,$10(a1)
	move.w	#$517,$24(a1)
	dbf	d7,loc_C466

loc_C48C:
	jsr	(j_Hibernate_Object_1Frame).w
	lea	unk_C534(pc),a1
	lea	$44(a5),a4
	moveq	#0,d7
	moveq	#0,d2
	move.l	$60(a5),d6
	cmpi.l	#$98967F,d6
	ble.s	loc_C4AE
	move.l	#$98967F,d6

loc_C4AE:
	move.l	(a4)+,a0
	move.l	(a1)+,d0
	cmp.l	d0,d6
	bge.s	loc_C4CE
	cmpi.w	#6,d7
	beq.s	loc_C4C0
	tst.w	d2
	beq.s	loc_C4C8

loc_C4C0:
	move.w	#(LnkTo_unk_C86E0-Data_Index),$22(a0)
	bra.s	loc_C4E2
; ---------------------------------------------------------------------------

loc_C4C8:
	clr.w	$22(a0)
	bra.s	loc_C4E2
; ---------------------------------------------------------------------------

loc_C4CE:
	moveq	#1,d2
	moveq	#-1,d1

loc_C4D2:
	addq.w	#1,d1
	sub.l	d0,d6
	bpl.s	loc_C4D2
	add.l	d0,d6
	add.w	d1,d1
	move.w	off_C550(pc,d1.w),$22(a0)

loc_C4E2:
	move.w	d7,d0
	mulu.w	#$C,d0
	add.w	$64(a5),d0
	add.w	(Camera_X_pos).w,d0
	move.w	d0,$1A(a0)
	move.w	$68(a5),d0
	add.w	(Camera_Y_pos).w,d0
	move.w	d0,$1E(a0)
	addq.w	#1,d7
	cmpi.w	#7,d7
	bne.s	loc_C4AE
	move.w	$64(a5),d0
	add.w	$6C(a5),d0
	move.w	d0,$64(a5)
	move.w	$68(a5),d1
	add.w	$70(a5),d1
	move.w	d1,$68(a5)
	subq.w	#1,$A(a5)
	bne.w	loc_C48C
	clr.l	$6C(a5)
	clr.l	$70(a5)
	bra.w	loc_C48C
; ---------------------------------------------------------------------------
unk_C534:	dc.b   0
	dc.b  $F
	dc.b $42 ; B
	dc.b $40 ; @
	dc.b   0
	dc.b   1
	dc.b $86 ; �
	dc.b $A0 ; �
	dc.b   0
	dc.b   0
	dc.b $27 ; '
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b $E8 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $64 ; d
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
off_C550:
	dc.w LnkTo_unk_C86E0-Data_Index
	dc.w LnkTo_unk_C8680-Data_Index
	dc.w LnkTo_unk_C86D0-Data_Index
	dc.w LnkTo_unk_C86C0-Data_Index
	dc.w LnkTo_unk_C8650-Data_Index
	dc.w LnkTo_unk_C8648-Data_Index
	dc.w LnkTo_unk_C86B0-Data_Index
	dc.w LnkTo_unk_C86A8-Data_Index
	dc.w LnkTo_unk_C8638-Data_Index
	dc.w LnkTo_unk_C8668-Data_Index
; ---------------------------------------------------------------------------

loc_C564:
	move.l	#$2000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,palette_line(a3)
	move.w	#$409,vram_tile(a3)
	bra.s	loc_C592
; ---------------------------------------------------------------------------

loc_C57C:
	move.l	#$2000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#2,palette_line(a3)
	move.w	#$517,vram_tile(a3)

loc_C592:
	st	$13(a3)
	move.b	#1,priority(a3)
	move.w	$44(a5),addroffset_sprite(a3)

loc_C5A2:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	$64(a5),d0
	add.w	$6C(a5),d0
	move.w	d0,$64(a5)
	add.w	(Camera_X_pos).w,d0
	move.w	d0,x_pos(a3)
	move.w	$68(a5),d1
	add.w	$70(a5),d1
	move.w	d1,$68(a5)
	add.w	(Camera_Y_pos).w,d1
	move.w	d1,y_pos(a3)
	subq.w	#1,$46(a5)
	bne.s	loc_C5A2
	clr.w	$6C(a5)
	clr.w	$70(a5)
	bra.s	loc_C5A2
; ---------------------------------------------------------------------------

loc_C5DE:
	move.l	#$2000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#2,palette_line(a3)
	move.b	#1,priority(a3)
	move.w	#$517,vram_tile(a3)
	move.w	#(LnkTo_unk_C8640-Data_Index),addroffset_sprite(a3)
	moveq	#-$40,d0
	moveq	#0,d1
	moveq	#2,d2
	moveq	#4,d3

loc_C60C:
	jsr	(j_Hibernate_Object_1Frame).w
	add.w	d2,d0
	cmpi.w	#$FFF8,d0
	bge.s	loc_C61E
	tst.w	d2
	bpl.s	loc_C61E
	neg.w	d2

loc_C61E:
	cmpi.w	#$D0,d0
	ble.s	loc_C62A
	tst.w	d2
	bmi.s	loc_C62A
	neg.w	d2

loc_C62A:
	add.w	d3,d1
	cmpi.w	#8,d1
	bge.s	loc_C638
	tst.w	d3
	bpl.s	loc_C638
	neg.w	d3

loc_C638:
	cmpi.w	#$D8,d1
	ble.s	loc_C644
	tst.w	d3
	bmi.s	loc_C644
	neg.w	d3

loc_C644:
	move.w	d0,d4
	add.w	(Camera_X_pos).w,d4
	move.w	d4,x_pos(a3)
	move.w	d1,d4
	add.w	(Camera_Y_pos).w,d4
	move.w	d4,y_pos(a3)
	bra.s	loc_C60C
; ---------------------------------------------------------------------------
ArtComp_C65A_HoloBG:
	binclude    "scenes/artcomp/Hologram_background.bin"
ArtComp_CAB2_HoloBlocks:
	binclude    "scenes/artcomp/Hologram_blocks.bin"
	align	2
MapEni_CC0E:
	binclude    "scenes/mapeni/hologram_background.bin"
	align	2

Pal_D00C:	binclude	"scenes/palette/Score_screen.bin"
Pal_D02A:	binclude	"scenes/palette/0D02A.bin"
Pal_D048:	binclude	"scenes/palette/0D048.bin"
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Character_CheckCollision

loc_D052:

	st	($FFFFFB4B).w
	lea	(Addr_FirstObjectSlot).w,a0

loc_D05A:
	_move.l	0(a0),d0
	beq.s	loc_D074
	move.l	d0,a0
	cmp.l	a5,a0
	beq.s	loc_D05A
	clr.l	$36(a0)
	clr.l	$3A(a0)
	clr.l	$3E(a0)
	bra.s	loc_D05A
; ---------------------------------------------------------------------------

loc_D074:
	jsr	(j_Delete_AllButCurrentObject).w
	st	($FFFFFB6A).w
	move.w	#$8200,4(a6)
	move.w	#$8407,4(a6)
	clr.w	(Level_Special_Effects).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C2F2,4(a0)
	move.w	#$24,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	(Addr_FirstGfxObjectSlot).w,d0
	beq.s	loc_D0C0

loc_D0AA:
	move.l	d0,a3
	_move.l	0(a3),d0
	move.l	d0,-(sp)
	cmp.l	(Addr_GfxObject_Kid).w,a3
	beq.s	loc_D0BC
	jsr	(j_loc_1078).w

loc_D0BC:
	move.l	(sp)+,d0
	bne.s	loc_D0AA

loc_D0C0:
	jsr	(j_Hibernate_Object_1Frame).w
	st	($FFFFFB49).w
	clr.w	(Time_Frames).w
	clr.b	(MurderWall_flag).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C326,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C428,4(a0)
	move.l	(Addr_TtlCrdLetters).l,a0
	move.w	#$8120,d0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A2E0,d0
	move.l	(LnkTo_unk_E06B5).l,a0
	jsr	(j_DecompressToVRAM).l
	moveq	#$E,d0
	lea	Pal_D02A(pc),a0
	lea	(Palette_Buffer+$42).l,a1

loc_D11C:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_D11C
	moveq	#4,d0
	lea	Pal_D048(pc),a0
	lea	(Palette_Buffer+$22).l,a1

loc_D12E:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_D12E
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_D142:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_D142
	moveq	#$1F,d0
	lea	($FFFF4F58).l,a1

loc_D150:
	clr.l	(a1)+
	dbf	d0,loc_D150
	move.w	#$100,($FFFFF876).w
	bra.s	loc_D170
; ---------------------------------------------------------------------------

loc_D15E:
	jsr	(j_Hibernate_Object_1Frame).w
	subi.w	#$10,($FFFFF876).w
	cmpi.w	#$70,($FFFFF876).w
	beq.s	loc_D17E

loc_D170:
	move.w	#$FFFF,($FFFFF888).w
	move.w	#$3FF,($FFFFF88A).w
	bra.s	loc_D15E
; ---------------------------------------------------------------------------

loc_D17E:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C57C,4(a0)
	move.w	#$F2C,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$58,$64(a0)
	move.w	#$100,$68(a0)
	move.w	#$FFFE,$70(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C460,4(a0)
	move.w	#$1C,$A(a0)
	move.w	#$98,$64(a0)
	move.w	#$100,$68(a0)
	move.w	#$FFFE,$70(a0)
	move.l	(Score).w,$60(a0)
	clr.l	(Score).w
	clr.l	$44(a5)
	clr.l	$48(a5)
	tst.b	(Two_player_flag).w
	beq.w	loc_D25E
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C564,4(a0)
	move.w	#$FD0,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$FF8C,$64(a0)
	move.w	#$30,$68(a0)
	move.w	#8,$6C(a0)
	move.l	a0,$44(a5)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C564,4(a0)
	move.w	#$FD4,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$FFF2,$64(a0)
	move.w	#$36,$68(a0)
	move.w	#8,$6C(a0)
	move.l	a0,$48(a5)
	tst.b	($FFFFFC39).w
	beq.s	loc_D25E
	move.w	#$FD8,$44(a0)

loc_D25E:
	tst.w	(Number_Continues).w
	bne.w	Continue_Screen
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C57C,4(a0)
	move.w	#$F0C,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$FF98,$64(a0)
	move.w	#$60,$68(a0)
	move.w	#8,$6C(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C57C,4(a0)
	move.w	#$F10,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$158,$64(a0)
	move.w	#$80,$68(a0)
	move.w	#$FFF8,$6C(a0)
	move.w	#$3C,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$1A3,d0

loc_D2CE:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	(Ctrl_Held).w
	bmi.s	loc_D2DC
	dbf	d0,loc_D2CE

loc_D2DC:
	bra.w	loc_D3F0
; ---------------------------------------------------------------------------

Continue_Screen:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C57C,4(a0)
	move.w	#$EF8,$44(a0)
	move.w	#$1C,$46(a0)
	move.w	#$FF88,$64(a0)
	move.w	#$60,$68(a0)
	move.w	#8,$6C(a0)
	move.l	a0,$4C(a5)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C460,4(a0)
	move.w	#$1C,$A(a0)
	move.w	#$134,$64(a0)
	move.w	#$80,$68(a0)
	move.w	#$FFF8,$6C(a0)
	move.l	a0,$50(a5)
	move.w	(Number_Continues).w,$62(a0)
	move.w	#$1C,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$123,d0

loc_D350:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	(Ctrl_Held).w
	bmi.s	Use_Continue
	dbf	d0,loc_D350
	move.l	$44(a5),d0
	beq.s	loc_D372
	move.l	d0,a0
	move.w	#$1000,$46(a0)
	move.w	#1,$6C(a0)

loc_D372:
	move.l	$48(a5),d0
	beq.s	loc_D386
	move.l	d0,a0
	move.w	#$1000,$46(a0)
	move.w	#1,$6C(a0)

loc_D386:
	move.l	$4C(a5),a0
	move.w	#$1000,$46(a0)
	move.w	#1,$6C(a0)
	move.l	$50(a5),a0
	move.w	#$1000,$A(a0)
	move.w	#1,$6C(a0)
	move.w	#$EF,d0

loc_D3AA:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	(Ctrl_Held).w
	bmi.s	Use_Continue
	dbf	d0,loc_D3AA
	bra.w	loc_D3F0
; ---------------------------------------------------------------------------

Use_Continue:							; Using a Continue (it's lost afterwards
	subq.w	#1,(Number_Continues).w
	sf	(Check_Helmet_Change).w
	sf	($FFFFFC29).w
	clr.w	($FFFFFBCC).w
	move.w	#3,(Number_Lives).w
	clr.w	(Current_Helmet).w
	clr.w	($FFFFFBCC).w
	clr.w	(Number_Diamonds).w
	clr.w	(Extra_hitpoint_slots).w
	move.w	#2,(Number_Hitpoints).w
	st	($FFFFFC36).w
	bra.w	Teleport
; ---------------------------------------------------------------------------

loc_D3F0:
	clr.w	(Game_Mode).w
	st	($FFFFFBCE).w
	clr.w	($FFFFFBCC).w
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_D40A:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_D40A
	moveq	#$3F,d0
	lea	($FFFF4F58).l,a0

loc_D418:
	move.w	#0,(a0)+
	dbf	d0,loc_D418
	move.w	#$100,($FFFFF876).w
	bra.s	loc_D440
; ---------------------------------------------------------------------------

loc_D428:
	jsr	(j_WaitForVint).w
	jsr	(j_Do_Nothing).w
	jsr	(j_Palette_to_VRAM).w
	jsr	(j_sub_14C0).w
	subi.w	#$10,($FFFFF876).w
	bmi.s	loc_D44C

loc_D440:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_D428
; ---------------------------------------------------------------------------

loc_D44C:
	jsr	(j_WaitForVint).w
	jsr	(j_Do_Nothing).w
	jsr	(j_Palette_to_VRAM).w
	jsr	(j_sub_14C0).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w
	bra.w	Teleport
; END OF FUNCTION CHUNK	FOR Character_CheckCollision
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR Flagpole

loc_D468:
	tst.b	(LevelSkip_Cheat).w
	beq.s	loc_D4CE
	moveq	#2,d6
	move.w	#$11C,d2
	add.w	(Camera_X_pos).w,d2
	moveq	#0,d3
	move.b	(Level_completion_time).w,d3

loc_D47E:
	move.l	#$2000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.b	#1,$10(a1)
	move.w	#$517,$24(a1)
	move.w	#$D4,d0
	add.w	(Camera_Y_pos).w,d0
	move.w	d0,$1E(a1)
	move.w	d2,$1A(a1)
	subi.w	#$C,d2
	divu.w	#$A,d3
	swap	d3
	move.w	d3,d0
	clr.w	d3
	swap	d3
	add.w	d0,d0
	lea	off_C550(pc),a0
	move.w	(a0,d0.w),$22(a1)
	dbf	d6,loc_D47E

loc_D4CE:
	lea	$44(a5),a2
	moveq	#0,d3
	move.w	#$CC,d7
	moveq	#0,d6
	moveq	#$1C,d5
	move.w	#$EF8,d0
	move.w	#$FF48,d1
	bsr.w	sub_D894
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C460,4(a0)
	move.w	d5,$A(a0)
	move.w	#$FF84,d1
	sub.w	d6,d1
	move.w	d1,$64(a0)
	move.w	d7,$68(a0)
	move.w	#8,$6C(a0)
	moveq	#0,d0
	move.w	(Number_Continues).w,d0
	move.l	d0,$60(a0)
	move.l	a0,(a2)+
	move.w	#$B4,d7
	moveq	#0,d6
	moveq	#$1C,d5
	move.w	#$F2C,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	(Score).w,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5
	move.w	(Time_Seconds_low_digit).w,d0
	move.w	(Time_Seconds_high_digit).w,d1
	mulu.w	#$A,d1
	add.w	d1,d0
	move.w	(Time_Minutes).w,d1
	mulu.w	#$64,d1
	add.w	d1,d0
	mulu.w	#$A,d0
	move.l	d0,-(sp)
	move.w	#$F44,d0
	move.w	#$FF60,d1
	bsr.w	sub_D894
	move.w	#$EF4,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	(sp)+,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	addq.w	#1,d3
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5
	tst.b	(NoHit_Bonus_Flag).w
	bne.w	loc_D5D2
	move.w	#$F18,d0
	move.w	#$FF38,d1
	bsr.w	sub_D894
	move.w	#$EF4,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	#$1388,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	addq.w	#1,d3
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5

loc_D5D2:
	tst.b	(NoPrize_Bonus_Flag).w
	bne.w	loc_D60E
	move.w	#$F1C,d0
	move.w	#$FF20,d1
	bsr.w	sub_D894
	move.w	#$EF4,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	#$1388,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	addq.w	#1,d3
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5

loc_D60E:
	move.w	(Current_LevelID).w,d0
	cmpi.w	#$49,d0
	bge.w	loc_D660
	lea	unk_D8E8(pc),a1
	move.b	(a1,d0.w),d0
	andi.w	#$FF,d0
	mulu.w	#$3E8,d0
	beq.w	loc_D660
	move.l	d0,-(sp)
	move.w	#$F24,d0
	move.w	#$FF58,d1
	bsr.w	sub_D894
	move.w	#$EF4,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	(sp)+,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	addq.w	#1,d3
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5

loc_D660:
	move.w	(Current_LevelID).w,d0
	cmpi.w	#$49,d0
	bge.w	loc_D702
	lea	unk_D934(pc),a1
	move.b	(Level_completion_time).w,d1
	cmp.b	(a1,d0.w),d1
	bhi.w	loc_D702
	move.b	(a1,d0.w),d0
	andi.l	#$FF,d0
	move.l	d0,-(sp)
	move.w	#$F3C,d0
	move.w	#$FF50,d1
	bsr.w	sub_D894
	move.w	#$EF4,d0
	move.w	#$FF98,d1
	bsr.w	sub_D894
	move.l	#$2710,d0
	move.w	#$1B0,d1
	bsr.w	sub_D8BE
	move.l	a0,(a2)+
	addq.w	#1,d3
	subi.w	#$18,d7
	addi.w	#$40,d6
	addq.w	#8,d5
	move.w	#$F4C,d0
	move.w	#$FF50,d1
	bsr.w	sub_D894
	move.w	#$F30,d0
	move.w	#$FFB4,d1
	bsr.w	sub_D894
	move.l	(sp)+,d0
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C460,4(a0)
	move.w	d5,$A(a0)
	move.w	#$FF5C,d1
	sub.w	d6,d1
	move.w	d1,$64(a0)
	move.w	d7,$68(a0)
	move.w	#8,$6C(a0)
	move.l	d0,$60(a0)

loc_D702:
	move.w	#$5A,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_D718:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_D718
	moveq	#$3F,d0
	lea	($FFFF4F58).l,a0

loc_D726:
	move.w	#0,(a0)+
	dbf	d0,loc_D726
	move.w	#$100,($FFFFF876).w

loc_D734:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#$7C7F,($FFFFF88C).w
	subi.w	#$10,($FFFFF876).w
	cmpi.w	#$80,($FFFFF876).w
	bne.s	loc_D734
	move.w	#$14,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#$3C,d0
	lea	$48(a5),a2
	move.l	(a2)+,a3
	move.l	(a2)+,a1
	move.w	#$78,d1
	moveq	#$28,d2
	move.l	d0,-(sp)
	moveq	#sfx_Socre_counter,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_D770:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	$60(a1),d4
	cmp.l	d2,d4
	blt.s	loc_D77E
	move.l	d2,d4

loc_D77E:
	move.l	(Score).w,d5
	add.l	d4,(Score).w
	move.l	d5,d6
	add.l	d4,d6
	cmpi.l	#$98967F,(Score).w ; Score 99.999.99
	blt.s	loc_D79E
	move.l	#$98967F,d6 ; Score 99.999.99
	move.l	d6,(Score).w

loc_D79E:
	divu.w	#$C350,d5 ; Score 50.000
	divu.w	#$C350,d6 ; Score 50.000
	cmp.w	d5,d6
	beq.s	loc_D7CE
	addq.w	#1,(Number_Lives).w
	move.l	d0,-(sp)
	moveq	#sfx_Ankh_prize,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C5DE,4(a0)
	move.w	#$F0,d0

loc_D7CE:
	move.l	(Score).w,$60(a3)
	sub.l	d2,$60(a1)
	bgt.s	loc_D7E4
	clr.l	$60(a1)
	subq.w	#1,d3
	beq.s	loc_D7F4
	move.l	(a2)+,a1

loc_D7E4:
	subq.w	#1,d1
	bne.s	loc_D770
	move.w	#$78,d1
	add.l	d2,d2
	add.l	d2,d2
	bra.w	loc_D770
; ---------------------------------------------------------------------------

loc_D7F4:
	move.l	d0,-(sp)
	moveq	#sfx_Socre_counter,d0
	jsr	(j_PlaySound2).l
	move.l	(sp)+,d0
	move.w	d0,-(sp)
	jsr	(j_Hibernate_Object).w
	cmpi.w	#Final_LevelID,(Current_LevelID).w
	beq.w	End_Credits
	addq.w	#1,(Current_LevelID).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w
	bra.w	Teleport
; ---------------------------------------------------------------------------

End_Credits:
	jsr	(j_StopMusic).l
	move.w	#$28,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#bgm_Ending,d0
	jsr	(j_PlaySound).l
	move.w	#$C8,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#$1F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1

loc_D84E:
	move.l	(a0)+,(a1)+
	dbf	d0,loc_D84E
	moveq	#$3F,d0
	moveq	#0,d1
	lea	($FFFF4F58).l,a0

loc_D85E:
	move.w	d1,(a0)+
	dbf	d0,loc_D85E
	move.w	#$100,($FFFFF876).w
	bra.s	loc_D876
; ---------------------------------------------------------------------------

loc_D86C:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,($FFFFF876).w
	bmi.s	loc_D882

loc_D876:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_D86C
; ---------------------------------------------------------------------------

loc_D882:
	st	($FFFFFBCE).w
	clr.w	($FFFFFBCC).w
	move.w	#$30,(Game_Mode).w
	jmp	(j_loc_6E2).w
; END OF FUNCTION CHUNK	FOR Flagpole

; =============== S U B	R O U T	I N E =======================================


sub_D894:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C57C,4(a0)
	move.w	d0,$44(a0)
	move.w	d5,$46(a0)
	sub.w	d6,d1
	move.w	d1,$64(a0)
	move.w	d7,$68(a0)
	move.w	#8,$6C(a0)
	rts
; End of function sub_D894


; =============== S U B	R O U T	I N E =======================================


sub_D8BE:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C460,4(a0)
	move.w	d5,$A(a0)
	add.w	d6,d1
	move.w	d1,$64(a0)
	move.w	d7,$68(a0)
	move.w	#$FFF8,$6C(a0)
	move.l	d0,$60(a0)
	rts
; End of function sub_D8BE

; ---------------------------------------------------------------------------
unk_D8E8:	include	"level/pathbonus.asm"
	align	2
unk_D934:	include	"level/speedbonus.asm"
	align	2
; ---------------------------------------------------------------------------

loc_D980:
	lea	(Addr_FirstObjectSlot).w,a0

loc_D984:
	_move.l	0(a0),d0
	beq.s	loc_D99E
	move.l	d0,a0
	cmp.l	a5,a0
	beq.s	loc_D984
	clr.l	$36(a0)
	clr.l	$3A(a0)
	clr.l	$3E(a0)
	bra.s	loc_D984
; ---------------------------------------------------------------------------

loc_D99E:
	jsr	(j_Delete_AllButCurrentObject).w
	st	($FFFFFB6A).w
	move.w	#$8200,4(a6)
	move.w	#$8407,4(a6)
	clr.w	(Level_Special_Effects).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_C2F2,4(a0)
	move.w	#$24,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	(Addr_FirstGfxObjectSlot).w,d0
	beq.s	loc_D9EA

loc_D9D4:
	move.l	d0,a3
	_move.l	0(a3),d0
	move.l	d0,-(sp)
	cmp.l	(Addr_GfxObject_Kid).w,a3
	beq.s	loc_D9E6
	jsr	(j_loc_1078).w

loc_D9E6:
	move.l	(sp)+,d0
	bne.s	loc_D9D4

loc_D9EA:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_C378,4(a0)
	st	($FFFFFB49).w
	moveq	#$3F,d0
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1
	lea	($FFFF4F58).l,a2

loc_DA16:
	move.w	(a0)+,d1
	move.w	d1,(a1)+
	subi.w	#$888,d1
	move.w	d1,(a2)+
	dbf	d0,loc_DA16
	move.w	#$100,($FFFFF876).w
	move.w	#$12C,d0
	bra.s	loc_DA3E
; ---------------------------------------------------------------------------

loc_DA30:
	jsr	(j_Hibernate_Object_1Frame).w
	subi.w	#$11,($FFFFF876).w
	subq.w	#1,d0
	beq.s	loc_DA4A

loc_DA3E:
	moveq	#-1,d1
	move.l	d1,($FFFFF888).w
	move.l	d1,($FFFFF88C).w
	bra.s	loc_DA30
; ---------------------------------------------------------------------------

loc_DA4A:
	move.l	#$F4241,(Score).w
	clr.w	($FFFFFBCC).w
	st	($FFFFFC36).w
	move.w	#$20,(PlayerStart_X_pos).w
	move.w	#$48F,(PlayerStart_Y_pos).w
	move.w	#HundredKTripDest_LevelID,(Current_LevelID).w
	clr.w	(Current_Helmet).w
	st	($FFFFFC29).w
	bra.w	Teleport
; ---------------------------------------------------------------------------
	moveq	#0,d0

loc_DA7A:
	move.w	#4,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$BC,d1
	move.w	#$644,d2
	bsr.w	sub_C346
	move.w	#$780,d1
	move.w	#$80,d2
	bsr.w	sub_C346
	addq.w	#1,d0
	cmpi.w	#8,d0
	bne.s	loc_DA7A
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_DAA6:
	movem.l	d0-d3/a0-a2,-(sp)
	lea	(Addr_FirstPlatformSlot).w,a2
	move.w	(Current_Helmet).w,d6
	add.w	d6,d6
	lea	unk_B408(pc),a0
	add.w	d6,a0
	moveq	#0,d7
	move.b	(a0),d7
	moveq	#$F,d5
	move.w	(Current_Helmet).w,d6
	cmpi.w	#9,d6
	beq.w	loc_DAD6
	cmpi.w	#5,d6
	beq.w	loc_DAD6
	moveq	#$1F,d5

loc_DAD6:
	move.w	y_pos(a3),d3
	move.w	d3,d2
	sub.w	d5,d2
	move.w	x_pos(a3),d0
	move.w	d0,d1
	sub.w	d7,d0
	add.w	d7,d1

loc_DAE8:
	_move.w	0(a2),d4
	beq.w	loc_DB1A
	move.w	d4,a2
	move.w	2(a2),d4
	cmp.w	d1,d4
	bgt.s	loc_DAE8
	add.w	$1A(a2),d4
	cmp.w	d0,d4
	blt.s	loc_DAE8
	move.w	6(a2),d4
	cmp.w	d3,d4
	bgt.s	loc_DAE8
	add.w	$1C(a2),d4
	cmp.w	d2,d4
	blt.s	loc_DAE8
	movem.l	(sp)+,d0-d3/a0-a2
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_DB1A:
	movem.l	(sp)+,d0-d3/a0-a2
	moveq	#0,d7
	rts
; End of function sub_DAA6


; =============== S U B	R O U T	I N E =======================================


sub_DB22:
	sf	(Cyclone_flying).w
	sf	($FFFFFA6A).w
	sf	($FFFFFA69).w
	sf	(Red_Stealth_sword_swing).w
	sf	(Maniaxe_throwing_axe).w
	sf	($FFFFFA66).w
	sf	($FFFFFA67).w
	sf	(Berzerker_charging).w
	sf	has_level_collision(a3)
	sf	is_animated(a3)
	sf	(Iron_Knight_block_breaker).w
	rts
; End of function sub_DB22

; ---------------------------------------------------------------------------
	dc.b   0
	dc.b   0

; filler
    rept 896
	dc.b	$FF
    endm

; ---------------------------------------------------------------------------
j_sub_F7E0:	;sub_DED2
	jmp	sub_F730(pc)
; ---------------------------------------------------------------------------
j_sub_F096:	;sub_DED6
	jmp	sub_F096(pc)
; ---------------------------------------------------------------------------
j_sub_F06A:	;sub_DEDA
	jmp	sub_F06A(pc)
; ---------------------------------------------------------------------------
j_sub_DFB0:	;sub_DEDE
	jmp	sub_DFB0(pc)
; ---------------------------------------------------------------------------
j_loc_DF22: ;DEE2
	jmp	loc_DF22(pc)
; ---------------------------------------------------------------------------
	jmp	sub_DF68(pc)
; ---------------------------------------------------------------------------
j_sub_FACE: ;DEEA
	jmp	sub_FACE(pc)
; ---------------------------------------------------------------------------
j_sub_10E86: ;DEEE
	jmp	sub_10E86(pc)
; ---------------------------------------------------------------------------
	jmp	return_FAFC(pc)
; ---------------------------------------------------------------------------
j_sub_10F44: ;DEF6
	jmp	sub_10F44(pc)
; ---------------------------------------------------------------------------
j_loc_1002E: ;DEFA
	jmp	loc_1002E(pc)
; ---------------------------------------------------------------------------
j_loc_11430: ;DEFE
	jmp	loc_11430(pc)
; ---------------------------------------------------------------------------
j_loc_110D0: ;DF02
	jmp	loc_110D0(pc)
; ---------------------------------------------------------------------------
j_loc_111F4: ;DF06
	jmp	loc_111F4(pc)
; ---------------------------------------------------------------------------
j_loc_11364: ;DF0A
	jmp	loc_11364(pc)
; ---------------------------------------------------------------------------
j_loc_10DA4: ;DF0E
	jmp	loc_10DA4(pc)
; ---------------------------------------------------------------------------
j_return_1142E: ;DF12
	jmp	return_1142E(pc)
; ---------------------------------------------------------------------------
j_loc_FAFE: ;DF16
	jmp	loc_FAFE(pc)
; ---------------------------------------------------------------------------
	jmp	loc_FAE2(pc)
; ---------------------------------------------------------------------------
	jmp	return_10DA2(pc)
; ---------------------------------------------------------------------------

loc_DF22:
	bsr.w	sub_EABC
	lea	($FFFFE90A).w,a0
	move.w	a0,($FFFFF8C8).w
	moveq	#$12,d0

loc_DF30:
	lea	$C(a0),a1
	move.w	a1,$A(a0)
	move.l	a1,a0
	dbf	d0,loc_DF30
	clr.w	$A(a0)
	clr.w	($FFFFF8C6).w
	lea	($FFFFE9FA).w,a0
	move.w	a0,($FFFFF8CC).w
	moveq	#$26,d0

loc_DF50:
	lea	$C(a0),a1
	move.w	a1,$A(a0)
	move.l	a1,a0
	dbf	d0,loc_DF50
	clr.w	$A(a0)
	clr.w	($FFFFF8CA).w
	rts
; End of function j_loc_DF22


; =============== S U B	R O U T	I N E =======================================


sub_DF68:

	move.l	d0,-(sp)
	moveq	#sfx_Evanescent_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	swap	d1
	move.w	($FFFFF8C8).w,d1
	beq.s	return_DFAE
	move.w	d1,a3
	move.w	$A(a3),($FFFFF8C8).w
	move.w	($FFFFF8C6).w,$A(a3)
	move.w	a3,($FFFFF8C6).w
	swap	d1
	move.w	d3,(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	exg	d1,a3
	move.w	d3,a3
	move.w	(a3),d3
	move.b	#$E3,(a3)
	exg	d1,a3
	andi.w	#$FF,d3
	subi.w	#$1C,d3
	move.w	d3,(a3)+
	clr.w	(a3)+

return_DFAE:
	rts
; End of function sub_DF68


; =============== S U B	R O U T	I N E =======================================


sub_DFB0:
	bsr.w	sub_E49A
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	y_pos(a3),d6
	move.w	($FFFFFAB6).w,d7
	move.w	d6,($FFFFFAB6).w
	cmpi.w	#MoveID_Jump,(Character_Movement).w
	bne.w	loc_EAE4
	move.w	(Current_Helmet).w,d0
	lea	unk_E246(pc),a5
	add.w	d0,d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	lea	(a5,d0.w),a5
	move.w	(a5)+,d0
	move.w	(a5)+,d1
	tst.b	x_direction(a3)
	beq.s	loc_DFEE
	exg	d0,d1

loc_DFEE:
	neg.w	d0
	add.w	x_pos(a3),d0
	add.w	x_pos(a3),d1
	subq.w	#1,d1
	asr.w	#4,d0
	bpl.s	loc_E000
	moveq	#0,d0

loc_E000:
	asr.w	#4,d1
	cmp.w	(Level_width_blocks).w,d1
	ble.s	loc_E00E
	move.w	(Level_width_blocks).w,d1
	subq.w	#1,d1

loc_E00E:
	sub.w	d0,d1
	sub.w	(a5),d6
	bmi.w	loc_EAE4
	subq.w	#1,d6
	sub.w	(a5),d7
	subq.w	#1,d7
	asr.w	#4,d6
	asr.w	#4,d7
	cmp.w	d7,d6
	bge.w	loc_EAE4
	lea	($FFFF4A04).l,a2
	move.w	d6,d2
	add.w	d2,d2
	move.w	(a2,d2.w),a2
	move.w	d0,d2
	add.w	d2,d2
	add.w	d2,a2

loc_E03A:
	move.w	(a2),d2
	andi.w	#$7000,d2
	cmpi.w	#$2000,d2
	bne.w	loc_E23A
	bsr.w	sub_E37A
	bsr.w	sub_E3C6
	move.l	d0,-(sp)
	moveq	#sfx_Reveal_Hidden_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	moveq	#0,d4
	move.b	6(a4),d4
	cmpi.w	#1,d4
	beq.s	loc_E07A
	cmpi.w	#$A,d4
	beq.w	loc_E0C2
	cmpi.w	#4,d4
	beq.w	loc_E19E
	bra.s	loc_E096
; ---------------------------------------------------------------------------

loc_E07A:
	move.l	($FFFFF8D4).w,a0
	move.w	a2,d4
	subq.w	#8,a0

loc_E082:
	addq.w	#8,a0
	cmp.w	(a0),d4
	bne.s	loc_E082
	tst.w	6(a0)
	bpl.s	loc_E096
	move.w	#$E101,d2
	move.w	#$1058,d3

loc_E096:
	move.b	#$60,(a2)
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_E29A,4(a0)
	move.w	d0,$44(a0)
	move.w	d6,$46(a0)
	move.l	a2,$48(a0)
	move.w	d2,$4C(a0)
	move.w	d3,$4E(a0)
	bra.w	loc_E1FE
; ---------------------------------------------------------------------------

loc_E0C2:
	move.b	#$60,(a2)
	moveq	#0,d4
	move.b	7(a4),d4
	lsl.w	#3,d4
	lea	unk_E11E(pc),a4
	add.l	d4,a4
	bsr.s	sub_E0F8
	bsr.s	sub_E0F8
	move.w	#8,$50(a0)
	bsr.s	sub_E0F8
	move.w	#8,$52(a0)
	bsr.s	sub_E0F8
	move.w	#8,$50(a0)
	move.w	#8,$52(a0)
	bra.w	loc_E1FE
; End of function sub_DFB0


; =============== S U B	R O U T	I N E =======================================


sub_E0F8:
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_E304,4(a0)
	move.w	d0,$44(a0)
	move.w	d6,$46(a0)
	move.l	a2,$48(a0)
	move.w	d2,$4C(a0)
	move.w	(a4)+,$4E(a0)
	rts
; End of function sub_E0F8

; ---------------------------------------------------------------------------
unk_E11E:	dc.b $10
	dc.b $E4 ; �
	dc.b $10
	dc.b $F4 ; �
	dc.b $11
	dc.b   4
	dc.b $11
	dc.b $14
	dc.b $10
	dc.b $EC ; �
	dc.b $10
	dc.b $FC ; �
	dc.b $11
	dc.b   4
	dc.b $11
	dc.b $14
	dc.b $10
	dc.b $E4 ; �
	dc.b $10
	dc.b $F8 ; �
	dc.b $11
	dc.b   4
	dc.b $11
	dc.b $18
	dc.b $10
	dc.b $EC ; �
	dc.b $11
	dc.b   0
	dc.b $11
	dc.b   4
	dc.b $11
	dc.b $18
	dc.b $10
	dc.b $E4 ; �
	dc.b $10
	dc.b $F4 ; �
	dc.b $11
	dc.b  $C
	dc.b $11
	dc.b $1C
	dc.b $10
	dc.b $EC ; �
	dc.b $10
	dc.b $FC ; �
	dc.b $11
	dc.b  $C
	dc.b $11
	dc.b $1C
	dc.b $10
	dc.b $E4 ; �
	dc.b $10
	dc.b $F8 ; �
	dc.b $11
	dc.b  $C
	dc.b $11
	dc.b $20
	dc.b $10
	dc.b $EC ; �
	dc.b $11
	dc.b   0
	dc.b $11
	dc.b  $C
	dc.b $11
	dc.b $20
	dc.b $10
	dc.b $E8 ; �
	dc.b $10
	dc.b $F4 ; �
	dc.b $11
	dc.b   8
	dc.b $11
	dc.b $14
	dc.b $10
	dc.b $F0 ; �
	dc.b $10
	dc.b $FC ; �
	dc.b $11
	dc.b   8
	dc.b $11
	dc.b $14
	dc.b $10
	dc.b $E8 ; �
	dc.b $10
	dc.b $F8 ; �
	dc.b $11
	dc.b   8
	dc.b $11
	dc.b $18
	dc.b $10
	dc.b $F0 ; �
	dc.b $11
	dc.b   0
	dc.b $11
	dc.b   8
	dc.b $11
	dc.b $18
	dc.b $10
	dc.b $E8 ; �
	dc.b $10
	dc.b $F4 ; �
	dc.b $11
	dc.b $10
	dc.b $11
	dc.b $1C
	dc.b $10
	dc.b $F0 ; �
	dc.b $10
	dc.b $FC ; �
	dc.b $11
	dc.b $10
	dc.b $11
	dc.b $1C
	dc.b $10
	dc.b $E8 ; �
	dc.b $10
	dc.b $F8 ; �
	dc.b $11
	dc.b $10
	dc.b $11
	dc.b $20
	dc.b $10
	dc.b $F0 ; �
	dc.b $11
	dc.b   0
	dc.b $11
	dc.b $10
	dc.b $11
	dc.b $20
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_E19E:
	tst.b	7(a4)
	beq.s	loc_E1BC
	subq.w	#2,a2
	subq.w	#1,d2
	subq.w	#1,d0
	bsr.s	sub_E1D4
	addq.w	#2,a2
	addq.w	#1,d2
	addq.w	#1,d0
	bsr.s	sub_E1D4
	move.w	#1,$50(a0)
	bra.s	loc_E1FE
; ---------------------------------------------------------------------------

loc_E1BC:
	bsr.s	sub_E1D4
	addq.w	#2,a2
	addq.w	#1,d2
	addq.w	#1,d0
	bsr.s	sub_E1D4
	move.w	#1,$50(a0)
	subq.w	#2,a2
	subq.w	#1,d2
	subq.w	#1,d0
	bra.s	loc_E1FE
; END OF FUNCTION CHUNK	FOR sub_DFB0

; =============== S U B	R O U T	I N E =======================================


sub_E1D4:
	move.b	#$60,(a2)
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_E282,4(a0)
	move.w	d0,$44(a0)
	move.w	d6,$46(a0)
	move.l	a2,$48(a0)
	move.w	d2,$4C(a0)
	move.w	d3,$4E(a0)
	rts
; End of function sub_E1D4

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_E1FE:
	clr.l	y_vel(a3)
	moveq	#0,d2
	move.w	d6,d2
	addq.w	#1,d2
	lsl.w	#4,d2
	add.w	(a5),d2
	clr.w	$20(a3)
	subq.w	#1,d2
	move.w	d2,(Kid_hitbox_bottom).w
	move.w	d2,y_pos(a3)
	subi.w	#$F,d2
	move.w	(Current_Helmet).w,d3
	cmpi.w	#9,d3
	beq.w	loc_E236
	cmpi.w	#5,d3
	beq.w	loc_E236
	subi.w	#$10,d2

loc_E236:
	move.w	d2,(Kid_hitbox_top).w

loc_E23A:
	addq.w	#1,d0
	addq.w	#2,a2
	dbf	d1,loc_E03A
	bra.w	loc_EAE4
; END OF FUNCTION CHUNK	FOR sub_DFB0
; ---------------------------------------------------------------------------
unk_E246:	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b $10
; ---------------------------------------------------------------------------

loc_E282:
	move.l	#$FF0004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$36(a5),a3
	tst.w	$50(a5)
	sne	x_direction(a3)
	bra.s	loc_E2A8
; ---------------------------------------------------------------------------

loc_E29A:
	move.l	#$FF0004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$36(a5),a3

loc_E2A8:
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	$4C(a5),d0
	move.w	$4E(a5),addroffset_sprite(a3)
	move.w	d1,d4
	tst.b	x_direction(a3)
	beq.s	loc_E2D2
	addq.w	#1,d4

loc_E2D2:
	lsl.w	#4,d4
	move.w	d4,x_pos(a3)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,y_pos(a3)
	moveq	#3,d3

loc_E2E2:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d3,loc_E2E2
	moveq	#3,d3

loc_E2F0:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d3,loc_E2F0
	bsr.w	sub_11530
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_E304:
	move.l	#$FF0004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	$4C(a5),d0
	move.w	$4E(a5),addroffset_sprite(a3)
	move.w	d1,d4
	lsl.w	#4,d4
	add.w	$50(a5),d4
	move.w	d4,x_pos(a3)
	move.w	d2,d4
	lsl.w	#4,d4
	add.w	$52(a5),d4
	move.w	d4,y_pos(a3)
	moveq	#3,d3

loc_E34C:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d3,loc_E34C
	moveq	#3,d3

loc_E35A:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d3,loc_E35A
	tst.w	$50(a5)
	bne.s	loc_E376
	tst.w	$52(a5)
	bne.s	loc_E376
	bsr.w	sub_11530

loc_E376:
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_E37A:
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	($FFFFF8EA).w,d0
	subq.w	#1,d0
	moveq	#8,d1

loc_E386:
	lsr.w	#1,d0
	beq.s	loc_E38E
	add.w	d1,d1
	bra.s	loc_E386
; ---------------------------------------------------------------------------

loc_E38E:
	move.l	($FFFFF8EC).w,a0
	move.w	($FFFFF8EA).w,d0
	lsl.w	#3,d0
	lea	(a0,d0.w),a1
	move.w	a2,d0
	move.l	a0,a4

loc_E3A0:
	cmp.w	(a4),d0
	beq.s	loc_E3C0
	bgt.s	loc_E3B2
	suba.l	d1,a4
	lsr.w	#1,d1
	cmp.l	a0,a4
	bge.s	loc_E3A0
	move.l	a0,a4
	bra.s	loc_E3A0
; ---------------------------------------------------------------------------

loc_E3B2:
	add.l	d1,a4
	lsr.w	#1,d1
	cmp.l	a1,a4
	blt.s	loc_E3A0
	move.l	a1,a4
	subq.w	#8,a4
	bra.s	loc_E3A0
; ---------------------------------------------------------------------------

loc_E3C0:
	movem.l	(sp)+,d0-d1/a0-a1
	rts
; End of function sub_E37A


; =============== S U B	R O U T	I N E =======================================


sub_E3C6:
	moveq	#0,d3
	move.b	6(a4),d3
	cmpi.b	#1,d3
	beq.s	loc_E3E4
	add.w	d3,d3
	add.w	d3,d3
	move.w	unk_E412(pc,d3.w),d2
	add.b	7(a4),d2
	move.w	unk_E414(pc,d3.w),d3
	rts
; ---------------------------------------------------------------------------

loc_E3E4:
	move.l	a0,-(sp)
	move.l	($FFFFF8D4).w,a0
	move.w	(a4),d3
	subq.w	#8,a0

loc_E3EE:
	addq.w	#8,a0
	cmp.w	(a0),d3
	bne.s	loc_E3EE
	move.w	#$E102,d2
	move.w	#$1060,d3
	tst.w	6(a0)
	bpl.s	loc_E40A
	move.w	#$E101,d2
	move.w	#$1058,d3

loc_E40A:
	add.b	7(a4),d2
	move.l	(sp)+,a0
	rts
; End of function sub_E3C6

; ---------------------------------------------------------------------------
unk_E412:	dc.b $E0 ; �
	dc.b   1
unk_E414:	dc.b $10
	dc.b $58 ; X
	dc.b $E1 ; �
	dc.b   2
	dc.b $10
	dc.b $60 ; `
	dc.b $E2 ; �
	dc.b   3
	dc.b $10
	dc.b $74 ; t
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E4 ; �
	dc.b   7
	dc.b $10
	dc.b $7C ; |
	dc.b $E5 ; �
	dc.b  $B
	dc.b $10
	dc.b $84 ; �
	dc.b $E6 ; �
	dc.b  $C
	dc.b $10
	dc.b $98 ; �
	dc.b $E7 ; �
	dc.b $10
	dc.b $10
	dc.b $9C ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E9 ; �
	dc.b $19
	dc.b $10
	dc.b $A0 ; �
	dc.b $EA ; �
	dc.b $1C
	dc.b $10
	dc.b $E4 ; �
	dc.b $EB ; �
	dc.b $2C ; ,
	dc.b $10
	dc.b $A4 ; �
	dc.b $EC ; �
	dc.b $2D ; -
	dc.b $10
	dc.b $84 ; �

; =============== S U B	R O U T	I N E =======================================


sub_E446:
	move.w	(a2),d0
	andi.w	#$7000,d0
	cmpi.w	#$2000,d0
	bne.s	loc_E48E
	bsr.w	sub_E37A
	bsr.w	sub_E3C6
	move.w	($FFFFF8D0).w,d0
	beq.s	loc_E48E
	move.w	d0,a0
	move.w	$A(a0),($FFFFF8D0).w
	move.w	($FFFFF8CE).w,$A(a0)
	move.w	a0,($FFFFF8CE).w
	move.w	a2,(a0)+
	move.w	d1,(a0)+
	move.w	d5,(a0)+
	move.w	d2,(a0)+
	move.w	#$12C,(a0)+
	move.l	($FFFFF8B6).w,a0
	move.w	d2,(a2)
	move.w	d1,(a0)+
	move.w	d5,(a0)+
	move.w	d2,(a0)+
	move.l	a0,($FFFFF8B6).w

loc_E48E:
	addq.w	#1,d5
	add.w	(Level_width_tiles).w,a2
	dbf	d6,sub_E446
	rts
; End of function sub_E446


; =============== S U B	R O U T	I N E =======================================


sub_E49A:
	move.w	($FFFFFAB8).w,d7
	beq.w	loc_E99C
	cmpi.w	#Eyeclops,(Current_Helmet).w
	beq.s	loc_E4B2
	clr.w	($FFFFFAB8).w
	bra.w	loc_E99C
; ---------------------------------------------------------------------------

loc_E4B2:
	subq.w	#1,d7
	move.l	(Addr_GfxObject_Kid).w,a0
	moveq	#$12,d0
	moveq	#-$F,d1
	tst.b	($FFFFFABE).w
	beq.s	loc_E4C4
	neg.w	d0

loc_E4C4:
	add.w	$1A(a0),d0
	sub.w	(Camera_X_pos).w,d0
	addi.w	#$80,d0
	add.w	$1E(a0),d1
	sub.w	(Camera_Y_pos).w,d1
	addi.w	#$80,d1
	move.l	(Addr_NextSpriteSlot).w,a2
	moveq	#0,d2
	move.b	(Number_Sprites).w,d2
	tst.w	d7
	bmi.w	loc_E7AC
	cmpi.w	#4,d7
	bge.w	loc_E650
	move.w	d7,d5
	lsl.w	#3,d5
	addi.w	#$10,d5
	move.w	d0,a1
	tst.b	($FFFFFABE).w
	bne.s	loc_E50A
	add.w	d5,a1
	moveq	#0,d4
	bra.s	loc_E512
; ---------------------------------------------------------------------------

loc_E50A:
	move.w	d0,a1
	suba.w	d5,a1
	move.w	#$800,d4

loc_E512:
	move.w	d7,d5
	lsl.w	#2,d5
	move.l	off_E560(pc,d5.w),a0

loc_E51A:
	move.w	(a0)+,d5
	cmpi.w	#$8000,d5
	beq.s	loc_E554
	add.w	d1,d5
	move.w	d5,(a2)+
	move.w	(a0)+,d5
	move.w	d5,d6
	lsr.w	#7,d6
	andi.w	#$18,d6
	addq.w	#8,d6
	addq.b	#1,d2
	move.b	d2,d5
	move.w	d5,(a2)+
	move.w	(a0)+,d5
	or.w	d4,d5
	move.w	d5,(a2)+
	move.w	d0,d5
	tst.w	($FFFFFABE).w
	beq.s	loc_E54E
	sub.w	(a0)+,d5
	sub.w	d6,d5
	move.w	d5,(a2)+
	bra.s	loc_E51A
; ---------------------------------------------------------------------------

loc_E54E:
	add.w	(a0)+,d5
	move.w	d5,(a2)+
	bra.s	loc_E51A
; ---------------------------------------------------------------------------

loc_E554:
	move.w	d1,d5
	add.w	(a0)+,d5
	move.w	d1,d6
	add.w	(a0)+,d6
	bra.w	loc_E70A
; ---------------------------------------------------------------------------
off_E560:	dc.l unk_E570
	dc.l unk_E596
	dc.l unk_E5C4
	dc.l unk_E5FA
unk_E570:	dc.b $FF
	dc.b $F0 ; �
	dc.b   5
	dc.b   0
	dc.b $E6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $7E ; ~
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $82 ; �
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   5
	dc.b   0
	dc.b $F6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $FF
	dc.b $F8 ; �
	dc.b   0
	dc.b $10
unk_E596:	dc.b $FF
	dc.b $F0 ; �
	dc.b   9
	dc.b   0
	dc.b $E6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $7E ; ~
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $82 ; �
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $86 ; �
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   8
	dc.b   9
	dc.b   0
	dc.b $F6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $FF
	dc.b $F4 ; �
	dc.b   0
	dc.b $14
unk_E5C4:	dc.b $FF
	dc.b $F0 ; �
	dc.b  $D
	dc.b   0
	dc.b $E6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $7E ; ~
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $82 ; �
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $86 ; �
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $8A ; �
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   8
	dc.b  $D
	dc.b   0
	dc.b $F6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $FF
	dc.b $F0 ; �
	dc.b   0
	dc.b $18
unk_E5FA:	dc.b $FF
	dc.b $EC ; �
	dc.b  $D
	dc.b   0
	dc.b $E6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   8
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $7E ; ~
	dc.b   0
	dc.b   8
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $82 ; �
	dc.b   0
	dc.b $10
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $86 ; �
	dc.b   0
	dc.b $18
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $8A ; �
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $7E ; ~
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $82 ; �
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $86 ; �
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $E6 ; �
	dc.b $8A ; �
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b  $C
	dc.b  $D
	dc.b   0
	dc.b $F6 ; �
	dc.b $76 ; v
	dc.b   0
	dc.b   8
	dc.b $80 ; �
	dc.b   0
	dc.b $FF
	dc.b $EC ; �
	dc.b   0
	dc.b $1C
; ---------------------------------------------------------------------------

loc_E650:
	move.w	d7,d3
	subq.w	#2,d3
	add.w	d3,d3
	move.w	d3,d4
	add.w	d3,d4
	add.w	d4,d3
	move.w	d0,a1
	move.w	d3,d4
	add.w	d4,d4
	tst.b	($FFFFFABE).w
	bne.w	loc_E67E
	add.w	d4,a1
	addi.w	#$20,a1
	add.w	d4,d0
	cmpi.w	#$1C0,d0
	bge.w	loc_E7A4
	moveq	#0,d4
	bra.s	loc_E692
; ---------------------------------------------------------------------------

loc_E67E:
	sub.w	d4,d0
	subi.w	#$20,d0
	move.w	d0,a1
	move.w	#$800,d4
	cmpi.w	#$60,d0
	ble.w	loc_E7A4

loc_E692:
	move.w	d1,d6
	add.w	d3,d6
	addi.w	#$18,d6
	sub.w	d3,d1
	subi.w	#$10,d1
	move.w	d1,d5
	lsr.w	#1,d3
	addq.w	#2,d3
	move.w	d1,(a2)+
	addi.w	#$10,d1
	move.b	#$D,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$E676,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+

loc_E6BC:
	subq.w	#8,d3
	bmi.s	loc_E6D8
	move.w	d1,(a2)+
	addi.w	#$20,d1
	move.b	#$F,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$E67E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	bra.s	loc_E6BC
; ---------------------------------------------------------------------------

loc_E6D8:
	cmpi.w	#$FFF8,d3
	beq.s	loc_E6F8
	lsl.w	#2,d3
	add.w	d3,d1
	move.w	d1,(a2)+
	addi.w	#$20,d1
	move.b	#$F,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$E67E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+

loc_E6F8:
	move.w	d1,(a2)+
	move.b	#$D,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$F676,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+

loc_E70A:
	move.l	a2,(Addr_NextSpriteSlot).w
	move.b	d2,(Number_Sprites).w
	move.w	a1,d1
	subi.w	#$80,d1
	add.w	(Camera_X_pos).w,d1
	asr.w	#4,d1
	bmi.s	loc_E79C
	cmp.w	(Level_width_blocks).w,d1
	bge.s	loc_E79C
	move.w	(Camera_Y_pos).w,d0
	subi.w	#$80,d0
	add.w	d0,d5
	add.w	d0,d6
	asr.w	#4,d5
	bpl.s	loc_E738
	moveq	#0,d5

loc_E738:
	cmp.w	(Level_height_pixels).w,d5
	blt.s	loc_E744
	move.w	(Level_height_pixels).w,d5
	subq.w	#1,d5

loc_E744:
	asr.w	#4,d6
	bpl.s	loc_E74A
	moveq	#0,d6

loc_E74A:
	cmp.w	(Level_height_pixels).w,d6
	blt.s	loc_E756
	move.w	(Level_height_pixels).w,d6
	subq.w	#1,d6

loc_E756:
	sub.w	d5,d6
	move.w	d5,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a2
	move.w	(a2,d0.w),a2
	move.w	d1,d0
	add.w	d0,d0
	add.w	d0,a2
	movem.w	d5-d6/a2,-(sp)
	bsr.w	sub_E446
	movem.w	(sp)+,d5-d6/a2
	tst.b	($FFFFFABE).w
	bne.s	loc_E786
	subq.w	#1,d1
	bmi.s	loc_E79C
	subq.w	#2,a2
	bra.s	loc_E790
; ---------------------------------------------------------------------------

loc_E786:
	addq.w	#1,d1
	cmp.w	(Level_width_blocks).w,d1
	bge.s	loc_E79C
	addq.w	#2,a2

loc_E790:
	cmpi.w	#3,($FFFFFAB8).w
	bcs.s	loc_E79C
	bsr.w	sub_E446

loc_E79C:
	addi.w	#1,($FFFFFAB8).w
	bra.s	loc_E7A8
; ---------------------------------------------------------------------------

loc_E7A4:
	clr.w	($FFFFFAB8).w

loc_E7A8:
	bra.w	loc_E99C
; ---------------------------------------------------------------------------

loc_E7AC:
	andi.w	#$7FFF,d7
	bne.s	loc_E7E0
	movem.l	d0-d2/a0,-(sp)
	move.l	#$3000001,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_EADE,4(a0)
	move.l	a1,($FFFFFABA).w
	move.l	a0,$C(a1)
	movem.l	(sp)+,d0-d2/a0
	subq.w	#2,(Number_Diamonds).w

loc_E7E0:
	tst.w	d7
	bne.s	loc_E842
	move.w	d0,d6
	tst.b	($FFFFFABE).w
	bne.s	loc_E7F4
	addi.w	#$10,d6
	moveq	#0,d4
	bra.s	loc_E7FE
; ---------------------------------------------------------------------------

loc_E7F4:
	subi.w	#$10,d0
	move.w	d0,d6
	move.w	#$800,d4

loc_E7FE:
	move.w	d1,d5
	subq.w	#8,d1
	subq.w	#4,d5
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#4,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$868E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#4,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$8692,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	move.b	#4,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$968E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	bra.w	loc_E948
; ---------------------------------------------------------------------------

loc_E842:
	cmpi.w	#1,d7
	bne.s	loc_E8A6
	move.w	d0,d6
	tst.b	($FFFFFABE).w
	bne.s	loc_E858
	addi.w	#$18,d6
	moveq	#0,d4
	bra.s	loc_E862
; ---------------------------------------------------------------------------

loc_E858:
	subi.w	#$18,d0
	move.w	d0,d6
	move.w	#$800,d4

loc_E862:
	subq.w	#6,d1
	move.w	d1,d5
	subq.w	#2,d1
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#8,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$868E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#8,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$8692,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	move.b	#8,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$968E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	bra.w	loc_E948
; ---------------------------------------------------------------------------

loc_E8A6:
	move.w	d7,d3
	lsl.w	#3,d3
	move.w	d0,d6
	tst.b	($FFFFFABE).w
	bne.s	loc_E8CA
	add.w	d3,d6
	addi.w	#$10,d6
	add.w	d3,d0
	subi.w	#$10,d0
	cmpi.w	#$1C0,d0
	bge.w	loc_E988
	moveq	#0,d4
	bra.s	loc_E8DE
; ---------------------------------------------------------------------------

loc_E8CA:
	sub.w	d3,d0
	subi.w	#$10,d0
	move.w	d0,d6
	cmpi.w	#$60,d0
	ble.w	loc_E988
	move.w	#$800,d4

loc_E8DE:
	move.w	d7,d3
	add.w	d3,d3
	subq.w	#4,d1
	sub.w	d3,d1
	move.w	d1,d5
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#$C,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$868E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	move.w	d7,d3
	lsr.w	#1,d3
	subq.w	#1,d3

loc_E902:
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#$C,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$8692,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+
	dbf	d3,loc_E902
	btst	#0,d7
	beq.s	loc_E936
	subq.w	#4,d1
	move.w	d1,(a2)+
	addq.w	#8,d1
	move.b	#$C,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$8692,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+

loc_E936:
	move.w	d1,(a2)+
	move.b	#$C,(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	#$968E,(a2)
	or.w	d4,(a2)+
	move.w	d0,(a2)+

loc_E948:
	move.l	($FFFFFABA).w,a1
	subi.w	#$80,d6
	add.w	(Camera_X_pos).w,d6
	move.w	d6,$1A(a1)
	subi.w	#$80,d5
	add.w	(Camera_Y_pos).w,d5
	move.w	d5,$1E(a1)
	andi.w	#$FE,d7
	add.w	d7,d7
	cmpi.w	#$20,d7
	ble.s	loc_E972
	moveq	#$20,d7

loc_E972:
	addi.w	#$1160,d7
	move.w	d7,$22(a1)
	addq.w	#1,($FFFFFAB8).w
	move.l	a2,(Addr_NextSpriteSlot).w
	move.b	d2,(Number_Sprites).w
	bra.s	loc_E99C
; ---------------------------------------------------------------------------

loc_E988:
	clr.w	($FFFFFAB8).w
	move.l	($FFFFFABA).w,a3
	move.l	$C(a3),a0
	jsr	(j_loc_1078).w
	jsr	(j_Delete_Object_a0).w

loc_E99C:
	move.l	(Addr_NextSpriteSlot).w,a3
	moveq	#0,d2
	move.b	(Number_Sprites).w,d3
	move.w	(Camera_X_pos).w,d4
	lsr.w	#4,d4
	subq.w	#4,d4
	move.w	d4,d5
	addi.w	#$1C,d5
	move.w	(Camera_Y_pos).w,d6
	lsr.w	#4,d6
	subq.w	#4,d6
	move.w	d6,d7
	addi.w	#$1C,d7
	move.w	($FFFFF8CE).w,d0
	beq.w	loc_EAB2

loc_E9CA:
	move.w	d0,a2
	move.w	8(a2),d0
	subi.w	#$127,d0
	bmi.s	loc_EA3E
	cmpi.w	#6,d0
	bcc.s	loc_EA3E
	move.w	2(a2),d1
	cmp.w	d4,d1
	blt.s	loc_EA3E
	cmp.w	d5,d1
	bgt.s	loc_EA3E
	move.w	4(a2),d2
	cmp.w	d6,d2
	blt.s	loc_EA3E
	cmp.w	d7,d2
	bgt.s	loc_EA3E
	lsl.w	#4,d1
	sub.w	(Camera_X_pos).w,d1
	addi.w	#$80,d1
	lsl.w	#4,d2
	sub.w	(Camera_Y_pos).w,d2
	addi.w	#$80,d2
	add.w	d0,d0
	add.w	d0,d0
	add.w	unk_EA26(pc,d0.w),d2
	move.w	d2,(a3)+
	move.b	unk_EA29(pc,d0.w),(a3)+
	addq.b	#1,d3
	move.b	d3,(a3)+
	move.w	#$8692,(a3)+
	add.w	unk_EA26(pc,d0.w),d1
	move.w	d1,(a3)+
	bra.s	loc_EA3E
; ---------------------------------------------------------------------------
unk_EA26:	dc.b   0
	dc.b   4
	dc.b   0
unk_EA29:	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_EA3E:
	subq.w	#1,8(a2)
	bne.s	loc_EAAA
	addq.w	#1,8(a2)
	move.w	(a2),a1
	move.b	(a1),d0
	bpl.s	loc_EAAA
	andi.b	#$F,d0
	cmpi.b	#$D,d0
	blt.s	loc_EA5A
	bra.s	loc_EAAA
; ---------------------------------------------------------------------------

loc_EA5A:
	move.w	(a1),d0
	cmp.w	6(a2),d0
	bne.s	loc_EA72
	move.w	2(a2),d1
	move.w	4(a2),d2
	bsr.w	sub_11542
	move.b	#$20,(a1)

loc_EA72:
	move.w	$A(a2),d0
	move.w	($FFFFF8CE).w,a0
	cmp.w	a2,a0
	bne.s	loc_EA86
	move.w	$A(a2),($FFFFF8CE).w
	bra.s	loc_EA98
; ---------------------------------------------------------------------------

loc_EA86:
	move.w	$A(a0),d1
	cmp.w	d1,a2
	beq.s	loc_EA92
	move.w	d1,a0
	bra.s	loc_EA86
; ---------------------------------------------------------------------------

loc_EA92:
	move.w	$A(a2),$A(a0)

loc_EA98:
	move.w	($FFFFF8D0).w,$A(a2)
	move.w	a2,($FFFFF8D0).w
	tst.w	d0
	bne.w	loc_E9CA
	bra.s	loc_EAB2
; ---------------------------------------------------------------------------

loc_EAAA:
	move.w	$A(a2),d0
	bne.w	loc_E9CA

loc_EAB2:
	move.l	a3,(Addr_NextSpriteSlot).w
	move.b	d3,(Number_Sprites).w
	rts
; End of function sub_E49A


; =============== S U B	R O U T	I N E =======================================


sub_EABC:
	lea	($FFFFEBDA).w,a0
	move.w	a0,($FFFFF8D0).w
	moveq	#$26,d0

loc_EAC6:
	lea	$C(a0),a1
	move.w	a1,$A(a0)
	move.l	a1,a0
	dbf	d0,loc_EAC6
	clr.w	$A(a0)
	clr.w	($FFFFF8CE).w
	rts
; End of function sub_EABC

; ---------------------------------------------------------------------------

loc_EADE:

	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_EADE
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_EAE4:
	tst.b	($FFFFFA64).w
	bne.w	loc_EB6E
	move.w	(Kid_hitbox_top).w,d0
	subq.w	#1,d0
	bpl.w	loc_EAF8
	moveq	#0,d0

loc_EAF8:
	move.w	(Kid_hitbox_bottom).w,d1
	addq.w	#1,d1
	cmp.w	(Level_height_blocks).w,d1
	blt.w	loc_EB0C
	move.w	(Level_height_blocks).w,d1
	subq.w	#1,d1

loc_EB0C:
	asr.w	#4,d0
	asr.w	#4,d1
	sub.w	d0,d1
	add.w	d0,d0
	lea	($FFFF4A04).l,a0
	move.w	(a0,d0.w),a0
	move.w	(Kid_hitbox_left).w,d0
	subq.w	#1,d0
	bpl.w	loc_EB2A
	moveq	#0,d0

loc_EB2A:
	move.w	(Kid_hitbox_right).w,d2
	addq.w	#1,d2
	cmp.w	(Level_width_pixels).w,d2
	blt.w	loc_EB3E
	move.w	(Level_width_pixels).w,d2
	subq.w	#1,d2

loc_EB3E:
	asr.w	#4,d0
	asr.w	#4,d2
	sub.w	d0,d2
	add.w	d0,d0
	add.w	d0,a0

loc_EB48:
	move.w	d2,d3
	move.w	a0,a1

loc_EB4C:
	move.w	(a1)+,d0
	bclr	#$F,d0
	beq.w	loc_EB62
	andi.w	#$F00,d0
	cmpi.w	#$A00,d0
	beq.w	loc_EB72

loc_EB62:
	dbf	d3,loc_EB4C
	add.w	(Level_width_tiles).w,a0
	dbf	d1,loc_EB48

loc_EB6E:
	bra.w	loc_EC22
; ---------------------------------------------------------------------------

loc_EB72:
	move.w	a1,d3
	subq.w	#2,d3
	bsr.w	sub_FACE
	bsr.w	sub_DF68
	bra.w	loc_EC22
; END OF FUNCTION CHUNK	FOR sub_DFB0
; ---------------------------------------------------------------------------
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b  $F
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b  $F
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_EC22:
	move.l	($FFFFF8B6).w,a1
	move.l	(Addr_NextSpriteSlot).w,a2
	moveq	#0,d0
	move.b	(Number_Sprites).w,d0
	move.w	d0,a5
	move.w	($FFFFF8C6).w,d0
	beq.w	loc_EDDA
	move.w	(Camera_X_pos).w,d4
	lsr.w	#4,d4
	move.w	d4,d6
	addi.w	#$14,d6
	move.w	(Camera_Y_pos).w,d5
	lsr.w	#4,d5
	move.w	d5,d7
	addi.w	#$E,d7

loc_EC52:
	move.w	d0,a0
	move.w	8(a0),d0
	bne.s	loc_ECA6
	swap	d4
	swap	d5
	move.w	2(a0),d1
	lsl.w	#4,d1
	addq.w	#8,d1
	move.w	4(a0),d2
	lsl.w	#4,d2
	addq.w	#8,d2
	move.w	6(a0),d3
	move.w	#3,d4

loc_EC76:
	btst	d4,d3
	beq.s	loc_EC9E
	move.w	($FFFFF8CC).w,d5
	beq.s	loc_ECA2
	move.w	d5,a3
	move.w	$A(a3),($FFFFF8CC).w
	move.w	($FFFFF8CA).w,$A(a3)
	move.w	a3,($FFFFF8CA).w
	move.w	(a0),(a3)+
	move.w	d1,(a3)+
	move.w	d2,(a3)+
	move.w	d4,(a3)+
	move.w	#$FFFE,(a3)+

loc_EC9E:
	dbf	d4,loc_EC76

loc_ECA2:
	swap	d4
	swap	d5

loc_ECA6:
	addq.w	#1,8(a0)
	cmpi.w	#$16,d0
	bne.s	loc_ED04
	move.w	$A(a0),d0
	move.w	($FFFFF8C6).w,a3
	cmp.w	a0,a3
	bne.s	loc_ECC4
	move.w	$A(a0),($FFFFF8C6).w
	bra.s	loc_ECD8
; ---------------------------------------------------------------------------

loc_ECC4:
	move.w	$A(a3),d1
	cmp.w	d1,a0
	beq.w	loc_ECD2
	move.w	d1,a3
	bra.s	loc_ECC4
; ---------------------------------------------------------------------------

loc_ECD2:
	move.w	$A(a0),$A(a3)

loc_ECD8:
	move.w	($FFFFF8C8).w,$A(a0)
	move.w	a0,($FFFFF8C8).w
	tst.w	d0
	bne.w	loc_EC52
	bra.w	loc_EDDA
; END OF FUNCTION CHUNK	FOR sub_DFB0
; ---------------------------------------------------------------------------
unk_ECEC:	dc.b   0
	dc.b $81 ; �
	dc.b   4
	dc.b $81 ; �
	dc.b   4
	dc.b $81 ; �
	dc.b   4
	dc.b $81 ; �
	dc.b   4
	dc.b $81 ; �
	dc.b   4
	dc.b $81 ; �
	dc.b   4
	dc.b $83 ; �
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_ED04:
	move.b	unk_ECEC(pc,d0.w),d0
	bne.s	loc_ED16
	move.w	$A(a0),d0
	bne.w	loc_EC52
	bra.w	loc_EDDA
; ---------------------------------------------------------------------------

loc_ED16:
	bpl.w	loc_EDBC
	move.w	2(a0),d1
	cmp.w	d4,d1
	blt.s	loc_ED52
	cmp.w	d6,d1
	bgt.s	loc_ED52
	move.w	4(a0),d2
	cmp.w	d5,d2
	blt.s	loc_ED52
	cmp.w	d7,d2
	bgt.s	loc_ED52
	lsl.w	#4,d1
	sub.w	(Camera_X_pos).w,d1
	addi.w	#$84,d1
	lsl.w	#4,d2
	sub.w	(Camera_Y_pos).w,d2
	addi.w	#$84,d2
	move.w	d2,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	#$8294,(a2)+
	move.w	d1,(a2)+

loc_ED52:
	lsr.w	#1,d0
	bcc.s	loc_EDB0
	move.w	4(a0),d1
	add.w	d1,d1
	lea	($FFFF4BB8).l,a3
	moveq	#-1,d2
	move.w	(a3,d1.w),d2
	add.w	2(a0),d2
	move.l	d2,a3
	moveq	#0,d1
	move.b	(a3),d1
	lsr.w	#1,d0
	bcs.s	loc_ED7C
	addi.w	#$6000,d1
	bra.s	loc_ED98
; ---------------------------------------------------------------------------

loc_ED7C:
	move.w	(Foreground_theme).w,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(LnkTo_ThemeCollision_Index).l,a4
	move.l	(a4,d0.w),a4
	moveq	#0,d0
	move.b	(a4,d1.w),d0
	ror.w	#4,d0
	or.w	d0,d1

loc_ED98:
	move.w	(a0),a3
	move.w	d1,(a3)
	move.w	2(a0),(a1)+
	move.w	4(a0),(a1)+
	move.w	d1,(a1)+
	move.w	$A(a0),d0
	bne.w	loc_EC52
	bra.s	loc_EDDA
; ---------------------------------------------------------------------------

loc_EDB0:
	move.w	$A(a0),d0
	bne.w	loc_EC52
	bra.w	loc_EDDA
; ---------------------------------------------------------------------------

loc_EDBC:
	move.w	(a0),a3
	move.w	#$E31C,d1
	add.w	6(a0),d1
	move.w	d1,(a3)
	move.w	2(a0),(a1)+
	move.w	4(a0),(a1)+
	move.w	d1,(a1)+
	move.w	$A(a0),d0
	bne.w	loc_EC52

loc_EDDA:
	move.w	($FFFFF8CA).w,d0
	beq.w	loc_F05A
	move.w	(Camera_X_pos).w,d4
	move.w	d4,d6
	subq.w	#8,d4
	addi.w	#$140,d6
	move.w	(Camera_Y_pos).w,d5
	move.w	d5,d7
	subq.w	#8,d5
	addi.w	#$140,d7

loc_EDFA:
	move.w	d0,a0
	move.w	6(a0),d0
	beq.s	loc_EE62
	subq.w	#2,d0
	beq.w	loc_EF0C
	bpl.w	loc_EEBC
	move.w	2(a0),d0
	addq.w	#4,d0
	cmp.w	(Level_width_pixels).w,d0
	bge.w	loc_EFA0
	addq.w	#1,8(a0)
	move.w	8(a0),d0
	bgt.s	loc_EE2A
	bne.s	loc_EE52
	addq.w	#2,(a0)
	bra.s	loc_EE52
; ---------------------------------------------------------------------------

loc_EE2A:
	cmpi.w	#4,d0
	bne.s	loc_EE38
	moveq	#0,d0
	move.w	d0,8(a0)
	addq.w	#2,(a0)

loc_EE38:
	move.w	(a0),a4
	move.w	(a4),d1
	btst	#$E,d1
	beq.s	loc_EE52
	cmpi.w	#2,d0
	bge.w	loc_EFA0
	andi.w	#$3000,d1
	bne.w	loc_EFA0

loc_EE52:
	addq.w	#4,2(a0)
	moveq	#0,d1
	moveq	#-$4,d2
	move.w	#$8A96,d3
	bra.w	loc_EF62
; ---------------------------------------------------------------------------

loc_EE62:
	cmpi.w	#4,4(a0)
	ble.w	loc_EFA0
	addq.w	#1,8(a0)
	move.w	8(a0),d0
	bgt.s	loc_EE80
	bne.s	loc_EEAC
	move.w	(Level_width_tiles).w,d1
	sub.w	d1,(a0)
	bra.s	loc_EEAC
; ---------------------------------------------------------------------------

loc_EE80:
	cmpi.w	#4,d0
	bne.s	loc_EE92
	moveq	#0,d0
	move.w	d0,8(a0)
	move.w	(Level_width_tiles).w,d1
	sub.w	d1,(a0)

loc_EE92:
	move.w	(a0),a4
	move.w	(a4),d1
	btst	#$E,d1
	beq.s	loc_EEAC
	cmpi.w	#2,d0
	blt.w	loc_EFA0
	andi.w	#$2000,d1
	bne.w	loc_EFA0

loc_EEAC:
	subq.w	#4,4(a0)
	moveq	#-$4,d1
	moveq	#-8,d2
	move.w	#$8295,d3
	bra.w	loc_EF62
; ---------------------------------------------------------------------------

loc_EEBC:
	cmpi.w	#4,2(a0)
	ble.w	loc_EFA0
	addq.w	#1,8(a0)
	move.w	8(a0),d0
	bgt.s	loc_EED6
	bne.s	loc_EEFE
	subq.w	#2,(a0)
	bra.s	loc_EEFE
; ---------------------------------------------------------------------------

loc_EED6:
	cmpi.w	#4,d0
	bne.s	loc_EEE4
	moveq	#0,d0
	move.w	d0,8(a0)
	subq.w	#2,(a0)

loc_EEE4:
	move.w	(a0),a4
	move.w	(a4),d1
	btst	#$E,d1
	beq.s	loc_EEFE
	cmpi.w	#2,d0
	bge.w	loc_EFA0
	andi.w	#$1000,d1
	beq.w	loc_EFA0

loc_EEFE:
	subq.w	#4,2(a0)
	moveq	#-8,d1
	moveq	#-$4,d2
	move.w	#$8296,d3
	bra.s	loc_EF62
; ---------------------------------------------------------------------------

loc_EF0C:
	move.w	4(a0),d0
	addq.w	#4,d0
	cmp.w	(Level_height_blocks).w,d0
	bge.w	loc_EFA0
	addq.w	#1,8(a0)
	move.w	8(a0),d0
	bgt.s	loc_EF2E
	bne.s	loc_EF56
	move.w	(Level_width_tiles).w,d1
	add.w	d1,(a0)
	bra.s	loc_EF56
; ---------------------------------------------------------------------------

loc_EF2E:
	cmpi.w	#4,d0
	bne.s	loc_EF40
	moveq	#0,d0
	move.w	d0,8(a0)
	move.w	(Level_width_tiles).w,d1
	add.w	d1,(a0)

loc_EF40:
	move.w	(a0),a4
	move.w	(a4),d1
	btst	#$E,d1
	beq.s	loc_EF56
	cmpi.w	#2,d0
	bge.s	loc_EFA0
	andi.w	#$2000,d1
	bne.s	loc_EFA0

loc_EF56:
	addq.w	#4,4(a0)
	moveq	#-$4,d1
	moveq	#0,d2
	move.w	#$9295,d3

loc_EF62:
	add.w	2(a0),d1
	cmp.w	d4,d1
	blt.s	loc_EF94
	cmp.w	d6,d1
	bgt.s	loc_EF94
	add.w	4(a0),d2
	cmp.w	d5,d2
	blt.s	loc_EF94
	cmp.w	d7,d2
	bgt.s	loc_EF94
	sub.w	(Camera_X_pos).w,d1
	addi.w	#$80,d1
	sub.w	(Camera_Y_pos).w,d2
	addi.w	#$80,d2
	move.w	d2,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	d3,(a2)+
	move.w	d1,(a2)+

loc_EF94:
	move.w	$A(a0),d0
	bne.w	loc_EDFA
	bra.w	loc_F05A
; ---------------------------------------------------------------------------

loc_EFA0:
	move.w	$A(a0),d0
	move.w	($FFFFF8CA).w,a3
	cmp.w	a0,a3
	bne.s	loc_EFB4
	move.w	$A(a0),($FFFFF8CA).w
	bra.s	loc_EFC8
; ---------------------------------------------------------------------------

loc_EFB4:
	move.w	$A(a3),d1
	cmp.w	d1,a0
	beq.w	loc_EFC2
	move.w	d1,a3
	bra.s	loc_EFB4
; ---------------------------------------------------------------------------

loc_EFC2:
	move.w	$A(a0),$A(a3)

loc_EFC8:
	move.w	($FFFFF8CC).w,$A(a0)
	move.w	a0,($FFFFF8CC).w
	move.b	(a4),d1
	bpl.w	loc_F054
	andi.w	#$F,d1
	add.w	d1,d1
	move.w	off_EFEA(pc,d1.w),a3
	addi.l	#off_EFEA,a3
	jmp	(a3)
; END OF FUNCTION CHUNK	FOR sub_DFB0
; ---------------------------------------------------------------------------
off_EFEA:	dc.w loc_F00A-off_EFEA
	dc.w loc_F00A-off_EFEA
	dc.w loc_F02A-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F00A-off_EFEA
	dc.w loc_F04A-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
	dc.w loc_F054-off_EFEA
; ---------------------------------------------------------------------------

loc_F00A:
	move.w	d6,-(sp)
	move.w	a4,d3
	move.w	6(a0),d6
	move.l	a1,($FFFFF8B6).w
	bsr.w	sub_FACE
	eori.w	#2,d6
	bsr.w	sub_10E86
	move.l	($FFFFF8B6).w,a1
	move.w	(sp)+,d6
	bra.s	loc_F054
; ---------------------------------------------------------------------------

loc_F02A:
	move.w	d6,-(sp)
	move.w	a4,d3
	move.w	6(a0),d6
	move.l	a1,($FFFFF8B6).w
	bsr.w	sub_FACE
	eori.w	#2,d6
	bsr.w	sub_10F44
	move.l	($FFFFF8B6).w,a1
	move.w	(sp)+,d6
	bra.s	loc_F054
; ---------------------------------------------------------------------------

loc_F04A:
	move.w	a4,d3
	bsr.w	sub_FACE
	bsr.w	sub_DF68
; START	OF FUNCTION CHUNK FOR sub_DFB0

loc_F054:
	tst.w	d0
	bne.w	loc_EDFA

loc_F05A:
	move.w	a5,d0
	move.b	d0,(Number_Sprites).w
	move.l	a1,($FFFFF8B6).w
	move.l	a2,(Addr_NextSpriteSlot).w
	rts
; END OF FUNCTION CHUNK	FOR sub_DFB0

; =============== S U B	R O U T	I N E =======================================


sub_F06A:
	lea	($FFFFE7F2).w,a0
	move.w	a0,($FFFFF8C4).w
	moveq	#$12,d0

loc_F074:
	lea	$E(a0),a1
	move.w	a1,$C(a0)
	move.l	a1,a0
	dbf	d0,loc_F074
	clr.w	$C(a0)
	clr.w	($FFFFF8C2).w
	moveq	#-1,d0
	move.w	d0,($FFFFF8BE).w
	move.w	d0,($FFFFF8C0).w
	rts
; End of function sub_F06A


; =============== S U B	R O U T	I N E =======================================


sub_F096:
	tst.b	($FFFFFA64).w
	beq.s	loc_F09E
	rts
; ---------------------------------------------------------------------------

loc_F09E:
	move.w	($FFFFF8BE).w,d3
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$1A(a0),d0
	lsr.w	#4,d0
	move.w	d0,($FFFFF8BE).w
	move.w	$1E(a0),d1
	lsr.w	#4,d1
	cmp.w	d0,d3
	beq.w	loc_F186
	bgt.s	loc_F0D0
	move.w	d0,d3
	addq.w	#3,d3
	cmp.w	(Level_width_blocks).w,d3
	blt.s	loc_F0D8
	move.w	(Level_width_blocks).w,d3
	subq.w	#1,d3
	bra.s	loc_F0D8
; ---------------------------------------------------------------------------

loc_F0D0:
	move.w	d0,d3
	subq.w	#3,d3
	bpl.s	loc_F0D8
	moveq	#0,d3

loc_F0D8:
	move.w	d1,d4
	subq.w	#5,d4
	bpl.s	loc_F0E0
	moveq	#0,d4

loc_F0E0:
	move.w	d1,d5
	addq.w	#2,d5
	cmp.w	(Level_height_pixels).w,d5
	blt.s	loc_F0F0
	move.w	(Level_height_pixels).w,d5
	subq.w	#1,d5

loc_F0F0:
	sub.w	d4,d5
	lea	($FFFF4A04).l,a1
	move.w	d4,d6
	add.w	d6,d6
	move.w	(a1,d6.w),a1
	move.w	d3,d6
	add.w	d6,d6
	add.w	d6,a1

loc_F106:
	move.w	(a1),d6
	andi.w	#$F00,d6
	cmpi.w	#$C00,d6
	bne.s	loc_F17C
	move.w	($FFFFF8C4).w,d7
	beq.s	loc_F17C
	move.w	d7,a3
	move.w	$C(a3),($FFFFF8C4).w
	move.w	($FFFFF8C2).w,$C(a3)
	move.w	a3,($FFFFF8C2).w
	move.w	a1,(a3)+
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	move.w	(a1),d6
	andi.w	#$FF,d6
	subi.w	#$2D,d6
	move.w	d6,(a3)+
	lsr.w	#1,d6
	bcc.s	loc_F14C
	move.l	a1,a4
	suba.w	(Level_width_tiles).w,a4
	tst.b	1(a4)
	bne.s	loc_F170

loc_F14C:
	lsr.w	#1,d6
	bcc.s	loc_F156
	tst.b	3(a1)
	bne.s	loc_F170

loc_F156:
	lsr.w	#1,d6
	bcc.s	loc_F166
	move.l	a1,a4
	add.w	(Level_width_tiles).w,a4
	tst.b	1(a4)
	bne.s	loc_F170

loc_F166:
	lsr.w	#1,d6
	bcc.s	loc_F176
	tst.b	-1(a1)
	beq.s	loc_F176

loc_F170:
	addi.w	#-$8000,-2(a3)

loc_F176:
	move.w	#$100,(a3)+
	clr.w	(a3)+

loc_F17C:
	add.w	(Level_width_tiles).w,a1
	addq.w	#1,d4
	dbf	d5,loc_F106

loc_F186:
	move.w	($FFFFF8C0).w,d4
	move.w	d1,($FFFFF8C0).w
	cmp.w	d1,d4
	beq.w	loc_F25C
	bgt.s	loc_F1A8
	move.w	d1,d4
	addq.w	#2,d4
	cmp.w	(Level_height_pixels).w,d4
	blt.s	loc_F1B0
	move.w	(Level_height_pixels).w,d4
	subq.w	#1,d4
	bra.s	loc_F1B0
; ---------------------------------------------------------------------------

loc_F1A8:
	move.w	d1,d4
	subq.w	#5,d4
	bpl.s	loc_F1B0
	moveq	#0,d4

loc_F1B0:
	move.w	d0,d3
	subq.w	#3,d3
	bpl.s	loc_F1B8
	moveq	#0,d3

loc_F1B8:
	move.w	d0,d5
	addq.w	#3,d5
	cmp.w	(Level_width_blocks).w,d5
	blt.s	loc_F1C8
	move.w	(Level_width_blocks).w,d5
	subq.w	#1,d5

loc_F1C8:
	sub.w	d3,d5
	lea	($FFFF4A04).l,a1
	move.w	d4,d6
	add.w	d6,d6
	move.w	(a1,d6.w),a1
	move.w	d3,d6
	add.w	d6,d6
	add.w	d6,a1

loc_F1DE:
	move.w	(a1),d6
	andi.w	#$F00,d6
	cmpi.w	#$C00,d6
	bne.s	loc_F254
	move.w	($FFFFF8C4).w,d7
	beq.s	loc_F254
	move.w	d7,a3
	move.w	$C(a3),($FFFFF8C4).w
	move.w	($FFFFF8C2).w,$C(a3)
	move.w	a3,($FFFFF8C2).w
	move.w	a1,(a3)+
	move.w	d3,(a3)+
	move.w	d4,(a3)+
	move.w	(a1),d6
	andi.w	#$FF,d6
	subi.w	#$2D,d6
	move.w	d6,(a3)+
	lsr.w	#1,d6
	bcc.s	loc_F224
	move.l	a1,a4
	suba.w	(Level_width_tiles).w,a4
	tst.b	1(a4)
	bne.s	loc_F248

loc_F224:
	lsr.w	#1,d6
	bcc.s	loc_F22E
	tst.b	3(a1)
	bne.s	loc_F248

loc_F22E:
	lsr.w	#1,d6
	bcc.s	loc_F23E
	move.l	a1,a4
	add.w	(Level_width_tiles).w,a4
	tst.b	1(a4)
	bne.s	loc_F248

loc_F23E:
	lsr.w	#1,d6
	bcc.s	loc_F24E
	tst.b	-1(a1)
	beq.s	loc_F24E

loc_F248:
	addi.w	#-$8000,-2(a3)

loc_F24E:
	move.w	#$100,(a3)+
	clr.w	(a3)+

loc_F254:
	addq.w	#2,a1
	addq.w	#1,d3
	dbf	d5,loc_F1DE

loc_F25C:
	move.w	(Camera_X_pos).w,d4
	lsr.w	#4,d4
	move.w	d4,d6
	addi.w	#$14,d6
	move.w	(Camera_Y_pos).w,d5
	lsr.w	#4,d5
	move.w	d5,d7
	addi.w	#$E,d7
	move.l	($FFFFF8B6).w,a1
	move.l	(Addr_NextSpriteSlot).w,a2
	move.w	#$500,d0
	move.b	(Number_Sprites).w,d0
	move.w	d0,a5
	move.w	($FFFFF8C2).w,d0
	beq.s	loc_F2B0

loc_F28C:
	move.w	d0,a0
	subq.b	#1,8(a0)
	beq.s	loc_F2B6
	move.w	6(a0),d0
	bmi.w	loc_F410
	move.w	$C(a0),d0
	bne.s	loc_F28C

loc_F2A2:
	move.w	a5,d0
	move.b	d0,(Number_Sprites).w
	move.l	a1,($FFFFF8B6).w
	move.l	a2,(Addr_NextSpriteSlot).w

loc_F2B0:
	bsr.w	sub_F568
	rts
; ---------------------------------------------------------------------------

loc_F2B6:
	move.w	$A(a0),d0
	addq.w	#1,$A(a0)
	move.b	#3,8(a0)
	add.w	d0,d0
	add.w	d0,d0
	move.l	off_F2CE(pc,d0.w),a3
	jmp	(a3)
; ---------------------------------------------------------------------------
off_F2CE:	dc.l loc_F2EE
	dc.l loc_F2F8
	dc.l loc_F386
	dc.l loc_F386
	dc.l loc_F386
	dc.l loc_F302
	dc.l loc_F31C
	dc.l loc_F326
; ---------------------------------------------------------------------------

loc_F2EE:
	move.w	(a0),a3
	move.b	#$ED,(a3)
	bra.w	loc_F386
; ---------------------------------------------------------------------------

loc_F2F8:
	move.b	#$A,9(a0)
	bra.w	loc_F386
; ---------------------------------------------------------------------------

loc_F302:
	bsr.w	sub_F536
	beq.w	loc_F386
	subq.b	#1,9(a0)
	beq.w	loc_F386
	move.w	#2,$A(a0)
	bra.w	loc_F386
; ---------------------------------------------------------------------------

loc_F31C:
	move.b	#$32,8(a0)
	bra.w	loc_F386
; ---------------------------------------------------------------------------

loc_F326:
	bsr.w	sub_F536
	beq.s	loc_F336
	move.w	#1,$A(a0)
	bra.w	loc_F386
; ---------------------------------------------------------------------------

loc_F336:
	move.w	(a0),a3
	move.b	#$EC,(a3)
	move.w	$C(a0),d0
	move.w	($FFFFF8C2).w,a3
	cmp.w	a0,a3
	bne.s	loc_F350
	move.w	$C(a0),($FFFFF8C2).w
	bra.s	loc_F364
; ---------------------------------------------------------------------------

loc_F350:
	move.w	$C(a3),d1
	cmp.w	d1,a0
	beq.w	loc_F35E
	move.w	d1,a3
	bra.s	loc_F350
; ---------------------------------------------------------------------------

loc_F35E:
	move.w	$C(a0),$C(a3)

loc_F364:
	move.w	($FFFFF8C4).w,$C(a0)
	move.w	a0,($FFFFF8C4).w
	tst.w	d0
	bne.w	loc_F28C

loc_F374:
	bra.w	loc_F2A2
; ---------------------------------------------------------------------------
	dc.b $8D ; �
	dc.b $3D ; =
	dc.b $8D ; �
	dc.b $41 ; A
	dc.b $8D ; �
	dc.b $45 ; E
	dc.b $8D ; �
	dc.b $49 ; I
	dc.b $8D ; �
	dc.b $4D ; M
	dc.b $8D ; �
	dc.b $3D ; =
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_F386:
	move.w	6(a0),d0
	bmi.w	loc_F410
	move.w	$A(a0),d1
	add.w	d1,d1
	move.w	loc_F374+2(pc,d1.w),d1
	move.w	(a0),a3
	lsr.w	#1,d0
	bcc.s	loc_F3B2
	move.l	a3,a4
	suba.w	(Level_width_tiles).w,a4
	move.w	d1,(a4)
	move.w	2(a0),(a1)+
	move.w	4(a0),(a1)
	subq.w	#1,(a1)+
	move.w	d1,(a1)+

loc_F3B2:
	lsr.w	#1,d0
	bcc.s	loc_F3CC
	move.w	d1,d2
	beq.s	loc_F3BC
	addq.w	#1,d2

loc_F3BC:
	move.w	d2,2(a3)
	move.w	2(a0),(a1)
	addq.w	#1,(a1)+
	move.w	4(a0),(a1)+
	move.w	d2,(a1)+

loc_F3CC:
	lsr.w	#1,d0
	bcc.s	loc_F3EA
	move.w	d1,d2
	beq.s	loc_F3D6
	addq.w	#2,d2

loc_F3D6:
	move.w	a3,a4
	add.w	(Level_width_tiles).w,a4
	move.w	d2,(a4)
	move.w	2(a0),(a1)+
	move.w	4(a0),(a1)
	addq.w	#1,(a1)+
	move.w	d2,(a1)+

loc_F3EA:
	lsr.w	#1,d0
	bcc.s	loc_F404
	move.w	d1,d2
	beq.s	loc_F3F4
	addq.w	#3,d2

loc_F3F4:
	move.w	d2,-2(a3)
	move.w	2(a0),(a1)
	subq.w	#1,(a1)+
	move.w	4(a0),(a1)+
	move.w	d2,(a1)+

loc_F404:
	move.w	$C(a0),d0
	bne.w	loc_F28C
	bra.w	loc_F2A2
; ---------------------------------------------------------------------------

loc_F410:
	move.w	$A(a0),d1
	subq.w	#6,d1
	bmi.s	loc_F41E
	bne.w	loc_F528
	moveq	#-5,d1

loc_F41E:
	add.w	d1,d1
	add.w	d1,d1
	addi.w	#$2AB,d1
	lsr.w	#1,d0
	bcc.s	loc_F462
	move.w	2(a0),d2
	move.w	4(a0),d3
	subq.w	#1,d3
	cmp.w	d4,d2
	blt.s	loc_F462
	cmp.w	d6,d2
	bgt.s	loc_F462
	cmp.w	d5,d3
	blt.s	loc_F462
	cmp.w	d7,d3
	bgt.s	loc_F462
	lsl.w	#4,d3
	sub.w	(Camera_Y_pos).w,d3
	addi.w	#$80,d3
	move.w	d3,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	d1,(a2)+
	lsl.w	#4,d2
	sub.w	(Camera_X_pos).w,d2
	addi.w	#$80,d2
	move.w	d2,(a2)+

loc_F462:
	lsr.w	#1,d0
	bcc.s	loc_F4A4
	move.w	2(a0),d2
	addq.w	#1,d2
	move.w	4(a0),d3
	cmp.w	d4,d2
	blt.s	loc_F4A4
	cmp.w	d6,d2
	bgt.s	loc_F4A4
	cmp.w	d5,d3
	blt.s	loc_F4A4
	cmp.w	d7,d3
	bgt.s	loc_F4A4
	lsl.w	#4,d3
	sub.w	(Camera_Y_pos).w,d3
	addi.w	#$80,d3
	move.w	d3,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	d1,d3
	addi.w	#$14,d3
	move.w	d3,(a2)+
	lsl.w	#4,d2
	sub.w	(Camera_X_pos).w,d2
	addi.w	#$80,d2
	move.w	d2,(a2)+

loc_F4A4:
	lsr.w	#1,d0
	bcc.s	loc_F4E6
	move.w	2(a0),d2
	move.w	4(a0),d3
	addq.w	#1,d3
	cmp.w	d4,d2
	blt.s	loc_F4E6
	cmp.w	d6,d2
	bgt.s	loc_F4E6
	cmp.w	d5,d3
	blt.s	loc_F4E6
	cmp.w	d7,d3
	bgt.s	loc_F4E6
	lsl.w	#4,d3
	sub.w	(Camera_Y_pos).w,d3
	addi.w	#$80,d3
	move.w	d3,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	d1,d3
	addi.w	#$1000,d3
	move.w	d3,(a2)+
	lsl.w	#4,d2
	sub.w	(Camera_X_pos).w,d2
	addi.w	#$80,d2
	move.w	d2,(a2)+

loc_F4E6:
	lsr.w	#1,d0
	bcc.s	loc_F528
	move.w	2(a0),d2
	subq.w	#1,d2
	move.w	4(a0),d3
	cmp.w	d4,d2
	blt.s	loc_F528
	cmp.w	d6,d2
	bgt.s	loc_F528
	cmp.w	d5,d3
	blt.s	loc_F528
	cmp.w	d7,d3
	bgt.s	loc_F528
	lsl.w	#4,d3
	sub.w	(Camera_Y_pos).w,d3
	addi.w	#$80,d3
	move.w	d3,(a2)+
	addq.w	#1,a5
	move.w	a5,(a2)+
	move.w	d1,d3
	addi.w	#$814,d3
	move.w	d3,(a2)+
	lsl.w	#4,d2
	sub.w	(Camera_X_pos).w,d2
	addi.w	#$80,d2
	move.w	d2,(a2)+

loc_F528:
	move.w	$C(a0),d0
	bne.w	loc_F28C
	bra.w	loc_F2A2
; End of function sub_F096

; ---------------------------------------------------------------------------
	rts

; =============== S U B	R O U T	I N E =======================================


sub_F536:
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	x_pos(a3),d0
	lsr.w	#4,d0
	subq.w	#4,d0
	sub.w	2(a0),d0
	bgt.s	loc_F564
	addq.w	#8,d0
	bmi.s	loc_F564
	move.w	y_pos(a3),d0
	lsr.w	#4,d0
	subq.w	#6,d0
	sub.w	4(a0),d0
	bgt.s	loc_F564
	addi.w	#9,d0
	bmi.s	loc_F564
	moveq	#1,d0
	rts
; ---------------------------------------------------------------------------

loc_F564:
	moveq	#0,d0
	rts
; End of function sub_F536


; =============== S U B	R O U T	I N E =======================================


sub_F568:
	move.w	(Kid_hitbox_left).w,d0
	asr.w	#4,d0
	subq.w	#1,d0
	bpl.s	loc_F574
	moveq	#0,d0

loc_F574:
	move.w	(Kid_hitbox_top).w,d2
	asr.w	#4,d2
	subq.w	#1,d2
	bpl.s	loc_F580
	moveq	#0,d2

loc_F580:
	move.w	(Kid_hitbox_right).w,d1
	addi.w	#$F,d1
	lsr.w	#4,d1
	addq.w	#1,d1
	move.w	(Kid_hitbox_bottom).w,d3
	addi.w	#$F,d3
	lsr.w	#4,d3
	addq.w	#1,d3
	lea	($FFFFF20A).w,a1
	lea	($FFFFF2AA).w,a2
	move.w	($FFFFF8C2).w,d4

loc_F5A4:
	bne.s	loc_F5B0

loc_F5A6:
	bra.w	loc_F72A
; ---------------------------------------------------------------------------

loc_F5AA:
	move.w	$C(a0),d4
	beq.s	loc_F5A6

loc_F5B0:
	move.w	d4,a0
	move.w	2(a0),d4
	cmp.w	d4,d0
	bgt.s	loc_F5AA
	cmp.w	d4,d1
	blt.s	loc_F5AA
	move.w	4(a0),d5
	cmp.w	d5,d2
	bgt.s	loc_F5AA
	cmp.w	d5,d3
	blt.s	loc_F5AA
	move.w	$A(a0),d6
	subq.w	#2,d6
	bmi.s	loc_F5AA
	subq.w	#4,d6
	bpl.s	loc_F5AA
	move.w	6(a0),d6
	lsr.w	#1,d6
	bcc.s	loc_F62C
	move.w	d5,d7
	sub.w	d2,d7
	subq.w	#2,d7
	bmi.s	loc_F62C
	cmp.w	d4,d0
	beq.s	loc_F62C
	cmp.w	d4,d1
	beq.s	loc_F62C
	move.w	d4,d7
	lsl.w	#4,d7
	addq.w	#2,d7
	move.w	d7,(a1)
	addq.w	#3,d7
	move.w	d7,8(a1)
	addq.w	#6,d7
	move.w	d7,$A(a1)
	addq.w	#3,d7
	move.w	d7,2(a1)
	move.w	d5,d7
	lsl.w	#4,d7
	subq.w	#1,d7
	move.w	d7,6(a1)
	move.w	d7,$E(a1)
	subq.w	#8,d7
	move.w	d7,4(a1)
	subq.w	#4,d7
	move.w	d7,$C(a1)
	lea	$10(a1),a1
	cmp.l	a1,a2
	beq.w	loc_F72A

loc_F62C:
	lsr.w	#1,d6
	bcc.s	loc_F67E
	move.w	d4,d7
	sub.w	d1,d7
	addq.w	#1,d7
	bpl.s	loc_F67E
	cmp.w	d5,d2
	beq.s	loc_F67E
	cmp.w	d5,d3
	beq.s	loc_F67E
	move.w	d5,d7
	lsl.w	#4,d7
	addq.w	#1,d7
	move.w	d7,4(a1)
	addq.w	#3,d7
	move.w	d7,$C(a1)
	addq.w	#6,d7
	move.w	d7,$E(a1)
	addq.w	#3,d7
	move.w	d7,6(a1)
	move.w	d4,d7
	addq.w	#1,d7
	lsl.w	#4,d7
	move.w	d7,(a1)
	move.w	d7,8(a1)
	addq.w	#8,d7
	move.w	d7,2(a1)
	addq.w	#4,d7
	move.w	d7,$A(a1)
	lea	$10(a1),a1
	cmp.l	a1,a2
	beq.w	loc_F72A

loc_F67E:
	lsr.w	#1,d6
	bcc.s	loc_F6D2
	move.w	d5,d7
	sub.w	d3,d7
	addq.w	#1,d7
	bpl.s	loc_F6D2
	cmp.w	d4,d0
	beq.s	loc_F6D2
	cmp.w	d4,d1
	beq.s	loc_F6D2
	move.w	d4,d7
	lsl.w	#4,d7
	addq.w	#2,d7
	move.w	d7,(a1)
	addq.w	#3,d7
	move.w	d7,8(a1)
	addq.w	#6,d7
	move.w	d7,$A(a1)
	addq.w	#3,d7
	move.w	d7,2(a1)
	move.w	d5,d7
	addq.w	#1,d7
	lsl.w	#4,d7
	subq.w	#1,d7
	move.w	d7,4(a1)
	move.w	d7,$C(a1)
	addq.w	#8,d7
	move.w	d7,6(a1)
	addq.w	#4,d7
	move.w	d7,$E(a1)
	lea	$10(a1),a1
	cmp.l	a1,a2
	beq.w	loc_F72A

loc_F6D2:
	lsr.w	#1,d6
	bcc.s	loc_F722
	move.w	d4,d7
	sub.w	d0,d7
	subq.w	#2,d7
	bmi.s	loc_F722
	cmp.w	d5,d2
	beq.s	loc_F722
	cmp.w	d5,d3
	beq.s	loc_F722
	move.w	d5,d7
	lsl.w	#4,d7
	addq.w	#1,d7
	move.w	d7,4(a1)
	addq.w	#3,d7
	move.w	d7,$C(a1)
	addq.w	#6,d7
	move.w	d7,$E(a1)
	addq.w	#3,d7
	move.w	d7,6(a1)
	move.w	d4,d7
	lsl.w	#4,d7
	move.w	d7,2(a1)
	move.w	d7,$A(a1)
	subq.w	#8,d7
	move.w	d7,(a1)
	subq.w	#4,d7
	move.w	d7,8(a1)
	lea	$10(a1),a1
	cmp.l	a1,a2
	beq.w	loc_F72A

loc_F722:
	move.w	$C(a0),d4
	bne.w	loc_F5B0

loc_F72A:
	move.w	#0,(a1)
	rts
; End of function sub_F568


; =============== S U B	R O U T	I N E =======================================


sub_F730:
	move.w	($FFFFF8D8).w,d6
	beq.w	return_FACC
	subq.w	#1,d6
	move.w	(Camera_X_pos).w,d4
	lsr.w	#4,d4
	swap	d6
	move.w	d4,d6
	addi.w	#$14,d6
	swap	d6
	move.w	(Camera_Y_pos).w,d5
	lsr.w	#4,d5
	move.w	d5,d7
	addi.w	#$E,d7
	swap	d7
	move.w	#$500,d7
	move.b	(Number_Sprites).w,d7
	move.l	($FFFFF8DA).w,a0
	move.l	($FFFFF8B2).w,a1
	move.l	(Addr_NextSpriteSlot).w,a2

loc_F76C:
	subq.w	#1,(a0)
	bne.w	loc_F9BA
	move.w	2(a0),d0
	bpl.w	loc_F898
	cmpi.w	#$8002,d0
	bgt.s	loc_F79A
	beq.s	loc_F78C
	addq.w	#1,2(a0)
	addq.w	#2,(a0)
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F78C:
	move.w	#3,2(a0)
	move.w	6(a0),(a0)
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F79A:
	cmpi.w	#$8004,d0
	bne.s	loc_F7AA
	addq.w	#1,2(a0)
	addq.w	#2,(a0)
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F7AA:
	clr.w	2(a0)
	move.w	4(a0),(a0)
	swap	d6
	swap	d7
	move.w	$C(a0),d1
	lea	($FFFF4A04).l,a4
	move.w	d1,d2
	add.w	d2,d2
	move.w	(a4,d2.w),a4
	move.w	$A(a0),d0
	move.w	d0,d2
	add.w	d2,d2
	add.w	d2,a4
	move.w	#$E304,a3
	lea	($FFFF505A).l,a5
	moveq	#0,d3
	move.b	$E(a0),d3
	subq.b	#1,d3
	tst.b	$F(a0)
	bne.w	loc_F83E
	cmp.w	d7,d1
	bgt.s	loc_F830
	cmp.w	d5,d1
	blt.s	loc_F830
	cmp.w	d6,d0
	bgt.s	loc_F830
	sub.w	d4,d0
	cmpi.w	#$FFF8,d0
	ble.s	loc_F830
	add.w	d4,d0
	lsl.w	#8,d1
	andi.w	#$F00,d1

loc_F808:
	move.w	a3,(a4)+
	cmp.w	d4,d0
	blt.s	loc_F828
	cmp.w	d6,d0
	bgt.s	loc_F828
	swap	d2
	move.w	d0,d2
	lsl.w	#2,d2
	andi.w	#$7C,d2
	or.w	d1,d2
	move.w	d2,(a1)+
	swap	d2
	move.l	(a5),(a1)+
	move.l	4(a5),(a1)+

loc_F828:
	addq.w	#1,d0
	dbf	d3,loc_F808
	bra.s	loc_F836
; ---------------------------------------------------------------------------

loc_F830:
	move.w	a3,(a4)+
	dbf	d3,loc_F830

loc_F836:
	swap	d6
	swap	d7
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F83E:
	cmp.w	d6,d0
	bgt.s	loc_F886
	cmp.w	d4,d0
	blt.s	loc_F886
	cmp.w	d7,d1
	bgt.s	loc_F886
	sub.w	d5,d1
	cmpi.w	#$FFF8,d1
	ble.s	loc_F886
	add.w	d5,d1
	lsl.w	#2,d0
	andi.w	#$7C,d0

loc_F85A:
	move.w	a3,(a4)
	cmp.w	d5,d1
	blt.s	loc_F87A
	cmp.w	d7,d1
	bgt.s	loc_F87A
	swap	d2

loc_F866:
	move.w	d1,d2
	lsl.w	#8,d2

loc_F86A:
	andi.w	#$F00,d2

loc_F86E:
	or.w	d0,d2
	move.w	d2,(a1)+

loc_F872:
	swap	d2
	move.l	(a5),(a1)+
	move.l	4(a5),(a1)+

loc_F87A:
	addq.w	#1,d1
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_F85A
	bra.s	loc_F890
; ---------------------------------------------------------------------------

loc_F886:
	move.w	a3,(a4)
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_F886

loc_F890:
	swap	d6
	swap	d7
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F898:
	beq.s	loc_F8A6
	move.w	#$8004,2(a0)
	addq.w	#2,(a0)
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F8A6:
	move.w	#$8001,2(a0)
	addq.w	#2,(a0)
	swap	d6
	swap	d7
	move.w	$C(a0),d1
	lea	($FFFF4BB8).l,a3
	lea	($FFFF4A04).l,a4
	move.w	d1,d2
	add.w	d2,d2
	move.w	(a4,d2.w),a4

loc_F8CA:
	moveq	#-1,d3
	move.w	(a3,d2.w),d3
	move.w	$A(a0),d0
	move.w	d0,d2
	add.w	d2,d2
	add.w	d2,a4
	add.w	d0,d3
	move.l	d3,a3
	moveq	#0,d3
	move.b	$E(a0),d3
	subq.b	#1,d3
	tst.b	$F(a0)
	bne.w	loc_F94E
	cmp.w	d7,d1
	bgt.s	loc_F93C
	cmp.w	d5,d1
	blt.s	loc_F93C
	cmp.w	d6,d0
	bgt.s	loc_F93C
	sub.w	d4,d0
	cmpi.w	#$FFF8,d0
	ble.s	loc_F93C
	add.w	d4,d0
	lsl.w	#8,d1
	andi.w	#$F00,d1

loc_F90A:
	moveq	#0,d2
	move.b	(a3)+,d2
	move.w	d2,(a4)+
	cmp.w	d4,d0
	blt.s	loc_F934
	cmp.w	d6,d0
	bgt.s	loc_F934
	swap	d2
	move.w	d0,d2
	lsl.w	#2,d2
	andi.w	#$7C,d2
	or.w	d1,d2
	move.w	d2,(a1)+
	swap	d2
	lsl.w	#3,d2
	move.l	(Addr_ThemeMappings).w,a5
	add.w	d2,a5
	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+

loc_F934:
	addq.w	#1,d0
	dbf	d3,loc_F90A
	bra.s	loc_F946
; ---------------------------------------------------------------------------

loc_F93C:
	moveq	#0,d2

loc_F93E:
	move.b	(a3)+,d2
	move.w	d2,(a4)+
	dbf	d3,loc_F93E

loc_F946:
	swap	d6
	swap	d7
	bra.w	loc_F9BA
; ---------------------------------------------------------------------------

loc_F94E:
	cmp.w	d6,d0
	bgt.s	loc_F9A4
	cmp.w	d4,d0
	blt.s	loc_F9A4
	cmp.w	d7,d1
	bgt.s	loc_F9A4
	sub.w	d5,d1
	cmpi.w	#$FFF8,d1
	ble.s	loc_F9A4
	add.w	d5,d1
	lsl.w	#2,d0
	andi.w	#$7C,d0

loc_F96A:
	moveq	#0,d2
	move.b	(a3),d2
	move.w	d2,(a4)
	cmp.w	d5,d1
	blt.s	loc_F994
	cmp.w	d7,d1
	bgt.s	loc_F994
	swap	d2
	move.w	d1,d2
	lsl.w	#8,d2
	andi.w	#$F00,d2
	or.w	d0,d2
	move.w	d2,(a1)+
	swap	d2
	lsl.w	#3,d2
	move.l	(Addr_ThemeMappings).w,a5
	add.w	d2,a5
	move.l	(a5)+,(a1)+
	move.l	(a5)+,(a1)+

loc_F994:
	addq.w	#1,d1
	add.w	(Level_width_blocks).w,a3
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_F96A
	bra.s	loc_F9B6
; ---------------------------------------------------------------------------

loc_F9A4:
	moveq	#0,d2

loc_F9A6:
	move.b	(a3),d2
	move.w	d2,(a4)
	add.w	(Level_width_blocks).w,a3
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_F9A6

loc_F9B6:
	swap	d6
	swap	d7

loc_F9BA:
	move.w	2(a0),d0
	bmi.s	loc_F9CC

loc_F9C0:
	lea	$10(a0),a0
	dbf	d6,loc_F76C
	bra.w	loc_FAC0
; ---------------------------------------------------------------------------

loc_F9CC:
	tst.b	$F(a0)
	bne.w	loc_FA4C
	move.w	$C(a0),d1
	sub.w	d5,d1
	bmi.s	loc_F9C0
	cmpi.w	#$E,d1
	bgt.s	loc_F9C0
	add.w	d5,d1
	moveq	#0,d2
	move.b	$E(a0),d2
	subq.b	#1,d2
	move.w	$A(a0),d0
	move.w	d0,d3
	sub.w	d4,d3
	bmi.s	loc_FA06
	subi.w	#$14,d3
	bgt.s	loc_F9C0
	neg.w	d3
	cmp.w	d2,d3
	bge.s	loc_FA0C
	move.w	d3,d2
	bra.s	loc_FA0C
; ---------------------------------------------------------------------------

loc_FA06:
	add.w	d3,d2
	bmi.s	loc_F9C0
	move.w	d4,d0

loc_FA0C:
	lsl.w	#4,d0
	sub.w	(Camera_X_pos).w,d0
	addi.w	#$80,d0
	lsl.w	#4,d1
	sub.w	(Camera_Y_pos).w,d1
	addi.w	#$80,d1
	move.w	#$24A,d3
	btst	#0,3(a0)
	bne.s	loc_FA2E
	addq.w	#4,d3

loc_FA2E:
	move.w	d1,(a2)+
	addq.w	#1,d7
	move.w	d7,(a2)+
	move.w	d3,(a2)+
	move.w	d0,(a2)+
	addi.w	#$10,d0
	dbf	d2,loc_FA2E

loc_FA40:
	lea	$10(a0),a0
	dbf	d6,loc_F76C
	bra.w	loc_FAC0
; ---------------------------------------------------------------------------

loc_FA4C:
	move.w	$A(a0),d0
	sub.w	d4,d0
	bmi.s	loc_FA40
	cmpi.w	#$14,d0
	bgt.s	loc_FA40
	add.w	d4,d0
	moveq	#0,d2
	move.b	$E(a0),d2
	subq.b	#1,d2
	move.w	$C(a0),d1
	move.w	d1,d3
	sub.w	d5,d3
	bmi.s	loc_FA7E
	subi.w	#$E,d3
	bgt.s	loc_FA40
	neg.w	d3
	cmp.w	d2,d3
	bge.s	loc_FA84
	move.w	d3,d2
	bra.s	loc_FA84
; ---------------------------------------------------------------------------

loc_FA7E:
	add.w	d3,d2
	bmi.s	loc_FA40
	move.w	d5,d1

loc_FA84:
	lsl.w	#4,d0
	sub.w	(Camera_X_pos).w,d0
	addi.w	#$80,d0
	lsl.w	#4,d1
	sub.w	(Camera_Y_pos).w,d1
	addi.w	#$80,d1
	move.w	#$24A,d3
	btst	#0,3(a0)
	bne.s	loc_FAA6
	addq.w	#4,d3

loc_FAA6:
	move.w	d1,(a2)+
	addq.w	#1,d7
	move.w	d7,(a2)+
	move.w	d3,(a2)+
	move.w	d0,(a2)+
	addi.w	#$10,d1
	dbf	d2,loc_FAA6
	lea	$10(a0),a0
	dbf	d6,loc_F76C

loc_FAC0:
	move.b	d7,(Number_Sprites).w
	move.l	a1,($FFFFF8B2).w
	move.l	a2,(Addr_NextSpriteSlot).w

return_FACC:
	rts
; End of function sub_F730


; =============== S U B	R O U T	I N E =======================================


sub_FACE:
	moveq	#0,d1
	move.w	d3,d1
	subi.w	#Level_Layout&$FFFF,d1
	divu.w	(Level_width_tiles).w,d1
	move.w	d1,d2
	swap	d1
	lsr.w	#1,d1
	rts
; End of function sub_FACE

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

loc_FAE2:
	move.l	a0,-(sp)
	lea	($FFFF4A04).l,a0
	move.w	d2,d3
	add.w	d3,d3
	move.w	(a0,d3.w),a0
	move.w	a0,d3
	add.w	d1,d3
	add.w	d1,d3
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

return_FAFC:
	rts
; ---------------------------------------------------------------------------

loc_FAFE:
	movem.l	d4/a0-a1,-(sp)
	move.w	d3,a0
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_FB3E,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	movem.l	(sp)+,d4/a0-a1
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_FB3E:
	move.w	$44(a5),d0
	move.w	$46(a5),d1
	move.l	$48(a5),a0
	move.l	a0,d3
	move.w	d1,d4
	add.w	d4,d4
	lea	($FFFF4BB8).l,a1
	move.w	(a1,d4.w),a1
	addi.l	#$FF0000,a1
	moveq	#0,d4
	move.b	(a1,d0.w),d4
	move.w	d4,(a0)
	move.l	($FFFFF8B6).w,a1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d4,(a1)+
	move.l	a1,($FFFFF8B6).w
	move.b	#$6F,(a0)
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.l	#stru_FD4C,d7
	jsr	(j_Init_Animation).w
	moveq	#5,d0

loc_FB94:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_FB94
	moveq	#5,d1

loc_FBA2:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_FBA2
	moveq	#4,d0

loc_FBB0:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_FBB0
	moveq	#4,d1

loc_FBBE:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_FBBE
	moveq	#3,d0

loc_FBCC:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_FBCC
	moveq	#4,d1

loc_FBDA:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_FBDA
	jsr	(j_sub_105E).w
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	#$EF2C,d0
	bsr.w	sub_11530
	move.w	d1,d4
	lsl.w	#4,d4
	addq.w	#4,d4
	move.w	d4,x_pos(a3)
	move.w	d2,d4
	lsl.w	#4,d4
	addq.w	#7,d4
	move.w	d4,y_pos(a3)
	move.l	#stru_FD10,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	d1,d4
	lsl.w	#4,d4
	addq.w	#8,d4
	move.w	d4,x_pos(a3)
	move.w	d2,d4
	lsl.w	#4,d4
	addq.w	#8,d4
	move.w	d4,y_pos(a3)
	move.l	#stru_FD3A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_FCA6,4(a0)
	jsr	(j_Allocate_PlatformSlot).w
	move.w	a3,$44(a0)
	clr.l	$A(a3)
	move.l	#$FFFF0000,$E(a3)
	move.w	#1,x_direction(a3)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,2(a3)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,6(a3)
	move.w	#$F,x_pos(a3)
	move.w	#7,$1C(a3)
	move.w	#$63,$20(a3)
	move.b	#$88,$1F(a3)
	move.w	#$2C3,$18(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_11542
	jmp	(j_Delete_CurrentObject).w
; End of function sub_FB3E


; =============== S U B	R O U T	I N E =======================================


sub_FCA6:
	move.l	d0,-(sp)
	moveq	#sfx_Elevator_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	$44(a5),a3
	move.w	#0,d1
	move.w	6(a3),d0

loc_FCBE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_FD00
	cmp.w	6(a3),d0
	beq.s	loc_FCD2
	addq.w	#1,d1
	move.w	6(a3),d0

loc_FCD2:
	cmpi.w	#$32,d1
	ble.s	loc_FCE2
	addi.l	#$7D0,$E(a3)
	bra.s	loc_FCEA
; ---------------------------------------------------------------------------

loc_FCE2:
	subi.l	#$708,$E(a3)

loc_FCEA:
	move.w	6(a3),d4
	cmp.w	(Level_height_blocks).w,d4
	blt.w	loc_FCFE
	jsr	(j_Deallocate_PlatformSlot).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_FCFE:
	bra.s	loc_FCBE
; End of function sub_FCA6


; =============== S U B	R O U T	I N E =======================================


sub_FD00:
	move.l	$E(a3),d7
	add.l	d7,6(a3)
	rts
; End of function sub_FD00

; ---------------------------------------------------------------------------
	anim_frame	1, 1, LnkTo_unk_E0ED6-Data_Index
	dc.b 2
	dc.b 5
stru_FD10:
	anim_frame	  1, $28, LnkTo_unk_E0EDE-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0EE6-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0EEE-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0EF6-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0EFE-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0F06-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0F0E-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0F16-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0F1E-Data_Index
	anim_frame	  1, $28, LnkTo_unk_E0F26-Data_Index
	dc.b 0
	dc.b 0
stru_FD3A:
	anim_frame	  1,   4, LnkTo_unk_E0F2E-Data_Index
	anim_frame	  1,   6, LnkTo_unk_E0F36-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_E0F3E-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0F46-Data_Index
	dc.b 0
	dc.b 0
stru_FD4C:
	anim_frame	1, 8, LnkTo_unk_E0ECE-Data_Index
	dc.b 0
	dc.b 0
; ---------------------------------------------------------------------------

diamond_pickup:
	tst.b	$19(a3)
	bne.s	+
	moveq	#sfx_Diamond_prize,d0
	jsr	(j_PlaySound).l

+
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$64,object_meta(a3)
	st	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#5,$A(a3)
	jsr	(j_sub_FF6).w
	move.l	#stru_10D6E,d7
	jsr	(j_Init_Animation).w
	cmpi.w	#$63,(Number_Diamonds).w		; Check if more than max diamonds
	bne.w	Increase_Diamonds
	sf	has_level_collision(a3)
	st	has_kid_collision(a3)
	move.l	(Addr_GfxObject_Kid).w,a4
	move.l	$26(a4),x_vel(a3)
	move.l	#$FFFD0000,y_vel(a3)

-
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$6000,y_vel(a3)
	tst.b	$19(a3)
	beq.s	-
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

Increase_Diamonds:
	move.l	x_pos(a3),d0
	sub.l	(Camera_X_pos).w,d0
	move.l	d0,$3E(a3)
	move.l	y_pos(a3),d0
	sub.l	(Camera_Y_pos).w,d0
	move.l	d0,$42(a3)
	move.l	#$1260000,d0
	sub.l	$3E(a3),d0
	asr.l	#5,d0
	move.l	#$300000,d1
	sub.l	$42(a3),d1
	asr.l	#5,d1
	move.w	#$1F,d2

-
	jsr	(j_Hibernate_Object_1Frame).w
	add.l	d0,$3E(a3)
	add.l	d1,$42(a3)
	move.w	$3E(a3),d4
	add.w	(Camera_X_pos).w,d4
	move.w	d4,x_pos(a3)
	move.w	$42(a3),d4
	add.w	(Camera_Y_pos).w,d4
	move.w	d4,y_pos(a3)
	dbf	d2,-
	addq.w	#1,(Number_Diamonds).w
	cmpi.w	#$14,(Number_Diamonds).w
	bne.w	+
	move.l	d0,-(sp)
	moveq	#sfx_Diamond_Power_available,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

+
	cmpi.w	#$32,(Number_Diamonds).w
	bne.w	+
	move.l	d0,-(sp)
	moveq	#sfx_Diamond_Power_available,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

+
	cmpi.w	#$63,(Number_Diamonds).w
	ble.w	+
	move.w	#$63,(Number_Diamonds).w

+
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_FE7A:
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$64,object_meta(a3)
	st	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#5,$A(a3)
	jsr	(j_sub_FF6).w
	move.l	#stru_10C08,d7
	jsr	(j_Init_Animation).w
	move.l	x_pos(a3),d0
	sub.l	(Camera_X_pos).w,d0
	move.l	d0,$3E(a3)
	move.l	y_pos(a3),d0
	sub.l	(Camera_Y_pos).w,d0
	move.l	d0,$42(a3)
	move.l	#$1270000,d0
	sub.l	$3E(a3),d0
	asr.l	#5,d0
	move.l	#$1F0000,d1
	sub.l	$42(a3),d1
	asr.l	#5,d1
	move.w	#$1F,d2

loc_FEEE:
	jsr	(j_Hibernate_Object_1Frame).w
	add.l	d0,$3E(a3)
	add.l	d1,$42(a3)
	move.w	$3E(a3),d4

loc_FEFE:
	add.w	(Camera_X_pos).w,d4
	move.w	d4,x_pos(a3)
	move.w	$42(a3),d4
	add.w	(Camera_Y_pos).w,d4
	move.w	d4,y_pos(a3)
	dbf	d2,loc_FEEE
	addq.w	#1,(Number_Lives).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_FF1E:
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$64,object_meta(a3)
	st	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#5,$A(a3)
	jsr	(j_sub_FF6).w
	move.l	#stru_10C18,d7
	jsr	(j_Init_Animation).w
	move.l	x_pos(a3),d0
	sub.l	(Camera_X_pos).w,d0
	move.l	d0,$3E(a3)
	move.l	y_pos(a3),d0
	sub.l	(Camera_Y_pos).w,d0
	move.l	d0,$42(a3)
	move.l	#$380000,d0
	sub.l	$3E(a3),d0
	asr.l	#5,d0
	move.l	#$1F0000,d1
	sub.l	$42(a3),d1
	asr.l	#5,d1
	move.w	#$1F,d2

loc_FF92:
	jsr	(j_Hibernate_Object_1Frame).w
	add.l	d0,$3E(a3)
	add.l	d1,$42(a3)
	move.w	$3E(a3),d4
	add.w	(Camera_X_pos).w,d4
	move.w	d4,x_pos(a3)
	move.w	$42(a3),d4
	add.w	(Camera_Y_pos).w,d4
	move.w	d4,y_pos(a3)
	dbf	d2,loc_FF92
	addq.w	#1,(Time_Seconds_low_digit).w
	cmpi.w	#$A,(Time_Seconds_low_digit).w
	bne.s	loc_FFDE
	clr.w	(Time_Seconds_low_digit).w
	addq.w	#1,(Time_Seconds_high_digit).w
	cmpi.w	#6,(Time_Seconds_high_digit).w
	bne.s	loc_FFDE
	clr.w	(Time_Seconds_high_digit).w
	addq.w	#1,(Time_Minutes).w

loc_FFDE:
	move.w	(Time_Minutes).w,d7
	addq.w	#3,d7	; Clocks are worth 3 minutes
	cmpi.w	#10,d7
	blt.w	+
	
	; If timer is above 10 minutes, reset it to 10 minutes
	move.w	#10,d7
	clr.w	(Time_Seconds_low_digit).w
	clr.w	(Time_Seconds_high_digit).w

+
	move.w	d7,(Time_Minutes).w

loc_FFFC:
	move.w	#1,(Time_SubSeconds).w

loc_10002:
	addq.w	#1,(Clocks_collected).w
	move.w	#$96,d3

loc_1000A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	$3E(a3),d4
	add.w	(Camera_X_pos).w,d4
	move.w	d4,x_pos(a3)
	move.w	$42(a3),d4

loc_1001E:
	add.w	(Camera_Y_pos).w,d4
	move.w	d4,y_pos(a3)
	dbf	d3,loc_1000A
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

loc_1002E:
	move.l	d0,-(sp)
	moveq	#sfx_Block_hit,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	movem.l	d4/a0-a1,-(sp)
	move.w	d3,a0
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_1007A,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	movem.l	(sp)+,d4/a0-a1
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_1007A:
	move.w	$44(a5),d0
	move.w	$46(a5),d1
	move.l	$48(a5),a0
	cmpi.b	#1,1(a0)
	beq.w	loc_101D8
	move.l	a0,d3
	move.w	d1,d4
	add.w	d4,d4
	lea	($FFFF4BB8).l,a1
	move.w	(a1,d4.w),a1
	addi.l	#$FF0000,a1
	moveq	#0,d4
	move.b	(a1,d0.w),d4
	move.w	d4,(a0)
	move.l	($FFFFF8B6).w,a1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d4,(a1)+
	move.l	a1,($FFFFF8B6).w
	move.b	#$6F,(a0)
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.l	#stru_101B6,d7
	jsr	(j_Init_Animation).w
	moveq	#5,d0

loc_100DA:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_100DA
	moveq	#5,d1

loc_100E8:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_100E8
	moveq	#4,d0

loc_100F6:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_100F6
	moveq	#4,d1

loc_10104:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_10104
	moveq	#3,d0

loc_10112:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_10112
	moveq	#4,d1

loc_10120:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_10120
	jsr	(j_sub_105E).w
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	#$E001,d0
	bsr.w	sub_11530
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#loc_102B8,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	addq.w	#8,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	subq.w	#8,d4
	move.w	d4,$1E(a1)
	move.w	#$1FFF,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#loc_10330,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	addq.w	#8,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_101B6:
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	dc.b 0
	dc.b 0
; ---------------------------------------------------------------------------

loc_101D8:
	move.l	a0,d3
	move.w	d1,d4
	add.w	d4,d4
	lea	($FFFF4BB8).l,a1
	move.w	(a1,d4.w),a1
	addi.l	#$FF0000,a1
	moveq	#0,d4
	move.b	(a1,d0.w),d4
	move.w	d4,(a0)
	move.l	($FFFFF8B6).w,a1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d4,(a1)+

loc_10200:
	move.l	a1,($FFFFF8B6).w
	move.b	#$6F,(a0)
	move.l	$36(a5),a3
	st	$13(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Block_hit,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#stru_10296,d7
	jsr	(j_Init_Animation).w
	moveq	#5,d0

loc_10228:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_10228
	moveq	#5,d1

loc_10236:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_10236
	moveq	#4,d0

loc_10244:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_10244
	moveq	#4,d1

loc_10252:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_10252
	moveq	#3,d0

loc_10260:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_10260
	moveq	#4,d1

loc_1026E:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_1026E
	jsr	(j_sub_105E).w
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	#$E102,d0
	bsr.w	sub_11530
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_10296:
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E4E-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E0E5E-Data_Index
	dc.b 0
	dc.b 0
; ---------------------------------------------------------------------------

loc_102B8:
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	#(LnkTo_unk_E0F2E-Data_Index),addroffset_sprite(a3)
	move.l	#stru_102DE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_102DE:
	anim_frame	  1,   4, LnkTo_unk_E0F2E-Data_Index
	anim_frame	  1,   6, LnkTo_unk_E0F36-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_E0F3E-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0F46-Data_Index
	dc.b 0
	dc.b 0
off_102F0:	; code to load prize object from prize block
	dc.l loc_10354	; 0 - Diamond
	dc.l loc_10A90	; 1 - 10000 points
	dc.l loc_10436	; 2 - Helmet (skycutter)
	dc.l loc_10480	; 3 - Helmet (cyclone)
	dc.l loc_104CA	; 4 - Helmet (red stealth)
	dc.l loc_10514	; 5 - Helmet (eyeclops)
	dc.l loc_1055E	; 6 - Helmet (juggernaut)
	dc.l loc_105A8	; 7 - Helmet (iron knight)
	dc.l loc_105F2	; 8 - Helmet (berzerker)
	dc.l loc_1063C	; 9 - Helmet (maniaxe)
	dc.l loc_10686	; A - Helmet (micromax)
	dc.l loc_10706	; B - 1-up
	dc.l loc_1076C	; C - Time
	dc.l loc_107F2	; D - Continue
	dc.l loc_108CA	; E - 10 diamonds
	dc.l loc_10354	; F - Same as 0
; ---------------------------------------------------------------------------

; load prize object from prize block.
loc_10330:
	move.l	$36(a5),a3
	clr.w	object_meta(a3)
	move.l	$48(a5),d2
	move.l	($FFFFF8D4).w,a1
	bra.s	loc_10344
; ---------------------------------------------------------------------------

loc_10342:
	addq.w	#8,a1

loc_10344:
	cmp.w	(a1),d2
	bne.s	loc_10342
	addq.w	#6,a1
	move.w	(a1),d7
	asl.w	#2,d7
	move.l	off_102F0(pc,d7.w),a4
	jmp	(a4)
; End of function sub_1007A

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_10848

loc_10354:

	sf	is_moved(a3)
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	#$64,object_meta(a3)
	move.w	#$1F4,d3
	swap	d3
	move.w	#1,d3
	swap	d3
	move.w	y_pos(a3),d0
	andi.w	#$FFF0,d0
	move.l	#0,d1
	move.b	#0,$12(a3)
	move.l	$48(a5),a2
	move.l	#stru_10D6E,d7
	jsr	(j_Init_Animation).w

loc_10396:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d3
	beq.w	loc_10430
	cmpi.w	#$C8,d3
	bne.w	loc_103B2
	move.l	#stru_10D80,d7
	jsr	(j_Init_Animation).w

loc_103B2:
	move.w	(a2),d4
	andi.w	#$7000,d4
	beq.s	loc_103DE
	cmpi.w	#$2000,d4
	beq.s	loc_103DE
	btst	#$10,d3
	beq.s	loc_103DA
	move.w	(Level_width_tiles).w,d4
	move.w	(a2,d4.w),d4
	andi.w	#$7000,d4
	beq.s	loc_103DE
	cmpi.w	#$2000,d4
	beq.s	loc_103DE

loc_103DA:
	moveq	#0,d1
	bra.s	loc_10404
; ---------------------------------------------------------------------------

loc_103DE:
	addi.l	#$1388,d1
	move.l	y_pos(a3),d2
	add.l	d1,d2
	move.l	d2,y_pos(a3)
	swap	d2
	move.w	d2,d5
	andi.w	#$FFF0,d2
	cmp.w	d2,d0
	beq.s	loc_10402
	bclr	#$10,d3
	add.w	(Level_width_tiles).w,a2

loc_10402:
	move.w	d2,d0

loc_10404:
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10430
	tst.w	collision_type(a3)
	beq.s	loc_10396
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#diamond_pickup,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)

loc_10430:
	jmp	(j_Delete_CurrentObject).w
; END OF FUNCTION CHUNK	FOR sub_10848
; ---------------------------------------------------------------------------

loc_10434:
	bra.s	loc_10434
; ---------------------------------------------------------------------------

loc_10436:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1D02).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$6C,object_meta(a3)
	move.l	#stru_106DC,d7
	jsr	(j_Init_Animation).w

loc_10464:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_1047C
	tst.w	collision_type(a3)
	beq.s	loc_10464

loc_1047C:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_10480:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1E34).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$70,object_meta(a3)
	move.l	#stru_106E8,d7
	jsr	(j_Init_Animation).w

loc_104AE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_104C6
	tst.w	collision_type(a3)
	beq.s	loc_104AE

loc_104C6:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_104CA:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1DBC).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$74,object_meta(a3)
	move.l	#stru_106F4,d7
	jsr	(j_Init_Animation).w

loc_104F8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10510
	tst.w	collision_type(a3)
	beq.s	loc_104F8

loc_10510:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_10514:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1DF8).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$78,object_meta(a3)
	move.l	#stru_106EE,d7
	jsr	(j_Init_Animation).w

loc_10542:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_1055A
	tst.w	collision_type(a3)
	beq.s	loc_10542

loc_1055A:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1055E:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1E70).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$7C,object_meta(a3)
	move.l	#stru_106D6,d7
	jsr	(j_Init_Animation).w

loc_1058C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_105A4
	tst.w	collision_type(a3)
	beq.s	loc_1058C

loc_105A4:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_105A8:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1EAC).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$80,object_meta(a3)
	move.l	#stru_106FA,d7
	jsr	(j_Init_Animation).w

loc_105D6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_105EE
	tst.w	collision_type(a3)
	beq.s	loc_105D6

loc_105EE:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_105F2:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1D80).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$84,object_meta(a3)
	move.l	#stru_106E2,d7
	jsr	(j_Init_Animation).w

loc_10620:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10638
	tst.w	collision_type(a3)
	beq.s	loc_10620

loc_10638:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1063C:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1CA2).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$88,object_meta(a3)
	move.l	#stru_106D0,d7
	jsr	(j_Init_Animation).w

loc_1066A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10682
	tst.w	collision_type(a3)
	beq.s	loc_1066A

loc_10682:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_10686:
	movem.l	a4-a5,-(sp)
	move.l	(LnkTo_Pal_A1D44).l,a5
	lea	(Palette_Buffer+$7A).l,a4
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	move.w	(a5)+,(a4)+
	movem.l	(sp)+,a4-a5
	bsr.w	sub_10CB0
	move.w	#$8C,object_meta(a3)
	move.l	#stru_10700,d7
	jsr	(j_Init_Animation).w

loc_106B4:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_106CC
	tst.w	collision_type(a3)
	beq.s	loc_106B4

loc_106CC:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_106D0:
	anim_frame	1, 1, LnkTo_unk_A5AB6-Data_Index
	dc.b 2
	dc.b 5
stru_106D6:
	anim_frame	1, 1, LnkTo_unk_C1A5C-Data_Index
	dc.b 2
	dc.b 5
stru_106DC:
	anim_frame	1, 1, LnkTo_unk_A96C4-Data_Index
	dc.b 2
	dc.b 5
stru_106E2:
	anim_frame	1, 1, LnkTo_unk_AFF56-Data_Index
	dc.b 2
	dc.b 5
stru_106E8:
	anim_frame	1, 1, LnkTo_unk_BACEC-Data_Index
	dc.b 2
	dc.b 5
stru_106EE:
	anim_frame	1, 1, LnkTo_unk_B7668-Data_Index
	dc.b 2
	dc.b 5
stru_106F4:
	anim_frame	1, 1, LnkTo_unk_B3FB8-Data_Index
	dc.b 2
	dc.b 5
stru_106FA:
	anim_frame	1, 1, LnkTo_unk_C2324-Data_Index
	dc.b 2
	dc.b 5
stru_10700:
	anim_frame	1, 1, LnkTo_unk_ABA68-Data_Index
	dc.b 2
	dc.b 5
; ---------------------------------------------------------------------------

loc_10706:
	bsr.w	sub_10848
	move.w	#$90,object_meta(a3)
	bsr.w	sub_10C78
	move.l	#stru_10C08,d7
	jsr	(j_Init_Animation).w

loc_1071E:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d3
	beq.s	loc_10768
	cmpi.w	#$12C,d3
	bne.w	loc_10738
	move.l	#stru_10C0E,d7
	jsr	(j_Init_Animation).w

loc_10738:
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10768
	tst.w	collision_type(a3)
	beq.s	loc_1071E
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_FE7A,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)

loc_10768:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1076C:
	move.w	#$94,object_meta(a3)
	bsr.w	sub_10C78
	move.l	#stru_10C18,d7
	jsr	(j_Init_Animation).w
	tst.b	($FFFFFB55).w
	bne.s	loc_10792
	move.l	d0,-(sp)
	moveq	#sfx_Clock_prize,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_10792:
	addq.b	#1,($FFFFFB55).w

loc_10796:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d3
	beq.s	loc_107E0
	cmpi.w	#$12C,d3
	bne.w	loc_107B0
	move.l	#stru_10C1E,d7
	jsr	(j_Init_Animation).w

loc_107B0:
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_107E0
	tst.w	collision_type(a3)
	beq.s	loc_10796
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_FF1E,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)

loc_107E0:
	subq.b	#1,($FFFFFB55).w
	bne.s	loc_107EE
	moveq	#sfx_Clock_prize,d0
	jsr	(j_PlaySound2).l

loc_107EE:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_107F2:
	bsr.w	sub_10848
	move.w	#$98,object_meta(a3)
	bsr.w	sub_10C78
	move.l	#stru_10C28,d7
	jsr	(j_Init_Animation).w

loc_1080A:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d3
	beq.s	loc_10838
	cmpi.w	#$12C,d3
	bne.w	loc_10824
	move.l	#stru_10C2E,d7
	jsr	(j_Init_Animation).w

loc_10824:
	bsr.w	sub_10C38
	move.w	(Level_height_blocks).w,d4
	cmp.w	y_pos(a3),d4
	ble.s	loc_10838
	tst.w	collision_type(a3)
	beq.s	loc_1080A

loc_10838:
	move.l	d0,-(sp)
	moveq	#$6A,d0 ; picking up coin prize only no sound
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_10848:

; FUNCTION CHUNK AT 00010354 SIZE 000000E0 BYTES

	lea	($FFFFFC84).w,a0
	tst.b	($FFFFFC39).w
	beq.s	loc_10856
	lea	($FFFFFD26).w,a0

loc_10856:
	tst.w	(a0)
	bpl.s	loc_1086A
	lea	2(a0),a1
	moveq	#$27,d0
	moveq	#0,d1
	move.w	d1,(a0)

loc_10864:
	move.l	d1,(a1)+
	dbf	d0,loc_10864

loc_1086A:
	move.w	#$27,d0
	move.w	$4A(a5),d1
	lea	2(a0),a1

loc_10876:
	cmp.w	(a1),d1
	bne.s	loc_10886
	move.w	(Current_LevelID).w,d2
	cmp.w	2(a1),d2
	beq.w	loc_10354

loc_10886:
	addq.w	#4,a1
	dbf	d0,loc_10876
	move.w	(a0),d0
	move.w	d0,d1
	addq.w	#1,d1
	cmpi.w	#$28,d1
	blt.s	loc_1089A
	moveq	#0,d1

loc_1089A:
	move.w	d1,(a0)
	lsl.w	#2,d0
	move.w	$4A(a5),2(a0,d0.w)
	move.w	(Current_LevelID).w,4(a0,d0.w)
	rts
; End of function sub_10848

; ---------------------------------------------------------------------------
byte_108AC:	dc.b 0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   9
; ---------------------------------------------------------------------------

loc_108CA:
	bsr.w	sub_10848
	move.l	x_pos(a3),$6C(a5)
	move.l	y_pos(a3),$70(a5)
	jsr	(j_loc_1078).w
	moveq	#0,d3
	lea	$44(a5),a2
	move.l	a2,a0
	moveq	#9,d0

loc_108E8:
	clr.l	(a0)+
	dbf	d0,loc_108E8

loc_108EE:
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#$1E,d3
	bge.s	loc_10960
	moveq	#0,d0
	move.b	byte_108AC(pc,d3.w),d0
	bmi.s	loc_10960
	move.l	#$FE0000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	d0,-(sp)
	moveq	#sfx_Diamond_prize,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.b	#1,$10(a1)
	st	$13(a1)
	move.w	#(LnkTo_unk_E1046-Data_Index),$22(a1)
	lsl.w	#2,d0
	lea	unk_10A52(pc),a3
	move.w	$6C(a5),$1A(a1)
	move.w	$70(a5),$1E(a1)
	move.w	(a3,d0.w),d1
	swap	d1
	clr.w	d1
	asr.l	#3,d1
	move.l	d1,$26(a1)
	move.w	2(a3,d0.w),d1
	swap	d1
	clr.w	d1
	asr.l	#3,d1
	move.l	d1,$2A(a1)
	st	$14(a1)
	move.w	#$78,$46(a1)
	move.l	a1,(a2)+

loc_10960:
	moveq	#0,d2

loc_10962:
	move.l	$44(a5,d2.w),d0
	beq.w	loc_10A3A
	move.l	d0,a1
	move.w	$46(a1),d0
	cmpi.w	#$20,d0
	beq.s	loc_10988
	blt.w	loc_109C0
	cmpi.w	#$70,d0
	bne.s	loc_10984
	sf	$14(a1)

loc_10984:
	bra.w	loc_109E8
; ---------------------------------------------------------------------------

loc_10988:
	move.l	$1A(a1),d0
	sub.l	(Camera_X_pos).w,d0
	move.l	d0,$3E(a1)
	move.l	$1E(a1),d0
	sub.l	(Camera_Y_pos).w,d0
	move.l	d0,$42(a1)
	move.l	#$1260000,d0
	sub.l	$3E(a1),d0
	asr.l	#5,d0
	move.l	d0,$26(a1)
	move.l	#$300000,d1
	sub.l	$42(a1),d1
	asr.l	#5,d1
	move.l	d1,$2A(a1)

loc_109C0:
	move.l	$26(a1),d0
	add.l	d0,$3E(a1)
	move.l	$2A(a1),d0
	add.l	d0,$42(a1)
	move.w	$3E(a1),d0
	add.w	(Camera_X_pos).w,d0
	move.w	d0,$1A(a1)
	move.w	$42(a1),d0
	add.w	(Camera_Y_pos).w,d0
	move.w	d0,$1E(a1)

loc_109E8:										; Could be 10-diamond pickup increment
	subq.w	#1,$46(a1)
	bne.s	loc_10A3A
	addq.w	#1,(Number_Diamonds).w
	cmpi.w	#$14,(Number_Diamonds).w
	bne.w	+
	move.l	d0,-(sp)
	moveq	#sfx_Diamond_Power_available,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

+
	cmpi.w	#$32,(Number_Diamonds).w
	bne.w	+
	move.l	d0,-(sp)
	moveq	#sfx_Diamond_Power_available,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

+
	cmpi.w	#$63,(Number_Diamonds).w
	ble.w	+
	move.w	#$63,(Number_Diamonds).w

+
	exg	a1,a3
	jsr	(j_loc_1078).w
	clr.l	$44(a5,d2.w)
	exg	a1,a3

loc_10A3A:
	addq.w	#4,d2
	cmpi.w	#$28,d2
	bne.w	loc_10962
	addq.w	#1,d3
	cmpi.w	#$118,d3
	bne.w	loc_108EE
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
unk_10A52:	dc.b $FF
	dc.b $EC ; �
	dc.b $FF
	dc.b $DC ; �
	dc.b $FF
	dc.b $EC ; �
	dc.b $FF
	dc.b $E5 ; �
	dc.b $FF
	dc.b $EC ; �
	dc.b $FF
	dc.b $EE ; �
	dc.b $FF
	dc.b $EC ; �
	dc.b $FF
	dc.b $F7 ; �
	dc.b   0
	dc.b   6
	dc.b $FF
	dc.b $DC ; �
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $E4 ; �
	dc.b   0
	dc.b $10
	dc.b $FF
	dc.b $E4 ; �
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $F0 ; �
	dc.b   0
	dc.b $10
	dc.b $FF
	dc.b $F0 ; �
	dc.b   0
	dc.b   6
	dc.b $FF
	dc.b $F8 ; �
unk_10A7A:	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   1
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   2
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   3
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b   4
	dc.b   0
; ---------------------------------------------------------------------------

loc_10A90:
	bsr.w	sub_10848
	move.l	(Score).w,d0
	move.l	d0,d1
	addi.l	#$2710,d1
	cmpi.l	#$98967F,d1
	blt.s	loc_10AAE
	move.l	#$98967F,d1

loc_10AAE:
	move.l	d1,(Score).w
	divu.w	#$C350,d0
	divu.w	#$C350,d1
	cmp.w	d0,d1
	beq.s	loc_10AC2
	addq.w	#1,(Number_Lives).w

loc_10AC2:
	cmpi.l	#$186A0,(Score).w
	blt.s	loc_10AE0
	cmpi.w	#HundredKTripStart_LevelID,(Current_LevelID).w
	bne.s	loc_10AE0
	tst.w	($FFFFFB4C).w
	bne.s	loc_10AE0
	move.w	#$3C,($FFFFFB4C).w

loc_10AE0:
	move.l	x_pos(a3),$6C(a5)
	move.l	y_pos(a3),$70(a5)
	jsr	(j_loc_1078).w
	moveq	#0,d3
	lea	$44(a5),a2
	move.l	a2,a0
	moveq	#4,d0

loc_10AFA:
	clr.l	(a0)+
	dbf	d0,loc_10AFA

loc_10B00:
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#$15,d3
	bge.s	loc_10B74
	moveq	#0,d0
	lea	unk_10A7A(pc),a1
	move.b	(a1,d3.w),d0
	bmi.s	loc_10B74
	move.l	#$FE0000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.b	#1,$10(a1)
	st	$13(a1)
	move.w	#(LnkTo_unk_E104E-Data_Index),$22(a1)
	tst.w	d3
	bne.s	loc_10B3A
	move.w	#(LnkTo_unk_E1056-Data_Index),$22(a1)

loc_10B3A:
	lsl.w	#2,d0
	lea	unk_10BF4(pc),a3
	move.w	$6C(a5),$1A(a1)
	move.w	$70(a5),$1E(a1)
	move.w	(a3,d0.w),d1
	swap	d1
	clr.w	d1
	asr.l	#3,d1
	move.l	d1,$26(a1)
	move.w	2(a3,d0.w),d1
	swap	d1
	clr.w	d1
	asr.l	#3,d1
	move.l	d1,$2A(a1)
	st	$14(a1)
	move.w	#$78,$46(a1)
	move.l	a1,(a2)+

loc_10B74:
	moveq	#0,d2

loc_10B76:
	move.l	$44(a5,d2.w),d0
	beq.w	loc_10BCE
	move.l	d0,a1
	move.w	$46(a1),d0
	cmpi.w	#$20,d0
	beq.s	loc_10B9A
	blt.w	loc_10BB2
	cmpi.w	#$70,d0
	bne.s	loc_10B98
	sf	$14(a1)

loc_10B98:
	bra.s	loc_10BCA
; ---------------------------------------------------------------------------

loc_10B9A:
	move.w	$1A(a1),d0
	sub.w	(Camera_X_pos).w,d0
	move.w	d0,$3E(a1)
	move.w	$1E(a1),d0
	sub.w	(Camera_Y_pos).w,d0
	move.w	d0,$42(a1)

loc_10BB2:
	subq.w	#6,$1A(a1)
	cmpi.w	#$10,d2
	bne.s	loc_10BCA
	move.w	$1A(a1),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FFE0,d0
	blt.s	loc_10BE0

loc_10BCA:
	subq.w	#1,$46(a1)

loc_10BCE:
	addq.w	#4,d2
	cmpi.w	#$14,d2
	bne.s	loc_10B76
	addq.w	#1,d3
	cmpi.w	#$118,d3
	bne.w	loc_10B00

loc_10BE0:
	lea	$44(a5),a2
	moveq	#4,d0

loc_10BE6:
	move.l	(a2)+,a3
	jsr	(j_loc_1078).w
	dbf	d0,loc_10BE6
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
unk_10BF4:	dc.b $FF
	dc.b $F0 ; �
	dc.b $FF
	dc.b $EC ; �
	dc.b $FF
	dc.b $F8 ; �
	dc.b $FF
	dc.b $EC ; �
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $EC ; �
	dc.b   0
	dc.b   8
	dc.b $FF
	dc.b $EC ; �
	dc.b   0
	dc.b $10
	dc.b $FF
	dc.b $EC ; �
stru_10C08:
	anim_frame	1, 1, LnkTo_unk_E0FE6-Data_Index
	dc.b 2
	dc.b 5
stru_10C0E:
	anim_frame	1, 6, LnkTo_unk_E0FE6-Data_Index
	anim_frame	1, 6, 0
	dc.b 2
	dc.b 9
stru_10C18:
	anim_frame	1, 1, LnkTo_unk_E0FCE-Data_Index
	dc.b 2
	dc.b 5
stru_10C1E:
	anim_frame	1, 6, LnkTo_unk_E0FCE-Data_Index
	anim_frame	1, 6, 0
	dc.b 2
	dc.b 9
stru_10C28:
	anim_frame	1, 1, LnkTo_unk_E0FD6-Data_Index
	dc.b 2
	dc.b 5
stru_10C2E:
	anim_frame	1, 6, LnkTo_unk_E0FD6-Data_Index
	anim_frame	1, 6, 0
	dc.b 2
	dc.b 9

; =============== S U B	R O U T	I N E =======================================


sub_10C38:
	btst	#$10,d3
	bne.s	loc_10C50
	move.w	(a2),d4
	andi.w	#$7000,d4
	beq.s	loc_10C50
	cmpi.w	#$2000,d4
	beq.s	loc_10C50
	moveq	#0,d1
	bra.s	return_10C76
; ---------------------------------------------------------------------------

loc_10C50:
	addi.l	#$1388,d1
	move.l	y_pos(a3),d2
	add.l	d1,d2
	move.l	d2,y_pos(a3)
	swap	d2
	move.w	d2,d5
	andi.w	#$FFF0,d2
	cmp.w	d2,d0
	beq.s	loc_10C74
	bclr	#$10,d3
	add.w	(Level_width_tiles).w,a2

loc_10C74:
	move.w	d2,d0

return_10C76:
	rts
; End of function sub_10C38


; =============== S U B	R O U T	I N E =======================================


sub_10C78:
	st	is_moved(a3)
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	#$1E,d0
	move.w	#$320,d3
	swap	d3
	move.w	#1,d3
	swap	d3
	move.w	y_pos(a3),d0
	andi.w	#$FFF0,d0
	move.l	#0,d1
	move.b	#0,$12(a3)
	move.l	$48(a5),a2
	rts
; End of function sub_10C78


; =============== S U B	R O U T	I N E =======================================


sub_10CB0:
	st	is_moved(a3)
	st	$13(a3)
	move.b	#3,palette_line(a3)
	move.w	#$1E,d0
	move.w	#$320,d3
	swap	d3
	move.w	#1,d3
	swap	d3
	move.w	y_pos(a3),d0
	andi.w	#$FFF0,d0
	move.l	#0,d1
	move.b	#1,$12(a3)
	move.l	$48(a5),a2
	bsr.w	sub_10CEC
	rts
; End of function sub_10CB0


; =============== S U B	R O U T	I N E =======================================


sub_10CEC:
	movem.l	d7-a0,-(sp)
	lea	($FFFFF86E).w,a0

loc_10CF4:
	move.l	4(a0),d7
	beq.w	loc_10D38
	move.l	d7,a0
	move.w	$3A(a0),d7
	cmpi.w	#$6C,d7
	blt.s	loc_10CF4
	cmpi.w	#$8C,d7
	bgt.s	loc_10CF4
	move.w	$1A(a0),d7
	move.w	$1E(a0),d6
	subq.w	#8,d6
	move.l	$C(a0),a0
	jsr	(j_Delete_Object_a0).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_10D3E,4(a0)
	move.w	d7,$44(a0)
	move.w	d6,$46(a0)

loc_10D38:
	movem.l	(sp)+,d7-a0
	rts
; End of function sub_10CEC


; =============== S U B	R O U T	I N E =======================================


sub_10D3E:
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	clr.w	vram_tile(a3)
	st	$13(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.l	#stru_102DE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_10D3E

; ---------------------------------------------------------------------------
stru_10D6E:
	anim_frame	  1,   3, LnkTo1_unk_E0E66-Data_Index
	anim_frame	  1,   3, LnkTo2_unk_E0E66-Data_Index
	anim_frame	  1,   3, LnkTo3_unk_E0E66-Data_Index
	anim_frame	  1,   3, LnkTo4_unk_E0E66-Data_Index
	dc.b 2
	dc.b $11
stru_10D80:
	anim_frame	  1,   3, LnkTo1_unk_E0E66-Data_Index
	anim_frame	  1,   3, 0
	anim_frame	  1,   3, LnkTo2_unk_E0E66-Data_Index
	anim_frame	  1,   3, 0
	anim_frame	  1,   3, LnkTo3_unk_E0E66-Data_Index
	anim_frame	  1,   3, 0
	anim_frame	  1,   3, LnkTo4_unk_E0E66-Data_Index
	anim_frame	  1,   3, 0
	dc.b 2
	dc.b $21
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

return_10DA2:
	rts
; ---------------------------------------------------------------------------

loc_10DA4:
	move.l	d0,-(sp)
	moveq	#sfx_Rubber_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	cmpi.w	#$A,($FFFFFB5A).w
	bge.s	return_10DE2
	addq.w	#1,($FFFFFB5A).w
	movem.l	d4/a0-a1,-(sp)
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_10DE4,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	move.w	d3,a1
	move.l	a1,$48(a0)
	movem.l	(sp)+,d4/a0-a1

return_10DE2:
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_10DE4:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.b	1(a1),d0
	cmpi.b	#$C,d0
	beq.s	loc_10E06
	cmpi.b	#$D,d0
	beq.s	loc_10E06
	move.w	#$E60E,d0
	bra.s	loc_10E0A
; ---------------------------------------------------------------------------

loc_10E06:
	move.w	#$E60C,d0

loc_10E0A:
	addq.w	#1,d0
	bsr.w	sub_11530
	subq.w	#1,d0
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11530
	move.w	#1,-(sp)
	jsr	(j_Hibernate_Object).w
	addq.w	#1,d0
	bsr.w	sub_11530
	subq.w	#1,d0
	move.w	#1,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11530
	move.w	#1,-(sp)
	jsr	(j_Hibernate_Object).w
	addq.w	#1,d0
	bsr.w	sub_11530
	subq.w	#1,d0
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11530
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	addq.w	#1,d0
	bsr.w	sub_11530
	subq.w	#1,d0
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11530
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11530
	subq.w	#1,($FFFFFB5A).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_10DE4


; =============== S U B	R O U T	I N E =======================================


sub_10E86:

	move.l	d0,-(sp)
	moveq	#sfx_Destroy_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	movem.l	d4/a0-a1,-(sp)
	move.w	d3,a0
	or.b	#$F,(a0)
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_10EDA,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d6,$4C(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	movem.l	(sp)+,d4/a0-a1
	rts
; End of function sub_10E86


; =============== S U B	R O U T	I N E =======================================


sub_10EDA:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	$4C(a5),d6
	bsr.w	sub_11542
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	#(LnkTo_unk_E0E4E-Data_Index),addroffset_sprite(a3)
	cmpi.w	#3,d6
	beq.s	loc_10F26
	cmpi.w	#2,d6
	beq.s	loc_10F1A
	cmpi.w	#1,d6
	beq.s	loc_10F20
	addq.w	#4,y_pos(a3)
	bra.s	loc_10F2A
; ---------------------------------------------------------------------------

loc_10F1A:
	subq.w	#4,y_pos(a3)
	bra.s	loc_10F2A
; ---------------------------------------------------------------------------

loc_10F20:
	subq.w	#4,x_pos(a3)
	bra.s	loc_10F2A
; ---------------------------------------------------------------------------

loc_10F26:
	addq.w	#4,x_pos(a3)

loc_10F2A:
	move.w	#(LnkTo_unk_E0E56-Data_Index),addroffset_sprite(a3)
	move.w	#2,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	$4C(a5),d6
	jsr	(j_sub_292E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_10EDA


; =============== S U B	R O U T	I N E =======================================


sub_10F44:

	move.l	d0,-(sp)
	moveq	#sfx_Prize_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bsr.w	sub_11006
	movem.l	d4/a0-a1,-(sp)
	move.w	d3,a0
	or.b	#$F,(a0)
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_10F9C,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d6,$4C(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	movem.l	(sp)+,d4/a0-a1
	rts
; End of function sub_10F44


; =============== S U B	R O U T	I N E =======================================


sub_10F9C:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	$4C(a5),d6
	bsr.w	sub_11542
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.w	#(LnkTo_unk_E0E6E-Data_Index),addroffset_sprite(a3)
	cmpi.w	#3,d6
	beq.s	loc_10FE8
	cmpi.w	#2,d6
	beq.s	loc_10FDC
	cmpi.w	#1,d6
	beq.s	loc_10FE2
	addq.w	#4,y_pos(a3)
	bra.s	loc_10FEC
; ---------------------------------------------------------------------------

loc_10FDC:
	subq.w	#4,y_pos(a3)
	bra.s	loc_10FEC
; ---------------------------------------------------------------------------

loc_10FE2:
	subq.w	#4,x_pos(a3)
	bra.s	loc_10FEC
; ---------------------------------------------------------------------------

loc_10FE8:
	addq.w	#4,x_pos(a3)

loc_10FEC:
	move.w	#(LnkTo_unk_E0E76-Data_Index),addroffset_sprite(a3)
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	$4C(a5),d6
	jsr	(j_sub_292E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_10F9C


; =============== S U B	R O U T	I N E =======================================


sub_11006:
	movem.l	d1-d2/d4/a0-a1,-(sp)
	eori.w	#2,d6
	move.w	d3,a0
	tst.w	d6
	bne.s	loc_11020
	tst.w	d2
	beq.w	loc_11080
	suba.w	(Level_width_tiles).w,a0
	bra.s	loc_11052
; ---------------------------------------------------------------------------

loc_11020:
	cmpi.w	#2,d6
	bge.s	loc_11036
	move.w	d1,d4
	addq.w	#1,d4
	cmp.w	(Level_width_blocks).w,d4
	bge.w	loc_11080
	addq.w	#2,a0
	bra.s	loc_11052
; ---------------------------------------------------------------------------

loc_11036:
	bne.s	loc_1104A
	move.w	d2,d4
	addq.w	#1,d4
	cmp.w	(Level_height_pixels).w,d4
	bge.w	loc_11080
	add.w	(Level_width_tiles).w,a0
	bra.s	loc_11052
; ---------------------------------------------------------------------------

loc_1104A:
	tst.w	d1
	beq.w	loc_11080
	subq.w	#2,a0

loc_11052:
	btst	#6,(a0)
	bne.w	loc_11080
	lsl.w	#4,d1
	addq.w	#8,d1
	lsl.w	#4,d2
	addq.w	#8,d2
	move.w	d6,d4
	lsl.w	#3,d4
	lea	unk_1108A(pc,d4.w),a1
	bsr.s	sub_110AA
	add.w	(a1)+,d1
	add.w	(a1)+,d2
	bsr.s	sub_110AA
	subq.w	#1,-2(a0)
	add.w	(a1)+,d1
	add.w	(a1)+,d2
	bsr.s	sub_110AA
	subq.w	#1,-2(a0)

loc_11080:
	eori.w	#2,d6
	movem.l	(sp)+,d1-d2/d4/a0-a1
	rts
; End of function sub_11006

; ---------------------------------------------------------------------------
unk_1108A:	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $FC ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   4
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $F8 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $F8 ; �

; =============== S U B	R O U T	I N E =======================================


sub_110AA:
	move.w	($FFFFF8CC).w,d4
	beq.s	return_110CE
	move.w	d4,a0
	move.w	$A(a0),($FFFFF8CC).w
	move.w	($FFFFF8CA).w,$A(a0)
	move.w	a0,($FFFFF8CA).w
	move.w	d3,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d6,(a0)+
	move.w	#$FFFE,(a0)+

return_110CE:
	rts
; End of function sub_110AA

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

loc_110D0:
	move.l	d0,-(sp)
	moveq	#sfx_Metal_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	movem.l	d4/a0-a1,-(sp)
	move.w	d3,a0
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_11120,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	ext.l	d3
	move.l	d3,$48(a0)
	move.w	d6,$4C(a0)
	move.w	d1,d4
	lsl.w	#4,d4

loc_1110E:
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)
	movem.l	(sp)+,d4/a0-a1
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_11120:
	move.w	$44(a5),d0
	move.w	$46(a5),d1
	move.l	$48(a5),a0
	move.w	d1,d4
	add.w	d4,d4
	lea	($FFFF4BB8).l,a1
	move.w	(a1,d4.w),a1
	addi.l	#$FF0000,a1
	moveq	#0,d4
	move.b	(a1,d0.w),d4
	move.w	d4,(a0)
	move.l	($FFFFF8B6).w,a1
	move.w	d0,(a1)+
	move.w	d1,(a1)+
	move.w	d4,(a1)+
	move.l	a1,($FFFFF8B6).w
	move.b	#$6F,(a0)
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.l	#stru_111CE,d7
	jsr	(j_Init_Animation).w
	tst.w	$4C(a5)
	bne.s	loc_11196
	moveq	#3,d0

loc_1117A:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1117A
	moveq	#3,d0

loc_11188:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_11188
	bra.s	loc_111B2
; ---------------------------------------------------------------------------

loc_11196:
	moveq	#3,d0

loc_11198:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_11198
	moveq	#3,d0

loc_111A6:
	addq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_111A6

loc_111B2:
	jsr	(j_sub_105E).w
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	#$E50B,d0
	bsr.w	sub_11530
	jmp	(j_Delete_CurrentObject).w
; End of function sub_11120

; ---------------------------------------------------------------------------
stru_111CE:
	anim_frame	  1,   4, LnkTo_unk_E0E96-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0E9E-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0EA6-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0EAE-Data_Index
	anim_frame	  1, $14, LnkTo_unk_E0E8E-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0E96-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0E9E-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0EA6-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E0EAE-Data_Index
	dc.b 0
	dc.b 0
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

loc_111F4:
	movem.l	d4/a0-a2,-(sp)
	move.w	d3,a2
	cmpi.w	#3,d6
	bne.s	loc_11230
	addq.w	#2,a2
	move.w	(Level_width_blocks).w,d4
	subq.w	#1,d4

loc_11208:
	cmp.w	d4,d1
	bge.w	loc_11296
	move.w	(a2)+,d7
	move.w	d7,d5
	andi.w	#$7000,d5
	cmpi.w	#$6000,d5
	bne.s	loc_11256
	bclr	#$F,d7
	beq.s	loc_11296
	andi.w	#$F00,d7
	cmpi.w	#$500,d7
	bne.s	loc_11296
	addq.w	#1,d1
	bra.s	loc_11208
; ---------------------------------------------------------------------------

loc_11230:
	tst.w	d1
	ble.s	loc_11296
	move.w	-(a2),d7
	move.w	d7,d5
	andi.w	#$7000,d5
	cmpi.w	#$6000,d5
	bne.s	loc_1125A
	bclr	#$F,d7
	beq.s	loc_11296
	andi.w	#$F00,d7
	cmpi.w	#$500,d7
	bne.s	loc_11296
	subq.w	#1,d1
	bra.s	loc_11230
; ---------------------------------------------------------------------------

loc_11256:
	subq.w	#4,a2
	bra.s	loc_1125C
; ---------------------------------------------------------------------------

loc_1125A:
	addq.w	#2,a2

loc_1125C:
	or.b	#$F,(a2)
	move.w	#$2001,a0
	move.l	#$FF0001,a1
	jsr	(j_sub_E02).w
	move.l	#sub_1129C,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	move.l	a2,$48(a0)
	move.w	d6,$4C(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)

loc_11296:
	movem.l	(sp)+,d4/a0-a2
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_1129C:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	bsr.w	sub_11542
	move.l	$36(a5),a3
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.b	#0,priority(a3)
	move.b	#0,$12(a3)
	move.w	#$3C,object_meta(a3)
	move.w	#(LnkTo_unk_E0E8E-Data_Index),addroffset_sprite(a3)
	move.w	#3,d3
	move.l	d0,-(sp)
	moveq	#sfx_Berzerker_moving_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_112E2:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	$4C(a5),d6
	cmpi.w	#3,d6
	bne.s	loc_112FE
	addq.w	#4,x_pos(a3)
	addq.w	#1,d3
	cmpi.w	#4,d3
	beq.s	loc_11334
	bra.s	loc_112E2
; ---------------------------------------------------------------------------

loc_112FE:
	subq.w	#4,x_pos(a3)
	addq.w	#1,d3
	cmpi.w	#4,d3
	beq.s	loc_1130C
	bra.s	loc_112E2
; ---------------------------------------------------------------------------

loc_1130C:
	tst.w	d1
	ble.s	loc_11328
	move.w	#0,d3
	subq.w	#1,d1
	subq.w	#2,a1
	move.w	(a1),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bne.s	loc_112E2
	addq.w	#2,a1
	addq.w	#1,d1

loc_11328:
	move.w	#$E50B,d0
	bsr.w	sub_11530
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_11334:
	move.w	(Level_width_blocks).w,d4
	subq.w	#1,d4
	cmp.w	d4,d1
	bge.w	loc_11358
	move.w	#0,d3
	addq.w	#1,d1
	addq.w	#2,a1
	move.w	(a1),d7
	andi.w	#$7000,d7
	cmpi.w	#$6000,d7
	bne.s	loc_112E2
	subq.w	#2,a1
	subq.w	#1,d1

loc_11358:
	move.w	#$E50B,d0
	bsr.w	sub_11530
	jmp	(j_Delete_CurrentObject).w
; End of function sub_1129C

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

loc_11364:
	move.l	d0,-(sp)
	moveq	#sfx_Shifting_block,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	movem.l	d0/a0-a1,-(sp)
	tst.w	d2
	beq.s	loc_113BA
	move.w	d3,a2
	suba.w	(Level_width_tiles).w,a2
	btst	#6,(a2)
	bne.s	loc_113BA
	move.b	#$6F,(a2)
	move.w	#$2001,a0
	move.l	#$FF0004,a1
	jsr	(j_sub_E02).w
	move.l	#sub_113C0,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	move.l	a2,$48(a0)
	move.w	d1,d4
	lsl.w	#4,d4
	move.w	d4,$1A(a1)
	move.w	d2,d4
	lsl.w	#4,d4
	move.w	d4,$1E(a1)

loc_113BA:
	movem.l	(sp)+,d0/a0-a1
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_113C0:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.l	$36(a5),a3
	st	is_moved(a3)
	st	$13(a3)
	move.b	#0,palette_line(a3)
	move.b	#0,priority(a3)
	move.b	#0,$12(a3)
	move.w	#(LnkTo_unk_E0EBE-Data_Index),addroffset_sprite(a3)
	move.w	#7,d0

loc_113F4:
	subq.w	#2,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_113F4
	move.w	#$E710,d0
	subq.w	#1,d2
	bsr.w	sub_11530
	addq.w	#1,d2
	add.w	(Level_width_tiles).w,a1
	bsr.w	sub_11542
	addi.w	#$10,y_pos(a3)
	move.w	#$F,d0

loc_1141E:
	subq.w	#1,y_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1141E
	jmp	(j_Delete_CurrentObject).w
; End of function sub_113C0

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_loc_DF22

return_1142E:
	rts
; ---------------------------------------------------------------------------

loc_11430:
	movem.l	d4/a0-a1,-(sp)
	tst.w	d2
	beq.s	loc_11474
	bmi.s	loc_11474
	moveq	#0,d4
	move.w	d3,a1
	suba.w	(Level_width_tiles).w,a1
	tst.w	(a1)
	bne.s	loc_11448
	bsr.s	sub_1149C

loc_11448:
	subq.w	#1,d1
	bmi.s	loc_11458
	tst.w	-2(a1)
	bne.s	loc_11458
	subq.w	#2,a1
	bsr.s	sub_1149C
	addq.w	#2,a1

loc_11458:
	addq.w	#1,d1
	addq.w	#1,d1
	cmp.w	(Level_width_blocks).w,d1
	bge.s	loc_1146E
	tst.w	2(a1)
	bne.s	loc_1146E
	addq.w	#2,a1
	bsr.s	sub_1149C
	subq.w	#2,a1

loc_1146E:
	subq.w	#1,d1
	tst.w	d4
	bne.s	loc_11496

loc_11474:
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_114C0,4(a0)
	move.w	d1,$44(a0)
	move.w	d2,$46(a0)
	move.w	d3,a1
	move.l	a1,$48(a0)
	or.b	#$F,(a1)

loc_11496:
	movem.l	(sp)+,d4/a0-a1
	rts
; END OF FUNCTION CHUNK	FOR j_loc_DF22

; =============== S U B	R O U T	I N E =======================================


sub_1149C:
	move.w	#$2001,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_114F4,4(a0)
	move.w	d1,$44(a0)
	subq.w	#1,d2
	move.w	d2,$46(a0)
	addq.w	#1,d2
	move.l	a1,$48(a0)
	moveq	#1,d4
	rts
; End of function sub_1149C


; =============== S U B	R O U T	I N E =======================================


sub_114C0:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	move.w	#$EF1B,d0
	bsr.w	sub_11530
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$EF1A,d0
	bsr.w	sub_11530
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_11542
	jmp	(j_Delete_CurrentObject).w
; End of function sub_114C0


; =============== S U B	R O U T	I N E =======================================


sub_114F4:
	move.w	$44(a5),d1
	move.w	$46(a5),d2
	move.l	$48(a5),a1
	tst.w	(a1)
	bne.s	loc_1152C
	move.w	#$EF1A,d0
	bsr.w	sub_11530
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$EF1B,d0
	bsr.w	sub_11530
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$E919,d0
	bsr.w	sub_11530

loc_1152C:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_114F4


; =============== S U B	R O U T	I N E =======================================


sub_11530:
	move.l	($FFFFF8B6).w,a0
	move.w	d0,(a1)
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d0,(a0)+
	move.l	a0,($FFFFF8B6).w
	rts
; End of function sub_11530


; =============== S U B	R O U T	I N E =======================================


sub_11542:
	move.w	d2,d0
	add.w	d0,d0
	lea	($FFFF4BB8).l,a0
	move.w	(a0,d0.w),a0
	addi.l	#$FF0000,a0
	moveq	#0,d0
	move.b	(a0,d1.w),d0
	move.w	d1,-(sp)
	move.w	(Foreground_theme).w,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(LnkTo_ThemeCollision_Index).l,a0
	move.l	(a0,d1.w),a0
	moveq	#0,d1
	move.b	(a0,d0.w),d1
	ror.w	#4,d1
	or.w	d1,d0
	move.w	(sp)+,d1
	move.l	($FFFFF8B6).w,a0
	move.w	d0,(a1)
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	move.w	d0,(a0)+
	move.l	a0,($FFFFF8B6).w
	rts
; End of function sub_11542

; ---------------------------------------------------------------------------
; filler
    rept 934
	dc.b	$FF
    endm

; =============== S U B	R O U T	I N E =======================================


j_LoadGameModeData:

; FUNCTION CHUNK AT 000143BC SIZE 00000004 BYTES

	jmp	LoadGameModeData(pc)
; ---------------------------------------------------------------------------

j_DecompressToVRAM:
	jmp	DecompressToVRAM(pc) ; a0 - source	address
				; d0 - offset in VRAM (destination)
; ---------------------------------------------------------------------------

j_DecompressToRAM_Special:
	jmp	DecompressToRAM_Special(pc)
; ---------------------------------------------------------------------------

j_DecompressToRAM:
				; Load_TitleArt+Et ...
	jmp	DecompressToRAM(pc)
; ---------------------------------------------------------------------------

j_EniDec:
	jmp	EniDec(pc)
; ---------------------------------------------------------------------------
Addr_TtlCrdLetters:dc.l	ArtComp_19C68_TtlCardLetters ;	DATA XREF: Character_CheckCollision+1AE0r
off_1194C:	dc.l sub_12D64
; ---------------------------------------------------------------------------

LoadGameModeData:
	move.w	(Game_Mode).w,d0
	move.l	GameLoadArray(pc,d0.l),a0
	jsr	(a0)
	clr.w	($FFFF0280).l
	rts
; End of function j_LoadGameModeData

; ---------------------------------------------------------------------------
GameLoadArray:	dc.l Load_SegaScreen
	dc.l Load_IntroSequence1
	dc.l Load_TitleCard
	dc.l Load_InGame	; also Results screen
	dc.l Load_DemoPlay
	dc.l Load_OptionMenu
	dc.l Load_IntroSequence2
	dc.l Load_IntroSequence3
	dc.l Load_IntroSequence4
	dc.l Load_IntroSequence5
	dc.l Load_IntroSequence6 ; is also TitleScreen if intro	played completely
	dc.l Load_TitleScreen
	dc.l Load_EndSequence
; ---------------------------------------------------------------------------

Load_DemoPlay:
	st	(Demo_Mode_flag).w
	lea	(Demo_InputData1).l,a4
	move.w	#$15,d7
	not.b	($FFFFFBC8).w
	beq.w	loc_119B6
	lea	(Demo_InputData2).l,a4
	move.w	#$1B,d7

loc_119B6:
	move.l	a4,(Addr_Current_Demo_Keypress).w
	move.w	d7,(Current_LevelID).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_119D8,4(a0)
	clr.w	($FFFFFBC2).w
	bsr.w	Load_InGame
	rts
; ---------------------------------------------------------------------------

loc_119D8:

	clr.b	(Ctrl_Pressed).w
	jsr	(j_Hibernate_Object_1Frame).w
	btst	#7,(Ctrl_1_Pressed).w
	beq.s	loc_119D8
	move.w	#$2C,(Game_Mode).w
	sf	(Demo_Mode_flag).w
	st	($FFFFFBCE).w
	st	($FFFFFC36).w
	move.w	#$82A,($FFFFFBCC).w
	clr.w	(Current_LevelID).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w

; =============== S U B	R O U T	I N E =======================================


Load_InGame:

	jsr	(j_Initialize_Platforms).w
	jsr	(j_sub_28FC).w
	jsr	(j_sub_44B0).w
	jsr	(j_Init_Timer_and_Bonus_Flags).w
	jsr	(j_StopMusic).l
	move.l	#$F,-(sp)
	jsr	(sub_E133C).l
	move.l	(sp)+,d0
	move.w	(Current_LevelID).w,d0
	move.l	(LnkTo_MapOrder_Index).l,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	move.l	#MapHeader_Index,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.l	#MapHeader_BaseAddress,a0
	add.w	d0,a0
	move.l	a0,(Addr_MapHeader).w
	moveq	#0,d0
	move.b	(a0)+,d0	; x size
	mulu.w	#$14,d0
	move.w	d0,(Level_width_blocks).w
	add.w	d0,d0
	move.w	d0,(Level_width_tiles).w
	lsl.w	#3,d0
	move.w	d0,(Level_width_pixels).w
	subi.w	#$140,d0
	move.w	d0,(Camera_max_X_pos).w
	moveq	#0,d0
	move.b	(a0)+,d0	; y size + flags
	move.b	d0,d1
	rol.b	#2,d1
	andi.b	#3,d1
	add.b	d1,d1
	move.b	d1,($FFFFFAD2).w
	andi.b	#$3F,d0
	mulu.w	#$E,d0
	move.w	d0,(Level_height_pixels).w
	add.w	d0,d0
	move.w	d0,(Level_height_tiles).w
	lsl.w	#3,d0
	move.w	d0,(Level_height_blocks).w
	subi.w	#$E0,d0
	move.w	d0,(Camera_max_Y_pos).w
	ext.w	d1
	add.w	d1,(Level_height_pixels).w
	add.w	d1,d1
	add.w	d1,(Level_height_tiles).w
	lsl.w	#3,d1
	add.w	d1,(Level_height_blocks).w
	add.w	d1,(Camera_max_Y_pos).w
	move.w	(Current_LevelID).w,d2
	move.l	(LnkTo_MapOrder_Index).l,a2
	move.b	(a2,d2.w),d2
	cmpi.w	#$54,d2
	beq.s	loc_11AE4
	move.l	#$FFFFDD02,a3
	cmpi.w	#$12C,(Level_width_blocks).w
	bgt.s	loc_11AEA

loc_11AE4:
	move.l	#$FFFF9E32,a3

loc_11AEA:
	lea	($FFFF4A00).l,a1
	move.w	a3,(a1)+
	move.w	a3,(a1)+
	lea	(Level_Layout).w,a2
	move.w	(Level_height_pixels).w,d0
	subq.w	#1,d0

loc_11AFE:
	move.w	a2,(a1)+
	add.w	(Level_width_tiles).w,a2
	dbf	d0,loc_11AFE
	move.w	(Level_width_blocks).w,d0
	subq.w	#1,d0
	move.w	#$6000,d1

loc_11B12:
	move.w	d1,(a3)+
	dbf	d0,loc_11B12
	moveq	#7,d0

loc_11B1A:
	move.w	a3,(a1)+
	dbf	d0,loc_11B1A
	move.w	(Level_width_blocks).w,d0
	subq.w	#1,d0
	moveq	#0,d1

loc_11B28:
	move.w	d1,(a3)+
	dbf	d0,loc_11B28
	lea	($FFFF4BB8).l,a3
	lea	(Level_terrain_layout).l,a4
	move.w	(Level_height_pixels).w,d0
	subq.w	#1,d0

loc_11B40:
	move.w	a4,(a3)+
	add.w	(Level_width_blocks).w,a4
	dbf	d0,loc_11B40
	move.w	(Level_width_tiles).w,d0
	lsr.w	#2,d0
	addi.w	#$1E,d0
	move.w	d0,(Background_width).w
	move.w	(Level_height_tiles).w,d0
	lsr.w	#2,d0
	addi.w	#$15,d0
	move.w	d0,(Background_height).w
	lea	($FFFF4D5C).l,a2
	lea	($FFFF87B2).w,a1
	move.w	(Background_height).w,d0
	subq.w	#1,d0
	move.w	(Background_width).w,d1

loc_11B7A:
	move.w	a1,(a2)+
	add.w	d1,a1
	dbf	d0,loc_11B7A
	moveq	#0,d7
	move.b	(a0)+,d7	; FG theme + flags
	bpl.s	loc_11B9A
	btst	#6,d7
	beq.s	loc_11B92
	st	(MurderWall_flag2).w

loc_11B92:
	andi.w	#$3F,d7
	st	(MurderWall_flag).w

loc_11B9A:
	move.w	d7,(Foreground_theme).w
	clr.w	($FFFFF898).w
	sf	($FFFFF896).w
	lsl.w	#2,d7
	moveq	#0,d0
	move.b	(a0)+,d0	; BG theme + flags
	move.w	d0,d1
	rol.b	#4,d1
	andi.w	#$F,d1
	move.w	d1,(Level_Special_Effects).w
	andi.w	#$F,d0
	move.w	d0,(Background_theme).w
	move.w	#(1<<Hills)|(1<<Desert)|(1<<Mountain)|(1<<Forest),d1
	;move.w	#%1010101000,d1	; bitmask telling which theme uses
	btst	d0,d1		; which BG format
	sne	(Background_format).w
	beq.s	loc_11BD2
	move.w	#$40,(Background_width).w

loc_11BD2:
	tst.b	($FFFFFC29).w
	beq.w	loc_11BE4
	addq.w	#4,a0
	sf	($FFFFFC29).w
	bra.w	loc_11BEC
; ---------------------------------------------------------------------------

loc_11BE4:
	move.w	(a0)+,(PlayerStart_X_pos).w	; player x position
	move.w	(a0)+,(PlayerStart_Y_pos).w	; player y position

loc_11BEC:
	move.w	(a0)+,(Flag_X_pos).w	; flag x position
	move.w	(a0)+,(Flag_Y_pos).w	; flag y position
	move.l	(a0)+,a1	; tile layout address
	movem.l	d7-a0/a6,-(sp)
	move.l	a1,a0
	move.w	(a0)+,d0
	lea	(a0,d0.w),a1
	lea	(Level_terrain_layout).l,a2
	moveq	#-1,d0
	move.l	d0,a3
	moveq	#0,d1
	moveq	#0,d2

loc_11C10:
	bsr.w	Decompress_Chunk	; decompress tile layout into buffer
	tst.w	d0
	bne.s	loc_11C10
	movem.l	(sp)+,d7-a0/a6
	lea	(Level_terrain_layout).l,a2
	lea	(Level_Layout).w,a3
	move.l	(LnkTo_ThemeCollision_Index).l,a4
	move.l	(a4,d7.w),a4
	moveq	#0,d0
	moveq	#0,d2

loc_11C34:
	moveq	#0,d1

loc_11C36:
	move.b	(a2)+,d2
	move.b	(a4,d2.w),d3
	lsl.b	#4,d3
	move.b	d3,(a3)+
	move.b	d2,(a3)+
	addq.w	#1,d1
	cmp.w	(Level_width_blocks).w,d1
	bne.s	loc_11C36
	addq.w	#1,d0
	cmp.w	(Level_height_pixels).w,d0
	bne.s	loc_11C34
	move.l	#$FFFF0280,($FFFFF8EC).w
	move.w	#$FFFF,($FFFF0280).l
	move.l	(a0)+,a1	; block	layout
	lea	($FFFF3B24).l,a5
	bsr.w	LoadBlockLayout	; into temp buffer at Decompression_Buffer?
	cmpi.w	#$21,(Current_LevelID).w	; is the level Forced Entry?
	bne.s	loc_11C7E
	move.w	#$E50B,($FFBCEA).l	; if yes, insert steel block at ($20,$B)

loc_11C7E:
	move.w	(a1)+,d0
	cmpi.w	#$FFFF,d0
	beq.s	loc_11C96
	move.w	d0,d1
	lsl.w	#2,d1
	lea	AddrTbl_BlockTypes(pc),a4
	move.l	(a4,d1.w),a4
	jsr	(a4)
	bra.s	loc_11C7E
; ---------------------------------------------------------------------------

loc_11C96:
	move.w	($FFFFF8EA).w,d0
	beq.s	loc_11CB2
	subq.w	#1,d0
	move.l	a5,($FFFFF8EC).w
	lea	($FFFF0280).l,a4

loc_11CA8:
	move.l	(a4)+,(a5)+
	move.l	(a4)+,(a5)+
	dbf	d0,loc_11CA8
	bra.s	loc_11CB6
; ---------------------------------------------------------------------------

loc_11CB2:
	clr.l	($FFFFF8EC).w

loc_11CB6:
	move.l	($FFFFF8D4).w,d0
	beq.s	loc_11CCA
	move.w	($FFFFF8D2).w,d1
	lsl.w	#3,d1
	add.w	d1,d0
	cmpi.w	#$43BC,d0
	bcc.s	loc_11D0A

loc_11CCA:
	move.l	($FFFFF8DA).w,d0
	beq.s	loc_11CE0
	move.w	($FFFFF8D8).w,d1
	mulu.w	#$10,d1
	add.w	d1,d0
	cmpi.w	#$43BC,d0
	bcc.s	loc_11D0A

loc_11CE0:
	move.l	($FFFFF8E0).w,d0
	beq.s	loc_11CF6
	move.w	($FFFFF8DE).w,d1
	mulu.w	#$A,d1
	add.w	d1,d0
	cmpi.w	#$43BC,d0
	bcc.s	loc_11D0A

loc_11CF6:
	move.l	($FFFFF8EC).w,d0
	beq.s	loc_11D0C	; background tiles
	move.w	($FFFFF8EA).w,d1
	lsl.w	#3,d1
	add.w	d1,d0
	cmpi.w	#$43BC,d0
	bcs.s	loc_11D0C	; background tiles

loc_11D0A:
	bra.s	loc_11D0A
; ---------------------------------------------------------------------------

loc_11D0C:
	move.l	(a0)+,a1	; background tiles
	bsr.w	sub_1280A
	move.l	(LnkTo_ThemeMappings_Index).l,a1
	move.l	(a1,d7.w),(Addr_ThemeMappings).w
	move.l	(a0)+,a1	; enemy	layout
	move.l	(a1)+,(Addr_EnemyLayout).w
	move.l	a1,(Addr_EnemyLayoutHeader).w
	move.l	(LnkTo_unk_7B8DC).l,a1
	lea	(Block_Mappings).l,a2
	moveq	#0,d1
	tst.b	($FFFFF896).w
	beq.s	loc_11D42
	move.l	#$80008000,d1

loc_11D42:
	move.w	#$A1,d0

loc_11D46:
	move.l	(a1)+,d2
	or.l	d1,d2
	move.l	d2,(a2)+
	dbf	d0,loc_11D46
	move.l	(LnkTo_ThemePal1_Index).l,a1
	move.l	d7,d0
	lsr.l	#1,d0
	move.w	(a1,d0.w),d0
	addi.l	#MainAddr_Index,d0
	move.l	d0,a1
	move.l	(a1),a1
	move.w	(Current_LevelID).w,d2
	move.l	(LnkTo_MapOrder_Index).l,a2
	move.b	(a2,d2.w),d2
	; check for alternative foreground palettes
	cmpi.b	#23,d2	; MapID = 3 (Stairway to Oblivion)?
	beq.s	loc_11D8E	; yes -> alternative cave palette
	cmpi.b	#23,d2
	beq.s	loc_11D8E	; yes -> alternative cave palette
	cmpi.b	#23,d2
	bne.s	loc_11D92	; no -> continue other checks
	lea	Pal_12CBC(pc),a1	; use Plethora cave palette
	bra.s	loc_11D92

loc_11D8E:
	lea	Pal_12CDA(pc),a1	; use alternative cave palette

loc_11D92:
	cmpi.b	#23,d2	; MapID = 1C (The Deadly Skyscrapers)?
	beq.s	loc_11D9E	; yes -> do nothing special anyway
	cmpi.b	#23,d2
	bne.s	loc_11DA0	; no -> continue other checks

loc_11D9E:
	; There was probably a special palette here for these two levels
	; but they removed the command
	; lea	Pal_12D08(pc),a1
	; and replaced it with nop, which does nothing
	; comment in the above instruction to see the palette in use
	nop

loc_11DA0:
	cmpi.b	#23,d2	; MapID = 1A (The Crypt (leftover))?
	beq.s	loc_11DAC	; yes -> alternative palette
	cmpi.b	#23,d2
	bne.s	loc_11DB0	; no -> regular palette

loc_11DAC:
	lea	Pal_12D26(pc),a1

loc_11DB0:
    cmpi.b    #$76,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_fg(pc),a1 ; 
+
        cmpi.b    #$54,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_fg(pc),a1 ; 
+
        cmpi.b    #$57,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_fg(pc),a1 ; 
+
        cmpi.b    #$69,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_fg(pc),a1 ; 
+
    cmpi.b    #$5F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_fg(pc),a1 ; 
+
    cmpi.b    #$40,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_fg(pc),a1 ; 
+
    cmpi.b    #$63,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_fg(pc),a1 ; 
+
    cmpi.b    #$59,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_fg(pc),a1 ; 
+
    cmpi.b    #$38,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_fg(pc),a1 ; 
+
    cmpi.b    #$04,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_light_fg(pc),a1 ; 
+
    cmpi.b    #$39,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_light_fg(pc),a1 ; 
+
    cmpi.b    #$16,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_dark_fg(pc),a1 ; 
+
    cmpi.b    #$3B,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_dark_fg(pc),a1 ; 
+
    cmpi.b    #$11,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_space_fg(pc),a1 ; 
+
    cmpi.b    #$05,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_space_fg(pc),a1 ; 
+
    cmpi.b    #$0F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_botanic_fg(pc),a1 ;
+
    cmpi.b    #$2F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_botanic_fg(pc),a1 ; 
+
    cmpi.b    #$1F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_fg(pc),a1 ; 
+
	lea	(Palette_Buffer+$2).l,a2
	moveq	#$E,d1

-	; loop to copy foreground palette into palette RAM
	move.w	(a1)+,(a2)+
	dbf	d1,-

	move.l	(LnkTo_ThemePal2_Index).l,a1
	moveq	#0,d0
	move.w	(Background_theme).w,d0
	add.w	d0,d0
	move.w	(a1,d0.w),d0
	addi.l	#MainAddr_Index,d0
	move.l	d0,a1
	move.l	(a1),a1
	move.w	(Current_LevelID).w,d2
	move.l	(LnkTo_MapOrder_Index).l,a2
	move.b	(a2,d2.w),d2
	; check for alternative background palettes
	cmpi.b	#23,d2
	beq.s	loc_11DF4
	cmpi.b	#23,d2
	bne.s	loc_11DF8

loc_11DF4:
	lea	Pal_12CF8(pc),a1

loc_11DF8:
	cmpi.b	#23,d2
	beq.s	loc_11E04
	cmpi.b	#23,d2
	bne.s	loc_11E06

loc_11E04:

	; There was probably a special palette here for these two levels
	; but they removed the command
	; lea	Pal_12D44(pc),a1
	; and replaced it with nop, which does nothing
	; comment in the above instruction to see the palette in use
	nop

loc_11E06:
	cmpi.b	#23,d2
	beq.s	loc_11E12
	cmpi.b	#23,d2
	bne.s	loc_11E16

loc_11E12:
	lea	Pal_12D54(pc),a1

loc_11E16:
    cmpi.b    #$76,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_bg(pc),a1 ; 
+
    cmpi.b    #$54,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_bg(pc),a1 ; 
+
    cmpi.b    #$57,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_bg(pc),a1 ; 
+
    cmpi.b    #$69,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_bg(pc),a1 ; 
+
    cmpi.b    #$5F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_bg(pc),a1 ; 
+
    cmpi.b    #$40,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_bg(pc),a1 ; 
+
    cmpi.b    #$63,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_bg(pc),a1 ; 
+
    cmpi.b    #$59,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_bg(pc),a1 ; 
+
    cmpi.b    #$38,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_hell_bg(pc),a1 ; 
+
    cmpi.b    #$04,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_light_bg(pc),a1 ; 
+
    cmpi.b    #$39,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_light_bg(pc),a1 ; 
+
    cmpi.b    #$16,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_dark_bg(pc),a1 ; 
+
    cmpi.b    #$3B,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_city_dark_bg(pc),a1 ; 
+
    cmpi.b    #$11,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_space_bg(pc),a1 ; 
+
    cmpi.b    #$05,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_space_bg(pc),a1 ; 
+
    cmpi.b    #$0F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_botanic_bg(pc),a1 ; 
+
    cmpi.b    #$2F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_botanic_bg(pc),a1 ; 
+
    cmpi.b    #$1F,d2    ;
    bne.s    +        ; if not, skip the next line (go to +)
    lea    Pal_heaven_bg(pc),a1 ; 
+
	move.w	(a1)+,(Palette_Buffer).l
	lea	(Palette_Buffer+$32).l,a2
	moveq	#6,d1

-	; loop to copy foreground palette into palette RAM
	move.w	(a1)+,(a2)+
	dbf	d1,-

	move.l	(MainAddr_Index).l,a0
	move.l	(a0,d7.w),a0
	move.w	#$1780,d0
	lea	Palette_Permutation_Identity(pc),a3
	cmpi.w	#City,(Foreground_theme).w
	bne.s	loc_11E48
	lea	Palette_Permutation_FGCity(pc),a3

loc_11E48:
	cmpi.w	#Forest,(Foreground_theme).w
	bne.s	loc_11E54
	lea	Palette_Permutation_FGForest(pc),a3

loc_11E54:
	cmpi.w	#Mountain,(Foreground_theme).w
	bne.s	loc_11E60
	lea	Palette_Permutation_FGMountain(pc),a3

loc_11E60:
	bsr.w	DecompressToRAM
	move.l	(LnkTo_ThemeArtBack_Index).l,a0
	move.w	(Background_theme).w,d7
	add.w	d7,d7
	add.w	d7,d7
	move.l	(a0,d7.w),a0
	move.w	#$F000,d0
	lea	Palette_Permutation_Identity(pc),a3
	cmpi.w	#Forest,(Background_theme).w
	bne.s	loc_11E8A
	lea	Palette_Permutation_BGForest(pc),a3

loc_11E8A:
	cmpi.w	#Mountain,(Background_theme).w
	bne.s	loc_11E96
	lea	Palette_Permutation_BGMountain(pc),a3

loc_11E96:
	cmpi.w	#Hills,(Background_theme).w
	bne.s	loc_11EA2
	lea	Palette_Permutation_BGHill(pc),a3

loc_11EA2:
	bsr.w	DecompressToRAM
	cmpi.w	#Hills,(Background_theme).w
	bne.s	loc_11EC4
	lea	Palette_Permutation_BGHill_alt(pc),a3
	move.l	(LnkTo_ThemeArtBack_Index).l,a1
	move.l	$34(a1),a0
	move.w	#$F800,d0
	bsr.w	DecompressToRAM

loc_11EC4:
	cmpi.w	#Mountain,(Background_theme).w
	bne.s	loc_11EFA
	lea	Palette_Permutation_Identity(pc),a3
	move.l	(LnkTo_ThemeArtBack_Index).l,a1
	move.l	$2C(a1),a0
	cmpi.w	#WeatherID_Storm,(Level_Special_Effects).w
	beq.s	loc_11EEA
	cmpi.w	#WeatherID_Storm_and_Hail,(Level_Special_Effects).w
	bne.s	loc_11EF2

loc_11EEA:
	move.l	$30(a1),a0
	lea	Palette_Permutation_BGMountain(pc),a3

loc_11EF2:
	move.w	#$FCA0,d0
	bsr.w	DecompressToRAM

loc_11EFA:
	move.l	(LnkTo_ArtComp_992E4_Blocks).l,a0
	move.w	#$4400,d0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)

	move.w	#$D740,d0
	move.l	(LnkTo_ArtComp_99F34_IngameNumbers).l,a0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	bsr.w	sub_12D64
	bsr.w	sub_129CE
	bsr.w	sub_12B8C
	bsr.w	sub_12C24
	jsr	(j_sub_F06A).l
	jsr	(j_loc_DF22).l
	bsr.w	Init_SpriteAttr_HUD
	jsr	(j_Clear_DiamondPowerObjectRAM).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	move.w	#$7FF,d0

loc_11F48:
	move.w	#$780,(a6)
	dbf	d0,loc_11F48
	move.w	(PlayerStart_X_pos).w,d1
	divu.w	#$140,d1
	moveq	#0,d0
	mulu.w	#$140,d1
	move.w	d1,d0
	swap	d0
	move.l	d0,(Camera_X_pos).w
	move.w	(PlayerStart_Y_pos).w,d1
	divu.w	#$E0,d1
	moveq	#0,d0
	mulu.w	#$E0,d1
	move.w	d1,d0
	swap	d0
	move.l	d0,(Camera_Y_pos).w
	cmpi.w	#7,(Foreground_theme).w
	bne.s	loc_11F96
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#RotatePalette_Lava_Water,4(a0)
	bra.s	loc_11FC8
; ---------------------------------------------------------------------------

loc_11F96:
	cmpi.w	#Cave,(Foreground_theme).w
	bne.s	loc_11FB0
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#RotatePalette_Lava_Water,4(a0)
	bra.s	loc_11FC8
; ---------------------------------------------------------------------------

loc_11FB0:
	cmpi.w	#Island,(Background_theme).w
	bne.s	loc_11FC8
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1202A,4(a0)

loc_11FC8:
				; Load_InGame+5A0j ...
	tst.b	(MurderWall_flag).w
	beq.s	loc_11FD2
	bsr.w	Murderwall

loc_11FD2:
	bsr.w	sub_140F6
	bsr.w	sub_144DA
	jsr	(j_loc_2FFE8).l
	jsr	(j_loc_31F8E).l
	bsr.w	sub_129AE
	jsr	(j_sub_7196).w
	bsr.w	Init_SpecialEffects
	tst.b	(MurderWall_flag).w
	beq.s	loc_12004
	move.w	#bgm_Murderwall,d0
	jsr	(j_PlaySound).l
	rts
; ---------------------------------------------------------------------------

loc_12004:
	move.w	(Foreground_theme).w,d1
	lea	unk_1201E(pc),a0
	moveq	#0,d0
	move.b	(a0,d1.w),d0
	move.w	d0,($FFFFFC32).w
	jsr	(j_PlaySound).l
	rts
; End of function Load_InGame

; ---------------------------------------------------------------------------
unk_1201E:
	dc.b   bgm_Mountain
	dc.b   bgm_Sky
	dc.b   bgm_Ice
	dc.b   bgm_Hills
	dc.b   bgm_Island
	dc.b   bgm_Desert
	dc.b   bgm_Swamp
	dc.b   bgm_Mountain
	dc.b   bgm_Cave
	dc.b   bgm_Forest
	dc.b   bgm_City
	dc.b   0
; ---------------------------------------------------------------------------
ANIART_SHORE_SIZE = $2E0

loc_1202A:
	move.l	#LnkTo_unk_9784A,a0
	move.l	(a0),d2
	addq.l	#2,d2		; d2 = DMA source address
	jsr	(j_Stop_z80).l
	lsr.l	#1,d2
	move.l	#(($9300|((ANIART_SHORE_SIZE&$1FE)>>1))<<16)|($9400|(ANIART_SHORE_SIZE>>9)),4(a6)	; DMA length
	move.w	#$9500,d4
	move.b	d2,d4
	move.w	d4,4(a6)
	move.w	#$9600,d4
	lsr.l	#8,d2
	move.b	d2,d4
	move.w	d4,4(a6)
	move.w	#$9700,d4
	lsr.l	#8,d2
	move.b	d2,d4
	move.w	d4,4(a6)
	move.l	#vdpComm($F600,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	moveq	#1,d3
	moveq	#1,d2
	moveq	#1,d1
	move.w	#9,$44(a5)
	move.w	#$F,$46(a5)
	move.w	#$19,$48(a5)

loc_12098:
	jsr	(j_Hibernate_Object_1Frame).w
	subi.w	#1,$44(a5)
	bne.s	loc_12110
	lea	(off_1220E).l,a4
	move.w	d3,d4
	addq.w	#1,d3
	andi.w	#3,d3
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a4,d4.w),a4
	move.l	(a4),d5
	addq.l	#2,d5		; d5 = DMA source address
	jsr	(j_Stop_z80).l
	lsr.l	#1,d5
	move.l	#$93609400,4(a6)	; DMA length: $C0
	move.w	#$9500,d4
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9600,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9700,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.l	#vdpComm($F600,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	move.w	#9,$44(a5)

loc_12110:
	subi.w	#1,$46(a5)
	bne.s	loc_12188
	lea	(off_1220E).l,a4
	move.w	d2,d4
	addq.w	#1,d2
	andi.w	#3,d2
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a4,d4.w),a4
	move.l	(a4),d5
	addi.l	#$C2,d5		; d5 = DMA source address
	jsr	(j_Stop_z80).l
	lsr.l	#1,d5
	move.l	#$93509400,4(a6)	; DMA length: $A0
	move.w	#$9500,d4
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9600,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9700,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.l	#vdpComm($F6C0,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	move.w	#9,$46(a5)

loc_12188:
	subi.w	#1,$48(a5)
	bne.w	loc_12098
	clr.w	d7
	lea	(off_1220E).l,a4
	move.w	d1,d4
	addq.w	#1,d1
	cmpi.w	#5,d1
	ble.s	loc_121A6
	moveq	#0,d1

loc_121A6:
	move.b	unk_12226(pc,d4.w),d7
	move.w	d7,$48(a5)
	add.w	d4,d4
	add.w	d4,d4
	move.l	(a4,d4.w),a4
	move.l	(a4),d5
	addi.l	#$162,d5		; d5 = DMA source address
	jsr	(j_Stop_z80).l
	lsr.l	#1,d5
	move.l	#$93C09400,4(a6)	; DMA length: $180
	move.w	#$9500,d4
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9600,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.w	#$9700,d4
	lsr.l	#8,d5
	move.b	d5,d4
	move.w	d4,4(a6)
	move.l	#vdpComm($F760,VRAM,DMA),($FFFFF800).w
	move.w	($FFFFF800).w,4(a6)
	move.w	($FFFFF802).w,4(a6)
	jsr	(j_Start_z80).l
	bra.w	loc_12098
; ---------------------------------------------------------------------------
off_1220E:	dc.l LnkTo_unk_9784A
	dc.l LnkTo_unk_97B2C
	dc.l LnkTo_unk_97E0E
	dc.l LnkTo_unk_980F0
	dc.l LnkTo_unk_97E0E
	dc.l LnkTo_unk_97B2C
unk_12226:	dc.b $19
	dc.b $1E
	dc.b $1E
	dc.b $14
	dc.b  $F
	dc.b  $A
; ---------------------------------------------------------------------------

RotatePalette_Lava_Water:
	move.w	#5,d0
	cmpi.w	#Mountain,(Foreground_theme).w
	beq.s	loc_1223A
	addq.w	#3,d0

loc_1223A:
	move.w	d0,d2

loc_1223C:
	jsr	(j_Hibernate_Object_1Frame).w
	subi.w	#1,d0
	bne.s	loc_1223C
	move.w	d2,d0
	move.w	(Palette_Buffer+$14).l,d1
	move.w	(Palette_Buffer+$12).l,(Palette_Buffer+$14).l
	move.w	(Palette_Buffer+$10).l,(Palette_Buffer+$12).l
	move.w	(Palette_Buffer+$E).l,(Palette_Buffer+$10).l
	move.w	d1,(Palette_Buffer+$E).l
	bra.s	loc_1223C
; ---------------------------------------------------------------------------
AddrTbl_BlockTypes:
	dc.l loc_122B8
	dc.l loc_123DC
	dc.l loc_122B8
	dc.l loc_124A6
	dc.l loc_1263C
	dc.l loc_122B8
	dc.l loc_1233C
	dc.l loc_122B8
	dc.l loc_1253A
	dc.l loc_122B8
	dc.l loc_125A6
	dc.l loc_126BA
	dc.l loc_125A6
	dc.l 0
	dc.l 0
	dc.l 0
	dc.l loc_126F2
; ---------------------------------------------------------------------------

loc_122B8:
	move.w	d0,d1
	add.w	d1,d1
	move.w	word_122C6(pc,d1.w),d5

loc_122C0:
	move.w	(a1)+,d1
	bpl.s	loc_122DA
	rts
; ---------------------------------------------------------------------------
word_122C6:
	dc.w $E001
	dc.w 0
	dc.w $E203
	dc.w 0
	dc.w 0
	dc.w $E50B
	dc.w $E60C
	dc.w $E710
	dc.w 0
	dc.w $E919
; ---------------------------------------------------------------------------

loc_122DA:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_12318

loc_122F6:
	tst.w	d0
	bmi.s	loc_122FE
	move.w	d5,(a4)
	bra.s	loc_12310
; ---------------------------------------------------------------------------

loc_122FE:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_12310:
	addq.w	#2,a4
	dbf	d3,loc_122F6
	bra.s	loc_122C0
; ---------------------------------------------------------------------------

loc_12318:
	tst.w	d0
	bmi.s	loc_12320
	move.w	d5,(a4)
	bra.s	loc_12332
; ---------------------------------------------------------------------------

loc_12320:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_12332:
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_12318
	bra.s	loc_122C0
; ---------------------------------------------------------------------------

loc_1233C:
	move.l	a3,-(sp)

loc_1233E:
	move.w	(a1)+,d1
	bpl.s	loc_12346
	move.l	(sp)+,a3
	rts
; ---------------------------------------------------------------------------

loc_12346:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	lea	($FFFF4BB8).l,a2
	moveq	#-1,d5
	move.w	(a2,d3.w),d5
	move.l	d5,a3
	add.w	d1,a3
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_123A4

loc_12372:
	tst.w	d0
	bmi.s	loc_12388
	move.b	(a3),d5
	bne.s	loc_12380
	move.w	#$E60C,d5
	bra.s	loc_12384
; ---------------------------------------------------------------------------

loc_12380:
	move.w	#$E60E,d5

loc_12384:
	move.w	d5,(a4)
	bra.s	loc_1239A
; ---------------------------------------------------------------------------

loc_12388:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_1239A:
	addq.w	#2,a4
	addq.w	#1,a3
	dbf	d3,loc_12372
	bra.s	loc_1233E
; ---------------------------------------------------------------------------

loc_123A4:
	tst.w	d0
	bmi.s	loc_123BA
	move.b	(a3),d5
	bne.s	loc_123B2
	move.w	#$E60C,d5
	bra.s	loc_123B6
; ---------------------------------------------------------------------------

loc_123B2:
	move.w	#$E60E,d5

loc_123B6:
	move.w	d5,(a4)
	bra.s	loc_123CC
; ---------------------------------------------------------------------------

loc_123BA:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_123CC:
	add.w	(Level_width_tiles).w,a4
	add.w	(Level_width_blocks).w,a3
	dbf	d3,loc_123A4
	bra.w	loc_1233E
; ---------------------------------------------------------------------------

loc_123DC:
	move.l	($FFFFF8D4).w,d1
	bne.s	loc_123E6
	move.l	a5,($FFFFF8D4).w

loc_123E6:
	move.w	(a1)+,d1
	bpl.s	loc_123EC
	rts
; ---------------------------------------------------------------------------

loc_123EC:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_12454

loc_12408:
	move.w	(a1)+,d5
	bsr.w	nullsub_1
	tst.w	d0
	bmi.s	loc_12422
	tst.w	d5
	bmi.s	loc_1241C
	move.w	#$E102,(a4)
	bra.s	loc_12434
; ---------------------------------------------------------------------------

loc_1241C:
	move.w	#$E101,(a4)
	bra.s	loc_12434
; ---------------------------------------------------------------------------

loc_12422:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_12434:
	move.l	($FFFFF8D4).w,a5
	move.w	($FFFFF8D2).w,d6
	lsl.w	#3,d6
	add.w	d6,a5
	move.w	a4,(a5)+
	move.w	d1,(a5)+
	move.w	d2,(a5)+
	move.w	d5,(a5)+
	addq.w	#1,($FFFFF8D2).w
	addq.w	#2,a4
	dbf	d3,loc_12408
	bra.s	loc_123E6
; ---------------------------------------------------------------------------

loc_12454:
	move.w	(a1)+,d5
	bsr.w	nullsub_1
	tst.w	d0
	bmi.s	loc_1246E
	tst.w	d5
	bmi.s	loc_12468
	move.w	#$E102,(a4)
	bra.s	loc_12480
; ---------------------------------------------------------------------------

loc_12468:
	move.w	#$E101,(a4)
	bra.s	loc_12480
; ---------------------------------------------------------------------------

loc_1246E:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+

loc_12480:
	move.l	($FFFFF8D4).w,a5
	move.w	($FFFFF8D2).w,d6
	lsl.w	#3,d6
	add.w	d6,a5
	move.w	a4,(a5)+
	move.w	d1,(a5)+
	move.w	d2,(a5)+
	move.w	d5,(a5)+
	addq.w	#1,($FFFFF8D2).w
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_12454
	bra.w	loc_123E6

; =============== S U B	R O U T	I N E =======================================


nullsub_1:
	rts
; End of function nullsub_1

; ---------------------------------------------------------------------------

loc_124A6:
	move.l	a5,($FFFFF8DA).w

loc_124AA:
	move.w	(a1),d1
	bpl.s	loc_124BE
	addq.w	#2,a1
	rts
; ---------------------------------------------------------------------------
	dc.w $E304
	dc.w $E305
	dc.w $E306
	dc.w 0
	dc.w $E306
	dc.w $E305
; ---------------------------------------------------------------------------

loc_124BE:
	move.w	2(a1),d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	8(a1),(a5)+
	move.w	$A(a1),d0
	beq.s	loc_124E8
	cmpi.w	#3,d0
	beq.s	loc_124E8
	ori.w	#$8000,d0

loc_124E8:
	move.w	d0,(a5)+
	move.w	$C(a1),(a5)+
	move.w	$E(a1),(a5)+
	move.w	a4,(a5)+
	move.w	d1,(a5)+
	move.w	d2,(a5)+
	move.b	5(a1),(a5)+
	move.b	7(a1),(a5)+
	addq.w	#1,($FFFFF8D8).w
	tst.w	$A(a1)
	bne.s	loc_12520
	move.w	4(a1),d3
	subq.w	#1,d3
	tst.w	6(a1)
	bne.s	loc_12526

loc_12516:
	move.w	#$E304,(a4)
	addq.w	#2,a4
	dbf	d3,loc_12516

loc_12520:
	lea	$10(a1),a1
	bra.s	loc_124AA
; ---------------------------------------------------------------------------

loc_12526:
	move.w	#$E304,(a4)
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_12526
	lea	$10(a1),a1
	bra.w	loc_124AA
; ---------------------------------------------------------------------------

loc_1253A:

	move.w	(a1)+,d1
	bpl.s	loc_12540
	rts
; ---------------------------------------------------------------------------

loc_12540:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_1257E

loc_1255C:
	move.l	a4,a2
	move.w	#$B811,(a2)
	move.w	#$B812,2(a2)
	add.w	(Level_width_tiles).w,a2
	move.w	#$B813,(a2)
	move.w	#$B814,2(a2)
	addq.w	#4,a4
	dbf	d3,loc_1255C
	bra.s	loc_1253A
; ---------------------------------------------------------------------------

loc_1257E:
	move.l	a4,a2
	move.w	#$B811,(a2)
	move.w	#$B812,2(a2)
	add.w	(Level_width_tiles).w,a2
	move.w	#$B813,(a2)
	move.w	#$B814,2(a2)
	add.w	(Level_width_tiles).w,a4
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_1257E
	bra.s	loc_1253A
; ---------------------------------------------------------------------------

loc_125A6:

	move.w	(a1)+,d1
	bpl.s	loc_125AC
	rts
; ---------------------------------------------------------------------------

loc_125AC:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_12600

loc_125C8:
	move.w	(a1)+,d5
	tst.w	d0
	bmi.s	loc_125E6
	moveq	#0,d6
	move.b	d5,d6
	move.w	d6,(a4)
	cmpi.w	#$C,d0
	bne.s	loc_125E0
	addi.w	#-$13D3,(a4)
	bra.s	loc_125F8
; ---------------------------------------------------------------------------

loc_125E0:
	addi.w	#-$15E4,(a4)
	bra.s	loc_125F8
; ---------------------------------------------------------------------------

loc_125E6:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	move.b	d5,(a2)+

loc_125F8:
	addq.w	#2,a4
	dbf	d3,loc_125C8
	bra.s	loc_125A6
; ---------------------------------------------------------------------------

loc_12600:
	move.w	(a1)+,d5
	tst.w	d0
	bmi.s	loc_1261E
	moveq	#0,d6
	move.b	d5,d6
	move.w	d6,(a4)
	cmpi.w	#$C,d0
	bne.s	loc_12618
	addi.w	#-$13D3,(a4)
	bra.s	loc_12630
; ---------------------------------------------------------------------------

loc_12618:
	addi.w	#-$15E4,(a4)
	bra.s	loc_12630
; ---------------------------------------------------------------------------

loc_1261E:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	move.b	d5,(a2)+

loc_12630:
	add.w	(Level_width_tiles).w,a4
	dbf	d3,loc_12600
	bra.w	loc_125A6
; ---------------------------------------------------------------------------

loc_1263C:
	move.l	($FFFFF8E0).w,d1
	bne.s	loc_12646
	move.l	a5,($FFFFF8E0).w

loc_12646:
	move.w	(a1)+,d1
	bpl.s	loc_1264C
	rts
; ---------------------------------------------------------------------------

loc_1264C:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	tst.w	d0
	bmi.s	loc_12670
	move.w	#$E407,(a4)
	move.w	#$E408,2(a4)
	bra.s	loc_1269C
; ---------------------------------------------------------------------------

loc_12670:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+
	addq.w	#2,a4
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)
	addq.w	#1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	move.b	#1,(a2)+
	subq.w	#2,a4

loc_1269C:
	move.l	($FFFFF8E0).w,a5
	move.w	($FFFFF8DE).w,d6
	mulu.w	#$A,d6
	add.w	d6,a5
	move.w	a4,(a5)+
	move.w	d1,(a5)+
	move.w	d2,(a5)+
	move.w	(a1)+,(a5)+
	move.w	(a1)+,(a5)+
	addq.w	#1,($FFFFF8DE).w
	bra.s	loc_12646
; ---------------------------------------------------------------------------

loc_126BA:

	move.w	(a1)+,d1
	bpl.s	loc_126C0
	rts
; ---------------------------------------------------------------------------

loc_126C0:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	tst.w	d0
	bmi.s	loc_126DE
	move.w	#$EB2C,(a4)
	bra.s	loc_126BA
; ---------------------------------------------------------------------------

loc_126DE:
	bsr.w	sub_127A8
	bsr.w	sub_127CE
	move.w	a4,(a2)+
	move.w	d1,(a2)+
	move.w	d2,(a2)+
	move.b	d0,(a2)+
	clr.b	(a2)+
	bra.s	loc_126BA
; ---------------------------------------------------------------------------

loc_126F2:

	move.w	(a1)+,d1
	bpl.s	loc_126F8
	rts
; ---------------------------------------------------------------------------

loc_126F8:
	move.w	(a1)+,d2
	move.w	d2,d3
	add.w	d3,d3

loc_126FE:
	lea	($FFFF4A04).l,a2
	move.w	(a2,d3.w),a4
	add.w	d1,a4
	add.w	d1,a4
	move.w	(a1)+,d3
	subq.w	#1,d3
	tst.w	(a1)+
	bne.s	loc_12730

loc_12714:
	move.w	(a1)+,d5
	move.b	byte_1274E(pc,d5.w),d5
	lsl.b	#4,d5
	bsr.s	sub_12752
	addq.b	#1,d5
	bsr.w	sub_127A8
	move.b	d5,(a4)
	addq.w	#2,a4
	addq.w	#1,d1
	dbf	d3,loc_12714
	bra.s	loc_126F2
; ---------------------------------------------------------------------------

loc_12730:
	move.w	(a1)+,d5
	move.b	byte_1274E(pc,d5.w),d5
	lsl.b	#4,d5
	bsr.s	sub_12752
	addq.b	#1,d5
	bsr.w	sub_127A8
	move.b	d5,(a4)
	add.w	(Level_width_tiles).w,a4
	addq.w	#1,d2
	dbf	d3,loc_12730
	bra.s	loc_126F2
; ---------------------------------------------------------------------------
byte_1274E:	dc.b 0
	dc.b   5
	dc.b   4
	dc.b   6

; =============== S U B	R O U T	I N E =======================================


sub_12752:
	cmpi.b	#$40,d5
	bne.s	loc_12772
	addq.w	#1,d1
	addq.w	#2,a4
	bsr.s	sub_12792
	subq.w	#2,a4
	subq.w	#1,d1
	addq.w	#1,d2
	add.w	(Level_width_tiles).w,a4
	bsr.s	sub_12792
	suba.w	(Level_width_tiles).w,a4
	subq.w	#1,d2
	rts
; ---------------------------------------------------------------------------

loc_12772:
	cmpi.b	#$50,d5
	bne.s	return_12790
	subq.w	#1,d1
	subq.w	#2,a4
	bsr.s	sub_12792
	addq.w	#2,a4
	addq.w	#1,d1
	addq.w	#1,d2
	add.w	(Level_width_tiles).w,a4
	bsr.s	sub_12792
	suba.w	(Level_width_tiles).w,a4
	subq.w	#1,d2

return_12790:
	rts
; End of function sub_12752


; =============== S U B	R O U T	I N E =======================================


sub_12792:
	cmp.w	(Level_width_blocks).w,d1
	bcc.s	return_127A6
	cmp.w	(Level_height_pixels).w,d2
	bcc.s	return_127A6
	tst.b	(a4)
	bmi.s	return_127A6
	bset	#0,(a4)

return_127A6:
	rts
; End of function sub_12792


; =============== S U B	R O U T	I N E =======================================


sub_127A8:
	movem.l	d0/a0,-(sp)
	move.b	#$20,(a4)
	move.l	#$FF0000,d0
	move.w	a4,d0
	subi.w	#Level_Layout&$FFFF,d0
	lsr.w	#1,d0
	addi.w	#Level_terrain_layout&$FFFF,d0
	move.l	d0,a0
	move.b	(a0),1(a4)
	movem.l	(sp)+,d0/a0
	rts
; End of function sub_127A8


; =============== S U B	R O U T	I N E =======================================


sub_127CE:
	movem.l	d0/a0-a1,-(sp)
	move.w	a4,d0
	move.l	($FFFFF8EC).w,a0
	move.l	a0,a1

loc_127DA:
	cmp.w	(a0),d0
	bcs.s	loc_127E2
	addq.w	#8,a0
	bra.s	loc_127DA
; ---------------------------------------------------------------------------

loc_127E2:
	move.l	a0,a2
	move.w	($FFFFF8EA).w,d0
	lsl.w	#3,d0
	add.w	d0,a1
	move.w	a1,d0
	sub.w	a0,d0
	lsr.w	#3,d0
	addq.w	#8,a1
	lea	8(a1),a0

loc_127F8:
	move.l	-(a1),-(a0)
	move.l	-(a1),-(a0)
	dbf	d0,loc_127F8
	addq.w	#1,($FFFFF8EA).w
	movem.l	(sp)+,d0/a0-a1
	rts
; End of function sub_127CE


; =============== S U B	R O U T	I N E =======================================


sub_1280A:
; FUNCTION CHUNK AT 000128BA SIZE 000000F4 BYTES

	tst.b	(Background_format).w
	bne.w	loc_128BA
	cmpi.w	#$8000,(a1)
	beq.w	loc_12824
	movem.l	d5-d7,-(sp)
	moveq	#0,d5
	moveq	#0,d6
	bra.s	loc_12830
; ---------------------------------------------------------------------------

loc_12824:
	movem.l	d5-d7,-(sp)
	addq.w	#2,a1
	move.w	(a1)+,d5
	move.w	(a1)+,d6
	move.l	(a1),a1

loc_12830:
	move.w	(a1)+,d0
	bmi.s	loc_12842
	move.w	(a1)+,d2
	sub.w	d5,d2
	move.w	(a1)+,d3
	sub.w	d6,d3
	bsr.w	sub_12848
	bra.s	loc_12830
; ---------------------------------------------------------------------------

loc_12842:
	movem.l	(sp)+,d5-d7
	rts
; End of function sub_1280A


; =============== S U B	R O U T	I N E =======================================

; Load one chunk of background into background tile buffer
	; d3 = y position
	; d2 = x position
	; d0 = which chunk of background (index into table)
	; Background_theme = Background theme
	; Background_width = background (buffer) width
	; $FFFF87B2 = background tile buffer
sub_12848:
	movem.l	d5-d6,-(sp)
	move.w	d2,d7
	move.w	d3,d6
	lea	($FFFF4D5C).l,a2
	move.l	(LnkTo_off_7B3E4).l,a3
	move.w	(Background_theme).w,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a3,d1.w),a3
	lea	($FFFF87B2).w,a2
	muls.w	(Background_width).w,d3
	add.w	d3,a2
	add.w	d2,a2
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),a3
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	subq.w	#1,d2
	subq.w	#1,d3

loc_12884:
	move.w	d2,d4
	move.l	a2,a4
	move.w	d7,d5

loc_1288A:
	tst.w	d5
	bmi.s	loc_128A0
	cmp.w	(Background_width).w,d5
	bge.s	loc_128A0
	tst.w	d6
	bmi.s	loc_128A0
	cmp.w	(Background_height).w,d6
	bge.s	loc_128A0
	move.b	(a3),(a4)

loc_128A0:
	addq.w	#1,a3
	addq.w	#1,a4
	addq.w	#1,d5
	dbf	d4,loc_1288A
	add.w	(Background_width).w,a2
	addq.w	#1,d6
	dbf	d3,loc_12884
	movem.l	(sp)+,d5-d6
	rts
; End of function sub_12848

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_1280A

loc_128BA:
	move.l	a0,-(sp)
	move.l	(LnkTo_off_7B3E4).l,a3
	move.w	(Background_theme).w,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a3,d0.w),a3
	cmpi.w	#Mountain,(Background_theme).w
	beq.s	loc_12910
	cmpi.w	#Hills,(Background_theme).w
	beq.w	loc_1295E
	cmpi.w	#Desert,(Background_theme).w
	beq.w	loc_12988
	;Forest
	move.w	#$780,d0
	move.l	(a3)+,a0
	lea	($FFFF87B2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF8EB2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF95B2).w,a1
	bsr.w	EniDec
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_12910:	; mountain
	move.w	#$2780,d0
	move.l	(a3)+,a0
	lea	($FFFF87B2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF8EB2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF95B2).w,a1
	bsr.w	EniDec
	cmpi.w	#2,(Level_Special_Effects).w	; stormy level?
	beq.s	loc_1294A
	cmpi.w	#3,(Level_Special_Effects).w	; stormy + hail level?
	beq.s	loc_1294A
	move.w	#$7E5,d0
	move.l	(a3)+,a0
	bra.s	loc_12952
; ---------------------------------------------------------------------------

loc_1294A:	; hailstorm
	move.w	#$27E5,d0
	move.l	4(a3),a0

loc_12952:
	lea	($FFFF98F2).w,a1
	bsr.w	EniDec
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_1295E:	; hill
	move.w	#$2780,d0
	move.l	(a3)+,a0
	lea	($FFFF87B2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF8EB2).w,a1
	bsr.w	EniDec
	move.w	#$7C0,d0
	move.l	(a3)+,a0
	lea	($FFFF95B2).w,a1
	bsr.w	EniDec
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_12988:	; desert
	move.w	#$2780,d0
	move.l	(a3)+,a0
	lea	($FFFF87B2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF8EB2).w,a1
	bsr.w	EniDec
	move.l	(a3)+,a0
	lea	($FFFF95B2).w,a1
	bsr.w	EniDec
	move.l	(sp)+,a0
	rts
; END OF FUNCTION CHUNK	FOR sub_1280A

; =============== S U B	R O U T	I N E =======================================


sub_129AE:
	cmpi.w	#Forest,(Background_theme).w
	bne.s	return_129CC
	move.w	(Palette_Buffer+$30).l,d0
	move.w	(Palette_Buffer+$34).l,(Palette_Buffer+$30).l
	move.w	d0,(Palette_Buffer+$34).l

return_129CC:
	rts
; End of function sub_129AE


; =============== S U B	R O U T	I N E =======================================


sub_129CE:
	move.l	#vdpComm($CDC0,VRAM,WRITE),4(a6)
	lea	ArtUnc_12A08(pc),a1
	moveq	#$1F,d0

loc_129DC:
	move.l	(a1)+,(a6)
	dbf	d0,loc_129DC
	lea	ArtUnc_12A8C(pc),a1
	moveq	#$1F,d0

loc_129E8:
	move.l	(a1)+,(a6)
	dbf	d0,loc_129E8
	move.l	#vdpComm($DF40,VRAM,WRITE),4(a6)
	lea	ArtUnc_12B0C(pc),a1
	moveq	#$1F,d0

loc_129FC:
	move.l	(a1)+,(a6)
	dbf	d0,loc_129FC
	rts
; End of function sub_129CE

; ---------------------------------------------------------------------------
	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b  $E
ArtUnc_12A08:  binclude    "ingame/artunc/Juggernaut_skull_frame_1.bin"
	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b $10
ArtUnc_12A8C:  binclude    "ingame/artunc/Juggernaut_skull_frame_2.bin"
ArtUnc_12B0C:  binclude    "ingame/artunc/Some_kind_of_star.bin"
; =============== S U B	R O U T	I N E =======================================


sub_12B8C:
	move.l	#vdpComm($D2C0,VRAM,WRITE),4(a6)
	lea	ArtUnc_12BA4(pc),a1
	move.w	#$1F,d0

loc_12B9C:
	move.l	(a1)+,(a6)
	dbf	d0,loc_12B9C
	rts
; End of function sub_12B8C

; ---------------------------------------------------------------------------
ArtUnc_12BA4:  binclude    "ingame/artunc/Flag_bottom.bin"
; =============== S U B	R O U T	I N E =======================================


sub_12C24:
	move.l	#vdpComm($45A0,VRAM,WRITE),4(a6)
	lea	ArtUnc_12C3C(pc),a1
	move.w	#$1F,d0

loc_12C34:
	move.l	(a1)+,(a6)
	dbf	d0,loc_12C34
	rts
; End of function sub_12C24

; ---------------------------------------------------------------------------
ArtUnc_12C3C:  binclude    "ingame/artunc/Hitpoint_display.bin"
Pal_12CBC:  binclude    "theme/palette_fg/cave_plethora.bin"
Pal_12CDA:  binclude    "theme/palette_fg/cave_alt.bin"
Pal_12CF8:  binclude    "theme/palette_bg/cave_alt.bin"
Pal_12D08:  binclude    "theme/palette_fg/city_unused.bin"
Pal_12D26:  binclude    "theme/palette_fg/city_alt.bin"
Pal_12D44:  binclude    "theme/palette_bg/city_unused.bin"
Pal_12D54:  binclude    "theme/palette_bg/city_alt.bin"
Pal_heaven_fg:  binclude    "theme/palette_fg/heaven.bin"
Pal_heaven_bg:  binclude    "theme/palette_bg/heaven.bin"
Pal_hell_fg:  binclude    "theme/palette_fg/hell.bin"
Pal_hell_bg:  binclude    "theme/palette_bg/hell.bin"
Pal_city_light_fg:  binclude    "theme/palette_fg/city_light.bin"
Pal_city_light_bg:  binclude    "theme/palette_bg/city_light.bin"
Pal_city_dark_fg:  binclude    "theme/palette_fg/city_dark.bin"
Pal_city_dark_bg:  binclude    "theme/palette_bg/city_dark.bin"
Pal_space_fg:  binclude    "theme/palette_fg/space.bin"
Pal_space_bg:  binclude    "theme/palette_bg/space.bin"
Pal_botanic_fg:  binclude    "theme/palette_fg/botanic.bin"
Pal_botanic_bg:  binclude    "theme/palette_bg/botanic.bin"

; =============== S U B	R O U T	I N E =======================================


sub_12D64:

	move.w	#$CEC0,d0
	lea	ArtComp_12D70(pc),a0
	bra.w	DecompressToVRAM	; a0 - source address
; End of function sub_12D64		; d0 - offset in VRAM (destination)

; ---------------------------------------------------------------------------
ArtComp_12D70:  binclude    "scenes/artcomp/Some_geometric_patterns.bin"
	align 2
; ---------------------------------------------------------------------------
; 12DD0
Load_SegaScreen:
	jsr	(j_StopMusic).l
	move	#$2700,sr
	move.w	#$8134,4(a6)
	move.w	#$1780,d0
	lea	ArtComp_12F30_Sega(pc),a0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	lea	Pal_12EEC(pc),a2
	moveq	#0,d7
	move.b	(a2)+,d7
	lea	(Palette_Buffer).l,a3
	add.w	d7,a3
	move.b	(a2)+,d7

loc_12DFE:
	move.w	(a2)+,(a3)+
	dbf	d7,loc_12DFE
	move.w	#$80BC,d1
	move.l	#vdpComm($061C,VRAM,WRITE),4(a6)
	bsr.w	sub_12E3C
	move.l	#vdpComm($069C,VRAM,WRITE),4(a6)
	bsr.w	sub_12E3C
	move.l	#vdpComm($071C,VRAM,WRITE),4(a6)
	bsr.w	sub_12E3C
	move.l	#vdpComm($079C,VRAM,WRITE),4(a6)
	bsr.w	sub_12E3C
	bra.w	loc_12E48

; =============== S U B	R O U T	I N E =======================================


sub_12E3C:
	moveq	#$B,d0

loc_12E3E:
	move.w	d1,(a6)
	addq.w	#1,d1
	dbf	d0,loc_12E3E
	rts
; End of function sub_12E3C

; ---------------------------------------------------------------------------

loc_12E48:
	move.w	#$8174,4(a6)
	move	#$2500,sr
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_12E64,4(a0)
	rts
; ---------------------------------------------------------------------------

loc_12E64:
	clr.b	(Ctrl_Pressed).w
	move.w	#$A,d2

loc_12E6C:
	move.w	d2,-(sp)
	jsr	(j_WaitForVint).w
	jsr	(j_ReadJoypad).w
	bclr	#7,(Ctrl_1_Pressed).w
	bne.w	loc_12EDE
	jsr	(j_Do_Nothing).w
	jsr	(j_Palette_to_VRAM).w
	move.w	(sp)+,d2
	dbf	d2,loc_12E6C
	moveq	#$28,d3
	move.w	#$80,d2
	moveq	#$14,d1

loc_12E96:
	move.w	d2,-(sp)
	move.w	d1,-(sp)
	jsr	(j_WaitForVint).w
	jsr	(j_ReadJoypad).w
	move.w	(sp)+,d1
	bclr	#7,(Ctrl_1_Pressed).w
	bne.s	loc_12EDE
	jsr	(j_Do_Nothing).w
	move.w	d1,-(sp)
	jsr	(j_Palette_to_VRAM).w
	move.w	(sp)+,d1
	subq.w	#1,d1
	bpl.s	loc_12ED8
	moveq	#3,d1
	move.w	d3,d0
	bmi.w	loc_12ED8
	subq.w	#2,d3
	lea	Pal_12EEC+6(pc,d0.w),a0
	lea	(Palette_Buffer+$4).l,a1
	moveq	#$A,d0

loc_12ED2:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_12ED2

loc_12ED8:
	move.w	(sp)+,d2
	dbf	d2,loc_12E96

loc_12EDE:
	move.w	#4,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------
Pal_12EEC:	dc.b   0
	dc.b  $C
	binclude	"scenes/palette/SegaLogo.bin"
ArtComp_12F30_Sega:  binclude    "scenes/artcomp/Sega_Logo.bin"
	align	2
; ---------------------------------------------------------------------------
; 1329E
LoadBlockLayout:
	cmpi.b	#$40,(a1)
	beq.s	loc_132A6
	rts
; ---------------------------------------------------------------------------

loc_132A6:
	movem.l	d0-a0/a2-a6,-(sp)
	move.l	a1,a0
	bsr.w	sub_13618
	lea	(Decompression_Buffer).l,a1
	moveq	#8,d0
	bsr.w	sub_13622
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,a2
	add.w	d1,d1
	lea	return_13662(pc),a5
	move.w	(a5,d1.w),a5
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,a3

loc_132D6:
	moveq	#1,d0
	bsr.w	sub_13622
	ror.w	#1,d1
	move.w	d1,d2
	moveq	#5,d0
	bsr.w	sub_13622
	cmpi.w	#$1F,d1
	beq.w	loc_134BA
	or.w	d1,d2
	move.w	d2,(a1)+
	add.w	d1,d1
	move.w	off_132FC(pc,d1.w),d1
	jmp	off_132FC(pc,d1.w)
; ---------------------------------------------------------------------------
off_132FC:	dc.w loc_1331E-off_132FC 
	dc.w loc_1334C-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_133DE-off_132FC
	dc.w loc_1342E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_133A0-off_132FC
	dc.w loc_1345E-off_132FC
	dc.w loc_133A0-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1331E-off_132FC
	dc.w loc_1347C-off_132FC
; ---------------------------------------------------------------------------

loc_1331E:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_1332E
	move.w	#$FFFF,(a1)+
	bra.s	loc_132D6
; ---------------------------------------------------------------------------

loc_1332E:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#4,d0
	bsr.w	sub_13622
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#1,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	bra.s	loc_1331E
; ---------------------------------------------------------------------------

loc_1334C:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_1335E
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_1335E:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,d2
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#1,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+

loc_1337C:
	moveq	#1,d0
	bsr.w	sub_13622
	tst.w	d1
	beq.s	loc_13392
	moveq	#4,d0
	bsr.w	sub_13622
	ori.w	#$8000,d1
	bra.s	loc_13398
; ---------------------------------------------------------------------------

loc_13392:
	moveq	#4,d0
	bsr.w	sub_13622

loc_13398:
	move.w	d1,(a1)+
	dbf	d2,loc_1337C
	bra.s	loc_1334C
; ---------------------------------------------------------------------------

loc_133A0:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_133B2
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_133B2:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,d2
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#1,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+

loc_133D0:
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	dbf	d2,loc_133D0
	bra.s	loc_133A0
; ---------------------------------------------------------------------------

loc_133DE:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_133F0
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_133F0:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#3,d0
	bsr.w	sub_13622
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#1,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#8,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#8,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#8,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	bra.s	loc_133DE
; ---------------------------------------------------------------------------

loc_1342E:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_13440
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_13440:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#$10,d0
	bsr.w	sub_13622
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#9,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	bra.s	loc_1342E
; ---------------------------------------------------------------------------

loc_1345E:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_13470
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_13470:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	bra.s	loc_1345E
; ---------------------------------------------------------------------------

loc_1347C:

	move.w	a2,d0
	bsr.w	sub_13622
	cmp.w	a5,d1
	bne.s	loc_1348E
	move.w	#$FFFF,(a1)+
	bra.w	loc_132D6
; ---------------------------------------------------------------------------

loc_1348E:
	move.w	d1,(a1)+
	move.w	a3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	moveq	#4,d0
	bsr.w	sub_13622
	move.w	d1,d2
	addq.w	#1,d1
	move.w	d1,(a1)+
	moveq	#1,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+

loc_134AC:
	moveq	#3,d0
	bsr.w	sub_13622
	move.w	d1,(a1)+
	dbf	d2,loc_134AC
	bra.s	loc_1347C
; ---------------------------------------------------------------------------

loc_134BA:
	move.w	#$FFFF,(a1)
	lea	(Decompression_Buffer).l,a1
	movem.l	(sp)+,d0-a0/a2-a6
	rts

; =============== S U B	R O U T	I N E =======================================


EniDec:

; FUNCTION CHUNK AT 00013570 SIZE 00000018 BYTES

	movem.l	d0-d7/a1-a5,-(sp)
	move.w	d0,a3
	move.b	(a0)+,d0
	ext.w	d0
	move.w	d0,a5
	move.b	(a0)+,d4
	lsl.b	#3,d4
	move.w	(a0)+,a2
	add.w	a3,a2
	move.w	(a0)+,a4
	add.w	a3,a4
	move.b	(a0)+,d5
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#$10,d6

loc_134EA:
	moveq	#7,d0
	move.w	d6,d7
	sub.w	d0,d7
	move.w	d5,d1
	lsr.w	d7,d1
	andi.w	#$7F,d1
	move.w	d1,d2
	cmpi.w	#$40,d1
	bcc.s	loc_13504
	moveq	#6,d0
	lsr.w	#1,d2

loc_13504:
	bsr.w	loc_13650
	andi.w	#$F,d2
	lsr.w	#4,d1
	add.w	d1,d1
	jmp	loc_13560(pc,d1.w)
; ---------------------------------------------------------------------------

loc_13514:
				; EniDec:loc_13560j ...
	move.w	a2,(a1)+
	addq.w	#1,a2
	dbf	d2,loc_13514
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_1351E:
	move.w	a4,(a1)+
	dbf	d2,loc_1351E
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_13526:
	bsr.w	sub_13588

loc_1352A:
	move.w	d1,(a1)+
	dbf	d2,loc_1352A
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_13532:
	bsr.w	sub_13588

loc_13536:
	move.w	d1,(a1)+
	addq.w	#1,d1
	dbf	d2,loc_13536
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_13540:
	bsr.w	sub_13588

loc_13544:
	move.w	d1,(a1)+
	subq.w	#1,d1
	dbf	d2,loc_13544
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_1354E:
	cmpi.w	#$F,d2
	beq.s	loc_13570

loc_13554:
	bsr.w	sub_13588
	move.w	d1,(a1)+
	dbf	d2,loc_13554
	bra.s	loc_134EA
; ---------------------------------------------------------------------------

loc_13560:
	bra.s	loc_13514
; End of function EniDec

; ---------------------------------------------------------------------------
	bra.s	loc_13514
; ---------------------------------------------------------------------------
	bra.s	loc_1351E
; ---------------------------------------------------------------------------
	bra.s	loc_1351E
; ---------------------------------------------------------------------------
	bra.s	loc_13526
; ---------------------------------------------------------------------------
	bra.s	loc_13532
; ---------------------------------------------------------------------------
	bra.s	loc_13540
; ---------------------------------------------------------------------------
	bra.s	loc_1354E
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR EniDec

loc_13570:
	subq.w	#1,a0
	cmpi.w	#$10,d6
	bne.s	loc_1357A
	subq.w	#1,a0

loc_1357A:
	move.w	a0,d0
	lsr.w	#1,d0
	bcc.s	loc_13582
	addq.w	#1,a0

loc_13582:
	movem.l	(sp)+,d0-d7/a1-a5
	rts
; END OF FUNCTION CHUNK	FOR EniDec

; =============== S U B	R O U T	I N E =======================================


sub_13588:
				; EniDec:loc_13532p ...
	move.w	a3,d3
	move.b	d4,d1
	add.b	d1,d1
	bcc.s	loc_1359A
	subq.w	#1,d6
	btst	d6,d5
	beq.s	loc_1359A
	ori.w	#$8000,d3

loc_1359A:
	add.b	d1,d1
	bcc.s	loc_135A8
	subq.w	#1,d6
	btst	d6,d5
	beq.s	loc_135A8
	addi.w	#$4000,d3

loc_135A8:
	add.b	d1,d1
	bcc.s	loc_135B6
	subq.w	#1,d6
	btst	d6,d5
	beq.s	loc_135B6
	addi.w	#$2000,d3

loc_135B6:
	add.b	d1,d1
	bcc.s	loc_135C4
	subq.w	#1,d6
	btst	d6,d5
	beq.s	loc_135C4
	ori.w	#$1000,d3

loc_135C4:
	add.b	d1,d1
	bcc.s	loc_135D2
	subq.w	#1,d6
	btst	d6,d5
	beq.s	loc_135D2
	ori.w	#$800,d3

loc_135D2:
	move.w	d5,d1
	move.w	d6,d7
	sub.w	a5,d7
	bcc.s	loc_13602
	move.w	d7,d6
	addi.w	#$10,d6
	neg.w	d7
	lsl.w	d7,d1
	move.b	(a0),d5
	rol.b	d7,d5
	add.w	d7,d7
	and.w	return_13662(pc,d7.w),d5
	add.w	d5,d1

loc_135F0:
	move.w	a5,d0
	add.w	d0,d0
	and.w	return_13662(pc,d0.w),d1
	add.w	d3,d1
	move.b	(a0)+,d5
	lsl.w	#8,d5
	move.b	(a0)+,d5
	rts
; ---------------------------------------------------------------------------

loc_13602:
	beq.s	loc_13614
	lsr.w	d7,d1
	move.w	a5,d0
	add.w	d0,d0
	and.w	return_13662(pc,d0.w),d1
	add.w	d3,d1
	move.w	a5,d0
	bra.s	loc_13650
; ---------------------------------------------------------------------------

loc_13614:
	moveq	#$10,d6
	bra.s	loc_135F0
; End of function sub_13588


; =============== S U B	R O U T	I N E =======================================


sub_13618:
	move.b	(a0)+,d5
	asl.w	#8,d5
	move.b	(a0)+,d5
	moveq	#$10,d6
	rts
; End of function sub_13618


; =============== S U B	R O U T	I N E =======================================


sub_13622:
	cmpi.w	#8,d0
	ble.s	sub_1364C
	subq.w	#8,d0
	bsr.w	sub_1364C
	lsl.w	#8,d1
	move.w	d1,-(sp)
	moveq	#8,d0
	bsr.w	sub_1364C
	or.w	(sp)+,d1
	rts
; End of function sub_13622


; =============== S U B	R O U T	I N E =======================================


sub_1363C:
	move.w	d6,d7
	sub.w	d0,d7
	move.w	d5,d1
	lsr.w	d7,d1
	add.w	d0,d0
	and.w	return_13662(pc,d0.w),d1
	rts
; End of function sub_1363C


; =============== S U B	R O U T	I N E =======================================


sub_1364C:
	bsr.s	sub_1363C
	lsr.w	#1,d0
; End of function sub_1364C


loc_13650:
	sub.w	d0,d6
	cmpi.w	#9,d6
	bcc.w	return_13662
	addi.w	#8,d6
	asl.w	#8,d5
	move.b	(a0)+,d5

return_13662:

	rts
; ---------------------------------------------------------------------------
	dc.w	 1
	dc.w	 3
	dc.w	 7
	dc.w	$F
	dc.w   $1F
	dc.w   $3F
	dc.w   $7F
	dc.w   $FF
	dc.w  $1FF
	dc.w  $3FF
	dc.w  $7FF
	dc.w  $FFF
	dc.w $1FFF
	dc.w $3FFF
	dc.w $7FFF
	dc.w $FFFF

; =============== S U B	R O U T	I N E =======================================

;sub_13684
Decompress_Chunk:
	moveq	#0,d0
	move.w	#$7FF,d4
	moveq	#0,d5
	moveq	#0,d6
	move.w	a3,d7
	subq.w	#1,d2
	beq.w	loc_13A24
	subq.w	#1,d2
	beq.w	loc_139A6
	subq.w	#1,d2
	beq.w	loc_13928
	subq.w	#1,d2
	beq.w	loc_138AA
	subq.w	#1,d2
	beq.w	loc_1382E
	subq.w	#1,d2
	beq.w	loc_137B0
	subq.w	#1,d2
	beq.w	loc_13736

Decompress_BitPos0:
	move.b	(a0)+,d1
	add.b	d1,d1
	bcs.s	Decompress_BP0_DrcCpy
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	Decompress_BP0_LongRef
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_136D0
	move.b	(a6)+,(a2)+

loc_136D0:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13724
	bra.w	loc_1382E
; ---------------------------------------------------------------------------

Decompress_BP0_LongRef:
	lsl.w	#3,d1
	move.w	d1,d6
	and.w	d4,d6		; d4 = $7FF
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	Decompress_BP0_LongRef_2or3
	add.b	d1,d1
	bcs.s	loc_13706
	bra.s	loc_13708
; ---------------------------------------------------------------------------

Decompress_BP0_LongRef_2or3:
	add.b	d1,d1
	bcc.s	Decompress_BP0_LongRef_2
	moveq	#0,d0
	move.b	(a1)+,d0	; read amount of bytes
	beq.s	loc_13716
	subq.w	#6,d0
	bmi.s	loc_1371C

loc_136FE:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_136FE

Decompress_BP0_LongRef_2:
	move.b	(a6)+,(a2)+

loc_13706:
	move.b	(a6)+,(a2)+

loc_13708:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_1372C
	bra.w	loc_13A24
; ---------------------------------------------------------------------------

loc_13716:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_1371C:
	move.w	#$FFFF,d0
	moveq	#1,d2
	rts
; ---------------------------------------------------------------------------

loc_13724:
	move.w	#1,d0
	moveq	#5,d2
	rts
; ---------------------------------------------------------------------------

loc_1372C:
	move.w	#1,d0
	moveq	#1,d2
	rts
; ---------------------------------------------------------------------------

Decompress_BP0_DrcCpy:
	move.b	(a1)+,(a2)+

loc_13736:
	add.b	d1,d1
	bcs.s	loc_137AE	; top bit = 1 --> direct copy
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_13756	; top bits 01 --> long ref
	; top bits 00 --> short ref 00:A
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_1374A	; A = 0 --> copy 2 tiles
	; A = 1 --> copy 3 tiles
	move.b	(a6)+,(a2)+

loc_1374A:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_1379E
	bra.w	loc_138AA
; ---------------------------------------------------------------------------

loc_13756:	; long ref 01:BBB:AA
	lsl.w	#3,d1	; skip 3 bits, put the into upper byte of word
	move.w	d1,d6
	and.w	d4,d6	; d4 = $7FF? is that always true?
	move.b	(a1)+,d6	; d6 = BBB*256 + BYTE1
	suba.l	d6,a6	; address to copy from
	add.b	d1,d1
	bcs.s	loc_1376A	; first bit of AA is 1
	add.b	d1,d1
	bcs.s	loc_13780	; AA = 01 --> copy 4 tiles
	bra.s	loc_13782	; AA = 00 --> copy 3 tiles
; ---------------------------------------------------------------------------

loc_1376A:
	add.b	d1,d1
	bcc.s	loc_1377E	; AA = 10 --> copy 5 tiles
	; AA = 11 --> copy 6 or more tiles
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_13790	; BYTE2 = 0 means: quit decompression
	subq.w	#6,d0
	bmi.s	loc_13796	; 0 < BYTE2 < 6 means: flush buffer

loc_13778:	; copy BYTE2 tiles
	move.b	(a6)+,(a2)+
	dbf	d0,loc_13778

loc_1377E:
	move.b	(a6)+,(a2)+

loc_13780:
	move.b	(a6)+,(a2)+

loc_13782:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_137A6
	bra.w	Decompress_BitPos0
; ---------------------------------------------------------------------------

loc_13790:	; quit decompression
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_13796:	; flush decompression buffer
	move.w	#$FFFF,d0
	moveq	#0,d2
	rts
; ---------------------------------------------------------------------------

loc_1379E:
	move.w	#1,d0
	moveq	#4,d2
	rts
; ---------------------------------------------------------------------------

loc_137A6:
	move.w	#1,d0
	moveq	#0,d2
	rts
; ---------------------------------------------------------------------------

loc_137AE:
	move.b	(a1)+,(a2)+

loc_137B0:
	add.b	d1,d1
	bcs.s	loc_1382C
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_137D0
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_137C4
	move.b	(a6)+,(a2)+

loc_137C4:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_1381C
	bra.w	loc_13928
; ---------------------------------------------------------------------------

loc_137D0:
	lsl.w	#3,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_137E6
	move.b	(a0)+,d1
	add.b	d1,d1
	bcs.s	loc_137FE
	bra.s	loc_13800
; ---------------------------------------------------------------------------

loc_137E6:
	move.b	(a0)+,d1
	add.b	d1,d1
	bcc.s	loc_137FC
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_1380E
	subq.w	#6,d0
	bmi.s	loc_13814

loc_137F6:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_137F6

loc_137FC:
	move.b	(a6)+,(a2)+

loc_137FE:
	move.b	(a6)+,(a2)+

loc_13800:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13824
	bra.w	loc_13736
; ---------------------------------------------------------------------------

loc_1380E:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_13814:
	move.w	#$FFFF,d0
	moveq	#7,d2
	rts
; ---------------------------------------------------------------------------

loc_1381C:
	move.w	#1,d0
	moveq	#3,d2
	rts
; ---------------------------------------------------------------------------

loc_13824:
	move.w	#1,d0
	moveq	#7,d2
	rts
; ---------------------------------------------------------------------------

loc_1382C:
	move.b	(a1)+,(a2)+

loc_1382E:
	add.b	d1,d1
	bcs.s	loc_138A8
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_1384E
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_13842
	move.b	(a6)+,(a2)+

loc_13842:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13898
	bra.w	loc_139A6
; ---------------------------------------------------------------------------

loc_1384E:
	lsl.w	#3,d1
	move.b	(a0)+,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_13864
	add.b	d1,d1
	bcs.s	loc_1387A
	bra.s	loc_1387C
; ---------------------------------------------------------------------------

loc_13864:
	add.b	d1,d1
	bcc.s	loc_13878
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_1388A
	subq.w	#6,d0
	bmi.s	loc_13890

loc_13872:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_13872

loc_13878:
	move.b	(a6)+,(a2)+

loc_1387A:
	move.b	(a6)+,(a2)+

loc_1387C:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_138A0
	bra.w	loc_137B0
; ---------------------------------------------------------------------------

loc_1388A:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_13890:
	move.w	#$FFFF,d0
	moveq	#6,d2
	rts
; ---------------------------------------------------------------------------

loc_13898:
	move.w	#1,d0
	moveq	#2,d2
	rts
; ---------------------------------------------------------------------------

loc_138A0:
	move.w	#1,d0
	moveq	#6,d2
	rts
; ---------------------------------------------------------------------------

loc_138A8:
	move.b	(a1)+,(a2)+

loc_138AA:
	add.b	d1,d1
	bcs.s	loc_13926
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_138CA
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_138BE
	move.b	(a6)+,(a2)+

loc_138BE:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13916
	bra.w	loc_13A24
; ---------------------------------------------------------------------------

loc_138CA:
	lsl.w	#2,d1
	move.b	(a0)+,d1
	add.w	d1,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_138E2
	add.b	d1,d1
	bcs.s	loc_138F8
	bra.s	loc_138FA
; ---------------------------------------------------------------------------

loc_138E2:
	add.b	d1,d1
	bcc.s	loc_138F6
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_13908
	subq.w	#6,d0
	bmi.s	loc_1390E

loc_138F0:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_138F0

loc_138F6:
	move.b	(a6)+,(a2)+

loc_138F8:
	move.b	(a6)+,(a2)+

loc_138FA:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_1391E
	bra.w	loc_1382E
; ---------------------------------------------------------------------------

loc_13908:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_1390E:
	move.w	#$FFFF,d0
	moveq	#5,d2
	rts
; ---------------------------------------------------------------------------

loc_13916:
	move.w	#1,d0
	moveq	#1,d2
	rts
; ---------------------------------------------------------------------------

loc_1391E:
	move.w	#1,d0
	moveq	#5,d2
	rts
; ---------------------------------------------------------------------------

loc_13926:
	move.b	(a1)+,(a2)+

loc_13928:
	add.b	d1,d1
	bcs.s	loc_139A4
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_13948
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_1393C
	move.b	(a6)+,(a2)+

loc_1393C:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13994
	bra.w	Decompress_BitPos0
; ---------------------------------------------------------------------------

loc_13948:
	add.w	d1,d1
	move.b	(a0)+,d1
	lsl.w	#2,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_13960
	add.b	d1,d1
	bcs.s	loc_13976
	bra.s	loc_13978
; ---------------------------------------------------------------------------

loc_13960:
	add.b	d1,d1
	bcc.s	loc_13974
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_13986
	subq.w	#6,d0
	bmi.s	loc_1398C

loc_1396E:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_1396E

loc_13974:
	move.b	(a6)+,(a2)+

loc_13976:
	move.b	(a6)+,(a2)+

loc_13978:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_1399C
	bra.w	loc_138AA
; ---------------------------------------------------------------------------

loc_13986:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_1398C:
	move.w	#$FFFF,d0
	moveq	#4,d2
	rts
; ---------------------------------------------------------------------------

loc_13994:
	move.w	#1,d0
	moveq	#8,d2
	rts
; ---------------------------------------------------------------------------

loc_1399C:
	move.w	#1,d0
	moveq	#4,d2
	rts
; ---------------------------------------------------------------------------

loc_139A4:
	move.b	(a1)+,(a2)+

loc_139A6:
	add.b	d1,d1
	bcs.s	loc_13A22
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_139C8
	move.b	(a0)+,d1
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_139BC
	move.b	(a6)+,(a2)+

loc_139BC:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13A12
	bra.w	loc_13736
; ---------------------------------------------------------------------------

loc_139C8:
	move.b	(a0)+,d1
	lsl.w	#3,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_139DE
	add.b	d1,d1
	bcs.s	loc_139F4
	bra.s	loc_139F6
; ---------------------------------------------------------------------------

loc_139DE:
	add.b	d1,d1
	bcc.s	loc_139F2
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_13A04
	subq.w	#6,d0
	bmi.s	loc_13A0A

loc_139EC:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_139EC

loc_139F2:
	move.b	(a6)+,(a2)+

loc_139F4:
	move.b	(a6)+,(a2)+

loc_139F6:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13A1A
	bra.w	loc_13928
; ---------------------------------------------------------------------------

loc_13A04:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_13A0A:
	move.w	#$FFFF,d0
	moveq	#3,d2
	rts
; ---------------------------------------------------------------------------

loc_13A12:
	move.w	#1,d0
	moveq	#7,d2
	rts
; ---------------------------------------------------------------------------

loc_13A1A:
	move.w	#1,d0
	moveq	#3,d2
	rts
; ---------------------------------------------------------------------------

loc_13A22:
	move.b	(a1)+,(a2)+

loc_13A24:
	add.b	d1,d1
	bcs.s	loc_13A9E
	move.b	(a0)+,d1
	move.l	a2,a6
	add.b	d1,d1
	bcs.s	loc_13A46
	move.b	(a1)+,d5
	suba.l	d5,a6
	add.b	d1,d1
	bcc.s	loc_13A3A
	move.b	(a6)+,(a2)+

loc_13A3A:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13A8E
	bra.w	loc_137B0
; ---------------------------------------------------------------------------

loc_13A46:
	lsl.w	#3,d1
	move.w	d1,d6
	and.w	d4,d6
	move.b	(a1)+,d6
	suba.l	d6,a6
	add.b	d1,d1
	bcs.s	loc_13A5A
	add.b	d1,d1
	bcs.s	loc_13A70
	bra.s	loc_13A72
; ---------------------------------------------------------------------------

loc_13A5A:
	add.b	d1,d1
	bcc.s	loc_13A6E
	moveq	#0,d0
	move.b	(a1)+,d0
	beq.s	loc_13A80
	subq.w	#6,d0
	bmi.s	loc_13A86

loc_13A68:
	move.b	(a6)+,(a2)+
	dbf	d0,loc_13A68

loc_13A6E:
	move.b	(a6)+,(a2)+

loc_13A70:
	move.b	(a6)+,(a2)+

loc_13A72:
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	move.b	(a6)+,(a2)+
	cmp.w	a2,d7
	bls.s	loc_13A96
	bra.w	loc_139A6
; ---------------------------------------------------------------------------

loc_13A80:
	move.w	#0,d0
	rts
; ---------------------------------------------------------------------------

loc_13A86:
	move.w	#$FFFF,d0
	moveq	#2,d2
	rts
; ---------------------------------------------------------------------------

loc_13A8E:
	move.w	#1,d0
	moveq	#6,d2
	rts
; ---------------------------------------------------------------------------

loc_13A96:
	move.w	#1,d0
	moveq	#2,d2
	rts
; ---------------------------------------------------------------------------

loc_13A9E:
	move.b	(a1)+,(a2)+
	bra.w	Decompress_BitPos0
; End of function Decompress_Chunk

; ---------------------------------------------------------------------------
ArtComp_13AA4:
	binclude    "ingame/artcomp/Murder_wall.bin"
	align	2
Pal_1408A:
	binclude	"ingame/palette/Murder_wall.bin"

; =============== S U B	R O U T	I N E =======================================


Murderwall:
	move.b	#1,($FFFFFAC0).w
	move.b	#0,($FFFFFABF).w
	move.l	#$20000,(MurderWall_max_speed).w ; Bloody Swamp and Forced Entry
	cmpi.w	#L_Hills_of_the_Warrior_1,(Current_LevelID).w
	bne.s	loc_140BE
	move.l	#$18000,(MurderWall_max_speed).w ; Hills of the Warrior 1

loc_140BE:
	clr.l	(MurderWall_speed).w
	move.w	(Camera_X_pos).w,d0
	beq.s	loc_140CE
	addi.w	#$30,d0
	bra.s	loc_140D2
; ---------------------------------------------------------------------------

loc_140CE:
	subi.w	#$30,d0

loc_140D2:
	move.w	d0,($FFFFFAC4).w
	lea	ArtComp_13AA4(pc),a0
	move.w	#$5F60,d0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	lea	Pal_1408A(pc),a0
	lea	(Palette_Buffer+$20).l,a1
	moveq	#7,d0

loc_140EE:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_140EE
	rts
; End of function Murderwall


; =============== S U B	R O U T	I N E =======================================


sub_140F6:
	move.b	($FFFFFAD2).w,d1
	bne.s	loc_140FE
	rts
; ---------------------------------------------------------------------------

loc_140FE:
	ext.w	d1
	lea	($FFFF4A04).l,a0
	move.w	(Level_height_pixels).w,d0
	sub.w	d1,d0
	subq.w	#1,d0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.l	a0,a1
	move.w	(Level_width_blocks).w,d2
	add.w	d2,d2
	move.w	d2,d3
	mulu.w	d1,d2
	add.w	d2,a1
	move.w	(Level_height_pixels).w,d0
	subq.w	#1,d0
	sub.b	($FFFFFAD2).w,d0
	move.l	a0,d7
	move.l	a1,d6
	move.w	(Level_width_blocks).w,d1
	subq.w	#1,d1
	move.w	d1,d2

loc_14138:
	move.w	d2,d1

loc_1413A:
	move.w	(a0)+,(a1)+
	dbf	d1,loc_1413A
	sub.w	d3,d7
	move.w	d7,a0
	sub.w	d3,d6
	move.w	d6,a1
	dbf	d0,loc_14138
	move.b	($FFFFFAD2).w,d0
	subq.w	#1,d0
	ext.w	d0
	moveq	#0,d4

loc_14156:
	move.w	d2,d1

loc_14158:
	move.w	d4,(a1)+
	dbf	d1,loc_14158
	sub.w	d3,d6
	move.w	d6,a1
	dbf	d0,loc_14156
	move.b	($FFFFFAD2).w,d1
	ext.w	d1
	lea	($FFFF4BB8).l,a0
	move.w	(Level_height_pixels).w,d0
	sub.w	d1,d0
	subq.w	#1,d0
	add.w	d0,d0
	move.w	(a0,d0.w),d7
	ori.l	#$FFFF0000,d7
	move.l	d7,a0
	move.l	a0,a1
	move.w	(Level_width_blocks).w,d2
	move.w	d2,d3
	mulu.w	d1,d2
	add.w	d2,a1
	move.w	(Level_height_pixels).w,d0
	subq.w	#1,d0
	sub.b	($FFFFFAD2).w,d0
	move.l	a0,d7
	move.l	a1,d6
	move.w	(Level_width_blocks).w,d1
	subq.w	#1,d1
	move.w	d1,d2

loc_141AA:
	move.w	d2,d1

loc_141AC:
	move.b	(a0)+,(a1)+
	dbf	d1,loc_141AC
	sub.w	d3,d7
	move.l	d7,a0
	sub.w	d3,d6
	move.l	d6,a1
	dbf	d0,loc_141AA
	move.b	($FFFFFAD2).w,d0
	subq.w	#1,d0
	ext.w	d0
	moveq	#0,d4

loc_141C8:
	move.w	d2,d1

loc_141CA:
	move.b	d4,(a1)+
	dbf	d1,loc_141CA
	sub.w	d3,d6
	move.l	d6,a1
	dbf	d0,loc_141C8
	move.b	($FFFFFAD2).w,d6
	ext.w	d6
	move.w	d6,d7
	mulu.w	(Level_width_tiles).w,d7
	move.l	($FFFFF8D4).w,a0
	move.w	($FFFFF8D2).w,d0
	bra.s	loc_141F6
; ---------------------------------------------------------------------------

loc_141EE:
	add.w	d7,(a0)
	add.w	d6,4(a0)
	addq.w	#8,a0

loc_141F6:
	dbf	d0,loc_141EE
	move.l	($FFFFF8DA).w,a0
	move.w	($FFFFF8D8).w,d0
	bra.s	loc_14210
; ---------------------------------------------------------------------------

loc_14204:
	add.w	d7,8(a0)
	add.w	d6,$C(a0)
	lea	$10(a0),a0

loc_14210:
	dbf	d0,loc_14204
	move.l	($FFFFF8E0).w,a0
	move.w	($FFFFF8DE).w,d0
	bra.s	loc_14228
; ---------------------------------------------------------------------------

loc_1421E:
	add.w	d7,(a0)
	add.w	d6,4(a0)
	lea	$A(a0),a0

loc_14228:
	dbf	d0,loc_1421E
	move.l	($FFFFF8EC).w,a0
	move.w	($FFFFF8EA).w,d0
	bra.s	loc_1423E
; ---------------------------------------------------------------------------

loc_14236:
	add.w	d7,(a0)
	add.w	d6,4(a0)
	addq.w	#8,a0

loc_1423E:
	dbf	d0,loc_14236
	rts
; End of function sub_140F6


; =============== S U B	R O U T	I N E =======================================

;sub_14244
Init_SpriteAttr_HUD:
	move.w	#$FFFF,(Number_Lives_prev).w
	move.w	#$FFFF,(Number_Diamonds_prev).w
	lea	unk_1427C(pc),a0
	lea	(Sprite_Table).l,a1
	moveq	#$13,d0

-
	move.l	(a0)+,(a1)+
	dbf	d0,-
	move.l	#Sprite_Table+$50,(Addr_NextSpriteSlot).w
	move.b	#$A,(Number_Sprites).w
	addq.w	#1,(Time_Seconds_low_digit).w
	move.w	#1,(Time_SubSeconds).w
	rts
; End of function Init_SpriteAttr_HUD

; ---------------------------------------------------------------------------
unk_1427C:
	sprite_attr $1A1, $8D, 1, 1, $8231, $1
	sprite_attr $190, $90, 0, 0, $00BC, $2
	sprite_attr $198, $90, 0, 0, $00BC, $3
	sprite_attr  $88, $90, 0, 0, $00BC, $4
	sprite_attr  $90, $90, 0, 0, $86C4, $5
	sprite_attr  $95, $90, 0, 0, $00BC, $6
	sprite_attr  $9D, $90, 0, 0, $00BC, $7
	sprite_attr $1A0, $A2, 1, 1, $86F2, $8
	sprite_attr $190, $A4, 0, 0, $00BC, $9
	sprite_attr $198, $A4, 0, 0, $00BC, $A

; =============== S U B	R O U T	I N E =======================================


sub_142CC:
	move.w	d0,d1
	rol.w	#2,d1
	andi.w	#3,d1
	andi.w	#$3FFF,d0
	addi.w	#$4000,d0
	swap	d0
	move.w	d1,d0
	move.l	d0,4(a6)
	move.b	(a0)+,d0
	lsl.w	#8,d0
	move.b	(a0)+,d0
	lea	(a0,d0.w),a1
	lea	(Decompression_Buffer).l,a2
	moveq	#0,d1
	moveq	#0,d2
	rts
; End of function sub_142CC


; =============== S U B	R O U T	I N E =======================================

; a0 - source address
; d0 - offset in VRAM (destination)

DecompressToVRAM:
				; Load_InGame+504p ...
	bsr.s	sub_142CC
	moveq	#-1,d0
	move.l	d0,a3	; end address beyond which to flush buffer

loc_14300:
	move.l	a2,a4		; a0 command array
				; a1 input array
				; a2 temp buffer
				; d2 bitpos (1 is lowest bit/last, 7 second highest, 0 highest)
	bsr.w	Decompress_Chunk
	lea	($C00000).l,a6
	move.l	a2,d3
	sub.l	a4,d3
	lsr.w	#1,d3
	subq.w	#1,d3

loc_14314:
	move.w	(a4)+,(a6)	; transfer data from buffer to VRAM
	dbf	d3,loc_14314
	tst.w	d0	; finished decompression?
	beq.s	return_14334
	; have to continue decompression but buffer is full
	lea	(Decompression_Buffer).l,a2
	lea	$800(a2),a4
	move.w	#$1FF,d3

loc_1432C:	; move second $800 bytes from buffer to first $800 bytes of buffer
	move.l	(a4)+,(a2)+
	dbf	d3,loc_1432C
	bra.s	loc_14300	; a0 command array
				; a1 input array
				; a2 temp buffer
				; d2 bitpos (1 is lowest bit/last, 7 second highest, 0 highest)
; ---------------------------------------------------------------------------

return_14334:
	rts
; End of function DecompressToVRAM

; ---------------------------------------------------------------------------
	lea	(Palette_Permutation_Identity).l,a3

; =============== S U B	R O U T	I N E =======================================


DecompressToVRAM_Special:
	move.l	a1,-(sp)
	bsr.s	sub_142CC
	lea	($FFFF0280).l,a4
	moveq	#0,d3

loc_14348:
	moveq	#0,d4

loc_1434A:
	move.b	(a3,d3.w),d5
	lsl.b	#4,d5
	or.b	(a3,d4.w),d5
	move.b	d5,(a4)+
	addq.w	#1,d4
	cmpi.w	#$10,d4
	bne.s	loc_1434A
	addq.w	#1,d3
	cmpi.w	#$10,d3
	bne.s	loc_14348

loc_14366:
	moveq	#-1,d0
	move.l	d0,a3
	move.l	a2,a4
	bsr.w	Decompress_Chunk
	move.l	a2,d3
	sub.l	a4,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	lea	($FFFF0280).l,a3
	moveq	#0,d5
	move.l	(sp)+,a6

loc_14382:
	move.b	(a4)+,d5
	move.b	(a3,d5.w),d6
	lsl.w	#8,d6
	move.b	(a4)+,d5
	move.b	(a3,d5.w),d6
	move.w	d6,(a6)+
	dbf	d3,loc_14382
	move.l	a6,-(sp)
	tst.w	d0
	beq.s	loc_143B2
	lea	(Decompression_Buffer).l,a2
	lea	$800(a2),a4
	move.w	#$1FF,d3

loc_143AA:
	move.l	(a4)+,(a2)+
	dbf	d3,loc_143AA
	bra.s	loc_14366
; ---------------------------------------------------------------------------

loc_143B2:
	move.l	(sp)+,a1
	lea	($C00000).l,a6
	rts
; End of function DecompressToVRAM_Special

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_LoadGameModeData

DecompressToRAM_Special:
	lea	Palette_Permutation_unknown(pc),a3
; END OF FUNCTION CHUNK	FOR j_LoadGameModeData

; =============== S U B	R O U T	I N E =======================================


DecompressToRAM:
	bsr.w	sub_142CC
	lea	($FFFF0280).l,a4
	moveq	#0,d3

loc_143CC:
	moveq	#0,d4

loc_143CE:
	move.b	(a3,d3.w),d5
	lsl.b	#4,d5
	or.b	(a3,d4.w),d5
	move.b	d5,(a4)+
	addq.w	#1,d4
	cmpi.w	#$10,d4
	bne.s	loc_143CE
	addq.w	#1,d3
	cmpi.w	#$10,d3
	bne.s	loc_143CC

loc_143EA:
	moveq	#-1,d0
	move.l	d0,a3
	move.l	a2,a4
	bsr.w	Decompress_Chunk
	lea	($C00000).l,a6
	move.l	a2,d3
	sub.l	a4,d3
	lsr.w	#1,d3
	subq.w	#1,d3
	lea	($FFFF0280).l,a3
	moveq	#0,d5

loc_1440A:
	move.b	(a4)+,d5
	move.b	(a3,d5.w),d6
	lsl.w	#8,d6
	move.b	(a4)+,d5
	move.b	(a3,d5.w),d6
	move.w	d6,(a6)
	dbf	d3,loc_1440A
	tst.w	d0
	beq.s	return_14438
	lea	(Decompression_Buffer).l,a2
	lea	$800(a2),a4
	move.w	#$1FF,d3

loc_14430:
	move.l	(a4)+,(a2)+
	dbf	d3,loc_14430
	bra.s	loc_143EA
; ---------------------------------------------------------------------------

return_14438:
	rts
; End of function DecompressToRAM

; ---------------------------------------------------------------------------
;unk_1443A
Palette_Permutation_unknown:
	binclude	"theme/palette_permutations/unknown.bin"
;unk_1444A
Palette_Permutation_FGCity:
	binclude	"theme/palette_permutations/city_fg.bin"
;unk_1445A
Palette_Permutation_FGForest:
	binclude	"theme/palette_permutations/forest_fg.bin"
;unk_1446A
;Palette_Permutation_unused:
	binclude	"theme/palette_permutations/unused.bin"
;unk_1447A
Palette_Permutation_Identity:
	binclude	"theme/palette_permutations/identity.bin"
;unk_1448A
Palette_Permutation_BGForest:
	binclude	"theme/palette_permutations/forest_bg.bin"
;unk_1449A
Palette_Permutation_FGMountain:
	binclude	"theme/palette_permutations/mountain_fg.bin"
;unk_144AA
Palette_Permutation_BGMountain:
	binclude	"theme/palette_permutations/mountain_bg.bin"
;unk_144BA
Palette_Permutation_BGHill:
	binclude	"theme/palette_permutations/hill_bg.bin"
;unk_144CA
Palette_Permutation_BGHill_alt:
	binclude	"theme/palette_permutations/hill_alt_bg.bin"

; =============== S U B	R O U T	I N E =======================================


sub_144DA:
	move.w	(Foreground_theme).w,d0
	moveq	#0,d1
	lea	unk_14576(pc),a0
	move.b	(a0,d0.w),d1
	move.l	(LnkTo_ThemeMappings_Index).l,a0
	add.w	d0,d0
	add.w	d0,d0
	move.l	(a0,d0.w),a0
	lsl.w	#3,d1
	lea	(a0,d1.w),a0
	moveq	#3,d2
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a2

loc_14506:
	move.w	(a0)+,d0
	bsr.w	sub_14582
	dbf	d2,loc_14506
	moveq	#$1F,d2

loc_14512:
	move.l	(a2)+,(a1)+
	dbf	d2,loc_14512
	moveq	#7,d2
	move.w	#$26E,d3

loc_1451E:
	move.w	d3,d0
	bsr.w	sub_14582
	addq.w	#1,d3
	dbf	d2,loc_1451E
	moveq	#$3F,d0
	lea	(Decompression_Buffer).l,a0
	lea	($FFFF78B2).l,a1

loc_14538:
	moveq	#7,d1
	move.l	(a1),d2
	move.l	(a0)+,d4

loc_1453E:
	lsl.l	#4,d5
	rol.l	#4,d2
	rol.l	#4,d4
	move.w	d2,d3
	andi.w	#$F,d3
	bne.s	loc_14552
	move.w	d4,d3
	andi.w	#$F,d3

loc_14552:
	or.w	d3,d5
	dbf	d1,loc_1453E
	move.l	d5,(a1)+
	dbf	d0,loc_14538
	move.l	#vdpComm($5E60,VRAM,WRITE),4(a6)
	lea	($FFFF78B2).l,a0
	moveq	#$3F,d0

loc_1456E:
	move.l	(a0)+,(a6)
	dbf	d0,loc_1456E
	rts
; End of function sub_144DA

; ---------------------------------------------------------------------------
unk_14576:
	dc.b $10
	dc.b  $A
	dc.b $7D ; }
	dc.b $60 ; `
	dc.b $E5 ; �
	dc.b $67 ; g
	dc.b $73 ; s
	dc.b $5F ; _
	dc.b   1
	dc.b $C5 ; �
	dc.b $9A ; �
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_14582:
	lsl.w	#5,d0
	swap	d0
	clr.w	d0
	move.l	d0,d1
	rol.l	#2,d1
	move.w	d1,d0
	andi.l	#$3FFFFFFF,d0
	move.l	d0,4(a6)
	moveq	#7,d1

loc_1459A:
	move.l	(a6),(a1)+
	dbf	d1,loc_1459A
	rts
; End of function sub_14582

; ---------------------------------------------------------------------------
;Init_SpecialEffect_Index
Init_SpecialEffect_Index:
	dc.l Init_SpecialEffect_Lava	; 1: lava
	dc.l Init_SpecialEffect_Storm	; 2: storm
	dc.l Init_SpecialEffect_Storm	; 3: storm+hail
	dc.l Init_SpecialEffect_Unknown	; 4: ?
	dc.l Init_SpecialEffect_Nothing	; 5: nothing
; =============== S U B	R O U T	I N E =======================================

Init_SpecialEffects:
	move.w	(Level_Special_Effects).w,d0
	beq.s	return_145C8
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	Init_SpecialEffect_Index(pc,d0.w),a0
	jmp	(a0)
; ---------------------------------------------------------------------------

return_145C8:
	rts
; End of function Init_SpecialEffects

; ---------------------------------------------------------------------------
unk_145CA:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $76 ; v
	dc.b   8
	dc.b   0
unk_145D4:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $18
	dc.b $A3 ; �
	dc.b   7
	dc.b  $E
	dc.b   0
unk_145DE:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $20
	dc.b $A3 ; �
	dc.b $79 ; y
	dc.b  $F
	dc.b   0
unk_145E8:
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $A9 ; �
	dc.b  $D
	dc.b   0

	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $3B ; ;
	dc.b  $C
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $20
	dc.b $A3 ; �
	dc.b $89 ; �
	dc.b  $F
	dc.b   0
unk_14602:
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $B1 ; �
	dc.b  $D
	dc.b   0

	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $6E ; n
	dc.b  $D
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $3F ; ?
	dc.b  $C
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b $A3 ; �
	dc.b $99 ; �
	dc.b  $F
	dc.b   0
unk_14624:
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $3F ; ?
	dc.b  $C
	dc.b   0

	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $20
	dc.b $A3 ; �
	dc.b $99 ; �
	dc.b  $F
	dc.b   0
dword_14636:	dc.l $20000
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $A9 ; �
	dc.b  $D
	dc.b   0

	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $3B ; ;
	dc.b  $C
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $20
	dc.b $A3 ; �
	dc.b $89 ; �
	dc.b  $F
	dc.b   0
unk_14650:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $B1 ; �
	dc.b  $D
	dc.b   0
unk_1465A:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $6E ; n
	dc.b  $D
	dc.b   0
unk_14664:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $18
	dc.b $A3 ; �
	dc.b $68 ; h
	dc.b   2
	dc.b   0
unk_1466E:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $10
	dc.b $A3 ; �
	dc.b $6B ; k
	dc.b   1
	dc.b   0
unk_14678:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   8
	dc.b $A3 ; �
	dc.b $6D ; m
	dc.b   0
	dc.b   0
unk_14682:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   8
	dc.b $BB ; �
	dc.b $6D ; m
	dc.b   0
	dc.b   0
unk_1468C:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $10
	dc.b $BB ; �
	dc.b $6B ; k
	dc.b   1
	dc.b   0
unk_14696:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $18
	dc.b $BB ; �
	dc.b $68 ; h
	dc.b   2
	dc.b   0
unk_146A0:	dc.b   0
	dc.b   2
	dc.w unk_145CA-j_LoadGameModeData
	dc.b   0
	dc.b   2
	dc.w unk_145D4-j_LoadGameModeData
	dc.b   0
	dc.b   2
	dc.w unk_145DE-j_LoadGameModeData
	dc.b   0
	dc.b   2
	dc.w unk_145E8-j_LoadGameModeData
	dc.b   0
	dc.b   2
	dc.w unk_14602-j_LoadGameModeData
	dc.w $FFFF
unk_146B6:	dc.b   0
	dc.b   0
	dc.w unk_14602-j_LoadGameModeData
	dc.b   0
	dc.b   0
	dc.w unk_145E8-j_LoadGameModeData
	dc.b   0
	dc.b   0
	dc.w unk_145DE-j_LoadGameModeData
	dc.b   0
	dc.b   0
	dc.w unk_145D4-j_LoadGameModeData
	dc.b   0
	dc.b   0
	dc.w unk_145CA-j_LoadGameModeData
	dc.w $FFFE
unk_146CC:
	dc.w  $A
	dc.w  -4
	dc.w unk_14664-j_LoadGameModeData
	dc.w  $A
	dc.w  -3
	dc.w unk_14664-j_LoadGameModeData
	dc.w  $A
	dc.w  -3
	dc.w unk_1466E-j_LoadGameModeData
	dc.w  $A
	dc.w  -2
	dc.w unk_1466E-j_LoadGameModeData
	dc.w   8
	dc.w  -1
	dc.w unk_14678-j_LoadGameModeData
	dc.w   4
	dc.w   0
	dc.w unk_14678-j_LoadGameModeData
	dc.w   4
	dc.w   0
	dc.w unk_14682-j_LoadGameModeData
	dc.w   8
	dc.w   1
	dc.w unk_14682-j_LoadGameModeData
	dc.w  $A
	dc.w   2
	dc.w unk_1468C-j_LoadGameModeData
	dc.w  $A
	dc.w   2
	dc.w unk_14696-j_LoadGameModeData
	dc.w $14
	dc.w   4
	dc.w unk_14696-j_LoadGameModeData
	dc.w $FFFF
word_14710:
	dc.w	 0
	dc.w	$A
	dc.w   $14
	dc.w   $1E
	dc.w   $28
	dc.w   $32
	dc.w   $3C
	dc.w   $46
	dc.w   $50
	dc.w   $5A
	dc.w   $64
	dc.w   $6E
	dc.w   $78
	dc.w   $82
	dc.w   $8C
	dc.w   $96
; ---------------------------------------------------------------------------

Obj_Lava_Geyser:
	move.w	$16(a5),d0	;x
	move.w	$18(a5),d1	;y
	move.w	$1A(a5),d2	;height ($8000 = small fireball)
	bmi.w	loc_1499C
	move.w	d2,d7
	andi.w	#$F,d7
	add.w	d7,d7
	move.w	word_14710(pc,d7.w),$4E(a5)
	lsr.w	#4,d2
	move.w	d2,$4A(a5)
	move.w	d0,$44(a5)
	move.w	d1,$46(a5)
	addi.w	#$80,$44(a5)
	addi.w	#$80,$46(a5)
	move.w	$46(a5),$54(a5)
	move.w	$4E(a5),d2

loc_14772:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d2,loc_14772
	tst.b	$19(a3)
	bne.s	loc_14788
	moveq	#sfx_Lava_Geyser_starting,d0
	jsr	(j_PlaySound).l

loc_14788:
	lea	unk_146B6(pc),a0
	bra.s	loc_147A0
; ---------------------------------------------------------------------------

loc_1478E:
	tst.b	$19(a3)
	bne.s	loc_1479C
	moveq	#sfx_Lava_Geyser,d0
	jsr	(j_PlaySound).l

loc_1479C:
	lea	unk_146A0(pc),a0

loc_147A0:
	move.w	$44(a5),d0
	move.w	$46(a5),d1
	subi.w	#$80,d0
	subi.w	#$80,d1
	move.w	#$1E,$50(a5)
	move.w	d1,$54(a5)

loc_147BA:
	move.w	(a0)+,d2
	cmpi.w	#$FFFF,d2
	beq.w	loc_1484E
	cmpi.w	#$FFFE,d2
	beq.s	loc_1483A
	move.w	(a0),d4
	move.w	d4,a2
	addi.l	#j_LoadGameModeData,a2
	move.l	a2,a1

loc_147D6:
	move.w	(Camera_X_pos).w,d7
	subi.w	#$20,d7
	cmp.w	d7,d0
	blt.w	loc_1482E
	addi.w	#$180,d7
	cmp.w	d7,d0
	bgt.w	loc_1482E
	move.w	(Camera_Y_pos).w,d7
	subi.w	#$48,d7
	cmp.w	d7,d1
	blt.s	loc_1482E
	addi.w	#$170,d7
	cmp.w	d7,d1
	bgt.s	loc_1482E
	bra.s	loc_1480C
; ---------------------------------------------------------------------------

loc_14804:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_14A58

loc_1480C:
	move.l	a1,a2
	bsr.w	sub_14BD8
	subi.w	#$80,d7
	add.w	(Camera_Y_pos).w,d7
	move.w	d7,$54(a5)
	dbf	d2,loc_14804
	addq.w	#2,a0
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_14A58
	bra.s	loc_147BA
; ---------------------------------------------------------------------------

loc_1482E:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d2,loc_147D6
	addq.w	#2,a0
	bra.s	loc_147BA
; ---------------------------------------------------------------------------

loc_1483A:
	moveq	#sfx_Lava_Geyser,d0
	jsr	(j_PlaySound2).l
	move.w	#$3C,-(sp)
	jsr	(j_Hibernate_Object).w
	bra.w	loc_1478E
; ---------------------------------------------------------------------------

loc_1484E:
	move.w	#0,d3
	move.w	#2,$48(a5)
	clr.b	$4C(a5)
	bra.s	loc_14866
; ---------------------------------------------------------------------------

loc_1485E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_14A58

loc_14866:
	move.w	$48(a5),d2
	bra.s	loc_14874
; ---------------------------------------------------------------------------

loc_1486C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_14A58

loc_14874:
	move.w	$44(a5),d0
	subi.w	#$80,d0
	move.w	(Camera_X_pos).w,d7
	subi.w	#$20,d7
	cmp.w	d7,d0
	blt.w	loc_14940
	addi.w	#$180,d7
	cmp.w	d7,d0
	bgt.w	loc_14940
	move.w	$46(a5),d1
	subi.w	#$80,d1
	subi.w	#$10,d1
	move.w	d3,d7
	addq.w	#1,d7
	lsl.w	#4,d7
	sub.w	d7,d1
	move.w	(Camera_Y_pos).w,d7
	subi.w	#$28,d7
	cmp.w	d7,d1
	blt.s	loc_148E6
	addi.w	#$130,d7
	cmp.w	d7,d1
	bgt.w	loc_14940
	moveq	#0,d7
	tst.b	$4C(a5)
	bne.s	loc_148CE
	move.l	#unk_14624,d7
	bra.s	loc_148D4
; ---------------------------------------------------------------------------

loc_148CE:
	move.l	#dword_14636,d7

loc_148D4:
	move.l	d7,a2
	bsr.w	sub_14BD8
	subi.w	#$80,d7
	add.w	(Camera_Y_pos).w,d7
	move.w	d7,$54(a5)

loc_148E6:
	moveq	#0,d7
	move.l	#unk_1465A,d7
	move.l	d7,a2
	move.l	a2,a1
	moveq	#0,d5
	addi.w	#$10,d1

loc_148F8:
	move.w	(Camera_Y_pos).w,d7
	subi.w	#$10,d7
	cmp.w	d7,d1
	blt.s	loc_14914
	addi.w	#$100,d7
	cmp.w	d7,d1
	bgt.w	loc_14940
	bsr.w	sub_14BD8
	move.l	a1,a2

loc_14914:
	addi.w	#$10,d1
	addq.w	#1,d5
	cmp.w	d3,d5
	ble.s	loc_148F8
	moveq	#0,d7
	move.l	#unk_14650,d7
	move.l	d7,a2
	move.w	(Camera_Y_pos).w,d7
	subi.w	#$10,d7
	cmp.w	d7,d1
	blt.s	loc_14940
	addi.w	#$100,d7
	cmp.w	d7,d1
	bgt.s	loc_14940
	bsr.w	sub_14BD8

loc_14940:
	dbf	d2,loc_1486C
	tst.b	$4D(a5)
	bne.s	loc_1498C
	addi.w	#1,d3
	cmp.w	$4A(a5),d3
	blt.w	loc_1485E
	eori.b	#1,$4C(a5)
	beq.s	loc_14966
	subi.w	#2,$4A(a5)
	bra.s	loc_1496C
; ---------------------------------------------------------------------------

loc_14966:
	addi.w	#2,$4A(a5)

loc_1496C:
	move.w	$4A(a5),d3
	move.w	#6,$48(a5)
	subq.w	#1,$50(a5)
	bne.w	loc_1485E
	st	$4D(a5)
	move.w	#1,$48(a5)
	bra.w	loc_1485E
; ---------------------------------------------------------------------------

loc_1498C:
	subi.w	#1,d3
	bne.w	loc_1485E
	sf	$4D(a5)
	bra.w	loc_14788
; ---------------------------------------------------------------------------

loc_1499C:	; small fireball from USM2
	andi.w	#$7FFF,d2
	move.w	d2,d7
	andi.w	#$F,d7
	add.w	d7,d7
	lea	word_14710(pc),a4
	move.w	(a4,d7.w),$4E(a5)
	lsr.w	#4,d2
	move.w	d2,$4A(a5)
	move.w	d1,$46(a5)
	move.w	d0,$44(a5)
	addi.w	#$80,$44(a5)
	addi.w	#$80,$46(a5)

loc_149CC:
	lea	unk_146CC(pc),a0
	move.w	$46(a5),d1
	move.w	$44(a5),d0
	subi.w	#$80,d0
	subi.w	#$80,d1
	move.w	d1,$54(a5)

loc_149E4:
	move.w	(a0)+,d2
	bmi.s	loc_14A4C
	move.w	(a0)+,$52(a5)
	moveq	#0,d7
	move.w	(a0)+,d7
	move.l	d7,a2
	addi.l	#j_LoadGameModeData,a2
	move.l	a2,a1
	bra.s	loc_14A0A
; ---------------------------------------------------------------------------

loc_149FC:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_14AB0
	move.l	a1,a2
	add.w	$52(a5),d1

loc_14A0A:
	move.w	(Camera_X_pos).w,d7
	subi.w	#$10,d7
	cmp.w	d7,d0
	blt.w	loc_14A46
	addi.w	#$160,d7
	cmp.w	d7,d0
	bgt.w	loc_14A46
	move.w	(Camera_Y_pos).w,d7
	subi.w	#$18,d7
	cmp.w	d7,d1
	blt.s	loc_14A46
	addi.w	#$110,d7
	cmp.w	d7,d1
	bgt.s	loc_14A46
	bsr.w	sub_14BD8
	subi.w	#$80,d7
	add.w	(Camera_Y_pos).w,d7
	move.w	d7,$54(a5)

loc_14A46:
	dbf	d2,loc_149FC
	bra.s	loc_149E4
; ---------------------------------------------------------------------------

loc_14A4C:
	move.w	#$3C,-(sp)
	jsr	(j_Hibernate_Object).w
	bra.w	loc_149CC

; =============== S U B	R O U T	I N E =======================================


sub_14A58:
	movem.l	d5/a0,-(sp)
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	$44(a5),d7
	subi.w	#$80,d7
	addq.w	#3,d7
	move.w	(Kid_hitbox_right).w,d5
	cmp.w	d7,d5
	blt.s	loc_14AAA
	addi.w	#$1A,d7
	move.w	(Kid_hitbox_left).w,d5
	cmp.w	d7,d5
	bgt.s	loc_14AAA
	move.w	$46(a5),d7
	subi.w	#$80,d7
	move.w	(Kid_hitbox_top).w,d5
	cmp.w	d7,d5
	bgt.s	loc_14AAA
	move.w	$54(a5),d7
	addi.w	#$10,d7
	move.w	(Kid_hitbox_bottom).w,d5
	cmp.w	d7,d5
	blt.s	loc_14AAA
	move.w	#$40,$3A(a0)
	move.w	#$28,$38(a0)

loc_14AAA:
	movem.l	(sp)+,d5/a0
	rts
; End of function sub_14A58


; =============== S U B	R O U T	I N E =======================================


sub_14AB0:
	move.w	d1,d7
	movem.l	d5/a0,-(sp)
	move.l	(Addr_GfxObject_Kid).w,a0
	move.w	(Kid_hitbox_bottom).w,d3
	move.w	$44(a5),d6
	subi.w	#$80,d6
	addq.w	#1,d6
	move.w	(Kid_hitbox_right).w,d5
	cmp.w	d6,d5
	blt.s	loc_14B22
	addi.w	#6,d6
	move.w	(Kid_hitbox_left).w,d5
	cmp.w	d6,d5
	bgt.s	loc_14B22
	move.w	$54(a5),d6
	subq.w	#1,d7
	addq.w	#1,d6
	cmpi.l	#unk_1466E,a2
	blt.s	loc_14AFC
	beq.s	loc_14B00
	cmpi.l	#unk_1468C,a2
	blt.s	loc_14B06
	bgt.s	loc_14B04
	addq.w	#3,d6
	bra.s	loc_14B06
; ---------------------------------------------------------------------------

loc_14AFC:
	subq.w	#7,d7
	bra.s	loc_14B06
; ---------------------------------------------------------------------------

loc_14B00:
	subq.w	#3,d6
	bra.s	loc_14B06
; ---------------------------------------------------------------------------

loc_14B04:
	addq.w	#7,d7

loc_14B06:
	move.w	(Kid_hitbox_top).w,d5
	cmp.w	d7,d5
	bgt.s	loc_14B22
	move.w	(Kid_hitbox_bottom).w,d5
	cmp.w	d6,d5
	blt.s	loc_14B22
	move.w	#$50,$3A(a0)
	move.w	#$28,$38(a0)

loc_14B22:
	movem.l	(sp)+,d5/a0
	rts
; End of function sub_14AB0


; =============== S U B	R O U T	I N E =======================================


Animation_Geyser:
	moveq	#5,d0

loc_14B2A:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.s	loc_14B2A
	moveq	#5,d0
	move.w	(Palette_Buffer+$2E).l,d5
	move.w	(Palette_Buffer+$2C).l,(Palette_Buffer+$2E).l
	move.w	(Palette_Buffer+$2A).l,(Palette_Buffer+$2C).l
	move.w	(Palette_Buffer+$28).l,(Palette_Buffer+$2A).l
	move.w	d5,(Palette_Buffer+$28).l
	bra.s	loc_14B2A
; End of function Animation_Geyser

; ---------------------------------------------------------------------------
; lava fountain positions.
; first word: number of entries (3 words per entry)
; each entry: x-pos, y-pos, height
LavaGeyserPositions_USM2:
	dc.w   3
	dc.w	$180, $312, $60
	dc.w	$240, $312, $63
	dc.w	$346, $312, $8000
LavaGeyserPositions_BlackPit:	; also used by USM3 if lava flag is set.
	dc.w  $D
	dc.w	$290, $170, $020
	dc.w	$3D0, $170, $020
	dc.w	$510, $170, $040
	dc.w	$650, $170, $060
	dc.w	$790, $170, $080
	dc.w	$8D0, $170, $0A0
	dc.w	$A10, $170, $0C0
	dc.w	$B50, $170, $0E0
	dc.w	$C90, $170, $100
	dc.w	$DD0, $170, $100
	dc.w	$F10, $170, $100
	dc.w	$1050, $170, $100
	dc.w	$1190, $170, $100
LavaGeyserPositions_Other:	; e.g. Elsewhere 29
	dc.w   3
	dc.w	$090, $330, $260
	dc.w	$010, $1D0, $090
	dc.w	$110, $1D0, $090
LavaGeyserPositions_75:	 
	dc.w   6
	dc.w	$0B1, $12F, $030
	dc.w	$11B, $16D, $8000
    dc.w	$161, $140, $020
	dc.w	$1FA, $1AE, $8000
	dc.w	$23B, $1AE, $8000
    dc.w	$041, $0A0, $030	
LavaGeyserPositions_19:
    dc.w   9 
    dc.w	$0B0, $69F, $30 
	dc.w	$390, $6AF, $80
	dc.w	$163, $0D0, $8000
	dc.w	$103, $0D0, $8000
	dc.w	$0E3, $0D0, $8000
	dc.w	$083, $0D0, $8000
	dc.w	$162, $350, $40
	dc.w	$1DF, $350, $40
	dc.w	$220, $4AF, $180
LavaGeyserPositions_31:
    dc.w   $D
	dc.w	$030, $270, $160
	dc.w	$1E0, $270, $1B0
	dc.w	$350, $270, $1B0
	dc.w	$4D0, $270, $1C5
	dc.w	$8A0, $270, $180
	dc.w	$BD0, $270, $160
	dc.w	$640, $270, $0A0
	dc.w	$B00, $270, $070
	dc.w	$6D2, $270, $8000
	dc.w	$942, $270, $8000
	dc.w	$982, $270, $8000
	dc.w	$9C2, $270, $8000
	dc.w	$A02, $270, $8000
LavaGeyserPositions_06:	
    dc.w   $15
	dc.w   $010, $51E, $050
	dc.w   $130, $51E, $030
	dc.w   $1E0, $51E, $030
	dc.w   $300, $51E, $040
	dc.w   $4C0, $51E, $8000
	dc.w   $090, $401, $030
	dc.w   $200, $431, $075
	dc.w   $2F0, $401, $020
	dc.w   $3C0, $411, $035
	dc.w   $600, $3E1, $050
	dc.w   $480, $431, $030
	dc.w   $5E0, $2B1, $045
	dc.w   $330, $2C1, $050
	dc.w   $4EC, $231, $8000
	dc.w   $453, $231, $8000
	dc.w   $200, $221, $020
	dc.w   $030, $181, $0A0
	dc.w   $010, $061, $8000
	dc.w   $0F0, $0E1, $070
	dc.w   $200, $0E1, $035
	dc.w   $3A0, $071, $020
	
	
	
	
	

; =============== S U B	R O U T	I N E =======================================


sub_14BD8:
	move.l	(Addr_NextSpriteSlot).w,a4
	move.w	d1,d7
	sub.w	(Camera_Y_pos).w,d7
	addi.w	#$80,d7
	move.w	(a2)+,d4

loc_14BE8:
	move.w	$44(a5),d6
	sub.w	(Camera_X_pos).w,d6
	add.w	(a2),d6
	move.w	d6,6(a4)
	sub.w	2(a2),d7
	_move.w	d7,0(a4)
	move.w	4(a2),4(a4)
	move.w	6(a2),d6
	addq.b	#1,(Number_Sprites).w
	add.b	(Number_Sprites).w,d6
	move.w	d6,2(a4)
	lea	8(a4),a4
	lea	8(a2),a2
	dbf	d4,loc_14BE8
	move.l	a4,(Addr_NextSpriteSlot).w
	rts
; End of function sub_14BD8

; ---------------------------------------------------------------------------
; address table for lava fountain positions
LavaGeyserPositions_Index:
	dc.l LavaGeyserPositions_USM2	; Under Skull Mountain 2
	dc.l LavaGeyserPositions_BlackPit	; Under Skull Mountain 3
	dc.l LavaGeyserPositions_BlackPit	; The Black Pit
	dc.l LavaGeyserPositions_75
	dc.l LavaGeyserPositions_19
	dc.l LavaGeyserPositions_31
	dc.l LavaGeyserPositions_06
	dc.l LavaGeyserPositions_Other	; everything else
; ---------------------------------------------------------------------------

Init_SpecialEffect_Lava:
	move.w	(Current_LevelID).w,d0
	move.l	(LnkTo_MapOrder_Index).l,a0
	move.b	(a0,d0.w),d0
	clr.w	d1
	cmpi.b	#M_Under_Skull_Mountain_2,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#M_Under_Skull_Mountain_3,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#M_The_Black_Pit,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#$75,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#$19,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#$31,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
	cmpi.w	#$06,d0
	beq.s	loc_14C5E
	addq.w	#1,d1
		
loc_14C5E:
	add.w	d1,d1
	add.w	d1,d1
	move.l	LavaGeyserPositions_Index(pc,d1.w),a4
	move.w	(a4)+,d0
	subq.w	#1,d0

loc_14C6A:
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Obj_Lava_Geyser,4(a0)
	move.l	(a4)+,$16(a0)
	move.w	(a4)+,$1A(a0)
	dbf	d0,loc_14C6A
	move.l	(LnkTo_ArtComp_983D2_Lava).l,a0
	move.w	#$5F60,d0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	move.l	(LnkTo_Pal_7B8AC).l,a0
	lea	(Palette_Buffer+$20).l,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Animation_Geyser,4(a0)
	rts
; ---------------------------------------------------------------------------

Init_SpecialEffect_Storm:
	cmpi.w	#Ice,(Background_theme).w
	beq.s	loc_14CCE
	move.l	(LnkTo_ArtComp_99090_Rain).l,a0
	move.w	#$7000,d0
	bra.s	loc_14CD8
; ---------------------------------------------------------------------------

loc_14CCE:
	move.l	(LnkTo_ArtComp_991ED_Hail).l,a0
	move.w	#$7000,d0

loc_14CD8:
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	cmpi.w	#Ice,(Background_theme).w
	beq.s	loc_14CEC
	move.l	(LnkTo_Pal_7B8BC).l,a0
	bra.s	loc_14CF2
; ---------------------------------------------------------------------------

loc_14CEC:
	move.l	(LnkTo_Pal_7B8CC).l,a0

loc_14CF2:
	lea	(Palette_Buffer+$20).l,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	cmpi.w	#Ice,(Background_theme).w
	beq.s	loc_14D1E
	move.w	#$380,d7
	move.w	d7,d6
	swap	d7
	move.w	d6,d7
	move.l	(LnkTo_unk_9B65C).l,a0
	addq.w	#4,a0
	move.l	a0,a3
	bra.s	loc_14D32
; ---------------------------------------------------------------------------

loc_14D1E:
	move.w	#$380,d7
	move.w	d7,d6
	swap	d7
	move.w	d6,d7
	move.l	(LnkTo_unk_9B6E0).l,a0
	addq.w	#4,a0
	move.l	a0,a3

loc_14D32:
	move.l	#vdpComm($6000,VRAM,WRITE),4(a6)
	moveq	#3,d2

loc_14D3C:
	moveq	#7,d1

loc_14D3E:
	moveq	#7,d0

loc_14D40:
	move.l	(a0),d6
	add.l	d7,d6
	move.l	d6,(a6)
	move.l	4(a0),d6
	add.l	d7,d6
	move.l	d6,(a6)
	move.l	8(a0),d6
	add.l	d7,d6
	move.l	d6,(a6)
	move.l	$C(a0),d6
	add.l	d7,d6
	move.l	d6,(a6)
	dbf	d0,loc_14D40
	lea	$10(a0),a0
	dbf	d1,loc_14D3E
	move.l	a3,a0
	dbf	d2,loc_14D3C
	cmpi.w	#2,(Level_Special_Effects).w	; rain?
	beq.s	loc_14D82
	move.l	(LnkTo_Pal_7B85C).l,($FFFFFADE).w
	bra.s	loc_14D8A
; ---------------------------------------------------------------------------

loc_14D82:
	move.l	(LnkTo_Pal_7B85C).l,($FFFFFADE).w

loc_14D8A:
	move.l	(LnkTo_ArtComp_9A7D2).l,a0
	move.w	#$76A0,d0
	bsr.w	DecompressToVRAM	; a0 - source address
				; d0 - offset in VRAM (destination)
	lea	($FFFFFAE2).w,a0
	lea	($FFFFFB00).w,a1
	moveq	#4,d0
	move.w	#$100,d2
	move.l	#$FFFFFFFF,d1

loc_14DAC:
	move.l	d1,(a0)+
	move.w	d2,(a0)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	move.l	d1,(a1)+
	dbf	d0,loc_14DAC
	move.b	#1,($FFFFFB3C).w
	move.b	#5,($FFFFFB3D).w
	move.b	#4,($FFFFFAD6).w
	move.w	#$100,($FFFFFADA).w
	move.w	#1,($FFFFFADC).w
	move.w	#1,($FFFFFB52).w
	sf	($FFFFFB54).w
	rts
; ---------------------------------------------------------------------------

;loc_14DE4:
Init_SpecialEffect_Unknown:
	move.l	(LnkTo_unk_9AA50).l,a0
	move.l	#vdpComm($7000,VRAM,WRITE),4(a6)
	move.w	(a0)+,d0
	subq.w	#1,d0

loc_14DF6:
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	dbf	d0,loc_14DF6
	move.b	#1,($FFFFFAD6).w
	clr.w	($FFFFFB3E).w
	move.l	#$8380,d7
	move.w	d7,d6
	swap	d7
	move.w	d6,d7
	move.l	d7,d6
	addi.l	#1,d6
	addi.l	#$20003,d7
	move.l	d6,d4
	move.l	d7,d3
	move.l	#$40004,d5
	move.l	#vdpComm($6000,VRAM,WRITE),4(a6)
	; fill a piece of the foreground plane with stuff.
	moveq	#7,d2

loc_14E42:
	moveq	#3,d1

loc_14E44:
	moveq	#$F,d0

loc_14E46:
	move.l	d6,(a6)
	move.l	d7,(a6)
	dbf	d0,loc_14E46
	add.l	d5,d6
	add.l	d5,d7
	dbf	d1,loc_14E44
	move.l	d3,d7
	move.l	d4,d6
	dbf	d2,loc_14E42
	move.w	#$8218,4(a6)	; foreground plane to address $6000
	move.w	#$8400,4(a6)	; background plane to address 0
	rts
; ---------------------------------------------------------------------------

Init_SpecialEffect_Nothing:
	rts
; ---------------------------------------------------------------------------
Pal_TitleCard_sky:	binclude    "theme/titlecard/palette/sky.bin"
Pal_TitleCard_ice:	binclude    "theme/titlecard/palette/ice.bin"
Pal_TitleCard_hill:	binclude    "theme/titlecard/palette/hill.bin"
Pal_TitleCard_island:	binclude    "theme/titlecard/palette/island.bin"
Pal_TitleCard_desert:	binclude    "theme/titlecard/palette/desert.bin"
Pal_TitleCard_swamp:	binclude    "theme/titlecard/palette/swamp.bin"
Pal_TitleCard_mountain:	binclude    "theme/titlecard/palette/mountain.bin"
Pal_TitleCard_cave:	binclude    "theme/titlecard/palette/cave.bin"
Pal_TitleCard_forest:	binclude    "theme/titlecard/palette/forest.bin"
Pal_TitleCard_city:	binclude    "theme/titlecard/palette/city.bin"
;14FAE
TitleCardPalettes_Index:
	dc.l 0
	dc.l Pal_TitleCard_sky
	dc.l Pal_TitleCard_ice
	dc.l Pal_TitleCard_hill
	dc.l Pal_TitleCard_island
	dc.l Pal_TitleCard_desert
	dc.l Pal_TitleCard_swamp
	dc.l Pal_TitleCard_mountain
	dc.l Pal_TitleCard_cave
	dc.l Pal_TitleCard_forest
	dc.l Pal_TitleCard_city
MapEni_TitleCard_sky:		binclude    "theme/titlecard/mapeni/sky.bin"
	align	2
MapEni_TitleCard_ice:		binclude    "theme/titlecard/mapeni/ice.bin"
	align	2
MapEni_TitleCard_hill:		binclude    "theme/titlecard/mapeni/hill.bin"
	align	2
MapEni_TitleCard_island:	binclude    "theme/titlecard/mapeni/island.bin"
	align	2
MapEni_TitleCard_desert:	binclude    "theme/titlecard/mapeni/desert.bin"
	align	2
MapEni_TitleCard_swamp:		binclude    "theme/titlecard/mapeni/swamp.bin"
	align	2
MapEni_TitleCard_mountain:	binclude    "theme/titlecard/mapeni/mountain.bin"
	align	2
MapEni_TitleCard_cave:		binclude    "theme/titlecard/mapeni/cave.bin"
	align	2
MapEni_TitleCard_forest:	binclude    "theme/titlecard/mapeni/forest.bin"
	align	2
MapEni_TitleCard_city:		binclude    "theme/titlecard/mapeni/city.bin"
	align	2
TitleCardMaps_Index:
	dc.l 0
	dc.l MapEni_TitleCard_sky
	dc.l MapEni_TitleCard_ice
	dc.l MapEni_TitleCard_hill
	dc.l MapEni_TitleCard_island
	dc.l MapEni_TitleCard_desert
	dc.l MapEni_TitleCard_swamp
	dc.l MapEni_TitleCard_mountain
	dc.l MapEni_TitleCard_cave
	dc.l MapEni_TitleCard_forest
	dc.l MapEni_TitleCard_city
ArtComp_TitleCard_sky:		binclude    "theme/titlecard/artcomp/sky.bin"
ArtComp_TitleCard_ice:		binclude    "theme/titlecard/artcomp/ice.bin"
ArtComp_TitleCard_hill:		binclude    "theme/titlecard/artcomp/hill.bin"
ArtComp_TitleCard_island:	binclude    "theme/titlecard/artcomp/island.bin"
ArtComp_TitleCard_desert:	binclude    "theme/titlecard/artcomp/desert.bin"
ArtComp_TitleCard_swamp:	binclude    "theme/titlecard/artcomp/swamp.bin"
ArtComp_TitleCard_mountain:	binclude    "theme/titlecard/artcomp/mountain.bin"
ArtComp_TitleCard_cave:		binclude    "theme/titlecard/artcomp/cave.bin"
ArtComp_TitleCard_forest:	binclude    "theme/titlecard/artcomp/forest.bin"
ArtComp_TitleCard_city:		binclude    "theme/titlecard/artcomp/city.bin"
TitleCardArt_Index:
	dc.l	0
	dc.l ArtComp_TitleCard_sky
	dc.l ArtComp_TitleCard_ice
	dc.l ArtComp_TitleCard_hill
	dc.l ArtComp_TitleCard_island
	dc.l ArtComp_TitleCard_desert
	dc.l ArtComp_TitleCard_swamp
	dc.l ArtComp_TitleCard_mountain
	dc.l ArtComp_TitleCard_cave
	dc.l ArtComp_TitleCard_forest
	dc.l ArtComp_TitleCard_city
; ---------------------------------------------------------------------------

Load_TitleCard:
	jsr	(j_sub_914).w
	move.l	#vdpComm($1400,VRAM,WRITE),4(a6)
	move.w	#$DF,d1
	move.w	#0,d0
	neg.w	d0

loc_19ABE:
	move.w	d0,(a6)
	move.w	d0,(a6)
	dbf	d1,loc_19ABE
	move.w	#0,d0
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d0,(a6)
	move.w	d0,(a6)
	jsr	(j_sub_924).w
	move.w	(Current_LevelID).w,d0
	move.l	(LnkTo_MapOrder_Index).l,a0
	move.b	(a0,d0.w),d0
	ext.w	d0
	move.l	#MapHeader_Index,a0
	add.w	d0,d0
	move.w	(a0,d0.w),d0
	move.l	#MapHeader_BaseAddress,a0
	add.w	d0,a0
	move.b	2(a0),d0
	andi.w	#$F,d0
	move.w	d0,d6
	add.w	d0,d0
	add.w	d0,d0
	move.w	d0,d7
	lea	TitleCardArt_Index(pc),a0
	move.l	(a0,d0.w),a0
	move.w	#$5F60,d0
	movem.l	d0-d7,-(sp)
	jsr	(j_DecompressToVRAM).l
	movem.l	(sp)+,d0-d7
	move.w	#$2FB,d0
	lea	TitleCardMaps_Index(pc),a0
	move.l	(a0,d7.w),a0
	lea	(Decompression_Buffer).l,a1
	movem.l	d0-d7,-(sp)
	jsr	(j_EniDec).l
	movem.l	(sp)+,d0-d7
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	move.w	#$7FF,d0
	move.w	#$94,d1

loc_19B58:
	move.w	d1,(a6)
	dbf	d0,loc_19B58
	move.l	#vdpComm($1280,VRAM,WRITE),4(a6)
	moveq	#$F,d0
	moveq	#0,d1

loc_19B6A:
	move.w	d1,(a6)
	dbf	d0,loc_19B6A
	lea	TitleCardPalettes_Index(pc),a0
	move.l	(a0,d7.w),a0
	lea	(Palette_Buffer).l,a1
	moveq	#$F,d0

loc_19B80:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_19B80
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	lea	(Decompression_Buffer).l,a0
	lea	(TitleCardSize_Index).l,a4
	add.w	d6,d6
	move.b	(a4,d6.w),d0
	ext.w	d0
	move.b	1(a4,d6.w),d1
	ext.w	d1
	moveq	#$1C,d6
	sub.w	d1,d6
	lsr.w	#1,d6
	moveq	#$28,d7
	sub.w	d0,d7
	lsr.w	#1,d7
	move.w	d1,d3
	subq.w	#1,d3
	move.w	d6,d2
	subq.w	#1,d2
	bmi.s	loc_19BCE
	move.w	#$2FB,d5

loc_19BC2:
	moveq	#$3F,d4

loc_19BC4:
	move.w	d5,(a6)
	dbf	d4,loc_19BC4
	dbf	d2,loc_19BC2

loc_19BCE:
	move.w	d7,d4
	subq.w	#1,d4
	bmi.s	loc_19BDA

loc_19BD4:
	move.w	d5,(a6)
	dbf	d4,loc_19BD4

loc_19BDA:
	move.w	d0,d5
	subq.w	#1,d5

loc_19BDE:
	move.w	(a0)+,(a6)
	dbf	d5,loc_19BDE
	move.w	#$40,d5
	sub.w	d7,d5
	sub.w	d0,d5
	subq.w	#1,d5

loc_19BEE:
	move.w	#$2FB,(a6)
	dbf	d5,loc_19BEE
	dbf	d3,loc_19BCE
	moveq	#$1C,d5
	sub.w	d1,d5
	sub.w	d6,d5
	subq.w	#1,d5

loc_19C02:
	moveq	#$3F,d4

loc_19C04:
	move.w	#$2FB,(a6)
	dbf	d4,loc_19C04
	dbf	d5,loc_19C02
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AB26,4(a0)
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AE2E,4(a0)
	rts
; ---------------------------------------------------------------------------
TitleCardSize_Index:
	dc.b   0,  0
	dc.b  $E,$12
	dc.b $11,$12
	dc.b $12,$11
	dc.b $10,$12
	dc.b $13, $F
	dc.b $10, $D
	dc.b $11,$11
	dc.b $12, $C
	dc.b  $F,$17
	dc.b $13,$11
Pal_19C48:	
	binclude	"scenes/palette/Title_card_letters.bin"
ArtComp_19C68_TtlCardLetters:
	binclude	"scenes/artcomp/Title_card_letters.bin"
	align	2
; 1A45C
;AddrTbl_LevelNames is defined in here at 1A842:
	include	"level/levelnames.asm"
; ---------------------------------------------------------------------------

loc_1AB26:
	lea	ArtComp_19C68_TtlCardLetters(pc),a0
	move.w	#$8120,d0
	jsr	(j_DecompressToVRAM).l
	lea	Pal_19C48(pc),a0
	lea	(Palette_Buffer+$20).l,a1
	moveq	#$F,d0

loc_1AB40:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1AB40
	move.w	(Current_LevelID).w,d7
	cmpi.w	#FirstElsewhere_LevelID,d7
	blt.s	loc_1AB52
	moveq	#FirstElsewhere_LevelID,d7

loc_1AB52:
	mulu.w	#$A,d7
	lea	AddrTbl_LevelNames(pc),a4
	move.l	(a4,d7.w),a2
	move.l	4(a4,d7.w),a3
	move.w	8(a4,d7.w),d0
	move.w	(a3)+,d2
	move.w	(a3)+,d3

loc_1AB6A:
	clr.w	d1
	move.b	(a2),d1
	beq.s	loc_1ABE2
	cmpi.b	#$FF,d1
	beq.w	loc_1ABF4
	cmpi.b	#$84,d1
	beq.s	loc_1ABEA
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AC70,4(a0)
	move.b	d1,$44(a0)
	move.w	d2,$46(a0)
	move.w	d3,$48(a0)
	addq.w	#1,a2
	subi.b	#$61,d1
	cmpi.b	#8,d1
	beq.s	loc_1ABDC
	cmpi.b	#$1B,d1
	beq.s	loc_1ABCA
	cmpi.b	#$1C,d1
	beq.s	loc_1ABD0
	cmpi.b	#$1D,d1
	beq.s	loc_1ABD6
	cmpi.b	#$1E,d1
	beq.s	loc_1ABD6
	cmpi.b	#$22,d1
	beq.s	loc_1ABDC
	addi.w	#$10,d2
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABCA:
	addi.w	#$28,d2
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABD0:
	addi.w	#$20,d2
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABD6:
	addi.w	#$18,d2
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABDC:
	addi.w	#8,d2
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABE2:
	addq.w	#1,a2
	move.w	(a3)+,d2
	move.w	(a3)+,d3
	bra.s	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABEA:
	addq.w	#1,a2
	addi.w	#$10,d2
	bra.w	loc_1AB6A
; ---------------------------------------------------------------------------

loc_1ABF4:
	tst.w	d0
	beq.s	loc_1AC10
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AD48,4(a0)
	move.w	d0,$44(a0)
	move.l	a3,$46(a0)

loc_1AC10:
	tst.b	(Two_player_flag).w
	beq.s	loc_1AC26
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AD80,4(a0)

loc_1AC26:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
off_1AC2A:	dc.w LnkTo_unk_C86E8-Data_Index
	dc.w LnkTo_unk_C86F0-Data_Index
	dc.w LnkTo_unk_C86F8-Data_Index
	dc.w LnkTo_unk_C8700-Data_Index
	dc.w LnkTo_unk_C8708-Data_Index
	dc.w LnkTo_unk_C8710-Data_Index
	dc.w LnkTo_unk_C8718-Data_Index
	dc.w LnkTo_unk_C8720-Data_Index
	dc.w LnkTo_unk_C8728-Data_Index
	dc.w LnkTo_unk_C8730-Data_Index
	dc.w LnkTo_unk_C8738-Data_Index
	dc.w LnkTo_unk_C8740-Data_Index
	dc.w LnkTo_unk_C8748-Data_Index
	dc.w LnkTo_unk_C8750-Data_Index
	dc.w LnkTo_unk_C8758-Data_Index
	dc.w LnkTo_unk_C8760-Data_Index
	dc.w LnkTo_unk_C8768-Data_Index
	dc.w LnkTo_unk_C8770-Data_Index
	dc.w LnkTo_unk_C8778-Data_Index
	dc.w LnkTo_unk_C8780-Data_Index
	dc.w LnkTo_unk_C8788-Data_Index
	dc.w LnkTo_unk_C8790-Data_Index
	dc.w LnkTo_unk_C8798-Data_Index
	dc.w LnkTo_unk_C87A0-Data_Index
	dc.w LnkTo_unk_C87A8-Data_Index
	dc.w LnkTo_unk_C87B0-Data_Index
	dc.w LnkTo_unk_C87B8-Data_Index
	dc.w LnkTo_unk_C87C0-Data_Index
	dc.w LnkTo_unk_C87C8-Data_Index
	dc.w LnkTo_unk_C87D0-Data_Index
	dc.w LnkTo_unk_C87D8-Data_Index
	dc.w LnkTo_unk_C87E0-Data_Index
	dc.w LnkTo_unk_C87E8-Data_Index
	dc.w LnkTo_unk_C87F0-Data_Index
	dc.w LnkTo_unk_C87F8-Data_Index
; ---------------------------------------------------------------------------

loc_1AC70:
	move.l	#$3000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#1,palette_line(a3)
	clr.w	d7
	move.b	$44(a5),d7
	move.w	d7,d6
	subi.b	#$61,d7
	add.w	d7,d7
	move.w	#$409,vram_tile(a3)
	move.w	off_1AC2A(pc,d7.w),addroffset_sprite(a3)
	move.w	$46(a5),d0
	move.w	$48(a5),d1
	cmpi.w	#$83,d6
	bne.s	loc_1ACB0
	subi.w	#8,d1

loc_1ACB0:
	jsr	(j_Get_RandomNumber_byte).w
	andi.b	#3,d7
	beq.s	loc_1ACE6
	cmpi.b	#2,d7
	blt.s	loc_1ACC8
	beq.s	loc_1ACE0
	move.w	#$100,d6
	bra.s	loc_1ACCC
; ---------------------------------------------------------------------------

loc_1ACC8:
	move.w	#$FFE0,d6

loc_1ACCC:
	jsr	(j_Get_RandomNumber_word).w
	andi.w	#$FF,d7
	addi.w	#$3E,d7
	andi.w	#$FFFC,d7
	move.w	d7,d5
	bra.s	loc_1ACFE
; ---------------------------------------------------------------------------

loc_1ACE0:
	move.w	#$160,d5
	bra.s	loc_1ACEA
; ---------------------------------------------------------------------------

loc_1ACE6:
	move.w	#$FFE0,d5

loc_1ACEA:
	jsr	(j_Get_RandomNumber_byte).w
	subi.w	#$20,d7
	bgt.s	loc_1ACF8
	addi.w	#$28,d7

loc_1ACF8:
	andi.w	#$FFFC,d7
	move.w	d7,d6

loc_1ACFE:
	move.w	d5,x_pos(a3)
	move.w	d6,y_pos(a3)
	move.w	d0,d7
	sub.w	d5,d7
	ext.l	d7
	muls.w	#$100,d7
	asr.l	#6,d7
	lsl.l	#8,d7
	move.l	d7,d2
	move.w	d1,d7
	sub.w	d6,d7
	ext.l	d7
	muls.w	#$100,d7
	asr.l	#6,d7
	lsl.l	#8,d7
	move.l	d7,d3
	move.w	#$3F,a0

loc_1AD2A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	x_pos(a3),d7
	cmp.w	d7,d0
	beq.s	loc_1AD3A
	add.l	d2,x_pos(a3)

loc_1AD3A:
	move.w	y_pos(a3),d7
	cmp.w	d7,d1
	beq.s	loc_1AD2A
	add.l	d3,y_pos(a3)
	bra.s	loc_1AD2A
; ---------------------------------------------------------------------------

loc_1AD48:
	move.w	$44(a5),d3
	move.l	$46(a5),a0
	move.w	(a0)+,d1
	move.w	(a0)+,d2
	subq.w	#1,d3

loc_1AD56:
	move.w	#$A000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1AC70,4(a0)
	move.b	#$7B,$44(a0)
	move.w	d1,$46(a0)
	move.w	d2,$48(a0)
	addi.w	#$10,d1
	dbf	d3,loc_1AD56
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1AD80:
	move.w	#$40,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	#$3000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#1,palette_line(a3)
	clr.w	d7
	move.b	#$80,d7
	subi.b	#$61,d7
	add.w	d7,d7
	move.w	#$409,vram_tile(a3)
	lea	off_1AC2A(pc),a4
	move.w	(a4,d7.w),addroffset_sprite(a3)
	move.w	#$60,d0
	move.w	#$FFD0,x_pos(a3)
	move.w	#$C0,y_pos(a3)
	move.l	#$3000004,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#1,$11(a1)
	move.b	#$81,d7
	tst.b	($FFFFFC39).w
	beq.s	loc_1ADEA
	addi.b	#1,d7

loc_1ADEA:
	subi.b	#$61,d7
	add.w	d7,d7
	move.w	#$409,$24(a1)
	lea	off_1AC2A(pc),a4
	move.w	(a4,d7.w),$22(a1)
	move.w	#$D0,d1
	move.w	#$160,$1A(a1)
	move.w	#$C8,$1E(a1)

loc_1AE10:
	jsr	(j_Hibernate_Object_1Frame).w
	cmp.w	x_pos(a3),d0
	beq.s	loc_1AE20
	addi.w	#4,x_pos(a3)

loc_1AE20:
	cmp.w	$1A(a1),d1
	beq.s	loc_1AE10
	subi.w	#4,$1A(a1)
	bra.s	loc_1AE10
; ---------------------------------------------------------------------------

loc_1AE2E:

	jsr	(j_Hibernate_Object_1Frame).w
	bclr	#Button_Start,(Ctrl_Pressed).w ; keyboard key (Enter) start
	beq.s	loc_1AE2E
	move.w	#$C,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

Load_IntroSequence1:
	jsr	(j_StopMusic).l
	move.w	#bgm_Ice,d0
	jsr	(j_PlaySound).l
	bsr.w	sub_1B850
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1B8F4,4(a0)
	rts
; ---------------------------------------------------------------------------

Load_IntroSequence3:
	bsr.w	sub_1B850
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1B93E,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1C572,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C58C,4(a0)
	lea	(unk_1AF78).l,a2
	move.b	($FFFFFC83).w,d7
	addq.b	#1,($FFFFFC83).w
	lsl.w	#3,d7
	andi.w	#$18,d7
	add.w	d7,a2
	moveq	#7,d3

loc_1AEBA:
	moveq	#0,d0
	move.b	(a2)+,d0
	bmi.w	return_1AF22
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	lea	unk_1AF24(pc,d0.w),a0
	btst	#0,5(a0)
	bne.s	loc_1AEE2
	move.l	#$1FF0000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	bra.s	loc_1AEEC
; ---------------------------------------------------------------------------

loc_1AEE2:
	move.l	#$2010000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w

loc_1AEEC:
	move.w	(a0)+,$1A(a1)
	move.w	(a0)+,$1E(a1)
	st	$13(a1)
	move.b	#1,$11(a1)
	move.w	#$1D6,$24(a1)
	move.w	(a0)+,d0
	bclr	#0,d0
	beq.s	loc_1AF12
	move.b	#1,$10(a1)

loc_1AF12:
	bclr	#1,d0
	sne	$16(a1)
	move.w	d0,$22(a1)
	dbf	d3,loc_1AEBA

return_1AF22:
	rts
; ---------------------------------------------------------------------------
unk_1AF24:	dc.b   0
	dc.b $F8 ; �
	dc.b   0
	dc.b $D0 ; �
	dc.b $12
	dc.b   9
	dc.b   0
	dc.b $E3 ; �
	dc.b   0
	dc.b $CC ; �
	dc.b $12
	dc.b $29 ; )
	dc.b   0
	dc.b $40 ; @
	dc.b   0
	dc.b $CC ; �
	dc.b $12
	dc.b $31 ; 1
	dc.b   0
	dc.b $60 ; `
	dc.b   0
	dc.b $D0 ; �
	dc.b $12
	dc.b  $D
	dc.b   0
	dc.b $D0 ; �
	dc.b   0
	dc.b $C8 ; �
	dc.b $12
	dc.b $11
	dc.b   0
	dc.b $C4 ; �
	dc.b   0
	dc.b $CC ; �
	dc.b $12
	dc.b $15
	dc.b   0
	dc.b $70 ; p
	dc.b   0
	dc.b $CC ; �
	dc.b $12
	dc.b $19
	dc.b   0
	dc.b $98 ; �
	dc.b   0
	dc.b $C4 ; �
	dc.b $12
	dc.b $1C
	dc.b   0
	dc.b $E4 ; �
	dc.b   0
	dc.b $C8 ; �
	dc.b $12
	dc.b $21 ; !
	dc.b   0
	dc.b $50 ; P
	dc.b   0
	dc.b $C8 ; �
	dc.b $12
	dc.b $2D ; -
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b $CC ; �
	dc.b $12
	dc.b $35 ; 5
	dc.b   0
	dc.b $3C ; <
	dc.b   0
	dc.b $C8 ; �
	dc.b $12
	dc.b $39 ; 9
	dc.b   1
	dc.b $14
	dc.b   0
	dc.b $CA ; �
	dc.b $12
	dc.b $3D ; =
	dc.b   0
	dc.b $2C ; ,
	dc.b   0
	dc.b $C8 ; �
	dc.b $12
	dc.b $25 ; %
unk_1AF78:	dc.b   0
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   6
	dc.b   7
	dc.b   9
	dc.b  $A
	dc.b   0
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b  $C
	dc.b $FF
	dc.b $FF
	dc.b   1
	dc.b   7
	dc.b   8
	dc.b  $A
	dc.b  $B
	dc.b  $D
	dc.b $FF
	dc.b $FF
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   5
	dc.b   7
	dc.b   8
	dc.b   9
	dc.b $FF
; ---------------------------------------------------------------------------

Load_IntroSequence2:
	move.w	#$2280,d0
	move.l	(Addr_HoloBG).w,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$3540,d0
	move.l	(Addr_HoloBG).w,a0
	add.w	(off_718E).w,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$2114,d0
	move.l	(Addr_HoloBG).w,a0
	add.w	(off_718A).w,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	bsr.w	sub_1B7B6
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1CD88
	move.w	#$FA60,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$1780,d0
	lea	(byte_243D5).l,a0
	lea	(Level_Layout).w,a1
	lea	(unk_1C336).l,a3
	bsr.w	DecompressToVRAM_Special
	lea	(Level_Layout).w,a1
	lea	($FFFFB152).w,a2
	move.w	#$2BF,d0

loc_1B012:
	move.l	(a1)+,(a2)+
	dbf	d0,loc_1B012
	move.w	#$BC,d0
	lea	(unk_2E7C6).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	moveq	#0,d4
	moveq	#0,d5
	moveq	#$28,d6
	moveq	#$1C,d7
	bsr.w	sub_1C5D0
	bsr.w	sub_1C4FE
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1B9D0,4(a0)
	rts
; ---------------------------------------------------------------------------

Load_IntroSequence4:
	move.w	#$1780,d0
	move.l	(Addr_HoloBG).w,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$20BC,d0
	move.l	(Addr_HoloBG).w,a0
	add.w	(off_718A).w,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1CD88
	move.w	#$FA60,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	bsr.w	sub_1C4FE
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1B988,4(a0)
	rts
; ---------------------------------------------------------------------------

Load_IntroSequence5:
	bsr.w	sub_1C278
	move.w	#$1780,d0
	move.l	#byte_1E6E3,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$4D80,d0
	move.l	#byte_20D36,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$6800,d0
	move.l	#byte_2A992,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$BD60,d0
	move.l	#byte_213D9,a0
	tst.b	($FFFFFC82).w
	beq.s	loc_1B100
	move.l	#byte_219C1,a0
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1B100
	move.l	#byte_216B7,a0

loc_1B100:
	jsr	(j_DecompressToVRAM).l
	move.w	#$BC,d0
	move.l	#MapEni_2E154,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1CD88
	move.w	#$FA60,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	lea	unk_1C3F0(pc),a3
	jsr	(j_DecompressToRAM).l
	bsr.w	sub_1C512
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BA28,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BCD0,4(a0)
	rts
; ---------------------------------------------------------------------------

Load_IntroSequence6:
	move.l	#vdpComm($1780,VRAM,WRITE),4(a6)
	moveq	#7,d0
	move.l	#$11111111,d1

loc_1B170:
	move.l	d1,(a6)
	dbf	d0,loc_1B170
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	move.w	#$7FF,d0

loc_1B182:
	move.w	#$20BC,(a6)
	dbf	d0,loc_1B182
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	moveq	#$D,d0

loc_1B194:
	moveq	#$1F,d1

loc_1B196:
	move.w	#$BD,(a6)
	move.w	#$BE,(a6)
	dbf	d1,loc_1B196
	moveq	#$1F,d1

loc_1B1A4:
	move.w	#$BF,(a6)
	move.w	#$C0,(a6)
	dbf	d1,loc_1B1A4
	dbf	d0,loc_1B194
	moveq	#0,d0
	bsr.w	sub_1B41C
	bsr.w	sub_1B2A4
	moveq	#$15,d4
	moveq	#1,d5
	moveq	#$12,d6
	moveq	#$14,d7
	bsr.w	sub_1C5D0
	move.l	#$FFB80000,(Level_Layout).w
	move.l	#$FFD00000,($FFFFA656).w
	cmpi.b	#2,($FFFFFC82).w
	bne.s	loc_1B1E8
	addi.w	#$20,($FFFFA656).w

loc_1B1E8:
	bsr.w	sub_1B222
	st	(Background_NoScrollFlag).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BAB0,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1B37C,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1B43A,4(a0)
	rts

; =============== S U B	R O U T	I N E =======================================


sub_1B222:
	move.w	($FFFFA656).w,(Camera_Y_pos).w
	move.w	#$DF,d4
	moveq	#0,d5
	move.w	(Level_Layout).w,d5
	swap	d5
	lea	(Horiz_Scroll_Buffer).l,a4

loc_1B23A:
	move.l	d5,(a4)+
	dbf	d4,loc_1B23A
	rts
; End of function sub_1B222

; ---------------------------------------------------------------------------

Load_TitleScreen:
	move.w	#bgm_Ice,d0
	jsr	(j_PlaySound).l
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	move.w	#$7FF,d0

loc_1B258:
	move.w	#$20BC,(a6)
	dbf	d0,loc_1B258
	bsr.w	sub_1B2A4
	bsr.w	Load_TitleArt
	moveq	#7,d4
	bsr.w	sub_1BF24
	bsr.w	sub_1B532
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Obj_TitleMenu,4(a0)	; Title menu object
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Obj_TitleTextKid,4(a0)	; Object for Kid text on title screen
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#Obj_TitleTextChameleon,4(a0)	; Object loading Chameleon text on title screen
	rts

; =============== S U B	R O U T	I N E =======================================


sub_1B2A4:

; FUNCTION CHUNK AT 0001C4B2 SIZE 00000038 BYTES

	move.w	#$1820,d0
	move.l	#byte_2A756,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$21E0,d0
	move.l	#byte_26E3D,a0
	tst.b	($FFFFFC82).w
	beq.s	loc_1B2D8
	move.l	#byte_2927C,a0
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1B2D8
	move.l	#byte_282C1,a0

loc_1B2D8:
	jsr	(j_DecompressToVRAM).l
	move.w	#$6620,d0
	move.l	#byte_2A961,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$FA60,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$20C1,d0
	lea	(unk_2F7D0).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	move.l	#vdpComm($F000,VRAM,WRITE),4(a6)
	lea	unk_1B32C(pc),a0
	moveq	#$1F,d0

loc_1B322:
	move.w	(a0)+,(a6)
	dbf	d0,loc_1B322
	bra.w	loc_1C4B2
; End of function sub_1B2A4

; ---------------------------------------------------------------------------
unk_1B32C:	dc.b $11
	dc.b $11
	dc.b $10
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $11
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_1B36C:
	move.l	d0,-(sp)
	move.w	#sfx_Thunderstorm,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; End of function sub_1B36C

; ---------------------------------------------------------------------------

loc_1B37C:
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#1,d0
	bsr.w	sub_1B41C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d0
	bsr.w	sub_1B41C
	bsr.s	sub_1B36C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#2,d0
	bsr.w	sub_1B41C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d0
	bsr.w	sub_1B41C
	bsr.s	sub_1B36C
	move.w	#$2C,d1

loc_1B3BC:
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	d1,d0
	andi.w	#3,d0
	addq.w	#1,d0
	bsr.s	sub_1B41C
	dbf	d1,loc_1B3BC
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d0
	bsr.s	sub_1B41C
	bsr.s	sub_1B36C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#1,d0
	bsr.s	sub_1B41C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d0
	bsr.s	sub_1B41C
	bsr.w	sub_1B36C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#2,d0
	bsr.s	sub_1B41C
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d0
	bsr.s	sub_1B41C
	bsr.w	sub_1B36C
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_1B41C:
	move.w	d0,d4
	lsl.w	#7,d4
	move.l	#ArtUnc_2A4D6,a4
	add.w	d4,a4
	move.l	#vdpComm($17A0,VRAM,WRITE),4(a6)
	moveq	#$1F,d4

loc_1B432:
	move.l	(a4)+,(a6)
	dbf	d4,loc_1B432
	rts
; End of function sub_1B41C


; =============== S U B	R O U T	I N E =======================================


sub_1B43A:
	move.w	#$2A,-(sp)
	jsr	(j_Hibernate_Object).w
	lea	unk_1B4D6(pc),a0

loc_1B446:
	move.w	#3,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#0,d4
	move.b	(a0)+,d4
	bmi.s	loc_1B45A
	bsr.w	sub_1BF24
	bra.s	loc_1B446
; ---------------------------------------------------------------------------

loc_1B45A:
	move.w	#$39,-(sp)
	jsr	(j_Hibernate_Object).w
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1
	moveq	#$3F,d0

loc_1B470:
	move.w	(a0),(a1)+
	clr.w	(a0)+
	dbf	d0,loc_1B470
	jsr	(j_Hibernate_Object_1Frame).w
	moveq	#7,d4
	bsr.w	sub_1BF24
	bsr.w	sub_1B532
	lea	(Palette_Buffer).l,a0
	lea	($FFFF4ED8).l,a1
	moveq	#$3F,d0

loc_1B494:
	move.w	(a1)+,(a0)+
	dbf	d0,loc_1B494
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	Load_TitleArt
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#GfxObjects_Collision_BottomBoundary4,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1B6AC,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1B5CE,4(a0)
	jmp	(j_Delete_CurrentObject).w
; End of function sub_1B43A

; ---------------------------------------------------------------------------
unk_1B4D6:	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   2
	dc.b   3
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   3
	dc.b   4
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   4
	dc.b   5
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   5
	dc.b   6
	dc.b   5
	dc.b   6
	dc.b $FF
unk_1B4F4:	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b   0
	dc.b  $F
; ---------------------------------------------------------------------------

GfxObjects_Collision_BottomBoundary4:
	move.w	#$A,-(sp)
	jsr	(j_Hibernate_Object).w
	move.l	(Level_Layout).w,d0
	asr.l	#4,d0
	move.l	($FFFFA656).w,d1
	asr.l	#4,d1
	moveq	#$F,d2

loc_1B51A:
	jsr	(j_Hibernate_Object_1Frame).w
	sub.l	d0,(Level_Layout).w
	sub.l	d1,($FFFFA656).w
	bsr.w	sub_1B222
	dbf	d2,loc_1B51A
	jmp	(j_Delete_CurrentObject).w

; =============== S U B	R O U T	I N E =======================================


sub_1B532:
	move.l	#vdpComm($1780,VRAM,WRITE),4(a6)
	moveq	#7,d0
	moveq	#0,d1

loc_1B53E:
	move.l	d1,(a6)
	dbf	d0,loc_1B53E
	move.w	#$331,d0
	lea	(unk_2F840).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	moveq	#$1B,d0

loc_1B566:
	moveq	#$3F,d1

loc_1B568:
	move.w	(a4),(a6)
	dbf	d1,loc_1B568
	addq.w	#2,a4
	dbf	d0,loc_1B566
	rts
; End of function sub_1B532


; =============== S U B	R O U T	I N E =======================================


Load_TitleArt:
	move.w	#$6760,d0
	move.l	#byte_22080,a0
	lea	unk_1B4F4(pc),a3
	jsr	(j_DecompressToRAM).l
	move.w	#$9A60,d0
	move.l	#byte_24985,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A360,d0
	move.l	#byte_26036,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A980,d0
	move.l	#byte_2A479,a0
	jsr	(j_DecompressToVRAM).l
	rts
; End of function Load_TitleArt


; =============== S U B	R O U T	I N E =======================================

;sub_1B5BC:
Obj_TitleTextKid:
	move.l	#$1FF0000,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	#$A5,y_pos(a3)
	bra.s	loc_1B5E4
; ---------------------------------------------------------------------------

loc_1B5CE:
	move.l	#$1FF0000,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	#6,y_vel(a3)
	move.w	#$FFA3,y_pos(a3)

loc_1B5E4:
	move.b	#2,palette_line(a3)
	move.w	#$2E,x_pos(a3)
	move.w	#$4D3,vram_tile(a3)
	move.w	#(LnkTo_unk_E10FE-Data_Index),addroffset_sprite(a3)
	move.w	#$2A,d0
	st	$13(a3)
	move.w	#$1E,-(sp)
	jsr	(j_Hibernate_Object).w
	st	is_moved(a3)

loc_1B610:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1B610
	sf	is_moved(a3)
	move.w	#$14,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_1B652
	move.w	#$2E,x_pos(a3)
	move.w	#$8C,y_pos(a3)
	move.w	#$A,-(sp)
	jsr	(j_Hibernate_Object).w
	bsr.w	sub_1B652
	move.w	#$5A,x_pos(a3)
	move.w	#$98,y_pos(a3)

loc_1B64C:
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_1B64C
; End of function Obj_TitleTextKid


; =============== S U B	R O U T	I N E =======================================


sub_1B652:
	move.l	#$2010000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.l	a1,a3
	move.b	#2,palette_line(a3)
	move.w	#$2E,x_pos(a3)
	move.w	#$40,y_pos(a3)
	move.w	#$54C,vram_tile(a3)
	st	is_moved(a3)
	st	$13(a3)
	move.l	#stru_1B68A,d7
	jsr	(j_Init_Animation).w
	rts
; End of function sub_1B652

; ---------------------------------------------------------------------------
stru_1B68A:
	anim_frame	  1,   4, LnkTo_unk_E11B6-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E11BE-Data_Index
	anim_frame	  1, $64, 0
	anim_frame	  1,   4, LnkTo_unk_E11A6-Data_Index
	anim_frame	  1,   4, LnkTo_unk_E11AE-Data_Index
	dc.b   2
	dc.b $15
; ---------------------------------------------------------------------------
;loc_1B6A0:
Obj_TitleTextChameleon:
	moveq	#0,d2

loc_1B6A2:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1B71A
	bra.s	loc_1B6A2
; ---------------------------------------------------------------------------

loc_1B6AC:
	move.w	#$1E,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BB10,4(a0)
	move.w	#$27,$44(a0)
	moveq	#$28,d2
	moveq	#0,d3

loc_1B6CE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1B71A
	subq.w	#1,d2
	bne.s	loc_1B6CE
	moveq	#0,d0

loc_1B6DC:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	d0,-(sp)
	bsr.w	sub_1B71A
	move.w	(sp)+,d0
	addq.w	#1,d0
	cmpi.w	#$1E,d0
	bne.s	loc_1B6DC
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#SegaText,$44(a0)
	bra.s	loc_1B6DC
; ---------------------------------------------------------------------------
off_1B70A:
	dc.l unk_2E706
	dc.l unk_2E728
	dc.l unk_2E77A
	dc.l unk_2E728

; =============== S U B	R O U T	I N E =======================================


sub_1B71A:
	addq.w	#1,d3
	move.w	d3,d0
	andi.w	#$C,d0
	move.l	off_1B70A(pc,d0.w),a0
	cmpi.w	#$22,d2
	bcc.w	return_1B7B4
	tst.w	d2
	bpl.s	loc_1B734
	moveq	#0,d2

loc_1B734:
	move.w	#$433B,d0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	moveq	#5,d4
	moveq	#$12,d5
	moveq	#$1D,d6
	sub.w	d2,d4
	bpl.s	loc_1B758
	suba.w	d4,a4
	suba.w	d4,a4
	add.w	d4,d6
	moveq	#0,d4

loc_1B758:
	move.w	d5,d0
	lsl.w	#7,d0
	add.w	d4,d0
	add.w	d4,d0
	addi.w	#$4000,d0
	swap	d0
	clr.w	d0
	subq.w	#1,d6
	moveq	#6,d7

loc_1B76C:
	move.w	d6,d1
	cmpi.w	#6,d7
	bne.s	loc_1B780
	tst.w	d4
	bmi.s	loc_1B780
	cmpi.w	#$14,d1
	blt.s	loc_1B780
	moveq	#$14,d1

loc_1B780:
	tst.w	d4
	beq.s	loc_1B79A
	subi.l	#$20000,d0
	move.l	d0,4(a6)
	move.w	#$BC,(a6)
	addi.l	#$20000,d0
	bra.s	loc_1B79E
; ---------------------------------------------------------------------------

loc_1B79A:
	move.l	d0,4(a6)

loc_1B79E:
	addi.l	#$800000,d0
	move.l	a4,a0

loc_1B7A6:
	move.w	(a0)+,(a6)
	dbf	d1,loc_1B7A6
	lea	$3A(a4),a4
	dbf	d7,loc_1B76C

return_1B7B4:
	rts
; End of function sub_1B71A


; =============== S U B	R O U T	I N E =======================================


sub_1B7B6:
	lea	unk_1B7E0(pc),a0

loc_1B7BA:
	moveq	#-1,d0
	move.w	(a0)+,d0
	cmpi.w	#$FFFF,d0
	beq.s	return_1B7DE
	move.l	d0,a1
	move.w	#$21AB,(a1)
	move.w	#$21AC,2(a1)
	move.w	#$21AD,$50(a1)
	move.w	#$21AE,$52(a1)
	bra.s	loc_1B7BA
; ---------------------------------------------------------------------------

return_1B7DE:
	rts
; End of function sub_1B7B6

; ---------------------------------------------------------------------------
unk_1B7E0:	dc.b $7C ; |
	dc.b $12
	dc.b $7C ; |
	dc.b $1A
	dc.b $7C ; |
	dc.b $22 ; "
	dc.b $7C ; |
	dc.b $2A ; *
	dc.b $7C ; |
	dc.b $32 ; 2
	dc.b $7C ; |
	dc.b $B2 ; �
	dc.b $7C ; |
	dc.b $B6 ; �
	dc.b $7C ; |
	dc.b $BA ; �
	dc.b $7C ; |
	dc.b $BE ; �
	dc.b $7C ; |
	dc.b $C2 ; �
	dc.b $7C ; |
	dc.b $C6 ; �
	dc.b $7C ; |
	dc.b $CA ; �
	dc.b $7C ; |
	dc.b $CE ; �
	dc.b $7C ; |
	dc.b $D2 ; �
	dc.b $7D ; }
	dc.b $52 ; R
	dc.b $7D ; }
	dc.b $56 ; V
	dc.b $7D ; }
	dc.b $5A ; Z
	dc.b $7D ; }
	dc.b $5E ; ^
	dc.b $7D ; }
	dc.b $62 ; b
	dc.b $7D ; }
	dc.b $66 ; f
	dc.b $7D ; }
	dc.b $6A ; j
	dc.b $7D ; }
	dc.b $6E ; n
	dc.b $7D ; }
	dc.b $72 ; r
	dc.b $7D ; }
	dc.b $F2 ; �
	dc.b $7D ; }
	dc.b $F6 ; �
	dc.b $7D ; }
	dc.b $FA ; �
	dc.b $7D ; }
	dc.b $FE ; �
	dc.b $7E ; ~
	dc.b   2
	dc.b $7E ; ~
	dc.b   6
	dc.b $7E ; ~
	dc.b  $A
	dc.b $7E ; ~
	dc.b  $E
	dc.b $7E ; ~
	dc.b $12
	dc.b $7E ; ~
	dc.b $92 ; �
	dc.b $7E ; ~
	dc.b $96 ; �
	dc.b $7E ; ~
	dc.b $9A ; �
	dc.b $7E ; ~
	dc.b $9E ; �
	dc.b $7E ; ~
	dc.b $A2 ; �
	dc.b $7E ; ~
	dc.b $A6 ; �
	dc.b $7E ; ~
	dc.b $AA ; �
	dc.b $7E ; ~
	dc.b $AE ; �
	dc.b $7E ; ~
	dc.b $B2 ; �
	dc.b $7F ; 
	dc.b $36 ; 6
	dc.b $7F ; 
	dc.b $3A ; :
	dc.b $7F ; 
	dc.b $3E ; >
	dc.b $7F ; 
	dc.b $42 ; B
	dc.b $7F ; 
	dc.b $46 ; F
	dc.b $7F ; 
	dc.b $4A ; J
	dc.b $7F ; 
	dc.b $4E ; N
	dc.b $7F ; 
	dc.b $D6 ; �
	dc.b $7F ; 
	dc.b $DA ; �
	dc.b $7F ; 
	dc.b $DE ; �
	dc.b $7F ; 
	dc.b $E2 ; �
	dc.b $7F ; 
	dc.b $E6 ; �
	dc.b $7F ; 
	dc.b $EA ; �
	dc.b $7F ; 
	dc.b $EE ; �
	dc.b $FF
	dc.b $FF

; =============== S U B	R O U T	I N E =======================================


sub_1B850:
	move.w	#$1780,d0
	lea	(byte_2D73B).l,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$2740,d0
	lea	(byte_2D71A).l,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$2800,d0
	lea	(byte_2DEBF).l,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$3AC0,d0
	lea	(byte_261D7).l,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$FA60,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$80BC,d0
	lea	(unk_2FDE0).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	moveq	#0,d4
	moveq	#0,d5
	moveq	#$28,d6
	moveq	#$1C,d7
	bsr.w	sub_1C5D0
	move.w	#$413A,d0
	lea	(unk_2FDCE).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	moveq	#$1B,d0

loc_1B8E4:
	moveq	#$3F,d1

loc_1B8E6:
	move.w	(a4),(a6)
	dbf	d1,loc_1B8E6
	addq.w	#2,a4
	dbf	d0,loc_1B8E4
	rts
; End of function sub_1B850


; =============== S U B	R O U T	I N E =======================================


sub_1B8F4:
	bsr.w	sub_1C54A
	bsr.w	sub_1C4EA
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#IntroText1,$44(a0)
	move.l	#loc_1B920,$44(a5)
	bsr.w	sub_1C204

loc_1B920:
	move.w	#$12B,d0

loc_1B924:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	dbf	d0,loc_1B924
	move.w	#$18,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; End of function sub_1B8F4


; =============== S U B	R O U T	I N E =======================================


sub_1B93E:
	bsr.w	sub_1C54A
	bsr.w	sub_1C4EA
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#IntroText3,$44(a0)
	move.l	#loc_1B96A,$44(a5)
	bsr.w	sub_1C204

loc_1B96A:
	move.w	#$EF,d0

loc_1B96E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	dbf	d0,loc_1B96E
	move.w	#$20,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; End of function sub_1B93E


; =============== S U B	R O U T	I N E =======================================


sub_1B988:
	move.w	#4,(Camera_Y_pos).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#IntroText4,$44(a0)
	move.l	#loc_1B9B2,$44(a5)
	bsr.w	sub_1C204

loc_1B9B2:
	move.w	#$21B,d0

loc_1B9B6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	dbf	d0,loc_1B9B6
	move.w	#$24,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; End of function sub_1B988

; ---------------------------------------------------------------------------

loc_1B9D0:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#IntroText2,$44(a0)
	move.l	#loc_1B9F4,$44(a5)
	bsr.w	sub_1C204

loc_1B9F4:
	move.w	#$3C,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$149,d0
	moveq	#-$40,d1

loc_1BA02:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C1A2
	bsr.w	sub_1C1A2
	bsr.w	sub_1C246
	bsr.w	sub_1C180
	dbf	d0,loc_1BA02
	move.w	#$1C,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_1BA28:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#IntroText5,$44(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BC36,4(a0)
	move.l	#loc_1BA5C,$44(a5)
	bsr.w	sub_1C204

loc_1BA5C:
	move.w	#$1BC,d0

loc_1BA60:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	dbf	d0,loc_1BA60
	move.w	#$28,(Game_Mode).w
	sf	($FFFFFBCE).w
	moveq	#$3F,d0
	move.w	#$AAA,d1
	lea	($FFFF4F58).l,a0

loc_1BA82:
	move.w	d1,(a0)+
	dbf	d0,loc_1BA82
	move.w	#$100,($FFFFF876).w
	bra.s	loc_1BAA0
; ---------------------------------------------------------------------------

loc_1BA90:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	subi.w	#$20,($FFFFF876).w
	bmi.s	loc_1BAAC

loc_1BAA0:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_1BA90
; ---------------------------------------------------------------------------

loc_1BAAC:
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_1BAB0:
	move.w	#$B8,d0

loc_1BAB4:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	dbf	d0,loc_1BAB4
	bra.s	loc_1BAEA
; ---------------------------------------------------------------------------
;loc_1BAC2:
Obj_TitleMenu:
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BB10,4(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1C7A0,4(a0)
	move.l	#SegaText,$44(a0)

loc_1BAEA:
	move.w	#$280,d0

loc_1BAEE:
	clr.b	(Ctrl_Pressed).w
	jsr	(j_Hibernate_Object_1Frame).w
	bclr	#7,(Ctrl_1_Pressed).w
	bne.s	loc_1BB52
	dbf	d0,loc_1BAEE

loc_1BB02:
	move.w	#$10,(Game_Mode).w
	st	($FFFFFBCE).w
	jmp	(j_loc_6E2).w
; ---------------------------------------------------------------------------

loc_1BB10:
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#2,palette_line(a3)
	move.w	#$94,y_pos(a3)
	move.w	#$4BD,vram_tile(a3)
	move.w	#(LnkTo_unk_E0ED6-Data_Index),addroffset_sprite(a3)

loc_1BB36:
	move.w	#$10C,d0
	move.w	$44(a5),d1
	beq.s	loc_1BB44
	subq.w	#1,$44(a5)

loc_1BB44:
	lsl.w	#3,d1
	sub.w	d1,d0
	move.w	d0,x_pos(a3)
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_1BB36
; ---------------------------------------------------------------------------

loc_1BB52:
	move.w	#$451B,d0
	lea	(unk_2EAAE).l,a0
	lea	(Decompression_Buffer).l,a1
	move.l	a1,a4
	jsr	(j_EniDec).l
	moveq	#4,d4
	moveq	#4,d5
	moveq	#$D,d6
	moveq	#5,d7
	bsr.w	sub_1C5D0
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#2,palette_line(a3)
	move.w	#$28,x_pos(a3)
	move.w	#$30,y_pos(a3)
	move.w	#$54B,vram_tile(a3)
	move.w	#(LnkTo_unk_E1196-Data_Index),addroffset_sprite(a3)
	move.w	#$280,d0
	moveq	#0,d1

Title_InputLoop:
	clr.b	(Ctrl_Pressed).w
	jsr	(j_Hibernate_Object_1Frame).w
	bclr	#7,(Ctrl_1_Pressed).w ; start pressed at title screen
	beq.s	loc_1BBDE
	move.w	#$14,(Game_Mode).w ; mode options
	cmpi.w	#2,d1
	beq.s	loc_1BBD6
	move.w	#8,(Game_Mode).w
	tst.w	d1
	sne	(Two_player_flag).w
	jsr	(j_StopMusic).l

loc_1BBD6:
	st	($FFFFFBCE).w
	if insertLevelSelect = 0
	jmp	(j_loc_6E2).w
	else
	jmp	(LevelSelect_ChkKey).w
	endif
; ---------------------------------------------------------------------------

loc_1BBDE:
	bclr	#0,(Ctrl_1_Pressed).w
	beq.s	loc_1BBF6
	tst.w	d1
	beq.s	loc_1BBF6
	subq.w	#1,d1
	bsr.w	sub_1BC26
	move.w	#$280,d0
	bra.s	loc_1BC0E
; ---------------------------------------------------------------------------

loc_1BBF6:
	bclr	#1,(Ctrl_1_Pressed).w
	beq.s	loc_1BC0E
	cmpi.w	#2,d1
	beq.s	loc_1BC0E
	bsr.w	sub_1BC26
	addq.w	#1,d1
	move.w	#$280,d0

loc_1BC0E:
	move.w	d1,d2
	add.w	d2,d2
	move.w	word_1BC20(pc,d2.w),y_pos(a3)
	dbf	d0,Title_InputLoop
	bra.w	loc_1BB02
; ---------------------------------------------------------------------------
word_1BC20:	dc.w $30
	dc.w $3A
	dc.w $44

; =============== S U B	R O U T	I N E =======================================


sub_1BC26:
	move.l	d0,-(sp)
	move.w	#sfx_Navigate_jingle,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	rts
; End of function sub_1BC26

; ---------------------------------------------------------------------------

loc_1BC36:
	moveq	#0,d4
	bsr.w	sub_1C034
	move.w	#$A0,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#1,d4
	bsr.w	sub_1C034
	move.w	#$90,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#2,d4
	bsr.w	sub_1C034
	move.w	#$B,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#3,d4
	bsr.w	sub_1C034
	move.w	#$B,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#4,d4
	bsr.w	sub_1C034
	moveq	#3,d4
	moveq	#$13,d5
	bsr.w	sub_1C0EE
	move.w	#$B,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#3,d4
	moveq	#$13,d5
	bsr.w	sub_1C112
	moveq	#5,d4
	bsr.w	sub_1C034
	move.w	#$37,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#6,d4
	bsr.w	sub_1C034
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#7,d4
	bsr.w	sub_1C034
	move.w	#8,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#6,d4
	bsr.w	sub_1C034
	move.w	#$F,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#5,d4
	bsr.w	sub_1C034

loc_1BCCA:
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_1BCCA
; ---------------------------------------------------------------------------

loc_1BCD0:
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.w	#$30,$1A(a1)
	move.w	#$80,$1E(a1)
	move.w	#$26C,$24(a1)
	move.w	#(LnkTo_unk_E1066-Data_Index),$22(a1)
	move.l	a1,$36(a5)
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.w	#$60,$1A(a1)
	move.w	#$80,$1E(a1)
	move.w	#$26C,$24(a1)
	move.w	#(LnkTo_unk_E106E-Data_Index),$22(a1)
	move.l	a1,$3A(a5)
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.w	#0,$1A(a1)
	move.w	#$E0,$1E(a1)
	move.w	#$26C,$24(a1)
	move.w	#(LnkTo_unk_E1076-Data_Index),$22(a1)
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.w	#$30,$1A(a1)
	move.w	#$B0,$1E(a1)
	move.w	#$26C,$24(a1)
	move.w	#(LnkTo_unk_E1076-Data_Index),$22(a1)
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#2,$11(a1)
	move.w	#$60,$1A(a1)
	move.w	#$B0,$1E(a1)
	move.w	#$26C,$24(a1)
	move.w	#(LnkTo_unk_E107E-Data_Index),$22(a1)
	move.w	#$1A0,-(sp)
	jsr	(j_Hibernate_Object).w
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BE3C,4(a0)
	move.l	#unk_1BE18,$44(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BE3C,4(a0)
	move.l	#unk_1BE24,$44(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BE3C,4(a0)
	move.l	#unk_1BE30,$44(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1BE88,4(a0)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
unk_1BE18:	dc.b $11
	dc.b $C8 ; �
	dc.b   0
	dc.b $12
	dc.b   0
	dc.b $78 ; x
	dc.b $FF
	dc.b $FC ; �
	dc.b $FF
	dc.b $FE ; �
	dc.b   0
	dc.b $28 ; (
unk_1BE24:	dc.b $11
	dc.b $CC ; �
	dc.b   0
	dc.b $58 ; X
	dc.b   0
	dc.b $68 ; h
	dc.b   0
	dc.b   4
	dc.b $FF
	dc.b $FE ; �
	dc.b   0
	dc.b $3C ; <
unk_1BE30:	dc.b $11
	dc.b $D0 ; �
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $80 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $28 ; (
; ---------------------------------------------------------------------------

loc_1BE3C:
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#2,palette_line(a3)
	move.l	$44(a5),a0
	move.w	(a0)+,addroffset_sprite(a3)
	move.w	(a0)+,x_pos(a3)
	move.w	(a0)+,y_pos(a3)
	move.w	(a0)+,x_vel(a3)
	move.w	(a0)+,y_vel(a3)
	move.w	(a0)+,d0
	move.w	#$26C,vram_tile(a3)
	st	is_moved(a3)

loc_1BE74:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$4000,y_vel(a3)
	dbf	d0,loc_1BE74
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1BE88:
	move.l	#$1FF0000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#3,palette_line(a3)
	move.b	#1,priority(a3)
	move.w	#$30,x_pos(a3)
	move.w	#$70,y_pos(a3)
	tst.b	($FFFFFC82).w
	bne.s	loc_1BEBE
	subq.w	#6,x_pos(a3)
	addq.w	#4,y_pos(a3)
	bra.s	loc_1BECE
; ---------------------------------------------------------------------------

loc_1BEBE:
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1BECE
	subq.w	#6,x_pos(a3)
	addq.w	#4,y_pos(a3)

loc_1BECE:
	move.l	#$2F000,x_vel(a3)
	move.l	#-$8F000,y_vel(a3)
	move.w	#$5EB,vram_tile(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_E10B6-Data_Index),d0
	tst.b	($FFFFFC82).w
	beq.s	loc_1BF02
	move.w	#(LnkTo_unk_E10C6-Data_Index),d0
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1BF02
	move.w	#(LnkTo_unk_E10BE-Data_Index),d0

loc_1BF02:
	move.w	d0,addroffset_sprite(a3)
	move.w	#$1C,d0

loc_1BF0A:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$9000,y_vel(a3)
	dbf	d0,loc_1BF0A
	sf	is_moved(a3)

loc_1BF1E:
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_1BF1E

; =============== S U B	R O U T	I N E =======================================


sub_1BF24:
	movem.l	d0-d3/a0-a3,-(sp)
	tst.w	d4
	beq.s	loc_1BF3E
	tst.b	($FFFFFC82).w
	beq.s	loc_1BF3E
	addq.w	#7,d4
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1BF3E
	addq.w	#7,d4

loc_1BF3E:
	mulu.w	#6,d4
	lea	off_1BFB0(pc),a4
	add.w	d4,a4
	move.w	#$20C1,d0
	tst.w	d4
	beq.s	loc_1BF54
	move.w	#$210F,d0

loc_1BF54:
	move.l	(a4)+,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.w	#$167,d0
	lea	($FFFF7F82).l,a0
	move.w	#$20BC,d1

loc_1BF70:
	move.w	d1,(a0)+
	dbf	d0,loc_1BF70
	lea	($FFFF7F82).l,a0
	lea	(Decompression_Buffer).l,a1
	moveq	#$13,d1

loc_1BF84:
	move.w	(a4),d0
	subq.w	#1,d0
	move.l	a0,a2

loc_1BF8A:
	move.w	(a1)+,(a2)+
	dbf	d0,loc_1BF8A
	addi.w	#$24,a0
	dbf	d1,loc_1BF84
	lea	($FFFF7F82).l,a4
	moveq	#$15,d4
	moveq	#1,d5
	moveq	#$12,d6
	moveq	#$14,d7
	bsr.w	sub_1C5D0
	movem.l	(sp)+,d0-d3/a0-a3
	rts
; End of function sub_1BF24

; ---------------------------------------------------------------------------
; Each entry is a pointer to Enigma compressed mappings and width in tiles.
off_1BFB0:
	dc.l unk_2F7D0
	dc.w $12
	; Red Stealth
	dc.l unk_2EACE
	dc.w $12
	dc.l unk_2EB32
	dc.w $12
	dc.l unk_2EBD4
	dc.w $12
	dc.l unk_2EC86
	dc.w $12
	dc.l unk_2ED62
	dc.w $12
	dc.l unk_2EE54
	dc.w $12
	dc.l unk_2EF2C
	dc.w $11
	; Maniaxe
	dc.l unk_2F306
	dc.w $10
	dc.l unk_2F374
	dc.w $10
	dc.l unk_2F41E
	dc.w $10
	dc.l unk_2F4D0
	dc.w $10
	dc.l unk_2F592
	dc.w $10
	dc.l unk_2F674
	dc.w $10
	dc.l unk_2F76A
	dc.w $E
	; Juggernaut
	dc.l unk_2EF92
	dc.w $10
	dc.l unk_2EFFE
	dc.w $10
	dc.l unk_2F09C
	dc.w $10
	dc.l unk_2F124
	dc.w $10
	dc.l unk_2F1B0
	dc.w $10
	dc.l unk_2F242
	dc.w $10
	dc.l unk_2F2D0
	dc.w $10

; =============== S U B	R O U T	I N E =======================================


sub_1C034:
	movem.l	d0-d3/a0-a3,-(sp)
	mulu.w	#$A,d4
	lea	off_1C126(pc),a4
	add.w	d4,a4
	move.w	#$A340,d0
	move.l	(a4)+,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.w	#$18F,d0
	lea	($FFFF7F82).l,a0
	moveq	#0,d1

loc_1C060:
	move.w	d1,(a0)+
	dbf	d0,loc_1C060
	lea	($FFFF7F82).l,a0
	add.w	4(a4),a0
	lea	(Decompression_Buffer).l,a1
	move.w	2(a4),d1
	subq.w	#1,d1

loc_1C07C:
	move.w	(a4),d0
	subq.w	#1,d0
	move.l	a0,a2

loc_1C082:
	move.w	(a1)+,(a2)+
	dbf	d0,loc_1C082
	addi.w	#$20,a0
	dbf	d1,loc_1C07C
	move.l	#$41940000,d0
	lea	($FFFF7F82).l,a0
	moveq	#7,d7

loc_1C09E:
	moveq	#$E,d6
	move.l	d0,4(a6)

loc_1C0A4:
	move.w	(a0)+,(a6)
	dbf	d6,loc_1C0A4
	addq.w	#2,a0
	addi.l	#$800000,d0
	dbf	d7,loc_1C09E
	moveq	#1,d7

loc_1C0B8:
	moveq	#$F,d6
	move.l	d0,4(a6)

loc_1C0BE:
	move.w	(a0)+,(a6)
	dbf	d6,loc_1C0BE
	addi.l	#$800000,d0
	dbf	d7,loc_1C0B8
	moveq	#$E,d7

loc_1C0D0:
	moveq	#$E,d6
	move.l	d0,4(a6)

loc_1C0D6:
	move.w	(a0)+,(a6)
	dbf	d6,loc_1C0D6
	addq.w	#2,a0
	addi.l	#$800000,d0
	dbf	d7,loc_1C0D0
	movem.l	(sp)+,d0-d3/a0-a3
	rts
; End of function sub_1C034


; =============== S U B	R O U T	I N E =======================================


sub_1C0EE:
	move.w	#$A340,d0
	lea	(unk_2FDA6).l,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l

loc_1C104:
	lea	(Decompression_Buffer).l,a4
	moveq	#$A,d6
	moveq	#9,d7
	bra.w	sub_1C5D0
; End of function sub_1C0EE


; =============== S U B	R O U T	I N E =======================================


sub_1C112:
	move.w	#$59,d0
	lea	(Decompression_Buffer).l,a0
	moveq	#0,d1

loc_1C11E:
	move.w	d1,(a0)+
	dbf	d0,loc_1C11E
	bra.s	loc_1C104
; End of function sub_1C112

; ---------------------------------------------------------------------------
off_1C126:	dc.l unk_2F856
	dc.w $C
	dc.w $18
	dc.w 6
	dc.l unk_2F882
	dc.w $C
	dc.w $18
	dc.w 6
	dc.l unk_2F8D2
	dc.w $C
	dc.w $19
	dc.w 6
	dc.l unk_2F94E
	dc.w $E
	dc.w $19
	dc.w 4
	dc.l unk_2F9DE
	dc.w $F
	dc.w $19
	dc.w 0
	dc.l unk_2FAA8
	dc.w $D
	dc.w $19
	dc.w 4
	dc.l unk_2FB76
	dc.w $D
	dc.w $19
	dc.w 4
	dc.l unk_2FC3A
	dc.w $D
	dc.w $19
	dc.w 4
	dc.l unk_2FCE4
	dc.w $D
	dc.w $19
	dc.w 4

; =============== S U B	R O U T	I N E =======================================


sub_1C180:
	move.l	#vdpComm($1780,VRAM,WRITE),4(a6)
	move.w	#$2BF,d3
	lea	($FFFFB152).w,a1
	lea	(Level_Layout).w,a0

loc_1C194:
	move.l	(a0)+,d4
	move.l	(a1)+,d5
	eor.l	d4,d5
	move.l	d5,(a6)
	dbf	d3,loc_1C194
	rts
; End of function sub_1C180


; =============== S U B	R O U T	I N E =======================================


sub_1C1A2:
	addq.w	#1,d1
	bmi.s	return_1C1F2
	cmpi.w	#$40,d1
	bge.s	return_1C1F2
	lea	(Level_Layout).w,a0
	moveq	#$57,d2
	moveq	#0,d3
	move.w	d1,d4
	lsr.w	#2,d4
	move.b	byte_1C1F4(pc,d4.w),d3
	btst	#0,d1
	beq.s	loc_1C1C6
	addi.w	#$20,d3

loc_1C1C6:
	btst	#1,d1
	beq.s	loc_1C1CE
	addq.w	#4,d3

loc_1C1CE:
	bsr.s	sub_1C1D2
	rts
; End of function sub_1C1A2


; =============== S U B	R O U T	I N E =======================================


sub_1C1D2:
	movem.l	d2-d3/a0,-(sp)
	move.w	#$F0,d4
	lsr.w	#1,d3
	bcs.s	loc_1C1E2
	move.w	#$F,d4

loc_1C1E2:
	add.w	d3,a0

loc_1C1E4:
	and.b	d4,(a0)
	addi.w	#$20,a0
	dbf	d2,loc_1C1E4
	movem.l	(sp)+,d2-d3/a0

return_1C1F2:
	rts
; End of function sub_1C1D2

; ---------------------------------------------------------------------------
byte_1C1F4:	dc.b 0
	dc.b $12
	dc.b   2
	dc.b $10
	dc.b   9
	dc.b $1B
	dc.b  $B
	dc.b $19
	dc.b   1
	dc.b $13
	dc.b   3
	dc.b $11
	dc.b   8
	dc.b $1A
	dc.b  $A
	dc.b $18

; =============== S U B	R O U T	I N E =======================================


sub_1C204:
	moveq	#$3F,d0
	move.w	($FFFFFBCC).w,d1
	lea	($FFFF4F58).l,a0

loc_1C210:
	move.w	d1,(a0)+
	dbf	d0,loc_1C210
	move.w	#0,($FFFFF876).w
	bra.s	loc_1C234
; ---------------------------------------------------------------------------

loc_1C21E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1C246
	addi.w	#$10,($FFFFF876).w
	cmpi.w	#$100,($FFFFF876).w
	bgt.s	loc_1C240

loc_1C234:
	moveq	#-1,d0
	move.l	d0,($FFFFF888).w
	move.l	d0,($FFFFF88C).w
	bra.s	loc_1C21E
; ---------------------------------------------------------------------------

loc_1C240:
	move.l	$44(a5),a0
	jmp	(a0)
; End of function sub_1C204


; =============== S U B	R O U T	I N E =======================================


sub_1C246:
	bclr	#7,(Ctrl_1_Pressed).w
	bne.s	loc_1C250
	rts
; ---------------------------------------------------------------------------

loc_1C250:
	cmpi.w	#$24,(Game_Mode).w
	beq.s	loc_1C264
	cmpi.w	#$28,(Game_Mode).w
	beq.s	loc_1C264
	bsr.w	sub_1C278

loc_1C264:
	move.w	#$2C,(Game_Mode).w
	st	($FFFFFBCE).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; End of function sub_1C246


; =============== S U B	R O U T	I N E =======================================


sub_1C278:
	addq.b	#1,($FFFFFC82).w
	cmpi.b	#3,($FFFFFC82).w
	bne.s	return_1C288
	clr.b	($FFFFFC82).w

return_1C288:
	rts
; End of function sub_1C278

; ---------------------------------------------------------------------------
Pal_1C28A:  binclude	"scenes/palette/intro1_wildside.bin"
Pal_1C2F0:  binclude	"scenes/palette/intro2_sky.bin"
unk_1C336:	dc.b   2
	dc.b   1
	dc.b   3
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b  $E
	dc.b  $F
Pal_1C346:  binclude	"scenes/palette/intro3_alley.bin"
Pal_1C3C6:  binclude	"scenes/palette/title_maniaxe_mask.bin"
Pal_1C3D4:  binclude	"scenes/palette/title_juggernaut_mask.bin"
unk_1C3F0:	dc.b   0
	dc.b   8
	dc.b   9
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
Pal_1C400:  binclude	"scenes/palette/title.bin"
Pal_1C466:  binclude	"scenes/palette/title_maniaxe.bin"
Pal_1C48C:  binclude	"scenes/palette/title_juggernaut.bin"
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_1B2A4

loc_1C4B2:
	lea	(Palette_Buffer).l,a1
	lea	Pal_1C400(pc),a0
	moveq	#$32,d0

loc_1C4BE:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C4BE
	tst.b	($FFFFFC82).w
	beq.s	return_1C4E8
	lea	(Palette_Buffer+$1A).l,a1
	lea	Pal_1C466(pc),a0
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1C4E0
	lea	Pal_1C48C(pc),a0

loc_1C4E0:
	moveq	#$12,d0

loc_1C4E2:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C4E2

return_1C4E8:
	rts
; END OF FUNCTION CHUNK	FOR sub_1B2A4

; =============== S U B	R O U T	I N E =======================================


sub_1C4EA:
	lea	($FFFF4ED8).l,a1
	lea	Pal_1C28A(pc),a0
	moveq	#$32,d0

loc_1C4F6:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C4F6
	rts
; End of function sub_1C4EA


; =============== S U B	R O U T	I N E =======================================


sub_1C4FE:
	lea	($FFFF4ED8).l,a1
	lea	Pal_1C2F0(pc),a0
	moveq	#$22,d0

loc_1C50A:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C50A
	rts
; End of function sub_1C4FE


; =============== S U B	R O U T	I N E =======================================


sub_1C512:
	lea	($FFFF4ED8).l,a1
	lea	Pal_1C346(pc),a0
	moveq	#$3F,d0

loc_1C51E:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C51E
	tst.b	($FFFFFC82).w
	beq.s	return_1C548
	lea	($FFFF4F3A).l,a1
	lea	Pal_1C3C6(pc),a0
	cmpi.b	#1,($FFFFFC82).w
	beq.s	loc_1C540
	lea	Pal_1C3D4(pc),a0

loc_1C540:
	moveq	#$D,d0

loc_1C542:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C542

return_1C548:
	rts
; End of function sub_1C512


; =============== S U B	R O U T	I N E =======================================


sub_1C54A:
	move.l	#$1000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.w	#$81,$1A(a1)
	move.w	#$C8,$1E(a1)
	move.w	#$140,$24(a1)
	move.w	#(LnkTo_unk_E109E-Data_Index),$22(a1)
	rts
; End of function sub_1C54A


; =============== S U B	R O U T	I N E =======================================


sub_1C572:
	move.l	#$2000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	#$3A,x_pos(a3)
	move.w	#(LnkTo_unk_E10A6-Data_Index),addroffset_sprite(a3)
	moveq	#1,d0
	bra.s	loc_1C5A4
; ---------------------------------------------------------------------------

loc_1C58C:
	move.l	#$2000004,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.w	#$DE,x_pos(a3)
	move.w	#(LnkTo_unk_E10AE-Data_Index),addroffset_sprite(a3)
	moveq	#-1,d0

loc_1C5A4:
	st	$13(a3)
	move.w	#$C8,y_pos(a3)
	move.w	#$140,vram_tile(a3)
	moveq	#$41,d1
	move.w	#$3C,-(sp)
	jsr	(j_Hibernate_Object).w

loc_1C5BE:
	jsr	(j_Hibernate_Object_1Frame).w
	add.w	d0,x_pos(a3)
	dbf	d1,loc_1C5BE

loc_1C5CA:
	jsr	(j_Hibernate_Object_1Frame).w
	bra.s	loc_1C5CA
; End of function sub_1C572


; =============== S U B	R O U T	I N E =======================================


sub_1C5D0:
	movem.l	d0-d1/d6-d7,-(sp)
	move.w	d5,d0
	lsl.w	#7,d0
	add.w	d4,d0
	add.w	d4,d0
	addi.w	#$4000,d0
	swap	d0
	clr.w	d0
	subq.w	#1,d6
	subq.w	#1,d7

loc_1C5E8:
	move.w	d6,d1
	move.l	d0,4(a6)
	addi.l	#$800000,d0

loc_1C5F4:
	move.w	(a4)+,(a6)
	dbf	d1,loc_1C5F4
	dbf	d7,loc_1C5E8
	movem.l	(sp)+,d0-d1/d6-d7
	rts
; End of function sub_1C5D0

; ---------------------------------------------------------------------------
; Chart of characters
; text value - meaning
;   $5C-$65 - numbers 1-9, 0
;    f  $66 - .
;    g  $67 - '
;    h  $68 - ,
;    i  $69 - !
;    j  $6A - ?
;   kl  $6B,$6C - (c) copyright
; \xFD  $FD - linebreak
; \xFE  $FE - delay, followed by a byte indicating the duration of delay
; \xFF  $FF - end of text
; Headers: VRAM destination plane address, VRAM base tile, delay between characters, x pos, y pos
IntroText1:	dc.w   0, $67D3, 2, 8, 2
	dc.b $FE, $20, "AFTER THE HEADY METAL DEFEATh", $FD, "THE GAME SOFTWARE", $FD
	dc.b $FE, $20, "HAD TO BE RESTORED", $FD, "AND DESIGNED AGAINf", $FF
	align 2
IntroText2:	dc.w $E000, $C7D3, 2, 7, 3
	dc.b $FE, $90, "A MYSTERIOUS TECHNICIAN gLUCIg", $FD, "MADE HIMSELF AVAILABLE TO", $FD, "RECOVER THE ARCADEf", $FF
	align 2
IntroText3:	dc.w   0, $67D3, 2, $A, 4
	dc.b $FE, $20, "AFTER THE CONCERTh", $FD, "REVEALED HIS CREEPY IDENTITYf",  $FF
	align 2
IntroText4:	dc.w   0, $C7D3, 2, 6, 8
	dc.b $FE, $20, "HE WAS THE DEMON HIMSELFf", $FD, $FD
	dc.b $FE, $40, "WANTING THE SOULS OF PLAYERS", $FD, "THOSE WHO HAD ALREADY PLAYED", $FD, "AND FAILED THEREf", $FF
	align 2
IntroText5:	dc.w   0, $C7D3, 2, $19, $3
	dc.b $FE, $20, "AGAIN OUR", $FD, "HEROi", $FD, "WILL RISK", $FD, "TO SAVE", $FD, "EVERYONEfff", $FD,$FD, $FD
	dc.b $FE, $60, "HE ISfff", $FF
	align 2
SegaText:	dc.w   0, $67D3, 0, $9, $19
	dc.b $00, " THE LAST SHOWDOWN", $FF	; 
	align 2
; ---------------------------------------------------------------------------

loc_1C7A0:
	move.l	$44(a5),a0
	lea	6(a0),a1
	move.w	(a1)+,d1
	move.w	(a1)+,d2
	moveq	#1,d0

loc_1C7AE:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.b	#1,d0
	bne.s	loc_1C7AE

loc_1C7B6:
	moveq	#0,d6
	move.b	(a1)+,d6
	cmpi.b	#$FF,d6
	bne.s	loc_1C7C4
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_1C7C4:
	cmpi.b	#$FD,d6
	bne.s	loc_1C7D2
	move.w	6(a0),d1
	addq.w	#2,d2
	bra.s	loc_1C7B6
; ---------------------------------------------------------------------------

loc_1C7D2:
	cmpi.b	#$FE,d6
	bne.s	loc_1C7DC
	move.b	(a1)+,d0
	bra.s	loc_1C7AE
; ---------------------------------------------------------------------------

loc_1C7DC:
	cmp.b	(off_20).w,d6	; This is likely a programming error and they forgot the # sign
	bne.s	loc_1C7E6
	move.b	#$6D,d6

loc_1C7E6:
	subi.b	#$41,d6
	bsr.s	sub_1C7F6
	addq.w	#1,d1
	move.w	4(a0),d0
	beq.s	loc_1C7B6
	bra.s	loc_1C7AE

; =============== S U B	R O U T	I N E =======================================


sub_1C7F6:
	move.w	d2,d4
	lsl.w	#7,d4
	add.w	d1,d4
	add.w	d1,d4
	add.w	(a0),d4
	move.w	d4,d5
	andi.w	#$3FFF,d5
	ori.w	#$4000,d5
	swap	d5
	rol.w	#2,d4
	andi.w	#3,d4
	move.w	d4,d5
	move.l	d5,4(a6)
	add.w	2(a0),d6
	move.w	d6,(a6)
	rts
; End of function sub_1C7F6


; =============== S U B	R O U T	I N E =======================================


sub_1C820:
	lea	(Palette_Buffer).l,a1
	lea	Pal_1C8AA(pc),a0
	moveq	#$F,d0

loc_1C82C:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C82C
	tst.w	d1
	beq.w	loc_1C84E
	suba.l	#$E,a1
	move.l	#$4000A0,(a1)+
	move.l	#$E004EE,(a1)+
	move.w	#$EEE,(a1)

loc_1C84E:
	lea	(Palette_Buffer+$20).l,a1
	moveq	#$2F,d0

loc_1C856:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C856
	rts
; End of function sub_1C820


; =============== S U B	R O U T	I N E =======================================


sub_1C85E:
	lea	(Palette_Buffer).l,a4
	add.w	d7,a4
	moveq	#$F,d7

loc_1C868:
	move.w	(a4),d6
	move.w	d6,d5
	move.w	d5,d4
	andi.w	#$F,d6
	beq.s	loc_1C876
	subq.w	#2,d6

loc_1C876:
	andi.w	#$F0,d5
	beq.s	loc_1C880
	subi.w	#$20,d5

loc_1C880:
	andi.w	#$F00,d4
	beq.s	loc_1C88A
	subi.w	#$200,d4

loc_1C88A:
	or.w	d4,d5
	or.w	d5,d6
	move.w	d6,(a4)+
	dbf	d7,loc_1C868
	rts
; End of function sub_1C85E


; =============== S U B	R O U T	I N E =======================================


sub_1C896:
	lea	(Palette_Buffer).l,a1
	lea	Pal_1C97C(pc),a0
	moveq	#$3F,d0

loc_1C8A2:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1C8A2
	rts
; End of function sub_1C896

; ---------------------------------------------------------------------------
Pal_1C8AA:  binclude	"scenes/palette/1C8AA.bin"
Pal_1C92A:  binclude	"scenes/palette/1C92A.bin"
Pal_1C97C:  binclude	"scenes/palette/options.bin"
	dc.b   0
	dc.b $78 ; x
	dc.b   0
	dc.b $C8 ; �
	dc.b   0
	dc.b $1E
	dc.b   0
	dc.b $24 ; $
	dc.b   1
	dc.b   1
; ---------------------------------------------------------------------------

Load_OptionMenu:
	jsr	(j_StopMusic).l
	move.w	#bgm_City,d0
	jsr	(j_PlaySound).l
	move.w	#$1780,d0
	move.l	(Addr_HoloBG).w,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$BC,d0
	move.l	(Addr_HoloBG).w,a0
	add.w	(off_718A).w,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1CD88
	move.w	#$9B80,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A120,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	lea	byte_1CA68(pc),a3
	jsr	(j_DecompressToRAM).l
; ---------------------------------------------------------------------------
byte_1CA68:	dc.b 0
	dc.b 3
	dc.b 4
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0
	dc.b 0			; as code, these are some useless or.b commands.
				; it is	used as	data, however the program runs through it at the same time
; ---------------------------------------------------------------------------
	move.w	#$5580,d0
	lea	ArtComp_1DD5C(pc),a0
	jsr	(j_DecompressToVRAM).l
	bsr.w	sub_1CCAE
	move.w	#$A6C0,d0
	lea	ArtComp_1DC8F(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A536,d0
	lea	MapEni_1E264(pc),a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	clr.w	($FFFFFB60).w
	moveq	#$1B,d0
	moveq	#$1F,d1
	bsr.w	sub_1CDA8
	bsr.w	sub_1C896
	clr.w	(Camera_X_pos).w
	clr.w	(Camera_Y_pos).w
	move.l	#$2000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#1,$11(a1)
	clr.w	$24(a1)
	move.w	#$2AC,$24(a1)
	move.w	#(LnkTo_unk_E105E-Data_Index),$22(a1)
	move.l	a1,a2
	move.l	#$2000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	st	$16(a1)
	move.b	#1,$11(a1)
	move.w	#$3C4,$24(a1)
	move.w	#(LnkTo_unk_E105E-Data_Index),$22(a1)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1CB2C,4(a0)
	move.l	a2,$26(a0)
	move.l	a1,$2A(a0)
	sf	(PaletteToDMA_Flag).w
	rts
; ---------------------------------------------------------------------------

loc_1CB2C:
	clr.w	(Options_Selected_Option).w
	move.w	#$30,$1A(a0)
	move.w	#$48,$1E(a0)
	move.w	#$110,$1A(a1)
	move.w	#$48,$1E(a1)
	sf	($FFFFFB5C).w
	move.w	#$118,($FFFFFB5E).w
	clr.w	(Camera_Y_pos).w
	moveq	#$1B,d0
	moveq	#$1F,d1
	bsr.w	sub_1CDA8
	moveq	#8,d2
	move.w	#$E0,d3

OptionScreen_IntroLoop:
	bsr.w	sub_1DA24
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d3
	if insertLevelSelect = 0
	beq.w	OptionScreen_Loop
	else
	beq.w	Chk_LevelSelect
	endif
	subq.w	#2,(Camera_Y_pos).w
	subq.w	#2,d3
	subq.w	#2,d2
	bne.w	loc_1CB88
	moveq	#8,d2
	subq.w	#1,d0
	subq.w	#1,d1
	bsr.w	sub_1CDA8

loc_1CB88:
	bsr.w	sub_1CC88
	bclr	#7,(Ctrl_1_Pressed).w
	beq.s	OptionScreen_IntroLoop
	bra.w	Option_Exit
; ---------------------------------------------------------------------------

OptionScreen_Loop:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_1CC88
	movem.l	d0-d3/a0-a3,-(sp)
	bsr.w	DrawOptText1
	bsr.w	DrawOptText2
	bsr.w	DrawOptText3
	bsr.w	DrawOptText4
	movem.l	(sp)+,d0-d3/a0-a3
	bsr.w	OptionScreen_Input
	bclr	#7,(Ctrl_1_Pressed).w
	beq.s	OptionScreen_Loop
; START	OF FUNCTION CHUNK FOR OptionScreen_Input

Option_Exit:
				; OptionScreen_Input+50j ...
	move.w	#$2C,(Game_Mode).w
	st	($FFFFFBCE).w
	jsr	(j_StopMusic).l
	jmp	(j_loc_6E2).w
; END OF FUNCTION CHUNK	FOR OptionScreen_Input

; =============== S U B	R O U T	I N E =======================================


OptionScreen_Input:

; FUNCTION CHUNK AT 0001CBC4 SIZE 00000014 BYTES

	bclr	#Button_Up,(Ctrl_Pressed).w
	beq.w	loc_1CBF2
	tst.w	(Options_Selected_Option).w
	beq.w	loc_1CBF2
	bsr.w	sub_1BC26
	subq.w	#1,(Options_Selected_Option).w

loc_1CBF2:
				; OptionScreen_Input+Ej
	bclr	#Button_Down,(Ctrl_Pressed).w
	beq.w	loc_1CC0E
	cmpi.w	#3,(Options_Selected_Option).w
	beq.w	loc_1CC0E
	bsr.w	sub_1BC26
	addq.w	#1,(Options_Selected_Option).w

loc_1CC0E:
				; OptionScreen_Input+2Aj
	bclr	#Button_Left,(Ctrl_Pressed).w
	beq.w	loc_1CC2A
	move.w	(Options_Selected_Option).w,d7
	add.w	d7,d7
	jmp	loc_1CC22(pc,d7.w)

loc_1CC22:
	bra.s	Option_2PInput
; ---------------------------------------------------------------------------
	bra.s	Option_Controls_Left
; ---------------------------------------------------------------------------
	bra.s	Option_SpeedButton
; ---------------------------------------------------------------------------
	bra.s	Option_Exit
; ---------------------------------------------------------------------------

loc_1CC2A:
	bclr	#Button_Right,(Ctrl_Pressed).w
	beq.w	return_1CC86
	move.w	(Options_Selected_Option).w,d7
	add.w	d7,d7
	jmp	loc_1CC3E(pc,d7.w)

loc_1CC3E:
	bra.s	Option_2PInput
; ---------------------------------------------------------------------------
	bra.s	Option_Controls_Right
; ---------------------------------------------------------------------------
	bra.s	Option_SpeedButton
; ---------------------------------------------------------------------------
	bra.w	Option_Exit
; ---------------------------------------------------------------------------

Option_2PInput:
				; OptionScreen_Input:loc_1CC3Ej
	bsr.w	sub_1BC26
	not.b	(Options_Suboption_2PController).w
	bra.w	return_1CC86
; ---------------------------------------------------------------------------

Option_SpeedButton:
				; OptionScreen_Input+6Aj
	bsr.w	sub_1BC26
	not.b	(Options_Suboption_Speed).w
	bra.w	return_1CC86
; ---------------------------------------------------------------------------

Option_Controls_Left:
	tst.w	(Options_Suboption_Controls).w
	beq.w	return_1CC86
	bsr.w	sub_1BC26
	subq.w	#1,(Options_Suboption_Controls).w
	bra.w	return_1CC86
; ---------------------------------------------------------------------------

Option_Controls_Right:
	cmpi.w	#5,(Options_Suboption_Controls).w
	beq.w	return_1CC86
	bsr.w	sub_1BC26
	addq.w	#1,(Options_Suboption_Controls).w

return_1CC86:
				; OptionScreen_Input+78j ...
	rts
; End of function OptionScreen_Input


; =============== S U B	R O U T	I N E =======================================


sub_1CC88:
	move.l	d7,-(sp)
	move.w	($FFFFFB5E).w,d7
	not.b	($FFFFFB5C).w
	beq.w	loc_1CCA2
	add.w	d7,$24(a0)
	sub.w	d7,$24(a1)
	bra.w	loc_1CCAA
; ---------------------------------------------------------------------------

loc_1CCA2:
	sub.w	d7,$24(a0)
	add.w	d7,$24(a1)

loc_1CCAA:
	move.l	(sp)+,d7
	rts
; End of function sub_1CC88


; =============== S U B	R O U T	I N E =======================================


sub_1CCAE:
	move.w	4(a6),d0
	move.l	#vdpComm($5580,VRAM,READ),4(a6)
	lea	(Level_Layout).w,a0
	move.w	#$45F,d0

loc_1CCC2:
	bsr.w	sub_1CD20
	bsr.w	sub_1CD32
	dbf	d0,loc_1CCC2
	move.l	#vdpComm($7880,VRAM,WRITE),4(a6)
	lea	(Level_Layout).w,a0
	move.w	#$117F,d0

loc_1CCDE:
	move.w	(a0)+,(a6)
	dbf	d0,loc_1CCDE
	move.w	#$100,d0

loc_1CCE8:
	dbf	d0,loc_1CCE8
	move.l	#vdpComm($5580,VRAM,READ),4(a6)
	lea	(Level_Layout).w,a0
	move.w	#$45F,d0

loc_1CCFC:
	bsr.w	sub_1CD32
	bsr.w	sub_1CD20
	dbf	d0,loc_1CCFC
	move.l	#vdpComm($5580,VRAM,WRITE),4(a6)
	lea	(Level_Layout).w,a0
	move.w	#$117F,d0

loc_1CD18:
	move.w	(a0)+,(a6)
	dbf	d0,loc_1CD18
	rts
; End of function sub_1CCAE


; =============== S U B	R O U T	I N E =======================================


sub_1CD20:
	move.w	(a6),d7
	andi.w	#$F0F,d7
	move.w	d7,(a0)+
	move.w	(a6),d7
	andi.w	#$F0F,d7
	move.w	d7,(a0)+
	rts
; End of function sub_1CD20


; =============== S U B	R O U T	I N E =======================================


sub_1CD32:
	move.w	(a6),d7
	andi.w	#$F0F0,d7
	move.w	d7,(a0)+
	move.w	(a6),d7
	andi.w	#$F0F0,d7
	move.w	d7,(a0)+
	rts
; End of function sub_1CD32


; =============== S U B	R O U T	I N E =======================================


sub_1CD44:
	move.w	4(a6),d7
	move.l	#0,4(a6)
	lea	(Decompression_Buffer).l,a4
	move.w	#$7FF,d7

loc_1CD5A:
	move.w	(a6),d6
	bclr	#$F,d6
	move.w	d6,(a4)+
	dbf	d7,loc_1CD5A
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	lea	(Decompression_Buffer).l,a4
	move.w	#$7FF,d7

loc_1CD78:
	move.w	(a4)+,(a6)
	dbf	d7,loc_1CD78
	move.w	#$100,d7

loc_1CD82:
	dbf	d7,loc_1CD82
	rts
; End of function sub_1CD44


; =============== S U B	R O U T	I N E =======================================


sub_1CD88:
	moveq	#$1B,d1
	lea	(Decompression_Buffer).l,a0

loc_1CD90:
	moveq	#$27,d0

loc_1CD92:
	move.w	(a0)+,(a6)
	dbf	d0,loc_1CD92
	moveq	#$17,d0

loc_1CD9A:
	move.w	#$94,(a6)
	dbf	d0,loc_1CD9A
	dbf	d1,loc_1CD90
	rts
; End of function sub_1CD88


; =============== S U B	R O U T	I N E =======================================


sub_1CDA8:
	move.w	d0,d7
	mulu.w	#$50,d7		; size of one line of a	plane on screen
	lea	(Decompression_Buffer).l,a4
	add.w	d7,a4
	move.w	d1,d7
	mulu.w	#$80,d7
	add.w	($FFFFFB60).w,d7
	lsl.l	#2,d7
	lsr.w	#2,d7
	addi.w	#$4000,d7
	swap	d7
	jsr	(j_sub_914).w
	move.l	d7,4(a6)
	moveq	#$27,d7		; one line of a	plane on screen

loc_1CDD4:
	move.w	(a4)+,(a6)
	dbf	d7,loc_1CDD4
	jsr	(j_sub_924).w
	rts
; End of function sub_1CDA8


; =============== S U B	R O U T	I N E =======================================


sub_1CDE0:
	moveq	#9,d0
	moveq	#9,d1

loc_1CDE4:
	bsr.w	sub_1DA24
	bsr.w	sub_1CDFA
	addq.w	#1,d0
	bsr.w	sub_1CDFA
	addq.w	#1,d0
	dbf	d1,loc_1CDE4
	rts
; End of function sub_1CDE0


; =============== S U B	R O U T	I N E =======================================


sub_1CDFA:
	move.w	d0,d7
	mulu.w	#$80,d7
	addi.w	#-$2000,d7
	addi.w	#$C,d7
	lsl.l	#2,d7
	lsr.w	#2,d7
	addi.w	#$4000,d7
	swap	d7
	jsr	(j_sub_914).w
	move.l	d7,4(a6)
	moveq	#$1B,d7

loc_1CE1C:
	move.w	#$94,(a6)
	dbf	d7,loc_1CE1C
	jsr	(j_sub_924).w
	rts
; End of function sub_1CDFA

; ---------------------------------------------------------------------------
word_1CE2A:	dc.w 7
				; DrawTextLine_Offsetr
word_1CE2C:	dc.w $A
				; DrawTextLine_Offset+Ar

; =============== S U B	R O U T	I N E =======================================


DrawOptText1:
	moveq	#0,d3
	tst.w	(Options_Selected_Option).w
	bne.w	loc_1CE3A
	moveq	#1,d3

loc_1CE3A:
	moveq	#0,d4
	lea	OptText1(pc),a4
	bsr.w	DrawTextLine_Offset
	moveq	#1,d4
	lea	OptText2(pc),a4
	tst.b	(Options_Suboption_2PController).w
	beq.w	loc_1CE56
	lea	OptText3(pc),a4

loc_1CE56:
	bsr.w	DrawTextLine_Offset
	rts
; End of function DrawOptText1

; ---------------------------------------------------------------------------
OptText1:	dc.b   0
	dc.b   0
	dc.b $5D ; ]
	dc.b $6D ; m
	dc.b $50 ; P
	dc.b $4C ; L
	dc.b $41 ; A
	dc.b $59 ; Y
	dc.b $45 ; E
	dc.b $52 ; R
	dc.b $53 ; S
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0
OptText2:	dc.b  $C
	dc.b   0
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $45 ; E
	dc.b $6D ; m
	dc.b $43 ; C
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $54 ; T
	dc.b $52 ; R
	dc.b $4F ; O
	dc.b $4C ; L
	dc.b $4C ; L
	dc.b $45 ; E
	dc.b $52 ; R
	dc.b $6D ; m
	dc.b   0
OptText3:	dc.b  $C
	dc.b   0
	dc.b $54 ; T
	dc.b $57 ; W
	dc.b $4F ; O
	dc.b $6D ; m
	dc.b $43 ; C
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $54 ; T
	dc.b $52 ; R
	dc.b $4F ; O
	dc.b $4C ; L
	dc.b $4C ; L
	dc.b $45 ; E
	dc.b $52 ; R
	dc.b $53 ; S
	dc.b   0
OptText4:	dc.b   0
	dc.b   3
	dc.b $43 ; C
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $54 ; T
	dc.b $52 ; R
	dc.b $4F ; O
	dc.b $4C ; L
	dc.b $53 ; S
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0
	dc.b   0
	dc.b  $B
	dc.b   3
	dc.b $4D ; M
	dc.b $4F ; O
	dc.b $44 ; D
	dc.b $45 ; E
	dc.b $6D ; m
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


DrawOptText2:
	moveq	#0,d3
	cmpi.w	#1,(Options_Selected_Option).w
	bne.w	loc_1CEB2
	moveq	#1,d3

loc_1CEB2:
	moveq	#0,d4
	lea	OptText4(pc),a4
	bsr.w	DrawTextLine_Offset
	moveq	#1,d4
	addq.w	#1,a4
	bsr.w	DrawTextLine_Offset
	move.w	#$509,d7
	move.w	#$C000,d6
	tst.b	d3
	beq.w	loc_1CED6
	move.w	#$E000,d6

loc_1CED6:
	add.w	d6,d7
	move.w	(Options_Suboption_Controls).w,d5
	addi.w	#$1B,d5
	add.w	d7,d5
	move.w	d5,(a6)
	move.w	word_1CE2C(pc),d1
	addq.w	#5,d1
	move.w	(Options_Suboption_Controls).w,d5
	add.w	d5,d5
	add.w	d5,d5
	lea	unk_1CF28(pc,d5.w),a3
	moveq	#2,d2

loc_1CEF8:
	move.b	(a3)+,d5
	ext.w	d5
	lea	OptText5(pc,d5.w),a4
	move.w	word_1CE2A(pc),d6
	addi.w	#9,d6
	move.w	d1,d7
	bsr.w	DrawTextLine
	addq.w	#2,d1
	dbf	d2,loc_1CEF8
	moveq	#0,d4
	lea	OptText6(pc),a4
	bsr.w	DrawTextLine_Offset
	bsr.w	DrawTextLine_Offset
	bsr.w	DrawTextLine_Offset
	rts
; End of function DrawOptText2

; ---------------------------------------------------------------------------
unk_1CF28:	dc.b   0
	dc.b   8
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   8
	dc.b $10
	dc.b   0
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $10
	dc.b   8
	dc.b   0
	dc.b   0
OptText5:	dc.b $53 ; S
	dc.b $50 ; P
	dc.b $45 ; E
	dc.b $45 ; E
	dc.b $44 ; D
	dc.b $6D ; m
	dc.b $6D ; m
	dc.b   0
	dc.b $4A ; J
	dc.b $55 ; U
	dc.b $4D ; M
	dc.b $50 ; P
	dc.b $6D ; m
	dc.b $6D ; m
	dc.b $6D ; m
	dc.b   0
	dc.b $53 ; S
	dc.b $50 ; P
	dc.b $45 ; E
	dc.b $43 ; C
	dc.b $49 ; I
	dc.b $41 ; A
	dc.b $4C ; L
	dc.b   0
OptText6:	dc.b   5
	dc.b   5
	dc.b $41 ; A
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0
	dc.b   5
	dc.b   7
	dc.b $42 ; B
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0
	dc.b   5
	dc.b   9
	dc.b $43 ; C
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


DrawOptText3:
	moveq	#0,d3
	cmpi.w	#2,(Options_Selected_Option).w
	bne.w	loc_1CF78
	moveq	#1,d3

loc_1CF78:
	moveq	#0,d4
	lea	OptText7(pc),a4
	bsr.w	DrawTextLine_Offset
	moveq	#1,d4
	lea	OptText8(pc),a4
	tst.b	(Options_Suboption_Speed).w
	beq.w	loc_1CF94
	lea	OptText9(pc),a4

loc_1CF94:
	bsr.w	DrawTextLine_Offset
	bsr.w	DrawTextLine_Offset
	rts
; End of function DrawOptText3

; ---------------------------------------------------------------------------
OptText7:	dc.b   0
	dc.b  $C
	dc.b $53 ; S
	dc.b $50 ; P
	dc.b $45 ; E
	dc.b $45 ; E
	dc.b $44 ; D
	dc.b $6D ; m
	dc.b $42 ; B
	dc.b $55 ; U
	dc.b $54 ; T
	dc.b $54 ; T
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b $6D ; m
	dc.b   0
OptText8:	dc.b  $E
	dc.b  $C
	dc.b $4E ; N
	dc.b $4F ; O
	dc.b $52 ; R
	dc.b $4D ; M
	dc.b $41 ; A
	dc.b $4C ; L
	dc.b $6D ; m
	dc.b $41 ; A
	dc.b $43 ; C
	dc.b $54 ; T
	dc.b $49 ; I
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b   0
	dc.b  $E
	dc.b  $E
	dc.b $50 ; P
	dc.b $55 ; U
	dc.b $53 ; S
	dc.b $48 ; H
	dc.b $6D ; m
	dc.b $46 ; F
	dc.b $4F ; O
	dc.b $52 ; R
	dc.b $6D ; m
	dc.b $46 ; F
	dc.b $41 ; A
	dc.b $53 ; S
	dc.b $54 ; T
	dc.b   0
OptText9:	dc.b  $E
	dc.b  $C
	dc.b $46 ; F
	dc.b $41 ; A
	dc.b $53 ; S
	dc.b $54 ; T
	dc.b $6D ; m
	dc.b $41 ; A
	dc.b $43 ; C
	dc.b $54 ; T
	dc.b $49 ; I
	dc.b $4F ; O
	dc.b $4E ; N
	dc.b $6D ; m
	dc.b $6D ; m
	dc.b   0
	dc.b  $E
	dc.b  $E
	dc.b $50 ; P
	dc.b $55 ; U
	dc.b $53 ; S
	dc.b $48 ; H
	dc.b $6D ; m
	dc.b $46 ; F
	dc.b $4F ; O
	dc.b $52 ; R
	dc.b $6D ; m
	dc.b $53 ; S
	dc.b $4C ; L
	dc.b $4F ; O
	dc.b $57 ; W
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


DrawOptText4:
	moveq	#0,d3
	cmpi.w	#3,(Options_Selected_Option).w
	bne.w	loc_1CFFE
	moveq	#1,d3

loc_1CFFE:
	moveq	#0,d4
	lea	OptText10(pc),a4
	bsr.w	DrawTextLine_Offset
	rts
; End of function DrawOptText4

; ---------------------------------------------------------------------------
OptText10:	dc.b   0
	dc.b $11
	dc.b $45 ; E
	dc.b $58 ; X
	dc.b $49 ; I
	dc.b $54 ; T
	dc.b $6D ; m
	dc.b $5B ; [
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


DrawTextLine_Offset:
				; DrawOptText1:loc_1CE56p ...
	move.w	word_1CE2A(pc),d6
	moveq	#0,d5		; 7 - d6
	move.b	(a4)+,d5	; x_pos	of text
	add.w	d5,d6
	move.w	word_1CE2C(pc),d7 ; A - d7
	moveq	#0,d5
	move.b	(a4)+,d5	; y_pos	of text
	add.w	d5,d7
	bsr.w	DrawTextLine
	rts
; End of function DrawTextLine_Offset


; =============== S U B	R O U T	I N E =======================================


DrawTextLine:
				; DrawTextLine_Offset+14p
	move.w	d7,d5
	mulu.w	#$80,d5
	add.w	d6,d5
	add.w	d6,d5
	asl.l	#2,d5
	lsr.w	#2,d5
	addi.w	#$4000,d5
	swap	d5
	move.w	#$4DC,d7
	tst.b	d4
	beq.w	loc_1D050
	move.w	#$509,d7

loc_1D050:
	move.w	#$C000,d6
	tst.b	d3		; set palette line
	beq.w	loc_1D05E
	move.w	#$E000,d6

loc_1D05E:
	add.w	d6,d7
	jsr	(j_sub_914).w
	move.l	d5,4(a6)

loc_1D068:
	moveq	#0,d5
	move.b	(a4)+,d5	; next letter
	beq.w	loc_1D07A
	subi.w	#$41,d5
	add.w	d7,d5
	move.w	d5,(a6)		; put onto plane
	bra.s	loc_1D068
; ---------------------------------------------------------------------------

loc_1D07A:
	jsr	(j_sub_924).w
	rts			; end of text
; End of function DrawTextLine


; =============== S U B	R O U T	I N E =======================================


sub_1D080:
	moveq	#0,d6
	moveq	#0,d5
	move.b	(a4)+,d6
	move.b	(a4)+,d5
	addi.w	#9,d5
	mulu.w	#$80,d5
	add.w	d6,d5
	add.w	d6,d5
	addi.w	#-$2000,d5
	asl.l	#2,d5
	lsr.w	#2,d5
	addi.w	#$4000,d5
	swap	d5

loc_1D0A2:
	move.l	d5,4(a6)
	moveq	#0,d7
	move.b	(a4)+,d7
	beq.w	return_1D0EA
	subi.w	#$41,d7
	addi.w	#-$1B24,d7
	jsr	(j_sub_914).w
	move.w	d7,(a6)
	jsr	(j_sub_924).w
	moveq	#2,d6

loc_1D0C2:
	bsr.w	sub_1DA24
	bsr.w	sub_1CC88
	movem.l	d0-a5,-(sp)
	jsr	(j_Make_SpritesFromGfxObjects).w
	jsr	(j_WaitForVint).w
	jsr	(j_Transfer_SpriteAndKidToVRAM).w
	movem.l	(sp)+,d0-a5
	dbf	d6,loc_1D0C2
	addi.l	#$20000,d5
	bra.s	loc_1D0A2
; ---------------------------------------------------------------------------

return_1D0EA:
	rts
; End of function sub_1D080


; =============== S U B	R O U T	I N E =======================================


sub_1D0EC:
	move.w	#$1780,d0
	move.l	(Addr_HoloBG).w,a0
	lea	unk_1D118(pc),a3
	jsr	(j_DecompressToRAM).l
	move.w	#$80BC,d0
	move.l	(Addr_HoloBG).w,a0
	add.w	(off_718A).w,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	rts
; End of function sub_1D0EC

; ---------------------------------------------------------------------------
unk_1D118:	dc.b   8
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b  $E
	dc.b  $F
; ---------------------------------------------------------------------------

Load_EndSequence:
	clr.w	(Camera_X_pos).w
	clr.w	(Camera_Y_pos).w
	bsr.w	sub_1DA24
	bsr.w	sub_1DA72
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	bsr.w	sub_1DA62
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1DA62
	bsr.s	sub_1D0EC
	move.l	#vdpComm($0000,VRAM,WRITE),4(a6)
	bsr.w	sub_1CD88
	move.w	#$27C0,d0
	lea	byte_1FC20(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$5220,d0
	lea	byte_23E77(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$5B80,d0
	lea	byte_24CD0(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$7BA0,d0
	lea	(byte_2D51B).l,a0
	jsr	(j_DecompressToVRAM).l
	moveq	#0,d1
	bsr.w	sub_1C820
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_1D1B0,4(a0)
	rts
; ---------------------------------------------------------------------------

loc_1D1B0:
	lea	unk_1D91C(pc),a2

loc_1D1B4:
	moveq	#0,d1
	moveq	#0,d0
	move.b	(a2)+,d1
	bmi.w	loc_1D1CE
	move.b	(a2)+,d0
	bsr.w	sub_1D944

loc_1D1C4:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_1D1C4
	bra.s	loc_1D1B4
; ---------------------------------------------------------------------------

loc_1D1CE:
	moveq	#1,d1
	bsr.w	sub_1C820
	moveq	#$14,d0

loc_1D1D6:
	moveq	#1,d4
	bsr.w	sub_1D86C
	moveq	#1,d1

loc_1D1DE:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_1D1DE
	dbf	d0,loc_1D1D6
	moveq	#$5A,d0

loc_1D1EC:
	moveq	#1,d4
	bsr.w	sub_1D86C
	bsr.w	sub_1D846
	bsr.w	sub_1DA24
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1D1EC
	moveq	#4,d0
	bsr.w	sub_1D944
	move.w	#$8005,d0
	bsr.w	sub_1D944
	clr.w	(Camera_X_pos).w
	clr.w	(Camera_Y_pos).w
	bsr.w	sub_1DA24
	lea	word_1D83A(pc),a4
	moveq	#2,d0
	move.w	#$1268,d1

loc_1D226:
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1D8B4,4(a0)
	move.w	(a4)+,$44(a0)
	move.w	(a4)+,$46(a0)
	move.w	d1,$48(a0)
	addq.w	#4,d1
	dbf	d0,loc_1D226
	moveq	#$32,d0

loc_1D24A:
	moveq	#0,d4
	bsr.w	sub_1D86C
	moveq	#1,d1

loc_1D252:
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_1D252
	dbf	d0,loc_1D24A
	move.w	#$8006,d0
	bsr.w	sub_1D944
	move.w	#$78,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#7,d0

loc_1D270:
	moveq	#$20,d7
	bsr.w	sub_1C85E
	move.w	#6,-(sp)
	jsr	(j_Hibernate_Object).w
	dbf	d0,loc_1D270
	move.l	#vdpComm($E000,VRAM,WRITE),4(a6)
	bsr.w	sub_1DA62
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#$8238,4(a6)
	move.w	#$8400,4(a6)
	bsr.w	sub_1CD44
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	#$5580,d0
	lea	byte_21B79(pc),a0
	jsr	(j_DecompressToVRAM).l
	bsr.w	sub_1CCAE
	move.w	#$9B80,d0
	lea	ArtComp_1DA86_LettersNumbers(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$A120,d0
	lea	(byte_261D7).l,a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$5220,d0
	lea	ArtComp_1DC8F(pc),a0
	jsr	(j_DecompressToVRAM).l
	move.w	#$8291,d0
	lea	(MapEni_1E264).l,a0
	lea	(Decompression_Buffer).l,a1
	jsr	(j_EniDec).l
	lea	(Palette_Buffer+$E).l,a1
	lea	Pal_1C92A(pc),a0
	moveq	#8,d0

loc_1D306:
	move.w	(a0)+,(a1)+
	dbf	d0,loc_1D306
	move.l	#$2000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$13(a1)
	move.b	#0,$10(a1)
	move.b	#0,$11(a1)
	clr.w	$24(a1)
	move.w	#(LnkTo_unk_E10CE-Data_Index),$22(a1)
	move.w	#$2AC,$24(a1)
	move.l	a1,a0
	move.l	#$2000000,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	st	$16(a1)
	st	$13(a1)
	move.b	#0,$10(a1)
	move.b	#0,$11(a1)
	clr.w	$24(a1)
	move.w	#(LnkTo_unk_E10CE-Data_Index),$22(a1)
	move.w	#$3C4,$24(a1)
	move.w	#$30,$1A(a0)
	move.w	#$48,$1E(a0)
	move.w	#$110,$1A(a1)
	move.w	#$48,$1E(a1)
	move.w	#$E000,($FFFFFB60).w
	clr.w	(Camera_Y_pos).w
	moveq	#$1B,d0
	moveq	#$1F,d1
	bsr.w	sub_1CDA8
	moveq	#8,d2
	move.w	#$E0,d3
	sf	($FFFFFB5C).w
	move.w	#$118,($FFFFFB5E).w

loc_1D3A0:
	bsr.w	sub_1DA24
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d3
	beq.w	loc_1D3CA
	subq.w	#2,(Camera_Y_pos).w
	subq.w	#2,d3
	subq.w	#2,d2
	bne.w	loc_1D3C4
	moveq	#8,d2
	subq.w	#1,d0
	subq.w	#1,d1
	bsr.w	sub_1CDA8

loc_1D3C4:
	bsr.w	sub_1CC88
	bra.s	loc_1D3A0
; ---------------------------------------------------------------------------

loc_1D3CA:
	moveq	#5,d0
	lea	($FFFFFB72).w,a4

loc_1D3D0:
	move.l	a1,-(sp)
	bsr.w	sub_1D786
	move.w	d0,d7
	lsl.w	#2,d7
	move.l	a1,(a4,d7.w)
	move.l	(sp)+,a1
	dbf	d0,loc_1D3D0
	lea	unk_1D75A(pc),a4
	move.l	a4,(Addr_PlatformLayout).w
	lea	EndText1(pc),a2

loc_1D3F0:
	move.w	(a2),d7
	beq.w	loc_1D44C
	bmi.w	loc_1D404
	move.l	a2,a4
	bsr.w	sub_1D080
	move.l	a4,a2
	bra.s	loc_1D3F0
; ---------------------------------------------------------------------------

loc_1D404:
	neg.w	d7
	subq.w	#1,d7
	add.w	d7,d7
	jmp	loc_1D40E(pc,d7.w)

loc_1D40E:
	bra.s	loc_1D412
; ---------------------------------------------------------------------------
	nop

loc_1D412:
	addq.w	#2,a2
	move.w	#$C8,d0

loc_1D418:
	bsr.w	sub_1D830
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1D418
	bsr.w	sub_1D7E6
	bsr.w	sub_1D800
	bsr.w	sub_1CDE0
	move.l	#$EEE0EC0,(Palette_Buffer+$62).l
	jsr	(j_Palette_to_VRAM).w
	move.l	(Addr_PlatformLayout).w,a4
	bsr.w	sub_1D7A8
	move.l	a4,(Addr_PlatformLayout).w
	bra.s	loc_1D3F0
; ---------------------------------------------------------------------------

loc_1D44C:
	move.w	#$190,d0

loc_1D450:
	bsr.w	sub_1D830
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d0,loc_1D450
	moveq	#$3F,d0
	lea	(Palette_Buffer).l,a0

loc_1D464:
	clr.w	(a0)+
	dbf	d0,loc_1D464
	jsr	(j_WaitForVint).w
	jsr	(j_Do_Nothing).w
	jsr	(j_Palette_to_VRAM).w
	st	($FFFFFBCE).w
	clr.w	($FFFFFBCC).w
	clr.w	(Game_Mode).w
	clr.w	(Number_Lives).w
	move.l	(off_7192).w,a0
	jmp	(a0)
; ---------------------------------------------------------------------------
EndText1:	dc.b  $B
	dc.b   2
	dc.b "CONGRATULATIONSmiii", 0
	dc.b  $B
	dc.b   4
	dc.b "YOUmHAVEmFREEDmTHEM", 0
	dc.b  $B
	dc.b   6
	dc.b "FROMmTHEmEVILmBOSSf", 0
	dc.b   9
	dc.b   8
	dc.b "YOUmWILLmBEmREMEMBEREDm", 0
	dc.b   8
	dc.b  $A
	dc.b "ASmTHEmFIRSTmHOLOGRAPHICm", 0
	dc.b  $C
	dc.b  $C
	dc.b "GAMEmCHAMPIONmfffmm", 0
	dc.b  $B
	dc.b  $F
	dc.b "THEmKIDmCHAMELEONfm", 0
	dc.b $FF
	dc.b $FF

	dc.b  $D
	dc.b   2
	dc.b "ANDhmNOWmffffmmmm", 0
	dc.b  $B
	dc.b   4
	dc.b "THEmPEOPLEmWHOmGAVE", 0
	dc.b  $A
	dc.b   6
	dc.b "UPmTHEIRmLIVEShmWIVES", 0
	dc.b   9
	dc.b   8
	dc.b "ANDmSANITYmTOmMAKEmTHIS", 0
	dc.b  $B
	dc.b  $A
	dc.b "GAMEmAmREALITYmfffmmm", 0
	dc.b   9
	dc.b  $C
	dc.b "mmmmm", 0
	dc.b  $C
	dc.b  $D
	dc.b "THEmSEGAmTECHNICALm", 0
	dc.b  $C
	dc.b  $F
	dc.b "mINSTITUTEmTEAMmimm", 0
	dc.b $FF
	dc.b $FF

	dc.b  $D
	dc.b   0
	dc.b "ffmGAMEmDESIGNmff", 0
	dc.b   8
	dc.b  $A
	dc.b "HOYTmNGmm", 0
	dc.b $15
	dc.b $11
	dc.b "BILLmDUNN", 0
	dc.b $13
	dc.b   8
	dc.b "RICKmMACARAEG", 0
	dc.b   8
	dc.b $13
	dc.b "mGRAEMEmBAYLESS", 0
	dc.b $FF
	dc.b $FF

	dc.b  $C
	dc.b   0
	dc.b "fffmSOFTWAREmfffm", 0
	dc.b   7
	dc.b   9
	dc.b "BCfTCHIUmLE", 0
	dc.b $17
	dc.b $12
	dc.b "MARKmCERNYm", 0
	dc.b $16
	dc.b   9
	dc.b "STEVEmWOITA", 0
	dc.b   7
	dc.b $12
	dc.b "BILLmWILLIS", 0
	dc.b $FF
	dc.b $FF

	dc.b  $F
	dc.b   0
	dc.b "fffmARTmfff", 0
	dc.b $13
	dc.b   8
	dc.b "mALANmACKERMANm", 0
	dc.b   7
	dc.b $12
	dc.b "BRENDAmROSS", 0
	dc.b   7
	dc.b   8
	dc.b "CRAIGmSTITT", 0
	dc.b $16
	dc.b $12
	dc.b "mmPAULmMICA", 0
	dc.b  $E
	dc.b  $F
	dc.b "JUDYmTOTOYA", 0
	dc.b $FF
	dc.b $FF

	dc.b  $A
	dc.b   2
	dc.b "SOUNDmBYm", 0
	dc.b  $A
	dc.b   4
	dc.b "NUmROMANTICmPRODUCTIONS", 0
	dc.b  $A
	dc.b  $A
	dc.b "SPECIALmTHANKSmTOmfff", 0
	dc.b  $C
	dc.b  $C
	dc.b "SCOTTmCHANDLERm", 0
	dc.b  $C
	dc.b  $E
	dc.b "HUGHmBOWENm", 0
	dc.b  $C
	dc.b $10
	dc.b "HAVENmCARTERm", 0
	dc.b  $C
	dc.b $12
	dc.b "ANDmTHEmTESTmGROUPm", 0
	dc.b   0
	dc.b   0
unk_1D75A:	dc.b   0
	dc.b $1E
	dc.b $30 ; 0
	dc.b $20
	dc.b $8A ; �
	dc.b $22 ; "
	dc.b   4
	dc.b $30 ; 0
	dc.b $78 ; x
	dc.b $30 ; 0
	dc.b $8C ; �
	dc.b $67 ; g
	dc.b   8
	dc.b   0
	dc.b $1E
	dc.b $2B ; +
	dc.b $2C ; ,
	dc.b $91 ; �
	dc.b $2B ; +
	dc.b $14
	dc.b $1E
	dc.b $6F ; o
	dc.b $18
	dc.b $91 ; �
	dc.b $6F ; o
	dc.b $24 ; $
	dc.b   0
	dc.b $26 ; &
	dc.b $23 ; #
	dc.b  $C
	dc.b $91 ; �
	dc.b $23 ; #
	dc.b   0
	dc.b $1E
	dc.b $6F ; o
	dc.b $10
	dc.b $A0 ; �
	dc.b $6F ; o
	dc.b $34 ; 4
	dc.b $66 ; f
	dc.b $56 ; V
	dc.b $28 ; (
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_1D786:
	move.l	#$3000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	sf	$13(a1)
	move.w	#$509,$24(a1)
	move.b	#2,$11(a1)
	move.b	#1,$10(a1)
	rts
; End of function sub_1D786


; =============== S U B	R O U T	I N E =======================================


sub_1D7A8:
	movem.l	a2-a3,-(sp)
	lea	($FFFFFB76).w,a2

loc_1D7B0:
	moveq	#0,d7
	move.b	(a4)+,d7
	beq.w	loc_1D7E0
	move.l	(a2)+,a3
	addi.w	#$32,d7
	move.w	d7,x_pos(a3)
	moveq	#0,d7
	move.b	(a4)+,d7
	addi.w	#-$A0,d7
	move.w	d7,y_pos(a3)
	moveq	#0,d7
	move.b	(a4)+,d7
	addi.w	#LnkTo_unk_E1106-Data_Index,d7
	move.w	d7,addroffset_sprite(a3)
	st	$13(a3)
	bra.s	loc_1D7B0
; ---------------------------------------------------------------------------

loc_1D7E0:
	movem.l	(sp)+,a2-a3
	rts
; End of function sub_1D7A8


; =============== S U B	R O U T	I N E =======================================


sub_1D7E6:
	movem.l	d7/a3-a4,-(sp)
	lea	($FFFFFB72).w,a4
	moveq	#5,d7

loc_1D7F0:
	move.l	(a4)+,a3
	sf	$13(a3)
	dbf	d7,loc_1D7F0
	movem.l	(sp)+,d7/a3-a4
	rts
; End of function sub_1D7E6


; =============== S U B	R O U T	I N E =======================================


sub_1D800:
	move.l	(sp)+,$44(a5)
	movem.l	d0-d1/d7/a4,$48(a5)
	moveq	#7,d0

loc_1D80C:
	moveq	#$60,d7
	bsr.w	sub_1C85E
	moveq	#3,d1

loc_1D814:
	bsr.w	sub_1D830
	jsr	(j_Hibernate_Object_1Frame).w
	dbf	d1,loc_1D814
	dbf	d0,loc_1D80C
	movem.l	$48(a5),d0-d1/d7/a4
	move.l	$44(a5),-(sp)
	rts
; End of function sub_1D800


; =============== S U B	R O U T	I N E =======================================


sub_1D830:
	bsr.w	sub_1DA24
	bsr.w	sub_1CC88
	rts
; End of function sub_1D830

; ---------------------------------------------------------------------------
word_1D83A:	dc.w   $AF
	dc.w   $64
	dc.w   $99
	dc.w   $7F
	dc.w   $8C
	dc.w   $5A

; =============== S U B	R O U T	I N E =======================================


sub_1D846:
	jsr	(j_Get_RandomNumber_byte).w
	move.b	(V_Int_counter).w,d5
	bclr	#7,d5
	eor.b	d5,d7
	ext.w	d7
	asr.w	#5,d7
	move.w	d7,(Camera_X_pos).w
	jsr	(j_Get_RandomNumber_byte).w
	eor.b	d5,d7
	ext.w	d7
	asr.w	#5,d7
	move.w	d7,(Camera_Y_pos).w
	rts
; End of function sub_1D846


; =============== S U B	R O U T	I N E =======================================


sub_1D86C:
	jsr	(j_Get_RandomNumber_byte).w
	move.b	(V_Int_counter).w,d5
	bclr	#7,d5
	eor.b	d5,d7
	ext.w	d7
	asr.w	#1,d7
	move.w	d7,d6
	jsr	(j_Get_RandomNumber_byte).w
	eor.b	d5,d7
	ext.w	d7
	asr.w	#1,d7
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_1D9D6,4(a0)
	move.w	#$A0,$44(a0)
	add.w	d6,$44(a0)
	move.w	#$70,$46(a0)
	add.w	d7,$46(a0)
	move.b	d4,$48(a0)
	rts
; End of function sub_1D86C


; =============== S U B	R O U T	I N E =======================================


sub_1D8B4:
	move.l	#$1000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.b	#2,palette_line(a3)
	move.w	#$3DD,vram_tile(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.w	$48(a5),addroffset_sprite(a3)
	jsr	(j_Get_RandomNumber_byte).w
	move.b	(V_Int_counter).w,d0
	eor.b	d0,d7
	andi.w	#$FF,d7
	lsr.w	#1,d7
	move.w	d7,-(sp)
	jsr	(j_Hibernate_Object).w
	moveq	#$78,d0
	moveq	#0,d1

loc_1D8FA:
	jsr	(j_Hibernate_Object_1Frame).w
	add.l	d1,y_pos(a3)
	addi.l	#$800,d1
	dbf	d0,loc_1D8FA
	jmp	(j_Delete_CurrentObject).w
; End of function sub_1D8B4

; ---------------------------------------------------------------------------
	if insertLevelSelect = 0
	; unused data
	dc.b $E0
	dc.b $E0 ; �
	dc.b $F0 ; �
	dc.b $E5 ; �
	dc.b $14
	dc.b $D8 ; �
	dc.b $1E
	dc.b $19
	dc.b $22 ; "
	dc.b $2D ; -
	dc.b $E0 ; �
	dc.b $E0 ; �
	else
Chk_LevelSelect:
	tst.b	(LevelSelect_Flag).w
	beq.w	OptionScreen_Loop
	jmp	LevelSelect_Loop
	endif

unk_1D91C:	dc.b $3C ; <
	dc.b   0
	dc.b   6
	dc.b   1
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   1
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   1
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   3
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   3
	dc.b   6
	dc.b   2
	dc.b   1
	dc.b   3
	dc.b $FF
	dc.b $FF
off_1D936:	dc.w unk_2E39A-unk_2E39A 
	dc.w unk_2E436-unk_2E39A
	dc.w unk_2E4D6-unk_2E39A
	dc.w unk_2E582-unk_2E39A
	dc.w unk_2E64A-unk_2E39A
	dc.w unk_2EA26-unk_2E39A
	dc.w unk_2EA5E-unk_2E39A

; =============== S U B	R O U T	I N E =======================================


sub_1D944:
	bclr	#$F,d0
	sne	($FFFFFB5C).w
	bclr	#$E,d0
	sne	($FFFFFB5E).w
	lea	(unk_2E39A).l,a0
	add.w	d0,d0
	add.w	off_1D936(pc,d0.w),a0
	lea	(Decompression_Buffer).l,a1
	move.w	#$813E,d0
	tst.b	($FFFFFB5C).w
	beq.w	loc_1D97E
	tst.b	($FFFFFB5E).w
	bne.w	loc_1D97E
	move.w	#$22DC,d0

loc_1D97E:
	jsr	(j_EniDec).l
	moveq	#$D,d7

loc_1D986:
	bsr.w	sub_1D990
	dbf	d7,loc_1D986
	rts
; End of function sub_1D944


; =============== S U B	R O U T	I N E =======================================


sub_1D990:
	move.w	d7,d5
	mulu.w	#$1C,d5
	lea	(Decompression_Buffer).l,a4
	add.w	d5,a4
	moveq	#7,d5
	add.w	d7,d5
	mulu.w	#$80,d5
	addi.w	#$1A,d5
	tst.b	($FFFFFB5C).w
	beq.w	loc_1D9B6
	addi.w	#-$2000,d5

loc_1D9B6:
	asl.l	#2,d5
	lsr.w	#2,d5
	addi.w	#$4000,d5
	swap	d5
	jsr	(j_sub_914).w
	move.l	d5,4(a6)
	moveq	#$D,d5

loc_1D9CA:
	move.w	(a4)+,(a6)
	dbf	d5,loc_1D9CA
	jsr	(j_sub_924).w
	rts
; End of function sub_1D990


; =============== S U B	R O U T	I N E =======================================


sub_1D9D6:
	move.l	#$2000000,a3
	jsr	(j_Load_GfxObjectSlot).w
	st	$13(a3)
	move.w	#$291,vram_tile(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.b	$48(a5),priority(a3)
	move.l	#stru_1DA0E,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_1D9D6

; ---------------------------------------------------------------------------
stru_1DA0E:
	anim_frame	  1,   3, LnkTo_unk_E10D6-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E10DE-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E10E6-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E10EE-Data_Index
	anim_frame	  1,   3, LnkTo_unk_E10F6-Data_Index
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_1DA24:
	movem.l	d6-d7,-(sp)
	jsr	(j_sub_914).w
	move.w	(Camera_Y_pos).w,d7
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d7,(a6)
	moveq	#0,d7
	move.w	d7,(a6)
	move.l	#vdpComm($1400,VRAM,WRITE),4(a6)
	move.w	(Camera_X_pos).w,d7
	neg.w	d7
	move.w	#$DF,d6

loc_1DA50:
	move.w	d7,(a6)
	move.w	d7,(a6)
	dbf	d6,loc_1DA50
	jsr	(j_sub_924).w
	movem.l	(sp)+,d6-d7
	rts
; End of function sub_1DA24


; =============== S U B	R O U T	I N E =======================================


sub_1DA62:
	move.w	#$7FF,d0
	move.w	#$94,d1

loc_1DA6A:
	move.w	d1,(a6)
	dbf	d0,loc_1DA6A
	rts
; End of function sub_1DA62


; =============== S U B	R O U T	I N E =======================================


sub_1DA72:
	move.l	#vdpComm($1280,VRAM,WRITE),4(a6)
	moveq	#$F,d0
	moveq	#0,d1

loc_1DA7E:
	move.w	d1,(a6)
	dbf	d0,loc_1DA7E
	rts
; End of function sub_1DA72

; ---------------------------------------------------------------------------
; 1DA86
ArtComp_1DA86_LettersNumbers:
	binclude    "scenes/artcomp/Intro_text_letters.bin"
ArtComp_1DC8F:
	binclude    "scenes/artcomp/Drop-down_screen_from_options_and_ending.bin"
ArtComp_1DD5C:
	binclude    "scenes/artcomp/Face_in_option_menu_background.bin"
	align	2
MapEni_1E264:
	binclude    "scenes/mapeni/options_frame.bin"
	align	2
Demo_InputData2:dc.b   0,  0,  0,  0,  0,  0,  0,$40,$40,$40,$48,$48,$48,$48,$48,$58
	dc.b $58,$58,$58,$58,$58,$58,$58,$58,$48,$48,$48,$58,$58,$58,$48,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$58,$58,$50,$50,$50,$50,$40,$40,$40
	dc.b $40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40,$40
	dc.b $40,$40,$40,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,$44,$44
	dc.b $44,$44,$44,$44,$44,$44,$44,$41,$40,$48,$48,$48,$48,$48,$48,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$58,$58
	dc.b $58,$58,$58,$58,$50,$10,$20,$20,$20,  0,  0,$20,$20,$20,  0,  0
	dc.b $20,$20,  0,  0,  0,$20,$20,  0,  0,  0,$20,$20,  0,  0,$20,$20
	dc.b   0,  0,  0,$20,  0,  0,  0,$20,$20,  0,  0,$20,$20,  0,  0,  0
	dc.b $20,$20,  0,  0,$20,$20,$20,  0,  0,$20,$20,$20,  0,  0,$20,$20
	dc.b $20,  0,  0,$20,$20,$20,  0,  0,$20,$20,$20,  0,  0,$20,$20,  0
	dc.b   0,$20,$20,  0,  0,  0,$20,$20,  0,  0,  0,$20,$20,  0,  0,$20
	dc.b $20,$20,  0,  0,$20,$20,  0,  0,$20,$20,$20,  0,  0,  0,$20,  0
	dc.b   0,  0,  0,  0,  0,  0,  8,  8,  8,  8,  8,  8,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8
	dc.b   8,  8,  8,  8,  8,  8,  8,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,$10,$10,  0,  0,  0,  0,$20
	dc.b   0,  0,  0,$20,$20,$20,  0,  0,$20,$20,  0,  0,  0,$20,$20,  4
	dc.b   4,$24,$24,  4,  4,$24,$24,  4,  4,$24,$24,  4,  4,  4,$24,$24
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  8,  8,  8,  8,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8
	dc.b   8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,$48,$48,$48,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$40,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  0
Demo_InputData1:dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88,$88
	dc.b $88,$88,$88,$88,$88,$88,$88,$88,  8,  8,  8,  8,  8,  8,$48,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48
	dc.b $48,$48,$48,$48,$48,$58,$58,$58,$58,$58,$58,$58,$58,$48,$48,$48
	dc.b $48,$48,$40,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  4,  4,  4
	dc.b   4,  4,  4,  4,  4,  4,  4,  4,  4,  4,  0,  0,  0,  0,  0,  0
	dc.b $10,$10,$10,$10,$10,$10,$10,$10,$10,$10, $A, $A, $A, $A, $A,$1A
	dc.b $1A,$1A,$1A,$1A,$1A,$1A,$1A,$1A,  8,  8,  0,  0,  0,  0,  0,  0
	dc.b   0,  0,  8,  8,  8,$18,$18,$18,$18,$18,$18,$18,$18,$18,$10,$10
	dc.b   0,  0,  0,  5,  4,  4,  0,  0,  0,  0,  1,  5,  1,  0,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,  8,  8,  8,  8,  8,  8,  8,  0,  0
	dc.b   0,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5
	dc.b   5,  9,  8,  8,  8,  8,  8,  8,  8,  8,  9,  9,  0,  0,  0,  0
	dc.b   0,  8,$18,$18,$18,$19,$18,$19,$19,$19,$19,$19,$10,$10,$10,$10
	dc.b $10,$14,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15,$15
	dc.b $11,$11,$11,$19,$11,$11,$11,$11,$11,$19,$19,$18,$18,$18,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,$18,$18,  8,  8,  8,$18,$18,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,$19,  4,  4,  4,  4,  4,  4,  5,  9
	dc.b   8,  8,  8,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18
	dc.b $18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,$18,  9
	dc.b   1,  9,  9,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,$48
	dc.b $48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$48,$58
	dc.b $58,$59,$19,$19,  9,  9,  9,$29,  9,  9,  9,$28,$28,$29,$29,  9
	dc.b   9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9,  9
	dc.b   9,  9,  9,  9,  9,  9,$29,$29,$29,$29,$29,$29,$29,  9,  9,$29
	dc.b $29,$29,  9,  9,$29,$29,$29,  9,  9,$29,$29,$29,  9,  9,$29,$29
	dc.b $29,  9,  9,$29,$29,  9,  9,$29,$29,$29,  9,  9,$29,$29,$29,  9
	dc.b   9,$29
byte_1E6E3:  binclude    "scenes/artcomp/Dark_alley_from_intro.bin"
byte_1FC20:  binclude    "scenes/artcomp/Boss_(cutscene)_after_defeat.bin"
byte_20D36:  binclude    "scenes/artcomp/P_block_from_intro.bin"
byte_213D9:  binclude    "scenes/artcomp/Red_Stealth_helmet_from_intro.bin"
byte_216B7:  binclude    "scenes/artcomp/Juggernaut_helmet_from_intro.bin"
byte_219C1:  binclude    "scenes/artcomp/Maniaxe_helmet_from_intro.bin"
byte_21B79:  binclude    "scenes/artcomp/Broken_Glass_plane.bin"
byte_22080:  binclude    "scenes/artcomp/Title_text_CHAMELEON.bin"
byte_23E77:  binclude    "ingame/artcomp/Goo_from_Boss.bin"
byte_243D5:  binclude    "scenes/artcomp/Sky_castle_and_night_sky_from_intro_scene.bin"
byte_24985:  binclude    "scenes/artcomp/Title_text_KID.bin"
byte_24CD0:  binclude    "scenes/artcomp/Computer_behind_grid_walls.bin"
byte_26036:  binclude    "scenes/artcomp/Title_menu.bin"
byte_261D7:  binclude    "scenes/artcomp/Kids_hanging_around_Wild_Side.bin"
byte_26E3D:  binclude    "scenes/artcomp/Red_Stealth_transformation_from_intro.bin"
byte_282C1:  binclude    "scenes/artcomp/Juggernaut_transformation_from_intro.bin"
byte_2927C:  binclude    "scenes/artcomp/Maniaxe_transformation_from_intro.bin"
byte_2A479:  binclude    "scenes/artcomp/Title_sparkles.bin"
ArtUnc_2A4D6:  binclude    "scenes/artunc/Grey_mixed_pixels_during_title_transformation.bin"
byte_2A756:  binclude    "scenes/artcomp/The_kid_transformation_from_intro.bin"
byte_2A961:  binclude    "scenes/artcomp/Background_on_title.bin"
byte_2A992:  binclude    "scenes/artcomp/The_kid_from_intro.bin"
byte_2D51B:  binclude    "scenes/artcomp/Kids_that_get_freed.bin"
byte_2D71A:  binclude    "scenes/artcomp/Background_for_intro_(Wild_Side).bin"
byte_2D73B:  binclude    "scenes/artcomp/Wild_Side_arcade.bin"
byte_2DEBF:  binclude    "scenes/artcomp/Wild_Side_door_and_inside.bin"
	align	2
MapEni_2E154:  binclude    "scenes/mapeni/intro3_alley.bin"
	align	2
unk_2E39A:  binclude    "scenes/mapeni/2E39A.bin"
	align	2
unk_2E436:  binclude    "scenes/mapeni/2E436.bin"
	align	2
unk_2E4D6:  binclude    "scenes/mapeni/2E4D6.bin"
	align	2
unk_2E582:  binclude    "scenes/mapeni/2E582.bin"
	align	2
unk_2E64A:  binclude    "scenes/mapeni/2E64A.bin"

	binclude    "scenes/mapeni/unused_2E6CB.bin"
	align	2
	binclude    "scenes/mapeni/unused_2E6EA.bin"
	align	2
unk_2E706:  binclude    "scenes/mapeni/2E706.bin"
	align	2
unk_2E728:  binclude    "scenes/mapeni/2E728.bin"
	align	2
unk_2E77A:  binclude    "scenes/mapeni/2E77A.bin"
	align	2
unk_2E7C6:  binclude    "scenes/mapeni/intro2_sky.bin"
	align	2
unk_2EA26:  binclude    "scenes/mapeni/2EA26.bin"
	align	2
unk_2EA5E:  binclude    "scenes/mapeni/2EA5E.bin"
	align	2
unk_2EAAE:  binclude    "scenes/mapeni/2EAAE.bin"
	align	2
unk_2EACE:  binclude    "scenes/mapeni/2EACE.bin"
	align	2
unk_2EB32:  binclude    "scenes/mapeni/2EB32.bin"
	align	2
unk_2EBD4:  binclude    "scenes/mapeni/2EBD4.bin"
	align	2
unk_2EC86:  binclude    "scenes/mapeni/2EC86.bin"
	align	2
unk_2ED62:  binclude    "scenes/mapeni/2ED62.bin"
	align	2
unk_2EE54:  binclude    "scenes/mapeni/2EE54.bin"
	align	2
unk_2EF2C:  binclude    "scenes/mapeni/2EF2C.bin"
	align	2
unk_2EF92:  binclude    "scenes/mapeni/2EF92.bin"
	align	2
unk_2EFFE:  binclude    "scenes/mapeni/2EFFE.bin"
	align	2
unk_2F09C:  binclude    "scenes/mapeni/2F09C.bin"
	align	2
unk_2F124:  binclude    "scenes/mapeni/2F124.bin"
	align	2
unk_2F1B0:  binclude    "scenes/mapeni/2F1B0.bin"
	align	2
unk_2F242:  binclude    "scenes/mapeni/2F242.bin"
	align	2
unk_2F2D0:  binclude    "scenes/mapeni/2F2D0.bin"
	align	2
unk_2F306:  binclude    "scenes/mapeni/2F306.bin"
	align	2
unk_2F374:  binclude    "scenes/mapeni/2F374.bin"
	align	2
unk_2F41E:  binclude    "scenes/mapeni/2F41E.bin"
	align	2
unk_2F4D0:  binclude    "scenes/mapeni/2F4D0.bin"
	align	2
unk_2F592:  binclude    "scenes/mapeni/2F592.bin"
	align	2
unk_2F674:  binclude    "scenes/mapeni/2F674.bin"
	align	2
unk_2F76A:  binclude    "scenes/mapeni/2F76A.bin"
	align	2
unk_2F7D0:  binclude    "scenes/mapeni/2F7D0.bin"
	align	2
unk_2F840:  binclude    "scenes/mapeni/2F840.bin"
	align	2
unk_2F856:  binclude    "scenes/mapeni/2F856.bin"
	align	2
unk_2F882:  binclude    "scenes/mapeni/2F882.bin"
	align	2
unk_2F8D2:  binclude    "scenes/mapeni/2F8D2.bin"
	align	2
unk_2F94E:  binclude    "scenes/mapeni/2F94E.bin"
	align	2
unk_2F9DE:  binclude    "scenes/mapeni/2F9DE.bin"
	align	2
unk_2FAA8:  binclude    "scenes/mapeni/2FAA8.bin"
	align	2
unk_2FB76:  binclude    "scenes/mapeni/2FB76.bin"
	align	2
unk_2FC3A:  binclude    "scenes/mapeni/2FC3A.bin"
	align	2
unk_2FCE4:  binclude    "scenes/mapeni/2FCE4.bin"
	align	2
unk_2FDA6:  binclude    "scenes/mapeni/2FDA6.bin"
	align	2
unk_2FDCE:  binclude    "scenes/mapeni/2FDCE.bin"
	align	2
unk_2FDE0:  binclude    "scenes/mapeni/intro1_wildside.bin"
	align	2

	dc.b   0
	dc.b   0

; filler
    rept 128
	dc.b	$FF
    endm

	align	2
; =============== S U B	R O U T	I N E =======================================
;2FFDA
j_loc_2FFE8:
	jmp	loc_2FFE8(pc)
; ---------------------------------------------------------------------------
;2FFDC
j_Transfer_ScrollDataToVRAM:
	jmp	Transfer_ScrollDataToVRAM(pc)
; ---------------------------------------------------------------------------
;2FFE0
j_sub_30194:
	jmp	sub_30194(pc)
; ---------------------------------------------------------------------------
;2FFE4
j_loc_3038A:
	jmp	loc_3038A(pc)
; ---------------------------------------------------------------------------

loc_2FFE8:
	move.w	(Camera_X_pos).w,($FFFFF82C).w
	move.w	(Camera_Y_pos).w,d7
	move.w	(Camera_Y_pos).w,d0
	subi.w	#$E0,d0
	move.w	d0,(Camera_Y_pos).w
	subq.w	#8,d0
	move.w	d0,($FFFFF82E).w
	move.l	d7,-(sp)
	moveq	#$1C,d6
	addi.w	#$E0,d7
	cmp.w	(Level_height_blocks).w,d7
	blt.s	loc_30014
	subq.w	#1,d6

loc_30014:
	move.l	(sp)+,d7

loc_30016:
	movem.l	d6-d7,-(sp)
	bsr.w	sub_30194

loc_3001E:
	movem.l	(sp)+,d6-d7
	addq.w	#8,(Camera_Y_pos).w
	dbf	d6,loc_30016
	move.w	d7,d0
	subi.w	#$380,d0
	move.w	d0,(Camera_Y_pos).w
	subi.w	#$20,d0
	move.w	d0,($FFFFFAA8).w
	move.l	d7,-(sp)
	bsr.w	BackgroundScroll_ComputeShiftData
	move.l	(sp)+,d7
	move.l	d7,-(sp)
	moveq	#$1C,d6
	addi.w	#$E0,d7
	cmp.w	(Level_height_blocks).w,d7
	blt.s	loc_30054
	subq.w	#1,d6

loc_30054:
	move.l	(sp)+,d7
	cmpi.w	#$FC80,(Camera_Y_pos).w
	beq.s	loc_30066
	subi.w	#$40,(Camera_Y_pos).w
	addq.w	#2,d6

loc_30066:
	movem.l	d6-d7,-(sp)
	tst.b	(Background_format).w
	bne.s	loc_30076
	bsr.w	sub_307D8
	bra.s	loc_3007A
; ---------------------------------------------------------------------------

loc_30076:
	bsr.w	sub_303BA

loc_3007A:
	movem.l	(sp)+,d6-d7
	addi.w	#$20,(Camera_Y_pos).w
	dbf	d6,loc_30066
	tst.w	d7
	bne.s	loc_30090
	clr.w	($FFFFFAA8).w

loc_30090:
	move.w	d7,(Camera_Y_pos).w
	move.w	d7,($FFFFF82E).w
	rts
; ---------------------------------------------------------------------------
; DMA scrolling data, plane B address for storm
;loc_3009A
Transfer_ScrollDataToVRAM:
	move.w	(Level_Special_Effects).w,d0
	subq.w	#1,d0
	ble.s	loc_300BA
	cmpi.w	#2,d0
	bgt.w	loc_30158
	subq.b	#1,($FFFFFAD6).w
	beq.s	loc_30110
	move.w	#$8407,4(a6)	; normal background plane address
	jsr	(j_sub_914).w

loc_300BA:
	move.w	(Camera_Y_pos).w,d0
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d0,(a6)
	lsr.w	#2,d0
	tst.b	(Background_NoScrollFlag).w
	beq.s	loc_300D2
	moveq	#0,d0

loc_300D2:
	move.w	d0,(a6)
	jsr	(j_Stop_z80).l
	dma68kToVDP	Horiz_Scroll_Buffer,$1400,$380,VRAM
	jsr	(j_Start_z80).l
	jsr	(j_sub_924).w
	rts
; ---------------------------------------------------------------------------

loc_30110:
	jsr	(j_sub_914).w
	move.w	#$8403,4(a6)	; storm background plane address
	move.l	#vdpComm($1400,VRAM,WRITE),4(a6)
	move.w	#$DF,d1
	move.w	(Camera_X_pos).w,d0
	move.w	($FFFFFAD8).w,d2
	neg.w	d0

loc_30130:
	move.w	d0,(a6)
	move.w	d2,(a6)
	dbf	d1,loc_30130
	move.w	(Camera_Y_pos).w,d0
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d0,(a6)
	move.w	d2,(a6)
	move.b	#4,($FFFFFAD6).w
	subq.w	#8,($FFFFFAD8).w
	jsr	(j_sub_924).w
	rts
; ---------------------------------------------------------------------------

loc_30158:
	jsr	(j_sub_914).w
	move.l	#vdpComm($1400,VRAM,WRITE),4(a6)
	move.w	#$DF,d1
	move.w	(Camera_X_pos).w,d0
	move.w	($FFFFFAD8).w,d2
	neg.w	d0

loc_30172:
	move.w	d2,(a6)
	move.w	d0,(a6)
	dbf	d1,loc_30172
	move.w	(Camera_Y_pos).w,d0

loc_3017E:
	move.l	#vdpComm($0000,VSRAM,WRITE),4(a6)
	move.w	d0,(a6)
	move.w	d0,(a6)
	subq.w	#8,($FFFFFAD8).w
	jsr	(j_sub_924).w
	rts
; End of function j_Transfer_ScrollDataToVRAM


; =============== S U B	R O U T	I N E =======================================


sub_30194:

	move.w	(Camera_X_pos).w,d7
	lsr.w	#3,d7
	move.w	(Camera_Y_pos).w,d5
	asr.w	#3,d5
	lea	($FFFF4A04).l,a0
	move.w	#$FF,d4
	move.w	($FFFFF82E).w,d0
	asr.w	#3,d0
	move.w	d5,d6
	cmp.w	d0,d5
	beq.w	loc_3023C
	move.l	(Addr_ThemeMappings).w,a1
	lea	(Block_Mappings).l,a2
	blt.s	loc_301CE
	addi.w	#$1C,d6
	cmp.w	(Level_height_tiles).w,d6
	bcc.s	loc_3023C

loc_301CE:
	move.w	d6,d0
	lsr.w	#1,d0
	bcc.s	loc_301D8
	addq.w	#4,a1
	addq.w	#4,a2

loc_301D8:
	add.w	d0,d0
	move.w	(a0,d0.w),a3
	move.w	d7,d0
	lsr.w	#1,d0
	add.w	d0,a3
	add.w	d0,a3
	andi.w	#$1F,d0
	cmpi.w	#$C,d0
	bcc.s	loc_301F6
	moveq	#$14,d1
	moveq	#-1,d2
	bra.s	loc_301FE
; ---------------------------------------------------------------------------

loc_301F6:
	moveq	#$1F,d1
	sub.w	d0,d1
	moveq	#$13,d2
	sub.w	d1,d2

loc_301FE:
	move.w	d6,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	add.w	d0,d0
	add.w	d0,d0
	add.w	d3,d0
	ori.w	#$4000,d0
	swap	d0
	move.w	#0,d0
	move.w	d7,-(sp)
	move.l	d0,4(a6)
	move.l	d0,-(sp)
	swap	d2
	bsr.w	sub_3034A
	swap	d2
	move.l	(sp)+,d0
	move.w	d2,d1
	bmi.s	loc_3023A
	andi.l	#$FF80FFFF,d0
	move.l	d0,4(a6)
	bsr.w	sub_3034A

loc_3023A:
	move.w	(sp)+,d7

loc_3023C:
	move.w	($FFFFF82C).w,d0
	lsr.w	#3,d0
	move.w	d7,d6
	cmp.w	d0,d7
	beq.w	loc_302E8
	move.l	(Addr_ThemeMappings).w,a1
	lea	(Block_Mappings).l,a2
	blt.s	loc_30262
	addi.w	#$28,d6
	cmp.w	(Level_width_tiles).w,d6
	bcc.w	loc_302E8

loc_30262:
	move.w	d6,d0
	lsr.w	#1,d0
	bcc.s	loc_3026C
	addq.w	#2,a1
	addq.w	#2,a2

loc_3026C:
	move.w	d5,d1
	andi.w	#$FFFE,d1
	move.w	(a0,d1.w),a3
	add.w	d0,a3
	add.w	d0,a3
	move.w	d5,d0
	lsr.w	#1,d0
	andi.w	#$F,d0
	cmpi.w	#2,d0
	bcc.s	loc_3028E
	moveq	#$E,d1
	moveq	#-1,d2
	bra.s	loc_30296
; ---------------------------------------------------------------------------

loc_3028E:
	moveq	#$F,d1
	sub.w	d0,d1
	moveq	#$D,d2
	sub.w	d1,d2

loc_30296:
	move.w	d5,d3
	andi.w	#$FFFE,d3
	andi.w	#$1F,d3
	lsl.w	#7,d3
	move.w	d6,d0
	andi.w	#$3F,d0
	add.w	d0,d0
	add.w	d3,d0
	ori.w	#$4000,d0
	swap	d0
	move.w	#0,d0
	move.w	#$8F80,4(a6)
	move.l	d0,4(a6)
	move.w	(Level_width_tiles).w,a4
	move.l	d0,-(sp)
	swap	d2
	bsr.w	sub_302F6
	swap	d2
	move.l	(sp)+,d0
	move.w	d2,d1
	bmi.s	loc_302E2
	andi.l	#$F07EFFFF,d0
	move.l	d0,4(a6)
	bsr.w	sub_302F6

loc_302E2:
	move.w	#$8F02,4(a6)

loc_302E8:
	move.w	(Camera_X_pos).w,($FFFFF82C).w
	move.w	(Camera_Y_pos).w,($FFFFF82E).w
	rts
; End of function sub_30194


; =============== S U B	R O U T	I N E =======================================


sub_302F6:
	move.w	#8,d2
	move.w	#$8000,d7

loc_302FE:
	move.w	(a3),d3
	bmi.s	loc_30336
	btst	d2,d3
	bne.s	loc_3031A
	and.w	d4,d3
	lsl.w	#3,d3
	move.w	(a1,d3.w),(a6)
	move.w	4(a1,d3.w),(a6)
	add.w	a4,a3
	dbf	d1,loc_302FE
	rts
; ---------------------------------------------------------------------------

loc_3031A:
	and.w	d4,d3
	lsl.w	#3,d3
	move.w	(a1,d3.w),d0
	or.w	d7,d0
	move.w	d0,(a6)
	move.w	4(a1,d3.w),d0
	or.w	d7,d0
	move.w	d0,(a6)
	add.w	a4,a3
	dbf	d1,loc_302FE
	rts
; ---------------------------------------------------------------------------

loc_30336:
	and.w	d4,d3
	lsl.w	#3,d3
	move.w	(a2,d3.w),(a6)
	move.w	4(a2,d3.w),(a6)
	add.w	a4,a3
	dbf	d1,loc_302FE
	rts
; End of function sub_302F6


; =============== S U B	R O U T	I N E =======================================


sub_3034A:
	move.w	#8,d2
	move.l	#$80008000,d7

loc_30354:
	move.w	(a3)+,d3
	bmi.s	loc_3037C
	btst	d2,d3
	bne.s	loc_3036A
	and.w	d4,d3
	lsl.w	#3,d3
	move.l	(a1,d3.w),(a6)
	dbf	d1,loc_30354
	rts
; ---------------------------------------------------------------------------

loc_3036A:
	and.w	d4,d3
	lsl.w	#3,d3
	move.l	(a1,d3.w),d0
	or.l	d7,d0
	move.l	d0,(a6)
	dbf	d1,loc_30354
	rts
; ---------------------------------------------------------------------------

loc_3037C:
	and.w	d4,d3
	lsl.w	#3,d3
	move.l	(a2,d3.w),(a6)
	dbf	d1,loc_30354
	rts
; End of function sub_3034A

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR j_Transfer_ScrollDataToVRAM

loc_3038A:
	cmpi.w	#4,(Level_Special_Effects).w
	beq.s	return_303B8
	move.w	(Game_Mode).w,d0
	beq.s	loc_3039C
	addq.w	#1,(Time_Frames).w

loc_3039C:
	bsr.w	BackgroundScroll_ComputeShiftData
	bsr.w	BackgroundScroll_ComputeShiftLayers
	tst.b	($FFFFFB49).w
	bne.s	return_303B8
	tst.b	(Background_format).w
	bne.s	sub_303BA
	bsr.w	sub_30744
	bsr.w	sub_307D8

return_303B8:
	rts
; END OF FUNCTION CHUNK	FOR j_Transfer_ScrollDataToVRAM

; =============== S U B	R O U T	I N E =======================================


sub_303BA:
	move.w	(Camera_Y_pos).w,d0
	asr.w	#5,d0
	move.w	($FFFFFAA8).w,d1
	move.w	d0,($FFFFFAA8).w
	cmp.w	d0,d1
	beq.w	return_3043A
	bgt.s	loc_303D4
	addi.w	#$1C,d0

loc_303D4:
	move.w	4(a0),d3
	move.l	(Addr_MapHeader).w,a0
	move.l	$14(a0),a0
	cmpi.w	#Desert,(Background_theme).w
	bne.s	loc_303EA
	addq.w	#1,a0

loc_303EA:
	moveq	#0,d1
	move.b	1(a0,d0.w),d1
	move.w	d1,d2
	lsl.w	#6,d1
	andi.w	#$1F,d0
	lsl.w	#7,d0
	ori.w	#$6000,d0
	move.w	d0,4(a6)
	move.w	#3,4(a6)
	cmpi.w	#$1C,d2
	bge.s	loc_3041C
	lea	($FFFF87B2).w,a0
	lea	(a0,d1.w),a0
	lea	$700(a0),a1
	bra.s	loc_30426
; ---------------------------------------------------------------------------

loc_3041C:
	lea	($FFFF8EB2).w,a0
	lea	(a0,d1.w),a0
	move.l	a0,a1

loc_30426:
	moveq	#7,d0

loc_30428:
	move.l	(a0)+,(a6)
	move.l	(a0)+,(a6)
	dbf	d0,loc_30428
	moveq	#7,d0

loc_30432:
	move.l	(a1)+,(a6)
	move.l	(a1)+,(a6)
	dbf	d0,loc_30432

return_3043A:
	rts
; End of function sub_303BA


; =============== S U B	R O U T	I N E =======================================


BackgroundScroll_ComputeShiftData:
	lea	(Horiz_Scroll_Data).l,a0
	move.w	(Background_width).w,d6
	move.w	(Camera_X_pos).w,d4
	move.w	(Time_Frames).w,d0
	add.w	d0,d0
	moveq	#1,d3

loc_30452:
	move.w	4(a0),d2
	lsr.w	#1,d0
	move.w	d0,a5
	move.w	d4,d1
	lsr.w	#3,d1
	add.w	d1,d0
	move.w	d0,4(a0)
	move.w	d2,6(a0)
	lsr.w	#3,d2
	lsr.w	#3,d0
	cmp.w	d0,d2
	beq.s	loc_30476
	bsr.w	sub_304B4
	bra.s	loc_3047A
; ---------------------------------------------------------------------------

loc_30476:
	move.w	#$FFFF,(a0)

loc_3047A:
	addq.w	#8,a0
	move.w	a5,d0
	dbf	d3,loc_30452
	moveq	#$10,d3
	ext.l	d4
	moveq	#$C,d7
	lsl.l	d7,d4
	moveq	#0,d5

loc_3048C:
	swap	d5
	move.w	4(a0),d2
	move.w	d5,4(a0)
	move.w	d2,6(a0)
	cmp.w	d5,d2
	beq.s	loc_304A4
	bsr.w	sub_304B4
	bra.s	loc_304A8
; ---------------------------------------------------------------------------

loc_304A4:
	move.w	#$FFFF,(a0)

loc_304A8:
	addq.w	#8,a0
	swap	d5
	add.l	d4,d5
	dbf	d3,loc_3048C
	rts
; End of function BackgroundScroll_ComputeShiftData


; =============== S U B	R O U T	I N E =======================================


sub_304B4:
	bgt.s	loc_304D8
	move.w	4(a0),d7
	asr.w	#3,d7
	addi.w	#$28,d7
	move.w	d7,d1

loc_304C2:
	cmp.w	d7,d6
	bgt.s	loc_304CA
	sub.w	d6,d7
	bra.s	loc_304C2
; ---------------------------------------------------------------------------

loc_304CA:
	move.w	d7,(a0)
	andi.w	#$3F,d1
	add.w	d1,d1
	move.w	d1,2(a0)
	rts
; ---------------------------------------------------------------------------

loc_304D8:
	move.w	4(a0),d7
	asr.w	#3,d7
	move.w	d7,d1

loc_304E0:
	cmp.w	d7,d6
	bgt.s	loc_304CA
	sub.w	d6,d7
	bra.s	loc_304E0
; End of function sub_304B4


; =============== S U B	R O U T	I N E =======================================


BackgroundScroll_ComputeShiftLayers:
	tst.b	(Background_NoScrollFlag).w
	beq.s	loc_3050A
	move.w	(Camera_X_pos).w,d2
	neg.w	d2
	swap	d2
	clr.w	d2
	lea	(Horiz_Scroll_Buffer).l,a3
	move.w	#$DF,d0

loc_30502:
	move.l	d2,(a3)+
	dbf	d0,loc_30502
	rts
; ---------------------------------------------------------------------------

loc_3050A:
	lea	(Horiz_Scroll_Buffer).l,a3
	moveq	#7,d5
	move.l	(LnkTo_BackgroundScroll_Index).l,a2
	move.l	(LnkTo_MapOrder_Index).l,a1
	move.w	(Current_LevelID).w,d7
	move.b	(a1,d7.w),d7
	ext.w	d7
	add.w	d7,d7
	add.w	d7,d7
	move.l	(a2,d7.w),a2
	lea	(Horiz_Scroll_Data).l,a1
	move.w	(Camera_Y_pos).w,d2
	move.w	d2,d3
	lsr.w	#5,d2
	add.w	d2,a2
	moveq	#$1B,d0
	moveq	#-1,d4
	clr.w	d1
	move.w	(Camera_X_pos).w,d2
	neg.w	d2
	swap	d2
	lsr.w	#2,d3
	and.w	d5,d3
	beq.s	loc_3056A
	move.w	d3,d4
	eor.w	d5,d3
	subq.w	#1,d4
	move.b	(a2)+,d1
	move.w	4(a1,d1.w),d2
	neg.w	d2

loc_30562:
	move.l	d2,(a3)+
	dbf	d3,loc_30562
	subq.w	#1,d0

loc_3056A:
	move.b	(a2)+,d1
	move.w	4(a1,d1.w),d2
	neg.w	d2
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	move.l	d2,(a3)+
	dbf	d0,loc_3056A
	tst.w	d4
	bmi.s	loc_30598
	move.b	(a2)+,d1
	move.w	4(a1,d1.w),d2
	neg.w	d2

loc_30592:
	move.l	d2,(a3)+
	dbf	d4,loc_30592

loc_30598:
	move.w	(Background_theme).w,d0
	cmpi.w	#Forest,d0
	beq.s	BackgroundScroll_ApplyForestWaterRipple
	cmpi.w	#Desert,d0
	beq.w	BackgroundScroll_ApplyDesertHeatRipple
	rts
; ---------------------------------------------------------------------------

BackgroundScroll_ApplyForestWaterRipple:
	move.w	(Camera_Y_pos).w,d1
	lsr.w	#2,d1
	move.l	(Addr_MapHeader).w,a0
	move.l	$14(a0),a0
	moveq	#0,d0
	move.b	(a0),d0
	lsl.w	#3,d0
	sub.w	d1,d0
	bpl.s	loc_305D4
	move.w	d0,d2
	addi.w	#$40,d0
	ble.s	return_30618
	neg.w	d2
	move.w	d0,d1
	moveq	#0,d0
	bra.s	loc_305E6
; ---------------------------------------------------------------------------

loc_305D4:
	move.w	#$E0,d1
	sub.w	d0,d1
	ble.s	return_30618
	moveq	#0,d2
	cmpi.w	#$40,d1
	ble.s	loc_305E6
	moveq	#$40,d1

loc_305E6:
	lea	(Horiz_Scroll_Buffer).l,a0
	add.w	d0,d0
	add.w	d0,d0
	lea	2(a0,d0.w),a0
	move.w	(a0),d3
	subq.w	#1,d1
	lea	BackgroundScroll_ForestWaterRippleData(pc,d2.w),a1
	move.w	(Time_Frames).w,d5
	lsr.w	#2,d5
	andi.w	#$3F,d5
	lea	(a1,d5.w),a1

loc_3060A:
	move.b	(a1)+,d4
	ext.w	d4
	add.w	d3,d4
	move.w	d4,(a0)
	addq.w	#4,a0
	dbf	d1,loc_3060A

return_30618:
	rts
; ---------------------------------------------------------------------------
;Water ripple data
BackgroundScroll_ForestWaterRippleData:
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   6
	dc.b   5
	dc.b   4
	dc.b   3
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   1
	dc.b   1
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   7
	dc.b   7
	dc.b   6
	dc.b   6
	dc.b   5
	dc.b   5
	dc.b   4
	dc.b   4
	dc.b   3
	dc.b   3
	dc.b   2
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   7
	dc.b   7
	dc.b   7
	dc.b   6
	dc.b   5
	dc.b   4
	dc.b   3
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   1
	dc.b   1
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   8
	dc.b   8
	dc.b   8
	dc.b   7
	dc.b   7
	dc.b   6
	dc.b   6
	dc.b   5
	dc.b   5
	dc.b   4
	dc.b   4
	dc.b   3
	dc.b   3
	dc.b   2
	dc.b   1
; ---------------------------------------------------------------------------

BackgroundScroll_ApplyDesertHeatRipple:
	move.w	(Camera_Y_pos).w,d6
	lsr.w	#2,d6
	move.l	(Addr_MapHeader).w,a0
	move.l	$14(a0),a2
	moveq	#0,d0
	move.b	(a2)+,d0
	lsl.w	#3,d0
	sub.w	d6,d0
	bpl.s	loc_306C2
	move.w	d0,d2
	addi.w	#$10,d0
	ble.s	return_30702
	neg.w	d2
	move.w	d0,d1
	moveq	#0,d0
	bra.s	loc_306D4
; ---------------------------------------------------------------------------

loc_306C2:
	move.w	#$E0,d1
	sub.w	d0,d1
	ble.s	return_30702
	moveq	#0,d2
	cmpi.w	#$10,d1
	ble.s	loc_306D4
	moveq	#$10,d1

loc_306D4:
	lea	(Horiz_Scroll_Buffer).l,a0
	add.w	d0,d0
	add.w	d0,d0
	lea	2(a0,d0.w),a0
	move.w	(a0),d3
	move.w	(Time_Frames).w,d5
	andi.w	#$30,d5
	add.w	d2,d5
	subq.w	#1,d1
	lea	BackgroundScroll_DesertHeatRippleData(pc,d5.w),a1

loc_306F4:
	move.b	(a1)+,d4
	ext.w	d4
	add.w	d3,d4
	move.w	d4,(a0)
	addq.w	#4,a0
	dbf	d1,loc_306F4

return_30702:
	rts
; End of function BackgroundScroll_ComputeShiftLayers

; ---------------------------------------------------------------------------
BackgroundScroll_DesertHeatRippleData:
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b   0
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_30744:
	lea	($FFFF4D5C).l,a0
	lea	(unk_309B8).l,a3
	lea	4(a6),a5
	move.l	(LnkTo_BackgroundScroll_Index).l,a2
	move.l	(LnkTo_MapOrder_Index).l,a1
	move.w	(Current_LevelID).w,d7
	move.b	(a1,d7.w),d7
	ext.w	d7
	add.w	d7,d7
	add.w	d7,d7
	move.l	(a2,d7.w),a2
	lea	(Horiz_Scroll_Data).l,a1
	move.w	(Camera_Y_pos).w,d7
	asr.w	#5,d7
	add.w	d7,a2
	add.w	d7,d7
	move.w	(a0,d7.w),a0
	move.w	(Background_width).w,d0
	move.w	#$80,d1
	lsl.w	#6,d7
	move.w	d7,d2
	moveq	#$1C,d3
	clr.w	d4
	move.w	d4,d6
	moveq	#3,d7

loc_3079A:
	move.b	(a2)+,d4
	cmpi.b	#$FF,d4
	beq.s	return_307B0
	move.l	(a1,d4.w),d5
	bpl.s	loc_307B2
	add.w	d0,a0
	add.w	d1,d2
	dbf	d3,loc_3079A

return_307B0:
	rts
; ---------------------------------------------------------------------------

loc_307B2:
	clr.w	d6
	andi.w	#$F80,d2
	ori.w	#$6000,d2
	or.w	d2,d5
	move.w	d5,(a5)
	move.w	d7,(a5)
	swap	d5
	move.b	(a0,d5.w),d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	add.w	d0,a0
	add.w	d1,d2
	dbf	d3,loc_3079A
	rts
; End of function sub_30744


; =============== S U B	R O U T	I N E =======================================


sub_307D8:
	move.w	(Background_width).w,a4
	move.l	(LnkTo_BackgroundScroll_Index).l,a2
	move.l	(LnkTo_MapOrder_Index).l,a1
	move.w	(Current_LevelID).w,d7
	move.b	(a1,d7.w),d7
	ext.w	d7
	add.w	d7,d7
	add.w	d7,d7
	move.l	(a2,d7.w),a2
	lea	(Horiz_Scroll_Data).l,a1
	move.w	(Camera_Y_pos).w,d0
	asr.w	#5,d0
	move.w	($FFFFFAA8).w,d1
	move.w	d0,($FFFFFAA8).w
	cmp.w	d0,d1
	beq.w	return_308B4
	bgt.s	loc_3081A
	addi.w	#$1C,d0

loc_3081A:
	move.w	d0,d3
	move.w	d0,d5
	move.b	(a2,d0.w),d0
	cmpi.b	#$FF,d0
	beq.w	return_308B4
	andi.w	#$FF,d0
	move.w	4(a1,d0.w),d0
	lsr.w	#3,d0
	move.w	d0,d2

loc_30836:
	cmp.w	d0,a4
	bgt.s	loc_30840
	sub.w	(Background_width).w,d0
	bra.s	loc_30836
; ---------------------------------------------------------------------------

loc_30840:
	add.w	d5,d5
	lea	($FFFF4D5C).l,a0
	move.w	(a0,d5.w),a0
	lea	4(a6),a5
	lea	(unk_309B8).l,a3
	add.w	d0,a0
	clr.w	d1
	move.w	d0,d7
	addi.w	#$28,d7
	cmp.w	d7,a4
	bgt.s	loc_3086A
	sub.w	(Background_width).w,d7
	moveq	#1,d1

loc_3086A:
	move.w	d2,d6
	move.w	d2,d0
	clr.w	d2
	andi.w	#$3F,d6
	addi.w	#$28,d6
	cmpi.w	#$3F,d6
	ble.s	loc_30884
	subi.w	#$40,d6
	moveq	#1,d2

loc_30884:
	andi.w	#$3F,d0
	add.w	d0,d0
	lsl.w	#7,d3
	andi.w	#$F80,d3
	ori.w	#$6000,d3
	or.w	d3,d0
	move.w	d0,(a5)
	move.w	#3,(a5)
	tst.w	d1
	bne.s	loc_308B6
	tst.w	d2
	bne.s	loc_308DE
	moveq	#$28,d4

loc_308A6:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d4,loc_308A6

return_308B4:
	rts
; ---------------------------------------------------------------------------

loc_308B6:
	tst.w	d2
	bne.s	loc_30904
	move.w	d7,d4
	moveq	#$28,d1
	sub.w	d7,d1
	subq.w	#1,d1
	moveq	#1,d2

loc_308C4:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d1,loc_308C4
	suba.w	(Background_width).w,a0
	move.w	d4,d1
	dbf	d2,loc_308C4
	rts
; ---------------------------------------------------------------------------

loc_308DE:
	move.w	d6,d4
	moveq	#$28,d1
	sub.w	d6,d1
	subq.w	#1,d1
	moveq	#1,d2

loc_308E8:
	clr.w	d7
	move.b	(a0)+,d7
	add.w	d7,d7
	move.w	(a3,d7.w),(a6)
	dbf	d1,loc_308E8
	move.w	d3,(a5)
	move.w	#3,(a5)
	move.w	d4,d1
	dbf	d2,loc_308E8
	rts
; ---------------------------------------------------------------------------

loc_30904:
	cmp.w	d6,d7
	bgt.s	loc_30936
	blt.w	loc_30978
	move.w	d7,d4
	moveq	#$28,d1
	sub.w	d7,d1
	subq.w	#1,d1
	moveq	#1,d2

loc_30916:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d1,loc_30916
	move.w	d3,(a5)
	move.w	#3,(a5)
	suba.w	(Background_width).w,a0
	move.w	d4,d1
	dbf	d2,loc_30916
	rts
; ---------------------------------------------------------------------------

loc_30936:
	move.w	d7,d1
	move.w	d6,d5
	moveq	#$27,d4
	sub.w	d1,d4
	sub.w	d5,d7
	subq.w	#1,d7

loc_30942:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d4,loc_30942
	suba.w	(Background_width).w,a0

loc_30954:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d7,loc_30954
	move.w	d3,(a5)
	move.w	#3,(a5)

loc_30968:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d5,loc_30968
	rts
; ---------------------------------------------------------------------------

loc_30978:
	move.w	d6,d1
	move.w	d7,d5
	move.w	#$27,d4
	sub.w	d1,d4
	sub.w	d5,d6
	subq.w	#1,d6
	move.w	d6,d1

loc_30988:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d4,loc_30988
	move.w	d3,(a5)
	move.w	#3,(a5)
	moveq	#1,d2

loc_3099E:
	clr.w	d6
	move.b	(a0)+,d6
	add.w	d6,d6
	move.w	(a3,d6.w),(a6)
	dbf	d1,loc_3099E
	move.w	d5,d1
	suba.w	(Background_width).w,a0
	dbf	d2,loc_3099E
	rts
; End of function sub_307D8

; ---------------------------------------------------------------------------
unk_309B8:	dc.b $27 ; '
	dc.b $80 ; �
	dc.b $27 ; '
	dc.b $81 ; �
	dc.b $27 ; '
	dc.b $82 ; �
	dc.b $27 ; '
	dc.b $83 ; �
	dc.b $27 ; '
	dc.b $84 ; �
	dc.b $27 ; '
	dc.b $85 ; �
	dc.b $27 ; '
	dc.b $86 ; �
	dc.b $27 ; '
	dc.b $87 ; �
	dc.b $27 ; '
	dc.b $88 ; �
	dc.b $27 ; '
	dc.b $89 ; �
	dc.b $27 ; '
	dc.b $8A ; �
	dc.b $27 ; '
	dc.b $8B ; �
	dc.b $27 ; '
	dc.b $8C ; �
	dc.b $27 ; '
	dc.b $8D ; �
	dc.b $27 ; '
	dc.b $8E ; �
	dc.b $27 ; '
	dc.b $8F ; �
	dc.b $27 ; '
	dc.b $90 ; �
	dc.b $27 ; '
	dc.b $91 ; �
	dc.b $27 ; '
	dc.b $92 ; �
	dc.b $27 ; '
	dc.b $93 ; �
	dc.b $27 ; '
	dc.b $94 ; �
	dc.b $27 ; '
	dc.b $95 ; �
	dc.b $27 ; '
	dc.b $96 ; �
	dc.b $27 ; '
	dc.b $97 ; �
	dc.b $27 ; '
	dc.b $98 ; �
	dc.b $27 ; '
	dc.b $99 ; �
	dc.b $27 ; '
	dc.b $9A ; �
	dc.b $27 ; '
	dc.b $9B ; �
	dc.b $27 ; '
	dc.b $9C ; �
	dc.b $27 ; '
	dc.b $9D ; �
	dc.b $27 ; '
	dc.b $9E ; �
	dc.b $27 ; '
	dc.b $9F ; �
	dc.b $27 ; '
	dc.b $A0 ; �
	dc.b $27 ; '
	dc.b $A1 ; �
	dc.b $27 ; '
	dc.b $A2 ; �
	dc.b $27 ; '
	dc.b $A3 ; �
	dc.b $27 ; '
	dc.b $A4 ; �
	dc.b $27 ; '
	dc.b $A5 ; �
	dc.b $27 ; '
	dc.b $A6 ; �
	dc.b $27 ; '
	dc.b $A7 ; �
	dc.b $27 ; '
	dc.b $A8 ; �
	dc.b $27 ; '
	dc.b $A9 ; �
	dc.b $27 ; '
	dc.b $AA ; �
	dc.b $27 ; '
	dc.b $AB ; �
	dc.b $27 ; '
	dc.b $AC ; �
	dc.b $27 ; '
	dc.b $AD ; �
	dc.b $27 ; '
	dc.b $AE ; �
	dc.b $27 ; '
	dc.b $AF ; �
	dc.b $27 ; '
	dc.b $B0 ; �
	dc.b $27 ; '
	dc.b $B1 ; �
	dc.b $27 ; '
	dc.b $B2 ; �
	dc.b $27 ; '
	dc.b $B3 ; �
	dc.b $27 ; '
	dc.b $B4 ; �
	dc.b $27 ; '
	dc.b $B5 ; �
	dc.b $27 ; '
	dc.b $B6 ; �
	dc.b $27 ; '
	dc.b $B7 ; �
	dc.b $27 ; '
	dc.b $B8 ; �
	dc.b $27 ; '
	dc.b $B9 ; �
	dc.b $27 ; '
	dc.b $BA ; �
	dc.b $27 ; '
	dc.b $BB ; �
	dc.b $27 ; '
	dc.b $BC ; �
	dc.b $27 ; '
	dc.b $BD ; �
	dc.b $27 ; '
	dc.b $BE ; �
	dc.b $27 ; '
	dc.b $BF ; �
	dc.b $27 ; '
	dc.b $C0 ; �
	dc.b $27 ; '
	dc.b $C1 ; �
	dc.b $27 ; '
	dc.b $C2 ; �
	dc.b $27 ; '
	dc.b $C3 ; �
	dc.b $27 ; '
	dc.b $C4 ; �
	dc.b $27 ; '
	dc.b $C5 ; �
	dc.b $27 ; '
	dc.b $C6 ; �
	dc.b $27 ; '
	dc.b $C7 ; �
	dc.b $27 ; '
	dc.b $C8 ; �
	dc.b $27 ; '
	dc.b $C9 ; �
	dc.b $27 ; '
	dc.b $CA ; �
	dc.b $27 ; '
	dc.b $CB ; �
	dc.b $27 ; '
	dc.b $CC ; �
	dc.b $27 ; '
	dc.b $CD ; �
	dc.b $27 ; '
	dc.b $CE ; �
	dc.b $27 ; '
	dc.b $CF ; �
	dc.b $27 ; '
	dc.b $D0 ; �
	dc.b $27 ; '
	dc.b $D1 ; �
	dc.b $27 ; '
	dc.b $D2 ; �
	dc.b $27 ; '
	dc.b $D3 ; �
	dc.b $27 ; '
	dc.b $D4 ; �
	dc.b $27 ; '
	dc.b $D5 ; �
	dc.b $27 ; '
	dc.b $D6 ; �
	dc.b $27 ; '
	dc.b $D7 ; �
	dc.b $27 ; '
	dc.b $D8 ; �
	dc.b $27 ; '
	dc.b $D9 ; �
	dc.b $27 ; '
	dc.b $DA ; �
	dc.b $27 ; '
	dc.b $DB ; �
	dc.b $27 ; '
	dc.b $DC ; �
	dc.b $27 ; '
	dc.b $DD ; �
	dc.b $27 ; '
	dc.b $DE ; �
	dc.b $27 ; '
	dc.b $DF ; �
	dc.b $27 ; '
	dc.b $E0 ; �
	dc.b $27 ; '
	dc.b $E1 ; �
	dc.b $27 ; '
	dc.b $E2 ; �
	dc.b $27 ; '
	dc.b $E3 ; �
	dc.b $27 ; '
	dc.b $E4 ; �
	dc.b $27 ; '
	dc.b $E5 ; �
	dc.b $27 ; '
	dc.b $E6 ; �
	dc.b $27 ; '
	dc.b $E7 ; �
	dc.b $27 ; '
	dc.b $E8 ; �
	dc.b $27 ; '
	dc.b $E9 ; �
	dc.b $27 ; '
	dc.b $EA ; �
	dc.b $27 ; '
	dc.b $EB ; �
	dc.b $27 ; '
	dc.b $EC ; �
	dc.b $27 ; '
	dc.b $ED ; �
	dc.b $27 ; '
	dc.b $EE ; �
	dc.b $27 ; '
	dc.b $EF ; �
	dc.b $27 ; '
	dc.b $F0 ; �
	dc.b $27 ; '
	dc.b $F1 ; �
	dc.b $27 ; '
	dc.b $F2 ; �
	dc.b $27 ; '
	dc.b $F3 ; �
	dc.b $27 ; '
	dc.b $F4 ; �
	dc.b $27 ; '
	dc.b $F5 ; �
	dc.b $27 ; '
	dc.b $F6 ; �
	dc.b $27 ; '
	dc.b $F7 ; �
	dc.b $27 ; '
	dc.b $F8 ; �
	dc.b $27 ; '
	dc.b $F9 ; �
	dc.b $27 ; '
	dc.b $FA ; �
	dc.b $27 ; '
	dc.b $FB ; �
	dc.b $27 ; '
	dc.b $FC ; �
	dc.b $27 ; '
	dc.b $FD ; �
	dc.b $27 ; '
	dc.b $FE ; �
	dc.b $27 ; '
	dc.b $FF
	dc.b $2F ; /
	dc.b $80 ; �
	dc.b $2F ; /
	dc.b $81 ; �
	dc.b $2F ; /
	dc.b $82 ; �
	dc.b $2F ; /
	dc.b $83 ; �
	dc.b $2F ; /
	dc.b $84 ; �
	dc.b $2F ; /
	dc.b $85 ; �
	dc.b $2F ; /
	dc.b $86 ; �
	dc.b $2F ; /
	dc.b $87 ; �
	dc.b $2F ; /
	dc.b $88 ; �
	dc.b $2F ; /
	dc.b $89 ; �
	dc.b $2F ; /
	dc.b $8A ; �
	dc.b $2F ; /
	dc.b $8B ; �
	dc.b $2F ; /
	dc.b $8C ; �
	dc.b $2F ; /
	dc.b $8D ; �
	dc.b $2F ; /
	dc.b $8E ; �
	dc.b $2F ; /
	dc.b $8F ; �
	dc.b $2F ; /
	dc.b $90 ; �
	dc.b $2F ; /
	dc.b $91 ; �
	dc.b $2F ; /
	dc.b $92 ; �
	dc.b $2F ; /
	dc.b $93 ; �
	dc.b $2F ; /
	dc.b $94 ; �
	dc.b $2F ; /
	dc.b $95 ; �
	dc.b $2F ; /
	dc.b $96 ; �
	dc.b $2F ; /
	dc.b $97 ; �
	dc.b $2F ; /
	dc.b $98 ; �
	dc.b $2F ; /
	dc.b $99 ; �
	dc.b $2F ; /
	dc.b $9A ; �
	dc.b $2F ; /
	dc.b $9B ; �
	dc.b $2F ; /
	dc.b $9C ; �
	dc.b $2F ; /
	dc.b $9D ; �
	dc.b $2F ; /
	dc.b $9E ; �
	dc.b $2F ; /
	dc.b $9F ; �
	dc.b $2F ; /
	dc.b $A0 ; �
	dc.b $2F ; /
	dc.b $A1 ; �
	dc.b $2F ; /
	dc.b $A2 ; �
	dc.b $2F ; /
	dc.b $A3 ; �
	dc.b $2F ; /
	dc.b $A4 ; �
	dc.b $2F ; /
	dc.b $A5 ; �
	dc.b $2F ; /
	dc.b $A6 ; �
	dc.b $2F ; /
	dc.b $A7 ; �
	dc.b $2F ; /
	dc.b $A8 ; �
	dc.b $2F ; /
	dc.b $A9 ; �
	dc.b $2F ; /
	dc.b $AA ; �
	dc.b $2F ; /
	dc.b $AB ; �
	dc.b $2F ; /
	dc.b $AC ; �
	dc.b $2F ; /
	dc.b $AD ; �
	dc.b $2F ; /
	dc.b $AE ; �
	dc.b $2F ; /
	dc.b $AF ; �
	dc.b $2F ; /
	dc.b $B0 ; �
	dc.b $2F ; /
	dc.b $B1 ; �
	dc.b $2F ; /
	dc.b $B2 ; �
	dc.b $2F ; /
	dc.b $B3 ; �
	dc.b $2F ; /
	dc.b $B4 ; �
	dc.b $2F ; /
	dc.b $B5 ; �
	dc.b $2F ; /
	dc.b $B6 ; �
	dc.b $2F ; /
	dc.b $B7 ; �
	dc.b $2F ; /
	dc.b $B8 ; �
	dc.b $2F ; /
	dc.b $B9 ; �
	dc.b $2F ; /
	dc.b $BA ; �
	dc.b $2F ; /
	dc.b $BB ; �
	dc.b $2F ; /
	dc.b $BC ; �
	dc.b $2F ; /
	dc.b $BD ; �
	dc.b $2F ; /
	dc.b $BE ; �
	dc.b $2F ; /
	dc.b $BF ; �
	dc.b $2F ; /
	dc.b $C0 ; �
	dc.b $2F ; /
	dc.b $C1 ; �
	dc.b $2F ; /
	dc.b $C2 ; �
	dc.b $2F ; /
	dc.b $C3 ; �
	dc.b $2F ; /
	dc.b $C4 ; �
	dc.b $2F ; /
	dc.b $C5 ; �
	dc.b $2F ; /
	dc.b $C6 ; �
	dc.b $2F ; /
	dc.b $C7 ; �
	dc.b $2F ; /
	dc.b $C8 ; �
	dc.b $2F ; /
	dc.b $C9 ; �
	dc.b $2F ; /
	dc.b $CA ; �
	dc.b $2F ; /
	dc.b $CB ; �
	dc.b $2F ; /
	dc.b $CC ; �
	dc.b $2F ; /
	dc.b $CD ; �
	dc.b $2F ; /
	dc.b $CE ; �
	dc.b $2F ; /
	dc.b $CF ; �
	dc.b $2F ; /
	dc.b $D0 ; �
	dc.b $2F ; /
	dc.b $D1 ; �
	dc.b $2F ; /
	dc.b $D2 ; �
	dc.b $2F ; /
	dc.b $D3 ; �
	dc.b $2F ; /
	dc.b $D4 ; �
	dc.b $2F ; /
	dc.b $D5 ; �
	dc.b $2F ; /
	dc.b $D6 ; �
	dc.b $2F ; /
	dc.b $D7 ; �
	dc.b $2F ; /
	dc.b $D8 ; �
	dc.b $2F ; /
	dc.b $D9 ; �
	dc.b $2F ; /
	dc.b $DA ; �
	dc.b $2F ; /
	dc.b $DB ; �
	dc.b $2F ; /
	dc.b $DC ; �
	dc.b $2F ; /
	dc.b $DD ; �
	dc.b $2F ; /
	dc.b $DE ; �
	dc.b $2F ; /
	dc.b $DF ; �
	dc.b $2F ; /
	dc.b $E0 ; �
	dc.b $2F ; /
	dc.b $E1 ; �
	dc.b $2F ; /
	dc.b $E2 ; �
	dc.b $2F ; /
	dc.b $E3 ; �
	dc.b $2F ; /
	dc.b $E4 ; �
	dc.b $2F ; /
	dc.b $E5 ; �
	dc.b $2F ; /
	dc.b $E6 ; �
	dc.b $2F ; /
	dc.b $E7 ; �
	dc.b $2F ; /
	dc.b $E8 ; �
	dc.b $2F ; /
	dc.b $E9 ; �
	dc.b $2F ; /
	dc.b $EA ; �
	dc.b $2F ; /
	dc.b $EB ; �
	dc.b $2F ; /
	dc.b $EC ; �
	dc.b $2F ; /
	dc.b $ED ; �
	dc.b $2F ; /
	dc.b $EE ; �
	dc.b $2F ; /
	dc.b $EF ; �
	dc.b $2F ; /
	dc.b $F0 ; �
	dc.b $2F ; /
	dc.b $F1 ; �
	dc.b $2F ; /
	dc.b $F2 ; �
	dc.b $2F ; /
	dc.b $F3 ; �
	dc.b $2F ; /
	dc.b $F4 ; �
	dc.b $2F ; /
	dc.b $F5 ; �
	dc.b $2F ; /
	dc.b $F6 ; �
	dc.b $2F ; /
	dc.b $F7 ; �
	dc.b $2F ; /
	dc.b $F8 ; �
	dc.b $2F ; /
	dc.b $F9 ; �
	dc.b $2F ; /
	dc.b $FA ; �
	dc.b $2F ; /
	dc.b $FB ; �
	dc.b $2F ; /
	dc.b $FC ; �
	dc.b $2F ; /
	dc.b $FD ; �
	dc.b $2F ; /
	dc.b $FE ; �
	dc.b $2F ; /
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
;off_30BF4
; one entry for each (sprite) entry in Data_Index:
; 4 words each:
; - x-coordinate of left edge of hitbox relative to sprite (center?)
; - width
; - y-coordinate of top edge of hitbox relative to sprite (center?)
; - height
CollisionSize_Index:
	dc.w unk_31D8E-CollisionSize_Index 
	dc.w loc_320C0+2-CollisionSize_Index
	dc.w loc_320C0+2-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314CE-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314D0-CollisionSize_Index
	dc.w unk_314DA-CollisionSize_Index
	dc.w unk_314DA-CollisionSize_Index
	dc.w unk_314DA-CollisionSize_Index
	dc.w loc_320D8-CollisionSize_Index
	dc.w loc_320D8-CollisionSize_Index
	dc.w loc_320D8-CollisionSize_Index
	dc.w loc_320D8-CollisionSize_Index
	dc.w unk_314E4-CollisionSize_Index
	dc.w unk_314E4-CollisionSize_Index
	dc.w unk_314E4-CollisionSize_Index
	dc.w unk_314E4-CollisionSize_Index
	dc.w unk_314EE-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314F8-CollisionSize_Index
	dc.w unk_314F8-CollisionSize_Index
	dc.w unk_314F8-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_31504-CollisionSize_Index
	dc.w unk_31504-CollisionSize_Index
	dc.w unk_31504-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w unk_314FA-CollisionSize_Index
	dc.w loc_32102-CollisionSize_Index
	dc.w loc_32102-CollisionSize_Index
	dc.w loc_32102-CollisionSize_Index
	dc.w unk_3150E-CollisionSize_Index
	dc.w unk_3150E-CollisionSize_Index
	dc.w unk_31518-CollisionSize_Index
	dc.w unk_31518-CollisionSize_Index
	dc.w unk_31518-CollisionSize_Index
	dc.w unk_3151A-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w unk_31524-CollisionSize_Index
	dc.w loc_32122-CollisionSize_Index
	dc.w loc_32122-CollisionSize_Index
	dc.w loc_32122-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_3152E-CollisionSize_Index
	dc.w unk_31538-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w unk_31542-CollisionSize_Index
	dc.w loc_32140-CollisionSize_Index
	dc.w loc_32140-CollisionSize_Index
	dc.w loc_32140-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_31556-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_31560-CollisionSize_Index
	dc.w unk_31560-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_31562-CollisionSize_Index
	dc.w unk_31562-CollisionSize_Index
	dc.w unk_31562-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w unk_3154C-CollisionSize_Index
	dc.w loc_3215E+2-CollisionSize_Index
	dc.w loc_3215E+2-CollisionSize_Index
	dc.w loc_3215E+2-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_3156C-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31580-CollisionSize_Index
	dc.w unk_31580-CollisionSize_Index
	dc.w unk_31580-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w unk_31576-CollisionSize_Index
	dc.w loc_3217C+2-CollisionSize_Index
	dc.w loc_3217C+2-CollisionSize_Index
	dc.w loc_3217C+2-CollisionSize_Index
	dc.w unk_3158A-CollisionSize_Index
	dc.w unk_3158A-CollisionSize_Index
	dc.w unk_3158A-CollisionSize_Index
	dc.w unk_3158C-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_315A0-CollisionSize_Index
	dc.w unk_315A0-CollisionSize_Index
	dc.w unk_315A0-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w unk_31596-CollisionSize_Index
	dc.w loc_3219E-CollisionSize_Index
	dc.w loc_3219E-CollisionSize_Index
	dc.w loc_3219E-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315B4-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315C8-CollisionSize_Index
	dc.w unk_315C8-CollisionSize_Index
	dc.w unk_315C8-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w unk_315BE-CollisionSize_Index
	dc.w loc_321C6-CollisionSize_Index
	dc.w loc_321C6-CollisionSize_Index
	dc.w loc_321C6-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315D2-CollisionSize_Index
	dc.w unk_315DC-CollisionSize_Index
	dc.w unk_315DC-CollisionSize_Index
	dc.w unk_315DC-CollisionSize_Index
	dc.w unk_315DC-CollisionSize_Index
	dc.w unk_315DC-CollisionSize_Index
	dc.w unk_315E8-CollisionSize_Index
	dc.w unk_315DE-CollisionSize_Index
	dc.w unk_315DE-CollisionSize_Index
	dc.w loc_321E4+2-CollisionSize_Index
	dc.w loc_321E4+2-CollisionSize_Index
	dc.w loc_321E4+2-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315F2-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_31606-CollisionSize_Index
	dc.w unk_31606-CollisionSize_Index
	dc.w unk_31606-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w unk_315FC-CollisionSize_Index
	dc.w loc_32200+4-CollisionSize_Index
	dc.w loc_32200+4-CollisionSize_Index
	dc.w loc_32200+4-CollisionSize_Index
	dc.w unk_31610-CollisionSize_Index
	dc.w unk_31610-CollisionSize_Index
	dc.w unk_31610-CollisionSize_Index
	dc.w unk_31612-CollisionSize_Index
	dc.w unk_3161C-CollisionSize_Index
	dc.w unk_31626-CollisionSize_Index
	dc.w unk_31630-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_31658-CollisionSize_Index
	dc.w unk_3163A-CollisionSize_Index
	dc.w unk_3163A-CollisionSize_Index
	dc.w unk_31644-CollisionSize_Index
	dc.w unk_31644-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w unk_3164E-CollisionSize_Index
	dc.w loc_32256-CollisionSize_Index
	dc.w unk_31662-CollisionSize_Index
	dc.w unk_31662-CollisionSize_Index
	dc.w unk_31662-CollisionSize_Index
	dc.w unk_31664-CollisionSize_Index
	dc.w unk_31664-CollisionSize_Index
	dc.w unk_31664-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3166E-CollisionSize_Index
	dc.w unk_3226C-CollisionSize_Index
	dc.w unk_3226C-CollisionSize_Index
	dc.w unk_3226C-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_3167A-CollisionSize_Index
	dc.w unk_31684-CollisionSize_Index
	dc.w unk_31684-CollisionSize_Index
	dc.w unk_31684-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_31686-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_32284-CollisionSize_Index
	dc.w unk_31692-CollisionSize_Index
	dc.w unk_31692-CollisionSize_Index
	dc.w unk_31692-CollisionSize_Index
	dc.w unk_31692-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_3169C-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w off_32290+2-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_3169E-CollisionSize_Index
	dc.w unk_316A0-CollisionSize_Index
	dc.w unk_316A0-CollisionSize_Index
	dc.w unk_316A0-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AA-CollisionSize_Index
	dc.w unk_316AC-CollisionSize_Index
	dc.w unk_316B6-CollisionSize_Index
	dc.w unk_316B8-CollisionSize_Index
	dc.w unk_316C2-CollisionSize_Index
	dc.w loc_322C0-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_316CC-CollisionSize_Index
	dc.w unk_316CC-CollisionSize_Index
	dc.w unk_316CE-CollisionSize_Index
	dc.w unk_316CE-CollisionSize_Index
	dc.w unk_316CE-CollisionSize_Index
	dc.w loc_322C8+4-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_316D8-CollisionSize_Index
	dc.w unk_316E2-CollisionSize_Index
	dc.w unk_316EC-CollisionSize_Index
	dc.w unk_316F6-CollisionSize_Index
	dc.w unk_31710-CollisionSize_Index
	dc.w unk_3172A-CollisionSize_Index
	dc.w unk_31744-CollisionSize_Index
	dc.w unk_3175E-CollisionSize_Index
	dc.w unk_3175E-CollisionSize_Index
	dc.w unk_3175E-CollisionSize_Index
	dc.w unk_31760-CollisionSize_Index
	dc.w unk_31760-CollisionSize_Index
	dc.w unk_31760-CollisionSize_Index
	dc.w unk_31760-CollisionSize_Index
	dc.w loc_3235E-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_3176A-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_31774-CollisionSize_Index
	dc.w unk_3177E-CollisionSize_Index
	dc.w unk_3177E-CollisionSize_Index
	dc.w unk_3177E-CollisionSize_Index
	dc.w loc_3237A+2-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31788-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w unk_31792-CollisionSize_Index
	dc.w loc_3247E+2-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188C-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_3188E-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_31898-CollisionSize_Index
	dc.w unk_3189A-CollisionSize_Index
	dc.w unk_318A4-CollisionSize_Index
	dc.w unk_318A4-CollisionSize_Index
	dc.w unk_318A6-CollisionSize_Index
	dc.w unk_318B0-CollisionSize_Index
	dc.w unk_318B2-CollisionSize_Index
	dc.w unk_318B2-CollisionSize_Index
	dc.w unk_318B2-CollisionSize_Index
	dc.w unk_318BC-CollisionSize_Index
	dc.w unk_318BC-CollisionSize_Index
	dc.w unk_318BC-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D0-CollisionSize_Index
	dc.w unk_318D2-CollisionSize_Index
	dc.w unk_318B2-CollisionSize_Index
	dc.w unk_318BC-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w unk_318C6-CollisionSize_Index
	dc.w loc_32386+2-CollisionSize_Index
	dc.w loc_32386+2-CollisionSize_Index
	dc.w loc_32386+2-CollisionSize_Index
	dc.w unk_31796-CollisionSize_Index
	dc.w unk_31798-CollisionSize_Index
	dc.w unk_3179A-CollisionSize_Index
	dc.w unk_3179C-CollisionSize_Index
	dc.w unk_317A6-CollisionSize_Index
	dc.w unk_317B0-CollisionSize_Index
	dc.w unk_317BA-CollisionSize_Index
	dc.w unk_317C4-CollisionSize_Index
	dc.w unk_317CE-CollisionSize_Index
	dc.w unk_317D8-CollisionSize_Index
	dc.w loc_323D6-CollisionSize_Index
	dc.w loc_323D6-CollisionSize_Index
	dc.w loc_323D6-CollisionSize_Index
	dc.w unk_317E2-CollisionSize_Index
	dc.w unk_317E4-CollisionSize_Index
	dc.w unk_317EE-CollisionSize_Index
	dc.w unk_317F8-CollisionSize_Index
	dc.w unk_31802-CollisionSize_Index
	dc.w unk_3180C-CollisionSize_Index
	dc.w unk_31816-CollisionSize_Index
	dc.w unk_31820-CollisionSize_Index
	dc.w unk_31822-CollisionSize_Index
	dc.w unk_31824-CollisionSize_Index
	dc.w unk_3182E-CollisionSize_Index
	dc.w unk_31838-CollisionSize_Index
	dc.w unk_31842-CollisionSize_Index
	dc.w unk_3184C-CollisionSize_Index
	dc.w unk_31856-CollisionSize_Index
	dc.w loc_32454-CollisionSize_Index
	dc.w loc_32454-CollisionSize_Index
	dc.w loc_32454-CollisionSize_Index
	dc.w unk_31862-CollisionSize_Index
	dc.w unk_31864-CollisionSize_Index
	dc.w unk_31866-CollisionSize_Index
	dc.w unk_31870-CollisionSize_Index
	dc.w unk_31872-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_31874-CollisionSize_Index
	dc.w unk_3187E-CollisionSize_Index
	dc.w unk_31880-CollisionSize_Index
	dc.w unk_31882-CollisionSize_Index
	dc.w unk_31882-CollisionSize_Index
	dc.w unk_31882-CollisionSize_Index
	dc.w unk_31882-CollisionSize_Index
	dc.w loc_324D0-CollisionSize_Index
	dc.w loc_324D0-CollisionSize_Index
	dc.w loc_324D0-CollisionSize_Index
	dc.w unk_318DC-CollisionSize_Index
	dc.w unk_318DC-CollisionSize_Index
	dc.w unk_318DC-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w unk_318DE-CollisionSize_Index
	dc.w loc_324DC-CollisionSize_Index
	dc.w loc_324DC-CollisionSize_Index
	dc.w loc_324DC-CollisionSize_Index
	dc.w unk_318E8-CollisionSize_Index
	dc.w unk_318E8-CollisionSize_Index
	dc.w unk_318E8-CollisionSize_Index
	dc.w unk_318EA-CollisionSize_Index
	dc.w unk_318F4-CollisionSize_Index
	dc.w unk_318FE-CollisionSize_Index
	dc.w unk_31908-CollisionSize_Index
	dc.w unk_31912-CollisionSize_Index
	dc.w unk_3191C-CollisionSize_Index
	dc.w unk_31926-CollisionSize_Index
	dc.w unk_31930-CollisionSize_Index
	dc.w unk_3193A-CollisionSize_Index
	dc.w loc_32534+4-CollisionSize_Index
	dc.w loc_32534+4-CollisionSize_Index
	dc.w loc_32534+4-CollisionSize_Index
	dc.w unk_31944-CollisionSize_Index
	dc.w unk_31944-CollisionSize_Index
	dc.w unk_31944-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_319C2-CollisionSize_Index
	dc.w unk_319D4-CollisionSize_Index
	dc.w unk_319EE-CollisionSize_Index
	dc.w unk_31A00-CollisionSize_Index
	dc.w unk_31A12-CollisionSize_Index
	dc.w unk_3194E-CollisionSize_Index
	dc.w unk_31958-CollisionSize_Index
	dc.w unk_3196A-CollisionSize_Index
	dc.w unk_31984-CollisionSize_Index
	dc.w unk_3199E-CollisionSize_Index
	dc.w unk_319B0-CollisionSize_Index
	dc.w loc_32618-CollisionSize_Index
	dc.w loc_32618-CollisionSize_Index
	dc.w loc_32618-CollisionSize_Index
	dc.w unk_31A24-CollisionSize_Index
	dc.w unk_31A24-CollisionSize_Index
	dc.w unk_31A26-CollisionSize_Index
	dc.w unk_31A30-CollisionSize_Index
	dc.w unk_31A30-CollisionSize_Index
	dc.w unk_31A30-CollisionSize_Index
	dc.w unk_31A32-CollisionSize_Index
	dc.w unk_31A3C-CollisionSize_Index
	dc.w unk_31A46-CollisionSize_Index
	dc.w unk_31A48-CollisionSize_Index
	dc.w unk_31A48-CollisionSize_Index
	dc.w unk_31A48-CollisionSize_Index
	dc.w unk_31A52-CollisionSize_Index
	dc.w unk_31A54-CollisionSize_Index
	dc.w unk_31A54-CollisionSize_Index
	dc.w unk_31A5E-CollisionSize_Index
	dc.w off_329B6+$14-CollisionSize_Index
	dc.w off_329B6+$14-CollisionSize_Index
	dc.w off_329B6+$14-CollisionSize_Index
	dc.w unk_31DD6-CollisionSize_Index
	dc.w unk_31DD6-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DD6-CollisionSize_Index
	dc.w unk_31DD6-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31DE0-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A60-CollisionSize_Index
	dc.w unk_31A6A-CollisionSize_Index
	dc.w unk_31A6A-CollisionSize_Index
	dc.w unk_31A6A-CollisionSize_Index
	dc.w off_32656+$A-CollisionSize_Index
	dc.w off_32656+$A-CollisionSize_Index
	dc.w off_32656+$A-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6C-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w unk_31A6E-CollisionSize_Index
	dc.w off_32656+$16-CollisionSize_Index
	dc.w off_32656+$16-CollisionSize_Index
	dc.w off_32656+$16-CollisionSize_Index
	dc.w unk_31A78-CollisionSize_Index
	dc.w unk_31A78-CollisionSize_Index
	dc.w unk_31A78-CollisionSize_Index
	dc.w unk_31A7A-CollisionSize_Index
	dc.w unk_31A7A-CollisionSize_Index
	dc.w unk_31A7A-CollisionSize_Index
	dc.w unk_31A7A-CollisionSize_Index
	dc.w unk_31A84-CollisionSize_Index
	dc.w unk_31A84-CollisionSize_Index
	dc.w unk_31A84-CollisionSize_Index
	dc.w unk_31A86-CollisionSize_Index
	dc.w unk_31A86-CollisionSize_Index
	dc.w loc_32682+2-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_31A90-CollisionSize_Index
	dc.w unk_31A9A-CollisionSize_Index
	dc.w unk_31AA4-CollisionSize_Index
	dc.w unk_31AAE-CollisionSize_Index
	dc.w unk_31AAE-CollisionSize_Index
	dc.w unk_31AAE-CollisionSize_Index
	dc.w unk_31AB0-CollisionSize_Index
	dc.w unk_31ABA-CollisionSize_Index
	dc.w unk_31AC4-CollisionSize_Index
	dc.w loc_326C0+2-CollisionSize_Index
	dc.w loc_326C0+2-CollisionSize_Index
	dc.w loc_326C0+2-CollisionSize_Index
	dc.w unk_31ACE-CollisionSize_Index
	dc.w unk_31ACE-CollisionSize_Index
	dc.w unk_31ACE-CollisionSize_Index
	dc.w unk_31ACE-CollisionSize_Index
	dc.w unk_31ACE-CollisionSize_Index
	dc.w unk_31AD0-CollisionSize_Index
	dc.w unk_31ADA-CollisionSize_Index
	dc.w unk_31AE4-CollisionSize_Index
	dc.w unk_31AEE-CollisionSize_Index
	dc.w unk_31AF8-CollisionSize_Index
	dc.w stru_326F6-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B04-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B0E-CollisionSize_Index
	dc.w unk_31B10-CollisionSize_Index
	dc.w unk_31B1A-CollisionSize_Index
	dc.w unk_31B24-CollisionSize_Index
	dc.w unk_31B36-CollisionSize_Index
	dc.w unk_31B48-CollisionSize_Index
	dc.w unk_31B5A-CollisionSize_Index
	dc.w unk_31B64-CollisionSize_Index
	dc.w unk_31B6E-CollisionSize_Index
	dc.w unk_31B78-CollisionSize_Index
	dc.w unk_31B8A-CollisionSize_Index
	dc.w unk_31B9C-CollisionSize_Index
	dc.w unk_31BAE-CollisionSize_Index
	dc.w unk_31BB8-CollisionSize_Index
	dc.w loc_327B6-CollisionSize_Index
	dc.w loc_327B6-CollisionSize_Index
	dc.w loc_327B6-CollisionSize_Index
	dc.w unk_31BC4-CollisionSize_Index
	dc.w unk_31BC6-CollisionSize_Index
	dc.w unk_31BC8-CollisionSize_Index
	dc.w unk_31BCA-CollisionSize_Index
	dc.w unk_31BCA-CollisionSize_Index
	dc.w unk_31BCA-CollisionSize_Index
	dc.w unk_31BD4-CollisionSize_Index
	dc.w unk_31BD6-CollisionSize_Index
	dc.w unk_31BD8-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31BE4-CollisionSize_Index
	dc.w unk_31BEE-CollisionSize_Index
	dc.w unk_31BF8-CollisionSize_Index
	dc.w unk_31C02-CollisionSize_Index
	dc.w unk_31C0C-CollisionSize_Index
	dc.w unk_31C16-CollisionSize_Index
	dc.w unk_31C20-CollisionSize_Index
	dc.w unk_31C20-CollisionSize_Index
	dc.w unk_31C20-CollisionSize_Index
	dc.w unk_31C20-CollisionSize_Index
	dc.w unk_31C22-CollisionSize_Index
	dc.w unk_31BDA-CollisionSize_Index
	dc.w unk_31C2C-CollisionSize_Index
	dc.w unk_31C36-CollisionSize_Index
	dc.w loc_32832+2-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w off_329B6+$20-CollisionSize_Index
	dc.w unk_31CAE-CollisionSize_Index
	dc.w unk_31CC0-CollisionSize_Index
	dc.w unk_31CD2-CollisionSize_Index
	dc.w unk_31CD2-CollisionSize_Index
	dc.w unk_31CD2-CollisionSize_Index
	dc.w unk_31C42-CollisionSize_Index
	dc.w unk_31C54-CollisionSize_Index
	dc.w unk_31C66-CollisionSize_Index
	dc.w unk_31C78-CollisionSize_Index
	dc.w unk_31C8A-CollisionSize_Index
	dc.w unk_31C9C-CollisionSize_Index
	dc.w unk_31CD4-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CDE-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CEA-CollisionSize_Index
	dc.w unk_31CEA-CollisionSize_Index
	dc.w unk_31CEA-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CE0-CollisionSize_Index
	dc.w unk_31CEC-CollisionSize_Index
	dc.w unk_31CEC-CollisionSize_Index
	dc.w unk_31D06-CollisionSize_Index
	dc.w unk_31D06-CollisionSize_Index
	dc.w unk_31D06-CollisionSize_Index
	dc.w unk_31D06-CollisionSize_Index
	dc.w unk_31D06-CollisionSize_Index
	dc.w unk_31D08-CollisionSize_Index
	dc.w unk_31D12-CollisionSize_Index
	dc.w unk_31D14-CollisionSize_Index
	dc.w unk_31D1E-CollisionSize_Index
	dc.w unk_31D28-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2A-CollisionSize_Index
	dc.w unk_31D2C-CollisionSize_Index
	dc.w unk_31D2C-CollisionSize_Index
	dc.w unk_31D36-CollisionSize_Index
	dc.w unk_31D36-CollisionSize_Index
	dc.w unk_31D40-CollisionSize_Index
	dc.w unk_31D40-CollisionSize_Index
	dc.w unk_31D40-CollisionSize_Index
	dc.w unk_31D40-CollisionSize_Index
	dc.w unk_31D40-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4A-CollisionSize_Index
	dc.w unk_31D4C-CollisionSize_Index
	dc.w unk_31D4C-CollisionSize_Index
	dc.w unk_31D4C-CollisionSize_Index
	dc.w unk_31D4C-CollisionSize_Index
	dc.w unk_31D4C-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D56-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D58-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5A-CollisionSize_Index
	dc.w unk_31D5C-CollisionSize_Index
	dc.w unk_31D5C-CollisionSize_Index
	dc.w unk_31D5C-CollisionSize_Index
	dc.w unk_31D5E-CollisionSize_Index
	dc.w unk_31D5E-CollisionSize_Index
	dc.w unk_31D5E-CollisionSize_Index
	dc.w unk_31D5E-CollisionSize_Index
	dc.w unk_31D68-CollisionSize_Index
	dc.w unk_31D68-CollisionSize_Index
	dc.w unk_31D68-CollisionSize_Index
	dc.w unk_31D68-CollisionSize_Index
	dc.w unk_31D6A-CollisionSize_Index
	dc.w unk_31D74-CollisionSize_Index
	dc.w unk_31D76-CollisionSize_Index
	dc.w unk_31D76-CollisionSize_Index
	dc.w unk_31D76-CollisionSize_Index
	dc.w unk_31D76-CollisionSize_Index
	dc.w unk_31D76-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D78-CollisionSize_Index
	dc.w unk_31D7A-CollisionSize_Index
	dc.w unk_31D7A-CollisionSize_Index
	dc.w unk_31D7A-CollisionSize_Index
	dc.w unk_31D7A-CollisionSize_Index
	dc.w unk_31D84-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
	dc.w unk_31D90-CollisionSize_Index
	dc.w unk_31D9A-CollisionSize_Index
	dc.w unk_31DA4-CollisionSize_Index
	dc.w unk_31DAE-CollisionSize_Index
	dc.w unk_31DB8-CollisionSize_Index
	dc.w unk_31DC2-CollisionSize_Index
	dc.w unk_31DCC-CollisionSize_Index
	dc.w unk_31DE4-CollisionSize_Index
	dc.w unk_31DEE-CollisionSize_Index
	dc.w unk_31DF8-CollisionSize_Index
	dc.w unk_31E02-CollisionSize_Index
	dc.w unk_31E0C-CollisionSize_Index
	dc.w unk_31E16-CollisionSize_Index
	dc.w unk_31E20-CollisionSize_Index
	dc.w unk_31E2A-CollisionSize_Index
	dc.w unk_31E34-CollisionSize_Index
	dc.w unk_31E3E-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31E48-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
	dc.w unk_31D8E-CollisionSize_Index
unk_314CE:
	dc.w	   0
unk_314D0:
	dc.w	 -$5,  $A,-$1F, $1F
	dc.w	   0
unk_314DA:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_314E4:
	dc.w	 -$2,  $4, -$7,  $E
	dc.w	   0
unk_314EE:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_314F8:
	dc.w	   0
unk_314FA:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_31504:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_3150E:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_31518:
	dc.w	   0
unk_3151A:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_31524:
	dc.w	 -$A, $14,-$1F, $1F
	dc.w	   0
unk_3152E:
	dc.w	 -$4,  $8, -$F,  $F
	dc.w	   0
unk_31538:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_31542:
	dc.w	 -$4,  $8, -$F,  $F
	dc.w	   0
unk_3154C:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_31556:
	dc.w	 -$6,  $B, -$C,  $C
	dc.w	   0
unk_31560:
	dc.w	   0
unk_31562:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_3156C:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_31576:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_31580:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_3158A:
	dc.w	   0
unk_3158C:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_31596:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_315A0:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
	dc.w	 -$A, $14, -$F,  $F
	dc.w	   0
unk_315B4:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_315BE:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_315C8:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_315D2:
	dc.w	-$17, $2E, -$F,  $F
	dc.w	   0
unk_315DC:
	dc.w	   0
unk_315DE:
	dc.w	 -$3,  $6, -$5,  $7
	dc.w	   0
unk_315E8:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_315F2:
	dc.w	 -$6,  $C, -$C,  $C
	dc.w	   0
unk_315FC:
	dc.w	 -$7,  $E,-$1F, $1F
	dc.w	   0
unk_31606:
	dc.w	 -$E, $1C, -$F,  $F
	dc.w	   0
unk_31610:
	dc.w	   0
unk_31612:
	dc.w	 -$8, $10, -$A,  $A
	dc.w	   0
unk_3161C:
	dc.w	 -$8, $10, -$A,  $A
	dc.w	   0
unk_31626:
	dc.w	 -$9, $12, -$C,  $C
	dc.w	   0
unk_31630:
	dc.w	-$10, $20,-$20, $20
	dc.w	   0
unk_3163A:
	dc.w	 -$8, $10, -$4,  $8
	dc.w	   0
unk_31644:
	dc.w	 -$E, $1C, -$2,  $4
	dc.w	   0
unk_3164E:
	dc.w	 -$A, $14, -$A, $14
	dc.w	   0
unk_31658:
	dc.w	-$10, $20,-$20, $20
	dc.w	   0
unk_31662:
	dc.w	   0
unk_31664:
	dc.w	 -$E, $1C,-$1B, $1B
	dc.w	   0
unk_3166E:
	dc.w	 -$E, $1C,-$1B, $1B
	dc.w	   0
	dc.w	   0
unk_3167A:
	dc.w	-$15, $27,-$14, $14
	dc.w	   0
unk_31684:
	dc.w	   0
unk_31686:
	dc.w	-$15, $27,-$14, $14
	dc.w	   0
	dc.w	   0
unk_31692:
	dc.w	 -$7,  $E,-$1E, $1E
	dc.w	   0
unk_3169C:
	dc.w	   0
unk_3169E:
	dc.w	   0
unk_316A0:
	dc.w	 -$C, $12,-$1D, $1D
	dc.w	   0
unk_316AA:
	dc.w	   0
unk_316AC:
	dc.w	 -$4,  $8, -$4,  $8
	dc.w	   0
unk_316B6:
	dc.w	   0
unk_316B8:
	dc.w	 -$3,  $6, -$3,  $6
	dc.w	   0
unk_316C2:
	dc.w	 -$2,  $4, -$2,  $4
	dc.w	   0
unk_316CC:
	dc.w	   0
unk_316CE:
	dc.w	 -$7,  $E,-$21, $21
	dc.w	   0
unk_316D8:
	dc.w	 $20,  $F, -$3,  $6
	dc.w	   0
unk_316E2:
	dc.w	 -$3,  $6, $20,  $F
	dc.w	   0
unk_316EC:
	dc.w	 $1E,  $4, $1E,  $4
	dc.w	   0
unk_316F6:
	dc.w	 -$E,  $F,-$1C,  $F
	dc.w	 -$1,  $F,-$1E,  $F
	dc.w	 -$1,  $F, -$C,  $B
	dc.w	   0
unk_31710:
	dc.w	 -$E,  $F,-$1C,  $F
	dc.w	 -$1,  $F,-$1E,  $F
	dc.w	 -$1,  $F, -$C,  $B
	dc.w	   0
unk_3172A:
	dc.w	 -$E,  $F,-$1C,  $F
	dc.w	 -$1,  $F,-$1E,  $F
	dc.w	 -$1,  $F, -$C,  $B
	dc.w	   0
unk_31744:
	dc.w	 -$E,  $F,-$1C,  $F
	dc.w	 -$1,  $F,-$1E,  $F
	dc.w	 -$1,  $F, -$C,  $B
	dc.w	   0
unk_3175E:
	dc.w	   0
unk_31760:
	dc.w	 -$E, $1B,-$1C, $16
	dc.w	   0
unk_3176A:
	dc.w	 -$4,  $8, -$4,  $8
	dc.w	   0
unk_31774:
	dc.w	 -$6,  $C, -$4,  $4
	dc.w	   0
unk_3177E:
	dc.w	 -$8, $10, -$8, $10
	dc.w	   0
unk_31788:
	dc.w	 -$E, $1C, -$9,  $9
	dc.w	   0
unk_31792:
	dc.w	   0
	dc.w	   0
unk_31796:
	dc.w	   0
unk_31798:
	dc.w	   0
unk_3179A:
	dc.w	   0
unk_3179C:
	dc.w	 -$F, $1D,-$1F, $1F
	dc.w	   0
unk_317A6:
	dc.w	 -$E, $1B,-$20, $20
	dc.w	   0
unk_317B0:
	dc.w	 -$E, $1B,-$20, $20
	dc.w	   0
unk_317BA:
	dc.w	 -$E, $1B,-$20, $20
	dc.w	   0
unk_317C4:
	dc.w	 -$E, $1B,-$20, $20
	dc.w	   0
unk_317CE:
	dc.w	 -$E, $1B,-$20, $20
	dc.w	   0
unk_317D8:
	dc.w	 -$E, $1C,-$1A, $1A
	dc.w	   0
unk_317E2:
	dc.w	   0
unk_317E4:
	dc.w	-$12, $26,-$20, $20
	dc.w	   0
unk_317EE:
	dc.w	-$12, $26,-$20, $20
	dc.w	   0
unk_317F8:
	dc.w	-$10, $24,-$1F, $1F
	dc.w	   0
unk_31802:
	dc.w	-$11, $24,-$1F, $1F
	dc.w	   0
unk_3180C:
	dc.w	-$11, $25,-$1E, $1E
	dc.w	   0
unk_31816:
	dc.w	 -$F, $23,-$1F, $1F
	dc.w	   0
unk_31820:
	dc.w	   0
unk_31822:
	dc.w	   0
unk_31824:
	dc.w	 -$F, $1E,-$1F, $1F
	dc.w	   0
unk_3182E:
	dc.w	 -$F, $1E,-$20, $20
	dc.w	   0
unk_31838:
	dc.w	-$10, $1F,-$1F, $1F
	dc.w	   0
unk_31842:
	dc.w	-$11, $20,-$1F, $1F
	dc.w	   0
unk_3184C:
	dc.w	-$10, $1F,-$20, $20
	dc.w	   0
unk_31856:
	dc.w	 -$F, $1E,-$1F, $1F
	dc.w	   0
	dc.w	   0
unk_31862:
	dc.w	   0
unk_31864:
	dc.w	   0
unk_31866:
	dc.w	 -$B, $16,-$1C, $1C
	dc.w	   0
unk_31870:
	dc.w	   0
unk_31872:
	dc.w	   0
unk_31874:
	dc.w	 -$B, $16,-$1C, $1C
	dc.w	   0
unk_3187E:
	dc.w	   0
unk_31880:
	dc.w	   0
unk_31882:
	dc.w	-$20, $40,-$1F, $1F
	dc.w	   0
unk_3188C:
	dc.w	   0
unk_3188E:
	dc.w	 -$7,  $7, -$B,  $B
	dc.w	   0
unk_31898:
	dc.w	   0
unk_3189A:
	dc.w	 -$4,  $A, -$2,  $2
	dc.w	   0
unk_318A4:
	dc.w	   0
unk_318A6:
	dc.w	 -$2,  $4,   0,  $9
	dc.w	   0
unk_318B0:
	dc.w	   0
unk_318B2:
	dc.w	 -$7,  $E, -$E,  $E
	dc.w	   0
unk_318BC:
	dc.w	 -$4,  $8,  $1,  $D
	dc.w	   0
unk_318C6:
	dc.w	  $1,  $E, -$4,  $8
	dc.w	   0
unk_318D0:
	dc.w	   0
unk_318D2:
	dc.w	 -$1,  $2, -$1,  $2
	dc.w	   0
unk_318DC:
	dc.w	   0
unk_318DE:
	dc.w	 -$B, $16,-$1D, $1D
	dc.w	   0
unk_318E8:
	dc.w	   0
unk_318EA:
	dc.w	-$17, $2B,-$16, $15
	dc.w	   0
unk_318F4:
	dc.w	-$14, $28,-$16, $15
	dc.w	   0
unk_318FE:
	dc.w	-$14, $2B,-$16, $15
	dc.w	   0
unk_31908:
	dc.w	-$14, $29,-$16, $15
	dc.w	   0
unk_31912:
	dc.w	-$15, $2B,-$16, $15
	dc.w	   0
unk_3191C:
	dc.w	-$14, $29,-$16, $15
	dc.w	   0
unk_31926:
	dc.w	-$15, $1D,-$2D, $2D
	dc.w	   0
unk_31930:
	dc.w	-$20, $27,-$22, $22
	dc.w	   0
unk_3193A:
	dc.w	 -$1, $19, -$8,  $8
	dc.w	   0
unk_31944:
	dc.w	 -$5,  $9, -$5,  $9
	dc.w	   0
unk_3194E:
	dc.w	-$13, $21,-$2B, $29
	dc.w	   0
unk_31958:
	dc.w	-$15, $1E,-$2C, $21
	dc.w	 -$7, $14, -$A,  $A
	dc.w	   0
unk_3196A:
	dc.w	-$10, $16,-$2C,  $6
	dc.w	-$13, $21,-$24, $1A
	dc.w	 -$4,  $E, -$A,  $8
	dc.w	   0
unk_31984:
	dc.w	-$14, $1D,-$2A, $20
	dc.w	 -$A, $13, -$9,  $7
	dc.w	  $6,  $8,-$21, $17
	dc.w	   0
unk_3199E:
	dc.w	-$14, $20,-$2C, $23
	dc.w	 -$7, $10, -$7,  $6
	dc.w	   0
unk_319B0:
	dc.w	-$13, $1F,-$2B, $1F
	dc.w	 -$7,  $F, -$B,  $A
	dc.w	   0
unk_319C2:
	dc.w	 -$C, $15,-$2D, $2D
	dc.w	  $9,  $C,-$2B, $18
	dc.w	   0
unk_319D4:
	dc.w	 -$C, $23,-$2D, $1B
	dc.w	-$12,  $9,-$13,  $7
	dc.w	 -$B, $15,-$10, $10
	dc.w	   0
unk_319EE:
	dc.w	 -$B, $22,-$2D, $1A
	dc.w	-$10, $1C,-$12, $11
	dc.w	   0
unk_31A00:
	dc.w	 -$E, $1A,-$2C, $2C
	dc.w	  $A,  $8,-$1F,  $D
	dc.w	   0
unk_31A12:
	dc.w	-$10, $1A,-$29, $27
	dc.w	  $A,  $7,-$21, $1F
	dc.w	   0
unk_31A24:
	dc.w	   0
unk_31A26:
	dc.w	 -$D, $19,-$10, $10
	dc.w	   0
unk_31A30:
	dc.w	   0
unk_31A32:
	dc.w	 -$9,  $F, -$5,  $5
	dc.w	   0
unk_31A3C:
	dc.w	 -$9,  $F, -$5,  $5
	dc.w	   0
unk_31A46:
	dc.w	   0
unk_31A48:
	dc.w	 -$D, $19,-$10, $10
	dc.w	   0
unk_31A52:
	dc.w	   0
unk_31A54:
	dc.w	 -$D, $19,-$10, $10
	dc.w	   0
unk_31A5E:
	dc.w	   0
unk_31A60:
	dc.w	 -$A, $14,-$19, $19
	dc.w	   0
unk_31A6A:
	dc.w	   0
unk_31A6C:
	dc.w	   0
unk_31A6E:
	dc.w	 -$5,  $A, -$B,  $B
	dc.w	   0
unk_31A78:
	dc.w	   0
unk_31A7A:
	dc.w	  $1,  $F, -$B,  $9
	dc.w	   0
unk_31A84:
	dc.w	   0
unk_31A86:
	dc.w	 -$7,  $F, -$F,  $E
	dc.w	   0
unk_31A90:
	dc.w	-$10, $10,  $1,  $3
	dc.w	   0
unk_31A9A:
	dc.w	 -$F,  $2,  $6,  $2
	dc.w	   0
unk_31AA4:
	dc.w	 -$2,  $4,  $1,  $F
	dc.w	   0
unk_31AAE:
	dc.w	   0
unk_31AB0:
	dc.w	 -$7,  $E, -$7,  $E
	dc.w	   0
unk_31ABA:
	dc.w	 -$7,  $E, -$7,  $E
	dc.w	   0
unk_31AC4:
	dc.w	 -$7,  $E, -$7,  $E
	dc.w	   0
unk_31ACE:
	dc.w	   0
unk_31AD0:
	dc.w	 -$A, $14,-$20, $20
	dc.w	   0
unk_31ADA:
	dc.w	 -$A, $14,-$20, $20
	dc.w	   0
unk_31AE4:
	dc.w	 -$A, $14,-$20, $20
	dc.w	   0
unk_31AEE:
	dc.w	 -$A, $14,-$20, $20
	dc.w	   0
unk_31AF8:
	dc.w	 -$A, $14,-$20, $20
	dc.w	   0
	dc.w	   0
unk_31B04:
	dc.w	 -$9, $14,-$1B, $1B
	dc.w	   0
unk_31B0E:
	dc.w	   0
unk_31B10:
	dc.w	 -$7,  $E, -$1,  $3
	dc.w	   0
unk_31B1A:
	dc.w	 -$3,  $E, -$2,  $4
	dc.w	   0
unk_31B24:
	dc.w	 -$8,  $7,   0,  $4
	dc.w	  $1,  $6, -$4,  $4
	dc.w	   0
unk_31B36:
	dc.w	 -$5,  $5,  $1,  $4
	dc.w	  $1,  $5, -$6,  $6
	dc.w	   0
unk_31B48:
	dc.w	 -$4,  $4,  $1,  $7
	dc.w	  $1,  $3, -$8,  $8
	dc.w	   0
unk_31B5A:
	dc.w	  $1,  $2, -$9,  $9
	dc.w	   0
unk_31B64:
	dc.w	 -$1,  $2, -$9,  $9
	dc.w	   0
unk_31B6E:
	dc.w	 -$3,  $E, -$2,  $4
	dc.w	   0
unk_31B78:
	dc.w	 -$8,  $7, -$4,  $5
	dc.w	  $1,  $6,  $1,  $4
	dc.w	   0
unk_31B8A:
	dc.w	 -$5,  $5, -$4,  $5
	dc.w	  $1,  $5,  $1,  $5
	dc.w	   0
unk_31B9C:
	dc.w	 -$4,  $5, -$8,  $8
	dc.w	  $1,  $3,  $1,  $7
	dc.w	   0
unk_31BAE:
	dc.w	  $1,  $2,  $1,  $8
	dc.w	   0
unk_31BB8:
	dc.w	 -$1,  $2,   0,  $9
	dc.w	   0
	dc.w	   0
unk_31BC4:
	dc.w	   0
unk_31BC6:
	dc.w	   0
unk_31BC8:
	dc.w	   0
unk_31BCA:
	dc.w	 -$2,  $5, -$6,  $3
	dc.w	   0
unk_31BD4:
	dc.w	   0
unk_31BD6:
	dc.w	   0
unk_31BD8:
	dc.w	   0
unk_31BDA:
	dc.w	 -$A, $14,-$12, $12
	dc.w	   0
unk_31BE4:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31BEE:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31BF8:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31C02:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31C0C:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31C16:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31C20:
	dc.w	   0
unk_31C22:
	dc.w	-$12, $1E,-$10, $10
	dc.w	   0
unk_31C2C:
	dc.w	 -$E, $17, -$F,  $F
	dc.w	   0
unk_31C36:
	dc.w	 -$B, $16, -$F,  $F
	dc.w	   0
	dc.w	   0
unk_31C42:
	dc.w	 -$F, $13,-$1B,  $D
	dc.w	 -$D, $1A, -$C,  $B
	dc.w	   0
unk_31C54:
	dc.w	 -$D, $13,-$1B,  $E
	dc.w	 -$E, $1D, -$B,  $A
	dc.w	   0
unk_31C66:
	dc.w	 -$E, $12,-$1B,  $D
	dc.w	-$10, $1E, -$B,  $A
	dc.w	   0
unk_31C78:
	dc.w	 -$E, $10,-$1B,  $C
	dc.w	 -$E, $1A, -$B,  $A
	dc.w	   0
unk_31C8A:
	dc.w	 -$D, $11,-$1B,  $D
	dc.w	-$11, $1D, -$B,  $A
	dc.w	   0
unk_31C9C:
	dc.w	 -$D, $10,-$1B,  $C
	dc.w	 -$F, $1D, -$C,  $B
	dc.w	   0
unk_31CAE:
	dc.w	 -$E, $12,-$1B,  $B
	dc.w	-$11, $1D, -$C,  $B
	dc.w	   0
unk_31CC0:
	dc.w	 -$E, $12,-$1B,  $C
	dc.w	-$10, $1E, -$B,  $A
	dc.w	   0
unk_31CD2:
	dc.w	   0
unk_31CD4:
	dc.w	 -$3,  $6, -$8,  $8
	dc.w	   0
unk_31CDE:
	dc.w	   0
unk_31CE0:
	dc.w	 -$E, $1C,-$1B, $18
	dc.w	   0
unk_31CEA:
	dc.w	   0
unk_31CEC:
	dc.w	-$1F, $3E,-$70, $70
	dc.w	-$10, $20,   0, $10
	dc.w	 -$8, $10, $10, $10
	dc.w	   0
unk_31D06:
	dc.w	   0
unk_31D08:
	dc.w	 -$4,  $6, -$4,  $6
	dc.w	   0
unk_31D12:
	dc.w	   0
unk_31D14:
	dc.w	 -$8,  $E, -$8,  $E
	dc.w	   0
unk_31D1E:
	dc.w	 -$8,  $E, -$8,  $E
	dc.w	   0
unk_31D28:
	dc.w	   0
unk_31D2A:
	dc.w	   0
unk_31D2C:
	dc.w	 -$8,  $E, -$8,  $E
	dc.w	   0
unk_31D36:
	dc.w	-$10, $1C,-$10, $1C
	dc.w	   0
unk_31D40:
	dc.w	 -$4,  $8, -$4,  $8
	dc.w	   0
unk_31D4A:
	dc.w	   0
unk_31D4C:
	dc.w	-$10, $20,-$40, $38
	dc.w	   0
unk_31D56:
	dc.w	   0
unk_31D58:
	dc.w	   0
unk_31D5A:
	dc.w	   0
unk_31D5C:
	dc.w	   0
unk_31D5E:
	dc.w	 -$5,  $A, -$A,  $A
	dc.w	   0
unk_31D68:
	dc.w	   0
unk_31D6A:
	dc.w	  $F,   0,  $F,   0
	dc.w	   0
unk_31D74:
	dc.w	   0
unk_31D76:
	dc.w	   0
unk_31D78:
	dc.w	   0
unk_31D7A:
	dc.w	 -$5,  $A, -$A,  $A
	dc.w	   0
unk_31D84:
	dc.w	 -$6,  $C, -$8, $10
	dc.w	   0
unk_31D8E:
	dc.w	   0
unk_31D90:
	dc.w	 -$1,  $2, -$1,  $2
	dc.w	   0
unk_31D9A:
	dc.w	 -$2,  $4, -$2,  $4
	dc.w	   0
unk_31DA4:
	dc.w	 -$3,  $6, -$3,  $6
	dc.w	   0
unk_31DAE:
	dc.w	 -$4,  $8, -$4,  $8
	dc.w	   0
unk_31DB8:
	dc.w	 -$5,  $A, -$5,  $A
	dc.w	   0
unk_31DC2:
	dc.w	 -$6,  $C, -$6,  $C
	dc.w	   0
unk_31DCC:
	dc.w	 -$7,  $E, -$7,  $E
	dc.w	   0
unk_31DD6:
	dc.w	 -$E, $1C,-$1C, $1C
	dc.w	   0
unk_31DE0:
	dc.w	   0
	dc.w	   0
unk_31DE4:
	dc.w	 -$1,  $8,   0, $10
	dc.w	   0
unk_31DEE:
	dc.w	 -$1,  $8,   0, $18
	dc.w	   0
unk_31DF8:
	dc.w	 -$1,  $8,   0, $20
	dc.w	   0
unk_31E02:
	dc.w	 -$1,  $8,   0, $28
	dc.w	   0
unk_31E0C:
	dc.w	 -$1,  $8,   0, $30
	dc.w	   0
unk_31E16:
	dc.w	 -$1,  $8,   0, $38
	dc.w	   0
unk_31E20:
	dc.w	 -$1,  $8,   0, $40
	dc.w	   0
unk_31E2A:
	dc.w	 -$1,  $8,   0, $48
	dc.w	   0
unk_31E34:
	dc.w	 -$1,  $8,   0, $50
	dc.w	   0
unk_31E3E:
	dc.w	 -$6,  $C, -$6,  $C
	dc.w	   0
unk_31E48:
	dc.w	   0

	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF
	dc.b $FF

; filler
    rept 308
	dc.b	$FF
    endm

; =============== S U B	R O U T	I N E =======================================

;sub_31F86
j_loc_31F8E:
	jmp	loc_31F8E(pc)

; =============== S U B	R O U T	I N E =======================================

;sub_31F8A
j_Manage_EnemyLoading:
	jmp	Manage_EnemyLoading(pc)
; ---------------------------------------------------------------------------

loc_31F8E:
	lea	(EnemyStatus_Table).w,a0
	move.w	#$1E,d0
	subq.w	#1,d0
	moveq	#0,d1

loc_31F9A:
	move.w	d1,(a0)+
	dbf	d0,loc_31F9A
	move.b	#$FF,($FFFFF940).w
	move.l	#0,($FFFFF942).w
	move.l	(Addr_EnemyLayoutHeader).w,a0
	move.l	(Addr_EnemyLayout).w,a1
	move.w	(Camera_X_pos).w,d1
	move.b	#0,($FFFFF93F).w
	move.w	(a0)+,d0
	beq.s	loc_31FCE
	move.w	(Camera_Y_pos).w,d1
	move.b	#1,($FFFFF93F).w

loc_31FCE:
	addi.l	#8,a0

loc_31FD4:
	cmp.w	(a0),d1
	blt.s	loc_31FE6
	addi.l	#8,a0
	move.w	(a1)+,d2
	lsl.w	#3,d2
	add.w	d2,a1
	bra.s	loc_31FD4
; ---------------------------------------------------------------------------

loc_31FE6:
	move.l	a1,(Addr_EnemyLayout).w
	move.w	(a0),(EnemyHeader7D).w
	suba.l	#8,a0
	move.w	(a0),($FFFFF93C).w
	move.l	a0,(Addr_EnemyLayoutHeader).w
	lea	(EnemyStatus_Table).w,a2
	move.w	(a1)+,d7
	andi.w	#$FF,d7
	subq.w	#1,d7
	bmi.s	loc_3204E

loc_3200A:
	clr.w	d0
	move.b	1(a1),d0
	beq.s	loc_32044
	bmi.s	loc_32036
	subq.w	#1,d0
	move.w	d0,d1
	ror.w	#4,d0
	add.w	d1,d1
	lea	(unk_3680C).l,a3
	or.w	(a3,d1.w),d0
	ori.w	#$C000,d0
	move.w	d0,(a2)+
	lea	8(a1),a1
	dbf	d7,loc_3200A
	bra.s	loc_3204E
; ---------------------------------------------------------------------------

loc_32036:
	move.w	#$8000,(a2)+
	lea	8(a1),a1
	dbf	d7,loc_3200A
	bra.s	loc_3204E
; ---------------------------------------------------------------------------

loc_32044:
	clr.w	(a2)+
	lea	8(a1),a1
	dbf	d7,loc_3200A

loc_3204E:
	bsr.w	Load_EnemyArtPaletteToVRAM
	rts
; ---------------------------------------------------------------------------
; check whether object is within range, i.e. close enough to the part of the
; level that's currently on screen
;loc_32054
Object_CheckInRange:
	cmpi.w	#$14,(Number_Objects).w
	ble.s	Object_CheckInRange_NormalRange
;Object_CheckInRange_CloseRange:
	; if there are many objects, the range outside of which we unload
	; them is smaller
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7
	cmpi.w	#-$104,d7
	blt.s	Object_OutOfRange
	cmpi.w	#$244,d7
	bgt.s	Object_OutOfRange
	; object is within x range
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#-$104,d7
	blt.s	Object_OutOfRange
	cmpi.w	#$1E4,d7
	bgt.s	Object_OutOfRange
	; object is within y range
	rts
; ---------------------------------------------------------------------------
; Object is too far away, so it'll be deleted.
;loc_32086
Object_OutOfRange:
	moveq	#0,d0
	move.b	$42(a5),d0
	bpl.s	loc_320A6
	btst	#6,d0
	beq.s	loc_320B4
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_320B4
; ---------------------------------------------------------------------------

loc_320A6:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_320B4:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
;loc_320B8
Object_CheckInRange_NormalRange:
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7

loc_320C0:
	cmpi.w	#-$1A4,d7
	blt.s	Object_OutOfRange
	cmpi.w	#$2E4,d7
	bgt.s	Object_OutOfRange
	; object is within x range
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#-$1A4,d7

loc_320D8:
	blt.s	Object_OutOfRange
	cmpi.w	#$284,d7
	bgt.s	Object_OutOfRange
	; object is within y range
	rts
; ---------------------------------------------------------------------------

loc_320E2:
	cmpi.w	#$14,(Number_Objects).w
	ble.s	loc_3211A
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7
	cmpi.w	#$FEFC,d7
	blt.s	loc_32116
	cmpi.w	#$244,d7
	bgt.s	loc_32116
	move.w	y_pos(a3),d7

loc_32102:
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#$FEFC,d7
	blt.s	loc_32116
	cmpi.w	#$1E4,d7
	bgt.s	loc_32116
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_32116:
	moveq	#1,d7
	rts
; ---------------------------------------------------------------------------

loc_3211A:
	move.w	x_pos(a3),d7
	sub.w	(Camera_X_pos).w,d7

loc_32122:
	cmpi.w	#$FE5C,d7
	blt.s	loc_32116
	cmpi.w	#$2E4,d7
	bgt.s	loc_32116
	move.w	y_pos(a3),d7
	sub.w	(Camera_Y_pos).w,d7
	cmpi.w	#$FE5C,d7
	blt.s	loc_32116
	cmpi.w	#$284,d7

loc_32140:
	bgt.s	loc_32116
	moveq	#0,d7
	rts
; ---------------------------------------------------------------------------

loc_32146:

	movem.l	d0-d1/a0,-(sp)
	moveq	#0,d1
	move.l	(Addr_EnemyLayoutHeader).w,a0
	move.w	2(a0),d7
	andi.w	#$FF,d7
	cmp.w	d7,d0	; is it the enemy type from the first slot?
	beq.s	loc_3216C
	addq.w	#1,d1

loc_3215E:
	move.w	4(a0),d7
	andi.w	#$FF,d7
	cmp.w	d7,d0	; is it the enemy type from the second slot?
	beq.s	loc_3216C
	addq.w	#1,d1

loc_3216C:
	; d1 is the slot this enemy type has been allocated
	lea	EnemyArt_PaletteLines(pc),a0
	move.b	(a0,d1.w),palette_line(a3)
	lea	EnemyArt_VRAMTileAddresses(pc),a0
	add.w	d1,d1

loc_3217C:
	move.w	(a0,d1.w),vram_tile(a3)
	movem.l	(sp)+,d0-d1/a0
	rts
; ---------------------------------------------------------------------------

loc_32188:
	move.l	a0,-(sp)
	move.l	(Addr_NextFreeGfxObjectSlot).w,a0
	_move.l	0(a0),(Addr_NextFreeGfxObjectSlot).w
	_move.l	0(a3),0(a0)
	_move.l	a0,0(a3)

loc_3219E:
	move.w	#1,$32(a0)
	addq.w	#1,(Number_GfxObjects).w
	move.l	a0,a1
	lea	4(a0),a0
	move.w	#$47,d7

loc_321B2:
	clr.b	(a0)+
	dbf	d7,loc_321B2
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------
;Enemy05_TarMonster_Init:
	include "code/enemy/Tar_Monster.asm"
; ---------------------------------------------------------------------------
;Enemy17_Hand_Init:
	include "code/enemy/Hand.asm"
; ---------------------------------------------------------------------------
;Enemy19_Fireball_Init:
	include "code/enemy/Fireball.asm"
; ---------------------------------------------------------------------------

loc_331D2:
	add.w	x_pos(a3),d1
	add.w	y_pos(a3),d0
	asr.w	#4,d0
	add.w	d0,d0
	lea	($FFFF4A04).l,a4
	move.w	(a4,d0.w),a4
	lsr.w	#4,d1
	add.w	d1,d1
	add.w	d1,a4
	move.w	(a4),d0
	andi.w	#$7000,d0
	rts
; ---------------------------------------------------------------------------

loc_331F6:
	move.w	d6,-(sp)
	add.w	x_pos(a3),d7
	move.w	y_pos(a3),d6
	addi.w	#$E,d6
	lsr.w	#4,d6
	add.w	d6,d6
	lea	($FFFF4A04).l,a4
	move.w	(a4,d6.w),a4
	lsr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4),d5
	suba.w	(Level_width_tiles).w,a4
	move.w	(a4),d6
	suba.w	(Level_width_tiles).w,a4
	move.w	(a4),d7
	move.w	(sp)+,d4
	cmpi.w	#$3E7,d4
	beq.w	return_33284
	bclr	#$F,d5
	beq.w	loc_33248
	move.w	d5,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_33248
	moveq	#0,d5

loc_33248:
	andi.w	#$7000,d5
	bclr	#$F,d6
	beq.w	loc_33264
	move.w	d6,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_33264
	moveq	#0,d6

loc_33264:
	andi.w	#$7000,d6
	bclr	#$F,d7
	beq.w	loc_33280
	move.w	d7,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_33280
	moveq	#0,d7

loc_33280:
	andi.w	#$7000,d7

return_33284:
	rts
; ---------------------------------------------------------------------------

loc_33286:
	move.w	d6,-(sp)
	add.w	y_pos(a3),d7
	lsr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	move.w	x_pos(a3),d7
	subi.w	#$E,d7
	lsr.w	#4,d7
	add.w	d7,d7
	add.w	d7,a4
	move.w	(a4)+,d5
	move.w	(a4)+,d6
	move.w	(a4)+,d7
	move.w	(sp)+,d4
	cmpi.w	#$3E7,d4
	beq.w	return_3330C
	bclr	#$F,d5
	beq.w	loc_332D0
	move.w	d5,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_332D0
	moveq	#0,d5

loc_332D0:
	andi.w	#$7000,d5
	bclr	#$F,d6
	beq.w	loc_332EC
	move.w	d6,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_332EC
	moveq	#0,d6

loc_332EC:
	andi.w	#$7000,d6
	bclr	#$F,d7
	beq.w	loc_33308
	move.w	d7,d4
	andi.w	#$F00,d4
	cmpi.w	#$300,d4
	bne.w	loc_33308
	moveq	#0,d7

loc_33308:
	andi.w	#$7000,d7

return_3330C:
	rts
; ---------------------------------------------------------------------------

loc_3330E:
	add.w	x_pos(a3),d6
	add.w	y_pos(a3),d7
	lsr.w	#4,d7
	add.w	d7,d7
	lea	($FFFF4A04).l,a4
	move.w	(a4,d7.w),a4
	lsr.w	#4,d6
	add.w	d6,d6
	add.w	d6,a4
	move.w	(a4)+,d7
	andi.w	#$7000,d7
	rts
; ---------------------------------------------------------------------------
;Enemy16_Drip_Init:
	include "code/enemy/Drips.asm"
; ---------------------------------------------------------------------------
;Enemy07_Archer_Init:
	include "code/enemy/Archer.asm"
; ---------------------------------------------------------------------------

unk_34554:	dc.b $FF
	dc.b   1
	dc.b   2
	dc.b  $C
	dc.b $FF
	dc.b   2
	dc.b   4
	dc.b   9
	dc.b $FF
	dc.b   3
	dc.b   4
	dc.b   6
	dc.b $E1 ; �
	dc.b $9F ; �
	dc.b $FF
	dc.b   4
	dc.b   4
	dc.b   6
	dc.b $FE ; �
	dc.b   3
	dc.b   2
	dc.b   3
	dc.b $FE ; �
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b $FE ; �
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b $FE ; �
	dc.b   0
	dc.b   0
	dc.b   3
	dc.b $FE ; �
	dc.b $FF
	dc.b   6
	dc.b   3
	dc.b $FE ; �
	dc.b $FE ; �
	dc.b   6
	dc.b   3
	dc.b $FE ; �
	dc.b $FD ; �
	dc.b   6
	dc.b   3
	dc.b $FF
	dc.b $FC ; �
	dc.b   8
	dc.b   6
	dc.b $DD ; �
	dc.b $48 ; H
	dc.b $FF
	dc.b $FD ; �
	dc.b   8
	dc.b   6
	dc.b $FF
	dc.b $FE ; �
	dc.b   8
	dc.b   9
	dc.b $FF
	dc.b $FF
	dc.b   6
	dc.b  $C
	dc.b $D8 ; �
	dc.b $F1 ; �
	dc.b $FE ; �
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b $FF
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b $FF
	dc.b   2
	dc.b   2
	dc.b   5
	dc.b $FF
	dc.b   3
	dc.b   4
	dc.b   3
	dc.b $FF
	dc.b   5
	dc.b   4
	dc.b   3
	dc.b $FF
	dc.b   3
	dc.b   4
	dc.b   3
	dc.b $E1 ; �
	dc.b $9F ; �
	dc.b $FF
	dc.b   2
	dc.b   2
	dc.b   4
	dc.b $FF
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b $FE ; �
	dc.b   1
	dc.b   0
	dc.b   1
	dc.b $FE ; �
	dc.b   0
	dc.b   0
	dc.b   2
	dc.b $FE ; �
	dc.b $FF
	dc.b   0
	dc.b   1
	dc.b $FF
	dc.b $FF
	dc.b   6
	dc.b   3
	dc.b $FF
	dc.b $FE ; �
	dc.b   6
	dc.b   6
	dc.b $FF
	dc.b $FD ; �
	dc.b   8
	dc.b   6
	dc.b $DD ; �
	dc.b $48 ; H
	dc.b $FF
	dc.b $FE ; �
	dc.b   6
	dc.b  $A
	dc.b $FF
	dc.b $FF
	dc.b   6
	dc.b   5
	dc.b $FF
	dc.b $FF
	dc.b   6
	dc.b   3
	dc.b $FF
	dc.b $FF
	dc.b   0
	dc.b   3
	dc.b $D8 ; �
	dc.b $F1 ; �

stru_345E4: ; fireball and flying dragon?
	anim_frame	  1,   2, LnkTo_unk_E0F2E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F36-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F3E-Data_Index
	anim_frame	  1,   2, LnkTo_unk_E0F46-Data_Index
	dc.b 0
	dc.b 0

;Enemy0C_Dragon_flying_Init:
	include "code/enemy/Dragon_Flying.asm"
; ---------------------------------------------------------------------------
;Enemy0F_UFO_Init:
	include "code/enemy/UFO.asm"
; ---------------------------------------------------------------------------
;Enemy18_Tornado_Init: 
	include "code/enemy/Tornado.asm"
; ---------------------------------------------------------------------------
;Enemy0E_Cloud_Init:
	include "code/enemy/Cloud.asm"
; ---------------------------------------------------------------------------
;Enemy06_Sphere_Init: 
	include "code/enemy/Sphere.asm"
; ---------------------------------------------------------------------------
;Enemy1B_EmoRock_Init:	
	include "code/enemy/Emo_Rock.asm"
; ---------------------------------------------------------------------------
;Enemy1D_BigHoppingSkull_Init: 
	include "code/enemy/Big_Hopping_Skull.asm"
; ---------------------------------------------------------------------------

unk_3680C:
	dc.b   0
	dc.b $F0 ; �
	dc.b   1
	dc.b $E0 ; �
	dc.b   2
	dc.b $D0 ; �
	dc.b   3
	dc.b $C0 ; �
; ---------------------------------------------------------------------------
;loc_36814
Manage_EnemyLoading:
	tst.b	($FFFFFB6A).w
	bne.s	return_3682A
	cmpi.w	#$10,(Game_Mode).w ; intro video
	bne.s	loc_3682C
	cmpi.w	#L_Knights_Isle,(Current_LevelID).w ; load enemies in this level for intro video
	beq.s	loc_3682C

return_3682A:
	rts
; ---------------------------------------------------------------------------

loc_3682C:
	move.l	(Addr_EnemyLayout).w,a1
	move.w	(a1)+,d7
	andi.w	#$FF,d7
	move.w	d7,d6
	lea	(EnemyStatus_Table).w,a2
	bra.w	loc_36968
; ---------------------------------------------------------------------------

loc_36840:
	clr.b	d4
	move.w	(a2),d0
	beq.s	loc_368A8
	cmpi.w	#$FFFF,d0
	beq.w	loc_36962
	btst	#$D,d0
	bne.w	loc_3685E
	btst	#$E,d0
	beq.s	loc_368A6
	bra.s	loc_3686E
; ---------------------------------------------------------------------------

loc_3685E:
	move.w	d0,d1
	andi.w	#$3FF,d1
	beq.s	loc_368A8
	subi.w	#1,(a2)
	bra.w	loc_36962
; ---------------------------------------------------------------------------

loc_3686E:
	move.w	d0,d1
	andi.w	#$C00,d1
	cmpi.w	#$C00,d1
	beq.w	loc_36962
	subi.w	#1,(a2)
	subi.w	#1,d0
	move.w	d0,d1
	andi.w	#$3FF,d1
	bne.w	loc_36962
	move.w	d0,d1
	rol.w	#4,d1
	andi.w	#3,d1
	add.w	d1,d1
	lea	unk_3680C(pc),a4
	move.w	(a4,d1.w),d5
	or.w	d5,(a2)
	moveq	#1,d4
	bra.s	loc_368A8
; ---------------------------------------------------------------------------

loc_368A6:
	moveq	#2,d4

loc_368A8:
	move.w	4(a1),d0
	sub.w	(Camera_X_pos).w,d0
	move.w	6(a1),d1
	clr.w	d5
	move.b	($FFFFFAD2).w,d5
	lsl.w	#3,d5
	add.w	d5,d1
	sub.w	(Camera_Y_pos).w,d1
	cmpi.w	#$FF80,d0
	blt.w	loc_36962
	cmpi.w	#$1C0,d0
	bgt.w	loc_36962
	cmpi.w	#$FF80,d1
	blt.w	loc_36962
	cmpi.w	#$160,d1
	bgt.w	loc_36962
	tst.b	($FFFFFB51).w
	beq.s	loc_36900
	cmpi.w	#$FFE0,d0
	blt.s	loc_36900
	cmpi.w	#$160,d0
	bgt.s	loc_36900
	cmpi.w	#$FFE0,d1
	blt.s	loc_36900
	cmpi.w	#$100,d1
	ble.s	loc_36962

loc_36900:
	cmpi.b	#1,d4
	bne.s	loc_3690A
	addi.w	#$400,(a2)

loc_3690A:
	move.w	#1,a0
	move.b	(a1),d0
	ext.w	d0
	cmpi.w	#$17,d0
	bne.w	loc_3691E
	move.w	#$FFFF,a0

loc_3691E:
	jsr	(j_Allocate_ObjectSlot).w	; --> a5
	lea	(EnemyLoad_Index).l,a3
	clr.w	d0
	move.b	(a1),d0	; enemy ID
	lsl.w	#3,d0
	move.l	4(a3,d0.w),4(a0)	; code for object
	st	$10(a0)
	move.l	a1,$44(a0)
	move.w	d6,d0
	sub.w	d7,d0
	subq.w	#1,d0
	move.b	d0,$42(a0)
	cmpi.b	#1,d4
	blt.s	loc_3695E
	beq.s	loc_36956
	or.b	#$80,$42(a0)
	bra.s	loc_3695E
; ---------------------------------------------------------------------------

loc_36956:
	or.b	#$C0,$42(a0)
	bra.s	loc_36962
; ---------------------------------------------------------------------------

loc_3695E:
	move.w	#$FFFF,(a2)

loc_36962:
	addq.w	#2,a2
	lea	8(a1),a1

loc_36968:
	dbf	d7,loc_36840
	st	($FFFFFB51).w
	rts
; End of function j_Manage_EnemyLoading


; =============== S U B	R O U T	I N E =======================================


sub_36972:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d0
	move.w	d0,d1
	sub.w	$4A(a5),d0
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d2
	sub.w	d0,d2
	subq.w	#1,d2
	lea	($FFFF4A04).l,a0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	move.w	d0,d1
	sub.w	$48(a5),d0
	add.w	$48(a5),d1
	subq.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d3
	sub.w	d0,d3
	add.w	d0,d0
	lea	(a0,d0.w),a1
	moveq	#0,d7
	move.w	(Level_width_tiles).w,d4
	addq.w	#1,d1
	cmp.w	(Level_width_blocks).w,d1
	blt.s	loc_369C4
	addq.w	#3,d7
	bra.s	loc_369F6
; ---------------------------------------------------------------------------

loc_369C4:
	add.w	d1,d1
	lea	(a0,d1.w),a4
	moveq	#0,d0
	move.w	d2,d5

loc_369CE:
	or.w	(a4),d0
	add.w	d4,a4
	dbf	d5,loc_369CE
	andi.w	#$4000,d0
	beq.s	loc_369DE
	addq.w	#1,d7

loc_369DE:
	move.w	(a4),d0
	andi.w	#$7000,d0
	cmpi.w	#$5000,d0
	bne.s	loc_369EE
	addq.w	#1,d7
	bra.s	loc_369F6
; ---------------------------------------------------------------------------

loc_369EE:
	andi.w	#$4000,d0
	beq.s	loc_369F6
	addq.w	#2,d7

loc_369F6:
	moveq	#0,d5

loc_369F8:
	move.l	a1,a4
	move.w	d3,d0

loc_369FC:
	or.w	(a4)+,d5
	dbf	d0,loc_369FC
	add.w	d4,a1
	dbf	d2,loc_369F8
	andi.w	#$4000,d5
	beq.s	loc_36A10
	addq.w	#4,d7

loc_36A10:
	moveq	#0,d5
	moveq	#0,d6
	move.w	d3,d4
	move.w	(a1)+,d0
	andi.w	#$4000,d0
	beq.s	loc_36A4A
	bra.s	loc_36A2A
; ---------------------------------------------------------------------------

loc_36A20:
	move.w	(a1)+,d0
	or.w	d0,d5
	andi.w	#$4000,d0
	beq.s	loc_36A36

loc_36A2A:
	dbf	d3,loc_36A20
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36A36:
	moveq	#1,d6
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36A40:
	move.w	(a1)+,d0
	or.w	d0,d5
	andi.w	#$4000,d0
	bne.s	loc_36A36

loc_36A4A:
	dbf	d3,loc_36A40
	moveq	#-1,d6
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; End of function sub_36972


; =============== S U B	R O U T	I N E =======================================


sub_36A58:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d0
	move.w	d0,d1
	sub.w	$4A(a5),d0
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d2
	sub.w	d0,d2
	subq.w	#1,d2
	lea	($FFFF4A04).l,a0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	move.w	d0,d1
	sub.w	$48(a5),d0
	add.w	$48(a5),d1
	subq.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d3
	sub.w	d0,d3
	add.w	d0,d0
	lea	(a0,d0.w),a1
	moveq	#0,d7
	move.w	(Level_width_tiles).w,d4
	tst.w	d0
	bne.s	loc_36AA6
	moveq	#3,d7
	bra.s	loc_36AD6
; ---------------------------------------------------------------------------

loc_36AA6:
	lea	-2(a1),a4
	moveq	#0,d0
	move.w	d2,d5

loc_36AAE:
	or.w	(a4),d0
	add.w	d4,a4
	dbf	d5,loc_36AAE
	andi.w	#$4000,d0
	beq.s	loc_36ABE
	addq.w	#1,d7

loc_36ABE:
	move.w	(a4),d0
	andi.w	#$7000,d0
	cmpi.w	#$4000,d0
	bne.s	loc_36ACE
	addq.w	#1,d7
	bra.s	loc_36AD6
; ---------------------------------------------------------------------------

loc_36ACE:
	andi.w	#$4000,d0
	beq.s	loc_36AD6
	addq.w	#2,d7

loc_36AD6:
	moveq	#0,d5

loc_36AD8:
	move.l	a1,a4
	move.w	d3,d0

loc_36ADC:
	or.w	(a4)+,d5
	dbf	d0,loc_36ADC
	add.w	d4,a1
	dbf	d2,loc_36AD8
	andi.w	#$4000,d5
	beq.s	loc_36AF0
	addq.w	#4,d7

loc_36AF0:
	moveq	#0,d5
	moveq	#0,d6
	move.w	d3,d4
	add.w	d3,a1
	add.w	d3,a1
	move.w	(a1),d0
	andi.w	#$4000,d0
	beq.s	loc_36B2E
	bra.s	loc_36B0E
; ---------------------------------------------------------------------------

loc_36B04:
	move.w	-(a1),d0
	or.w	d0,d5
	andi.w	#$4000,d0
	beq.s	loc_36B1A

loc_36B0E:
	dbf	d3,loc_36B04
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36B1A:
	moveq	#1,d6
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36B24:
	move.w	-(a1),d0
	or.w	d0,d5
	andi.w	#$4000,d0
	bne.s	loc_36B1A

loc_36B2E:
	dbf	d3,loc_36B24
	moveq	#-1,d6
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; End of function sub_36A58


; =============== S U B	R O U T	I N E =======================================


sub_36B3C:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d0
	move.w	d0,d1
	sub.w	$4A(a5),d0
	subq.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	cmp.w	(Level_height_pixels).w,d1
	bcs.s	loc_36B5A
	move.w	(Level_height_pixels).w,d1
	subq.w	#1,d1

loc_36B5A:
	move.w	d1,d2
	sub.w	d0,d2
	lea	($FFFF4A04).l,a0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	move.w	d0,d1
	sub.w	$48(a5),d0
	add.w	$48(a5),d1
	subq.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d3
	sub.w	d0,d3
	add.w	d0,d0
	lea	(a0,d0.w),a1
	moveq	#0,d5
	moveq	#0,d6
	addq.w	#1,d1
	move.w	(Level_width_tiles).w,d4
	tst.w	d2
	bpl.s	loc_36BA0
	cmp.w	(Level_width_blocks).w,d1
	seq	d6
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36BA0:
	cmp.w	(Level_width_blocks).w,d1
	bne.s	loc_36BAA
	moveq	#1,d6
	bra.s	loc_36BBE
; ---------------------------------------------------------------------------

loc_36BAA:
	add.w	d1,d1
	lea	(a0,d1.w),a4
	move.w	d2,d0

loc_36BB2:
	or.w	(a4),d6
	add.w	d4,a4
	dbf	d0,loc_36BB2
	andi.w	#$4000,d6

loc_36BBE:
	move.l	a1,a4
	move.w	d3,d0

loc_36BC2:
	or.w	(a4)+,d5
	dbf	d0,loc_36BC2
	add.w	d4,a1
	dbf	d2,loc_36BBE
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; End of function sub_36B3C


; =============== S U B	R O U T	I N E =======================================


sub_36BD6:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d0
	move.w	d0,d1
	sub.w	$4A(a5),d0
	subi.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	cmp.w	(Level_height_pixels).w,d1
	bcs.s	loc_36BF6
	move.w	(Level_height_pixels).w,d1
	subq.w	#1,d1

loc_36BF6:
	move.w	d1,d2
	sub.w	d0,d2
	lea	($FFFF4A04).l,a0
	add.w	d0,d0
	move.w	(a0,d0.w),a0
	move.w	x_pos(a3),d0
	move.w	d0,d1
	sub.w	$48(a5),d0
	add.w	$48(a5),d1
	subq.w	#1,d1
	lsr.w	#4,d0
	lsr.w	#4,d1
	move.w	d1,d3
	sub.w	d0,d3
	add.w	d0,d0
	lea	(a0,d0.w),a1
	moveq	#0,d5
	moveq	#0,d6
	move.w	(Level_width_tiles).w,d4
	tst.w	d2
	bpl.s	loc_36C38
	tst.w	d1
	seq	d6
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36C38:
	tst.w	d0
	bne.s	loc_36C40
	moveq	#1,d6
	bra.s	loc_36C52
; ---------------------------------------------------------------------------

loc_36C40:
	lea	-2(a1),a4
	move.w	d2,d0

loc_36C46:
	or.w	(a4),d6
	add.w	d4,a4
	dbf	d0,loc_36C46
	andi.w	#$4000,d6

loc_36C52:
	move.l	a1,a4
	move.w	d3,d0

loc_36C56:
	or.w	(a4)+,d5
	dbf	d0,loc_36C56
	add.w	d4,a1
	dbf	d2,loc_36C52
	andi.w	#$4000,d5
	move.l	(sp)+,a0
	rts
; End of function sub_36BD6


; =============== S U B	R O U T	I N E =======================================


sub_36C6A:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d4
	subq.w	#1,d4
	lsr.w	#4,d4
	addq.w	#1,d4
	cmp.w	(Level_height_pixels).w,d4
	bcs.s	loc_36C82
	moveq	#0,d6
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36C82:
	lea	($FFFF4A04).l,a0
	add.w	d4,d4
	move.w	(a0,d4.w),a0
	move.w	x_pos(a3),d4
	move.w	d4,d5
	sub.w	$48(a5),d4
	add.w	$48(a5),d5
	subq.w	#1,d5
	lsr.w	#4,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d4,d4
	add.w	d4,a0
	moveq	#0,d6

loc_36CAA:
	or.w	(a0)+,d6
	dbf	d5,loc_36CAA
	andi.w	#$4000,d6
	move.l	(sp)+,a0
	rts
; End of function sub_36C6A


; =============== S U B	R O U T	I N E =======================================


sub_36CB8:
	move.l	a0,-(sp)
	move.w	y_pos(a3),d4
	sub.w	$4A(a5),d4
	lsr.w	#4,d4
	subq.w	#1,d4
	bpl.s	loc_36CCC
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36CCC:
	cmp.w	(Level_height_pixels).w,d4
	bcs.s	loc_36CD8
	moveq	#0,d6
	move.l	(sp)+,a0
	rts
; ---------------------------------------------------------------------------

loc_36CD8:
	lea	($FFFF4A04).l,a0
	add.w	d4,d4
	move.w	(a0,d4.w),a0
	move.w	x_pos(a3),d4
	move.w	d4,d5
	sub.w	$48(a5),d4
	add.w	$48(a5),d5
	subq.w	#1,d5
	lsr.w	#4,d4
	lsr.w	#4,d5
	sub.w	d4,d5
	add.w	d4,d4
	add.w	d4,a0
	moveq	#0,d6

loc_36D00:
	or.w	(a0)+,d6
	dbf	d5,loc_36D00
	andi.w	#$4000,d6
	move.l	(sp)+,a0
	rts
; End of function sub_36CB8


; =============== S U B	R O U T	I N E =======================================


Load_EnemyArtPaletteToVRAM:
	moveq	#0,d7
	move.l	(Addr_EnemyLayoutHeader).w,a1	; pointer to enemy layout
	addq.w	#2,a1

loc_36D16:
	move.w	(a1)+,d1
	move.w	d1,d4	; enemy ID whose art/palette to load
	cmpi.w	#$FFFF,d4
	beq.w	loc_36E42	; blank entry
	andi.w	#$FFF,d1
	lsl.w	#3,d1
	lea	EnemyLoad_Index(pc),a2
	lea	(a2,d1.w),a2
	move.w	(a2)+,d2
	move.w	(a2),d3
	lea	(Data_Index).l,a0
	move.w	d4,d1
	rol.w	#2,d1
	andi.w	#3,d1
	beq.s	loc_36D52
	cmpi.w	#1,d1
	beq.s	loc_36D4E
	addi.w	#4,d2

loc_36D4E:
	addi.w	#4,d2

loc_36D52:
	move.l	(a0,d2.w),a0
	move.w	d7,d0
	add.w	d0,d0
	lea	EnemyArt_VRAMAddresses(pc),a2
	move.w	(a2,d0.w),d0
	moveq	#0,d6
	andi.w	#$FFF,d4
	cmpi.w	#enemyid_Lion,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_invalid1F,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_UFO,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_Robot,d4
	beq.s	Load_EnemyArtToVRAM
	cmpi.w	#enemyid_HeadyMetal,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_Shiskaboss,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_BoomerangBosses,d4
	beq.s	Load_EnemyPaletteLong
	cmpi.w	#enemyid_BagelBrothers,d4
	beq.s	Load_EnemyPaletteLong
	bra.s	Load_EnemyPaletteNormal
; ---------------------------------------------------------------------------

Load_EnemyPaletteLong:
	; enemies with more palette entries
	lea	(Palette_Buffer+$42).l,a2
	moveq	#$E,d5

-
	move.w	(a0)+,(a2)+
	dbf	d5,-
	bra.w	Load_EnemyArtToVRAM
; ---------------------------------------------------------------------------

Load_EnemyPaletteNormal:
	cmpi.w	#1,d7
	beq.s	Load_EnemyPalette_SecondEnemy
	bge.s	Load_EnemyPalette_ThirdEnemy
	; first enemy type
	lea	(Palette_Buffer+$22).l,a2
	moveq	#6,d5

-
	move.w	(a0)+,(a2)+
	dbf	d5,-
	move.w	#0,(Palette_Buffer+$30).l
	bra.s	Load_EnemyArtToVRAM
; ---------------------------------------------------------------------------

Load_EnemyPalette_SecondEnemy:	; 2nd enemy type
	lea	(Palette_Buffer+$42).l,a2
	moveq	#6,d5

-
	move.w	(a0)+,(a2)+
	dbf	d5,-
	move.w	#0,(Palette_Buffer+$50).l
	bra.s	Load_EnemyArtToVRAM
; ---------------------------------------------------------------------------

Load_EnemyPalette_ThirdEnemy:	; 3rd enemy type
	lea	(Palette_Buffer+$52).l,a2
	moveq	#6,d5

-
	move.w	(a0)+,(a2)+
	dbf	d5,-
	move.w	#0,(Palette_Buffer+$50).l
	moveq	#1,d6

Load_EnemyArtToVRAM:
	lea	(Data_Index).l,a0
	move.l	(a0,d3.w),a0	; compressed art address
	movem.l	d7/a1,-(sp)
	tst.w	d7
	bne.s	loc_36E2C
	; first enemy type
	cmpi.w	#Forest,(Background_theme).w
	bne.s	loc_36E2C
	lea	unk_36E54(pc),a3
	cmpi.w	#enemyid_TarMonster,d4
	bne.s	loc_36E24
	lea	unk_36E64(pc),a3

loc_36E24:
	jsr	(j_DecompressToRAM).l
	bra.s	loc_36E3E
; ---------------------------------------------------------------------------

loc_36E2C:
	tst.w	d6
	beq.s	loc_36E38
	jsr	(j_DecompressToRAM_Special).l
	bra.s	loc_36E3E
; ---------------------------------------------------------------------------

loc_36E38:
	jsr	(j_DecompressToVRAM).l

loc_36E3E:
	movem.l	(sp)+,d7/a1

loc_36E42:
	addq.w	#1,d7
	cmpi.w	#3,d7
	bne.w	loc_36D16
	rts
; End of function Load_EnemyArtPaletteToVRAM

; ---------------------------------------------------------------------------
; 36E4E
; The games allows for three different enemies per level. Their art is loaded
; into 3 slots in VRAM, starting at the following addresses:
EnemyArt_VRAMAddresses:
	dc.w $5F60
	dc.w $8120
	dc.w $A2E0
unk_36E54:
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b  $A
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b  $E
	dc.b  $F
unk_36E64:
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b   7
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b  $E
	dc.b  $F
	dc.b   0
	dc.b   1
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   5
	dc.b   6
	dc.b   7
	dc.b  $F
	dc.b   9
	dc.b  $A
	dc.b  $B
	dc.b  $C
	dc.b  $D
	dc.b  $E
	dc.b  $F

; =============== S U B	R O U T	I N E =======================================


sub_36E84:
	move.l	(Addr_EnemyLayoutHeader).w,a4
	moveq	#0,d4
	move.w	2(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5	; is it the enemy type from the first slot?
	beq.s	loc_36EA6
	addq.w	#1,d4
	move.w	4(a4),d3
	andi.w	#$FFF,d3
	cmp.w	d3,d5	; is it the enemy type from the second slot?
	beq.s	loc_36EA6
	addq.w	#1,d4

loc_36EA6:
	; d4 is the slot this enemy type has been allocated
	lea	EnemyArt_PaletteLines(pc),a4
	move.b	(a4,d4.w),palette_line(a3)
	lea	EnemyArt_VRAMTileAddresses(pc),a4
	move.w	d4,$3E(a3)
	add.w	d4,d4
	move.w	(a4,d4.w),vram_tile(a3)
	rts
; End of function sub_36E84

; ---------------------------------------------------------------------------
EnemyLoad_Index:
	enemyloaddata	LnkTo_Pal_A1F4E-Data_Index, LnkTo_unk_CBC1C-Data_Index, Enemy00_FireDemon_Init	;00 - Fire demon
	enemyloaddata	LnkTo_Pal_A22D4-Data_Index, LnkTo_unk_DB2BC-Data_Index, Enemy01_Diamond_Init	;01 - Enemy diamond
	enemyloaddata	0, 0, 0
	enemyloaddata	LnkTo1_Pal_A2328-Data_Index,LnkTo_unk_DBA4D-Data_Index, Enemy03_Robot_Init	;03 - Alien robot
	enemyloaddata	LnkTo_Pal_A1F08-Data_Index, LnkTo_unk_CAD8E-Data_Index, Enemy04_Armadillo_Init	;04 - Armadillo
	enemyloaddata	LnkTo_Pal_A1FB0-Data_Index, LnkTo_unk_CCD87-Data_Index, Enemy05_TarMonster_Init	;05 - Tar monster
	enemyloaddata	LnkTo_Pal_A22AA-Data_Index, LnkTo_unk_DB03A-Data_Index, Enemy06_Sphere_Init	;06 - Sphere
	enemyloaddata	LnkTo_Pal_A22FE-Data_Index, LnkTo_unk_D744D-Data_Index, Enemy07_Archer_Init	;07 - Archer
	enemyloaddata	LnkTo_Pal_A1EFA-Data_Index, LnkTo_unk_CA1ED-Data_Index, Enemy08_Orca_Init	;08 - Orca
	enemyloaddata	LnkTo_Pal_A20AC-Data_Index, LnkTo_unk_D03E2-Data_Index, Enemy09_Crab_Init	;09 - Crab
	enemyloaddata	LnkTo_Pal_A21D8-Data_Index, LnkTo_unk_D8176-Data_Index, Enemy0A_RockTank_Init	;0A - Rock Tank
	enemyloaddata	LnkTo_Pal_A21D8-Data_Index, LnkTo_unk_D8176-Data_Index, Enemy0B_RockTank_shooting_Init	;0B - Rock Tank (shoots)
	enemyloaddata	LnkTo_Pal_A1ED0-Data_Index, LnkTo_unk_C8800-Data_Index, Enemy0C_Dragon_flying_Init	;0C - Flying dragon
	enemyloaddata	LnkTo_Pal_A1ED0-Data_Index, LnkTo_unk_C8800-Data_Index, Enemy0D_Dragon_Init	;0D - Walking dragon
	enemyloaddata	LnkTo_Pal_A2004-Data_Index, LnkTo_unk_CDAB8-Data_Index, Enemy0E_Cloud_Init	;0E - Cloud
	enemyloaddata	LnkTo2_Pal_A2328-Data_Index,LnkTo_unk_DC579-Data_Index, Enemy0F_UFO_Init	;0F - UFO
	enemyloaddata	LnkTo_Pal_A20D6-Data_Index, LnkTo_unk_D0B79-Data_Index, Enemy10_Goat_Init	;10 - Goat
	enemyloaddata	LnkTo_Pal_A212A-Data_Index, LnkTo_unk_D3151-Data_Index, Enemy11_Ninja_Init	;11 - Ninja
	enemyloaddata	LnkTo_Pal_A217E-Data_Index, LnkTo_unk_D4ED3-Data_Index, Enemy12_Lion_Init	;12 - Lion
	enemyloaddata	LnkTo_Pal_A2154-Data_Index, LnkTo_unk_D3D94-Data_Index, Enemy13_Scorpion_Init	;13 - Scorpion
	enemyloaddata	LnkTo_Pal_A2100-Data_Index, LnkTo_unk_D1ED8-Data_Index, Enemy14_SpinningTwins_Init	;14 - Spinning Twins
	enemyloaddata	0, 0, 0
	enemyloaddata	LnkTo_Pal_A2082-Data_Index, LnkTo_unk_CF71D-Data_Index, Enemy16_Drip_Init	;16 - Drip
	enemyloaddata	LnkTo_Pal_A2058-Data_Index, LnkTo_unk_CF02F-Data_Index, Enemy17_Hand_Init	;17 - Hand
	enemyloaddata	LnkTo_Pal_A1FDA-Data_Index, LnkTo_unk_CC7E0-Data_Index, Enemy18_Tornado_Init	;18 - Tornado
	enemyloaddata	LnkTo_Pal_A202E-Data_Index, LnkTo_unk_CE944-Data_Index, Enemy19_Fireball_Init	;19 - Fireball
	enemyloaddata	LnkTo_Pal_A2280-Data_Index, LnkTo_unk_DACAB-Data_Index, Enemy1A_Driller_Init	;1A - Driller
	enemyloaddata	LnkTo_Pal_A2202-Data_Index, LnkTo_unk_D88E7-Data_Index, Enemy1B_EmoRock_Init	;1B - Emo Rock
	enemyloaddata	LnkTo_Pal_A2256-Data_Index, LnkTo_unk_DA75D-Data_Index, Enemy1C_MiniHoppingSkull_Init	;1C - Mini hopping skull
	enemyloaddata	LnkTo_Pal_A222C-Data_Index, LnkTo_unk_D985D-Data_Index, Enemy1D_BigHoppingSkull_Init	;1D - Big hopping skull
	enemyloaddata	0, 0, 0
	enemyloaddata	0, 0, 0
	enemyloaddata	LnkTo_Pal_A2382-Data_Index, LnkTo_unk_DD8BB-Data_Index, Enemy20_HeadyMetal_Init	;20 - Heady Metal (final boss)
	enemyloaddata	LnkTo_Pal_A23A0-Data_Index, LnkTo_unk_DE3E3-Data_Index, sub_37332		;21 - Boss eyes/attacks
	enemyloaddata	LnkTo_Pal_A23AE-Data_Index, LnkTo_unk_DEA20-Data_Index, Enemy22_Shiskaboss_Init	;22 - Shiskaboss (all three heads)
	enemyloaddata	LnkTo_Pal_A23AE-Data_Index, LnkTo_unk_DEA20-Data_Index, Enemy23_BoomerangBosses_Init	;23 - Boomerang bosses (all three heads)
	enemyloaddata	LnkTo_Pal_A23AE-Data_Index, LnkTo_unk_DEA20-Data_Index, Enemy24_BagelBrothers_Init	;24 - Bagel Brothers (one head)
EnemyArt_PaletteLines:
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   0
EnemyArt_VRAMTileAddresses:
	dc.w   $2FB
	dc.w   $409
	dc.w   $517

; =============== S U B	R O U T	I N E =======================================

; used by most enemies
sub_36FF4:
	clr.w	d5
	move.b	($FFFFFAD2).w,d5
	lsl.w	#4,d5
	add.w	d5,y_pos(a3)
	rts
; End of function sub_36FF4


; =============== S U B	R O U T	I N E =======================================


sub_37002:
	move.l	d0,-(sp)
	moveq	#sfx_Boss_eye_pops,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$20,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	move.w	#(LnkTo_unk_C8460-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#4,$A(a3)
	jsr	(j_sub_FF6).w
	move.w	#$3C,d0

loc_37054:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	cmpi.w	#$1C,d7
	beq.s	loc_370C2
	cmpi.w	#$2C,d7
	beq.s	loc_370C2
	cmpi.w	#$FFFF,d7
	beq.s	loc_370C2
	clr.w	collision_type(a3)
	subq.w	#1,d0
	bne.s	loc_37078
	bra.s	loc_370C2
; ---------------------------------------------------------------------------

loc_37078:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d6
	move.w	y_pos(a3),d4
	cmp.w	d5,d3
	bgt.s	loc_3709E
	st	x_direction(a3)
	addi.l	#$FA0,x_vel(a3)
	bra.s	loc_370AA
; ---------------------------------------------------------------------------

loc_3709E:
	sf	x_direction(a3)
	addi.l	#-$FA0,x_vel(a3)

loc_370AA:
	cmp.w	d6,d4
	bgt.s	loc_370B8
	addi.l	#$FA0,y_vel(a3)
	bra.s	loc_370C0
; ---------------------------------------------------------------------------

loc_370B8:
	addi.l	#-$FA0,y_vel(a3)

loc_370C0:
	bra.s	loc_37054
; ---------------------------------------------------------------------------

loc_370C2:
	clr.w	collision_type(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	jmp	(j_Delete_CurrentObject).w
; End of function sub_37002


; =============== S U B	R O U T	I N E =======================================


sub_370D2:
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$20,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	move.w	#(LnkTo_unk_C8460-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#3,$A(a3)
	jsr	(j_sub_FF6).w
	move.w	#$78,d0
	move.l	#stru_37BD8,d7
	jsr	(j_Init_Animation).w

loc_3712E:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$2710,y_vel(a3)
	tst.b	$18(a3)
	beq.s	loc_3712E
	move.l	#0,y_vel(a3)

loc_37148:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	cmpi.w	#$1C,d7
	beq.s	loc_371B6
	cmpi.w	#$2C,d7
	beq.s	loc_371B6
	cmpi.w	#$FFFF,d7
	beq.s	loc_371B6
	clr.w	collision_type(a3)
	subq.w	#1,d0
	bne.s	loc_3716C
	bra.s	loc_371D4
; ---------------------------------------------------------------------------

loc_3716C:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d6
	move.w	y_pos(a3),d4
	cmp.w	d5,d3
	bgt.s	loc_37192
	st	x_direction(a3)
	addi.l	#$7D0,x_vel(a3)
	bra.s	loc_3719E
; ---------------------------------------------------------------------------

loc_37192:
	sf	x_direction(a3)
	addi.l	#-$7D0,x_vel(a3)

loc_3719E:
	cmp.w	d6,d4
	bgt.s	loc_371AC
	addi.l	#$7D0,y_vel(a3)
	bra.s	loc_371B4
; ---------------------------------------------------------------------------

loc_371AC:
	addi.l	#-$7D0,y_vel(a3)

loc_371B4:
	bra.s	loc_37148
; ---------------------------------------------------------------------------

loc_371B6:
	clr.w	collision_type(a3)
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	move.l	#stru_37BC6,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_371D4:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	move.b	($FFFFF809).w,d7
	andi.b	#1,d7
	beq.s	loc_371F4
	move.l	d0,-(sp)
	moveq	#sfx_Plethora_x,d0 ; NO SOUND!
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bra.s	loc_37200
; ---------------------------------------------------------------------------

loc_371F4:
	move.l	d0,-(sp)
	moveq	#sfx_Boss_dies,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0

loc_37200:
	move.l	#stru_37C0E,d7
	jsr	(j_Init_Animation).w

loc_3720A:
	jsr	(j_Hibernate_Object_1Frame).w
	move.w	collision_type(a3),d7
	cmpi.w	#$1C,d7
	beq.s	loc_371B6
	cmpi.w	#$2C,d7
	beq.s	loc_371B6
	cmpi.w	#$FFFF,d7
	beq.s	loc_371B6
	clr.w	collision_type(a3)
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d6
	move.w	y_pos(a3),d4
	cmp.w	d5,d3
	bgt.s	loc_37246
	st	x_direction(a3)
	bra.s	loc_3724A
; ---------------------------------------------------------------------------

loc_37246:
	sf	x_direction(a3)

loc_3724A:
	tst.b	$18(a3)
	beq.s	loc_3720A
	move.w	#$6000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_37002,4(a0)
	move.w	y_pos(a3),d6
	addi.w	#8,d6
	move.w	d6,$46(a0)
	tst.b	x_direction(a3)
	bne.s	loc_37280
	move.w	x_pos(a3),d5
	addi.w	#-5,d5
	move.w	d5,$44(a0)
	bsr.s	sub_3728C

loc_37280:
	move.w	x_pos(a3),d5
	addi.w	#5,d5
	move.w	d5,$44(a0)
; End of function sub_370D2


; =============== S U B	R O U T	I N E =======================================


sub_3728C:
	move.l	#stru_37BFC,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3728C


; =============== S U B	R O U T	I N E =======================================


sub_3729E:
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$20,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	$13(a3)
	st	is_moved(a3)
	sf	x_direction(a3)
	move.w	#(LnkTo_unk_C8460-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#1,$A(a3)
	jsr	(j_sub_FF6).w
	move.w	#$64,d0
	addq.b	#1,($FFFFFB4F).w
	move.l	#stru_37BEA,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w

loc_372F6:
	jsr	(j_Hibernate_Object_1Frame).w
	subq.w	#1,d0
	bne.s	loc_37300
	bra.s	loc_3731C
; ---------------------------------------------------------------------------

loc_37300:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	cmp.w	d5,d3
	bgt.s	loc_37316
	st	x_direction(a3)
	bra.s	loc_3731A
; ---------------------------------------------------------------------------

loc_37316:
	sf	x_direction(a3)

loc_3731A:
	bra.s	loc_372F6
; ---------------------------------------------------------------------------

loc_3731C:
	move.l	#stru_37BFC,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	subq.b	#1,($FFFFFB4F).w
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3729E


; =============== S U B	R O U T	I N E =======================================


sub_37332:
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	st	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	addq.w	#2,$A(a3)
	jsr	(j_sub_FF6).w
	move.w	#$FFFC,y_vel(a3)
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	cmp.w	d5,d3
	bge.s	loc_37394
	move.l	#$FFFF8001,x_vel(a3)
	bra.s	loc_3739C
; ---------------------------------------------------------------------------

loc_37394:
	move.l	#$7FFF,x_vel(a3)

loc_3739C:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$BB8,y_vel(a3)
	bsr.w	sub_37AF0
	move.w	d6,addroffset_sprite(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_373BE
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_373BE:
	bra.s	loc_3739C
; End of function sub_37332


; =============== S U B	R O U T	I N E =======================================


;sub_373C0:
Enemy20_HeadyMetal_Init:
	move.l	$44(a5),a0
	lea	($FFFFFB72).w,a2
	bsr.w	sub_3764A
	move.w	#(LnkTo_unk_C8430-Data_Index),$22(a1)
	move.w	#0,$3E(a1)
	move.w	#$1C2,$40(a1)
	move.w	#$C8,$42(a1)
	move.l	a1,(a2)+
	bsr.w	sub_3764A
	st	$16(a1)
	st	$3D(a1)
	move.w	#(LnkTo_unk_C8430-Data_Index),$22(a1)
	move.l	a1,(a2)+
	bsr.w	sub_3764A
	move.w	#(LnkTo_unk_C8438-Data_Index),$22(a1)
	addi.w	#$1F,$1E(a1)
	move.w	#$A,$3E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-$56,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-$46,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-$36,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-$26,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-$16,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#-$C,$1A(a1)
	addi.w	#-6,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-$56,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-$46,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-$36,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-$26,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-$16,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_37680
	move.w	#(LnkTo_unk_C8488-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-6,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_376B6
	move.w	#(LnkTo_unk_C8480-Data_Index),$22(a1)
	addi.w	#-$B,$1A(a1)
	addi.w	#-3,$1E(a1)
	move.l	a1,(a2)+
	bsr.w	sub_376B6
	move.w	#(LnkTo_unk_C8480-Data_Index),$22(a1)
	addi.w	#$C,$1A(a1)
	addi.w	#-3,$1E(a1)
	move.l	a1,(a2)+
	move.l	($FFFFFB7A).w,a3
	move.l	#stru_37B8A,d7
	jsr	(j_Init_Animation).w
	move.l	#0,d6
	move.l	#0,d7
	bsr.w	sub_376EC
	moveq	#$1E,d0

loc_37582:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$28,d4
	cmp.w	d5,d3
	bgt.s	loc_375AA
	move.l	#$8000,d6
	bra.s	loc_375B0
; ---------------------------------------------------------------------------

loc_375AA:
	move.l	#$FFFF8000,d6

loc_375B0:
	cmp.w	d7,d4
	bgt.s	loc_375BC
	move.l	#$4800,d7
	bra.s	loc_375C2
; ---------------------------------------------------------------------------

loc_375BC:
	move.l	#$FFFFB000,d7

loc_375C2:
	move.l	($FFFFFB72).w,a2
	cmpi.w	#4,$3E(a2)
	bge.s	loc_375D4
	move.l	#0,d6

loc_375D4:
	tst.b	($FFFFFB4F).w
	beq.s	loc_375DE
	clr.l	d6
	clr.l	d7

loc_375DE:
	bsr.w	sub_376EC
	move.l	($FFFFFB7A).w,a3
	tst.b	($FFFFFB4E).w
	bne.s	loc_3763A
	tst.b	$18(a3)
	beq.s	loc_3763A
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_370D2,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	subq.w	#1,$3E(a3)
	move.w	$3E(a3),d2
	bne.s	loc_3761E
	move.w	#$A,$3E(a3)

loc_3761E:
	cmpi.w	#6,d2
	blt.s	loc_37630
	move.l	#stru_37B98,d7
	jsr	(j_Init_Animation).w
	bra.s	loc_3763A
; ---------------------------------------------------------------------------

loc_37630:
	move.l	#stru_37BC0,d7
	jsr	(j_Init_Animation).w

loc_3763A:
	bsr.w	sub_37708
	bsr.w	sub_379E8
	bsr.w	sub_37ABC
	bra.w	loc_37582
; End of function Enemy20_HeadyMetal_Init


; =============== S U B	R O U T	I N E =======================================


sub_3764A:
	move.l	#$1010002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.w	4(a0),$1A(a1)
	move.w	6(a0),$1E(a1)
	move.b	#0,$10(a1)
	move.w	#$20,d0
	move.w	d0,$3A(a1)
	exg	a1,a3
	jsr	loc_32146(pc)
	exg	a1,a3
	st	$13(a1)
	st	$14(a1)
	rts
; End of function sub_3764A


; =============== S U B	R O U T	I N E =======================================


sub_37680:
	move.l	#$1000002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.w	4(a0),$1A(a1)
	move.w	6(a0),$1E(a1)
	move.b	#0,$10(a1)
	move.w	#$21,d0
	move.w	d0,$3A(a1)
	exg	a1,a3
	jsr	loc_32146(pc)
	exg	a1,a3
	st	$13(a1)
	st	$14(a1)
	rts
; End of function sub_37680


; =============== S U B	R O U T	I N E =======================================


sub_376B6:
	move.l	#$FF0002,a1
	jsr	(j_Allocate_GfxObjectSlot_a1).w
	move.w	4(a0),$1A(a1)
	move.w	6(a0),$1E(a1)
	move.b	#0,$10(a1)
	move.w	#$20,d0
	move.w	d0,$3A(a1)
	exg	a1,a3
	jsr	loc_32146(pc)
	exg	a1,a3
	st	$13(a1)
	st	$14(a1)
	rts
; End of function sub_376B6


; =============== S U B	R O U T	I N E =======================================


sub_376EC:
	moveq	#$10,d5
	lea	($FFFFFB72).w,a4

loc_376F2:
	move.l	(a4)+,d4
	beq.w	loc_37702
	move.l	d4,a3
	move.l	d6,x_vel(a3)
	move.l	d7,y_vel(a3)

loc_37702:
	dbf	d5,loc_376F2
	rts
; End of function sub_376EC


; =============== S U B	R O U T	I N E =======================================


sub_37708:
	tst.l	($FFFFFB72).w
	bne.s	loc_37710
	rts
; ---------------------------------------------------------------------------

loc_37710:
	move.l	($FFFFFB72).w,a3
	move.w	collision_type(a3),d7
	beq.w	loc_377BC
	clr.w	collision_type(a3)
	cmpi.w	#$2C,d7
	beq.s	loc_3772A
	bne.w	loc_377BC

loc_3772A:
	addi.w	#1,$3E(a3)
	move.w	$3E(a3),d7
	lea	(unk_3795E).l,a2
	lea	($FFFFFB7A).w,a3
	move.w	d7,d5
	add.w	d5,d5
	move.w	(a2,d5.w),d6
	add.w	d6,a3
	move.l	a3,a1
	move.l	(a3),a3
	cmpi.w	#$C,d7
	bgt.s	loc_37768
	addq.w	#2,$A(a3)
	jsr	(j_sub_FF6).w
	move.l	d0,-(sp)
	moveq	#sfx_Boss_eye_pops,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	bra.s	loc_377BC
; ---------------------------------------------------------------------------

loc_37768:
	cmpi.w	#$18,d7
	bgt.s	loc_37778
	subq.w	#2,$A(a3)
	jsr	(j_sub_FF6).w
	bra.s	loc_377BC
; ---------------------------------------------------------------------------

loc_37778:
	cmpi.w	#$24,d7
	bgt.s	loc_377BC
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_3729E,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#sub_37332,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	jsr	(j_loc_1078).w
	clr.l	(a1)

loc_377BC:
	move.l	($FFFFFB72).w,a3
	cmpi.w	#$25,$3E(a3)
	blt.w	return_3787A
	st	has_kid_collision(a3)
	st	($FFFFFB4E).w
	move.l	($FFFFFB72).w,a3
	tst.w	$40(a3)
	bne.s	loc_377F6
	move.l	($FFFFFA30).w,a4
	st	$13(a4)
	sf	$3D(a4)
	move.l	$3E(a4),a4
	st	$13(a4)
	bsr.w	sub_378C8
	rts
; ---------------------------------------------------------------------------

loc_377F6:
	move.l	#-$186A0,d6
	move.l	#$186A0,d7
	subq.w	#1,$40(a3)
	move.w	$40(a3),d1
	cmpi.w	#$15E,d1
	ble.s	loc_3781E
	move.l	#-$30D40,d6
	move.l	#$30D40,d7
	bra.s	loc_37866
; ---------------------------------------------------------------------------

loc_3781E:
	cmpi.w	#$FA,d1
	ble.s	loc_37832
	move.l	#-$493E0,d6
	move.l	#$493E0,d7
	bra.s	loc_37866
; ---------------------------------------------------------------------------

loc_37832:
	cmpi.w	#$96,d1
	ble.s	loc_37846
	move.l	#-$61A80,d6
	move.l	#$61A80,d7
	bra.s	loc_37866
; ---------------------------------------------------------------------------

loc_37846:
	cmpi.w	#$64,d1
	ble.s	loc_3785A
	move.l	#-$7A120,d6
	move.l	#$7A120,d7
	bra.s	loc_37866
; ---------------------------------------------------------------------------

loc_3785A:
	move.l	#-$927C0,d6
	move.l	#$927C0,d7

loc_37866:
	move.w	(Frame_Counter).w,d0
	andi.w	#2,d0
	bne.s	loc_37876
	bsr.w	sub_3787C
	bra.s	return_3787A
; ---------------------------------------------------------------------------

loc_37876:
	bsr.w	sub_378A2

return_3787A:
	rts
; End of function sub_37708


; =============== S U B	R O U T	I N E =======================================


sub_3787C:
	add.l	d6,x_vel(a3)
	move.l	($FFFFFB76).w,a3
	add.l	d7,x_vel(a3)
	move.l	($FFFFFB7A).w,a3
	add.l	d7,y_vel(a3)
	move.l	($FFFFFBAE).w,a3
	add.l	d6,x_vel(a3)
	move.l	($FFFFFBB2).w,a3
	add.l	d7,x_vel(a3)
	rts
; End of function sub_3787C


; =============== S U B	R O U T	I N E =======================================


sub_378A2:
	add.l	d7,x_vel(a3)
	move.l	($FFFFFB76).w,a3
	add.l	d6,x_vel(a3)
	move.l	($FFFFFB7A).w,a3
	add.l	d6,y_vel(a3)
	move.l	($FFFFFBAE).w,a3
	add.l	d7,x_vel(a3)
	move.l	($FFFFFBB2).w,a3
	add.l	d6,x_vel(a3)
	rts
; End of function sub_378A2


; =============== S U B	R O U T	I N E =======================================


sub_378C8:
	tst.b	($FFFFFB4E).w
	beq.s	loc_378D6
	subq.w	#1,$42(a3)
	bne.s	loc_378D6
	bra.s	loc_37922
; ---------------------------------------------------------------------------

loc_378D6:
	addi.l	#-$26D18,x_vel(a3)
	move.l	($FFFFFB76).w,a3
	addi.l	#$26D18,x_vel(a3)
	move.l	($FFFFFB7A).w,a3
	addi.l	#$13880,y_vel(a3)
	move.w	#(LnkTo_unk_C8458-Data_Index),addroffset_sprite(a3)
	move.l	d0,-(sp)
	moveq	#sfx_Boss_dies,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	($FFFFFBAE).w,a3
	addi.l	#-$26D18,x_vel(a3)
	move.l	($FFFFFBB2).w,a3
	addi.l	#$26D18,x_vel(a3)
	rts
; ---------------------------------------------------------------------------

loc_37922:
	lea	($FFFFFB72).w,a1
	move.l	($FFFFFB72).w,a3
	jsr	(j_loc_1078).w
	clr.l	(a1)+
	move.l	($FFFFFB76).w,a3
	jsr	(j_loc_1078).w
	clr.l	(a1)+
	move.l	($FFFFFB7A).w,a3
	jsr	(j_loc_1078).w
	clr.l	(a1)+
	lea	($FFFFFBAE).w,a1
	move.l	($FFFFFBAE).w,a3
	jsr	(j_loc_1078).w
	clr.l	(a1)+
	move.l	($FFFFFBB2).w,a3
	jsr	(j_loc_1078).w
	clr.l	(a1)
	rts
; End of function sub_378C8

; ---------------------------------------------------------------------------
unk_3795E:	dc.b   0
	dc.b   0
	dc.b   0
	dc.b $1C
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $28 ; (
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $2C ; ,
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b $1C
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $28 ; (
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $2C ; ,
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $1C
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b $28 ; (
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $2C ; ,
	dc.b   0
	dc.b $30 ; 0
unk_379A8:	dc.b   2
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   4
	dc.b   2
	dc.b   4
	dc.b   2
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   2
	dc.b   8
	dc.b   2
	dc.b   8
	dc.b   2
	dc.b  $A
	dc.b   2
	dc.b  $A
	dc.b   2
	dc.b  $C
	dc.b   2
	dc.b  $C
	dc.b   2
	dc.b  $E
	dc.b   2
	dc.b  $E
	dc.b   2
	dc.b  $E
	dc.b   2
	dc.b  $E
	dc.b   2
	dc.b  $C
	dc.b   2
	dc.b  $C
	dc.b   2
	dc.b  $A
	dc.b   2
	dc.b  $A
	dc.b   2
	dc.b   8
	dc.b   2
	dc.b   8
	dc.b   2
	dc.b   6
	dc.b   2
	dc.b   6
	dc.b   2
	dc.b   4
	dc.b   2
	dc.b   4
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   2
	dc.b   0
	dc.b   2
	dc.b   0

; =============== S U B	R O U T	I N E =======================================


sub_379E8:
	lea	unk_379A8(pc),a2
	addi.w	#1,d2
	andi.w	#$1F,d2
	move.w	d2,d7
	add.w	d7,d7
	move.w	(a2,d7.w),(Palette_Buffer+$5E).l
	rts
; End of function sub_379E8

; ---------------------------------------------------------------------------
off_37A02:	dc.w LnkTo_unk_C8488-Data_Index
	dc.w LnkTo_unk_C8490-Data_Index
	dc.w LnkTo_unk_C8498-Data_Index
	dc.w LnkTo_unk_C84A0-Data_Index
	dc.w LnkTo_unk_C84A8-Data_Index
	dc.w LnkTo_unk_C84B0-Data_Index
	dc.w LnkTo_unk_C84B8-Data_Index
	dc.w LnkTo_unk_C84C0-Data_Index
	dc.w LnkTo_unk_C84C8-Data_Index
	dc.w LnkTo_unk_C84D0-Data_Index
	dc.w LnkTo_unk_C84D8-Data_Index
	dc.w LnkTo_unk_C84E0-Data_Index
	dc.w LnkTo_unk_C84E8-Data_Index
	dc.w LnkTo_unk_C84F0-Data_Index
	dc.w LnkTo_unk_C84F8-Data_Index
	dc.w LnkTo_unk_C8500-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_37A22:
	tst.b	(Diamond_power_active).w
	beq.s	loc_37A3E
	move.b	($FFFFF809).w,d7
	andi.b	#8,d7
	beq.s	loc_37A38
	move.w	#(LnkTo_unk_C8488-Data_Index),d6
	bra.s	return_37A3C
; ---------------------------------------------------------------------------

loc_37A38:
	move.w	#(LnkTo_unk_C84A8-Data_Index),d6

return_37A3C:
	rts
; ---------------------------------------------------------------------------

loc_37A3E:
	movem.l	d2-d5/d7-a2,-(sp)
	move.l	(Addr_GfxObject_Kid).w,a1
	lea	off_37A02(pc),a2
	move.w	$1A(a1),d5
	move.w	$1E(a1),d7
	move.w	x_pos(a3),d3
	move.w	y_pos(a3),d4
	addq.w	#4,d4
	cmp.w	d4,d7
	bgt.s	loc_37A78
	addi.w	#-8,d4
	cmp.w	d4,d7
	blt.s	loc_37A94
	addi.w	#-8,d3
	cmp.w	d3,d5
	blt.s	loc_37A74
	moveq	#6,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37A74:
	moveq	#2,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37A78:
	addi.w	#-4,d3
	cmp.w	d3,d5
	blt.s	loc_37A8C
	addi.w	#8,d3
	cmp.w	d3,d5
	bgt.s	loc_37A90
	moveq	#4,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37A8C:
	moveq	#3,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37A90:
	moveq	#5,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37A94:
	addi.w	#-4,d3
	cmp.w	d3,d5
	blt.s	loc_37AA8
	addi.w	#8,d3
	cmp.w	d3,d5
	bgt.s	loc_37AAC
	moveq	#0,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37AA8:
	moveq	#1,d2
	bra.s	loc_37AAE
; ---------------------------------------------------------------------------

loc_37AAC:
	moveq	#7,d2

loc_37AAE:
	move.w	d2,d7
	add.w	d7,d7
	move.w	(a2,d7.w),d6
	movem.l	(sp)+,d2-d5/d7-a2
	rts
; End of function sub_37A22


; =============== S U B	R O U T	I N E =======================================


sub_37ABC:
	movem.l	a0,-(sp)
	lea	($FFFFFB7E).w,a0
	moveq	#$B,d5

loc_37AC6:
	move.l	(a0),d4
	beq.s	loc_37AD4
	move.l	d4,a3
	bsr.w	sub_37AF0
	move.w	d6,addroffset_sprite(a3)

loc_37AD4:
	addq.w	#4,a0
	dbf	d5,loc_37AC6
	movem.l	(sp)+,a0
	rts
; End of function sub_37ABC

; ---------------------------------------------------------------------------
off_37AE0:	dc.w LnkTo_unk_C8488-Data_Index
	dc.w LnkTo_unk_C8490-Data_Index
	dc.w LnkTo_unk_C8498-Data_Index
	dc.w LnkTo_unk_C84A0-Data_Index
	dc.w LnkTo_unk_C84A8-Data_Index
	dc.w LnkTo_unk_C84B0-Data_Index
	dc.w LnkTo_unk_C84B8-Data_Index
	dc.w LnkTo_unk_C84C0-Data_Index

; =============== S U B	R O U T	I N E =======================================


sub_37AF0:
	tst.b	(Diamond_power_active).w
	beq.s	loc_37B0C
	move.b	($FFFFF809).w,d6
	andi.b	#8,d6
	beq.s	loc_37B06
	move.w	#$E20,d6
	bra.s	return_37B0A
; ---------------------------------------------------------------------------

loc_37B06:
	move.w	#$E30,d6

return_37B0A:
	rts
; ---------------------------------------------------------------------------

loc_37B0C:
	movem.l	d2-d5/d7/a1,-(sp)
	move.l	(Addr_GfxObject_Kid).w,a1
	lea	off_37AE0(pc),a2
	move.w	$1A(a1),d5
	move.w	$1E(a1),d7
	move.w	x_pos(a3),d3
	move.w	y_pos(a3),d4
	addq.w	#4,d4
	cmp.w	d4,d7
	bgt.s	loc_37B46
	addi.w	#-8,d4
	cmp.w	d4,d7
	blt.s	loc_37B62
	addi.w	#-8,d3
	cmp.w	d3,d5
	blt.s	loc_37B42
	moveq	#6,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B42:
	moveq	#2,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B46:
	addi.w	#-4,d3
	cmp.w	d3,d5
	blt.s	loc_37B5A
	addi.w	#8,d3
	cmp.w	d3,d5
	bgt.s	loc_37B5E
	moveq	#4,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B5A:
	moveq	#3,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B5E:
	moveq	#5,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B62:
	addi.w	#-4,d3
	cmp.w	d3,d5
	blt.s	loc_37B76
	addi.w	#8,d3
	cmp.w	d3,d5
	bgt.s	loc_37B7A
	moveq	#0,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B76:
	moveq	#1,d2
	bra.s	loc_37B7C
; ---------------------------------------------------------------------------

loc_37B7A:
	moveq	#7,d2

loc_37B7C:
	move.w	d2,d7
	add.w	d7,d7
	move.w	(a2,d7.w),d6
	movem.l	(sp)+,d2-d5/d7/a1
	rts
; End of function sub_37AF0

; ---------------------------------------------------------------------------
stru_37B8A:
	anim_frame	  1, $96, LnkTo_unk_C8438-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8440-Data_Index
	anim_frame	  1, $28, LnkTo_unk_C8448-Data_Index
	dc.b   0
	dc.b   0
stru_37B98:
	anim_frame	  1, $2D, LnkTo_unk_C8458-Data_Index
	dc.b   2
	dc.b $13
	anim_frame	1, $32, LnkTo_unk_C8438-Data_Index
	anim_frame	1, 5, LnkTo_unk_C8440-Data_Index
	anim_frame	1, $14, LnkTo_unk_C8448-Data_Index
	dc.b   0
	dc.b   0
	anim_frame	1, $14, LnkTo_unk_C8458-Data_Index
	dc.b   2
	dc.b $13
	anim_frame	1, $19, LnkTo_unk_C8438-Data_Index
	anim_frame	1, 5, LnkTo_unk_C8440-Data_Index
	anim_frame	1, $F, LnkTo_unk_C8448-Data_Index
	dc.b   0
	dc.b   0
stru_37BC0:
	anim_frame	1, $A, LnkTo_unk_C8458-Data_Index
	dc.b   2
	dc.b $13
stru_37BC6:
	anim_frame	  1,  $A, LnkTo_unk_C8478-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8470-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8468-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8460-Data_Index
	dc.b   0
	dc.b   0
stru_37BD8:
	anim_frame	  1,   5, LnkTo_unk_C8460-Data_Index
	anim_frame	  1,   5, LnkTo_unk_C8468-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8470-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8478-Data_Index
	dc.b   0
	dc.b   0
stru_37BEA:
	anim_frame	  1,  $A, LnkTo_unk_C8460-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8468-Data_Index
	anim_frame	  1, $64, LnkTo_unk_C8470-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8478-Data_Index
	dc.b   0
	dc.b   0
stru_37BFC:
	anim_frame	  1, $32, LnkTo_unk_C8478-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8470-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8468-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8460-Data_Index
	dc.b   0
	dc.b   0
stru_37C0E:
	anim_frame	1, $64, LnkTo_unk_C8478-Data_Index
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

;loc_37C14:
Enemy24_BagelBrothers_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39478,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	#1,$1E(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39022,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_390BA,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39598,4(a0)
	addi.w	#-$96,y_pos(a3)
	addi.w	#-$64,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	#1,$1E(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39152,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_391EA,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_396BE,4(a0)
	addi.w	#-$12C,y_pos(a3)
	addi.w	#0,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	#1,$1E(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39282,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3931A,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

;loc_37DB4:
Enemy23_BoomerangBosses_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_37F30,4(a0)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38C92,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38D2A,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38012,4(a0)
	addi.w	#-$C8,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38DC2,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38E5A,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_380F4,4(a0)
	addi.w	#-$1C2,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38EF2,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38F8A,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_37F30:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$23,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#BoomerangBoss_HitPointsPerHead,$3E(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB7A).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_398F0).l,a2
	moveq	#1,d0
	move.w	#1,d1

loc_37F80:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39952
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_37F94
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_37F94:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_37F80
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_37F80
	cmp.w	d5,d3
	bgt.s	loc_37FC2
	st	x_direction(a3)
	bra.s	loc_37FC6
; ---------------------------------------------------------------------------

loc_37FC2:
	sf	x_direction(a3)

loc_37FC6:
	move.b	x_direction(a3),($FFFFFB86).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_37FD6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39952
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_37FEA
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_37FEA:
	tst.b	$18(a3)
	beq.s	loc_37FD6
	bsr.w	sub_397E4

loc_37FF4:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39952
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_38008
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_38008:
	tst.b	$18(a3)
	beq.s	loc_37FF4
	bra.w	loc_37F80
; ---------------------------------------------------------------------------

loc_38012:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$23,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#BoomerangBoss_HitPointsPerHead,$3E(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB7E).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39988).l,a2
	moveq	#1,d0
	move.w	#1,d1

loc_38062:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_399E4
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_38076
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_38076:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_38062
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_38062
	cmp.w	d5,d3
	bgt.s	loc_380A4
	st	x_direction(a3)
	bra.s	loc_380A8
; ---------------------------------------------------------------------------

loc_380A4:
	sf	x_direction(a3)

loc_380A8:
	move.b	x_direction(a3),($FFFFFB87).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_380B8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_399E4
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_380CC
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_380CC:
	tst.b	$18(a3)
	beq.s	loc_380B8
	bsr.w	sub_397E4

loc_380D6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_399E4
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_380EA
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_380EA:
	tst.b	$18(a3)
	beq.s	loc_380D6
	bra.w	loc_38062
; ---------------------------------------------------------------------------

loc_380F4:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$23,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#BoomerangBoss_HitPointsPerHead,$3E(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB82).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39A1A).l,a2
	moveq	#1,d0
	move.w	#1,d1

loc_38144:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39A7C
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_38158
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_38158:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_38144
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_38144
	cmp.w	d5,d3
	bgt.s	loc_38186
	st	x_direction(a3)
	bra.s	loc_3818A
; ---------------------------------------------------------------------------

loc_38186:
	sf	x_direction(a3)

loc_3818A:
	move.b	x_direction(a3),($FFFFFB88).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_3819A:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39A7C
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_381AE
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_381AE:
	tst.b	$18(a3)
	beq.s	loc_3819A
	bsr.w	sub_397E4

loc_381B8:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39A7C
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_381CC
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_381CC:
	tst.b	$18(a3)
	beq.s	loc_381B8
	bra.w	loc_38144
; ---------------------------------------------------------------------------

;loc_381D6:
Enemy22_Shiskaboss_Init:
	move.l	#$1000002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39478,4(a0)	; head 1
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38902,4(a0)	; eye 1
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3899A,4(a0)	; eye 2
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_39598,4(a0)	; head 2
	addi.w	#$48,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38A32,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38ACA,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_396BE,4(a0)	; head 3
	addi.w	#$90,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38B62,4(a0)
	addi.w	#-$25,y_pos(a3)
	addi.w	#-$C,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#$FFFF,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38BFA,4(a0)
	addi.w	#$18,x_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.l	$44(a5),a0
	move.w	4(a0),x_pos(a3)
	move.w	6(a0),y_pos(a3)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38494,4(a0)	; skewer pieces?
	addi.w	#-$5A,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38512,4(a0)
	addi.w	#$28,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38590,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3860E,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3868C,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3870A,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38788,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38806,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_38884,4(a0)
	addi.w	#$20,y_pos(a3)
	move.w	x_pos(a3),$44(a0)
	move.w	y_pos(a3),$46(a0)
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38494:
	; skewer piece 1
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F8-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_384D6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_384E8
	bra.s	loc_384D6
; ---------------------------------------------------------------------------

loc_384E8:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$FFFF2000,x_vel(a3)

loc_384F6:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38510
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38510:
	bra.s	loc_384F6
; ---------------------------------------------------------------------------

loc_38512:
	; skewer piece 2
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_38554:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_38566
	bra.s	loc_38554
; ---------------------------------------------------------------------------

loc_38566:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$E000,x_vel(a3)

loc_38574:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_3858E
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3858E:
	bra.s	loc_38574
; ---------------------------------------------------------------------------

loc_38590:
	; skewer piece 3
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_385D2:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_385E4
	bra.s	loc_385D2
; ---------------------------------------------------------------------------

loc_385E4:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$FFFF4000,x_vel(a3)

loc_385F2:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_3860C
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3860C:
	bra.s	loc_385F2
; ---------------------------------------------------------------------------

loc_3860E:
	; skewer piece 4
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_38650:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_38662
	bra.s	loc_38650
; ---------------------------------------------------------------------------

loc_38662:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$C000,x_vel(a3)

loc_38670:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_3868A
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3868A:
	bra.s	loc_38670
; ---------------------------------------------------------------------------

loc_3868C:
	; skewer piece 5
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_386CE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_386E0
	bra.s	loc_386CE
; ---------------------------------------------------------------------------

loc_386E0:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$FFFF6000,x_vel(a3)

loc_386EE:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38708
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38708:
	bra.s	loc_386EE
; ---------------------------------------------------------------------------

loc_3870A:
	; skewer piece 6
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_3874C:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_3875E
	bra.s	loc_3874C
; ---------------------------------------------------------------------------

loc_3875E:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$A000,x_vel(a3)

loc_3876C:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38786
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38786:
	bra.s	loc_3876C
; ---------------------------------------------------------------------------

loc_38788:
	; skewer piece 7
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_387CA:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_387DC
	bra.s	loc_387CA
; ---------------------------------------------------------------------------

loc_387DC:
	move.w	#$FFF9,y_vel(a3)
	move.l	#$FFFF8000,x_vel(a3)

loc_387EA:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38804
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38804:
	bra.s	loc_387EA
; ---------------------------------------------------------------------------

loc_38806:
	; skewer piece 8
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85F0-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_38848:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_3885A
	bra.s	loc_38848
; ---------------------------------------------------------------------------

loc_3885A:
	move.w	#$FFF8,y_vel(a3)
	move.l	#$8000,x_vel(a3)

loc_38868:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38882
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38882:
	bra.s	loc_38868
; ---------------------------------------------------------------------------

loc_38884:
	; skewer piece 9
	move.l	#$1010002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$22,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C85E8-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0

loc_388C6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_39846
	cmpi.b	#3,($FFFFFB4E).w
	beq.s	loc_388D8
	bra.s	loc_388C6
; ---------------------------------------------------------------------------

loc_388D8:
	move.w	#$FFFA,y_vel(a3)
	move.l	#$FFFF6000,x_vel(a3)

loc_388E6:
	jsr	(j_Hibernate_Object_1Frame).w
	addi.l	#$1B58,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38900
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38900:
	bra.s	loc_388E6
; ---------------------------------------------------------------------------

loc_38902:
	move.l	#$1020002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_3893E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_38962
	move.b	$16(a2),d0
	bra.s	loc_3893E
; ---------------------------------------------------------------------------

loc_38962:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_38976:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38998
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38998:
	bra.s	loc_38976
; ---------------------------------------------------------------------------

loc_3899A:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_389D6:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_389FA
	move.b	$16(a2),d0
	bra.s	loc_389D6
; ---------------------------------------------------------------------------

loc_389FA:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38A0E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38A30
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38A30:
	bra.s	loc_38A0E
; ---------------------------------------------------------------------------

loc_38A32:
	move.l	#$1020002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38A6E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_38A92
	move.b	$16(a2),d0
	bra.s	loc_38A6E
; ---------------------------------------------------------------------------

loc_38A92:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_38AA6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38AC8
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38AC8:
	bra.s	loc_38AA6
; ---------------------------------------------------------------------------

loc_38ACA:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38B06:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_38B2A
	move.b	$16(a2),d0
	bra.s	loc_38B06
; ---------------------------------------------------------------------------

loc_38B2A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38B3E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38B60
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38B60:
	bra.s	loc_38B3E
; ---------------------------------------------------------------------------

loc_38B62:
	move.l	#$1020002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38B9E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_38BC2
	move.b	$16(a2),d0
	bra.s	loc_38B9E
; ---------------------------------------------------------------------------

loc_38BC2:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#-$4000,x_vel(a3)

loc_38BD6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38BF8
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38BF8:
	bra.s	loc_38BD6
; ---------------------------------------------------------------------------

loc_38BFA:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38C36:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_38C5A
	move.b	$16(a2),d0
	bra.s	loc_38C36
; ---------------------------------------------------------------------------

loc_38C5A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38C6E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38C90
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38C90:
	bra.s	loc_38C6E
; ---------------------------------------------------------------------------

loc_38C92:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38CCE:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_38CF2
	move.b	$16(a2),d0
	bra.s	loc_38CCE
; ---------------------------------------------------------------------------

loc_38CF2:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_38D06:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38D28
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38D28:
	bra.s	loc_38D06
; ---------------------------------------------------------------------------

loc_38D2A:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38D66:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_38D8A
	move.b	$16(a2),d0
	bra.s	loc_38D66
; ---------------------------------------------------------------------------

loc_38D8A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38D9E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38DC0
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38DC0:
	bra.s	loc_38D9E
; ---------------------------------------------------------------------------

loc_38DC2:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38DFE:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_38E22
	move.b	$16(a2),d0
	bra.s	loc_38DFE
; ---------------------------------------------------------------------------

loc_38E22:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_38E36:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38E58
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38E58:
	bra.s	loc_38E36
; ---------------------------------------------------------------------------

loc_38E5A:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38E96:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_38EBA
	move.b	$16(a2),d0
	bra.s	loc_38E96
; ---------------------------------------------------------------------------

loc_38EBA:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38ECE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38EF0
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38EF0:
	bra.s	loc_38ECE
; ---------------------------------------------------------------------------

loc_38EF2:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38F2E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_38F52
	move.b	$16(a2),d0
	bra.s	loc_38F2E
; ---------------------------------------------------------------------------

loc_38F52:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_38F66:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_38F88
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_38F88:
	bra.s	loc_38F66
; ---------------------------------------------------------------------------

loc_38F8A:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#1,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_38FC6:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_38FEA
	move.b	$16(a2),d0
	bra.s	loc_38FC6
; ---------------------------------------------------------------------------

loc_38FEA:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_38FFE:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_39020
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_39020:
	bra.s	loc_38FFE
; ---------------------------------------------------------------------------

loc_39022:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_3905E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_39082
	move.b	$16(a2),d0
	bra.s	loc_3905E
; ---------------------------------------------------------------------------

loc_39082:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_39096:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_390B8
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_390B8:
	bra.s	loc_39096
; ---------------------------------------------------------------------------

loc_390BA:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_390F6:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7A).w,a2
	move.b	($FFFFFB86).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB72).w
	bne.s	loc_3911A
	move.b	$16(a2),d0
	bra.s	loc_390F6
; ---------------------------------------------------------------------------

loc_3911A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_3912E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_39150
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_39150:
	bra.s	loc_3912E
; ---------------------------------------------------------------------------

loc_39152:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_3918E:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_391B2
	move.b	$16(a2),d0
	bra.s	loc_3918E
; ---------------------------------------------------------------------------

loc_391B2:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_391C6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_391E8
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_391E8:
	bra.s	loc_391C6
; ---------------------------------------------------------------------------

loc_391EA:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_39226:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB7E).w,a2
	move.b	($FFFFFB87).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB74).w
	bne.s	loc_3924A
	move.b	$16(a2),d0
	bra.s	loc_39226
; ---------------------------------------------------------------------------

loc_3924A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_3925E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_39280
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_39280:
	bra.s	loc_3925E
; ---------------------------------------------------------------------------

loc_39282:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_392BE:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_393C8
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_392E2
	move.b	$16(a2),d0
	bra.s	loc_392BE
; ---------------------------------------------------------------------------

loc_392E2:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$FFFFC000,x_vel(a3)

loc_392F6:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_39318
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_39318:
	bra.s	loc_392F6
; ---------------------------------------------------------------------------

loc_3931A:
	move.l	#$1030002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8488-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	sf	d0

loc_39356:
	jsr	(j_Hibernate_Object_1Frame).w
	move.l	($FFFFFB82).w,a2
	move.b	($FFFFFB88).w,d2
	bsr.w	sub_39420
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	tst.w	($FFFFFB76).w
	bne.s	loc_3937A
	move.b	$16(a2),d0
	bra.s	loc_39356
; ---------------------------------------------------------------------------

loc_3937A:
	jsr	(sub_393B2).l
	move.w	#$FFFD,y_vel(a3)
	move.l	#$4000,x_vel(a3)

loc_3938E:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_37A22
	move.w	d6,addroffset_sprite(a3)
	addi.l	#$7D0,y_vel(a3)
	move.w	y_pos(a3),d5
	cmp.w	(Level_height_blocks).w,d5
	ble.s	loc_393B0
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_393B0:
	bra.s	loc_3938E

; =============== S U B	R O U T	I N E =======================================


sub_393B2:
	move.l	d0,-(sp)
	moveq	#sfx_Boss_eye_pops,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	addq.w	#4,$A(a3)
	jsr	(j_sub_FF6).w
	rts
; End of function sub_393B2


; =============== S U B	R O U T	I N E =======================================


sub_393C8:
	move.w	$22(a2),d6
	subi.w	#$EE0,d6
	asr.w	#1,d6
	move.w	word_39416(pc,d6.w),d7
	tst.b	d2
	beq.s	loc_393DE
	move.w	word_3940C(pc,d6.w),d7

loc_393DE:
	add.w	$1A(a2),d7
	move.w	d7,x_pos(a3)
	move.w	$1E(a2),y_pos(a3)
	subi.w	#$25,y_pos(a3)
	cmp.b	$16(a2),d0
	beq.s	return_3940A
	tst.b	d0
	beq.s	loc_39402
	subq.w	#1,$A(a3)
	bra.s	loc_39406
; ---------------------------------------------------------------------------

loc_39402:
	addq.w	#1,$A(a3)

loc_39406:
	jsr	(j_sub_FF6).w

return_3940A:
	rts
; End of function sub_393C8

; ---------------------------------------------------------------------------
word_3940C:	dc.w $FFF4
	dc.w 0
	dc.w $D
	dc.w $D
	dc.w $D
word_39416:	dc.w $FFF4
	dc.w $FFEC
	dc.w $FFE8
	dc.w $FFE8
	dc.w $FFE8

; =============== S U B	R O U T	I N E =======================================


sub_39420:
	move.w	$22(a2),d6
	subi.w	#$EE0,d6
	asr.w	#1,d6
	move.w	word_3946E(pc,d6.w),d7
	tst.b	d2
	beq.s	loc_39436
	move.w	word_39464(pc,d6.w),d7

loc_39436:
	add.w	$1A(a2),d7
	move.w	d7,x_pos(a3)
	move.w	$1E(a2),y_pos(a3)
	subi.w	#$25,y_pos(a3)
	cmp.b	$16(a2),d0
	beq.s	return_39462
	tst.b	d0
	bne.s	loc_3945A
	subq.w	#1,$A(a3)
	bra.s	loc_3945E
; ---------------------------------------------------------------------------

loc_3945A:
	addq.w	#1,$A(a3)

loc_3945E:
	jsr	(j_sub_FF6).w

return_39462:
	rts
; End of function sub_39420

; ---------------------------------------------------------------------------
word_39464:	dc.w	$C
	dc.w   $14
	dc.w   $18
	dc.w   $18
	dc.w   $18
word_3946E:	dc.w $C
	dc.b   0
	dc.b   0
	dc.b $FF
	dc.b $F3 ; �
	dc.b $FF
	dc.b $F3 ; �
	dc.b $FF
	dc.b $F3 ; �
; ---------------------------------------------------------------------------

loc_39478:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$22,d0
	tst.w	d2
	beq.s	loc_39494
	move.w	#$24,d0

loc_39494:
	; head 1
	move.w	d0,object_meta(a3)
	bset	#7,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB7A).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0
	move.w	#0,d1
	tst.w	d2
	beq.s	loc_394E2
	lea	(unk_39AB2).l,a2
	move.w	#BagelBrothers_HitPointsPerHead,$3E(a3)
	bra.s	loc_394E8
; ---------------------------------------------------------------------------

loc_394E2:
	move.w	#ShishkaBoss_HitPointsPerHead,$3E(a3)

loc_394E8:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_394F6
	bsr.w	sub_398BC
	bra.s	loc_394FA
; ---------------------------------------------------------------------------

loc_394F6:
	bsr.w	sub_39BF8

loc_394FA:
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_39506
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_39506:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_394E8
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_394E8
	cmp.w	d5,d3
	bgt.s	loc_39534
	st	x_direction(a3)
	bra.s	loc_39538
; ---------------------------------------------------------------------------

loc_39534:
	sf	x_direction(a3)

loc_39538:
	move.b	x_direction(a3),($FFFFFB86).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_39548:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_39556
	bsr.w	sub_398BC
	bra.s	loc_3955A
; ---------------------------------------------------------------------------

loc_39556:
	bsr.w	sub_39BF8

loc_3955A:
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_39566
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_39566:
	tst.b	$18(a3)
	beq.s	loc_39548
	bsr.w	sub_397E4

loc_39570:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_3957E
	bsr.w	sub_398BC
	bra.s	loc_39582
; ---------------------------------------------------------------------------

loc_3957E:
	bsr.w	sub_39BF8

loc_39582:
	move.w	d7,($FFFFFB72).w
	tst.w	d7
	beq.s	loc_3958E
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_3958E:
	tst.b	$18(a3)
	beq.s	loc_39570
	bra.w	loc_394E8
; ---------------------------------------------------------------------------

loc_39598:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$22,d0
	tst.w	d2
	beq.s	loc_395B4
	move.w	#$24,d0

loc_395B4:
	; head 2
	move.w	d0,object_meta(a3)
	bset	#7,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#$1E,$3E(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB7E).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0
	move.w	#0,d1
	tst.w	d2
	beq.s	loc_39608
	lea	(unk_39C2E).l,a2
	move.w	#BagelBrothers_HitPointsPerHead,$3E(a3)
	bra.s	loc_3960E
; ---------------------------------------------------------------------------

loc_39608:
	move.w	#ShishkaBoss_HitPointsPerHead,$3E(a3)

loc_3960E:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_3961C
	bsr.w	sub_398BC
	bra.s	loc_39620
; ---------------------------------------------------------------------------

loc_3961C:
	bsr.w	sub_39D4A

loc_39620:
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_3962C
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_3962C:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_3960E
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_3960E
	cmp.w	d5,d3
	bgt.s	loc_3965A
	st	x_direction(a3)
	bra.s	loc_3965E
; ---------------------------------------------------------------------------

loc_3965A:
	sf	x_direction(a3)

loc_3965E:
	move.b	x_direction(a3),($FFFFFB87).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_3966E:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_3967C
	bsr.w	sub_398BC
	bra.s	loc_39680
; ---------------------------------------------------------------------------

loc_3967C:
	bsr.w	sub_39D4A

loc_39680:
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_3968C
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_3968C:
	tst.b	$18(a3)
	beq.s	loc_3966E
	bsr.w	sub_397E4

loc_39696:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_396A4
	bsr.w	sub_398BC
	bra.s	loc_396A8
; ---------------------------------------------------------------------------

loc_396A4:
	bsr.w	sub_39D4A

loc_396A8:
	move.w	d7,($FFFFFB74).w
	tst.w	d7
	beq.s	loc_396B4
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_396B4:
	tst.b	$18(a3)
	beq.s	loc_39696
	bra.w	loc_3960E
; ---------------------------------------------------------------------------

loc_396BE:
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$22,d0
	tst.w	d2
	beq.s	loc_396DA
	move.w	#$24,d0

loc_396DA:
	; head 3
	move.w	d0,object_meta(a3)
	bset	#7,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#$1E,$3E(a3)
	move.w	#(LnkTo_unk_C8600-Data_Index),addroffset_sprite(a3)
	move.l	a3,($FFFFFB82).w
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	lea	(unk_39872).l,a2
	moveq	#1,d0
	move.w	#0,d1
	tst.w	d2
	beq.s	loc_3972E
	lea	(unk_39D80).l,a2
	move.w	#BagelBrothers_HitPointsPerHead,$3E(a3)
	bra.s	loc_39734
; ---------------------------------------------------------------------------

loc_3972E:
	move.w	#ShishkaBoss_HitPointsPerHead,$3E(a3)

loc_39734:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_39742
	bsr.w	sub_398BC
	bra.s	loc_39746
; ---------------------------------------------------------------------------

loc_39742:
	bsr.w	sub_39EB4

loc_39746:
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_39752
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_39752:
	move.l	(Addr_GfxObject_Kid).w,a1
	move.w	$1A(a1),d5
	move.w	x_pos(a3),d3
	move.w	$1E(a1),d7
	move.w	y_pos(a3),d4
	addi.w	#-$40,d4
	cmp.w	d4,d7
	blt.s	loc_39734
	addi.w	#$40,d4
	cmp.w	d4,d7
	bgt.s	loc_39734
	cmp.w	d5,d3
	bgt.s	loc_39780
	st	x_direction(a3)
	bra.s	loc_39784
; ---------------------------------------------------------------------------

loc_39780:
	sf	x_direction(a3)

loc_39784:
	move.b	x_direction(a3),($FFFFFB88).w
	move.l	#stru_39FC6,d7
	jsr	(j_Init_Animation).w

loc_39794:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_397A2
	bsr.w	sub_398BC
	bra.s	loc_397A6
; ---------------------------------------------------------------------------

loc_397A2:
	bsr.w	sub_39EB4

loc_397A6:
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_397B2
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_397B2:
	tst.b	$18(a3)
	beq.s	loc_39794
	bsr.w	sub_397E4

loc_397BC:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.w	d2
	bne.s	loc_397CA
	bsr.w	sub_398BC
	bra.s	loc_397CE
; ---------------------------------------------------------------------------

loc_397CA:
	bsr.w	sub_39EB4

loc_397CE:
	move.w	d7,($FFFFFB76).w
	tst.w	d7
	beq.s	loc_397DA
	bra.w	loc_39EBE
; ---------------------------------------------------------------------------

loc_397DA:
	tst.b	$18(a3)
	beq.s	loc_397BC
	bra.w	loc_39734

; =============== S U B	R O U T	I N E =======================================


sub_397E4:
	tst.w	d1
	bne.s	loc_397FA
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3A0D2,4(a0)
	bra.s	loc_3980A
; ---------------------------------------------------------------------------

loc_397FA:
	move.w	#0,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3A1EA,4(a0)

loc_3980A:
	move.w	x_pos(a3),d6
	move.w	y_pos(a3),$46(a0)
	move.b	x_direction(a3),$49(a0)
	tst.b	x_direction(a3)
	bne.s	loc_3982C
	move.w	#$FFFD,$48(a0)
	addi.w	#-$18,d6
	bra.s	loc_39836
; ---------------------------------------------------------------------------

loc_3982C:
	move.w	#3,$48(a0)
	addi.w	#$18,d6

loc_39836:
	move.w	d6,$44(a0)
	move.l	#stru_39FD8,d7
	jsr	(j_Init_Animation).w
	rts
; End of function sub_397E4


; =============== S U B	R O U T	I N E =======================================


sub_39846:
	subq.w	#1,d0
	beq.s	loc_3984C
	rts
; ---------------------------------------------------------------------------

loc_3984C:
	move.w	(a2)+,d0
	bpl.s	loc_39858
	lea	(unk_39872).l,a2
	bra.s	loc_3984C
; ---------------------------------------------------------------------------

loc_39858:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_39846

; ---------------------------------------------------------------------------
; Shishka boss heads movement
unk_39872:
	dc.w	$168, 0, -1
	dc.w	$168, -1, 0
	dc.w	$168, 0, 1
	dc.w	$168, 1, 0
	dc.w	$B4, 0, -2
	dc.w	$1CC, -1, 0
	dc.w	$168, 0, 1
	dc.w	$E6, 2, 0
	dc.w	$B4, -1, 0
	dc.w	$12C, 0, 0
	dc.w	$B4, -1, 0
	dc.w	$168, 1, 0
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_398BC:
	bsr.s	sub_39846
	bsr.w	sub_3A292
	rts
; End of function sub_398BC


; =============== S U B	R O U T	I N E =======================================


sub_398C4:
	subq.w	#1,d0
	beq.s	loc_398CA
	rts
; ---------------------------------------------------------------------------

loc_398CA:
	move.w	(a2)+,d0
	bpl.s	loc_398D6
	lea	(unk_398F0).l,a2
	bra.s	loc_398CA
; ---------------------------------------------------------------------------

loc_398D6:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_398C4

; ---------------------------------------------------------------------------
; Boomerang boss head 1 movement
unk_398F0:
	dc.w	$96, 0, 0
	dc.w	$12C, 0, -1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$12C, 0, -1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$96, 0, 1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$96, 0, 1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$12C, 0, 1
	dc.w	$12C, 0, -2
	dc.w	$12C, 0, 2
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_39952:
	bsr.w	sub_398C4
	bsr.w	sub_3A292
	rts
; End of function sub_39952


; =============== S U B	R O U T	I N E =======================================


sub_3995C:
	subq.w	#1,d0
	beq.s	loc_39962
	rts
; ---------------------------------------------------------------------------

loc_39962:
	move.w	(a2)+,d0
	bpl.s	loc_3996E
	lea	(unk_39988).l,a2
	bra.s	loc_39962
; ---------------------------------------------------------------------------

loc_3996E:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_3995C

; ---------------------------------------------------------------------------
; Boomerang boss head 2 movement
unk_39988:
	dc.w	$12C, 0, -1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$12C, 0, -1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$96, 0, 1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$96, 0, 1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$12C, 0, 1
	dc.w	$12C, 0, -2
	dc.w	$12C, 0, 2
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_399E4:
	bsr.w	sub_3995C
	bsr.w	sub_3A292
	rts
; End of function sub_399E4


; =============== S U B	R O U T	I N E =======================================


sub_399EE:
	subq.w	#1,d0
	beq.s	loc_399F4
	rts
; ---------------------------------------------------------------------------

loc_399F4:
	move.w	(a2)+,d0
	bpl.s	loc_39A00
	lea	(unk_39A1A).l,a2
	bra.s	loc_399F4
; ---------------------------------------------------------------------------

loc_39A00:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_399EE

; ---------------------------------------------------------------------------
; Boomerang boss head 3 movement
unk_39A1A:
	dc.w	$C8, 0, 0
	dc.w	$12C, 0, -1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$12C, 0, -1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$96, 0, 1
	dc.w	$64, -1, 0
	dc.w	$64, 1, 0
	dc.w	$96, 0, 1
	dc.w	$64, 1, 0
	dc.w	$64, -1, 0
	dc.w	$12C, 0, 1
	dc.w	$C8, 0, -3
	dc.w	$C8, 0, 3
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_39A7C:
	bsr.w	sub_399EE
	bsr.w	sub_3A292
	rts
; End of function sub_39A7C


; =============== S U B	R O U T	I N E =======================================


sub_39A86:
	subq.w	#1,d0
	beq.s	loc_39A8C
	rts
; ---------------------------------------------------------------------------

loc_39A8C:
	move.w	(a2)+,d0
	bpl.s	loc_39A98
	lea	(unk_39AB2).l,a2
	bra.s	loc_39A8C
; ---------------------------------------------------------------------------

loc_39A98:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_39A86

; ---------------------------------------------------------------------------
; Bagel Brothers head movement
unk_39AB2:
	dc.w	$32, 0, 0
	dc.w	$1E, 0, -1
	dc.w	$384, -1, 0
	dc.w	$32, 0, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$32, 0, 0
	dc.w	$384, -1, 0
	dc.w	$32, 0, 0
	dc.w	$C8, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$C8, 0, 1
	dc.w	$96, 0, 0
	dc.w	$384, -1, 0
	dc.w	$96, 0, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$12C, -3, 0
	dc.w	$C8, 0, -1
	dc.w	$384, 1, 0
	dc.w	$1C2, -2, 0
	dc.w	$E1, 4, 0
	dc.w	$B4, -5, 0
	dc.w	$96, 6, 0
	dc.w	$C8, 0, 1
	dc.w	$32, 0, 0
	dc.w	$1E, 0, -1
	dc.w	$12C, -3, 0
	dc.w	$32, 0, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$96, 0, 0
	dc.w	$384, -1, 0
	dc.w	$96, 0, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$32, 0, 0
	dc.w	$E1, -4, 0
	dc.w	$C8, 0, -1
	dc.w	$384, 1, 0
	dc.w	$1C2, -2, 0
	dc.w	$32, 0, 0
	dc.w	$B4, 5, 0
	dc.w	$E1, -4, 0
	dc.w	$384, 1, 0
	dc.w	$C8, 0, 1
	dc.w	$64, 0, 0
	dc.w	$E1, -4, 0
	dc.w	$64, 0, 0
	dc.w	$64, 0, -1
	dc.w	$E1, 4, 0
	dc.w	$64, 0, 1
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_39BF8:
	bsr.w	sub_39A86
	bsr.w	sub_3A292
	rts
; End of function sub_39BF8


; =============== S U B	R O U T	I N E =======================================


sub_39C02:
	subq.w	#1,d0
	beq.s	loc_39C08
	rts
; ---------------------------------------------------------------------------

loc_39C08:
	move.w	(a2)+,d0
	bpl.s	loc_39C14
	lea	(unk_39C2E).l,a2
	bra.s	loc_39C08
; ---------------------------------------------------------------------------

loc_39C14:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_39C02

; ---------------------------------------------------------------------------
; Bagel Brothers head movement
unk_39C2E:
	dc.w	$1E, 0, -1
	dc.w	$384, -1, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$384, -1, 0
	dc.w	$32, 0, 0
	dc.w	$C8, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$C8, 0, 1
	dc.w	$96, 0, 0
	dc.w	$384, -1, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$12C, -3, 0
	dc.w	$C8, 0, -1
	dc.w	$384, 1, 0
	dc.w	$1C2, -2, 0
	dc.w	$E1, 4, 0
	dc.w	$12C, -3, 0
	dc.w	$96, 6, 0
	dc.w	$C8, 0, 1
	dc.w	$1E, 0, -1
	dc.w	$12C, -3, 0
	dc.w	$32, 0, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$384, -1, 0
	dc.w	$96, 0, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$12C, -3, 0
	dc.w	$C8, 0, -1
	dc.w	$384, 1, 0
	dc.w	$1C2, -2, 0
	dc.w	$32, 0, 0
	dc.w	$B4, 5, 0
	dc.w	$E1, -4, 0
	dc.w	$B4, 5, 0
	dc.w	$C8, 0, 1
	dc.w	$64, 0, 0
	dc.w	$12C, -3, 0
	dc.w	$1E, 0, 0
	dc.w	$64, 0, -1
	dc.w	$E1, 4, 0
	dc.w	$64, 0, 1
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_39D4A:
	bsr.w	sub_39C02
	bsr.w	sub_3A292
	rts
; End of function sub_39D4A


; =============== S U B	R O U T	I N E =======================================


sub_39D54:
	subq.w	#1,d0
	beq.s	loc_39D5A
	rts
; ---------------------------------------------------------------------------

loc_39D5A:
	move.w	(a2)+,d0
	bpl.s	loc_39D66
	lea	(unk_39D80).l,a2
	bra.s	loc_39D5A
; ---------------------------------------------------------------------------

loc_39D66:
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,x_vel(a3)
	moveq	#0,d7
	move.w	(a2)+,d7
	swap	d7
	asr.l	#1,d7
	move.l	d7,y_vel(a3)
	rts
; End of function sub_39D54

; ---------------------------------------------------------------------------
; Bagel Brothers head movement
unk_39D80:
	dc.w	$1E, 0, -1
	dc.w	$384, -1, 0
	dc.w	$32, 0, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$32, 0, 0
	dc.w	$384, -1, 0
	dc.w	$32, 0, 0
	dc.w	$C8, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$C8, 0, 1
	dc.w	$96, 0, 0
	dc.w	$384, -1, 0
	dc.w	$96, 0, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$12C, -3, 0
	dc.w	$C8, 0, -1
	dc.w	$E1, 4, 0
	dc.w	$B4, -5, 0
	dc.w	$96, 6, 0
	dc.w	$C8, 0, 1
	dc.w	$32, 0, 0
	dc.w	$1E, 0, -1
	dc.w	$12C, -3, 0
	dc.w	$32, 0, 0
	dc.w	$1E, 0, 1
	dc.w	$12C, 3, 0
	dc.w	$96, 0, 0
	dc.w	$384, -1, 0
	dc.w	$96, 0, 0
	dc.w	$64, 0, -1
	dc.w	$12C, 3, 0
	dc.w	$64, 0, 1
	dc.w	$32, 0, 0
	dc.w	$E1, -4, 0
	dc.w	$C8, 0, -1
	dc.w	$384, 1, 0
	dc.w	$1C2, -2, 0
	dc.w	$32, 0, 0
	dc.w	$B4, 5, 0
	dc.w	$E1, -4, 0
	dc.w	$384, 1, 0
	dc.w	$C8, 0, 1
	dc.w	$64, 0, 0
	dc.w	$E1, -4, 0
	dc.w	$64, 0, 0
	dc.w	$64, 0, -1
	dc.w	$E1, 4, 0
	dc.w	$64, 0, 1
	dc.w	$FFFF
; =============== S U B	R O U T	I N E =======================================


sub_39EB4:
	bsr.w	sub_39D54
	bsr.w	sub_3A292
	rts
; End of function sub_39EB4

; ---------------------------------------------------------------------------

loc_39EBE:
	st	has_kid_collision(a3)
	addq.b	#1,($FFFFFB4E).w
	cmpi.b	#3,($FFFFFB4E).w
	bne.s	loc_39EE2
	move.l	($FFFFFA30).w,a4
	st	$13(a4)
	sf	$3D(a4)
	move.l	$3E(a4),a4
	st	$13(a4)

loc_39EE2:
	move.l	#stru_39FEE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A004,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3A016,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A028,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3A03A,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A050,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3A062,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A074,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	d0,-(sp)
	moveq	#sfx_Boss_dies,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.w	#$A,d0

loc_39F7A:
	move.l	#stru_3A086,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A09C,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	move.l	#stru_3A0AE,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	eori.b	#$FF,x_direction(a3)
	move.l	#stru_3A0C0,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	subq.w	#1,d0
	bne.s	loc_39F7A
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------
stru_39FC6:
	anim_frame	  1, $14, LnkTo_unk_C8608-Data_Index
	anim_frame	  1, $28, LnkTo_unk_C8610-Data_Index
	anim_frame	  1, $19, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_39FD8:
	anim_frame	  1, $22, LnkTo_unk_C8620-Data_Index
	anim_frame	  1,   5, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,  $A, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_39FEE:
	anim_frame	  1,   6, LnkTo_unk_C8620-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A004:
	anim_frame	  1,   6, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   6, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_3A016:
	anim_frame	  1,   4, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A028:
	anim_frame	  1,   4, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_3A03A:
	anim_frame	  1,   2, LnkTo_unk_C8620-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A050:
	anim_frame	  1,   2, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_3A062:
	anim_frame	  1,   2, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A074:
	anim_frame	  1,   2, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   2, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_3A086:
	anim_frame	  1,   1, LnkTo_unk_C8620-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A09C:
	anim_frame	  1,   1, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
stru_3A0AE:
	anim_frame	  1,   1, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8600-Data_Index
	dc.b   0
	dc.b   0
stru_3A0C0:
	anim_frame	  1,   1, LnkTo_unk_C8608-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8610-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8618-Data_Index
	anim_frame	  1,   1, LnkTo_unk_C8620-Data_Index
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_3A0D2:
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$21,d0
	move.w	d0,object_meta(a3)
	jsr	loc_32146(pc)
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#$32,$40(a3)
	move.w	#$C8,$42(a3)
	move.w	#(LnkTo_unk_C8510-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.w	$48(a5),x_vel(a3)
	move.l	#stru_3A1CC,d7
	jsr	(j_Init_Animation).w

loc_3A134:
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#0,$40(a3)
	bne.s	loc_3A168
	clr.l	x_vel(a3)
	move.l	#stru_3A1D6,d7
	jsr	(j_Init_Animation).w

loc_3A14E:
	jsr	(j_Hibernate_Object_1Frame).w
	cmpi.w	#0,$42(a3)
	bne.s	loc_3A15E
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3A15E:
	subq.w	#1,$42(a3)
	bsr.w	sub_3A172
	bra.s	loc_3A14E
; ---------------------------------------------------------------------------

loc_3A168:
	subq.w	#1,$40(a3)
	bsr.w	sub_3A1A6
	bra.s	loc_3A134

; =============== S U B	R O U T	I N E =======================================


sub_3A172:
	move.w	collision_type(a3),d7
	beq.w	return_3A1A4
	clr.w	collision_type(a3)
	cmpi.w	#$1C,d7
	beq.s	loc_3A192
	cmpi.w	#$2C,d7
	beq.s	loc_3A192
	cmpi.w	#$FFFF,d7
	bne.w	return_3A1A4

loc_3A192:
	move.l	#stru_3A1E0,d7
	jsr	(j_Init_Animation).w
	jsr	(j_sub_105E).w
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

return_3A1A4:
	rts
; End of function sub_3A172


; =============== S U B	R O U T	I N E =======================================


sub_3A1A6:
	move.w	collision_type(a3),d7
	beq.w	return_3A1CA
	clr.w	collision_type(a3)
	cmpi.w	#$1C,d7
	beq.s	loc_3A1C6
	cmpi.w	#$2C,d7
	beq.s	loc_3A1C6
	cmpi.w	#$FFFF,d7
	bne.w	return_3A1CA

loc_3A1C6:
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

return_3A1CA:
	rts
; End of function sub_3A1A6

; ---------------------------------------------------------------------------
stru_3A1CC:
	anim_frame	1, 5, LnkTo_unk_C8510-Data_Index
	anim_frame	1, 5, LnkTo_unk_C8518-Data_Index
	dc.b   2
	dc.b   9
stru_3A1D6:
	anim_frame	1, 5, LnkTo_unk_C8520-Data_Index
	anim_frame	1, 5, LnkTo_unk_C8528-Data_Index
	dc.b   2
	dc.b   9
stru_3A1E0:
	anim_frame	1, 2, LnkTo_unk_C8510-Data_Index
	anim_frame	1, 2, LnkTo_unk_C8518-Data_Index
	dc.b   0
	dc.b   0
; ---------------------------------------------------------------------------

loc_3A1EA:
	move.l	d0,-(sp)
	moveq	#sfx_Voice_die,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	move.l	#$1040002,a3
	jsr	(j_Load_GfxObjectSlot).w
	move.b	#0,priority(a3)
	move.w	#$23,d0
	move.w	d0,object_meta(a3)
	jsr	(loc_32146).l
	sf	has_kid_collision(a3)
	st	$13(a3)
	st	is_moved(a3)
	move.w	#$190,$40(a3)
	move.w	#(LnkTo_unk_C8530-Data_Index),addroffset_sprite(a3)
	move.w	$44(a5),x_pos(a3)
	move.w	$46(a5),y_pos(a3)
	move.w	$48(a5),x_vel(a3)
	move.b	$48(a5),d0
	move.l	#stru_3A308,d7
	jsr	(j_Init_Animation).w

loc_3A24C:
	jsr	(j_Hibernate_Object_1Frame).w
	tst.b	d0
	beq.s	loc_3A25E
	addi.l	#$7D0,x_vel(a3)
	bra.s	loc_3A266
; ---------------------------------------------------------------------------

loc_3A25E:
	addi.l	#-$7D0,x_vel(a3)

loc_3A266:
	subq.w	#1,$40(a3)
	bne.s	loc_3A270
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3A270:
	cmpi.w	#0,x_pos(a3)
	bgt.s	loc_3A27C
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3A27C:
	move.w	x_pos(a3),d5
	cmp.w	(Level_width_pixels).w,d5
	ble.s	loc_3A28A
	jmp	(j_Delete_CurrentObject).w
; ---------------------------------------------------------------------------

loc_3A28A:
	bsr.w	sub_3A1A6
	bra.s	loc_3A24C
; ---------------------------------------------------------------------------
	rts

; =============== S U B	R O U T	I N E =======================================

; used by boss
sub_3A292:
	swap	d1
	move.w	collision_type(a3),d7
	beq.w	loc_3A2E0
	clr.w	collision_type(a3)
	cmpi.w	#$1C,d7
	beq.s	loc_3A2C0
	cmpi.w	#$2C,d7
	beq.s	loc_3A2C0
	tst.b	(Berzerker_charging).w
	beq.s	loc_3A2E0
	cmpi.w	#$20,d7
	beq.s	loc_3A2C0
	cmpi.w	#$24,d7
	beq.s	loc_3A2C0
	bne.s	loc_3A2E0

loc_3A2C0:
	move.b	#$A,d1
	move.l	d0,-(sp)
	moveq	#sfx_Big_Hopping_Skull_groan,d0
	jsr	(j_PlaySound).l
	move.l	(sp)+,d0
	subi.w	#1,$3E(a3)
	cmpi.w	#0,$3E(a3)
	ble.w	loc_3A2FA

loc_3A2E0:
	tst.b	d1
	beq.s	loc_3A2EE
	subq.b	#1,d1
	move.b	#3,palette_line(a3)
	bra.s	loc_3A2F4
; ---------------------------------------------------------------------------

loc_3A2EE:
	move.b	#2,palette_line(a3)

loc_3A2F4:
	swap	d1
	clr.w	d7
	rts
; ---------------------------------------------------------------------------

loc_3A2FA:
	swap	d1
	move.w	#1,d7
	move.b	#3,palette_line(a3)
	rts
; End of function sub_3A292

stru_3A308:
	anim_frame	  1,   4, LnkTo_unk_C8530-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8538-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8540-Data_Index
	anim_frame	  1,   4, LnkTo_unk_C8548-Data_Index
	dc.b   2
	dc.b $11
; ---------------------------------------------------------------------------

;Enemy00_FireDemon_Init: 
	include "code/enemy/Fire_Demon.asm"
; ---------------------------------------------------------------------------
;Enemy03_Robot_Init: 
	include "code/enemy/Robot.asm"
; ---------------------------------------------------------------------------
;Enemy01_Diamond_Init: 
	include "code/enemy/Diamond.asm"
; ---------------------------------------------------------------------------
;Enemy09_Crab_Init: 
	include "code/enemy/Crab.asm"
; ---------------------------------------------------------------------------
;Enemy0A_RockTank_Init: 
	include "code/enemy/Tank.asm"
; ---------------------------------------------------------------------------
;Enemy0B_RockTank_shooting_Init: 
	include "code/enemy/Tank_Shooting.asm"
; ---------------------------------------------------------------------------
;Enemy14_SpinningTwins_Init: 
	include "code/enemy/Spinning_Twins.asm"
; ---------------------------------------------------------------------------
;Enemy1A_Driller_Init: 
	include "code/enemy/Driller.asm"
; =============== S U B	R O U T	I N E =======================================


sub_3BF72:
	move.w	object_meta(a3),d7
	andi.w	#$FFF,d7
	cmpi.w	#$1A,d7
	beq.w	loc_3BFD4
	move.l	$3A(a5),a4
	move.w	x_pos(a3),x_pos(a4)
	move.w	y_pos(a3),y_pos(a4)
	move.w	$46(a4),d4
	sub.w	d4,y_pos(a4)
	cmpi.w	#3,d7
	beq.s	loc_3BFA8

loc_3BFA0:
	move.b	x_direction(a3),$16(a4)

return_3BFA6:
	rts
; ---------------------------------------------------------------------------

loc_3BFA8:
	cmpi.w	#$800,$38(a4)
	beq.s	loc_3BFA0
	tst.w	$40(a3)
	beq.s	loc_3BFA0
	move.b	$16(a4),d7
	cmp.b	x_direction(a3),d7
	beq.s	return_3BFA6
	tst.b	d7
	beq.s	loc_3BFCC
	subi.w	#4,x_pos(a4)
	bra.s	return_3BFA6
; ---------------------------------------------------------------------------

loc_3BFCC:
	addi.w	#4,x_pos(a4)
	bra.s	return_3BFA6
; ---------------------------------------------------------------------------

loc_3BFD4:
	move.l	$3A(a5),a4
	move.l	$3E(a5),a2
	move.w	x_pos(a3),d4
	move.w	y_pos(a3),d5
	move.w	d4,x_pos(a4)
	move.w	d4,$1A(a2)
	tst.b	x_direction(a3)
	bne.s	loc_3C000
	subi.w	#$18,x_pos(a4)
	addi.w	#$17,$1A(a2)
	bra.s	loc_3C00C
; ---------------------------------------------------------------------------

loc_3C000:
	subi.w	#$17,x_pos(a4)
	addi.w	#$18,$1A(a2)

loc_3C00C:
	move.w	d5,y_pos(a4)
	move.w	d5,$1E(a2)
	move.l	#$FFFF8000,$26(a4)
	move.l	#$8000,$26(a2)
	rts
; End of function sub_3BF72

; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_3C4F8

loc_3C026:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	st	x_direction(a3)
	addq.b	#4,$5A(a5)
	beq.w	loc_3C464

loc_3C03A:
	tst.w	$3A(a5)
	beq.s	loc_3C044
	bsr.w	sub_3BF72

loc_3C044:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	jmp	(a0)
; ---------------------------------------------------------------------------
; Code used by Crab, Diamond, Driller, Fire_Demon, Robot, Spinning_Twins, Tank, Tank_Shooting
loc_3C04E:
	bsr.w	sub_3C4F8
	bsr.w	sub_36972
	btst	#2,d7
	bne.w	loc_3C464
	tst.w	d6
	bmi.w	loc_3C17A
	move.l	x_pos(a3),d0
	move.l	d0,d1
	add.l	$50(a5),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	move.w	d0,d3
	add.w	$48(a5),d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C0C6
	btst	#1,d7
	beq.s	loc_3C0A6
	tst.w	d5
	bne.s	loc_3C0A6
	lsl.w	#3,d4
	cmp.w	$48(a5),d4
	bcs.s	loc_3C0A6
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	bra.w	loc_3C17A
; ---------------------------------------------------------------------------

loc_3C0A6:
	btst	#0,d7
	beq.s	loc_3C0B4
	st	$6E(a5)
	bra.w	loc_3C0D2
; ---------------------------------------------------------------------------

loc_3C0B4:
	tst.w	d6
	bmi.s	loc_3C0C6
	btst	#1,d7
	bne.s	loc_3C0C6
	st	$6E(a5)
	bra.w	loc_3C0D2
; ---------------------------------------------------------------------------

loc_3C0C6:
	move.l	d2,x_pos(a3)
	sf	$5A(a5)
	bra.w	loc_3C03A
; ---------------------------------------------------------------------------

loc_3C0D2:
	clr.l	x_vel(a3)
	clr.l	y_vel(a3)
	sf	x_direction(a3)
	addq.b	#4,$5A(a5)
	beq.w	loc_3C464

loc_3C0E6:
	tst.w	$3A(a5)
	beq.s	loc_3C0F0
	bsr.w	sub_3BF72

loc_3C0F0:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE
	jmp	(a0)
; ---------------------------------------------------------------------------
; Code used by Crab, Diamond, Driller, Fire_Demon, Robot, Spinning_Twins, Tank, Tank_Shooting
loc_3C0FA:
	bsr.w	sub_3C4F8
	bsr.w	sub_36A58
	btst	#2,d7
	bne.w	loc_3C464
	tst.w	d6
	bmi.w	loc_3C266
	move.l	x_pos(a3),d0
	move.l	d0,d1
	sub.l	$50(a5),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	neg.w	d1
	move.w	d0,d3
	sub.w	$48(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C172
	btst	#1,d7
	beq.s	loc_3C152
	tst.w	d5
	bne.s	loc_3C152
	lsl.w	#3,d4
	cmp.w	$48(a5),d4
	bcs.s	loc_3C152
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	bra.w	loc_3C266
; ---------------------------------------------------------------------------

loc_3C152:
	btst	#0,d7
	beq.s	loc_3C160
	st	$6E(a5)
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3C160:
	tst.w	d6
	bmi.s	loc_3C172
	btst	#1,d7
	bne.s	loc_3C172
	st	$6E(a5)
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3C172:
	move.l	d2,x_pos(a3)
	bra.w	loc_3C0E6
; ---------------------------------------------------------------------------

loc_3C17A:
	clr.l	y_vel(a3)
	move.l	$50(a5),x_vel(a3)
	addq.w	#1,y_pos(a3)
	bra.s	loc_3C19C
; END OF FUNCTION CHUNK	FOR sub_3C4F8
; ---------------------------------------------------------------------------

loc_3C18A:
	tst.w	$3A(a5)
	beq.s	loc_3C194
	bsr.w	sub_3BF72

loc_3C194:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE

loc_3C19C:
	bsr.w	sub_36B3C
	tst.w	d5
	bne.w	loc_3C464
	move.l	x_pos(a3),d0
	move.l	d0,d1
	add.l	x_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	move.w	d0,d3
	add.w	$48(a5),d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C1DE
	tst.w	d6
	beq.w	loc_3C1DE
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	clr.l	x_vel(a3)
	bra.s	loc_3C1E4
; ---------------------------------------------------------------------------

loc_3C1DE:
	move.l	d2,x_pos(a3)
	move.l	d2,d0

loc_3C1E4:
	move.l	y_pos(a3),d0
	move.l	d0,d1
	add.l	y_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	bge.s	loc_3C220
	neg.w	d1
	move.w	d0,d3
	sub.w	$4A(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C242
	bsr.w	sub_36CB8
	beq.w	loc_3C242
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	clr.l	y_vel(a3)
	bra.s	loc_3C246
; ---------------------------------------------------------------------------

loc_3C220:
	move.w	d0,d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C242
	bsr.w	sub_36C6A
	beq.w	loc_3C242
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	bra.w	loc_3C026
; ---------------------------------------------------------------------------

loc_3C242:
	move.l	d2,y_pos(a3)

loc_3C246:
	move.l	y_vel(a3),d0
	addi.l	#$2000,d0
	cmpi.l	#$80000,d0
	blt.s	loc_3C25E
	move.l	#$80000,d0

loc_3C25E:
	move.l	d0,y_vel(a3)
	bra.w	loc_3C18A
; ---------------------------------------------------------------------------
; START	OF FUNCTION CHUNK FOR sub_3C4F8

loc_3C266:
	clr.l	y_vel(a3)
	move.l	$50(a5),x_vel(a3)
	addq.w	#1,y_pos(a3)
	bra.s	loc_3C288
; ---------------------------------------------------------------------------

loc_3C276:
	tst.w	$3A(a5)
	beq.s	loc_3C280
	bsr.w	sub_3BF72

loc_3C280:
	jsr	(j_Hibernate_Object_1Frame).w
	bsr.w	sub_3C3CE

loc_3C288:
	bsr.w	sub_36BD6
	tst.w	d5
	bne.w	loc_3C464
	move.l	x_pos(a3),d0
	move.l	d0,d1
	sub.l	x_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	neg.w	d1
	move.w	d0,d3
	sub.w	$48(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C2CA
	tst.w	d6
	beq.w	loc_3C2CA
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,x_pos(a3)
	clr.l	x_vel(a3)
	bra.s	loc_3C2D0
; ---------------------------------------------------------------------------

loc_3C2CA:
	move.l	d2,x_pos(a3)
	move.l	d2,d0

loc_3C2D0:
	move.l	y_pos(a3),d0
	move.l	d0,d1
	add.l	y_vel(a3),d1
	move.l	d1,d2
	swap	d0
	swap	d1
	sub.w	d0,d1
	bge.s	loc_3C30C
	neg.w	d1
	move.w	d0,d3
	sub.w	$4A(a5),d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C32E
	bsr.w	sub_36CB8
	beq.w	loc_3C32E
	sub.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	clr.l	y_vel(a3)
	bra.s	loc_3C332
; ---------------------------------------------------------------------------

loc_3C30C:
	move.w	d0,d3
	neg.w	d3
	andi.w	#$F,d3
	cmp.w	d1,d3
	bcc.s	loc_3C32E
	bsr.w	sub_36C6A
	beq.w	loc_3C32E
	add.w	d3,d0
	swap	d0
	clr.w	d0
	move.l	d0,y_pos(a3)
	bra.w	loc_3C0D2
; ---------------------------------------------------------------------------

loc_3C32E:
	move.l	d2,y_pos(a3)

loc_3C332:
	move.l	y_vel(a3),d0
	addi.l	#$2000,d0
	cmpi.l	#$80000,d0
	blt.s	loc_3C34A
	move.l	#$80000,d0

loc_3C34A:
	move.l	d0,y_vel(a3)
	bra.w	loc_3C276
; END OF FUNCTION CHUNK	FOR sub_3C4F8

; =============== S U B	R O U T	I N E =======================================


sub_3C352:
	move.w	object_meta(a3),d7
	andi.w	#$FFF,d7
	clr.w	d6
	cmpi.w	#$1A,d7
	beq.s	loc_3C372
	addi.w	#1,d6
	cmpi.w	#$A,d7
	beq.s	loc_3C372
	cmpi.w	#$B,d7
	bne.s	return_3C3CC

loc_3C372:
	tst.b	$19(a3)
	beq.s	loc_3C39C
	tst.b	$6A(a5)
	bne.s	loc_3C3C6
	lea	($FFFFFA34).w,a4
	subi.b	#1,(a4,d7.w)
	bne.s	loc_3C3C6
	lea	(byte_3C46C).l,a4
	move.b	(a4,d6.w),d0
	jsr	(j_PlaySound2).l
	bra.s	loc_3C3C6
; ---------------------------------------------------------------------------

loc_3C39C:
	tst.b	$6A(a5)
	beq.s	loc_3C3C6
	lea	($FFFFFA34).w,a4
	move.l	a4,d5
	tst.b	(a4,d7.w)
	bne.s	loc_3C3BE
	lea	(byte_3C46C).l,a4
	move.b	(a4,d6.w),d0
	jsr	(j_PlaySound).l

loc_3C3BE:
	move.l	d5,a4
	addi.b	#1,(a4,d7.w)

loc_3C3C6:
	move.b	$19(a3),$6A(a5)

return_3C3CC:
	rts
; End of function sub_3C352


; =============== S U B	R O U T	I N E =======================================

; Used by Diamond, Fire_Demon, Spinning_Twins
sub_3C3CE:
	bsr.s	sub_3C352
	cmpi.w	#$FFE0,x_pos(a3)
	ble.s	loc_3C436
	cmpi.w	#$FFE0,y_pos(a3)
	ble.s	loc_3C436
	move.w	(Level_width_pixels).w,d7
	addi.w	#$20,d7
	cmp.w	x_pos(a3),d7
	blt.s	loc_3C436
	move.w	(Level_height_blocks).w,d7
	addi.w	#$20,d7
	cmp.w	y_pos(a3),d7
	blt.s	loc_3C436
	cmpi.w	#$A,(Number_Objects).w
	ble.s	return_3C434
	cmpi.w	#$14,(Number_Objects).w
	ble.s	loc_3C43A
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FEFC,d0
	blt.s	loc_3C436
	cmpi.w	#$244,d0
	bgt.s	loc_3C436
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FEFC,d0
	blt.s	loc_3C436
	cmpi.w	#$1E4,d0
	bgt.s	loc_3C436

return_3C434:
	rts
; ---------------------------------------------------------------------------

loc_3C436:
	bra.w	loc_3C46E
; ---------------------------------------------------------------------------

loc_3C43A:
	move.w	x_pos(a3),d0
	sub.w	(Camera_X_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3C436
	cmpi.w	#$2E4,d0
	bgt.s	loc_3C436
	move.w	y_pos(a3),d0
	sub.w	(Camera_Y_pos).w,d0
	cmpi.w	#$FE5C,d0
	blt.s	loc_3C436
	cmpi.w	#$284,d0
	bgt.s	loc_3C436
	rts
; ---------------------------------------------------------------------------

loc_3C464:
	move.w	#$FFFF,collision_type(a3)
	jmp	(a0)
; ---------------------------------------------------------------------------
byte_3C46C:
	dc.b sfx_Drill_moving
	dc.b sfx_Tank_driving
; ---------------------------------------------------------------------------

loc_3C46E:
	clr.w	d6
	move.w	object_meta(a3),d7
	andi.w	#$FFF,d7
	cmpi.w	#$14,d7
	beq.w	loc_3BC56
	cmpi.w	#$1A,d7
	beq.s	loc_3C494
	addq.w	#1,d6
	cmpi.w	#$A,d7
	beq.s	loc_3C494
	cmpi.w	#$B,d7
	bne.s	loc_3C4C0

loc_3C494:
	tst.b	$19(a3)
	beq.s	loc_3C4A2
	tst.b	$6A(a5)
	bne.s	loc_3C4C0
	bra.s	loc_3C4A8
; ---------------------------------------------------------------------------

loc_3C4A2:
	tst.b	$6A(a5)
	bne.s	loc_3C4C0

loc_3C4A8:
	lea	($FFFFFA34).w,a4
	subi.b	#1,(a4,d7.w)
	bne.s	loc_3C4C0
	move.b	byte_3C46C(pc,d6.w),d0
	ext.w	d0
	jsr	(j_PlaySound2).l

loc_3C4C0:
	moveq	#0,d0
	subi.w	#1,(Number_of_Enemy).w
	move.b	$42(a5),d0
	bpl.s	loc_3C4E6
	btst	#6,d0
	beq.s	loc_3C4F4
	andi.w	#$3F,d0
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	subi.w	#$400,(a0,d0.w)
	bra.s	loc_3C4F4
; ---------------------------------------------------------------------------

loc_3C4E6:
	add.w	d0,d0
	lea	(EnemyStatus_Table).w,a0
	move.w	#$2168,d7
	move.w	d7,(a0,d0.w)

loc_3C4F4:
	jmp	(j_Delete_CurrentObject).w
; End of function sub_3C3CE


; =============== S U B	R O U T	I N E =======================================


sub_3C4F8:
	move.w	object_meta(a3),d7
	andi.w	#$FFF,d7
	cmpi.w	#$B,d7
	beq.s	loc_3C50E
	cmpi.w	#3,d7
	beq.s	loc_3C538
	rts
; ---------------------------------------------------------------------------

loc_3C50E:
	move.l	$3A(a5),a4
	cmpi.w	#(LnkTo_unk_C7F10-Data_Index),$22(a4)
	bne.s	return_3C536
	cmpi.w	#5,$32(a4)
	bne.s	return_3C536
	exg	a0,a4
	move.w	#$8000,a0
	jsr	(j_Allocate_ObjectSlot).w
	move.l	#loc_3B730,4(a0)
	exg	a0,a4

return_3C536:
	rts
; ---------------------------------------------------------------------------

loc_3C538:
	move.l	$3A(a5),a4
	tst.b	$4E(a5)
	bne.s	loc_3C5A2
	cmpi.w	#(LnkTo_unk_C82F0-Data_Index),$22(a4)
	bne.s	return_3C552
	cmpi.w	#9,$32(a4)
	beq.s	loc_3C554

return_3C552:
	rts
; ---------------------------------------------------------------------------

loc_3C554:
	cmpi.w	#2,$40(a3)
	beq.w	loc_3C5FC
	jsr	(j_Get_RandomNumber_long).w
	cmpi.w	#$A,d7
	ble.s	loc_3C56A
	rts
; ---------------------------------------------------------------------------

loc_3C56A:
	cmpi.w	#1,$40(a3)
	blt.s	loc_3C5EE
	move.l	(Addr_GfxObject_Kid).w,a2
	move.w	x_pos(a4),d7
	sub.w	$1A(a2),d7
	bmi.s	loc_3C588
	tst.b	$16(a4)
	beq.s	loc_3C5EE
	bra.s	loc_3C58E
; ---------------------------------------------------------------------------

loc_3C588:
	tst.b	$16(a4)
	bne.s	loc_3C5EE

loc_3C58E:
	st	$4E(a5)
	sf	$15(a4)
	move.w	#9,$54(a5)
	move.w	#(LnkTo_unk_C8338-Data_Index),$22(a4)

loc_3C5A2:
	subi.w	#1,$54(a5)
	bne.s	return_3C5F4
	move.w	$4E(a5),d7
	andi.w	#$FF,d7
	addi.w	#1,d7
	cmpi.w	#2,d7
	bgt.s	loc_3C5D8
	blt.s	loc_3C5C4
	eori.b	#$FF,$16(a4)

loc_3C5C4:
	or.w	d7,$4E(a5)
	add.w	d7,d7
	move.w	off_3C5F6(pc,d7.w),$22(a4)
	move.w	#9,$54(a5)
	bra.s	return_3C5F4
; ---------------------------------------------------------------------------

loc_3C5D8:
	st	$15(a4)
	clr.w	$4E(a5)
	exg	a3,a4
	move.l	#stru_3A716,d7
	jsr	(j_Init_Animation).w
	exg	a3,a4

loc_3C5EE:
	move.l	(sp)+,d7
	bra.w	Enemy03_Robot_Shoot
; ---------------------------------------------------------------------------

return_3C5F4:
	rts
; ---------------------------------------------------------------------------
off_3C5F6:
	dc.w LnkTo_unk_C8338-Data_Index
	dc.w LnkTo_unk_C8340-Data_Index
	dc.w LnkTo_unk_C8338-Data_Index
; ---------------------------------------------------------------------------

loc_3C5FC:
	move.l	(Addr_GfxObject_Kid).w,a2
	move.w	x_pos(a3),d7
	sub.w	$1A(a2),d7
	bmi.s	loc_3C612
	tst.b	$16(a4)
	beq.s	loc_3C5EE
	bra.s	loc_3C618
; ---------------------------------------------------------------------------

loc_3C612:
	tst.b	$16(a4)
	bne.s	loc_3C5EE

loc_3C618:
	st	$4E(a5)
	sf	$15(a4)
	move.w	#9,$54(a5)
	move.w	#(LnkTo_unk_C8338-Data_Index),$22(a4)
	bra.w	loc_3C5A2
; End of function sub_3C4F8

; ---------------------------------------------------------------------------
	rts
; ---------------------------------------------------------------------------
;Enemy04_Armadillo_Init: 
	include "code/enemy/Armadillo.asm"
; ---------------------------------------------------------------------------
;Enemy10_Goat_Init: 
	include "code/enemy/Goat.asm"
; ---------------------------------------------------------------------------
;Enemy0D_Dragon_Init: 
	include "code/enemy/Dragon.asm"
; ---------------------------------------------------------------------------
;Enemy08_Orca_Init: 
	include "code/enemy/Orca.asm"
; ---------------------------------------------------------------------------
;Enemy11_Ninja_Init: 
	include "code/enemy/Ninja.asm"
; ---------------------------------------------------------------------------
;Enemy13_Scorpion_Init: 
	include "code/enemy/Scorpion.asm"
; ---------------------------------------------------------------------------
;Enemy12_Lion_Init: 
	include "code/enemy/Lion.asm"
; ---------------------------------------------------------------------------
;Enemy1C_MiniHoppingSkull_Init: 
	include "code/enemy/Mini_Hopping_Skull.asm"
; ---------------------------------------------------------------------------
; filler
    rept 368
	dc.b	$FF
    endm

; =============== S U B	R O U T	I N E =======================================

;sub_3F57A:
j_Clear_DiamondPowerObjectRAM:
	jmp	Clear_DiamondPowerObjectRAM(pc)
; End of function j_Clear_DiamondPowerObjectRAM


; =============== S U B	R O U T	I N E =======================================

;sub_3F57E:
j_DiamondPower_Run:
	jmp	DiamondPower_Run(pc)
; End of function j_DiamondPower_Run


; =============== S U B	R O U T	I N E =======================================

;sub_3F582:
j_DiamondPower_CompileSprites:
	jmp	DiamondPower_CompileSprites(pc)
; End of function j_DiamondPower_CompileSprites


; =============== S U B	R O U T	I N E =======================================

;sub_3F586:
Clear_DiamondPowerObjectRAM:
	lea	(Addr_FirstDPObjectSlot).w,a0
	lea	($FFFFF612).w,a1
-
	move.w	#0,(a0)+
	cmp.w	a1,a0
	blt.s	-
; End of function Clear_DiamondPowerObjectRAM


; =============== S U B	R O U T	I N E =======================================
; initialize diamond power object slots

;sub_3F596:
Initialize_DiamondPowerObjectSlots:
	lea	($FFFFF2AC).w,a0
	move.l	a0,(Addr_NextFreeDPObjectSlot).w
	moveq	#8,d0
-
	lea	$4C(a0),a1
	move.l	a1,4(a0)
	move.l	a1,a0
	dbf	d0,-
	clr.l	4(a0)
	clr.l	(Addr_FirstDPObjectSlot).w
	clr.l	(Addr_LastDPObjectSlot).w
	rts
; End of function Initialize_DiamondPowerObjectSlots


; =============== S U B	R O U T	I N E =======================================
; find new diamond power object slot (add it to the beginning of list)

;sub_3F5BC:
Allocate_DiamondPowerObjectSlot:
	move.l	(Addr_NextFreeDPObjectSlot).w,a0	; next free object slot
	move.l	4(a0),(Addr_NextFreeDPObjectSlot).w	; the successor in the list become the next free object slot
	move.l	(Addr_FirstDPObjectSlot).w,4(a0)	; previously first object slot becomes successor of our new object
	tst.l	(Addr_FirstDPObjectSlot).w
	bne.s	+			; if the first object slot was empty
	move.l	a0,(Addr_LastDPObjectSlot).w	; then our new object is also the last object in the list
+
	move.l	a0,(Addr_FirstDPObjectSlot).w	; our object is the first in the list, regardless
	move.w	#1,8(a0)
	move.w	#0,$38(a0)
	rts
; End of function Allocate_DiamondPowerObjectSlot

; =============== S U B	R O U T	I N E =======================================


sub_3F5E8:
	lea	($FFFFF5A0).w,a1

loc_3F5EC:
	move.l	4(a1),d0
	cmp.l	d0,a0
	beq.s	loc_3F5F8
	move.l	d0,a1
	bra.s	loc_3F5EC
; ---------------------------------------------------------------------------

loc_3F5F8:
	cmp.l	(Addr_LastDPObjectSlot).w,a0
	bne.s	loc_3F610
	cmpi.l	#$FFFFF5A0,a1
	bne.s	loc_3F60C
	clr.l	(Addr_LastDPObjectSlot).w
	bra.s	loc_3F610
; ---------------------------------------------------------------------------

loc_3F60C:
	move.l	a1,(Addr_LastDPObjectSlot).w

loc_3F610:
	move.l	4(a0),4(a1)
	move.l	(Addr_NextFreeDPObjectSlot).w,4(a0)
	move.l	a0,(Addr_NextFreeDPObjectSlot).w
	move.l	a1,a0
	tst.l	(Addr_FirstDPObjectSlot).w	; while we still have diamond power objects
	sne	(Diamond_power_active).w	; set the diamond power flag.
	beq.s	loc_3F62E
	rts
; ---------------------------------------------------------------------------

loc_3F62E:
	sf	(FiveWayShotReady).w
	sf	(SamuraiHazeActive).w
	sf	(KidIsInvulnerable).w
	rts
; End of function sub_3F5E8


; =============== S U B	R O U T	I N E =======================================


sub_3F63C:
	clr.l	(Addr_FirstDPObjectSlot).w
	clr.l	(Addr_NextFreeDPObjectSlot).w
	sf	(Diamond_power_active).w
	sf	(FiveWayShotReady).w
	sf	(SamuraiHazeActive).w
	sf	(KidIsInvulnerable).w
	rts
; End of function sub_3F63C


; =============== S U B	R O U T	I N E =======================================


DiamondPower_Run:
	move.l	#$FFFFF5C2,($FFFFF5B0).w
	tst.b	(Diamond_power_active).w
	bne.w	DiamondPower_Main_Execute
	move.w	(Current_Helmet).w,d0	; Check if helmet ID is Juggernaut
	cmpi.w	#Juggernaut,d0
	bne.s	+
	tst.b	(FiveWayShotReady).w
	bne.w	DiamondPower_Init_FiveWayShot
	bra.s	DiamondPower_rts
; ---------------------------------------------------------------------------

+
	move.b	(Ctrl_Held).w,d1
	andi.b	#Button_Start_mask|Button_A_mask,d1
	cmpi.b	#Button_Start_mask|Button_A_mask,d1
	bne.s	DiamondPower_rts
	cmpi.w	#Eyeclops,d0		; Check if Helmet ID is Eyeclops
	bne.s	DiamondPower_Check

DiamondPower_rts:
	rts
; ---------------------------------------------------------------------------

DiamondPower_Check:	; Checks performed when a Diamond Power is input
	cmpi.w	#$14,(Number_Diamonds).w		; Compare diamonds to 20
	blt.s	DiamondPower_rts			; If <, return
	subi.w	#$14,(Number_Diamonds).w		; Subtract 20 from diamonds
	move.w	(Current_Helmet).w,d0			; Helmet ID -> d0
	cmpi.w	#$1E,(Number_Diamonds).w		; Compare diamonds to 30
	blt.s	+					; If <, execute diamond power
	subi.w	#$1E,(Number_Diamonds).w		; Subtract 30 from diamonds
	addi.w	#$A,d0					; Add 10 to d0

+	; Initialize Diamond Power
	move.w	d0,(Diamond_power_ID).w
	add.w	d0,d0
	add.w	d0,d0
	move.l	DiamondPower_Init_Index(pc,d0.w),a0
	st	(Diamond_power_active).w
	move.l	a0,-(sp)
	bsr.w	Initialize_DiamondPowerObjectSlots
	move.l	(sp)+,a0
	jmp	(a0)
; ---------------------------------------------------------------------------
;off_3F6CE:
DiamondPower_Init_Index:	; Initialization code for each diamond power
	; 20-diamond power
	dc.l DiamondPower_Init_CircleOfDoom		; The_Kid - Circle of Doom
	dc.l DiamondPower_Init_Invulnerability		; Skycutter - Invulnerability
	dc.l DiamondPower_Init_SlashingRain		; Cyclone - Slashing Rain
	dc.l DiamondPower_Init_SamuraiHaze		; Red_Stealth - Samurai Haze
	dc.l 0						; Eyeclops - invalid
	dc.l DiamondPower_Init_FiveWayShot		; Juggernaut - not accessed via this index
	dc.l DiamondPower_Init_CircleOfDoom		; Iron_Knight - Circle of Doom
	dc.l DiamondPower_Init_Invulnerability		; Berzerker - Invulnerability
	dc.l DiamondPower_Init_CircleOfDoom		; Maniaxe - Circle of Doom
	dc.l DiamondPower_Init_MiniSnake		; Micromax - Mini-Snake
	; 50 diamond powers
	dc.l DiamondPower_Init_DeathSnake		; The_Kid - Death Snake
	dc.l DiamondPower_Init_DeathSnake2		; Skycutter - Death Snake
	dc.l DiamondPower_Init_TrackingRain		; Cyclone - Tracking Rain
	dc.l DiamondPower_Init_DeathSnake		; Red_Stealth - Death Snake
	dc.l 0						; Eyeclops - invalid
	dc.l DiamondPower_Init_FiveWayShot		; Juggernaut - not accessed via this index
	dc.l DiamondPower_Init_ExtraHitPoint		; Iron_Knight - Extra Hit Point
	dc.l DiamondPower_Init_WallOfDeath		; Berzerker - Wall of Death
	dc.l DiamondPower_Init_ExtraLife		; Maniaxe - Extra Life
	dc.l DiamondPower_Init_SwiftMiniSnake		; Micromax - Swift Mini-Snake
; ---------------------------------------------------------------------------
;loc_3F71E:
DiamondPower_Main_Execute:
	move.l	(Addr_NextSpriteSlot).w,a2
	moveq	#0,d2
	move.b	(Number_Sprites).w,d2
	move.l	($FFFFF5B0).w,a4
	move.w	(Diamond_power_ID).w,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	DiamondPower_Main_Index(pc,d0.w),a0
	jsr	(a0)
	move.l	a2,(Addr_NextSpriteSlot).w
	move.b	d2,(Number_Sprites).w
	move.l	a4,($FFFFF5B0).w
	rts
; ---------------------------------------------------------------------------
; off_3F748:
DiamondPower_Main_Index:; Running code for each diamond power
	; 20-diamond power
	dc.l DiamondPower_Main_CircleOfDoom	; The_Kid - Circle of Doom
	dc.l DiamondPower_Main_InvulnAndHaze	; Skycutter - Invulnerability
	dc.l DiamondPower_Main_SlashingRain	; Cyclone - Slashing Rain
	dc.l DiamondPower_Main_InvulnAndHaze	; Red_Stealth - Samurai Haze
	dc.l 0					; Eyeclops - invalid
	dc.l DiamondPower_Main_FiveWayShot	; Juggernaut - 5-Way Shot
	dc.l DiamondPower_Main_CircleOfDoom	; Iron_Knight - Circle of Doom
	dc.l DiamondPower_Main_InvulnAndHaze	; Berzerker - Invulnerability
	dc.l DiamondPower_Main_CircleOfDoom	; Maniaxe - Circle of Doom
	dc.l DiamondPower_Main_Snake		; Micromax - Mini-Snake
	; 50 diamond powers
	dc.l DiamondPower_Main_Snake		; The_Kid - Death Snake
	dc.l DiamondPower_Main_Snake2		; Skycutter - Death Snake v2
	dc.l DiamondPower_Main_SlashingRain	; Cyclone - Tracking Rain
	dc.l DiamondPower_Main_Snake		; Red_Stealth - Death Snake
	dc.l 0					; Eyeclops - invalid
	dc.l DiamondPower_Main_FiveWayShot	; Juggernaut - 5-Way Shot
	dc.l DiamondPower_Main_ExtraHPLife	; Iron_Knight - Extra Hit Point
	dc.l DiamondPower_Main_WallOfDeath	; Berzerker - Wall of Death
	dc.l DiamondPower_Main_ExtraHPLife	; Maniaxe - Extra Life
	dc.l DiamondPower_Main_Snake		; Micromax - Swift Mini-Snake
; ---------------------------------------------------------------------------
;loc_3F798:
DiamondPower_CompileSprites:
	move.l	($FFFFF5B0).w,a0
	lea	($FFFFF5C2).w,a1
	cmp.l	a0,a1
	beq.s	return_3F7CE
	move.l	(Addr_NextSpriteSlot).w,a2
	moveq	#0,d2
	move.b	(Number_Sprites).w,d2

loc_3F7AE:
	move.w	(a1)+,(a2)+
	move.w	(a1)+,d0
	addq.w	#1,d2
	add.w	d2,d0
	move.w	d0,(a2)+
	move.w	(a1)+,d0
	andi.w	#$7FFF,d0
	move.w	d0,(a2)+
	move.w	(a1)+,(a2)+
	cmp.l	a0,a1
	bne.s	loc_3F7AE
	move.l	a2,(Addr_NextSpriteSlot).w
	move.b	d2,(Number_Sprites).w

return_3F7CE:
	rts
; ---------------------------------------------------------------------------
;loc_3F7D0:
DiamondPower_Init_CircleOfDoom:
	moveq	#8,d1
	move.l	#$10000,d2
	divu.w	d1,d2
	lsl.l	#8,d2
	moveq	#0,d3
	moveq	#$21,d0
	swap	d0
	clr.w	d0
	subq.w	#1,d1

loc_3F7E6:
	bsr.w	Allocate_DiamondPowerObjectSlot
	move.l	d0,$3E(a0)
	clr.w	$40(a0)
	move.l	d3,$42(a0)
	add.l	d2,d3
	dbf	d1,loc_3F7E6
	rts
; ---------------------------------------------------------------------------

DiamondPower_Main_CircleOfDoom:
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	#$7F,d3
	sub.w	(Camera_X_pos).w,d3
	move.w	#$7F,d4
	sub.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_3F81A
	rts
; ---------------------------------------------------------------------------

loc_3F81A:
	move.l	d0,a0
	move.l	$3E(a0),d5
	lsr.l	#8,d5
	move.w	$42(a0),d0
	bsr.w	sub_40236
	muls.w	d5,d0
	swap	d0
	asr.w	#6,d0
	add.w	x_pos(a3),d0
	move.w	d0,$1A(a0)
	add.w	d3,d0
	muls.w	d5,d1
	swap	d1
	asr.w	#6,d1
	neg.w	d1
	add.w	y_pos(a3),d1
	subi.w	#$10,d1
	move.w	d1,$1E(a0)
	add.w	d4,d1
	move.w	$3E(a0),d5
	moveq	#0,d6
	lsr.w	#1,d5
	move.b	byte_3F8B4(pc,d5.w),d6
	tst.w	$38(a0)
	bne.s	loc_3F87A
	subi.l	#$400,$3E(a0)
	cmpi.w	#$C,d5
	bge.s	loc_3F880
	subi.l	#$19000,$3E(a0)
	bge.s	loc_3F880

loc_3F87A:
	bsr.w	sub_3F5E8
	bra.s	loc_3F8AA
; ---------------------------------------------------------------------------

loc_3F880:
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d6,d5
	addi.w	#$1144,d5
	move.w	d5,$22(a0)
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+
	subq.w	#4,$42(a0)

loc_3F8AA:
	move.l	4(a0),d0
	bne.w	loc_3F81A
	rts
; ---------------------------------------------------------------------------
byte_3F8B4:	dc.b 0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   4
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   5
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
	dc.b   6
; ---------------------------------------------------------------------------
;loc_3F8D0:
DiamondPower_Init_SwiftMiniSnake:
	moveq	#$10,d4
	move.w	#$480,d5
	lea	DiamondPower_InitData_SwiftMiniSnake(pc),a2
	move.w	#$4B0,(Diamond_power_timer).w
	bra.s	DiamondPower_Init_Snake
; ---------------------------------------------------------------------------
;unk_3F8E2:
DiamondPower_InitData_SwiftMiniSnake:	; diamond sizes?
	dc.w   5,  4,  3,  2,  1,  1
; ---------------------------------------------------------------------------
;loc_3F8EE:
DiamondPower_Init_MiniSnake:
	moveq	#6,d4
	move.w	#$300,d5
	lea	DiamondPower_InitData_MiniSnake(pc),a2
	move.w	#$1E0,(Diamond_power_timer).w
	bra.s	DiamondPower_Init_Snake
; ---------------------------------------------------------------------------
;unk_3F900:
DiamondPower_InitData_MiniSnake:	; diamond sizes?
	dc.w   4,  3,  2,  1,  1,  1
; ---------------------------------------------------------------------------
;loc_3F90C:
DiamondPower_Init_DeathSnake:
	move.w	#$4B0,(Diamond_power_timer).w
	lea	DiamondPower_InitData_DeathSnake(pc),a2
	moveq	#6,d4
	move.w	#$400,d5

;loc_3F91C:
DiamondPower_Init_Snake:
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	x_pos(a3),d6
	move.w	y_pos(a3),d7
	moveq	#5,d1

loc_3F92A:
	bsr.w	Allocate_DiamondPowerObjectSlot
	cmpi.w	#5,d1
	bne.s	loc_3F946
	move.l	a0,($FFFFF5B4).w
	move.w	#$40,$3E(a0)
	move.w	d4,$2E(a0)
	move.w	d5,$30(a0)

loc_3F946:
	move.w	d6,$1A(a0)
	move.w	d7,$1E(a0)
	lea	$40(a0),a1
	move.w	(a2)+,$24(a0)
	move.w	d6,(a1)+
	move.w	d7,(a1)+
	move.w	d6,(a1)+
	move.w	d7,(a1)+
	move.w	d6,(a1)+
	move.w	d7,(a1)+
	dbf	d1,loc_3F92A
	rts
; ---------------------------------------------------------------------------
;unk_3F968:
DiamondPower_InitData_DeathSnake:	; diamond sizes?
	dc.w   6,  6,  5,  4,  3,  2
; ---------------------------------------------------------------------------

DiamondPower_Main_Snake:
	move.l	(Addr_FirstDPObjectSlot).w,a1

loc_3F978:
	move.l	a1,a0
	move.l	4(a0),d1
	beq.s	loc_3F9A2
	move.l	d1,a1
	lea	$40(a0),a3
	move.w	(a3),$1A(a0)
	move.w	2(a3),$1E(a0)
	move.l	4(a3),(a3)+
	move.l	4(a3),(a3)+
	move.w	$1A(a1),(a3)+
	move.w	$1E(a1),(a3)+
	bra.s	loc_3F978
; ---------------------------------------------------------------------------

loc_3F9A2:
	subq.w	#1,(Diamond_power_timer).w
	move.l	($FFFFF5B4).w,a0
	move.w	$1A(a0),d0
	sub.w	(Camera_X_pos).w,d0
	move.w	$1E(a0),d1
	sub.w	(Camera_Y_pos).w,d1
	moveq	#-1,d3
	move.l	($FFFFF86A).w,d6
	beq.s	loc_3FA0C

loc_3F9C2:
	move.l	d6,a1
	move.w	$1A(a1),d4
	move.w	$1E(a1),d5
	subi.w	#$10,d5
	sub.w	(Camera_X_pos).w,d4
	cmpi.w	#$FFF8,d4
	blt.s	loc_3FA06
	cmpi.w	#$148,d4
	bge.s	loc_3FA06
	sub.w	(Camera_Y_pos).w,d5
	cmpi.w	#$10,d5
	blt.s	loc_3FA06
	cmpi.w	#$F0,d5
	bge.s	loc_3FA06
	sub.w	d0,d4
	bge.s	loc_3F9F6
	neg.w	d4

loc_3F9F6:
	sub.w	d1,d5
	bge.s	loc_3F9FC
	neg.w	d5

loc_3F9FC:
	add.w	d4,d5
	cmp.w	d5,d3
	bcs.s	loc_3FA06
	move.w	d5,d3
	move.l	a1,a3

loc_3FA06:
	move.l	4(a1),d6
	bne.s	loc_3F9C2

loc_3FA0C:
	cmpi.w	#$FFFF,d3
	bne.s	loc_3FA16
	move.l	(Addr_GfxObject_Kid).w,a3

loc_3FA16:
	move.w	x_pos(a3),d0
	sub.w	$1A(a0),d0
	move.w	y_pos(a3),d1
	subi.w	#$10,d1
	sub.w	$1E(a0),d1
	neg.w	d1
	moveq	#0,d3
	tst.w	d1
	bpl.s	loc_3FA36
	moveq	#6,d3
	neg.w	d1

loc_3FA36:
	tst.w	d0
	bpl.s	loc_3FA40
	eori.w	#2,d3
	neg.w	d0

loc_3FA40:
	cmp.w	d0,d1
	bge.s	loc_3FA46
	addq.w	#1,d3

loc_3FA46:
	btst	#1,d3
	bne.s	loc_3FA50
	eori.w	#1,d3

loc_3FA50:
	move.w	$3E(a0),d4
	lsr.w	#5,d4
	andi.w	#7,d4
	cmp.w	d3,d4
	beq.s	loc_3FA72
	sub.w	d4,d3
	bmi.s	loc_3FA6A
	cmpi.w	#4,d3
	bge.s	loc_3FAC2
	bra.s	loc_3FACC
; ---------------------------------------------------------------------------

loc_3FA6A:
	cmpi.w	#$FFFC,d3
	bge.s	loc_3FAC2
	bra.s	loc_3FACC
; ---------------------------------------------------------------------------

loc_3FA72:
	move.w	d0,d5
	or.w	d1,d5
	beq.s	loc_3FAD4
	move.w	$3E(a0),d5
	btst	#0,d3
	beq.s	loc_3FA84
	neg.w	d5

loc_3FA84:
	moveq	#$66,d6
	btst	d3,d6
	beq.s	loc_3FA8C
	exg	d0,d1

loc_3FA8C:
	moveq	#0,d4
	lsr.w	#1,d1
	move.w	d1,d4
	swap	d4
	divu.w	d0,d4
	lea	word_402B0(pc),a1
	andi.w	#$1F,d5
	add.w	d5,d5
	moveq	#0,d0
	move.w	(a1,d5.w),d0
	lsr.w	#1,d0
	swap	d0
	neg.w	d5
	addi.w	#$80,d5
	move.w	(a1,d5.w),d1
	divu.w	d1,d0
	btst	#0,d3
	beq.s	loc_3FABE
	exg	d0,d4

loc_3FABE:
	cmp.w	d4,d0
	ble.s	loc_3FACC

loc_3FAC2:
	move.w	$2E(a0),d0
	sub.w	d0,$3E(a0)
	bra.s	loc_3FAD4
; ---------------------------------------------------------------------------

loc_3FACC:
	move.w	$2E(a0),d0
	add.w	d0,$3E(a0)

loc_3FAD4:
	move.w	$3E(a0),d0
	bsr.w	sub_40236
	move.w	$30(a0),d5
	muls.w	d5,d0
	asr.l	#6,d0
	add.l	d0,$1A(a0)
	muls.w	d5,d1
	asr.l	#6,d1
	sub.l	d1,$1E(a0)
	move.l	(Addr_GfxObject_Kid).w,a3
	move.l	x_vel(a3),d3
	asr.l	#1,d3
	add.l	d3,$1A(a0)
	move.l	y_vel(a3),d3
	asr.l	#1,d3
	add.l	d3,$1E(a0)
	move.w	#$7F,d3
	sub.w	(Camera_X_pos).w,d3
	move.w	#$7F,d4
	sub.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_3FB20
	rts
; ---------------------------------------------------------------------------

loc_3FB20:
	move.l	d0,a0
	tst.w	(Diamond_power_timer).w
	bge.s	loc_3FB3E
	move.w	(Time_Frames).w,d1
	andi.w	#$F,d1
	bne.s	loc_3FB3E
	subq.w	#1,$24(a0)
	bne.s	loc_3FB3E
	bsr.w	sub_3F5E8
	bra.s	loc_3FB88
; ---------------------------------------------------------------------------

loc_3FB3E:
	move.w	$1A(a0),d0
	add.w	d3,d0
	move.w	$1E(a0),d1
	add.w	d4,d1
	move.w	$24(a0),d6
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d6,d5
	addi.w	#$1144,d5
	move.w	d5,$22(a0)
	tst.w	d0
	ble.s	loc_3FB88
	cmpi.w	#$1E0,d0
	bge.s	loc_3FB88
	tst.w	d1
	ble.s	loc_3FB88
	cmpi.w	#$1E0,d1
	bge.s	loc_3FB88
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+

loc_3FB88:
	move.l	4(a0),d0
	bne.s	loc_3FB20
	rts
; ---------------------------------------------------------------------------
;loc_3FB90:
DiamondPower_Init_ExtraHitPoint:
	moveq	#8,d2
	bra.s	loc_3FB96
; ---------------------------------------------------------------------------
;loc_3FB94:
DiamondPower_Init_ExtraLife:
	moveq	#7,d2

loc_3FB96:
	moveq	#0,d3
	moveq	#9,d1

loc_3FB9A:
	bsr.w	Allocate_DiamondPowerObjectSlot
	move.l	#$400000,$3E(a0)
	move.l	d3,$42(a0)
	addi.l	#$199999,d3
	move.w	d2,$24(a0)
	move.w	#0,$22(a0)
	dbf	d1,loc_3FB9A
	clr.w	(Diamond_power_timer).w
	rts
; ---------------------------------------------------------------------------

DiamondPower_Main_ExtraHPLife:
	addq.w	#1,(Diamond_power_timer).w
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	#$7F,d3
	sub.w	(Camera_X_pos).w,d3
	move.w	#$7F,d4
	sub.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_3FBE4
	rts
; ---------------------------------------------------------------------------

loc_3FBE4:
	move.l	d0,a0
	move.l	$3E(a0),d5
	lsr.l	#8,d5
	lsr.l	#1,d5
	move.w	$42(a0),d0
	bsr.w	sub_40236
	muls.w	d5,d0
	swap	d0
	asr.w	#5,d0
	add.w	x_pos(a3),d0
	add.w	d3,d0
	muls.w	d5,d1
	swap	d1
	asr.w	#5,d1
	neg.w	d1
	add.w	y_pos(a3),d1
	subi.w	#$10,d1
	add.w	d4,d1
	move.w	$24(a0),d6
	cmpi.w	#$40,(Diamond_power_timer).w
	bge.s	loc_3FC2A
	addq.w	#2,$3E(a0)
	subq.w	#2,$42(a0)
	bra.s	loc_3FC56
; ---------------------------------------------------------------------------

loc_3FC2A:
	addq.w	#1,$42(a0)
	subq.w	#6,$3E(a0)
	bge.s	loc_3FC56
	cmpi.w	#7,$24(a0)
	beq.s	loc_3FC4E
	cmpi.w	#4,(Extra_hitpoint_slots).w
	bge.s	loc_3FC4C
	addq.w	#1,(Extra_hitpoint_slots).w
	addq.w	#1,(Number_Hitpoints).w

loc_3FC4C:
	bra.s	loc_3FC52
; ---------------------------------------------------------------------------

loc_3FC4E:
	addq.w	#1,(Number_Lives).w

loc_3FC52:
	bra.w	sub_3F63C
; ---------------------------------------------------------------------------

loc_3FC56:
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+
	move.l	4(a0),d0
	bne.w	loc_3FBE4
	rts
; ---------------------------------------------------------------------------
;loc_3FC78:
DiamondPower_Init_Invulnerability:
	st	(KidIsInvulnerable).w
	lea	DiamondPower_InitData_Invulnerability(pc),a1
	bra.s	loc_3FC8A
; ---------------------------------------------------------------------------
;loc_3FC82:
DiamondPower_Init_SamuraiHaze:
	st	(SamuraiHazeActive).w
	lea	DiamondPower_InitData_SamuraiHaze(pc),a1

loc_3FC8A:
	; load 10 diamonds to circle around the kid
	moveq	#9,d1

loc_3FC8C:
	bsr.w	Allocate_DiamondPowerObjectSlot
	moveq	#0,d3
	move.b	(a1)+,d3
	move.w	d3,$3E(a0)
	clr.w	$40(a0)
	move.b	(a1)+,d3
	ext.w	d3
	move.w	d3,$46(a0)
	moveq	#0,d3
	move.b	(a1)+,d3
	move.w	d3,$42(a0)
	move.b	(a1)+,d3
	move.w	d3,$48(a0)
	move.w	#0,$22(a0)
	dbf	d1,loc_3FC8C
	move.w	#$1E0,(Diamond_power_timer).w
	rts
; ---------------------------------------------------------------------------
;unk_3FCC4:
DiamondPower_InitData_SamuraiHaze:	; initialization data for the 10 diamonds for Samurai Haze
; radius, y_pos, phase, rotation speed
	dc.b  $C,-$24,   0,   2
	dc.b  $C,-$24, $80,   2
	dc.b  $C,   4, $80,   2
	dc.b  $C,   4,   0,   2
	dc.b $15,-$1A, $20,   2
	dc.b $15,-$1A, $A0,   2
	dc.b $15,  -6, $60,   2
	dc.b $15,  -6, $E0,   2
	dc.b $18,-$10, $40,   2
	dc.b $18,-$10, $C0,   2
;unk_3FCEC:
DiamondPower_InitData_Invulnerability:	; initialization data for the 10 diamonds for Invulnerability diamonds
	dc.b  $C,-$24,   0,   6
	dc.b  $C,-$24, $80,   6
	dc.b  $C,   4, $40,   6
	dc.b  $C,   4, $C0,   6
	dc.b $15,-$1A, $10,   6
	dc.b $15,-$1A, $90,   6
	dc.b $15,  -6, $30,   6
	dc.b $15,  -6, $B0,   6
	dc.b $18,-$10, $20,   6
	dc.b $18,-$10, $A0,   6
; ---------------------------------------------------------------------------

DiamondPower_Main_InvulnAndHaze:
	subq.w	#1,(Diamond_power_timer).w
	move.w	(Diamond_power_timer).w,d7
	cmpi.w	#-$1B,d7
	bge.s	loc_3FD28
	bsr.w	sub_3F63C
	rts
; ---------------------------------------------------------------------------

loc_3FD28:
	neg.w	d7
	bpl.s	loc_3FD2E
	moveq	#0,d7

loc_3FD2E:
	lsr.w	#2,d7
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	#$7F,d3
	sub.w	(Camera_X_pos).w,d3
	move.w	#$7F,d4
	sub.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_3FD4C
	rts
; ---------------------------------------------------------------------------

loc_3FD4C:
	move.l	d0,a0
	tst.w	d7
	bne.s	loc_3FD5A
	move.w	$48(a0),d1
	add.w	d1,$42(a0)

loc_3FD5A:
	move.l	$3E(a0),d5
	lsr.l	#8,d5
	lsr.l	#1,d5
	move.w	$42(a0),d0
	bsr.w	sub_40236
	muls.w	d5,d0
	swap	d0
	asr.w	#5,d0
	add.w	x_pos(a3),d0
	add.w	d3,d0
	muls.w	d5,d1
	swap	d1
	asr.w	#5,d1
	addi.w	#$18,d1
	bpl.s	loc_3FD84
	moveq	#0,d1

loc_3FD84:
	lsr.w	#2,d1
	cmpi.w	#$B,d1
	ble.s	loc_3FD8E
	moveq	#$B,d1

loc_3FD8E:
	moveq	#0,d6
	move.b	byte_3FDDC(pc,d1.w),d6
	sub.w	d7,d6
	bmi.s	loc_3FDD2
	move.w	$46(a0),d1
	add.w	y_pos(a3),d1
	add.w	d4,d1
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	cmpi.w	#$C,d6
	bge.s	loc_3FDC2
	move.w	d1,(a4)+
	move.w	(a1,d6.w),(a4)+
	move.w	2(a1,d6.w),(a4)+
	move.w	d0,(a4)+
	bra.s	loc_3FDD2
; ---------------------------------------------------------------------------

loc_3FDC2:
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+

loc_3FDD2:
	move.l	4(a0),d0
	bne.w	loc_3FD4C
	rts
; ---------------------------------------------------------------------------
byte_3FDDC:	dc.b 1
	dc.b   1
	dc.b   2
	dc.b   2
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   3
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b   5
; ---------------------------------------------------------------------------
;loc_3FDE8:
DiamondPower_Init_TrackingRain:
	st	($FFFFF5B9).w
	move.w	#$708,(Diamond_power_timer).w
	bra.s	loc_3FDFE
; ---------------------------------------------------------------------------
;loc_3FDF4:
DiamondPower_Init_SlashingRain:
	sf	($FFFFF5B9).w
	move.w	#$2D0,(Diamond_power_timer).w

loc_3FDFE:
	clr.w	($FFFFF5C0).w
	rts
; ---------------------------------------------------------------------------

DiamondPower_Main_SlashingRain:
	subq.w	#1,(Diamond_power_timer).w
	bmi.w	loc_3FE62
	moveq	#6,d0
	cmp.w	($FFFFF5C0).w,d0
	ble.w	loc_3FE62
	move.w	(Time_Frames).w,d0
	andi.w	#$F,d0
	bne.s	loc_3FE62
	addq.w	#1,($FFFFF5C0).w
	jsr	(j_Get_RandomNumber_byte).w
	lsl.w	#2,d7
	divu.w	#$140,d7
	swap	d7
	jsr	Allocate_DiamondPowerObjectSlot(pc)
	move.w	(Camera_X_pos).w,d0
	add.w	d7,d0
	move.w	d0,$1A(a0)
	clr.w	$1C(a0)
	move.w	(Camera_Y_pos).w,d1
	subq.w	#8,d1
	move.w	d1,$1E(a0)
	move.w	#0,$3E(a0)
	move.w	#4,$24(a0)
	clr.l	$26(a0)
	move.w	#2,$2A(a0)

loc_3FE62:
	move.w	#$7F,d3
	sub.w	(Camera_X_pos).w,d3
	move.w	#$7F,d4
	sub.w	(Camera_Y_pos).w,d4
	move.l	(Addr_GfxObject_Kid).w,a3
	move.l	x_vel(a3),a5
	move.l	a5,d6
	asr.l	#2,d6
	suba.l	d6,a5
	move.w	(Time_Frames).w,d7
	andi.w	#7,d7
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_3FE90
	rts
; ---------------------------------------------------------------------------

loc_3FE90:
	move.l	d0,a0
	tst.w	$3E(a0)
	beq.s	loc_3FEBC

loc_3FE98:
	move.l	$1A(a0),d0
	add.l	$26(a0),d0
	move.l	d0,$1A(a0)
	swap	d0
	add.w	d3,d0
	move.l	$1E(a0),d1
	add.l	$2A(a0),d1
	move.l	d1,$1E(a0)
	swap	d1
	add.w	d4,d1
	bra.w	loc_3FF90
; ---------------------------------------------------------------------------

loc_3FEBC:
	subq.w	#1,d7
	bne.w	loc_3FF70
	tst.b	($FFFFF5B9).w
	beq.w	loc_3FF6E
	move.w	$1A(a0),d0
	sub.w	(Camera_X_pos).w,d0
	move.w	$1E(a0),d1
	sub.w	(Camera_Y_pos).w,d1
	moveq	#-1,d7
	move.l	($FFFFF86A).w,d6
	beq.s	loc_3FF2C

loc_3FEE2:
	move.l	d6,a1
	move.w	$1A(a1),d5
	move.w	$1E(a1),d6
	subi.w	#8,d6
	sub.w	(Camera_X_pos).w,d5
	cmpi.w	#$FFF8,d5
	blt.s	loc_3FF26
	cmpi.w	#$148,d5
	bge.s	loc_3FF26
	sub.w	(Camera_Y_pos).w,d6
	cmpi.w	#$10,d6
	blt.s	loc_3FF26
	cmpi.w	#$F0,d6
	bge.s	loc_3FF26
	sub.w	d0,d5
	bge.s	loc_3FF16
	neg.w	d5

loc_3FF16:
	sub.w	d1,d6
	bge.s	loc_3FF1C
	neg.w	d6

loc_3FF1C:
	add.w	d5,d6
	cmp.w	d6,d7
	bcs.s	loc_3FF26
	move.w	d6,d7
	move.l	a1,a3

loc_3FF26:
	move.l	4(a1),d6
	bne.s	loc_3FEE2

loc_3FF2C:
	cmpi.w	#8,d7
	bcs.s	loc_3FF6E
	cmpi.w	#$40,d7
	bcc.s	loc_3FF6E
	moveq	#0,d6
	lsr.w	#3,d7

loc_3FF3C:
	addq.w	#1,d6
	lsr.w	#1,d7
	bne.s	loc_3FF3C
	move.l	x_pos(a3),d0
	sub.l	$1A(a0),d0
	asr.l	d6,d0
	move.l	d0,$26(a0)
	move.l	y_pos(a3),d0
	subi.l	#$80000,d0
	sub.l	$1E(a0),d0
	asr.l	d6,d0
	move.l	d0,$2A(a0)
	addq.w	#1,$3E(a0)
	moveq	#$14,d7
	bra.w	loc_3FE98
; ---------------------------------------------------------------------------

loc_3FF6E:
	moveq	#$14,d7

loc_3FF70:
	move.l	$1A(a0),d0
	add.l	$26(a0),d0
	add.l	a5,d0
	move.l	d0,$1A(a0)
	swap	d0
	add.w	d3,d0
	move.w	$1E(a0),d1
	add.w	$2A(a0),d1
	move.w	d1,$1E(a0)
	add.w	d4,d1

loc_3FF90:
	move.w	$24(a0),d6
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d6,d5
	addi.w	#$1144,d5
	move.w	d5,$22(a0)
	tst.w	d0
	ble.s	loc_3FFC0
	cmpi.w	#$1C8,d0
	bge.s	loc_3FFC0
	cmpi.w	#$68,d1
	ble.s	loc_3FFC0
	cmpi.w	#$168,d1
	ble.s	loc_3FFCA

loc_3FFC0:
	bsr.w	sub_3F5E8
	subq.w	#1,($FFFFF5C0).w
	bra.s	loc_3FFDA
; ---------------------------------------------------------------------------

loc_3FFCA:
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+

loc_3FFDA:
	move.l	4(a0),d0
	bne.w	loc_3FE90
	rts
; ---------------------------------------------------------------------------
;loc_3FFE4:
DiamondPower_Init_WallOfDeath:
	moveq	#9,d1
	moveq	#0,d2
	moveq	#$D,d3

loc_3FFEA:
	bsr.w	Allocate_DiamondPowerObjectSlot
	move.w	d2,$3E(a0)
	move.w	d3,$40(a0)
	sf	$42(a0)
	move.w	#6,$24(a0)
	subq.w	#8,d2

loc_40002:
	addi.w	#$16,d3

loc_40006:
	dbf	d1,loc_3FFEA
	move.w	#$4B0,(Diamond_power_timer).w
	rts
; ---------------------------------------------------------------------------

DiamondPower_Main_WallOfDeath:
	subq.w	#1,(Diamond_power_timer).w
	move.w	(Camera_X_pos).w,d3
	move.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_40026
	rts
; ---------------------------------------------------------------------------

loc_40026:
	move.l	d0,a0
	move.w	$3E(a0),d0
	move.w	$40(a0),d1
	tst.b	$42(a0)
	bne.s	loc_40044
	addq.w	#8,$3E(a0)
	cmpi.w	#$139,d0
	blt.s	loc_4006E
	st	$42(a0)

loc_40044:
	tst.w	(Diamond_power_timer).w
	bpl.s	loc_40060
	move.w	(Diamond_power_timer).w,d7
	andi.w	#7,d7
	bne.s	loc_40060
	subq.w	#1,$24(a0)
	bpl.s	loc_40060
	bsr.w	sub_3F5E8
	bra.s	loc_400B0
; ---------------------------------------------------------------------------

loc_40060:
	subq.w	#8,$3E(a0)
	cmpi.w	#7,d0
	bgt.s	loc_4006E
	sf	$42(a0)

loc_4006E:
	move.w	d0,d5
	add.w	d3,d5
	move.w	d5,$1A(a0)
	move.w	d1,d5
	add.w	d4,d5
	move.w	d5,$1E(a0)
	addi.w	#$7F,d0
	addi.w	#$7F,d1
	move.w	$24(a0),d6
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d6,d5
	addi.w	#$1144,d5

loc_4009C:
	move.w	d5,$22(a0)
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+

loc_400B0:
	move.l	4(a0),d0
	bne.w	loc_40026
	rts
; ---------------------------------------------------------------------------

DiamondPower_Init_FiveWayShot:

	st	(Diamond_power_active).w
	subq.w	#5,(Number_Diamonds).w
	bsr.w	Initialize_DiamondPowerObjectSlots
	move.w	#5,(Diamond_power_ID).w
	moveq	#4,d1
	move.l	(Addr_GfxObject_Kid).w,a3
	move.w	#$20,d4
	tst.b	x_direction(a3)
	beq.s	loc_400DE
	neg.w	d4

loc_400DE:
	move.w	x_pos(a3),d2
	sub.w	(Camera_X_pos).w,d2
	add.w	d4,d2
	move.w	y_pos(a3),d3
	sub.w	(Camera_Y_pos).w,d3
	lea	word_40124(pc),a5

loc_400F4:
	bsr.w	Allocate_DiamondPowerObjectSlot
	move.w	#5,$24(a0)
	move.w	d2,$3E(a0)
	move.w	d3,$40(a0)
	move.w	(a5)+,d4
	tst.b	x_direction(a3)
	beq.s	loc_40110
	neg.w	d4

loc_40110:
	move.w	d4,$26(a0)
	move.w	(a5)+,$2A(a0)
	dbf	d1,loc_400F4
	move.w	#$50,(Diamond_power_timer).w
	rts
; End of function DiamondPower_Run

; ---------------------------------------------------------------------------
word_40124:	dc.w 6
	dc.w $FFFC
	dc.w 7
	dc.w $FFFE
	dc.w 8
	dc.w 0
	dc.w 7
	dc.w 2
	dc.w 6
	dc.w 4
; ---------------------------------------------------------------------------

DiamondPower_Main_FiveWayShot:
	subq.w	#1,(Diamond_power_timer).w
	move.w	(Camera_X_pos).w,d3
	move.w	(Camera_Y_pos).w,d4
	move.l	(Addr_FirstDPObjectSlot).w,d0
	bne.s	loc_4014C
	rts
; ---------------------------------------------------------------------------

loc_4014C:
	move.l	d0,a0
	move.w	$3E(a0),d0
	move.w	$40(a0),d1
	add.w	$26(a0),d0
	bpl.s	loc_40166
	tst.w	$26(a0)
	bge.s	loc_40166
	neg.w	$26(a0)

loc_40166:
	cmpi.w	#$140,d0
	blt.s	loc_40176
	tst.w	$26(a0)
	ble.s	loc_40176
	neg.w	$26(a0)

loc_40176:
	move.w	d0,$3E(a0)
	add.w	$2A(a0),d1
	bpl.s	loc_4018A
	tst.w	$2A(a0)
	bge.s	loc_4018A
	neg.w	$2A(a0)

loc_4018A:
	cmpi.w	#$E0,d1
	blt.s	loc_4019A
	tst.w	$2A(a0)
	ble.s	loc_4019A
	neg.w	$2A(a0)

loc_4019A:
	move.w	d1,$40(a0)
	tst.w	(Diamond_power_timer).w
	bpl.s	loc_401BA
	move.w	(Diamond_power_timer).w,d7
	andi.w	#7,d7
	bne.s	loc_401BA
	subq.w	#1,$24(a0)
	bpl.s	loc_401BA
	bsr.w	sub_3F5E8
	bra.s	loc_401FC
; ---------------------------------------------------------------------------

loc_401BA:
	move.w	d0,d5
	add.w	d3,d5
	move.w	d5,$1A(a0)
	move.w	d1,d5
	add.w	d4,d5
	move.w	d5,$1E(a0)
	addi.w	#$7F,d0
	addi.w	#$7F,d1
	move.w	$24(a0),d6
	sub.w	d6,d0
	sub.w	d6,d1
	add.w	d6,d6
	add.w	d6,d6
	lea	word_4020E(pc),a1
	move.w	d6,d5
	addi.w	#$1144,d5
	move.w	d5,$22(a0)
	move.w	d1,(a2)+
	move.b	(a1,d6.w),(a2)+
	addq.b	#1,d2
	move.b	d2,(a2)+
	move.w	2(a1,d6.w),(a2)+
	move.w	d0,(a2)+

loc_401FC:
	move.l	4(a0),d0
	bne.w	loc_4014C
	rts
; ---------------------------------------------------------------------------
;loc_40206:
DiamondPower_Init_DeathSnake2:
	bra.w	DiamondPower_Init_DeathSnake
; ---------------------------------------------------------------------------

DiamondPower_Main_Snake2:
	bra.w	DiamondPower_Main_Snake
; ---------------------------------------------------------------------------
word_4020E:
	dc.w	 0,$86EA
	dc.w	 0,$86EB
	dc.w	 0,$86EC
	dc.w	 0,$86ED
	dc.w  $500,$86EE
	dc.w  $500,$86F2
	dc.w  $500,$86F6
	dc.w  $500,$8231
	dc.w	 0,$822D
	dc.w  $500,$E6FA

; =============== S U B	R O U T	I N E =======================================


sub_40236:
	andi.w	#$FF,d0
	add.w	d0,d0
	cmpi.w	#$100,d0
	bge.s	loc_40274
	cmpi.w	#$80,d0
	bge.s	loc_4025A
	move.w	d0,d1
	subi.w	#$80,d0
	neg.w	d0
	move.w	word_402B0(pc,d0.w),d0
	move.w	word_402B0(pc,d1.w),d1
	rts
; ---------------------------------------------------------------------------

loc_4025A:
	subi.w	#$100,d0
	neg.w	d0
	move.w	d0,d1
	subi.w	#$80,d0
	neg.w	d0
	move.w	word_402B0(pc,d0.w),d0
	neg.w	d0
	move.w	word_402B0(pc,d1.w),d1
	rts
; ---------------------------------------------------------------------------

loc_40274:
	cmpi.w	#$180,d0
	bge.s	loc_40294
	subi.w	#$100,d0
	move.w	d0,d1
	subi.w	#$80,d0
	neg.w	d0
	move.w	word_402B0(pc,d0.w),d0
	neg.w	d0
	move.w	word_402B0(pc,d1.w),d1
	neg.w	d1
	rts
; ---------------------------------------------------------------------------

loc_40294:
	subi.w	#$200,d0
	neg.w	d0
	move.w	d0,d1
	subi.w	#$80,d0
	neg.w	d0
	move.w	word_402B0(pc,d0.w),d0
	move.w	word_402B0(pc,d1.w),d1
	neg.w	d1
	rts
; End of function sub_40236

; ---------------------------------------------------------------------------
	dc.b $E0
	dc.b   0

word_402B0:
	dc.w	 0
	dc.w  $192
	dc.w  $324
	dc.w  $4B5
	dc.w  $646
	dc.w  $7D5
	dc.w  $964
	dc.w  $AF1
	dc.w  $C7C
	dc.w  $E06
	dc.w  $F8D
	dc.w $1112
	dc.w $1294
	dc.w $1413
	dc.w $158F
	dc.w $1707
	dc.w $187D
	dc.w $19EF
	dc.w $1B5D
	dc.w $1CC7
	dc.w $1E2B
	dc.w $1F8B
	dc.w $20E7
	dc.w $223C
	dc.w $238E
	dc.w $24DA
	dc.w $2620
	dc.w $2760
	dc.w $2899
	dc.w $29CD
	dc.w $2AFB
	dc.w $2C21
	dc.w $2D40
	dc.w $2E5A
	dc.w $2F6C
	dc.w $3076
	dc.w $317A
	dc.w $3276
	dc.w $336A
	dc.w $3452
	dc.w $3538
	dc.w $3614
	dc.w $36E4
	dc.w $37B0
	dc.w $3872
	dc.w $392C
	dc.w $39DC
	dc.w $3A82
	dc.w $3B20
	dc.w $3BB8
	dc.w $3C42
	dc.w $3CC6
	dc.w $3D40
	dc.w $3DAE
	dc.w $3E16
	dc.w $3E72
	dc.w $3EC4
	dc.w $3F0E
	dc.w $3F4E
	dc.w $3F84
	dc.w $3FB0
	dc.w $3FD2
	dc.w $3FEC
	dc.w $3FFA
	dc.w $3FFE
	dc.w $FFFF
	dc.w $FFFF
	dc.w $FFFF
	dc.w $FFFF
; ---------------------------------------------------------------------------
; 4033A
MapHeader_BaseAddress:
	dc.w Start_LevelID
	dc.w 0

; 4033E
LnkTo_MapOrder_Index:	dc.l MapOrder_Index 

; 40342
MapHeader_Index:
	include "level/mapheader_index.asm"

; 4043E
MapOrder_Index:
	include	"level/maporder.asm"
	align 2

	include "level/mapheader_definitions.asm"
	align	2

	include "level/foreground_includes.asm"
	align	2

	include "level/background_includes.asm"
	;align	2	; Block layouts aren't aligned in the original.

	include "level/block_includes.asm"
	align	2

	include "level/enemy_includes.asm"
; ---------------------------------------------------------------------------
; filler
    rept 534
	dc.b	$FF
    endm

	align	2
; ---------------------------------------------------------------------------
MainAddr_Index:	dc.l ThemeArtFront_Index 
LnkTo_ThemeArtBack_Index:	dc.l ThemeArtBack_Index 
LnkTo_ThemeMappings_Index:	dc.l ThemeMappings_Index
LnkTo_unk_7B8DC:	dc.l unk_7B8DC
LnkTo_ThemePal1_Index:	dc.l ThemePal1_Index
LnkTo_ThemePal2_Index:	dc.l ThemePal2_Index
LnkTo_ThemeCollision_Index:	dc.l	ThemeCollision_Index
LnkTo_ArtComp_992E4_Blocks:	dc.l ArtComp_992E4_Blocks
LnkTo_off_7B3E4:	dc.l off_7B3E4
LnkTo_ArtComp_99F34_IngameNumbers:dc.l ArtComp_99F34_IngameNumbers 
LnkTo_BackgroundScroll_Index:	dc.l BackgroundScroll_Index
LnkTo_unk_9784A:	dc.l unk_9784A
LnkTo_unk_97B2C:	dc.l unk_97B2C
LnkTo_unk_97E0E:	dc.l unk_97E0E
LnkTo_unk_980F0:	dc.l unk_980F0
LnkTo_Pal_7B684:	dc.l Pal_7B684
LnkTo_Pal_7B6A2:	dc.l Pal_7B6A2
LnkTo_Pal_7B6C0:	dc.l Pal_7B6C0
LnkTo_Pal_7B6DE:	dc.l Pal_7B6DE
LnkTo_Pal_7B6FC:	dc.l Pal_7B6FC
LnkTo_Pal_7B71A:	dc.l Pal_7B71A
LnkTo_Pal_7B738:	dc.l Pal_7B738
LnkTo_Pal_7B756:	dc.l Pal_7B756
LnkTo_Pal_7B792:	dc.l Pal_7B792
LnkTo_Pal_7B7B0:	dc.l Pal_7B7B0
LnkTo_Pal_7B7CE:	dc.l Pal_7B7CE
LnkTo0_Pal_7B7EC:	dc.l Pal_7B7EC
LnkTo_Pal_7B7EC:	dc.l Pal_7B7EC
LnkTo_Pal_7B7FC:	dc.l Pal_7B7FC
LnkTo_Pal_7B80C:	dc.l Pal_7B80C
LnkTo_Pal_7B81C:	dc.l Pal_7B81C
LnkTo_Pal_7B82C:	dc.l Pal_7B82C
LnkTo_Pal_7B83C:	dc.l Pal_7B83C
LnkTo_Pal_7B84C:	dc.l Pal_7B84C
LnkTo_Pal_7B87C:	dc.l Pal_7B87C
LnkTo_Pal_7B88C:	dc.l Pal_7B88C
LnkTo_Pal_7B89C:	dc.l Pal_7B89C
off_7B0AC:	dc.l unk_99FCA
	dc.l unk_9A1CC
	dc.l unk_9A3CE
	dc.l unk_9A5D0
LnkTo_unk_9B65C:	dc.l unk_9B65C
LnkTo_Pal_7B774:	dc.l Pal_7B774
LnkTo_Pal_7B85C:	dc.l Pal_7B85C
LnkTo_Pal_7B86C:	dc.l Pal_7B86C
LnkTo_ArtComp_9A7D2:	dc.l ArtComp_9A7D2
LnkTo_ArtComp_983D2_Lava:	dc.l ArtComp_983D2_Lava
LnkTo_Pal_7B8AC:	dc.l Pal_7B8AC
LnkTo_ArtComp_99090_Rain:	dc.l ArtComp_99090_Rain
LnkTo_Pal_7B8BC:	dc.l Pal_7B8BC
LnkTo_unk_9B6E0:	dc.l unk_9B6E0
LnkTo_ArtComp_991ED_Hail:	dc.l ArtComp_991ED_Hail
LnkTo_Pal_7B8CC:	dc.l Pal_7B8CC
LnkTo_unk_9AA50:	dc.l unk_9AA50
	dc.l unk_9AC52
	dc.l unk_9AE54
	dc.l unk_9B056
	dc.l unk_9B258
	dc.l unk_9B45A
ThemeArtFront_Index:dc.l unk_80E84
	dc.l unk_80E86
	dc.l unk_82B58
	dc.l unk_84911
	dc.l unk_8676F
	dc.l unk_88795
	dc.l unk_8A321
	dc.l unk_8C54C
	dc.l unk_8E2D8
	dc.l unk_902C2
	dc.l unk_92226
ThemeArtBack_Index:dc.l	unk_93C94
	dc.l unk_93C94
	dc.l unk_9422F
	dc.l unk_9489A
	dc.l unk_94B50
	dc.l unk_94D92
	dc.l unk_95506
	dc.l unk_95B76
	dc.l unk_96045
	dc.l unk_96514
	dc.l unk_96B49
	dc.l unk_970D2
	dc.l unk_9729F
	dc.l unk_97381
ThemeMappings_Index:dc.l unk_7C4EC
	dc.l unk_7C51C
	dc.l unk_7CCE4
	dc.l unk_7D364
	dc.l unk_7DB24
	dc.l unk_7E304
	dc.l unk_7E9AC
	dc.l unk_7F1A4
	dc.l unk_7F80C
	dc.l unk_7FE94
	dc.l unk_8068C
ThemePal1_Index:dc.w LnkTo_Pal_7B684-MainAddr_Index
	dc.w LnkTo_Pal_7B6A2-MainAddr_Index
	dc.w LnkTo_Pal_7B6C0-MainAddr_Index
	dc.w LnkTo_Pal_7B6DE-MainAddr_Index
	dc.w LnkTo_Pal_7B6FC-MainAddr_Index
	dc.w LnkTo_Pal_7B71A-MainAddr_Index
	dc.w LnkTo_Pal_7B738-MainAddr_Index
	dc.w LnkTo_Pal_7B756-MainAddr_Index
	dc.w LnkTo_Pal_7B792-MainAddr_Index
	dc.w LnkTo_Pal_7B7B0-MainAddr_Index
	dc.w LnkTo_Pal_7B7CE-MainAddr_Index
ThemePal2_Index:dc.w LnkTo0_Pal_7B7EC-MainAddr_Index
	dc.w LnkTo_Pal_7B7EC-MainAddr_Index
	dc.w LnkTo_Pal_7B7FC-MainAddr_Index
	dc.w LnkTo_Pal_7B80C-MainAddr_Index
	dc.w LnkTo_Pal_7B81C-MainAddr_Index
	dc.w LnkTo_Pal_7B82C-MainAddr_Index
	dc.w LnkTo_Pal_7B83C-MainAddr_Index
	dc.w LnkTo_Pal_7B84C-MainAddr_Index
	dc.w LnkTo_Pal_7B87C-MainAddr_Index
	dc.w LnkTo_Pal_7B88C-MainAddr_Index
	dc.w LnkTo_Pal_7B89C-MainAddr_Index
ThemeCollision_Index:dc.l unk_7BB64
	dc.l unk_7BB6A
	dc.l unk_7BC62
	dc.l unk_7BD5E
	dc.l unk_7BE57
	dc.l unk_7BF53
	dc.l unk_7C02C
	dc.l unk_7C128
	dc.l unk_7C1F5
	dc.l unk_7C2F1
	dc.l unk_7C3F1
BackgroundScroll_Index:
	include "level/bgscroll_index.asm"
off_7B3E4:	dc.l off_7B410
	dc.l off_7B410
	dc.l off_7B490
	dc.l off_7B520
	dc.l off_7B52C
	dc.l off_7B560
	dc.l off_7B56C
	dc.l off_7B5D8
	dc.l off_7B5EC
	dc.l off_7B640
	dc.l off_7B64C
off_7B410:	dc.l unk_9B83C
	dc.l unk_9B842
	dc.l unk_9B852
	dc.l unk_9B868
	dc.l unk_9B884
	dc.l unk_9B8AC
	dc.l unk_9B8BC
	dc.l unk_9B8D0
	dc.l unk_9B8EA
	dc.l unk_9B910
	dc.l unk_9B93C
	dc.l unk_9B974
	dc.l unk_9B9C4
	dc.l unk_9B9DE
	dc.l unk_9BA1A
	dc.l unk_9BA2A
	dc.l unk_9BA32
	dc.l unk_9BA66
	dc.l unk_9BA8C
	dc.l unk_9BA9C
	dc.l unk_9BC08
	dc.l unk_9BC34
	dc.l unk_9BC60
	dc.l unk_9BCB4
	dc.l unk_9BDF8
	dc.l unk_9BDFE
	dc.l unk_9BE08
	dc.l unk_9BE10
	dc.l unk_9BE1E
	dc.l unk_9BE2E
	dc.l unk_9BE40
	dc.l unk_9BE58
off_7B490:	dc.l unk_9BE76
	dc.l unk_9BEF2
	dc.l unk_9BF1E
	dc.l unk_9BF4A
	dc.l unk_9BF9E
	dc.l unk_9C01A
	dc.l unk_9C022
	dc.l unk_9C02C
	dc.l unk_9C03E
	dc.l unk_9C058
	dc.l unk_9C07C
	dc.l unk_9C08A
	dc.l unk_9C156
	dc.l unk_9C1C6
	dc.l unk_9C1FA
	dc.l unk_9C20E
	dc.l unk_9C21C
	dc.l unk_9C234
	dc.l unk_9C240
	dc.l unk_9C254
	dc.l unk_9C25C
	dc.l unk_9C264
	dc.l unk_9C270
	dc.l unk_9C286
	dc.l unk_9C2AE
	dc.l unk_9C30C
	dc.l unk_9C3A6
	dc.l unk_9C440
	dc.l unk_9C476
	dc.l unk_9C4AC
	dc.l unk_9C4E2
	dc.l unk_9C518
	dc.l unk_9C594
	dc.l unk_9C5C0
	dc.l unk_9C5EC
	dc.l unk_9C618
off_7B520:	dc.l unk_9C644
	dc.l unk_9C7B6
	dc.l unk_9C934
off_7B52C:	dc.l unk_9CBAE
	dc.l unk_9CBC6
	dc.l unk_9CBDC
	dc.l unk_9CC0A
	dc.l unk_9CC5C
	dc.l unk_9CC9C
	dc.l unk_9CCB2
	dc.l unk_9CCC6
	dc.l unk_9CCE0
	dc.l unk_9CCEE
	dc.l unk_9CD14
	dc.l unk_9CD24
	dc.l unk_9CD3E
off_7B560:	dc.l unk_9CD68
	dc.l unk_9CE0C
	dc.l unk_9CEC6
off_7B56C:	dc.l unk_9D044
	dc.l unk_9D0FC
	dc.l unk_9D114
	dc.l unk_9D17C
	dc.l unk_9D234
	dc.l unk_9D24C
	dc.l unk_9D2B4
	dc.l unk_9D36C
	dc.l unk_9D384
	dc.l unk_9D3EC
	dc.l unk_9D4A4
	dc.l unk_9D4BC
	dc.l unk_9D524
	dc.l unk_9D5DC
	dc.l unk_9D5F4
	dc.l unk_9D65C
	dc.l unk_9D726
	dc.l unk_9D740
	dc.l unk_9D7B2
	dc.l unk_9D86A
	dc.l unk_9D882
	dc.l unk_9D8EA
	dc.l unk_9D8FE
	dc.l unk_9D948
	dc.l unk_9D992
	dc.l unk_9D9DC
	dc.l unk_9DA26
off_7B5D8:	dc.l unk_9DA3A
	dc.l unk_9DBF2
	dc.l unk_9DDC0
	dc.l unk_9DEAC
	dc.l unk_9DFAC
off_7B5EC:	dc.l unk_9E004
	dc.l unk_9E228
	dc.l unk_9E3CC
	dc.l unk_9E4BA
	dc.l unk_9E880
	dc.l unk_9E8EC
	dc.l unk_9E958
	dc.l unk_9E9B6
	dc.l unk_9E9CE
	dc.l unk_9E9D8
	dc.l unk_9E9DE
	dc.l unk_9E9E6
	dc.l unk_9E9EE
	dc.l unk_9E9FA
	dc.l unk_9EA76
	dc.l unk_9EAA2
	dc.l unk_9EB1E
	dc.l unk_9EB72
	dc.l unk_9EB9E
	dc.l unk_9EBCA
	dc.l unk_9EBF6
off_7B640:	dc.l unk_9EC22
	dc.l unk_9EDAA
	dc.l unk_9EF3E
off_7B64C:	dc.l unk_9F124
	dc.l unk_9F144
	dc.l unk_9F164
	dc.l unk_9F258
	dc.l unk_9F34C
	dc.l unk_9F436
	dc.l unk_9F534
	dc.l unk_9F61E
	dc.l unk_9F6B8
	dc.l unk_9F7C0
	dc.l unk_9F88C
	dc.l unk_9F912
	dc.l unk_9F998
	dc.l unk_9F9EC
Pal_7B684:  binclude    "theme/palette_fg/theme0.bin"
Pal_7B6A2:  binclude    "theme/palette_fg/sky.bin"
Pal_7B6C0:  binclude    "theme/palette_fg/ice.bin"
Pal_7B6DE:  binclude    "theme/palette_fg/hill.bin"
Pal_7B6FC:  binclude    "theme/palette_fg/island.bin"
Pal_7B71A:  binclude    "theme/palette_fg/desert.bin"
Pal_7B738:  binclude    "theme/palette_fg/swamp.bin"
Pal_7B756:  binclude    "theme/palette_fg/mountain.bin"
Pal_7B774:  binclude    "theme/palette_fg/mountain_storm.bin"
Pal_7B792:  binclude    "theme/palette_fg/cave.bin"
Pal_7B7B0:  binclude    "theme/palette_fg/forest.bin"
Pal_7B7CE:  binclude    "theme/palette_fg/city.bin"
Pal_7B7EC:  binclude    "theme/palette_bg/sky.bin"
Pal_7B7FC:  binclude    "theme/palette_bg/ice.bin"
Pal_7B80C:  binclude    "theme/palette_bg/hill.bin"
Pal_7B81C:  binclude    "theme/palette_bg/island.bin"
Pal_7B82C:  binclude    "theme/palette_bg/desert.bin"
Pal_7B83C:  binclude    "theme/palette_bg/swamp.bin"
Pal_7B84C:  binclude    "theme/palette_bg/mountain.bin"
Pal_7B85C:  binclude    "theme/palette_bg/mountain_storm.bin"
Pal_7B86C:  binclude    "theme/palette_bg/mountain_lightning.bin"
Pal_7B87C:  binclude    "theme/palette_bg/cave.bin"
Pal_7B88C:  binclude    "theme/palette_bg/forest.bin"
Pal_7B89C:  binclude    "theme/palette_bg/city.bin"
Pal_7B8AC:  binclude	"ingame/palette/lava.bin"
Pal_7B8BC:  binclude	"ingame/palette/hail_mountain.bin"
Pal_7B8CC:  binclude	"ingame/palette/hail_ice.bin"

unk_7B8DC:  binclude    "theme/block_mappings.bin"

unk_7BB64:  binclude    "theme/collision/theme0.bin"
unk_7BB6A:  binclude    "theme/collision/sky.bin"
unk_7BC62:  binclude    "theme/collision/ice.bin"
unk_7BD5E:  binclude    "theme/collision/hill.bin"
unk_7BE57:  binclude    "theme/collision/island.bin"
unk_7BF53:  binclude    "theme/collision/desert.bin"
unk_7C02C:  binclude    "theme/collision/swamp.bin"
unk_7C128:  binclude    "theme/collision/mountain.bin"
unk_7C1F5:  binclude    "theme/collision/cave.bin"
unk_7C2F1:  binclude    "theme/collision/forest.bin"
unk_7C3F1:  binclude    "theme/collision/city.bin"
	align	2
unk_7C4EC:  binclude    "theme/mappings/theme0.bin"
unk_7C51C:  binclude    "theme/mappings/sky.bin"
unk_7CCE4:  binclude    "theme/mappings/ice.bin"
unk_7D364:  binclude    "theme/mappings/hill.bin"
unk_7DB24:  binclude    "theme/mappings/island.bin"
unk_7E304:  binclude    "theme/mappings/desert.bin"
unk_7E9AC:  binclude    "theme/mappings/swamp.bin"
unk_7F1A4:  binclude    "theme/mappings/mountain.bin"
unk_7F80C:  binclude    "theme/mappings/cave.bin"
unk_7FE94:  binclude    "theme/mappings/forest.bin"
unk_8068C:  binclude    "theme/mappings/city.bin"

unk_80E84:  binclude    "theme/artcomp_fg/theme0.bin"
unk_80E86:  binclude    "theme/artcomp_fg/sky.bin"
unk_82B58:  binclude    "theme/artcomp_fg/ice.bin"
unk_84911:  binclude    "theme/artcomp_fg/hill.bin"
unk_8676F:  binclude    "theme/artcomp_fg/island.bin"
unk_88795:  binclude    "theme/artcomp_fg/desert.bin"
unk_8A321:  binclude    "theme/artcomp_fg/swamp.bin"
unk_8C54C:  binclude    "theme/artcomp_fg/mountain.bin"
unk_8E2D8:  binclude    "theme/artcomp_fg/cave.bin"
unk_902C2:  binclude    "theme/artcomp_fg/forest.bin"
unk_92226:  binclude    "theme/artcomp_fg/city.bin"
	align	2
unk_93C94:  binclude    "theme/artcomp_bg/sky.bin"
unk_9422F:  binclude    "theme/artcomp_bg/ice.bin"
unk_9489A:  binclude    "theme/artcomp_bg/hill.bin"
unk_94B50:  binclude    "theme/artcomp_bg/island.bin"
unk_94D92:  binclude    "theme/artcomp_bg/desert.bin"
unk_95506:  binclude    "theme/artcomp_bg/swamp.bin"
unk_95B76:  binclude    "theme/artcomp_bg/mountain.bin"
unk_96045:  binclude    "theme/artcomp_bg/cave.bin"
unk_96514:  binclude    "theme/artcomp_bg/forest.bin"
unk_96B49:  binclude    "theme/artcomp_bg/city.bin"
unk_970D2:  binclude    "theme/artcomp_bg/cave_alt.bin"
unk_9729F:  binclude    "theme/artcomp_bg/mountain_lightning.bin"
unk_97381:  binclude    "theme/artcomp_bg/hill_alt.bin"
	align	2

	align_dmasafe	ANIART_SHORE_SIZE+2
unk_9784A:	dc.w	$17
	binclude	"ingame/artunc/shore_1.bin"
	align_dmasafe	ANIART_SHORE_SIZE+2
unk_97B2C:	dc.w	$17
	binclude	"ingame/artunc/shore_2.bin"
	align_dmasafe	ANIART_SHORE_SIZE+2
unk_97E0E:	dc.w	$17
	binclude	"ingame/artunc/shore_3.bin"
	align_dmasafe	ANIART_SHORE_SIZE+2
unk_980F0:	dc.w	$17
	binclude	"ingame/artunc/shore_4.bin"

ArtComp_983D2_Lava:  
	binclude    "ingame/artcomp/Lava.bin"
	align	2
ArtComp_99090_Rain:  
	binclude    "ingame/artcomp/Rain.bin"
ArtComp_991ED_Hail:  
	binclude    "ingame/artcomp/Hail_Sparkles.bin"
	align	2
ArtComp_992E4_Blocks:  
	binclude    "ingame/artcomp/Blocks.bin"
	align	2
ArtComp_99F34_IngameNumbers:  
	binclude    "ingame/artcomp/HUD_numbers.bin"
	align	2

	align_dmasafe	ANIART_DIAMOND_SIZE+2
unk_99FCA:	dc.w	$10
	binclude	"ingame/artunc/diamond_1.bin"
	align_dmasafe	ANIART_DIAMOND_SIZE+2
unk_9A1CC:	dc.w	$10
	binclude	"ingame/artunc/diamond_2.bin"
	align_dmasafe	ANIART_DIAMOND_SIZE+2
unk_9A3CE:	dc.w	$10
	binclude	"ingame/artunc/diamond_3.bin"
	align_dmasafe	ANIART_DIAMOND_SIZE+2
unk_9A5D0:	dc.w	$10
	binclude	"ingame/artunc/diamond_4.bin"

ArtComp_9A7D2:  
	binclude    "ingame/artcomp/Spinning_rock_(loaded_into_VRAM_but_unused).bin"
	align	2

unk_9AA50:	dc.w	$10
	binclude	"scenes/artunc/unknown_1.bin"
unk_9AC52:	dc.w	$10
	binclude	"scenes/artunc/unknown_2.bin"
unk_9AE54:	dc.w	$10
	binclude	"scenes/artunc/unknown_3.bin"
unk_9B056:	dc.w	$10
	binclude	"scenes/artunc/unknown_4.bin"
unk_9B258:	dc.w	$10
	binclude	"scenes/artunc/unknown_grid_1.bin"
unk_9B45A:	dc.w	$10
	binclude	"scenes/artunc/unknown_grid_2.bin"

unk_9B65C:	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   9
	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b  $B
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b  $E
	dc.b   0
	dc.b  $F
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $11
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $12
	dc.b   0
	dc.b $13
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $15
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $16
	dc.b   0
	dc.b $17
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b $19
	dc.b   0
	dc.b $1A
	dc.b   0
	dc.b $1B
	dc.b   0
	dc.b $1C
	dc.b   0
	dc.b $1D
	dc.b   0
	dc.b $1E
	dc.b   0
	dc.b $1F
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b $21 ; !
	dc.b   0
	dc.b $22 ; "
	dc.b   0
	dc.b $23 ; #
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b $25 ; %
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $26 ; &
	dc.b   0
	dc.b $27 ; '
	dc.b   0
	dc.b $28 ; (
	dc.b   0
	dc.b $29 ; )
	dc.b   0
	dc.b $2A ; *
	dc.b   0
	dc.b $2B ; +
	dc.b   0
	dc.b $2C ; ,
	dc.b   0
	dc.b $2D ; -
	dc.b   0
	dc.b $2E ; .
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $2F ; /
	dc.b   0
	dc.b $30 ; 0
	dc.b   0
	dc.b $31 ; 1
	dc.b   0
	dc.b $32 ; 2
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b $33 ; 3
	dc.b   0
	dc.b $34 ; 4
unk_9B6E0:	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   9
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b  $B
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b  $E
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b  $F
	dc.b   0
	dc.b $10
	dc.b   0
	dc.b $11
	dc.b   0
	dc.b $12
	dc.b   0
	dc.b   9
	dc.b   0
	dc.b $13
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $14
	dc.b   0
	dc.b $15
	dc.b   0
	dc.b $16
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $17
	dc.b   0
	dc.b $18
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $19
	dc.b   0
	dc.b $1A
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $1B
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $1C
	dc.b   0
	dc.b $1D
	dc.b   0
	dc.b $1E
	dc.b   0
	dc.b $1F
	dc.b $18
	dc.b $13
	dc.b   0
	dc.b $20
	dc.b   0
	dc.b $21 ; !
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $22 ; "
	dc.b   0
	dc.b $23 ; #
	dc.b   0
	dc.b $24 ; $
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $25 ; %
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $26 ; &
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $27 ; '

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b   2
	dc.b   0
	dc.b   3
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   5
	dc.b   0
	dc.b   6
	dc.b   0
	dc.b   7
	dc.b   0
	dc.b   8
	dc.b   0
	dc.b   9
	dc.b   0
	dc.b  $A
	dc.b   0
	dc.b  $B
	dc.b   0
	dc.b  $C
	dc.b   0
	dc.b  $D
	dc.b   0
	dc.b  $E
	dc.b   0
	dc.b  $F

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   6
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b $19
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $A8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $88 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $98 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $B8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $98 ; �

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   6
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b $19
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $A8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $88 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $98 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $B8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $98 ; �

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   6
	dc.b   4
	dc.b   4
	dc.b   5
	dc.b $19
	dc.b   0
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $A8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $88 ; �
	dc.b   0
	dc.b   0
	dc.b   0
	dc.b   1
	dc.b   0
	dc.b $35 ; 5
	dc.b $D0 ; �
	dc.b $98 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $B8 ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $98 ; �

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   9
	dc.b $D4 ; �
	dc.b $5D ; ]
	dc.b   0
	dc.b $35 ; 5
	dc.b $D5 ; �
	dc.b $BC ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $E0 ; �
	dc.b   0
	dc.b $24 ; $
	dc.b $25 ; %
	dc.b $CC ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $8C ; �
	dc.b   0
	dc.b $FF
	dc.b $4B ; K
	dc.b $88 ; �
	dc.b   0
	dc.b $24 ; $
	dc.b $25 ; %
	dc.b $CC ; �
	dc.b   0
	dc.b   9
	dc.b $38 ; 8
	dc.b $E3 ; �

	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   4
	dc.b   0
	dc.b   9
	dc.b $D4 ; �
	dc.b $5D ; ]
	dc.b   0
	dc.b $35 ; 5
	dc.b $D5 ; �
	dc.b $BC ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $E0 ; �
	dc.b   0
	dc.b $24 ; $
	dc.b $25 ; %
	dc.b $CC ; �
	dc.b   0
	dc.b $35 ; 5
	dc.b $CE ; �
	dc.b $8C ; �
	dc.b   0
	dc.b $FF
	dc.b $4B ; K
	dc.b $88 ; �
	dc.b   0
	dc.b $24 ; $
	dc.b $25 ; %
	dc.b $CC ; �
	dc.b   0
	dc.b   9
	dc.b $38 ; 8
	dc.b $E3 ; �
	align	2

unk_9B83C:  binclude	"theme/bg_chunks/sky_00.bin"
	align	2
unk_9B842:  binclude	"theme/bg_chunks/sky_01.bin"
	align	2
unk_9B852:  binclude	"theme/bg_chunks/sky_02.bin"
	align	2
unk_9B868:  binclude	"theme/bg_chunks/sky_03.bin"
	align	2
unk_9B884:  binclude	"theme/bg_chunks/sky_04.bin"
	align	2
unk_9B8AC:  binclude	"theme/bg_chunks/sky_05.bin"
	align	2
unk_9B8BC:  binclude	"theme/bg_chunks/sky_06.bin"
	align	2
unk_9B8D0:  binclude	"theme/bg_chunks/sky_07.bin"
	align	2
unk_9B8EA:  binclude	"theme/bg_chunks/sky_08.bin"
	align	2
unk_9B910:  binclude	"theme/bg_chunks/sky_09.bin"
	align	2
unk_9B93C:  binclude	"theme/bg_chunks/sky_0A.bin"
	align	2
unk_9B974:  binclude	"theme/bg_chunks/sky_0B.bin"
	align	2
unk_9B9C4:  binclude	"theme/bg_chunks/sky_0C.bin"
	align	2
unk_9B9DE:  binclude	"theme/bg_chunks/sky_0D.bin"
	align	2
unk_9BA1A:  binclude	"theme/bg_chunks/sky_0E.bin"
	align	2
unk_9BA2A:  binclude	"theme/bg_chunks/sky_0F.bin"
	align	2
unk_9BA32:  binclude	"theme/bg_chunks/sky_10.bin"
	align	2
unk_9BA66:  binclude	"theme/bg_chunks/sky_11.bin"
	align	2
unk_9BA8C:  binclude	"theme/bg_chunks/sky_12.bin"
	align	2
unk_9BA9C:  binclude	"theme/bg_chunks/sky_13.bin"
	align	2
unk_9BC08:  binclude	"theme/bg_chunks/sky_14.bin"
	align	2
unk_9BC34:  binclude	"theme/bg_chunks/sky_15.bin"
	align	2
unk_9BC60:  binclude	"theme/bg_chunks/sky_16.bin"
	align	2
unk_9BCB4:  binclude	"theme/bg_chunks/sky_17.bin"
	align	2
unk_9BDF8:  binclude	"theme/bg_chunks/sky_18.bin"
	align	2
unk_9BDFE:  binclude	"theme/bg_chunks/sky_19.bin"
	align	2
unk_9BE08:  binclude	"theme/bg_chunks/sky_1A.bin"
	align	2
unk_9BE10:  binclude	"theme/bg_chunks/sky_1B.bin"
	align	2
unk_9BE1E:  binclude	"theme/bg_chunks/sky_1C.bin"
	align	2
unk_9BE2E:  binclude	"theme/bg_chunks/sky_1D.bin"
	align	2
unk_9BE40:  binclude	"theme/bg_chunks/sky_1E.bin"
	align	2
unk_9BE58:  binclude	"theme/bg_chunks/sky_1F.bin"
	align	2
unk_9BE76:  binclude	"theme/bg_chunks/ice_00.bin"
	align	2
unk_9BEF2:  binclude	"theme/bg_chunks/ice_01.bin"
	align	2
unk_9BF1E:  binclude	"theme/bg_chunks/ice_02.bin"
	align	2
unk_9BF4A:  binclude	"theme/bg_chunks/ice_03.bin"
	align	2
unk_9BF9E:  binclude	"theme/bg_chunks/ice_04.bin"
	align	2
unk_9C01A:  binclude	"theme/bg_chunks/ice_05.bin"
	align	2
unk_9C022:  binclude	"theme/bg_chunks/ice_06.bin"
	align	2
unk_9C02C:  binclude	"theme/bg_chunks/ice_07.bin"
	align	2
unk_9C03E:  binclude	"theme/bg_chunks/ice_08.bin"
	align	2
unk_9C058:  binclude	"theme/bg_chunks/ice_09.bin"
	align	2
unk_9C07C:  binclude	"theme/bg_chunks/ice_0A.bin"
	align	2
unk_9C08A:  binclude	"theme/bg_chunks/ice_0B.bin"
	align	2
unk_9C156:  binclude	"theme/bg_chunks/ice_0C.bin"
	align	2
unk_9C1C6:  binclude	"theme/bg_chunks/ice_0D.bin"
	align	2
unk_9C1FA:  binclude	"theme/bg_chunks/ice_0E.bin"
	align	2
; the next 7 chunks seem to be in the wrong format:
; each tileID is a word instead of a byte,
; but the game has no code specific for this.
; So these tiles are broken, and they are unused anyway
; except for number $14 which is used at the edges of
; Diamond Edge and Ice God's Vengeance.
unk_9C20E:  binclude	"theme/bg_chunks/ice_0F.bin"
	dc.b $2C
	dc.b   8
	dc.b $48
	dc.b   0
	dc.b $4A
	align	2
unk_9C21C:  binclude	"theme/bg_chunks/ice_10.bin"
	dc.b   0
	dc.b $2C
	dc.b   8
	dc.b $48
	dc.b   0
	dc.b $47
	dc.b   0
	dc.b $4A
	dc.b   0
	dc.b $4A
	align	2
unk_9C234:  binclude	"theme/bg_chunks/ice_11.bin"
	dc.b   0
	dc.b $5F
	dc.b   0
	dc.b $70
	align	2
unk_9C240:  binclude	"theme/bg_chunks/ice_12.bin"
	dc.b   0
	dc.b $5F
	dc.b   0
	dc.b $63
	dc.b   0
	dc.b $70
	dc.b   0
	dc.b $72
	align	2
unk_9C254:  binclude	"theme/bg_chunks/ice_13.bin"
	dc.b   8
	dc.b $74
	align	2
unk_9C25C:  binclude	"theme/bg_chunks/ice_14.bin"
	dc.b   0
	dc.b $70
	align	2
unk_9C264:  binclude	"theme/bg_chunks/ice_15.bin"
	dc.b   0
	dc.b $70
	dc.b   0
	dc.b $70
	align	2
unk_9C270:  binclude	"theme/bg_chunks/ice_16.bin"
	align	2
unk_9C286:  binclude	"theme/bg_chunks/ice_17.bin"
	align	2
unk_9C2AE:  binclude	"theme/bg_chunks/ice_18.bin"
	align	2
unk_9C30C:  binclude	"theme/bg_chunks/ice_19.bin"
	align	2
unk_9C3A6:  binclude	"theme/bg_chunks/ice_1A.bin"
	align	2
unk_9C440:  binclude	"theme/bg_chunks/ice_1B.bin"
	align	2
unk_9C476:  binclude	"theme/bg_chunks/ice_1C.bin"
	align	2
unk_9C4AC:  binclude	"theme/bg_chunks/ice_1D.bin"
	align	2
unk_9C4E2:  binclude	"theme/bg_chunks/ice_1E.bin"
	align	2
unk_9C518:  binclude	"theme/bg_chunks/ice_1F.bin"
	align	2
unk_9C594:  binclude	"theme/bg_chunks/ice_20.bin"
	align	2
unk_9C5C0:  binclude	"theme/bg_chunks/ice_21.bin"
	align	2
unk_9C5EC:  binclude	"theme/bg_chunks/ice_22.bin"
	align	2
unk_9C618:  binclude	"theme/bg_chunks/ice_23.bin"
	align	2
unk_9C644:  binclude	"theme/bg_chunks/hill_eni_00.bin"
	align	2
unk_9C7B6:  binclude	"theme/bg_chunks/hill_eni_01.bin"
	align	2
unk_9C934:  binclude	"theme/bg_chunks/hill_eni_02.bin"
	align	2
unk_9CBAE:  binclude	"theme/bg_chunks/island_00.bin"
	align	2
unk_9CBC6:  binclude	"theme/bg_chunks/island_01.bin"
	align	2
unk_9CBDC:  binclude	"theme/bg_chunks/island_02.bin"
	align	2
unk_9CC0A:  binclude	"theme/bg_chunks/island_03.bin"
	align	2
unk_9CC5C:  binclude	"theme/bg_chunks/island_04.bin"
	align	2
unk_9CC9C:  binclude	"theme/bg_chunks/island_05.bin"
	align	2
unk_9CCB2:  binclude	"theme/bg_chunks/island_06.bin"
	align	2
unk_9CCC6:  binclude	"theme/bg_chunks/island_07.bin"
	align	2
unk_9CCE0:  binclude	"theme/bg_chunks/island_08.bin"
	align	2
unk_9CCEE:  binclude	"theme/bg_chunks/island_09.bin"
	align	2
unk_9CD14:  binclude	"theme/bg_chunks/island_0A.bin"
	align	2
unk_9CD24:  binclude	"theme/bg_chunks/island_0B.bin"
	align	2
unk_9CD3E:  binclude	"theme/bg_chunks/island_0C.bin"
	align	2
unk_9CD68:  binclude	"theme/bg_chunks/desert_eni_00.bin"
	align	2
unk_9CE0C:  binclude	"theme/bg_chunks/desert_eni_01.bin"
	align	2
unk_9CEC6:  binclude	"theme/bg_chunks/desert_eni_02.bin"
	align	2
unk_9D044:  binclude	"theme/bg_chunks/swamp_00.bin"
	align	2
unk_9D0FC:  binclude	"theme/bg_chunks/swamp_01.bin"
	align	2
unk_9D114:  binclude	"theme/bg_chunks/swamp_02.bin"
	align	2
unk_9D17C:  binclude	"theme/bg_chunks/swamp_03.bin"
	align	2
unk_9D234:  binclude	"theme/bg_chunks/swamp_04.bin"
	align	2
unk_9D24C:  binclude	"theme/bg_chunks/swamp_05.bin"
	align	2
unk_9D2B4:  binclude	"theme/bg_chunks/swamp_06.bin"
	align	2
unk_9D36C:  binclude	"theme/bg_chunks/swamp_07.bin"
	align	2
unk_9D384:  binclude	"theme/bg_chunks/swamp_08.bin"
	align	2
unk_9D3EC:  binclude	"theme/bg_chunks/swamp_09.bin"
	align	2
unk_9D4A4:  binclude	"theme/bg_chunks/swamp_0A.bin"
	align	2
unk_9D4BC:  binclude	"theme/bg_chunks/swamp_0B.bin"
	align	2
unk_9D524:  binclude	"theme/bg_chunks/swamp_0C.bin"
	align	2
unk_9D5DC:  binclude	"theme/bg_chunks/swamp_0D.bin"
	align	2
unk_9D5F4:  binclude	"theme/bg_chunks/swamp_0E.bin"
	align	2
unk_9D65C:  binclude	"theme/bg_chunks/swamp_0F.bin"
	align	2
unk_9D726:  binclude	"theme/bg_chunks/swamp_10.bin"
	align	2
unk_9D740:  binclude	"theme/bg_chunks/swamp_11.bin"
	align	2
unk_9D7B2:  binclude	"theme/bg_chunks/swamp_12.bin"
	align	2
unk_9D86A:  binclude	"theme/bg_chunks/swamp_13.bin"
	align	2
unk_9D882:  binclude	"theme/bg_chunks/swamp_14.bin"
	align	2
unk_9D8EA:  binclude	"theme/bg_chunks/swamp_15.bin"
	align	2
unk_9D8FE:  binclude	"theme/bg_chunks/swamp_16.bin"
	align	2
unk_9D948:  binclude	"theme/bg_chunks/swamp_17.bin"
	align	2
unk_9D992:  binclude	"theme/bg_chunks/swamp_18.bin"
	align	2
unk_9D9DC:  binclude	"theme/bg_chunks/swamp_19.bin"
	align	2
unk_9DA26:  binclude	"theme/bg_chunks/swamp_1A.bin"
	align	2
unk_9DA3A:  binclude	"theme/bg_chunks/mountain_eni_00.bin"
	align	2
unk_9DBF2:  binclude	"theme/bg_chunks/mountain_eni_01.bin"
	align	2
unk_9DDC0:  binclude	"theme/bg_chunks/mountain_eni_02.bin"
	align	2
unk_9DEAC:  binclude	"theme/bg_chunks/mountain_eni_03.bin"
	align	2
unk_9DFAC:  binclude	"theme/bg_chunks/mountain_eni_04.bin"
	align	2
unk_9E004:  binclude	"theme/bg_chunks/cave_00.bin"
	align	2
unk_9E228:  binclude	"theme/bg_chunks/cave_01.bin"
	align	2
unk_9E3CC:  binclude	"theme/bg_chunks/cave_02.bin"
	align	2
unk_9E4BA:  binclude	"theme/bg_chunks/cave_03.bin"
	align	2
unk_9E880:  binclude	"theme/bg_chunks/cave_04.bin"
	align	2
unk_9E8EC:  binclude	"theme/bg_chunks/cave_05.bin"
	align	2
unk_9E958:  binclude	"theme/bg_chunks/cave_06.bin"
	align	2
unk_9E9B6:  binclude	"theme/bg_chunks/cave_07.bin"
	align	2
unk_9E9CE:  binclude	"theme/bg_chunks/cave_08.bin"
	align	2
unk_9E9D8:  binclude	"theme/bg_chunks/cave_09.bin"
	align	2
unk_9E9DE:  binclude	"theme/bg_chunks/cave_0A.bin"
	align	2
unk_9E9E6:  binclude	"theme/bg_chunks/cave_0B.bin"
	align	2
unk_9E9EE:  binclude	"theme/bg_chunks/cave_0C.bin"
	align	2
unk_9E9FA:  binclude	"theme/bg_chunks/cave_0D.bin"
	align	2
unk_9EA76:  binclude	"theme/bg_chunks/cave_0E.bin"
	align	2
unk_9EAA2:  binclude	"theme/bg_chunks/cave_0F.bin"
	align	2
unk_9EB1E:  binclude	"theme/bg_chunks/cave_10.bin"
	align	2
unk_9EB72:  binclude	"theme/bg_chunks/cave_11.bin"
	align	2
unk_9EB9E:  binclude	"theme/bg_chunks/cave_12.bin"
	align	2
unk_9EBCA:  binclude	"theme/bg_chunks/cave_13.bin"
	align	2
unk_9EBF6:  binclude	"theme/bg_chunks/cave_14.bin"
	align	2
unk_9EC22:  binclude	"theme/bg_chunks/forest_eni_00.bin"
	align	2
unk_9EDAA:  binclude	"theme/bg_chunks/forest_eni_01.bin"
	align	2
unk_9EF3E:  binclude	"theme/bg_chunks/forest_eni_02.bin"
	align	2
unk_9F124:  binclude	"theme/bg_chunks/city_00.bin"
	align	2
unk_9F144:  binclude	"theme/bg_chunks/city_01.bin"
	align	2
unk_9F164:  binclude	"theme/bg_chunks/city_02.bin"
	align	2
unk_9F258:  binclude	"theme/bg_chunks/city_03.bin"
	align	2
unk_9F34C:  binclude	"theme/bg_chunks/city_04.bin"
	align	2
unk_9F436:  binclude	"theme/bg_chunks/city_05.bin"
	align	2
unk_9F534:  binclude	"theme/bg_chunks/city_06.bin"
	align	2
unk_9F61E:  binclude	"theme/bg_chunks/city_07.bin"
	align	2
unk_9F6B8:  binclude	"theme/bg_chunks/city_08.bin"
	align	2
unk_9F7C0:  binclude	"theme/bg_chunks/city_09.bin"
	align	2
unk_9F88C:  binclude	"theme/bg_chunks/city_0A.bin"
	align	2
unk_9F912:  binclude	"theme/bg_chunks/city_0B.bin"
	align	2
unk_9F998:  binclude	"theme/bg_chunks/city_0C.bin"
	align	2
unk_9F9EC:  binclude	"theme/bg_chunks/city_0D.bin"
	align	2

	include	"level/bgscroll_includes.asm"

; filler
    rept 133
	dc.b	$FF
    endm
    	align	2

Data_Index:	dc.l 0
LnkTo_Pal_A1C72:	dc.l Pal_A1C72
			dc.l Pal_A1C72
LnkTo_unk_A23CC:	dc.l unk_A23CC
LnkTo_unk_A2552:	dc.l unk_A2552
LnkTo_unk_A26D8:	dc.l unk_A26D8
LnkTo_unk_A285E:	dc.l unk_A285E
LnkTo_unk_A29E4:	dc.l unk_A29E4
LnkTo_unk_A2B6A:	dc.l unk_A2B6A
			dc.l unk_A2CF0
LnkTo_unk_A2E76:	dc.l unk_A2E76
LnkTo_unk_A307C:	dc.l unk_A307C
LnkTo_unk_A3202:	dc.l unk_A3202
LnkTo_unk_A3408:	dc.l unk_A3408
LnkTo_unk_A358E:	dc.l unk_A358E
LnkTo_unk_A3794:	dc.l unk_A3794
LnkTo_unk_A391A:	dc.l unk_A391A
			dc.l unk_A3AA0
LnkTo_unk_A3B66:	dc.l unk_A3B66
LnkTo_unk_A3CEC:	dc.l unk_A3CEC
LnkTo_unk_A3E72:	dc.l unk_A3E72
LnkTo_unk_A3FF8:	dc.l unk_A3FF8
LnkTo_unk_A41FE:	dc.l unk_A41FE
LnkTo_unk_A43E4:	dc.l unk_A43E4
LnkTo_unk_A44EA:	dc.l unk_A44EA
LnkTo_unk_A4630:	dc.l unk_A4630
LnkTo_unk_A4816:	dc.l unk_A4816
LnkTo_unk_A491C:	dc.l unk_A491C
LnkTo_unk_A4A22:	dc.l unk_A4A22
LnkTo_unk_A4BA8:	dc.l unk_A4BA8
LnkTo_unk_A4D2E:	dc.l unk_A4D2E
LnkTo_unk_A4EB4:	dc.l unk_A4EB4
LnkTo_unk_A503A:	dc.l unk_A503A
LnkTo_unk_A51C0:	dc.l unk_A51C0
LnkTo_unk_A5346:	dc.l unk_A5346
LnkTo_unk_A54CC:	dc.l unk_A54CC
LnkTo_unk_A5612:	dc.l unk_A5612
LnkTo_unk_A5758:	dc.l unk_A5758
LnkTo_Pal_A1C8A:	dc.l Pal_A1C8A
LnkTo_Pal_A1CA2:	dc.l Pal_A1CA2
LnkTo_Pal_A1CA8:	dc.l Pal_A1CA8
			dc.l Pal_A1CC6
LnkTo_unk_A589E:	dc.l unk_A589E
LnkTo_unk_A5924:	dc.l unk_A5924
LnkTo_unk_A59AA:	dc.l unk_A59AA
LnkTo_unk_A5A30:	dc.l unk_A5A30
LnkTo_unk_A5AB6:	dc.l unk_A5AB6
LnkTo_unk_A5B7C:	dc.l unk_A5B7C
LnkTo_unk_A5E02:	dc.l unk_A5E02
LnkTo_unk_A6128:	dc.l unk_A6128
LnkTo_unk_A63AE:	dc.l unk_A63AE
LnkTo_unk_A65B4:	dc.l unk_A65B4
LnkTo_unk_A67BA:	dc.l unk_A67BA
LnkTo_unk_A6A40:	dc.l unk_A6A40
LnkTo_unk_A6CC6:	dc.l unk_A6CC6
LnkTo_unk_A6FEC:	dc.l unk_A6FEC
LnkTo_unk_A73B2:	dc.l unk_A73B2
LnkTo_unk_A7778:	dc.l unk_A7778
LnkTo_unk_A79FE:	dc.l unk_A79FE
LnkTo_unk_A7C04:	dc.l unk_A7C04
LnkTo_unk_A7E0A:	dc.l unk_A7E0A
LnkTo_unk_A8090:	dc.l unk_A8090
LnkTo_unk_A8276:	dc.l unk_A8276
LnkTo_unk_A83FC:	dc.l unk_A83FC
LnkTo_unk_A85E2:	dc.l unk_A85E2
LnkTo_unk_A8768:	dc.l unk_A8768
LnkTo_unk_A88AE:	dc.l unk_A88AE
LnkTo_unk_A89B4:	dc.l unk_A89B4
LnkTo_unk_A8AFA:	dc.l unk_A8AFA
LnkTo_unk_A8F80:	dc.l unk_A8F80
LnkTo_Pal_A1CE4:	dc.l Pal_A1CE4
LnkTo_Pal_A1D02:	dc.l Pal_A1D02
LnkTo_Pal_A1D08:	dc.l Pal_A1D08
			dc.l unk_A92A6
LnkTo_unk_A94AC:	dc.l unk_A94AC
			dc.l unk_A95F2
LnkTo_unk_A9638:	dc.l unk_A9638
			dc.l unk_A967E
LnkTo_unk_A96C4:	dc.l unk_A96C4
LnkTo_unk_A978A:	dc.l unk_A978A
LnkTo_unk_A9990:	dc.l unk_A9990
LnkTo_unk_A9B96:	dc.l unk_A9B96
LnkTo_unk_A9D9C:	dc.l unk_A9D9C
LnkTo_unk_A9FA2:	dc.l unk_A9FA2
LnkTo_unk_AA1A8:	dc.l unk_AA1A8
LnkTo_unk_AA3AE:	dc.l unk_AA3AE
LnkTo_unk_AA5B4:	dc.l unk_AA5B4
			dc.l unk_AA73A
			dc.l unk_AA780
			dc.l unk_AA846
LnkTo_unk_AA88C:	dc.l unk_AA88C
LnkTo_unk_AAA92:	dc.l unk_AAA92
LnkTo_unk_AADB8:	dc.l unk_AADB8
LnkTo_unk_AB3BE:	dc.l unk_AB3BE
LnkTo_Pal_A1D26:	dc.l Pal_A1D26
LnkTo_Pal_A1D44:	dc.l Pal_A1D44
LnkTo_Pal_A1D4A:	dc.l Pal_A1D4A
LnkTo_unk_AB5C4:	dc.l unk_AB5C4
LnkTo_unk_AB68A:	dc.l unk_AB68A
LnkTo_unk_AB750:	dc.l unk_AB750
LnkTo_unk_AB816:	dc.l unk_AB816
LnkTo_unk_AB8DC:	dc.l unk_AB8DC
LnkTo_unk_AB9A2:	dc.l unk_AB9A2
LnkTo_unk_ABA68:	dc.l unk_ABA68
LnkTo_unk_ABB8E:	dc.l unk_ABB8E
LnkTo_unk_ABC54:	dc.l unk_ABC54
LnkTo_unk_ABD1A:	dc.l unk_ABD1A
LnkTo_unk_ABDE0:	dc.l unk_ABDE0
LnkTo_unk_ABEA6:	dc.l unk_ABEA6
LnkTo_unk_ABF6C:	dc.l unk_ABF6C
LnkTo_unk_AC032:	dc.l unk_AC032
LnkTo_unk_AC0F8:	dc.l unk_AC0F8
LnkTo_unk_AC17E:	dc.l unk_AC17E
LnkTo_unk_AC244:	dc.l unk_AC244
LnkTo_unk_AC30A:	dc.l unk_AC30A
LnkTo_unk_AC3D0:	dc.l unk_AC3D0
LnkTo_unk_AC656:	dc.l unk_AC656
LnkTo_unk_AC85C:	dc.l unk_AC85C
LnkTo_unk_AC9E2:	dc.l unk_AC9E2
LnkTo_unk_ACAA8:	dc.l unk_ACAA8
LnkTo_unk_ACB6E:	dc.l unk_ACB6E
LnkTo_unk_ACC34:	dc.l unk_ACC34
LnkTo_unk_ACCFA:	dc.l unk_ACCFA
LnkTo_unk_ACDC0:	dc.l unk_ACDC0
LnkTo_unk_ACE86:	dc.l unk_ACE86
LnkTo_unk_ACF4C:	dc.l unk_ACF4C
LnkTo_unk_AD012:	dc.l unk_AD012
LnkTo_unk_AD0D8:	dc.l unk_AD0D8
LnkTo_unk_AD19E:	dc.l unk_AD19E
LnkTo_unk_AD264:	dc.l unk_AD264
LnkTo_Pal_A1D68:	dc.l Pal_A1D68
LnkTo_Pal_A1D80:	dc.l Pal_A1D80
LnkTo_Pal_A1D86:	dc.l Pal_A1D86
LnkTo_unk_AD32A:	dc.l unk_AD32A
LnkTo_unk_AD5B0:	dc.l unk_AD5B0
LnkTo_unk_AD836:	dc.l unk_AD836
LnkTo_unk_ADABC:	dc.l unk_ADABC
LnkTo_unk_ADD42:	dc.l unk_ADD42
LnkTo_unk_ADFC8:	dc.l unk_ADFC8
LnkTo_unk_AE24E:	dc.l unk_AE24E
LnkTo_unk_AE4D4:	dc.l unk_AE4D4
LnkTo_unk_AE75A:	dc.l unk_AE75A
LnkTo_unk_AE9E0:	dc.l unk_AE9E0
LnkTo_unk_AEC66:	dc.l unk_AEC66
LnkTo_unk_AEEEC:	dc.l unk_AEEEC
LnkTo_unk_AF172:	dc.l unk_AF172
LnkTo_unk_AF3F8:	dc.l unk_AF3F8
LnkTo_unk_AF67E:	dc.l unk_AF67E
LnkTo_unk_AF904:	dc.l unk_AF904
LnkTo_unk_AFAEA:	dc.l unk_AFAEA
LnkTo_unk_AFCD0:	dc.l unk_AFCD0
LnkTo_unk_AFF56:	dc.l unk_AFF56
LnkTo_unk_B007C:	dc.l unk_B007C
LnkTo_unk_B0282:	dc.l unk_B0282
LnkTo_unk_B0508:	dc.l unk_B0508
			dc.l unk_B078E
LnkTo_unk_B0994:	dc.l unk_B0994
LnkTo_unk_B0C1A:	dc.l unk_B0C1A
LnkTo_unk_B0EA0:	dc.l unk_B0EA0
LnkTo_unk_B1126:	dc.l unk_B1126
LnkTo_unk_B130C:	dc.l unk_B130C
LnkTo_unk_B14F2:	dc.l unk_B14F2
LnkTo_unk_B1778:	dc.l unk_B1778
LnkTo_unk_B19FE:	dc.l unk_B19FE
LnkTo_unk_B1C84:	dc.l unk_B1C84
LnkTo_unk_B1E6A:	dc.l unk_B1E6A
LnkTo_unk_B1FB0:	dc.l unk_B1FB0
LnkTo_unk_B20F6:	dc.l unk_B20F6
			dc.l unk_B223C
			dc.l unk_B2562
			dc.l unk_B2888
			dc.l unk_B2BAE
			dc.l unk_B2ED4
			dc.l unk_B31FA
LnkTo_Pal_A1DA4:	dc.l Pal_A1DA4
LnkTo_Pal_A1DBC:	dc.l Pal_A1DBC
LnkTo_Pal_A1DC2:	dc.l Pal_A1DC2
LnkTo_unk_B3520:	dc.l unk_B3520
LnkTo_unk_B3706:	dc.l unk_B3706
LnkTo_unk_B3A2C:	dc.l unk_B3A2C
LnkTo_unk_B3CB2:	dc.l unk_B3CB2
LnkTo_unk_B3FB8:	dc.l unk_B3FB8
LnkTo_unk_B40DE:	dc.l unk_B40DE
			dc.l unk_B42C4
			dc.l unk_B45EA
			dc.l unk_B4870
LnkTo_unk_B4AB6:	dc.l unk_B4AB6
LnkTo_unk_B4C9C:	dc.l unk_B4C9C
LnkTo_unk_B4E82:	dc.l unk_B4E82
LnkTo_unk_B5088:	dc.l unk_B5088
LnkTo_unk_B580E:	dc.l unk_B580E
LnkTo_unk_B5F94:	dc.l unk_B5F94
LnkTo_unk_B617A:	dc.l unk_B617A
LnkTo_unk_B6360:	dc.l unk_B6360
LnkTo_unk_B6546:	dc.l unk_B6546
LnkTo_unk_B672C:	dc.l unk_B672C
LnkTo_unk_B6912:	dc.l unk_B6912
LnkTo_unk_B6AF8:	dc.l unk_B6AF8
LnkTo_unk_B6C3E:	dc.l unk_B6C3E
LnkTo_unk_B6D84:	dc.l unk_B6D84
LnkTo_unk_B6ECA:	dc.l unk_B6ECA
LnkTo_unk_B7150:	dc.l unk_B7150
LnkTo_Pal_A1DE0:	dc.l Pal_A1DE0
LnkTo_Pal_A1DF8:	dc.l Pal_A1DF8
LnkTo_Pal_A1DFE:	dc.l Pal_A1DFE
			dc.l unk_B73D6
			dc.l unk_B74DC
			dc.l unk_B7562
LnkTo_unk_B7668:	dc.l unk_B7668
LnkTo_unk_B772E:	dc.l unk_B772E
LnkTo_unk_B79B4:	dc.l unk_B79B4
			dc.l unk_B7C3A
LnkTo_unk_B7EC0:	dc.l unk_B7EC0
LnkTo_unk_B8146:	dc.l unk_B8146
LnkTo_unk_B85CC:	dc.l unk_B85CC
LnkTo_unk_B8A52:	dc.l unk_B8A52
LnkTo_unk_B8ED8:	dc.l unk_B8ED8
LnkTo_unk_B915E:	dc.l unk_B915E
LnkTo_unk_B9364:	dc.l unk_B9364
LnkTo_unk_B95EA:	dc.l unk_B95EA
LnkTo_unk_B9870:	dc.l unk_B9870
LnkTo_unk_B9A76:	dc.l unk_B9A76
LnkTo_unk_B9CFC:	dc.l unk_B9CFC
LnkTo_unk_B9E42:	dc.l unk_B9E42
LnkTo_unk_B9F88:	dc.l unk_B9F88
LnkTo_unk_BA0CE:	dc.l unk_BA0CE
LnkTo_unk_BA354:	dc.l unk_BA354
LnkTo_Pal_A1E1C:	dc.l Pal_A1E1C
LnkTo_Pal_A1E34:	dc.l Pal_A1E34
LnkTo_Pal_A1E3A:	dc.l Pal_A1E3A
LnkTo_unk_BA55A:	dc.l unk_BA55A
			dc.l unk_BA7E0
			dc.l unk_BAA66
LnkTo_unk_BACEC:	dc.l unk_BACEC
LnkTo_unk_BADB2:	dc.l unk_BADB2
LnkTo_unk_BAF98:	dc.l unk_BAF98
LnkTo_unk_BB11E:	dc.l unk_BB11E
LnkTo_unk_BB304:	dc.l unk_BB304
LnkTo_unk_BB48A:	dc.l unk_BB48A
LnkTo_unk_BB710:	dc.l unk_BB710
LnkTo_unk_BB996:	dc.l unk_BB996
LnkTo_unk_BBB1C:	dc.l unk_BBB1C
LnkTo_unk_BBCA2:	dc.l unk_BBCA2
LnkTo_unk_BBE28:	dc.l unk_BBE28
LnkTo_unk_BBFAE:	dc.l unk_BBFAE
LnkTo_unk_BC134:	dc.l unk_BC134
LnkTo_unk_BC2BA:	dc.l unk_BC2BA
LnkTo_unk_BC400:	dc.l unk_BC400
LnkTo_unk_BC546:	dc.l unk_BC546
LnkTo_unk_BC68C:	dc.l unk_BC68C
LnkTo_unk_BC872:	dc.l unk_BC872
LnkTo_unk_BCA58:	dc.l unk_BCA58
LnkTo_unk_BCC3E:	dc.l unk_BCC3E
LnkTo_unk_BCE24:	dc.l unk_BCE24
LnkTo_unk_BD00A:	dc.l unk_BD00A
LnkTo_unk_BD1F0:	dc.l unk_BD1F0
LnkTo_unk_BD3F6:	dc.l unk_BD3F6
LnkTo_unk_BD5FC:	dc.l unk_BD5FC
LnkTo_unk_BD882:	dc.l unk_BD882
LnkTo_unk_BDA88:	dc.l unk_BDA88
LnkTo_unk_BDC8E:	dc.l unk_BDC8E
LnkTo_Pal_A1E58:	dc.l Pal_A1E58
LnkTo_Pal_A1E70:	dc.l Pal_A1E70
LnkTo_Pal_A1E76:	dc.l Pal_A1E76
LnkTo_unk_BDF14:	dc.l unk_BDF14
LnkTo_unk_BE09A:	dc.l unk_BE09A
LnkTo_unk_BE320:	dc.l unk_BE320
LnkTo_unk_BE6A6:	dc.l unk_BE6A6
			dc.l unk_BE70C
LnkTo_unk_BE772:	dc.l unk_BE772
LnkTo_unk_BE838:	dc.l unk_BE838
			dc.l unk_BE95E
			dc.l unk_BEAE4
			dc.l unk_BEC6A
LnkTo_unk_BEDF0:	dc.l unk_BEDF0
LnkTo_unk_BEF76:	dc.l unk_BEF76
LnkTo_unk_BF0FC:	dc.l unk_BF0FC
LnkTo_unk_BF282:	dc.l unk_BF282
LnkTo_unk_BF408:	dc.l unk_BF408
LnkTo_unk_BF58E:	dc.l unk_BF58E
LnkTo_unk_BF714:	dc.l unk_BF714
			dc.l unk_BF89A
LnkTo_unk_BFAE0:	dc.l unk_BFAE0
LnkTo_unk_BFD26:	dc.l unk_BFD26
LnkTo_unk_C0000:	dc.l unk_C0000
LnkTo_unk_C0246:	dc.l unk_C0246
LnkTo_unk_C03CC:	dc.l unk_C03CC
LnkTo_unk_C0552:	dc.l unk_C0552
LnkTo_unk_C06D8:	dc.l unk_C06D8
LnkTo_unk_C085E:	dc.l unk_C085E
LnkTo_unk_C0B84:	dc.l unk_C0B84
LnkTo_unk_C0EAA:	dc.l unk_C0EAA
LnkTo_unk_C1270:	dc.l unk_C1270
			dc.l unk_C1876
LnkTo_unk_C1A5C:	dc.l unk_C1A5C
LnkTo_unk_C1B82:	dc.l unk_C1B82
LnkTo_unk_C1B8A:	dc.l unk_C1B8A
LnkTo_Pal_A1E94:	dc.l Pal_A1E94
LnkTo_Pal_A1EAC:	dc.l Pal_A1EAC
LnkTo_Pal_A1EB2:	dc.l Pal_A1EB2
LnkTo_unk_C1B92:	dc.l unk_C1B92
LnkTo_unk_C1E18:	dc.l unk_C1E18
LnkTo_unk_C209E:	dc.l unk_C209E
LnkTo_unk_C2324:	dc.l unk_C2324
LnkTo_unk_C244A:	dc.l unk_C244A
LnkTo_unk_C26D0:	dc.l unk_C26D0
LnkTo_unk_C2956:	dc.l unk_C2956
			dc.l unk_C2BDC
LnkTo_unk_C2E62:	dc.l unk_C2E62
LnkTo_unk_C30E8:	dc.l unk_C30E8
LnkTo_unk_C354E:	dc.l unk_C354E
LnkTo_unk_C39B4:	dc.l unk_C39B4
LnkTo_unk_C3FBA:	dc.l unk_C3FBA
LnkTo_unk_C4420:	dc.l unk_C4420
LnkTo_unk_C46A6:	dc.l unk_C46A6
LnkTo_unk_C492C:	dc.l unk_C492C
LnkTo_unk_C4BB2:	dc.l unk_C4BB2
LnkTo_unk_C4E38:	dc.l unk_C4E38
LnkTo_unk_C50BE:	dc.l unk_C50BE
LnkTo_unk_C5344:	dc.l unk_C5344
LnkTo_unk_C548A:	dc.l unk_C548A
LnkTo_unk_C55D0:	dc.l unk_C55D0
LnkTo_unk_C5716:	dc.l unk_C5716
LnkTo_unk_C599C:	dc.l unk_C599C
LnkTo_unk_C5C22:	dc.l unk_C5C22
LnkTo_unk_C5EA8:	dc.l unk_C5EA8
LnkTo_unk_C612E:	dc.l unk_C612E
LnkTo_unk_C63B4:	dc.l unk_C63B4
LnkTo_unk_C663A:	dc.l unk_C663A
LnkTo_unk_C68C0:	dc.l unk_C68C0
LnkTo_unk_C6B46:	dc.l unk_C6B46
LnkTo_unk_C6DCC:	dc.l unk_C6DCC
LnkTo_unk_C7052:	dc.l unk_C7052
LnkTo_unk_C72D8:	dc.l unk_C72D8
LnkTo_Pal_A1ED0:	dc.l Pal_A1ED0
			dc.l Pal_A1EDE
			dc.l Pal_A1EEC
LnkTo_unk_C755E:	dc.l unk_C755E
LnkTo_unk_C7566:	dc.l unk_C7566
LnkTo_unk_C756E:	dc.l unk_C756E
LnkTo_unk_C7576:	dc.l unk_C7576
LnkTo_unk_C757E:	dc.l unk_C757E
LnkTo_unk_C7586:	dc.l unk_C7586
LnkTo_unk_C758E:	dc.l unk_C758E
LnkTo_unk_C7596:	dc.l unk_C7596
LnkTo_unk_C759E:	dc.l unk_C759E
LnkTo_unk_C75A6:	dc.l unk_C75A6
LnkTo_unk_C75AE:	dc.l unk_C75AE
LnkTo_unk_C75B6:	dc.l unk_C75B6
LnkTo_unk_C75BE:	dc.l unk_C75BE
LnkTo_unk_C75C6:	dc.l unk_C75C6
LnkTo_unk_C75CE:	dc.l unk_C75CE
LnkTo_unk_C75D6:	dc.l unk_C75D6
LnkTo_unk_C75DE:	dc.l unk_C75DE
LnkTo_unk_C75E6:	dc.l unk_C75E6
LnkTo_unk_C75EE:	dc.l unk_C75EE
LnkTo_unk_C75F6:	dc.l unk_C75F6
LnkTo_unk_C75FE:	dc.l unk_C75FE
LnkTo_unk_C7606:	dc.l unk_C7606
LnkTo_unk_C760E:	dc.l unk_C760E
LnkTo_unk_C7616:	dc.l unk_C7616
LnkTo_unk_C761E:	dc.l unk_C761E
			dc.l unk_C7626
LnkTo_unk_C762E:	dc.l unk_C762E
LnkTo_unk_C7636:	dc.l unk_C7636
LnkTo_Pal_A1EFA:	dc.l Pal_A1EFA
LnkTo_unk_C763E:	dc.l unk_C763E
LnkTo_unk_C7646:	dc.l unk_C7646
LnkTo_unk_C764E:	dc.l unk_C764E
LnkTo_unk_C7656:	dc.l unk_C7656
LnkTo_unk_C765E:	dc.l unk_C765E
LnkTo_unk_C7666:	dc.l unk_C7666
LnkTo_unk_C766E:	dc.l unk_C766E
LnkTo_unk_C7676:	dc.l unk_C7676
LnkTo_unk_C767E:	dc.l unk_C767E
LnkTo_unk_C7686:	dc.l unk_C7686
LnkTo_unk_C768E:	dc.l unk_C768E
LnkTo_unk_C7696:	dc.l unk_C7696
LnkTo_unk_C769E:	dc.l unk_C769E
LnkTo_Pal_A1F08:	dc.l Pal_A1F08
			dc.l Pal_A1F16
			dc.l Pal_A1F24
LnkTo_unk_C76A6:	dc.l unk_C76A6
LnkTo_unk_C76AE:	dc.l unk_C76AE
LnkTo_unk_C76B6:	dc.l unk_C76B6
LnkTo_unk_C76BE:	dc.l unk_C76BE
LnkTo_unk_C76C6:	dc.l unk_C76C6
LnkTo_unk_C76CE:	dc.l unk_C76CE
LnkTo_unk_C76D6:	dc.l unk_C76D6
LnkTo_unk_C76DE:	dc.l unk_C76DE
LnkTo_unk_C76E6:	dc.l unk_C76E6
LnkTo_unk_C76EE:	dc.l unk_C76EE
LnkTo_unk_C76F6:	dc.l unk_C76F6
LnkTo_unk_C76FE:	dc.l unk_C76FE
LnkTo_unk_C7706:	dc.l unk_C7706
LnkTo_unk_C770E:	dc.l unk_C770E
LnkTo_unk_C7716:	dc.l unk_C7716
			dc.l Pal_A1F32
			dc.l Pal_A1F40
LnkTo_Pal_A1F4E:	dc.l Pal_A1F4E
			dc.l Pal_A1F5C
			dc.l Pal_A1F6A
			dc.l Pal_A1F78
			dc.l Pal_A1F86
			dc.l Pal_A1F94
			dc.l Pal_A1FA2
LnkTo_unk_C771E:	dc.l unk_C771E
LnkTo_unk_C7726:	dc.l unk_C7726
LnkTo_unk_C772E:	dc.l unk_C772E
LnkTo_unk_C7736:	dc.l unk_C7736
LnkTo_unk_C773E:	dc.l unk_C773E
LnkTo_unk_C7746:	dc.l unk_C7746
LnkTo_unk_C774E:	dc.l unk_C774E
LnkTo_unk_C7756:	dc.l unk_C7756
LnkTo_unk_C775E:	dc.l unk_C775E
LnkTo_unk_C7766:	dc.l unk_C7766
LnkTo_unk_C776E:	dc.l unk_C776E
LnkTo_unk_C7776:	dc.l unk_C7776
LnkTo_unk_C777E:	dc.l unk_C777E
LnkTo_unk_C7786:	dc.l unk_C7786
LnkTo_unk_C778E:	dc.l unk_C778E
LnkTo_unk_C7796:	dc.l unk_C7796
LnkTo_unk_C779E:	dc.l unk_C779E
LnkTo_Pal_A1FB0:	dc.l Pal_A1FB0
			dc.l Pal_A1FBE
			dc.l Pal_A1FCC
LnkTo_unk_C77A6:	dc.l unk_C77A6
LnkTo_unk_C77AE:	dc.l unk_C77AE
LnkTo_unk_C77B6:	dc.l unk_C77B6
LnkTo_unk_C77BE:	dc.l unk_C77BE
LnkTo_unk_C77C6:	dc.l unk_C77C6
LnkTo_unk_C77CE:	dc.l unk_C77CE
LnkTo_unk_C77D6:	dc.l unk_C77D6
LnkTo_unk_C77DE:	dc.l unk_C77DE
LnkTo_unk_C77E6:	dc.l unk_C77E6
LnkTo_unk_C77EE:	dc.l unk_C77EE
LnkTo_unk_C77F6:	dc.l unk_C77F6
LnkTo_unk_C77FE:	dc.l unk_C77FE
LnkTo_unk_C7806:	dc.l unk_C7806
LnkTo_unk_C780E:	dc.l unk_C780E
LnkTo_unk_C7816:	dc.l unk_C7816
LnkTo_unk_C781E:	dc.l unk_C781E
LnkTo_unk_C7826:	dc.l unk_C7826
LnkTo_unk_C782E:	dc.l unk_C782E
LnkTo_unk_C7836:	dc.l unk_C7836
LnkTo_Pal_A1FDA:	dc.l Pal_A1FDA
			dc.l Pal_A1FE8
			dc.l Pal_A1FF6
LnkTo_unk_C783E:	dc.l unk_C783E
LnkTo_unk_C7846:	dc.l unk_C7846
LnkTo_unk_C784E:	dc.l unk_C784E
LnkTo_unk_C7856:	dc.l unk_C7856
LnkTo_unk_C785E:	dc.l unk_C785E
LnkTo_Pal_A2004:	dc.l Pal_A2004
			dc.l Pal_A2012
			dc.l Pal_A2020
LnkTo_unk_C7866:	dc.l unk_C7866
LnkTo_unk_C786E:	dc.l unk_C786E
LnkTo_unk_C7876:	dc.l unk_C7876
LnkTo_unk_C787E:	dc.l unk_C787E
LnkTo_unk_C7886:	dc.l unk_C7886
LnkTo_unk_C788E:	dc.l unk_C788E
LnkTo_unk_C7896:	dc.l unk_C7896
LnkTo_unk_C789E:	dc.l unk_C789E
LnkTo_unk_C78A6:	dc.l unk_C78A6
LnkTo_unk_C78AE:	dc.l unk_C78AE
LnkTo_unk_C78B6:	dc.l unk_C78B6
LnkTo_unk_C78BE:	dc.l unk_C78BE
LnkTo_unk_C78C6:	dc.l unk_C78C6
LnkTo_unk_C78CE:	dc.l unk_C78CE
LnkTo_Pal_A202E:	dc.l Pal_A202E
			dc.l Pal_A203C
			dc.l Pal_A204A
LnkTo_unk_C78D6:	dc.l unk_C78D6
LnkTo_unk_C78DE:	dc.l unk_C78DE
LnkTo_unk_C78E6:	dc.l unk_C78E6
LnkTo_unk_C78EE:	dc.l unk_C78EE
LnkTo_unk_C78F6:	dc.l unk_C78F6
LnkTo_unk_C78FE:	dc.l unk_C78FE
LnkTo_unk_C7906:	dc.l unk_C7906
LnkTo_unk_C790E:	dc.l unk_C790E
LnkTo_unk_C7916:	dc.l unk_C7916
LnkTo_unk_C791E:	dc.l unk_C791E
LnkTo_unk_C7926:	dc.l unk_C7926
LnkTo_unk_C792E:	dc.l unk_C792E
LnkTo_unk_C7936:	dc.l unk_C7936
LnkTo_unk_C793E:	dc.l unk_C793E
LnkTo_unk_C7946:	dc.l unk_C7946
LnkTo_unk_C794E:	dc.l unk_C794E
LnkTo_unk_C7956:	dc.l unk_C7956
LnkTo_unk_C795E:	dc.l unk_C795E
LnkTo_unk_C7966:	dc.l unk_C7966
LnkTo_unk_C796E:	dc.l unk_C796E
LnkTo_unk_C7976:	dc.l unk_C7976
LnkTo_unk_C797E:	dc.l unk_C797E
LnkTo_unk_C7986:	dc.l unk_C7986
LnkTo_unk_C798E:	dc.l unk_C798E
LnkTo_unk_C7996:	dc.l unk_C7996
LnkTo_unk_C799E:	dc.l unk_C799E
LnkTo_unk_C79A6:	dc.l unk_C79A6
LnkTo_Pal_A2058:	dc.l Pal_A2058
			dc.l Pal_A2066
			dc.l Pal_A2074
LnkTo_unk_C79AE:	dc.l unk_C79AE
LnkTo_unk_C79B6:	dc.l unk_C79B6
LnkTo_unk_C79BE:	dc.l unk_C79BE
LnkTo_unk_C79C6:	dc.l unk_C79C6
LnkTo_unk_C79CE:	dc.l unk_C79CE
LnkTo_unk_C79D6:	dc.l unk_C79D6
LnkTo_unk_C79DE:	dc.l unk_C79DE
LnkTo_unk_C79E6:	dc.l unk_C79E6
LnkTo_unk_C79EE:	dc.l unk_C79EE
LnkTo_unk_C79F6:	dc.l unk_C79F6
LnkTo_unk_C79FE:	dc.l unk_C79FE
LnkTo_unk_C7A06:	dc.l unk_C7A06
LnkTo_unk_C7A0E:	dc.l unk_C7A0E
LnkTo_unk_C7A16:	dc.l unk_C7A16
LnkTo_Pal_A2082:	dc.l Pal_A2082
			dc.l Pal_A2090
LnkTo_Pal_A209E:	dc.l Pal_A209E
LnkTo_unk_C7A1E:	dc.l unk_C7A1E
LnkTo_unk_C7A26:	dc.l unk_C7A26
LnkTo_unk_C7A2E:	dc.l unk_C7A2E
LnkTo_unk_C7A36:	dc.l unk_C7A36
LnkTo_unk_C7A3E:	dc.l unk_C7A3E
LnkTo_unk_C7A46:	dc.l unk_C7A46
LnkTo_unk_C7A4E:	dc.l unk_C7A4E
LnkTo_unk_C7A56:	dc.l unk_C7A56
LnkTo_unk_C7A5E:	dc.l unk_C7A5E
LnkTo_unk_C7A66:	dc.l unk_C7A66
LnkTo_unk_C7A6E:	dc.l unk_C7A6E
LnkTo_unk_C7A76:	dc.l unk_C7A76
LnkTo_unk_C7A7E:	dc.l unk_C7A7E
LnkTo_unk_C7A86:	dc.l unk_C7A86
LnkTo_unk_C7A8E:	dc.l unk_C7A8E
LnkTo_unk_C7A96:	dc.l unk_C7A96
LnkTo_unk_C7A9E:	dc.l unk_C7A9E
LnkTo_unk_C7AA6:	dc.l unk_C7AA6
LnkTo_unk_C7AAE:	dc.l unk_C7AAE
LnkTo_unk_C7AB6:	dc.l unk_C7AB6
LnkTo_unk_C7ABE:	dc.l unk_C7ABE
LnkTo_unk_C7AC6:	dc.l unk_C7AC6
LnkTo_unk_C7ACE:	dc.l unk_C7ACE
LnkTo_unk_C7AD6:	dc.l unk_C7AD6
LnkTo_unk_C7ADE:	dc.l unk_C7ADE
LnkTo_unk_C7AE6:	dc.l unk_C7AE6
LnkTo_unk_C7AEE:	dc.l unk_C7AEE
LnkTo_unk_C7AF6:	dc.l unk_C7AF6
LnkTo_unk_C7AFE:	dc.l unk_C7AFE
LnkTo_unk_C7B06:	dc.l unk_C7B06
LnkTo_unk_C7B0E:	dc.l unk_C7B0E
LnkTo_unk_C7B16:	dc.l unk_C7B16
LnkTo_unk_C7B1E:	dc.l unk_C7B1E
LnkTo_unk_C7B26:	dc.l unk_C7B26
LnkTo_unk_C7B2E:	dc.l unk_C7B2E
LnkTo_unk_C7B36:	dc.l unk_C7B36
LnkTo_unk_C7B3E:	dc.l unk_C7B3E
LnkTo_unk_C7B46:	dc.l unk_C7B46
LnkTo_unk_C7B4E:	dc.l unk_C7B4E
LnkTo_unk_C7B56:	dc.l unk_C7B56
LnkTo_unk_C7B5E:	dc.l unk_C7B5E
LnkTo_unk_C7B66:	dc.l unk_C7B66
LnkTo_unk_C7B6E:	dc.l unk_C7B6E
LnkTo_unk_C7B76:	dc.l unk_C7B76
LnkTo_unk_C7B7E:	dc.l unk_C7B7E
LnkTo_unk_C7B86:	dc.l unk_C7B86
LnkTo_unk_C7B8E:	dc.l unk_C7B8E
LnkTo_unk_C7B96:	dc.l unk_C7B96
LnkTo_unk_C7B9E:	dc.l unk_C7B9E
LnkTo_unk_C7BA6:	dc.l unk_C7BA6
LnkTo_unk_C7BAE:	dc.l unk_C7BAE
LnkTo_unk_C7BB6:	dc.l unk_C7BB6
LnkTo_unk_C7BBE:	dc.l unk_C7BBE
LnkTo_unk_C7BC6:	dc.l unk_C7BC6
LnkTo_unk_C7BCE:	dc.l unk_C7BCE
LnkTo_unk_C7BD6:	dc.l unk_C7BD6
LnkTo_unk_C7BDE:	dc.l unk_C7BDE
LnkTo_unk_C7BE6:	dc.l unk_C7BE6
LnkTo_unk_C7BEE:	dc.l unk_C7BEE
LnkTo_unk_C7BF6:	dc.l unk_C7BF6
LnkTo_unk_C7BFE:	dc.l unk_C7BFE
LnkTo_Pal_A20AC:	dc.l Pal_A20AC
			dc.l Pal_A20BA
			dc.l Pal_A20C8
LnkTo_unk_C7C06:	dc.l unk_C7C06
LnkTo_unk_C7C0E:	dc.l unk_C7C0E
LnkTo_unk_C7C16:	dc.l unk_C7C16
LnkTo_unk_C7C1E:	dc.l unk_C7C1E
LnkTo_unk_C7C26:	dc.l unk_C7C26
LnkTo_unk_C7C2E:	dc.l unk_C7C2E
LnkTo_unk_C7C36:	dc.l unk_C7C36
LnkTo_unk_C7C3E:	dc.l unk_C7C3E
LnkTo_unk_C7C46:	dc.l unk_C7C46
LnkTo_unk_C7C4E:	dc.l unk_C7C4E
LnkTo_Pal_A20D6:	dc.l Pal_A20D6
			dc.l Pal_A20E4
			dc.l Pal_A20F2
LnkTo_unk_C7C56:	dc.l unk_C7C56
LnkTo_unk_C7C5E:	dc.l unk_C7C5E
LnkTo_unk_C7C66:	dc.l unk_C7C66
LnkTo_unk_C7C6E:	dc.l unk_C7C6E
LnkTo_unk_C7C76:	dc.l unk_C7C76
LnkTo_unk_C7C7E:	dc.l unk_C7C7E
LnkTo_unk_C7C86:	dc.l unk_C7C86
LnkTo_unk_C7C8E:	dc.l unk_C7C8E
LnkTo_unk_C7C96:	dc.l unk_C7C96
LnkTo_unk_C7C9E:	dc.l unk_C7C9E
LnkTo_unk_C7CA6:	dc.l unk_C7CA6
LnkTo_unk_C7CAE:	dc.l unk_C7CAE
LnkTo_unk_C7CB6:	dc.l unk_C7CB6
LnkTo_unk_C7CBE:	dc.l unk_C7CBE
LnkTo_unk_C7CC6:	dc.l unk_C7CC6
LnkTo_Pal_A2100:	dc.l Pal_A2100
			dc.l Pal_A210E
			dc.l Pal_A211C
LnkTo_unk_C7CCE:	dc.l unk_C7CCE
LnkTo_unk_C7CD6:	dc.l unk_C7CD6
LnkTo_unk_C7CDE:	dc.l unk_C7CDE
LnkTo_unk_C7CE6:	dc.l unk_C7CE6
LnkTo_unk_C7CEE:	dc.l unk_C7CEE
LnkTo_unk_C7CF6:	dc.l unk_C7CF6
LnkTo_unk_C7CFE:	dc.l unk_C7CFE
LnkTo_unk_C7D06:	dc.l unk_C7D06
LnkTo_unk_C7D0E:	dc.l unk_C7D0E
LnkTo_unk_C7D16:	dc.l unk_C7D16
LnkTo_unk_C7D1E:	dc.l unk_C7D1E
LnkTo_unk_C7D26:	dc.l unk_C7D26
LnkTo_unk_C7D2E:	dc.l unk_C7D2E
LnkTo_unk_C7D36:	dc.l unk_C7D36
LnkTo_unk_C7D3E:	dc.l unk_C7D3E
LnkTo_unk_C7D46:	dc.l unk_C7D46
LnkTo_unk_C7D4E:	dc.l unk_C7D4E
LnkTo_Pal_A212A:	dc.l Pal_A212A
			dc.l Pal_A2138
			dc.l Pal_A2146
LnkTo_unk_C7D56:	dc.l unk_C7D56
LnkTo_unk_C7D5E:	dc.l unk_C7D5E
LnkTo_unk_C7D66:	dc.l unk_C7D66
LnkTo_unk_C7D6E:	dc.l unk_C7D6E
LnkTo_unk_C7D76:	dc.l unk_C7D76
LnkTo_unk_C7D7E:	dc.l unk_C7D7E
LnkTo_unk_C7D86:	dc.l unk_C7D86
LnkTo_unk_C7D8E:	dc.l unk_C7D8E
LnkTo_unk_C7D96:	dc.l unk_C7D96
LnkTo_unk_C7D9E:	dc.l unk_C7D9E
LnkTo_unk_C7DA6:	dc.l unk_C7DA6
LnkTo_unk_C7DAE:	dc.l unk_C7DAE
LnkTo_unk_C7DB6:	dc.l unk_C7DB6
LnkTo_unk_C7DBE:	dc.l unk_C7DBE
LnkTo_Pal_A2154:	dc.l Pal_A2154
			dc.l Pal_A2162
			dc.l Pal_A2170
LnkTo_unk_C7DC6:	dc.l unk_C7DC6
LnkTo_unk_C7DCE:	dc.l unk_C7DCE
LnkTo_unk_C7DD6:	dc.l unk_C7DD6
LnkTo_unk_C7DDE:	dc.l unk_C7DDE
LnkTo_unk_C7DE6:	dc.l unk_C7DE6
LnkTo_unk_C7DEE:	dc.l unk_C7DEE
LnkTo_unk_C7DF6:	dc.l unk_C7DF6
LnkTo_unk_C7DFE:	dc.l unk_C7DFE
LnkTo_unk_C7E06:	dc.l unk_C7E06
LnkTo_unk_C7E0E:	dc.l unk_C7E0E
LnkTo_unk_C7E16:	dc.l unk_C7E16
LnkTo_unk_C7E1E:	dc.l unk_C7E1E
LnkTo_Pal_A217E:	dc.l Pal_A217E
LnkTo_Pal_A21BA:	dc.l Pal_A21BA
			dc.l Pal_A219C
LnkTo_unk_C7E20:	dc.l unk_C7E20
LnkTo_unk_C7E28:	dc.l unk_C7E28
LnkTo_unk_C7E30:	dc.l unk_C7E30
LnkTo_unk_C7E38:	dc.l unk_C7E38
LnkTo_unk_C7E40:	dc.l unk_C7E40
LnkTo_unk_C7E48:	dc.l unk_C7E48
			dc.l unk_C7E50
LnkTo_unk_C7E58:	dc.l unk_C7E58
LnkTo_unk_C7E60:	dc.l unk_C7E60
LnkTo_unk_C7E68:	dc.l unk_C7E68
LnkTo_unk_C7E70:	dc.l unk_C7E70
LnkTo_unk_C7E78:	dc.l unk_C7E78
LnkTo_unk_C7E80:	dc.l unk_C7E80
LnkTo_unk_C7E88:	dc.l unk_C7E88
LnkTo_unk_C7E90:	dc.l unk_C7E90
LnkTo_unk_C7E98:	dc.l unk_C7E98
LnkTo_unk_C7EA0:	dc.l unk_C7EA0
LnkTo_unk_C7EA8:	dc.l unk_C7EA8
LnkTo_unk_C7EB0:	dc.l unk_C7EB0
LnkTo_Pal_A21D8:	dc.l Pal_A21D8
LnkTo_Pal_A21E6:	dc.l Pal_A21E6
			dc.l Pal_A21F4
LnkTo_unk_C7EB8:	dc.l unk_C7EB8
LnkTo_unk_C7EC0:	dc.l unk_C7EC0
LnkTo_unk_C7EC8:	dc.l unk_C7EC8
LnkTo_unk_C7ED0:	dc.l unk_C7ED0
LnkTo_unk_C7ED8:	dc.l unk_C7ED8
LnkTo_unk_C7EE0:	dc.l unk_C7EE0
LnkTo_unk_C7EE8:	dc.l unk_C7EE8
LnkTo_unk_C7EF0:	dc.l unk_C7EF0
LnkTo_unk_C7EF8:	dc.l unk_C7EF8
LnkTo_unk_C7F00:	dc.l unk_C7F00
LnkTo_unk_C7F08:	dc.l unk_C7F08
LnkTo_unk_C7F10:	dc.l unk_C7F10
LnkTo_unk_C7F18:	dc.l unk_C7F18
LnkTo_unk_C7F20:	dc.l unk_C7F20
LnkTo_unk_C7F28:	dc.l unk_C7F28
LnkTo_unk_C7F30:	dc.l unk_C7F30
LnkTo_Pal_A2202:	dc.l Pal_A2202
			dc.l Pal_A221E
			dc.l Pal_A2210
LnkTo_unk_C7F38:	dc.l unk_C7F38
LnkTo_unk_C7F40:	dc.l unk_C7F40
LnkTo_unk_C7F48:	dc.l unk_C7F48
LnkTo_unk_C7F50:	dc.l unk_C7F50
LnkTo_unk_C7F58:	dc.l unk_C7F58
LnkTo_unk_C7F60:	dc.l unk_C7F60
LnkTo_unk_C7F68:	dc.l unk_C7F68
LnkTo_unk_C7F70:	dc.l unk_C7F70
LnkTo_unk_C7F78:	dc.l unk_C7F78
LnkTo_unk_C7F80:	dc.l unk_C7F80
LnkTo_unk_C7F88:	dc.l unk_C7F88
LnkTo_unk_C7F90:	dc.l unk_C7F90
LnkTo_unk_C7F98:	dc.l unk_C7F98
LnkTo_Pal_A222C:	dc.l Pal_A222C
			dc.l Pal_A2248
			dc.l Pal_A223A
LnkTo_unk_C7FA0:	dc.l unk_C7FA0
LnkTo_unk_C7FA8:	dc.l unk_C7FA8
LnkTo_unk_C7FB0:	dc.l unk_C7FB0
LnkTo_unk_C7FB8:	dc.l unk_C7FB8
LnkTo_unk_C7FC0:	dc.l unk_C7FC0
LnkTo_unk_C7FC8:	dc.l unk_C7FC8
LnkTo_unk_C7FD0:	dc.l unk_C7FD0
LnkTo_unk_C7FD8:	dc.l unk_C7FD8
LnkTo_unk_C7FE0:	dc.l unk_C7FE0
LnkTo_unk_C7FE8:	dc.l unk_C7FE8
LnkTo_unk_C7FF0:	dc.l unk_C7FF0
LnkTo_unk_C7FF8:	dc.l unk_C7FF8
LnkTo_Pal_A2256:	dc.l Pal_A2256
LnkTo_Pal_A2264:	dc.l Pal_A2264
			dc.l Pal_A2272
LnkTo_unk_C8000:	dc.l unk_C8000
LnkTo_unk_C8008:	dc.l unk_C8008
LnkTo_unk_C8010:	dc.l unk_C8010
LnkTo_unk_C8018:	dc.l unk_C8018
LnkTo_unk_C8020:	dc.l unk_C8020
LnkTo_unk_C8028:	dc.l unk_C8028
LnkTo_unk_C8030:	dc.l unk_C8030
LnkTo_unk_C8038:	dc.l unk_C8038
LnkTo_unk_C8040:	dc.l unk_C8040
LnkTo_unk_C8048:	dc.l unk_C8048
LnkTo_unk_C8050:	dc.l unk_C8050
LnkTo_unk_C8058:	dc.l unk_C8058
LnkTo_unk_C8060:	dc.l unk_C8060
			dc.l unk_C8068
LnkTo_unk_C8070:	dc.l unk_C8070
LnkTo_unk_C8078:	dc.l unk_C8078
LnkTo_unk_C8080:	dc.l unk_C8080
LnkTo_unk_C8088:	dc.l unk_C8088
LnkTo_Pal_A2280:	dc.l Pal_A2280
			dc.l Pal_A228E
			dc.l Pal_A229C
LnkTo_unk_C8090:	dc.l unk_C8090
LnkTo_unk_C8098:	dc.l unk_C8098
LnkTo_unk_C80A0:	dc.l unk_C80A0
LnkTo_unk_C80A8:	dc.l unk_C80A8
LnkTo_unk_C80B0:	dc.l unk_C80B0
LnkTo_unk_C80B8:	dc.l unk_C80B8
LnkTo_unk_C80C0:	dc.l unk_C80C0
LnkTo_unk_C80C8:	dc.l unk_C80C8
LnkTo_unk_C80D0:	dc.l unk_C80D0
LnkTo_unk_C80D8:	dc.l unk_C80D8
LnkTo_unk_C80E0:	dc.l unk_C80E0
LnkTo_unk_C80E8:	dc.l unk_C80E8
LnkTo_Pal_A22AA:	dc.l Pal_A22AA
			dc.l Pal_A22B8
			dc.l Pal_A22C6
LnkTo_unk_C80F0:	dc.l unk_C80F0
LnkTo_unk_C80F8:	dc.l unk_C80F8
LnkTo_unk_C8100:	dc.l unk_C8100
LnkTo_unk_C8108:	dc.l unk_C8108
LnkTo_unk_C8110:	dc.l unk_C8110
LnkTo_unk_C8118:	dc.l unk_C8118
LnkTo_unk_C8120:	dc.l unk_C8120
LnkTo_unk_C8128:	dc.l unk_C8128
LnkTo_unk_C8130:	dc.l unk_C8130
LnkTo_Pal_A22D4:	dc.l Pal_A22D4
			dc.l Pal_A22E2
			dc.l Pal_A22F0
LnkTo_unk_C8138:	dc.l unk_C8138
LnkTo_unk_C8140:	dc.l unk_C8140
LnkTo_unk_C8148:	dc.l unk_C8148
LnkTo_unk_C8150:	dc.l unk_C8150
LnkTo_unk_C8158:	dc.l unk_C8158
LnkTo_unk_C8160:	dc.l unk_C8160
LnkTo_unk_C8168:	dc.l unk_C8168
LnkTo_unk_C8170:	dc.l unk_C8170
LnkTo_unk_C8178:	dc.l unk_C8178
LnkTo_unk_C8180:	dc.l unk_C8180
LnkTo_Pal_A22FE:	dc.l Pal_A22FE
			dc.l Pal_A230C
			dc.l Pal_A231A
LnkTo_unk_C8188:	dc.l unk_C8188
			dc.l unk_C8190
			dc.l unk_C8198
			dc.l unk_C81A0
			dc.l unk_C81A8
			dc.l unk_C81B0
LnkTo_unk_C81B8:	dc.l unk_C81B8
			dc.l unk_C81C0
LnkTo_unk_C81C8:	dc.l unk_C81C8
LnkTo_unk_C81D0:	dc.l unk_C81D0
			dc.l unk_C81D8
			dc.l unk_C81E0
			dc.l unk_C81E8
LnkTo_unk_C81F0:	dc.l unk_C81F0
LnkTo_unk_C81F8:	dc.l unk_C81F8
LnkTo_unk_C8200:	dc.l unk_C8200
LnkTo_unk_C8208:	dc.l unk_C8208
LnkTo_unk_C8210:	dc.l unk_C8210
LnkTo_unk_C8218:	dc.l unk_C8218
LnkTo_unk_C8220:	dc.l unk_C8220
LnkTo_unk_C8228:	dc.l unk_C8228
LnkTo_unk_C8230:	dc.l unk_C8230
LnkTo_unk_C8238:	dc.l unk_C8238
LnkTo_unk_C8240:	dc.l unk_C8240
LnkTo_unk_C8248:	dc.l unk_C8248
LnkTo_unk_C8250:	dc.l unk_C8250
LnkTo_unk_C8258:	dc.l unk_C8258
LnkTo1_Pal_A2328:	dc.l Pal_A2328
			dc.l Pal_A2346
			dc.l Pal_A2364
LnkTo_unk_C8260:	dc.l unk_C8260
LnkTo_unk_C8268:	dc.l unk_C8268
LnkTo_unk_C8270:	dc.l unk_C8270
LnkTo_unk_C8278:	dc.l unk_C8278
LnkTo_unk_C8280:	dc.l unk_C8280
LnkTo_unk_C8288:	dc.l unk_C8288
LnkTo_unk_C8290:	dc.l unk_C8290
LnkTo_unk_C8298:	dc.l unk_C8298
LnkTo_unk_C82A0:	dc.l unk_C82A0
LnkTo_unk_C82A8:	dc.l unk_C82A8
LnkTo_unk_C82B0:	dc.l unk_C82B0
LnkTo_unk_C82B8:	dc.l unk_C82B8
LnkTo_unk_C82C0:	dc.l unk_C82C0
LnkTo_unk_C82C8:	dc.l unk_C82C8
LnkTo_unk_C82D0:	dc.l unk_C82D0
LnkTo_unk_C82D8:	dc.l unk_C82D8
LnkTo_unk_C82E0:	dc.l unk_C82E0
LnkTo_unk_C82E8:	dc.l unk_C82E8
LnkTo_unk_C82F0:	dc.l unk_C82F0
LnkTo_unk_C82F8:	dc.l unk_C82F8
LnkTo_unk_C8300:	dc.l unk_C8300
LnkTo_unk_C8308:	dc.l unk_C8308
LnkTo_unk_C8310:	dc.l unk_C8310
LnkTo_unk_C8318:	dc.l unk_C8318
LnkTo_unk_C8320:	dc.l unk_C8320
LnkTo_unk_C8328:	dc.l unk_C8328
LnkTo_unk_C8330:	dc.l unk_C8330
LnkTo_unk_C8338:	dc.l unk_C8338
LnkTo_unk_C8340:	dc.l unk_C8340
LnkTo2_Pal_A2328:	dc.l Pal_A2328
			dc.l Pal_A2346
			dc.l Pal_A2364
LnkTo_unk_C8348:	dc.l unk_C8348
LnkTo_unk_C8350:	dc.l unk_C8350
LnkTo_unk_C8358:	dc.l unk_C8358
LnkTo_unk_C8360:	dc.l unk_C8360
LnkTo_unk_C8368:	dc.l unk_C8368
LnkTo_unk_C8370:	dc.l unk_C8370
LnkTo_unk_C8378:	dc.l unk_C8378
LnkTo_unk_C8380:	dc.l unk_C8380
LnkTo_unk_C8388:	dc.l unk_C8388
LnkTo_unk_C8390:	dc.l unk_C8390
LnkTo_unk_C8398:	dc.l unk_C8398
LnkTo_unk_C83A0:	dc.l unk_C83A0
LnkTo_unk_C83A8:	dc.l unk_C83A8
LnkTo_unk_C83B0:	dc.l unk_C83B0
LnkTo_unk_C83B8:	dc.l unk_C83B8
LnkTo_unk_C83C0:	dc.l unk_C83C0
LnkTo_unk_C83C8:	dc.l unk_C83C8
LnkTo_unk_C83D0:	dc.l unk_C83D0
LnkTo_unk_C83D8:	dc.l unk_C83D8
LnkTo_unk_C83E0:	dc.l unk_C83E0
LnkTo_unk_C83E8:	dc.l unk_C83E8
LnkTo_unk_C83F0:	dc.l unk_C83F0
LnkTo_unk_C83F8:	dc.l unk_C83F8
LnkTo_unk_C8400:	dc.l unk_C8400
LnkTo_unk_C8408:	dc.l unk_C8408
			dc.l unk_C8410
LnkTo_unk_C8418:	dc.l unk_C8418
LnkTo_unk_C8420:	dc.l unk_C8420
LnkTo_unk_C8428:	dc.l unk_C8428
LnkTo_Pal_A2382:	dc.l Pal_A2382
LnkTo_unk_C8430:	dc.l unk_C8430
LnkTo_unk_C8438:	dc.l unk_C8438
LnkTo_unk_C8440:	dc.l unk_C8440
LnkTo_unk_C8448:	dc.l unk_C8448
			dc.l unk_C8450
LnkTo_unk_C8458:	dc.l unk_C8458
LnkTo_unk_C8460:	dc.l unk_C8460
LnkTo_unk_C8468:	dc.l unk_C8468
LnkTo_unk_C8470:	dc.l unk_C8470
LnkTo_unk_C8478:	dc.l unk_C8478
LnkTo_unk_C8480:	dc.l unk_C8480
LnkTo_Pal_A23A0:	dc.l Pal_A23A0
LnkTo_unk_C8488:	dc.l unk_C8488
LnkTo_unk_C8490:	dc.l unk_C8490
LnkTo_unk_C8498:	dc.l unk_C8498
LnkTo_unk_C84A0:	dc.l unk_C84A0
LnkTo_unk_C84A8:	dc.l unk_C84A8
LnkTo_unk_C84B0:	dc.l unk_C84B0
LnkTo_unk_C84B8:	dc.l unk_C84B8
LnkTo_unk_C84C0:	dc.l unk_C84C0
LnkTo_unk_C84C8:	dc.l unk_C84C8
LnkTo_unk_C84D0:	dc.l unk_C84D0
LnkTo_unk_C84D8:	dc.l unk_C84D8
LnkTo_unk_C84E0:	dc.l unk_C84E0
LnkTo_unk_C84E8:	dc.l unk_C84E8
LnkTo_unk_C84F0:	dc.l unk_C84F0
LnkTo_unk_C84F8:	dc.l unk_C84F8
LnkTo_unk_C8500:	dc.l unk_C8500
			dc.l unk_C8508
LnkTo_unk_C8510:	dc.l unk_C8510
LnkTo_unk_C8518:	dc.l unk_C8518
LnkTo_unk_C8520:	dc.l unk_C8520
LnkTo_unk_C8528:	dc.l unk_C8528
LnkTo_Pal_A23AE:	dc.l Pal_A23AE
LnkTo_unk_C8530:	dc.l unk_C8530
LnkTo_unk_C8538:	dc.l unk_C8538
LnkTo_unk_C8540:	dc.l unk_C8540
LnkTo_unk_C8548:	dc.l unk_C8548
			dc.l unk_C8550
			dc.l unk_C8558
			dc.l unk_C8560
			dc.l unk_C8568
			dc.l unk_C8570
			dc.l unk_C8578
			dc.l unk_C8580
			dc.l unk_C8588
			dc.l unk_C8590
			dc.l unk_C8598
			dc.l unk_C85A0
			dc.l unk_C85A8
			dc.l unk_C85B0
			dc.l unk_C85B8
			dc.l unk_C85C0
			dc.l unk_C85C8
			dc.l unk_C85D0
			dc.l unk_C85D8
			dc.l unk_C85E0
LnkTo_unk_C85E8:	dc.l unk_C85E8
LnkTo_unk_C85F0:	dc.l unk_C85F0
LnkTo_unk_C85F8:	dc.l unk_C85F8
LnkTo_unk_C8600:	dc.l unk_C8600
LnkTo_unk_C8608:	dc.l unk_C8608
LnkTo_unk_C8610:	dc.l unk_C8610
LnkTo_unk_C8618:	dc.l unk_C8618
LnkTo_unk_C8620:	dc.l unk_C8620
			dc.l unk_C8628
			dc.l unk_C8630
LnkTo_unk_C8638:	dc.l unk_C8638
LnkTo_unk_C8640:	dc.l unk_C8640
LnkTo_unk_C8648:	dc.l unk_C8648
LnkTo_unk_C8650:	dc.l unk_C8650
			dc.l unk_C8658
			dc.l unk_C8660
LnkTo_unk_C8668:	dc.l unk_C8668
			dc.l unk_C8670
			dc.l unk_C8678
LnkTo_unk_C8680:	dc.l unk_C8680
			dc.l unk_C8688
			dc.l unk_C8690
			dc.l unk_C8698
			dc.l unk_C86A0
LnkTo_unk_C86A8:	dc.l unk_C86A8
LnkTo_unk_C86B0:	dc.l unk_C86B0
			dc.l unk_C86B8
LnkTo_unk_C86C0:	dc.l unk_C86C0
			dc.l unk_C86C8
LnkTo_unk_C86D0:	dc.l unk_C86D0
			dc.l unk_C86D8
LnkTo_unk_C86E0:	dc.l unk_C86E0
LnkTo_unk_C86E8:	dc.l unk_C86E8
LnkTo_unk_C86F0:	dc.l unk_C86F0
LnkTo_unk_C86F8:	dc.l unk_C86F8
LnkTo_unk_C8700:	dc.l unk_C8700
LnkTo_unk_C8708:	dc.l unk_C8708
LnkTo_unk_C8710:	dc.l unk_C8710
LnkTo_unk_C8718:	dc.l unk_C8718
LnkTo_unk_C8720:	dc.l unk_C8720
LnkTo_unk_C8728:	dc.l unk_C8728
LnkTo_unk_C8730:	dc.l unk_C8730
LnkTo_unk_C8738:	dc.l unk_C8738
LnkTo_unk_C8740:	dc.l unk_C8740
LnkTo_unk_C8748:	dc.l unk_C8748
LnkTo_unk_C8750:	dc.l unk_C8750
LnkTo_unk_C8758:	dc.l unk_C8758
LnkTo_unk_C8760:	dc.l unk_C8760
LnkTo_unk_C8768:	dc.l unk_C8768
LnkTo_unk_C8770:	dc.l unk_C8770
LnkTo_unk_C8778:	dc.l unk_C8778
LnkTo_unk_C8780:	dc.l unk_C8780
LnkTo_unk_C8788:	dc.l unk_C8788
LnkTo_unk_C8790:	dc.l unk_C8790
LnkTo_unk_C8798:	dc.l unk_C8798
LnkTo_unk_C87A0:	dc.l unk_C87A0
LnkTo_unk_C87A8:	dc.l unk_C87A8
LnkTo_unk_C87B0:	dc.l unk_C87B0
LnkTo_unk_C87B8:	dc.l unk_C87B8
LnkTo_unk_C87C0:	dc.l unk_C87C0
LnkTo_unk_C87C8:	dc.l unk_C87C8
LnkTo_unk_C87D0:	dc.l unk_C87D0
LnkTo_unk_C87D8:	dc.l unk_C87D8
LnkTo_unk_C87E0:	dc.l unk_C87E0
LnkTo_unk_C87E8:	dc.l unk_C87E8
LnkTo_unk_C87F0:	dc.l unk_C87F0
LnkTo_unk_C87F8:	dc.l unk_C87F8
LnkTo_unk_C8800:	dc.l unk_C8800
LnkTo_unk_CA1ED:	dc.l unk_CA1ED
LnkTo_unk_CAD8E:	dc.l unk_CAD8E
LnkTo_unk_CBC1C:	dc.l unk_CBC1C
LnkTo_unk_CCD87:	dc.l unk_CCD87
LnkTo_unk_CC7E0:	dc.l unk_CC7E0
LnkTo_unk_CDAB8:	dc.l unk_CDAB8
LnkTo_unk_CE944:	dc.l unk_CE944
LnkTo_unk_CF02F:	dc.l unk_CF02F
LnkTo_unk_CF71D:	dc.l unk_CF71D
LnkTo_unk_D03E2:	dc.l unk_D03E2
LnkTo_unk_D0B79:	dc.l unk_D0B79
LnkTo_unk_D1ED8:	dc.l unk_D1ED8
LnkTo_unk_D3151:	dc.l unk_D3151
LnkTo_unk_D3D94:	dc.l unk_D3D94
LnkTo_unk_D4ED3:	dc.l unk_D4ED3
LnkTo_unk_D8176:	dc.l unk_D8176
LnkTo_unk_D88E7:	dc.l unk_D88E7
LnkTo_unk_D985D:	dc.l unk_D985D
LnkTo_unk_DA75D:	dc.l unk_DA75D
LnkTo_unk_DACAB:	dc.l unk_DACAB
LnkTo_unk_DB03A:	dc.l unk_DB03A
LnkTo_unk_DB2BC:	dc.l unk_DB2BC
LnkTo_unk_D744D:	dc.l unk_D744D
LnkTo_unk_DBA4D:	dc.l unk_DBA4D
LnkTo_unk_DC579:	dc.l unk_DC579
LnkTo_unk_DD8BB:	dc.l unk_DD8BB
LnkTo_unk_DE3E3:	dc.l unk_DE3E3
LnkTo_unk_DEA20:	dc.l unk_DEA20
LnkTo_unk_E06B5:	dc.l unk_E06B5
LnkTo_unk_E0E4E:	dc.l unk_E0E4E
LnkTo_unk_E0E56:	dc.l unk_E0E56
LnkTo_unk_E0E5E:	dc.l unk_E0E5E
LnkTo1_unk_E0E66:	dc.l unk_E0E66
LnkTo2_unk_E0E66:	dc.l unk_E0E66
LnkTo3_unk_E0E66:	dc.l unk_E0E66
LnkTo4_unk_E0E66:	dc.l unk_E0E66
LnkTo_unk_E0E6E:	dc.l unk_E0E6E
LnkTo_unk_E0E76:	dc.l unk_E0E76
			dc.l unk_E0E7E
			dc.l unk_E0E86
LnkTo_unk_E0E8E:	dc.l unk_E0E8E
LnkTo_unk_E0E96:	dc.l unk_E0E96
LnkTo_unk_E0E9E:	dc.l unk_E0E9E
LnkTo_unk_E0EA6:	dc.l unk_E0EA6
LnkTo_unk_E0EAE:	dc.l unk_E0EAE
			dc.l unk_E0EB6
LnkTo_unk_E0EBE:	dc.l unk_E0EBE
			dc.l unk_E0EC6
LnkTo_unk_E0ECE:	dc.l unk_E0ECE
LnkTo_unk_E0ED6:	dc.l unk_E0ED6
LnkTo_unk_E0EDE:	dc.l unk_E0EDE
LnkTo_unk_E0EE6:	dc.l unk_E0EE6
LnkTo_unk_E0EEE:	dc.l unk_E0EEE
LnkTo_unk_E0EF6:	dc.l unk_E0EF6
LnkTo_unk_E0EFE:	dc.l unk_E0EFE
LnkTo_unk_E0F06:	dc.l unk_E0F06
LnkTo_unk_E0F0E:	dc.l unk_E0F0E
LnkTo_unk_E0F16:	dc.l unk_E0F16
LnkTo_unk_E0F1E:	dc.l unk_E0F1E
LnkTo_unk_E0F26:	dc.l unk_E0F26
LnkTo_unk_E0F2E:	dc.l unk_E0F2E
LnkTo_unk_E0F36:	dc.l unk_E0F36
LnkTo_unk_E0F3E:	dc.l unk_E0F3E
LnkTo_unk_E0F46:	dc.l unk_E0F46
			dc.l unk_E0F4E
LnkTo_unk_E0F56:	dc.l unk_E0F56
			dc.l unk_E0F5E
			dc.l unk_E0F66
			dc.l unk_E0F6E
			dc.l unk_E0F76
			dc.l unk_E0F7E
			dc.l unk_E0F86
			dc.l unk_E0F8E
			dc.l unk_E0F96
			dc.l unk_E0F9E
			dc.l unk_E0FA6
			dc.l unk_E0FAE
			dc.l unk_E0FB6
			dc.l unk_E0FBE
			dc.l unk_E0FC6
LnkTo_unk_E0FCE:	dc.l unk_E0FCE
LnkTo1_NULL:		dc.l 0

