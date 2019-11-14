# Introduction

The Flappy Bird implemented on FPGA. (A course design of "Digital Logic Design" in Zhejiang University.)

# Development Environment
### Experiment Platform

- Family: Kintex7
- Device: XC7K160T
- Package: FFG676
### Development environment
- Xilinx ISE 14.7
### HDL
- Verilog

# Requiremnet of the project

This game needs two hardware parts to play, that are a development board as shown in section 2.1 and a monitor with VGA.
**Input**
SW [15:0]: the sixteen switches on the board 
BTN_X[4:0] BTN_Y[3:0]: the button matrix on the right of the board
**Output**
Monitor: to display the game screen.
7-segment digital: to show how many columns you have passed.


# Display
![avatar](/img/demo.gif)