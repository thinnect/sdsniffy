# sdsniffy

Radio sniffer that prints packets out over serial. It has a packet queue and
and splits a print over several tasks to disrupt radio as little as possible and
give the other side a better chance to store the data as well. Works reasonably
well with OpenLog loggers for example. In that case the recommended baudrate
is 115200(which is also the default).

Compilation options:
* RADIO_CHANNEL ?= 26 (11...26)
* ENABLE_PA ?= 1 (use PA pins to control external amplifier)
