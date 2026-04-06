# Let's Get Dressed - Project Guidelines

## Project Overview
A wardrobe management app that helps users organize and discover outfit combinations using their existing clothes and accessories. Users can scan items once, then receive smart suggestions for mixing and matching.

## Architecture Overview

### Platform & Deployment
- **iOS Frontend**: SwiftUI app targeting iPhone and Mac only
  - NOT intended for App Store distribution
  - Local/enterprise distribution via TestFlight or direct installation
- **Backend**: Java-based service handling AI suggestions and data management

### Core Domains

#### 1. Wardrobe Inventory
- **Scanning**: Front and back photos of individual clothing items and accessories
- **Storage**: Comprehensive wardrobe database with item metadata
- **Read-Only by Default**: Existing wardrobe items are immutable unless explicitly managed

#### 2. Outfit Suggestions
- **Algorithm**: Generate outfit combinations using existing items only
- **Matching**: Consider color, style, occasion, and accessory coordination
- **Conservative**: Do NOT suggest purchasing new items

#### 3. Wardrobe Modification
- **User-Initiated Only**: New items/accessories added only when user explicitly requests
- **No Unsolicited Purchases**: Never recommend buying anything unless explicitly asked
- **Transparent History**: Track what's in the wardrobe at any point

## Technical Stack

### Frontend (iOS)
- **Language**: Swift (SwiftUI)
- **Targets**: iOS 15+ (iPhone), macOS 12+ (Intel/Apple Silicon)
- **Distribution**: Ad-hoc/Enterprise provisioning, NOT App Store

### Backend
- **Language**: Java
- **Responsibilities**: 
  - Wardrobe data persistence
  - AI-powered outfit suggestion engine
  - Image processing (clothing recognition/categorization)
  - API endpoints for iOS client

## Data Storage Architecture

### Vector Database (Primary Storage)
- **Purpose**: Store image embeddings (vectors in bytes) for similarity matching
- **Technology**: Pinecone, Weaviate, Milvus, or Qdrant
- **Data Structure**:
  - Item embedding vectors (1536+ dimensions from vision models)
  - Metadata: color, style, occasion, season, size, category, item_id
  - Front and back photo embeddings stored separately for comprehensive matching

### Relational Database (Metadata & State)
- **Purpose**: Store structured wardrobe metadata and outfit history
- **Technology**: PostgreSQL or MySQL
- **Tables**:
  - `wardrobe_items`: item_id, type, color, season, occasion, size, brand, created_at, archived_at
  - `accessories`: category, compatibility_tags
  - `outfit_combinations`: suggested outfits with item_id references and user ratings
  - `wardrobe_snapshots`: immutable history of wardrobe state

### Image Storage (Local Phone Storage - Free)
- **Format**: JPEG/PNG front and back photos
- **Storage**: iOS local device storage (Documents or App Support directory)
- **iOS Path**: `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]/wardrobe/{item_id}/front.jpg`
- **macOS Path**: `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]/wardrobe/{item_id}/front.jpg`
- **Note**: Embeddings in vector DB, images stored locally on device for user display only (zero cost storage)

### Vector Similarity Workflow
1. **Scan**: iOS captures front + back photos, stores locally on device
2. **Upload**: iOS sends photos + vectors to Java backend for processing
3. **Embed**: Backend extracts vectors using vision model (e.g., OpenAI CLIP embeddings)
4. **Store**: Save vectors to vector DB with metadata; metadata mirrors to local DB (SQLite)
5. **Suggest**: Query vector DB for similar clothing + color/style coordination
6. **Match**: Use vector similarity + metadata filters for outfit combinations

## Development Constraints

### Wardrobe Management
- Once scanned, items stay in the wardrobe by default
- Deletion only removes from database, never auto-suggested as "replacements"
- Combination suggestions always use only existing inventory

### Feature Scope
- ✅ Scan and organize clothes
- ✅ Suggest outfit combinations from existing items
- ✅ Filter by occasion, season, color, etc.
- ❌ Do NOT suggest new purchases unless explicitly requested in chat
- ❌ Do NOT integrate with shopping platforms
- ❌ Do NOT implement App Store integration

## Code Organization
- Backend: Java services layer with clear API contracts
- Frontend: SwiftUI views organized by feature domain
- Shared: API models and types (JSON-based communication)
