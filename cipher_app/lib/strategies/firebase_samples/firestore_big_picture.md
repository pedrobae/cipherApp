# Firestore Big Picture: Cipher App

```
Firestore Root
├── users/{userId}
│   └── profile, preferences, etc.
├── publicCiphers/{cipherId}
│   └── metadata
│   └── versions/{versionId}
│       └── sections/{sectionId}
├── playlists/{playlistId}
│   └── metadata, items, collaborators
├── infoContent/{infoId}
│   └── title, content, images
├── stats/mostDownloadedCiphers
│   └── ciphers: [ ... ]
```

- Use Firebase Realtime Database for high-frequency, real-time session data (e.g., scroll sync):

```
Realtime Database Root
└── sessions/{sessionId}
    └── playlistId, currentIndex, scrollPosition, presenter, timestamp
```

**Resumo:**
- Firestore: persistent data (users, ciphers, playlists, info, stats)
- RTDB: volatile, real-time session state
