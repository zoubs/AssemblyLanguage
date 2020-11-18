; multi-segment executable file template.
macro printn  
    mov DL,0DH
    mov AH, 2
    int 21H
    mov DL,0AH
    mov AH, 2
    int 21H 
endm       ;打印回车换行

data segment
    result db "00000$"; 
    pout db "the sum is :$"
    pkey db "press any key...$"
ends

stack segment
    dw   128  dup(0)
ends

code segment
start:
; set segment registers:
    mov ax, 0F000H     ;将数据改到要求的区域
    mov ds, ax
    mov es, ax
     
    xor ax, ax
    xor bx, bx 
    xor si, si
    mov cx, 100 
    
lop1:           ;在要求的数据区存100个数据
    mov [si], 2  ;我实验时存的100个2
    inc si
    loop lop1
     
    mov cx, 100
    dec si 
    
again:
    mov al, [si]
    dec si
    add bx, ax
    loop again
      ;此时bx中存放和
    mov ax, data
    mov ds, ax
    mov es, ax
    
    mov cx, 5
    lea di, result
    add di, 4  
    mov ax, bx

lop2:
    mov bl, 10   ;10进制基数
    div bl    ;余数在ah中
    or  ah, 30h
    mov [di], ah 
    dec di
    xor ah, ah
    loop lop2
    
    mov cx, 4
    lea si, result
notzero: ;过滤前面的0
    
    mov ah, [si]
    cmp ah,'0'
    jne printstr 
    inc si
    loop notzero
     
printstr:    
    lea dx, pout
    mov ah, 9
    int 21h      ;打印提示信息
    mov dx, si
    mov ah, 9
    int 21h
    
    printn    ;打印回车换行       
   lea dx, pkey
   mov ah, 9
   int 21h        ; output string at ds:dx
    
    ; wait for any key....    
   ; mov ah, 1
   ; int 21h
over:  
   mov ax, 4C00h ; exit to operating system.
   int 21h    
ends

end start ; set entry point and stop the assembler.
