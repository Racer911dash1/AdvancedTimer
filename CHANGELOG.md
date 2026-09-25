# Changelog

All changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

The following unreleased changes have not yet been submitted to the Godot asset store.

## Unreleased

### Changed

- Renamed `sort_weighted_times` to `sort_weighted_times_action`
- Documentation, clarifying some parts.

### Fixed

- Setting `seed` to `null` after previously setting a seed did not "disable" the seeded time generation. It now randomizes the seed when set to `null`, effectively disabling it.
  - Setting `static_randomization` also sets the rng seed.

### Other

This category is for changes that are not relevant for the average user.

- Setters and Getters are now functions instead of codeblocks.
  - Additionally changed the logic of some setters.
- Added weighted_times default value - `null`
- Doc comment placed according to the gdscript style guide.
- Shuffled code, mainly to follow the gdscript style guide.
- Removed formatter addon.

---

## [2.3.1] - 2026-08-24

### Fixed

- An error where a changed variable name didn't reflect the change in the `_validate_property()` function.

## [2.3.0] - 2026-08-06

### Added

- `start_weighted()` method for weighted randomization.
	- Set the `weighted_times` property to use the method without arguments.
- `WeightedTimeTable` Resource for reusable Dictionaries.

### Changed

- Some documentation.

### Fixed

- The timer seed not changing after entering the scene tree.
- The `min/max_wait_time` setter not enforcing the minimum time if set via code.


## [2.2.0] - 2026-07-06

### Added

- Static Randomization
  - Uses a RandomNumberGenerator variable that's shared across all instances of the same class.
  - Recommended for web builds if a lot of timers get generated in short succession.

### Changed

- `start_random()` now always starts a timer even with wrong arguments.
  - Renamed the parameters from `_min/max_wait_time` to `min/max_time`.
  - If `max_time` is less than `min_time`, a timer of `min_time` will start.
  - If any argument is below `0.001`, their value will be clamped to `0.001`.
    - Pushed errors are not pushed as warnings instead.
- Renamed `timer_seed` to `seed`
- Some documentation.

### Removed

- `Seeded` due to making `seed` a checkable property

## [2.1.0] - 2026-06-22

### Added

- A signal to inform how long the randomized timer lasts until timeout is emitted.

### Changed

- Variables to be more simple to type out
- Timer seed to allow negative values
- step_size to be set to any value
- Documentation comments. Prodiding examples and fixing broken links.

## [2.0.0] - 2026-05-23

### Added

- Grouped Properties, making it easier to tell what belongs together.

### Changed

- `start_random()` now calling `start()` with the `super` keyword.
- Randomized timers now being rounded up to 3 decimal places.

### Fixed

- `start_random()` by reusing the arguments given during its initial call

### Deprecated

- `start()` due to limitations, if you want to use this class as a normal timer,
set **Min Wait Time** and **Max Wait Time** to the same values.

### Removed

- **Random Timer** due to deprecating `start()`.

## [1.1.0] - 2026-05-23

#### Added

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
