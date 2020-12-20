
set_cursor macro i,j                   
        mov ah,2
        mov bh,0
        mov dh,i
        mov dl,j
        int 10h
endm
show_string macro i,j,k
        set_cursor i,j
        mov dx,DATAS
        mov ds,dx
      mov ah,9
      mov dx,offset k
      int 21h
endm
show_string1 macro name
        mov dx,offset name
        mov ah,9
        int 21h
endm
delay MACRO
   jmp $+2
   jmp $+2
endm
get_dh MACRO 
    push dx
    push ax 
    set_cursor 2,58
    mov ah,8
    int 10H
    CALL SUB_AL
    mov SIZE_DH,al
    ADD SIZE_DH,6 
    pop  ax 
    pop  dx
    set_cursor dh,dl  
endm 
get_dl MACRO
    push dx 
    push ax 
    push cx
    set_cursor 2,59
    mov ah,8
    int 10H
    CALL SUB_AL 
    mov cl,al
    mov ax,3
    mul cl
    mov size_dl,al
    add size_dl,4
    pop  cx  
    pop  ax 
    pop  dx
    set_cursor dh,dl  
endm 
mess segment
        dw 128 dup(0)
mess ends 
size_num segment
        dW 128 dup(0)
size_num ends 
stack segment stack
        dw 128 dup(0)
stack ends
acpi_table_address segment
        dd 128 dup(0)
acpi_table_address ends 
;----------------------------------------------------------------------
DATAS SEGMENT

MESS_IOS DB 'IO Space   START:0000  END:0100'           ; IO SPACE MESS 
MESS_IOS_LEN=$-OFFSET MESS_IOS                       

MESS_ADDRESS DB 'Address: '          ; MEMORY MESS
MESS_ADDRESS_LEN=$-OFFSET MESS_ADDRESS
MESS_ADDRESS_TYPE DB 'Type:Memory    Address  0000000000000000'
MESS_ADDRESS_TYPE_LEN=$-OFFSET MESS_ADDRESS_TYPE

MESS_CMOS DB 'Devive: CMOS'                             ; CMOS MESS
MESS_CMOS_LEN=$-OFFSET MESS_CMOS                     
MESS_CMOS_TYPE DB 'Type:ISA    Port 0070,0071'
MESS_CMOS_TYPE_LEN=$-OFFSET MESS_CMOS_TYPE

MESS_SIO DB 'Super  IO: ITE - ID 8625'                  ; SUPER IO 
MESS_SIO_LEN=$-OFFSET MESS_SIO                     
MESS_SIO_TYPE DB 'Type:ISA    Port 002E,002F   LDN 00'
MESS_SIO_TYPE_LEN=$-OFFSET MESS_SIO_TYPE

MESS_PCI DB 'DEVICE:D00:F00       '                           ; PCI 
MESS_PCI_LEN=$-OFFSET MESS_PCI                    
MESS_PCI_TYPE DB 'Type:PCI   Bus 00   Device 00   Function 00'
MESS_PCI_TYPE_LEN=$-OFFSET MESS_PCI_TYPE 
BUFF_NUM DB 'bus:device:function:'

MESS_E820 DB 'Start Address                Size        Type          Extended Attr.                  '    
MESS_E820_LEN=$-OFFSET MESS_E820                    
MESS_E820_PAGE DB 'Page 01/02'
MESS_E820_PAGE_LEN=$-OFFSET MESS_E820_PAGE

MESS_SMBUS DB 'SMBus Controller: D31:F4   Intel SMBUS '          
MESS_SMBUS_LEN=$-OFFSET MESS_SMBUS                    
MESS_SMBUS_TYPE DB 'Type:SMBus   Base F040   SlaveAddress A4   Count 200'
MESS_SMBUS_TYPE_LEN=$-OFFSET MESS_SMBUS_TYPE 

MESS_SMBIOS DB '(000) SMBIOS INFORMATION                         Size:    Addr:        '          
MESS_SMBIOS_LEN=$-OFFSET MESS_SMBIOS  
MESS_SMBIOS_TYPE DB 'Type:SMBIOS   Index 0000/0053'
MESS_SMBIOS_TYPE_LEN=$-OFFSET MESS_SMBIOS_TYPE 

MESS_MSR DB 'MSR:Information    '
MESS_MSR_LEN=$-OFFSET MESS_MSR 
MESS_MSR_TYPE DB 'Type:Intel CPU MSRs   CPU# 00'
MESS_MSR_TYPE_LEN=$-OFFSET MESS_MSR_TYPE 

MESS_ACPI DB 'ACPI table:                 ADDRESS:             Size:    '
MESS_ACPI_LEN=$-OFFSET MESS_ACPI 
MESS_ACPI_TYPE DB 'Type:ACPI table'
MESS_ACPI_TYPE_LEN=$-OFFSET MESS_ACPI_TYPE 
MESS_ACPI_TO DB '->'
;-----------------------------------------------------------------------
OPT_IOS DB 'IO SPACE'                 ; OPTIONS OF MANU 
OPT_IOS_LEN=$-OFFSET OPT_IOS          ; DH=8               ; MANU MESS
OPT_MEMORY DB 'MEMORY'                
OPT_MEMORY_LEN=$-OFFSET OPT_MEMORY
OPT_CMOS DB 'CMOS'
OPT_CMOS_LEN=$-OFFSET OPT_CMOS
OPT_SIO DB 'SUPER IO'
OPT_SIO_LEN=$-OFFSET OPT_SIO
OPT_PCI DB 'PCI'
OPT_PCI_LEN=$-OFFSET OPT_PCI
OPT_E820 DB 'E820'
OPT_E820_LEN=$-OFFSET OPT_E820
OPT_SMBUS DB 'SMBus'
OPT_SMBUS_LEN=$-OFFSET OPT_SMBUS
OPT_SMBIOS DB 'SMBIOS'
OPT_SMBIOS_LEN=$-OFFSET OPT_SMBIOS
OPT_MSR DB 'MSR'
OPT_MSR_LEN=$-OFFSET OPT_MSR
OPT_ACPI DB 'ACPI'
OPT_ACPI_LEN=$-OFFSET OPT_ACPI
OPT_EXIT DB 'EXIT'
OPT_EXIT_LEN=$-OFFSET OPT_EXIT
;-----------------------------------------------------------------------
WINWIDTH    =    80         ; PARAMETER OF WINDOWS
WINTOP      =     0
WINLEFT     =     0                                  
WINBOTTOM   =    24
WINRIGHT    =   WINLEFT+WINWIDTH-1   
;-----------------------------------------------------------------------
ESCKEY      =   1BH         ; THE ASCII OF key 'ESC' ON KEYBOARD
COUNT_OPTS  DB    0         ; COUNT THE NUMBER OF OPTIONS IN MANU 
IOS_PORT    DW    0         ; IO_SPACE_PRO
CMOS_PORT   DB    0
COOR_VAR    DW    0         ; COORDINATE SYSTEM 
MANU_OPT    DB    0         ; OPTIONS IN MANU 
COUNT_SHOW_ARDS_NUM DW 0    ; E820
SIO_PORT    DB    0         ; SIO_PRO      ; SIO_AL
CHOOSE_LDN  DB    0         ; SUPER IO     ; CHOOSE LDN 
VAR_ADD     DW    0         ; MEMORY_SEG
STORE_COLOR DB    0         ; CHANGE ; STORE COLOR OF BL 
SOTRE_AL    DB    0
CHANGE_StoreDX  DW  0       ; CHANGE ; STORE DX 
VAR_SI      DW    0         ; CHANGE ; MEMORY;
StoreAH DB    0         ; PCI_COOR_DATA 
DIVISORS            DW    10000, 1000, 100, 10, 1 
RESULTS             DB    0,0,0,0,0,"$"       ;存放五位数ASCII码

BUSNUM      DB    0000H     ; 0 - 00FFh         ;PCI
DEVNUM      DB    001FH     ; 0 - 001Fh
FUNNUM      DB    0007H     ; 0 - 0007h
REGNUM      DB    00FFH     ; 0 - 00FFh

DATA_EXPRESS  DW    0                                       
ARDS_NUM      DW    0           ; E820
SHOW_ARDS_NUM DW    0
E820_PAGE     DB    0
HADDR         DD    0
LADDR         DD    0
buffer db 4 dup(0),'$'
kb  db 'KB$'
mb  db 'MB$'
gb  db 'GB$'
b1 db '1=Available$'
b2 db '2=Reserved$'
b3 db '3=ACPI Data$'
b4 db '4=ACPI NVS$'
leftk db '($'
righk db ')$'
size1 dd 0
size2 dw 0
REG_NO dd 0
DL_NO db 0
DH_NO db 0

HST_STS    EQU 0H
HST_CNT    EQU 2H
HST_CMD    EQU 3H
XMIT_SLAVE EQU 4H
HST_D0     EQU 5H
sm_base    EQU 0f040H
REG        DB  0

STRU_MAX_SIZE  DD   0            ; SMBIOS 
EPS_OFFSET     DW   0
JUDGE_00       DB   1
JUDGE_0000     DB   1
ADDR_TYPE0     DW   0
SMBIOS_SIZE    DW   0
DATA_LENGTH    DB   0
STORE_SIZE     DW   0
SIZE_DH        DB   0
SIZE_DL        DB   0

MSR_ADD               DD   0       ; MSR
STORE_EAX             DD   0 
STORE_EDX             DD   0 

COOR_COLOMN           DB   0        ;  ACPI  
COOR_LAST_ROW         DW   0       
COUNT_NUM             DW   0
ACPI_TABLE_NAME       DD   0
ACPI_TABLE_NUM        DD   0

DATAS ENDS
;--------------------------------------------
     .386
CSEG SEGMENT USE16
     ASSUME CS:CSEG,DS:DATAS,SS:STACK 
START:                   ;------------------The program starts here
    MOV AL,0             ; USE PAGE 0                  
    MOV AH,5                
    INT 10
    MOV BH,07H           ; SET BLACK WHITE 
    CALL SET_WINDOWS
    CALL OPTIONS          ; OF MAMU 
    CALL MANU_OPERATION      
  OVER:                          
    CALL ENDING                ;The program END here
;------------------------------
MANU_OPERATION:                ;----------------------- FUNCTION :CHOOSE FUNCTION 
    MOV BH,0 
    MOV BL,07H  ;BLACK WHITE                   
    MOV CX,1
    MOV DL,28
    MOV DH,8
  CLEAR_STAR:  ; CLEAR '*' OF MANU 
    MOV AH,2
    INT 10H
    MOV AL,0
    MOV AH,9
    INT 10H
    INC DH
    CMP DH,14                
    JLE CLEAR_STAR    ; <= , JUMP 

    set_cursor 8,28
    MOV AH,9
    MOV AL,2AH     ;  ' * '
    INT 10H
  MANU_INPUT:          
    MOV AH,1
    INT 16H
    JZ MANU_INPUT 
    MOV AH,0                    ; INPUT A KEY 
    INT 16H 
    CMP AH,48H                  ; UP
    JE JMP_M_UP
    CMP AH,50H                  ; DOWN 
    JE JMP_M_DOWN
    CMP AL,0DH                  ; ENTER
    JE CHOSE_FUNCTION
    JMP MANU_INPUT  
;-----------------------  
JMP_M_UP:CALL M_UP
         JMP MANU_INPUT
JMP_M_DOWN:CALL M_DOWN
         JMP MANU_INPUT 
CHOSE_FUNCTION:       
    CMP DH,8
    JE SHOW_IO_SPACE
    CMP DH,9
    JE SHOW_MEMORY
    CMP DH,10
    JE SHOW_CMOS
    CMP DH,11
    JE SHOW_SIO  
    CMP DH,12
    JE SHOW_PCI
    CMP DH,13
    JE SHOW_E820
    CMP DH,14
    JE SHOW_SMBus 
    CMP DH,15
    JE SHOW_SMBios
    CMP DH,16
    JE SHOW_MSR
    CMP DH,17
    JE SHOW_ACPI
    CMP DH,18
    JE OVER
    JMP OVER
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
SHOW_IO_SPACE:        ;------------------- SHOW IO_SPACE ---------------------------   
    MOV MANU_OPT,1
    MOV BH,17H               
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_IOSpace         
    CALL IOS_COOR_DATA
    CALL OPERATION
SHOW_MEMORY:          ;------------------- SHOW MEMORY --------------------
    MOV MANU_OPT,2
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_MEMORY         
    CALL MEMORY_COOR_DATA
    CALL OPERATION
SHOW_CMOS:            ;------------------- SHOW CMOS --------------------
    MOV MANU_OPT,3
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_CMOS        
    CALL CMOS_COOR_DATA
    CALL OPERATION
SHOW_SIO:             ;------------------- SHOW SIO --------------------
    MOV MANU_OPT,4
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_SIO         
    CALL SIO_COOR_DATA
    CALL OPERATION
SHOW_PCI:             ;------------------- SHOW PCI --------------------
    MOV MANU_OPT,5
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_PCI         
    CALL PCI_COOR_DATA
    CALL OPERATION
SHOW_E820:            ;------------------- SHOW E820 --------------------
    MOV MANU_OPT,6
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL TITLE_E820  
    CALL E820_SHOW_ARDS
    CALL E820_OPERATION
SHOW_SMBUS:           ;------------------- SHOW SMBUS --------------------
    MOV MANU_OPT,7
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_SMBUS
    CALL SMBUS_COOR_DATA
    CALL OPERATION
SHOW_SMBios:             ;------------------- SHOW SMbios --------------------
    MOV MANU_OPT,8
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL COOR_SYSTEM
    CALL TITLE_SMBios
      CALL FIND_EPS
    CALL SMBios_COOR_DATA
    CALL SMBIOS_OPERATION
SHOW_MSR:             ;------------------- SHOW MSR --------------------
    MOV MANU_OPT,9
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0    
    CALL MSR_COOR_SYSTEM    
    CALL TITLE_MSR   
      MOV AX,datasg
      MOV FS,AX    
      MOV ESI,0
      MOV EAX,0
      MOV MSR_ADD,0
    CALL MSR_COOR_DATA
    CALL MSR_OPERATION
SHOW_ACPI:           ;------------------- SHOW ACPI --------------------
    MOV MANU_OPT,10
    MOV BH,17H
    CALL SET_WINDOWS
    MOV BH,0
    CALL TITLE_ACPI
    CALL FIND_ACPI_TABLE
      MOV AX,OFFSET acpi_table_address
      MOV FS,AX
      MOV AX,0
      MOV GS,AX 
      MOV EDI,0
    CALL ACPI_COOR_DATA
    CALL SMBIOS_OPERATION

;---------------------------------------------------------------------------
;---------------------------------------------------------------------------  
;---------------------------------------------------------------------------
OPERATION:                    
     MOV CX,1
     set_cursor 6,7
     CALL CHANGE
  KEY_INPUT:
     MOV AH,1           ; CLEAR BUFFER ZONE
     INT 16H
     JZ KEY_INPUT

     MOV AH,0                     ; INPUT A KEY 
     INT 16H    
     CMP AH,48H                   ; UP
     JE UP_JMP  
     CMP AH,50H                   ; DOWN 
     JE DOWN_JMP                  
     CMP AH,4BH                   ; LEFT        
     JE LEFT_JMP                   
     CMP AH,4DH                   ; RIGHT  
     JE RIGHT_JMP                 
     CMP AL,ESCKEY                ; 'ESC'
     JE ESC_TO_BACK     
     CMP AL,96                    ; ' ` ' 
     JE TO_EX_SEG
     CMP AL,0DH                   ; 'ENTER'
     JE TO_WRITE
     CMP AL,51H                   ; 'Q' 
     JE LOOP_COOR_DATA      
     JMP KEY_INPUT

UP_JMP:CALL UP
     JMP KEY_INPUT
DOWN_JMP:CALL DOWN
     JMP KEY_INPUT
LEFT_JMP:CALL LEFT
     JMP KEY_INPUT
RIGHT_JMP:CALL RIGHT
     JMP KEY_INPUT
ESC_TO_BACK:
     CALL CLEAR_SCREEN
     JMP START
TO_WRITE:
     CMP MANU_OPT,1
     JE  WRITE 
     CMP MANU_OPT,2
     JE  WRITE 
     JMP KEY_INPUT
LOOP_COOR_DATA:
     CMP MANU_OPT,1
     JE  LOOP_IOS_DATAS
     CMP MANU_OPT,3
     JE  LOOP_CMOS_DATAS
  LOOP_CONTINUE:
     MOV AH,1
     INT 16H
     JZ LOOP_COOR_DATA
     JMP KEY_INPUT
  LOOP_IOS_DATAS:CALL IOS_COOR_DATA
                JMP LOOP_CONTINUE
  LOOP_CMOS_DATAS:CALL CMOS_COOR_DATA
                JMP LOOP_CONTINUE
TO_EX_SEG:
       CMP MANU_OPT,1
       JE  IOS_SEG
       CMP MANU_OPT,2
       JE  MEMORY_SEG       
       CMP MANU_OPT,4
       JE  SIO_SEG       
       CMP MANU_OPT,5
       JE  PCI_SEG
       JMP KEY_INPUT
;----------------------------------------------

;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------
IOS_COOR_DATA:                 ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX

      CALL PRO_STAR             ; DATA STORE IN CX 
      MOV IOS_PORT,CX

      MOV BH,0
      set_cursor 6,7
      MOV CX,10H
  IOS_LOOP_COLOMN:
      CALL IOS_WR_ROW
      INC DH
      MOV DL,7
      INT 10H
      LOOP IOS_LOOP_COLOMN
      POP CX          
      POP DX    
      set_cursor dh,dl 
      RET
IOS_WR_ROW:     
    PUSH CX
      MOV CX,10H
  IOS_WR_A_PORT:
    PUSH CX

      PUSH DX
      MOV DX,IOS_PORT
      IN AL,DX
      INC IOS_PORT
      POP DX

      CALL SHOW_AL
    POP CX
      LOOP IOS_WR_A_PORT
    POP CX
      RET
;-------------------------------------------------------------------
MEMORY_COOR_DATA:              ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX
      PUSH EDI 

      MOV AX,0
      MOV ES,AX
      MOV DH,22
      MOV DL,36
      CALL PRO_ADD            

      set_cursor 6,7
      MOV CX,10H
  MEMORY_LOOP_COLOMN:
      CALL MEMORY_WR_ROW
      INC DH
      set_cursor dh,7
      LOOP MEMORY_LOOP_COLOMN

      POP EDI 
      POP CX
      POP DX 
      MOV AH,2
      INT 10H
      RET
;-------------------
MEMORY_WR_ROW:     
    PUSH CX
      MOV CX,10H
  MEMORY_WR_A_PORT:
      PUSH CX
      MOV AL,ES:[EDI]
      INC EDI
      CALL SHOW_AL
      POP CX
      LOOP MEMORY_WR_A_PORT
    POP CX
      RET
;-------------------------------------------------------------------
CMOS_COOR_DATA:              ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX        
      set_cursor 6,7
      MOV CX,10H
  CMOS_LOOP_COLOMN:
      CALL CMOS_WR_ROW
      INC DH
      MOV DL,7
      INT 10H
      LOOP CMOS_LOOP_COLOMN
      POP CX
      POP DX 
      set_cursor dh,dl 
      RET
CMOS_WR_ROW:     
    PUSH CX
      MOV CX,10H
  CMOS_WR_A_PORT:
    PUSH CX

  UIP:
      MOV AL,0AH
      OUT 70H,AL
      JMP $+2
      IN AL,71H
      TEST AL,80H
      JNZ UIP
      MOV AL,CMOS_PORT
      INC CMOS_PORT
      CMP AL,13
      JLE NOT_ADD_80H  
      CMP AL,80H
      JNL NOT_ADD_80H    
      ADD AL,80H
    NOT_ADD_80H:
      OUT 70H,AL
      JMP $+2
      IN AL,71H    
     
      CALL SHOW_AL
    POP CX
      LOOP CMOS_WR_A_PORT
    POP CX
      RET
;-------------------------------------------------------------------
SIO_COOR_DATA:              ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX

      MOV SIO_PORT,0    

      set_cursor 6,7
      MOV CX,10H
  SIO_LOOP_COLOMN:
      CALL SIO_WR_ROW
      INC DH
      set_cursor dh,7
      LOOP SIO_LOOP_COLOMN
      POP CX
      POP DX 
      set_cursor dh,dl 
      RET
SIO_WR_ROW:     
    PUSH CX
      MOV CX,10H
  SIO_WR_A_PORT:
    PUSH CX

      PUSH DX      
      mov dx,2eh                 ;address port
  	mov al,87h                 ;ENTER PnP MODE 
      out dx,al
      mov al,01h
      out dx,al
      mov al,55h
      out dx,al
      mov al,55h
      out dx,al
     
      mov al,07h                 ;LDN address
      out dx,al
      mov al,CHOOSE_LDN             ;CHOOSE LDN 
   
      out 2fh,al                 ;data port ,al value into 2fh port 
      mov al,SIO_PORT                 ;index 
      INC SIO_PORT
      out dx,al     
      in al,2fh             ;2fh value storage al
      POP DX
      MOV AH,2
      INT 10H 

      CALL SHOW_AL
    POP CX
      LOOP SIO_WR_A_PORT
    POP CX
      RET
;-------------------------------------------------------------------
PCI_COOR_DATA:              ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX

      CALL PCI_PRO             ; GET BUSNUM,DEVNUM,FUNNUM
      MOV REGNUM,0             ; GET REGNUM      

      set_cursor 6,7
      MOV CX,10H
  PCI_LOOP_COLOMN:             ;  DISPLAY  DATAS 
      CALL PCI_WR_ROW
      INC DH
      MOV DL,7
      INT 10H
      LOOP PCI_LOOP_COLOMN

      POP CX
      POP DX 
      MOV AH,2
      INT 10H
      RET
;---------------------------
PCI_WR_ROW:     
    PUSH CX
      MOV CX,4
  PCI_WR_A_PORT:
    PUSH CX

       CALL pci_read          ; DATA IN EAX 
       MOV StoreAH,AH  
       CALL SHOW_AL
       MOV AL,StoreAH
       CALL SHOW_AL
       SHR EAX,16
       MOV StoreAH,AH
       CALL SHOW_AL
       MOV AL,StoreAH
       CALL SHOW_AL
       ADD REGNUM,4

    POP CX
      LOOP PCI_WR_A_PORT
    POP CX
      RET
;---------------------
PCI_PRO:
    PUSH DX
    PUSH CX
    MOV DH,22
    MOV DL,19
    CALL GET_NUM
    MOV BUSNUM,AL
    MOV DL,31
    CALL GET_NUM
    MOV DEVNUM,AL 
    MOV DL,45
    CALL GET_NUM
    MOV FUNNUM,AL 
    POP CX 
    POP DX
    MOV AH,2
    INT 10H
    RET
;-----------------------
GET_NUM:
    set_cursor dh,dl 
    MOV AH,8
    INT 10H
    CALL SUB_AL
    MOV CL,4
    ROL AL,CL
    MOV CH,AL           ;STORE IN CH 
  INC DL
    set_cursor dh,dl 
    MOV AH,8
    INT 10H
    CALL SUB_AL
    OR AL,CH            ; DATA IN AL 
    RET
;------------------------
pci_read proc
     ;protect register
     push ebx
     push dx
     ;clear
     xor eax,eax
     xor ebx,ebx
     ;enable
     add eax,1h
     shl eax,31
     ;bus number
     movzx ebx,BUSNUM
     and ebx,0ffh
     shl ebx,16
     add eax,ebx
     ;device number
     xor ebx,ebx
     movzx ebx,DEVNUM
     and ebx,0ffh
     shl ebx,11
     add eax,ebx
     ;function number
     xor ebx,ebx
     movzx ebx,FUNNUM
     and ebx,0ffh
     shl ebx,8
     add eax,ebx
     ;register
     xor ebx,ebx
     movzx ebx,REGNUM
     and ebx,0ffh
     add eax,ebx
     ;read IO
     mov dx,0cf8h
     out dx,eax
     mov dx,0cfch
     in eax,dx                 ; data in eax 
     ;resume register
     pop dx
     pop ebx
     ret
pci_read endp   
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
E820_OPERATION:   
             set_cursor 2,0       ; CURSOR ON THE LEFT 
             MOV CX,1 
             CALL E820_CHANGE
          E820_INPUT:
             MOV AH,1          
             INT 16H
             JE E820_INPUT

             MOV AH,0                     ; INPUT A KEY 
             INT 16H    
             CMP AH,48H                   ;  UP
             JE PRE_ROW_JMP  
             CMP AH,50H                   ;  DOWN 
             JE NEXT_ROW_JMP   
             CMP AL,ESCKEY                ; 'ESC'
             JE ESC_TO_BACK     
             JMP E820_INPUT
PRE_ROW_JMP: JMP  PRE_ROW
NEXT_ROW_JMP:JMP  NEXT_ROW
;----------------------------
E820_SHOW_ARDS:
        PUSH CX
        PUSH DX 

        MOV ARDS_NUM,0
        mov DL_NO,15
        mov DH_NO,2
        set_cursor DH_NO,DL_NO

        mov dx,mess
        mov es,dx

        mov ebx,0
        mov edi,0
s:
        mov ecx,20
        mov edx,'SMAP'
        mov eax,0E820h
        int 15h
        INC ARDS_NUM

        push ebx
        push edx
        push eax
        
        mov eax,es:[edi]
        mov laddr,eax
        call read
        add edi,4
        mov eax,es:[edi]
        mov haddr,eax
        call read

        mov DL_NO,16
        set_cursor DH_NO,DL_NO
        show_string1 leftk       ;  (

        cmp haddr,0
        ja  show_GB 

        mov eax,laddr
        call show_size           ;show sizes = kb or mb
        mov DL_NO,21
        call show_kmb            ;show kb
jia1: 
        mov DL_NO,23
        set_cursor DH_NO,DL_NO
        show_string1 righk       ; )
;---------------------------------------------
        mov DL_NO,29
        set_cursor DH_NO,DL_NO
        add edi,4
        mov eax,es:[edi]
        call show_size
        mov DL_NO,33
        call show_kmb

        add edi,8

        mov DL_NO,41
        mov eax,es:[edi]
        cmp eax,1
        je show1
        cmp eax,2
        je show2
        cmp eax,3
        je show3
        cmp eax,4
        je show4
return:
        add DH_NO,1
        mov DL_NO,15
        set_cursor DH_NO,DL_NO

        pop eax
        pop edx
        pop ebx
        cmp ebx,0
        jne s
exit:
        POP DX
        POP CX 
        MOV AH,2
        INT 10H 
        RET
;------------------------------------------------
lllooo:
        mov cl,8
        shr REG_NO,cl
        mov eax,REG_NO
        call num2

        dec DL_NO
        set_cursor DH_NO,DL_NO

        mov eax,REG_NO
        call num1

        dec DL_NO
        set_cursor DH_NO,DL_NO
        ret
;-------------------read----------------------
read:
        mov REG_NO,eax
        call num2

        dec DL_NO
        set_cursor DH_NO,DL_NO

        mov eax,REG_NO
        call num1

        dec DL_NO
        set_cursor DH_NO,DL_NO

        call lllooo
        call lllooo
        call lllooo
        ret
;---------------------------------
show1:  show_string DH_NO,DL_NO,b1
        jmp return

show2:  show_string DH_NO,DL_NO,b2
        jmp return

show3:  show_string DH_NO,DL_NO,b3
        jmp return

show4:  show_string DH_NO,DL_NO,b4
        jmp return

;-----------------num1-------------
num1:
        mov cl,4
        shr al,cl
        cmp al,9
        jle num
        add al,7
num:    add al,30h
        mov cx,1
        mov bl,17h
        mov ah,9
        int 10h
        ret

;------------------- num2 ------------------
num2:
        and al,00001111b
        cmp al,9
        jle num11
        add al,7
num11:   add al,30h
        mov cx,1
        mov bl,17h
        mov ah,9
        int 10h
        ret
;---------------------
show_GB proc
     mov ebx,haddr
     shl ebx,12
     mov eax,laddr
     shr eax,20
     add eax,ebx

     mov edx,0
     mov ebx,1024
     div ebx                       ;shang = eax = MB , yushu = edx 

     mov si,offset buffer          ;buffer
     mov cx,4

decima:
     mov dx,0
     mov bx,10                     ;bx = = chushu = 10

     div bx                        ;shang = ax ,yushu = dx
     add dl,30h
     mov [si+3],dl
     dec si
     loop decima

     show_string1 buffer           ;show shijinzhi
     mov DL_NO,21
     set_cursor DH_NO,DL_NO
     show_string1 gb

     jmp jia1
     ret
show_GB endp
;-------------------------------------------
show_size proc
      mov size1,eax                 ;low 32 size
      cmp eax,0FFFFFh               ;1MB = 1048576,0FFFFFh=1048575
      jb  kb1                       ;<
      
      mov edx,0
      mov ebx,1024
      div ebx                       ;shang = eax = MB , yushu = edx 

  kb1:mov edx,0
      mov ebx,1024
      div ebx                       ;shang = eax = MB , yushu = edx 

      mov si,offset buffer          ;buffer
      mov cx,4

decimal:
      mov dx,0
      mov bx,10                     ;bx = = chushu = 10

      div bx                        ;shang = ax ,yushu = dx
      add dl,30h
      mov [si+3],dl
      dec si
      loop decimal

      show_string1 buffer           ;show shijinzhi

      ret
show_size endp
;-------------------------------------------
show_kmb proc

      set_cursor DH_NO,DL_NO
      cmp size1,0FFFFFh
      jb  kb2
      show_string1 mb
      jmp pop1
  kb2:show_string1 kb
     
 pop1:ret
show_kmb endp
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
SMBUS_COOR_DATA:
      PUSH DX
      PUSH CX
      PUSH SI 

      set_cursor 6,7      
      MOV SI,0
      MOV CX,10H
    SMBUS_LOOP_COLOMN:
      CALL SMBUS_WR_ROW
      INC DH
      set_cursor DH,7
      LOOP SMBUS_LOOP_COLOMN

      POP SI 
      POP CX          
      POP DX    
      set_cursor dh,dl 
      RET

SMBUS_WR_ROW:     
    PUSH CX
      MOV CX,10H
  SMBUS_WR_A_PORT:
      PUSH CX
      ;----------
      call SMBUS_READ
      MOV AL,SOTRE_AL
      CALL SHOW_AL 
      ;----------
      POP CX
      LOOP SMBUS_WR_A_PORT
    POP CX
      RET
;----------------------------------------------------------
SMBUS_READ proc
        push dx 
        mov dx,0f040h
        mov al,1eh
        out dx,al     ;reset status register

        mov dx,0f044h ;chose device
        mov al,0a5h
        out dx,al

        mov dx,0f043h ;chose register
        mov ax,si
        out dx,al
       
check_smbus_ready:
        mov dx,0f040h ;check status register
        in al,dx
        test al,01h
        jnz check_smbus_ready

        mov dx,0f042h
        mov al,48h
        out dx,al     ;byte read
      
  check:mov dx,0f040h
        in al,dx
        test al,01h
        jnz check

        mov dx,0f045h
        in al,dx        ;read data
        MOV SOTRE_AL,AL 

        inc si         
        pop dx 
        set_cursor dh,dl
        ret 
SMBUS_READ endp
;------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------------------------
SMBios_COOR_DATA:
      PUSH DX
      PUSH CX
      PUSH ES 
      PUSH ESI 
      PUSH EDI 

      MOV AX,size_num       ; SEGMENT FOR STORE SIZE 
      MOV GS,AX         
       
      MOV SMBIOS_SIZE,0
      MOV ADDR_TYPE0,0
      MOV JUDGE_00,1
      MOV JUDGE_0000,1
      MOV ESI,0

      MOV DH,2
      MOV DL,67
      CALL PRO_ADD               ; GET ADDRESS      ;  EDI 
      MOV AL,FS:[EDI+1]
      INC AL 
      MOV DATA_LENGTH,AL 
  
      set_cursor 6,7
      MOV CX,10H
  SMBIOS_LOOP_COLOMN:
      CALL SMBIOS_WR_ROW
      INC DH
      set_cursor dh,7
      LOOP SMBIOS_LOOP_COLOMN


      CMP SMBIOS_SIZE,255
      JNL OUT_OF_SIZE
    OUT_OF_SIZE_BACK:
      CALL SMBIOS_CHANGE_SIZE    
      get_dh
      get_dl
      CALL SMBIOS_CHANGE_HADDLE

      POP EDI 
      POP ESI
      POP ES 
      POP CX
      POP DX 
      set_cursor DH,DL 
      RET
;---------------------------
SMBIOS_WR_ROW:     
    PUSH CX
      MOV CX,10H
  SMBIOS_WR_A_PORT:
      PUSH CX

      MOV AL,FS:[EDI]
      INC EDI 
      INC ADDR_TYPE0


      CMP JUDGE_0000,2
      JE  SMBIOS_JJ

      INC SMBIOS_SIZE            ;  COUNT  NUMBER 
      MOV CX,0
      MOV CL,DATA_LENGTH
      CMP ADDR_TYPE0,CX 
      JNL SHOW_TYPE_DATA
      CALL SHOW_AL
      JMP SMBIOS_J
    SMBIOS_JJ:
      MOV BL,18H
      CALL SHOW_AL_CHANGE_COLOR
    SMBIOS_J:
      POP CX
      LOOP SMBIOS_WR_A_PORT
    POP CX
      RET
;------------------------------
SHOW_TYPE_DATA PROC
      CMP AL,00H 
      JNE NOT_00
      CMP JUDGE_00,00H
      JNE NOT_00
      MOV JUDGE_0000,2
      JMP SMBIOS_JJ
    NOT_00:
      MOV JUDGE_00,AL 
      CALL SHOW_AL
      JMP SMBIOS_J
SHOW_TYPE_DATA ENDP 

;-----------------------
SMBIOS_CHANGE_SIZE PROC 
      PUSH DX 
      PUSH CX
      set_cursor 2,58
      MOV BL,1BH      
      MOV AX,SMBIOS_SIZE
      CMP AH,0
      JE JUST_SHOW_AL
      MOV SOTRE_AL,AL
      MOV AL,AH
      CALL ADD_AL
      MOV AH,9
      MOV CX,1
      INT 10H
      set_cursor 2,59
      MOV AL,SOTRE_AL  
    JUST_SHOW_AL:
      CALL SHOW_AL_CHANGE_COLOR 
      POP CX
      POP DX
      set_cursor DH,DL 
      RET 
SMBIOS_CHANGE_SIZE ENDP 
;---------------------------
OUT_OF_SIZE:  
      MOV AL,FS:[EDI]
      CMP AL,00H
      JNE NONONO_00   
      CMP JUDGE_00,00H
      JZ OUT_OUT 
    NONONO_00:
      INC SMBIOS_SIZE
      INC EDI    
      MOV JUDGE_00,AL
      JMP OUT_OF_SIZE
    OUT_OUT:
      INC SMBIOS_SIZE
      JMP OUT_OF_SIZE_BACK
;----------------------------
SMBIOS_CHANGE_HADDLE PROC
      PUSH DX
      MOV DH,6
      MOV DL,7
      CALL GET_NUM
      MOV AH,0
      MOV DATA_EXPRESS,AX
      CALL CREATE_16_TO_10
      MOV DI,OFFSET RESULTS
      ADD DI,2
      set_cursor 2,5
      MOV DX,DI
      MOV AH,9
      INT 21H 
      POP DX
      set_cursor DH,DL
      RET 
SMBIOS_CHANGE_HADDLE ENDP
;-----------------------------
SMBIOS_CHANGE_ADDr PROC 
      set_cursor 2,67            
      MOV BL,1BH 
      MOV EAX,EDI 
      SHR EAX,24
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,EDI 
      SHR EAX,16
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,EDI 
      SHR EAX,8
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,EDI 
      CALL SHOW_AL_CHANGE_COLOR2 
      RET 
SMBIOS_CHANGE_ADDr ENDP 
;----------------------------
SMBIOS_OPERATION:                    
     MOV CX,1
     set_cursor 6,7
     CALL CHANGE
  SMBIOS_KEY_INPUT:
     MOV AH,1           ; CLEAR BUFFER ZONE
     INT 16H
     JZ SMBIOS_KEY_INPUT

     MOV AH,0                     ; INPUT A KEY 
     INT 16H    
     CMP AH,48H                   ; UP
     JE SMB_UP 
     CMP AH,50H                   ; DOWN 
     JE SMB_DOWN            
     CMP AH,4BH                   ; LEFT        
     JE SMB_LEFT              
     CMP AH,4DH                   ; RETIGHT  
     JE SMB_RIGHT        
     CMP AL,ESCKEY                ; 'ESC'
     JE ESC_TO_BACK     
     CMP AH,49H                   ; 'PAGE UP' 
     JE TO_PAGE_UP   
     CMP AH,51H                   ; 'PAGE DOWN' 
     JE TO_PAGE_DOWN          
     JMP SMBIOS_KEY_INPUT
TO_PAGE_UP:
     CMP MANU_OPT,8
     JE  SMBIOS_PAGE_UP
     CMP MANU_OPT,10
     JE  ACPI_PAGE_UP
TO_PAGE_DOWN:
     CMP MANU_OPT,8
     JE  SMBIOS_PAGE_DOWN 
     CMP MANU_OPT,10
     JE  ACPI_PAGE_DOWN 

;-------------------------
SMB_UP:
    CALL BACK_BL                     ; FUNCTION : 1. recover its color     
    CMP  DH,6                         ;            2. press the key 'up' on keyboard , it move up
    JZ   NO_UPP
    DEC  DH
    MOV  AH,2
    INT  10H
  NO_UPP:    
    CALL CHANGE
    JMP SMBIOS_KEY_INPUT
SMB_DOWN:
    CALL BACK_BL
    CMP DL,SIZE_DL
    JLE DOWN_L
      DEC SIZE_DH 
  DOWN_L:
      CMP DH,SIZE_DH
      JB  NO_DOWN_R
      MOV DH,6
      set_cursor DH,DL
      CALL CHANGE
      get_dh 
      JMP SMBIOS_KEY_INPUT
    NO_DOWN_R:
      INC DH
      set_cursor DH,DL
      CALL CHANGE
      get_dh
      JMP SMBIOS_KEY_INPUT
SMB_LEFT:
    CALL BACK_BL
    CMP DH,SIZE_DH
    JB  LEFT_U
      CMP DL,8
      JLE LEFT_TO_RIGHT1
      SUB DL,3
      set_cursor DH,DL
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
    LEFT_TO_RIGHT1:
      MOV DL,SIZE_DL
      set_cursor DH,DL 
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
  LEFT_U:
      CMP DL,8
      JLE LEFT_TO_RIGHT2
      SUB DL,3
      set_cursor DH,DL
      CALL CHANGE 
      JMP SMBIOS_KEY_INPUT
    LEFT_TO_RIGHT2:
      ADD DL,45
      set_cursor DH,DL 
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
SMB_RIGHT:
    CALL BACK_BL
    CMP DH,SIZE_DH
    JB  RIGHT_U
      CMP DL,SIZE_DL
      JB  RIGHT_TO_LEFT1
      MOV DL,7
      set_cursor DH,DL
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
      RIGHT_TO_LEFT1:
      ADD DL,3
      set_cursor DH,DL 
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
  RIGHT_U:
      CMP DL,50
      JA  RIGHT_TO_LEFT2
      ADD DL,3
      set_cursor DH,DL
      CALL CHANGE 
      JMP SMBIOS_KEY_INPUT
    RIGHT_TO_LEFT2:
      SUB DL,45
      set_cursor DH,DL 
      CALL CHANGE
      JMP SMBIOS_KEY_INPUT
;-------------------------
SMBIOS_PAGE_UP:
      PUSH CX 
      MOV DH,22
      MOV DL,26
      CALL GET_NUM
      CMP AL,0                  ; JUDGE INDEX 
      JE PAGE_UP_END
      DEC AL
      set_cursor 22,26          ; CHANGE INDEX 
      MOV BL,17H
      CALL SHOW_AL_CHANGE_COLOR2


      MOV DH,2
      MOV DL,67
      CALL PRO_ADD              ; DATA IN  EDI 

      MOV EAX,0
      PUSH BX
      SUB STORE_SIZE,2
      MOV BX,STORE_SIZE
      MOV AX,GS:[BX]
      POP BX 
      SUB EDI,EAX 

      CALL SMBIOS_CHANGE_ADDr   

      CALL SMBios_COOR_DATA

    PAGE_UP_END:
      POP CX 
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT
;---------------------------
SMBIOS_PAGE_DOWN:  
      PUSH CX 
      MOV DH,22
      MOV DL,26
      CALL GET_NUM
      CMP AL,53H                ; JUDGE INDEX 
      JE PAGE_DOWN_END

      INC AL
      set_cursor 22,26          ; CHANGE INDEX 
      MOV BL,17H
      CALL SHOW_AL_CHANGE_COLOR2

      MOV DH,2
      MOV DL,67
      CALL PRO_ADD              ; DATA IN  EDI 

      MOV EAX,0
      MOV AX,SMBIOS_SIZE
      
      PUSH BX
      MOV BX,STORE_SIZE
      MOV GS:[BX],AX 
      ADD STORE_SIZE,2
      POP BX 

      ADD EDI,EAX                ; ADDr + SIZE 

      CALL SMBIOS_CHANGE_ADDr 

      CALL SMBios_COOR_DATA

    PAGE_DOWN_END:
      POP CX 
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT
;-----------------------------------------------------
FIND_EPS PROC
      PUSH SI 
      MOV AX,0F000H
      MOV FS,AX
      MOV SI,0
    FIND_SM3:  
      MOV AL,FS:[SI]
      INC SI 
      CMP AL,5FH             ; ' _ '
      JNE FIND_SM3 

      MOV AL,FS:[SI]
      INC SI
      CMP AL,53H             ; ' S '
      JNE FIND_SM3

      MOV AL,FS:[SI]
      INC SI
      CMP AL,4DH             ; ' M '
      JNE FIND_SM3

      MOV AL,FS:[SI]
      INC SI
      CMP AL,33H             ; ' 3 '
      JNE FIND_SM3

      MOV AL,FS:[SI]
      INC SI
      CMP AL,5FH             ; ' _ '
      JNE FIND_SM3

      SUB SI,5
      MOV EPS_OFFSET,SI      ; STORE EPS OFFSET
      ADD SI,0CH 
      MOV EAX,FS:[SI]
      MOV STRU_MAX_SIZE,EAX

      ADD SI,4
      MOV EAX,FS:[SI]
      MOV LADDR,EAX      
      MOV EDI,EAX
      ADD SI,4
      MOV EAX,FS:[SI]
      MOV HADDR,EAX 
      MOV FS,AX              ;   FIRST ADDRESS  IN    FS:[EDI]

      CALL SMBIOS_CHANGE_ADDr

      POP SI 
      RET 
FIND_EPS ENDP 
;--------------------------------
;-------------------------------
SHOW_AL_CHANGE_COLOR PROC 
      MOV CH,AL            ;STORE IN CH
      MOV CL,4
      ROL AL,CL
      AND AL,0FH           
    PUSH CX
      MOV CX,1
      CALL ADD_AL
      MOV AH,9
      INT 10H
    POP CX

      INC DL
      MOV AH,2
      INT 10H
      AND CH,0FH
      MOV AL,CH
      MOV AH,9
      MOV CX,1
      CALL ADD_AL
      INT 10H

      INC DL
      MOV AH,2
      INT 10H
      MOV AL,0
      MOV AH,9
      INT 10H

      MOV AH,2
      INC DL
      INT 10H
      RET 
SHOW_AL_CHANGE_COLOR ENDP
;-----------------------
SHOW_AL_CHANGE_COLOR2 PROC 
      MOV CH,AL            ;STORE IN CH
      MOV CL,4
      ROL AL,CL
      AND AL,0FH           
    PUSH CX
      MOV CX,1
      CALL ADD_AL
      MOV AH,9
      INT 10H
    POP CX

      INC DL
      MOV AH,2
      INT 10H
      AND CH,0FH
      MOV AL,CH
      MOV AH,9
      MOV CX,1
      CALL ADD_AL
      INT 10H

      INC DL
      MOV AH,2
      INT 10H 
      RET 
SHOW_AL_CHANGE_COLOR2 ENDP
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
datasg segment
msr_p1  dd  00000010h,00000017h,0000001Bh,0000002Ah,0000002Eh,00000035h,0000003Ah,0000008Bh
        dd  0000009Bh,000000C1h,000000C2h,000000C3h,000000C4h,000000C5h,000000C6h,000000C7h
        dd  000000C8h,000000CEh,000000E2h,000000E4h,000000E7h,000000E8h,000000FEh,0000013Ah
        dd  0000013Ch,00000174h,00000175h,00000176h,00000179h,0000017Ah,00000186h,00000187h
        dd  00000188h,00000189h,0000018Ah,0000018Bh,0000018Ch,0000018Dh,00000194h,00000198h
        dd  00000199h,0000019Ah,0000019Bh,0000019Ch,000001A0h,000001A2h,000001A4h,000001AAh
        dd  000001ADh,000001B0h,000001B1h,000001B2h,000001D9h,000001DBh,000001DCh,000001DDh
        dd  000001DEh,000001F0h,000001F2h,000001F3h,000001F4h,000001F5h,000001FCh,00000200h
        dd  00000201h,00000202h,00000203h,00000204h,00000205h,00000206h,00000207h,00000208h
        dd  00000209h,0000020Ah,0000020Bh,0000020Ch,0000020Dh,0000020Eh,0000020Fh,00000210h
        dd  00000211h,00000212h,00000213h,00000250h,00000258h,00000259h,00000268h,00000269h
        dd  0000026Ah,0000026Bh,0000026Ch,0000026Dh,0000026Eh,0000026Fh,00000277h,00000280h
        dd  00000281h,00000282h,00000283h,00000284h,00000285h,00000286h,00000287h,00000288h
        dd  00000289h,000002E0h,000002FFh,00000309h,0000030Ah,0000030Bh,000003F8h,000003F9h
        dd  000003FAh,000003FCh,000003FDh,000003FEh,00000400h,00000401h,00000402h,00000403h
        dd  00000404h,00000405h,00000406h,00000407h,00000408h,00000409h,0000040Ah,0000040Bh
        dd  0000040Ch,0000040Dh,0000040Eh,0000040Fh,00000410h,00000411h,00000412h,00000413h
        dd  00000414h,00000415h,00000416h,00000417h,00000418h,00000419h,0000041Ah,0000041Bh
        dd  0000041Ch,0000041Dh,0000041Eh,0000041Fh,00000420h,00000421h,00000422h,00000423h
        dd  00000424h,00000425h,00000426h,00000427h,00000480h,00000481h,00000482h,00000483h
        dd  00000484h,00000485h,00000486h,00000487h,00000488h,00000489h,0000048Ah,00000600h
        dd  00000601h,00000606h,0000060Ah,0000060Bh,0000060Ch,0000060Dh,00000610h,00000611h
        dd  00000614h,00000608h,00000639h,0000063Ah,00000640h,00000641h,00000642h,0C0000080h
        dd  0C0000081h,0C0000082h,0C0000084h,0C0000100h,0C0000101h,00000001H
datasg ends
rdmsr MACRO
  db 0fh
  db 32h
endm
;---------------------------------------------------
MSR_COOR_DATA PROC               ;SHOW THE DATA IN THE COORDINATE SYSTEM
      PUSH DX
      PUSH CX

      MOV ESI,MSR_ADD

      MOV DH,6
      MOV DL,31
      set_cursor DH,DL 
      MOV CX,10H
  MSR_LOOP_COLOMN:
      CALL MSR_WR_ROW
      INC DH
      set_cursor dh,31
      LOOP MSR_LOOP_COLOMN
      POP CX
      POP DX 
      set_cursor DH,DL 
      RET
MSR_COOR_DATA ENDP 
;------------------------------
MSR_WR_ROW:     
    PUSH CX
      MOV ECX,FS:[ESI]
      CMP ECX,00000001h
      JZ MSR_RD_END 
      PUSH EDX 
      RDMSR               ; DATA  IN  EDX  EAX 
      MOV STORE_EAX,EAX 
      MOV STORE_EDX,EDX
      POP  EDX 
      CALL SHOW_MSR_DATAS
      CALL MSR_SHOW_ADDRESS
      ADD ESI,4
    MSR_RD_END: 
    POP CX
      RET

;--------------------------------
SHOW_MSR_DATAS:
      MOV EAX,STORE_EAX
      CALL SHOW_AL
      MOV EAX,STORE_EAX
      SHR EAX,8
      CALL SHOW_AL
      MOV EAX,STORE_EAX
      SHR EAX,16
      CALL SHOW_AL
      MOV EAX,STORE_EAX
      SHR EAX,24
      CALL SHOW_AL
      ;----------------
      MOV EAX,STORE_EDX
      CALL SHOW_AL
      MOV EAX,STORE_EDX
      SHR EAX,8
      CALL SHOW_AL
      MOV EAX,STORE_EDX
      SHR EAX,16
      CALL SHOW_AL
      MOV EAX,STORE_EDX
      SHR EAX,24
      CALL SHOW_AL
      RET 
;--------------------------------
MSR_SHOW_ADDRESS: 
      set_cursor DH,22
      MOV BL,14H
      MOV EAX,FS:[ESI]
      SHR EAX,24
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,FS:[ESI]
      SHR EAX,16
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,FS:[ESI]
      SHR EAX,8
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,FS:[ESI]
      CALL SHOW_AL_CHANGE_COLOR2      
      RET 
;--------------------------------
MSR_OPERATION:                  
     MOV CX,1
  MSR_KEY_INPUT:
     MOV AH,1                     ; CLEAR BUFFER ZONE
     INT 16H
     JZ MSR_KEY_INPUT
     MOV AH,0                     ; INPUT A KEY 
     INT 16H    
     CMP AL,ESCKEY                ; 'ESC'
     JE ESC_TO_BACK     
     CMP AH,49H                   ; 'PAGE UP' 
     JE MSR_PAGE_UP   
     CMP AH,51H                   ; 'PAGE DOWN' 
     JE MSR_PAGE_DOWN   
     CMP AL,51H                   ; 'Q' 
     JE MSR_LOOP_COOR_DATA        
     JMP MSR_KEY_INPUT

MSR_LOOP_COOR_DATA:
     CALL MSR_COOR_DATA
     MOV AH,1
     INT 16H
     JZ MSR_LOOP_COOR_DATA
     JMP MSR_KEY_INPUT

;--------------------------------------
MSR_PAGE_DOWN:
    MOV BH,17H
    MOV CH,6      
    MOV CL,WINLEFT            ; SetWindows 
    MOV DH,21
    MOV DL,WINRIGHT  
    MOV AL,0
    MOV AH,6 
    INT 10H
    MOV BH,0

     CMP MSR_ADD,704
     JNL NOT_SHOW_DATA1
     ADD MSR_ADD,64     
    NOT_SHOW_DATA1:
     CALL MSR_COOR_DATA
     JMP MSR_KEY_INPUT     
MSR_PAGE_UP:
     CMP MSR_ADD,0
     JLE NOT_SHOW_DATA2
     SUB MSR_ADD,64
     CALL MSR_COOR_DATA
    NOT_SHOW_DATA2:
     JMP MSR_KEY_INPUT  

;--------------------------------------
MSR_COOR_SYSTEM:
      set_cursor 5,31 
      MOV CX,8
      MOV AH,9
      MOV AL,0
      MOV COOR_VAR,AX
      MOV BL,14H          ; COLOR BLUE RED 
  MSR_LOOP_ROW:
    PUSH CX
      MOV CX,1
      MOV AL,30H          ; 0
      MOV AH,9
      INT 10H
      INC DL      
      set_cursor DH,DL     

      MOV AX,COOR_VAR    
      CALL ADD_AL      ;123..789ABCDEF
      INT 10H

      INC DL
      set_cursor DH,DL 
      MOV AL,0           ; SPACE 
      MOV AH,9
      INT 10H
       
      INC DL         ;NEXT 
      set_cursor DH,DL 
      INC COOR_VAR
      POP CX
      LOOP MSR_LOOP_ROW
      RET



;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------

;----------------------------------------------------------------------------------------------------
ACPI_COOR_DATA:
      PUSH DX
      PUSH CX

      MOV ESI,FS:[EDI]
      MOV EAX,GS:[ESI]
      MOV ACPI_TABLE_NAME,EAX 
      CALL ACPI_SHOW_TABLE
      CALL ACPI_SHOW_ADDr
      CALL ACPI_GET_COOR

      set_cursor 6,7
      MOV CH,0 
      MOV CL,COOR_COLOMN
      ADD COOR_COLOMN,5
  ACPI_LOOP_COLOMN:
      CALL ACPI_WR_ROW
      INC DH
      set_cursor dh,7
      LOOP ACPI_LOOP_COLOMN

      SUB COOR_COLOMN,5
      CALL ACPI_SHOW_SIZE
      get_dh
      get_dl
      CALL ACPI_COOR_SYSTEM 

      POP CX
      POP DX 
      MOV AH,2
      INT 10H
      RET
;-------------------
ACPI_WR_ROW:   
      PUSH CX  

      CMP DH,COOR_COLOMN
      JZ  CX_NOT_10H
      MOV CX,10H
      JMP ACPI_WR_A_PORT
      CX_NOT_10H:
      MOV CX,COOR_LAST_ROW
  ACPI_WR_A_PORT:
      PUSH CX

      MOV AL,GS:[ESI]
      CALL SHOW_AL
      INC ESI
      INC COUNT_NUM

      POP CX
      LOOP ACPI_WR_A_PORT
      POP CX 
      RET
;--------------------------------------
ACPI_SHOW_SIZE PROC 
      MOV BL,1BH
      MOV CX,1
      set_cursor 6,19
      MOV AH,8
      INT 10H
      set_cursor 2,58
      MOV AH,9
      INT 10H
      set_cursor 6,20
      MOV AH,8
      INT 10H
      set_cursor 2,59
      MOV AH,9
      INT 10H
      RET 
ACPI_SHOW_SIZE ENDP 
;-------------------------------------------
ACPI_SHOW_ADDr:
      MOV DH,2
      MOV DL,40
      set_cursor DH,DL 
      MOV EAX,FS:[EDI]  
      MOV LADDR,EAX 
      MOV BL,1BH 
      MOV EAX,LADDR
      SHR EAX,24
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,LADDR
      SHR EAX,16
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,LADDR
      SHR EAX,8
      CALL SHOW_AL_CHANGE_COLOR2
      MOV EAX,LADDR
      CALL SHOW_AL_CHANGE_COLOR2 
      RET
;-----------------------------------------
ACPI_SHOW_TABLE:
      MOV CX,1
      MOV BL,1BH 
      set_cursor 2,16
      MOV EAX,ACPI_TABLE_NAME
      MOV AH,9
      INT 10H
      set_cursor 2,17
      MOV EAX,ACPI_TABLE_NAME
      SHR EAX,8
      MOV AH,9
      INT 10H
      set_cursor 2,18
      MOV EAX,ACPI_TABLE_NAME
      SHR EAX,16
      MOV AH,9
      INT 10H
      set_cursor 2,19
      MOV EAX,ACPI_TABLE_NAME
      SHR EAX,24
      MOV AH,9
      INT 10H
      RET 
;-------------------------------------------------------
ACPI_GET_COOR PROC                    ; ACPI_COORDINATE
      PUSH ESI
      ADD ESI,4
      MOV EAX,GS:[ESI]
      CMP AX,00FFH
      JNL MORE_THAN_256 
      MOV SOTRE_AL,AL
      SHR AL,4
      INC AL
      MOV COOR_COLOMN,AL
      MOV AL,SOTRE_AL
      AND AL,0FH
      MOV AH,0
      MOV COOR_LAST_ROW,AX
      POP ESI
      RET 

    MORE_THAN_256:
      MOV COOR_COLOMN,10H
      MOV COOR_LAST_ROW,10H
      POP ESI
      RET 
ACPI_GET_COOR ENDP 
;-----------------------------------------------------
ACPI_COOR_SYSTEM:
      set_cursor 5,7
      MOV CX,10H
      MOV AH,9
      MOV AL,0
      MOV COOR_VAR,AX
      MOV BL,14H          ; COLOR BLUE RED 
  ACPI_LOOP_ROW:
    PUSH CX
      MOV CX,1
      MOV AL,30H          ; 0
      MOV AH,9
      INT 10H
      INC DL      
      set_cursor DH,DL     

      MOV AX,COOR_VAR    
      CALL ADD_AL      ;123..789ABCDEF
      INT 10H

      INC DL
      set_cursor DH,DL 
      MOV AL,0           ; SPACE 
      MOV AH,9
      INT 10H
       
      INC DL         ;NEXT 
      set_cursor DH,DL 
      INC COOR_VAR
    POP CX
      LOOP ACPI_LOOP_ROW
    ;----------------------
      MOV DL,4
      MOV DH,6
      INT 10H
      MOV AH,9
      MOV AL,0
      MOV COOR_VAR,AX
      MOV CH,0
      MOV CL,COOR_COLOMN
   ACPI_LOOP_COLMN:
    PUSH CX
      MOV CX,1
      MOV AX,COOR_VAR
      CALL ADD_AL         ; 123..789ABCDEF
      INT 10H                

      INC DL 
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV AL,30H            ; 0
      INT 10H

      MOV DL,4              ; NEXT 
      INC DH
      MOV AH,2
      INT 10H
      INC COOR_VAR
    POP CX
      LOOP ACPI_LOOP_COLMN
      RET
;--------------------------------------
FIND_ACPI_TABLE PROC 
      MOV ACPI_TABLE_NUM,0
      MOV AX,OFFSET acpi_table_address
      MOV FS,AX
      MOV AX,0
      MOV GS,AX 
      MOV ESI,0B5F58028H         ; GET RSDT ADDRESS 
      MOV EDI,0
      MOV FS:[EDI],ESI
      ADD EDI,4
      ADD ESI,4
      MOV ECX,GS:[ESI]           ; LENGTH 
      ADD ECX,0B5F58028H
      ADD ESI,20H
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX 
      ADD ESI,4
      ADD EDI,4      

      PUSH ESI
      MOV ESI,EAX
      ADD ESI,24H
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX 
      ADD EDI,4      
      POP ESI

    GET_ELSE_ADD:
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX
      ADD EDI,4
      ADD ESI,4     
      CMP ESI,ECX 
      JLE GET_ELSE_ADD
;-------------------------------
      MOV ESI,0B5F580A0H         ; GET XSDT ADDRESS 
      ADD ESI,4
      MOV ECX,GS:[ESI]           ; LENGTH
      ADD ECX,0B5F580A0H
      ADD ESI,20H
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX 
      ADD ESI,8
      ADD EDI,4

      PUSH ESI
      MOV ESI,EAX 
      ADD ESI,24H
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX 
      ADD EDI,4      
      POP ESI

    GET_ELSE_ADD2:
      MOV EAX,GS:[ESI]
      MOV FS:[EDI],EAX
      ADD EDI,4
      ADD ESI,8     
      CMP ESI,ECX 
      JLE GET_ELSE_ADD2
      MOV ACPI_TABLE_NUM,EDI 
      SUB ACPI_TABLE_NUM,4
      RET 
FIND_ACPI_TABLE ENDP 
;----------------------------
ACPI_PAGE_UP:
    PUSH CX 
    PUSH BX 
    MOV BH,17H
    MOV CH,5         ; SET WINDOWS    
    MOV CL,4
    MOV DH,21
    MOV DL,53  
    MOV AL,0
    MOV AH,6 
    INT 10H
    POP BX 
      CMP EDI,0
      JE  PAGE_UP_RE
      SUB EDI,4
      POP CX 
      CALL ACPI_COOR_DATA
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT
    PAGE_UP_RE:
      MOV EDI,ACPI_TABLE_NUM
      POP CX 
      CALL ACPI_COOR_DATA
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT
ACPI_PAGE_DOWN:
    PUSH CX
    PUSH BX 
    MOV BH,17H
    MOV CH,5         ; SET WINDOWS    
    MOV CL,4
    MOV DH,21
    MOV DL,53  
    MOV AL,0
    MOV AH,6 
    INT 10H
    POP BX
      CMP EDI,ACPI_TABLE_NUM
      JNL PAGE_DOWN_RE
      ADD EDI,4
      POP CX
      CALL ACPI_COOR_DATA
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT      
    PAGE_DOWN_RE:
      MOV EDI,0
      POP CX 
      CALL ACPI_COOR_DATA
      MOV DH,6
      MOV DL,8
      set_cursor DH,DL 
      JMP SMBIOS_KEY_INPUT


































;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
IOS_SEG:                       ; FUNCTION : CHANGE THE DATA EXTENT
      PUSH AX                  ;            INPUT THE CHARACTERS AFTER 'Start:' to do it 
      PUSH BX
      PUSH CX                               
      PUSH DX
      MOV BL,1BH
  IOS_SEG_CLEAR:               ; CLEAR THE DATA AFTER 'Start:'
      MOV DH,2
      MOV DL,30
      MOV AH,2
      INT 10H          
      MOV CX,4
      MOV AL,0
      MOV AH,9
      INT 10H
      MOV CX,1     
  IOS_INPUT_NUM:               ; input characters
      MOV AH,1
      INT 16H
      JZ IOS_INPUT_NUM

      MOV AH,0                         ; input character 
      INT 16H      
      CMP AL,0DH                       ; if the character is 'enter',jump to T_ENTER
      JZ IOS_ReflashSegDate  
      CMP AL,60H                       ; if the  character is '`',jump to CLEAR
      JZ IOS_SEG_CLEAR
      MOV AH,2
      INT 10H                          
      MOV AH,9
      INT 10H
      INC DL
      CMP DL,33                        
      JLE IOS_INPUT_NUM                      ; IF <=34 - JUMP  ;  IF > 34 - continue
  ;----------------------                  
  IOS_CONFIRM:                               ; INPUT A CHARACTER TO CONFIRM
      MOV AH,1
      INT 16H
      JZ  IOS_CONFIRM
      MOV AH,0                         ; INPUT A CHARACTER TO CONFIRM
      INT 16H 
      CMP AL,0DH                       ; IF ITS 'ENTER' , JUMP T_ENTER
      JZ  IOS_ReflashSegDate             
      CMP AL,60H                       ; IF ITS '`' , JUMP CLEAR
      JZ  IOS_SEG_CLEAR
      JMP IOS_CONFIRM
   IOS_ENDD:
      POP DX
      POP CX
      POP BX
      POP AX                 
      MOV AH,2              
      INT 10H               
      JMP OPERATION                            
  ;-------------------
  IOS_ReflashSegDate:       ; FUNCTION : 1. confirm the data extent  ('Start' and 'End') 
      MOV CL,33             ;            2. update the data in the coordinate system
      DEC DL
      CMP DL,30
      JNL JMP_INC 
      INC DL
      INC CL
  JMP_INC:
      SUB CL,DL
      MOV BL,1BH
  MoveToBack:               ; FUNCTION : adjust the location of characters on 'Start:'
      PUSH CX               ;            字符向后移动并在前边补0
      MOV AH,8
      INT 10H
      ADD DL,CL
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV CX,1     
      INT 10H
      POP CX                    
      SUB DL,CL
      DEC DL        
      MOV AH,2
      INT 10H
      CMP DL,30
      JNL MoveToBack           ;dl=29
          
      MOV AL,30H                          ; FUNCTION : complement 0 for Start
      inc dl
      mov ah,2                    
      int 10H
      mov ah,9
      int 10h
      
      MOV CX,1                       
      MOV DL,33                        ; 1. produce the end of the DATA SEG
      MOV AH,2                         ; 2. combine the four character into one
      INT 10H
  start_to_end:                            ; setion 1 : produce the end of the DATA EXTENT
      MOV AH,8                       
      INT 10H
      ADD DL,10
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
      SUB DL,11
      MOV AH,2
      INT 10H
      CMP DL,30
      jnl start_to_end                     ; if dl >= jump 
       
      MOV DL,41                       ; 'End' = 'Start:' + 0100h                       
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CMP AL,38H                      ; if the number <=8 jump ,or +7 to be the char 
      JLE ADD_1
      ADD AL,7
  ADD_1:CMP AL,45H                      ; if al <= 45h(E) , jump to ADD_2
      JLE ADD_2                       ; else ,carry a number
      MOV AL,30H
      MOV AH,9
      INT 10H
      DEC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CMP AL,38H
      JLE ADD_3
      ADD AL,7
  ADD_3:CMP AL,45H
      JLE ADD_2
      MOV AL,30H
      MOV AH,9
      INT 10H
      JMP ADD_4
  ADD_2:INC AL
      MOV AH,9
      INT 10H
  ADD_4:
      CALL IOS_COOR_DATA
      JMP  IOS_ENDD
;----------------------------------------------------------------------------------------
MEMORY_SEG PROC                      ; FUNCTION : CHANGE THE DATA EXTENT
      PUSH AX                        ;            INPUT THE CHARACTERS AFTER 'Start:' to do it 
      PUSH BX
      PUSH CX
      PUSH DX
      MOV BL,17H
  M_CLEAR:                       ; CLEAR THE DATA AFTER 'ADDRESS'
      MOV DH,22
      MOV DL,28
      MOV AH,2
      INT 10H          
      MOV CX,16
      MOV AL,0
      MOV AH,9
      INT 10H
      MOV CX,1
  M_INPUT_NUM:                         ; FUNCTION : input characters
      MOV AH,1
      INT 16H
      JZ M_INPUT_NUM

      MOV AH,0                  ; input character 
      INT 16H
      CMP AL,0DH
      JZ M_ReflashSegDate
      CMP AL,60H                 ; if the  character is '`',jump to CLEAR
      JZ M_CLEAR      
      MOV AH,9
      INT 10H

      MOV AH,2
      INC DL
      INT 10H
      CMP DL,44            
      JLE M_INPUT_NUM
  M_CONFIRM:
      MOV AH,1
      INT 16H
      JZ  M_CONFIRM
      MOV AH,0                         ; INPUT A CHARACTER TO CONFIRM
      INT 16H 
      CMP AL,0DH                       ; IF ITS 'ENTER' , JUMP T_ENTER
      JZ  M_ReflashSegDate             
      CMP AL,60H                       ; IF ITS '`' , JUMP CLEAR
      JZ  M_CLEAR
      JMP M_CONFIRM
   M_ENDD:
      POP DX
      POP CX
      POP BX
      POP AX
      MOV AH,2
      INT 10H
      JMP OPERATION
MEMORY_SEG ENDP 
;------------------------------ 
M_ReflashSegDate:                ; FUNCTION : 1. confirm the data extent 
      MOV CL,44                  ;            2. update the data in the coordinate system
      SUB CL,DL
      MOV BL,1BH
  LOOP_ADJUST:                ; adjust the location of characters on 'ADDRESS'
      PUSH CX
      MOV AH,8
      INT 10H
      ADD DL,CL
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV BL,17H
      MOV CX,1     
      INT 10H
      POP CX
      SUB DL,CL
      DEC DL
      MOV AH,2
      INT 10H
      CMP DL,27
      JNL LOOP_ADJUST
      INC DL
      INC DL
      MOV AL,30H
      MOV BL,17H
  LOOP_COMPL:                 ; FUNCTION : complement 0
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
      DEC DL
      CMP DL,29
      JNL LOOP_COMPL     ;>=

      PUSH SI
      MOV DH,22
      MOV DL,28
      MOV SI,DX
      MOV DH,2
      MOV DL,13
  LOOP_TO_TITLE:              ; COPY THE ADDRESS TO TITLE 
      PUSH DX
      MOV DX,SI
      INC SI
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      POP DX
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV BL,1BH
      INT 10H
      INC DL
      CMP DL,44
      JLE LOOP_TO_TITLE
      POP SI
      CALL MEMORY_COOR_DATA
      JMP M_ENDD
;------------------------------------------------------------------------------
SIO_SEG:                      ;CHANGE LDN 
      PUSH BX
      PUSH CX
      PUSH DX
      MOV BL,17H
  LDN_CLEAR:                       ; CLEAR THE DATA AFTER 'ADDRESS'
      MOV DH,22
      MOV DL,37
      MOV AH,2
      INT 10H          
      MOV CX,2
      MOV AL,0
      MOV AH,9
      INT 10H 
      MOV CX,1    
  WRITE_LDN:                    
      MOV AH,1
      INT 16H
      JZ WRITE_LDN

      MOV AH,0                  ; input A character 
      INT 16H
      CMP AL,0DH
      JZ LDN_ENTER
      CMP AL,60H            ; if the  character is '`',jump to CLEAR
      JZ LDN_CLEAR  

      MOV AH,9
      INT 10H
      INC DL 
      MOV AH,2
      INT 10H
      CMP DL,38            
      JLE WRITE_LDN      ; DL=39
LDN_CONFIRM:
      MOV AH,1
      INT 16H
      JZ LDN_CONFIRM
      MOV AH,0               ; INPUT A CHARACTER TO CONFIRM
      INT 16H 
      CMP AL,0DH             ; IF ITS 'ENTER' , JUMP T_ENTER
      JZ LDN_ENTER             
      JMP LDN_CLEAR
LDN_ENTER:                ; FUNCTION : 1. confirm the data extent 
      MOV CL,39         ;            2. update the data in the coordinate system
      SUB CL,DL
ADJUST_L:                ; adjust the location of characters
    PUSH CX
      MOV AH,8
      INT 10H
      ADD DL,CL
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV CX,1     
      INT 10H
    POP CX
      SUB DL,CL
      DEC DL             ;DL=36
      MOV AH,2
      INT 10H
      CMP DL,36
      JNL ADJUST_L

      INC DL
      INC DL
      MOV AL,30H
COMPL_0:                 ; FUNCTION : complement 0
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
      DEC DL
      CMP DL,37
      JNL COMPL_0    ;>=
                  ;-----------------------------------------
      MOV AH,2          ; GET DATA  
      MOV DL,38
      MOV DH,22
      INT 10H
      MOV AH,8                     
      INT 10H                       
      CALL SUB_AL    
      MOV CH,AL           ; store in CH                      
    DEC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H               
      CALL SUB_AL 
      MOV CL,4         
      ROL AL,CL                 ; COMBINE TWO CHARACTER INTO ONE
      OR AL,CH          ; STORE IN AL

      MOV CHOOSE_LDN,AL 
      CALL SIO_COOR_DATA

      POP DX
      POP CX
      POP BX
      MOV AH,2
      INT 10H
      JMP KEY_INPUT
;----------------------------------------------------------------------------------------
PCI_SEG:
    PUSH DX 
    PUSH CX

    set_cursor 22,19     ; CHANGE BUS
    CALL WRITE_SEG

    ADD DL,11
    set_cursor dh,dl     ; CHANGE DEVICE 
    CALL WRITE_SEG

    ADD DL,13 
    set_cursor dh,dl     ; CHANGE FUNCTION
    CALL WRITE_SEG
  
    CALL DEVICE_EXPRESS
    CALL PCI_COOR_DATA
    
    POP CX
    POP DX 
    MOV AH,2
    INT 10H
    JMP OPERATION
;-----------------------------------------------
WRITE_SEG:                                       
      MOV BL,17H
      MOV CX,2
      MOV AH,9
      MOV AL,0                    
      INT 10H           ;CLEAR DATA                       
      MOV CX,1
  WRITE_CHAR:                    
      MOV AH,1
      INT 16H
      JZ WRITE_CHAR
      MOV AH,0          ; INPUT THE FIRST CHARACTER
      INT 16H
      CMP AL,0DH
      JZ FIRST_ENTER
      MOV AH,9   
      INT 10H              
    INC DL              
      MOV AH,2          
      INT 10H
      
      MOV AH,0          ; INPUT THE SECOND CHARACTER
      INT 16H      
      CMP AL,0DH
      JZ  SECOND_ENTER     
      MOV AH,9
      INT 10H                  
                                    
      MOV AH,0         ; INPUT THE THIRD CHARACTER   ; TO CONFIRM             
      INT 16H                       
      CMP AL,0DH                         
      JZ FINISH_WRITE                ; step:      
      MOV AL,0                ; press a key to continue       
      MOV AH,9                ; if the key is 'enter' , jump to 
      INT 10H                 ; W_OUT to put the data to its port 
      MOV AH,2                ; if the thrid key is not 'enter' then clear the first and second character
      DEC DL                  ; and input again.           
      INT 10H
      MOV AH,9
      INT 10H
      JMP WRITE_CHAR
FIRST_ENTER:
      MOV AL,30H
      MOV AH,9
      INT 10H
      INC DL
      MOV AH,2
      INT 10H
SECOND_ENTER:
      MOV AL,30H
      MOV AH,9
      INT 10H                         
FINISH_WRITE:                    ; FUNCTION : PUT DATA INTO THE PORT        
      RET
;-------------------
DEVICE_EXPRESS:                  ; EXPRESS  ' DEVICE:D0 :F0 '
      PUSH DI
      PUSH SI 
      MOV DH,22
      MOV DL,31
      CALL GET_NUM
      MOV AH,0
      MOV DATA_EXPRESS,AX
      CALL CREATE_16_TO_10
      set_cursor 2,12
      MOV DI,OFFSET RESULTS
      ADD DI,3
      MOV DX,DI
      MOV AH,9
      INT 21H
    ;---------------
      MOV DH,22
      MOV DL,45
      CALL GET_NUM
      MOV AH,0
      MOV DATA_EXPRESS,AX
      CALL CREATE_16_TO_10
      set_cursor 2,16
      MOV DI,OFFSET RESULTS
      ADD DI,3
      MOV DX,DI
      MOV AH,9
      INT 21H
      
      POP SI
      POP DI 
      RET
;---------------------------------
CREATE_16_TO_10:
        mov     ax,DATAS
        mov     ds,ax
        mov     AX,DATA_EXPRESS        ; 要显示的字符
        mov     si, offset divisors
        mov     di, offset results                    
        mov     cx,5  
aa:
        mov     dx,0           
        div     word ptr [si]         ;除法指令的被除数是隐含操作数，此处为dx:ax，商ax,余数dx
        add     al,48                 ;商加上48即可得到相应数字的ASCII码
        mov     byte ptr [di],al       
        inc     di                               
        add     si,2                          
        mov     ax,dx                       
        loop    aa
        mov     cx,4   
        mov     di, offset results
bb:
        cmp     byte ptr [di],'0'     ;不输出前面的0字符   
        jne     CC
        inc     di                          
        loop    bb
cc:
        ret 
;---------------------------------------------





























;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
WRITE PROC                        
      PUSH AX                     ; FUNCTION:
      PUSH BX                     ; CHANGE THE DATA OF THE PORT;
      PUSH CX                     ; 1. CHOOSE ONE DATA
      PUSH DX                     ; 2. PRESS THE KEY 'ENTER' TO EDIT
      PUSH EDI                    ; 3. INPUT THE NEW DATA BY KEYBOARD           
                                  ; 4. PRESS THE KEY 'ENTER' AGAIN
      MOV CX,1 
      MOV AH,9
      MOV AL,0                    
      INT 10H           ;CLEAR DATA 
    DEC DL                       
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
  WRITE_INPUT:                    
      MOV AH,1
      INT 16H
      JZ WRITE_INPUT
      MOV AH,0          ; INPUT THE FIRST CHARACTER
      INT 16H
      CMP AL,0DH
      JZ NO_0
      MOV AH,9   
      INT 10H              
    INC DL              
      MOV AH,2          
      INT 10H
      
      MOV AH,0          ; INPUT THE SECOND CHARACTER
      INT 16H      
      CMP AL,0DH
      JZ  ONE_0     
      MOV AH,9
      INT 10H                  
                                    
      MOV AH,0         ; INPUT THE THIRD CHARACTER   ; TO CONFIRM             
      INT 16H                       
      CMP AL,0DH                         
      JZ W_OUT                ; step:      
      MOV AL,0                ; press a key to continue       
      MOV AH,9                ; if the key is 'enter' , jump to 
      INT 10H                 ; W_OUT to put the data to its port 
      MOV AH,2                ; if the thrid key is not 'enter' then clear the first and second character
      DEC DL                  ; and input again.           
      INT 10H
      MOV AH,9
      INT 10H
      JMP WRITE_INPUT
NO_0:
      MOV AL,30H
      MOV AH,9
      INT 10H
      INC DL
      MOV AH,2
      INT 10H
ONE_0:
      MOV AL,30H
      MOV AH,9
      INT 10H   
                         ;-------------------------------------------------------------
W_OUT:                    ; FUNCTION : PUT DATA INTO THE PORT        

      CMP MANU_OPT,1
      JE  IO_WRITE
      CMP MANU_OPT,2
      JE  MEMORY_WRITE

  WRITE_END:
      POP EDI 
      POP DX
      POP CX
      POP BX
      POP AX
      MOV AH,2
      INT 10H     
      JMP KEY_INPUT
WRITE ENDP
;----------------------------------------------------
;----------------------------------------------------
IO_WRITE:
      MOV AH,8         ; GET DATA              
      INT 10H                       
      CALL SUB_AL                  
      MOV CH,AL                     ; store in CH
    DEC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H               
      CALL SUB_AL 
      MOV CL,4             
      ROL AL,CL                    ; COMBINE TWO CHARACTER INTO ONE
      OR CH,AL         
      MOV CL,0                   ;STORE IN CH 
    PUSH CX                      ; STORE IN STACK 1                           
                  ;---------------------------------------------------------------                                
                      ; GET PORT       
      SUB DH,6                              
      MOV AL,16           ; 1. GET THE sequence number of its location,STORE IN CX
      MUL DH
      MOV CL,AL                             ; STORE IN CL  , CH=0     
      SUB DL,7                       
      MOV AL,DL                             ;column*16 + row     ; (dh-5)*16+(dl-16)/3  
      MOV AH,0                                           
      MOV DL,3
      DIV DL                     
      ADD CL,AL                             
      MOV CH,0                         ; STORE DATA IN CX                              
    PUSH CX                          ; STORE IN STACK 2
                             ; 2. Get the number of previous ports from 'IO Space START:',    
                                ; Calculate the number of previous ports
      CALL PRO_STAR 
      
      MOV DX,CX
    POP CX                        ; GET FROM STACK 2
      ADD DX,CX                     
    POP CX                        ; GET FROM STACK 1
      MOV AL,CH              
      OUT DX,AL                    
      CALL IOS_COOR_DATA
      JMP WRITE_END
;-------------------------------------------------
MEMORY_WRITE:
      MOV AH,8         ; GET DATA              
      INT 10H                       
      CALL SUB_AL    
      MOV CH,AL           ; store in CH                      
    DEC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H               
      CALL SUB_AL 
      MOV CL,4            ; STORE IN AL
      ROL AL,CL                 ; COMBINE TWO CHARACTER INTO ONE
      OR AL,CH                                                       
                ;---------------------------------------------------------------                                
                                   ; GET ADDRESS
      MOV DH,2
      MOV DL,21 
      CALL PRO_ADD              
      MOV ES:[EDI],AL          
      CALL MEMORY_COOR_DATA
      JMP WRITE_END
;----------------------------------------------------------------------------------




;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
PRO_ADD:           ; -----combine the 16 character after 'ADDRESS' into one      
    PUSH AX 
    PUSH CX
      MOV CX,0
      MOV EDI,0                   ;  STORE IN EDI

      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CALL SUB_AL       
      MOV CH,AL    ;1                  
      ROL CH,4   
      CALL NEXT_S
      OR CH,AL     ;2
      CALL NEXT_S
      MOV CL,AL    ;3
      ROL CL,4
      CALL NEXT_S
      OR CL,AL     ;4
      MOV DI,CX
      ROL EDI,16

      MOV CX,0
      CALL NEXT_S      
      MOV CH,AL    ;1                  
      ROL CH,4   
      CALL NEXT_S
      OR CH,AL     ;2
      CALL NEXT_S
      MOV CL,AL    ;3
      ROL CL,4
      CALL NEXT_S
      OR CL,AL     ;4
      MOV DI,CX

    POP CX   
    POP AX
      RET
NEXT_S:
      INC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CALL SUB_AL    
      RET 
;------------------------------------------------------------
SUB_AL:                             ; FUNCTION:
      SUB AL,30H                    ; Turn the value of al to original value ,not ascii 
      CMP AL,9
      JLE SSUB 
      SUB AL,7
 SSUB:
      RET

ADD_AL:                           ; FUNCTION : Turn original value to ascii 
    CMP AL,9
    JLE JJUD
    ADD AL,7
 JJUD:
    ADD AL,30H
    RET
;------------------------------------------------------------
PRO_STAR:                            ; setion 2 : combine the four character  after 'Start:' into one      
    PUSH AX 
      MOV DL,30
      MOV DH,2
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CALL SUB_AL
      MOV CH,AL                        ; gao 8 wei STORE IN CH 
      MOV CL,4
      ROL CH,CL
      CALL NEXT_S
      OR CH,AL
      CALL NEXT_S
      ROL AL,CL
      MOV CL,AL
      CALL NEXT_S                      
      OR CL,AL                         ; di 8 wei STORE IN CL        
    POP AX
      RET
;----------------------------------------------
CHANGE:  
     MOV AH,8 
     INT 10H
     MOV BL,AH
     MOV STORE_COLOR,BL
     MOV BL,70H
     MOV AH,9
     INT 10H                           
             MOV CHANGE_StoreDX,DX  ; A CHANGING COORDINATE IN THE UPPER LEFT CORNER -LEFT
             MOV DH,5
             MOV DL,4
             MOV AH,2
             INT 10H
             MOV BL,74H
             MOV DX,CHANGE_StoreDX
             MOV AL,DH
             SUB AL,6
             CALL ADD_AL
             MOV AH,9
             INT 10H                               

                    CMP MANU_OPT,2           ; IF NOT MEMORY , JMP 
                    JNZ NO_CHANGE_TITLE1

                    CALL SUB_AL     ;CHANGE TITLE BY LEFT TOP ANGLE-LEFT
                    MOV CL,AL       ;STORE IN CL       
                    MOV DH,22
                    MOV DL,42
                    MOV AH,2
                    INT 10H             ;TITLE   13-28
                    MOV AH,8            ;BOTTOM  28-43
                    INT 10H
                    CALL SUB_AL
                    ADD CL,AL 
                    MOV DH,2
                    MOV DL,27
                    MOV AH,2
                    INT 10H
                    MOV AL,CL
                    MOV CX,1
                    MOV AH,9
                    MOV BL,1BH                                     
                    INT 10H 
                NO_CHANGE_TITLE1:    
                    MOV DX,CHANGE_StoreDX             
                    MOV AH,2
                    INT 10H             

     INC DL
     INT 10H
     MOV AH,8
     INT 10H
     MOV BL,70H
     MOV AH,9
     INT 10H

             MOV CHANGE_StoreDX,DX       ; A CHANGING COORDINATE IN THE UPPER LEFT CORNER - RIGHT       
             MOV DH,5
             MOV DL,5
             MOV AH,2
             INT 10H
             MOV BL,74H
             MOV DX,CHANGE_StoreDX
             MOV AL,DL
             SUB AL,7
             MOV CL,3
             MOV AH,0
             DIV CL
             CALL ADD_AL
             MOV CX,1
             MOV AH,9
             INT 10H
                    CMP MANU_OPT,2
                    JNZ NO_CHANGE_TITLE2
                  
                    MOV VAR_SI,0
                    CALL SUB_AL     ;CHANGE TITLE BY ANGLE-RIGHT
                    MOV CL,AL       ;STORE IN CL       
                    MOV DH,22
                    MOV DL,43
                    MOV AH,2
                    INT 10H
                    MOV AH,8
                    INT 10H
                    CALL SUB_AL
                    ADD CL,AL       ;STORE IN CL 
                    MOV DH,2
                    MOV DL,28
                    MOV AH,2
                    INT 10H
                    MOV AL,CL       ;CL==>AL 
                    MOV CX,1
                    MOV BL,1BH      ; READY TO SHOW

                    CMP AL,16                  
                    JNL BIG_F       ; >=16,JMP  
                    CALL ADD_AL   ; ELSE 
                    MOV AH,9   
                    INT 10H
                    JMP LOCA_27
                BIG_F:
                    MOV VAR_SI,1
                    SUB AL,16
                    CALL ADD_AL
                    MOV AH,9
                    INT 10H
                LOCA_27: 
                    DEC DL
                    MOV AH,2
                    INT 10H
                    MOV AH,8
                    INT 10H
                    ADD AX,VAR_SI
                    CMP AL,16
                    JNL BIG_FF       ; >=16,JMP 
                    CALL ADD_AL
                    MOV VAR_SI,0
                    MOV AH,9
                    INT 10H
                    JMP LOCA_26
                BIG_FF:
                    MOV var_SI,1
                    SUB AL,16
                    CALL ADD_AL
                    MOV AH,9
                    INT 10H 

                LOCA_26:
                    MOV DL,26          
                    MOV DH,2                    
                    MOV CX,DX 
                    MOV DH,22
                    MOV DL,41
                LOOP_26_TO_13:               ; LOOP SHOW TIELE, DH=2,DL=26--->13                                                     
                    MOV AH,2                 ; FROM BOTTOM ADDREDD
                    INT 10H
                    MOV AH,8
                    INT 10H
                    CALL SUB_AL
                    ADD AX,VAR_SI
                    CMP AL,16
                    JNL BIG_16         ; >= , JUMP 
                    MOV VAR_SI,0           
                    JMP JUMP_1
                BIG_16:              ; DATA IN AL 
                    SUB AL,16
                    MOV VAR_SI,1
                JUMP_1:
                  PUSH DX 
                    MOV DX,CX
                    MOV AH,2
                    INT 10H
                    CALL ADD_AL                   ;--------------HAVGE SOME TROUBLE
                  PUSH CX
                    MOV CX,1
                    MOV AH,9
                    INT 10H
                  POP CX
                    DEC CL
                  POP DX 
                    DEC DL 
                    CMP CL,13
                    JNL LOOP_26_TO_13       ; >= ,JUMP 
                    MOV CX,1       
                    
                NO_CHANGE_TITLE2:
		            MOV DX,CHANGE_StoreDX
		            MOV AH,2
		            INT 10H
                    RET
;----------------------------------------------
SHOW_AL:
      MOV CH,AL            ;STORE IN CH
      CALL BL_COLOR
      MOV CL,4
      ROL AL,CL
      AND AL,0FH           
    PUSH CX
      MOV CX,1
      CALL ADD_AL
      MOV AH,9
      INT 10H
    POP CX

      INC DL
      MOV AH,2
      INT 10H
      AND CH,0FH
      MOV AL,CH
      MOV AH,9
      MOV CX,1
      CALL ADD_AL
      INT 10H

      INC DL
      MOV AH,2
      INT 10H
      MOV AL,0
      MOV AH,9
      INT 10H

      MOV AH,2
      INC DL
      INT 10H
      RET
BL_COLOR:
      MOV BL,1EH
      CMP AL,00
      JZ MP1
      CMP AL,0FFH
      JZ MP2
      JMP MP3
  MP1:MOV BL,18H
      JMP MP3
  MP2:MOV BL,17H
  MP3:RET
;----------------------------
UP:  CALL BACK_BL                     ; FUNCTION : 1. recover its color     
     CMP DH,6                         ;            2. press the key 'up' on keyboard , it move up
     JZ NO_UP
     DEC DH
     MOV AH,2
     INT 10H
  NO_UP:    
     CALL CHANGE
     RET
DOWN:CALL BACK_BL                    ; press the key 'down' on keyboard , it move down
     CMP DH,21
     JZ NO_DOWN
     INC DH
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
  NO_DOWN:    
     SUB DH,15
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
LEFT:CALL BACK_BL                  ; press the key 'left' on keyboard , it move left
     CMP DL,8
     JLE TO_RIGHT
     SUB DL,3
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
  TO_RIGHT:
     ADD DL,45
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
RIGHT:CALL BACK_BL                 ; press the key 'right' on keyboard , it move right
     CMP DL,50
     JNLE TO_LEFT
     ADD DL,3
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
  TO_LEFT:
     SUB DL,45
     MOV AH,2
     INT 10H
     CALL CHANGE
     RET
BACK_BL:             ;---------------------- FUNCTION : RESUME THE COLOR WHEN IT IS NOT CHOSE
     MOV AH,8
     INT 10H
     MOV BL,STORE_COLOR        
     MOV AH,9
     INT 10H
  DEC DL
     MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     MOV AH,9
     INT 10H
  INC DL
     MOV AH,2 
     INT 10H
;-----------------;
     MOV AH,8
     INT 10H
     MOV BL,1EH
     CMP AL,30H  
     JZ IS_0
     CMP AL,46H
     JZ IS_F
      
  NOT_FF: 
     MOV AH,8
     INT 10H      
     MOV AH,9
     INT 10H
    
     DEC DL
     MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     MOV AH,9
     INT 10H
     RET
  IS_0:
     DEC DL 
     MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     CMP AL,30H
     JZ IS_00
     INC DL
     MOV AH,2
     INT 10H
     JMP NOT_FF
  IS_00:
     MOV BL,18H
     MOV AH,9
     INT 10H
     INC DL
     MOV AH,2
     INT 10H
     MOV AH,9
     INT 10H
     DEC DL
     MOV AH,2
     INT 10H
     RET 
  IS_F:
     DEC DL 
     MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     CMP AL,46H
     JZ IS_FF
     INC DL
     MOV AH,2
     INT 10H
     JMP NOT_FF
  IS_FF:
     MOV BL,17H
     MOV AH,9
     INT 10H
     INC DL
     MOV AH,2
     INT 10H
     MOV AH,9
     INT 10H
     DEC DL
     MOV AH,2
     INT 10H
     RET
;---------------------------------
PRE_ROW:                            ; E820
     CMP DH,3
     JNL CAN_UP
     CMP E820_PAGE,2
     JE  PAGE2_TO_PAGE1
     JMP E820_INPUT
  CAN_UP:
     CALL E820_BackColor
     DEC DH
     MOV AH,2
     INT 10H
     CALL E820_CHANGE
     JMP  E820_INPUT 

NEXT_ROW:
     CMP DH,22
     JLE CAN_DOWN
     CMP E820_PAGE,1
     JE  PAGE1_TO_PAGE2
     JMP E820_INPUT
  CAN_DOWN: 
     CALL E820_BackColor  
     INC DH
     MOV AH,2
     INT 10H
     CALL E820_CHANGE
     JMP E820_INPUT 
;--------------------------------
PAGE2_TO_PAGE1:
     MOV SHOW_ARDS_NUM,21 
     MOV E820_PAGE,1
     MOV BH,17H
     CALL SET_WINDOWS
     MOV BH,0
     CALL TITLE_E820  
              PUSH DX                ; CHANGE PAGE TITTLE 
              PUSH CX        
              MOV DH,24
              MOV DL,6
              MOV AH,2
              INT 10H
              MOV AL,1
              CALL ADD_AL
              MOV BL,17H
              MOV CX,1
              MOV AH,9
              INT 10H
              POP CX 
              POP DX 
              MOV AH,2
              INT 10H     
    CALL E820_SHOW_ARDS
    MOV DH,23
    CALL E820_CHANGE
    JMP E820_INPUT      
;--------------------------------------------------            
PAGE1_TO_PAGE2:
     MOV AX,ARDS_NUM
     SUB AX,21
     MOV SHOW_ARDS_NUM,AX     
     MOV E820_PAGE,2    
     MOV BH,17H
     CALL SET_WINDOWS
     MOV BH,0
     CALL TITLE_E820
              PUSH DX                ; CHANGE PAGE TITTLE 
              PUSH CX        
              MOV DH,24
              MOV DL,6
              MOV AH,2
              INT 10H
              MOV AL,2
              CALL ADD_AL
              MOV BL,17H
              MOV CX,1
              MOV AH,9
              INT 10H
              POP CX 
              POP DX 
              MOV AH,2
              INT 10H  
    MOV DH,2
    CALL E820_CHANGE
    JMP E820_INPUT

;--------------------------------
E820_CHANGE:
      PUSH DX
      MOV DL,0
      MOV AH,2
      INT 10H
      MOV BL,57H              ; PINK WHITE 
      MOV CX,80
  COLOR_PINK:
      PUSH CX
      MOV AH,8
      INT 10H
      MOV CX,1
      MOV AH,9
      INT 10H

      INC DL
      MOV AH,2
      INT 10H
      POP CX
      LOOP COLOR_PINK
      POP DX
      MOV AH,2
      INT 10H
      RET 
E820_BackColor:
      PUSH DX 
      MOV DL,0
      MOV AH,2
      INT 10H
      MOV BL,17H              ; PINK WHITE 
      MOV CX,80
  COLOR_WHITE:
      PUSH CX
      MOV AH,8
      INT 10H
      MOV CX,1
      MOV AH,9
      INT 10H

      INC DL
      MOV AH,2
      INT 10H
      POP CX
      LOOP COLOR_WHITE    
      POP DX
      MOV AH,2
      INT 10H
      RET  
;---------------------------------
COOR_SYSTEM:
      MOV DH,5
      MOV DL,7
      MOV AH,2
      INT 10H      
      MOV CX,10H
      MOV AH,9
      MOV AL,0
      MOV COOR_VAR,AX
      MOV BL,14H          ; COLOR BLUE RED 
  LOOP_ROW:
    PUSH CX
      MOV CX,1
      MOV AL,30H          ; 0
      MOV AH,9
      INT 10H
      INC DL      
      MOV AH,2
      INT 10H     

      MOV AX,COOR_VAR    
      CALL ADD_AL      ;123..789ABCDEF
      INT 10H

      MOV AH,2
      INC DL
      INT 10H
      MOV AL,0           ; SPACE 
      MOV AH,9
      INT 10H

      MOV AH,2           ;NEXT 
      INC DL
      INT 10H
      INC COOR_VAR
      POP CX
      LOOP LOOP_ROW
 ;------------------------- 
      MOV DL,4
      MOV DH,6
      INT 10H
      MOV AH,9
      MOV AL,0
      MOV COOR_VAR,AX
      MOV CX,10H
   LOOP_COLMN:
      PUSH CX
      MOV CX,1
      MOV AX,COOR_VAR
      CALL ADD_AL         ; 123..789ABCDEF
      INT 10H                

      INC DL 
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV AL,30H            ; 0
      INT 10H

      MOV DL,4              ; NEXT 
      INC DH
      MOV AH,2
      INT 10H
      INC COOR_VAR
      POP CX
      LOOP LOOP_COLMN
      RET
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
;----------------------------------------------------------------------------------------
OPTIONS:                                 ;--------- SHOW MESS OF MANU ------------
    MOV COUNT_OPTS,0        
    MOV AX,DATAS
    MOV DS,AX
    MOV SI,OFFSET OPT_IOS                ; IO SPACE 
    MOV CX,OPT_IOS_LEN
    MOV DH,8
    MOV DL,30
    PUSH DS
    POP ES
    MOV BP,SI
    MOV BH,0
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H
    INC COUNT_OPTS

    MOV SI,OFFSET OPT_MEMORY              ; MEMORY
    MOV CX,OPT_MEMORY_LEN
    MOV DH,9
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H
    INC COUNT_OPTS

    MOV SI,OFFSET OPT_CMOS                ; CMOS 
    MOV CX,OPT_CMOS_LEN 
    MOV DH,10
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H
    INC COUNT_OPTS

    MOV SI,OFFSET OPT_SIO             ; SUPER IO
    MOV CX,OPT_SIO_LEN
    MOV DH,11
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H
    INC COUNT_OPTS

    MOV SI,OFFSET OPT_PCI               ; PCI 
    MOV CX,OPT_PCI_LEN
    MOV DH,12
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS   

    MOV SI,OFFSET OPT_E820              ; E820
    MOV CX,OPT_E820_LEN
    MOV DH,13
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS   

    MOV SI,OFFSET OPT_SMBUS              ; SMBUS 
    MOV CX,OPT_SMBUS_LEN
    MOV DH,14
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS   

    MOV SI,OFFSET OPT_SMBIOS             ; SMBIOS
    MOV CX,OPT_SMBIOS_LEN
    MOV DH,15
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS   

    MOV SI,OFFSET OPT_MSR             ; MSR
    MOV CX,OPT_MSR_LEN
    MOV DH,16
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS   

    MOV SI,OFFSET OPT_ACPI             ; MSR
    MOV CX,OPT_ACPI_LEN
    MOV DH,17
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS     

    MOV SI,OFFSET OPT_EXIT                ; EXIT 
    MOV CX,OPT_EXIT_LEN 
    MOV DH,18
    MOV DL,30
    MOV BP,SI
    MOV AL,0
    MOV BL,07H
    MOV AH,13H
    INT 10H 
    INC COUNT_OPTS  
    RET
;---------------------------
M_UP:                         ; --------------MANU OPERATION---------------
    MOV AH,9
    MOV AL,0
    INT 10H
    CMP DH,9  
    JNL M_NO_UP                 ; >=
    ADD DH,COUNT_OPTS         
  M_NO_UP:    
    DEC DH
    MOV AH,2
    INT 10H
    MOV AH,9
    MOV CX,1
    MOV AL,2AH
    MOV BL,07H
    INT 10H
    RET
M_DOWN:
    MOV AH,9
    MOV AL,0
    INT 10H
    MOV CL,COUNT_OPTS
    ADD CL,6 
    CMP DH,CL        
    JLE M_NO_DOWN     
    SUB DH,COUNT_OPTS
  M_NO_DOWN:    
    INC DH
    MOV AH,2
    INT 10H   
    MOV AH,9
    MOV CX,1
    MOV AL,2AH
    MOV BL,07H
    INT 10H
    RET
;--------------------------
TITLE_IOSpace:                       ; show the title 'IO Space  Start:      End:    '
      MOV AX,DATAS
      MOV DS,AX
      MOV SI,OFFSET MESS_IOS
      MOV CX,MESS_IOS_LEN
      MOV DH,2
      MOV DL,13
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      RET
TITLE_MEMORY:
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_ADDRESS
      MOV CX,MESS_ADDRESS_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      

      MOV SI,OFFSET MESS_ADDRESS_TYPE        ;BOTTOM
      MOV CX,MESS_ADDRESS_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV BH,0
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H 

      PUSH SI
      MOV DH,22
      MOV DL,28
      MOV SI,DX
      MOV DH,2
      MOV DL,13
COPY_TO:           ;       COPY THE ADDRESS TO TITLE 
      PUSH DX
      MOV DX,SI
      INC SI
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      POP DX
      MOV AH,2
      INT 10H
      MOV AH,9
      MOV BL,1BH
      INT 10H
      INC DL
      CMP DL,44
      JLE COPY_TO
      POP SI

      RET
TITLE_CMOS: 
      MOV AX,DATAS
      MOV DS,AX
      MOV SI,OFFSET MESS_CMOS
      MOV CX,MESS_CMOS_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_CMOS_TYPE       ;BOTTOM
      MOV CX,MESS_CMOS_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET
TITLE_SIO:                         ;SET TITLE 'ADDRESS'
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_SIO
      MOV CX,MESS_SIO_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_SIO_TYPE     ; SET BOTTOM 
      MOV CX,MESS_SIO_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET  
TITLE_PCI:                         ;SET TITLE 'ADDRESS'
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_PCI
      MOV CX,MESS_PCI_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_PCI_TYPE     ; SET BOTTOM 
      MOV CX,MESS_PCI_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET
TITLE_E820:                         ;SET TITLE 'ADDRESS'
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_E820
      MOV CX,MESS_E820_LEN
      MOV DH,1
      MOV DL,0
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,47H             ;RED WHITE
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_E820_PAGE     ; SET BOTTOM 
      MOV CX,MESS_E820_PAGE_LEN
      MOV DH,24
      MOV DL,0
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET
TITLE_SMBUS:
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_SMBUS
      MOV CX,MESS_SMBUS_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_SMBUS_TYPE     ; SET BOTTOM 
      MOV CX,MESS_SMBUS_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET
 TITLE_SMbIOS:
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_SMBIOS
      MOV CX,MESS_SMBIOS_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_SMBIOS_TYPE     ; SET BOTTOM 
      MOV CX,MESS_SMBIOS_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET     
TITLE_MSR:
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_MSR
      MOV CX,MESS_MSR_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_MSR_TYPE    
      MOV CX,MESS_MSR_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET     
TITLE_ACPI:
      MOV AX,DATAS 
      MOV DS,AX
      MOV SI,OFFSET MESS_ACPI
      MOV CX,MESS_ACPI_LEN
      MOV DH,2
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H      
      
      MOV SI,OFFSET MESS_ACPI_TYPE    
      MOV CX,MESS_ACPI_TYPE_LEN
      MOV DH,22
      MOV DL,4
      PUSH DS
      POP ES
      MOV BP,SI
      MOV AL,0
      MOV BL,17H
      MOV AH,13H
      INT 10H      
      RET     
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------
;------------------------------------------------------------------------------------    
ENDING PROC             ;--------------- QUIT PROGRAM AND CLEAR SCREEN --------------
    CALL CLEAR_SCREEN
    MOV AX,4C00H
    INT 21H
ENDING ENDP

CLEAR_SCREEN PROC
    MOV CX,0
    MOV DH,24                  
    MOV DL,79
    MOV BH,07       ; COLOR FULL IN 
    MOV AL,0        ; CLEAR THE WHOLE WINDOW 
    MOV AH,6
    INT 10H
    MOV BH,0        ; SET PAGE 0
    MOV DX,0        ; CURSOR
    MOV AH,2
    INT 10H
    RET
CLEAR_SCREEN ENDP
;--------------------------------------------------------------------------------------
SET_WINDOWS:
    MOV CH,WINTOP         ; SET WINDOWS    
    MOV CL,WINLEFT
    MOV DH,WINBOTTOM
    MOV DL,WINRIGHT  
    MOV AL,0
    MOV AH,6 
    INT 10H
    RET
;--------------------------
set_cursor macro i,j
        mov ah,2
        mov bh,0
        mov dh,i
        mov dl,j
        int 10h
endm

;--------------------------------------------------------------------------------------------
CSEG ENDS                         ;---------------------- CODE END -------------------------
     END START
