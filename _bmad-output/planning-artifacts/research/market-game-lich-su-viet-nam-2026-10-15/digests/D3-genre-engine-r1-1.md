# D3 — Genre, 2D/3D and engine choice for solo/small indies (round 1)

Accessed for all: 2026-10-15. Class: D = data-driven, O = official/primary, N = news report, V = vendor/opinion.

## Findings

### Genre performance on Steam
1. **Claim:** Of 20,282 Steam games released in 2025, 608 reached 1,000+ reviews (~3%). By hit rate: Open World Survival Craft 20.8% (15/72), Farming 8.3% (5/60), Roguelike Deckbuilder 5.1% (11/212), Simulation 4.1% (43/1,048), Management 3.4% (19/549), Horror 3.2%, Idle 2.79%, RPG 2.4% (28/1,158), Metroidvania 1.1% (3/269), Souls-like 0.8%, City Builder 0.5% (2/397), Puzzle 0.34% (14/4,022), 2D Platformer 0.18% (3/1,658). 3D Platformer: listed as 8/1,390 with a stated 0.05% rate; 8/1,390 actually works out to 0.58%, so the source's figure looks like a typo.
   - Source: https://howtomarketagame.com/2026/01/27/what-the-hell-happened-in-2025/ · How To Market A Game (Chris Zukowski) · 2026-01-27 · Confidence: high (primary dataset; I read the table through a fetch summary, not verbatim) · Class: D
2. **Claim:** "Narrative" was the #1 genre by count of 1,000+-review games in 2025 (51 titles), passing Horror (39), and it has grown every year. About 19 translated Chinese FMV visual novels reached 1,000 reviews. 4X, turn-based tactics and grand strategy are not broken out separately.
   - Source: same as #1 · Confidence: medium-high · Class: D
3. **Claim:** Median Steam revenue fell for 12 straight years: about $15,000 (2016) to $1,728 (2026 releases). 60.7% of games earn under $10k, 14.4% earn over $100k, and the top 1% take 84.6% of revenue. Best $100k hit rates by genre: Sandbox 27.3%, FPS 21.6%, RPG 19.4%. Lowest medians (about $1k or less): racing, puzzle, arcade, platformer.
   - Source: https://gameworldobserver.com/2026/09/01/the-median-revenue-of-games-on-steam-has-been-declining-for-12-consecutive-years · Game World Observer (reporting a "We Love It" study by I. Lambe et al.) · 2026-09-01 · Confidence: medium (secondary report; methodology not seen) · Class: N/D
4. **Claim (STALE, >2 yrs):** Median revenue by tag: Colony Sim $44k (292 games), Roguelike Deckbuilder $38k, 4X $35k, City Builder $22k, Grand Strategy $19k, Action RPG $4.3k. The median across all tag medians was about $2.6k.
   - Source: https://newsletter.gamediscover.co/p/which-genre-should-your-next-pc-game · GameDiscoverCo (data from Games-Stats) · 2021-03-03 · Confidence: low for 2026 decisions (outside the 2-year freshness window; use only as directional) · Class: D
5. **Claim:** The tension between #1 and #4: strategy and city-builder tags had high medians back in 2021, but in 2025 City Builder had a very low breakout rate (0.5%). Strategy/city-builder buyers do pay, but few new entrants break through.
   - Source: synthesis of #1 and #4 · Confidence: medium (inference) · Class: D-derived

### Historical theme
6. **Claim:** An academic study counted about 206 million copies of Steam games tagged "historical" sold. It groups them into three clusters: strategy/top-down, narrative action-adventure, and first-person action. All three lean heavily on violence as the core mechanic.
   - Source: https://scholarlypublications.universiteitleiden.nl/handle/1887/3212769 · Leiden University (Boom, Ariese, van den Hout, Mol, Politopoulos) · 2020 · Confidence: medium (old; abstract-level) · Class: D/academic
7. **Claim:** Manor Lords (a medieval city-builder made mostly by solo dev Greg Styczeń / Slavic Magic, published by Hooded Horse) launched 2024-04-26. It sold 1M copies in about 30 hours, 2M in 3 weeks, 3M in 9 months and 4M in 28 months. Its 173k peak concurrent players is a record for strategy games.
   - Sources: https://wnhub.io/news/finance/item-51918 · WN Hub · ~2026-08/09 (4M milestone) · Confidence: medium-high · Class: N; https://www.tweaktown.com/news/97926/ · TweakTown · 2024-04 · Class: N
   - Caveat: this is an outlier. A publisher (Hooded Horse) and years of wishlist build-up were involved, so it does not show what a typical solo outcome looks like.
8. **Claim:** Total War: Three Kingdoms (Creative Assembly, a AAA studio, not indie) sold over 1M copies in under a week. The source reports more than 4M Steam units, an estimated 60%+ of them in the Chinese region. This shows how big domestic-history demand can be in Asian markets.
   - Source: https://gamesbeat.com/total-war-three-kingdoms-1-million-sold/ · GamesBeat · 2019 (the 1M figure); the 4M / 60% figures come from a search snippet I could not trace to a dated source · Confidence: 1M high; 4M / 60% unverified · Class: N

### 2D vs 3D
9. **Claim:** Vendor estimates: a small 2D indie game costs $30k–$75k and takes 3–6 months, while a small 3D project costs $300k–$500k and takes 6–12 months. 2D teams run 4–8 specialists versus 15–40 for 3D. A high-quality 3D character takes "several weeks" against "a few days" for a comparable 2D character.
   - Source: https://www.cubix.co/blog/2d-vs-3d-game-development-cost-in-the-us/ · Cubix (outsourcing vendor) · 2026-07-02 · Confidence: low-medium (vendor estimates for outsourced studio work; direction credible, absolute numbers not applicable to a solo dev) · Class: V
10. **Claim:** The 2D 3D-pipeline argument: a 3D character needs modeling, UV mapping, texturing, rigging and animation, while 2D needs either frame-by-frame drawing or skeletal tools like Spine.
    - Source: search-result synthesis (hitem3d / Cubix / ixie blogs) · Confidence: medium (consensus, but non-data sources) · Class: V
    - Note: I found no data-driven source comparing pixel art with hand-drawn effort. See gaps.

### Engine choice
11. **Claim:** Unity: the Runtime Fee was cancelled on 2024-09-12 and never took effect. Unity Personal is free up to $200k in revenue plus funding, and the splash screen is optional from Unity 6. Unity Pro costs $2,310/yr or $210/mo per seat. A 5% price increase applies from 2026-01-12. Havok is no longer bundled from Unity 6.3.
    - Source: https://unity.com/pricing-updates · Unity Technologies · announced 2025-11-10 (page current at access) · Confidence: high · Class: O
    - Freshness: the announcement is about 11 months old, so it is outside the 3-month rule. It is the current official page, but check it again before deciding.
12. **Claim:** Unreal Engine: a 5% royalty applies only to lifetime gross revenue per product above $1M (the first $1M is exempt). Under the "Launch Everywhere with Epic" program (from 2025-01-01), the royalty drops to 3.5% if the game ships on the Epic Games Store at the same time as or before other stores.
    - Source: search synthesis of https://wnhub.io/news/engines/item-45651 (WN Hub, ~2024-10) and Unreal EULA summaries · Confidence: medium-high. The official unrealengine.com/license page returned HTTP 403 when I tried to fetch it, so this is not verified against the primary source this run. · Class: N
13. **Claim:** Steam engine share (VGI, Steam only). Unity has lost about 3 points of release share since 2021. Unreal releases grew about 12% year over year. Godot is about 1% of share, driven by Brotato, Buckshot Roulette and Dome Keeper, and VGI projects it at about 5% by 2030. Unity is "pretty healthy" among games selling under 1M units.
    - Source: https://discussions.unity.com/t/game-engines-report-2025-video-game-insights-steam-only/1681939 · Unity Discussions forum post summarising the VGI Game Engines Report 2025 · 2025-09-03 · Confidence: medium (second-hand summary) · Class: D/N
    - Unverified, search snippet only: "2024 Steam releases: Unity 51%, Unreal 28%, Godot 5%, GameMaker 4%, custom 13%", plus "Unreal out-earned Unity on Steam in 2024, 31% vs 26%". These are attributed to voxbooster/VGI but were not fetched. They conflict with the ~1% Godot figure in this item, possibly because that one measures units or revenue rather than releases.
14. **Claim:** Godot's official blog, using SteamDB's tech-detection data, describes "exponential growth" in Godot releases on Steam per year. It does not publish exact counts and warns that SteamDB detection figures are approximate.
    - Source: https://godotengine.org/article/godot-growth-stats-2026/ · Godot Foundation · 2026-05-06 · Confidence: medium (qualitative) · Class: O
15. **Claim:** Godot exports to Windows, macOS, Linux, Android, iOS and Web. It has a dedicated 2D engine, separate from 3D, with lights, shaders, tilesets, physics and particles. Consoles are not officially supported because console SDKs conflict with Godot's open-source license; console ports go through third parties such as W4 Games (founded by Godot core developers).
    - Source: https://en.wikipedia.org/wiki/Godot_(game_engine) · Wikipedia · accessed 2026-10-15 (snippet) · Confidence: medium · Class: N (tertiary)

## Leads (next round)
- Pull exact Godot / Unity / Unreal / GameMaker release counts for 2024–2026 from SteamDB (https://steamdb.info/stats/releases/?tech=Engine.Godot) or the WN Hub analytics piece (https://wnhub.io/news/analytics/item-50801). The "1,229 Godot releases in 2025" and "2,864 titles" figures are snippets only and unverified.
- The VGI Game Engines Report 2025 itself (app.sensortower / vginsights), for share by revenue tier.
- Fetch the official Unreal EULA through an alternative URL (unrealengine.com/en-US/eula/unreal) to confirm the $1M / 5% / 3.5% terms.
- howtomarketagame Q1 2026 report (https://howtomarketagame.com/2026/05/14/2026-q1-games/) and "Leftover research from 2025", for strategy, tactics and historical breakdowns.
- SteamDB "Historical" tag page (https://steamdb.info/tag/3987), for counts and top indie titles.
- Small-indie history successes not yet verified: Kingdom series, Against the Storm, Inkulinati, Shogun Showdown, Ostriv, and Chinese indie history games (e.g. small-studio Three Kingdoms titles, Wuxia RPGs).
- Engine learning-curve and beginner surveys (GDC State of the Industry 2026 engine usage).

## Gaps
- No fresh (≤2 yr) median-revenue-by-tag data for 4X, turn-based tactics, visual novel, action RPG or "Historical". The GameDiscoverCo data is from 2021.
- No data-driven comparison of pixel art and hand-drawn effort. The 2D/3D cost figures come only from vendor sources.
- Engine pricing freshness: the Unity page is about 11 months old and Unreal is not verified against the primary page. Neither meets the ≤3-month rule.
- No verified data on small Asian or Vietnamese historical indie successes.
- I found no learning-curve comparison data (only belief: Godot/GDScript is commonly described as beginner-friendly, which is unverified this run).
