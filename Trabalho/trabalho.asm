.data
CHAR_POS: 	.half 0,192
OLD_CHAR_POS: 	.half 0,0
SWORD_ACTIVE: 	.word 1			#flag da espada
SWORD_POS:	.half 32,192
GAME_STATE:	.word 0			#flag do estado do jogo (0=jogando,1=pegando item)
ITEM_TIMER:	.word 0			#tempo que a pose de pegar item vai ficar e tempo do áudio
##DRONE##
DRONE_POS:	.half 288,160		#posição inicial
DRONE_VEL:	.word 4			#Velocidade no eixo Y
DRONE_FLAG:	.word 1




.text
SETUP:		
		
	
		
GAME_LOOP:	la t0,GAME_STATE	#carrega o estado do jogo
		lw t1,0(t0)
		
		beqz t1,STATE_PLAYING	#se for 0 quer dizer que esta jogando
		li t2,1
		beq t1,t2,STATE_ITEM_COLLECTED		#se for 1 esta pegando item
		#adicionar outros estados aqui
		
		j END_FRAME_PROCESSING
		
STATE_PLAYING:	la a0,map1		#carregando o mapa para printar
		li a1,0
		li a2,0
		mv a3,s0
		call PRINT
		
	

		call KEY2
		call UPDATE_DRONE
		call CHECK_DRONE_COLLISION

		
		
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

		la t0,CHAR_POS		#carregando posicao do personagem
		la a0,char		#para printar personagem
		lh a1,0(t0)		#carregando x do personagem
		lh a2,2(t0)		#carregando y do personagem
		mv a3,s0
		call PRINT
		
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
		la a0,map1		#carregando o mapa para printar
		li a1,0
		li a2,0
		mv a3,s0
		call PRINT
		
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
	
		la t0,ITEM_TIMER
		lw t1,0(t0)
		addi t1,t1,-1
		sw t1,0(t0)
		
		beqz t1,END_ITEM_COLLECTED
		
		la t0,CHAR_POS
		la a0,char
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
		
		
		
		
FIM:		ret

CHECK_DRONE_COLLISION:
		la t0,DRONE_FLAG
		lw t1,0(t0)
		beqz t1,FIM_COL_DRONE
		
		la t0,CHAR_POS
		lh t1,0(t0)
		lh t2,2(t0)
		
		la t0,DRONE_POS
		lh t3,0(t0)
		lh t4,2(t0)
		
		#calculando distancia
		sub t5,t1,t3
		bgez t5,SKIP_NEG_X
		neg t5,t5
		
SKIP_NEG_X:	li t6,24
		bge t5,t6,FIM_COL_DRONE
		
		sub t5,t2,t4
		bgez t5,SKIP_NEG_Y
		neg t5,t5
		
SKIP_NEG_Y:	bge t5,t6,FIM_COL_DRONE

		#COLIDIU (decrementar vida/pintar de vermelho)

		
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

CHAR_CIMA:	la t0,CHAR_POS
		la t1,OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)
		
		lh t1,2(t0)
		
		li t5,32		#borda de cima
		ble t1,t5,FIM_MOVIMENTO
		
		addi t1,t1,-32		#sobe um bloco
		sh t1,2(t0)
		ret

CHAR_ESQ:	la t0,CHAR_POS
		la t1,OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)
		
		lh t1,0(t0)
		
		li t5,32		#borda da esquerda
		ble t1,t5,FIM_MOVIMENTO
		
		addi t1,t1,-32		#um bloco pra esquerda
		sh t1,0(t0)
		ret
		
CHAR_BAIXO:	la t0,CHAR_POS
		la t1,OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)
		
		lh t1,2(t0)
		
		li t5,336		#borda de baixo
		bge t1,t5,FIM_MOVIMENTO
		
		addi t1,t1,32		#desce um bloco
		sh t1,2(t0)
		ret
		
		
CHAR_DIR:	la t0,CHAR_POS
		la t1,OLD_CHAR_POS
		lw t2,0(t0)
		sw t2,0(t1)
		
		lh t1,0(t0)
		
		li t5,560		#borda da direita
		bge t1,t5,FIM_MOVIMENTO
		
		addi t1,t1,32		#um bloco pra direita
		sh t1,0(t0)
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
		

.data
.include "map1.data"
.include "char.data"
.include "tile.s"
.include "pilar1.data"
.include "teste.data"

