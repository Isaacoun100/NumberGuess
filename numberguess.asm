; Lee, S. C. (2024801079). 
; Bennett Lewis, R. (2022133987). 
; Herera Monge, I. (201916055).
;
; Tecnologico de Costa Rica

include "emu8086.inc"
.MODEL SMALL

.DATA
    aleatorio db "Ingrese un numero aleatorio",13, 10, "$"
    vacio db 13, 10, "$"
    requestNumber1 DB "Ingrese el primer valor (menor)$"
    requestNumber2 DB "Ingrese el segundo valor (mayor)$"
    errorRand DB "Error: no se pudo generar un numero", 13, 10, "$"
    errorRandOp1 DB "1. Reintentar genera numero aleatorio", 13, 10, "$"
    errorRandOp2 DB "2. Ingresar otro valor de inico/final", 13, 10, "$"
    firstValue DW 0
    secondValue DW 0
    numAleAtorio DW 0
    tempRand DW 0

.CODE
imp macro mensaje
    mov ah, 09
    lea dx, mensaje
    int 21h
endm

generarRand macro
    ; Solicitar primer numero
    imp requestNumber1
leerNum1:
    ; Leer un caracter para el primer numero
    mov ah, 1
    int 21h
    cmp al, 13
    je prepareSecond    ;Si el usuario presiona enter termina el proceso
    ;Obtiene y almacena el siguiente digito del numero
    sub al, 48
    mov bl, al
    xor ax, ax
    mov ax, firstValue
    mov bh, 10      ;Multiplica el numero anterio por 10 dandole espacio al nuevo digito
    mul bh
    xor bh, bh
    add ax, bx      ;Anade el nuevo digito
    mov firstValue, ax     ; Guardar el valor en firstValue
loop leerNum1

prepareSecond:
    ; Solicitar el segundo numero
    imp vacio
    imp requestNumber2
    jmp leerNum2

leerNum2:
    ; Leer un caracter para el segundo numero
    mov ah, 1
    int 21h
    cmp al, 13
    je prepararNum      ;Si el usuario presiona enter termina el proceso
    ;Obtiene y almacena el siguiente digito del numero
    sub al, 48
    mov bl, al
    xor ax, ax
    mov ax, secondValue
    mov bh, 10      ;Multiplica el numero anterio por 10 dandole espacio al nuevo digito
    mul bh
    xor bh, bh
    add ax, bx      ;Anade el nuevo digito
    mov secondValue, ax         ; Guardar el valor en second value
loop leerNum2    

prepararNum:
    ;Se asegura que secondValue sea mayor que firstValue
    mov ax, secondValue
    cmp ax, firstValue
    jle final
    mov ax, firstValue
    cmp ax, 0
    jl final        ;secondValue debe ser mayor o igual a 0
    ;Obtiene el numero de tics del reloj para el numero aleatorio
    mov ah, 00h
    int 1ah
    mov tempRand, dx    ;Almacena el numero de tics desde medianoche en temRand 
    jmp obtenerNum
    
obtenerNum:
    ;Obtiene el primer digito del numero aleatorio
    xor dx, dx
    mov ax, tempRand
    mov cx, 10
    div cx
    ;Guarda el numero aleatorio sin el primer digito para el siguiente ciclo
    mov tempRand, ax
    ;Revisa si numAleatorio con el nuevo digito es mayor que secondValue
    mov ax, numAleatorio
    mov bx, dx
    mul cx      ;multiplica numAleatorio por 10 para hacer espacio al siguiente digito
    add ax, bx
    cmp ax, secondValue
    jge final        ;Si el numero es mayor o igual a secondValue termina el proceso
    ;Anade el numero con el nuevo digito a numAleatorio
    mov numAleatorio, ax
    ;Se revisa que tempRand sea diferente a 0 para el siguiente ciclo
    mov ax, tempRand
    cmp ax, 0
    jle final
loop obtenerNum

erroRandGenerar:
    ;Pregunta si el usuario desea generar un numero
    ;Dentro del rango o ingresar un rango diferente
    imp errorRand
    imp errorRandOp1
    imp errorRandOp2
    mov ah, 1
    int 21h
    cmp al, "1"
    je prepararNum
    cmp al, "2"
    jne erroRandGenerar
    ;Pide el primer valor del nuevo rango
    imp vacio
    imp requestNumber1
    jmp leerNum1

final:
    imp vacio
    mov ax, numAleatorio
    cmp ax, firstValue
    jl erroRandGenerar  
    call print_num    
endm
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS
    ; Inicio del programa
    MOV AX, @DATA
    MOV DS, AX
        
    generarRand
    ; Terminar programa
    MOV AH, 4Ch
    INT 21h
    
END
