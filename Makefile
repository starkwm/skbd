TEST_ARGS ?=

build:
	@swift build

release: clean
	@swift build --configuration release --disable-sandbox

format:
	@swift format -i -r -p Sources Tests Package.swift

lint:
	@swift format lint --strict -r -p Sources Tests Package.swift

test:
	@swift test --parallel --disable-xctest $(TEST_ARGS)

clean:
	@swift package clean

.DEFAULT_GOAL := build
.PHONY: build release format lint test clean
