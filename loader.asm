use16
org 0x7c00

start:	
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov ss,ax
	cld
	;mov si, 7c00h
	;mov di,0600h		
	;mov cx,200h
	;rep movsb

;print msg
	mov ax, 1301h ; режим
	mov dx, 0000h
	mov cx, 45   ; количество символов
	mov bp, start_msg
	mov bx, 0008h
	int 10h
;read key

back:
	mov ah, 00h
	int 16h
	
	cmp al, 31h
	jz boot_linux
	cmp al, 32h
	jz boot_notepadpro
	jmp back

	
boot_linux:
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov ss,ax
	
	mov ax, 0201h ; al - число секторов
	mov cx, 01h   ; cl - номер сектора
	mov dx, 80h   ; dh - номер головки, dl - номер диска
	mov bx, 7C00h ; адрес буфера вызывающей программы
	int 13h
	jmp 0000:7c00h
	
boot_notepadpro:
	xor ax, ax
	mov es, ax
	mov  si, start_notepadpro_msg
	mov  ah, 0x0E
	mov  bh, 0x00
print_notepadpro:
	lodsb
	test al, al
	jz   jump_to_notepadpro
	int  0x10 
	jmp  print_notepadpro
jump_to_notepadpro:
	mov ah, 00h
	int 16h
	mov ax, 0003h
	int 10h
	mov ah, 02h
	mov dx, 00h
	mov cx, 02h
	mov al, 02h
	mov bx, 0xF000
	int 13h
	jmp 0000h:0xF000





	
	jmp start
	
	
;ax это реал мод
;включаем
;затем CX:DX = segment:offset
;1 сегмент, граб на 80

start_msg: db 'key 1 to boot Linux', 0ah, 0dh, 'key 2 to boot NotepadPro', 0
shit: db '      shit!          ', 0
start_notepadpro_msg: db 0ah,0ah,0dh,'NotepadPro started, press any key',0
finish:
     times 0x1FE-finish+start db 0
     db   0x55, 0xAA
incbin 'notepadpro.bin'