# Change log

## 9d41857 - 2023-08-15

### Added
* Added CHANGELOG.md to store information based on git versions
* Model game_best_player to store match best player information

### Changed
* Moved award update function to service object
* Upgrade to Rails / deps to 7.0.7
* Championship Awards form following same pattern as Seasons
* Model to save awards ( championship / season ) n<->n

### Fixed
* legacy game_best_player association in old models