 10  HGR2 : FOR M = 1 TO 20:P = 45:Q = 25:A = 22:B = 20:C =  - 1:D =  - 1: FOR L = 1 TO 4: FOR K = 1 TO 5: FOR I = 0 TO 19:X = P - C * I
 20 Y = Q - D * I:S = P + C * I:T = Q + D * I:E = X - A:F = Y - B:G = S + A:H = T + B: HCOLOR=  RND (1) * 7 + 1
 30  HPLOT S,Y TO G,Y TO G,F TO S,F TO S,Y: HPLOT X,T TO E,T TO E,H TO X,H TO X,T: HPLOT S,T TO G,T TO G,H TO S,H TO S,T
 40  NEXT I:P = P + 45: NEXT :P = 45:Q = Q + 40: NEXT : NEXT 
