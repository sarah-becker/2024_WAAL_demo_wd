# WAAL Model Parameters — Sources & Verification Tracker

This document tracks numerical values used in the WAAL bycatch simulation scripts, their current
sources or status, and whether they need citation confirmation. Intended to become a reference
table for the manuscript methods.

---

## How to use this document

- **Status** column: `confirmed` = source verified | `needs citation` = value is used but source unclear | `needs verification` = value may need checking against source
- Add script number where each value first appears
- Eventually convert to a formal table for the manuscript

---

## Mitigation Efficacy (Script 08)

| Parameter | Value | Description | Source / Notes | Status |
|-----------|-------|-------------|----------------|--------|
| `eff_tori_lines` | 0.75 | Efficacy of tori lines alone | Literature — source TBD | needs citation |
| `eff_night_set` | 0.60 | Efficacy of night setting alone | Literature — source TBD | needs citation |
| `eff_line_weight` | 0.65 | Efficacy of line weighting alone | Literature — source TBD | needs citation |
| `eff_3of3` | ~0.965 | Combined 3/3 efficacy (multiplicative: `1 - (1-0.75)*(1-0.60)*(1-0.65)`) | Derived from above three values assuming independence | needs verification — is multiplicative combination appropriate? |

| `eff_1of3` | 0.75 | 1/3 mitigation efficacy = tori lines only (= `eff_tori_lines`) | Same source as `eff_tori_lines` | needs citation |
| `eff_2of3` | 0.90 | 2/3 mitigation efficacy = tori lines + night setting (multiplicative: `1-(1-0.75)*(1-0.60)`) | Derived from `eff_tori_lines` and `eff_night_set` assuming independence | needs verification |

**Notes:**
- The three individual efficacy values are combined assuming measures act independently on bycatch risk.
- Confirm whether these are mean values, medians, or point estimates from a specific study or meta-analysis (e.g., Melvin et al., Trebilco et al., or ACAP best practice guidelines?).
- `eff_1of3` and `eff_2of3` used in Part 8 (historical regulatory timeline scenario).

---

## Modeling Assumptions (Script 08)

| Assumption | Description | Alternative | Status |
|------------|-------------|-------------|--------|
| Initial stage vector = SSD | Population projections (Parts 2 & 3) are initialized at the stable stage distribution (SSD) of `m_base`, computed from its dominant eigenvector and scaled to N0. | Use observed Clay et al. 1990–1994 stage class counts as starting vector, with additional assumptions to split Clay's 5 classes across the 11 matrix stages. | needs flagging in methods |
| 2010–2019 regulatory gap | Part 8 historical scenario assumes 1/3 mitigation (tori lines) continued through 2010–2019 because no distinct regulatory break was identified for that period. | Use m_base for 2010–2019 (most conservative) or use a different efficacy level if evidence exists. | needs flagging in methods |
| `pairs_scale` denominator | Script 09 uses `pairs_scale = N0 / 1200` to convert observed breeding pairs to total-N units for plot overlays. 1200 is an interpolated estimate of Bird Island pairs circa 1990–94 (between 1370 in 1983/84 and 948 in 2003/04). | SSD-implied pairs at N0 = 1660 (21.4% of N0 in IS+IF+ES+EF stages). Gap reflects population being below equilibrium age structure in 1990–94 (mid-decline). | needs flagging in methods |

**Notes:**
- SSD assumption means all scenarios start from a theoretical equilibrium, not the observed 1990 population structure.
- Clay data has 5 classes (J2+3, IMM, FB, SB, NB); splitting these into 11 matrix stages would require assumptions about experienced vs. inexperienced breeder proportions within each class.
- Does not affect Script 06a results — 6a uses observed Clay counts directly for per-capita fishing mortality and does not project forward.
- Current approach is standard in demographic modeling when stage-resolved counts are unavailable. Should be stated explicitly in methods.
- `pairs_scale` secondary axis is calibrated to empirical pair counts, not the model's SSD. Should be noted in figure captions.

---

<!-- Add new sections below as you review each script -->

