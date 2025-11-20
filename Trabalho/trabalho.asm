.data
CHAR_POS: 	.half 0,192
OLD_CHAR_POS: 	.half 0,0
SWORD_ACTIVE: 	.word 1		#flag da espada
SWORD_POS:	.half 32,192
GAME_STATE:	.word 0		#flag do estado do jogo
ITEM_TIMER:	.word 0		#tempo que a pose de pegar item vai ficar
#VIDA/DANO#
HEALTH_PLAYER: 	.word 3		#3 de vida inicial
INV_TIMER: 	.word 0		#tempo de invencibilidade

PLAYER_ATT:	.word 0		#0= n atacando 1= atacando
ATT_TIMER:	.word 0		#frames do ataque

MAP_WIDTH: 	.word 20	#largura do mapa em blocos

#Dados dos Inimigos
DRONE_POS:	.half 288,160	#posicao inicial
DRONE_VEL:	.word 4		#velocidade no eixo Y
DRONE_FLAG:	.word 1		#1=vivo 0=morto

#Controle de Níveis
CURRENT_LEVEL:       .word 1	#nivel atual
CURRENT_MAP_BG_PTR:  .word 0	#ponteiro para o background atual
CURRENT_MAP_COL_PTR: .word 0	#ponteiro para o mapa de colisao

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





.text
SETUP:
		call LOAD_LEVEL		#carrega os ponteiros dos mapas
		
	
		
GAME_LOOP:	la t0,GAME_STATE	#carrega o estado do jogo
		lw t1,0(t0)
		
		beqz t1,STATE_PLAYING	#se for 0 quer dizer que esta jogando
		li t2,1
		beq t1,t2,STATE_ITEM_COLLECTED		#se for 1 esta pegando item
		#adicionar outros estados aqui
		
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
		
		la a0,CURRENT_MAP_BG_PTR		#carregando o mapa para printar
		lw a0,0(a0)
		li a1,0
		li a2,0
		mv a3,s0
		call PRINT
		
		call DRAW_SCENARIO
		
		call KEY2
		call UPDATE_DRONE
		call CHECK_DRONE_COLLISION
		call CHECK_INTERACTION

		
		
		la t0,SWORD_ACTIVE	#carregando flag
		lw t1,0(t0)
		beqz t1,SKIP_SWORD_DRAW
		
		
		la t0,SWORD_POS		#carregando posicao da espada
		la a0,teste		#para printar espada
		lh a1,0(t0)		#carregando x da espada
		lh a2,2(t0)		#carregando y da espada
		mv a3,s0
		call PRINT
		
SKIP_SWORD_DRAW:

		la t0,DRONE_FLAG
		lw t1,0(t0)
		beqz t1,SKIP_DRONE_DRAW
		
		la t0,DRONE_POS
		la a0,char		#imagem do drone
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
		
SKIP_DRONE_DRAW:
		la t0,INV_TIMER		#carregando tempo de invencibilidade
		lw t1,0(t0)
		bnez t1,CHECK_BLINK	#se n for zero ainda ta invencivel vai piscar
		
		la t0,PLAYER_ATT
		lw t1,0(t0)
		bnez t1,DRAW_ATT
		
		la t0,CHAR_POS		#carregando personagem pra printar
		la a0,char
		lh a1,0(t0)
		lh a2,2(t0)
		mv a3,s0
		call PRINT
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
		li t1,80		#tempo que vai ficar parado
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
		la a0,char
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
GAME_OVER:	#implementar aqui oq acontece no game over
		li a7,10		#por enquanto so finalizando programa
		ecall
FIM_TAKE_DAMAGE:

FIM_COL_DRONE:	ret

UPDATE_DRONE:	la t0,DRONE_FLAG	#carrega flag
		lw t1,0(t0)
		beqz t1,FIM_DRONE	#se for 0 ta morto
		
		la t0,DRONE_POS		#carrega posicao
		lh t1,2(t0)
		
		la t2,DRONE_VEL		#carrega velocidade de movimento
		lw t3,0(t2)
		
		add t1,t1,t3		#incrementa velocidade na posicao
		sh t1,2(t0)
		
		li t4,352		#limite inferior
		bge t1,t4,INVERTE_DRONE_Y
		
		li t5,32		#limite superior
		ble t1,t5,INVERTE_DRONE_Y 
		
		ret
INVERTE_DRONE_Y:
		neg t3,t3		#t3=-t3 -> inverte
		sw t3,0(t2)
		ret	
		
FIM_DRONE:	ret

CHAR_CIMA:	
		addi sp,sp,-4
		sw ra,0(sp)
		
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
		
		la t0,DRONE_POS		#posicao drone
		lh t3,0(t0)
		lh t4,2(t0)
		
		sub t5,t1,t3
		bgez t5,SKIP_NEG_X_ATT
		neg t5,t5
SKIP_NEG_X_ATT:
		li t6,40		#se a distancia for 40 ou menos ataca
		bge t5,t6,FIM_ATT_COLLISION
		
		sub t5,t2,t4
		bgez t5,SKIP_NEG_Y_ATT
		neg t5,t5
SKIP_NEG_Y_ATT:
		bge t5,t6,FIM_ATT_COLLISION
		
		la t0,DRONE_FLAG
		sw zero,0(t0)
		
		##adicionar efeito visual,etc##
		
		ret
		
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
		j SKIP_DRAW_TILE
		
PREP_PILAR:#1
		la a0,pilar1
		j DRAW_TILE_NOW
PREP_COIN:#2
		la a0,rupee
		j DRAW_TILE_NOW
PREP_DOOR:#3
		la a0,porta
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
		lb a0,0(t3)
		
		li t1,1			#pilar
		beq a0,t1, TILE_SOLIDO
		
		li t1,4			#parede
		beq a0,t1, TILE_SOLIDO
		
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
		
		j FIM_INTERACTION

INTERACT_COIN:	sb zero,0(t3)
		#adicionar incrementar moeda no contador
		li a7, 31
    		li a0, 75     
    		li a1, 200    
    		li a2, 0      
    		li a3, 100    
    		ecall
    		
    		j FIM_INTERACTION
INTERACT_DOOR:	
		#adicionar aqui transição pra prox fase
		li a7, 31
	    	li a0, 55
	    	li a1, 500    
	    	li a2, 0
	    	li a3, 100
	    	ecall
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
		
		
.data
#Sprites
.include "char.data"
.include "pilar1.data"
.include "teste.data"
.include "rupee.data"
.include "porta.data"
		
