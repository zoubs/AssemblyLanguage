//用户输入一个字符串，显示输出其长度
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#define max 100
int main()
{
	int len;
	char p[max];
	printf("请输入一个字符串：");
	scanf_s("%s", p,max);
	_asm 
	{
		xor ecx, ecx  //清零，用来计数
		lea ebx, p
		then :
		mov al, BYTE PTR[ebx]
		cmp al, 0
		je case1
		inc ecx    //计数
		inc ebx    //访问下一个字符地址
		jmp then
			case1 :
		mov len, ecx
	}
	printf("字符串长度为：%d", len);
	len = strlen(p);

	return 0;
}