# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedQuickNode<T>(...)` — wraps a otel_quicknode call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutQuickNodeInstrumentation()` / `Async()`.
