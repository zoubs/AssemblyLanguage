#include <stdio.h>
int count(int num)
{
	int  r = 0, count = 0;
	while (num || r)    //商和余数均为0
	{
		r = num % 10;    //得到每一位的值
		if (r == 7)
		{
			count++;
		}
		num = num / 10;
	}
	printf("7在各位中出现的次数为：%d",count);
	return 0;
}
int main()
{
	int num;
	printf("请输入一个整数：");
	scanf_s("%d", &num);
	count(num);

	return 0;
}