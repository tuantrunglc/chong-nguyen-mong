# D1 — Indie game pipeline (idea → release → post-launch) — Round 1 digest

Accessed for all sources: 2026-10-15. Research firewall respected (web only, no project files).
Class codes: FEE = platform/engine pricing/policy (primary doc); BENCH = market benchmark data; SURVEY = industry survey; PM = postmortem/practitioner experience; VENDOR = vendor marketing (biased).

## Findings

### Steam release mechanics (primary docs)
1. **Claim:** Steam Direct fee is US$100 per new app, recoupable in the payment after the product reaches US$1,000 Adjusted Gross Revenue.
   - Source: https://partner.steamgames.com/doc/gettingstarted/appfee — Valve/Steamworks — pub date not shown (live doc) — accessed 2026-10-15 — confidence: high — class: FEE
2. **Claim:** A new product must have a public "Coming Soon" store page for at least two weeks before release; submit page for review at least 7 business days before you want it live.
   - Source: https://partner.steamgames.com/doc/store/coming_soon — Valve/Steamworks — live doc — accessed 2026-10-15 — high — FEE
3. **Claim:** Store-page review and build review each typically take 3–5 business days; Valve asks devs to plan at least 7 business days for each.
   - Source: https://partner.steamgames.com/doc/store/review_process — Valve/Steamworks — live doc — accessed 2026-10-15 — high — FEE
4. **Claim:** Steam Next Fest eligibility: public base-game store page, a publicly playable demo live by fest start, game not released before that edition ends, and a title may participate in only ONE Next Fest. Demo review deadlines: ~5 weeks before for Press Preview, ~3 weeks before for standard participation.
   - Source: https://partner.steamgames.com/doc/marketing/upcoming_events/nextfest — Valve/Steamworks — live doc — accessed 2026-10-15 — high — FEE
5. **Claim:** Steam requires disclosure of AI use in the content survey, split into "pre-generated" (made with AI during development, shipped in game) and "live-generated" (created while game runs); live-generated content must also describe guardrails. Live-generated adult-only sexual AI content is prohibited. AI content is reviewed under the same legality/infringement rules as other content.
   - Source: https://partner.steamgames.com/doc/gettingstarted/contentsurvey — Valve/Steamworks — live doc (no date shown) — accessed 2026-10-15 — high — FEE

### Engine costs
6. **Claim:** Unity Personal is free for customers with up to US$200,000 revenue+funding (effective with Unity 6, 17 Oct 2024); Runtime Fee cancelled (12 Sep 2024); Unity Pro US$2,310/yr per seat (or US$210/mo) from 12 Jan 2026; splash screen optional on Personal from Unity 6.
   - Source: https://unity.com/products/pricing-updates — Unity Technologies — page updated for 2026 pricing — accessed 2026-10-15 — high — FEE
7. **Claim:** Unreal Engine charges 5% royalty only on lifetime gross revenue above US$1M per product; revenue through Epic Games Store is royalty-free. (Official license page returned 403; claim corroborated by secondary reports.)
   - Source: https://roadtovr.com/unreal-engine-royalty-free-first-1-million-revenue/ (Road to VR, 2020) + search snippet of https://www.unrealengine.com/en-US/faq — accessed 2026-10-15 — medium (primary not fetched; >3 months old) — FEE
   - Godot cost (free, MIT license): unverified belief — not retrieved this run.

### Marketing / wishlist benchmarks (Chris Zukowski, How To Market A Game)
8. **Claim:** Launch wishlist tiers: Bronze 5,000 / Silver 8,000 / Gold 50,000 / Diamond 90,000, where revenue tiers are Bronze $0–10K, Silver $10K–249K, Gold $250K–999K, Diamond $1M+. Initial Coming Soon page launch yields ~23–68 wishlists (Bronze) to 426–4,275 (Diamond). Next Fest wishlists gained: Bronze 0–999, Silver 1,000–6,999, Gold 7,000–9,999, Diamond 10,000+. Launch guidance updated June 2026; Next Fest study Feb 2026.
   - Source: https://howtomarketagame.com/benchmarks/ — How To Market A Game (Chris Zukowski) — updated June 2026 — accessed 2026-10-15 — high (practitioner dataset, self-reported devs) — BENCH
9. **Claim:** "Wishlist inflation": games launched 2023–2025 sold roughly half as many units per wishlist in month one vs 2020–2022, but wishlists still predict launch sales about as well (Spearman 0.87 vs 0.89; n=160 games).
   - Source: https://howtomarketagame.com/2026/10/13/wishlist-inflation-is-real-but-they-are-still-important/ — How To Market A Game — 2026-10-13 — accessed 2026-10-15 — high — BENCH
10. **Claim:** Pre-fest wishlist count is the strongest correlate of Next Fest wishlist gains; games launching their demo well before Next Fest earned ~2.5x more fest wishlists than those launching the demo at the event. (Search-snippet level, aggregated from secondary guide citing Zukowski survey.)
    - Source: https://app.cinevva.com/guides/steam-next-fest-strategy (secondary) ; related primary https://howtomarketagame.com/2025/08/26/the-demo-effect-from-7000-wishlists-to-42000/ (not fetched) — accessed 2026-10-15 — low-medium — BENCH

### Industry context (survey)
11. **Claim:** GDC 2026 State of the Game Industry (2,300+ respondents): 52% think generative AI is having a negative impact (vs 30% in 2025, 18% prior year); ~36% of professionals use gen-AI tools (30% at studios); 28% laid off in past two years; one-third of indie studios reported layoffs; Unreal 42% / Unity 30% primary engine overall; 54% of established indies primarily use Unity; 11% of newer indies use Godot.
    - Source: https://gdconf.com/article/gdc-2026-state-of-the-game-industry-reveals-impact-of-layoffs-generative-ai-and-more/ — GDC / Informa — early 2026 (exact date not captured) — accessed 2026-10-15 — high for headline numbers; medium for engine split (summarized by fetch model) — SURVEY
    - Implication: AI-generated art is allowed on Steam with disclosure (F5), but sentiment among devs (and likely players) is increasingly negative — reputational risk for a history game.

### Timelines, scope, failure modes (postmortems)
12. **Claim:** Solo dev of The Ramp (Steam) planned a 1-month project, nearly derailed by feature creep, finished in 8 months by radically cutting to the core; worked ~3–4 focused hours/day; late playtesting with strangers caused a difficulty problem.
    - Source: https://www.gamedeveloper.com/design/postmortem-i-the-ramp-i- — Game Developer (Paul Schnepf) — 2021-09-23 — accessed 2026-10-15 — medium (single case, >2 yrs) — PM
13. **Claim:** Scope creep is the main reason first games aren't finished; recommended: timebox feature experimentation (~3 weeks), set a hard release deadline not far in the future, show the game early and often (local indie events give deadlines), and "forget about everything else and just ship it."
    - Source: https://www.gamedeveloper.com/production/how-to-finish-your-first-game-when-you-can-t-seem-to-finish-your-first-game — Game Developer (Mickey Sanchez) — 2015-04-06 — accessed 2026-10-15 — medium (old, opinion) — PM
14. **Claim:** Tower of Guns (solo-ish FPS) took 3,850 tracked hours over ~600 days; >600 hours prototyping in year one; marketing/business consumed ~25% of total project time (983+ hours).
    - Source: https://www.gamedeveloper.com/business/how-long-does-it-take-to-make-an-indie-game- — Game Developer (Joseph Mirabello) — 2014-04-07 — accessed 2026-10-15 — medium (single case, old, but hard data) — PM

### Outsourcing costs
15. **Claim:** Vendor-published 2D art outsourcing ranges: simple 2D character (concept+final) US$300–800, detailed US$800–2,500; 2D environments US$500–2,000; props US$200–800; low/mid-tier freelancers in Eastern Europe/SE Asia US$50–300 per asset; very cheap hourly rates ($15–25/h) can cost 40–60% more effectively due to revisions.
    - Source: https://whimsygames.co/blog/the-complete-guide-to-game-art-outsourcing-costs-timelines-and-how-to-choose-a-studio/ and https://pixune.com/blog/game-art-outsourcing-price/ — Whimsy Games / Pixune (outsourcing vendors) — 2025–2026 (exact date not captured) — accessed 2026-10-15 — low (vendor bias, search-snippet level) — VENDOR

## Rejected / downgraded
- Gitnux / strayspark / fungies stats ("indie average 18 months", "55% solo", "70% solo failure rate", "indie = 25% of Steam revenue"): no traceable methodology; NOT used as findings.

## Leads worth chasing (round 2)
- Zukowski "The demo effect: 7,000 → 42,000 wishlists" (2025-08-26) and "Do wishlists get old?" (2025-01-27) — demo timing, long pre-launch campaigns (Cosmoteer 4.5 yrs).
- Zukowski "How many wishlists ... coming soon page" — recommended timing of Steam page (commonly cited as 6–12+ months before launch; unverified).
- Game Developer podcast "Analyzing the 2026 GDC State of the Industry report" — indie funding details; GDC 2026 talk "Game Funding: Lessons From Outersloth".
- Unreal official FAQ (403 on license page) — retry via FAQ URL; Godot license page.
- VG Insights / Gamalytic data on median indie revenue & dev time (not searched yet).
- GMTK Game Jam / Ludum Dare / Vietnam-local jams (e.g. Global Game Jam Vietnam sites) as scoping/learning path.
- Valve pricing: Steam revenue share 70/30 (unverified belief; not retrieved).

## Looked for but could not find (this round)
- A primary, authoritative definition of phases (concept → GDD → prototype → vertical slice → production → alpha/beta → launch → post-launch) with deliverables per phase; only practitioner blogs surfaced. Phase model remains unverified belief.
- Methodologically sound survey of first-game solo dev duration/budget (median months, median spend). None found; only single postmortems.
- Any Vietnam-specific data on indie budgets or art outsourcing rates.
- Exact publication date of the GDC 2026 SOTI article.
- Steam's own dev-facing guidance on team roles / asset store use (none — asset-store and audio/music sourcing costs not researched).
