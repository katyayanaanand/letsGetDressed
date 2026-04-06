# Let's Get Dressed - Setup & Deployment Guide

## Prerequisites

### Backend
- Java 17+
- Maven 3.6+
- PostgreSQL 14+ (local or remote)
- Pinecone account (free tier available)
- OpenAI API key (for embeddings)

### Frontend (iOS)
- Xcode 15+
- iOS deployment target: iOS 15+
- macOS deployment target: macOS 12+

---

## Backend Setup

### 1. Database Configuration

**Install PostgreSQL locally (macOS):**
```bash
brew install postgresql@14
brew services start postgresql@14
```

**Create database:**
```bash
createdb letsgetdressed
```

**Configure credentials in** `backend/src/main/resources/application.yml`:
```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/letsgetdressed
    username: postgres
    password: <your_postgres_password>
```

### 2. Vector Database (Pinecone)

**Set up Pinecone account:**
1. Go to [pinecone.io](https://www.pinecone.io)
2. Create free account
3. Create index:
   - **Name**: `wardrobe-items`
   - **Dimensions**: 1536
   - **Metric**: cosine
   - **Encoding**: float32

**Set environment variable:**
```bash
export PINECONE_API_KEY=your-api-key-here
```

### 3. OpenAI API Key

**Set environment variable for embeddings:**
```bash
export OPENAI_API_KEY=sk-your-key-here
```

### 4. Run Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

Backend runs on `http://localhost:8080`

Health check:
```bash
curl http://localhost:8080/api/health
```

---

## iOS Setup

### 1. Update Backend URL

Edit `frontend/LetsGetDressed/Networking/APIClient.swift`:

Change:
```swift
private let baseURL: URL = URL(string: "http://localhost:8080")!
```

**For Testing on Simulator (localhost):**
```swift
private let baseURL: URL = URL(string: "http://127.0.0.1:8080")!
```

**For Physical Device:**
```swift
private let baseURL: URL = URL(string: "http://YOUR_MACHINE_IP:8080")!
```

Get your machine's IP:
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

### 2. Enable Camera Permissions

Add to `Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan your wardrobe items</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo library access to add existing photos to your wardrobe</string>
```

### 3. Build & Run

```bash
cd frontend
# Open in Xcode
open LetsGetDressed.xcodeproj

# Or build from command line
xcodebuild -scheme LetsGetDressed -destination 'generic/platform=iOS' build
```

---

## End-to-End Testing

### Test Backend First

```bash
# Check health
curl http://localhost:8080/api/health

# Get empty wardrobe
curl http://localhost:8080/api/wardrobe

# Add test item
curl -X POST http://localhost:8080/api/wardrobe \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Blue Shirt",
    "category": "Top",
    "color": "Blue",
    "season": "Summer",
    "occasion": "Casual",
    "frontImagePath": "test/image.jpg",
    "tags": ["cotton", "comfortable"]
  }'
```

### Test iOS App

1. Run backend on local machine
2. Update `APIClient.swift` with machine IP
3. Build & run iOS app on simulator/device
4. Navigate to "Wardrobe" tab
5. Tap "Add Your First Item"
6. Capture front image (camera or gallery)
7. Fill in item details
8. Tap "Save to Wardrobe"
9. Item should appear in list with thumbnail
10. Navigate to "Suggestions" tab to test outfit generation

---

## Architecture Overview

```
iOS App (SwiftUI)
    ↓
APIClient (URLSession)
    ↓
Java Spring Boot Backend (localhost:8080)
    ├── PostgreSQL (local DB)
    ├── Pinecone (Vector DB)
    └── OpenAI API (Embeddings)

Image Storage Flow:
  Camera/Gallery → ImageManager → Documents/wardrobe/{itemId}/
                              ↓
                          Backend API
                              ↓
                          Database (path metadata)
```

---

## Troubleshooting

### Backend Issues

**Port 8080 already in use:**
```bash
lsof -i :8080
kill -9 <PID>
```

**PostgreSQL connection refuses:**
```bash
brew services restart postgresql@14
```

**Vector DB connection timeout:**
- Check PINECONE_API_KEY is set
- Verify Pinecone index exists
- Check internet connection

### iOS Issues

**"Cannot connect to localhost:8080":**
- Ensure backend is running
- Use machine IP for physical devices
- Check firewall allows traffic

**Camera not working:**
- Grant camera permissions in Settings
- Test on physical device (simulators have limitations)
- Check Info.plist has NSCameraUsageDescription

**Images not saving:**
- Check Documents directory permissions
- Ensure sufficient disk space
- Try app reset: Delete app, rebuild

---

## Next Steps

1. ✅ Core functionality (scan, store, suggestions)
2. 🔄 Vector similarity refinement
3. 📱 UI/UX polish
4. 🧪 Unit & integration tests
5. 📦 Distribution (TestFlight/enterprise)

---

## Project Structure

```
letsGetDressed/
├── backend/                          # Java Spring Boot
│   ├── src/main/java/com/letsgetdressed/
│   │   ├── controller/              # REST endpoints
│   │   ├── model/                   # JPA entities
│   │   ├── repository/              # Data access
│   │   ├── service/                 # Business logic
│   │   └── LetsGetDressedApplication.java
│   ├── src/main/resources/
│   │   └── application.yml          # Configuration
│   └── pom.xml                      # Dependencies
│
├── frontend/LetsGetDressed/         # iOS SwiftUI
│   ├── App/                         # Entry point
│   ├── Models/                      # Data models
│   ├── Views/                       # SwiftUI screens
│   ├── ViewModels/                  # Logic & state
│   ├── Services/                    # Camera, images, API
│   ├── Networking/                  # API client
│   └── Resources/                   # Assets
│
└── .github/
    └── copilot-instructions.md      # Project guidelines
```

---

## Performance Tips

- **Images**: Compressed to 0.8 quality (80% smaller than original)
- **Thumbnails**: 320x320 for list views
- **Vector DB**: Queries are fast (<100ms) with proper indexing
- **Local Storage**: No network latency for photo access
- **Batch Operations**: Future: sync multiple items in one request

---

## Security Notes

- ✅ No API keys stored in code (use environment variables)
- ✅ Photos stored locally (only on device)
- ✅ No third-party integrations
- ✅ Ad-hoc distribution (not App Store)
- 🔄 TODO: HTTPS for backend (use self-signed cert in development)

---

## Support

For issues or questions, check:
1. Project instructions: `.github/copilot-instructions.md`
2. Backend logs: `mvn spring-boot:run` output
3. iOS debugger: Xcode console
4. Pinecone docs: https://docs.pinecone.io
5. OpenAI API docs: https://platform.openai.com/docs
