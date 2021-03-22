;
; A music sequence consists of a sequence of command lists. One after another.
; A command list begins with the # beats until the next command list is used,
; followed by a list of commands. A command list is terminated by the command
; 'endcmd'. A sequence is terminated if # beats 'til next cmdlst is 0.
;

;
; Commands
;
endcmd         gequ  0
playnote       gequ  1                  ;followed by osc,note
stopnote       gequ  2                  ;followed by osc
settempo       gequ  3                  ;followed by new tempo
setchan        gequ  4                  ;followed by osc,channel
;
; Notes
;
C2             gequ  $24
C2s            gequ  $25
D2             gequ  $26
D2s            gequ  $27
E2             gequ  $28
F2             gequ  $29
F2s            gequ  $2A
G2             gequ  $2B
G2s            gequ  $2C
A2             gequ  $2D
A2s            gequ  $2E
B2             gequ  $2F
C3             gequ  $30
C3s            gequ  $31
D3             gequ  $32
D3s            gequ  $33
E3             gequ  $34
F3             gequ  $35
F3s            gequ  $36
G3             gequ  $37
G3s            gequ  $38
A3             gequ  $39
A3s            gequ  $3A
B3             gequ  $3B
C4             gequ  $3C
C4s            gequ  $3D
D4             gequ  $3E
D4s            gequ  $3F
E4             gequ  $40
F4             gequ  $41
F4s            gequ  $42
G4             gequ  $43
G4s            gequ  $44
A4             gequ  $45
A4s            gequ  $46
B4             gequ  $47
C5             gequ  $48
C5s            gequ  $49
D5             gequ  $4A
D5s            gequ  $4B
E5             gequ  $4C
F5             gequ  $4D
F5s            gequ  $4E
G5             gequ  $4F
G5s            gequ  $50
A5             gequ  $51
A5s            gequ  $52
B5             gequ  $53
