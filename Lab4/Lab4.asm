include \masm32\include\masm32rt.inc
.data
ms db 13,10,"Press Enter to Exit",10,13,0
inputms db "Input integer value ",0
outputms db "Results",10,13,0
pusto db " ",0
n1 db 10,13,0
.data?
inbuf db 100 dup (?)
a sdword 10 dup (?)
string db 16 dup (?)
.stack 4096
.code
start:
mov ecx,10
mov ebx,0
cycle: push ecx
invoke StdOut, addr inputms
invoke StdIn, addr inbuf,lengthof inbuf
invoke StripLF, addr inbuf
invoke atol,addr inbuf
mov a[ebx*4],eax
inc ebx
pop ecx
loop cycle
invoke StdOut,addr outputms
mov ecx,10
mov ebx,0
cycle2:push ecx
invoke dwtoa,a[ebx*4],addr string
invoke StdOut,addr string
invoke StdOut,addr pusto
inc ebx
pop ecx
loop cycle2
invoke StdOut,addr n1
invoke StdOut, addr ms
invoke StdIn,addr inbuf, lengthof inbuf
invoke ExitProcess,0
end start