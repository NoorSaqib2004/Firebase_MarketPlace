# Firebase Marketplace App - Services Setup Guide

## Required Firebase Services

### 1. **Firebase Authentication** ✅
- **Purpose**: User login/registration
- **Methods Configured**:
  - Email/Password authentication ONLY (Google Sign-In removed)
- **Setup Steps**:
  1. Go to Firebase Console → Authentication
  2. Click "Get Started"
  3. Click "Email/Password" provider
  4. Toggle "Email/Password" ON
  5. Toggle "Email link (passwordless sign-in)" OFF
  6. Click Save

### 2. **Cloud Firestore** ✅
- **Purpose**: Store all app data (users, listings, chats, messages, favorites)
- **Collections Needed**:
  ```
  users/
  ├── {uid}
  │   ├── name, email, phone, photoUrl, city
  │   └── favorites/ (subcollection)
  │       └── {listingId}

  listings/
  ├── {listingId}
  │   ├── title, description, price, images, category
  │   ├── ownerId, createdAt, status

  chats/
  ├── {chatId}
  │   ├── users[], listingId, lastMessage, updatedAt
  │   └── messages/ (subcollection)
  │       └── {messageId}
  │           ├── senderId, text, timestamp, seen, imageUrl
  ```

- **Setup Steps**:
  1. Go to Firebase Console → Firestore Database
  2. Click "Create Database"
  3. Start in **Test Mode** (for development)
  4. Collections will auto-create when app first writes data

### 3. **Firebase Storage** ✅
- **Purpose**: Store images (profiles, listings, chat images)
- **Folders Structure**:
  ```
  profiles/{uid}/{timestamp}        - Profile pictures
  listings/{listingId}/{timestamp}  - Listing images
  chats/{chatId}/{timestamp}        - Chat images
  ```

- **Setup Steps**:
  1. Go to Firebase Console → Build → Storage
  2. Click "Get Started"
  3. Choose location: **us-central1** (default)
  4. Click "Enable"
  5. Storage will now be ready (folders auto-create when app uploads files)
  6. Go to "Rules" tab and paste the Storage Rules below

---

## Security Rules Setup

### Firestore Security Rules
```firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection
    match /users/{uid} {
      allow read: if request.auth.uid != null;
      allow create, update: if request.auth.uid == uid;
      allow delete: if request.auth.uid == uid;
      
      // Favorites subcollection
      match /favorites/{favorite} {
        allow read: if request.auth.uid != null;
        allow create, update, delete: if request.auth.uid == uid;
      }
    }
    
    // Listings collection
    match /listings/{listing} {
      allow read: if true; // Anyone can view listings
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.ownerId;
    }
    
    // Chats collection
    match /chats/{chat} {
      allow read: if request.auth.uid in resource.data.users;
      allow create: if request.auth.uid != null;
      allow update: if request.auth.uid in resource.data.users;
      
      // Messages subcollection
      match /messages/{message} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chat)).data.users;
        allow create: if request.auth.uid != null && request.auth.uid == request.resource.data.senderId;
      }
    }
  }
}
```

### Storage Security Rules
```storage rules
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Profile images
    match /profiles/{uid}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid == uid;
    }
    
    // Listing images
    match /listings/{listing}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth.uid != null;
    }
    
    // Chat images
    match /chats/{chat}/{allPaths=**} {
      allow read: if request.auth.uid != null;
      allow write: if request.auth.uid != null;
    }
  }
}
```

---

## Services Used in App Code

### **AuthService**
- `signInWithEmailPassword(email, password)` ✅
- `registerWithEmailPassword(email, password, name, phone, city)` ✅
- `signOut()` ✅
- **Note**: Google Sign-In removed (email/password only)

### **ListingService**
- `createListing(ListingModel)` → Firestore
- `fetchListings()` → Stream from Firestore
- `searchListingsByTitle(query)` → Firestore query
- `filterListingsByPrice(min, max)` → Firestore query
- `fetchListingsByUser(userId)` → Firestore query
- `updateListingStatus(listingId, status)` → Firestore update

### **ChatService**
- `createChat(buyerId, sellerId, listingId)` → Firestore
- `sendMessage(chatId, MessageModel)` → Firestore
- `getMessages(chatId)` → Stream from Firestore
- `getUserChats(uid)` → Stream from Firestore

### **FavoritesService**
- `addToFavorites(uid, listingId)` → Firestore
- `removeFromFavorites(uid, listingId)` → Firestore
- `getUserFavorites(uid)` → Stream from Firestore

### **StorageService**
- `uploadProfileImage(uid, file)` → Firebase Storage
- `uploadListingImages(listingId, List<File>)` → Firebase Storage
- `uploadChatImage(chatId, file)` → Firebase Storage

---

## Configuration Files Already Set Up

✅ `firebase_options.dart` - Firebase credentials for all platforms
✅ `google-services.json` - Android configuration
✅ `pubspec.yaml` - All dependencies added

---

## Next Steps

1. **Go to Firebase Console** (https://console.firebase.google.com/)
2. **Select your project**: `test-demo-a0620`
3. **Enable services**:
   - ✅ Authentication (Email/Password + Google)
   - ✅ Firestore Database (Test Mode for now)
   - ✅ Storage
4. **Copy-paste the Security Rules** above into:
   - Firestore Rules
   - Storage Rules
5. **Create test user** in Firebase Console → Authentication → Add User
6. **Test login** with the test user credentials

---

## Production Checklist

- [ ] Enable Email verification
- [ ] Set up Firestore indexes (Firebase will suggest)
- [ ] Switch Firestore from Test Mode to Production Rules
- [ ] Set up Google Sign-In credentials
- [ ] Enable CORS for web (if needed)
- [ ] Set up backup rules
- [ ] Enable monitoring/analytics

