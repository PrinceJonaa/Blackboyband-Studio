# BBB World — retention, social discovery and monetization gates
**State (Nov 10, 2026):** server/client code migrated into this independent Roblox repository. No Studio build, multiplayer playtest, product IDs, live monetization or Roblox analytics results established.

## Design premise
The enjoyable activity must create the return visit, not fear of missing a reward. BBB players can hang out, explore, practice music and earn their way through optional careers with no spending. The social invitation is user-triggered and never mandatory.

## Implemented M0.1 gameplay loop
1. **Arrive** in BBB Plaza; players see a small QUESTS button and optional INVITE control.
2. **Play** three rotating UTC-day missions from: tune the CRT TV, qualify at 96-BPM Rooftop Jam, clear the sequential five-platform Backstage Parkour, or stay 20 sec on the BBB dance floor. Solo players can complete every day's set.
3. **Earn** 20 Fans per mission, 40 Fans and **one B-Side Stamp** for all three (100 Fans total from the daily set). Missed days cause no loss of prior stamps or punishment.
4. **Social bonus:** two or more actual players sharing the dance floor for 15 seconds each can get 15 Fans per day. This isn't an invite-spam reward; it's server-observed co-play.
5. **Free milestones:** 3 stamps mark eligibility for an Artist Title; 7 stamps mark eligibility for a Spotlight customization. Current prototype only sets replicated unlock attributes; **items and wardrobe interfaces are not built yet.**
6. **Return:** next UTC day, another three missions rotate. Older collectibles remain available for exploration; the timed rhythm game remains playable after the day's fan reward limit.

Technical contracts:
- Server grants mission completion only from validated world interactions, not client RemoteEvent claims.
- A player can inspect the mission board without participating.
- The remote `quest-view` only returns the state. Native `PromptGameInvite` is opened after player taps INVITE and the API reports eligibility.
- Session-owned DataStore profile saves existing M0 poster/fan records plus stamps, daily status and jam daily payout day. **Storage failure produces clearly marked temporary session play and never overwrites an older persisted profile.**
- Parkour reward requires an opted-in start plus touching all five platforms in order within 120 seconds.
- No real songs, user-generated uploads, paid products, creator assets or public publishing.

## Growth mechanics to build after playtesting
- **User-created souvenir:** a free approved-sticker photo booth or personal setlist to share with friends through Roblox's supported social surfaces.
- **Crew session:** player-led two-to-four-person mini-show where one selects the music, another controls lights and everyone can dance; the event ends cleanly if the host disconnects.
- **Weekly BBB listening room:** a scheduled session with an alternate anytime replay path; no false shortage timers or exclusive paid listening.
- **New music drop** updates the world and playlist through an explicitly moderated asset pipeline.
- **Optional invite:** user initiates it; never automatically prompts at launch and never claims someone joined until a real server join is observed.

## Monetization roadmap (NOT IMPLEMENTED)
**Phase 0 — now:** No purchase prompts. Confirm player retention and functional saves first.
**Phase 1 — after tests and moderation:** One-time cosmetic passes (BBB studio decor, CRT skins, stage light colors, photo booth backgrounds). Offer clear guaranteed contents; no effect on daily quest completion or talent progress.
**Phase 2 — if desired and after verification:** Repeatable *nonrandom* developer products, e.g., a chosen one-show confetti effect, purely decorative. Requires product IDs from the current Roblox experience and a single authoritative, idempotent `MarketplaceService.ProcessReceipt` handler that durably records purchase receipts before granting items.
**Defer:** subscriptions, rotating premium seasonal passes, pay-to-complete quests, purchased Fan points, gacha/loot boxes, artificial scarcity, paywalling BBB releases and trading. Avoid pressuring younger players.

Roblox docs:
- https://create.roblox.com/docs/production/monetization
- https://create.roblox.com/docs/production/monetization/developer-products
- https://create.roblox.com/docs/production/monetization/paid-random-items
- https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing
- https://create.roblox.com/docs/production/promotion/invite-prompts

## Release measurements to capture
Measure for each **consented/testing** cohort: first 5-minute meaningful action; Day-1 and Day-7 return rate; percent completing a daily quest and all three; session length; percent who willingly join co-play; failed saves, quest exploit attempts, and performance per device. Add anonymous aggregate creator analytics or platform-supported telemetry only after deciding the event schema and privacy review. Avoid storing other players' friend graphs or personally identifying activity logs in the profile.

**Gate before paid experiments:** Roblox Studio + 2-player playtest; reconnect/save verification; no duplicate rewards on rejoin, platform changes or rapid repeat prompts; review checkout screen and product rights; actual fun/return signal in voluntary testing.

## Manual QA sequence
1. In Studio, run `roblox/tests/QuestRules.spec.luau` as a Script in ServerScriptService (not a production source path).
2. Play with API services disabled: the temporary progress banner appears, quests still work but don't claim durable saves.
3. Use an isolated **test experience** with API services enabled; complete two missions, leave and rejoin, check progress, prevent duplicate award.
4. Finish all 3 daily quests: +100 fans and +1 stamp exactly once. Restart and repeat the same actions: zero extra daily quest reward.
5. Advance mocked day in isolated test harness: exactly 3 missions rotate, stamps persist, no forced consecutive-day streak.
6. Enter/leave dance zone, then invite a second test player and co-dance; only actual co-dance qualifies once per day. No reward just for opening invite.
7. Try parkour finish without starting or by skipping steps: no reward. Run in order: one-time collectible reward; revisit following day to count daily mission again.
8. Try rhythm taps without server-started session, spam same beat, pause/leave: no fabricated score.
9. Simulate a failed save/locked profile to ensure live data isn't overwritten by fallback. Review mobile UI, font sizes and zone access.
