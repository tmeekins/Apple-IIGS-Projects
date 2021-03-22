 1  &  HGR :X(1) = 25:X(2) = 50:X(3) = 240:Y(1) = 25:Y(2) = 180:Y(3) = 100: FOR I = 0 TO 15: &  DEF I,I,I,I: NEXT 
 2  FOR I = 0 TO 199: FOR J = 0 TO 319
 3 M = 0: FOR K = 1 TO 3
 4 Q = I - Y(K):R = J - X(K)
 5 S =  SQR (Q * Q + R * R)
 6 M = M + ( - .2 * S + 50) * (1 +  COS (.1 * S))
 7  NEXT K
 8 A = (M + .5) / 8: &  HCOLOR= (A -  INT (A)) * 16
 9  &  HPLOT J,I
 10  NEXT J: NEXT I
