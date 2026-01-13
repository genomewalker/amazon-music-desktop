# Amazon Music Desktop

![CI](https://github.com/genomewalker/amazon-music-desktop/actions/workflows/ci.yml/badge.svg)
![Secret Scan](https://github.com/genomewalker/amazon-music-desktop/actions/workflows/secret-scan.yml/badge.svg)

A lightweight macOS desktop wrapper for Amazon Music built with SwiftUI and `WKWebView`. It provides a native window, menu bar controls, and a mini player while keeping you in the Amazon Music web experience.

## Features

- Amazon Music web player embedded in a native macOS window
- Media keys / Now Playing integration
- Menu bar controls (play/pause, next/previous)
- Mini player window for quick access
- Session persistence via WebKit data store

## Requirements

- macOS 13.0 or later
- Xcode command line tools (for `swift`)

## Build

```bash
cd "/Users/kbd606/Desktop/Amazon Music Desktop"
./scripts/build-app.sh
```

The app will be built at:

```
Build/Amazon Music Desktop.app
```

## Install

```bash
ditto "Build/Amazon Music Desktop.app" "/Applications/Amazon Music Desktop.app"
```

## Run

```bash
open "/Applications/Amazon Music Desktop.app"
```

## Notes

- This project is not affiliated with Amazon.
- Playback metadata relies on the Amazon Music web player and may change if their UI changes.
- Offline downloads are not supported.
