#include<iostream>
using namespace std;
#define max 100
int main()
{
	char a[max];
	int num1, num2;
	int flag;    //判断除数为是否为0
	char b[11];
	char s[11], ys[11];
	printf("请输入被除数:");
	cin >> a;
	printf("请输入除数:");
	cin >> b;
	
	_asm
	{
		lea esi, a
		call LAB1
		mov edx, eax     //返回被除数
		lea esi, b
		call LAB1       //返回除数
		mov ecx,eax     //除数放在ecx中
		mov eax,edx    //被除数放在eax中
		xor edx, edx
		jecxz end1      //除数为0,跳转结束
		div ecx          //商在eax,余数在edx
		mov num1, eax    //num1商的数值
		mov num2, edx    //num2余数的数值
		lea ebx, s
		call for1

		mov eax, edx
		lea ebx, ys
		call for1

		jmp end2        //跳过下面的子程序
	}
	_asm
	{  //将商和余数转换为10进制字符串的子程序
	for1:
		push edx
		push ecx
		push ebp
		//lea ebx, count
		mov esi, 10    //十进制基数
		mov ecx, 10    //循环次数
	for2 :
		xor edx, edx
		div esi         //eax含商，edx含余数
		add dl, '0'
		mov[ebx + ecx - 1], dl
		loop for2

		mov BYTE PTR[ebx + 10], 0       //字符串末尾加‘\0’
		
		pop ebp
		pop ecx
		pop edx
		ret
	}
	_asm
	{     //将字符串转换为数值的子程序
	LAB1:
		push ecx
		push esi
		push edx
		push ebp
		xor ecx, ecx        //ECX存储字符串长度

	loop1 :
		mov al, BYTE PTR[esi + ecx]
		cmp al, 0
		je next1
		inc ecx
		jmp loop1
	next1 :
		xor ebx, ebx         //ebx作为初值Y
		xor eax, eax
		jecxz next3
	next2 :
		imul ebx, 10         //Y*10
		mov al, [esi]        //al此时内容为对应的ASCII码
		inc esi
		and al, 0fH          //效果等于 -30H
		add ebx, eax          //Y = Y*10 + d
		loop next2
	next3 :
		mov eax, ebx         //准备返回值
		pop ebp
		pop ebx              //恢复寄存器值
		pop esi
		pop ecx
		ret
	}
	_asm
	{
	end1:
		mov flag,ecx
	end2:
	}
	if (flag == 0)
	{
		cout << "除数不能为0，错误" << endl;
	}
	else
	{
		cout << "转换为10进制数值的商为："<<num1 << endl << "转换为10进制数值的余数为：" << num2 << endl;
		cout << "十进制字符串形式" << endl << "商为：";
		for (int i = 0; i < 10; i++)
		{   //调整输出格式，去掉前面多余的0
			if (s[i] != '0')
			{
				int j = i;
				while (j < 10)
				{
					cout<<s[j];
					j++;
				}
				break;
			}
		}
		cout << endl << "余数为：";
		for (int i = 0; i < 10; i++)
		{   //调整输出格式，去掉前面多余的0
			if (ys[i] != '0')
			{
				int j = i;
				while (j < 10)
				{
					cout << ys[j];
					j++;
				}
				break;
			}
		}
	}
	
	return 0;
}