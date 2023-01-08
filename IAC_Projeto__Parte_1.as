STACKBASE       EQU     8000h
                
                ORIG    0020h
                
MAPA            TAB     40

B               WORD    5

                MVI     R6, STACKBASE

loop:           MVI     R1, MAPA
                MVI     R2, 40
                
                JAL     atualizajogo
                BR      loop
                
Fim:            BR      Fim
                
atualizajogo:   DEC     R2 ;Se já tiver avançado o jogo todo, acabar a funçao
                BR.Z    atualizajogo2
                
                ;copiar o valor da direita para a esquerda
                
                INC     R1
                LOAD    R3, M[R1]
                DEC     R1
                STOR    M[R1], R3
                INC     R1 ;avançar uma casa
                BR      atualizajogo
                
atualizajogo2:  DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R1
                JAL     geracacto
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R1], R3
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7
                
geracacto:      DEC     R6
                STOR    M[R6], R4
                
                DEC     R6
                STOR    M[R6], R5
                
                MVI     R1, 16
                MVI     R2, B
                MVI     R4, 1
                LOAD    R2, M[R2]
                
                AND     R4, R2, R4
                
                SHR     R2
                
                MVI     R5, 1
                CMP     R4, R5
                BR.Z    bit

geracacto2:     MVI     R3, B
                STOR    M[R3], R2
                MVI     R5, 62258
                CMP     R2, R5
                BR.C    valor0
                DEC     R1
                AND     R2, R2, R1
                INC     R2
                MOV     R3, R2
                
                LOAD    R5, M[R6]
                INC     R6
                       
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7
                
bit:            MVI     R5, b400h
                XOR     R2, R2, R5
                BR      geracacto2
                
valor0:         MOV     R3, R0

                LOAD    R5, M[R6]
                INC     R6
                
                LOAD    R4, M[R6]
                INC     R6
                
                JMP     R7                
  
                
                
