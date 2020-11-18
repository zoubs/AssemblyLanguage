#include<stdio.h>
int main()
{
	char a[20];
	char Inverse[20];  //存放逆序后的字符串
	printf("请输入一个想要逆序输出的字符串：");
	scanf_s("%s", a, 20);
	_asm
	{
		xor eax, eax
		xor esi,esi
		xor ecx, ecx          //清零
		lea ebx, a          //取原字符串首地址
		lea edx, Inverse      //取逆置后字符串首地址
			loop1:            //压栈并记录
		mov al, BYTE PTR[ebx]
		cmp al, 0             //判断字符串是否结束
		je NEXT1
		push ax              //压栈
		inc ecx              //字符串长度+1
		inc ebx              //访问下一个元素
		jmp loop1
			NEXT1:
		pop bx
		mov BYTE PTR[edx+esi], bl
		inc esi
		loop NEXT1                            //将源字符串依次弹栈，实现逆置

		mov BYTE PTR[edx + esi], 0            //字符串尾加‘\0’
	}
	printf("逆序后的字符串为：%s", Inverse);
	return 0;
}