APP_NAME := vroom
SRC_DIR  := src
BUILD_DIR := build

ODIN := odin
COMMON_FLAGS := -vet

.PHONY: all debug release run clean

all: debug

debug:
	@mkdir -p $(BUILD_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BUILD_DIR)/$(APP_NAME)-debug -debug $(COMMON_FLAGS)

release:
	@mkdir -p $(BUILD_DIR)
	$(ODIN) build $(SRC_DIR) -out:$(BUILD_DIR)/$(APP_NAME) -o:speed $(COMMON_FLAGS)

run: debug
	./$(BUILD_DIR)/$(APP_NAME)-debug

clean:
	rm -rf $(BUILD_DIR)
