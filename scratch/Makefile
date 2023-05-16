img: print_reg.bin
	dd if=/dev/zero of=print_reg.img count=2880
	dd if=print_reg.bin of=print_reg.img conv=notrunc

print_reg.bin:
	nasm print_reg.asm -f bin -O3 -o print_reg.bin

run:
	qemu-system-i386 -fda print_reg.img

clean: 
	rm -f *.bin *.img