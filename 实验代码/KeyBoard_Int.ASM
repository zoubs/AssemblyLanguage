    ;演示程序（键盘中断改颜色程序）
    ;演示软件中断处理程序（采用虚拟机可加载格式）
	PORT_KEY_DAT   EQU   0x60
    PORT_KEY_STA   EQU   0x64
        section   text
        bits   16
    Signature     db   "ZBOS"       ;签名信息
    Version       dw   1            ;格式版本
    Length        dw   end_of_text  ;工作程序长度
    Start         dw   Begin        ;工作程序入口点的偏移
    Zoneseg       dw   1A00H        ;工作程序入口点的段值（期望）
    Reserved      dd   0            ;保留

	 ;-----------------------------------
 int09h_handler:                     ;新的9号键盘中断处理程序
        PUSHA                           ;保护通用寄存器
        ;
        MOV   AL, 0ADH
        OUT   PORT_KEY_STA, AL          ;禁止键盘发送数据到接口
        ;
        IN    AL, PORT_KEY_DAT          ;从键盘接口读取按键扫描码
        ;
        STI                             ;开中断
        CALL  Int09hfun                 ;完成相关功能
        ;
        CLI                             ;关中断
        MOV   AL, 0AEH
        OUT   PORT_KEY_STA, AL          ;允许键盘发送数据到接口
        ;
        MOV   AL, 20H                   ;通知中断控制器8259A
        OUT   20H, AL                   ;当前中断处理已经结束
        ;
        POPA                            ;恢复通用寄存器
        ;
        IRET                            ;中断返回
    ;-----------------------------------
    Int09hfun:                          ;演示9H号中断处理程序的具体功能
        CMP   AL, 1CH                   ;判断回车键的扫描码
        JNZ   .LAB1                     ;非回车键，转
        MOV   AH, AL                    ;回车键，保存扫描码
        MOV   AL, 0DH                   ;回车键ASCII码
        JMP   SHORT .LAB2
    .LAB1:
        MOV   AH, AL                    ;保存扫描码
       
    .LAB2:
        CALL  Enqueue                   ;保存到键盘缓冲区
    .LAB3:
        RET                             ;返回
    ;-----------------------------------
    Enqueue:                            ;把扫描码和ASCII码存入键盘缓冲区
        PUSH  DS                        ;保护DS
        MOV   BX, 40H
        MOV   DS, BX                    ;DS=0040H
        MOV   BX, [001CH]               ;取队列的尾指针
        MOV   SI, BX                    ;SI=队列尾指针
        ADD   SI, 2                     ;SI=下一个可能位置
        CMP   SI, 003EH                 ;越出缓冲区界吗？
        JB    .LAB1                     ;没有，转
        MOV   SI, 001EH                 ;是的，循环到缓冲区头部
    .LAB1:
        CMP   SI, [001AH]               ;与队列头指针比较
        JZ    .LAB2                     ;相等表示，队列已经满
        MOV   [BX], AX                  ;把扫描码和ASCII码填入队列
        MOV    [001CH], SI              ;保存队列尾指针
    .LAB2:
        POP   DS                        ;恢复DS
        RET                             ;返回

;==============================================================
    newhandler:                     ;扩展显示I/O程序入口
        STI                         ;开中断//@2
        PUSHA                       ;保护通用寄存器//@3
        PUSH  DS                    ;保护涉及的段寄存器//@4
        PUSH  ES
        ;
        CALL  putchar               ;实现功能
        ;
        POP   ES                    ;恢复段寄存器
        POP   DS
        POPA                        ;恢复通用寄存器
        IRET                        ;中断返回
    ;-----------------------------------------
    putchar:
    ;功能：当前光标位置处显示带属性的字符，随后光标后移一个位置
    ;入口：AL=字符ASCII码；BL=属性
    ;说明：不支持退格符、响铃符等控制符
        PUSH  AX
        MOV   AX, 0B800H            ;设置显示存储区段值
        MOV   DS, AX
        MOV   ES, AX
        POP   AX
        ;        
        CALL  get_lcursor           ;取得光标逻辑位置
        ;
        CMP   AL, 0DH               ;回车符？
        JNZ   .LAB1
        MOV   DL, 0                 ;是，列号DL=0
        JMP   .LAB3
    .LAB1:
        CMP   AL, 0AH               ;换行符？
        JZ    .LAB2
        ;                           ;至此，普通字符
        MOV   AH, BL                ;AH=属性
        MOV   BX, 0                 ;计算光标位置对应存储单元偏移
        MOV   BL, DH
        IMUL  BX, 80
        ADD   BL, DL
        ADC   BH, 0
        SHL   BX, 1                 ;BX=(行号*80+列号)*2
        ;
        MOV   [BX], AX              ;写到显示存储区对应单元
        ;
        INC   DL                    ;增加列号
        CMP   DL, 80                ;超过最后一列？
        JB    .LAB3                 ;否
        MOV   DL, 0                 ;是，列号=0
    .LAB2:
        INC   DH                    ;增加行号
        CMP   DH, 25                ;超过最后一行？
        JB    .LAB3                 ;否
        DEC   DH                    ;是，行号减1（保持在最后一行）
        ;
        CLD                         ;实现屏幕向上滚一行
        MOV   SI, 80*2              ;第1行起始偏移
        MOV   ES, AX
        MOV   DI, 0                 ;第0行起始偏移
        MOV   CX, 80*24             ;复制24行内容
        REP   MOVSW                 ;实现屏幕向上滚一行
        ;
        MOV   CX, 80                ;清除屏幕最后一行
        MOV   DI, 80*24*2           ;最后一行起始偏移
        MOV   AX, 0x0720            ;黑底白字
        REP   STOSW                 ;形成空白行
    .LAB3:
        CALL  set_lcursor           ;设置逻辑光标
        CALL  set_pcursor           ;设置物理光标
        RET
    ;---------------------------------------------
    get_lcursor:                    ;取得逻辑光标位置（DH=行号，DL=列号）
        PUSH  DS
        PUSH  0040H                 ;BIOS数据区的段值是0040H
        POP   DS                    ;DS=0040H
        MOV   DL, [0050H]           ;取得列号
        MOV   DH, [0051H]           ;取得行号
        POP   DS
        RET
    ;---------------------------------------------
    set_lcursor:                    ;设置逻辑光标（DH=行号，DL=列号）
        PUSH  DS
        PUSH  0040H                 ;BIOS数据区的段值是0040H
        POP   DS                    ;DS=0040H
        MOV   [0050H], DL           ;设置列号
        MOV   [0051H], DH           ;设置行号
        POP   DS
        RET
    ;---------------------------------------------
    set_pcursor:                    ;设置物理光标（DH=行号，DL=列号）
        MOV   AL, 80                ;计算光标寄存器值
        MUL   DH                    ;AX=(行号*80+列号)
        ADD   AL, DL
        ADC   AH, 0
        MOV   CX, AX                ;保存到CX
        ;
        MOV   DX, 3D4H              ;索引端口地址
        MOV   AL, 14                ;14号是光标寄存器高位
        OUT   DX, AL
        MOV   DX, 3D5H              ;数据端口地址
        MOV   AL, CH
        OUT   DX, AL                ;设置光标寄存器高8位
        ;
        MOV   DX, 3D4H              ;索引端口地址
        MOV   AL, 15
        OUT   DX, AL
        MOV   DX, 3D5H              ;数据端口地址
        MOV   AL, CL
        OUT   DX, AL                ;设置光标寄存器低8位
        RET
    ;========================================================

    Begin:
        MOV   AL, 0
        MOV   AH, 5
        INT   10H                       ;指定第0显示页
        ;
        XOR   AX, AX                    ;准备设置中断向量
        MOV   DS, AX
        CLI
        MOV   WORD [90H*4], newhandler  ;设置90H中断向量之偏移
        MOV   [90H*4+2], CS             ;设置90H中断向量之段值
		
		MOV   WORD [9*4], int09h_handler
        MOV   [9*4+2], CS               ;启用新的键盘中断处理程序
        STI
        ;
        PUSH  CS
        POP   DS
	NEXT:
		MOV   AH, 0                     ;调用键盘I/O程序
        INT   16H                       ;获取用户按键
        ;
		MOV   BL, AH                    ;保存扫描码

		;MOV   AH, 14                    ;显示取得的字符（按键）
        ;INT   10H
        ;
        CMP   BL, 1CH                    ;回车键吗？
        JZ    .LAB2                      ;是则结束
		CMP   BL, 13H                     ;r
		JZ    .COLOR_RED
		CMP   BL, 22H                     ;g
		JZ    .COLOR_GREEN
		CMP   BL, 30H                     ;b
		JZ    .COLOR_BLUE
		JMP   NEXT
	
	.COLOR_RED:
		MOV   CX, 6
	.RED:
		MOV   AL, ' '
		MOV   AH, 14
		INT   10H
		LOOP  .RED
		MOV   AL, 'R'
		MOV   AH, 14
		INT   10H                          ;显示R
		MOV   AL, 0DH
		INT   10H
		MOV   AL, 0AH
		INT   10H                          ;显示回车换行

		MOV   BL, 04H
		JMP   .COLOR_END
	
	.COLOR_GREEN:
		MOV   CX, 6
	.GREEN:
		MOV   AL, ' '
		MOV   AH, 14
		INT   10H
		LOOP  .GREEN

		MOV   AL, 'G'
		MOV   AH, 14
		INT   10H                          ;显示G
		MOV   AL, 0DH
		INT   10H
		MOV   AL, 0AH
		INT   10H                          ;显示回车换行

		MOV   BL, 02H
		JMP   .COLOR_END
	
	.COLOR_BLUE:
		MOV   CX, 6
	.BLUE:
		MOV   AL, ' '
		MOV   AH, 14
		INT   10H
		LOOP  .BLUE

		MOV   AL, 'B'
		MOV   AH, 14
		INT   10H                          ;显示B
		MOV   AL, 0DH
		INT   10H
		MOV   AL, 0AH
		INT   10H                          ;显示回车换行

		MOV   BL, 01H
		JMP   .COLOR_END
	
	.COLOR_END:
        CLD
        MOV   SI, mess                  ;提示信息
	    ;MOV   BL, 02H                   ;绿色
    .LAB1:
        LODSB
        OR    AL, AL                    ;显示信息以0结尾
        JZ    NEXT
        INT   90H                       ;调用扩展的显示I/O功能
        ;                                显示带属性的字符
        JMP   .LAB1
    .LAB2:
        RETF
    ;
    mess  db   "                      Welcom To Exploring Assembler World !",0dh, 0ah,"                          Believe Me,You Will Enjoy It!", 0dh, 0ah, 0
    end_of_text:                    ;结束位置
