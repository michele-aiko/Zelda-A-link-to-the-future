.data
CHAR_POS: 	.half 0,192
OLD_CHAR_POS: 	.half 0,0
SWORD_ACTIVE: 	.word 1		#flag da espada
SWORD_POS:	.half 32,192
SHIELD_ACTIVE:	.word 0
GAME_STATE:	.word 0		#flag do estado do jogo
ITEM_TIMER:	.word 0		#tempo que a pose de pegar item vai ficar
COIN_COUNT:	.word 0

#ANIMAÇÃO#
PLAYER_DIR:	.word 3		#0 cima 1 esq 2 baixo 3 dir
PLAYER_MOVING:	.word 0
ANIM_FRAME:	.word 0
ANIM_TIMER:	.word 0
#CIMA#
char_u0:
	.include "D0.data"
char_u1:
	.include "D1.data"
char_u2:
	.include "D2.data"
char_u3:
	.include "D3.data"
#ESQUERDA#
char_l0:
	.include "E0.data"
char_l1:
	.include "E1.data"
char_l2:
	.include "E2.data"
char_l3:
	.include "E3.data"
#BAIXO#
#char_d0:
#	.include "D0.data"
#char_d1:
#	.include "D1.data"
#char_d2:
#	.include "D2.data"
#char_d3:
#	.include "D3.data"
#DIREITA#
#char_r0:
#	.include "D0.data"
#char_r1:
#	.include "D1.data"
#char_r2:
#	.include "D2.data"
#char_r3:
#	.include "D3.data"
#PONTEIROS_POSIÇÃO#
CHAR_SPRITES_PTR:
	.word char_u0, char_u1, char_u2, char_u3
	.word char_l0, char_l1, char_l2, char_l3
	.word char_u0, char_u1, char_u2, char_u3
	.word char_u0, char_u1, char_u2, char_u3
	

#VIDA/DANO#
HEALTH_PLAYER: 	.word 3		#3 de vida inicial
MAX_HEALTH:	.word 3
INV_TIMER: 	.word 0		#tempo de invencibilidade

PLAYER_ATT:	.word 0		#0= n atacando 1= atacando
ATT_TIMER:	.word 0		#frames do ataque

MAP_WIDTH: 	.word 20	#largura do mapa em blocos

#Dados dos Inimigos
#DRONE#
DRONE_POS:	.half 288,160	#posicao inicial drone
DRONE_VEL:	.word 4		#velocidade no eixo Y
DRONE_FLAG:	.word 1		#1=vivo 0=morto
#TURRET#
TURRET_POS:	.half 288,64 	#posicao turret
TURRET_FLAG:	.word 1		#1=vivo 0=morto
TURRET_CD:	.word 0
BULLET_POS:	.half 0,0	#posicao atual da bala
BULLET_ACTIVE:	.word 0		#0=comecando a atirar 1=viajando
BULLET_SPEED:	.word 10		#velocidade do tiro

#Controle de Níveis
CURRENT_LEVEL:       .word 1	#nivel atual
LAST_LEVEL:	     .word 1
TARGET_LEVEL:	     .word 1
CURRENT_MAP_BG_PTR:  .word 0	#ponteiro para o background atual
CURRENT_MAP_COL_PTR: .word 0	#ponteiro para o mapa de colisao
TRANSITION_TIMER:    .word 0	#tempo de transição de tela
PUZZLE_STATE:	     .word 0

#Endereços			#lista de endereços dos backgrounds
LEVEL_BG_LIST:
    .word map1_data, map2_data, map3_data, map4_data

LEVEL_COL_LIST:			#lista de endereços dos mapas de colisão
    .word col_map1, col_map2, col_map3, col_map4
#Mapas
map1_data:
    .include "map1.data"
col_map1:
    .include "collision_map.data"

map2_data:
    .include "map2.data"
col_map2:
    .include "collision_map2.data"
map3_data:
    .include "map3.data"
col_map3:
    .include "collision_map3.data"
map4_data:
    .include "map4.data"
col_map4:
    .include "collision_map4.data"
    
NUM_0: 
.include "num0.data"
NUM_1: 
.include "num1.data"
NUM_2: 
.include "num2.data"
NUM_3: 
.include "num3.data"
NUM_4: 
.include "num4.data"
NUM_5: 
.include "num5.data"
NUM_6: 
.include "num6.data"
NUM_7: 
.include "num7.data"
NUM_8: 
.include "num8.data"
NUM_9: 
.include "num9.data"   

NUMBER_SPRITES:
	.word NUM_0,NUM_1,NUM_2,NUM_3,NUM_4,NUM_5,NUM_6,NUM_7,NUM_8,NUM_9 

.text
SETUP:
		call LOAD_LEVEL		#carrega os ponteiros dos mapas
		
	
		
GAME_LOOP:	la t0,GAME_STATE	#carrega o estado do jogo
		lw t1,0(t0)
		
		beqz t1,STATE_PLAYING	#se for 0 quer dizer que esta jogando
		li t2,1
		beq t1,t2,STATE_ITEM_COLLECTED		#se for 1 esta pegando item
		
		li t2,3			#estado 3=transição de nivel
		beq t1,t2,STATE_TRANSITION_SCREEN
		
		j END_FRAME_PROCESSING
		
STATE_PLAYING:	
		la t0,INV_TIMER		#carregando tempo de invencibilidade
		lw t1,0(t0)		
		beqz t1,SKIP_INV_DECREMENT	#se for 0 n ta mais invencivel
		addi t1,t1,-1		#decrementando tempo
		sw t1,0(t0)
SKIP_INV_DECREMENT:

		la t0,ATT_TIMER			#carrega timer de ataque
		lw t1,0(t0)
		beqz t1,SKIP_ATT_DECREMENT	#se for 0 n faz nada
		
		addi t1,t1,-1			#decrementa tempo
		sw t1,0(t0)
		
		beqz t1,END_ATT_ANIMATION	#se for 0 termina o aaque
		j SKIP_ATT_DECREMENT		
		
END_ATT_ANIMATION:
		la t0,PLAYER_ATT		#fim do ataque
		sw zero,0(t0)
		
SKIP_ATT_DECREMENT:

		call CHECK_ATT_COLLISION		#verifica se o ataque ta pegando na hitbox
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,3
		beq t1,t2,DRAW_SHOP_BG			#se for nivel 3 desenho eh diferente pq eh loja
		
		li t2,4
		beq t1,t2,DRAW_FINAL_BG
		
		la a0,CURRENT_MAP_BG_PTR		#carregando o mapa para printar
		lw a0,0(a0)
		li a1,0
		li a2,0
		mv a3,s0
		call PRINT
		j END_DRAW_BG
DRAW_SHOP_BG:
		call DRAW_BLACK_SCREEN
		la a0,CURRENT_MAP_BG_PTR
		lw a0,0(a0)
		li a1,160
		li a2,128
		mv a3,s0
		call PRINT
		j END_DRAW_BG


DRAW_FINAL_BG:
		la a0,CURRENT_MAP_BG_PTR
		lw a0,0(a0)
		li a1,96
		li a2,32
		mv a3,s0
		call PRINT_FINAL_LEVEL
		
		la a0,puzzle
		li a1,252
		li a2,272
		mv a3,s0
		call PRINT
		j END_DRAW_BG
PRINT_FINAL_LEVEL:
		li t0,0xFF0
		add t0,t0,a3
		slli t0,t0,20
		add t0,t0,a1
		li t1,640
		mul t1,t1,a2
		add t0,t0,t1
		
		addi t1,a0,8
		
		li t4,112
		li t5,352
		li t2,0
LOOP_FINAL_Y:
		li t3,0
LOOP_FINAL_X:
		lw t6,0(t1)
		sw t6,0(t0)
		
		addi t0,t0,4
		addi t1,t1,4
		addi t3,t3,1
		blt t3,t4,LOOP_FINAL_X
		
		addi t0,t0,640
		addi t0,t0,-448
		addi t2,t2,1
		blt t2,t5,LOOP_FINAL_Y
		ret
END_DRAW_BG:
		
		call DRAW_SCENARIO
		
		call KEY2
		call UPDATE_DRONE
		call UPDATE_TURRET
		call CHECK_DRONE_COLLISION
		call CHECK_BULLET_COLLISION
		call CHECK_INTERACTION
		
		call DRAW_FULL_HUD

		
		
		la t0,SWORD_ACTIVE	#carregando flag
		lw t1,0(t0)
		beqz t1,SKIP_SWORD_DRAW
		
		
		la t0,SWORD_POS		#carregando posicao da espada
		la a0,sword		#para printar espada
		lh a1,0(t0)		#carregando x da espada
		lh a2,2(t0)		#carregando y da espada
		mv a3,s0
		call PRINT
		
SKIP_SWORD_DRAW:

		la t0,DRONE_FLAG
		lw t1,0(t0)
		beqz t1,SKIP_DRONE_DRAW
		
		la t0,DRONE_VEL
		lw t1,0(t0)
		bgez t1,USE_DRONE_RIGHT
		
USE_DRONE_LEFT:	
		la a0,drone1
		j DRAW_DRONE_FINAL
USE_DRONE_RIGHT:
		la a0 drone2
		
DRAW_DRONE_FINAL:
		la t0,DRONE_POS
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
SKIP_DRONE_DRAW:
		call DRAW_PLAYER
		j SKIP_CHAR_DRAW
		
CHECK_BLINK:
		andi t2,t1,8		#alterna frames pra ele piscar, isola o 4º bit
		beqz t2,DRAW_INVINCIBLE #toda vez q o bit for zero printa
		j SKIP_CHAR_DRAW
		
DRAW_INVINCIBLE:
		la t0,CHAR_POS		#printando invencivel piscando
		la a0,char
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		j SKIP_CHAR_DRAW
		
DRAW_ATT:	la t0,CHAR_POS		#carrega posição pra atacar
		la a0,teste		#substituir aqui pela sprite de ataque
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		j SKIP_CHAR_DRAW
		
		
SKIP_CHAR_DRAW:
		la t0,SWORD_ACTIVE
		lw t1,0(t0)
		beqz t1,SKIP_COLLISION
		
		la t0,CHAR_POS		#posicao personagem pra comparar
		lh t1,0(t0)
		lh t2,2(t0)
		
		la t3,SWORD_POS		#posicao espada pra comparar
		lh t4,0(t3)
		lh t5,2(t3)
		
		bne t1,t4,SKIP_SWORD	#comparando x
		bne t2,t5,SKIP_SWORD	#comparando y
		
		
		
		la t0,SWORD_ACTIVE	#se estiver na espada, flag=0
		sw zero,0(t0)
		
		la t0,GAME_STATE	
		li t1,1		
		sw t1,0(t0)		#mudando o estado para 1=pegando item
		
		la t0,ITEM_TIMER
		li t1,65		#tempo que vai ficar parado
		sw t1,0(t0)
		
		#tocando som#
		li a7,31
		li a0,74
		li a1,1000
		li a2,8
		li a3,127
		ecall
		
SKIP_COLLISION:
		j END_FRAME_PROCESSING
STATE_TRANSITION_SCREEN:
		call DRAW_BLACK_SCREEN
		
		la t0,TRANSITION_TIMER
		lw t1,0(t0)
		addi t1,t1,-1
		sw t1,0(t0)
		
		li t2,15
		bne t1,t2,SKIP_LEVEL_CHANGE_TRANSITION
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		la t0,LAST_LEVEL
		sw t1,0(t0)
		
		la t0,TARGET_LEVEL
		lw t3,0(t0)
		
		la t0,CURRENT_LEVEL
		sw t3,0(t0)
		
		#li t4,5
		#bge t3,t4,GAME_WIN_SCREEN		#implementar dps
		
		call LOAD_LEVEL
		
		
		la t0,CHAR_POS
		li t3,0			#mudar o X aqui
		li t4,192		#mudar o Y aqui
		sh t3,0(t0)
		sh t4,2(t0)
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		
		li t2,4
		beq t1,t2,SETUP_LEVEL_4
		
		li t2,3
		beq t1,t2,SETUP_LEVEL_3
		
		#configurando inimigos por nivel#
		
		li t2,2
		beq t1,t2,SETUP_LEVEL_2
		
		la t0,DRONE_FLAG	#aq vai ser a sentinela
		li t3,1
		sw t3,0(t0)
		
		la t0,TURRET_FLAG
		sw zero,0(t0)
		
		la t0,DRONE_POS
		li t3,288
		li t4,160
		sh t3,0(t0)
		sh t4,2(t0)
		
		j SKIP_LEVEL_CHANGE_TRANSITION
		
SETUP_LEVEL_2:
		la t0,DRONE_FLAG
		li t1,1
		sw t1,0(t0)
		
		la t0,TURRET_FLAG
		li t1,1
		sw t1,0(t0)
		
		la t0,DRONE_POS
		li t3,288
		li t4,192 
		sh t3,0(t0)
		sh t4,2(t0)
		
		la t0,TURRET_POS
		li t3,288
		li t4,64
		sh t3,0(t0)
		sh t4,2(t0)
		
		la t0,LAST_LEVEL
		lw t1,0(t0)
		li t2,3
		beq t1,t2,SPAWN_LADDER
		
		la t0,CHAR_POS
		li t3,32
		li t4,192
		sh t3,0(t0)
		sh t4,2(t0)
		j SKIP_LEVEL_CHANGE_TRANSITION
SPAWN_LADDER:
		la t0,CHAR_POS
		li t3,192
		li t4,64
		sh t3,0(t0)
		sh t4,2(t0)
		
		j SKIP_LEVEL_CHANGE_TRANSITION
SETUP_LEVEL_3:
		la t0,DRONE_FLAG
		sw zero,0(t0)
		la t0,TURRET_FLAG
		sw zero,0(t0)
		la t0,BULLET_ACTIVE
		sw zero,0(t0)
		
		la t0,CHAR_POS
		li t3,192
		li t4,320
		sh t3,0(t0)
		sh t4,2(t0)
		
		j SKIP_LEVEL_CHANGE_TRANSITION
		
SETUP_LEVEL_4:
		la t0,DRONE_FLAG
		sw zero,0(t0)
		la t0,TURRET_FLAG
		sw zero,0(t0)
		la t0,BULLET_ACTIVE
		sw zero,0(t0)
		
		la t0,CHAR_POS
		li t3,384
		li t4,352
		sh t3,0(t0)
		sh t4,2(t0)
		
		j SKIP_LEVEL_CHANGE_TRANSITION
		
SKIP_LEVEL_CHANGE_TRANSITION:
		bnez t1,END_FRAME_PROCESSING
		la t0,GAME_STATE
		sw zero,0(t0)
		j END_FRAME_PROCESSING
		
STATE_ITEM_COLLECTED:
		la a0,CURRENT_MAP_BG_PTR		#carregando o mapa para printar
		lw a0,0(a0)
		li a1,0
		li a2,0
		mv a3,s0
		call PRINT
		
		call DRAW_SCENARIO			#redesenha as coisas paradas
		
		la t0,DRONE_FLAG
		lw t1,0(t0)
		beqz t1,SKIP_DRONE_POSE
		
		la t0,DRONE_POS
		la a0,drone2
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
		
SKIP_DRONE_POSE:
	
		la t0,ITEM_TIMER	#carregando tempo de coleta do item
		lw t1,0(t0)
		addi t1,t1,-1
		sw t1,0(t0)
		
		beqz t1,END_ITEM_COLLECTED 	#se for zero acabou o tempo
		
		la t0,CHAR_POS		#printa a posição de pegar item
		la a0,char		#aq vai mudar a imagem pra char_item ou algo assim
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
		j END_FRAME_PROCESSING
		
END_ITEM_COLLECTED:
		la t0,GAME_STATE
		sw zero,0(t0)
		j END_FRAME_PROCESSING
		
		
SKIP_SWORD:


END_FRAME_PROCESSING:
			
		li t0,0xFF200604	#procedimento de inverter o frame to bitmap
		sw s0,0(t0)
		
		xori s0,s0,1		#invertendo o frame dnv	
		
		li a7,32		#carregando som
		li a0,33
		ecall
		
		j GAME_LOOP
		
KEY2:		li t1,0xFF200000	# carrega o endereço de controle do KDMMIO
		lw t0,0(t1)		# Le bit de Controle Teclado
		andi t0,t0,0x0001	# mascara o bit menos significativo
	   	beq t0,zero,FIM   	# Se não há tecla pressionada então vai para FIM
	  	lw t2,4(t1)  		# le o valor da tecla tecla
		
		li t0,'w'
		beq t2,t0,CHAR_CIMA	#se pressionar w
		
		li t0,'a'
		beq t2,t0,CHAR_ESQ	#se pressionar a
		
		li t0,'s'
		beq t2,t0,CHAR_BAIXO	#se pressionar s
		
		li t0,'d'
		beq t2,t0,CHAR_DIR	#se pressionar d
		
		li t0,' '
		beq t2,t0,PLAYER_ATTACK
		
		
		
		
FIM:		ret

PLAYER_ATTACK:
		la t0,PLAYER_ATT	#carrega flag
		lw t1,0(t0)
		bnez t1,FIM_PLAYER_ATTACK	#se for 1 ja ta atacando
		
		li t1,1			#muda flag pra 1 pra atacar
		sw t1,0(t0)
		
		li t1,10		#10 frames de ataque
		la t0,ATT_TIMER
		sw t1,0(t0)
		
		li a7, 31       
		li a0, 45       
		li a1, 80       
		li a2, 0        
		li a3, 127      
		ecall
		
FIM_PLAYER_ATTACK:
		ret
		
		

CHECK_DRONE_COLLISION:
		la t0,DRONE_FLAG	#carregando flag do drone
		lw t1,0(t0)
		beqz t1,FIM_COL_DRONE	#se for 0 n tem drone
		
		la t0,CHAR_POS		#carregando posicao do personagem pra comparar
		lh t1,0(t0)
		lh t2,2(t0)
		
		la t0,DRONE_POS		#carregando posicao do drone pra comparar
		lh t3,0(t0)
		lh t4,2(t0)
		
		#calculando distancia entre o drone e o personagem
		sub t5,t1,t3
		bgez t5,SKIP_NEG_X
		neg t5,t5		#inverte se for negativo
		
SKIP_NEG_X:	li t6,24		#24=limite de colisao
		bge t5,t6,FIM_COL_DRONE #se for maior que 24 n colidiu x
		
		sub t5,t2,t4
		bgez t5,SKIP_NEG_Y
		neg t5,t5
		
SKIP_NEG_Y:	bge t5,t6,FIM_COL_DRONE #se for maior que 24 n colidiu y
		j TAKE_DAMAGE

FIM_COL_DRONE:	ret

UPDATE_TURRET:	
		addi sp,sp,-4
		sw ra,0(sp)
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,2
		bne t1,t2,FIM_TURRET_FUNC
		
		la t0,TURRET_CD
		lw t1,0(t0)
		beqz t1,CHECK_TURRET_ALIVE
		addi t1,t1,-1
		sw t1,0(t0)
		
CHECK_TURRET_ALIVE:
		la t0,TURRET_FLAG	#verifica se ta viva ainda
		lw t1,0(t0)
		beqz t1,UPDATE_BULLET_ONLY
		
		la t0,TURRET_POS
		la a0,char		#trocar a sprite############################
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
		la t0,BULLET_ACTIVE
		lw t1,0(t0)
		bnez t1,MOVE_BULLET	#se for 1 a bala ta viajando
		
		la t0,TURRET_CD
		lw t1,0(t0)
		bnez t1,FIM_TURRET_FUNC
		
		la t0,BULLET_ACTIVE
		li t1,1			#se chegou aq comeca a atirar
		sw t1,0(t0)
		
		la t0,TURRET_CD
		li t1,20
		sw t1,0(t0)
		
		la t0,TURRET_POS	#carregando bala na posicao da turret
		lh t2,0(t0)
		lh t3,2(t0)
		
		addi t2,t2,12		#fazendo sair da frente da turret
		addi t3,t3,32
		
		la t0,BULLET_POS
		sh t2,0(t0)
		sh t3,2(t0)
		
		j DRAW_BULLET
MOVE_BULLET:
		la t0,BULLET_POS
		lh t2,0(t0)
		lh t3,2(t0)
		
		la t4,BULLET_SPEED	#incrementando a speed na posicao da bala
		lw t4,0(t4)
		add t3,t3,t4
		sh t3,2(t0)
		
		li t5,384		#limite
		bge t3,t5,RESET_BULLET
		
		#verificar colisao aqui##############
		
		j DRAW_BULLET
		
RESET_BULLET:
		la t0,BULLET_ACTIVE
		sw zero,0(t0)
		j FIM_TURRET_FUNC
DRAW_BULLET:
		la t0,BULLET_POS
		la a0,bullet		#mudar sprite de tiro#######################
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		j FIM_TURRET_FUNC
UPDATE_BULLET_ONLY:
		j FIM_TURRET_FUNC
FIM_TURRET_FUNC:
	lw ra,0(sp)
	addi sp,sp,4
	ret
CHECK_BULLET_COLLISION:
		la t0,BULLET_ACTIVE
		lw t1,0(t0)
		beqz t1,FIM_COL_BULLET	#se n tem bala n tem dano
		
		la t0,BULLET_POS	
		lh t1,0(t0)		#x bala
		lh t2,2(t0)		#y bala
		
		la t0,CHAR_POS		
		lh t3,0(t0)		#x player
		lh t4,2(t0)		#y player
		
		sub t5,t1,t3
		bgez t5,POS_X_B
		neg t5,t5
POS_X_B:
		li t6,20		#hitbox
		bge t5,t6,FIM_COL_BULLET
		
		sub t5,t2,t4
		bgez t5,POS_Y_B
		neg t5,t5
POS_Y_B:
		li t6,20		#hitbox
		bge t5,t6,FIM_COL_BULLET
		
		#se chegou aqui acertou o player#
		la t0,BULLET_ACTIVE
		sw zero,0(t0)
		
		la t0,SHIELD_ACTIVE
		lw t1,0(t0)
		bnez t1,SHIELD_BLOCK
		
		la t0,HEALTH_PLAYER
		sw zero,0(t0)
		j GAME_OVER
		
SHIELD_BLOCK:
		# Som de defesa (Metal)
        	li a7, 31
        	li a0, 56           # Instrumento (Trumpet/Metal)
        	li a1, 300          # Duração
        	li a2, 0
        	li a3, 127
        	ecall
        	
        	ret
FIM_COL_BULLET:
		ret

UPDATE_DRONE:	la t0,DRONE_FLAG	#carrega flag
		lw t1,0(t0)
		beqz t1,FIM_DRONE	#se for 0 ta morto
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,2
		beq t1,t2,MOVIMENTO_HORIZONTAL

MOVIMENTO_VERTICAL:		
		la t0,DRONE_POS		#carrega posicao
		lh t1,2(t0)
		
		la t2,DRONE_VEL		#carrega velocidade de movimento
		lw t3,0(t2)
		
		add t1,t1,t3		#incrementa velocidade na posicao
		sh t1,2(t0)
		
		li t4,352		#limite inferior
		bge t1,t4,INVERTE_VELOCIDADE
		
		li t5,32		#limite superior
		ble t1,t5,INVERTE_VELOCIDADE 
		
		ret
		
MOVIMENTO_HORIZONTAL:
		la t0,DRONE_POS
		lh t1,0(t0)
		
		
		la t2,DRONE_VEL
		lw t3,0(t2)
		
		add t1,t1,t3
		sh t1,0(t0)
		
		li t4,320		#limite horizontal
		bge t1,t4,INVERTE_VELOCIDADE
		li t5,192
		ble t1,t5,INVERTE_VELOCIDADE
		
		ret
INVERTE_VELOCIDADE:
		neg t3,t3		#t3=-t3 -> inverte
		sw t3,0(t2)
		ret	
		
FIM_DRONE:	ret

CHAR_CIMA:	
		addi sp,sp,-4
		sw ra,0(sp)
		
		li a0,0
		call UPDATE_STEP_ANIM
		
		la t0,CHAR_POS
		lh t1,0(t0)
		lh t2,2(t0)
		
		addi t3,t2,-32
		
		mv a1,t1
		mv a2,t3
		
		addi sp, sp, -16
    		sw t0, 0(sp)
  		sw t1, 4(sp)
  		sw t2, 8(sp)
    		sw t3, 12(sp)
    		
    		call IS_POSITION_SOLID
    		
    		lw t3, 12(sp)
		lw t2, 8(sp)
		lw t1, 4(sp)
		lw t0, 0(sp)
		addi sp, sp, 16
		
		bnez a0,BLOQUEADO_CIMA
		
		sh t3,2(t0)
		
BLOQUEADO_CIMA: lw ra,0(sp)
		addi sp,sp,4
		ret

CHAR_ESQ:
		addi sp,sp,-4
		sw ra,0(sp)
		
		li a0,1
		call UPDATE_STEP_ANIM
		
		la t0,CHAR_POS
		lh t1,0(t0)
		lh t2,2(t0)
		
		addi t3,t1,-32
		
		mv a1,t3
		mv a2,t2
		
		addi sp, sp, -16
    		sw t0, 0(sp)
  		sw t1, 4(sp)
  		sw t2, 8(sp)
    		sw t3, 12(sp)
    		
    		call IS_POSITION_SOLID
    		
    		lw t3, 12(sp)
		lw t2, 8(sp)
		lw t1, 4(sp)
		lw t0, 0(sp)
		addi sp, sp, 16
		
		bnez a0,BLOQUEADO_ESQ
		
		sh t3,0(t0)
		
BLOQUEADO_ESQ:	lw ra,0(sp)
		addi sp,sp,4
		ret
		
CHAR_BAIXO:	
		addi sp,sp,-4
		sw ra,0(sp)
		
		li a0,2
		call UPDATE_STEP_ANIM
		
		la t0,CHAR_POS
		lh t1,0(t0)
		lh t2,2(t0)
		
		addi t3,t2,32
		
		mv a1,t1
		mv a2,t3
		
		addi sp, sp, -16
    		sw t0, 0(sp)
  		sw t1, 4(sp)
  		sw t2, 8(sp)
    		sw t3, 12(sp)
    		
    		call IS_POSITION_SOLID
    		
    		lw t3, 12(sp)
		lw t2, 8(sp)
		lw t1, 4(sp)
		lw t0, 0(sp)
		addi sp, sp, 16
		
		bnez a0,BLOQUEADO_BAIXO
		
		sh t3,2(t0)
		
BLOQUEADO_BAIXO:lw ra,0(sp)
		addi sp,sp,4
		ret
		
		
CHAR_DIR:	
		addi sp,sp,-4
		sw ra,0(sp)
		
		li a0,3
		call UPDATE_STEP_ANIM
		
		la t0,CHAR_POS
		
		lh t1,0(t0)
		lh t2,2(t0)
		
		addi t3,t1,32
		
		mv a1,t3
		mv a2,t2
		
		addi sp, sp, -16
    		sw t0, 0(sp)
  		sw t1, 4(sp)
  		sw t2, 8(sp)
    		sw t3, 12(sp)
    		
    		call IS_POSITION_SOLID
    		
    		lw t3, 12(sp)
		lw t2, 8(sp)
		lw t1, 4(sp)
		lw t0, 0(sp)
		addi sp, sp, 16
		
		bnez a0,BLOQUEADO_DIR
		
		sh t3,0(t0)
		
BLOQUEADO_DIR:	lw ra,0(sp)
		addi sp,sp,4
		ret
		
FIM_MOVIMENTO:	ret
		

#	a0 = endereco imagem
#	a1 = x
#	a2 =y
#	a3 = frame
##
#	t0 = endereco bitmap
#	t1 = endereco imagem
#	t2 = cont linha
#	t3 = cont coluna
#	t4 = largura
#	t5 = altura

PRINT:		li t0,0xFF0 		#adicionando o endereco do bitmap
		add t0,t0,a3		#decidindo se vai ser frame 0 ou 1 
		slli t0,t0,20		#deslocando 4 bytes pra esquerda pra setar o endereco do bitmap
		
		add t0,t0,a1		#adicionando x (coluna) no endereco
		
		li t1,640
		mul t1,t1,a2		#~linha (y) = linha*320~
		add t0,t0,t1		#adicionando y (linha) no endereco ~linha=linha*320~ / Agora temos o endereco inicial
		
		addi t1,a0,8		#skipando os valores de altura e largura da imagem
		
		mv t2,zero		#zerando contadores
		mv t3,zero
		
		lw t4,0(a0)		#carregando valor de altura e largura nos registradores
		lw t5,4(a0)
		
		
PRINT_LINHA:	lw t6,0(t1)		#carregando o byte inicial dps das 2 words
		sw t6,0(t0)		#salvando no bitmap
		
		addi t0,t0,4		#incrementando de 4 em 4
		addi t1,t1,4
		
		addi t3,t3,4		#incementando cont coluna
		blt t3,t4,PRINT_LINHA	#enquanto o cont coluna for menor q a largura, continua printando
		
		addi t0,t0,640		#pula uma linha
		sub t0,t0,t4		#volta pra coluna 1 (subtrai sua largura)
		
		mv t3,zero		#zera o cont coluna
		addi t2,t2,1		#incrementa cont linha
		
		blt t2,t5,PRINT_LINHA	#para se cont linha for maior ou igual a altura
		
		ret
		
CHECK_ATT_COLLISION:
		la t0,PLAYER_ATT	#flag de ataque
		lw t1,0(t0)
		beqz t1, FIM_ATT_COLLISION
		
		la t0,CHAR_POS		#posicao personagem
		lh t1,0(t0)
		lh t2,2(t0)
		
		la t0,DRONE_FLAG
		lw t3,0(t0)
		beqz t3,CHECK_TURRET_HIT
	
		la t0,DRONE_POS		#posicao drone
		lh t3,0(t0)
		lh t4,2(t0)
		
		sub t5,t1,t3
		bgez t5,SKIP_NEG_X_ATT
		neg t5,t5
SKIP_NEG_X_ATT:
		li t6,40		#se a distancia for 40 ou menos ataca
		bge t5,t6,CHECK_TURRET_HIT
		
		sub t5,t2,t4
		bgez t5,SKIP_NEG_Y_ATT
		neg t5,t5
SKIP_NEG_Y_ATT:
		bge t5,t6,CHECK_TURRET_HIT
		
		la t0,DRONE_FLAG
		sw zero,0(t0)
		
		##adicionar efeito visual,etc##
		
CHECK_TURRET_HIT:
		la t0,CURRENT_LEVEL
		lw t3,0(t0)
		li t4,2
		bne t3,t4,FIM_ATT_COLLISION
	
		la t0,TURRET_FLAG
		lw t3,0(t0)
		beqz t3,FIM_ATT_COLLISION
		
		la t0,SHIELD_ACTIVE
		lw t3,0(t0)
		beqz t3,FIM_ATT_COLLISION
	
		la t0,TURRET_POS
		lh t3,0(t0)
		lh t4,2(t0)
	
		sub t5,t1,t3
		bgez t5,SKIP_NEG_X_TURRET
		neg t5,t5
SKIP_NEG_X_TURRET:
		li t6,40
		bge t5,t6,FIM_ATT_COLLISION
		
		sub t5,t2,t4
		bgez t5,SKIP_NEG_Y_TURRET
		neg t5,t5
SKIP_NEG_Y_TURRET:
		bge t5,t6,FIM_ATT_COLLISION
		
		la t0,TURRET_FLAG
		sw zero,0(t0)
		
		
		
FIM_ATT_COLLISION:
		ret
		
DRAW_SCENARIO:				#logica de verificar no mapa de colisão se tem ou nao parede/pilar/moeda/porta
		addi sp,sp,-4
		sw ra,0(sp)
	
		la s1, CURRENT_MAP_COL_PTR
		lw s1,0(s1)
		li s2,0
		li s3,0
		li s4,13
		li s5,20
	
LOOP_Y_SCENARIO:
		bge s2,s4, FIM_DRAW_SCENARIO
		li s3,0
LOOP_X_SCENARIO:
		bge s3,s5,NEXT_LINE_SCENARIO
		
		lb t0,0(s1)
		beqz t0,SKIP_DRAW_TILE
		
		li t1,1
		beq t0,t1,PREP_PILAR
		li t2,2
		beq t0,t2,PREP_COIN
		li t3,3
		beq t0,t3,PREP_DOOR
		li t4,6
		beq t0,t4,PREP_LADDER
		li t4,7
		beq t0,t4,PREP_HEART
		li t4,8
		beq t0,t4,PREP_SHIELD
		li t4,9
		beq t0,t4,PREP_MERCHANT
		li t4,10
		beq t0,t4,PREP_BUTTON
		li t4,5
		beq t0,t4,PREP_HIDDEN_DOOR
		j SKIP_DRAW_TILE
		
PREP_PILAR:#1
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,1
		beq t1,t2,DRAW_PILAR_1
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,2
		beq t1,t2,DRAW_PILAR_2
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,4
		beq t1,t2,DRAW_PILAR_4
		
DRAW_PILAR_1:
		la a0,pilar1
		j DRAW_TILE_NOW
DRAW_PILAR_2:
		la a0,pilar2
		j DRAW_TILE_NOW
DRAW_PILAR_4:
		la a0,pilar4
		j DRAW_TILE_NOW
PREP_COIN:#2
		la a0,rupee
		j DRAW_TILE_NOW
PREP_DOOR:#3
		la a0,porta
		j DRAW_TILE_NOW
PREP_LADDER:#4	
		la a0,porta 		#mudar aqui o sprite pra escada
		j DRAW_TILE_NOW
PREP_HEART:#7	
		la a0,NUM_3
		slli a1,s3,5
		addi a1,a1,8
		slli a2,s2,5
		addi a2,a2,32
		mv a3,s0
		
		addi sp,sp,-4
		sw ra,0(sp)
		call PRINT
		lw ra,0(sp)
		addi sp,sp,4

		la a0,heart 		
		j DRAW_TILE_NOW
PREP_SHIELD:#8
		la a0,NUM_4
		slli a1,s3,5
		addi a1,a1,8
		slli a2,s2,5
		addi a2,a2,32
		mv a3,s0
		
		addi sp,sp,-4
		sw ra,0(sp)
		call PRINT
		lw ra,0(sp)
		addi sp,sp,4
		
		la a0,sword 		#mudar aqui o sprite pra escudo
		j DRAW_TILE_NOW
PREP_MERCHANT:
		la a0,char 		#mudar aqui o sprite pro vendedor
		j DRAW_TILE_NOW
		
PREP_BUTTON:
		la a0,porta		#mudar aqui o sprite pro botao
		j DRAW_TILE_NOW
PREP_HIDDEN_DOOR:
		la a0,pilar4
		j DRAW_TILE_NOW		
		
		
DRAW_TILE_NOW:				#printa o tile daquela posição
		slli a1,s3,5
		slli a2,s2,5
		mv a3,s0
		
		addi sp,sp,-20
		sw s1,0(sp)
		sw s2,4(sp)
		sw s3,8(sp)
		sw s4,12(sp)
		sw s5,16(sp)
				
		call PRINT
		
		lw s5,16(sp)
		lw s4,12(sp)
		lw s3,8(sp)
		lw s2,4(sp)
		lw s1,0(sp)
		addi sp,sp,20
SKIP_DRAW_TILE:
		addi s1,s1,1
		addi s3,s3,1
		j LOOP_X_SCENARIO
NEXT_LINE_SCENARIO:
		addi s2,s2,1
		j LOOP_Y_SCENARIO
FIM_DRAW_SCENARIO:
		lw ra,0(sp)
		addi sp,sp,4
		ret
		
IS_POSITION_SOLID:			#se for 1=pilar ou 4=parede n pode passar
		srli t1,a1,5		#converte pixel X para grid X (/32)
		srli t2,a2,5		#converte pixel Y para grid Y (/32)
		
		#calcula o indice do array no mapa
		la t3,MAP_WIDTH
		lw t3,0(t3)
		mul t2,t2,t3
		add t2,t2,t1
		
		la t3,CURRENT_MAP_COL_PTR
		lw t3,0(t3)
		add t3,t3,t2
		lb t0,0(t3)
		
		li t1,1			#pilar
		beq t0,t1, TILE_SOLIDO
		
		li t1,4			#parede
		beq t0,t1, TILE_SOLIDO
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		li t2,2
		bne t1,t2,TILE_VAZIO
		
		la t0,TURRET_FLAG
		lw t1,0(t0)
		beqz t1,TILE_VAZIO
		
		la t0,TURRET_POS
		lh t3,0(t0)
		lh t4,2(t0)
		sub t5,a1,t3
		bgez t5,CHECK_POS_X
		neg t5,t5
CHECK_POS_X:
		li t6,32
		bge t5,t6,TILE_VAZIO
		
		sub t5,a2,t4
		bgez t5,CHECK_POS_Y
		neg t5,t5
CHECK_POS_Y:
		bge t5,t6,TILE_VAZIO
		j TILE_SOLIDO
TILE_VAZIO:
		
		li a0,0			#n tem bloqueio
		ret
		
TILE_SOLIDO:
		li a0,1			#bloqueado
		ret
		
CHECK_INTERACTION:
		addi sp,sp,-4
		sw ra,0(sp)
		
		la t0,CHAR_POS
		lh t1,0(t0)
		lh t2,2(t0)
		addi t1,t1,16		#centro do personagem +16 pixels
		addi t2,t2,16
		
		srli t1,t1,5		#convertendo pro grid
		srli t2,t2,5
		
		la t3,MAP_WIDTH
		lw t3,0(t3)
		mul t2,t2,t3
		add t2,t2,t1
		la t3,CURRENT_MAP_COL_PTR
		lw t3,0(t3)
		add t3,t3,t2		#t3 é o tile que o jogador ta em cima
		
		lb t4,0(t3)		#le o valor do tile
		
		li t5,2			#2 é moeda
		beq t4,t5,INTERACT_COIN
		
		li t5,3			#3 é porta
		beq t4,t5,INTERACT_DOOR
		
		li t5,6
		beq,t4,t5,INTERACT_LADDER
		
		li t5,7
		beq t4,t5,BUY_HEART
		
		li t5,8
		beq t4,t5,BUY_SHIELD
		
		li t5,10
		beq t4,t5,CHECK_PUZZLE_SEQUENCE
		
		j FIM_INTERACTION
		
CHECK_PUZZLE_SEQUENCE:
		la t0,PUZZLE_STATE
		lw t1,0(t0)
		
		la t2,CHAR_POS
		lh t2,0(t2)
		
		li t6,250
		blt t2,t6,TRY_BTN_1
		li t6,390
		bge t2,t6,TRY_BTN_3
		
		j TRY_BTN_2
		
TRY_BTN_1:
		li t5,0
		beq t1,t5,ADVANCE_TO_1
		
		li t5,1
		beq t1,t5,FIM_INTERACTION
		
		j RESET_PUZZLE
		
ADVANCE_TO_1:
		li t1,1
		sw t1,0(t0)
		j PLAY_CLICK_SOUND
		
TRY_BTN_3:
		li t5,1
		beq t1,t5,ADVANCE_TO_2
		
		li t5,2
		beq t1,t5,FIM_INTERACTION
		
		j RESET_PUZZLE
ADVANCE_TO_2:
		li t1,2
		sw t1,0(t0)
		j PLAY_CLICK_SOUND
		
TRY_BTN_2:
		li t5,3
		beq t1,t5,FIM_INTERACTION
		
		li t5,2
		beq t1,t5,ADVANCE_TO_OPEN
		
		j RESET_PUZZLE
ADVANCE_TO_OPEN:
		li t1,3
		sw t1,0(t0)
		
		addi sp,sp,-4
		sw ra,0(sp)
		call UNLOCK_HIDDEN_DOOR
		lw ra,0(sp)
		addi sp,sp,4
		
		li a7, 31
        	li a0, 74
        	li a1, 800
        	li a2, 0
        	li a3, 100
        	ecall
		
		j FIM_INTERACTION
RESET_PUZZLE:
		beqz t1,FIM_INTERACTION
		
		la t0,PUZZLE_STATE
		sw zero,0(t0)
		
		li a7, 31           
        	li a0, 40
        	li a1, 300
        	li a2, 0
        	li a3, 100
        	ecall
        	j FIM_INTERACTION
        	
PLAY_CLICK_SOUND:
		li a7, 31
        	li a0, 65           
        	li a1, 200
        	li a2, 0
        	li a3, 100
        	ecall
        	j FIM_INTERACTION
		
		
BUY_HEART:
		la t0,MAX_HEALTH
		lw t1,0(t0)
		li t2,4
		bge t1,t2,FIM_INTERACTION
		
		la t0,COIN_COUNT
		lw t1,0(t0)
		li t2,3
		blt t1,t2,FIM_INTERACTION
		
		sub t1,t1,t2
		sw t1,0(t0)
		
		
		la t0,MAX_HEALTH
		lw t1,0(t0)
		addi t1,t1,1
		sw t1,0(t0)
		
		la t2,HEALTH_PLAYER
		sw t1,0(t2)
		
		li a7, 31
        	li a0, 83           
		li a1, 500
        	li a2, 0
        	li a3, 100
        	ecall
        	
        	sb zero,0(t3)
        	
        	j FIM_INTERACTION
        	
BUY_SHIELD:
		la t0,COIN_COUNT
		lw t1,0(t0)
		li t2,4
		blt t1,t2,FIM_INTERACTION
		
		sub t1,t1,t2
		sw t1,0(t0)
		
		la t0,SHIELD_ACTIVE
		li t1,1
		sw t1,0(t0)
		
		
		li a7, 31
        	li a0, 83           # Instrumento diferente
        	li a1, 500
        	li a2, 0
        	li a3, 100
        	ecall
        	
        	sb zero,0(t3)
        	
        	
        	
        	j FIM_INTERACTION

INTERACT_COIN:	sb zero,0(t3)
		
		la t0,COIN_COUNT
		lw t1,0(t0)
		
		li t2,9
		bge t1,t2,SKIP_INC_COIN
		
		addi t1,t1,1
		sw t1,0(t0)
SKIP_INC_COIN:
		
		li a7, 31
    		li a0, 75     
    		li a1, 200    
    		li a2, 0      
    		li a3, 100    
    		ecall
    		
    		j FIM_INTERACTION
INTERACT_DOOR:	
		li a7, 31
	    	li a0, 55
	    	li a1, 500    
	    	li a2, 0
	    	li a3, 100
	    	ecall
	    	
	    	la t0,CURRENT_LEVEL
	    	lw t1,0(t0)
	    	
	    	li t2,1
	    	beq t1,t2,DOOR_LVL_2
	    	
	    	li t2,2
	    	beq t1,t2,DOOR_LVL_4
	    	
	    	li t2,4
	    	beq t1,t2,GAME_WIN
	    	
	    	j START_TRANSITION
DOOR_LVL_2:
	li t1,2				#vai pra fase 2 se tiver na 1
	j SAVE_TARGET
DOOR_LVL_4:
	li t1,4				#vai pra fase 4 se tiver na 2
	j SAVE_TARGET
SAVE_TARGET:
	la t0,TARGET_LEVEL
	sw t1,0(t0)
START_TRANSITION:	
	    	la t0,GAME_STATE
	    	li t1,3			#estado 3=transição
	    	sw t1,0(t0)
	    	
	    	la t0,TRANSITION_TIMER
	    	li t1,30
	    	sw t1,0(t0)
	    	j FIM_INTERACTION
	    	
INTERACT_LADDER:
		li a7, 31
        	li a0, 58           # Som diferente da porta
        	li a1, 500
        	li a2, 0
        	li a3, 100
        	ecall
        	
        	la t0,CURRENT_LEVEL
        	lw t1,0(t0)
        	
        	li t2,2
        	beq t1,t2,LADDER_TO_SHOP
        	
        	li t2,3
        	beq t1,t2,LADDER_BACK_TO_2
        	
        	j START_TRANSITION
        	
LADDER_TO_SHOP:
        	li t1, 3            #vai pra loja
        	j SAVE_TARGET_LADDER

LADDER_BACK_TO_2:
        	li t1, 2            #volta pro 2
        	j SAVE_TARGET_LADDER

SAVE_TARGET_LADDER:
        	la t0, TARGET_LEVEL
        	sw t1, 0(t0)
        
      
        	j START_TRANSITION
        	
        	la t0,GAME_STATE
        	li t1,3
        	sw t1,0(t0)
        	
        	la t0,TRANSITION_TIMER
        	li t1,60
        	sw t1,0(t0)
        	j FIM_INTERACTION

FIM_INTERACTION:
    		lw ra, 0(sp)
    		addi sp, sp, 4
    		ret
    		
LOAD_LEVEL:
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		
		addi t1,t1,-1
		slli t1,t1,2
		
		la t2,LEVEL_BG_LIST
		add t2,t2,t1
		lw t3,0(t2)
		la t4,CURRENT_MAP_BG_PTR
		sw t3,0(t4)
		
		la t2,LEVEL_COL_LIST
		add t2,t2,t1
		lw t3,0(t2)
		la t4,CURRENT_MAP_COL_PTR
		sw t3,0(t4)
		
		ret
DRAW_BLACK_SCREEN:
    		li t0, 0xFF0   # Endereço do Bitmap Frame 0
    		add t0,t0,s0
    		slli t0,t0,20
    		
    		li t1, 76800       # Total de pixels (640x480)
    		li t2, 0            # Cor Preta
LOOP_BLACK:
    		sw t2, 0(t0)        # Pinta pixel
    		addi t0, t0, 4      # Próximo pixel
		addi t1, t1, -1     # Decrementa contador
    		bnez t1, LOOP_BLACK

    		ret
DRAW_FULL_HUD:
		addi sp,sp,-4
		sw ra,0(sp)
		
		call DRAW_HUD_HEARTS
		
		la a0,bluebox		#desenha a primeira caixa
		li a1,412
		li a2,426
		mv a3,s0
		call PRINT
		
		la t0,SWORD_ACTIVE
		lw t1,0(t0)
		bnez t1,DRAW_SHIELD_BOX
		
		la a0,sword 		#colocar aqui sprite de espada
		li a1,414
		li a2,430
		mv a3,s0
		call PRINT
DRAW_SHIELD_BOX:
		la a0,bluebox		#segunda caixa
		li a1,452
		li a2,426
		mv a3,s0
		call PRINT
		
		la t0,SHIELD_ACTIVE
		lw t1,0(t0)
		beqz t1,FIM_HUD_ITEMS
		
		la a0,sword		#colocar aq o sprite do shield##############
		li a1,454
		li a2,430
		mv a3,s0
		call PRINT
FIM_HUD_ITEMS:
		
		#ADICIONAR LOGICA DE FLAG AQUI APOS A FLAG#
		
		la a0,bag		#desenha bolsa de moedas
		li a1,158
		li a2,434
		mv a3,s0
		call PRINT
		
		la t0,COIN_COUNT	#desenha contador de moedas
		lw a0,0(t0)
		li a1,190
		li a2,434
		mv a3,s0
		call DRAW_NUMBER
		
		la a0,level		#desenha o L
		li a1,80
		li a2,434
		mv a3,s0
		call PRINT
		
		la t0,CURRENT_LEVEL
		lw a0,0(t0)
		li a1,100
		li a2,434
		mv a3,s0
		call DRAW_NUMBER
		
		lw ra,0(sp)
		addi sp,sp,4
		ret     		    		    		    		    		    		    		
		    		    		    		    		    		    		    		    		    		
   
DRAW_HUD_HEARTS:
		addi sp,sp,-4
		sw ra,0(sp)
		
		la a0,life
		li a1,516
		li a2,434
		mv a3,s0
		call PRINT
		
		addi sp,sp,-12
		sw s1,0(sp)
		sw s2,4(sp)
		sw s3,8(sp)
		
		li s1,0
		li s3,512
		
		la t0,HEALTH_PLAYER
		lw s2,0(t0)
		
		la t0,MAX_HEALTH
		lw s4,0(t0)
		
LOOP_HUD:
		bge s1,s4,FIM_HUD
	
		blt s1,s2,USE_FULL_HEART
		
		la a0,heart_empty
		j DRAW_HEART_NOW
		
USE_FULL_HEART:
		la a0,heart_full
		
DRAW_HEART_NOW:
		mv a1,s3
		li a2,450
		mv a3,s0
		call PRINT
		
		addi s3,s3,14
		addi s1,s1,1
		j LOOP_HUD
FIM_HUD:
		lw s3,8(sp)
		lw s2,4(sp)
		lw s1,0(sp)
		addi sp,sp,12
		lw ra,0(sp)
		addi sp,sp,4
		ret
		
DRAW_NUMBER:
		addi sp,sp,-4
		sw ra,0(sp)
		
		addi sp, sp, -16
    		sw a0, 0(sp)
    		sw a1, 4(sp)
    		sw a2, 8(sp)
    		sw a3, 12(sp)
    		
    		li t0,0xFF0
    		add t0,t0,a3
    		slli t0,t0,20
    		
    		add t0,t0,a1
    		
    		li t1,640
    		mul t1,t1,a2
    		add t0,t0,t1
    		
    		li t2,28
LOOP_CLEAN_Y:
		li t3,16
		mv t4,t0
LOOP_CLEAN_X:
		sb zero,0(t4)
		addi t4,t4,1
		addi t3,t3,-1
		bnez t3,LOOP_CLEAN_X
		
		addi t0,t0,640
		addi t2,t2,-1
		bnez t2,LOOP_CLEAN_Y
		
		lw a3, 12(sp)
    		lw a2, 8(sp)
    		lw a1, 4(sp)
    		lw a0, 0(sp)
    		addi sp, sp, 16
		
		li t0,9
		ble a0,t0,FIND_SPRITE
		mv a0,t0
		
FIND_SPRITE:
		la t0,NUMBER_SPRITES
		slli t1,a0,2
		add t0,t0,t1
		lw a0,0(t0)
		
		call PRINT
		
		lw ra,0(sp)
		addi sp,sp,4
		ret
		
TAKE_DAMAGE:	la t0,INV_TIMER		#carregando tempo de invencibilidade
		lw t1,0(t0)
		bnez t1,FIM_TAKE_DAMAGE	#se >0 ta invencivel, logo n toma dano
		
		li a7,31		#som
		li a0,60
		li a1,200
		li a2,120
		li a3,127
		ecall
		
		la t0,HEALTH_PLAYER	#carregando vida
		lw t1,0(t0)
		addi t1,t1,-1		#decrementa vida
		sw t1,0(t0)
		
		li t2,35
		la t0,INV_TIMER		#tempo de invencibilidade apos tomar dano
		sw t2,0(t0)
		
		blez t1,GAME_OVER	#se chegar a 0, game over
		
		j FIM_TAKE_DAMAGE
		
GAME_OVER:	
		li a7,31		#som
		li a0,60
		li a1,200
		li a2,120
		li a3,127
		ecall
		
		la a0,gameover
		li a1,0
		li a2,0
		li a3,0
		call PRINT
		la a0,gameover
		li a1,0
		li a2,0
		li a3,1
		call PRINT
		
		
WAIT_FOR_RESTART:
		li t0,0xFF200000
		lw t1,0(t0)
		andi t1,t1,1
		beqz t1,WAIT_FOR_RESTART
		
		lw t2,4(t0)
		li t3,' '
		bne t2,t3,WAIT_FOR_RESTART
		#reinicia o jogo#
		la t0,HEALTH_PLAYER
		li t1,3
		sw t1,0(t0)
		
		la t0,BULLET_ACTIVE
		sw zero,0(t0)
		
		la t0,INV_TIMER
		sw zero,0(t0)
		
		la t0,CURRENT_LEVEL
		lw t1,0(t0)
		la t2,TARGET_LEVEL
		sw t1,0(t2)
		
		la t0,GAME_STATE
		li t1,3
		sw t1,0(t0)
		
		la t0,TRANSITION_TIMER
		li t1,30
		sw t1,0(t0)
		
		j GAME_LOOP
		
		
FIM_TAKE_DAMAGE:
		ret
		
UNLOCK_HIDDEN_DOOR:
		la t0,CURRENT_MAP_COL_PTR
		lw t0,0(t0)
		
		li t1,300
LOOP_FIND_DOOR:
		lb t2,0(t0)
		li t3,5
		bne t2,t3,NEXT_TILE_DOOR
		
		li t3,3
		sb t3,0(t0)
NEXT_TILE_DOOR:
		addi t0,t0,1
		addi t1,t1,-1
		bnez t1,LOOP_FIND_DOOR
		ret
UPDATE_STEP_ANIM:
		la t0,PLAYER_DIR
		lw t1,0(t0)
		
		bne a0,t1,NEW_DIRECTION
		
		la t2,ANIM_FRAME
		lw t3,0(t2)
		addi t3,t3,1
		
		andi t3,t3,3
		sw t3,0(t2)
		
		ret
NEW_DIRECTION:
		sw a0,0(t0)
		la t2,ANIM_FRAME
		sw zero,0(t2)
		ret
DRAW_PLAYER:
		addi sp,sp,-4
		sw ra,0(sp)
		
		la t0,INV_TIMER
		lw t1,0(t0)
		bnez t1,HANDLE_BLINK_ANIM
		
		la t0,PLAYER_ATT
		lw t1,0(t0)
		bnez t1,DRAW_ATT_SPRITE
NORMAL_DRAW:
		la t0,PLAYER_DIR
		lw t1,0(t0)
		slli t1,t1,2
		
		la t0,ANIM_FRAME
		lw t2,0(t0)
		
		add t1,t1,t2
		slli t1,t1,2
		
		la t0,CHAR_SPRITES_PTR
		add t0,t0,t1
		lw a0,0(t0)
		
		la t0,CHAR_POS
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		
		call PRINT
		
		lw ra,0(sp)
		addi sp,sp,4
		ret
HANDLE_BLINK_ANIM:
		andi t2,t1,8
		beqz t2,NORMAL_DRAW
		
		lw ra,0(sp)
		addi sp,sp,4
		ret
DRAW_ATT_SPRITE:
		la a0,teste
		la t0,CHAR_POS
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
		lw ra,0(sp)
		addi sp,sp,4
		ret
		
GAME_WIN:
		la a0,gameover 			#fazer a tela de vitoria e por aqui
		li a1,0
		li a2,0
		li a3,0
		call PRINT
		li a1,0
		li a2,0
		li a3,1
		call PRINT
		
		li a7,31
		li a0,60
		li a1,1000
		li a2,0
		li a3,127
		ecall

    		
WAIT_FOR_EXIT:
		li t0,0xFF200000
		lw t1,0(t0)
		andi t1,t1,1
		beqz t1,WAIT_FOR_EXIT
		
		lw t2,4(t0)
		li t3,' '
		bne t2,t3,WAIT_FOR_EXIT
		
		li a7,10
		ecall
	

		
		

		
		
.data
#Sprites
.include "char.data"
.include "pilar1.data"
.include "pilar2.data"
.include "pilar4.data"
.include "teste.data"
.include "rupee.data"
.include "porta.data"
.include "heart_empty.data"
.include "heart_full.data"
.include "bag.data"
.include "bluebox.data"
.include "level.data"
.include "life.data"
.include "sword.data"
.include "bullet.data"
.include "gameover.data"
.include "drone1.data"
.include "drone2.data"
.include "heart.data"
.include "puzzle.data"
