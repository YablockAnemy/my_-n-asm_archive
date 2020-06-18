use64
section dbgcode progbits alloc exec nowrite align=0 
dbg:
	mov qword [dbgr], rax
	mov qword [dbgr+8], rbx
	mov qword [dbgr+16], rcx
	mov qword [dbgr+24], rdx
	mov word [dbgf], "ra"
	call .prp
	mov word [dbgf], "x:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov rcx, dbgr
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rb"
	call .prp
	mov word [dbgf], "x:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov rcx, dbgr
	add rcx, 8
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rc"
	call .prp
	mov word [dbgf], "x:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov rcx, dbgr
	add rcx, 16
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rd"
	call .prp
	mov word [dbgf], "x:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov rcx, dbgr
	add rcx, 24
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rs"
	call .prp
	mov word [dbgf], "i:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov qword [dbgd], rsi
	mov rcx, dbgd
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rd"
	call .prp
	mov word [dbgf], "i:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov qword [dbgd], rdi
	mov rcx, dbgd
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rb"
	call .prp
	mov word [dbgf], "p:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov qword [dbgd], rbp
	mov rcx, dbgd
	call .conv
	mov word [dbgf], 0x0A00
	call .prp

	mov word [dbgf], "rs"
	call .prp
	mov word [dbgf], "p:"
	call .prp
	mov word [dbgf], "0x"
	call .prp
	mov qword [dbgd], rsp
	add qword [dbgd], 8
	mov rcx, dbgd
	call .conv
.lo:
	call .inf
	cmp word [dbgf], 0x230A
	jnz .ret
	call .preb
	jmp .lo
.ret:
	mov rax, qword [dbgr]
	mov rbx, qword [dbgr+8]
	mov rcx, qword [dbgr+16]
	mov rdx, qword [dbgr+24]
	ret
.conv:
	mov al, byte [rcx+7]
	call d2hc
	mov word [dbgh], ax
	mov al, byte [rcx+6]
	call d2hc
	mov word [dbgh+2], ax
	mov al, byte [rcx+5]
	call d2hc
	mov word [dbgh+4], ax
	mov al, byte [rcx+4]
	call d2hc
	mov word [dbgh+6], ax
	mov al, byte [rcx+3]
	call d2hc
	mov word [dbgh+8], ax
	mov al, byte [rcx+2]
	call d2hc
	mov word [dbgh+10], ax
	mov al, byte [rcx+1]
	call d2hc
	mov word [dbgh+12], ax
	mov al, byte [rcx]
	call d2hc
	mov word [dbgh+14], ax
	call .prh
	ret
.preb:
	call .inh
	mov ax, word [dbgh]
	call hc2d
	mov byte [dbgd+7], al
	mov ax, word [dbgh+2]
	call hc2d
	mov byte [dbgd+6], al
	mov ax, word [dbgh+4]
	call hc2d
	mov byte [dbgd+5], al
	mov ax, word [dbgh+6]
	call hc2d
	mov byte [dbgd+4], al
	mov ax, word [dbgh+8]
	call hc2d
	mov byte [dbgd+3], al
	mov ax, word [dbgh+10]
	call hc2d
	mov byte [dbgd+2], al
	mov ax, word [dbgh+12]
	call hc2d
	mov byte [dbgd+1], al
	mov ax, word [dbgh+14]
	call hc2d
	mov byte [dbgd], al
	mov rbx, qword [dbgd]
	mov al, byte [rbx]
	call d2hc
	mov word [dbgf], ax
	call .prp
	mov word [dbgf], 0x0A00
	call .prp
	ret
.inf:
	mov rbx, 0
	mov rcx, dbgf
	mov rdx, 2
	call read
	ret
.inh:
	mov rbx, 0
	mov rcx, dbgh
	mov rdx, 16
	call read
	ret
.prp:
	mov rbx, 1
	mov rcx, dbgf
	mov rdx, 2
	call write
	ret
.prh:
	mov rbx, 1
	mov rcx, dbgh
	mov rdx, 16
	call write
	ret
_std:
	int 0x80
	cmp rax, -255
	jnc handler
	ret
_io:
	int 0x80
	cmp rax, -255
	jnc handler
	add rcx, rax
	sub rdx, rax
	ret
read:
	mov rax, 3
	call _io
	jnz read
	ret
write:
	mov rax, 4
	call _io
	jnz write
	ret
hc2d:
	sub ah, 48
	cmp ah, 10
	jc .1
	sub ah, 7
.1:
	sub al, 48
	cmp al, 10
	jc .2
	sub al, 7
.2:
	mov dh, ah
	mov dl, 16
	mul dl
	or al, dh
	ret
d2hc:
	xor ah, ah
	mov dl, 16
	div dl
	cmp al, 10
	jc .1
	add al, 7
.1:
	add al, 48
	cmp ah, 10
	jc .2
	add ah, 7
.2:
	add ah, 48
	ret
;##################################################
close:
	mov rax, 6
	call _std
	ret
hc2dA:
	sub ah, 48
	cmp ah, 10
	jc .1
	sub ah, 7
.1:
	sub al, 48
	cmp al, 10
	jc .2
	sub al, 7
.2:
	mov dl, al
	mov al, ah
	mov dh, 16
	mul dh
	or al, dl
	ret
section dbgdata progbits alloc noexec write align=0
dbgr:	dq 0, 0, 0, 0
dbgf:	db 0, 0
dbgh:	dq 0, 0
dbgd:	dq 0
