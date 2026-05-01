[BITS 16]           ; Le decimos al ensamblador que empezamos en 16 bits
[ORG 0x7C00]        ; Dirección de memoria donde la BIOS carga este código
arranque:
    ; PASO 1: Desactivar interrupciones
    cli                     
    ; PASO 2: Cargar la GDT
    lgdt [gdt_descriptor]   
    ; PASO 3: Cambiar el bit PE en CR0
    mov eax, cr0            ; Copiamos el contenido de CR0 a EAX
    or eax, 0x1             ; Cambiamos el primer bit a 1 (Protection Enable)
    mov cr0, eax            ; Lo volvemos a guardar en CR0


    ; PASO 4: Salto largo (Far Jump) para limpiar el procesador
    ; 0x08 es nuestro selector de código en la GDT
    jmp 0x08:modo_protegido 
; ---------------------------------------------------------
; AQUÍ EMPIEZA EL MODO PROTEGIDO (32 BITS)
; ---------------------------------------------------------
[BITS 32]
modo_protegido:
    ; PASO 5: Actualizar los registros de segmento
    ; 0x10 es nuestro selector de datos en la GDT
    mov ax, 0x10            
    mov ds, ax              ; Segmento de datos
    mov ss, ax              ; Segmento de pila (Stack)
    mov es, ax              ; Segmento extra
    mov fs, ax
    mov gs, ax

    ; (Opcional) Escribir una 'X' verde en la pantalla para comprobar que funcionó
    mov byte [0xB8000], 'X' ; Carácter 'X'
    mov byte [0xB8001], 0x0A ; Color Verde

; INTENTO DE ESCRITURA ILEGAL
    mov byte [0x500], 0x41  ; Intentamos escribir la letra 'A' en la dirección 0x500
    ; Bucle infinito para que no se apague
    jmp $                   
; =========================================================
; ESTRUCTURA DE LA GDT (Definida a mano, sin macros)
; =========================================================
gdt_inicio:
gdt_nula:                   ; Descriptor 0: Siempre debe ser nulo (Obligatorio)
    dd 0x0
    dd 0x0
gdt_codigo:                 ; Descriptor 1: Segmento de Código (Selector = 0x08)
    dw 0xFFFF               ; Límite (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10010000b             ; Byte de Acceso: Presente, Ring 0, Código, Ejecutable, Lectura
    db 11001111b            ; Granularidad (4KB) y Límite (bits 16-19)
    db 0x0                  ; Base (bits 24-31)
gdt_datos:                  ; Descriptor 2: Segmento de Datos (Selector = 0x10)
    dw 0xFFFF               ; Límite (bits 0-15)
    dw 0x0                  ; Base (bits 0-15)
    db 0x0                  ; Base (bits 16-23)
    db 10010010b            ; Byte de Acceso: Presente, Ring 0, Datos, Lectura/Escritura
    db 11001111b            ; Granularidad (4KB) y Límite (bits 16-19)
    db 0x0                  ; Base (bits 24-31)
gdt_fin:
; El puntero que necesita la instrucción 'lgdt'
gdt_descriptor:
    dw gdt_fin - gdt_inicio - 1  ; Tamaño de la tabla (Límite)
    dd gdt_inicio                ; Dirección donde empieza la tabla

; Relleno para que sea un sector de arranque válido (512 bytes)
times 510-($-$$) db 0
