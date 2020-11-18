#include<iostream>
using namespace std;
#define max 100
int main()
{
	char cha;
	char str1[max];
	int n;
	cout << "请输入一个字符：";
	cin >> cha;
	cout << "请输入长度：";
	cin >> n;
	_asm
	{
		xor eax, eax
		mov ecx, n   //计数n次
		mov al, cha   //取字符
		lea esi, str1
		call cat
		jmp end1
	}
	_asm
	{
		cat :
		for1:
		mov BYTE PTR[esi], al
		inc esi
		loop for1
		mov BYTE PTR[esi],0
		ret
	}
	_asm
	{
		end1 :
	}
	
	cout <<"生成的字符串为："<< str1 << endl;
	return 0;
}