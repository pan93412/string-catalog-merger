# XcStringMerger

Allow merging the translated [String Catalog](https://developer.apple.com/documentation/Xcode/localizing-and-varying-text-with-a-string-catalog) with the project's current String Catalog, useful for resolving merge conflicts.

## Features

- Provide multiple merge strategies – merge, replace or merge only the translated.
- Save your WIP merge session in the file.
- Localized in Chinese (Traditional).

## Components

- `XcStringMerger`: The core of the merger, with the type declaration of String Catalog included.
- `XcStringMergerUI`: The UI of `XcStringMerger` targeting mainly for macOS.

## Screenshots

![XcStringMergerUI](./docs/ui.png)

