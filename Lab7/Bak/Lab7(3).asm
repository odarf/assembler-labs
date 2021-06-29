.386P
.MODEL FLAT, STDCALL 					; Плоская модель памяти.
STD_OUTPUT_HANDLE	equ -11			; Константы.
STD_INPUT_HANDLE		equ -10
FOREGROUND_BLUE   equ  1h 			; Cиний цвет букв.
FOREGROUND_INTENSITY equ  8h 		; Повышенная интенсивность.
BACKGROUND_BLUE equ 10h 				; Синий цвет фона.
BACKGROUND_INTENSITY     equ 80h 		; Повышенная интенсивность.
COL1 = 1h+8h    							; Цвет выводимого текста.
COL2 = 1h+8h+10h 						; Цвет выводимого текста 2.
EXTERN WriteConsoleA@20:NEAR			; Запись данных в консоль
EXTERN ExitProcess@4:NEAR 					; Завершение процесса
EXTERN SetConsoleCursorPosition@8:NEAR ; Получение позиции курсора
EXTERN SetConsoleTitleA@4:NEAR 		; Получение заголовка консоли
EXTERN FreeConsole@0:NEAR 			; Освобождение консоли
EXTERN AllocConsole@0:NEAR 			; Создание консоли
EXTERN CharToOemA@8:NEAR
EXTERN GetStdHandle@4:NEAR
EXTERN ReadConsoleA@20:NEAR
EXTERN SetConsoleScreenBufferSize@8:NEAR
EXTERN SetConsoleTextAttribute@8:NEAR

includelib c:\masm32\lib\user32.lib		; Директивы подключения библиотек
includelib c:\masm32\lib\kernel32.lib
;------------------------------------------------
COOR STRUC 
     X WORD ? 
     Y WORD ? 
COOR ENDS 
_DATA SEGMENT PARA PUBLIC USE32 'DATA'	; Сегмент данных.
	HANDL  DWORD   ? 		; Задание строк для вывода на экран
	HANDL1 DWORD   ?
	STR3 DB "Павлов",13,10,0
	STR4 DB "ПО-52",13,10,0
	STR1 DB "Введите строку:",13,10,0
	STR2 DB "Работа консоли",0
	BUF  DB 200 dup(?)
	LENS DWORD ?
	CRD  COOR <?> 
_DATA ENDS 
_TEXT SEGMENT PARA PUBLIC USE32 'CODE' ; Сегмент кода.
START: 
	PUSH OFFSET STR1 	; Перекодируем строки, 
	PUSH OFFSET STR1 	; которые будут выводиться на экран
	CALL CharToOemA@8 
	PUSH OFFSET STR2 
	PUSH OFFSET STR2 
	CALL CharToOemA@8
	PUSH OFFSET STR3 
	PUSH OFFSET STR3 
	CALL CharToOemA@8
	PUSH OFFSET STR4 
	PUSH OFFSET STR4 
	CALL CharToOemA@8 
	CALL FreeConsole@0 		; Освобождаем существующую консоль
	CALL AllocConsole@0 	; Образуем консоль
	PUSH STD_INPUT_HANDLE  		; Получение HANDL1 ввода
	CALL GetStdHandle@4 
	MOV  HANDL1,EAX 
	PUSH STD_OUTPUT_HANDLE 	; Получение HANDL вывода
	CALL GetStdHandle@4 
	MOV  HANDL, EAX
	MOV  CRD.X,100 		; Установка нового размера окна консоли
	MOV  CRD.Y,25 
	PUSH CRD 
	PUSH EAX
	CALL SetConsoleScreenBufferSize@8 
	PUSH OFFSET  STR2 	; Задать заголовок окна консоли 
	CALL SetConsoleTitleA@4 
	MOV  CRD.X,15 			; Установка позиции курсора
	MOV  CRD.Y,15
	PUSH CRD
	PUSH HANDL
	CALL SetConsoleCursorPosition@8 
	PUSH COL1 ; Задаем цветовые атрибуты выводимого текста
	PUSH HANDL
	
		CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR3 	; Вывести строку STR1
	CALL LENSTR 		; В ЕВХ длина строки
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR3
	PUSH HANDL
	CALL WriteConsoleA@20

		CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR4 	; Вывести строку STR1
	CALL LENSTR 		; В ЕВХ длина строки
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR4
	PUSH HANDL
	CALL WriteConsoleA@20

	CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR1 	; Вывести строку STR1
	CALL LENSTR 		; В ЕВХ длина строки
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR1
	PUSH HANDL
	CALL WriteConsoleA@20
	
	       
	PUSH 0 			; Ожидание ввода строки.

	PUSH OFFSET LENS
	PUSH 200
	PUSH OFFSET BUF
	PUSH HANDL1
	CALL ReadConsoleA@20 
; Выводим полученную строку.
; Вначале задаем цветовые атрибуты выводимого текста.
	PUSH COL2
	PUSH HANDL
	CALL SetConsoleTextAttribute@8 
;------------------------------------------
      PUSH 0
      PUSH OFFSET LENS
      PUSH [LENS]
      PUSH OFFSET BUF
      PUSH HANDL
      CALL WriteConsoleA@20 
; Небольшая задержка.
	MOV  ECX,01FFFFFFFH 
L1:
	LOOP L1 
; Закрыть консоль, завершение работы программы
	CALL FreeConsole@0 
	CALL ExitProcess@4 
; Строка -   [EBP+08H].
; Длина в ЕВХ 
; Процедура работы со строкой
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
