* = PlayerADDR

InitIRQ:

    sei

    lda #$35
    sta $01

    jsr VSync

	lda #$00
	sta $d011
	sta $d020
    jsr SIDInit

    jsr VSync

    jsr NMIFix

    lda #<MusicIRQ
    sta $fffe
    lda #>MusicIRQ
    sta $ffff

    ldx #0
    jsr SetNextRaster

    lda #$7f
    sta $dc0d
    lda $dc0d
    lda #$01
    sta $d01a
    lda #$01
    sta $d019

    cli

Forever:
    jmp Forever

VSync:
	bit	$d011
	bpl	*-3
	bit	$d011
	bmi	*-3
    rts

SetNextRaster:
    lda D012_Values, x
    sta $d012
    lda $d011
    and #$7f
    ora D011_Values, x
    sta $d011
    rts

MusicIRQ:
callCount:
    ldx #0
    inx
    cpx #NumCallsPerFrame
    bne JustPlayMusic

ColChangeFrame:
    ldy #$c0
    iny
    bne !skip+
    inc $d020
    ldy #$c0
!skip:
    sty ColChangeFrame + 1
    ldx #0

JustPlayMusic:
    stx callCount + 1

    jsr SIDPlay

    ldx callCount + 1
    jsr SetNextRaster

    asl $d019
    rti

//; =============================================================================
//; DATA SECTION - Raster Line Timing
//; =============================================================================

.var FrameHeight = 312 // TODO: NTSC!
D011_Values: .fill NumCallsPerFrame, (>(mod(250 + ((FrameHeight * i) / NumCallsPerFrame), 312))) * $80
D012_Values: .fill NumCallsPerFrame, (<(mod(250 + ((FrameHeight * i) / NumCallsPerFrame), 312)))

.import source "../INC/NMIFix.asm"

