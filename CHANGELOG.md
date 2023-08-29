# Change log

## cc4db9d - 2023-08-25

### Added
* User Championships view
* Reorganized Game card elments into service objects and partials 

## 6cdc550 - 2023-08-18

### Added
* Moved awards calc into generic app service
* pry-rails
* bootstrap popover to show basic user info when focus on usernames nick

### Changed
* Removed WO column from games and added subtype int to help control statuses
* Changed championship jsonb type from datetime to date

## 7d55589 - 2023-08-17

### Added
* Manager Championship Settings

### Changed
* New column gsequence and function in Championship controller to get game sequence number

### Fixed
* Championship name check method
* Championship badge upload/save

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