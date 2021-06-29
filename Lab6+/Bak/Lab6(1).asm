.586P
.MODEL FLAT, STDCALL
STD_OUTPUT_HANDLE   equ -11
STD_INPUT_HANDLE    equ -10
KEY_EV              equ 1h 
MOUSE_EV            equ 2h
;��� ��������� �������� ��� ������ ���������
;EXTERN WriteConsoleA@20:NEAR; - ������ ������ � �������
;EXTERN SetConsoleCursorPosition@8:NEAR; - ����� ������� �������
;EXTERN SetConsoleTitleA@4:NEAR; - ��������� ��������� �������
;EXTERN FreeConsole@0:NEAR; - �������� ����� �������
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
;��������� ������������ ��� ����������� ���������.
includelib c:\masm32\lib\user32.lib
includelib c:\masm32\lib\kernel32.lib
;------------------------------------------------
COOR STRUC 
     X WORD ? 
     Y WORD ? 
COOR ENDS 
;������� ������. ������ ��� ������, ������� ����� �� ������
_DATA SEGMENT PARA PUBLIC USE32 'DATA'
        HANDL  DWORD  ?
        HANDL1 DWORD  ?
        HANDL2 DWORD  ?
        TITL DB "��������� ������� ����",0
        BUF  DB 200 dup(0)
        LENS DWORD ?
        CO   DWORD  ?
        FORM DB "����������: %u  %u  ",0
        CRD  COOR <?> 
        STR1 DB "��� ������ ������� ESC.",0
        MOUS_KEY WORD 19 dup(?)
        STR2 DB "������� ������ ��-71 �������� �.�. " ,0		
_DATA ENDS 
;������� ����, ������� �������, �������� HANDL1 ����� � HANDL1 � HANDL2 ������.
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
;������ ��������� ���� �������.
        PUSH OFFSET TITL 
        PUSH OFFSET TITL 
        CALL CharToOemA@8 
        PUSH OFFSET TITL
        CALL SetConsoleTitleA@4
		;*************************************
;������������� ������ � ������� CharToOemA@8, ����� ��������� ����� �� ������� �����.
        PUSH OFFSET STR2
        PUSH OFFSET STR2
        CALL CharToOemA@8 
;����� ������. ����� ������
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
;������������� ������ � ������� CharToOemA@8, ����� ��������� ����� �� ������� �����.
        PUSH OFFSET STR1
        PUSH OFFSET STR1
        CALL CharToOemA@8 
;����� ������. ����� ������
        PUSH OFFSET STR1
        CALL LENSTR 
        PUSH 0
        PUSH OFFSET LENS
        PUSH EBX
        PUSH OFFSET STR1
        PUSH HANDL
        CALL WriteConsoleA@20
;*************************************

     
;���� ��������: �������� ���� ��� ������� ESC.
LOO:
;������ ���������� �������. 
        MOV  CRD.X,15 
        MOV  CRD.Y,15
        PUSH CRD 
        PUSH HANDL
        CALL SetConsoleCursorPosition@8 
;����������� ���� ������ � �������.
	PUSH OFFSET CO
	PUSH 1  
	PUSH OFFSET MOUS_KEY
	PUSH HANDL1 
	CALL ReadConsoleInputA@16 
;�������� ���� - ��������� ��������� ���� � ������� �������
	CMP  WORD PTR MOUS_KEY,MOUSE_EV 
JNE  LOO1;  - ������� �� LOO1, ��� ���� ������� �� ����������
;����� ����������� ���������� ���� � ������. Y-���� � X-����.
	MOV  AX,WORD PTR MOUS_KEY+6
;����������� � ���������� ������� �����. 
	MOVZX EAX,AX 
	PUSH EAX
	MOV  AX,WORD PTR MOUS_KEY+4
;����������� � ���������� ������� �����. 
	MOVZX EAX,AX 
	PUSH EAX
	PUSH OFFSET FORM 
	PUSH OFFSET BUF 
	CALL wsprintfA 
;�������������� �����.
ADD  ESP,16
;������������� ������ ��� ������. 
	PUSH OFFSET BUF 
	PUSH OFFSET BUF 
	CALL CharToOemA@8 
;����� ������.
	PUSH OFFSET BUF 
	CALL LENSTR
;����� �� ����� ��������� �������. 
	PUSH 0
	PUSH OFFSET LENS
	PUSH EBX
	PUSH OFFSET BUF
	PUSH HANDL
	CALL WriteConsoleA@20
	JMP  LOO
LOO1: 
;��� �� ������� �� ����������?
        CMP  WORD PTR MOUS_KEY,KEY_EV
        JNE  LOO ;����, �����?
        CMP  BYTE PTR MOUS_KEY+14,27
        JNE  LOO
;*************************************
;�������� �������, ���������� ���������
	CALL FreeConsole@0
	PUSH 0
	CALL ExitProcess@4
	RET
;��������� ����������� ����� ������.
;������ -   [EBP+08H].
;����� � ��� 
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
