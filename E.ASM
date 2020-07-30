ESCKEY=1BH                                   ;THE ASCII OF key 'ESC' ON KEYBOARD
DATA SEGMENT
MESS DB 'IO Space   START:      END:    '
MESS_LEN=$-OFFSET MESS                       ;THE LENGTH OF MESS DB
DATA ENDS

WINWIDTH = 80                                ;THE PARAMETER OF WINDOWS
WINTOP = 0
WINLEFT = 0                                  
WINBOTTOM = 24
WINRIGHT = WINLEFT+WINWIDTH-1
COLOR = 97H
PAGEN = 0
L_SHIFT = 00000010B                          ;SET BINARY THE 'SHIFT' KEY 
R_SHIFT = 00000001B
CSEG SEGMENT
     ASSUME CS:CSEG,DS:DATA

START:                                        ;The program starts here
      MOV AL,PAGEN                            
      MOV AH,5                     ;USE A NEW PAGE
      INT 10

      MOV CH,WINTOP                ;CREATE WINDOWS
      MOV CL,WINLEFT
      MOV DH,WINBOTTOM
      MOV DL,WINRIGHT
      MOV BH,COLOR
      MOV AL,0
      MOV AH,6
      INT 10H

                                  ;Call subroutine  
      CALL ZUOBIAO                ;ESTABLISH THE COORDINATE SYSTEM
      CALL TITLE_IOSpace                 ;SET TITLE 'IO Space START:   END:'    
      MOV DI,0
      CALL INNER                  ;SHOW THE DATA IN THE COOR SYSTEM
      CALL MOVING 


   OVER:                          
      MOV AX,4C00H                ;The program starts here
      INT 21H

WRITE PROC                        ; subroutine WRITE
      PUSH AX                     ; FUNCTION:
      PUSH BX                     ; CHANGE THE DATA OF THE PORT;
      PUSH CX                     ; 1. CHOOSE ONE DATA
      PUSH DX                     ; 2. PRESS THE KEY 'ENTER' TO EDIT
      MOV CX,1                    ; 3. INPUT THE NEW DATA BY KEYBOARD
      MOV AH,9                    ; 4. PRESS THE KEY 'ENTER' AGAIN
      MOV AL,0                    
      INT 10H           ;CLEAR DATA 
      DEC DL                       
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H

  RD_KEY:
      MOV AH,2                      ; INPUT CHARACTER FROM KEYBOARD
      INT 16H
      TEST AL,L_SHIFT+R_SHIFT       ; PRESS THE KEY 'SHIFT' TO QUIT
      JNZ OVER                      
      MOV AH,1
      INT 16H
      JZ RD_KEY
      MOV AH,0          ; INPUT THE FIRST CHARACTER
      INT 16H

      MOV AH,9   
      INT 10H              
      INC DL              
      MOV AH,2          
      INT 10H
      MOV AH,0          ; INPUT THE SECOND CHARACTER
      INT 16H      
      MOV AH,9
      INT 10H                  
                                    
      MOV AH,0         ; INPUT THE THIRD CHARACTER   ;IN ORDER TO CONFIRM             
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
      JMP RD_KEY
                     ;-------------------------------------------------------------
W_OUT:                                ; FUNCTION OF W_OUT  : PUT DATA INTO THE PORT
      MOV AH,8         ; GET DATA              
      INT 10H                       
      CALL SUB_AL    
      MOV CH,0                
      MOV CL,AL                     ; store in cL 
      DEC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H               
      CALL SUB_AL 
      MOV CH,AL                     
      MOV AL,10H                    ; COMBINE TWO CHARACTER INTO ONE
      MUL CH                        ; CL*16+CH
      ADD CX,AX                     ; STORE THE DATA IN CX        ; STORE IN STACK 1
      PUSH CX
                  ;---------------------------------------------------------------                                
                      ; GET PORT 
      SUB DH,5                              ; FUNCTION : GET THE PORT NUMBER   
      MOV AL,16           ; FIRST: GET THE sequence number of its location
      MUL DH
      MOV CL,AL                             ; STORE IN CL  , CH=0     
      SUB DL,16                       
      MOV AX,DX                             ;column*16 + row     ; (dh-5)*16+(dl-16)/3  
      MOV AH,0                                           
      MOV DL,3
      DIV DL                     
      ADD CL,AL                             ;STORE IN STACK 2 
      PUSH CX                      
                         ; SECOND: Get the number of previous ports from 'IO Space START:',    
      MOV DH,2           ;         Calculate the number of previous ports
      MOV DL,33
      CALL GET_CHAR                                      
      ADD CL,AL                             ; store in CL    , CH=0
      DEC DL
      CALL GET_CHAR
      MOV CH,AL
      MOV AL,16
      MUL CH 
      ADD CX,AX                    ; ACCUMULATIVE IN CX
      PUSH CX                      ; STORE IN STACK 3
      DEC DL
      CALL GET_CHAR
      MOV CL,AL
      MOV AL,256                   ; out of ??????????                 
      MUL CL  
      POP CX                       ; GET FROM STACK 3
      ADD CX,AX
      PUSH CX                      ; STORE IN STACK 3
      DEC DL
      CALL GET_CHAR
      MOV CL,AL
      MOV CH,0
      MOV AX,4096
      PUSH DX                      ; STORE IN STACK 4
      MUL CX
      POP DX                       ; GET FORM STACK 4
      POP CX                       ; GET FROM STACK 3
      ADD AX,CX
      POP CX                       ; GET FROM STACK 2
      ADD AX,CX                    ; STORE PORT IN AX
      MOV DX,AX
      POP CX                       ; GET FROM STACK 1
      MOV AX,CX
      OUT DX,AL                    
    ;  OUT DX,AL       ;MAYBE TRY IT AGAIN
           
      POP DX
      POP CX
      POP BX
      POP AX
      MOV AH,2
      INT 10H     
      RET
WRITE ENDP

GET_CHAR:
      MOV AH,2                       
      INT 10H                        
      MOV AH,8
      INT 10H
      CALL SUB_AL                       ; Turn the value of al to original value ,not ascii  
      RET


EX_SEG:                                 ; FUNCTION : CHANGE THE DATA EXTENT
      PUSH AX                           ;            INPUT THE CHARACTERS AFTER 'Start:' to do it 
      PUSH BX
      PUSH CX                               
      PUSH DX
      MOV BL,1BH
CLEAR:                                  ; CLEAR THE DATA AFTER 'Start:'
      MOV DH,2
      MOV DL,30
      MOV AH,2
      INT 10H          
      MOV CX,5
      MOV AL,0
      MOV BL,1BH
      MOV AH,9
      INT 10H
      MOV CX,1
IN_NUM:                                 ; FUNCTION : input characters
      MOV AH,2 
      INT 10H
      INT 16H
      TEST AL,L_SHIFT+R_SHIFT
      JNZ OVER2
      MOV AH,1
      INT 16H
      JZ IN_NUM

      MOV AH,0                         ; input first character 
      INT 16H      
      CMP AL,0DH                       ; if the character is 'enter',jump to T_ENTER
      JZ T_ENTER  
      CMP AL,60H                       ; if the  character is '`',jump to CLEAR
      JZ CLEAR                          
      MOV AH,9
      INT 10H
      INC DL
      CMP DL,33                        
      JLE IN_NUM                       ; IF <=34 - JUMP  ;  IF > 34 - continue ;
CONFIRM:  
      MOV AH,2
      INT 16H   
      TEST AL,L_SHIFT+R_SHIFT
      JNZ OVER2
      MOV AH,1
      INT 16H
      JZ CONFIRM
      MOV AH,0                         ; INPUT A CHARACTER TO CONFIRM
      INT 16H 
      CMP AL,0DH                       ; IF ITS 'ENTER' , JUMP T_ENTER
      JZ T_ENTER             
      CMP AL,60H                       ; IF ITS '`' , JUMP CLEAR
      JZ CLEAR
      JMP CONFIRM
   ENDD:
      POP DX
      POP CX
      POP BX
      POP AX                 
      MOV AH,2              
      INT 10H               
      JMP S_COR                               

OVER2:
      MOV AX,4C00H                         
      INT 21H   
 
T_ENTER:                                ; FUNCTION : 1. confirm the data extent  ('Start' and 'End') 
                               ;            2. update the data in the coordinate system
      MOV CL,34
      SUB CL,DL
      MOV BL,1BH
MOVE_CHAR:                                 ; FUNCTION : adjust the location of characters on 'Start:'
      PUSH CX                           ;            字符向后移动并在前边补0
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
      JNL MOVE_CHAR
      MOV AL,30H
      INC DL
complement_0:                                 ; FUNCTION : complement 0 for Start
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
      DEC DL
      CMP DL,30
      JNL complement_0                    ;>=


                                     ; T_ENTER's FUNCTION : 
      MOV DL,30                      ; 1. produce the end of the DATA EXTENT
      MOV AH,2                       ; 2. combine the four character into one
      INT 10H
start_to_end:                            ; setion 1 : produce the end of the DATA EXTENT
      MOV AH,8                       
      INT 10H
      ADD DL,10
      MOV AH,2
      INT 10H
      MOV AH,9
      INT 10H
      SUB DL,9
      MOV AH,2
      INT 10H
      CMP DL,33
      JLE start_to_end                     ; if dl >= 30 jump 

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
      CALL PRO_DI
      JMP ENDD

PRO_DI:                            ; setion 2 : combine the four character  after 'Start:' into one
      PUSH CX
      MOV DL,30
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CALL SUB_AL
      MOV CH,AL
      MOV CL,4
      ROL CH,CL
      CALL NEXT_S
      OR CH,AL
      CALL NEXT_S
      ROL AL,CL
      MOV CL,AL
      CALL NEXT_S
      OR CL,AL
      MOV DI,CX
      POP CX
      CALL INNER
      RET

SUB_AL:                             ; FUNCTION:
      SUB AL,30H                    ; Turn the value of al to original value ,not ascii 
      CMP AL,9
      JLE HHH
      SUB AL,7
  HHH:RET

NEXT_S:
      INC DL
      MOV AH,2
      INT 10H
      MOV AH,8
      INT 10H
      CALL SUB_AL    
      RET
      
TO_EX_SEG:                                  ; MIDDLE JUMP ;JUNP TO EX_SEG
      JMP EX_SEG
TO_OVER:
     MOV AX,4C00H
     INT 21H
TO_WRITE:
     CALL WRITE
     JMP S_COR

MOVING:                                  ; FUNCTION : PRESS DIFFERENT KEY TO CHOOSE DIFFERENT FUNCTION
     MOV CX,1
     MOV DH,5
     MOV DL,16
     MOV BH,PAGEN
     MOV AH,2
     INT 10H
     CALL CHANGE
S_COR:
     MOV AH,2
     INT 16H
     TEST AL,L_SHIFT+R_SHIFT
     JNZ TO_OVER
     MOV AH,1
     INT 16H
     JZ S_COR
     MOV AH,0
     INT 16H    

     CMP AL,0DH                               ; 'ENTER'
     JE TO_WRITE
     CMP AH,48H                               ; UP
     JE UP_JMP
     CMP AH,50H                               ; DOWN 
     JE DOWN_JMP
     CMP AH,4BH                               ; LEFT 
     JE LEFT_JMP                           
     CMP AH,4DH                               ; RIGHT
     JE RIGHT_JMP 
     CMP AL,96                                ; ' ` '            
     JE TO_EX_SEG
     JMP S_COR
     
CHANGE:                                         ; FUNCTION :  CHANGE THE COLOR WHEN IT IS CHOSE
     MOV AH,8 
     INT 10H
     MOV BL,AH
     MOV BL,70H
     MOV AH,9
     INT 10H
                                    
                 PUSH SI           ; A CHANGING COORDINATE IN THE UPPER LEFT CORNER -LEFT 
                 MOV SI,DX
                 MOV DH,4
                 MOV DL,13
                 MOV AH,2
                 INT 10H
                 MOV BL,74H
                 MOV DX,SI
                 MOV AL,DH
                 SUB AL,5
                 CALL JUDGE_ZB
                 MOV AH,9
                 INT 10H                               
                 MOV DX,SI                
                 MOV AH,2
                 INT 10H
     INC DL
  ;  MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     MOV BL,70H
     MOV AH,9
     INT 10H
                 MOV SI,DX       ; A CHANGING COORDINATE IN THE UPPER LEFT CORNER - RIGHT       
                 MOV DH,4
                 MOV DL,14
                 MOV AH,2
                 INT 10H
                 MOV BL,74H
                 MOV DX,SI
                 MOV AL,DL
                 SUB AL,16
                 MOV CL,3
                 MOV AH,0
                 DIV CL
                 CALL JUDGE_ZB
                 MOV CX,1
                 MOV AH,9
                 INT 10H
                 MOV DX,SI
                 MOV AH,2
                 INT 10H
                 POP SI
     JMP S_COR

UP_JMP:JMP UP
DOWN_JMP:JMP DOWN
LEFT_JMP:JMP LEFT
RIGHT_JMP:JMP RIGHT

JUDGE_ZB:                               ; FUNCTION : Turn original value to ascii 
    CMP AL,9
    JLE JJ3
    ADD AL,7
JJ3:ADD AL,30H
    RET

UP:  CALL BACK_BL                       ; FUNCTION : 1. recover its color            
     CMP DH,5                           ;            2. press the key 'up' on keyboard , it move up   
     JZ NO_UP                           
     DEC DH
     MOV AH,2
     INT 10H
  NO_UP:    
     CALL CHANGE
DOWN:CALL BACK_BL                                     ; press the key 'down' on keyboard , it move down
     CMP DH,20
     JZ NO_DOWN
     INC DH
     MOV AH,2
     INT 10H
     CALL CHANGE
  NO_DOWN:    
     SUB DH,15
     MOV AH,2
     INT 10H
     CALL CHANGE
LEFT:CALL BACK_BL                                     ; press the key 'left' on keyboard , it move left
     CMP DL,18
     JLE TO_RIGHT
     SUB DL,3
     MOV AH,2
     INT 10H
     CALL CHANGE
  TO_RIGHT:
     ADD DL,45
     MOV AH,2
     INT 10H
     CALL CHANGE
RIGHT:CALL BACK_BL                                    ; press the key 'right' on keyboard , it move right
     CMP DL,60
     JNLE TO_LEFT
     ADD DL,3
     MOV AH,2
     INT 10H
     CALL CHANGE
  TO_LEFT:
     SUB DL,45
     MOV AH,2
     INT 10H
     CALL CHANGE
BACK_BL:                                 ; FUNCTION : RESUME THE COLOR WHEN IT IS NOT CHOSE
     MOV AH,8
     INT 10H
     CALL BL_COLOR        
     MOV AH,9
     INT 10H
     DEC DL
     MOV AH,2
     INT 10H
     MOV AH,8
     INT 10H
     CALL BL_COLOR
     MOV AH,9
     INT 10H
     RET

BL_COLOR:                               ; FUNCTION : CHANGE THE COLOR BY THE CHARACTER
      PUSH CX
      MOV BL,1EH                        ; 00    ;  18H  ;  GREY
      SUB AL,00                         ; FF    ;  17H  ;  WHITE
      JZ MP1                            ; ELSE  ;  1EH  ;  YELLOW
      SUB AL,0FFH
      JZ MP2
      JMP MP3
  MP1:MOV BL,18H
      JMP MP3
  MP2:MOV BL,17H
  MP3:
      POP CX
      RET

INNER PROC
      PUSH CX
      MOV BH,PAGEN
      MOV DL,16
      MOV DH,5
      MOV AH,2
      INT 10H
      MOV CX,10H
   XH:CALL DU
      INC DH
      MOV DL,16
      INT 10H
      LOOP XH
      POP CX
      RET
INNER ENDP

   DU:     
      PUSH CX
      MOV CX,10H
DUXIE:PUSH CX
      PUSH DX
      MOV DX,DI
      IN AL,DX
      INC DI
      POP DX
      MOV CH,AL

      MOV BL,1EH
      SUB AL,00
      JZ P1
      SUB AL,0FFH
      JZ P2
      JMP P3
   P1:MOV BL,18H
      JMP P3
   P2:MOV BL,17H
   P3:MOV AL,CH
      MOV CL,4
      ROL AL,CL
      AND AL,0FH
      
      MOV AH,9
      PUSH CX
      MOV CX,1
      CMP AL,9
      JLE NM1
      ADD AL,07H
      INT 10H
  NM1:ADD AL,30H      
      INT 10H
      INC DL
      MOV AH,2
      INT 10H
      POP CX

      AND CH,0FH
      MOV AL,CH
      MOV AH,9
      MOV CX,1
      CMP AL,9
      JLE NM2
      ADD AL,07H
      INT 10H
  NM2:ADD AL,30H     
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
      POP CX
      LOOP DUXIE
      POP CX
      RET
      
TITLE_IOSpace:                       ; show the title 'IO Space  Start:      End:    '
      MOV AX,DATA
      MOV DS,AX
      MOV SI,OFFSET MESS
      MOV CX,MESS_LEN
      MOV DH,2
      MOV DL,13
      PUSH DS
      POP ES
      MOV BP,SI
      MOV BH,0
      MOV AL,0
      MOV BL,1BH
      MOV AH,13H
      INT 10H
      
      RET

ZUOBIAO:                           ; establish the xy coordinate system
      MOV BH,PAGEN
      MOV DL,16
      MOV DH,4                     ; 1. establish THE X coordinate system
      MOV AH,2                     
      INT 10H      

      MOV CX,10H                
      MOV AH,9
      MOV AL,0
      MOV SI,AX
      MOV BL,14H
   S1:PUSH CX
      MOV CX,1
      MOV AL,30H
      MOV AH,9
      INT 10H
      MOV AH,2
      INC DL
      INT 10H

      MOV AX,SI
      CMP AL,9
      JLE NUM
      ADD AL,07H
  NUM:ADD AL,30H
      INT 10H
      MOV AH,2
      INC DL
      INT 10H
      MOV AL,0
      MOV AH,9
      INT 10H
      MOV AH,2
      INC DL
      INT 10H
      INC SI
      POP CX
      LOOP S1
                                     
      MOV DL,13                       ; 2. 1. establish THE y coordinate system
      MOV DH,5
      INT 10H
      MOV AH,9
      MOV AL,0
      MOV SI,AX
      MOV CX,10H
   S2:PUSH CX
      MOV CX,1
      MOV AX,SI
      CMP AL,9
      JLE NUM2
      ADD AL,55
      INT 10H
      JMP J2
 NUM2:ADD AL,30H
      INT 10H
   J2:MOV AH,2
      INC DL
      INT 10H
      MOV AH,9
      MOV AL,30H
      INT 10H
      MOV DL,13
      INC DH
      MOV AH,2
      INT 10H
      INC SI
      POP CX
      LOOP S2
      RET



 CSEG ENDS
      END START
