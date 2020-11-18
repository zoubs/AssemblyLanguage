#include<stdio.h>
int Sign()
{
	char buff[10];
	int sum, i;
	char ch;
	printf("请输入10位十进制数字符串：");
	for (i = 0; i < 10; i++)
	{
		scanf_s("%c", &buff[i], 1);
	}
	_asm
	{
		xor eax, eax
		xor ecx, ecx
		xor edx, edx    //存放结果和
		lea ebx, buff
		then :
		mov al, BYTE PTR[ebx]
			add ecx, eax
			inc ebx
			inc edx
			cmp edx, 10
			jl then
			sub ecx, 480   //共10个数据，减去0的ASCII码  48*10 = 480
			mov sum, ecx
	}
	
	printf("有符号计算的和为：%d", sum);
	return 0;
}
int unsign()
{
	char buff[10];
	int  i;
	unsigned sum;
	char ch;
	printf("请输入10位十进制数字符串：");
	for (i = 0; i < 10; i++)
	{
		scanf_s("%c", &buff[i], 1);
	}
	_asm
	{
		xor eax, eax
		xor ecx, ecx
		xor edx, edx    //存放结果和
		lea ebx, buff
		then :
		mov al, BYTE PTR[ebx]
			add ecx, eax
			inc ebx
			inc edx
			cmp edx, 10
			jl then
			sub ecx, 480   //共10个数据，减去0的ASCII码  48*10 = 480
			mov sum, ecx
	}
	printf("无符号计算的和为和为：%u", sum);
	return 0;
}
int main()
{
	char ch;
	printf("进行有符号还是无符号比较（y代表有符号，n代表无符号）：");
	ch = getchar();
	if (ch == 'y')
	{//有符号数计算求和
		ch = getchar();   //读走缓冲区的换行符
		Sign();
	}
	else if (ch == 'n')
	{//无符号数计算求和
		ch = getchar();   //读走缓冲区的换行符
		unsign();
	}

	return 0;
}
