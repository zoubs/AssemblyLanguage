#include <stdio.h>
#include <string.h>
#define MAX 100
int count(int type, int& m, int &n)
{
	if (type == 0)
	{
		m++;
	}
	else if (type == 1)
	{
		n++;
	}
	return 0;
}
int number(char ch)     //a为当前字符,判断是否为数字
{
	if (ch >= '0' && ch <= '9')
	{
		return 1;
	}
	else
		return 0;
}
int alph(char ch)       //a为当前字符,判断是否为字母
{
	if (((ch >= 'A') && (ch <= 'Z')) || ((ch >= 'a') && (ch <= 'z')))
	{
		return 1;
	}
	else
		return 0;
}
int main()
{
	char ch[MAX];
	int length,i,type,m = 0, n = 0;    //type代表类型，m代表数字个数，n代表字母个数
	printf("请输入一个字符串：");
	scanf_s("%s", ch, MAX);
	length = strlen(ch);
	for (i = 0; i < length; i++)
	{
		type = 2;
		if (number(ch[i]))
		{
			type = 0;     //说明是数字
		}
		else if (alph(ch[i]))
		{
			type = 1;    //说明是字母
		}
		count(type,m,n);
	}
	printf("数字个数为：%d\n字母个数为：%d", m, n);
	return 0;
}