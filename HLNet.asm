use64
section NetScript progbits alloc exec nowrite align=0
connect:
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
	
	
	mov dword [$tcp.path], 2
	mov dword [$tcp.fam], 1
	mov dword [$tcp.proto], 6
	
	mov dword [$sock.addr], $addr
	mov dword [$sock.len], 16
	
	mov word [$addr.fam], 2
	mov word [$addr.port], si
	mov dword [$addr.ip], 0
	mov qword [$addr.zero], 0
	
	
	mov rax, 102
	mov rbx, 1
	mov rcx, $tcp
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov dword [$sock.fd], eax
	mov rax, 102
	mov rbx, 2
	mov rcx, $sock
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov word [$addr.port], di
	mov dword [$addr.ip], edx
	
	mov rax, 102
	mov rbx, 3
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov ebx, dword [$sock.fd]
	ret

listen:
	mov word [$addr.zero+2], di
	mov dl, byte [$addr.zero+2]
	mov dh, byte [$addr.zero+3]
	mov byte [$addr.zero+3], dl
	mov byte [$addr.zero+2], dh
	mov di, word [$addr.zero+2]
	
	
	mov dword [$tcp.path], 2
	mov dword [$tcp.fam], 1
	mov dword [$tcp.proto], 6
	
	mov dword [$sock.addr], $addr
	mov dword [$sock.len], 16
	
	mov word [$addr.fam], 2
	mov word [$addr.port], di
	mov dword [$addr.ip], 0
	mov qword [$addr.zero], 0
	
	mov dword [$turn.conn], 0xFFFFFFFF
	
	
	mov rax, 102
	mov rbx, 1
	mov rcx, $tcp
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov dword [$turn.fd], eax
	mov dword [$sock.fd], eax
	
	mov rax, 102
	mov rbx, 2
	mov rcx, $sock
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov rax, 102
	mov rbx, 4
	mov rcx, $turn
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov ebx, dword [$turn.fd]
	ret

accept:
	mov dword [$sock.fd], edx
	mov dword [$sock.addr], $addr
	mov dword [$sock.len], $sock.len
	
	mov rax, 102
	mov rbx, 5
	mov rcx, $sock
	int 0x80
	cmp rax, -255
	jnc handler
	
	mov ebx, eax
	ret
section NetStruct progbits alloc noexec write align=0
$tcp:
	.path:	resb 4
	.fam:	resb 4
	.proto:	resb 4
$sock:
	.fd:	resb 4
	.addr:	resb 4
	.len:	resb 4
$addr:
	.fam:	resb 2
	.port:	resb 2
	.ip:	resb 4
	.zero:	resb 8
$turn:
	.fd:	resb 4
	.conn:	resb 4
