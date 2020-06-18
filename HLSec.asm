use64
section SecScript progbits alloc exec write align=0
s5auth:
	mov byte [$auth.ver], 5
	mov byte [$auth.len], 1
	mov byte [$auth.meth], 0
	
	call connect
	
	mov rax, 4
	mov rcx, $auth
	mov rdx, 3
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov rdx, 2
.r:	mov rax, 3
	int 0x80
	cmp rax, -255
	jnc handler
	add rcx, rax
	sub rdx, rax
	jnz .r
	
	cmp word [$auth], 0x5
	jnz handler
	ret

s5conn:
	mov dword [$addr.zero], edx
	mov dh, byte [$addr.zero+3]
	mov byte [$addr.zero+3], dl
	mov byte [$addr.zero], dh
	mov dl, byte [$addr.zero+1]
	mov dh, byte [$addr.zero+2]
	mov byte [$addr.zero+2], dl
	mov byte [$addr.zero+1], dh
	mov edx, dword [$addr.zero]
	
	mov word [$addr.zero+2], si
	mov dl, byte [$addr.zero+2]
	mov dh, byte [$addr.zero+3]
	mov byte [$addr.zero+3], dl
	mov byte [$addr.zero+2], dh
	mov si, word [$addr.zero+2]
	
	mov word [$addr.zero+2], di
	mov dl, byte [$addr.zero+2]
	mov dh, byte [$addr.zero+3]
	mov byte [$addr.zero+3], dl
	mov byte [$addr.zero+2], dh
	mov di, word [$addr.zero+2]
	
	mov dx, word [$addr.zero]
	
	
	mov byte [$conn.ver], 5
	mov byte [$conn.cmd], 1
	mov byte [$conn.res], 0
	mov byte [$conn.type], 1
	mov dword [$conn.ip], edx
	mov word [$conn.port], di
	
	
	mov rax, 4
	mov rcx, $conn
	mov rdx, 10
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov rdx, 10
.r:	mov rax, 3
	int 0x80
	cmp rax, -255
	jnc handler
	add rcx, rax
	sub rdx, rax
	jnz .r
	
	cmp word [$conn], 0x1000005
	jnz handler
	
	mov rax, 6
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov edx, dword [$conn.ip]
	mov di, word [$conn.port]
	jmp connect+159

section SecStruct progbits alloc exec write align=0
$auth:
	.ver:	resb 1
	.len:	resb 1
	.meth:	resb 1
$conn:
	.ver:	resb 1
	.cmd:	resb 1
	.res:	resb 1
	.type:	resb 1
	.ip:	resb 4
	.port:	resb 2
