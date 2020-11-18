
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
segment code
    org 100h
    alph db "ABCDEFGHIJKLMNOPQRSTUVWXYZ",0DH,0AH,'$'
    
    mov cx, 9
again:
    mov dx, offset alph
    mov ah,9
    int 21h
    loop again
    ; add your code here 
    
    mov ah, 4CH
    int 21H
ret   
