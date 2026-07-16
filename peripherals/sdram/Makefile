GHDL ?= ghdl
STD ?= 08
TOP ?= testbench_sdram
STOP ?= 4us

# Repo root and this Makefile's path within it, so the file works wherever copied.
REPO_ROOT := $(shell git -C $(CURDIR) rev-parse --show-toplevel)
DIR := $(patsubst $(REPO_ROOT)/%,%,$(CURDIR))
BUILD_DIR ?= $(DIR)/build
WAVE ?= $(BUILD_DIR)/wave.ghw

# Paths relative to repo root; analysis order matters (packages/DUT before users).
SRC = \
	$(DIR)/sdram_pkg.vhd \
	$(DIR)/sim/mti_pkg.vhd \
	$(DIR)/sim/mt48lc8m16a2.vhd \
	$(DIR)/sdram_controller.vhd \
	$(DIR)/testbench_sdram.vhd

GHDL_FLAGS = --std=$(STD) --workdir=$(BUILD_DIR) -frelaxed -fsynopsys

.PHONY: check analyze elaborate sim clean

check:
	@command -v $(firstword $(GHDL)) >/dev/null 2>&1 || { \
		echo "'$(firstword $(GHDL))' not found: set the GHDL variable or add it to PATH."; \
		exit 1; }

analyze: check
	@mkdir -p $(REPO_ROOT)/$(BUILD_DIR)
	cd $(REPO_ROOT) && $(GHDL) -a $(GHDL_FLAGS) $(SRC)

elaborate: analyze
	cd $(REPO_ROOT) && $(GHDL) -e $(GHDL_FLAGS) $(TOP)

sim: elaborate
	cd $(REPO_ROOT) && $(GHDL) -r $(GHDL_FLAGS) $(TOP) --wave=$(WAVE) --stop-time=$(STOP)
	@echo "Simulation done: $(BUILD_DIR)/$(notdir $(WAVE))"

clean:
	rm -rf $(REPO_ROOT)/$(BUILD_DIR)
	rm -f $(REPO_ROOT)/e~$(TOP).o $(REPO_ROOT)/$(TOP)
