#include <iostream>
using namespace std;
#define max 20
#define MAX 2*max
int main()
{
	char a[max];
	char b[max];
	char buffer[MAX];
	cout<<"请输入字符串1：";
	cin >> a;
	cout<<"请输入字符串2：";
	cin >> b;
	_asm
	{
		xor eax,eax
		lea esi, a
		lea edi, buffer
	for1:
		mov al, BYTE PTR[esi]
		cmp al, 0
		je for2                 //a中元素已全部转移
		mov BYTE PTR[edi], al         //先将a中元素移到buffer中
		inc edi                //下一个写入地址
		inc esi                //下一个转移元素的地址
		jmp for1

	for2:
		lea esi, b
	for3:
		mov al, BYTE PTR[esi]
		mov BYTE PTR[edi], al        //转移b串中的元素，最后一个'0'也转移
		cmp al,0
		je for4
		inc esi
		inc edi
		jmp for3

	for4:

	}
	cout <<"经连接后的字符串为："<< buffer << endl;
	return 0;
}