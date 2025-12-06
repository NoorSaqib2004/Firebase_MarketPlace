# Firebase Storage Setup - Step by Step

## Enable Firebase Storage

1. **Go to Firebase Console**
   - URL: https://console.firebase.google.com/
   - Select your project: `test-demo-a0620`

2. **Navigate to Storage**
   - Left sidebar → "Build" section
   - Click "Storage"

3. **Start Storage**
   - You should see "Get Started" button
   - Click it

4. **Choose Security Rules**
   - A dialog will appear with options:
     - ✅ **Test Mode (For Development)** - Choose this first
     - Production Mode - Choose this later
   - Click **Test Mode**

5. **Choose Location**
   - Default: `us-central1` (or choose closest to your users)
   - Click "Next"

6. **Confirm and Create**
   - Click "Done" or "Create"
   - Storage is now enabled!

7. **Add Security Rules** (Optional but recommended)
   - Go to "Rules" tab
   - Replace with these rules:

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

8. **Publish Rules**
   - Click "Publish" button

---

## Verify Storage is Working

After enabling Storage, you should see:
- A "Buckets" page with your bucket name: `test-demo-a0620.firebasestorage.app`
- Tabs: "Files", "Rules", "CORS"

That's it! Storage is now ready for the app to upload images.

---

## App Will Auto-Create Folders

When you use these features in the app:
- **Upload Profile Picture** → Creates `profiles/` folder
- **Upload Listing Images** → Creates `listings/` folder
- **Upload Chat Images** → Creates `chats/` folder

No manual setup needed!
