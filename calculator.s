yuval203455345_moshe203737804/main.c000644 001750 001750 00000032264 13263416026 016716 0ustar00yuvalyuval000000 000000 #include <stdio.h>
#include <stdlib.h>
#include <memory.h>


typedef struct bignum {
    unsigned long number_of_digits;
    char *digit;
    int is_neg;
} bignum;

extern int _add(bignum** stack);
extern int _sub(bignum ** stack);
extern int _mul(bignum ** stack);
extern int _mul2(bignum ** stack);
extern int _div2(bignum ** stack);
void remove_zeros(struct bignum *pBignum);

int check_if_neg();

int cps_populate_bignums_in_order(bignum **pBignum1, bignum **pBignum2);


void remove_zeros(struct bignum *pBignum) {
    long num_of_digits = pBignum->number_of_digits;
    for(long i=1;i<num_of_digits;i++){
        if(pBignum->digit[num_of_digits-i]=='0'){
            pBignum->number_of_digits--;
        }
        else
            break;
    }
    char* new_ptr = malloc(pBignum->number_of_digits);
    memset(new_ptr, '\0', pBignum->number_of_digits);
    strncpy(new_ptr,pBignum->digit,pBignum->number_of_digits);
    free(pBignum->digit);
    pBignum->digit = new_ptr;

}


int MAXSIZE = 1024;
bignum* stack[1024];
int top = -1;

int isempty() {

    if(top == -1)
        return 1;
    else
        return 0;
}

int isfull() {

    if(top == 1024)
        return 1;
    else
        return 0;
}

bignum* pop() {
    bignum* data;

    if(!isempty()) {
        data = stack[top];
        top = top - 1;
        return data;
    }

    return NULL;
}

int push(bignum* data) {

    if(!isfull()) {
        top = top + 1;
        stack[top] = data;
        }
    else {
        printf("Stack is full.\n");
    }
    return 0;
}


void substract() {

    bignum** arg1 = malloc(sizeof(bignum*));
    bignum** arg2 = malloc(sizeof(bignum*));
    int is_replaced = cps_populate_bignums_in_order(arg1,arg2); //arg1 will be the bigger arg
    pop();
    pop();
    push(*arg1);
    push(*arg2);
    _sub(stack+top-1);
    free(stack[top]->digit);
    free(stack[top]);
    stack[top]=NULL;
    top--;
    remove_zeros(stack[top]);
    free(arg1);
    free(arg2);
    if (is_replaced){
        stack[top]->is_neg=1;

    }
}

void construct_number(int neg_checker, unsigned int digs_counter, char *acc_digits) {
    bignum* cur_num = (bignum*) malloc(sizeof(bignum));
    cur_num->digit = (char *) malloc(digs_counter);
    cur_num->is_neg = neg_checker;
    for(int i=0; i<digs_counter;i++){
        cur_num->digit[i] = acc_digits[digs_counter-1-i];
    }
    cur_num->number_of_digits  = digs_counter;
    push(cur_num);
}

void eraseStack(){
 while(1){
            bignum *to_delete = pop();
            if(to_delete){
                free(to_delete->digit);
                free(to_delete);
                stack[top+1]=NULL;
            }
            else{
                break;
            }
        }
}


int main() {
    char nextChar;
    char *acc_digits = (char *) malloc(1024);
    unsigned int digs_counter= 0;
    int neg_checker = 0;
    while((nextChar = (char) fgetc(stdin)) != 'q'){
        if (digs_counter && (nextChar == ' ' || nextChar =='\n')){
            construct_number(neg_checker, digs_counter, acc_digits);
            digs_counter=0;
            neg_checker=0;
        }
        else if(nextChar == '_'){
            neg_checker =1;
        }
        else if (nextChar<='9' && nextChar >= '0'){
            acc_digits[digs_counter] = nextChar;
            digs_counter++;
        }
        else if (nextChar<='9' && nextChar >= '0'){
            acc_digits[digs_counter] = nextChar;
            digs_counter++;
        }
        else{

            if (nextChar == '-'){
                if(digs_counter){
                    construct_number(neg_checker, digs_counter, acc_digits);
                    digs_counter=0;
                    neg_checker=0;

                }
                int if_one_neg=check_if_neg();
                bignum** arg1 = malloc(sizeof(bignum*));
                bignum** arg2 = malloc(sizeof(bignum*));
                int is_replaced= cps_populate_bignums_in_order(arg1,arg2); //arg1 will be the bigger arg
                int arg1_neg = stack[top-1]->is_neg;
                pop();
                pop();
                push(*arg1);
                push(*arg2);
                if(if_one_neg){

                    _add(stack+top-1);
                    free(stack[top]->digit);
                    free(stack[top]);
                    top--;
                    stack[top]->is_neg = arg1_neg;
                }
                else{
                    substract();
                    if(!is_replaced){
                        stack[top]->is_neg = arg1_neg;
                    }
                    else{
                        if(arg1_neg)
                            stack[top]->is_neg = 0;
                        else
                            stack[top]->is_neg = 1;

                    }

                }
                digs_counter= 0;
                free(arg1);
                free(arg2);
            }
            else if (nextChar == '+'){
                if(digs_counter){
                    construct_number(neg_checker, digs_counter, acc_digits);
                    digs_counter=0;
                    neg_checker=0;

                }
                int if_one_neg=check_if_neg();
                bignum** arg1 = malloc(sizeof(bignum*));
                bignum** arg2 = malloc(sizeof(bignum*));
                int arg1_neg = stack[top]->is_neg;
                int arg2_neg = stack[top-1]->is_neg;
                int is_replaced= cps_populate_bignums_in_order(arg1,arg2); //arg1 will be the bigger arg
                pop();
                pop();
                push(*arg1);
                push(*arg2);

                if(!if_one_neg){
                    _add(stack+top-1);
                    digs_counter = 0;
                    free(stack[top]->digit);
                    free(stack[top]);
                    top--;
                }
                else{

                    substract();
                }

                if (is_replaced&&if_one_neg){
                    stack[top]->is_neg = arg1_neg;
                }
                else if(if_one_neg){
                    stack[top]->is_neg=arg2_neg;
                }
                else{
                    stack[top]->is_neg=arg2_neg;
                }
                free(arg1);
                free(arg2);
            }
            else if (nextChar == '*'){
                if(digs_counter){
                    construct_number(neg_checker, digs_counter, acc_digits);
                    digs_counter=0;
                    neg_checker=0;

                }
            int is_neg_result=check_if_neg();
	       bignum* copy_num1 = (bignum*) malloc(sizeof(bignum));
	       bignum* copy_num2 = (bignum*) malloc(sizeof(bignum));
               bignum* result_num = (bignum*) malloc(sizeof(bignum));
               char* copy1;
               char* copy2;
               char* result;
	       copy1 = (char*)malloc(stack[top-1]->number_of_digits);
               copy_num1->number_of_digits = stack[top-1]->number_of_digits;
               memset(copy1, '\0', stack[top-1]->number_of_digits);
    	       strncpy(copy1,stack[top-1]->digit,stack[top-1]->number_of_digits);
               copy_num1->digit = copy1;

	       copy2 = (char*)malloc(stack[top]->number_of_digits);
               copy_num2->number_of_digits = stack[top]->number_of_digits;
               memset(copy2, '\0', stack[top]->number_of_digits);
    	       strncpy(copy2,stack[top]->digit,stack[top]->number_of_digits);
	       copy_num2->digit = copy2;
                unsigned long temp = stack[top-1]->number_of_digits+stack[top]->number_of_digits+1;
	       result = (char*)malloc(temp);
               result_num->number_of_digits = temp;
               memset(result, '0',temp);

               result_num->digit = result;
	       free(stack[top]->digit);
	       free(stack[top]);
            stack[top]=NULL;
	       free(stack[top-1]->digit);
	       free(stack[top-1]);
            stack[top-1]=NULL;
               top = top-2;
               push(result_num);
               push(copy_num1);
	       push(copy_num2);
               _mul2(stack+top-2);
	       free(stack[top]->digit);
               free(stack[top]);
               free(stack[top-1]->digit);
               free(stack[top-1]);
               top = top-2;
                stack[top]->is_neg=is_neg_result;
            }
            else if (nextChar == '/'){
		remove_zeros(stack[top]);
		if(stack[top]->digit[stack[top]->number_of_digits-1] == '0'){		
			printf("can't divide by 0\n");
			eraseStack();
			continue;		
		}
                if(digs_counter){
                    construct_number(neg_checker, digs_counter, acc_digits);
                    digs_counter=0;
                    neg_checker=0;

                }
                int is_neg_result=check_if_neg();
		bignum* result_num = (bignum*) malloc(sizeof(bignum));
                bignum* divisor_num = (bignum*) malloc(sizeof(bignum));
                char* result;
                char* divisor;

                if(stack[top-1]->number_of_digits<stack[top]->number_of_digits) {
                    result = (char *) malloc(1);
                    result[0] = '0';
                    result_num->number_of_digits=1;
                    result_num->digit=result;
                    free(stack[top]->digit);
                    free(stack[top]);
                    free(stack[top-1]->digit);
                    free(stack[top-1]);
                    top = top -2;
                    push(result_num);
                    stack[top]->is_neg=0;
                    continue;
                }

                divisor = (char*)malloc(stack[top-1]->number_of_digits);
        		result = (char*)malloc(stack[top-1]->number_of_digits-stack[top]->number_of_digits + 1);
	        	result_num->number_of_digits = stack[top-1]->number_of_digits-stack[top]->number_of_digits + 1;
                divisor_num->number_of_digits = stack[top-1]->number_of_digits;
                memset(result, '0', stack[top-1]->number_of_digits-stack[top]->number_of_digits + 1);
	        	memset(divisor, '0', stack[top-1]->number_of_digits);
                unsigned long index = stack[top-1]->number_of_digits - stack[top]->number_of_digits;
        		strncpy(&(divisor[index]),stack[top]->digit,stack[top]->number_of_digits);
    	       	result_num->digit = result;
	        	divisor_num->digit = divisor;

                bignum* copy_num1 = (bignum*) malloc(sizeof(bignum));
                char* copy1;
                copy1 = (char*)malloc(stack[top-1]->number_of_digits);
                copy_num1->number_of_digits = stack[top-1]->number_of_digits;
                memset(copy1, '\0', stack[top-1]->number_of_digits);
                strncpy(copy1,stack[top-1]->digit,stack[top-1]->number_of_digits);
                copy_num1->digit = copy1;

                free(stack[top]->digit);
                        free(stack[top]);
                    free(stack[top-1]->digit);
                        free(stack[top-1]);
                top = top-2;
                push(result_num);
                push(copy_num1);
		        push(divisor_num);
                _div2(stack+top-2);
                free(stack[top]->digit);
                free(stack[top]);
                free(stack[top-1]->digit);
                free(stack[top-1]);
                top = top -2;

                stack[top]->is_neg=is_neg_result;
		
            }
            else if (nextChar == 'p'){
                if(digs_counter){
                    construct_number(neg_checker, digs_counter, acc_digits);
                    digs_counter=0;
                    neg_checker=0;

                }

		    bignum* cur = stack[top];
		    remove_zeros(cur);

		    if (cur->is_neg && cur->digit[cur->number_of_digits-1]!='0'){
		        putchar('-');
		    }
		    for(long i=cur->number_of_digits-1;i>=0;i--){
		        printf("%c",cur->digit[i]);
		    }
		    printf("\n");
		
            }
            else if(nextChar =='c'){
               eraseStack();
            }

        }

    }
    free(acc_digits);
    for (int j=0; stack[j]!=NULL;j++) {
        bignum* cur = stack[j];
        if(j<top){
            if (cur->is_neg){
                putchar('-');
            }

            for(long i=cur->number_of_digits-1;i>=0;i--){
                printf("%c",cur->digit[i]);
            }
            putchar('\n');
        }
    }

    }

int cps_populate_bignums_in_order(bignum **pBignum1, bignum **pBignum2) {
    bignum* arg1 = stack[top-1];
    bignum* arg2 = stack[top];
    if(arg1->number_of_digits>arg2->number_of_digits) {
        *pBignum1 = arg1;
        *pBignum2 = arg2;
        return 0;
    }
    else if(arg1->number_of_digits<arg2->number_of_digits){
        *pBignum1=arg2;
        *pBignum2=arg1;
        return 1;
    }
    else{
        for (unsigned long i=arg1->number_of_digits-1;i>=0;i--){
            if (arg1->digit[i]>arg2->digit[i]){
                *pBignum1 = arg1;
                *pBignum2 = arg2;
                return 0;
            }
            else if(arg1->digit[i]<arg2->digit[i]){
                *pBignum2 = arg1;
                *pBignum1 = arg2;
                return 1;
            }
        }
        *pBignum1 = arg1;
        *pBignum2 = arg2;
        return 0;
    }
}



int check_if_neg() {
    int first_arg_neg = stack[0]->is_neg;
    int second_arg_neg = stack[1]->is_neg;
    if (first_arg_neg != second_arg_neg){
        return 1;
    }
    else{
        return 0;
    }
}


yuval203455345_moshe203737804/asm.asm000644 001750 001750 00000017356 13262727670 017126 0ustar00yuvalyuval000000 000000 section .data
mode db 0
temp dq 0
number_of_digits1 dq 0
number_of_digits2 dq 0
number_of_digits3 dq 0

section .text
global _add
global _sub
global _mul2
global _div2

;*******************************DIV ZONE*************************************;
_div2:
    push rbp ; Save caller state
    mov rbp, rsp
    mov byte[mode], 4
    jmp init_div2

init_div2:
    mov r8,[rdi+8]
    mov r10,[rdi+16]
    mov r12,[rdi]
    mov rbx,[r8] ; number being divided number of digits
    mov rsi,[r12]; result number of digits
    mov rax,0
    mov al,47; counter
    mov rcx,rbx; N
    mov r9,[r8+8]; char* of number being divided
    mov r11,[r10+8]; char* of divisor
    mov r14,[r12+8]; char* of result
    mov r15,0; running index
    mov r12,0
    mov r13,0
    mov r10,0
    mov r8,0
    mov [temp],rcx
    jmp deep_comp2

deep_comp2:
    mov r10,[temp] 
    mov r15,0
    inc al
    mov rdx,rbx
    sub rdx,r15
    dec rdx
    cmp byte[r9+rdx],'0'
    jg .comp
    dec rbx
    .comp:
	cmp rbx,rcx
	jg substract_div
        cmp rbx,rcx
        jl set_result
        .comp2:
		cmp r15,rbx
		je  substract_div
		mov rdx,rbx
		dec rdx
		sub rdx,r15
	    	mov r12b, byte[r9+rdx]
		mov rdx,r10
		dec rdx
		sub rdx,r15
	    	mov r13b, byte[r11+rdx]
		cmp r12b,r13b
		jg substract_div
		cmp r12b,r13b
		jl set_result
		inc r15
		jmp .comp2
       
    
set_result:
    inc r8
    mov r15,0
    mov byte[r14+rsi-1],al;
    mov al,47
    dec rsi
    dec rcx
    cmp rsi,0
    je end_code
    jmp deep_comp2
    

;*******************************MUL2 ZONE*************************************;    

_mul2:
    push rbp ; Save caller state
    mov rbp, rsp
    mov byte[mode], 3
    jmp mul_init

mul_init:
    mov r12,0;
    mov r13,0;
    mov r14,0; indexer of multiplier
    mov r15,0; indexer of multilcant
    mov rax,0; result/quotient 
    mov rbx,0; used for div and mul
    mov rdx,0; remainder
    mov rcx,0; used for div and mul
    mov r8,[rdi]; get into 1st bignum
    mov r9,[r8]
    mov [number_of_digits1],r9

    mov r11,[r8+8]; char* of 1st bignum
    mov r8, [rdi+8]; get into 2nd bignum
    mov r9, [r8]; get number_of_digits of 2nd bignum
    mov [number_of_digits2],r9
    mov r12,[r8+8]; char* of 2nd bignum
    mov r8,[rdi+16]; get into 3rd bignum
    mov r10,[r8]; get number_of_digits of 3rd bignum
    mov [number_of_digits3],r10
    mov r13,[r8+8]; char* of 3rd bignum
    mov r8,0; - used for result[]
    mov r9,0; - used for bignum1[]
    mov r10,0; - used for bignum2[]
    jmp to_int

multiply:
    cmp r15,[number_of_digits2]
    je update_multiplier
    mov r8,r15
    add r8,r14
    mov r9b,byte[r12+r15]
    mov r10b,byte[r13+r14]
    sub r9b, '0'
    sub r10b,'0'
    mov bx,r9w
    mov ax,r10w
    mul bx
    mov bx,ax
    mov dx,0
    add al,byte[r11+r8]
    mov cx,10
    div cx
    mov byte[r11+r8],dl
    inc r8
    mov bl,byte[r11+r8]
    add al,bl       
    mov byte[r11+r8],al
    inc r15
    jmp multiply

update_multiplier:
   mov r15,0
   inc r14
   cmp r14,[number_of_digits3]
   je finish_mul
   jmp multiply

finish_mul:
   cmp r15,[number_of_digits1]
   je end_code
   mov r10w,word[r11+r15]
   add r10w,'0'
   mov word[r11+r15],r10w
   inc r15
   jmp finish_mul

to_int:
   cmp r15,[number_of_digits1]
   je set_before_run
   mov r10b,byte[r11+r15]
   sub r10b,'0'
   mov byte[r11+r15],r10b
   inc r15
   jmp to_int

set_before_run:
   mov r15,0
   jmp multiply
;*******************************ADDITION ZONE*************************************;

_add:
    push rbp ; Save caller state
    mov byte[mode], 1
    mov rbp, rsp
    jmp reading_big_nums

multiply_by_two:
    mov rdx,0; carry
    mov r12,0; char[counter] - num1
    mov r13,0; char[counter] - num2
    mov r15,0; counter
    mov rbx,0; number of digits num1
    mov rcx,0; number of digits num2

    mov r8,[rdi]; first bigNum
    mov r9,[r8+8]; char[0] of first bigNum

    mov r10,[rdi+16]; 2nd bigNum
    mov r11,[r10+8]; char[0] of 2nd bigNum
    jmp get_num_of_digits

reading_big_nums:
    mov rdx,0; carry
    mov r12,0; char[counter] - num1
    mov r13,0; char[counter] - num2
    mov r15,0; counter
    mov rbx,0; number of digits num1
    mov rcx,0; number of digits num2

    mov r8,[rdi]; first bigNum
    mov r9,[r8+8]; char[0] of first bigNum

    mov r10,[rdi+8]; 2nd bigNum
    mov r11,[r10+8]; char[0] of 2nd bigNum
    jmp get_num_of_digits

get_num_of_digits:
    mov bl, byte[r8];             rax<=first bignum's digits
    mov cl, byte[r10]; 
    jmp cmp_arg1


cmp_arg1:
    cmp r15 ,rbx
    jge cmp_arg1_finished 
    mov r12b, byte[r9+r15]; r12 holds char[counter] of 1st bigNUm
    jmp cmp_arg2


cmp_arg1_finished:
    cmp r15,rcx
    jge last_char
    mov r13b,byte[r11+r15]; r13 holds char[counter] of 2nd bigNUm
    cmp dl,1
    je addition
    jmp end_code
    
cmp_arg2:
    mov r13b,'0'
    cmp r15,rcx
    jge check_carry
    mov r13b,byte[r11+r15]
    jmp addition


check_carry:
    cmp dl,1
    je addition
    jmp mode_check

addition:
    add r12b,r13b ;r12 = r12+13
    add r12b,dl
    mov dl, 0
    sub r12d,'0'
    cmp r12d,'9' ; carry check 
    jg _carry
    jmp result_array

_carry:
    sub r12d,10;
    mov dl,1
    ;stc; carry flag = 1
    jmp result_array

result_array:
    mov byte[r9+r15],r12b; r12 holds char[counter] of 1st bigNUm
    inc r15
    jmp cmp_arg1


last_char:
    cmp dl,0
    je mode_check
    mov byte[r9+r15],'1'
    inc bl
    mov byte[r8],bl
    jmp mode_check
    jmp end_code

mode_check:
     mov r15,0
     cmp byte[mode],3
     je substract_by_one
     cmp byte[mode],4
     je init_div2
     jmp end_code

end_code:
    mov [rbp-8], rax
    pop rbp ; Restore caller state
    ret


;*******************************SUBSTRACTION-DIV ZONE*************************************;
substract_div:
mov r15,0;counter
mov r10,r8
mov rdx,0;carry
jmp cmp_arg1_sub
;*******************************SUBSTRACTION ZONE*************************************;

_sub:
    push rbp ; Save caller state
    mov byte[mode], 2
    mov rbp, rsp
    jmp reading_big_nums_sub

div_substraction:
    mov r15,0; counter
    mov rdx,0; carry
    jmp cmp_arg1_sub

substract_by_one:
    mov rdx,0; carry
    mov rbx,0; number of digits num1
    mov rcx,0; number of digits num2
    mov r8,[rdi+8]
    mov r9,[r8+8]; char* of first bigNum
    mov r10,[rdi+24]
    mov r11, [r10+8]; char* of 2nd bigNum
    mov rbx,[r8]
    mov rcx,[r10]
    mov r10,0
    jmp cmp_arg1_sub

reading_big_nums_sub:
    mov r15,0
    mov rdx,0; carry
    mov r12,0; char[counter] - num1
    mov r13,0; char[counter] - num2
    mov r15,0; counter
    mov rbx,0; number of digits num1
    mov rcx,0; number of digits num2


    mov r8,[rdi]; first bigNum digits
    mov r9,[r8+8]; char* of first bigNum
    mov r10,[rdi+8]; 2nd bigNum digits
    mov r11,[r10+8]; char* of 2nd bigNum

    mov rbx,[r8]
    mov rcx,[r10]
    mov r10,0

;no need for subtracting the smaller from the bigger

cmp_arg1_sub:
    cmp r15 ,rbx
    jge cmp_arg1_finished_sub
    mov r12b, byte[r9+r15]; r12 holds char[counter] of 1st bigNUm
    jmp cmp_arg2_sub

cmp_arg2_sub:
    mov r13b,'0'
    cmp r15,rcx
    jge substraction
    mov r13b,byte[r11+r10]
    jmp substraction

cmp_arg1_finished_sub:
    mov r12b,'0'
    cmp r15,rcx
    jge last_char_sub
    mov r13b,byte[r11+r10]; r13 holds char[counter] of 2nd bigNUm
    jmp substraction

substraction:
    sub r12b, '0'
    sub r13b, '0'
    sub r12b,r13b
    sub r12b,dl
    cmp r12b,0
    jl compen
    mov dl,0
    jmp result_a

compen:
    add r12b,10
    mov dl, 1
    jmp result_a

result_a:
    add r12b,'0'
    mov byte[r9+r15],r12b; r12 holds char[counter] of 1st bigNUm
    inc r15
    inc r10
    jmp cmp_arg1_sub

last_char_sub:
    cmp dl,0
    je mode_sub
    cmp dl,1
    jne mode_sub
    mov byte[rdi+16],1
    jmp mode_sub

mode_sub:
     mov r15,0
     cmp byte[mode],3
     je mul_init
     cmp byte[mode],4
     je deep_comp2
     jmp end_code
yuval203455345_moshe203737804/000775 001750 001750 00000000000 13263416420 015617 5ustar00yuvalyuval000000 000000 yuval203455345_moshe203737804/makefile000644 001750 001750 00000000310 13262730015 017305 0ustar00yuvalyuval000000 000000 calc: main.o asm.o
	gcc -g -Wall -o calc main.o asm.o
main.o: main.c
	gcc -g -Wall -c -o main.o main.c
asm.o: asm.asm
	nasm -g -f elf64 -w+all asm.asm -o asm.o
.PHONY: clean

clean:
	rm -f *.o calc 
	
