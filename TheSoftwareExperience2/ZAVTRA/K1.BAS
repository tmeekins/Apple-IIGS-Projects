 5 V = 1:VS = 1
 8  HOME 
 9  GR 
 10 T =  RND (9): FOR S = 1 TO 18:S% = S
 11  VTAB 22: PRINT S,V
 12  FOR Y = 0 TO 19: FOR X = Y TO 19: GOSUB 20: COLOR= C
 13  PLOT X,39 - Y: PLOT 39 - X,39 - Y: PLOT 39 - X,Y: PLOT X,Y: PLOT Y,X: PLOT 39 - Y,X: PLOT 39 - Y,39 - X: PLOT Y,39 - X
 14  NEXT X,Y
 16 V = V + VS: IF V > 0 AND V < 16 GOTO 11
 17  IF V = 16 THEN V = 15:VS =  - 1
 18  IF V = 0 THEN V = 1:VS = 1
 19  NEXT : GOTO 10
 20  IF T < .4 THEN C = ( ABS ((1.5 * X / (S% + 18)) - (1.5 * Y / (S% + 18)) * (X - (S% + V))) + S%): RETURN 
 21  IF T > .6 THEN C = (( ABS ((V * X / 25) - (V * Y / 25) * ((Y - S%) / V)) + S%) * (T > .6)): RETURN 
 22 C = ( ABS ((S5 * X / 25) - (S% * Y / 25) * ((X - V) / S%)) + S%): RETURN 
