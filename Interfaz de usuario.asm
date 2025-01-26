; Juego interactivo: Reto del Numero Secreto
; Código ajustado y revisado para eliminar errores

include "emu8086.inc"
.MODEL SMALL

.DATA
mensajeInicio DB "Reto del Numero Secreto!$"
pedirRangoMin DB "Ingrese el limite inferior del rango:$"
pedirRangoMax DB "Ingrese el limite superior del rango:$"
pedirNumero DB "Intenta adivinar el numero secreto:$"
felicitacion DB "Felicidades! Adivinaste el numero en $"
intentosRestantes DB "Intentos restantes: $"
intentosMensaje DB " intentos usados.$"
perdiste DB "Lo siento, has perdido! El numero secreto era: $"
errorRango DB "Rango invalido! Reiniciando...$"
numeroSecreto DW 0
numeroIngresado DW 0
limiteInferior DW 0
limiteSuperior DW 0
intentosMax DW 5
usados DW 0

.CODE

; Macro para imprimir mensajes
imp macro mensaje
    mov ah, 09h
    lea dx, mensaje
    int 21h
endm

; Generar numero aleatorio dentro del rango
generarNumeroAleatorio:
    mov ah, 00h
    int 1ah       ; Obtener numero de ticks del reloj
    xor dx, dx
    mov ax, dx
    xor dx, dx
    mov bx, limiteSuperior
    sub bx, limiteInferior
    inc bx
    div bx        ; Numero aleatorio dentro del rango
    add dx, limiteInferior
    mov numeroSecreto, dx
    ret

; Leer un numero del teclado
leerNumero:
    xor ax, ax
    xor bx, bx
leerDigito:
    mov ah, 1       ; Leer un caracter
    int 21h
    cmp al, 13      ; Enter
    je finLectura
    sub al, 48      ; Convertir ASCII a numero
    mov bl, al
    mov cx, 10
    mul cx
    add ax, bx
    jmp leerDigito
finLectura:
    ret

; Iniciar el juego
iniciarJuego:
    imp mensajeInicio
    mov usados, 0

    ; Solicitar rango dinamico
    imp pedirRangoMin
    call leerNumero
    mov limiteInferior, ax

    imp pedirRangoMax
    call leerNumero
    mov limiteSuperior, ax

    ; Validar que el rango sea valido
    mov ax, limiteInferior
    cmp ax, limiteSuperior
    jl rangoValido
    imp errorRango
    jmp iniciarJuego

rangoValido:
    call generarNumeroAleatorio ; Generar numero secreto

jugar:
    imp pedirNumero
    call leerNumero
    mov numeroIngresado, ax
    inc usados

    ; Comparar numero ingresado con el numero secreto
    mov ax, numeroIngresado
    cmp ax, numeroSecreto
    je ganar
    
    ; Indicar si quedan intentos
    mov ax, intentosMax
    sub ax, usados
    imp intentosRestantes
    call print_num_uns

    ; Revisar si se agotaron los intentos
    mov ax, usados
    cmp ax, intentosMax
    jge perder

    ; Continuar el juego
    jmp jugar

; Gana el jugador
ganar:
    imp felicitacion
    call print_num_uns
    imp intentosMensaje
    ret

; Pierde el jugador
perder:
    imp perdiste
    mov ax, numeroSecreto
    call print_num_uns
    ret

DEFINE_PRINT_NUM_UNS
END
