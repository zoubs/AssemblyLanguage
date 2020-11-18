; multi-segment executable file template.

macro printn      ;打印回车换行
    mov DL, 0DH 
    mov ah, 2
    int 21H
    mov DL, 0AH
    mov ah, 2
    int 21H
endm

macro printstr 1 ;打印字符串
    mov DX, 1
    mov ah, 9
    int 21H
endm

macro inputstr 1 ;输入字符串
    mov DX, 1
    mov AH, 0AH
    int 21H
endm
data segment
    a db 6,0,6 DUP(0)
    num1 dw 0
    b db 6,0,6 DUP(0)
    num2 dw 0
    gy dw 0
    gb dw 0,0 
    result db 6 DUP()
    pin db "please input a number bellow 65535:$" 
    pout db "the least common multiple is :$"
    ; add your data here!
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
    
    lea ax, pin
    printstr ax  ;打印提示信息
    lea ax, a
    inputstr ax   ;输入
    ;lea dx, a
    ;mov ah, 0AH
    ;int 21h 
    printn       ;打印回车换行
    
    lea ax, pin   
    printstr ax  ;打印提示信息
    lea ax, b
    inputstr ax  ;输入
    xor cx, cx
    
    lea si, a 
    inc si
    mov cl, [si]   ;数1长度 
    inc si         ;si指向最高位数
    
    xor dx, dx
    mov bx, 10
    xor ax, ax
lop1:
    mul bx
    mov dl, [si] 
    inc si
    sub dl, 30H
    add ax,dx
    loop lop1
    mov num1, ax
    ;此时num1为第一个数的值
    
    lea si, b 
    inc si
    mov cl, [si]   ;数2长度 
    inc si         ;si指向最高位数
    mov bx, 10
    xor ax, ax
lop2:
    mul bx
    mov dl, [si] 
    inc si
    sub dl, 30H
    add ax,dx
    loop lop2
    mov num2, ax 
    ;此时ax中为第二个数的值
    xor dx, dx
    mov ax, num1  ;ax为第一个数
    mov bx, num2
    ;先求最大公约数
    cmp ax, bx
    jae max
    mov cx, ax
    mov ax, bx
    mov bx, cx
    
max:           ;此时ax中为较大值
    div bx      ;a/b,余数在dx商在ax
    cmp dx, 0
    je over      ;说明bx值为最大公约数
    mov ax, bx    ;a = b
    mov bx, dx    ;b = 余数
    xor dx, dx    ;防止32位被除数被高位dx影响
    jmp max
    
over:
    mov gy, bx
    mov ax, num1  
    mov cx, num2 
    mul cx        ;乘积为DS:AX,可能为32位
    div bx        ;乘积除以最大公约数 = 最小公倍数，在AX中,
                  ;若最小公倍数过大（超过16位）会报错
    mov gb, ax
    mov bx, 10    ;10进制基数
    lea si, result
    add si, 5 
    mov [si],'$'   ;放结束标志
    
    mov cx, 5     ;最大为5位数，除以10五次即可

over1:
    div bx         ;结果在AX余数在DX
    or dl, 30H     ;得到对应ASCII码
    dec si
    mov [si], dl 
    xor dx, dx     ;防止32位被除数被高位dx影响
    loop over1
   
   
over2:
    mov al, [si]
    cmp al, 30H
    jne toprint
    inc si
    jmp over2
     
toprint: 
     printn        ;打印回车换行
     lea ax, pout
     printstr ax   ;打印提示信息
     printstr si   ;打印结果
     printn        ;打印回车换行
     
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
