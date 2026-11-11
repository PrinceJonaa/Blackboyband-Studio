# BLACK BOY BAND — Roblox Studio

A **standalone Black Boy Band Roblox game**, built in Luau and Rojo. This is the game's own codebase, progression system, world, and art pipeline. It does not depend on the BBB website or any other game.

## What's playable after opening in Roblox Studio

- Walk around BBB Plaza, Jona Studio, a record shop, Mel's Comic Corner, Noel's Sound Yard, and a raised rooftop.
- Use *in-world* Roblox proximity prompts, including a rooftop lift and return, plus a large BBB CRT TV that tunes between world zones.
- Collect three different BBB posters; each is counted only once per player.
- Step onto an illuminated multiplayer BBB Dance Floor; occupancy is decided on the server and reflected in a small HUD indicator.
- Enter the optional five-platform Backstage Parkour course from Noel's area; first finish grants +30 Fans, with best-effort saved completion.
- Source/rights extraction registry: [`OPEN_SOURCE_EXTRACTION.md`](OPEN_SOURCE_EXTRACTION.md).
- Play a **96 BPM / 16-beat visual rhythm challenge** at the rooftop stage, using **F** or the mobile **TAP** button. Server time judges taps and the server awards fan points.
- Open the voluntary QUESTS board to see three rotating daily activities; each awards 20 Fans, and completing the daily set grants 40 Fans plus one B-Side Stamp.
- Two or more players can earn a once-daily **Crew Dance** reward by staying together on the dance floor for 15 seconds.
- Use the INVITE control to open a native Roblox friend invitation, only after you tap it. Inviting someone does not itself award points.
- Free progress unlock indicators appear at 3 and 7 stamps; cosmetic assets and UI have **not** been built yet.

- Save poster/fan progress plus quests and stamps using a server-owned, session-locked DataStore record. If Studio API access is unavailable or a record cannot be locked, gameplay remains temporary and must not overwrite previous saved progress.
- A **BBB Crew Showcase** rooftop activity now supports 1–4 people with four timed roles (Lead, Lights, Hype, Crew), stage light feedback, a shared crowd score, and once-per-day Fans. Players start/join via an in-world proximity prompt, then use **G** / controller **X** / touch **HIT**. The 96 BPM show currently uses visual timing only, pending approved BBB audio.
- Multiple Roblox players can join and explore the same place. No live concert scheduling or collaborative music production yet.

**Current media:** Placeholder geometry/signage only; no private or released recordings, artwork, member likenesses, user secrets, monetization, or copyrighted outside assets are imported. The rhythm activity is **visual-only until approved Roblox audio assets are uploaded and connected**.

## Open in Studio (Rojo)

1. Install [Roblox Studio](https://create.roblox.com/) and [Rojo](https://rojo.space/), including its Studio plugin.
2. In this `roblox/` directory, run `rojo build -o BBBWorld.rbxl` and open the generated file in Studio; alternatively run `rojo serve` and connect the plugin to an open place.
3. Press **Play**. The server script creates the greybox map at runtime (the world is deliberately not prebuilt in Edit mode).
4. Walk to the labeled **ROOFTOP LIFT** pad; press the proximity prompt to go up. Start the jam at the **ROOFTOP JAM** interaction marker.
5. Test on desktop and phone emulation. To exercise persistent DataStores in Studio, enable Studio API services only in a test experience that you own and explicitly intend to test.

## Acceptance checklist

- [ ] Spawn and walk to all named locations without stuck colliders.
- [ ] Rooftop lift and return work with multiple player avatars.
- [ ] BBB TV cycles between all five destination channels; each landing is safe.
- [ ] First-time poster pickup grants points; duplicate pickup grants zero.
- [ ] Daily three-mission rotation gives 20 Fans each, 40 bonus and one stamp once per UTC day.
- [ ] An incomplete day or missed day never deletes earlier stamps.
- [ ] Two-player dance gives 15 Fans once per day per participating player, only after server-observed occupancy.
- [ ] The INVITE button opens only on player request; no reward for opening or sending an invitation.
- [ ] Rooftop minigame starts only from proximity prompt; a remote tap without an active session grants nothing.
- [ ] Crew Showcase lobby admits 1–4 people and each role has distinct cues; server checks beat timing and distances.
- [ ] Showcase's daily reward is paid only once, and no solo stage session can overlap it.
- [ ] Duplicate taps on the same beat are ignored; round reward is awarded only after finishing and qualifying.
- [ ] Desktop F and mobile TAP work; timer/feedback stays legible.
- [ ] Rejoin loads existing M0 fans/posters and new quest/stamp data with DataStore enabled in a separate test experience; failed/locked loads never overwrite existing saves.
- [ ] Dance floor occupancy toggles on enter/exit and after respawn, including multiple users.
- [ ] Backstage parkour route is reachable; finishing from away from the platform fails, and repeated completion awards zero.
- [ ] Test actual multiplayer, reduced-motion/accessibility, and final audio asset permissions before release.

**Evidence:** Source implemented on an isolated branch. No Roblox Studio playtest, render verification, CI, publication, or asset moderation has been performed from this chat.

**Architecture:** Roblox's built-in replicated world + server script, a client HUD script, and one RemoteEvent for rhythm input and feedback. The server owns scores, quest rewards, and persistent player data. Gameplay is implemented in Luau and is independent of other projects.

**Project boundary:** this repository is exclusively for the Black Boy Band Roblox game. Web apps and other game projects remain outside this codebase.

## Retention and monetization

The first implementation deliberately has **no Robux purchases**. See [retention and monetization plan](RETENTION_AND_MONETIZATION.md) for the daily set, crew reward, launch analytics, cosmetic-only purchase experiments, and platform/rights gates. Quest rules are in `src/server/QuestRules.luau`; persistence and lock ownership are in `src/server/Progression.luau`. A manual Studio-only logic test is in `tests/QuestRules.spec.luau`.

**Repository:** https://github.com/PrinceJonaa/Blackboyband-Studio

**Important:** This public source repository contains only standalone game scripts and documentation, not private audio, unreleased tracks, credentials, or other projects' assets.

## M1 Gameplay — Crew Showcase

[Full gameplay instructions and acceptance criteria](SHOWTIME_GAMEPLAY.md). The game is in a draft PR pending a real Roblox Studio build, mobile playtest, and 2–4 person session. **No real-money products or audio uploads** are included.
