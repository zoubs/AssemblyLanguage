#include<stdio.h>
//对输入的两个数进行比较
int sign()
{
	int a, b, max;
	printf("请输入两个整数：");
	scanf_s("%d %d", &a, &b);
	max = a;
	_asm {
		mov eax, a
		mov ebx, b
		cmp eax, ebx
		jle SHORT choose1
		mov max, eax
		jmp choose2          //无条件跳转，结束分支防止顺序执行修改正确的值
		choose1 :
		mov max, ebx
		choose2 :
	}
	printf("进行有符号比较的最大值为：%d", max);
	return 0;
}
int unsign()
{
	unsigned a, b ;
	int max;
	printf("请输入两个整数：");
	scanf_s("%u %u", &a, &b);
	_asm {
		mov eax, a
		mov ebx, b
		cmp eax, ebx
		jbe SHORT choose1
		mov max, eax
		jmp choose2          //无条件跳转，结束分支防止顺序执行修改正确的值
			choose1 :
		mov max, ebx
			choose2:
	}
	printf("无符号比较的最大值为：%d", max);
	return 0;
}
int main()
{
	char ch;
	printf("进行有符号还是无符号比较（y代表有符号，n代表无符号）：");
	ch = getchar();
	if(ch == 'y')
	{//有符号数比较
		sign();  
	}
	else if (ch == 'n')
	{//无符号数比较
		unsign();
	}
	return 0;
}