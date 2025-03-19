;����������
;---------------------------------------
%include "boot.inc"
section MBR vstart=0x7c00
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00
    mov ax, 0xb800      ;�Կ����ڴ�λ��
    mov gs, ax

;������Ҫ��������������0x06���ӹ��ܣ��Ͼ�ȫ���У�ʵ������
;�ж�10h�����ܺţ�0x06  ���ܣ��Ͼ���
;ah=0x06
;al=0 ��ʾ�Ͼ�������0��ʾȫ�� ����ax����0x600
;bh = �Ͼ�������
;cl,ch  ��ʾ���Ͻǵ�x,y
;dh,dl  ��ʾ���½ǵ�x,y
;�޷���ֵ

    mov ax, 0x600
    mov bx, 0x700
    mov cx, 0               ;���Ͻ�0��0
    mov dx, 0x184f          ;���½� ��80, 25��

    int 0x10                ;10���ж�

;����ַ���MBR
    mov byte [gs:0x00], '1'
    mov byte [gs:0x01], 0xA4    ;��ɫ������˸��ǰ��ɫΪ��ɫ

    mov byte [gs:0x02], ' '
    mov byte [gs:0x03], 0xA4    ;��ɫ������˸��ǰ��ɫΪ��ɫ

    mov byte [gs:0x04], 'M'
    mov byte [gs:0x05], 0xA4    ;��ɫ������˸��ǰ��ɫΪ��ɫ

    mov byte [gs:0x06], 'B'
    mov byte [gs:0x07], 0xA4    ;��ɫ������˸��ǰ��ɫΪ��ɫ

    mov byte [gs:0x08], 'R'
    mov byte [gs:0x09], 0xA4    ;��ɫ������˸��ǰ��ɫΪ��ɫ

    mov eax, LOADER_START_SECTOR        ;��ʼ�������߼���ַLBA
    mov bx, LOADER_BASE_ADDR            ;д���ַ
    mov cx, 4                           ;�ȴ������������
    call rd_disk_m_16

    jmp LOADER_BASE_ADDR + 0x300

    ;-----------------------------------------------------------------
    ;���ܣ���ȡӲ��n������
rd_disk_m_16:
    ;-----------------------------------------------------------------

                                                ;eax = LBA������
                                                ;bx = ������д����ڴ��ַ
                                                ;cx = �����������
    mov esi, eax        ;����
    mov di, cx          ;����

;��дӲ�̣�
;��һ��������Ҫ����������
    mov dx, 0x1f2
    mov al, cl
    out dx, al          ;Ҫ��ȡ������������cl�л��

    mov eax, esi        ;�ָ�eax

;��LBA��ַҲ�����߼��ȵ�ַ����0x1f3 - 0x1f6 �˿�
;һ���˿ڷ�һ��byte �ֽ�
    mov dx, 0x1f3
    out dx, al

    mov cl, 8
    shr eax, cl             ;��eax����8λ
    mov dx, 0x1f4           
    out dx, al

    shr eax, cl             ;��eax����8λ
    mov dx, 0x1f5           
    out dx, al

    shr eax, cl             ;��eax����8λ
    and al, 0x0f
    or al, 0xe0             ;����7-4λ��1110�� ��ʾlbaģʽ
    mov dx, 0x1f6           
    out dx, al

;��0x1f7�˿�д������0x20
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

;���Ӳ��״̬
.not_ready:
    nop
    in al, dx
    and al, 0x88            ;����λΪ1��ʾӲ�̿������Ѿ�׼�������ݴ���
                            ;����λΪ1��ʾӲ��æ
    cmp al, 0x08
    jnz .not_ready          ;û��׼���ã�����ѭ���ȴ�

;��0x1f0�˿ڶ�ȡ����
    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
;diΪҪ�������������һ��������512���ֽڣ�ÿ�ζ���һ���֣�������Ҫdi*256��
    mov dx, 0x1f0
.go_on_read:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .go_on_read
    ret

    times 510-($-$$) db 0
    db 0x55, 0xaa


