# Open-source Roblox extraction shortlist (2026-11-10)

**Evidence:** Repository file trees, license metadata and selected actual source files inspected. These are external project descriptions and source observations, not BBB Studio gameplay tests. We do NOT import binaries or third-party audio/character models without separate asset rights review.

| Source | What to read | BBB application | Rights / decision |
|---|---|---|---|
| [Velmora](https://github.com/yashveer-singh-speaks/velmora) | `src/server/Cavern/DanceFloorService.luau`, `src/client/Cavern/DanceFloorClient.luau`, `src/client/Cavern/DartsClient.luau` | Server-owned dance-zone occupancy; optional arcade dart/aim challenge; separated client visuals | Source MIT. **TRANSLATE** dance-zone occupancy in M0; don't copy original game assets/emote IDs |
| [Sky Scramble](https://shuriken.studio/templates/sky-scramble) | downloadable `.rbxl` and `src/` per author's template description; inspect files after downloading | Short parkour/checkpoint loops, rounds, touch movement, cooperative race events | Advertised MIT; third-party assets may have separate terms. **STUDY** route/checkpoint mechanics; original BBB 5-platform course authored in M0 |
| [Slime Factory Tycoon](https://github.com/DLinacre/slime-factory-tycoon) | `src/server/Services/DataManager.luau`, `AchievementService.luau`, `src/shared/Net.luau` | Safer session-locked DataStore, autosaves, stat-driven achievement service, server-authoritative economy | Source MIT. **ADAPT NEXT**; requires migration + race tests, don't drop entire tycoon into BBB |
| [Industry Tycoon](https://github.com/EnigmaDevelopmentGroup/Industry-Tycoon) | `src/`, `default.project.json`, `tsconfig.json` | Example of Roblox TypeScript + Rojo modular project structure; potential beat lab typed shared logic | MIT. **STUDY** toolchain; not needed for initial Luau greybox |
| [Shuriken Studio's Elevator](https://shuriken.studio/templates) | complete place/template download with license | Physical elevator and vertical movement when expanding venues | Advertised MIT. **STUDY NEXT**; evaluate source and motion/physics in Studio first |
| [Shuriken Studio's Touge Drift](https://shuriken.studio/templates) | place and model sources | Optional later music-neighborhood delivery/racing side game | Advertised MIT. **LATER**, out of initial scope |
| [ROMania](https://github.com/RenderingByte/ROMania) | `StarterGui/ROManiaEngine.client.lua`, `SongListManager.client.lua`, `ReplicatedStorage/Maps/` | Rhythm map/song selection concepts | No top-level LICENSE was visible in inspected repository tree. **STUDY ONLY** until rights are resolved; don't copy code or song charts/audio |
| [Sigurd20202's Place](https://github.com/belarusian/Sigurd20202-s-Place) | `src/server/obby.server.luau`, `npcDialogue.server.luau`, `coinSystem.server.luau` | Checkpoint and world activity source study | No top-level LICENSE in inspected tree; **STUDY ONLY**, not a code transplant |
| [JonahPWR's Open Source Roblox Games](https://github.com/JonahPWR/Open-Source-Roblox-Games) | separate `.rbxl` binaries (Clickity Click, Guess-the-Game, etc.) | Small arcade-room inspirations | Repository claims MIT but notes some files are from third-party uncopylocked games; uncertain individual title/asset provenance. **STUDY ONLY** until traced to original authors |

## M0 implemented (original BBB adaptations, not cloned files)
- **Dance Floor:** a shared, light-up tiled BBB floor; the Roblox server scans each player's avatar root at bounded cadence and replicates a `BBBDanceFloor` boolean; the client only shows small dance-mode status. This adapts Velmora's *authority boundary*, not its visuals/emotes/music.
- **Backstage Parkour:** 5 original raised jump platforms, opt-in entry and exit prompts, and one-per-profile 30 Fans reward (saved as `posters.backstage` for M0 schema compatibility). Inspired by party-game loops and checkpoints, not copied map/scripts.
- **Already existing:** 96 BPM server-scored rooftop jam; three discovery posters, BBB TV channel portal.

## Next concrete extraction tasks
1. **DataManager** — replace the early M0 best-effort `GetAsync`/merge strategy with a single session-locked profile manager; handle failed initial load without overwriting saved data, concurrent joins, DataStore outage, autosave and migration of `posters.backstage`. Source study: `DLinacre/slime-factory-tycoon/src/server/Services/DataManager.luau`. Add tests for lost update, stale locks, rejoin and double session.
2. **Multiplayer event rounds** — build an opt-in 2–4-player rooftop dance showdown with server start/finish, round teardown, independent score/rank and clear consent; don't introduce pay-to-win.
3. **Beat Lab** — use a small four-bar original sequencer with approved/published Roblox audio assets; server-validate shared loops, save only on explicit request.
4. **NPC streets** — design BBB-only authored schedules and offscreen abstractions under one Roblox server authority, and connect proximity reactions to actually observed player actions.
5. **Asset pass** — source original BBB-approved artwork and uploaded audio IDs separately. Revalidate source asset licenses even when the repository software license is MIT.

## QA gates
- Luau type/syntax checks and Rojo build (not run in this chat).
- Roblox Studio Play and local 2-player test for all destinations, prompt distances, avatar respawn and mobile HUD.
- Dance mode must turn on/off only when server senses avatar on the floor, and never give points or trigger a song without permission.
- Parkour finish cannot be claimed from outside the finish area; repeated finish must grant zero points; rejoin must not grant reward again on successful saved load.
- Unexpected disconnect / failed profile load must not overwrite a previously saved player's progress.
- No new copyrighted game meshes, scripts, protected chart/audio assets, or real member representations imported without rights/approval.

**Current state:** source files committed in this standalone repository; no Studio playtest, CI run, public Roblox experience or media moderation verified.
