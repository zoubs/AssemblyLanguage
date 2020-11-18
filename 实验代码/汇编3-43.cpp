#include <stdio.h>
int main()
{
	char a[100];
	printf("请输入一个字符串：");
	scanf_s("%s", a,100);
	char count[11];
	_asm
	{
		xor eax, eax
		lea ebx, a
	loop1:
		mov cl,BYTE PTR[ebx]
		cmp cl,0    //判断字符串是否结束
		je NEXT
		inc eax
		inc ebx
		jmp loop1
	NEXT:
		lea ebx, count
		mov esi, 10    //十进制基数
		mov ecx, 10    //循环次数
	NEXT1:
		xor edx,edx
		div esi         //eax含商，edx含余数
		add dl, '0'
		mov [ebx + ecx - 1], dl
		loop NEXT1
		
		mov BYTE PTR[ebx + 10],0
	}
	printf("该字符串的长度为：");
	for (int i = 0; i < 10; i++)
	{   //长度为10的字符串，先得到的位放最后一位，前面的位可能为0，输出时不输出前几位可能为0的位
		if (count[i] != '0')
		{
			int j = i;
			while (j < 10)
			{
				printf("%c", count[j]);
				j++;
			}
			break;
		}
	}
	return 0;
}