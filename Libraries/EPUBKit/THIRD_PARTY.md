# Third-Party Notices

This directory vendors third-party code under the MIT License.

## EPUBKit

- Copyright (c) 2022 Witek Bobrowski
- Upstream: https://github.com/witekbobrowski/EPUBKit
- License: MIT (see `LICENSE` in this directory)

EPUBKit transitively depends on:

## AEXML

- Copyright (c) Marko Tadić
- Upstream: https://github.com/tadija/AEXML
- License: MIT

## ZipArchive (SSZipArchive)

- Copyright (c) ZipArchive contributors
- Upstream: https://github.com/ZipArchive/ZipArchive
- License: MIT

AEXML and ZipArchive are SwiftPM dependencies, resolved from upstream and unmodified. The vendored EPUBKit is a modified fork: it uses ZipArchive instead of marmelroy/Zip, adds EPUB3 XHTML navigation and NCX-less spine support, hardens the NCX parser against missing attributes, drops the upstream test target, and raises the platform minimums to macOS 10.15 and iOS/tvOS 17 (required by AEXML ≥ 4.7.2).
