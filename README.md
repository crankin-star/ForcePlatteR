
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- Render to README.md with `devtools::build_readme()` -->

# ForcePlatteR

<!-- badges: start -->

<!-- badges: end -->

The goal of ForcePlatteR is to …

## Installation

You can install the development version of ForcePlatteR from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("crankin-star/ForcePlatteR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(ForcePlatteR)

masses
#> Force plate data with 8 channels
#>          Time CZ(Volts) DZ(Volts)  AZ(Volts)  BZ(Volts)  YAC(Volts) XDC(Volts)
#> 0       0e+00 -0.115422 -0.148921 -0.0452042 -0.0619534 -0.00204257 0.00246685
#> 1       2e-04 -0.115422 -0.148921 -0.0461705 -0.0609871 -0.00236467 0.00278895
#> 2       4e-04 -0.114778 -0.148599 -0.0458484 -0.0619534 -0.00236467 0.00343315
#> 3       6e-04 -0.115744 -0.148599 -0.0455263 -0.0603429 -0.00204257 0.00375525
#> 4       8e-04 -0.115100 -0.148599 -0.0461705 -0.0613092 -0.00139837 0.00472156
#> 5       1e-03 -0.115422 -0.147954 -0.0461705 -0.0606650 -0.00139837 0.00472156
#>         XAB(Volts) YBD(Volts)
#> 0       0.00504366  0.0494936
#> 1       0.00504366  0.0491715
#> 2       0.00472156  0.0475610
#> 3       0.00439946  0.0472389
#> 4       0.00472156  0.0462726
#> 5       0.00472156  0.0446621
#> Scan rate: 5000  Scans per Frame:10  Total scans: 51460
cfg <- read_config("calibration_data/A1840_1.acl")

df <- masses$data
S <- cfg$S

# We can usually get offsets from the GUI selector
offset <- c(-0.002, -0.169, -0.204, -0.218, 0.006, -0.041, -0.046, -0.017)
df[-1] <- sweep(df[-1], 2, offset, `-`) # excluding time column

forces <- calculate_forces(df, S)

# plot.force_output(forces, component = "Fz")
```
