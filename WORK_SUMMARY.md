# Work Summary - WAAL Bycatch Analysis

## Session: January 12, 2026

### Overview
Major revision to bycatch estimation methodology. Identified and corrected conceptual issue in script 03b regarding spatial allocation of Bird Island bycatch. Implemented corrected approach in script 03c.

---

## Key Accomplishments

### 1. Identified Conceptual Issue in Script 03b

**Problem discovered:**
- Script 03b scaled Bird Island distributions by **global average** (15.67% of total WAAL population)
- This assumed BI represents 15.67% of birds uniformly across all space
- **Reality**: % BI varies spatially from 0-60% depending on location

**Why this matters:**
- Near South Georgia: BI may be 60% of local WAAL population
- Near Crozet: BI may be only 5% of local WAAL population
- Scaling by global average (15.67%) everywhere underestimates this heterogeneity

### 2. Confirmed Theoretical Foundation

**Verified catchability framework:**
- Catchability (β) is analogous to Lotka-Volterra interaction coefficients
- Also equivalent to fisheries catchability coefficient (q)
- All represent per capita interaction rates: β = probability of capture per hook per bird
- BPUE is a **fishery property** (fishing practices), not a **population property**
- Therefore, BPUE should not be scaled by bird composition

**Key equations:**
```
β = (BPUE × Total_Hooks) / Σ(Hooks × Birds_all_WAAL)
Bycatch = Σ(Hooks × Birds × β)
```

### 3. Compared Population Distribution Datasets (Script 02b)

**Created comparison script** to validate using both Carneiro and Clay data:
- **Carneiro et al. 2020**: Population-specific distributions (South Georgia)
- **Clay et al. 2019**: Age-class specific distributions (Bird Island tracking)

**Results:**
- Pearson correlation: r = 0.98 (98% of variance shared)
- Spearman correlation: rho = 0.94 (rank order highly consistent)
- **Conclusion**: Distributions are highly consistent, safe to combine

**Interpretation:**
- Both datasets capture the same underlying BI spatial distribution
- Small differences due to different time periods, sample sizes, methods
- Validated hybrid approach: Carneiro for population allocation, Clay for age partitioning

### 4. Implemented Corrected Method (Script 03c)

**New approach:**
```
Step 1: Calculate catchability using ALL WAAL (same as 03b)
  β = (BPUE × H_total) / Σ(hooks × birds_all_WAAL)

Step 2: Calculate total WAAL bycatch density in each cell
  total_bycatch[i] = hooks[i] × birds_all[i] × β

Step 3: Allocate to BI using LOCAL % BI (NEW - uses actual spatial variation)
  BI_bycatch[i] = total_bycatch[i] × pct_BI[i]

  where pct_BI[i] comes from script 02 (Carneiro-based)

Step 4: Partition BI bycatch by age class (using Clay distributions)
  BI_age_bycatch[i] = BI_bycatch[i] × age_weight[i]

  where age_weight[i] comes from Clay age-class distributions
```

**Key innovation:**
- Uses **actual local % BI** that varies spatially (0-60%)
- NOT global average (15.67%) applied uniformly

### 5. Compared Results: 03b vs 03c

**Total bycatch:**
- 03b: 284.3 birds/year
- 03c: 312.1 birds/year
- Change: +27.8 birds (+9.8%)

**By fishery (more revealing):**

| Fishery | 03b | 03c | Ratio | Change |
|---------|-----|-----|-------|--------|
| Pelagic | 147.9 | 196.4 | 1.33× | +33% |
| Demersal | 136.4 | 115.7 | 0.85× | -15% |

**Interpretation:**
- **Pelagic fishing** occurs more in areas with OTHER populations (not BI)
  - BI gets 14.2% of pelagic bycatch (vs 32.1% mean BI across space)
  - Pelagic fleets operate widely across Southern Ocean
  - Less concentrated near South Georgia

- **Demersal fishing** occurs more near BI birds
  - BI gets 19.5% of demersal bycatch (closer to 32.1% mean)
  - Demersal fisheries target shelf/slope near islands
  - South Georgia is major toothfish fishery

**Why this matters:**
- 03b underestimated pelagic risk to BI (by 33%)
- 03b overestimated demersal risk to BI (by 15%)
- The global average approach masked real spatial patterns

### 6. Discussed Future Enhancements

#### Regional Catchability Approach (Future Script)
**Concept**: Stratify by region × fishery using literature BPUE

```r
# For each region (South Atlantic, Indian Ocean, etc.):
β_region = (BPUE_region × H_region) / Σ(hooks × birds)_region

# Then apply within region using local % BI (same as 03c)
```

**Benefits:**
- Captures regional differences in fishing practices/mitigation
- South Georgia (good mitigation) vs IUU areas (poor mitigation)
- Still maintains catchability framework within regions
- Combines regional BPUE variation with fine-scale spatial allocation

**Data needs from lit review:**
- BPUE (essential)
- Geographic bounding box (essential)
- Fishery type: pelagic/demersal (essential)
- Sample size: hooks observed (essential)
- Time period: years data collected (essential)
- Mitigation status: present/absent/type (high priority)
- Fleet/country (nice to have)
- Confidence intervals (nice to have)

**For ~20-30 papers**: Should be sufficient for 3-5 regional strata per fishery

#### Age-Specific Catchability
**Biological plausibility:**
- Juveniles may be more naive, aggressive foragers → higher catchability
- Adults more experienced, cautious → lower catchability
- Breeding vs non-breeding may have different vulnerability

**Data reality:**
- Literature rarely reports age-specific bycatch
- Most studies report BPUE for all ages combined
- Age at sea is difficult to determine

**Recommended approach:**
1. Note as assumption in methods (constant catchability across ages)
2. Look for any age-specific data during lit review
3. Conduct sensitivity analysis in demographic model
4. Document as uncertainty/future research

#### Temporal Variation in BPUE
**Critical insight:**
- Current BPUE estimates may be post-mitigation
- BI population decline may reflect historical (pre-mitigation) mortality
- Need to match BPUE time period to population trend data

**For lit review:**
- Extract year of data collection (not just publication year)
- Note mitigation status (pre/post, mandatory/voluntary)
- Stratify BPUE by time period
- Can estimate historical mortality for demographic model

### 7. Supervisor Feedback and Script 03d Development

**Supervisor consultation confirmed 03c approach and suggested refinement:**

#### Confirmation of 03c Theoretical Framework
- ✓ **BPUE should NOT be scaled by % BI** - correct, it's a fishery property
- ✓ **Use catchability (β) derived from BPUE for all WAAL** - theoretically sound
- ✓ **Allocate to BI using local composition** - biologically realistic
- **03c approach validated!**

#### Suggested Enhancement: Spatial Catchability (Script 03d)
Instead of single global β, create **cell-specific catchability map** based on literature coverage:

**Approach:**
```
For each 5×5 cell:
1. Identify which BPUE studies cover this cell (via bounding boxes)
2. Calculate β for each study's BPUE
3. Average them → β_cell (WEIGHTED by sample size)
4. Apply β_cell to calculate bycatch using local % BI
```

**Key decisions:**
1. **Averaging method**: Weighted mean by sample size (hooks observed)
   - Studies with larger samples get more weight
   - More reliable than simple mean

2. **Gap filling**: Expert elicitation for cells without literature coverage
   - Consult fisheries experts to assign appropriate BPUE values
   - Based on similarity in: fishing operations, mitigation practices, regulatory environment
   - Document rationale for each assignment

**Result:** Spatially-varying catchability map reflecting local fishing practices!

#### Script 03d Implementation

**Created: scripts/03d_bycatch_spatial_catchability.Rmd**

**Features:**
- Defines BPUE studies with geographic bounding boxes
- For each cell, finds overlapping studies
- Calculates weighted average catchability (by sample size)
- Expert elicitation framework for gap filling
- Maintains catchability framework + local % BI allocation
- Outputs catchability maps, coverage maps, bycatch by age

**Placeholders to fill:**
- BPUE study definitions (from lit review - script 04)
- Expert gap-fill regions (from expert consultation)

**Advantages:**
- Captures spatial variation in fishing practices/mitigation
- Handles overlapping studies elegantly
- Fine spatial resolution (5×5 cells)
- Empirical where possible (literature) + expert knowledge for gaps
- Maintains theoretical rigor (catchability framework)

---

## Scripts Created/Modified

### New Scripts:
1. **scripts/02b_compare_carneiro_clay.Rmd**
   - Compares Carneiro South Georgia vs Clay total distributions
   - Validates hybrid approach (r = 0.98)
   - Outputs: correlation plots, difference maps, agreement statistics

2. **scripts/03c_bycatch_corrected_catchability.Rmd**
   - Implements corrected allocation using local % BI map
   - Maintains catchability framework throughout
   - Uses Carneiro for population allocation, Clay for age partitioning
   - Outputs: age-specific bycatch, per capita rates, comparison with 03b

3. **scripts/03d_bycatch_spatial_catchability.Rmd**
   - Implements spatial catchability approach (supervisor feedback)
   - Cell-specific β based on literature coverage
   - Weighted averaging by sample size
   - Expert elicitation for gap filling
   - Outputs: catchability maps, coverage maps, bycatch estimates

### Existing Scripts (unchanged):
- **scripts/02_compare_pop_distributions.Rmd**: Already saves `percentage_bird_island.tif`
- **scripts/03b_bycatch_catchability_method.Rmd**: Preserved for comparison

---

## Key Results from Script 03c

### Total Bycatch Estimates

| Age Class | Pelagic | Demersal | Total | Per Capita Rate |
|-----------|---------|----------|-------|-----------------|
| FB | 11.0 | 7.1 | 18.1 | 0.0196 |
| SB | 22.8 | 12.1 | 34.9 | 0.0128 |
| NB | 52.2 | 37.7 | 89.8 | 0.0227 |
| J2J3 | 28.0 | 13.4 | 41.4 | 0.0252 |
| IMM | 82.4 | 45.5 | 127.9 | 0.0211 |
| **TOTAL** | **196.4** | **115.7** | **312.1** | - |

### Validation Checks (All Pass ✓)
- Total WAAL bycatch matches expected (100%)
- Age partitioning sums to BI total (100%)
- Catchability values identical to 03b
- BI allocation: 14.2% (pelagic), 19.5% (demersal)

### Spatial Patterns
- Mean % BI across space: 32.1%
- But BI gets only 14.2-19.5% of bycatch
- Reveals fishing concentrates in areas with fewer BI birds
- Especially true for pelagic fisheries (high seas, distant water)

---

## Conceptual Advances

### 1. Clarified Catchability vs Population Proportion
**The confusion:**
- Should we scale BPUE by % BI birds?
- If birds from different populations have different distributions, doesn't that affect bycatch?

**The resolution:**
- BPUE is a **fishery property** (gear, practices, mitigation)
- All birds in a location face the **same local catchability**
- The **% BI varies spatially** and determines BI's share of local bycatch
- But we don't pre-scale BPUE - we scale the bycatch allocation

**Mathematical equivalence:**
```
Method A (conceptually wrong):
  BPUE_map[i] = BPUE × pct_BI[i]  ← Treats BPUE as pop property

Method B (correct - what 03c does):
  Total_bycatch[i] = hooks[i] × birds_all[i] × β
  BI_bycatch[i] = Total_bycatch[i] × pct_BI[i]  ← Allocates bycatch by composition

These give different results because Method A artificially varies BPUE!
```

### 2. Hybrid Data Source Approach Validated
- **Carneiro (population-specific)**: WHERE each breeding population goes
- **Clay (age-specific)**: WHERE each age class from BI goes
- **High correlation (r=0.98)**: They agree on BI spatial distribution
- **Complementary**: Use both for population allocation + age partitioning

### 3. Three Levels of Heterogeneity Captured
**Current (03c):**
1. Spatial bird composition (% BI varies 0-60%)
2. Age-class distributions (where different ages go)

**Future (03d - spatial approach):**
1. Cell-specific catchability (via literature coverage)
2. Spatial bird composition (via % BI map)
3. Age-class distributions (via Clay)

---

## Next Steps

### Immediate:
1. ✅ Script 03c validated and recommended for current analyses
2. ✅ Script 03d framework created (supervisor feedback incorporated)
3. Integrate per capita mortality rates into matrix model (use 03c for now)
4. Run population projections with fishing mortality

### Literature Review (Script 04) - **CRITICAL NEXT STEP**:
1. Extract BPUE from ~20-30 papers
2. **Essential data for each study:**
   - BPUE value (birds per 1000 hooks)
   - Geographic bounding box (lat/lon min/max)
   - Fishery type (pelagic/demersal)
   - Sample size (hooks observed) - **needed for weighted averaging**
   - Time period (years data collected)
3. **High priority:**
   - Mitigation status (present/absent/type)
   - Fleet/country (if available)
4. **Output format:** Ready to plug into script 03d bounding box structure

### Expert Elicitation for Gap Filling:
1. Identify regions without literature coverage (after lit review)
2. Consult with fisheries experts to assign BPUE values for gaps
3. Base assignments on similarity in:
   - Fishing operations (fleet type, gear, practices)
   - Mitigation adoption (tori lines, night setting, regulations)
   - Regulatory environment (RFMO requirements, enforcement)
4. Document rationale for each assignment
5. Populate `expert_gap_fill` table in script 03d

### Implement Spatial Catchability (Script 03d):
1. Complete literature review → replace placeholder studies
2. Complete expert elicitation → populate gap-fill table
3. Run script 03d with real data
4. Compare with 03c to quantify impact of spatial variation
5. Generate catchability maps showing regional patterns
6. Assess which approach (03c vs 03d) to use for final demographic model

### Sensitivity Analyses:
1. Age-specific catchability (juveniles more vulnerable?)
2. Temporal variation (pre- vs post-mitigation BPUE)
3. BPUE uncertainty (confidence intervals from literature)
4. Regional variation (once lit review complete)

---

## Files Modified

### New Files:
- `scripts/02b_compare_carneiro_clay.Rmd`
- `scripts/03c_bycatch_corrected_catchability.Rmd`
- `output/bycatch_summary_03c.csv`
- `output/bycatch_percapita_summary_03c.csv`
- `output/bycatch_comparison_03b_vs_03c.csv`
- `output/carneiro_clay_agreement.csv`
- `output/maps/comparison_carneiro_clay.png`
- `output/maps/bycatch_*_03c.png` (multiple maps)
- `output/rasters/bycatch_*_03c.tif` (multiple rasters)

### Existing Files (used, not modified):
- `output/rasters/percentage_bird_island.tif` (from script 02)
- `output/rasters/total_bird_density_all_pops.tif` (from script 02)
- All fishing effort and bird distribution inputs

---

## Key Insights for Paper/Thesis

### Methodological Contribution:
1. Properly integrates population-specific and age-specific spatial data
2. Maintains theoretical rigor (catchability framework)
3. Accounts for spatial heterogeneity in population composition
4. Validates hybrid data source approach (Carneiro + Clay)

### Biological/Conservation Implications:
1. Pelagic fisheries pose higher risk to BI than previously estimated
2. Demersal fisheries pose lower risk (concentrated near SG, well-regulated)
3. Spatial patterns reveal where different populations face different risks
4. Regional approach will identify priority areas for mitigation

### Uncertainty/Future Work:
1. Age-specific vulnerability (biological plausibility, but no data)
2. Temporal trends (need historical BPUE for population decline period)
3. Regional variation (planned - regional catchability approach)
4. Other populations' demographics (BI data only)

---

## Questions Remaining

1. **Temporal mismatch**: When was BI declining vs when were BPUE studies conducted?
2. **Other populations**: Why is BI declining but others stable (if ~same per capita mortality)?
3. **Historical baseline**: What was BPUE pre-mitigation during period of decline?
4. **Regional coverage**: Will 20-30 papers be sufficient for 3-5 regional strata?

---

## Session Continuation: January 12, 2026 (Afternoon)

### Overview
Attempted to systematically compare 03d and 03e methods to verify mathematical equivalence. Discovered critical data issues that explain discrepancies between scripts and invalidate current results.

### Summary
**Good news:** 03d and 03e methods are mathematically equivalent when using identical data.

**Bad news:** Multiple critical data problems identified:
1. **Fishing effort template has wrong extent** - excludes South Georgia (lat only to -50°, SG is at -54°)
2. **Bird distributions show albatross in tropics** - biologically impossible
3. **All comparison results are invalid** due to template issue

**Status:** All bycatch analyses on hold until data validation and corrections completed tomorrow.

---

## Key Findings

### 1. Discovered Differences Between Actual Scripts and Comparison Tests

**Created comparison script to test 03d vs 03e equivalence:**
- Script: `03_comparison_all_methods.Rmd`
- Goal: Test if methods are mathematically equivalent when using same data/parameters

**Found actual 03d and 03e scripts use different approaches than expected:**

| Feature | Actual 03d/03e Scripts | Original Comparison Script |
|---------|------------------------|----------------------------|
| Catchability | **Spatial** (BPUE study bounding boxes) | **Global** (single β value) |
| % BI extent | **Clipped** (only in SG range from script 02) | **Unclipped** (everywhere) |
| BI distribution | Carneiro (03d) vs Clay (03e) | Tested combinations |

**This explained why actual scripts gave different results:**
- Actual 03d: 111.91 pelagic, 68.36 demersal
- Actual 03e: 80.59 pelagic, 79.82 demersal
- They weren't using the same approach!

### 2. BPUE Study Coverage Issues

**Analyzed spatial coverage of placeholder BPUE studies:**

Pelagic studies:
- Study 1: lat -60 to -30, lon -70 to -20
- Study 2: lat -60 to -35, lon -65 to -25
- Coverage: Reasonable for South Atlantic

Demersal studies:
- Study 1: lat -60 to -35, lon -70 to -25
- Study 2: lat -55 to -40, lon -65 to -50
- **Problem: Only covers 2.24% of demersal fishing effort!**

**Where demersal fishing actually occurs:**
- 69% of effort: Southern Atlantic (lon -72° to -77°, west of Chile)
- 16% of effort: Indian Ocean
- 13% of effort: Other regions
- **Only 2.2% of effort: Near South Georgia**

**Result with spatial catchability:**
- BI birds concentrated near South Georgia (Clay distributions)
- Most demersal fishing occurs far from South Georgia
- Low spatial overlap → very low demersal bycatch (2.59 birds)
- vs 79.82 birds in actual 03e script

### 3. Updated Comparison Script to Use Global BPUE

**Simplified approach:**
- Removed spatial catchability (lit review incomplete anyway)
- Use single global β per fishery
- Focus on testing mathematical equivalence of 03d vs 03e methods
- Script renamed: `03_comparison_global_unclipped.Rmd`

**Results with global catchability:**
- Method 03d: 262.73 pelagic, 6.37 demersal = 269.10 total
- Method 03e: 262.73 pelagic, 6.37 demersal = 269.10 total
- ✓ **Mathematical equivalence confirmed!** (difference < 0.01 birds)

**But demersal still oddly low (6.37 vs expected ~70-80)...**

### 4. CRITICAL BUG DISCOVERED: Fishing Effort Template Extent

**Investigated why demersal bycatch remained low and South Georgia missing from BI maps:**

```
Clay distributions (original):
  - Latitude: -90° to 0°
  - Contains South Georgia data at -54°
  - 2 cells near SG with data

Fishing effort template:
  - Latitude: -50° to 65°  ← WRONG!
  - DOES NOT include South Georgia (-54°)
  - Resolution: 5° × 5°

After resampling Clay to fishing template:
  - 0 cells near South Georgia
  - All SG data LOST during resample
```

**This explains EVERYTHING:**
- Why SG doesn't appear in BI density maps
- Why demersal bycatch is 6 birds instead of 70-80
- Why results look "more clipped" when unclipped
- Why script 03d shows 111 pelagic (uses different template)
- Why comparison shows 263 pelagic (different alignment)

**The fishing effort rasters have incorrect spatial extent!**

### 5. Data Shows Bird Island Albatross in Tropics (Biologically Impossible)

**User observation:**
- Maps show BI albatross density in tropical latitudes
- Wandering albatross are Southern Ocean species
- Should not occur north of ~30°S

**This indicates MULTIPLE data problems:**
1. Template extent wrong (excludes SG)
2. Possibly fishing effort data wrong
3. Possibly bird distribution data wrong
4. Possibly alignment/resampling issues creating artifacts

**Status:** Need thorough data validation tomorrow
- Check all input rasters for correct extent and values
- Verify bird distributions are realistic
- Check fishing effort matches source data
- Rebuild from scratch if necessary

### 7. Clay Age-Class Proportion Issue

**Discovered age class proportions don't sum to 1.0:**
- FB: 5.7%, SB: 16.9%, NB: 24.4%, J2J3: 10.0%, IMM: 36.3%
- **Sum: 93.2% (missing J1 juveniles and some adult classes)**

**Fixed in comparison script:**
- Weight Clay distributions by age proportions
- Normalize combined result to sum to 1.0
- Then scale by prop_BI (931.8 / 5325.8 = 0.175)
- This correctly accounts for BI = 60% of SG

### 8. Map Extent Issues in Final Script

**Script 03_final_clay_carneiro_method.Rmd maps cut off Southern Ocean:**
- Used `ext(template)` for map limits
- Should use `map_extent <- c(-180, 180, -90, 0)`
- **Fixed:** Changed all maps to use full Southern Hemisphere extent

---

## Scripts Created/Modified

### Modified:
1. **scripts/03_comparison_all_methods.Rmd**
   - Reverted clipping changes to test unclipped approach
   - Added visualization maps
   - Discovered doesn't match actual 03d/03e behavior

2. **scripts/03_final_clay_carneiro_method.Rmd**
   - Fixed map extents to show full Southern Ocean
   - Changed from `ext(template)` to `map_extent <- c(-180, 180, -90, 0)`

### Created:
3. **scripts/03_comparison_global_unclipped.Rmd** (new)
   - Tests mathematical equivalence of 03d vs 03e
   - Global catchability (single β per fishery)
   - Unclipped Clay for BI + Carneiro for others
   - Fixed age class normalization
   - Includes visualization maps
   - **Confirms methods are mathematically equivalent**
   - **BUT reveals critical template extent bug**

---

## Critical Issues Identified

### 1. **Fishing Effort Template Extent is Wrong**
**Status:** CRITICAL BUG - blocking all analyses

**Problem:**
- Template latitude: -50° to 65°
- South Georgia location: -54°
- Template excludes entire region below -50°

**Impact:**
- All resampling operations lose South Georgia data
- Explains low bycatch estimates
- Explains missing BI in maps
- Invalidates all comparison results

**Next Steps:**
- Determine correct template to use
- Option A: Use `total_bird_density_all_pops.tif` from script 02
- Option B: Regenerate fishing effort rasters with correct extent (-90° to 65°)
- Re-run all analyses with corrected template

### 2. Clipping Method Creates Mathematical Non-Equivalence

**Script 02 approach:**
- Creates `percentage_bird_island.tif` with values only in SG range
- Outside SG range: NA (not calculated)
- Used in actual 03d and 03e scripts

**Issue:**
- If 03d uses clipped % BI but 03e doesn't, they're not mathematically equivalent
- Current actual scripts differ (111 vs 81 pelagic) partly due to this

**Decision needed:**
- Use clipped (conservative, avoids edge artifacts) OR
- Use unclipped (theoretically consistent, calculates everywhere birds exist)

### 3. Spatial vs Global Catchability

**Spatial approach (03d/03e actual scripts):**
- Different β in different regions based on BPUE study coverage
- Requires literature review to define bounding boxes
- More realistic but complex

**Global approach (comparison script):**
- Single β value everywhere
- Simpler, good for testing equivalence
- Less realistic spatial patterns

**Decision needed:**
- Which approach for standardized method?
- Global is simpler for now (lit review incomplete)
- Can add spatial variation later

---

## Key Insights

### 1. Template Extent is Foundational
**Everything depends on getting the spatial template correct:**
- Alignment operations
- Resampling
- Coverage calculations
- Final bycatch estimates

**If template is wrong, all downstream results are invalid.**

### 2. Mathematical Equivalence Works (When Data is Correct)
- 03d and 03e methods ARE mathematically equivalent
- When using same data/catchability, results match perfectly
- Discrepancies in actual scripts due to different implementations, not methods

### 3. Data Quality Issues Cascade
- Wrong template extent → lost South Georgia data
- Lost SG data → artificially low BI density
- Low BI density → unrealistically low bycatch
- Small differences in inputs → large differences in outputs

---

## Questions to Resolve (Tomorrow)

### Immediate Priority: Data Validation

1. **Why are there albatross in the tropics?**
   - Bird distributions should be Southern Ocean only
   - Check Clay input rasters directly
   - Check Carneiro input rasters directly
   - Verify no resampling artifacts creating spurious tropical values

2. **Which template should be the canonical one?**
   - total_bird_density_all_pops.tif from script 02?
   - Regenerated fishing effort with correct extent?
   - Some other reference raster?
   - **Must extend to at least -80°S to include all bird ranges**

3. **What is the correct spatial extent for Southern Ocean analyses?**
   - Latitude: -90° to 0°? -80° to 0°?
   - Should match bird distribution data extent
   - Verify against original data sources

4. **Are fishing effort rasters themselves correct?**
   - Do they have correct extent in source data?
   - Or were they processed incorrectly?
   - Need to check source CSVs: Pel_LL_effort.csv and demersal sources
   - Regenerate if necessary

5. **Are ALL input rasters valid?**
   - Check every TIF file for:
     - Correct extent (not cut off)
     - Realistic values (no negatives, no impossibly large values)
     - Correct units
     - No NaN/Inf issues
   - Validate against biological knowledge (no tropical albatross!)

### Once Data is Fixed:

6. **Clipped vs Unclipped - which to standardize on?**
   - Clipped: Conservative, matches script 02 output
   - Unclipped: Theoretically consistent, mathematically cleaner

7. **Once template is fixed, how different will results be?**
   - Need to re-run all comparisons
   - Verify 03d and 03e still match
   - Get realistic bycatch estimates

8. **Should we use spatial or global catchability?**
   - Global is simpler for now (lit review incomplete)
   - Can add spatial variation later once lit review complete

---

## Session: January 15, 2026

### Overview
Major overhaul of fishing effort data processing and visualization in script 01 to match Clay et al. 2019 methodology. Fixed data aggregation, scaling, and created publication-quality maps with discrete color bins.

---

## Key Accomplishments

### 1. Fixed Fishing Effort Rasterization to Preserve Exact Values

**Problem discovered:**
- Data is already in 5×5 degree gridded cells
- Script was converting to points, then rasterizing with `fun=mean`
- This caused grid misalignment and value inconsistencies
- Values didn't match Clay 2019 reference plots

**Solution implemented:**
- Changed from point-based rasterization to direct grid conversion
- Now uses `rast(data, type="xyz")` for already-gridded data
- Preserves exact values from source data
- Eliminates rounding errors and alignment issues

**Code changes (lines 93-98, 177-182):**
```r
# Before:
pll_points <- vect(pll_annual, geom = c("Lon", "Lat"))
rast_pll <- rasterize(pll_points, rast_pll, field = "mean_effort", fun = mean)

# After:
rast_pll <- rast(pll_mean_annual, type = "xyz", crs = "EPSG:4326")
```

### 2. Created Mean AND Cumulative Fishing Effort Versions

**Added new raster outputs:**
- **Mean annual effort**: Average hooks per location across years (1990-2009)
- **Cumulative effort**: Total hooks summed across all years (1990-2009)
- Both available in scaled (10^6) and unscaled versions

**Calculations:**
```r
# Mean: group by Lon, Lat → mean(Hooks)
# Cumulative: group by Lon, Lat → sum(Hooks)
```

### 3. Corrected Scaling Units to Match Clay 2019

**Critical discovery:**
- Initially scaled demersal to 10^3 hooks (incorrect - confused with trawl)
- Clay 2019 legend clearly states: **"10^6 hooks for longline"** (both pelagic AND demersal)
- Demersal values were 10× too high

**Solution:**
- Changed demersal scaling from 10^3 to 10^6 (lines 185, 196)
- Both fisheries now use consistent scaling
- Values now match Clay 2019 reference plots

**Impact:**
- Demersal values reduced by 10×
- Now shows realistic values (5 instead of 50 in most cells)
- Matches published literature

### 4. Created Discrete Blue Color Scale for Maps

**Implemented discrete bins matching Clay 2019:**
- Bin breaks: 0, 5, 10, 25, 50, 100, 500, >500 (in units of 10^6 hooks)
- Blue color palette (light to dark) from RColorBrewer
- Same color = same fishing effort value across all plots

**Transformation-aware binning:**
- Untransformed: bins at actual values (5, 10, 25, ...)
- Sqrt transformed: bins at sqrt(5), sqrt(10), sqrt(25), ...
- Log transformed: bins at log(6), log(11), log(26), ...
- **Labels stay the same** (5, 10, 25, ...) so colors are comparable

**Code (lines 293-310):**
```r
# Transform breaks to match data transformation
if (transform == "sqrt") {
  breaks <- sqrt(original_breaks)
} else if (transform == "log") {
  breaks <- log(original_breaks + 1)
}
```

### 5. Created Multiple Map Versions for Each Dataset

**Generated 12 scaled fishing effort maps:**

For each fishery type (pelagic, demersal):
- Mean annual effort × 3 transformations (raw, sqrt, log)
- Cumulative effort × 3 transformations (raw, sqrt, log)

**All with:**
- Discrete blue color bins
- Horizontal legends at bottom
- Consistent scaling (10^6 hooks)
- 10 cm wide × 6 cm tall figures at 300 dpi

### 6. Fixed Legend Display

**Problem:**
- Initial legends showed only title and min/max values
- Color bar and bin labels were missing/unreadable

**Solutions applied:**
- Changed from `guide_colorsteps` to `guide_colorbar`
- Made legends horizontal at bottom (barwidth=15cm, barheight=0.8cm)
- Added black frame and tick marks for visibility
- Sized appropriately for publication

### 7. Updated Pelagic Extent (Attempted)

**Changed extent from -50S to -60S** (line 267)
- Updated `ext_pel <- c(-180, 180, -60, 0)`
- However, data doesn't actually extend south of -50S

**Data verification:**
- Pelagic data (Pel_LL_effort.csv) contains: ICCAT, WCPFC, IOTC, IATTC
- Southernmost latitude: **-47.5°S** (center of -50° to -45° cell)
- No data south of 50°S in the file
- Clay 2019 plot shows data to ~60°S in Southern Ocean

**Conclusion:**
- Clay 2019 likely had additional data sources (e.g., CCSBT)
- Cannot replicate their 50-60°S coverage without additional data
- Current analysis accurately reflects available data extent

### 8. Verified Temporal Extent

**Confirmed both datasets filtered to 1990-2009:**
- **Pelagic**: Naturally 1990-2009 in source data
- **Demersal**: Filtered on line 162 (`filter(Year >= 1990, Year <= 2009)`)
- Matches WAAL distribution data timeframe (Clay et al. 2019)
- CCAMLR source data extends 1989-2024, correctly filtered

---

## Scripts Modified

### scripts/01_fishing_effort_overlap.Rmd

**Major changes:**
1. **Lines 93-98**: Fixed pelagic mean rasterization (direct xyz conversion)
2. **Lines 103-112**: Added pelagic cumulative effort calculation
3. **Lines 177-182**: Fixed demersal mean rasterization
4. **Lines 187-196**: Added demersal cumulative effort calculation
5. **Lines 185, 196**: Changed demersal scaling from 10^3 to 10^6
6. **Lines 267**: Updated pelagic extent to -60S
7. **Lines 268-350**: Enhanced mapping function with discrete bins and transformations
8. **Lines 354-487**: Created all scaled map versions (mean + cumulative × transformations)
9. **Lines 646-660**: Updated raster save operations with correct scaling comments
10. **Lines 281-288**: Added resample step in overlap calculation to fix extent mismatch

**Function enhancements:**
- `map_fishing_effort()`: Added `discrete_bins` and `bin_breaks` parameters
- Transformation-aware bin calculation
- Horizontal legend layout
- Improved formatting for publication

---

## Files Created/Modified

### New Output Files:
**Rasters (scaled to 10^6 hooks):**
- `output/rasters/fishing_effort_demersal_mean_scaled.tif`
- `output/rasters/fishing_effort_pelagic_mean_scaled.tif`
- `output/rasters/fishing_effort_demersal_cumulative.tif`
- `output/rasters/fishing_effort_pelagic_cumulative.tif`
- `output/rasters/fishing_effort_demersal_cumulative_scaled.tif`
- `output/rasters/fishing_effort_pelagic_cumulative_scaled.tif`

**Maps (12 total - mean + cumulative × raw/sqrt/log × pelagic/demersal):**
- `output/maps/fishing_effort_demersal_mean_scaled_raw.png`
- `output/maps/fishing_effort_demersal_mean_scaled_sqrt.png`
- `output/maps/fishing_effort_demersal_mean_scaled_log.png`
- `output/maps/fishing_effort_pelagic_mean_scaled_raw.png`
- `output/maps/fishing_effort_pelagic_mean_scaled_sqrt.png`
- `output/maps/fishing_effort_pelagic_mean_scaled_log.png`
- `output/maps/fishing_effort_demersal_cumulative_scaled_raw.png`
- `output/maps/fishing_effort_demersal_cumulative_scaled_sqrt.png`
- `output/maps/fishing_effort_demersal_cumulative_scaled_log.png`
- `output/maps/fishing_effort_pelagic_cumulative_scaled_raw.png`
- `output/maps/fishing_effort_pelagic_cumulative_scaled_sqrt.png`
- `output/maps/fishing_effort_pelagic_cumulative_scaled_log.png`

---

## Key Results

### Fishing Effort Summary Statistics

**Pelagic Longline (1990-2009):**
- Total hooks: [to be calculated]
- Mean annual hooks: [to be calculated]
- Spatial extent: -47.5°S to 62.5°N
- Data sources: ICCAT, WCPFC, IOTC, IATTC

**Demersal Longline (1990-2009):**
- Total hooks: [to be calculated]
- Mean annual hooks: [to be calculated]
- Spatial extent: -77.5°S to [northern limit]
- Data sources: CCAMLR, Argentina, Chile, Falklands, Namibia, South Africa

### Map Validation

**Pelagic maps:**
- ✓ Match Clay 2019 values and spatial patterns
- ✓ Correct scaling (10^6 hooks)
- ✓ Discrete blue color bins display correctly
- ✓ Legends readable and positioned at bottom
- ⚠ Data only extends to 50°S (Clay had data to 60°S - different sources)

**Demersal maps:**
- ✓ Match Clay 2019 values after 10^6 correction
- ✓ Values now realistic (5 vs previous 50)
- ✓ Correct scaling (10^6 hooks)
- ✓ Same color scale as pelagic for comparability
- ✓ Extends to Southern Ocean (-77.5°S)

---

## Technical Improvements

### 1. Data Processing Best Practices
- Eliminated unnecessary point conversions for gridded data
- Preserved exact source values without rounding
- Proper temporal filtering (1990-2009)
- Separated mean vs cumulative calculations

### 2. Visualization Enhancements
- Publication-quality discrete color schemes
- Consistent binning across transformations
- Horizontal legends for better figure layout
- Multiple transformation options for different audiences

### 3. Code Organization
- Parameterized mapping function for flexibility
- Clear comments documenting units and scaling
- Modular approach (mean and cumulative separate)
- Saved both scaled and unscaled versions

---

## Insights for Analysis

### 1. Spatial Patterns Confirmed
- Pelagic effort concentrated in tropical/subtropical high seas
- Demersal effort concentrated near continental shelves and seamounts
- Southern Ocean (CCAMLR) demersal effort reaches far south (-77.5°S)
- Limited pelagic effort in Southern Ocean in available data

### 2. Scaling Implications
- Using 10^6 hooks as standard unit allows direct comparison between fisheries
- Values interpretable: 5 = 5 million hooks cumulative over 20 years
- Consistent with published literature (Clay 2019)

### 3. Data Limitations Identified
- Pelagic data gap south of 50°S
- Cannot fully replicate Clay 2019 Southern Ocean coverage
- May affect overlap calculations with WAAL distributions in far south
- Consider acquiring CCSBT or additional Southern Ocean pelagic data

---

## Next Steps

### Immediate:
1. ✅ Fishing effort maps completed and validated
2. Verify overlap calculations work with corrected rasters
3. Check if resample fix (line 281) resolved extent mismatch error
4. Document final fishing effort statistics in results

### Data Acquisition (Optional):
1. Investigate CCSBT (Southern Bluefin Tuna Commission) data availability
2. Check for additional Southern Ocean pelagic longline sources
3. Would extend pelagic coverage from 50°S to potentially 60°S
4. Improve overlap estimates with southern WAAL distributions

### Analysis Continuation:
1. Run overlap calculations with corrected fishing effort rasters
2. Update bycatch estimates using proper scaling (10^6)
3. Verify spatial overlap patterns match expectations
4. Generate age-specific overlap maps

---

## Questions Resolved

1. **Why were demersal values 10× too high?** → Incorrect scaling (10^3 vs 10^6)
2. **Why don't cell values match exactly?** → Point-based rasterization artifacts, now fixed
3. **Why does pelagic cut off at 50°S?** → Source data limitation, not Clay 2019 extent issue
4. **Are legends showing correctly?** → Yes, after switching to guide_colorbar with horizontal layout
5. **Should bins be different for log transform?** → No, transform breaks but keep labels same for comparability

---

## Session: February 11, 2026

### Overview
Refined BPUE summary statistics in script 04 to correctly count studies and observations, and added CSV exports for all summary tables.

### Changes to Script 04

**Fixed inflated `n_studies` counts:**
- Changed `n_studies = n()` (row count, inflated by region/year expansion) to `n_studies = n_distinct(citation)` (unique citations)
- Added `n_bpue = n_distinct(row_id)` to count unique BPUE observations without inflation from region or year-group expansion

**Fixed inflated mean/SD from expansion:**
- `mean()` and `sd()` were computed on all expanded rows, so a single BPUE duplicated across year groups could show `sd = 0` instead of `NA`
- Changed to `mean(bpue[!duplicated(row_id)])` and `sd(bpue[!duplicated(row_id)])` to de-duplicate before computing stats

**Added CSV exports for all summary tables:**
- `output/bpue_summary_full.csv` (fishery x fleet x period x region)
- `output/bpue_summary_by_fishery.csv`
- `output/bpue_summary_by_fleet.csv`
- `output/bpue_summary_by_period.csv`
- `output/bpue_summary_by_region.csv`

**Added region sanity check:**
- Compares CSV region labels against bounding box centroid assignments
- Identified Abraham & Thompson 2009 mislabeled as "SE Indian" (should be "SW Pacific") — fixed in CSV
- Collins et al. 2021 "CCAMLR" vs "SW Atlantic" is a definitional mismatch (CCAMLR jurisdiction extends north of 60°S)
- Summaries use CSV region labels (not bbox-derived), confirmed correct

**Region label fix:**
- Abraham & Thompson 2009 NZ entries corrected from "SE Indian" to "SW Pacific" in source CSV

---

---

## Session: February 12-13, 2026

### Overview
Completed script 03f with demographic validation, revised gap-filling, and fixed a critical raster extent bug. Total BI bycatch estimate: ~293 birds/yr (down from ~370 after bug fix).

### Key Changes to Script 03f

**1. Demographic validation added (Section 13)**
- Compares per-capita fishing mortality against known survival rates (s_Juv=0.846, s_Imm=0.921, s_EF=0.913, etc.)
- Checks that implied natural mortality stays positive (fishing mortality < total mortality)
- All age classes pass: fishing = 17-38% of total mortality
- Includes mortality budget in bird counts (total deaths/yr vs bycatch deaths/yr)

**2. Gap-filling revised to temporal extrapolation (Section 8 rewrite)**
- Priority 1: Same fleet, nearest period with β, scaled by BPUE temporal ratio (`β_fill = β_source × bpue_target / bpue_source`)
- Priority 2: Regional mean β for target period
- Priority 3: Fishery-type mean β (fallback)
- Temporal scaling slightly increased estimates (correct — earlier periods had higher BPUE)

**3. Critical bug fix: BI density raster extent (Section 2 rewrite)**
- **Problem**: Pre-built `BI_density_*_final.tif` files used fishing effort template (lat -50..65) instead of bird distribution grid (lat -90..0)
- South Georgia at -54°S was completely excluded → zero BI bird density there → DLL bycatch near SG missing
- 15.7% of total bird density south of 50°S was lost, inflating β by ~19%
- **Fix**: Build BI density directly from Clay originals in 03f (correct -90..0 grid)
- **Impact**: Bycatch dropped from ~370 to ~293 birds/yr; maps now show full SG coverage

**4. Population size calculation fix (Section 2)**
- `Dem_props copy.csv` has 4 period rows + 1 summary row (1990-2009)
- Summary row was included in `mean()`, double-counting it
- Fixed with `filter(Period != "1990-2009")` before grouping

### Other Work
- Added SSD vs observed demographic proportions comparison to `WAAL_bycatch_2-13-26.Rmd`
- Population not at stable stage distribution: IMM grew 32%→50%, FB shrank 7.8%→3.4% (consistent with declining population)

### Current Status
- 03f produces ~293 BI birds/yr — biologically plausible per demographic validation
- Expert elicitation in progress to refine BPUE rates and gap-filling; will retest when complete

---

## Session: February 14, 2026

### Overview
Connected 03f bycatch estimates to the demographic matrix model in `WAAL_bycatch_2-13-26.Rmd`. Replaced placeholder code with real mortality data, added fleet-level mitigation scenarios.

### Changes to WAAL_bycatch_2-13-26.Rmd

**1. Removed empty placeholder chunks**
- Deleted ~60 lines of stub code for fishing effort, distributions, overlap, and BPUE (lines 182-237)
- These are all handled by script 03f now

**2. Added 03f per-capita mortality loading**
- Loads `bycatch_by_fishery_period_03f.csv` for 1990-1995 period (pre-mitigation baseline)
- Loads period-specific population from `Dem_props copy.csv` (1990-1994)
- Calculates per-capita rates as `annual_byc / Pop` for each age class × fishery
- Feeds into existing `dem_fm_*` / `pel_fm_*` variables used by downstream code
- Rationale: 1990-1995 = least mitigation → baseline for testing mitigation scenarios

**3. Added fleet-level mitigation scenario framework**
- Loads fleet-level bycatch from `bycatch_by_fleet_period_03f.csv`
- Defines per-fleet mitigation status table with: status (none/partial/full), compliance (0-1), and notes
- Mitigation efficacy placeholders: tori lines (70%), night setting (60%), line weighting (50%)
- Combined: 2/3 measures = ~88%, 3/3 measures = ~94% (multiplicative independence)
- `calc_fleet_fm()`: sums per-capita rates across fleets after applying fleet-specific reductions
- `calc_lambda_from_scenario()`: builds 11-stage matrix with mitigated survival and extracts lambda

**4. Defined 6 management scenarios**
- 0: No mitigation (1990-1995 baseline)
- 1: Current mitigation (as defined in fleet table)
- 2: All PLL fleets adopt 2/3 (current compliance)
- 3: All PLL fleets adopt 3/3 (current compliance)
- 4: Full compliance everywhere (3/3, 100%)
- 5: Target top 3 PLL fleets only (Taiwan, Japan, Other = ~95% of PLL bycatch)

**5. SSD comparison interpretation**
- J2J3 and IMM under-represented vs SSD; SB and NB over-represented
- Consistent with aging population: fewer young birds entering, adults accumulating in non-breeding classes
- Caveat: SSD from mean vital rates (1990-2009) — population was never at this equilibrium

### Key Decisions
- Use 1990-1995 as baseline (pre-mitigation) rather than mean across all periods
- Later periods can validate: plug in partial mitigation levels and check if predicted lambda matches observed trends
- Fleet mitigation statuses and efficacy rates are all placeholders — to be updated from literature

*Last updated: February 16, 2026*

---

## Session: February 16, 2026

### Overview
Bug fixes, code reorganization, refinement of mitigation efficacy rates and uncertainty ranges, new fleet-level visualizations including heatmaps, and BPUE source labeling in `WAAL_bycatch_2-13-26.Rmd`.

### Bug Fixes

1. **Variable name typo (line 801)**: `mitigation_eff` → `mit_eff` in the IUU scenario loop.

2. **Efficacy variables defined after use**: Moved efficacy definitions into the blanket scenario chunk so they're defined before `mitigation_scenarios` references them.

3. **RStudio notebook cache issue**: Changed `output: html_notebook` to `output: html_document` in YAML header.

### Mitigation Efficacy Updates

Iteratively refined individual measure efficacy based on literature review. Final values:

| Measure | Value | Source/rationale |
|---------|-------|-----------------|
| Tori lines | 0.75 | Bull 2007, Melvin 2014; paired operational ~70-85%, single ~50-65% |
| Night setting | 0.60 | ACAP review: 60-85% experimental, varies with moon/latitude |
| Line weighting | 0.65 | Robertson et al. 2006: 50-80% depending on weight type |
| Hook shielding | 0.35 | Sullivan et al. 2018: ~30-50%, limited data |
| **2/3 combined** | **90.0%** | tori + night setting |
| **3/3 combined** | **96.5%** | tori + night + line weighting |

### Uncertainty Simulation: Three-Layer Filtering

Rewrote uncertainty simulations with three layers of constraint enforcement:

1. **Biological hierarchy (re-draw)**: Draw adult survival stages first, then re-draw s_Imm until < min(adult), re-draw s_Juv until < s_Imm. Prevents biologically impossible juvenile > adult survival without discarding sims.

2. **FM clamping**: `clamp_fm()` checks if total FM (legal + IUU) exceeds 95% of the mortality budget (1 - survival). If so — rare — proportionally scales down both DLL and PLL FM. Prevents negative natural mortality.

3. **Baseline lambda filtering (re-draw)**: After computing all parameters, calculates baseline lambda (no mitigation). Re-draws entire parameter set if baseline lambda >= 1 (population known to be declining) OR < 0.95 (observed decline is ~1-2%/yr, not >5%). This is analogous to the WFC script's highfilter + lowfilter, but uses re-drawing instead of discarding sims. Falls back after 50 attempts.

All three layers use **re-drawing** rather than **rejection/skipping**, so all 1000 sims complete and the mean is not systematically biased by asymmetric removal of draws.

### Uncertainty Range Revisions

Widened placeholder CIs to better reflect estimation difficulty:

- **Juvenile survival**: ±0.035 → **±0.065** (hardest to estimate from mark-recapture)
- **Adult stage-specific survival**: ±0.03 → **±0.04**
- **Breeding success**: ±0.06 → **±0.09** (high interannual variability)
- **Fishing mortality**: ±50% → **±100%** (0.33x-2.0x; compounds BPUE, spatial overlap, gap-filling uncertainty)

### New Visualizations

1. **Zoomed blanket scenario plot** — y-axis 0.995-1.005, shows where each scenario crosses lambda=1
2. **Coverage threshold table** — minimum coverage for each scenario to reach lambda >= 1
3. **Zoomed uncertainty mean lines** — overlaid scenarios near recovery threshold
4. **P(lambda >= 1) probability of recovery** — fraction of sims achieving recovery vs coverage
5. **Zoomed fixed-IUU plots** and **P(recovery) for fixed-IUU** — faceted by IUU × enforcement
6. **Stacked bar chart** — fleet-level bycatch under each management scenario
7. **Dodged bar chart** — per-fleet bycatch reduction across key scenarios
8. **Cumulative fleet adoption curve** — lambda vs cumulative % bycatch mitigated, with fleet labels annotated by BPUE source (observed vs gap-filled, marked with *)
9. **Management scenarios mapped onto blanket curves** — fleet scenarios positioned by bycatch-weighted effective coverage
10. **Waterfall chart** — incremental lambda gain per fleet with 3/3 measures; bars colored by BPUE data source (blue = observed, orange = gap-filled)
11. **Heatmap: lambda surface** — efficacy × coverage colored by lambda (RdBu palette), white contour at lambda=1, fleet scenarios as labeled diamond points
12. **Heatmap: recovery zone** — binary (lambda >= 1 vs < 1) with fleet scenario diamonds overlaid

### BPUE Source Labeling

Added observed vs gap-filled BPUE classification to fleet-level visualizations:
- Loaded `coverage_info_03f.csv` to identify which fleets have at least one period with direct BPUE data
- **Observed BPUE fleets**: PLL Japan (all periods), PLL Brazil (2001-2010), PLL Taiwan (2001-2005), PLL South Africa (1996-2010), DLL CCAMLR (1996-2000), DLL Argentina (1990-2005)
- **Gap-filled fleets**: All others (Korea, Spain, China, Other, etc.)
- Waterfall bars colored by data source; cumulative curve fleet labels marked with * for gap-filled

### 7th Scenario: Complete Elimination
Added "Complete elimination" (efficacy=1.0) to all scenario visualizations, updated all 7-color palettes.

### Stale Comment Cleanup
Updated inline comments on `mitigation_scenarios` efficacy values to match current rates throughout session.

---

## Session Continuation: February 16, 2026

### Overview
Resolved persistent issue of uncertainty simulation means being lower than deterministic lambda values. Implemented post-hoc centering approach after iterative investigation of the root cause (Jensen's inequality + constraint-induced bias).

### Uncertainty Simulation Approach — Final Design

**Problem:** Uncertainty simulations consistently produced mean lambda values lower than deterministic values, across multiple attempts to fix via filtering.

**Root cause:** Two compounding factors:
1. **Jensen's inequality** — lambda is a nonlinear function of vital rates; E[f(x)] ≠ f(E[x])
2. **Constraint-induced bias** — biological hierarchy re-draws (s_Juv < s_Imm < min(adults)) and FM clamping both act as rejection sampling, which conditions the distribution and shifts the mean

**Previous approach (removed):** Baseline lambda filtering (0.95 ≤ lambda < 1.0) via repeat-loop re-draws. This was a third layer of rejection sampling that further lowered the mean.

**Final approach — three components:**
1. **Biological hierarchy (kept):** Re-draw s_Imm until < min(adult stages), then re-draw s_Juv until < s_Imm. This enforces a biologically necessary constraint (younger stages must have lower survival).
2. **FM clamping (kept):** `clamp_fm()` scales fishing mortality proportionally if it would exceed 95% of the mortality budget, ensuring natural mortality remains positive.
3. **Post-hoc centering (new):** After all sims complete, shift lambda values so the mean matches the deterministic lambda:
   ```r
   shift = det_lambda - mean(sim_lambdas)
   lambda_centered = sim_lambda + shift
   ```
   This preserves the variance/shape from the uncertainty simulations but anchors the central tendency to the deterministic value (computed from point-estimate vital rates).

**Why this is biologically reasonable:**
- The deterministic lambda uses the best point estimates of all vital rates — it's the most defensible central estimate
- The uncertainty sims capture how much lambda could vary given parameter uncertainty
- Post-hoc centering separates the question "what is the best estimate of lambda?" from "how uncertain are we about lambda?"
- Avoids the mathematically inevitable mean-shifting caused by applying nonlinear functions to constrained random draws

### Redraw Diagnostics
Diagnostic counters retained for biological hierarchy re-draws (s_Imm, s_Juv). Baseline lambda redraw counters removed since that filter was dropped.

### Code Changes (WAAL_bycatch_2-13-26.Rmd)
- **Sim 1 (main uncertainty):** Removed `repeat` loop and baseline lambda matrix/eigenvalue check. Added post-hoc centering in format chunk using `blanket_results` as deterministic reference.
- **Sim 2 (fixed-IUU):** Same removal of `repeat` loop. Added post-hoc centering using `iuu_scenario_output` as deterministic reference.
- Both centering blocks: join on (scenario, coverage) or (scenario, iuu_proportion, coverage, iuu_reduction), compute shift per group, apply to all sim lambdas.

Last updated: February 17, 2026

---

## Session: February 17, 2026

### Overview
Revised management scenario framework in `WAAL_bycatch_2-13-26.Rmd`: fixed compliance assumptions, expanded scenario structure to cross efficacy × compliance, added full elimination scenario, and integrated IUU into fleet-level heatmaps.

### Compliance Assumption Fix

**Problem:** Scenarios mixed different compliance assumptions — "all PLL" scenarios bumped 0% fleets to 50%, "full compliance" overrode all to 100%, "target top 3" set Taiwan/Japan/Other to 80%. This created inconsistencies (e.g., targeting 3 fleets showed higher coverage than targeting all PLL fleets).

**Fix:** All realistic scenarios now use each fleet's original compliance from the lookup table. Only the efficacy (which measures a fleet adopts) varies between scenarios. Rationale: compliance is hard to improve, so we assume fleets maintain current compliance rates.

### Expanded Scenario Structure

**Before:** 6 efficacy scenarios with ad-hoc compliance overrides.

**After:** 6 efficacy scenarios × 3 compliance levels = 19 combinations (+ 1 full elimination):
- **Efficacy scenarios:** No mitigation, Current, All PLL 2/3, All PLL 3/3, All fleets 3/3, Target top 3 PLL
- **Compliance levels:**
  - Baseline: lookup table values as-is
  - Improved: close 50% of gap to 100% (e.g., 60% → 80%)
  - Full: 100% for all fleets
- **Full elimination:** theoretical upper bound at (1,1)

### Bug Fix: No Mitigation Heatmap Position

`scenario_none` only zeroed `effective_reduction` but left `base_efficacy` intact, causing the heatmap point code to compute a non-zero y-coordinate. Fixed by also zeroing `base_efficacy` and `compliance`. Point now correctly sits at (0, 0).

### IUU-Integrated Heatmaps

Added four new visualization approaches overlaying fleet scenarios on coverage × efficacy heatmaps under varying IUU assumptions:

1. **Option 1 — Faceted by IUU proportion** (0%, 5%, 10%, 20%, no enforcement): Shows how the lambda=1 contour tightens as IUU increases
2. **Option 2 — 3×3 facet grid** (IUU proportion × IUU enforcement reduction): Full interaction space, + zoomed version cropped to management scenario region
3. **Option 3 — Arrow trajectories** on single heatmap (IUU=10%): Shows lambda shift from no-enforcement to full-enforcement per scenario
4. **Option 4 — Two-panel approach**: Panel A = mitigation heatmap at IUU=10%; Panel B = IUU proportion × enforcement heatmap at fixed mitigation (All PLL 3/3)

**Infrastructure added:**
- `calc_lambda_from_survival()`: shared matrix builder
- `calc_lambda_iuu_blanket()`: blanket efficacy × coverage under IUU
- `calc_lambda_fleet_iuu()`: fleet scenario lambda under IUU
- Pre-computed grid: 51×51 efficacy/coverage × 4 IUU proportions × 3 enforcement levels
- Pre-computed fleet scenario points under all IUU combinations

### Visualization Updates

- Bar chart now uses `position_dodge` with fill = compliance level (3 bars per efficacy scenario)
- Heatmap points use shape for compliance level (circle/triangle/square) with connecting lines
- Labels nudged for overlapping scenarios (Target Top3 PLL vs All PLL 3/3)
- Zoomed heatmaps auto-calculate bounds from scenario point positions

---

## Session: February 18, 2026

### Overview
Debugging, interpretation, and exploratory mapping.

### 1. Fixed chunk ordering bug in `03f_bycatch_spatial_catchability_v2.Rmd`
- **Error**: `object 'age_class_props' not found` at line 130
- **Cause**: `load-demographics` chunk (which defines `age_class_props`) appeared *after* `build-bi-density` chunk that uses it
- **Fix**: Moved `## Demographic proportions` / `load-demographics` section to run before `## Build BI density rasters`, so demographics are loaded first

### 2. Interpreted cumulative bycatch output table
- Table shows mean annual BI bycatch × years per period (period_total)
- Cumulative total 1990–2010: ~6,305 birds; annual rate declined from ~491 birds/yr (1996–2000) to ~98 birds/yr (2006–2010), consistent with mitigation adoption
- Clarified why the large cumulative total is not in conflict with the 14–30% of total mortality figure: the cumulative spans 21 years and all age classes, while per-capita rates use the full tracked population (all life stages, not just breeding adults)

### 3. Interpreted demographic validation output
- All age classes pass the biological plausibility check (positive implied natural mortality) even in the worst period (1996–2000)
- Non-breeders have highest fishing fraction (~33–55% of total mortality depending on period), which is biologically sensible — non-breeders spend 100% of the year at sea
- Worst-case period is 1996–2000 (consistent with peak annual bycatch rate)

### 4. Created quick map script for Rep Log 17287 BLL effort data
- New file: `scripts/quick_map_BLL17287.R`
- Reads `data/Rep Log 17287 BLL effort truncated.csv`, wraps longitudes >180, aggregates total hooks by 5° cell, plots with viridis (magma) log-scale color and Natural Earth land basemap
- Saves to `output/maps/quick_map_BLL17287.png`

---

## Session: February 23, 2026

### Overview
Integrated New Zealand BLL data (Rep Log 17287) into scripts 01, 04, and WAAL_bycatch. Fixed overlap map bird density weighting and South Georgia/Falklands gap. Added date-versioned output filenames and discrete-bin overlap maps.

### Changes to `01_fishing_effort_overlap.Rmd`

1. **NZ data integration**: Added NZ BLL load and `nz_std`. NZ uses x.0 cell centers vs x.5 for other DLL sources — rasterized separately on native grid, then bilinear resampled to x.5 reference raster before adding with `subst(NA,0)` to avoid NA propagation.

2. **Mean annual aggregation fix**: Changed from `mean(Hooks)` (mean monthly, wrong) to two-step: `group_by(Lon, Lat, Year) %>% sum()` then `group_by(Lon, Lat) %>% mean()` (mean annual total, correct). Applied to both PLL and DLL (NZ and non-NZ separately).

3. **Overlap map: bird density weighting**: Changed from binary mask (`bird_mask <- bird_resample > 0`) to density-weighted overlap (`fishing * bird_resample`). Bird resample now uses `method="average"` instead of `method="bilinear"` to fix the South Georgia / Falklands gap (bilinear point-samples at 5° cell center near land; average aggregates all fine-res bird cells within each 5° fishing cell).

4. **Discrete-bin overlap maps**: Added `map_overlap_discrete()` function with fixed breaks (0, 10, 100, 1000, 2000, 5000, 10000); 0–10 = white, rest = orange→dark red (`brewer.pal(9, "YlOrRd")[4:8]`). Separate maps for PLL and DLL. Small bottom legend to maximize map area.

5. **Date suffix versioning**: `date_sfx <- format(Sys.Date(), "%Y-%m-%d")` added; all exported raster and CSV filenames include the date suffix.

6. **Grid diagnostic**: Block comparing unique Lon values across DLL sources to detect grid convention mismatches.

### Changes to `04_bpue_literature_review.Rmd`

- Added NZ `nz_std` using `standardize_dem_data()` with NZ column names (`truncated_long`, `truncated_lat`, `total_hooks`); no +2.5 offset (column already in correct grid coords).
- Updated `bind_rows` to include `nz_std`; added `filter(!is.na(Lon), !is.na(Lat))`.

### Changes to `WAAL_bycatch_2-13-26.Rmd`

- Added `date_sfx` to setup chunk; updated all three `read_csv` paths to use dated filenames matching 03f outputs.
- Added **New Zealand** to `fleet_mitigation` tribble: DLL fleet, status = "full", compliance = 0.85 ("3/3 measures, ACAP signatory, observer coverage required"). Without this entry, NZ would default to `effective_reduction = 0` in fleet-level scenarios.

### Notes on `03f_bycatch_spatial_catchability_v2.Rmd`

- No changes needed: NZ already added fleet-by-fleet (no grid mixing issue); date suffix already on all outputs; bird density weighting and resample method already correctly handled; `make_effort_raster()` uses correct mean annual aggregation.

*Last updated: February 23, 2026*

---

## Session: February 24, 2026

### Overview
Extended `03f_bycatch_spatial_catchability_v2.Rmd` with per-capita temporal analysis and age-class maps.
Created two new standalone demographic model scripts.

### Changes to `03f_bycatch_spatial_catchability_v2.Rmd`

1. **Per-capita rates by period**: Added `percap-by-period` chunk computing PLL + DLL per-capita FM for each 5-year period, saved to `output/percap_rates_by_period_03f_<date>.csv`. Line plot saved to `output/maps/percap_by_period_03f_<date>.png`.

2. **Per-capita rates by year**: Added `percap-by-year` section with a triple-nested loop (year × fishery × fleet) that applies period-level catchability (β) to individual-year effort data. Saved to `output/percap_rates_by_year_03f_<date>.csv` and `output/maps/percap_by_year_03f_<date>.png`. Subtitle notes β is period-fixed.

3. **ggsave calls added to all 6 previously unsaved figures**: percap-by-period, percap-by-year, catchability maps (loop), bycatch density maps (loop). All saved to `output/maps/` with date suffix, 300 dpi.

4. **Bycatch density maps by age class**: Added `map-bycatch-by-age` and `map-bycatch-by-age-combined` chunks. For each fishery (PLL/DLL) and combined, produces a 5-panel patchwork (j2j3, imm, fb, sb, nb) of mean annual bycatch density across all periods. Saved to `output/maps/bycatch_by_age_<fishery>_03f_<date>.png`.

### New script: `WAAL_bycatch_mean_effort_2-24-26.Rmd`

Copy of original demo script modified to use mean annual fishing effort across all four 5-year periods (1990–2010) instead of the 1990–1995 period only.

- Title updated to indicate mean annual effort
- Bycatch loading: averages per-capita FM across all four periods
- Population sizes: averaged across the four Clay periods
- Fleet bycatch: averaged across all periods
- All figure filenames use `_mean1990_2010_<date>` suffix to avoid overwriting original

**Key finding**: Full bycatch elimination under mean annual effort does not push lambda > 1. This is because mean annual FM (averaged across declining 1990–2010 effort) is lower than the 1990–1995 FM — resulting in a smaller survival gain at full elimination. Not a bug — reflects that mean effort is not the highest-effort baseline.

### New script: `WAAL_bycatch_by_period_2-24-26.Rmd`

Third standalone demographic model script. Runs blanket mitigation scenarios independently for each of the four 5-year fishing effort periods. Key concept: period-specific FM rates are used as independent baselines, allowing comparison of how lambda response curves shift as fishing effort declined from 1990–1995 through 2006–2010.

**Structure:**
- Same vital rates and matrix as original demo
- Loads bycatch from all 4 periods via `bycatch_by_fishery_period_03f_<date>.csv`
- Period ↔ population mapping: 1990–1995 byc → 1990–1994 Clay pop, etc.
- Computes period-specific total FM and natural mortality
- Runs `expand.grid(year_group × scenario_idx × reduction)` loop (~2828 rows)
- Figure names use `_by_period_<date>` suffix

**Figures produced (4):**
1. `01_baseline_lambda_by_period` — lambda at zero mitigation by period (bar chart; shows effort reduction effect alone)
2. `02_lambda_curves_by_period` — lambda vs coverage, faceted by mitigation scenario, colored by period
3. `03_lambda_curves_zoom` — same, zoomed to lambda = 1 threshold
4. `04_threshold_heatmap` — tile heatmap: minimum coverage to reach lambda >= 1 by scenario × period; red = never recovers

*Last updated: February 24, 2026 (session 1)*

---

## Session: February 24, 2026 (session 2)

### New script: `scripts/03g_bycatch_spatial_catchability_v3.Rmd`

Copy of `03f_bycatch_spatial_catchability_v2.Rmd` with additions to support FM decomposition into effort-driven vs catchability-driven components. All `_03f_` file/figure names changed to `_03g_`.

**New Section 9b** (`calculate-bycatch-counterfactuals`): for each later period vs 1990–1995 baseline, computes:
- `bycatch_effort_only`: baseline β rasters × current effort (effort change only)
- `bycatch_catchability_only`: current β rasters × baseline effort (catchability change only)
Only fleet × fishery combinations present in BOTH baseline and current period are included.

**New Section 12b** (`export-decomposition-tables`): saves four new CSVs — `beta_by_fleet_period_03g`, `bycatch_effort_only_03g`, `bycatch_catchability_only_03g`, `hooks_by_fleet_period_03g`.

### Updated script: `scripts/WAAL_bycatch_by_period_2-24-26.Rmd`

Extended from 432 to ~900 lines. Key updates:

**Period-specific vital rates** (`load_period_vrs` chunk):
- Two VRs vary across periods: `s_Juv` (strong declining trend) and `s_adult_pooled` (moderate variation); r/b/k stable and held at mean values
- Inline estimates from Clay et al. figure (to be replaced with PlotDigitizer values):
  - s_Juv: 0.84 / 0.76 / 0.68 / 0.76 (2006–2010 gap-filled with mean of available periods)
  - s_adult_pooled: 0.935 / 0.925 / 0.915 / 0.930
- `vr_model` toggle: `"pooled"` (same pooled survival for all adult/imm stages) or `"scaled"` (stage-specific values scaled by ratio to mean, preserving relative stage structure); change one line to switch between approaches
- `vr_effective` table built from chosen model; used downstream in `nm_by_period`
- To activate digitized values: set `vr_file` to CSV filename in `data/`; CSV format: `year, s_Juv, s_adult_pooled`

**FM decomposition sections** (`load_decomposition_tables`, `compute_decomposition`):
- Loads 03g counterfactual outputs and computes per-period effort_factor and beta_factor
- Aggregates to bycatch-weighted scalar ratios per period

**New figures (05–08 + sensitivity):**
5. `05_fm_decomposition_bars` — FM reduction split into effort vs β components by period
6. `06_observed_on_heatmap` — original coverage × efficacy surface with iso-lambda contours for each observed later period
7. `07_decomp_heatmap` — effort_ratio × β_ratio surface; period points at decomposed coordinates; theoretical scenarios along right edge
8. `08_decomp_heatmap_zoom` — Figure 07 zoomed to observed range
9. `sensitivity_vr_pooled_vs_scaled` — overlay of lambda curves under both VR model options for the 3/3 scenario; also prints a table of baseline lambda differences by period

**VR model sensitivity** (`vr_sensitivity` + `plot_vr_sensitivity` chunks):
- After the main figures, runs the mitigation loop under the alternative `vr_model` (whichever was not chosen by the `vr_model` toggle)
- Prints a table comparing baseline lambda by period under pooled vs scaled
- Plots overlaid lambda curves (solid = pooled, dashed = scaled) for the 3/3 scenario
- If lines overlap, the simpler pooled model is sufficient; divergence indicates stage structure matters

*Last updated: February 24, 2026 (session 2)*

---

## Session: February 24, 2026 (session 3)

### Overview
Bug fix for `vr_effective` not found error in `WAAL_bycatch_by_period_2-24-26.Rmd`. Revised Figure 06 twice to better match the old heatmap format. Clarified two conceptual questions about the period-based analysis.

### Bug fix: duplicate `load_period_vrs` section removed

**Problem:** `vr_effective` not found at line 185 (`natural_mortality_by_period` chunk).
**Cause:** The `load_period_vrs` chunk (which defines `vr_effective`) had been inserted in the correct location (before `natural_mortality_by_period`) during session 2, but the original copy of the chunk was not removed from its old location (~line 685, after `plot_vr_sensitivity`). The duplicate was unreachable before `nm_by_period` ran.
**Fix:** Removed the full duplicate `*PERIOD-SPECIFIC VITAL RATES*` section (including `load_period_vrs` chunk and surrounding narrative) from its old post-sensitivity location. The section now exists only once, correctly placed before `natural_mortality_by_period`.

### Figure 06 revised — final format

Figure 06 (`06_observed_on_heatmap`) was revised to match the format of the old `WAAL_bycatch_mean_effort_2-24-26.Rmd` heatmap, with **time period** playing the role that **compliance level** played in the old script.

**Final structure:**
- Same RdBu lambda surface on coverage × efficacy axes with percent labels and white λ=1 contour (identical to old heatmap)
- For each mitigation scenario × time period: a colored dot at `(min_coverage_to_recover, scenario_efficacy)` — the minimum fleet coverage at which lambda crosses 1 for that period's FM
- White lines connect the four period points within each scenario (temporal trajectory)
- Scenario names labeled at the 1990–1995 point (rightmost, needs most coverage)
- Period color legend matches `period_colors` used throughout the script

**How to read it:** Within each scenario (fixed y-position = efficacy), points shift leftward over time as FM declined and less additional fleet coverage was needed to achieve recovery. The 1990–1995 points land on or near the white λ=1 contour (same FM used for both surface and threshold); later period points fall to its left.

**Key data used:** `threshold_by_period` (already computed for Figure 04 tile chart) joined with `mitigation_scenarios` to get efficacy values. No new computation required.

### Conceptual clarifications

**1. Do later periods account for already-occurring mitigation?**
Yes — `total_fm_wide` for each period contains the *observed* FM for that period, which already reflects whatever real-world mitigation occurred (lower β from changed fishing practices, fewer hooks). `reduction = 0` in `period_results` means "no *additional* mitigation beyond what already happened in that period," not "no mitigation at all." The 2006–2010 period curves start from a better baseline precisely because some mitigation was in place. The script correctly treats each period's FM as the starting point.

**2. Are there old compliance assumptions that need updating?**
No — the by-period script has no compliance tiers. `reduction` is simply the proportion of the entire fleet that adopts mitigation (0–100%), the same framing as the blanket mitigation coverage in the original demo. No fleet-level compliance table is used in this script.

*Last updated: February 24, 2026 (session 3)*

---

## Session: February 25, 2026

### Overview
Completed and corrected all 4 period-specific bycatch scripts (06a–06d). Discussed and resolved the conceptual approach to vital rates across periods. Updated uncertainty simulation parameters to match period-specific survival values. Created a new diagnostic figure script (07).

---

### Key Work Done

#### 1. Completed 06b, 06c, 06d edits
Applied the same structural changes to all four scripts:
- Title updated to reflect period
- `target_period_byc` and `target_period_pop` set to matching period string
- `surv_params` simplified to 2 parameters (`s_Juv`, `s_Adult`)
- Main uncertainty sim loop: draws `sim_s_Adult` once → assigns to all adult `sim_s_*` → draws `sim_s_Juv` with hierarchy enforcement (`s_Juv < s_Adult`)
- Diagnostic counters simplified to `diag_juv_redraws` / `diag_juv_capped` only
- `clamp_fm`: all adult/immature budgets use `(1 - sim_s_Adult)` uniformly
- Same pattern applied to fixed-IUU loop

#### 2. Vital rate approach — period-specific survival (user-set)
The user manually updated survival VRs in each script to match period-specific values read from a published figure. The final structure is:
- **Survival:** Two pooled parameters (`s_Juv`, `s_Adult`), **period-specific**
- **Behavioral rates (b\*, r\*, k\*):** Stage-specific, **fixed across periods** (from literature; no period-specific empirical estimates available)
- **Rationale:** Stage-specific behavioral rates are structurally required (collapsing to means inflates lambda); survival varies empirically by period and is the primary demographic signal

**Period-specific survival values:**
| Script | Period | `s_Juv` | `s_Adult` |
|--------|--------|---------|-----------|
| 06a | 1990–1994 | 0.78 | 0.96 |
| 06b | 1995–1999 | 0.725 | 0.940 |
| 06c | 2000–2004 | 0.78 | 0.92 |
| 06d | 2005–2009 | 0.78 | 0.92 |

#### 3. surv_params updated to match period-specific values
All four `surv_params` blocks updated so uncertainty simulation is centered on the correct period mean, with CI widths matching original absolute widths (s_Juv ±0.075/0.070; s_Adult −0.040/+0.030):

| Script | `s_Juv` CI | `s_Adult` CI |
|--------|------------|--------------|
| 06a | (0.705, 0.850) | (0.920, 0.990) |
| 06b | (0.650, 0.795) | (0.900, 0.970) |
| 06c | (0.705, 0.850) | (0.880, 0.950) |
| 06d | (0.705, 0.850) | (0.880, 0.950) |

#### 4. Conceptual discussion: is decreased fishing effort captured?
Yes — the survival rates (read from a figure of observed survival) already reflect the net outcome of all changes: effort, catchability, and natural mortality combined. The period-specific per-capita FM rates in the bycatch CSVs similarly embed the combined effect. The model does not separately attribute changes to effort vs. catchability — that distinction requires a counterfactual analysis (pending).

#### 5. Script 07 — diagnostic figures
Created `scripts/07_diagnostic_figures.Rmd` with three dual y-axis plots:
- **Plot 1 (PLL):** Mean annual hooks (bars, left axis) + BI bycatch per 1,000 hooks (line, right axis)
- **Plot 2 (DLL):** Same structure as plot 1 for demersal longline
- **Plot 3:** s_Juv and s_Adult survival (lines, left axis) + mean per-capita FM averaged across age classes (dashed line, right axis)

Data sources used:
- `hooks_by_fleet_period_03g_2026-02-24.csv` — fishing effort (5-year total hooks by fleet; ÷5 for mean annual)
- `bycatch_by_fishery_period_03f_2026-02-25.csv` — mean annual BI bycatch (bi_total column)
- `percap_rates_by_period_03f_2026-02-25.csv` — per-capita FM by period and age class
- Survival rates hardcoded from 06a–06d VR sections

Note: hooks file uses period labels "1990-1995" vs bycatch model's "1990-1994" — mapped explicitly in script.

---

### Pending Tasks (future sessions)
1. **Counterfactual analysis:** For periods 1995–1999, 2000–2004, 2005–2009, compare observed mortality vs: (a) what it would have been with 1990–1994 baseline catchability held constant; (b) what it would have been with 1990–1994 baseline fishing effort held constant

*Last updated: February 25, 2026 (session 4)*
