# Raspberry-Pi-2
Some cracker jack box code for Raspberry Pi 2

gpio_set_47.s  - sets PIN 47

gpio_clear_47.s - clears PIN 47

You can use the code to blink the 'ACT' LED with Bash like so:

<code>
$ while :; do sudo ./gpio_clear_47; sleep .5 ; sudo ./gpio_set_47 ; done
</code>

This is just a simple example of how to access GPIO from Raspian; which is not possible (or maybe extremely difficult) via Assembly from user space unless you map the GPIO base address to a file in virtual memory.  Otherwise, you can cut bait and just install raspi-gpio or you can access the led triggers, and what not, directly like so:

<code>
#!/bin/bash
what=$1
echo $what | sudo tee /sys/class/leds/led0/trigger && echo $what | sudo tee /sys/class/leds/led1/trigger
unset what
</code>

Next goal: do a baremetal version someday... 



