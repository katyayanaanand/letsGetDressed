<<<<<<< HEAD
# LetsGetDressed

LetsGetDressed is a private wardrobe assistant for personal use on iPhone and Mac. It is intended for local or private deployment only and is not designed for App Store hosting or public cloud use.

## Project overview

The project has two main parts:

- `frontend/LetsGetDressed/` — a SwiftUI app for iPhone and Mac
- `backend/` — a Java 17 Spring Boot 3 backend that runs locally on a Mac

The SwiftUI app can point to the local backend during development or private use on the same machine or local network.

## Intended use

This project is built for:

- private wardrobe management
- scanning and organizing clothing and accessories
- generating outfit suggestions from items you already own

This project is not built for:

- App Store distribution
- public hosting
- default shopping recommendations

## Core behavior rules

### Wardrobe-only suggestions by default

Outfit suggestions must use only the current wardrobe by default.

Default behavior:

- use only items already stored in the wardrobe
- do not suggest buying anything
- do not recommend external products

### Shopping suggestions are opt-in only

Shopping suggestions should only appear when explicitly requested.

The shared request contract uses:

- `allowShoppingSuggestions: false` by default

If shopping suggestions are not explicitly enabled, suggestion logic should return combinations built only from existing wardrobe items.

## Local architecture

### Backend

The backend is a Spring Boot 3 application using Java 17. It is expected to run locally on a Mac for private use.

Primary API endpoints:

- `GET /api/health`
- `GET /api/wardrobe`
- `POST /api/wardrobe`
- `GET /api/wardrobe/{id}`
- `POST /api/suggestions`

### Frontend

The frontend is a SwiftUI app for iPhone and Mac only. It can be configured to call the local backend through the app networking layer.

The frontend and backend should share the same JSON contract for:

- wardrobe items
- wardrobe item creation
- outfit suggestion requests
- outfit suggestion responses

See `docs/api-contract.md` for the shared payload definitions.

## Least-space storage strategy for clothing scans

The app should optimize for minimal storage use while preserving enough detail for browsing and local outfit suggestions.

Recommended storage strategy:

- store optimized image files on disk instead of raw image blobs in a database
- save only file paths and metadata in the database or in-memory model
- create thumbnails for list and grid browsing
- calculate content hashes to detect duplicates
- avoid storing original full-resolution images after optimization unless the user explicitly chooses to retain them

### Expected image metadata

Each wardrobe item should track image-related metadata such as:

- `frontImagePath`
- `backImagePath`
- `thumbnailPath`
- `mimeType`
- `width`
- `height`
- `byteSize`
- `contentHash`

### Why this approach

This supports the least-space acquisition requirement:

- compressed files take less disk space than raw captures
- thumbnails reduce memory and rendering costs in the UI
- metadata in the data model keeps the API lightweight
- hashes support deduplication without storing duplicate image data
- not keeping original full-resolution images by default reduces long-term storage usage

## Suggested image handling flow

1. Capture or import front and back clothing images.
2. Resize large inputs to practical dimensions for local use.
3. Compress to HEIC or JPEG depending on platform support.
4. Generate a thumbnail for fast browsing.
5. Compute dimensions, byte size, MIME type, and content hash.
6. Store optimized files on disk.
7. Persist only metadata and file paths in the backend model.
8. Remove the original full-resolution temporary file unless the user chooses to retain it.

## Development notes

- Backend target: Spring Boot 3, Java 17
- Frontend target: SwiftUI for iPhone and Mac
- Default suggestion mode: wardrobe-only
- Default shopping flag: `allowShoppingSuggestions = false`

## API contract

The shared API contract is documented in:

- `docs/api-contract.md`

That document defines the expected request and response JSON for wardrobe items and outfit suggestions, including the least-space image metadata fields.
=======
# letsGetDressed
>>>>>>> 7dc3f40d75eed6eed9a6a4c5e6cc49d24319c08c
