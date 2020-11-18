#include <stdio.h>
#define MAX 100
int main()
{
	char a[MAX];
	int len;
	printf("请输入一个字符串：");
	scanf_s("%s", a, MAX);
	_asm
	{
		lea ecx, a    //ECX 中存放字符串首地址
		call strlen1
		mov len, eax
		jmp end1
	}
	_asm
	{
	strlen1:
		push esi          //保护esi
		xor esi, esi
		or esi, ecx       //esi初值也为字符串首地址
	for1:
		mov al, [esi]
		or al, al        //判断字符串是否结束
		je len1            //若结束，则跳转
		inc esi
		jmp for1
	len1:
		sub esi,ecx
		mov eax, esi       //准备返回值
		pop esi
		ret
	
	}
	_asm
	{
		end1:
	}
	printf("字符串长度为：%d", len);
	return 0;
}