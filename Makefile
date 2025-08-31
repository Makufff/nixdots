# Defaults tuned for this repo
FLAKE_HOST ?= desktop
USER       ?= makufff
HOST_DIR   ?= hosts/$(USER)

DEVICE     ?= /dev/nvme0n1

NIX_FLAGS   ?= --extra-experimental-features 'nix-command flakes'
NIXOS_FLAGS ?= -j 4 --cores 6
HOME_FLAGS  ?= -j 4 --cores 6

# Escape '#' so Make doesn't treat it as a comment
FLAKE      ?= .\#$(FLAKE_HOST)
FLAKE_HM   ?= .\#$(USER)

all: switch

lock: flake.lock

flake.lock:
	nix $(NIX_FLAGS) flake lock

update: flake.lock
	nix $(NIX_FLAGS) flake update

check:
	nix $(NIX_FLAGS) flake check

fmt:
	nix fmt

build:
	sudo nixos-rebuild $(NIXOS_FLAGS) build --flake $(FLAKE)

test:
	sudo nixos-rebuild $(NIXOS_FLAGS) test --flake $(FLAKE)

switch:
	sudo nixos-rebuild $(NIXOS_FLAGS) switch --flake $(FLAKE)

upgrade: update
	sudo nixos-rebuild $(NIXOS_FLAGS) switch --upgrade --flake $(FLAKE)

rescue:
	sudo nixos-rebuild --option sandbox false $(NIXOS_FLAGS) boot --install-bootloader --flake $(FLAKE)

boot:
	sudo nixos-rebuild $(NIXOS_FLAGS) boot --install-bootloader --flake $(FLAKE)

# Home Manager (note: Home Manager is also managed via NixOS in this repo)
home:
	home-manager $(HOME_FLAGS) --flake $(FLAKE_HM) switch -b backup

# Disko: partition/format/mount according to disks/default.nix
disko:
	nix $(NIX_FLAGS) run github:nix-community/disko -- --mode disko ./disks/default.nix --argstr device $(DEVICE)

# Generate and write a fresh hardware-configuration.nix for the current system
gen-hw:
	nixos-generate-config --show-hardware-config > $(HOST_DIR)/hardware-configuration.nix

# Secure Boot helper (lanzaboote)
sbctl-keys:
	sudo sbctl create-keys && sudo sbctl enroll-keys

.PHONY: all lock update check fmt build test switch upgrade rescue boot home disko gen-hw sbctl-keys
