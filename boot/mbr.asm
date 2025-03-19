;主引导程序
;---------------------------------------
%include "boot.inc"
section MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800      ;显卡的内存位置
    mov gs, ax

;首先需要清屏，清屏利用0x06号子功能，上卷全部行，实现清屏
;中断10h，功能号：0x06  功能：上卷窗口
;ah=0x06
;al=0 表示上卷行数，0表示全部 所以ax就是0x600
;bh = 上卷行属性
;cl,ch  表示左上角的x,y
;dh,dl  表示右下角的x,y
;无返回值

    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0               ;左上角0，0
    mov dx, 0x184f          ;右下角 （80, 25）

    int 0x10                ;10号中断

;输出字符串MBR
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4    ;绿色背景闪烁，前景色为红色

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4    ;绿色背景闪烁，前景色为红色

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4    ;绿色背景闪烁，前景色为红色

    mov byte [gs:0x06], 'B'
    mov byte [gs:0x07], 0xA4    ;绿色背景闪烁，前景色为红色

    mov byte [gs:0x08], 'R'
    mov byte [gs:0x09], 0xA4    ;绿色背景闪烁，前景色为红色

    mov eax, LOADER_START_SECTOR        ;起始扇区的逻辑地址LBA
    mov bx, LOADER_BASE_ADDR            ;写入地址
    mov cx, 4                           ;等待读入的扇区数
    call rd_disk_m_16

    jmp LOADER_BASE_ADDR + 0x300

    ;-----------------------------------------------------------------
    ;功能：读取硬盘n个扇区
rd_disk_m_16:
    ;-----------------------------------------------------------------

                                                ;eax = LBA扇区号
                                                ;bx = 将数据写入的内存地址
                                                ;cx = 读入的扇区数
    mov esi, eax        ;备份
    mov di, cx          ;备份

;读写硬盘：
;第一步：设置要读的扇区数
    mov dx, 0x1f2
    mov al, cl
    out dx, al          ;要读取的扇区数，在cl中获得

    mov eax, esi        ;恢复eax

;将LBA地址也就是逻辑扇地址存入0x1f3 - 0x1f6 端口
;一个端口放一个byte 字节
    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl             ;将eax右移8位
    mov dx, 0x1f4           
    out dx, al

    shr eax, cl             ;将eax右移8位
    mov dx, 0x1f5           
    out dx, al

    shr eax, cl             ;将eax右移8位
    and al, 0x0f
    or al, 0xe0             ;设置7-4位是1110， 表示lba模式
    mov dx, 0x1f6           
    out dx, al

;向0x1f7端口写入读命令，0x20
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

;检测硬盘状态
.not_ready:
    nop
    in al, dx
    and al, 0x88            ;第三位为1表示硬盘控制器已经准备好数据传输
                            ;第七位为1表示硬盘忙
    cmp al, 0x08
    jnz .not_ready          ;没有准备好，继续循环等待

;从0x1f0端口读取数据
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
;di为要读入的扇区数，一个扇区有512个字节，每次读入一个字，所以需要di*256次
    mov dx, 0x1f0
.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

    times 510-($-$$) db 0
    db 0x55, 0xaa


