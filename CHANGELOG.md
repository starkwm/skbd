# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Added `ShortcutManager` for managing shortcuts

### Removed

- Removed `starkwm/alicia` dependency

### Changed

- Updated `apple/swift-argument-parser` dependency

## [0.0.4] - 2024-07-19

### Removed

- Removed the passing of environment variables to the started processes

## [0.0.3] - 2024-06-15

### Changed

- Updated `starkwm/alicia` dependency
- Updated `apple/swift-argument-parser` dependency
- Updated to set the environment of the process to the same environment as the running `skbd` instance.

## [0.0.2] - 2024-02-29

### Changed

- Updated the minimum required macOS version to 13

## [0.0.1] - 2023-03-15

### Added

- Added the initial release, with feature parity to the old `skbd`
