# Firebase Hosting for CORDIS (Flutter Web)

**Architecture:** Web version uses Firestore only (no SQLite). Desktop/Mobile use SQLite + Firestore sync. Distribution: Playlist-driven (no public cipher library). Goal: Stay within Firestore free tier (50k reads/day).

---

## Setup Checklist

- [ ] Firestore security rules updated (user-scoped access)

---

## Action Plan

### Phase 1: Initial Setup (1 day)

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

Top-level playlists with lazy-fetched version snapshots:

```
playlists/{playlistId}
   ownerId: string
   collaboratorIds: [string]
   name, description, createdAt, updatedAt
   items: [
      { pvId: string, order: number, updatedAt: timestamp, type: 'cipherVersion' }
   ]

playlists/{playlistId}/versions/{pvId}  // snapshot used in this playlist
   baseCipherId: string
   title, author, musicKey, tags
   versionName, songStructure, transposedKey
   sections: { sectionId: { contentCode, contentText, contentColor, contentType } }
   createdAt, updatedAt

users/{ownerId}/ciphers/{cipherId}      // owner-only source of truth
   full editable cipher content (not read by collaborators)

publicCiphers/{cipherId} (optional)
   metadata only; rights-owned and readable by authenticated users
```

**Cost impact:** ~80% reduction vs public cipher browsing model

#### Indexes (recommended)

- playlists: `collaboratorIds array-contains` + `updatedAt desc` for member queries
- playlists/versions: `order asc` (single-field) for presentation ordering

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

## Post-Launch

1. Monitor Firestore usage daily for first month
2. Adjust caching/pagination if approaching limits
3. Document actual vs projected costs
4. Plan paid tier if user base exceeds free tier capacity (~500-1000 active users)
