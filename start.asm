%include "dbg.asm"
%include "HLNet.asm"
%include "HLSec.asm"
use64
global _start
section prog progbits alloc exec write align=0
_start:
	mov qword [rsp], handler
	jmp main
handler:
	jmp $
main:
	mov di, 9050
	call s5auth
	mov rax, 1
	mov rbx, 0
	int 0x80
