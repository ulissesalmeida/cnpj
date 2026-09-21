# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- `CNPJ` now holds its digits internally as a string instead of a tuple of
  integers. The struct is opaque, so `digits/1`, `format/1`, `parse/1`,
  `parse!/1` and `valid?/1` keep their current contracts.

### Fixed

- `CNPJ.format/1` raising `ArgumentError` for CNPJs with leading zeros
- `CNPJ.parse/1`, `CNPJ.parse!/1` and `CNPJ.valid?/1` raising
  `FunctionClauseError` for negative integers. They now return
  `:invalid_format` and `false`.

## [0.2.0] - 2020-05-11

### Added

- `CNPJ.format`
- `CNPJ.parse!`
- `CNPJ.parse`
- `CNPJ.digits`
- `CNPJ.valid?` for string numbers
- `CNPJ.valid?` for formatted numbers

## [0.1.0]

### Added

- `CNPJ.valid?` for integers
