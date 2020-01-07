DOSSEG
.model small;

.stack 500H

pauseProg MACRO length
  LOCAL pause1
  LOCAL pause2
  
  pause1:
  mov cx, length
  pause2:
  dec cx
  jnz pause2
  dec bx
  jnz pause1
  
ENDM

playnote MACRO frequency

  push ax
  push bx
  push cx
  
  mov al, 182
  out 43h, al
  
  mov ax, frequency

  out 42h, al
  mov al, ah
  out 42h, al
  in al, 61h

  or al, 00000011b
  out 61h, al                   
  mov bx, 25

  pauseProg 10000
  
  in al, 61h
  and al, 11111100b
  out 61h, al
  
  pop cx
  pop bx
  pop ax

ENDM

.data 
notes dw 100 dup(0);
 
.code
 mov ax, @data
 mov ds,ax
  
 lea bx, notes
 mov cx, 0
 jmp afterAddNote
 
 read_key_loop:
  
  addNote:
    playnote dx
    mov [bx], dx
    add bx, 2
    inc cx
    
  afterAddNote:
  
  mov ah, 00h ;
  int 16h     ; get keystroke
  
  cmp al, 'a'
  je note1
  cmp al, 's'
  je note2
  cmp al, 'd'
  je note3
  cmp al, 'f'
  je note4
  cmp al, 'g'
  je note5
  cmp al, 'h'
  je note6
  cmp al, 'j'
  je note7
  cmp al, 'k'
  je note8
  cmp ah, 28
  je program_end
  
  jmp afterAddNote
  
  note1:
    mov dx, 9121
  	jmp read_key_loop
  note2:
    mov dx, 8126
  	jmp read_key_loop
  note3:
    mov dx, 7239
  	jmp read_key_loop
  note4:
    mov dx, 6833
  	jmp read_key_loop 
  note5:
    mov dx, 6087
  	jmp read_key_loop
  note6:
    mov dx, 5423
  	jmp read_key_loop
  note7:
    mov dx, 4831
  	jmp read_key_loop  
  note8:
    mov dx, 4560
  	jmp read_key_loop

  program_end:
  
  lea bx, notes
  playSounds:
    mov dx, [bx]
    add bx, 2
    playnote dx
  loop playSounds
  
  mov	ax,4c00h
  int	21h	
  
end
