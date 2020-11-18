    ;演示程序（工作程序）dp87.asm
    ;演示定时中断处理程序（采用虚拟机可加载格式）
    ;运行后，将显示当前时钟，用户按#键结束程序
        section   text
        bits   16
    Signature     db   "ZBOS"       ;签名信息
    Version       dw   1            ;格式版本
    Length        dw   end_of_text  ;工作程序长度
    Start         dw   Begin        ;工作程序入口点的偏移
    Zoneseg       dw   2800H        ;工作程序入口点的段值（期望）
    Reserved      dd   0            ;保留
    ;-------------------------------
    ;新的1CH号中断处理程序
    Entry_1CH:
        DEC   BYTE  [CS:count]      ;计数器减1
        JZ    ETIME                 ;当计数为0，显示时间
        IRET                        ;否则，中断返回
        ;
    ETIME:                          
        MOV   BYTE [CS:count], 18   ;重新设置计数初值
        ;
        STI                         ;开中断
        PUSHA                       ;保护现场
        CALL  get_time              ;获取当前时间
        CALL  EchoTime              ;显示当前时间
        POPA                        ;恢复现场
        IRET                        ;中断返回
    ;------------------------------
    get_time:                       ;简化方式获取实时时钟（时分秒）
        MOV   AL, 4                 ;准备读取时值
        OUT   70H, AL
        IN    AL, 71H               ;获取时值
        MOV   CH, AL                ;CH=时值BCD码
        MOV   AL, 2                 ;准备读取分值
        OUT   70H, AL
        IN    AL, 71H               ;获取分值
        MOV   CL, AL                ;CL=分值BCD码
        MOV   AL, 0                 ;准备读取秒值
        OUT   70H, AL
        IN    AL, 71H               ;获取秒值
        MOV   DH, AL                ;DH=秒值BCD码
        RET
    ;------------------------------
    %define   ROW     10            ;时间显示位置行号
    %define   COLUMN  36            ;时间显示位置列号
    EchoTime:                       ;显示当前时间（时分秒）
        PUSH  SI
        ;-----                      ;设置显示时间的位置
        PUSH  DX                    ;保存入口参数
        PUSH  CX
        MOV   BH, 0
        MOV   AH, 3                 ;取得当前光标位置
        INT   10H
        MOV   SI, DX                ;保存当前光标位置
        MOV   DX, (ROW<<8) + COLUMN
        MOV   AH, 2
        INT   10H                   ;设置光标位置
        POP   CX
        POP   DX
        ;-----                      ;显示当前时间（时:分:秒）
        MOV   AL, CH
        CALL  EchoBCD               ;显示时值
        MOV   AL, ':'
        CALL  PutChar
        MOV   AL, CL
        CALL  EchoBCD               ;显示分值
        MOV   AL, ':'
        CALL  PutChar
        MOV   AL, DH
        CALL  EchoBCD               ;显示秒值
        ;-----                      ;恢复光标原先位置
        MOV   DX, SI
        MOV   AH, 2
        INT   10H
        POP   SI
        RET
    ;------------------------------ 
    EchoBCD:                        ;显示2位BCD码值
        PUSH  AX
        SHR   AL, 4
        ADD   AL, '0'
        CALL  PutChar
        POP   AX
        AND   AL, 0FH
        ADD   AL, '0'
        CALL  PutChar
        RET
    ;------------------------------
    PutChar:                        ;TTY方式显示一个字符
        MOV   BH, 0
        MOV   AH, 14
        INT   10H
        RET
    ;-------------------------------
    count    DB   1                 ;计数器
    old1ch   DD   0                 ;用于保存原1CH号中断向量
    ;------------------------------
    Begin:                          ;启动点
        MOV   AX, CS
        MOV   DS, AX                ;DS = CS
        MOV   SI, 1CH*4             ;1CH号中断向量所在地址
        MOV   AX, 0
        MOV   ES, AX                ;ES = 0
        ;保存1CH号中断向量
        MOV   AX, [ES:SI]
        MOV   [old1ch], AX          ;保存向量之偏移
        MOV   AX, [ES:SI+2]
        MOV   [old1ch+2], AX        ;保存向量之段值
        ;设置新的1CH号中断向量
        CLI                         ;关中断
        MOV   AX, Entry_1CH
        MOV   [ES:SI], AX           ;设置新向量之偏移
        MOV   AX, CS
        MOV   [ES:SI+2], AX         ;设置新向量之段值
        STI                         ;开中断
        ;---------------------------
        ;等待并接受用户按键，直到用户按'#'键，结束
    Continue:
        MOV   AH, 0
        INT   16H                   ;等待并接受用户按键
        ;
        CMP   AL, 20H
        JB    Continue
        CALL  PutChar
        ;
        CMP   AL, '#'
        JNZ   Continue              ;只要不是'#'，继续等待并接受按键
        ;---------------------------
        ;恢复原1CH号中断向量
        MOV   EAX, [CS:old1ch]      ;获取保存的原1CH号中断向量
        MOV   [ES:SI], EAX          ;恢复原1CH号中断向量
        ;
        RETF                        ;结束程序，返回加载器
    end_of_text:                    ;源程序结束位置
