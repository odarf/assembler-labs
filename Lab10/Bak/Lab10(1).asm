.586 					; ��� ���������� .386
.model flat,stdcall 			; ������� ������ ������
option casemap:none 		; ���������������� � ���������
; ����������� ��������� include windows.inc
include /masm32/include/windows.inc 	; ���������� ����������
include /masm32/include/user32.inc
include /masm32/include/kernel32.inc
include /masm32/include/gdi32.inc
includelib /masm32/lib/user32.lib
includelib /masm32/libkernel32.lib
includelib /masm32/libgdi32.lib
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD
; ���������p����� ������.
.DATA                
; ��� ������ ����.      
ClassName db "SimpleWinClass",0        
; ��� ����.
AppName db "���� ����� ����� ����� ������� �����, �� ��� ��������.",0                    
MouseClick db 0  
; H����������p����� ������. ���������� ����� �p��p����.  
.DATA?                               
	hInstance HINSTANCE ?       
	CommandLine LPSTR ?
	hitpoint POINT <>
; ����� ���������� ���.
.CODE               
start:
; ����� ���������� �p��p����.
invoke GetModuleHandle, NULL  
mov hInstance,eax
; ����� ��������� ��p���.
invoke GetCommandLine    
; �������� �������, ���� �p��p���� �� ��p��������� ��������� ��p���
mov CommandLine,eax
; ������� �������� �������
invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT    
; ����� �� �p��p����..
invoke ExitProcess, eax      
; ����p������� ��������, ���������� � eax, ��p���� �� WinMain.
WinMain proc   hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD
;�������� ��������� ��p������� � �����.
	LOCAL wc:WNDCLASSEX      
	LOCAL msg:MSG
	LOCAL hwnd:HWND
; ���������� ��p����p� wc.
	mov   wc.cbSize,SIZEOF WNDCLASSEX   
	mov   wc.style, CS_HREDRAW or CS_VREDRAW
	mov   wc.lpfnWndProc, OFFSET WndProc
	mov   wc.cbClsExtra,NULL
	mov   wc.cbWndExtra,NULL
	push  hInstance ;hInst
	pop   wc.hInstance
	mov   wc.hbrBackground,COLOR_WINDOW+1
	mov   wc.lpszMenuName,NULL
	mov   wc.lpszClassName,OFFSET ClassName
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov   wc.hIcon,eax
	mov   wc.hIconSm,eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov   wc.hCursor,eax
; ������p���� ������ ����.
	invoke RegisterClassEx, addr wc  
	invoke CreateWindowEx,NULL,\
		ADDR ClassName,\
		 ADDR AppName,\
		WS_OVERLAPPEDWINDOW,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
		CW_USEDEFAULT,\
		NULL,\
		NULL,\
		hInst,\
		NULL
	mov   hwnd,eax
; ����p����� ���� �� ��������.
	invoke ShowWindow, hwnd,CmdShow   
; �������� ���������� �������.
	invoke UpdateWindow, hwnd   
	.WHILE TRUE   
		invoke GetMessage, ADDR msg,NULL,0,0
		.BREAK .IF (!eax)
		invoke DispatchMessage, ADDR msg
	.ENDW
; ���p������ ����p�������� �������� � eax.
	mov     eax,msg.wParam  
	ret
WinMain endp
WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM
LOCAL hdc:HDC
LOCAL ps:PAINTSTRUCT
; ���� ������������ ���p����� ����.
	.IF uMsg==WM_DESTROY      
; �� ������� �� �p��p���� .     
	invoke PostQuitMessage,NULL    
	.ELSEIF uMsg==WM_LBUTTONDOWN
		mov eax,lParam
		and eax,0FFFFh
		mov hitpoint.x,eax
		mov eax,lParam
		shr eax,16
		mov hitpoint.y,eax
		mov MouseClick,TRUE
		invoke InvalidateRect,hWnd,NULL,TRUE
	.ELSEIF uMsg==WM_PAINT
		invoke BeginPaint,hWnd, ADDR ps
		mov    hdc,eax
	.IF MouseClick
		invoke lstrlen,ADDR AppName
		invoke TextOut,hdc,hitpoint.x,hitpoint.y,ADDR AppName,eax
	.ENDIF
		invoke EndPaint,hWnd, ADDR ps
	.ELSE
; ������� ��p������ ����.
	invoke DefWindowProc,hWnd,uMsg,wParam,lParam     
	ret
	.ENDIF
	xor eax,eax
	ret
WndProc endp
end start
