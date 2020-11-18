#include<stdio.h>
#include<stdlib.h>
#define MAX1 100
#define MAX2 100
int main()
{
	char str1[MAX1];
	char control[MAX2];
	char* p = NULL;
	printf("请输入字符串1(子串)：");
	scanf_s("%s", str1, MAX1);
	printf("请输入字符串2(母串)：");
	scanf_s("%s", control, MAX2);
	_asm
	{  //准备参数
		lea edx, str1
		lea ecx, control
		call strbrk1
		mov p, eax
		jmp end1
	}
	_asm 
	{      //自己写的strbrk库函数
	strbrk1 :
		push edx
		push ecx
		push ebp
		mov ebp, esp         //建立堆栈框架
		call strlen1
		mov ecx, eax         //ecx = 串control长度
		jecxz OVER3           //control长度为0，则不需要查找

		xor eax, eax
		mov edx, ecx           //保存串2长度
		mov ebx, [ebp+8]       //取串1首地址
	for1 :
		mov esi, ebx           //ESI=开始搜索串1的起始地址
		mov edi, [ebp+4]       //EDI=串2首地址
		mov ecx, edx           //ECX=串2长度
		mov al, [esi]          //取出串1中一个元素
	for2 :
		cmp al, [edi]
		jz  OVER2               //说明找到
		inc edi                  //没找到就继续检索
		loop for2
		inc ebx                  //遍历完还不在，则从串1的下一个元素开始
		or al, al
		jnz for1

	OVER1 :    //未找到
		pop ebp
		pop ecx
		pop edx
		xor eax, eax
		ret

	OVER2 :     //找到
		pop ebp
		pop ecx
		pop edx
		mov eax, esi      //准备返回值
		ret

	OVER3:
		pop ebp
		pop ecx
		pop edx
		xor eax, eax             //eax=0,代表没找到
		ret
	}

	_asm
	{    //自己写的求字符串长度的库函数
	strlen1 :
		push esi           //保护esi
		xor esi, esi
		xor eax, eax
		or esi, ecx       //esi初值也为字符串首地址
	then :
		mov al, [esi]
		or al, al        //判断字符串是否结束
		je len1            //若结束，则跳转
		inc esi
		jmp then
	len1 :
		sub esi, ecx
		mov eax, esi      //准备返回值
		pop esi
		ret
	}
	_asm
	{
		end1 :
	}
	if (p)
	{
		printf("在母串中首次出现的字符地址偏移为：%p", p);
		printf("\n该字符为：%c", *p);
	}
	else
	{
		printf("串1中没有字符在串2中出现");
	}
	return 0;
}