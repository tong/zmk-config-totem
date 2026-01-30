BOARD ?= seeeduino_xiao_ble
SHIELD_LEFT ?= totem_left
SHIELD_RIGHT ?= totem_right

ZMK_CONFIG_PATH ?= $(shell pwd)
ZEPHYR_BASE ?= $(shell pwd)/zephyr
FLASH_DRIVE_PATH ?= /run/media/$(USER)/XIAO-SENSE

ZMK_STUDIO_FLAG_$(SHIELD_LEFT) = -DCONFIG_ZMK_STUDIO=y
ZMK_STUDIO_FLAG_$(SHIELD_RIGHT) = 
ZMK_STUDIO_FLAG_settings_reset = 

.PHONY: all clean setup install-left install-right install-settings-reset $(SHIELD_LEFT) $(SHIELD_RIGHT) settings_reset

all: build/$(SHIELD_LEFT)/zephyr/zmk.uf2 build/$(SHIELD_RIGHT)/zephyr/zmk.uf2

build/%/zephyr/zmk.uf2:
	. .env/bin/activate && \
	export ZEPHYR_BASE=$(ZEPHYR_BASE) && west build -s zmk/app -b $(BOARD) -d build/$* -- -DSHIELD=$* -DZMK_CONFIG=$(ZMK_CONFIG_PATH) -DZEPHYR_BASE=$(ZEPHYR_BASE) -DZephyr_DIR=$(ZEPHYR_BASE)/share/zephyr-package/cmake $(ZMK_STUDIO_FLAG_$*)

$(SHIELD_LEFT): build/$(SHIELD_LEFT)/zephyr/zmk.uf2
$(SHIELD_RIGHT): build/$(SHIELD_RIGHT)/zephyr/zmk.uf2
settings_reset: build/settings_reset/zephyr/zmk.uf2

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
