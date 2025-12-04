#################################################################
# PLAY_AUDIO_DEMO				       	     	#
# Toca e adiciona audio em 3 tracks distintas			#
# 							     	#
# RECEBE:						        #
#	A0 : MODO (0 = continuar tocando, 1 = tocar nova)	#
#	se a0 = 1:						#
#		A1 = endereco do audio		                #
#		A2 = track para sobrescrever (1, 2 ou 3)      	#
#		A3 = modo loop (0 ou 1)			        #
# RETORNA:                                                  	#
#       (nada)                                             	#
#################################################################

.data

# Eh uma boa idea definir o proposito de cada track em seu projeto no comeco
# Por exemplo, TRACK1 poderia ser para musica de fundo, TRACK2 para efeitos sonoros e TRACK3 para dialogo
# Cada um eh tao bom quanto o outro, entao n importa muito qual vc escolher para oq

TRACK1:
	TRACK1_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK1_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK1_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK1_PROXIMO_POINTER:	.word 0 # marca qual eh a proxima nota
	TRACK1_LOOP:		.word 0	# marca se o track estah loopando
	
# A track 2 eh comumente utilizada para tocar efeitos sonoros
TRACK2:
	TRACK2_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK2_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK2_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK2_PROXIMO_POINTER:	.word 0 # marca qual eh a proxima nota
	TRACK2_LOOP:		.word 0	# marca se o track estah loopando

# A track 3 eh comumente utilizada para tocar miscelaneos que nao se encaixam nas outras categorias
TRACK3:
	TRACK3_ATIVO: 		.word 0	# se estah tocando ou nao
	TRACK3_TIMESTAMP:	.word 0 # quando o track comecou
	TRACK3_INICIO_POINTER:	.word 0 # pointer pra primeira nota (em caso de loop)
	TRACK3_PROXIMO_POINTER:	.word 0 # marca qual eh a proxima nota
	TRACK3_LOOP:		.word 0	# marca se o track estah loopando
	
#	Notas (struct){
#		byte pitch
#		byte instrument
#		byte volume
#		space 1
#		word duration
#		word start_ms
#	}

.text
.eqv pitch 0
.eqv instrument 1
.eqv volume 2
.eqv duration, 4
.eqv start_ms 8
.eqv tamanho_struct_nota 12

PLAY_AUDIO_DEMO:
		addi sp, sp, -4
		sw ra, (sp)
		beqz, a0, PLAY_AUDIO.TOCAR_SEQUENCIAL	# apena toca as tracks se o modo for 0
		
		# senao, inicializa a track escolhida
PLAY_AUDIO.SWITCH1:
		li t0, 1
		bne a2, t0, PLAY_AUDIO.SWITCH2
		jal PLAY_AUDIO.INICIAR_TRACK1		# inicia a track 1
		j PLAY_AUDIO.SWITCH_FIM
PLAY_AUDIO.SWITCH2:
		li t0, 2
		bne a2, t0, PLAY_AUDIO.SWITCH3
		jal PLAY_AUDIO.INICIAR_TRACK2		# inicia a track 2
		j PLAY_AUDIO.SWITCH_FIM
PLAY_AUDIO.SWITCH3:
		li t0, 3
		bne a2, t0, PLAY_AUDIO.SWITCH_FIM
		jal PLAY_AUDIO.INICIAR_TRACK3		# inicia a track 3
PLAY_AUDIO.SWITCH_FIM:

PLAY_AUDIO.TOCAR_SEQUENCIAL:
	jal PLAY_AUDIO.TRACK1
	jal PLAY_AUDIO.TRACK2
	jal PLAY_AUDIO.TRACK3
	j PLAY_AUDIO.FIM
	


PLAY_AUDIO.INICIAR_TRACK1: 		
		sw a1, TRACK1_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK1_PROXIMO_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK1_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK1_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK1_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret			
       		
PLAY_AUDIO.TRACK1: 

		lw t0, TRACK1_ATIVO
		beqz t0, PLAY_AUDIO.TRACK1_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK1_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK1_PROXIMO_POINTER
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK1_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK1_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK1_PROXIMO_POINTER, t1	# vai pra proxima nota no arquivo
		
		j PLAY_AUDIO.TRACK1		# checa se hah alguma nota que deveria tocar simultaneamente
		
PLAY_AUDIO.TRACK1_FIM1:	
		lw t0, TRACK1_LOOP
		beqz t0, PLAY_AUDIO.TRACK1_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK1_INICIO_POINTER
		sw t0, TRACK1_PROXIMO_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK1_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j PLAY_AUDIO.TRACK1_FIM2	# continua com o resto do proc
		
PLAY_AUDIO.TRACK1_FIM1_CONT:
		sw zero, TRACK1_PROXIMO_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK1_ATIVO, t0	# termina a reproducao
PLAY_AUDIO.TRACK1_FIM2:
       		ret
       		
       		
       		
       		
       		
       		
       		
PLAY_AUDIO.INICIAR_TRACK2: 		
		sw a1, TRACK2_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK2_PROXIMO_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK2_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK2_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK2_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret
       		
PLAY_AUDIO.TRACK2: 

		lw t0, TRACK2_ATIVO
		beqz t0, PLAY_AUDIO.TRACK2_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK2_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK2_PROXIMO_POINTER
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK2_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK2_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK2_PROXIMO_POINTER, t1	# vai pra proxima nota no arquivo
		
		j PLAY_AUDIO.TRACK2		# checa se hah alguma nota que deveria tocar simultaneamente
		
PLAY_AUDIO.TRACK2_FIM1:	
		lw t0, TRACK2_LOOP
		beqz t0, PLAY_AUDIO.TRACK2_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK2_INICIO_POINTER
		sw t0, TRACK2_PROXIMO_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK2_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j PLAY_AUDIO.TRACK2_FIM2	# continua com o resto do proc
		
PLAY_AUDIO.TRACK2_FIM1_CONT:
		sw zero, TRACK2_PROXIMO_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK2_ATIVO, t0	# termina a reproducao
PLAY_AUDIO.TRACK2_FIM2:
       		ret
       		
       		
       		
       		
       		
       		
       		
       		
       		
       		
PLAY_AUDIO.INICIAR_TRACK3: 		
		sw a1, TRACK3_INICIO_POINTER, t1# salva o audio como o ponteiro de inicio
		sw a1, TRACK3_PROXIMO_POINTER, t1	# salva o audio como o ponteiro atual tbm
       		li t0, 1
      		sw t0, TRACK3_ATIVO, t1		# ativa a track
      		csrr t0, time
      		sw t0, TRACK3_TIMESTAMP, t1	# salva o momento em que a track comecou
      		sw a3, TRACK3_LOOP, t1		# salva se o loop estah ligado ou nao
      		ret
       		
PLAY_AUDIO.TRACK3: 

		lw t0, TRACK3_ATIVO
		beqz t0, PLAY_AUDIO.TRACK3_FIM2	# se o track nao estah ativo, volta para onde estavamos
		
		lw t0, TRACK3_TIMESTAMP
		csrr t1, time
		sub t2, t1, t0			# milisegundos desde o comeco do timestamp
		
		lw t0, TRACK3_PROXIMO_POINTER
		lw t1, duration(t0)
		beqz t1, PLAY_AUDIO.TRACK3_FIM1	# se duracao == 0, chegamos no fim e devemos voltar
		
		lw t1, start_ms(t0)		
		bgt t1, t2, PLAY_AUDIO.TRACK3_FIM2	# se start_ms < ms_desde_timestamp: nao toca nada ainda, nao eh hora
		
		lb a0, pitch(t0)
		lw a1, duration(t0)
		lb a2, instrument(t0)
		lb a3, volume(t0)
		li a7, 31
		ecall
		
		addi t0, t0, tamanho_struct_nota
		sw t0, TRACK3_PROXIMO_POINTER, t1	# vai pra proxima nota no arquivo
		
		j PLAY_AUDIO.TRACK3		# checa se hah alguma nota que deveria tocar simultaneamente
		
PLAY_AUDIO.TRACK3_FIM1:	
		lw t0, TRACK3_LOOP
		beqz t0, PLAY_AUDIO.TRACK3_FIM1_CONT
		# se o loop estiver ligado, reinicia tudo
		
		lw t0, TRACK3_INICIO_POINTER
		sw t0, TRACK3_PROXIMO_POINTER, t1	# coloca o ponteiro de nota de volta no comeco
		csrr t0, time
		sw t0, TRACK3_TIMESTAMP, t1	# reinicia a timestamp da track (pra ela tocar de novo)
		j PLAY_AUDIO.TRACK3_FIM2	# continua com o resto do proc
		
PLAY_AUDIO.TRACK3_FIM1_CONT:
		sw zero, TRACK3_PROXIMO_POINTER, t0	# limpa o pointer de reproducao
		sw zero, TRACK3_ATIVO, t0	# termina a reproducao
PLAY_AUDIO.TRACK3_FIM2:
       		ret
       
       
PLAY_AUDIO.FIM:
		lw ra, (sp)
		addi sp, sp, 4
		ret
       
       
       
