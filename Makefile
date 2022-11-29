
NDK_IMAGE := different/alpine-android-ndk:r25b
IMAGE_EXISTS := $(shell docker images -q ${NDK_IMAGE})
BUILD_DIR := ./build

build: deps
	mkdir -p build
	docker run --rm --mount source=$(PWD),destination=/source,type=bind \
  --workdir=/source ${NDK_IMAGE} ndk-build -e NDK_PROJECT_PATH=. -e \
	APP_BUILD_SCRIPT=Android.mk -e NDK_APP_DST_DIR=${BUILD_DIR} NDK_APP_OUT=${BUILD_DIR} \
	APP_PLATFORM=android-28 APP_ABI="armeabi-v7a arm64-v8a" APP_STL=none

deps:
ifeq ($(IMAGE_EXISTS),)
	$(info pulling docker build image)
	docker pull ${NDK_IMAGE}
endif

all: clean format deps build

format:
	find . -not -name libusb.h -regex '.*\.\(c\|h\)'  -exec clang-format -style=file -i {} \;

.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}