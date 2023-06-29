# EMU OS

An operating system written from scratch to eventually run the Chip8 apps and later on the NES apps.

It uses only x86 assembly language, and currently runs in 16 bit real mode only. However, the `scratch` folder contains working code to jump to 32 bit protected mode, setting up the VESA bios extensions, and setting up and drawing font glyphs to the screen.

It comes bundled with the test suite roms from [here](https://www.github.com/Timendus/chip8-test-suite)

## Screenshots

- Home Screen

![Home Screen Screenshot](/imgs/home_page.png)

- Chip8 Logo

![Chip8 Logo Screenshot](/imgs/chip8_logo.png)

- IBM Logo

![IBM Logo Screenshot](/imgs/ibm_logo.png)

- Corax+ Opcode Test.

As you can see, one test is failing.

![Corax+ Screenshot](/imgs/corax_plus.png)

## User Input

The home screen is displayed on boot. Arrow keys from the keyboard can be used to change the current selection. Pressing `Enter` on the keyboard executes the selected application. Once inside the application pressing `Esc` will bring you back to the home screen.

## Build Info
### Requirements

This was developed in the Windows Subsystem for Linux 2 environment

The required packages can be installed with

```
sudo apt install nasm gcc make bochs bochs-x bochsbios vgabios 
```
You might also need to install `libalsasound2`, if bochs fails to start with `failed to find snd card`.

If testing with `qemu` is desired please install the `qemu-x86` package.


`VcXsrv` is required to display the GUI for the apps from WSL.
Avaiable from [Sourceforge](https://sourceforge.net/projects/vcxsrv/)

Using `bochs-sdl2` for the display only showed the graphics mode 'drawing' output but the initial teletype output would always be black. `bochs-x` displays all types of modes as expected.
Also the application startup time reduced greatly with bochs-x compared to bochs-sdl2.

### Making

`make` will 
- compile the assembly files in to freestanding binaries, using `nasm`.
- create a 15 MB blank file in the `build` folder.  
- copy the `boot` binary into the image.
- copy the rest of the files, e.g. kernel, and chip8 apps into the image.

`make clean` will
- delele everything from the `build` folder.

`make debug` will
- run the image through bochs emulator.

`make run` will
- run the image through the qmeu emulator.
