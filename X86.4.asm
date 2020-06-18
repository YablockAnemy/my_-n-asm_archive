use64
global _start
section FScript progbits alloc exec write align=0
_start:
	mov qword [rsp], handler
	jmp main
;int#########################################################################
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
_net:
	mov rax, 102
	int 0x80
	cmp rax, -255
	jnc handler
	ret
;proc########################################################################
exit:
	mov rax, 1
	mov rbx, 0
	int 0x80
fork:
	mov rax, 2
	call _std
	cmp rax, 0
	ret
;io##########################################################################
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
;fd##########################################################################
open:
	mov rax, 5
	call _std
	ret
close:
	mov rax, 6
	call _std
	ret
;net#########################################################################
socket:
	mov rbx, 1
	mov rcx, .tcp
	call _net
	ret
socket.tcp:
	.path:	dd 2
	.fam:	dd 1
	.proto:	dd 6
bind:
	mov rbx, 2
	mov rcx, $addr.arg
	mov dword [$addr.arg.len], 16
	call _net
	ret
connect:
	mov rbx, 3
	mov rcx, $addr.arg
	mov dword [$addr.arg.len], 16
	call _net
	ret
accept:
	mov rbx, 5
	mov rcx, $addr.arg
	mov dword [$addr.arg.len], $addr.arg.len
	call _net
	ret
$addr.arg:
	.fd:	dd 0
	.addr:	dd $addr
	.len:	dd 16
$addr:
	.fam:	dw 2
	.port:	dw 0
	.ip:	dd 0
	.zero:	dq 0
listen:
	mov rbx, 4
	mov rcx, .full
	call _net
	ret
listen.full:
	.fd:	dd 0
	.conn:	dd 0xFFFFFFFF
send:
	mov rbx, 9
	mov rcx, $io
	call _net
	ret
recv:
	mov rbx, 10
	mov rcx, $io
	call _net
	ret
$io:
	.fd:	dd 0
	.buf:	dd 0
	.len:	dd 0
	.mode:	dd 0
;socks#######################################################################
s5auth:
	mov byte [.buf.ver], 5
	mov byte [.buf.len], 1
	mov dword [$io.buf], .buf
	mov dword [$io.len], 3
	call socket
	mov dword [$addr.arg.fd], eax
	mov dword [$io.fd], eax
	call connect
	call send
	mov dword [$io.len], 2
	call recv
	cmp word [.buf], 0x0005
	jnz handler
	ret
s5auth.buf:
	.ver:	db 5
	.len:	db 1
	.meth:	db 0
s5conn:
	ret
s5conn.buf:
	.ver:	db 5
	.cmd:	db 1
	.res:	db 0
;conv########################################################################
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
