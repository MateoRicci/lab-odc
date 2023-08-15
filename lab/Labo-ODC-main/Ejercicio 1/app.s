	.equ SCREEN_WIDTH,   640
	.equ SCREEN_HEIGH,   480
	.equ BITS_PER_PIXEL, 32

	.equ GPIO_BASE,    0x3f200000
	.equ GPIO_GPFSEL0, 0x00
	.equ GPIO_GPLEV0,  0x34

	.globl main

main:
	mov x20, x0

///////////////////////////coordenadas iniciales///////////////////////////
	mov x19, SCREEN_HEIGH
	lsr x19, x19, #2
	mov x17, #100     // coordenada inicial x del sol
	mov x18, #100	  // coordenada inicial x de la luna
	mov x19, #210	  // coordenada inicial x de la cloud
	
	mov x21, #0    	
	mov x22, #0	 	// coordenada x inicial raft
	mov x23, #0		// coordenada y inicial raft
	mov x27, #0


repeat:
	mov x0, x20
	mov x2, SCREEN_HEIGH         // Y Size
	movz x12, 0x08, lsl 16
	movk x12, 0x2539, lsl 00
	mov x13, #430

set_x:
	mov x1, SCREEN_WIDTH         // X Size

drawing:
	layer_1:
		bl color_night
	
	layer_2:
		// Stars
		mov x5, #600    // coordenada x inicial star
		mov x6, #450	 // coordenada y inicial star
		mov x3, #5 // ancho
		mov x4, #5 //alto
		b draw_star

	layer_3:
		// Moon
		mov x3, #40                 // Radio del circulo
		mul x4, x3, x3	 
		mov x5, x18			         // Coordenada X (centro del circulo)
		mov x6, #380			     // Coordenada Y
		bl moon

	layer_4:
		// Clouds
		mov x3, #30                 // Radio del circulo	 
		mov x5, x19			         // Coordenada X (centro del circulo)
		mov x6, #400			     // Coordenada Y
		bl cloud
		bl cloud_2
		bl cloud_3

	layer_5:
	// Sea
		cmp x2, #270
		b.le color_sea

	layer_6:
	// Raft
		add x5, x22, #260 // horizontal
		add x6, x23, #120 //altura
		mov x3, #100 // ancho
		mov x4, #60 //alto
		bl raft_border

		add x5, x22, #267 // horizontal
		add x6, x23, #127 //altura
		mov x3, #85 // ancho
		mov x4, #45 //alto
		bl raft

		add x5, x22, #272 // horizontal
		add x6, x23, #165 //altura
		mov x3, #10 // ancho
		mov x4, #70 //alto
		bl raft_stick

		add x5, x22, #233 // horizontal
		add x6, x23, #220 //altura
		mov x3, #50 // ancho
		mov x4, #25 //alto
		bl raft_flag

		add x5, x22, #250 // horizontal
		add x6, x23, #225 //altura
		mov x3, #15 // ancho
		mov x4, #15 //alto
		bl flag_dot

	end_layers:

//----------------------- Ciclo del framebuffer ---------------------------------------

cycle:
	stur w10,[x0]  // Colorear el pixel N
	add x0,x0,4    // Siguiente pixel
	sub x1,x1,1    // Decrementar contador X
	cbnz x1,drawing  // Si no terminó la fila, salto
	sub x2,x2,1    // Decrementar contador Y
	cmp x2, x13
	b.gt continue_cycle
	sub x13, x13, #5
	sub x12, x12, #1
continue_cycle:
	cbnz x2,set_x  // Si no es la última fila, salto

//--------------------- GPIOM -----------------------
	mov x9, GPIO_BASE
	str wzr, [x9, GPIO_GPFSEL0]
	ldr w15, [x9, GPIO_GPLEV0]
	and w11, w15, 0x04
	cmp w11, #0x04
	b.eq tecla_w
	B end

//------------------------- Movimiento ---------------------------
	tecla_w:
	mov x3, #70                  // Radio del circulo
	b end

end:
	b repeat
	cbz x2, done

//--------------------------------------------------------------

draw_star:
	bl star
	sub x5, x5, #50
	sub x6, x6, #50
	bl star
	add x5, x5, #20
	sub x6, x6, #70
	bl star
	sub x5, x5, #150
	add x6, x6, #130
	bl star
	sub x5, x5, #80
	sub x6, x6, #60
	bl star
	sub x5, x5, #150
	add x6, x6, #50
	bl star
	sub x5, x5, #180
	sub x6, x6, #70
	bl star
	add x5, x5, #200
	sub x6, x6, #70
	bl star
	b layer_3

star:
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_star
		cmp x11, xzr
		b.ge end_star
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_star
		cmp x11, xzr
		b.le end_star
		b.ge color_star
	end_star:
		ret

moon:
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_moon
	ret

sun:
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_sun
	ret

cloud:
	mul x4, x3, x3
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	sub x21, x21, #5 
	mul x4, x21, x21
	add x5, x5, #38
	sub x6, x6, #8
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	add x21, x21, #4 
	mul x4, x21, x21
	sub x5, x5, #45
	sub x6, x6, #25
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	add x5, x5, #38
	sub x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	add x5, x5, #38
	add x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	ret

cloud_2:
	mov x3, #20
	add x5, x5, #210
	add x6, x6, #70
	mul x4, x3, x3
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	sub x21, x21, #5 
	mul x4, x21, x21
	add x5, x5, #28
	sub x6, x6, #3
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	add x21, x21, #4 
	mul x4, x21, x21
	sub x5, x5, #40
	sub x6, x6, #25
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	add x5, x5, #28
	sub x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	add x5, x5, #33
	add x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	ret

cloud_3:
	mov x3, #18
	sub x5, x5, #460
	sub x6, x6, #50
	mul x4, x3, x3
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	add x21, x21, #5 
	mul x4, x21, x21
	sub x5, x5, #28
	add x6, x6, #3
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	mov x21, x3
	add x21, x21, #4 
	mul x4, x21, x21
	add x5, x5, #40
	sub x6, x6, #25
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	sub x5, x5, #28
	sub x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	sub x5, x5, #33
	add x6, x6, #5
	sub x9, x5, x1
	sub x11, x6, x2
	mul x9, x9, x9
	mul x11, x11, x11
	add x9, x9, x11
	cmp x4, x9
	b.ge color_cloud
	ret

raft_border:
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_raft_border
		cmp x11, xzr
		b.ge end_raft_border
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_raft_border
		cmp x11, xzr
		b.le end_raft_border 
		b.ge color_raft_border
	end_raft_border:
		ret

raft: 
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_raft
		cmp x11, xzr
		b.ge end_raft
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_raft
		cmp x11, xzr
		b.le end_raft
		b.ge color_raft
	end_raft:
		ret

raft_stick: 
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_raft_stick
		cmp x11, xzr
		b.ge end_raft_stick
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_raft_stick
		cmp x11, xzr
		b.le end_raft_stick
		b.ge color_raft_stick
	end_raft_stick:
		ret

raft_flag: 
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_raft_flag
		cmp x11, xzr
		b.ge end_raft_flag
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_raft_flag
		cmp x11, xzr
		b.le end_raft_flag
		b.ge color_raft_flag
		
	end_raft_flag:
		ret

flag_dot:
	sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.ge end_flag_dot
		cmp x11, xzr
		b.ge end_flag_dot
		add x5, x5, x3
		add x6, x6, x4
		sub x9, x11, x2
		sub x9, x5, x1
		sub x11, x6, x2
		cmp x9, xzr
		b.le end_flag_dot
		cmp x11, xzr
		b.le end_flag_dot
		b.ge color_moon
		
	end_flag_dot:
		ret

//log:


// -------------------- Colors ----------------------

color_night:
	mov x10, x12
	ret

color_star:
	movz x10, 0xE4, lsl 16
	movk x10, 0xE4E4, lsl 00
	ret

color_sea:
	movz x10, 0x13, lsl 16
	movk x10, 0x1EBD, lsl 00
	b layer_6

color_moon:
	movz x10, 0xDE, lsl 16
	movk x10, 0xDDC4, lsl 00 
	ret

color_sun:                  
	movz x10, 0x00FB, lsl 16
	movk x10, 0xC117, lsl 00 
	ret

color_cloud:
	movz x10, 0x3D, lsl 16
	movk x10, 0x4850, lsl 00 
	ret

color_raft_border:
	movz x10, 0x99, lsl 16
	movk x10, 0x4C00, lsl 00 
	ret

color_raft:
	movz x10, 0xDA, lsl 16
	movk x10, 0x8B25, lsl 00 
	ret

color_raft_stick:
	movz x10, 0xDE, lsl 16
	movk x10, 0xDDC4, lsl 00 
	ret

color_raft_flag:
	movz x10, 0x00, lsl 16
	movk x10, 0x0000, lsl 00 
	ret


done:
InfLoop:
	b InfLoop
