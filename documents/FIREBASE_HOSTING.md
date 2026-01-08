# Firebase Hosting for CORDIS (Flutter Web)

**Architecture:** Web version uses Firestore only (no SQLite). Desktop/Mobile use SQLite + Firestore sync. Distribution: Playlist-driven (no public cipher library). Goal: Stay within Firestore free tier (50k reads/day).

---

## Setup Checklist

- [ ] Firebase project created and configured
- [ ] Firebase CLI installed (`npm i -g firebase-tools`)
- [ ] Web platform enabled in Flutter
- [ ] Firestore security rules updated (user-scoped access)
- [ ] Firebase domain authorized in Auth settings

---

## Action Plan

### Phase 1: Initial Setup (1 day)

1. **Configure Firebase for web**
   - Verify CORDIS/lib/firebase_options.dart exists and is current
   - Add web app in Firebase Console if missing
   - Add domain to Firebase Auth authorized domains

2. **Enable & build web**
   - Run: `flutter config --enable-web`
   - Run: `flutter pub get`
   - Run: `flutter build web --release`
   - Verify CORDIS/build/web exists

3. **Initialize Firebase Hosting**
   - Run: `firebase init hosting` (from repo root)
   - Public directory: `CORDIS/build/web`
   - SPA rewrite: Yes
   - Set up GitHub integration: Optional (can add later)

4. **Configure firebase.json**
   - Update public path to `CORDIS/build/web`
   - Verify SPA rewrite rule present
   - Set cache headers (index.html: no-cache, assets: immutable)

### Phase 2: Firestore Schema (1-2 days)

Migrate to playlist-driven, user-scoped structure:

```
users/{userId}/
  ├── profile/
  ├── playlists/{playlistId}/
  │   ├── metadata (name, owner, description)
  │   ├── items/ (references to ciphers)
  │   └── collaborators/ (shared access)
  └── settings/

ciphers/{cipherId}/  (only rights-owned ciphers)
  ├── metadata (title, author, key, tags)
  ├── versions/{versionId}/
  │   ├── songStructure
  │   └── sections/
  └── stats/

playlists/{playlistId}/  (global, not per-user)
  ├── metadata
  ├── items/
  └── collaborators/
```

**Cost impact:** ~80% reduction vs public cipher browsing model

### Phase 3: Repository Layer (2-3 days)

Create web-specific repository:
- `lib/repositories/web_playlist_repository.dart` - Load playlists + ciphers
- Update `CipherProvider` to detect platform (web → Firestore, mobile → SQLite)
- Add caching layer (15-min cache on metadata)
- No `CloudCipherRepository.getPublicCiphers()` method

### Phase 4: Testing & Deployment (1 day)

1. **Local testing:**
   - Run: `flutter run -d chrome`
   - Test login flow
   - Test playlist loading
   - Test cipher viewing

2. **Preview deployment:**
   - Run: `firebase hosting:channel:deploy preview-1`
   - Share preview URL
   - Test on multiple browsers

3. **Production deployment:**
   - Run: `firebase deploy --only hosting`

---

## Cost Monitoring

**Track daily (Firebase Console):**
- Reads: X / 50,000
- Writes: Y / 20,000
- Storage: Z / 1GB

**Optimization thresholds:**
- 30k reads → Add view caching
- 40k reads → Implement pagination
- 45k reads → Reduce batch operations

**Expected usage per session:**
- Load playlists: ~5 reads
- Browse items: ~5 reads
- View ciphers: ~3-10 reads
- **Total: ~15-20 reads per session**

---

## Deployment Pipeline

**Manual deployment:**
```
cd CORDIS && flutter build web --release && cd .. && firebase deploy --only hosting
```

**CI/CD (optional, add later):**
- Create `.github/workflows/firebase-hosting.yml`
- Deploy previews on PRs, production on main
- Requires `FIREBASE_TOKEN` in repo secrets

---

## Key Differences from Desktop/Mobile

| Aspect | Desktop/Mobile | Web |
|--------|---|---|
| **Storage** | SQLite (local) | Firestore (cloud) |
| **Offline** | Full ✅ | Partial (cached only) |
| **Sync** | Manual sync to Firestore | Real-time Firestore |
| **Ciphers** | All downloaded/available | Only in playlists |
| **Auth** | Optional (local-first) | Required (Firestore access) |

---

## Post-Launch

1. Monitor Firestore usage daily for first month
2. Adjust caching/pagination if approaching limits
3. Document actual vs projected costs
4. Plan paid tier if user base exceeds free tier capacity (~500-1000 active users)
