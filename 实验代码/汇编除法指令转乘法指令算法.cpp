#include <stdio.h>

typedef unsigned int uint32;
typedef unsigned long long uint64;

#define is2exp(x) (((x - 1) & x) == 0)//检测x是否为2的整数次幂

uint32 log2x(uint32 x)
{
	//└log2(x)┘ , x>0
	//求小于等于x以2为底的对数的最大整数
	int e;
	for (e = 31; e >= 0; e--) {
		if ((int)x < 0) return e;
		x <<= 1;
	}
	return -1;
}

int main()
{         //无符号数64位的被除数在本程序中并没有确定值，用（unit64）被除数      代替
	uint32 b, c, i;
	printf("请输入除数(大于1)：");
	scanf_s("%d", &b);//除数，b > 1
	for (i = 0; true; i++) 
	{
		c = b - ((uint64)1 << (32 + i)) % b;
		if (c == b) 
		{
			c = 0;//此时b为2的整数次幂
			break;
		}
		else if (is2exp(c))
		{
			if (log2x(c) <= i) break;
		}
		else 
		{
			if (log2x(c) < i) break;
		}
	}
	uint32 e, db;
	e = log2x(b);
	db = (((uint64)1 << (32 + i)) + c) / b;//当i = e+1时取结果的低32bit
	printf("当除数为 %d 时，转换关系如下:\n", b);
	if (i <= e)
	{
		printf("商 = ((uint64)被除数 * 0x%x) >> %d", db, 32 + i);
	}
	else 
	{
		//i = e + 1时就说明在 e <= └log2(b)┘内无法完全满足c*a < 2^(e+32)
		printf("t = ((uint64)被除数 * 0x%x) >> 32\n", db);
		printf("商 = ((((uint64)被除数 - t) >> 1) + t) >> %d", e);
	}
	return 0;
}

