 5 V = 1:VS = 1
 8  HOME 
 9  &  HGR : GOSUB 300
 10  FOR T = 1 TO 3: FOR S = 1 TO 18:S% = S
 11  VTAB 22: PRINT T,S,V: &  XDRAW 
 12  FOR Y = 0 TO 19: FOR X = Y TO 19: ON T GOSUB 20,21,22:C =  INT (C): IF C > 15 THEN C = C - 16
 13  &  HCOLOR= C
 14  GOSUB 100
 15  NEXT X,Y: &  DRAW 
 16 V = V + VS: IF V > 0 AND V < 16 GOTO 11
 17  IF V = 16 THEN V = 15:VS =  - 1
 18  IF V = 0 THEN V = 1:VS = 1
 19  NEXT : NEXT : GOTO 10
 20 C = ( ABS ((1.5 * X / (S% + 18)) - (1.5 * Y / (S% + 18)) * (X - (S% + V))) + S%): RETURN 
 21 C = (( ABS ((V * X / 25) - (V * Y / 25) * ((Y - S%) / V)) + S%) * (T > .6)): RETURN 
 22 C = ( ABS ((S5 * X / 25) - (S% * Y / 25) * ((X - V) / S%)) + S%): RETURN 
 100 XX = X:YY = 39 - Y: GOSUB 200
 101 XX = 39 - X: GOSUB 200
 102 YY = Y: GOSUB 200
 103 XX = X: GOSUB 200
 104  RETURN 
 200  & SR(XX * 4,YY * 3),(XX * 4 + 3,YY * 3 + 2)
 210  & SR(YY * 4,XX * 3),(YY * 4 + 3,XX * 3 + 2)
 220  RETURN 
 300  FOR I = 0 TO 15: READ R,G,B: &  DEF I,R,G,B: NEXT : RETURN 
 310  DATA 0,0,0
 311  DATA 0,0,10
 312  DATA 9,0,10
 313  DATA 12,0,12
 314  DATA 13,0,8
 315  DATA 14,2,2
 316  DATA 15,4,0
 317  DATA 15,7,0
 318  DATA 15,9,0
 319  DATA 15,11,0
 320  DATA 15,13,0
 321  DATA 15,15,0
 322  DATA 10,13,0
 323  DATA 6,11,0
 324  DATA 3,10,0
 325  DATA 0,8,0
