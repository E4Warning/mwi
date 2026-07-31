# Map index values onto the five activity classes

Converts continuous index values into the five ordered classes used to
communicate the index to the public and to mosquito-control
stakeholders.

## Usage

``` r
mwi_category(x, labels = mwi_activity_levels())
```

## Arguments

- x:

  Numeric vector of index values in `[0, 1]`, for example the result of
  [`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md).

- labels:

  Character vector of five class labels, ordered from least to most
  activity. Defaults to
  [`mwi_activity_levels()`](https://e4warning.github.io/mwi/reference/mwi_activity_levels.md);
  supply your own to translate them.

## Value

An ordered factor with five levels.

## Details

The class boundaries are

|                        |                    |
|------------------------|--------------------|
| Index value            | Class              |
| `= 0`                  | No activity        |
| `> 0` and `<= 0.33`    | Low activity       |
| `> 0.33` and `<= 0.66` | Moderate activity  |
| `> 0.66` and `< 1`     | High activity      |
| `= 1`                  | Very high activity |

Note that "very high activity" corresponds to the single value 1, which
the index attains only when relative humidity is exactly 95% and the
other two variables are in their optimal ranges (see
[`mwi()`](https://e4warning.github.io/mwi/reference/mwi.md)). Reported
humidity is usually rounded to whole percentage points, so this occurs
in practice, but it will be rare in continuous data such as reanalysis
output.

## Examples

``` r
mwi_category(c(0, 0.2, 0.5, 0.9, 1))
#> [1] No activity        Low activity       Moderate activity  High activity     
#> [5] Very high activity
#> 5 Levels: No activity < Low activity < Moderate activity < ... < Very high activity

# Order is respected, so classes can be compared
mwi_category(0.9) > mwi_category(0.2)
#> [1] TRUE

# Supply your own labels
labs <- c("none", "low", "moderate", "high", "very high")
mwi_category(c(0, 1), labels = labs)
#> [1] none      very high
#> Levels: none < low < moderate < high < very high
```
