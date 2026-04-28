.code16             # Arrancamos en 16 bits (Modo Real)
.global _start

_start:
    # 1. Deshabilitar interrupciones
    cli             

    # 2. Cargar el registro GDTR con la dirección y tamaño de nuestra GDT
    lgdt gdt_descriptor

    # 3. Fijar el bit más bajo del CR0 (PE - Protection Enable) en 1
    movl %cr0, %eax
    orl $0x1, %eax
    movl %eax, %cr0

    # 4. Salto largo (Far Jump) para limpiar el pipeline y cargar CS
    # El 0x08 es el offset en la GDT para nuestro segmento de código
    ljmp $0x08, $protected_mode

.code32             # A partir de acá, el procesador está en 32 bits
protected_mode:
    # 5. Configurar el resto de los registros de segmento con el selector de datos
    movw $0x10, %ax
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs
    movw %ax, %ss

    # --- PRUEBA DE ESCRITURA ILEGAL ---
    movl $0x00000000, %ebx
    movb $0xAA, (%ebx)      # ¡Esto va a causar el Triple Fault!

    # Bucle infinito para no crashear
    jmp .

# ---------------------------------------------------------
# DEFINICIÓN DE LA GDT
# ---------------------------------------------------------
.align 8
gdt_start:
    # 1. Descriptor Nulo (obligatorio, 8 bytes de ceros)
    .quad 0x0000000000000000

    # 2. Descriptor de Código (Selector 0x08)
    # Base: 0x00000000, Límite: 0xFFFFF, Granularidad: 4KB, Ejecución/Lectura
    .word 0xFFFF        # Limit 0:15
    .word 0x0000        # Base 0:15
    .byte 0x00          # Base 16:23
    .byte 0b10011010    # Presente, Privilegio 0 (Ring 0), Tipo: Código Ejecución/Lectura
    .byte 0b11001111    # Granularidad (4KB), Tamaño 32-bit, Limit 16:19
    .byte 0x00          # Base 24:31

    # 3. Descriptor de Datos DIFERENCIADO (Selector 0x10)
    # Base: 0x00010000, Límite: 0xFFFFF, Granularidad: 4KB, Lectura/Escritura
    .word 0xFFFF        # Limit 0:15
    .word 0x0000        # Base 0:15 (Ojo acá, sumado al byte siguiente arman la base)
    .byte 0x01          # Base 16:23 -> BASE TOTAL: 0x00010000
    .byte 0b10010000    # Presente, Privilegio 0 (Ring 0), Tipo: Datos SOLO LECTURA
    .byte 0b11001111    # Granularidad (4KB), Tamaño 32-bit, Limit 16:19
    .byte 0x00          # Base 24:31
gdt_end:

gdt_descriptor:
    .word gdt_end - gdt_start - 1   # Tamaño de la GDT
    .long gdt_start                 # Dirección base de la GDT
