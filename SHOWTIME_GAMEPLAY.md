# M1: BBB Crew Showcase — playable gameplay milestone

**Status:** Draft GitHub branch. All source changes are isolated in `PrinceJonaa/Blackboyband-Studio` only. **Not compiled, tested in Studio, or published.** No modifications to the BBB website or another game.

## Play loop
1. Join the standalone BBB Roblox game, go to the rooftop via lift or CRT TV.
2. At the luminous **CREW SHOWCASE / JOIN HERE** prompt, press the Roblox proximity interaction.
3. An **opt-in 9-second lobby** accepts 1–4 players. Roles are assigned in join order: **LEAD** (beats 1,3), **LIGHTS** (beats 2,4), **HYPE** (beat 4), **CREW** (beats 1,4), repeated over four 4-beat phrases.
4. A synchronized **96 BPM / 16-beat show** starts after a 2-second countdown. Press **G** (desktop), **X** (controller), or the on-screen **HIT** button. The server checks the nearest target beat from `workspace:GetServerTimeNow()` and grades PERFECT (±95ms), GOOD (±195ms), OFF (±280ms), or WAIT on other beats.
5. Four physical stage lamps change colors each beat, and the UI reports the crowd-energy percentage and individual hits when the round ends.
6. If a player gets 2+ successful hits, they earn **15 Fans** once per UTC day. With 2+ actual participants and 8+ total successful hits, the first qualifying run of the day earns **25 Fans** instead. Returning players may practice unlimited times for fun.
7. Solo Rooftop Jam and Crew Showcase can't take the stage simultaneously. Performer UI is separated from solo UI.

## Why this first
- Actually tests cooperative **music-show rhythm** and coordinated roles, rather than converting every open-source system into an empty room.
- Uses an already playable rooftop environment, keeping scope tight.
- Validates a loop people can invite friends to voluntarily, and can test solo without booking four testers.
- Provides measured gameplay challenges before audio uploads, production meshes, long-term currency economy, quests, or Robux monetization.

## Technical boundaries
- `src/server/ShowtimeRules.luau` is a pure rules module and can be independently unit-tested. `Showtime.luau` owns the lobby, participants, role, server-time judgments, per-player repeat protection, 75ms remote throttling, and final results.
- `src/client/Showtime.client.luau` only displays synchronized cues and sends a plain `hit` signal. It does **not** provide scores, beat indexes, payment information, or client timestamps.
- `World.server.luau` places stage fixtures and interaction in-world, validates avatar position, and awards currency only if eligible.
- `Progression.luau` persists a `showRewardDay` value, migrating previous records without deleting posters, stamps, or solo-jam rewards.
- No unauthorized tracks or audio asset IDs; sound can be attached later after Roblox asset upload and rights/permissions verification. See Roblox sound docs: https://create.roblox.com/docs/sound

## Studio acceptance checklist
- [ ] `rojo build -o BBBWorld.rbxl` succeeds.
- [ ] One person can open lobby, receive LEAD role, do a show with `G` and touch, see stage lights and results.
- [ ] 2–4 people can join same lobby and receive distinct roles; correct beat cues and HUDs.
- [ ] Player 5 cannot join a full lobby. Player cannot join once show started.
- [ ] 2+ hits = 15 Fans (solo) or 25 Fans (multi with shared >=8 hits); less than two hits = no Fans.
- [ ] Replay on the same UTC day awards no extra Fans. Rejoin persists reward-day when DataStore is healthy.
- [ ] Player leaving a lobby removes seat and assigns next role correctly. Disconnect during show never crashes round.
- [ ] Abusive `BBBShowtimeEvent:FireServer("hit")` spam or remote calls far from stage cannot award points.
- [ ] Solo Rooftop Jam and Crew Showcase cannot run concurrently.
- [ ] Music is absent unless approved audio IDs are explicitly configured; visual show remains accessible.
- [ ] Mobile HUD doesn't overlap the Roblox chat or prevent walking.
- [ ] On device, test clock skew/latency timing and adapt forgiveness window before public launch.
- [ ] Test a full 2-player session in Roblox Studio and record short footage before marking the PR ready.

## Next gameplay after this
**BBB Beat Lab:** an eight-/sixteen-step pattern editor with 3–4 authored instruments, 96 BPM visual timeline and player-approved loops. Add sounds only after uploading licensed, accessible audio. Later connect Beat Lab patterns to **Showtime** through an explicit player opt-in; never play another player's recording automatically.

Do **not** add monetization yet. First measure repeat participation and whether the cooperative rhythm game is genuinely fun to play.
