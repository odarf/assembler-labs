.386; тип пpоцессоp 80386

.model flat,stdcall ; Плоская модель памяти

option casemap:none ; Чувствительность к регистрам, none - ее нет

; Подключаем библиотеки, необходимые для работы программы.

include \masm32\include\masm32rt.inc

include \masm32\include\windows.inc

include \masm32\include\user32.inc

include \masm32\include\kernel32.inc

includelib \masm32\includelib\user32.lib

includelib \masm32\includelib\kernel32.lib

WinMain proto :DWORD,:DWORD,:DWORD,:DWORD

; Сегмент данных 

; Инициализируемые -  имя класса и заголовок окна, сообщение

; Неинициализиpуемые - дескриптор программы и командная строка

.DATA

                     

ClassName db "SimpleWinClass",0

AppName db "Группа ПО-72",0

OurText db "Костюков"

.DATA?

hInstance HINSTANCE ?       

CommandLine LPSTR   ?

; Сегменткода

.CODE                

start:

invoke GetModuleHandle, NULL  

mov hInstance, eax

invoke GetCommandLine

mov CommandLine, eax

; Вызываемосновнуюфункциюпрограммы

invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 

; Выход из программы

invoke ExitProcess, eax

; Процедура, в которой создается окно с сообщением: создаются локальные

; переменные, задается размер окна, его цвет, задаётся класс окна, 

; затемрегистрацияклассаокна

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 

LOCAL wc:WNDCLASSEX 

LOCAL msg:MSG 

LOCAL hwnd:HWND 

; Заполнениестpуктуpыwc. 

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

    ; pегистpация нашего класса окна

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

; Задаем функцию, которая позволит отобразить окно на рабочем столе. 

invoke ShowWindow, hwnd,SW_SHOWNORMAL 

invoke UpdateWindow, hwnd 

.WHILE TRUE   

invoke GetMessage, ADDR msg,NULL,0,0 

.BREAK .IF (!eax) 

invoke TranslateMessage, ADDR msg 

invoke DispatchMessage, ADDR msg 

.ENDW

; Сохpанениевозвpащаемогозначениявeax. 

mov eax,msg.wParam 

ret

WinMain endp

; Процедура, где выводится текст по центру в окне. 

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM

LOCAL hdc:HDC

LOCAL ps:PAINTSTRUCT

LOCAL rect:RECT

; Цикл закрытия окна, функция выхода из программы 

.IF uMsg==WM_DESTROY            

.ELSEIF uMsg==WM_PAINT

; Описываем функции, где задаем параметры вывода текста. 

invoke BeginPaint,hWnd, ADDR ps 

mov hdc, eax 

invoke GetClientRect,hWnd, ADDR rect 

invoke DrawText, hdc,ADDR OurText,-1, ADDR rect, DT_SINGLELINE or DT_CENTER or 

DT_VCENTER 

invoke EndPaint,hWnd, ADDR ps 

 .ELSE

; Функцияобpаботкиокна. 

invoke DefWindowProc,hWnd,uMsg,wParam,lParam

ret

.ENDIF

invoke PostQuitMessage,NULL 

xor eax, eax

ret

; Завершение процедуры и конец программы.

WndProc endp

end start
