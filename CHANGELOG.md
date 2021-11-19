# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2021-11-19

### Added

- `exec` command to run `latexmk` directly.
- `clobber` command to delete both unessential files and artifacts.

### Changed

- `go` command renamed to `build`.
- `clean` command simply deletes unessential files (instead of everything).
- Configuration must be named `.mnogootexrc` (instead of `.mnogootex.yml`).

### Removed

- `mnogoo` shell integration no longer exists.
- `dir` and `pdf` commands no longer exist.

### Fixed

- Avoid deleting files before buils so viewers can reload.
- Caught nasty IO timing bug when polling `latexmk -pv` for logs.

## [1.1.0] - 2021-11-06

### Added

- New option `work_path` in configuration file to simplify access to build folders.

## [1.0.1] - 2018-09-03

### Fixed

- `mnogootex mnogoo` now produces correct path.

## [1.0.0] - 2018-04-24

### Added

- First public release.

[unreleased]: https://github.com/paolobrasolin/mnogootex/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/paolobrasolin/mnogootex/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/paolobrasolin/mnogootex/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/paolobrasolin/mnogootex/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/paolobrasolin/mnogootex/releases/tag/v1.0.0
