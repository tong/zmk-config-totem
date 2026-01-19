BOARD ?= seeeduino_xiao_ble
SHIELD_LEFT ?= totem_left
SHIELD_RIGHT ?= totem_right

ZMK_CONFIG_PATH ?= $(shell pwd)
ZEPHYR_BASE ?= $(shell pwd)/zephyr
FLASH_DRIVE_PATH ?= /run/media/$(USER)/XIAO-SENSE

.PHONY: all clean setup install-left install-right $(SHIELD_LEFT) $(SHIELD_RIGHT)

all: build/$(SHIELD_LEFT)/zephyr/zmk.uf2 build/$(SHIELD_RIGHT)/zephyr/zmk.uf2

build/%/zephyr/zmk.uf2:
	. .env/bin/activate && \
	export ZEPHYR_BASE=$(ZEPHYR_BASE) && west build -s zmk/app -b $(BOARD) -d build/$* -- -DSHIELD=$* -DZMK_CONFIG=$(ZMK_CONFIG_PATH) -DZEPHYR_BASE=$(ZEPHYR_BASE) -DZephyr_DIR=$(ZEPHYR_BASE)/share/zephyr-package/cmake -DCONFIG_ZMK_STUDIO=y

install-left: build/$(SHIELD_LEFT)/zephyr/zmk.uf2
	cp $< $(FLASH_DRIVE_PATH)/

install-right: build/$(SHIELD_RIGHT)/zephyr/zmk.uf2
	cp $< $(FLASH_DRIVE_PATH)/

setup:
	test -d .env || python -m venv .env
	. .env/bin/activate && \
	python -m pip install --upgrade pip && \
	python -m pip install protobuf grpcio-tools west pyelftools && \
	(test -d .west || west init -l config/) && \
	west update

clean:
	rm -rf build
