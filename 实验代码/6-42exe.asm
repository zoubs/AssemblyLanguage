; multi-segment executable file template.

data segment
    
    alph db "ABCDEFGHIJKLMNOPQRSTUVWXYZ"£¬0DH,0AH,'$'; add your data here!
    pkey db "press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, data
    mov ds, ax
    mov es, ax 
    
    mov cx, 9   ;Ñ­»·´ÎÊý
aggin:
    
    mov dx, offset alph
    mov ah, 9
    int 21h
    loop aggin
             
             
    lea dx, pkey
    mov ah, 9
    int 21h        ; output string at ds:dx
    
    ; wait for any key....    
    mov ah, 1
    int 21h
    
    mov ax, 4c00h ; exit to operating system.
    int 21h    
ends

end start ; set entry point and stop the assembler.
