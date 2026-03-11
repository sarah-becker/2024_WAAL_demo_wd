# Pending Work

Items to address before final analysis runs. Add to this as issues are identified during script review.

---

## Script 01 — Fishing Effort

- [ ] **Retain `vessel_nationality_code` from CCAMLR data (C2_725.csv).**
  Currently the `standardize_dem_data()` function drops this column. In final runs, pass it through
  so CCAMLR effort can be disaggregated by flag state. France (FRA) dominates (~38% of hooks) and
  likely reflects Kerguelen/Crozet fishing — retaining country labels will allow regional or
  fleet-specific analyses.

- [ ] **Check for NZ double-counting.** NZL appears in CCAMLR data AND as a separate source
  (`Rep Log 17287 BLL effort truncated.csv`). Verify these cover different fisheries/time periods
  before combining.

- [ ] **Retain `RFMO` and `Flag` columns from PLL data (`Pel_LL_effort.csv`).**
  Currently dropped when grouping by `Lon, Lat, Year`. In final runs, pass both through so pelagic
  effort can be disaggregated by fleet/country. RFMOs present: ICCAT, WCPFC, IOTC, IATTC. Top flag
  states: Taiwan (~8.7B hooks), Japan (~5.8B), Spain (~1.1B), China (~748M).

- [ ] **(Optional) Investigate WCPFC fleet attribution in PLL data.** All 50,598 WCPFC rows have
  `NA` for Flag — the WCPFC data was compiled without fleet disaggregation. Attributing these hooks
  by country would require returning to the original WCPFC source data. Not essential but would
  improve transparency of the effort dataset.

---

<!-- Add new sections below as issues are identified in other scripts -->
