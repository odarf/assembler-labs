include /masm32/include/masm32rt.inc
.data
a sword 15
b sword 9
vc sword 15
result db 10 dup (' '),0
res1 db "не а и не b = ",0
res2 db 13,10,"сдвиг влево a на 2= "
.code
start:
mov ax,a
mov bx,b
not ax
not bx
and ax,bx
mov a,ax

invoke dwtoa,a,addr result
invoke StdOut, addr res1
invoke StdOut, addr result
mov ax,vc
shl ax,2
mov a,ax
invoke dwtoa,a,addr result
invoke StdOut, addr res2
invoke StdOut, addr result
invoke StdIn, addr result, LengthOf result
invoke ExitProcess,0
end start