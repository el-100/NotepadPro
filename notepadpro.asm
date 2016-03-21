use16
org 0xF000

core:	
	xor ax, ax
	mov es, ax

	mov si, 7f00h

;clear screen
	mov ax, 0003h
	int 10h

;print start message
	mov ax, 1301h ; режим
	mov dx, 1700h
	mov cx, 20   ; количество символов
	mov bp, info
	mov bx, 0008h
	int 10h
	
	mov dx, 0000h ; устанавливаем курсор на 0-ю строку
	mov cx, 1 ; используется для сдвига, и для прерывания
	xor bh, bh ; что-то оочень нужное!
	
	mov [0xaf10],dx ; говорим что все файлы пустые
	mov [0xaf20],dx ;
	mov [0xaf30],dx ;
	
	mov edx, 7f00h;
	mov [0xaf00],edx ; по умолчанию открыт 1-й файл
	
	;mov ecx, 0000h ; итератор
	
start:
	xor ax, ax  ; команда ожидания нажатия клавиши
	int 16h		; фигачим прерывание клавиатуры
	
	pop ecx
	pop edx
	call savefile
	push edx
	push ecx
	call openfile

; экранирование null'ов
	cmp al, 0
	je screen
	mov [si], al ; записываем в si символ
	add si, 1	 ; сдвигаем указатель текста
screen:

	pop ecx
	pop edx
	call printfile
	push edx
	push ecx
	
	add dx, 1    ; ++
	cmp dx, 200h ; 512 байт на файл
	jnz start
	
	mov dx, 0000h ; устанавливаем курсор на 0-ю строку 0-й столбец
	sub si, 200h
	
	jmp start
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	; af00h тут лежит номер открытого файла
	; af10h записано байт в 1-й файл
	; af20h записано байт во 2-й файл
	; af30h записано байт в 3-й файл
	
	
	
	
	
savefile:
	mov ebx, [0xaf00]
	mov dx, si   ; длина строки
	sub dx, bp	 ;
; запоминаем длину текущего файла
	cmp ebx, 7f00h
	je len1
	cmp ebx, 8f00h
	je len2
	cmp ebx, 9f00h
	je len3
	jmp endlen
len1:
	mov [0xaf10],dx
	jmp endlen
len2:
	mov [0xaf20],dx
	jmp endlen
len3:
	mov [0xaf30],dx
	jmp endlen
endlen:
	ret 0
	
	
	
	
	
	
	
openfile:

; открываем файл №1
	cmp ah, 3bh
	jne file1end
	
	mov ebx, 7f00h 
	mov [0xaf00],ebx
	
	mov dx, [0xaf10]
	mov si, 7f00h
	add si, dx
file1end:
	
; открываем файл №2
	cmp ah, 3ch
	jne file2end
	
	mov ebx, 8f00h 
	mov [0xaf00],ebx
	
	mov dx, [0xaf20]
	mov si, 8f00h
	add si, dx
file2end:
	
; открываем файл №3
	cmp ah, 3dh
	jne file3end
	
	mov ebx, 9f00h 
	mov [0xaf00],ebx
	
	mov dx, [0xaf30]
	mov si, 9f00h
	add si, dx
file3end:

	ret 0
	
	
	
	
	
	
	
printfile:
;;;;;;;;;;;; КОСТЫЛЬ ОЧИСТКИ ЭКРАНА

;clear screen
	mov ax, 0003h
	int 10h

;print start message
	mov ax, 1301h ; режим
	mov dx, 1700h
	mov cx, 20   ; количество символов
	mov bp, info
	mov bx, 0008h
	int 10h
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	mov bp, [0xaf00] ; указатель на текущий файл
	
	mov cx, si   ; длина строки
	sub cx, bp	 ;
	
	mov dx, 0
	
	mov bx, 0008h
	mov ax, 1301h  ; печатаем весь текст из bp 
	int 10h		 ;
	ret 0

	
	
	
resrve: db '        '
info: db 'Notepad Pro Edition'
	
finish:
	times 0x600-finish+start db 0