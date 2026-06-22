# Changelog

All changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-06-22

## Added

- A signal to inform how long the randomized timer lasts until timeout is emitted.

## Changed

- Variables to be more simple to type out
- Timer seed to allow negative values
- step_size to be set to any value
- Documentation comments. Prodiding examples and fixing broken links.

## [2.0.0] - 2026-05-23

## Added

- Grouped Properties, making it easier to tell what belongs together.

## Changed

- `start_random()` now calling `start()` with the `super` keyword.
- Randomized timers now being rounded up to 3 decimal places.

## Fixed

- `start_random()` by reusing the arguments given during its initial call

## Deprecated

- `start()` due to limitations, if you want to use this class as a normal timer,
set **Min Wait Time** and **Max Wait Time** to the same values.

## Removed

- **Random Timer** due to deprecating `start()`.

## [1.1.0] - 2026-05-23

### Added

- Function arguments for `start_random()`.
  - If none are provided, the timer will start a timer between **Min Wait Time** and **Max Wait Time**.
- Rounded randomness.
  - Three options available: Floor, Round, Ceil
	- Control the direction of the rounding.
  - Clamped rounding.
	- Prevent the rounded number to go out of bounds of the defined **Min Wait Time** and **Max Wait Time**.
  - Step.
	- Level of Steps the rounding should do.

Note that **Wait Time** and **Step** will never go below `0.001`.

### Changed

- `start_random()` will no longer do an early return when **Random Timer** is set to **false**.
- Screenshot of the inspector window.

### Fixed

- Alt text of the icon in the README.md.

## [1.0.0] - 2026-05-23

### Added

- This file.
