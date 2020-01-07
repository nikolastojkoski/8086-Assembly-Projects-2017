DOSSEG
.model small;

.stack 100H

writeChar MACRO chr
  mov dl, chr
  mov ah, 02h
  int 21h
ENDM
newline MACRO
  writeChar 10 ;newline chr
  writeChar 13 ;return chr
ENDM
addEmptyLines MACRO
  LOCAL L1
  mov cx, 10
  L1:
    newline
  loop L1
ENDM
clearscreen MACRO
  LOCAL L1
  mov cx, 50
  L1:
    newline
  loop L1
ENDM
write MACRO msg
  mov dx, offset msg
  mov ah, 9
  int 21h
ENDM
writeln MACRO msg
  write msg
  newline
ENDM
read_filename MACRO filename
 
  mov dx, offset filename
  mov ah, 0Ah
  int 21h
  
  mov si, offset filename + 1
  mov cl, [si] ;len of msg
  mov ch, 0
  inc cx ;to reach chr(13)
  add si, cx ; now si points to chr(13)
  mov al, 0
  mov [si], al
  newline;
  
ENDM
open_file MACRO filename, handle, err
  mov ah, 3Dh
  mov dx, offset filename; + 2
  mov al, 0; 2- r/w ,1 - readonly attribute
  int 21h
  jc open_error 
  
  mov handle, ax
  jmp openfile_end
  
  open_error:
    mov err, 1
  openfile_end:
ENDM
close_file MACRO handle
  mov bx, handle;offset handle
  mov ah, 3Eh
  int 21h
ENDM
move_file_pointer MACRO handle, bytes, cur_ptr

  ;check range for move(bytes)
  mov ax, cur_ptr
  mov bx, bytes
  add ax, bx
  cmp ax, 0
  jl move_to_begin

  mov cx, 0  ;cx:dx bytes to move (signed)
  mov dx, bytes
  cmp dx, 0
  jl negative_dir
  jmp move_ptr
  
  negative_dir:
     mov cx, -1
     
  move_ptr:
  	mov ah, 42h
  	mov al, 1 ; move relative to current file pos
  	mov bx, handle
  	int 21h
  	mov cur_ptr, ax ;new location(in bytes from beggining of file)
    jmp move_file_pointer_end
  move_to_begin:
    mov ah, 42h
    mov al, 0 ;move relative to beginning of file
    mov bx, handle
    mov cx, 0
    mov dx, 0
    int 21h;
    mov cur_ptr, ax
  
  move_file_pointer_end:		
ENDM
read_line MACRO handle, line_w, out_length
  mov cx, line_w
  read_line_loop:
  	push cx
  	
    mov ah, 3Fh
    mov bx, handle
    mov cx, 1
    lea dx, chr
    int 21h
    
    cmp ax, cx
    jl end_of_file
    
    writeChar chr
    
    pop cx
  loop read_line_loop
  
  mov out_length, line_w
  jmp read_line_end
  
  end_of_file:
    pop cx
    mov ax, line_w
    sub ax, cx
    mov out_length, ax
    
  read_line_end: 
ENDM

read_file MACRO handle, line_w, numLines

  mov al, numLines
  mov ah, line_w
  mul ah
  push ax
  
  mov bx, line_w
  sub ax, bx
  mov bx, -1
  imul bx
  mov pgdn_bytes, ax 
  ;pgdn_bytes=-(numLines*line_w - line_w)
  
  pop ax
  mov bx, line_w
  add ax, bx
  mov bx, -1
  imul bx
  mov pgup_bytes, ax
  ;pgup_bytes = -(numLines * line_w + line_w)
  
 read_loop:
    mov cx, numLines
    
    readlines_loop:
      push cx 
	  read_line handle, line_w, out_len
	  
	  mov ax, cur_ptr
  	  mov bx, out_len
  	  add ax, bx
  	  mov cur_ptr, ax
		
	  pop cx
	loop readlines_loop

	addEmptyLines
	
	 mov ah, 00h
	 int 16h ;get keystroke   
	 
	 cmp ah, 81 ;pgdn-81
	 je move_page_dn
	 
	 cmp ah,73  ;pgup-73 
	 je move_page_up
	 
	 cmp al, 'e'
	 je readfile_end
	 
  jmp read_loop
   
  move_page_up:
    mov ax, pgup_bytes
    mov var_bytes, ax
    jmp move_fptr
  move_page_dn:
    mov ax, pgdn_bytes
    mov var_bytes, ax
    jmp move_fptr
	 
   move_fptr: 
    move_file_pointer handle, var_bytes, cur_ptr
    clearscreen
    jmp read_loop
  
  readfile_end:
ENDM
.data 
  ;messages
  filename_m db "Enter file name: ", "$"
  errOpen_m db "Cannot open file!", "$"
  
  ;file variables
  filename db 40        ;max len
   		   db ?         ;chars entered
 	       db 40 dup(0) ;buffer
  handle dw 0
	
  ;variables
  chr db 0
  err db 0
  out_len dw 0
  var_bytes dw 0
  cur_ptr dw 0
  pgup_bytes dw 0
  pgdn_bytes dw 0
	
.code
	mov ax, @data
	mov ds,ax
	mov es,ax
	
	writeln filename_m
	read_filename filename
	
	clearscreen
	
	open_file filename + 2, handle, err
	
	mov al, err
	cmp al, 1
	jne main_program_readfile
	writeln errOpen_m
	jmp main_program_end
	
main_program_readfile:
	
	read_file handle, 80, 10
	
	close_file handle
	
main_program_end:
	
	mov	ax,4c00h
	int	21h	
end
