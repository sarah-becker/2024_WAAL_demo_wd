# Wandering Albatross Bycatch Estimation: Conceptual Framework

**Project:** Bird Island Wandering Albatross Demographic Model
**Author:** Sarah Becker
**Date:** January 2026

---

## Overview

This document describes the conceptual framework for estimating fisheries bycatch mortality of wandering albatrosses (*Diomedea exulans*)
from Bird Island, South Georgia. We estimate age-specific bycatch mortality rates for input into a stage-structured demographic matrix model.

---

## Theoretical Foundation

### Bycatch as Predator-Prey Interaction

We model fisheries bycatch using theory from both predator-prey ecology (Lotka-Volterra) and fisheries science (catchability models), 
recognizing that fishing represents a form of predation on seabird populations. This approach grounds our estimates in well-established ecological 
theory while ensuring that predicted mortality matches empirical observations from the bycatch literature. By anchoring to observed BPUE (the fishery property)
and partitioning spatially based on encounter rates (hooks × birds interaction), we achieve both empirical validity and theoretical rigor.

**Lotka-Volterra predation rate:**
```
Predation = β × Predators × Prey
```

**Fisheries catch equation:**
```
Catch = q × Effort × Abundance
```

**Applied to seabird bycatch:**
```
Bycatch_i = β × Hooks_i × Birds_i
```

Where **β** (catchability) represents the probability a bird is caught per hook per bird, analogous to the Lotka-Volterra attack rate and the fisheries catchability coefficient (q).

### Deriving Catchability from BPUE

Total bycatch must match observed Bycatch Per Unit Effort (BPUE) from literature:

```
Total bycatch = α × H_total
```

This also equals the sum across all spatial cells:

```
α × H_total = Σ_i (β × H_i × B_i)
```

Solving for catchability:

```
β = (α × H_total) / Σ_i (H_i × B_i)
```

This partitions total expected bycatch spatially based on the hooks × birds interaction in each cell.

### Key Assumptions

1. **Linear encounter model**: Bycatch rate ∝ hooks × birds
2. **Random mixing**: Birds and gear encounter randomly within cells
3. **Constant catchability**: β constant within region/fishery strata
4. **No behavioral response**: Birds don't avoid high-bycatch areas
5. **No gear saturation**: Hook availability doesn't limit catches

These are standard in fisheries science and reasonable for low bycatch rates.

---

## Data Integration

### Spatial Data
- **Bird distributions** by age class (Clay et al. 2019): 1° × 1° grid, year-round
- **Population distributions** (Carneiro et al. 2020): Crozet, Kerguelen, South Georgia
- **Fishing effort**: Pelagic and demersal longline hooks per grid cell

### Demographic Data
- **Age class proportions** from Bird Island population (Clay et al. 2019)
- **Breeding pair estimates**: Global total = 5,947 pairs
- **Bird Island proportion**: 15.67% of global population (60% of SG's 1,553 pairs)

### Bycatch Rates
- **BPUE** from published literature (birds per 1,000 hooks)
- Currently: mean values by fishery type
- Future: regional weighted averages from comprehensive literature review

---

## Three Methodological Approaches

### Approach 1: Overlap-Based Method (Script 03)

This was our initial approach that creates a spatially-varying BPUE map by multiplying a single global BPUE value by the percentage of Bird Island birds in each cell. While simple and intuitive, it has a fundamental conceptual flaw: **BPUE is a fishery property, not a population property**. Fishing gear doesn't selectively catch birds based on colony of origin—a hook in a mixed population area has the same catchability for all birds present. By artificially downweighting BPUE in areas where Bird Island birds mix with other populations, this method underestimates total bycatch and misrepresents the biological process.

**Formula:**
```
BPUE_map_i = pct_BI_i × BPUE
Bycatch_age = Σ_i (BPUE_map_i × overlap_i_age × prop_age)
```

**Concept:**
Spatially varies BPUE based on the proportion of Bird Island birds in each cell, then multiplies by overlap indices (bird density × fishing effort).

**Problem:**
BPUE is a **fishery property** (gear type, mitigation measures), not a population property. Fishing hooks don't selectively catch based on bird origin. Scaling BPUE by % BI artificially downweights bycatch in mixed-population areas.

**Status:** Implemented but not recommended. Conceptually flawed; underestimates bycatch.

---

### Approach 2: Catchability Method (Script 03b) - **SUPERSEDED BY 03c**

This method correctly treats BPUE as a fishery characteristic and uses catchability (β) to partition mortality spatially. However, it has a **key limitation**: it scales Bird Island distributions by the **global average** (15.67%), assuming this applies uniformly everywhere. In reality, % BI varies spatially from 0-60%. Superseded by script 03c which uses **actual local % BI** in each cell.

**Framework:**

Uses a single global BPUE (α) to derive a catchability coefficient (β) that partitions total expected bycatch across space.

**For Bird Island age-class bycatch:**
```
β = (α × H_total) / Σ_i (H_i × B_i_all_pops)

Bycatch_age = Σ_i (H_i × B_i_age_BI_scaled × β)
```

**Key innovation: Proper scaling of bird distributions**

Bird Island distributions must be scaled to represent their proportion of the **global WAAL population** (15.67%), ensuring units match those used in catchability calculation:

```
B_i_age_BI_scaled = (B_i_age_BI / sum) × prop_age × prop_BI_global
```

Where:
- Bird distributions normalized to sum to 1
- Scaled by age class proportion of BI population
- Scaled by BI proportion of global population

**Process:**
1. Calculate catchability (β) using total WAAL density (all populations)
2. Scale BI age-class distributions to global proportion
3. Apply β to scaled BI distributions
4. Sum across cells for each age class

**Strengths:**
- Theoretically rigorous (interaction coefficient framework)
- Correctly partitions total expected bycatch
- Produces realistic estimates (validated against simple calculations)
- Age-class specific mortality rates

**Limitations:**
- Assumes single global BPUE (no regional variation)
- Requires careful attention to units and scaling

**Status:** Implemented but superseded by 03c.

---

### Approach 3: Corrected Catchability Method (Script 03c) - **CURRENT RECOMMENDED**

This method addresses 03b's limitation by using **actual local % BI** in each cell (0-60% spatial variation) rather than uniform 15.67%. Maintains catchability framework while properly accounting for spatial heterogeneity in population composition. Combines Carneiro distributions (for population allocation) with Clay distributions (for age partitioning), validated by high correlation (r=0.98).

**Framework:**

```
Step 1: Calculate catchability using ALL WAAL (same as 03b)
  β = (α × H_total) / Σ_i (H_i × B_i_all_pops)

Step 2: Calculate total WAAL bycatch density
  Total_bycatch_i = H_i × B_i_all_pops × β

Step 3: Allocate to BI using actual local % BI (KEY INNOVATION)
  BI_bycatch_i = Total_bycatch_i × pct_BI_i
  where pct_BI_i varies 0-60%, not uniform 15.67%

Step 4: Partition by age class using Clay distributions
  BI_age_bycatch_i = BI_bycatch_i × age_weight_i
```

**Key Innovation:**
- Uses local % BI map from script 02 (Carneiro-based)
- Accounts for spatial variation: 0% (near other colonies) to 60% (near South Georgia)
- Properly integrates population-specific (Carneiro) and age-specific (Clay) data

**Results:**
- Pelagic: 196.4 birds/year (33% higher than 03b)
- Demersal: 115.7 birds/year (15% lower than 03b)
- Total: 312.1 birds/year
- Reveals fishing concentrates more in areas with other populations

**Status:** Implemented and validated. Currently recommended for demographic model input.

---

### Approach 4: Regional Catchability Method (Future) - **FUTURE GOAL**

The regional catchability method is our ultimate goal—a **hybrid approach combining spatial BPUE variation with the catchability framework**. Instead of applying a blocky BPUE map directly (which would suffer from the same conceptual issues as Approach 1), we use literature-derived regional BPUE values to calculate region-and-fishery-specific catchability coefficients (β_rf). These catchabilities are then applied within each region using the same interaction-based framework as Approach 2, ensuring spatial allocation within regions is driven by hooks × birds interaction, not bird composition. This gives us **regional variation in fishing mortality** (capturing differences between well-regulated vs. poorly-regulated fisheries) combined with **fine-scale spatial partitioning** within regions (capturing local encounter hotspots). The result is bycatch estimates stratified by region × fishery × age class—providing demographic rates for the matrix model and regional detail for targeted management recommendations.

**Framework:**

Extends catchability framework to account for regional variation in BPUE due to different fishing practices, mitigation adoption, and regulatory environments.

**Regional catchability:**
```
For region r, fishery f:
  β_rf = (α_rf × H_total_rf) / Σ_i∈r (H_i_f × B_i_all_pops)

Bycatch_rfa = Σ_i∈r (H_i_f × B_i_a_BI_scaled × β_rf)
```

**Process:**
1. Compile BPUE estimates from literature by region and fishery
2. Calculate weighted regional averages (by sample size, recency, quality)
3. Assign grid cells to regions (e.g., South Atlantic, Indian Ocean, etc.)
4. Calculate region × fishery specific catchabilities
5. Apply within each region for fine-scale spatial allocation
6. Stratify by age class

**Example regional structure:**
- South Atlantic (ICCAT area)
- Indian Ocean (IOTC area)
- Western Pacific (WCPFC area)
- Eastern Pacific (IATTC area)
- Southern Ocean (south of 60°S)

**Output stratification:**

Bycatch estimates for each:
- Region (captures geographic variation in practices)
- Fishery type (pelagic vs. demersal)
- Age class (for demographic model)

Can aggregate as needed or maintain full stratification for sensitivity analyses and management prioritization.

**Example output structure:**

| Region | Fishery | Age Class | Bycatch | β | α (BPUE) | % of Total |
|--------|---------|-----------|---------|------|----------|------------|
| South Atlantic | Pelagic | FB | - | - | - | - |
| | | SB | - | - | - | - |
| | | NB | - | - | - | - |
| | | J2J3 | - | - | - | - |
| | | IMM | - | - | - | - |
| | Demersal | FB | - | - | - | - |
| | | SB | - | - | - | - |
| | | NB | - | - | - | - |
| | | J2J3 | - | - | - | - |
| | | IMM | - | - | - | - |
| Indian Ocean | Pelagic | (all ages) | - | - | - | - |
| | Demersal | (all ages) | - | - | - | - |
| W Pacific | Pelagic | (all ages) | - | - | - | - |
| | Demersal | (all ages) | - | - | - | - |
| E Pacific | Pelagic | (all ages) | - | - | - | - |
| | Demersal | (all ages) | - | - | - | - |
| S Ocean | Pelagic | (all ages) | - | - | - | - |
| | Demersal | (all ages) | - | - | - | - |
| **TOTAL** | -- | **All** | **Total** | -- | -- | **100%** |

This stratification enables:
- **Demographic model**: Sum across regions/fisheries for age-specific rates
- **Sensitivity analysis**: Test impact of regional mitigation improvements
- **Management priority**: Identify highest-impact regions/fisheries
- **Scenario testing**: Model effort redistribution or practice changes

**Strengths:**
- Incorporates regional differences in fishing mortality
- Captures variation in mitigation effectiveness
- Fishery-specific catchabilities
- Fine-scale spatial partitioning within regions
- Enables region-specific management recommendations
- Most realistic representation of spatial heterogeneity

**Limitations:**
- Requires comprehensive literature review
- Data-intensive (sufficient studies per region needed)
- Regional boundaries somewhat arbitrary
- Must weight studies appropriately

**Status:** In development. Requires completion of literature review (script 04).

---

## Comparison of Approaches

We developed these approaches iteratively, identifying conceptual and mathematical issues in each version. Approach 1 proved conceptually flawed. Approach 2 (03b) fixed those flaws but assumes uniform BI proportion (15.67%) everywhere. Approach 3 (03c) uses actual local % BI (0-60%), properly accounting for spatial heterogeneity. Approach 4 (future) will add regional BPUE variation while maintaining the corrected spatial allocation.

| Feature | Overlap (03) | Catchability (03b) | Corrected (03c) | Regional (Future) |
|---------|--------------|-------------------|-----------------|-------------------|
| **Theoretical basis** | Ad hoc | Catchability theory | Catchability theory | Regional catchability |
| **BPUE treatment** | Varies by % BI | Single global | Single global | Regional values |
| **% BI allocation** | Pre-scaled BPUE | Uniform 15.67% | Local 0-60% | Local 0-60% |
| **Spatial resolution** | Cell-by-cell | Cell-by-cell | Cell-by-cell | Regional strata |
| **Conceptual validity** | ✗ Flawed | ~ Limited | ✓ Valid | ✓ Valid |
| **Regional variation** | No | No | No | Yes |
| **Age-class specific** | Yes | Yes | Yes | Yes |
| **Data requirements** | Low | Low | Low | High |
| **Status** | Complete | Superseded | **CURRENT** | Planned |

---

## Critical Methodological Decisions

### Why Catchability Over Overlap?

The overlap method incorrectly treats BPUE as a bird population property. In reality:

- **BPUE reflects fishery characteristics**: gear type, setting practices, mitigation measures
- **All birds face same local risk**: A hook doesn't "know" if nearby birds are from BI or Crozet
- **Spatial variation should come from fishing practices**, not bird composition

The catchability framework correctly:
- Uses BPUE to set total expected mortality (fishery property)
- Partitions spatially based on bird-hook interactions (encounter process)
- Applies same local catchability to all birds in that location

### Why Scale Bird Island Distributions?

**The unit mismatch problem:**

Catchability is calculated using total WAAL density (proportion of global population, sums to 1.0). Bird Island age-class distributions represent proportion of that age class (each sums to different values). These are incompatible units.

**The solution:**

Scale BI distributions to represent their share of the global population:
- BI is 15.67% of global WAAL
- First breeders are 5.96% of BI
- Therefore: BI first breeders are 0.1567 × 0.0596 = 0.0093 of global WAAL

This ensures both catchability calculation and bycatch calculation use the same currency: proportion of global WAAL population.

### Why Regional Catchabilities?

BPUE varies geographically due to:
- **Mitigation adoption**: Tori lines, night setting, hook shielding
- **Regulatory enforcement**: Strong (e.g., South Georgia) vs. weak (some IUU fisheries)
- **Gear differences**: Setting depth, line weighting, hook types
- **Seabird community**: Species composition affects aggregate BPUE

A single global BPUE averages over meaningful variation. Regional catchabilities capture real differences in fishing mortality risk while maintaining theoretical consistency through the catchability framework.

**Why the hybrid approach?** We considered two alternatives for incorporating spatial variation in BPUE: (1) directly applying a blocky BPUE map (simple but conceptually flawed—same problem as Approach 1), or (2) using regional BPUE values to calculate regional catchabilities that are then applied via the interaction framework (theoretically consistent). We chose the latter because it gives us **regional variation in overall fishing mortality** (what we want to capture) combined with **fine-scale spatial partitioning based on encounter rates** (what the catchability framework does well). This hybrid approach is more complex but avoids the artifactual results that would arise from directly applying spatially-varying BPUE to bird composition data.

---

## Analytical Workflow

### Current Implementation (Script 03b)

```
Data Inputs
├── Bird distributions (Clay 2019)
├── Population distributions (Carneiro 2020)
├── Fishing effort (pelagic, demersal)
├── BPUE (mean values)
└── Demographic data

↓

Script 01: Calculate overlap indices
├── Bird density × fishing effort
└── By age class × fishery

↓

Script 02: Calculate population proportions
├── Normalize population distributions
├── Weight by breeding pairs
├── Calculate % from Bird Island
└── Create total WAAL density map

↓

Script 03b: Estimate bycatch (catchability method)
├── Scale BI distributions to global proportion
├── Calculate catchability (β) per fishery
├── Apply β to BI age-class distributions
├── Sum across cells
└── Calculate per capita mortality rates

↓

Demographic Model
├── Age-specific mortality rates
├── Population projections
└── Sensitivity analyses
```

### Future Implementation (Script 03c)

Adds regional stratification:

```
Script 04: BPUE literature review
├── Extract BPUE from published studies
├── Create spatial bounding boxes
├── Calculate weighted regional averages
└── Generate regional BPUE rasters

↓

Script 03c: Regional catchability method
├── Assign cells to regions
├── Calculate β_region,fishery
├── Apply to BI distributions within regions
├── Stratify by region × fishery × age class
└── Aggregate for demographic model or scenario testing
```

---

## Data Sources Summary

**Bird tracking data:**
- Clay, T.A., et al. (2019). *Journal of Applied Ecology*, 56(7), 1882-1893.
- Carneiro, A.P.B., et al. (2020). *Journal of Applied Ecology*, 57(3), 514-525.

**Population estimates:**
- Poncet, S., et al. (2006). South Georgia breeding pairs. *Polar Biology*, 29(9), 772-781.
- ACAP (2009), Ryan et al. (2009), CNRS databases (2010, 2011) for other populations.

**BPUE estimates:**
- Tuck, G.N., et al. (2015). *PLoS ONE*, 10(7), e0133365.
- Klaer, N.L. (2012). CSIRO Marine and Atmospheric Research.
- Jiménez, S., et al. (2020). *Aquatic Conservation*, 30(6), 1199-1211.
- Additional studies to be compiled in literature review (script 04).

**Theoretical framework:**
- Lotka-Volterra: Lotka (1925), Volterra (1926)
- Fisheries catchability: Arreguín-Sánchez (1996), Hilborn & Walters (1992)
- Seabird bycatch: Anderson et al. (2011), Lewison & Crowder (2003)

---

## Next Steps

### Immediate Priorities

1. **Validate current approach** (script 03b)
   - Compare with published estimates
   - Sensitivity to BPUE uncertainty
   - Integrate into demographic model

2. **Complete literature review** (script 04)
   - Systematic extraction of BPUE values
   - Spatial bounding boxes for studies
   - Quality assessment and weighting

### Future Development

3. **Implement regional catchabilities** (script 03c)
   - Define regions based on data coverage
   - Calculate weighted regional BPUE
   - Validate against global estimate

4. **Uncertainty quantification**
   - Propagate BPUE confidence intervals
   - Bootstrap spatial variation
   - Scenario analyses

5. **Management applications**
   - Identify high-priority regions for mitigation
   - Evaluate spatial closures
   - Project effects of improved practices

---

## Key Equations Reference

### Catchability Derivation
```
Total bycatch constraint:     C_total = α × H_total
Sum across cells:             C_total = Σ_i (β × H_i × B_i)
Solve for β:                  β = (α × H_total) / Σ_i (H_i × B_i)
```

### Bird Island Bycatch
```
Scale BI distribution:        B_i_age_scaled = (B_i_age_norm) × prop_age × prop_BI
Calculate bycatch:            C_age = Σ_i (H_i × B_i_age_scaled × β)
Per capita rate:              m_age = C_age / N_age
```

### Regional Extension
```
Regional catchability:        β_rf = (α_rf × H_total_rf) / Σ_i∈r (H_i_f × B_i)
Regional bycatch:             C_rfa = Σ_i∈r (H_i_f × B_i_a_scaled × β_rf)
Total across regions:         C_fa = Σ_r C_rfa
```

---

*For detailed numerical examples, validation calculations, and step-by-step implementation, see METHODS.md (full version).*

*Document last updated: January 12, 2026*
