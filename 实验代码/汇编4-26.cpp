#include<stdio.h>

int main() {
	char a[100];
	printf("请输入要统计的字符串：");
	scanf_s("%s", a, 100);
	int n;

	_asm {
		lea edx, a      //取字符串的首地址
		xor eax, eax    //清零
		xor ebx, ebx     //BL存目前最长连续0数量,BH存目前连续0数目
	    mov ecx, 8      //每次操作一个字符，即8位

	then:
		mov al, BYTE PTR[edx]
		mov ecx, 8
		cmp al, 0
		je OVER       //结束

	for1 :
		shr eax, 1      //将最低位移到CF位，方便分析其值为0还是1
		jnb zero_count      //CF为0则跳转，统计计数
		xor bh, bh        //读到1则将当前清零

	for2 :
		dec ecx
		cmp ecx, 0
		je NEXT    //循环8次跳回上级循环
		jmp for1

	zero_count :
		inc bh
		cmp bl, bh
		jge for2
		mov bl, bh
		jmp for2
		
	NEXT:
		inc edx
		jmp then

	OVER :
		xor eax,eax
		mov al, bl
		mov n, eax

	}

	printf("连续0的最大长度为：%d", n);

	return 0;
}