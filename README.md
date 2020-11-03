# Impulse-Radio-Time-Hopping-Transceiver
The code emulates the entire framework of Impulse Radio Time Hopping Ultra Wide Band Communication System. It contains the Transmitter and Receiver.

Various channel impairments are added seperately and collectively.

I've sampled the results of this system at various stages of the communication chain process and placed right beneath the code.

Results are finally stored in a structure called "STORE" for later use.

## Essential Modules
1. Signal Frame Generate:
   This module controls the choice of whether to add the channel distortion and also the amount of distortion for various distances
2. Interferer Frame Generate

Sample Outputs of the modules are re-produced below:
Signal Frame with frames re-transmitted for three times.
![Signal](Signal.jpg)

![Signal](Interferer.jpg)

![Signal](Combined_Signal.jpg)
