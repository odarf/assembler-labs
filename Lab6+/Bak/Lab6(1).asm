.586P
.MODEL FLAT, STDCALL
STD_OUTPUT_HANDLE   equ -11
STD_INPUT_HANDLE    equ -10
KEY_EV              equ 1h 
MOUSE_EV            equ 2h
;Это прототипы процедур для работы программы
;EXTERN WriteConsoleA@20:NEAR; - запись данных в консоль
;EXTERN SetConsoleCursorPosition@8:NEAR; - выбор позиции курсора
;EXTERN SetConsoleTitleA@4:NEAR; - получение заголовка консоли
;EXTERN FreeConsole@0:NEAR; - создание новой консоли
EXTERN wsprintfA:NEAR 
EXTERN GetStdHandle@4:NEAR
EXTERN WriteConsoleA@20:NEAR
EXTERN SetConsoleCursorPosition@8:NEAR
EXTERN SetConsoleTitleA@4:NEAR
EXTERN FreeConsole@0:NEAR
EXTERN AllocConsole@0:NEAR
EXTERN CharToOemA@8:NEAR
EXTERN SetConsoleTextAttribute@8:NEAR
EXTERN ReadConsoleA@20:NEAR 
;EXTERN timeSetEvent@20:NEAR 
;EXTERN timeKillEvent@4:NEAR 
EXTERN ExitProcess@4:NEAR
EXTERN ReadConsoleInputA@16:NEAR
;Директивы компоновщику для подключения библиотек.
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
;------------------------------------------------
COOR STRUC 
     X WORD ? 
     Y WORD ? 
COOR ENDS 
;Сегмент данных. Задаем все данные, которые будут на экране
_DATA SEGMENT PARA PUBLIC USE32 'DATA'
        HANDL  DWORD  ?
        HANDL1 DWORD  ?
        HANDL2 DWORD  ?
        TITL DB "Обработка событий мыши",0
        BUF  DB 200 dup(0)
        LENS DWORD ?
        CO   DWORD  ?
        FORM DB "Координаты: %u  %u  ",0
        CRD  COOR <?> 
        STR1 DB "Для выхода нажмите ESC.",0
        MOUS_KEY WORD 19 dup(?)
        STR2 DB "Студент группы ПО-71 Костюков А.М. " ,0		
_DATA ENDS 
;Сегмент кода, создаем консоль, получаем HANDL1 ввода и HANDL1 и HANDL2 вывода.
_TEXT SEGMENT PARA PUBLIC USE32 'CODE' 
START: 
        CALL FreeConsole@0
        CALL AllocConsole@0 
        PUSH STD_INPUT_HANDLE
        CALL GetStdHandle@4
        MOV  HANDL1,EAX 
        PUSH STD_OUTPUT_HANDLE
        CALL GetStdHandle@4
        MOV  HANDL,EAX
        PUSH STD_OUTPUT_HANDLE
        CALL GetStdHandle@4
        MOV  HANDL2,EAX         
;Задаем заголовок окна консоли.
        PUSH OFFSET TITL 
        PUSH OFFSET TITL 
        CALL CharToOemA@8 
        PUSH OFFSET TITL
        CALL SetConsoleTitleA@4
		;*************************************
;Перекодировка строки с помощью CharToOemA@8, чтобы выводился текст на русском языке.
        PUSH OFFSET STR2
        PUSH OFFSET STR2
        CALL CharToOemA@8 
;Длина строки. Вывод строки
        PUSH OFFSET STR2
        CALL LENSTR 
        PUSH 0
        PUSH OFFSET LENS
        PUSH EBX
        PUSH OFFSET STR2
        PUSH HANDL
        CALL WriteConsoleA@20
;*************************************   
;*************************************
;Перекодировка строки с помощью CharToOemA@8, чтобы выводился текст на русском языке.
        PUSH OFFSET STR1
        PUSH OFFSET STR1
        CALL CharToOemA@8 
;Длина строки. Вывод строки
        PUSH OFFSET STR1
        CALL LENSTR 
        PUSH 0
        PUSH OFFSET LENS
        PUSH EBX
        PUSH OFFSET STR1
        PUSH HANDL
        CALL WriteConsoleA@20
;*************************************

     
;Цикл ожиданий: движение мыши или нажатие ESC.
LOO:
;Задаем координаты курсора. 
        MOV  CRD.X,15 
        MOV  CRD.Y,15
        PUSH CRD 
        PUSH HANDL
        CALL SetConsoleCursorPosition@8 
;Прочитываем одну запись о событии.
	PUSH OFFSET CO
	PUSH 1  
	PUSH OFFSET MOUS_KEY
	PUSH HANDL1 
	CALL ReadConsoleInputA@16 
;Проверка мыши - сравнение координат мыши с буфером записей
	CMP  WORD PTR MOUS_KEY,MOUSE_EV 
JNE  LOO1;  - переход на LOO1, где цикл событий от клавиатуры
;Здесь преобразуем координаты мыши в строку. Y-мышь и X-мышь.
	MOV  AX,WORD PTR MOUS_KEY+6
;Копирование с обнулением старших битов. 
	MOVZX EAX,AX 
	PUSH EAX
	MOV  AX,WORD PTR MOUS_KEY+4
;Копирование с обнулением старших битов. 
	MOVZX EAX,AX 
	PUSH EAX
	PUSH OFFSET FORM 
	PUSH OFFSET BUF 
	CALL wsprintfA 
;Восстановление стека.
ADD  ESP,16
;Перекодировка строки для вывода. 
	PUSH OFFSET BUF 
	PUSH OFFSET BUF 
	CALL CharToOemA@8 
;Длина строки.
	PUSH OFFSET BUF 
	CALL LENSTR
;Вывод на экран координат курсора. 
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET BUF
	PUSH HANDL
	CALL WriteConsoleA@20
	JMP  LOO
LOO1: 
;Нет ли события от клавиатуры?
        CMP  WORD PTR MOUS_KEY,KEY_EV
        JNE  LOO ;Есть, какое?
        CMP  BYTE PTR MOUS_KEY+14,27
        JNE  LOO
;*************************************
;Закрытие консоли, завершение программы
	CALL FreeConsole@0
	PUSH 0
	CALL ExitProcess@4
	RET
;Процедура определения длины строки.
;Строка -   [EBP+08H].
;Длина в ЕВХ 
LENSTR PROC
      ENTER 0,0
      PUSH  EAX
;----------------------
      CLD
      MOV   EDI,DWORD PTR  [EBP+08H]
      MOV   EBX,EDI
      MOV   ECX,100 
      XOR   AL,AL
      REPNE SCASB
      SUB   EDI,EBX
      MOV   EBX,EDI
      DEC   EBX
;----------------------
      POP   EAX 
      LEAVE 
      RET   4
LENSTR ENDP
_TEXT  ENDS
       END START
