; Lee, S. C. (2024801079). 
; Bennett Lewis, R. (2022133987). 
; Herera Monge, I. (201916055).
;
; Tecnologico de Costa Rica

.MODEL SMALL

.DATA
    requestNumber1 DB "Ingrese el primer valor (menor)$"
    requestNumber2 DB "Ingrese el segundo valor (mayor)$"
    firstValue DB 0
    secondValue DB 0

.CODE

    ; Inicio del programa
    MOV AX, @DATA
    MOV DS, AX

    ; Solicitar primer numero
    LEA DX, requestNumber1
    MOV AH, 09h
    INT 21h

    ; Leer un caracter para el primer numero
    MOV AH, 01h
    INT 21h
    SUB AL, '0'
    MOV firstValue, AL     ; Guardar el valor en firstValue

    ; Solicitar el segundo numero
    LEA DX, requestNumber2
    MOV AH, 09h
    INT 21h

    ; Leer un caracter para el segundo numero
    MOV AH, 01h
    INT 21h
    SUB AL, '0'            
    MOV secondValue, AL    ; Guardar el valor en second value

    ; Terminar programa
    MOV AH, 4Ch
    INT 21h
END
