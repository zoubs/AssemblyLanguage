#include<iostream>
using namespace std;
#define max 100
int main()
{
	int num;
	char a[max];
	char b[9];
	printf("请输入一个十进制数组成的字符串（不能含有其他字符）：");
	cin >> a;
	_asm
	{
		call LAB1

		lea edx, b;
		xor esi, esi
		mov edi, eax      //要转换的十进制数值
		inc esi           //循环8次，一次4位，共32位
		for1:
		mov ecx, 8
		sub ecx, esi       //8-i
		shl ecx, 2         //32 - i*4
		mov eax, edi
		shr eax, cl        // >>(32 - i*4)
		and al, 0fH        // 截取低4位
		or al, 30H         //相当于加30H
		cmp al, 39H
		jle for2
		add al, 7
			for2:
		mov BYTE PTR[edx], al
		inc edx

		inc esi               //用来计数
		cmp esi, 8             // <=8跳转
		jle for1
		mov BYTE PTR[edx], 0

		jmp LAB2            //跳过后面的子程序部分
	}
	_asm      //转换对应数值子程序
	{
	LAB1:
		push ecx
		push edx
		push esi
		lea esi, a
		xor ecx, ecx        //ECX存储字符串长度
		
	loop1:
		mov al, BYTE PTR [esi + ecx]
		cmp al,0
		je next1
		inc ecx
		jmp loop1
	next1:
		xor edx, edx         //EDX作为初值Y
		xor eax, eax
		jecxz next3
	next2:
		imul edx, 10         //Y*10
		mov al, [esi]        //al此时内容为对应的ASCII码
		inc esi
		and al, 0fH          //效果等于 -30H
		add edx, eax          //Y = Y*10 + d
		loop next2
	next3:
		mov num, edx
		mov eax, edx         //准备返回值
		pop esi
		pop edx
		pop ecx
		ret
	}
	_asm
	{
		LAB2:
	}
	cout <<"十进制数值为：" <<num << endl << "十六进制字符串形式为：" << b;
	return 0;
}