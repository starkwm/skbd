VERSION_TMPL=Sources/skbd/Version.swift.tmpl
VERSION_FILE=Sources/skbd/Version.swift

all: build

format:
	@swift-format format --in-place --recursive --parallel Sources Tests Package.swift

lint:
	@swift-format lint --recursive Sources Tests Package.swift

test:
	@swift test -q --parallel --enable-code-coverage

coverage:
	$(eval BIN_PATH := $(shell swift build --show-bin-path))
	$(eval XCTEST_PATH := $(shell find $(BIN_PATH) -name '*.xctest'))
	$(eval BASE_NAME := $(shell basename $(XCTEST_PATH) .xctest))
	@xcrun llvm-cov report \
		$(XCTEST_PATH)/Contents/MacOS/$(BASE_NAME) \
		--instr-profile=.build/debug/codecov/default.profdata \
		--ignore-filename-regex=".build|Tests" \
		--use-color

clean:
	@swift package clean

build:
	@swift build

release: clean
	@swift build --configuration release --disable-sandbox

bump_version:
ifneq ($(strip $(shell git status --untracked-files=no --porcelain 2>/dev/null)),)
	$(error git state is not clean)
endif
	@sed 's/__VERSION__/$(NEW_VERSION)/g' $(VERSION_TMPL) > $(VERSION_FILE)
	git add $(VERSION_FILE)
	git commit -m "Release $(NEW_VERSION)"
	git tag $(NEW_VERSION)
	git push origin HEAD
	git push origin $(NEW_VERSION)

.DEFAULT_GOAL := build
.PHONY: all format lint test coverage clean build release bump_version
