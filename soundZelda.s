.data
TAMANHO: .word 29
NOTAS: .word 69, 1100, 69, 220, 69, 140, 69, 140, 69, 140, 69,290,67, 170, 69, 800,
  69, 220, 69, 140, 69, 140, 69, 140, 69, 290, 67, 170, 69, 800, 69, 150, 69, 150, 69, 150, 69, 230,
  64, 115, 64, 115, 64, 230, 64, 115, 64, 115, 64, 230, 64, 115, 64, 115, 64, 230, 64,230
  
.text
	
MUSICA:		
	lw s1,TAMANHO		# le o numero de notas
	la s0,NOTAS		# define o endereCo das notas (Endereço inicial do array)
	li t0,0			# zera o contador de notas
	li a2, 80		#instrumento
	li a3,100		# volume

LOOP:
	lw a0,0(s0)		# le o valor da nota
	lw a1,4(s0)		# le a duracao da nota
	
	li a7,31		# toca a nota
	ecall		
	
	mv a0,a1		# passa a duracao da nota para a pausa (Pausa entre notas)
	li a7,32		# define a chamada de syscal (Sleep)
	ecall			# realiza uma pausa de a0 ms
	
	addi s0,s0,8		
	addi t0,t0,1	
	bne t0, s1, LOOP		        

MUSICA_FIM:
	jr ra
	

