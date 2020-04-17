# <h.zeller@acm.org>
DEFINES=-DF_CPU=8000000UL

TARGET_ARCH=-mmcu=attiny2313
CC=avr-gcc
CFLAGS=-Os -g -W -Wall -Wextra -ffunction-sections -fdata-sections -mcall-prologues $(DEFINES) -I.
CXX=avr-g++
CXXFLAGS=$(CFLAGS) -std=c++11
AVRDUDE_DEVICE ?= /dev/ttyUSB0
AVRDUDE     = avrdude -p t2313 -c stk500v2 -P $(AVRDUDE_DEVICE)
FLASH_CMD   = $(AVRDUDE) -e -U flash:w:main.hex
LINK=avr-g++ -g $(TARGET_ARCH) -Wl,-gc-sections
OBJECTS=main.o

all : main.hex

main.elf: $(OBJECTS)
	$(LINK) -o $@ $(OBJECTS)
	avr-size $@

disasm: main.elf
	avr-objdump -C -S main.elf

main.hex: main.elf
	avr-objcopy -j .text -j .data -O ihex main.elf main.hex

flash: main.hex
	$(FLASH_CMD)

clean:
	rm -f $(OBJECTS) main.elf main.hex

# Make sure to recompile everything if cflags change.
compiler-flags: FORCE
	@echo '$(CXX) $(CXXFLAGS)' | cmp -s - $@ || echo '$(CXX) $(CXXFLAGS)' > $@

%.o : %.c compiler-flags
	$(CC) $(TARGET_ARCH) $(CFLAGS) -c -o $@ $<

%.o : %.cc compiler-flags
	$(CXX) $(TARGET_ARCH) $(CXXFLAGS) -c -o $@ $<

# Internal 8Mhz, no clock division
fuse:
	$(AVRDUDE) -U lfuse:w:0xe4:m -U hfuse:w:0x9f:m

.PHONY: FORCE
