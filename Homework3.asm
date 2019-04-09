#Homework 3 


#declare prompts and variables

	.data
#for syscall 54
prompt:		.asciiz	"Enter some text: "
buffer:		.word	100
println:	.asciiz	"\nYou entered: "
string:		.space	100

#printing results
charCount:	.word	0
wordCount:	.word 	0
wordLabel:	.asciiz	" words "
charLabel:	.asciiz	" characters "

#for syscall 59
endmsg:		.asciiz	"Goodbye!"
endprompt: 	.asciiz "Message: "

     

	.text

#repeat the prompt loop until the user clicks cancel

loop:
      #use dialog syscall to input a string from the user 
      la $a0, prompt
      la $a1, string
      lw $a2, buffer
      li $v0, 54
      syscall


      #if the user clicks cancel.... end the loop and branch to exit
      beq $a1, -2, exit
      beq $a1, -3, exit

      #calls the function for the stack 
      la $a0, string
      lw $a1, buffer
      jal stack

      #store charcount in $v0 and store wordcount in $v1
      sw $v0, charCount
      sw $v1, wordCount
      
      #print before the string is printed 
      la $a0, println
      li $v0, 4
      syscall

      #display the string and counts
      la $a0, string
      li $v0, 4
      syscall

      #word count

      lw $a0, wordCount
      li $v0, 1
      syscall

      la $a0, wordLabel
      li $v0, 4
      syscall

      #char count

      lw $a0, charCount
      li $v0, 1
      syscall

      la $a0, charLabel
      li $v0, 4
      syscall

      #call function which counts the number of characters and words 
      j loop

exit:
      #display goodbye message dialog box using syscall 59 
      la $a0, endprompt
      la $a1, endmsg
      li $v0, 59
      syscall

      #exit
      li $v0, 10
      syscall

#define the loops needed

stack:
      #save s0 on stack by allocating 4 bytes -- push
      addi $sp, $sp, -4
      sw $s1, 0($sp)
      move $s1, $a0

      #char count
      li $t1, 0
      #word count
      li $t2, 1

loop2:
      lb $t3, ($s1)

      #end of string or null string 
      beq $t3, '\n', end
      beq $t3, '\0', end

      #increment the char count
      add $t1, $t1, 1

      #if there is a space... add one to the word count
      beq $t3, ' ', wordCounter
      
      j loop3

     

#call loop to count the words

wordCounter:
      addi $t2, $t2, 1

loop3:
      addi $s1, $s1, 1

      j loop2    

end:
      #restore stack -- pop
      lw $s1, 0($sp)
      add $sp, $sp, 4

      #move the values back to their respective registers
      move $v0, $t1
      move $v1, $t2

      jr $ra
