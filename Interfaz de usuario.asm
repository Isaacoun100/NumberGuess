
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; Juego interactivo: Reto del Numero Secreto
; Codigo actualizado para corregir errores de parametros y garantizar funcionalidad completa

include "emu8086.inc"
.MODEL SMALL

.DATA
    mensajeInicio DB "Reto del Numero Secreto!$"
    pedirRangoMin DB "Ingrese el limite inferior del rango:$"
    pedirRangoMax DB "Ingrese el limite superior del rango:$"
    pedirSimbolo DB "Elija un simbolo para mostrar intentos restantes:$"
    pedirNumero DB "Intenta adivinar el numero secreto:$"
    mayor DB "\x18 El numero secreto es mayor que tu intento!$"
    menor DB "\x19 El numero secreto es menor que tu intento!$"
    pista DB "Pista: La diferencia entre tu intento y el numero secreto es: $"
    correcto DB "? Correcto! Adivinaste el numero secreto!$"
    felicidades DB "Felicidades! Adivinaste el numero en $"
    intentos DB " intentos!$"
    derrota DB "Lo siento, has perdido! El numero era: $"
    menu DB "Menu: (1) Reiniciar | (2) Salir$"
    opcionInvalida DB "Opcion invalida! Intenta de nuevo.$"
    intentosRestantes DB "Intentos restantes: $"
    simboloIntentos DB "?"

    numeroSecreto DW 0
    numeroIngresado DW 0
    limiteInferior DW 0
    limiteSuperior DW 0
    intentosMax DW 5
    intentosUsados DW 0
    diferencia DW 0

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

; Imprimir intentos restantes visualmente
imprimirIntentos macro
    mov ax, intentosMax
    sub ax, intentosUsados
    mov cx, ax
mostrarSimbolos:
    cmp cx, 0
    je finIntentos
    mov dl, simboloIntentos
    mov ah, 02h
    int 21h
    loop mostrarSimbolos
finIntentos:
    ret
endm

; Iniciar el juego
iniciarJuego:
    imp mensajeInicio
    mov intentosUsados, 0

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
    imp opcionInvalida
    jmp iniciarJuego

rangoValido:
    imp pedirSimbolo
    call leerSimbolo
    call generarNumeroAleatorio ; Generar numero secreto

jugar:
    imp pedirNumero
    call leerNumero
    inc intentosUsados

    ; Comparar numero ingresado con el numero secreto
    mov ax, numeroIngresado
    mov bx, numeroSecreto
    cmp ax, bx
    je ganar

    ; Calcular la diferencia para la pista
    mov ax, numeroIngresado
    sub ax, numeroSecreto
    jns diferenciaPositiva
    neg ax

    diferenciaPositiva:
    mov diferencia, ax
    imp pista
    call print_num_uns

    ; Continuar con las pistas de mayor o menor
    cmp ax, numeroSecreto
    ja mayorQue
    jb menorQue

mayorQue:
    imp mayor
    jmp siguienteIntento

menorQue:
    imp menor
    jmp siguienteIntento

siguienteIntento:
    imp intentosRestantes
    imprimirIntentos
    mov ax, intentosMax
    cmp intentosUsados, ax
    jl jugar
    jmp perder

ganar:
    imp correcto
    imp felicidades
    call print_num_uns
    imp intentos
    jmp mostrarMenu

perder:
    imp derrota
    mov ax, numeroSecreto
    call print_num_uns
    jmp mostrarMenu

mostrarMenu:
    imp menu
    call leerNumero
    cmp ax, 1
    je iniciarJuego
    cmp ax, 2
    je salir
    imp opcionInvalida
    jmp mostrarMenu

salir:
    mov ah, 4ch
    int 21h

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

; Leer un simbolo del teclado
leerSimbolo:
    mov ah, 1       ; Leer un caracter
    int 21h
    mov simboloIntentos, al
    ret

DEFINE_PRINT_NUM_UNS
END

ret




