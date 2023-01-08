    STACKBASE       EQU     8000h
                
                ORIG    0020h
                
MAP_DIM         EQU     80 
CATO_MAX_ALTURA EQU     8   
SALTO_MAX       EQU     12  ; tem de ser numero par
MAPA            TAB     80


B               WORD    5
JUMPstate       WORD    0     ; = 1 if the dino is jumping
JUMPaltura      WORD    0
dinoLastCursor  WORD    0
FlagDescida     WORD    0     ; 0 se sobe, 1 se desce
Centenas        WORD    0
Milhares        WORD    0
DezMilhares     WORD    0
CentMilhares    WORD    0
Game_Over       STR     '---> Game Over <---'
RESTART         WORD    0

TERM_WRITE      EQU     FFFEh
TERM_CURSOR     EQU     FFFCh
TERM_READ       EQU     FFFFh
TERM_STATE      EQU     FFFDh
INT_MASK_VALUE  EQU     FFFFh
INT_MASK        EQU     FFFAh
TIMER_CONTROL   EQU     FFF7h
TIMER_VALUE     EQU     FFF6h

DISP7SEG_3      EQU     FFF3h
DISP7SEG_2      EQU     FFF2h
DISP7SEG_1      EQU     FFF1h
DISP7SEG_0      EQU     FFF0h
DISP7SEG_5      EQU     FFEFh
DISP7SEG_4      EQU     FFEEh



Main:           
                 
                
                ;enables interruptions
                MVI     R1, INT_MASK
                MVI     R2, INT_MASK_VALUE
                STOR    M[R1], R2               ; set interrupt mask
                
                
                
                MVI     R6, STACKBASE
                
                JAL     desenhaMapa
                JAL     desenhaDino
                
                ENI
                JAL     INIT_TIMER
                
loop:           
                JAL     atualizaDino
                
                MVI     R1, MAPA
                MVI     R2, 0
                JAL     atualizamapa 
                BR      loop
;==============================================================
; Rotina de fim de jogo.
; Imprime mensagem "Game Over" e espera que o utilizador carregue
; em 0 para recomeçar
;==============================================================                
GAME_OVER:      MVI     R1, TIMER_CONTROL
                STOR    M[R1], R0          ;desativa o timer 
                
                MVI     R1, TERM_CURSOR
                MVI     R2, 5150
                STOR    M[R1], R2
                MVI     R4, TERM_WRITE
                MVI     R2, 19
                MVI     R1, Game_Over
                
mensagem:       LOAD    R3, M[R1]
                STOR    M[R4], R3
                INC     R1
                DEC     R2
                CMP     R2, R0
                BR.P    mensagem
                MVI     R1, RESTART
                STOR    M[R1], R0
                
espera_0:       
                LOAD    R2, M[R1]
                CMP     R2, R0
                BR.Z    espera_0
                
                
                JAL     ClearPreviousMap
                
                BR      Main ;recomeça o programa

;==============================================================
; Pega no Cato da posição de memória guardada em R1,  
; apaga-o do terminal
;==============================================================
apagaCato:      LOAD    R3, M[R1]
                MOV     R4, R2
                MVI     R5, 11008   ;coluna 43
                ADD     R5, R5, R4 ; Pos inicial do cursor
                MVI     R4, 256 ; numero para subir coluna
                
                DEC     R6
                STOR    M[R6], R2
                
                CMP     R3, R0
                BR.Z    fimloopii
                
                
loopii:         MVI     R2, TERM_CURSOR
                STOR    M[R2], R5
                MVI     R2, TERM_WRITE
                
                DEC     R6
                STOR    M[R6], R3
                MVI     R3, ' '
                STOR    M[R2], R3
                LOAD    R3, M[R6]
                INC     R6
                
                SUB     R5, R5, R4
                
                DEC     R3
                CMP     R3, R0
                BR.P    loopii
                BR      fimloopii

                
; esta pequena etiqueta é usada tanto na função imprimeCato como na apagaCato                 
fimloopii:      LOAD    R2, M[R6]
                INC     R6
                JMP     R7


;==============================================================
; Pega no Cato da posição de memória guardada em R1, e 
; representa-o no terminal
;==============================================================
imprimeCato:    LOAD    R3, M[R1]
                MOV     R4, R2
                ;SHL     R4 ;isto é a linha
                MVI     R5, 11008   ;coluna 43
                ADD     R5, R5, R4 ; Pos inicial do cursor
                MVI     R4, 256 ; numero para subir coluna
                
                DEC     R6
                STOR    M[R6], R2
                
                CMP     R3, R0
                BR.Z    fimloopii
                
                
loopiii:        DEC     R6   
                STOR    M[R6], R1
                MVI     R1, dinoLastCursor
                LOAD    R1, M[R1]
                CMP     R5, R1       ;Vê se colidiu com Cato
                BR.Z    GAME_OVER
                LOAD    R1, M[R6]
                INC     R6
                
                MVI     R2, TERM_CURSOR
                STOR    M[R2], R5
                MVI     R2, TERM_WRITE
                
                DEC     R6
                STOR    M[R6], R3
                MVI     R3, '#'
                STOR    M[R2], R3
                LOAD    R3, M[R6]
                INC     R6
                
                SUB     R5, R5, R4
                
                DEC     R3
                CMP     R3, R0
                BR.P    loopiii
                BR      fimloopii
                
;==============================================================
; Atualiza todo o mapa. Função central do jogo que recorre a 
; outras funções para correr ordeiramente o programa
;==============================================================
                
atualizamapa:   ;Se já tiver avançado o jogo todo, acabar a funçao
                MVI     R3, MAP_DIM
                DEC     R3
                CMP     R3, R2
                BR.Z    atualizamapa2
                
                ;apagar o cato (caso exista algum)
                DEC     R6
                STOR    M[R6], R7
                JAL     apagaCato
                LOAD    R7, M[R6]
                INC     R6
                
               
                ;copiar o valor da direita para a esquerda da tabela de catos
                INC     R1
                LOAD    R3, M[R1]
                DEC     R1
                STOR    M[R1], R3
                
                ;imprime o novo cato da posição (caso exista algum)
                DEC     R6
                STOR    M[R6], R7
                JAL     imprimeCato
                LOAD    R7, M[R6]
                INC     R6
                
                INC     R1 ;avançar uma casa da tabela
                INC     R2 
                
                BR      atualizamapa ; so para quando o jogador perder
                
atualizamapa2:  DEC     R6
                STOR    M[R6], R7
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                DEC     R6
                STOR    M[R6], R4
                
                DEC     R6
                STOR    M[R6], R5
                JAL     geracacto
                
                LOAD    R5, M[R6]
                INC     R6
                
                LOAD    R4, M[R6]
                INC     R6
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                STOR    M[R1], R3
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7


geracacto:      
                
                MVI     R1, CATO_MAX_ALTURA       ;altura do cato
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
                
                
                
                JMP     R7
                
bit:            MVI     R5, b400h
                XOR     R2, R2, R5
                BR      geracacto2
                
valor0:         MOV     R3, R0

                JMP     R7                


;==============================================================
; Representa o chão do Mapa no Terminal com '*'
; 
;==============================================================

desenhaMapa:    MVI     R1, MAP_DIM
                DEC     R1
                MVI     R2, TERM_CURSOR
                MVI     R3, 11264       ; linha 44 coluna 0
                STOR    M[R2], R3
                MVI     R2, TERM_WRITE
                MVI     R3, '*'
                
floorprinter:   STOR    M[R2], R3
                DEC     R1
                CMP     R1, R0
                BR.NZ   floorprinter
                
                JMP     R7

;==============================================================
; Atualiza a posição do Dino, consoante o estado em que está (se estiver)
; no salto.
;==============================================================
atualizaDino:   MVI     R1, 1
                MVI     R2, JUMPstate
                LOAD    R2, M[R2]
                CMP     R1,R2
                BR.NZ   fimsalto ; se não estiver a Saltar, avança.
                
                MVI     R1, dinoLastCursor
                LOAD    R1, M[R1]
                MVI     R2, TERM_CURSOR
                STOR    M[R2], R1
                MVI     R1, ' '
                MVI     R2, TERM_WRITE
                STOR    M[R2], R1
                
                MVI     R1, FlagDescida
                LOAD    R1, M[R1]
                CMP     R1, R0
                BR.P    desce
                
                MVI     R1, JUMPaltura
                LOAD    R1, M[R1]
                MVI     R2, SALTO_MAX               ; altura maxima do salto
                CMP     R2, R1
                BR.Z    desce
                BR.P    sobe
                
                
                
desce:          MVI     R3, FlagDescida
                MVI     R4, 1
                STOR    M[R3], R4
                MVI     R1, JUMPaltura
                LOAD    R1, M[R1]
                DEC     R1
                DEC     R1
                MVI     R2, JUMPaltura
                STOR    M[R2],R1
                BR      fimsalto
                
sobe:           MVI     R1, JUMPaltura
                LOAD    R1, M[R1]
                INC     R1
                INC     R1
                MVI     R2, JUMPaltura
                STOR    M[R2],R1
                BR      fimsalto
                
                
                
fimsalto:       
                DEC     R6
                STOR    M[R6],R7
                JAL     desenhaDino
                LOAD    R7, M[R6]
                INC     R6
                JMP     R7

;============================================================
; A função abaixo trata de representar o Dino na nova
; posição.
;============================================================
desenhaDino:    
                MVI     R1, 11048
                MVI     R2, JUMPaltura
                LOAD    R2, M[R2]
                CMP     R2, R0
                BR.P    setAltura
                
                MVI     R3, JUMPstate ;se estava em salto e altura for 0
                LOAD    R3, M[R3]
                CMP     R3, R0
                BR.Z    setAltura
                
                
                MVI     R3, 0
                MVI     R4, FlagDescida
                STOR    M[R4], R3
                MVI     R4, JUMPstate
                STOR    M[R4], R3
                
setAltura:      MVI     R2, JUMPaltura
                LOAD    R2, M[R2]
loopi:          CMP     R2,R0
                BR.Z    pintaDino
                MVI     R3, 512          ; cada mudança de altura = 2 linhas
                SUB     R1, R1, R3
                DEC     R2
                DEC     R2
                BR      loopi
                
pintaDino:      MVI     R2, TERM_CURSOR
                STOR    M[R2], R1
                MVI     R2, dinoLastCursor
                STOR    M[R2], R1
                MVI     R1, TERM_WRITE
                MVI     R2, 'D'
                STOR    M[R1], R2
                JMP     R7
                
;===============================================================
; A função abaixo limpa a tabela dos Catos e o Terminal do jogo
;
;===============================================================
ClearPreviousMap:
                
                ;reinicia o valor das variaveis do programa
                MVI     R1, Centenas
                STOR    M[R1], R0
                MVI     R1, Milhares
                STOR    M[R1], R0
                MVI     R1, DezMilhares
                STOR    M[R1], R0
                MVI     R1, JUMPstate
                STOR    M[R1], R0
                MVI     R1, JUMPaltura
                STOR    M[R1], R0
                MVI     R1, dinoLastCursor
                STOR    M[R1], R0
                MVI     R1, FlagDescida
                STOR    M[R1], R0
                
                ;reinicia o score
                MVI     R1, DISP7SEG_2
                STOR    M[R1], R0
                MVI     R1, DISP7SEG_3
                STOR    M[R1], R0
                MVI     R1, DISP7SEG_4
                STOR    M[R1], R0
                ;limpa a tabela dos catos
                MVI     R1, MAPA
                MVI     R2, MAP_DIM
                
clearMAPA:      STOR    M[R1], R0
                DEC     R2
                INC     R1
                CMP     R2, R0
                BR.P    clearMAPA
                
                ;limpa o Terminal
                MVI     R1, TERM_CURSOR
                STOR    M[R1], R0
                MVI     R2, 3600
clearTerminal:  MVI     R1, TERM_WRITE
                MVI     R3, ' '
                STOR    M[R1], R3
                DEC     R2
                CMP     R2, R0
                BR.P    clearTerminal
                JMP     R7
                
                


;==============================================================
; Atualiza a pontuação do jogador
; 
;==============================================================
Pontuacao:      DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                DEC     R6
                STOR    M[R6], R3
                
                MVI     R1, Centenas
                MVI     R2, 9
                LOAD    R3, M[R1]
                CMP     R2, R3
                BR.Z    P_Milhares
                INC     R3
                STOR    M[R1], R3
                MVI     R1, DISP7SEG_2
                STOR    M[R1], R3
                
                BR      Fim_Pontos
                
P_Milhares:     STOR    M[R1], R0
                MVI     R1, DISP7SEG_2
                STOR    M[R1], R0
                
                MVI     R1, Milhares
                MVI     R2, 9
                LOAD    R3, M[R1]
                CMP     R2, R3
                BR.Z    P_DezMilhares
                
                INC     R3
                STOR    M[R1], R3
                MVI     R1, DISP7SEG_3
                STOR    M[R1], R3
                
                BR      Fim_Pontos
                
P_DezMilhares:  STOR    M[R1], R0
                MVI     R1, DISP7SEG_3
                STOR    M[R1], R0               

                MVI     R1, DezMilhares
                LOAD    R3, M[R1]
                INC     R3
                MVI     R1, DISP7SEG_4
                STOR    M[R1], R3
                
Fim_Pontos:     LOAD    R3, M[R6]
                INC     R6
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                JMP     R7

;==============================================================
; Inicializa o temporizador.
; 
;==============================================================
INIT_TIMER:     DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R1, TIMER_VALUE
                MVI     R2, 12      ;1seg e 2 décimas de segundo
                STOR    M[R1], R2
                MVI     R1, TIMER_CONTROL
                MVI     R2, 1
                STOR    M[R1], R2
                
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                JMP     R7
                
                
                ; Button 0
                ORIG    7F00h
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                MVI     R1, RESTART
                MVI     R2, 1
                STOR    M[R1], R2
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                RTI
                
                
                ; Keyboard interruption (to jump)
                ORIG    7F70h
                
                
                DEC     R6
                STOR    M[R6], R1
                DEC     R6
                STOR    M[R6], R2
                
                MVI     R1, TERM_READ
                LOAD    R2, M[R1]
                MVI     R1, 24
                CMP     R1, R2
                BR.NZ   Ignoratecla
                
                
                MVI     R1, JUMPstate
                MVI     R2, 1
                STOR    M[R1], R2
                
Ignoratecla:                 
                LOAD    R2, M[R6]
                INC     R6
                LOAD    R1, M[R6]
                INC     R6
                RTI
                
                ;timer interruption (to increase pontuation each second)
                ORIG    7FF0h
                DEC     R6
                STOR    M[R6], R7
                JAL     Pontuacao
                JAL     INIT_TIMER
                LOAD    R7, M[R6]
                INC     R6
                RTI
    
