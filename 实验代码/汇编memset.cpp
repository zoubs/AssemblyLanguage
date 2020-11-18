#include <stdio.h>
#include <stdlib.h>
#include <memory.h>
int main()
{
	char* dst;
	char a;
	int n,count;
	printf("请输入初始空间大小：");
	scanf_s("%d", &n);
	dst = (char*)malloc(n * sizeof(char));
	printf("请输入需要批量处理的空间大小：");
	scanf_s("%d", &count);
	printf("请输入要填充的值：");
	scanf_s("\n%c", &a, 1);
	_asm
	{
		xor eax, eax
		mov ecx, dst      //ecx存空间的首地址
		mov edx, count    //edx存放要修改的空间大小
		mov al, a         //要覆盖的值
		//单纯检验函数的话，好像不用压栈传参，寄存器够用
		call memset1
		jmp last
	}
	_asm
	{
	memset1:
		push ecx
		test edx, edx
		jz toend          //要修改长度为0，直接结束
	dword_alain:
		push edi          //保护edi
		mov edi, ecx      //edi=目标首地址
		cmp edx, 4    //长度小于4，直接进入收尾，剩余空间一个一个字节的填充
		jb tail
		neg ecx         //取反，方便计算目标地址在对齐之前的字节数
		and ecx, 3      //ecx为在字节对齐之前的字节数
		jz SHORT dwords  //已经4倍对齐，则跳转
		sub edx, ecx     //稍后需要批量处理的长度

	adjust_loop:
		mov [edi], al       //将4字节对齐前的空间先填充
		inc edi
		dec ecx         //书上用的add和sub指令，相对代码字节较长
		jnz adjust_loop
	dwords:        //至此，首地址已4字节对齐
		//此段的目的为让eax中含四字节的填充值
		//优化了书上的代码
		mov ecx, eax         //ecx = 0/0/0/value
		shl eax, 8       //eax = 0/0/value/0
		or eax, ecx      //eax = 0/0/value/value
		or ecx, eax      //ecx = 0/0/value/value
		shl eax, 10h     //eax = value/value/0/0
		or eax, ecx      //eax = value/value/value/value
		//比书上代码运算速度快
		//实现每次4字节的填充
		mov ecx, edx     //ecx = 长度
		and edx, 3       //edx = 4字节填充后的剩余
		shr ecx, 2       //长度除以4，为四字节填充的次数
		jz tail          //如为0，直接跳转到收尾处理
		rep stosd        //批量填充
	main_loop_tail:
		test edx, edx         //检验是否有剩余尾巴
		jz finish         //没有，填充完毕

	tail://扫尾工作
		mov [edi],al     //每次一字节
		inc edi
		dec edx
		jne tail
	finish:
		pop edi
		pop eax       //eax=空间首地址，准备返回值
			ret
	toend:
		pop eax
			ret
	}
	_asm
	{
		last:
	}
	if (dst)
	{
		printf("填充后的空间值为：");
		for (int i = 0; i < count; i++)
		{
			printf("%c ", dst[i]);
		}
	}
	return 0;
}