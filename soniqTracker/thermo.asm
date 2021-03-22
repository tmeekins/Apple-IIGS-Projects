**************************************************************************
*
* ImageQuant thermometer routines
*
**************************************************************************

	mcopy	m/thermo.mac

**************************************************************************
*
* Open a thermometer window
*
**************************************************************************

OpenThermo	START	xtras

	using	ThermoData

space	equ	0

	subroutine (4:string,2:size),space

	lda	size
	sta	ThermoMax
	stz	ThermoVal
	lda	string
	sta	ThermoString
	lda	string+2
	sta	ThermoString+2

	NewWindow2 (#0,#0,#ThermoDraw,#0,#0,#ThermoWindow,#$800E),ThermoPort
	GetCtlHandleFromID (#0,#1000),ThermoCtl
               ShowWindow ThermoPort
               jsl	ThermoDraw
	
	return

	END

**************************************************************************
*
* Close a thermometer window
*
**************************************************************************

CloseThermo	START	xtras

	using	ThermoData

	phb
	phk
	plb

	CloseWindow ThermoPort

	plb
	rtl

	END

**************************************************************************
*
* Draw the contents of thermometer window
*
**************************************************************************

ThermoDraw	START	xtras

	using	ThermoData

	phb
	phk
	plb

	SetPort ThermoPort

	CStringWidth ThermoString,@a
	lsr	a
	sta	temp
	sec
	lda	#200
	sbc	temp
	tax	
	MoveTo (@x,#15)
	DrawCString ThermoString

	DrawControls ThermoPort

	plb
	rtl

temp	ds	2

	END

**************************************************************************
*
* Update the thermometer
*
**************************************************************************

UpdateThermo	START	xtras

	using	ThermoData

	phb
	phk
	plb

	SetCtlValue (@a,ThermoCtl)
;	DrawControls ThermoPort
	plb
	rtl            

	END

**************************************************************************
*
* Thermometer data
*
**************************************************************************

ThermoData	DATA	xtras

ThermoString	ds	4
ThermoPort	ds	4
ThermoCtl	ds	4

ThermoWindow 	ANOP
           	DC 	I2'$50' 	; template size
           	DC 	I2'$20A0' 	; frame bits
           	DC 	I4'0' 	; no title
           	DC 	I4'0' 	; window refcon
           	DC 	I2'0,0,0,0' 	; zoom rectangle
           	DC 	I4'0' 	; standard colors
           	DC 	I2'0,0' 	; origin y/x
           	DC 	I2'0,0' 	; data height/width
           	DC 	I2'0,0' 	; max height/width
           	DC 	I2'0,0' 	; scroll vert/horiz
           	DC 	I2'0,0' 	; page vert/horiz
           	DC 	I4'0' 	; info refcon
           	DC 	I2'0' 	; info height
           	DC 	I4'0' 	; frame defproc
           	DC 	I4'0' 	; info defproc
           	DC 	I4'0' 	; content defproc
           	DC 	I2'80,120,120,520' ; position
           	DC 	I4'-1' 	; plane
           	DC 	I4'ThermoList' 	; control reference
           	DC 	I2'3' 	; indescref

ThermoList 	ANOP
           	DC 	I4'ThermoControl' 	; control 1
           	DC 	I4'0'	; end of control list

ThermoControl 	ANOP
           	DC 	I2'8' 	; pCount
           	DC 	I4'1000' 	; ID (1000)
           	DC 	I2'25,20,35,380' 	; rect
           	DC 	I4'$87FF0002' 	; thermometer
           	DC 	I2'1' 	; flag
           	DC 	I2'%0001000000000000' ; moreFlags
           	DC 	I4'0' 	; refCon
ThermoVal      DC 	I2'100' 	; value
ThermoMax      DC 	I2'200' 	; data
           	DC 	I4'0' 	; no ctlColorTable

	END
                               
