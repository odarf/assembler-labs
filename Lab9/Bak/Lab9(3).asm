.386; ��� �p������p 80386

.model flat,stdcall ; ������� ������ ������

option casemap:none ; ���������������� � ���������, none - �� ���

; ���������� ����������, ����������� ��� ������ ���������.

include \masm32\include\masm32rt.inc

include \masm32\include\windows.inc

include \masm32\include\user32.inc

include \masm32\include\kernel32.inc

includelib \masm32\includelib\user32.lib

includelib \masm32\includelib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

; ������� ������ 

; ���������������� -  ��� ������ � ��������� ����, ���������

; ������������p����� - ���������� ��������� � ��������� ������

.DATA

                     

ClassName db "SimpleWinClass",0

AppName db "������ ��-72",0

OurText db "��������"

.DATA?

hInstance HINSTANCE ?       

CommandLine LPSTR   ?

; �����������

.CODE                

start:

invoke GetModuleHandle, NULL  

mov hInstance, eax

invoke GetCommandLine

mov CommandLine, eax

; ��������������������������������

invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 

; ����� �� ���������

invoke ExitProcess, eax

; ���������, � ������� ��������� ���� � ����������: ��������� ���������

; ����������, �������� ������ ����, ��� ����, ������� ����� ����, 

; ��������������������������

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 

LOCAL wc:WNDCLASSEX 

LOCAL msg:MSG 

LOCAL hwnd:HWND 

; ������������p����p�wc. 

mov wc.cbSize,SIZEOF WNDCLASSEX    

mov wc.style, CS_HREDRAW or CS_VREDRAW 

mov wc.lpfnWndProc, OFFSET WndProc 

mov wc.cbClsExtra,NULL 

mov wc.cbWndExtra,NULL 

push  hInst 

pop wc.hInstance 

mov   wc.hbrBackground,COLOR_WINDOW+1 

mov wc.lpszMenuName,NULL 

mov wc.lpszClassName,OFFSET ClassName 

invoke LoadIcon,NULL,IDI_APPLICATION 

mov wc.hIcon,eax 

mov wc.hIconSm,eax 

invoke LoadCursor,NULL,IDC_ARROW 

mov wc.hCursor,eax

    ; p�����p���� ������ ������ ����

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

mov hwnd, eax

; ������ �������, ������� �������� ���������� ���� �� ������� �����. 

invoke ShowWindow, hwnd,SW_SHOWNORMAL 

invoke UpdateWindow, hwnd 

.WHILE TRUE   

invoke GetMessage, ADDR msg,NULL,0,0 

.BREAK .IF (!eax) 

invoke TranslateMessage, ADDR msg 

invoke DispatchMessage, ADDR msg 

.ENDW

; ���p����������p�����������������eax. 

mov eax,msg.wParam 

ret

WinMain endp

; ���������, ��� ��������� ����� �� ������ � ����. 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

LOCAL hdc:HDC

LOCAL ps:PAINTSTRUCT

LOCAL rect:RECT

; ���� �������� ����, ������� ������ �� ��������� 

.IF uMsg==WM_DESTROY            

.ELSEIF uMsg==WM_PAINT

; ��������� �������, ��� ������ ��������� ������ ������. 

invoke BeginPaint,hWnd, ADDR ps 

mov hdc, eax 

invoke GetClientRect,hWnd, ADDR rect 

invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, DT_SINGLELINE or DT_CENTER or 

DT_VCENTER 

invoke EndPaint,hWnd, ADDR ps 

 .ELSE

; ���������p����������. 

invoke DefWindowProc,hWnd,uMsg,wParam,lParam

ret

.ENDIF

invoke PostQuitMessage,NULL 

xor eax, eax

ret

; ���������� ��������� � ����� ���������.

WndProc endp

end start
