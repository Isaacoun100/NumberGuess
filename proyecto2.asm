; Lee, S. C. (2024801079). 
; Bennett Lewis, R. (2022133987). 
; Herera Monge, I. (201916055).
;
; Tecnologico de Costa Rica
include "emu8086.inc"
.MODEL SMALL

.DATA
    titulo DB "Reto del numero secreto", 13, 10, "$"
    instruccion DB "Adivine el numero secreto entre los valores engresados para ganar, solo tiene 5 intentos", 13, 10, "$"
    aleatorio DB "Ingrese un numero aleatorio",13, 10, "$"
    pregunta DB "Cual es el numero secreto: ", 13, 10, "$"
    mostrarIntentos DB "Numero de intentos: ", "$"
    vacio DB 13, 10, "$"
    requestNumber1 DB "Ingrese el primer valor (menor)$"
    requestNumber2 DB "Ingrese el segundo valor (mayor)$"
    errorRand DB "Error: no se pudo generar un numero", 13, 10, "$"
    errorRandOp1 DB "1. Reintentar genera numero aleatorio", 13, 10, "$"
    errorRandOp2 DB "2. Ingresar otro valor de inico/final", 13, 10, "$"
    salirJuego db "presione (s) para salir del juego y (r) para reiniciar", 13, 10, "$"
    errorAdiv DB "El dato ingresado no es valido, vuelva a intentarlo", 13, 10, "$"
    victoria DB "Ganador", 13, 10, "$"
    perdio DB "Derrota", 13, 10, "$"
    arriba DB " > ?$"
    abajo DB " < ?$"
    revelar DB "El numero secreto es: ", 13, 10, "$"
    firstValue DW 0
    secondValue DW 0
    numAleatorio DW 0
    tempRand DW 0
    numIntentos DB 0

.CODE
imp macro mensaje
    mov ah, 09
    lea dx, mensaje
    int 21h
endm

adiv macro
    mov firstValue, 0       ;Reutiliza firstValue para almacenar la el numero del jugador
    mov cx, 10
jugadorAdiv:
    ;Obtiene el digito del jugador
    mov ah, 1
    int 21h
    cmp al, 13
    je finalAdiv        ;Finaliza si el jugador presiona enter
    
    cmp al, "r"         ;Si el jugador presiona r sale del juego
    je finalAdiv
    cmp al, "R"
    je finalAdiv
    cmp al, "s"     ;Si el jugador presiona s sale del juego
    je finalAdiv
    cmp al, "S"
    je finalAdiv
    ;Verifica que se haya ingresado un numero
    sub al, 48      ;Convierte de ASCII a decimal
    cmp al, 9
    jg errorAdivJ
    cmp al, 0
    jl errorAdivJ       ;Si no es un numero del 0 al 9 salta al error
    ;Ingresa el digito al resto del numero en firstValue
    mov bl, al
    xor ax, ax
    mov ax, firstValue
    mov bh, 10      ;Multiplica el numero anterio por 10 dandole espacio al nuevo digito
    mul bh
    xor bh, bh
    add ax, bx      ;Anade el nuevo digito
    mov firstValue, ax     ; Guardar el valor en firstValue
loop jugadorAdiv
    
errorAdivJ:
   imp vacio
   imp errorAdiv        ;Salta error al jugador por no ingresar un digito
   ;El jugador debe reintentar ingresar un numero 
   imp mostrarIntentos
   mov ah, 02
   mov dl, numIntentos
   add dl, 30h
   int 21h
   imp vacio
   imp salirJuego
   imp pregunta
   jmp jugadorAdiv

finalAdiv:
endm     

generarRand macro
    ; Solicitar primer numero
    imp salirJuego
    imp requestNumber1
leerNum1:
    ; Leer un caracter para el primer numero
    mov ah, 1
    int 21h
    cmp al, 13
    je prepareSecond    ;Si el juegador presiona enter termina el proceso
    
    cmp al, "r"         ;Si el jugador presiona r sale del juego
    je saltarProc
    cmp al, "R"
    je saltarProc
    cmp al, "s"     ;Si el jugador presiona s sale del juego
    je saltarProc
    cmp al, "S"
    je saltarProc                                                
    
    ;Obtiene y almacena el siguiente digito del numero
    sub al, 48
    cmp al, 9
    jg erroRandGenerar
    cmp al, 0
    jl erroRandGenerar
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
    imp salirJuego
    imp requestNumber2
    jmp leerNum2

leerNum2:
    ; Leer un caracter para el segundo numero
    mov ah, 1
    int 21h
    cmp al, 13
    je prepararNum      ;Si el usuario presiona enter termina el proceso
    
    cmp al, "r"         ;Si el jugador presiona r sale del juego
    je saltarProc
    cmp al, "R"
    je saltarProc
    cmp al, "s"     ;Si el jugador presiona s sale del juego
    je saltarProc
    cmp al, "S"
    je saltarProc
    
    ;Obtiene y almacena el siguiente digito del numero
    sub al, 48
    cmp al, 9
    jg erroRandGenerar
    cmp al, 0
    jl erroRandGenerar
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
    jle erroRandGenerar
    mov ax, firstValue
    cmp ax, 0
    jl erroRandGenerar        ;firstValue debe ser mayor o igual a 0
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
    cmp ax, 1
    jl final
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
    
    cmp al, "r"         ;Si el jugador presiona r sale del juego
    je saltarProc
    cmp al, "R"
    je saltarProc
    cmp al, "s"     ;Si el jugador presiona s sale del juego
    je saltarProc
    cmp al, "S"
    je saltarProc
    
    ;Pide el primer valor del nuevo rango
    imp vacio
    imp requestNumber1
    jmp leerNum1

final:
    imp vacio
    mov ax, numAleatorio
    cmp ax, firstValue
    jl erroRandGenerar
saltarProc:    
endm
    ; Inicio del programa
    MOV AX, @DATA
    MOV DS, AX
    DEFINE_PRINT_NUM
    DEFINE_PRINT_NUM_UNS
iniciarJuego:
    mov numIntentos, 1      ;Inicia el juego con 0 intentos
    imp vacio
    imp titulo
    imp instruccion     ; Muestra las instrucciones al jugador de como jugar        
    generarRand
    cmp al, "r"     ; si el jugador presiona "r" reinicia el juego
    je iniciarJuego                                              
    cmp al, "R"
    je iniciarJuego
    ;Si el jugador presiona "s" termina el juego
    cmp al, "s"
    je salir
    cmp al, "S"
    je salir
adivinar:
    imp mostrarIntentos     ;Imprime el numero del intento actual
    mov ah, 02
    mov dl, numIntentos
    add dl, 30h
    int 21h
    
    imp vacio
    imp salirJuego      ;Imprime las opciones de salida del juego
    imp pregunta        ;Pregunta al jugador que adivine el numero
    adiv        ;Obtiene el numero del jugador
    cmp al, "r"     ; si el jugador presiona "r" reinicia el juego
    je iniciarJuego                                              
    cmp al, "R"
    je iniciarJuego
    ;Si el jugador presiona "s" termina el juego
    cmp al, "s"
    je salir
    cmp al, "S"
    je salir
    ;Compara el numero aleatorio con la adivinacion del jugador
    mov ax, firstValue
    cmp ax, numAleatorio
    je ganador      ;Si son iguales el jugador gana
    jg mayor        ;Si la adivinacion es mayor al numero secreto lo indica
    jl menor        ;Si la adivinacion es menor al numero secreto lo indica

mayor:
    ;Muestra al jugador que su adivinacion es mayor al numero secreto
    imp arriba
    imp vacio
    inc numIntentos     ;Incrementa el numero de intentos
    ;El jugador pierde si el numero de intentos es mayor a 5
    mov al, numIntentos
    cmp al, 5
    jg perdida
    ;Le pide al jugador su siguiente adivinacion
    jmp adivinar

menor:
    ;Muestra al jugador que su adivinacion es menor al numero secreto
    imp abajo
    imp vacio
    inc numIntentos         ;Incrementa el numero de intentos
    ;El jugador pierde si el numero de intentos es mayor a 5
    mov al, numIntentos
    cmp al, 5
    jg perdida  
    ;Le pide al jugador su siguiente adivinacion
    jmp adivinar    

perdida:
    imp vacio
    imp perdio      ;Indica que el jugador a perdido
    ;Le revela el numero secreto al jugado
    imp revelar     
    mov ax, numAleatorio        
    CALL print_num
    jmp salir
        
    
ganador:
    imp vacio
    imp victoria        ;Indica al jugador que ha ganado
    ;le muestra al jugador el numero de intentos utilizados
    imp mostrarIntentos     
    xor ax, ax
    mov al, numIntentos
    CALL print_num 
        
salir:
    ; Terminar programa
    MOV AH, 4Ch
    INT 21h
    
END