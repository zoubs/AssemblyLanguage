    ;演示程序（工作程序）dp85.asm
    ;演示除法出错中断处理程序（采用虚拟机可加载格式）
        section   text
        bits   16
    ;可加载工作程序头部特征信息
    Signature     db   "ZBOS"       ;签名信息
    Version       dw   1            ;格式版本
    Length        dw   end_of_text  ;工作程序长度
    Start         dw   Begin        ;工作程序入口点的偏移
    Zoneseg       dw   1800H        ;工作程序入口点的段值（期望）
    Reserved      dd   0            ;保留
    ;-------------------------------
    Begin:                              ;演示程序的初始化
        MOV   AX, 0                     ;准备设置中断向量
        MOV   DS, AX
        CLI                             ;关中断
        MOV   WORD [0*4], int00h_handler;设置0号中断向量之偏移
        MOV   [0*4+2], CS               ;设置0号中断向量之段值
        STI                             ;开中断
        ;
        MOV   BH, 0
        MOV   AH, 14
        MOV   AL, '#'
        INT   10H                       ;为了示意，显示井号
        ;
        MOV   AX, 600                   ;演示除出错
        MOV   BL, 2
        DIV   BL                        ;除法操作溢出！//@1
    LABV:
        ;
        MOV   AH, 14
        MOV   AL, 0DH                   ;形成回车
        INT   10H
        MOV   AL, 0AH                   ;形成换行
        INT   10H
        ;
        RETF                            ;结束（返回到加载器）
    ;-----------------------------------
    ;00H号中断处理程序（除出错中断处理程序）
    int00h_handler:                      
        STI                             ;开中断//@2
        PUSHA                           ;保护通用寄存器//@3
        PUSH  DS                        ;保护DS//@4
        MOV   BP, SP
        ;
        PUSH  CS
        POP   DS                        ;使DS=CS
        MOV   DX, mess                  ;指向提示信息
        CALL  PutStr                    ;显示提示信息
        ;
        ADD   WORD [BP+18], 2           ;调整返回地址! //@5
        ;
        POP   DS                        ;恢复DS
        POPA                            ;恢复通用寄存器
        ;
        IRET                            ;中断返回
        ;
    mess   db   "Divide overflow", 0    ;提示信息
    ;
    PutStr:                             ;显示字符串（以0结尾）
        MOV   BH, 0
        MOV   SI, DX                    ;DX=字符串起始地址偏移
    .LAB1:
        LODSB
        OR    AL, AL
        JZ    .LAB2
        MOV   AH, 14
        INT   10H
        JMP   .LAB1
    .LAB2:
        RET
    end_of_text:                        ;结束位置
