#include <stdio.h>
int main()
{
	unsigned a;
	int count;
	printf("请输入一个整数：");
	scanf_s("%u", &a);
	_asm
	{
			xor edx,edx  //计位值为0的位数
			mov eax,a
			mov ecx,32   //循环计数
		NEXT:
			shr eax,1    //右移一位，最低位进入CF
			cmc          //将CF位取反，0->1，从而利用adc指令统计位位0的个数
			adc dl, 0    //加CF位,统计为0位的个数
			loop NEXT
			mov count,edx
	}
	printf("%d ", count);
	return 0;
}