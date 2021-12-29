CROSS =
CC = $(addprefix $(CROSS),gcc)
AS = nasm
LD = $(addprefix $(CROSS),ld)
OBJCOPY = $(addprefix $(CROSS),objcopy)

ASMBFLAGS	= -f elf -w-orphan-labels
CFLAGS		= -Os -std=c99 -m32 -Wall -Wshadow -W -Wconversion -Wno-sign-conversion  -fno-stack-protector
CFLAGS 		+= -fomit-frame-pointer -fno-builtin -fno-common  -ffreestanding  -Wno-unused-parameter -Wunused-variable
LDFLAGS		= -s -static -T ToyOS.ld -n -Map ToyOS.map
OJCYFLAGS	= -S -O binary

INC = -I ./ -I include/

TOYOS_OBJS :=
TOYOS_OBJS += boot.o main.o vgastr.o
TOYOS_ELF = ToyOS.elf
TOYOS_BIN = ToyOS.bin
FLOPPY_IMG = disk.img


.PHONY: all clean check run
all: bootimg

# 制作启动镜像
bootimg: kernel
	/bin/bash ./scripts/mkfloppy.sh load $(FLOPPY_IMG) $(TOYOS_BIN) grub.cfg
	
# 创建启动磁盘，大小=count * bs，扇区大小=512B
floppy: $(FLOPPY_IMG)
$(FLOPPY_IMG): 
	dd if=/dev/zero of=$@ bs=512 count=65536
	/bin/bash ./scripts/mkfloppy.sh create $@

clean:
	rm *.o *.map
	rm $(TOYOS_ELF) $(TOYOS_BIN) 

run:
	qemu-system-i386 -m 1024 -drive format=raw,file=$(FLOPPY_IMG)

kernel: $(TOYOS_BIN)
$(TOYOS_BIN): $(TOYOS_ELF)
	$(OBJCOPY) $(OJCYFLAGS) $< $@

$(TOYOS_ELF): $(TOYOS_OBJS)
	$(LD) $(LDFLAGS) -o $@ $(TOYOS_OBJS)

%.o: %.asm
	$(AS) $(ASMBFLAGS) -o $@ $<

%.o : %.c
	$(CC) $(CFLAGS) $(INC) -c $< -o $@
