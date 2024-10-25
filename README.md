# p12mqtt
A Tasmota Berry program to publish the energy parameters obtained via the P1 port of the utility meter to MQTT


This is a small program that reads the output of the P1 port of the utility meter (DSMTR 5.0 standard) and publishes selected values on the local area net.

Which elements should be mapped to which prameters in the JSON published via MQTT is determined by the mapping in the codes variable. The example uses this mapping:
```json
{"1-0:1.8.1":"enrg_imp_t1","1-0:1.8.2":"enrg_imp_t2","1-0:2.8.1":"enrg_exp_t1","1-0:2.8.2":"enrg_exp_t2","0-0:96.14.0":"tariff","1-0:1.7.0":"pwr_imp","1-0:2.7.0":"pwr_exp","1-0:32.7.0":"volts_l1","1-0:52.7.0":"volts_l2","1-0:72.7.0":"volts_l3","1-0:31.7.0":"amps_l1","1-0:51.7.0":"amps_l2","1-0:71.7.0":"amps_l3","1-0:21.7.0":"l1_pwr_imp","1-0:41.7.0":"l2_pwr_imp","1-0:61.7.0":"l3_pwr_imp","1-0:22.7.0":"l1_pwr_exp","1-0:42.7.0":"l2_pwr_exp","1-0:62.7.0":"l3_pwr_exp"}
```
The smart meter is connected to the ESP like this:
![image](https://github.com/user-attachments/assets/311d01e6-4341-4189-ad29-db6fb3885679)
The P1 port is activated after boot by a 3.3V signal from GPIO 6 to the RTS pin of the P1 port. This can be done by a rule on system#boot after initialisation of the serial port of the esp (as in my case) but also could also be done by the init function of the program.

If you use the Lolin C3 mini Version 2 with the WS2812 on GPIO7 you can also get a quick indication of power used (red) or produced (green) with the brightness a measure of the amount of power.

