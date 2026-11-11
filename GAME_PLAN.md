# BLACK BOY BAND: Roblox Universe — creative and technical direction

## Promise
A social, music-first Roblox neighborhood. Players aren't just spectators at a virtual concert: they can discover songs, collaborate on music-inspired challenges, form a crew, and return to places that remember their choices.

## World layout
1. **BBB Plaza / The Block** — shared spawn, a giant functional channel-tuning CRT linking member zones, bulletin board, future event countdown, meeting point.
2. **Jona Studio** — interactive mixing/beat lab. Later: a constrained step sequencer with authored samples; player actions produce a saved in-game sketch, never automatic music publication.
3. **Mel Comic Corner** — illustrated storytelling and arcade gateway; playable chapters are opt-in and use only approved art.
4. **Noel Sound Yard** — R&B/soul-oriented social lounge and listening activities, with approved songs.
5. **Record Shop** — discovery hub for BBB releases, collectibles, and playable song memories.
6. **Rooftop Jam** — small live stage, rhythm-game challenge, audience response, occasional band events.
7. **Later: subway and nearby blocks** — new sessions/venues as separate sectors only when streaming scale needs them.

Treat these as BBB creative zones rather than representations of real individuals; likenesses, dialogues and private music require separate approval.

## Player loop
Explore → encounter a song, poster, NPC or friend → voluntarily enter an activity → gain observable feedback → save a collectible/artifact or new access → return to a changed place. A player can also just hang out and listen.

## Three mini-games to prioritize
- **Rooftop Rhythm:** 96 BPM, 16 beats, tap timing; start only by interacting with stage; server evaluates scores. (M0 coded, visual-only pending audio)
- **Beat Lab:** assemble a short four-bar pattern from an approved sample library; trade or play sessions only with explicit owner controls. (M1 proposed)
- **Showtime Crew:** 2–4 players coordinate lights, song transitions, and crowd timing to prepare a BBB performance; no pay-to-win power. (M2 proposed)

Side activities: collect posters, photo scavenger hunts, comic arcade, skate/parkour routes, live event scavenger trails, dance emotes.

## Independent BBB Roblox architecture
This game is built from scratch using native Roblox services and Luau. No code, assets, saves, world data, repository links, or dependencies from another game are required. The BBB cast, music challenges, and neighborhood are the creative focus.

## One-server-authority approach
- Roblox **ServerScriptService** owns progression, rate limiting, rhythm scoring, music-event state and persistence.
- **StarterPlayerScripts** owns transient mobile/desktop UI.
- Roblox **ReplicatedStorage** carries authored content schemas/RemoteEvents, never privileged database keys or raw private recordings.
- NPCs can tick server-side at bounded cadence; off-zone state is abstract and does not fabricate evidence of interactions.
- If a later TypeScript sharing layer is worthwhile, isolate pure rules and compile with roblox-ts; Roblox platform APIs still need adapters.

## Milestones
**M0: implemented prototype (Studio playtest pending)**
Spawn, six labeled spaces, in-world BBB CRT channel travel, rooftop lift, poster hunt, server-scored rhythm minigame, touch/keyboard HUD, session fan points and best-effort DataStore.

**M1: first real music session**
Replace the geometric markers with mobile-friendly art; secure/upload **one** approved track into Roblox; synchronize stage FX to a beatmap; a simple studio step sequencer; NPC audience presence only when actually nearby.

**M2: social game**
Event director for scheduled showcases, crew objectives, join/leave recovery, 2–4 player co-op, user-enabled accessibility settings, player feedback evidence, basic in-world radio. Keep game available outside scheduled concerts.

**M3: living BBB universe**
NPC daily routes, off-screen abstraction, authored venue events, multiple song memories/comic scenes, cross-platform BBB website discovery. Link published releases rather than streaming private recordings through an unapproved external endpoint.

## Release and verification
1. Compile with Rojo; run Studio Play and 2-player local test.
2. Test teleport safety, proximity prompt activation, rhythm anti-spam, mobile UI, no accidental awards, datastore failure/rejoin.
3. Replace placeholders with licensed art/audio, check moderation and member portrayal approvals.
4. Review performance, accessibility and content ratings; keep the experience private before explicitly choosing to publish.

No Roblox Studio, audio upload, live server, public URL, or player telemetry is established merely by this branch.
