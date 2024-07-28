COMMIT := $(shell git rev-parse --short HEAD)

IMAGE := nixos-thinkpad-t14s-gen6-$(COMMIT).img

TARGET := /dev/sdX

$(IMAGE).xz: $(IMAGE)
	xz -k $(IMAGE)

$(IMAGE):
	sudo ./scripts/make-image.sh $(IMAGE)

flash: $(IMAGE) $(TARGET)
	sudo dd if=$(IMAGE) of=$(TARGET)
	sudo parted -sf $(TARGET) p
