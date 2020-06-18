    ;16-битная адресация, пока мы находимся в реальном режиме
    use16
    org 0x7c00
    start:
      jmp 0x0000:entry              ;теперь CS=0, IP=0x7c00
    entry:
      mov ax, cs
      mov ds, ax
     
    ;очистить экран
      mov ax, 0x0003
      int 0x10
     
    ;открыть A20
      in  al, 0x92
      or  al, 2
      out 0x92, al
     
    ;Загрузить адрес и размер GDT в GDTR
      lgdt  [gdtr]
    ;Запретить прерывания
      cli
    ;Запретить немаскируемые прерывания
      in  al, 0x70
      or  al, 0x80
      out 0x70, al
     
    ;Переключиться в защищенный режим
      mov  eax, cr0
      or   al, 1
      mov  cr0, eax
     
    ;Загрузить в CS:EIP точку входа в защищенный режим
      O32 jmp 00001000b:pm_entry
     
    ;32-битная адресация
    use32
    ;Точка входа в защищенный режим
    pm_entry:
    ;Загрузить сегментные регистры (кроме SS)
      mov  ax, cs
      mov  ds, ax
      mov  es, ax
     
      mov  edi, 0xB8000             ;начало видеопамяти в видеорежиме 0x3
      mov  esi, msg                 ;выводимое сообщение
      cld
    .loop                           ;цикл вывода сообщения
      lodsb                         ;считываем очередной символ строки
      test al, al                   ;если встретили 0
      jz   .exit                    ;прекращаем вывод
      stosb                         ;иначе выводим очередной символ
      mov  al, 7                    ;и его атрибут в видеопамять
      stosb
      jmp  .loop
    .exit
     
      jmp  $                        ;зависаем
     
    msg:
      db  'Hello World!', 0
     
    ;Глобальная таблица дескрипторов.
    ;Нулевой дескриптор использовать нельзя!
    gdt:
      db  0x00, 0x00, 0x00, 0x00, 0x00,      0x00,      0x00, 0x00 
      db  0xFF, 0xFF, 0x00, 0x00, 0x00, 10011010b, 11001111b, 0x00
    gdt_size  equ $ - gdt
     
    ;данные, загружаемые в регистр GDTR
    gdtr:
      dw  gdt_size - 1
      dd  gdt
     
    finish:
    times 0x1FE-finish+start db 0
    db   0x55, 0xAA ; сигнатура загрузочного сектора
