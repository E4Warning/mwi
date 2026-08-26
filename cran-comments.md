## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission (the only NOTE).
* The words flagged as possibly misspelled in DESCRIPTION (Benaki, CONOPS,
  MWI, Phytopathological) are proper nouns and acronyms: the Benaki
  Phytopathological Institute co-developed the index, LIFE CONOPS is the EU
  project under which it was developed, and MWI is the index's name.

## Test environments

* local macOS (Darwin 24.6), R 4.4.2
* GitHub Actions: ubuntu-latest (release, devel, oldrel-1), windows-latest
  (release), macos-latest (release)
* win-builder release (R 4.6.1) and devel (2026-08-24 r90445): both
  Status: 1 NOTE (new submission only), all 127 tests passing

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
