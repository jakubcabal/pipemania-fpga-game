# Pipe Mania for FPGA

Pipe Mania for FPGA is a simple game programmed in VHDL, which was created as a study project at VUT Brno in 2014.
Now the game was released under the MIT license and will gradually be optimized for cheap FPGA board [EP4CE6 Starter Board](http://www.ebay.com/itm/111975895262) with Altera FPGA Cyclone IV EP4CE6E22C8 for $45.

![Start Screen](docs/start_screen.JPG?raw=true)

# Table of resource usage summary:

LE (LUT+FF) | LUT | FF | Memory bits | Fmax
:---:|:---:|:---:|:---:|:---:
 1262 | 1165 | 530 | 60988 | 62.2 MHz

*Synthesis was performed using Quartus Prime Lite Version 16.0 for device EP4CE6E22C8 with enable force use of synchronous clear.*
