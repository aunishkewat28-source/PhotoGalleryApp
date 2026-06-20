# Photo Gallery

An iOS photo gallery app built with **SwiftUI**, **Core Data**, and **URLSession**. It fetches photos from the JSONPlaceholder API, persists them locally, and supports viewing, editing titles, and deleting records.

## Requirements

| Item | Value |
|------|-------|
| Language | Swift 5+ |
| Minimum iOS | 15.0 |
| UI Framework | SwiftUI |
| Architecture | MVVM + Repository |
| Networking | URLSession |
| Persistence | Core Data |
| Dependency Manager | None (no third-party libraries) |

## Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd PhotoGalleryApp
   ```

2. **Open the project in Xcode**
   ```bash
   open PhotoGallery/PhotoGallery.xcodeproj
   ```

3. **Select a simulator or device**
   - Choose an iOS 15.0+ simulator (e.g. iPhone 15 / iPhone 16)
   - Or connect a physical device with a valid development team

4. **Configure signing (if needed)**
   - Select the **PhotoGallery** target
   - Go to **Signing & Capabilities**
   - Choose your **Team**

5. **Build and run**
   - Press `Cmd + R` or click the Run button

> **Note:** The app requires network access on first launch to fetch photos from the API.

## Features

- Fetch 5000 photos from `https://jsonplaceholder.typicode.com/photos`
- Display photos in a scrollable list with thumbnail and title
- Image caching with `NSCache` to avoid re-downloading on scroll
- Core Data persistence — loads from local storage on subsequent launches
- Upsert logic prevents duplicate records on re-fetch
- Lazy loading pagination (30 items per page from Core Data)
- Edit photo title on detail screen with save to Core Data
- Delete via swipe-to-delete or detail screen with confirmation alert
- Loading, empty, and error states with retry support

## Architecture Overview

The app follows **MVVM** with a **Repository** layer as the single source of truth.

```
PhotoGalleryApp
├── App/                    # App entry point
├── Core/
│   ├── Persistence/        # Core Data stack + model
│   ├── Networking/         # URLSession API service
│   └── Cache/              # NSCache image caching
├── Models/                 # DTOs + Core Data extensions
├── Repositories/           # Data access & business logic
├── ViewModels/             # Presentation logic
└── Views/                  # SwiftUI screens & components
```

### Data Flow

```
View → ViewModel → Repository → (Core Data / API / ImageCache)
```

| Layer | Responsibility |
|-------|----------------|
| **View** | SwiftUI UI, user interactions |
| **ViewModel** | State management, loading/error handling |
| **Repository** | CRUD, API fetch, deduplication, pagination |
| **Core Data** | Local persistence |
| **PhotoAPIService** | Network requests via URLSession |
| **ImageCache** | In-memory image caching |

### Key Components

| File | Purpose |
|------|---------|
| `PersistenceController` | Core Data stack (shared + preview) |
| `PhotoRepository` | Load, save, update, delete, paginate |
| `PhotoListViewModel` | List state, pagination, errors |
| `PhotoDetailViewModel` | Edit title, delete photo |
| `ImageCache` | Actor-based cache with in-flight deduplication |
| `AsyncThumbnailImage` | Async image loader with placeholder fallback |

## Screenshots

> Add screenshots to a `screenshots/` folder and update the paths below before submission.

| Screen | Description |
|--------|-------------|
| Loading | Initial fetch with progress indicator |
| Photo List | Scrollable list with thumbnails and titles |
| Detail / Edit | Full image, editable title, save & delete |
| Empty State | No photos available message |
| Error State | Network failure with Try Again button |

Example layout:

```
screenshots/
├── loading.png
├── photo-list.png
├── detail-edit.png
├── empty-state.png
└── error-state.png
```

## Assumptions

1. **API pagination** — The JSONPlaceholder API returns all 5000 records in a single response. UI pagination is handled from Core Data in batches of **30 items**, not via API paging.

2. **Default image** — When a thumbnail or full image fails to load, a system placeholder icon (`photo`) is shown instead of a custom asset.

3. **First launch strategy** — On launch, the app checks Core Data first. If empty, it fetches from the API and saves all records. On subsequent launches, data loads from Core Data only.

4. **Deduplication** — Photos are upserted by `id` using a Core Data uniqueness constraint and fetch-before-insert logic.

5. **No third-party libraries** — Networking uses native `URLSession`, caching uses `NSCache`. No Alamofire, Kingfisher, or SDWebImage.

6. **iOS 15 compatibility** — Uses `NavigationView` instead of `NavigationStack` for broader iOS 15 support.

## Project Structure

```
PhotoGalleryApp/
├── .gitignore
├── README.md
└── PhotoGallery/
    ├── PhotoGallery.xcodeproj
    ├── PhotoGallery/
    │   ├── App/
    │   ├── Core/
    │   ├── Models/
    │   ├── Repositories/
    │   ├── ViewModels/
    │   └── Views/
    ├── PhotoGalleryTests/
    └── PhotoGalleryUITests/
```

## Git Branches

| Branch | Purpose |
|--------|---------|
| `main` | Stable base |
| `feature/photo-gallery` | Full app implementation |

## License

This project was created as a technical assessment submission.
