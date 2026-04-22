## Resubmission (v1.0.1)

This is a patch release. In this version I have:

* Fixed a bug in `create_proj()` that caused failures in non-RStudio 
  IDEs (Positron, VSCode) when called from a working directory 
  outside an existing project (#1).
* Added two new parameters (`use_rproj`, `setwd_to_proj`) with 
  backwards-compatible defaults.
* Added `cli` to Imports.

## Test environments

* local macOS (R release)
* win-builder (R release, R devel, R oldrelease)
* mac-builder (R release)

## R CMD check results

0 errors | 0 warnings | 0 notes on R release and R devel.

On R oldrelease (R 4.4.3), one NOTE:

    Author field differs from that derived from Authors@R

This is a known cosmetic artifact of how different R versions render 
ORCID URLs in the Author field. The Authors@R specification itself 
is correct and valid. This NOTE also appeared (and was accepted) in 
the v1.0.0 submission.
