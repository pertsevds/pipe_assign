## [1.1.0] - 2025-01-XX

### Added
- **New `match_to/2` macro**: it's an alias to `assign_to/2` for readability

### Changed
- Simplified `assign_to/2` macro implementation
  - Now it's a warning if variable is unused
- Updated documentation to emphasize pattern matching capabilities

### Removed
- Removed complex variable handling logic and compiler warning suppression
- Removed performance overhead warnings as benchmarks now show negligible impact

## [1.0.0] - 2025-01-XX

### Added
- Initial release of PipeAssign
