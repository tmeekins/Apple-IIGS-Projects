 5  DIM Q(15,3),DF(15),COL(15): DIM C(1,1)
 10  DIM P(15,3)
 15  &  HGR 
 20  FOR I = 0 TO 15: FOR J = 1 TO 3:P(I,J) = I: NEXT : NEXT 
 30  FOR I = 0 TO 15: &  DEF I,P(I,1),P(I,2),P(I,3): NEXT 
 50  FOR YY = 72 TO 0 STEP  - 1:R = YY:G = R:B = R: GOSUB 1000
 60  FOR X = 0 TO 319:Y = YY * 2: GOSUB 2000:Y = YY * 2 + 1: GOSUB 2000: NEXT : NEXT 
 80  END 
 1000  FOR I = 0 TO 15: FOR J = 1 TO 3:Q(I,J) = P(I,J) * 72 / 15: NEXT : NEXT 
 1010  FOR I = 0 TO 15:DF(I) =  ABS (Q(I,1) - R) +  ABS (Q(I,2) - G) +  ABS (Q(I,3) - B): NEXT 
 1020  FOR I = 0 TO 15:COL(I) = I: NEXT 
 1030  FOR I = 0 TO 3: FOR J = I TO 15
 1040  IF DF(J) < DF(I) THEN T = DF(J):DF(J) = DF(I):DF(I) = T:T = COL(J):COL(J) = COL(I):COL(I) = T
 1050  NEXT : NEXT 
 1060 A = COL(0):B = A:C = B:D = C
 1070  IF DF(0) < 2 THEN 1200
 1080 B = COL(1)
 1090  IF DF(0) < 4 THEN 1200
 1100 C = COL(1)
 1200 C(0,0) = C:C(1,0) = D:C(0,1) = A:C(1,1) = B
 1210  RETURN 
 2000 X1 = 0:Y1 = 0
 2010  IF (X / 2) <  >  INT (X / 2) THEN X1 = 1
 2020  IF (Y / 2) <  >  INT (Y / 2) THEN Y1 = 1
 2030  &  HCOLOR= C(X1,Y1)
 2040  &  HPLOT X,Y
 2050  RETURN 
 5000  DATA 0,0,0,7,7,7,8,4,1,7,2,12,0,0,15,0,8,0,15,7,0,13,0,0,15,10,9,15,15,0,0,14,0,4,13,15,13,10,15,7,8,15,12,12,12,15,15,15
