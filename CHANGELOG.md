# Changelog

All changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [1.1.0] - 2026-05-23

### Added

- Function arguments for `start_random()`
  - If none are provided, the timer will start a timer between **Min Wait Time** and **Max Wait Time**
- Rounded randomness
  - Three options available: Floor, Round, Ceil
    - Control the direction of the rounding
  - Clamped rounding
    - Prevent the rounded number to go out of bounds of the defined **Min Wait Time** and **Max Wait Time**
  - Step
    - Level of Steps the rounding should do

Note that **Wait Time** and **Step** will never go below `0.001`

### Changed

- `start_random()` will no longer do an early return when **Random Timer** is set to **false**
- Screenshot of the inspector window

### Fixed

- Alt text of the icon in the README.md

## [1.0.0] - 2026-05-23

### Added

- This file