COMPONENT=SniffyC

MAKEFILE_LOCATION := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

PFLAGS +=-DTOSH_DATA_LENGTH=114

CFLAGS += -DSTART_PRINTF_DELAY=1024

PRINTF_BUFFER_SIZE=2048

RADIO_CHANNEL ?= 26

# 99(factory default) - JTAG+SPI, WDTON fuse disabled, bootloader size 4KB, normal startup
AVR_FUSE_H ?= 0x99
# FC - brownout at 2.0V
AVR_FUSE_E ?= 0xFD

CFLAGS += -I$(MAKEFILE_LOCATION)

USE_BLINKY ?= 1
ifeq ($(USE_BLINKY),1)
    CFLAGS += -DUSE_BLINKY
endif

ENABLE_PA ?= 0
ifneq ($(ENABLE_PA),0)
    $(info ENABLE_PA)
    CFLAGS += -DRFA1_ENABLE_PA
endif

BASE_LOG_LEVEL=0xFFFF
PLATFORM_BAUDRATE ?= 115200L

# Avoid strange TinyOS issues
CFLAGS += -DTASKLET_IS_TASK

$(info --------------------------------------------------------------------------------)
include $(TINYOS_ROOT_DIR)/Makefile.include
$(call TOSMake_include,extras/groundlib.extra)
$(call TOSMake_include,extras/watchdogs.extra)
$(info --------------------------------------------------------------------------------)

