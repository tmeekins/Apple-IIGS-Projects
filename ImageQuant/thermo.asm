**************************************************************************
*
* ImageQuant thermometer routines
*
**************************************************************************

	mcopy	thermo.mac

**************************************************************************
*
* Open a thermometer window
*
**************************************************************************

OpenThermo	START

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

CloseThermo	START

	using	ThermoData

	CloseWindow ThermoPort

	rtl

	END

**************************************************************************
*
* Draw the contents of thermometer window
*
**************************************************************************

ThermoDraw	START

	using	ThermoData

	SetPort ThermoPort

	CStringWidth ThermoString,@a
	lsr	a
	sta	temp
	sec
	lda	#200
	sbc	temp
	tax	
	MoveTo (@x,#30)
	DrawCString ThermoString

	DrawControls ThermoPort
	rtl

temp	ds	2

	END

**************************************************************************
*
* Update the thermometer
*
**************************************************************************

UpdateThermo	START

	using	ThermoData

	phy
	SetCtlValue (@a,ThermoCtl)
;	DrawControls ThermoPort
	ply
	rtl            

	END

**************************************************************************
*
* Thermometer data
*
**************************************************************************

ThermoData	DATA

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
           	DC 	I2'70,100,130,500' ; position
           	DC 	I4'-1' 	; plane
           	DC 	I4'ThermoList' 	; control reference
           	DC 	I2'3' 	; indescref

ThermoList 	ANOP
           	DC 	I4'ThermoControl' 	; control 1
           	DC 	I4'0'	; end of control list

ThermoControl 	ANOP
           	DC 	I2'8' 	; pCount
           	DC 	I4'1000' 	; ID (1000)
           	DC 	I2'40,20,50,360' 	; rect
           	DC 	I4'$87FF0002' 	; thermometer
           	DC 	I2'1' 	; flag
           	DC 	I2'%0001000000000000' ; moreFlags
           	DC 	I4'0' 	; refCon
ThermoVal      DC 	I2'100' 	; value
ThermoMax      DC 	I2'200' 	; data
           	DC 	I4'0' 	; no ctlColorTable

	END
                               
