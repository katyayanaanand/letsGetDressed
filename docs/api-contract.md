# API Contract

This document defines the shared JSON contract between the SwiftUI frontend and the Spring Boot backend.

## Base assumptions

- Base path: `/api`
- Content type: `application/json`
- Suggestion requests must default `allowShoppingSuggestions` to `false`
- Image files are stored on disk as optimized compressed files
- The API model stores paths and metadata, not raw image blobs

## Endpoints

- `GET /api/health`
- `GET /api/wardrobe`
- `POST /api/wardrobe`
- `GET /api/wardrobe/{id}`
- `POST /api/suggestions`

---

## Health

### `GET /api/health`

#### Response

```json
{
  "status": "ok"
}
```

---

## Wardrobe item model

A wardrobe item represents one clothing or accessory entry in the current wardrobe.

### JSON shape

```json
{
  "id": "7f4d2f2c-8d3f-4a18-a8b9-21de4f0f2b11",
  "name": "Blue Oxford Shirt",
  "category": "TOP",
  "color": "Blue",
  "season": "All",
  "occasion": "Casual",
  "notes": "Works with chinos and dark denim.",
  "frontImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-front.heic",
  "backImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-back.heic",
  "thumbnailPath": "/Users/me/Pictures/LetsGetDressed/thumbnails/blue-shirt-thumb.jpg",
  "mimeType": "image/heic",
  "width": 1600,
  "height": 2000,
  "byteSize": 248320,
  "contentHash": "sha256:8b1d7f3f2df7f1d43d43f0a4c9ef104ce1fdb8e4c8a1dfd67f7c0de77f56a2f1"
}
```

### Field reference

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `id` | string | response-only | Unique identifier for the wardrobe item |
| `name` | string | yes | User-friendly item name |
| `category` | string | yes | Example: `TOP`, `BOTTOM`, `DRESS`, `OUTERWEAR`, `SHOES`, `ACCESSORY` |
| `color` | string | no | Primary visible color |
| `season` | string | no | Example: `Spring`, `Summer`, `Fall`, `Winter`, `All` |
| `occasion` | string | no | Example: `Casual`, `Work`, `Formal` |
| `notes` | string | no | Free-form notes |
| `frontImagePath` | string | no | Filesystem path to optimized front image |
| `backImagePath` | string | no | Filesystem path to optimized back image |
| `thumbnailPath` | string | no | Filesystem path to generated thumbnail |
| `mimeType` | string | no | MIME type of the optimized stored image |
| `width` | number | no | Pixel width of the optimized image |
| `height` | number | no | Pixel height of the optimized image |
| `byteSize` | number | no | Size in bytes of the optimized stored image |
| `contentHash` | string | no | Stable hash used for deduplication |

### Storage contract

The wardrobe item model supports least-space storage:

- optimized front and back image files are stored on disk
- thumbnails are stored separately on disk
- metadata and file paths are stored in the backend model
- original raw captures should not be stored in the API model
- `contentHash` is used to detect duplicates

---

## `GET /api/wardrobe`

Returns all wardrobe items.

### Response

```json
[
  {
    "id": "7f4d2f2c-8d3f-4a18-a8b9-21de4f0f2b11",
    "name": "Blue Oxford Shirt",
    "category": "TOP",
    "color": "Blue",
    "season": "All",
    "occasion": "Casual",
    "notes": "Works with chinos and dark denim.",
    "frontImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-front.heic",
    "backImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-back.heic",
    "thumbnailPath": "/Users/me/Pictures/LetsGetDressed/thumbnails/blue-shirt-thumb.jpg",
    "mimeType": "image/heic",
    "width": 1600,
    "height": 2000,
    "byteSize": 248320,
    "contentHash": "sha256:8b1d7f3f2df7f1d43d43f0a4c9ef104ce1fdb8e4c8a1dfd67f7c0de77f56a2f1"
  }
]
```

---

## `POST /api/wardrobe`

Creates a new wardrobe item.

### Request

```json
{
  "name": "Blue Oxford Shirt",
  "category": "TOP",
  "color": "Blue",
  "season": "All",
  "occasion": "Casual",
  "notes": "Works with chinos and dark denim.",
  "frontImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-front.heic",
  "backImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-back.heic",
  "thumbnailPath": "/Users/me/Pictures/LetsGetDressed/thumbnails/blue-shirt-thumb.jpg",
  "mimeType": "image/heic",
  "width": 1600,
  "height": 2000,
  "byteSize": 248320,
  "contentHash": "sha256:8b1d7f3f2df7f1d43d43f0a4c9ef104ce1fdb8e4c8a1dfd67f7c0de77f56a2f1"
}
```

### Response

```json
{
  "id": "7f4d2f2c-8d3f-4a18-a8b9-21de4f0f2b11",
  "name": "Blue Oxford Shirt",
  "category": "TOP",
  "color": "Blue",
  "season": "All",
  "occasion": "Casual",
  "notes": "Works with chinos and dark denim.",
  "frontImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-front.heic",
  "backImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-back.heic",
  "thumbnailPath": "/Users/me/Pictures/LetsGetDressed/thumbnails/blue-shirt-thumb.jpg",
  "mimeType": "image/heic",
  "width": 1600,
  "height": 2000,
  "byteSize": 248320,
  "contentHash": "sha256:8b1d7f3f2df7f1d43d43f0a4c9ef104ce1fdb8e4c8a1dfd67f7c0de77f56a2f1"
}
```

---

## `GET /api/wardrobe/{id}`

Returns one wardrobe item by identifier.

### Response

```json
{
  "id": "7f4d2f2c-8d3f-4a18-a8b9-21de4f0f2b11",
  "name": "Blue Oxford Shirt",
  "category": "TOP",
  "color": "Blue",
  "season": "All",
  "occasion": "Casual",
  "notes": "Works with chinos and dark denim.",
  "frontImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-front.heic",
  "backImagePath": "/Users/me/Pictures/LetsGetDressed/items/blue-shirt-back.heic",
  "thumbnailPath": "/Users/me/Pictures/LetsGetDressed/thumbnails/blue-shirt-thumb.jpg",
  "mimeType": "image/heic",
  "width": 1600,
  "height": 2000,
  "byteSize": 248320,
  "contentHash": "sha256:8b1d7f3f2df7f1d43d43f0a4c9ef104ce1fdb8e4c8a1dfd67f7c0de77f56a2f1"
}
```

---

## Suggestion request

### `POST /api/suggestions`

Creates outfit suggestions using current wardrobe items.

### Request

```json
{
  "occasion": "Casual dinner",
  "season": "Fall",
  "preferredColors": [
    "Blue",
    "White"
  ],
  "allowShoppingSuggestions": false
}
```

### Request field reference

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `occasion` | string | no | Occasion or context for the outfit |
| `season` | string | no | Season filter |
| `preferredColors` | array of strings | no | Optional preferred colors |
| `allowShoppingSuggestions` | boolean | no | Defaults to `false`; must remain `false` unless the user explicitly requests shopping suggestions |

### Rule

When `allowShoppingSuggestions` is `false` or omitted:

- suggestions must use only wardrobe items already stored in the system
- no purchase recommendations should be returned

When `allowShoppingSuggestions` is `true`:

- shopping suggestions may be considered later
- current scaffold behavior may return an empty shopping suggestion list placeholder

---

## Suggestion response

### Response

```json
{
  "summary": "1 outfit suggestion generated from your current wardrobe.",
  "outfits": [
    {
      "title": "Casual Blue Outfit",
      "itemIds": [
        "7f4d2f2c-8d3f-4a18-a8b9-21de4f0f2b11",
        "a27e9d10-7227-43fd-b932-b2de3104c2aa"
      ],
      "notes": "Built only from wardrobe items already on hand."
    }
  ],
  "shoppingSuggestions": []
}
```

### Response field reference

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `summary` | string | yes | Human-readable summary |
| `outfits` | array | yes | Outfit combinations generated from existing wardrobe items |
| `outfits[].title` | string | yes | Display name for the suggestion |
| `outfits[].itemIds` | array of strings | yes | Identifiers of wardrobe items used in the suggestion |
| `outfits[].notes` | string | no | Optional explanation |
| `shoppingSuggestions` | array | yes | Must be empty unless shopping suggestions were explicitly requested and implemented |

---

## Integration notes

- Frontend models should match these field names exactly.
- Backend controllers should serialize and deserialize these JSON keys directly.
- `allowShoppingSuggestions` should be set to `false` by default in the SwiftUI client.
- Image-related paths are file references for local/private use and should not be treated as public URLs by default.