## R CMD check results

0 errors | 0 warnings | 0 notes

* This is a new submission.

## Test environments

* local macOS (Darwin 24.6), R 4.4.2
* GitHub Actions: ubuntu-latest (release, devel, oldrel-1), windows-latest
  (release), macos-latest (release)
* win-builder (devel and release)

## Notes for reviewers

* The package implements the Mosquito Weather Index, an operational
  mosquito-activity index published in Greece since 2014, and accompanies a
  manuscript currently under review; `inst/CITATION` will be updated with the
  final reference on publication.
* No dependencies beyond base R. Test suite includes a regression fixture of
  314 observations validated against the analysis pipeline of the accompanying
  article (100% line coverage).

## Downstream dependencies

There are currently no downstream dependencies.
