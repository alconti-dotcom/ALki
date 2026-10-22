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

All three libraries are used in source / package form and are not modified. The one change to the vendored EPUBKit is in its `Package.swift`, which raises the iOS and tvOS minimum to 17 to match AEXML 4.7.3.
