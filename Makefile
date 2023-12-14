.SILENT:
.PHONY: build run

PRODUCT_NAME := NowPlaying

run: build
	open build/Debug/${PRODUCT_NAME}.app

# setup:
# 	mint bootstrap
# 	$(MAKE) xcproj

# xcproj:
# 	mint run xcodegen xcodegen generate --use-cache --quiet

build: # xcproj
	xcrun xcodebuild -configuration Debug build | xcpretty
