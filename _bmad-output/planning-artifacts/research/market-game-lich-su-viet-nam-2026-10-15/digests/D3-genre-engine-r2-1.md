# D3 Genre / Engine — Round 2 digest (r2-1)
Accessed: 2026-10-15 for all sources. Tool calls: 18. Sources used: 12.
Class: M = market data (third-party estimate), V = vendor/self-report, P = practitioner postmortem, C = community/blog, E = encyclopedic.

## Findings

### Lead 1 — Genre performance on Steam (2024–2026)
1. **Claim:** Steam-wide baseline for the Jan 2024–Jun 2025 release cohort: 17.3% of games reached 100+ reviews, 4.2% reached 1,000+ reviews, median 11 reviews, median paid list price $4.99. The source treats 1,000 reviews as a rule of thumb for about $150k gross.
   Source: https://www.steampageanalyzer.com/niches/tactical-rpg — Steam Page Analyzer — pub 2026-09-27 — accessed 2026-10-15 — confidence: medium (one aggregator; review-count method; the $150k rule is a heuristic) — class M
2. **Claim:** Tactical RPG tag, same cohort: 21.9% reached 100+ reviews, 5.4% reached 1,000+ (1.3x baseline), median 15 reviews, median price $9.99. Releases rose from 353 (2024) to 423 (2025) and 393 by 27 Sep 2026. Games at $20+ reached 1,000 reviews 25.5% of the time; games under $5 only 0.7%.
   Source: same as F1 — confidence: medium — class M
3. **Claim:** Roguelike Deckbuilder tag, same cohort: 38% reached 100+ reviews, 7.8% reached 1,000+ (about 2x baseline), median 52 reviews, median price $9.99. Releases went 143 (2024), 224 (2025), 316 by 27 Sep 2026, so supply is growing fast. The $15–19.99 tier did best (22.7% reached 1,000 reviews).
   Source: https://www.steampageanalyzer.com/niches/roguelike-deckbuilder — Steam Page Analyzer — pub 2026-09-27 — accessed 2026-10-15 — confidence: medium — class M
4. **Claim:** Visual Novel tag, same cohort: 25.2% reached 100+ reviews but only 4.0% reached 1,000+ (at baseline), median 24 reviews, median price $7.99. Releases: 1,216 (2024), 1,458 (2025), 1,416 by 27 Sep 2026. VNs priced $15+ reached 1,000 reviews 7.7–8.2% of the time.
   Source: https://www.steampageanalyzer.com/niches/visual-novel — Steam Page Analyzer — pub 2026-09-27 — accessed 2026-10-15 — confidence: medium — class M
5. **Claim:** Roguelite revenue on Steam was about $400M in 2025 (+80% on 2024) and about $500M in H1 2026. Most of the growth was concentrated at the top: Slay the Spire 2 made an estimated $108M in March 2026 alone. Roguelike/roguelite releases grew from 432 (2021) to 1,926 (2025). The article cites SteamDB, Alinea, GameDiscoverCo and Zukowski.
   Source: https://recognizingpatterns.substack.com/p/the-roguelite-cull-hasnt-happened — Abbas Saleem Khan (Substack) — pub 2026-07-19 — accessed 2026-10-15 — confidence: medium-low (secondary compilation of estimates) — class M
6. **Claim:** Shogun Showdown (feudal-Japan-themed tactical roguelite) is by Roboatino, a solo developer (Mirko). Version 1.0 released September 2024 on PC and consoles.
   Source: https://en.wikipedia.org/wiki/Shogun_Showdown — Wikipedia — pub n/a (live page) — accessed 2026-10-15 — confidence: medium — class E
7. **Claim:** Shogun Showdown has an estimated ~150.1K Steam copies and about $1.4M gross Steam revenue as of 2026-07-22. The source rates this estimate "medium confidence" and it covers Steam only.
   Source: https://raijin.gg/app/2084000/Shogun_Showdown — Raijin.gg — data date 2026-07-22 — accessed 2026-10-15 — confidence: low-medium (model estimate) — class M
8. **Claim:** Thronefall, by the two-person team Grizzly Games, sold over 1M copies. It sold 315K in its first two months of Early Access (from 2023-08-02). In Dec 2025 its publisher Mythwright acquired the IP. Note: Thronefall uses a medieval-fantasy setting, not real history.
   Sources: https://www.gamesmarket.global/indie-hit-thronefall-sells-over-one-million-copies-588b03986d04328e71544cbcb1d1b454/ (GamesMarket, pub date not captured); https://www.pocketgamer.biz/mythwright-acquires-minimalist-strategy-title-thronefall (PocketGamer.biz, ~Dec 2025) — accessed 2026-10-15 — confidence: medium (search snippets; articles not opened) — class M/V

### Lead 2 — Engine share
9. **Claim:** Engine share of 2024 Steam releases (VGI, 13k+ games): Unity 51%, Unreal 28%, custom 13%, Godot 5%, GameMaker 4%. Revenue share: custom 41%, Unreal 31%, Unity 26%. Unity dominates the "tiny/small" games (<100k units). Godot is the only small engine growing significantly.
   Source: https://gamedevreports.substack.com/p/video-game-insights-game-engines — GameDev Reports (summarising Video Game Insights "Big Game Engine Report 2025") — pub 2025-02-10 — accessed 2026-10-15 — confidence: medium-high (large sample; methodology not disclosed) — class M
10. **Claim:** Godot release counts per SteamDB: about 1,229 new Godot releases in 2025, about 22x growth over six years. In rolling windows: 618 (2023-24), 1,500 (2024-25), 2,864 (2025-26). Godot's own blog cites the same SteamDB source and warns the numbers are "approximate" and can change with SteamDB's detection algorithm.
    Sources: https://wnhub.io/news/analytics/item-50801 (WN Hub, pub date not captured); https://godotengine.org/article/godot-growth-stats-2026/ (Godot Foundation, pub 2026-05-06) — accessed 2026-10-15 — confidence: medium for the direction, low for exact counts — class M/V
    **Reconciling the numbers:** VGI's 5% (2024, share of all releases) and SteamDB's ~1.2–2.9K (raw counts) measure different things, so they do not conflict. With about 18–20K Steam releases a year (unverified belief; not retrieved this run), 2025-26 Godot would be roughly 10–15% of releases. That figure is unverified. I found no 2025/2026 cross-engine percentage table this run.

### Lead 3 — Vietnamese community / learning
11. **Claim:** Viblo (a Vietnamese dev platform) published "5 reasons Godot 4 suits solo game devs in Vietnam" (2026-04-20). Its reasons are general ones: free/MIT licence, light editor, 2D strength. It says Unity remains the most popular choice for solo devs. It names no Vietnamese Godot community and gives no member counts. The author account is "Ziva Engine", a Godot-adjacent tool vendor, so it may be biased. A search snippet from another Viblo post said Vietnamese studios such as Amanotes and Young Buffalo use Unity; I did not verify this in the fetched article.
    Source: https://viblo.asia/p/5-ly-do-godot-4-phu-hop-voi-game-dev-solo-tai-viet-nam-1QLxnpYd4Aw — Viblo / Ziva Engine — pub 2026-04-20 — accessed 2026-10-15 — confidence: low — class C/V

### Lead 4 — 2D vs 3D cost/time (non-vendor)
12. **Claim:** Failbetter Games moved Sunless Sea from 3D-workflow Unity to Unity's 2D tools. They reported that asset work "that took 30 minutes is now taking 5", plus better collision and optimisation.
    Source: https://www.failbettergames.com/news/2d-or-not-2d — Failbetter Games (developer blog) — pub 2014-02-11 — accessed 2026-10-15 — confidence: medium (one first-hand anecdote; dated) — class P
13. **Claim:** Marian (Holowka): the team spent more than a year on a 3D Unity prototype, then restarted in 2D. The team shrank from about 8 people to 2. Reasons given: physics complexity, art asset load, team management and funding. No numbers given.
    Source: https://www.gamedeveloper.com/design/marian-from-3d-to-2d — Game Developer (Alexander Holowka) — pub 2011-02-14 — accessed 2026-10-15 — confidence: low-medium (anecdote, old) — class P

## Gaps
- No Steam niche data for the "Historical" tag (the steampageanalyzer /niches/historical page returned 404). No Gamalytic, VG Insights or howtomarketagame genre report retrieved for history-themed games.
- No team-size or sales data retrieved for Inkulinati, Kingdom Two Crowns, Banished, Sengoku Dynasty, Wartales, The Last Spell, Pentiment or Citizen Sleeper.
- No 2025/2026 cross-engine percentage share (Unity vs Godot vs Unreal vs GameMaker) found. The newest comparable data is VGI for 2024. SteamDB tech pages were not fetched directly.
- No named Vietnamese Godot or Unity community (Facebook/Discord) with member counts. No Vietnamese-language course inventory.
- No 2025–2026 beginner learning-curve comparison retrieved. No GDC talk with quantified 2D vs 3D cost. The postmortem evidence is from 2011–2014 and anecdotal.
- No "narrative adventure" tag data, and no Steam data on success rates for history-themed games specifically.
