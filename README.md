# Metro Detroit Golf Course Analysis

A data project answering a simple question — **where should you live in Metro Detroit if you golf?** — and using it as a vehicle to demonstrate spatial analysis, data collection, and a fix for a common statistical pitfall in ratings data.

Covers all **127 golf courses** across the tri-county area (Wayne, Oakland, Macomb): public, private, 9-hole, and par-3.

---

## Key findings

- **Best place to live for golf:** the West Bloomfield / Commerce area — within 15 miles of **66 courses**, more than any other point in the tri-county.
- **Oakland County dominates** with 66 courses, but **25 are private clubs** — so the densest area for golf isn't the densest area you can actually book a tee time.
- **Star ratings are misleading at low review counts.** Three courses tie at 4.8 stars, but once ratings are weighted by review volume, the leaderboard reorders and small-sample courses drop out.

---

## The analysis

### 1. Course density — "closest to the most courses"
For every point on a grid across the tri-county area, counted how many courses fall within a 15-mile radius (haversine / straight-line distance), then mapped the result as a heatmap to find the maximum-coverage location. A second kernel-density heatmap (built in Tableau) independently confirms the same hotspot — convergent evidence from two methods.

> Note: distances are **straight-line, not drive time.** A true drive-time analysis would use road-network isochrones; this is a first-order approximation.

### 2. Difficulty vs. satisfaction
Plotted each course by USGA slope rating (difficulty) against its rating, with k-means clustering to surface natural groupings. Private clubs cluster as tough *and* well-reviewed; public courses spread wider.

### 3. Review-weighted ratings (the ratings "trap")
Raw Google star ratings treat a 4.8 from 42 reviewers the same as a 4.6 from 1,000 — but small samples sit at the extremes and haven't stabilized. Applied a Bayesian shrinkage adjustment (the method IMDb uses for its Top 250):

```
adjusted = (v * R + m * C) / (v + m)
```

where `R` = course rating, `v` = its review count, `C` = global mean rating across all courses, and `m` = a confidence constant (median review count). This pulls thinly-reviewed courses toward the mean and rewards ratings backed by real volume.

---

## Data sources

| Field | Source |
|---|---|
| Course locations, ratings, review counts | Google Places |
| Difficulty (slope / course rating) | USGA National Course Rating Database |
| County / municipality boundaries | US Census (TIGER via `tigris`) |
| Course roster & type (public/private) | Compiled from Places, county directories, Golf Association of Michigan |

---

## Tools

- **R** — `geosphere` (15-mile grid + haversine), `ggplot2` / `sf` / `tigris` (mapping), Bayesian rating calc
- **Tableau** — kernel-density heatmap, slope-vs-rating scatter with k-means clustering, county breakout
- **Python** — data consolidation and CSV wrangling
- **Google Places API** — location and ratings pull

---

## Files

- `course_coordinates.csv` — course names, lat/long, county
- `google_ratings.csv` — current Google rating and review count per course
- `bayesian_ratings.csv` — raw vs. review-adjusted rating, ranked
- `slope_ratings.csv` — USGA slope by course
- `golf_hotspot.R` — 15-mile grid search
- `golf_hotspot_map.R` — mapping / visualization

---

## Caveats & limitations

- **Not a certified census.** The 127-course roster is thorough but assembled from public sources; a handful of small private or 9-hole courses may be missing, and course counts are best-effort.
- **Straight-line, not drive time.** Distances ignore roads, traffic, and water — a spot 14 miles away across Lake St. Clair isn't a 14-mile drive.
- **Ratings ≠ quality.** Google ratings measure satisfaction, not course conditioning or design; slope measures difficulty, not desirability. They're kept as separate axes deliberately.
- A few Google listings were flagged and excluded or corrected where they pointed to the wrong entity (a pro shop, a restaurant, or a shared listing).

---

## Author

**Ben Kronk** — Strategy & Competitive Intelligence
Built as a portfolio project. Always happy to talk golf, or business.
