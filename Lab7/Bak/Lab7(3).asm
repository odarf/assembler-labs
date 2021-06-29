.386P
.MODEL FLAT, STDCALL 					; ������� ������ ������.
STD_OUTPUT_HANDLE	equ -11			; ���������.
STD_INPUT_HANDLE		equ -10
FOREGROUND_BLUE   equ  1h 			; C���� ���� ����.
FOREGROUND_INTENSITY equ  8h 		; ���������� �������������.
BACKGROUND_BLUE equ 10h 				; ����� ���� ����.
BACKGROUND_INTENSITY     equ 80h 		; ���������� �������������.
COL1 = 1h+8h    							; ���� ���������� ������.
COL2 = 1h+8h+10h 						; ���� ���������� ������ 2.
EXTERN WriteConsoleA@20:NEAR			; ������ ������ � �������
EXTERN ExitProcess@4:NEAR 					; ���������� ��������
EXTERN SetConsoleCursorPosition@8:NEAR ; ��������� ������� �������
EXTERN SetConsoleTitleA@4:NEAR 		; ��������� ��������� �������
EXTERN FreeConsole@0:NEAR 			; ������������ �������
EXTERN AllocConsole@0:NEAR 			; �������� �������
EXTERN CharToOemA@8:NEAR
EXTERN GetStdHandle@4:NEAR
EXTERN ReadConsoleA@20:NEAR
EXTERN SetConsoleScreenBufferSize@8:NEAR
EXTERN SetConsoleTextAttribute@8:NEAR

includelib c:\masm32\lib\user32.lib		; ��������� ����������� ���������
includelib c:\masm32\lib\kernel32.lib
;------------------------------------------------
COOR STRUC 
     X WORD ? 
     Y WORD ? 
COOR ENDS 
_DATA SEGMENT PARA PUBLIC USE32 'DATA'	; ������� ������.
	HANDL  DWORD   ? 		; ������� ����� ��� ������ �� �����
	HANDL1 DWORD   ?
	STR3 DB "������",13,10,0
	STR4 DB "��-52",13,10,0
	STR1 DB "������� ������:",13,10,0
	STR2 DB "������ �������",0
	BUF  DB 200 dup(?)
	LENS DWORD ?
	CRD  COOR <?> 
_DATA ENDS 
_TEXT SEGMENT PARA PUBLIC USE32 'CODE' ; ������� ����.
START: 
	PUSH OFFSET STR1 	; ������������ ������, 
	PUSH OFFSET STR1 	; ������� ����� ���������� �� �����
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
	CALL FreeConsole@0 		; ����������� ������������ �������
	CALL AllocConsole@0 	; �������� �������
	PUSH STD_INPUT_HANDLE  		; ��������� HANDL1 �����
	CALL GetStdHandle@4 
	MOV  HANDL1,EAX 
	PUSH STD_OUTPUT_HANDLE 	; ��������� HANDL ������
	CALL GetStdHandle@4 
	MOV  HANDL, EAX
	MOV  CRD.X,100 		; ��������� ������ ������� ���� �������
	MOV  CRD.Y,25 
	PUSH CRD 
	PUSH EAX
	CALL SetConsoleScreenBufferSize@8 
	PUSH OFFSET  STR2 	; ������ ��������� ���� ������� 
	CALL SetConsoleTitleA@4 
	MOV  CRD.X,15 			; ��������� ������� �������
	MOV  CRD.Y,15
	PUSH CRD
	PUSH HANDL
	CALL SetConsoleCursorPosition@8 
	PUSH COL1 ; ������ �������� �������� ���������� ������
	PUSH HANDL
	
		CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR3 	; ������� ������ STR1
	CALL LENSTR 		; � ��� ����� ������
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR3
	PUSH HANDL
	CALL WriteConsoleA@20

		CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR4 	; ������� ������ STR1
	CALL LENSTR 		; � ��� ����� ������
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR4
	PUSH HANDL
	CALL WriteConsoleA@20

	CALL SetConsoleTextAttribute@8       
	PUSH OFFSET STR1 	; ������� ������ STR1
	CALL LENSTR 		; � ��� ����� ������
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET STR1
	PUSH HANDL
	CALL WriteConsoleA@20
	
	       
	PUSH 0 			; �������� ����� ������.

	PUSH OFFSET LENS
	PUSH 200
	PUSH OFFSET BUF
	PUSH HANDL1
	CALL ReadConsoleA@20 
; ������� ���������� ������.
; ������� ������ �������� �������� ���������� ������.
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
; ��������� ��������.
	MOV  ECX,01FFFFFFFH 
L1:
	LOOP L1 
; ������� �������, ���������� ������ ���������
	CALL FreeConsole@0 
	CALL ExitProcess@4 
; ������ -   [EBP+08H].
; ����� � ��� 
; ��������� ������ �� �������
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
