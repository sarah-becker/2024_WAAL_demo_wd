# Wandering Albatross Bycatch Estimation Methods

**Project:** Bird Island Wandering Albatross Demographic Model
**Date:** February 2026 (updated)
**Author:** Sarah Becker

---

## Table of Contents

1. [Overview](#overview)
2. [Theoretical Framework](#theoretical-framework)
3. [Data Sources](#data-sources)
4. [Methodological Approaches](#methodological-approaches)
5. [Script Summaries](#script-summaries)
6. [Analysis Workflow](#analysis-workflow)
7. [Future Development](#future-development)
8. [References](#references)

---

## Overview

This document describes the methods for estimating fisheries bycatch mortality of wandering albatrosses (Diomedea exulans) from Bird Island, South Georgia. The analysis integrates:

- **Spatial distributions** of birds by age class (Clay et al. 2019)
- **Population-specific distributions** (Carneiro et al. 2020)
- **Fishing effort data** (pelagic and demersal longline)
- **Bycatch Per Unit Effort (BPUE)** estimates from published literature
- **Catchability theory** from fisheries science and predator-prey ecology

The goal is to estimate **age-specific bycatch mortality rates** for input into a stage-structured demographic matrix model, allowing evaluation of population viability and conservation interventions.

---

## Theoretical Framework

### Bycatch as a Predator-Prey Interaction

We model fisheries bycatch using concepts from both **Lotka-Volterra predator-prey theory** and **fisheries catchability models**, recognizing that fishing represents a form of predation on seabird populations. This approach is grounded in the understanding that bycatch mortality arises from the interaction between fishing effort (predators) and bird abundance (prey), with the catchability coefficient (β) serving as the interaction coefficient that determines the rate at which encounters result in mortality. By anchoring our estimates to observed Bycatch Per Unit Effort (BPUE) from the literature, we ensure that total predicted mortality matches empirical observations while providing a theoretically rigorous framework for partitioning that mortality across space, fishery types, and bird age classes.

#### Lotka-Volterra Framework

In the classic Lotka-Volterra model, the predation rate is:

```
Predation rate = β × (Predators) × (Prey)
```

Where **β** (attack rate) represents the efficiency with which predators encounter and consume prey.

#### Fisheries Catchability Framework

In standard fisheries models, catch is modeled as:

```
Catch (C) = q × Effort (E) × Abundance (N)
```

Where **q** (catchability coefficient) represents the proportion of stock removed per unit of effort and abundance.

#### Application to Seabird Bycatch

For our bycatch model:

```
Bycatch_i = β × Hooks_i × Birds_i
```

Where:
- **β** = catchability (probability a bird is caught per hook per bird)
- **Hooks_i** = fishing effort (number of hooks) in grid cell *i*
- **Birds_i** = bird density in grid cell *i*

The parameter **β** is analogous to both the Lotka-Volterra attack rate and the fisheries catchability coefficient (q).

### Deriving Catchability from BPUE

We constrain the total bycatch to match observed Bycatch Per Unit Effort (BPUE) from the literature:

```
Total bycatch = α × H_total
```

Where:
- **α** (alpha) = BPUE from literature (birds per hook)
- **H_total** = total hooks across all grid cells

Since total bycatch also equals the sum across all cells:

```
α × H_total = Σ_i (β × H_i × B_i)
```

Solving for β:

```
β = (α × H_total) / Σ_i (H_i × B_i)
```

This partitions the total expected bycatch across space proportional to the hooks × birds interaction in each cell.

### Key Assumptions

1. **Linear encounter model**: Bycatch rate is proportional to the product of hooks and birds
2. **Random mixing**: Birds and fishing gear encounter each other randomly within grid cells
3. **Constant catchability**: β is constant within region/fishery strata (but varies between them)
4. **No behavioral response**: Birds don't learn to avoid high-bycatch areas
5. **No gear saturation**: Number of available hooks doesn't limit catches

These are standard assumptions in fisheries science and are reasonable for seabird bycatch given the low bycatch rates relative to total hooks deployed.

---

## Data Sources

### Bird Distributions

#### Age-Class Distributions (Clay et al. 2019)
- **Source:** Tracking data from Bird Island, South Georgia (1990-2009)
- **Resolution:** 1° × 1° grid cells
- **Coverage:** Year-round distributions
- **Age classes:**
  - FB (First Breeders)
  - SB (Successful Breeders)
  - NB (Non-Breeders)
  - J1 (Juvenile 1) - *excluded, no distribution available*
  - J2J3 (Juveniles 2-3)
  - IMM (Immatures)

#### Population-Specific Distributions (Carneiro et al. 2020)
- **Populations:** Crozet, Kerguelen, South Georgia
- **Resolution:** 1° × 1° grid cells
- **Coverage:** Year-round distributions
- **Use:** Calculate proportion of birds from Bird Island in each grid cell

### Demographic Data

**Population proportions** by age class from Clay et al. 2019:
- FB: 5.96%
- SB: 17.20%
- NB: 24.88%
- J2J3: 10.05%
- IMM: 35.03%
- Total (excluding J1): 93.12%

**Breeding pair estimates** (global):
- South Georgia: 1,553 pairs (Poncet et al. 2006)
- Prince Edward Island: 1,800 pairs (Ryan et al. 2009)
- Marion Island: 1,900 pairs (ACAP 2009)
- Crozet: 340 pairs (CNRS 2010)
- Kerguelen: 354 pairs (CNRS 2011)
- **Total: 5,947 pairs**

**Bird Island proportion of global population:**
- Bird Island = 60% of South Georgia (Poncet et al. 2006)
- BI proportion = 0.6 × 1,553 / 5,947 = **15.67%**

### Fishing Effort Data

- **Pelagic longline:** Global distribution of hooks deployed
- **Demersal longline:** Global distribution of hooks deployed
- **Resolution:** Matched to bird distribution grid (1° × 1°)
- **Units:** Number of hooks per grid cell

### Bycatch Per Unit Effort (BPUE)

**Current values** (to be updated from literature review):

**Pelagic longline:**
- Klaer 2012 (South Atlantic): 0.01 birds per 1,000 hooks
- Tuck et al. 2015 (South Atlantic): 0.007 birds per 1,000 hooks
- **Mean:** 0.0085 birds per 1,000 hooks

**Demersal longline:**
- Tuck et al. 2015 (baseline): 0.00184 birds per 1,000 hooks
- Jiménez et al. 2020 (South Georgia, pre-mitigation): 0.029 birds per 1,000 hooks
- **Mean:** 0.01542 birds per 1,000 hooks

**Future:** Will be replaced with weighted regional averages from comprehensive literature review (script 04).

---

## Methodological Approaches

We have developed three approaches to estimating bycatch, each with different strengths:

### Approach 1: Overlap-Based Method (Script 03)

**Conceptual Approach:**

This was our initial approach to spatially allocating bycatch mortality. The method creates a spatially-varying BPUE map by multiplying a single global BPUE value by the percentage of Bird Island birds in each cell, then applies this to overlap indices (bird density × fishing effort). While simple and intuitive, this approach has a fundamental conceptual flaw: it treats BPUE as varying with bird population composition rather than recognizing that **BPUE is a fishery property, not a population property**. In reality, fishing gear doesn't selectively catch birds based on their colony of origin—a hook deployed in a mixed population area has the same catchability for a Bird Island bird as for a Crozet bird. By artificially downweighting BPUE in areas where Bird Island birds mix with other populations, this method underestimates total bycatch. We moved away from this approach to better align with the underlying biological and fisheries processes.

**Formula:**
```
BPUE_map_i = pct_BI_i × BPUE
Bycatch_age = Σ_i (BPUE_map_i × overlap_i_age × prop_age)
```

**Process:**
1. Scale BPUE by % Bird Island birds in each cell
2. Multiply by overlap index (bird density × fishing effort)
3. Scale by age class proportion

**Strengths:**
- Simple and intuitive
- Direct use of overlap indices

**Weaknesses:**
- Incorrectly varies BPUE by bird composition rather than fishing practices
- Underestimates total bycatch (~77% of expected)
- BPUE is a fishery property, not a population property

**Status:** Implemented and working. Produces conservative estimates but conceptually flawed.

### Approach 2: Catchability Method (Script 03b) - **SUPERSEDED BY 03c**

**Conceptual Approach:**

This method correctly treats BPUE as a fishery characteristic and uses the catchability coefficient (β) to partition mortality spatially. However, it has a **conceptual limitation**: it scales Bird Island distributions by the **global average proportion** (15.67%), assuming BI represents this percentage uniformly across all space. In reality, % BI varies from 0-60% depending on location. This approach was superseded by script 03c which uses the **actual local % BI** in each cell.

**Key Limitation:** Assumes uniform 15.67% BI proportion everywhere, when spatial variation is 0-60%. This masks important spatial heterogeneity in population composition.

**Mathematical Framework:**

The total bycatch constraint from literature:
```
C_total = α × H_total
```

Where:
- C_total = total expected bycatch (all WAAL)
- α = BPUE from literature (birds per hook)
- H_total = total hooks deployed

This total bycatch must equal the sum across all cells:
```
C_total = Σ_i (β × H_i × B_i_all_pops)
```

Where:
- β = catchability (birds caught per hook per bird)
- H_i = hooks in cell i
- B_i_all_pops = bird density in cell i (proportion of global WAAL population)

Solving for β:
```
β = (α × H_total) / Σ_i (H_i × B_i_all_pops)
```

For Bird Island age-class specific bycatch:
```
C_age_BI = Σ_i (β × H_i × B_i_age_BI_scaled)
```

Where:
- B_i_age_BI_scaled = Bird Island age-class density, scaled to global proportion

**Detailed Process:**

#### Step 1: Scale Bird Island Distributions to Global Proportion

**Why this is necessary:**
The catchability (β) is calculated using total bird density (B_i_all_pops), which represents the proportion of the GLOBAL WAAL population in each cell and sums to 1.0.

The Bird Island age-class distributions from Clay et al. 2019 represent the proportion of THAT age class in each cell and sum to various values (e.g., FB sums to ~0.05, IMM sums to ~0.35).

These are in different units! We must scale BI distributions to match.

**Scaling procedure:**

a) **Load raw Bird Island age-class distributions:**
```r
bird_fb_raw <- rast("WA_AllMonths_Both_FB_1990-2009.tif")
bird_sb_raw <- rast("WA_AllMonths_Both_SB_1990-2009.tif")
# ... etc for nb, j2j3, imm
```

b) **Normalize each distribution to sum to 1:**
```r
# Replace NA with 0
bird_fb_zero <- subst(bird_fb_raw, NA, 0)

# Calculate sum
sum_fb <- global(bird_fb_zero, "sum", na.rm = TRUE)

# Normalize
bird_fb_norm <- bird_fb_zero / sum_fb  # Now sums to 1.0
```

c) **Calculate scaling factors:**
```r
# Bird Island proportion of global WAAL
# BI = 60% of South Georgia, SG = 1553 of 5947 global pairs
prop_BI_global <- 0.6 × (1553 / 5947) = 0.1567

# Age class proportions of BI population (from Clay et al. 2019)
prop_fb <- 0.0596   # 5.96% of BI are first breeders
prop_sb <- 0.1720   # 17.20% are successful breeders
prop_nb <- 0.2488   # 24.88% are non-breeders
prop_j2j3 <- 0.1005 # 10.05% are juveniles 2-3
prop_imm <- 0.3503  # 35.03% are immatures
```

d) **Apply scaling:**
```r
# Each BI age-class distribution gets scaled by:
# (1) Its proportion of the BI population
# (2) BI's proportion of the global population

bird_fb_scaled <- bird_fb_norm × prop_fb × prop_BI_global
bird_sb_scaled <- bird_sb_norm × prop_sb × prop_BI_global
# ... etc
```

e) **Verify scaling:**
```r
sum(bird_fb_scaled) = prop_fb × prop_BI_global = 0.0596 × 0.1567 = 0.00934

# All BI age classes should sum to:
sum_all_BI <- prop_BI_global × sum(prop_fb, prop_sb, prop_nb, prop_j2j3, prop_imm)
            = 0.1567 × 0.9312 = 0.1460 ✓
```

Now B_i_age_BI_scaled is in the same units as B_i_all_pops (proportion of global WAAL).

#### Step 2: Load Total Bird Density (All Populations)

From script 02:
```r
total_bird_density <- rast("total_bird_density_all_pops.tif")

# Verify it sums to 1.0
global(total_bird_density, "sum", na.rm = TRUE) = 1.0 ✓
```

This represents:
```
B_i_all_pops = (B_crozet × 0.0572) + (B_kerg × 0.0595) +
               (B_PEI × 0.6222) + (B_SG × 0.2611)
```

Where each B_population is normalized (sums to 1) and weighted by breeding pair proportions.

#### Step 3: Calculate Catchability for Each Fishery

**Pelagic longline:**
```r
# BPUE from literature (convert to per hook)
α_pel <- 0.0085 / 1000 = 8.5 × 10^-6 birds per hook

# Total hooks
H_total_pel <- sum(fishing_effort_pelagic) = 1.632 × 10^8 hooks

# Calculate hooks × birds for each cell
hooks_x_birds_pel <- fishing_effort_pelagic × total_bird_density

# Sum across all cells
sum_HxB_pel <- sum(hooks_x_birds_pel) = 8.051 × 10^4

# Calculate catchability
β_pel <- (α_pel × H_total_pel) / sum_HxB_pel
      = (8.5×10^-6 × 1.632×10^8) / 8.051×10^4
      = 0.01723
```

**Demersal longline:**
```r
α_dem <- 0.015419 / 1000 = 1.542 × 10^-5 birds per hook
H_total_dem <- 3.854 × 10^7 hooks
sum_HxB_dem <- 1.700 × 10^5
β_dem <- (α_dem × H_total_dem) / sum_HxB_dem = 0.00350
```

**Interpretation of β:**
- β_pel = 0.01723 means: for each hook deployed in a cell, the probability that a bird in that cell is caught is 0.01723 × (bird density in that cell)
- This is the "interaction coefficient" - the rate at which hooks and birds interact to produce bycatch

#### Step 4: Calculate Bycatch for Each Age Class

**For each fishery and age class:**
```r
# Example: Pelagic bycatch of first breeders
bycatch_pel_fb <- sum(fishing_effort_pelagic × bird_fb_scaled × β_pel)
                = sum_i (H_i_pel × B_i_fb_BI × 0.01723)
                = 8.45 birds/year
```

**Full results (pelagic):**
```
Age Class | Bycatch (birds/year) | Per Capita Rate
----------|----------------------|----------------
FB        | 8.45                 | 0.00914
SB        | 20.98                | 0.00767
NB        | 39.34                | 0.00993
J2J3      | 19.30                | 0.01175
IMM       | 59.85                | 0.00988
----------|----------------------|----------------
TOTAL     | 147.92               | --
```

**Full results (demersal):**
```
Age Class | Bycatch (birds/year) | Per Capita Rate
----------|----------------------|----------------
FB        | 8.27                 | 0.00895
SB        | 14.48                | 0.00529
NB        | 44.15                | 0.01115
J2J3      | 15.74                | 0.00958
IMM       | 53.76                | 0.00888
----------|----------------------|----------------
TOTAL     | 136.41               | --
```

#### Step 5: Validation

**Simple calculation (all WAAL):**
```
Expected bycatch (all WAAL) = α × H_total
Pelagic:  8.5×10^-6 × 1.632×10^8 = 1,387 birds
Demersal: 1.542×10^-5 × 3.854×10^7 = 594 birds
TOTAL: 1,981 birds
```

**Expected BI proportion:**
```
BI should be: 0.1567 × 0.9312 = 14.60% of total
Expected BI bycatch: 1,981 × 0.1460 = 289 birds
```

**Our result:**
```
Catchability method: 147.92 + 136.41 = 284 birds
Ratio: 284 / 289 = 98.3% ✓
```

The 98% match validates our approach!

**Strengths:**
- Theoretically rigorous (based on predator-prey/catchability theory)
- Correctly partitions total expected bycatch
- Produces realistic estimates (~98% of expected from simple calculation)
- Age-class specific estimates
- Bird densities properly scaled to same units

**Weaknesses:**
- Assumes single global BPUE (no regional variation)
- More complex conceptually
- Requires careful attention to units and scaling

**Status:** Implemented but superseded by 03c.

**Key Results (Script 03b):**
- Pelagic: 148 birds/year
- Demersal: 136 birds/year
- **Total: 284 birds/year**

### Approach 3: Corrected Catchability Method (Script 03c) - **CURRENT RECOMMENDED**

**Conceptual Approach:**

This method addresses the key limitation of script 03b by using the **actual local % BI** in each cell rather than assuming a uniform global average (15.67%). The approach maintains the catchability framework throughout but properly accounts for spatial heterogeneity in population composition. We calculate total WAAL bycatch using catchability (same as 03b), then allocate to Bird Island based on the **local percentage of birds from BI** in each cell (from Carneiro et al. 2020 distributions via script 02). Finally, we partition BI bycatch by age class using Clay et al. 2019 distributions. This hybrid approach combines population-specific distributions (Carneiro) for allocation with age-specific distributions (Clay) for partitioning, validated by high correlation (r=0.98) between datasets.

**Mathematical Framework:**

```
Step 1: Calculate catchability using ALL WAAL (same as 03b)
  β = (α × H_total) / Σ_i (H_i × B_i_all_pops)

Step 2: Calculate total WAAL bycatch density in each cell
  Total_bycatch_i = H_i × B_i_all_pops × β

Step 3: Allocate to BI using actual local % BI (NEW - key innovation)
  BI_bycatch_i = Total_bycatch_i × pct_BI_i

  where pct_BI_i = local percentage of birds from BI in cell i (varies 0-60%)

Step 4: Partition BI bycatch by age class
  BI_age_bycatch_i = BI_bycatch_i × age_weight_i

  where age_weight_i comes from Clay age-class distributions
```

**Detailed Process:**

#### Step 1: Load Local % BI Map (from Script 02)

Script 02 calculates the percentage of birds from Bird Island in each grid cell using Carneiro et al. 2020 population-specific distributions:

```r
pct_bird_island <- rast("output/rasters/percentage_bird_island.tif")
```

This map varies spatially from 0% (areas with only other populations) to ~60% (near South Georgia).

#### Step 2: Calculate Catchability (Same as 03b)

```r
# For each fishery
hooks_x_birds <- fishing_effort × total_bird_density_all_pops
β = (BPUE × H_total) / sum(hooks_x_birds)
```

#### Step 3: Calculate Total WAAL Bycatch

```r
total_waal_bycatch <- fishing_effort × total_bird_density × β
```

This gives bycatch for ALL WAAL populations in each cell.

#### Step 4: Allocate to Bird Island

```r
BI_total_bycatch <- total_waal_bycatch × pct_bird_island
```

This allocates the appropriate fraction to BI based on actual local composition.

#### Step 5: Partition by Age Class

```r
# Normalize Clay distributions and weight by age proportions
age_weights <- (bird_age_norm × prop_age) / sum_all_ages

# Allocate BI bycatch to each age
BI_age_bycatch <- BI_total_bycatch × age_weights
```

**Strengths:**
- Accounts for spatial variation in % BI (0-60% vs uniform 15.67%)
- Maintains catchability framework (theoretically rigorous)
- Uses Carneiro for population allocation (population-specific data)
- Uses Clay for age partitioning (age-specific data)
- Validated hybrid approach (r=0.98 correlation between datasets)
- Produces realistic spatial patterns

**Validation:**
- Total WAAL bycatch matches expected (100%)
- Age partitioning sums correctly (100%)
- Catchability values identical to 03b
- Spatial allocation reflects actual population composition

**Status:** Implemented and validated. Currently recommended approach.

**Key Results (Script 03c):**
- Pelagic: 196 birds/year (33% higher than 03b)
- Demersal: 116 birds/year (15% lower than 03b)
- **Total: 312 birds/year**

**Comparison with 03b:**
- Pelagic increased because BI birds occur in areas with less pelagic fishing than global average
- Demersal decreased because BI birds occur in areas with more demersal fishing than global average
- Reveals spatial heterogeneity masked by uniform 15.67% assumption

**BI Allocation Patterns:**
- BI gets 14.2% of pelagic bycatch (vs 32.1% mean BI across space)
- BI gets 19.5% of demersal bycatch (vs 32.1% mean BI across space)
- Both below spatial mean indicates fishing concentrates more in areas with other populations
- Pelagic especially so (high seas fleets operate widely)
- Demersal closer to mean (shelf/slope fishing near islands)

### Approach 4: Spatial Catchability Method (Script 03d) - **IN DEVELOPMENT**

**Conceptual Approach:**

This method extends 03c by incorporating **spatially-varying catchability** based on literature coverage. Developed following supervisor feedback, it addresses the limitation of single global BPUE by creating a cell-specific catchability map. Each 5×5 degree cell gets its own β value based on which BPUE studies cover it (via geographic bounding boxes). Where multiple studies overlap, catchabilities are averaged using **weighted mean by sample size**. For cells without literature coverage, **expert elicitation** assigns appropriate BPUE values based on similarity in fishing operations, mitigation practices, and regulatory environment. This approach maintains the catchability framework and local % BI allocation from 03c while capturing fine-scale spatial variation in fishing mortality risk.

**Mathematical Framework:**

**For each cell i:**

1. Identify studies covering cell i (via bounding boxes)
2. Calculate β for each study j:
```
β_j = (BPUE_j × H_total) / Σ_k (H_k × B_k_all)
```

3. Calculate cell-specific catchability (weighted average):
```
β_i = Σ_j (β_j × w_j) / Σ_j w_j

where w_j = hooks_observed_j  (weight by sample size)
```

4. Calculate total WAAL bycatch:
```
Total_bycatch_i = H_i × B_i_all × β_i
```

5. Allocate to BI using local % BI (same as 03c):
```
BI_bycatch_i = Total_bycatch_i × pct_BI_i
```

6. Partition by age class (same as 03c):
```
BI_age_bycatch_i = BI_bycatch_i × age_weight_i
```

**Detailed Process:**

#### Step 1: Define BPUE Studies with Bounding Boxes

From literature review (script 04), extract for each study:
```r
bpue_studies <- tibble(
  study_id = "Tuck2015_SAtl",
  bpue_per_1000 = 0.007,
  lat_min = -60, lat_max = -35,
  lon_min = -65, lon_max = -25,
  hooks_observed = 750000,  # For weighting
  year_collected = 2012,
  fishery = "pelagic"
)
```

#### Step 2: Assign Studies to Cells

For each 5×5 cell:
- Check which studies' bounding boxes overlap this cell
- Collect all BPUE values from overlapping studies

#### Step 3: Calculate Weighted Catchability

If cell has N overlapping studies:
```r
# Calculate β for each study
betas <- map(studies, ~calculate_catchability(.x$bpue, H_total, sum_H_x_B))

# Weighted average by sample size
beta_cell <- weighted.mean(betas, w = studies$hooks_observed)
```

**Rationale for weighting:** Studies with larger sample sizes are more reliable and should contribute more to the average.

#### Step 4: Expert Elicitation for Gap Filling

For cells not covered by any literature study, consult fisheries experts to assign BPUE based on:

**Similarity criteria:**
- Fishing operations (fleet type, gear characteristics, fishing practices)
- Mitigation adoption (tori lines, night setting, weighted lines, hook shielding)
- Regulatory environment (RFMO requirements, enforcement levels, IUU risk)
- Geographic/oceanographic context

**Expert gap-fill framework:**
```r
expert_gap_fill <- tibble(
  region_name = "South_Atlantic_EEZ",
  lat_min = -60, lat_max = -30,
  lon_min = -70, lon_max = -20,
  bpue_pel_expert = 0.007,  # Based on similar well-regulated fisheries
  bpue_dem_expert = 0.002,
  justification = "Similar to South Georgia - good mitigation, strong enforcement"
)
```

**Fallback:** For cells outside both literature coverage and expert regions, use global weighted mean catchability.

#### Step 5: Create Catchability Rasters

Result: Two rasters (pelagic and demersal) where each cell has its β value based on:
- Literature studies (if covered)
- Expert assignment (if no literature)
- Global mean (if neither)

#### Step 6: Calculate Bycatch

Apply cell-specific catchability (same framework as 03c):
```r
total_bycatch_i = H_i × B_i_all × β_i
BI_bycatch_i = total_bycatch_i × pct_BI_i
BI_age_bycatch_i = BI_bycatch_i × age_weight_i
```

**Strengths:**
- Captures fine-scale spatial variation in fishing practices/mitigation
- Empirical where possible (literature) + expert knowledge for gaps
- Weighted averaging accounts for study reliability (sample size)
- Maintains catchability framework (theoretically rigorous)
- Uses local % BI allocation (from 03c)
- Fine spatial resolution (5×5 cells)
- Transparent (can see which studies inform each cell)

**Limitations:**
- Requires comprehensive literature review (~20-30 studies)
- Needs expert consultation for gap filling
- Computationally intensive (calculates β for each cell)
- Bounding boxes may overlap imperfectly with actual study areas

**Validation:**
- Total WAAL bycatch should match weighted mean BPUE × total hooks
- Compare with 03c to quantify impact of spatial variation
- Sensitivity to weighting scheme (sample size vs equal weight)
- Coverage maps show which cells informed by literature vs expert

**Status:** Framework implemented, awaiting literature review data and expert consultation.

**Key Decision Points (Supervisor Feedback):**
- ✓ Weight by sample size (not equal weight)
- ✓ Use expert elicitation for gaps (not simple interpolation or global mean)
- ✓ Base expert assignments on fishing similarity (operations, mitigation, regulations)

---

### Approach 5: Regional Catchability Method (Alternative Future) - **ALTERNATIVE APPROACH**

**Conceptual Approach:**

The regional catchability method represents our ultimate analytical goal—a **hybrid approach that combines the strengths of both spatial BPUE variation and the catchability framework** while avoiding the pitfalls of each used alone. This method recognizes that BPUE varies geographically due to real differences in fishing practices (mitigation adoption, gear types, regulatory enforcement) while maintaining the theoretical rigor of the catchability framework for fine-scale spatial partitioning within regions. Rather than creating a blocky BPUE map that would be applied directly (as in a simple spatial approach), we use literature-derived regional BPUE values to calculate region-and-fishery-specific catchability coefficients (β_rf). These catchabilities are then applied within each region using the same interaction-based framework as Approach 2, ensuring that spatial allocation within regions is driven by the hooks × birds interaction, not by arbitrary bird composition. This approach gives us **regional variation in fishing mortality risk** (capturing differences between well-regulated fisheries like South Georgia versus areas with weaker mitigation) combined with **fine-scale spatial partitioning** within each region (capturing local hotspots based on encounter rates). The result is bycatch estimates stratified by region × fishery × age class, providing both the demographic rates needed for the matrix model and the regional detail needed for targeted management recommendations.

**Mathematical Framework:**

This approach extends the catchability framework to account for regional variation in BPUE due to different fishing practices, mitigation measures, and regulatory environments.

**Regional total bycatch constraint:**
For each region r and fishery f:
```
C_total_rf = α_rf × H_total_rf
```

Where:
- C_total_rf = total expected bycatch in region r, fishery f
- α_rf = regional BPUE from literature (weighted average of studies in that region)
- H_total_rf = total hooks in region r, fishery f

**Regional catchability:**
```
β_rf = (α_rf / 1000) × H_total_rf / Σ_i∈r (H_i_f × B_i_all_pops)
```

Where the sum is only over cells within region r.

**Bird Island age-class bycatch:**
```
C_rfa = Σ_i∈r (H_i_f × B_i_a_BI_scaled × β_rf)
```

**Total bycatch across all regions:**
```
C_total_fa = Σ_r C_rfa
```

**Detailed Process:**

#### Step 1: Create Regional BPUE Map from Literature Review

**From script 04 literature review, compile studies by region:**

Example regions (based on RFMO boundaries and study coverage):
- **R1:** South Atlantic (ICCAT area, south of 25°S)
- **R2:** Indian Ocean (IOTC area, south of 25°S)
- **R3:** Western Pacific (WCPFC area, south of 25°S)
- **R4:** Eastern Pacific (IATTC area, south of 25°S)
- **R5:** Southern Ocean (south of 60°S, all longitudes)

**Example literature compilation for R1 (South Atlantic), Pelagic:**

| Study | Year | BPUE (per 1000) | Hooks Observed | Weight |
|-------|------|-----------------|----------------|--------|
| Tuck et al. 2015 | 2015 | 0.007 | 500,000 | 0.25 |
| Klaer 2012 | 2012 | 0.010 | 300,000 | 0.15 |
| Robertson et al. 2014 | 2014 | 0.008 | 400,000 | 0.20 |
| Phillips et al. 2016 | 2016 | 0.006 | 800,000 | 0.40 |

**Weighted average:**
```r
α_R1_pel <- Σ(BPUE_i × weight_i) / Σ(weight_i)
          = (0.007×0.25 + 0.010×0.15 + 0.008×0.20 + 0.006×0.40)
          = 0.00725 birds per 1000 hooks
```

Weight by:
- Sample size (hooks observed)
- Recency (more recent studies weighted higher)
- Study quality (peer-reviewed vs. grey literature)
- Relevance (exact location match vs. broader region)

**Repeat for all region × fishery combinations.**

#### Step 2: Assign Grid Cells to Regions

Create a regional mask:
```r
# Create raster with region IDs
region_mask <- rast(template)

# Assign cells to regions based on lat/lon
# Example: South Atlantic
region_mask[lat < -25 & lon > -70 & lon < 20] <- 1  # R1: South Atlantic
region_mask[lat < -25 & lon >= 20 & lon < 120] <- 2 # R2: Indian Ocean
# ... etc for all regions
```

#### Step 3: Calculate Regional Catchabilities

**For each region and fishery:**

```r
# Example: South Atlantic, Pelagic
# Extract cells in this region
cells_R1 <- which(region_mask == 1)

# Calculate hooks × birds for these cells
hooks_x_birds_R1_pel <- sum(
  fishing_effort_pelagic[cells_R1] × total_bird_density[cells_R1]
)

# Total hooks in region
H_total_R1_pel <- sum(fishing_effort_pelagic[cells_R1])

# Regional BPUE (from literature)
α_R1_pel <- 0.00725 / 1000  # Convert to per hook

# Calculate regional catchability
β_R1_pel <- (α_R1_pel × H_total_R1_pel) / hooks_x_birds_R1_pel
          = (7.25×10^-6 × 4.5×10^7) / 2.2×10^4
          = 0.0148
```

**Repeat for all regions and fisheries** to create a table of β values:

| Region | Fishery | α (BPUE per hook) | H_total | Σ(H×B) | β (catchability) |
|--------|---------|-------------------|---------|--------|------------------|
| R1: S Atlantic | Pelagic | 7.25×10^-6 | 4.5×10^7 | 2.2×10^4 | 0.0148 |
| R1: S Atlantic | Demersal | 1.54×10^-5 | 1.2×10^7 | 5.1×10^4 | 0.0036 |
| R2: Indian Ocean | Pelagic | 1.20×10^-5 | 6.8×10^7 | 4.0×10^4 | 0.0204 |
| R2: Indian Ocean | Demersal | 2.10×10^-5 | 1.5×10^7 | 6.2×10^4 | 0.0051 |
| R3: W Pacific | Pelagic | 5.50×10^-6 | 3.2×10^7 | 1.8×10^4 | 0.0098 |
| ... | ... | ... | ... | ... | ... |

**Note the variation in β values:**
- Indian Ocean pelagic has higher β (0.0204) - perhaps due to less mitigation
- Western Pacific has lower β (0.0098) - perhaps due to better compliance
- This captures real regional differences in fishing mortality risk

#### Step 4: Calculate Bycatch for Each Region × Fishery × Age Class

**For each combination:**

```r
# Example: South Atlantic, Pelagic, First Breeders
# Get cells in region R1
cells_R1 <- which(region_mask == 1)

# Calculate bycatch in these cells
bycatch_R1_pel_fb <- sum(
  fishing_effort_pelagic[cells_R1] ×
  bird_fb_scaled[cells_R1] ×
  β_R1_pel
)

# Repeat for all age classes in this region/fishery
# Repeat for all regions and fisheries
```

**Example full output table:**

| Region | Fishery | Age Class | Bycatch (birds/yr) | β | α (BPUE per 1000) | % of Total |
|--------|---------|-----------|--------------------|----|-------------------|------------|
| **South Atlantic** | **Pelagic** | FB | 3.2 | 0.0148 | 0.00725 | 1.1% |
| | | SB | 8.5 | 0.0148 | 0.00725 | 3.0% |
| | | NB | 15.2 | 0.0148 | 0.00725 | 5.4% |
| | | J2J3 | 7.1 | 0.0148 | 0.00725 | 2.5% |
| | | IMM | 22.8 | 0.0148 | 0.00725 | 8.0% |
| | **Pelagic subtotal** | -- | **56.8** | -- | -- | **20.0%** |
| | **Demersal** | FB | 2.8 | 0.0036 | 0.01542 | 1.0% |
| | | SB | 5.2 | 0.0036 | 0.01542 | 1.8% |
| | | NB | 18.4 | 0.0036 | 0.01542 | 6.5% |
| | | J2J3 | 6.5 | 0.0036 | 0.01542 | 2.3% |
| | | IMM | 21.3 | 0.0036 | 0.01542 | 7.5% |
| | **Demersal subtotal** | -- | **54.2** | -- | -- | **19.1%** |
| **S Atlantic TOTAL** | -- | -- | **111.0** | -- | -- | **39.1%** |
| | | | | | | |
| **Indian Ocean** | **Pelagic** | FB | 4.1 | 0.0204 | 0.01200 | 1.4% |
| | | SB | 10.2 | 0.0204 | 0.01200 | 3.6% |
| | | NB | 20.8 | 0.0204 | 0.01200 | 7.3% |
| | | J2J3 | 10.5 | 0.0204 | 0.01200 | 3.7% |
| | | IMM | 31.5 | 0.0204 | 0.01200 | 11.1% |
| | **Pelagic subtotal** | -- | **77.1** | -- | -- | **27.2%** |
| | **Demersal** | FB | 3.5 | 0.0051 | 0.02100 | 1.2% |
| | | SB | 7.8 | 0.0051 | 0.02100 | 2.7% |
| | | NB | 22.1 | 0.0051 | 0.02100 | 7.8% |
| | | J2J3 | 7.9 | 0.0051 | 0.02100 | 2.8% |
| | | IMM | 28.2 | 0.0051 | 0.02100 | 9.9% |
| | **Demersal subtotal** | -- | **69.5** | -- | -- | **24.5%** |
| **Indian Ocean TOTAL** | -- | -- | **146.6** | -- | -- | **51.6%** |
| | | | | | | |
| **Western Pacific** | **Pelagic** | FB | 1.0 | 0.0098 | 0.00550 | 0.4% |
| | | SB | 2.1 | 0.0098 | 0.00550 | 0.7% |
| | | NB | 3.1 | 0.0098 | 0.00550 | 1.1% |
| | | J2J3 | 1.5 | 0.0098 | 0.00550 | 0.5% |
| | | IMM | 4.8 | 0.0098 | 0.00550 | 1.7% |
| | **Pelagic subtotal** | -- | **12.5** | -- | -- | **4.4%** |
| | **Demersal** | FB | 0.8 | 0.0028 | 0.01200 | 0.3% |
| | | SB | 1.3 | 0.0028 | 0.01200 | 0.5% |
| | | NB | 3.5 | 0.0028 | 0.01200 | 1.2% |
| | | J2J3 | 1.2 | 0.0028 | 0.01200 | 0.4% |
| | | IMM | 4.2 | 0.0028 | 0.01200 | 1.5% |
| | **Demersal subtotal** | -- | **11.0** | -- | -- | **3.9%** |
| **W Pacific TOTAL** | -- | -- | **23.5** | -- | -- | **8.3%** |
| | | | | | | |
| **GRAND TOTAL** | -- | **All ages** | **284.0** | -- | -- | **100.0%** |

*Note: These are illustrative numbers for demonstration. Actual values will come from literature review (script 04).*

#### Step 5: Aggregate for Demographic Model

**For demographic model input, sum across regions and fisheries:**

| Age Class | Total Bycatch | Per Capita Rate | Population | Primary Source Regions |
|-----------|---------------|-----------------|------------|------------------------|
| FB | 15.1 | 0.01634 | 924.2 | Indian Ocean (27%), S Atlantic (21%) |
| SB | 35.1 | 0.01283 | 2735.6 | Indian Ocean (29%), S Atlantic (24%) |
| NB | 83.1 | 0.02098 | 3960.4 | Indian Ocean (25%), S Atlantic (18%) |
| J2J3 | 34.7 | 0.02112 | 1642.8 | Indian Ocean (30%), S Atlantic (20%) |
| IMM | 116.0 | 0.01916 | 6054.8 | Indian Ocean (27%), S Atlantic (20%) |
| **TOTAL** | **284.0** | -- | 15317.8 | -- |

**But also have the detailed stratification available for:**
- Sensitivity analyses (what if Indian Ocean mitigation improves?)
- Management prioritization (which regions/fisheries contribute most?)
- Scenario testing (what if pelagic effort shifts to demersal?)

**Strengths:**
- Incorporates regional variation in fishing practices/mitigation
- Fishery-specific catchabilities reflecting real differences
- Fine-scale spatial partitioning within regions (via catchability framework)
- Most realistic representation of spatial heterogeneity
- Provides bycatch estimates stratified by region × fishery × age class
- Enables region-specific management recommendations
- Captures variation in mitigation effectiveness
- Can track changes over time as mitigation improves

**Weaknesses:**
- Requires comprehensive literature review
- More complex implementation
- Data-intensive (need sufficient studies in each region)
- Regional boundaries somewhat arbitrary
- Some regions may have sparse data
- Must weight studies appropriately (sample size, recency, quality)

**Status:** In development. Requires completion of literature review (script 04).

**Next Steps:**
1. Complete literature review (script 04) - extract all BPUE values
2. Define regions based on data coverage and management relevance
3. Calculate weighted regional BPUE values
4. Implement regional catchability calculations
5. Validate against total from script 03b (should be similar if weighted properly)
6. Document regional variation and management implications

---

## Script Summaries

### Script 01: `01_fishing_effort_overlap.Rmd`

**Purpose:** Calculate spatial overlap between bird distributions and fishing effort.

**Inputs:**
- Bird Island age-class distributions (Clay et al. 2019)
- Pelagic and demersal longline fishing effort

**Process:**
1. Load and normalize bird distributions
2. Crop fishing effort to bird distribution extents
3. Calculate overlap indices (bird density × fishing effort > 0)
4. Create maps showing spatial overlap

**Outputs:**
- Overlap rasters for each age class × fishery combination
- Maps of overlap indices
- Used in Approach 1 (script 03)

**Status:** Complete and validated.

### Script 02: `02_compare_pop_distributions.Rmd`

**Purpose:** Calculate the proportion of birds from Bird Island in each grid cell.

**Inputs:**
- Population-specific distributions (Carneiro et al. 2020: Crozet, Kerguelen, South Georgia)
- Breeding pair estimates (global)

**Process:**
1. Normalize each population distribution to sum to 1
2. Weight by breeding population size
3. Use "clipped" method: mask other populations to South Georgia cells
4. Calculate percentage of birds from South Georgia and Bird Island (60% of SG)
5. Create total bird density map (all populations) for catchability calculations

**Key Calculations:**
```r
# Population proportions (using actual total = 5,947 pairs)
prop_southg = 1553 / 5947 = 0.2611
prop_crozet = 340 / 5947 = 0.0572
prop_kerg = 354 / 5947 = 0.0595
prop_pei = (1800 + 1900) / 5947 = 0.6222

# Bird Island
prop_bird_island = 0.6 × prop_southg = 0.1567

# Total bird density (normalized, sums to 1.0)
total_bird_density = Σ (pop_dist_norm × pop_proportion)
```

**Note on corrections:** Previous analyses used 6,000 as a round number for total pairs, causing proportions to sum to 0.991 instead of 1.0. Current analysis uses the actual total (5,947) for mathematical correctness, resulting in ~0.9% higher percentage values.

**Outputs:**
- `percentage_south_georgia.tif` - % of birds from South Georgia in each cell
- `percentage_bird_island.tif` - % of birds from Bird Island in each cell
- `total_bird_density_all_pops.tif` - Total WAAL density (all populations, for catchability)
- Used in Approaches 1, 2, and 3

**Status:** Complete and validated.

### Script 02b: `02b_compare_carneiro_clay.Rmd`

**Purpose:** Compare Carneiro South Georgia distribution with Clay total (sum of all age classes).

**Inputs:**
- Carneiro et al. 2020 South Georgia distribution
- Clay et al. 2019 age-class distributions (all ages)
- Demographic proportions (to weight age classes)

**Process:**
1. Load Carneiro SG distribution and normalize
2. Load and normalize all Clay age-class distributions
3. Weight Clay distributions by age proportions and sum
4. Resample to common grid
5. Calculate correlation, difference maps, scatter plots
6. Assess agreement metrics

**Outputs:**
- Correlation statistics (Pearson, Spearman)
- Difference maps (Clay - Carneiro)
- Scatter plots
- Agreement metrics

**Results:**
- Pearson r = 0.98 (98% variance shared)
- Spearman rho = 0.94 (rank order consistent)
- **Conclusion**: Distributions highly consistent, validates hybrid approach

**Status:** Complete. Validates using Carneiro for population allocation + Clay for age partitioning.

### Script 03: `03_bycatch_estimates.Rmd`

**Purpose:** Estimate bycatch using overlap-based method (Approach 1).

**Inputs:**
- Percentage Bird Island rasters (from script 02)
- Overlap indices (from script 01)
- BPUE values from literature
- Demographic proportions

**Process:**
1. Create BPUE maps scaled by % Bird Island
2. Multiply by overlap indices for each age class
3. Scale by age class proportion
4. Calculate per capita rates

**Outputs:**
- Total bycatch by fishery and age class
- Per capita mortality rates
- Bycatch density maps

**Current Results:**
- Pelagic: 61.8 birds/year
- Demersal: 161.4 birds/year
- **Total: 223.2 birds/year**

**Status:** Complete but not recommended due to conceptual issues.

### Script 03b: `03b_bycatch_catchability_method.Rmd` - **SUPERSEDED BY 03c**

**Purpose:** Estimate bycatch using catchability method (Approach 2). Superseded due to uniform scaling assumption.

**Inputs:**
- Total bird density (all populations, from script 02)
- Bird Island age-class distributions (Clay et al. 2019)
- Fishing effort (pelagic and demersal)
- BPUE values from literature
- Demographic proportions

**Process:**
1. **Scale Bird Island distributions to global proportion:**
   - Normalize each age-class distribution to sum to 1
   - Multiply by age class proportion of BI population
   - Multiply by BI proportion of global population (15.67%)
   - Result: Bird densities in same units as total bird density

2. **Calculate catchability (β) for each fishery:**
   ```r
   β_pelagic = (α_pel / 1000) × H_total_pel / Σ(H_i_pel × B_i_all_pops)
   β_demersal = (α_dem / 1000) × H_total_dem / Σ(H_i_dem × B_i_all_pops)
   ```

3. **Calculate bycatch for each age class:**
   ```r
   Bycatch_age = Σ_i (H_i × B_i_age_BI_scaled × β)
   ```

4. Calculate per capita rates and create maps

**Key Corrections Made:**
- Fixed BPUE units (converted from per 1,000 hooks to per hook)
- Properly scaled BI distributions to global proportion
- Ensured bird densities match units used in catchability calculation

**Current Results:**
- Pelagic: 147.9 birds/year
- Demersal: 136.4 birds/year
- **Total: 284.3 birds/year**

**Validation:**
- Expected BI bycatch (simple calculation): 290 birds/year
- Catchability method: 284 birds/year (98% of expected ✓)

**Status:** Complete but superseded by 03c. Preserved for comparison.

### Script 03c: `03c_bycatch_corrected_catchability.Rmd` - **CURRENT RECOMMENDED**

**Purpose:** Estimate bycatch using corrected catchability method (Approach 3) with local % BI.

**Inputs:**
- Total bird density (all populations, from script 02)
- **Percentage Bird Island map** (from script 02) - KEY NEW INPUT
- Clay age-class distributions (from Clay et al. 2019)
- Fishing effort (pelagic and demersal)
- BPUE values from literature
- Demographic proportions

**Process:**
1. **Calculate catchability (β) for each fishery** (same as 03b):
   ```r
   β = (BPUE × H_total) / Σ(H_i × B_i_all_pops)
   ```

2. **Calculate total WAAL bycatch density**:
   ```r
   Total_bycatch_i = H_i × B_i_all_pops × β
   ```

3. **Allocate to BI using local % BI** (KEY DIFFERENCE from 03b):
   ```r
   BI_total_bycatch_i = Total_bycatch_i × pct_BI_i
   ```
   Where pct_BI_i varies spatially (0-60%), NOT uniform 15.67%

4. **Partition by age class** using Clay distributions:
   ```r
   age_weights_i = (bird_age_norm_i × prop_age) / sum_all_ages_i
   BI_age_bycatch_i = BI_total_bycatch_i × age_weights_i
   ```

**Key Innovation:**
- Uses **actual local % BI** from Carneiro distributions (0-60% spatial variation)
- NOT global average (15.67%) applied uniformly
- Properly accounts for spatial heterogeneity in population composition
- Validates hybrid data approach (Carneiro for allocation, Clay for age partitioning)

**Current Results:**
- Pelagic: 196.4 birds/year (33% higher than 03b)
- Demersal: 115.7 birds/year (15% lower than 03b)
- **Total: 312.1 birds/year**

**Comparison with 03b:**
- Pelagic increased: BI birds occur in areas with less pelagic fishing than global average suggests
- Demersal decreased: BI birds occur in areas with more demersal fishing than global average suggests
- Reveals spatial heterogeneity masked by uniform 15.67% assumption

**Validation:**
- Total WAAL bycatch matches expected: 100% ✓
- Age partitioning sums correctly: 100% ✓
- Catchability values identical to 03b ✓
- BI allocation: 14.2% (pelagic), 19.5% (demersal) vs 32.1% mean BI across space

**Status:** Complete, validated, and currently recommended. Use for demographic model input.

### Script 03d: `03d_bycatch_spatial_catchability.Rmd` - **IN DEVELOPMENT**

**Purpose:** Estimate bycatch using spatial catchability method (Approach 4) with cell-specific β values.

**Inputs:**
- Total bird density (all populations, from script 02)
- Percentage Bird Island map (from script 02)
- Clay age-class distributions (from Clay et al. 2019)
- Fishing effort (pelagic and demersal)
- **BPUE studies database with bounding boxes** (from lit review - script 04) - KEY NEW INPUT
- **Expert elicitation for gap filling** - KEY NEW INPUT
- Demographic proportions

**Process:**
1. **Define BPUE studies with bounding boxes**:
   ```r
   bpue_studies <- tibble(
     study_id, bpue_per_1000,
     lat_min, lat_max, lon_min, lon_max,
     hooks_observed, year_collected
   )
   ```

2. **For each 5×5 cell, identify overlapping studies**:
   - Check which studies' bounding boxes cover this cell
   - Collect BPUE values from all overlapping studies

3. **Calculate cell-specific catchability (weighted average)**:
   ```r
   # Calculate β for each study
   betas <- map(studies, ~calculate_catchability(.x$bpue))
   # Weighted mean by sample size
   beta_cell <- weighted.mean(betas, w = studies$hooks_observed)
   ```

4. **Fill gaps using expert elicitation**:
   - For cells without literature coverage
   - Assign BPUE based on fishing similarity (operations, mitigation, regulations)
   - Document rationale for each assignment

5. **Create catchability rasters**:
   - Result: β_pelagic(x,y) and β_demersal(x,y)
   - Each cell has its own catchability value

6. **Calculate bycatch** (same framework as 03c):
   ```r
   Total_bycatch_i = H_i × B_i_all × β_i  # Cell-specific β
   BI_bycatch_i = Total_bycatch_i × pct_BI_i  # Local % BI
   BI_age_bycatch_i = BI_bycatch_i × age_weights_i  # Age partitioning
   ```

**Key Innovation:**
- **Cell-specific catchability** based on literature coverage
- **Weighted averaging** by sample size when multiple studies overlap
- **Expert elicitation** for gap filling (not simple interpolation)
- Maintains local % BI allocation from 03c

**Advantages:**
- Captures fine-scale spatial variation in fishing practices
- Empirical where possible (literature) + expert knowledge for gaps
- Weighted by study reliability (sample size)
- Transparent (can see which studies inform each cell)

**Planned Outputs:**
- Catchability maps (pelagic and demersal)
- Study coverage maps (# studies per cell)
- Bycatch by age class
- Per capita mortality rates
- Comparison with 03c

**Status:** Framework implemented with placeholders. Awaiting:
1. Literature review data (script 04) - ~20-30 studies with bounding boxes
2. Expert consultation for gap filling

**Supervisor Feedback Incorporated:**
- ✓ BPUE NOT scaled by % BI (confirmed correct)
- ✓ Cell-specific catchability from literature
- ✓ Weighted averaging by sample size
- ✓ Expert elicitation for gaps

### Script 04: `04_bpue_literature_review.Rmd`

**Purpose:** Compile, standardize, and analyze BPUE estimates from published literature. Identify spatial and temporal gaps in BPUE coverage relative to fishing effort.

**Inputs:**
- `data/BPUE_2926.csv` — BPUE literature review spreadsheet
- `data/Pel_LL_effort.csv` — Pelagic longline effort
- Demersal longline effort (CCAMLR, Argentina, Chile, Falklands, Namibia, South Africa)
- `data/ne_10m_land/` — Natural Earth basemap

**Process:**
1. Load BPUE CSV and standardize bounding box coordinates (manual lookup table for diverse coordinate formats)
2. Load and standardize PLL and DLL fishing effort data by fleet and year group (1990-1995, 1996-2000, 2001-2005, 2006-2010)
3. Create sf bounding box polygons for each BPUE study; expand multi-period entries across year groups
4. Generate fleet-specific maps (faceted by period) showing effort + BPUE bounding boxes
5. Spatial gap analysis: calculate % of effort cells covered by BPUE studies per fleet/period
6. Regional gap analysis: assign effort and BPUE to 7 ocean regions (SW/SE Atlantic, SW/SE Indian, SW/SE Pacific, Southern Ocean), identify fleet × region × period combinations lacking BPUE data
7. Sanity check comparing CSV region labels against bounding box centroid region assignments
8. BPUE summary statistics (mean, SD) by fishery, fleet, period, and region

**Summary statistic methodology:**
- `n_studies` = `n_distinct(citation)` — counts unique papers, not inflated by multi-region/period expansion
- `n_bpue` = `n_distinct(row_id)` — counts unique BPUE observations, not inflated by expansion
- `mean_bpue` and `sd_bpue` computed on de-duplicated observations (`bpue[!duplicated(row_id)]`) to avoid inflation from year-group or region expansion
- Regions assigned from CSV labels (not bounding box coordinates)

**Outputs:**
- `data/BPUE_2926_standardized.csv` — BPUE data with standardized bounding box coordinates
- `output/spatial_gap_analysis.csv` — % effort cells covered by BPUE per fleet/period
- `output/temporal_gap_analysis.csv` — fleet/period combinations lacking BPUE
- `output/regional_bpue_gap_table.csv` — full fleet × region × period table with BPUE where available
- `output/regional_bpue_gaps_only.csv` — effort-exists-but-no-BPUE subset
- `output/bpue_summary_full.csv` — BPUE stats by fishery × fleet × period × region
- `output/bpue_summary_by_fishery.csv`
- `output/bpue_summary_by_fleet.csv`
- `output/bpue_summary_by_period.csv`
- `output/bpue_summary_by_region.csv`
- `output/maps/bpue_review/` — fleet maps, coverage heatmaps, regional gap heatmaps

**Status:** Complete and validated. Provides BPUE data and gap identification for script 03d spatial catchability approach.

### Script 07: `07_diagnostic_figures.Rmd`

**Purpose:** Diagnostic figures comparing key inputs and outcomes (effort, catchability, survival, FM) across the four time periods (06a–06d), plus cross-period heatmap visualizations (Figures P4–P8).

**Inputs:**
- `output/hooks_by_fleet_period_03g_*.csv` — mean annual hooks per fleet × period
- `output/bycatch_by_fishery_period_03f_*.csv` — mean annual BI bycatch per fishery × period
- `output/percap_rates_by_period_03f_*.csv` — per-capita FM by age class × period
- `output/bycatch_*_03g_*.csv` — observed + counterfactual bycatch for FM decomposition
- `output/heatmap_data_{period}_*.csv`, `heatmap_ref_pts_{period}_*.csv`, `scenario_heatmap_pts_{period}_*.csv` — from scripts 06a–06d
- Raw source files: `data/Pel_LL_effort.csv`, all 7 DLL CSVs — for mean/median effort diagnostic
- `data/WAAL_dist_Clay2019/Dem_props copy.csv` — population sizes by age class and period

**Figures produced:**

- **Plot 1 (p1)** — PLL effort (bars) + catchability/BPUE (line), dual y-axis
- **Plot 2 (p2)** — DLL effort (bars) + catchability/BPUE (line), dual y-axis
- **Mean vs Median effort diagnostic** — raw annual hooks per year with mean and median overlaid; summary table of CV% and mean/median ratio per period, assessing whether median is more appropriate than mean for 06 scripts
- **Plot 3 (p3)** — Mean per-capita FM vs total mortality budget (survival reference lines)
- **Fleet effort plots** — stacked bar charts by fleet × period and by fleet × year (1990–2009)
- **Figure P4** — stacked bar decomposition of FM decline: effort-driven vs catchability-driven components
- **Figure P5** — 06a coverage × efficacy lambda heatmap with three later-period equivalent-mitigation points
- **Figure P6** — effort_ratio × β_ratio lambda surface with observed period trajectories and theoretical scenario points
- **Figure P7** — 2×2 faceted heatmap (one panel per period) with shared lambda scale; gold diamond reference points (no-mitigation, historical, current) and white scenario lines
- **Figure P8** — single-panel heatmap, all periods on 1990–1994 FM baseline surface

**Figure P8 details:**

P8 places all four periods' reference points (Historical and Current regs) and three future scenario lines on the 1990–1994 lambda surface. This isolates the *mitigation signal* from the *effort-reduction signal*: reading each point's λ against the 1990–1994 surface answers "if this period's bycatch-weighted coverage/efficacy were applied to 1990–1994 effort levels, what would population growth rate be?"

Key design choices:
- **Surface**: same formula as P5/P7 top-left panel; `ns_Juv = 1 - ((fm_base × (1 - eff × cov)) + nm_base)` for each stage; 1990–1994 FM and NM from script 03f
- **Lambda scale**: `scale_fill_distiller` with `limits = lambda_range` (shared with P7) and `oob = scales::squish` — required because heatmap_p8 lambda is recomputed from scratch and floating-point differences from pre-saved 06a values cause minimum-lambda cells (bottom/left edges where `eff × cov = 0`) to fall just outside `lambda_range`; default `oob = censor` renders these as `na.value = "grey50"` (visible grey border)
- **Reference points**: `shape = 19, size = 2.5` (small solid circles) per period; "Current regs (XXXX effort)" labels distinguish that same regulations produce different bycatch-weighted coverage/efficacy positions because `fleet_percap` (bycatch distribution across fleets) differs between periods; Historical (1990–1994) labeled "(no mitigation)" since 06a hist_fleet_mitigation is all zeros
- **Scenario lines**: 1990–1994 period only, grey (`color = "grey85"`); scenarios = 2/3 PLL, 3/3 PLL, 3/3 all fleets, full elimination

**Outputs:**
- `output/figures/07_diagnostic_effort_catchability_survival.png`
- `output/figures/07_fleet_effort_by_period.png`
- `output/figures/07_fleet_effort_by_year.png`
- `output/figures/07_p4_fm_decomposition_bars.png`
- `output/figures/07_p5_period_recovery_heatmap.png`
- `output/figures/07_p6_decomp_effort_beta_heatmap.png`
- `output/figures/07_p7_combined_heatmap_all_periods.png`
- `output/figures/07_p8_single_panel_all_periods.png`

**Status:** Complete and validated.

---

## Analysis Workflow

### Current Workflow (Using Script 03b)

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA INPUTS                               │
├─────────────────────────────────────────────────────────────┤
│ • Bird distributions (Clay 2019)                            │
│ • Population distributions (Carneiro 2020)                  │
│ • Fishing effort (pelagic, demersal)                        │
│ • BPUE from literature (mean values)                        │
│ • Demographic data (proportions, population sizes)          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              SCRIPT 01: Fishing Effort Overlap              │
├─────────────────────────────────────────────────────────────┤
│ Calculate: overlap_indices[fishery, age_class]              │
│ Output: overlap rasters, maps                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         SCRIPT 02: Population Distributions                 │
├─────────────────────────────────────────────────────────────┤
│ Calculate:                                                   │
│  • pct_bird_island[cell]                                    │
│  • pct_south_georgia[cell]                                  │
│  • total_bird_density[cell] (all populations)               │
│ Output: percentage rasters, total density raster            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         SCRIPT 03b: Bycatch (Catchability Method)           │
├─────────────────────────────────────────────────────────────┤
│ Calculate:                                                   │
│  1. β[fishery] = catchability coefficients                  │
│  2. bycatch[fishery, age_class]                             │
│  3. percap_mortality[age_class]                             │
│ Output: bycatch estimates, maps, CSV summaries              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              DEMOGRAPHIC MATRIX MODEL                        │
├─────────────────────────────────────────────────────────────┤
│ Input: percap_mortality[age_class]                          │
│ Output: population growth rate, sensitivity, projections    │
└─────────────────────────────────────────────────────────────┘
```

### Future Workflow (Using Script 03c with Regional Catchabilities)

```
┌─────────────────────────────────────────────────────────────┐
│                    DATA INPUTS                               │
├─────────────────────────────────────────────────────────────┤
│ • Bird distributions (Clay 2019)                            │
│ • Population distributions (Carneiro 2020)                  │
│ • Fishing effort (pelagic, demersal)                        │
│ • Regional BPUE from literature review ← NEW!               │
│ • Demographic data (proportions, population sizes)          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         SCRIPT 04: BPUE Literature Review                   │
├─────────────────────────────────────────────────────────────┤
│ Process:                                                     │
│  • Extract BPUE from PDFs                                   │
│  • Create spatial bounding boxes                            │
│  • Calculate weighted regional averages                     │
│ Output: BPUE[region, fishery], spatial bounds               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              SCRIPT 01: Fishing Effort Overlap              │
├─────────────────────────────────────────────────────────────┤
│ Calculate: overlap_indices[fishery, age_class]              │
│ Output: overlap rasters, maps                               │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│         SCRIPT 02: Population Distributions                 │
├─────────────────────────────────────────────────────────────┤
│ Calculate:                                                   │
│  • pct_bird_island[cell]                                    │
│  • total_bird_density[cell] (all populations)               │
│ Output: percentage rasters, total density raster            │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│    SCRIPT 03c: Bycatch (Regional Catchability Method)       │
├─────────────────────────────────────────────────────────────┤
│ Calculate:                                                   │
│  1. β[region, fishery] = regional catchabilities            │
│  2. bycatch[region, fishery, age_class]                     │
│  3. percap_mortality[age_class] (summed across regions)     │
│ Output: stratified bycatch estimates, maps, CSV summaries   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│              DEMOGRAPHIC MATRIX MODEL                        │
├─────────────────────────────────────────────────────────────┤
│ Input: percap_mortality[age_class]                          │
│ Options:                                                     │
│  • Use total across all regions/fisheries                   │
│  • Run scenarios: pelagic only, demersal only               │
│  • Run scenarios: specific regions                          │
│ Output: population growth rate, sensitivity, projections    │
└─────────────────────────────────────────────────────────────┘
```

---

## Future Development

### Implemented (as of February 2026)

1. **Fleet-level spatial catchability (script 03f)** — current recommended approach. Per-study β from BPUE bounding boxes, hierarchical gap-filling, fleet × fishery × period × age-class bycatch.
2. **Multi-period demographic model (scripts 06a–06d)** — period-matched bycatch rates and population sizes. Full blanket + fleet-level mitigation analysis run independently per period.
3. **Mortality partitioning table** — per-stage fm_dll, fm_pll, nm, pct_fm saved per period.
4. **Historical fleet mitigation lookup** — period-specific placeholder tables reflecting regulatory history; to be updated from RFMO literature.
5. **Heatmap reference points** — no-mitigation, historical, current overlaid as gold diamonds; saved as CSV for cross-period comparison.
6. **Cross-period combined heatmap (script 07, Figure P7)** — 2×2 faceted heatmap with shared lambda color scale, all reference points and hypothetical scenarios.
7. **Uncertainty quantification** — 1000-sim Monte Carlo with beta distributions, biological hierarchy constraints, FM clamping, post-hoc centering.
8. **IUU integration** — three-component mortality partition with enforcement reduction scenarios.

### Still Pending

9. **Update hist_fleet_mitigation** from RFMO literature review (current values are placeholders)
10. **Regional BPUE variation** — Approach 4/5 framework with region-specific catchabilities when literature review (script 04) is complete
11. **Refine FM uncertainty** — update from BPUE confidence intervals once available
12. **Validate with later periods** — compare predicted lambdas against observed 2001-2010 population trends

### Long Term

13. **Multi-Species Extension**
   - Apply framework to other albatross species
   - Community-level bycatch assessment
   - Comparative vulnerability analysis

8. **Management Applications**
   - Identify priority areas for mitigation
   - Evaluate effectiveness of marine protected areas
   - Project impacts of fishery management scenarios

---

## Key Decisions and Rationale

### Why Use Catchability Framework (Script 03b) Over Overlap Method (Script 03)?

**Problem with Overlap Method:**
The overlap method scales BPUE by the percentage of Bird Island birds in each cell:
```
BPUE_map_i = pct_BI_i × BPUE
```

This is conceptually incorrect because:
- BPUE is a **fishery property** (fishing practices, gear, mitigation)
- It should not vary based on **bird population composition**
- A fishing hook doesn't "know" whether the nearby bird is from Bird Island or Crozet
- All birds in a cell face the same catchability from the fishery operating there

**Catchability Method Solution:**
Uses a single BPUE (α) to derive a catchability coefficient (β) that partitions the total expected bycatch spatially based on the hooks × birds interaction. Bird Island-specific bycatch is then calculated by applying this catchability to the Bird Island bird distributions (properly scaled to global proportion).

**Validation:** The catchability method produces estimates (284 birds/year) that match the expected value from simple calculation (290 birds/year = 98%), while the overlap method underestimates (223 birds/year = 77% of expected).

### Why Scale Bird Island Distributions to Global Proportion?

**The Problem:**
In the catchability equation:
```
β = α × H_total / Σ(H_i × B_i_all_pops)
```

The bird density (B_i_all_pops) represents the proportion of the **global WAAL population** in each cell (sums to 1.0).

The Bird Island age-class distributions represent the proportion of **that BI age class** in each cell (each sums to ~0.05 to 0.35).

These are in different units!

**The Solution:**
Scale BI distributions to represent their proportion of the global population:
```
B_i_BI_age_scaled = (B_i_BI_age / sum) × prop_age × prop_BI_global
```

Where:
- prop_age = age class proportion of BI population (e.g., FB = 5.96%)
- prop_BI_global = BI proportion of global WAAL (15.67%)

Now both the catchability calculation and bycatch calculation use bird densities in the same units (proportion of global WAAL population).

**Validation:** After scaling, BI age-class distributions sum to 0.146 (14.6% of global), which equals 15.67% × 93.12% (BI proportion × sum of age class proportions excluding J1) ✓

### Why Regional Catchabilities (Future Script 03c)?

**Motivation:**
BPUE varies spatially due to:
- Different fishing practices (gear types, setting methods)
- Different mitigation measure adoption (tori lines, night setting, hook shielding)
- Different regulatory environments
- Different seabird community composition
- Different oceanographic conditions affecting bird behavior

A single global BPUE (current script 03b) averages over this variation.

**Approach:**
Calculate region × fishery specific catchabilities:
```
β_region_fishery = α_region_fishery × H_total_region / Σ(H_i × B_i)_region
```

This allows:
- Higher β in regions with poor mitigation (e.g., some IUU fisheries)
- Lower β in regions with strong mitigation (e.g., South Georgia after regulations)
- Fishery-specific differences (pelagic vs. demersal practices)
- Fine-scale spatial partitioning within regions (via catchability framework)

**Data Requirements:**
Requires comprehensive literature review (script 04) to obtain regional BPUE estimates with sufficient sample sizes and geographic coverage.

---

## Technical Notes

### Raster Alignment and Resampling

All spatial operations require aligned grids (same extent, resolution, CRS). We use:
- **Template raster:** `total_bird_density` (from script 02) as the master grid
- **Resampling method:** Bilinear interpolation for continuous data (bird densities, fishing effort)
- **CRS:** WGS84 (EPSG:4326)
- **Resolution:** 1° × 1° (inherited from Clay et al. 2019 data)

### Missing Data Handling

- **Bird distributions:** Already processed by Clay et al. 2019; NAs represent areas with no data
- **Fishing effort:** NAs represent areas with no fishing activity (converted to 0 for calculations)
- **Population distributions:** NAs in ocean areas outside species range (kept as NA)

### Computational Considerations

- **Raster operations:** Use `terra` package (successor to `raster`, faster)
- **Functional programming:** Use `purrr::map()` family for iteration
- **Memory management:** Process rasters cell-by-cell when needed, avoid loading full grids into memory unnecessarily

### Quality Control

All scripts include:
- **Diagnostic output:** Print key summary statistics to verify calculations
- **Validation checks:** Compare results to expected values (e.g., distributions should sum to 1)
- **Visualization:** Create maps at each step to visually verify spatial patterns
- **Documentation:** Clear comments and markdown text explaining each step

---

## References

### Data Sources

**Bird distributions:**
- Clay, T.A., et al. (2019). A comprehensive large-scale assessment of fisheries bycatch risk to threatened seabird populations. *Journal of Applied Ecology*, 56(7), 1882-1893.

**Population-specific distributions:**
- Carneiro, A.P.B., et al. (2020). A framework for mapping the distribution of seabirds by integrating tracking, demography and phenology. *Journal of Applied Ecology*, 57(3), 514-525.

**Breeding population estimates:**
- ACAP (2009). Agreement on the Conservation of Albatrosses and Petrels Species Assessment.
- CNRS Chinzè Monitoring Database (2010, 2011). Crozet and Kerguelen breeding pair estimates.
- Poncet, S., et al. (2006). Status and distribution of wandering, black-browed and grey-headed albatrosses breeding at South Georgia. *Polar Biology*, 29(9), 772-781.
- Ryan, P.G., et al. (2009). Seabird monitoring on Marion Island. South African National Antarctic Programme.

**BPUE estimates:**
- Jiménez, S., et al. (2020). Bycatch of great albatrosses in pelagic longline fisheries in the southwest Atlantic. *Aquatic Conservation*, 30(6), 1199-1211.
- Klaer, N.L. (2012). A review of sea bird bycatch in the southern and eastern scalefish and shark fishery. CSIRO Marine and Atmospheric Research.
- Tuck, G.N., et al. (2015). A decision framework for assessing the extent to which environmental and bycatch impacts can be mitigated through spatial closures in longline fisheries. *PLoS ONE*, 10(7), e0133365.

### Theoretical Framework

**Catchability and fisheries models:**
- Arreguín-Sánchez, F. (1996). Catchability: a key parameter for fish stock assessment. *Reviews in Fish Biology and Fisheries*, 6(2), 221-242.
- Hilborn, R., & Walters, C.J. (1992). *Quantitative Fisheries Stock Assessment: Choice, Dynamics and Uncertainty*. Chapman and Hall.

**Lotka-Volterra and predator-prey theory:**
- Lotka, A.J. (1925). *Elements of Physical Biology*. Williams & Wilkins.
- Volterra, V. (1926). Fluctuations in the abundance of a species considered mathematically. *Nature*, 118, 558-560.

**Seabird bycatch:**
- Anderson, O.R.J., et al. (2011). Global seabird bycatch in longline fisheries. *Endangered Species Research*, 14(2), 91-106.
- Lewison, R.L., & Crowder, L.B. (2003). Estimating fishery bycatch and effects on a vulnerable seabird population. *Ecological Applications*, 13(3), 743-753.

---

## Appendix: Comparison of Methods

### Summary Table

| Feature | Script 03<br>(Overlap) | Script 03b<br>(Catchability) | Script 03c<br>(Corrected) | Future<br>(Regional) |
|---------|------------------------|------------------------------|--------------------------|----------------------|
| **Theoretical basis** | Ad hoc | Catchability theory | Catchability theory | Regional catchability |
| **BPUE application** | Varies by % BI | Single global value | Single global value | Regional values |
| **% BI allocation** | Pre-scaled BPUE | Uniform 15.67% | Local 0-60% | Local 0-60% |
| **Spatial resolution** | Cell-by-cell | Cell-by-cell | Cell-by-cell | Regional strata |
| **Partitioning method** | Direct overlap | Hooks × birds | Hooks × birds | Regional hooks × birds |
| **Total bycatch** | 223 birds | 284 birds | 312 birds | TBD |
| **Match expected?** | 77% | 98% | 100% | TBD |
| **Age-class specific?** | Yes | Yes | Yes | Yes |
| **Region specific?** | No | No | No | Yes |
| **Fishery specific?** | Yes | Yes | Yes | Yes |
| **Conceptual validity** | ✗ Flawed | ~ Limited | ✓ Valid | ✓ Valid |
| **Data requirements** | Low | Low | Low | High |
| **Complexity** | Low | Medium | Medium | High |
| **Status** | Complete | Superseded | **CURRENT** | Planned |

### When to Use Each Method

**Script 03 (Overlap):**
- ✗ Not recommended due to conceptual issues
- Historical comparison only

**Script 03b (Catchability):**
- ~ Superseded by 03c
- Limitation: Assumes uniform 15.67% BI everywhere
- Use only for comparison with 03c

**Script 03c (Corrected Catchability):**
- ✓ **Current recommended approach**
- Uses actual local % BI (0-60% spatial variation)
- Maintains catchability framework
- Validated hybrid data sources (Carneiro + Clay)
- Use for: Demographic model input, current best estimates

**Future (Regional Catchability):**
- ✓ Future enhancement when regional BPUE available
- Will stratify by region × fishery
- Captures regional mitigation differences
- Use when: Literature review complete (script 04)

---

*Document last updated: February 11, 2026*
