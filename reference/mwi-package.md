# mwi: Compute the Mosquito Weather Index

Computes the Mosquito Weather Index (MWI), an operational index that
combines air temperature, relative humidity and wind speed into a single
number between 0 and 1 summarising how favourable the weather is for
adult mosquito activity, and maps that number onto five ordered activity
classes. The index was developed by the Benaki Phytopathological
Institute and the National Observatory of Athens under the LIFE CONOPS
project and has been published operationally since 2014. Because the
index is a non-linear function of its three inputs, it must be evaluated
at sub-daily resolution before being aggregated over time; helpers are
provided that enforce that order of operations.

## See also

Useful links:

- <https://github.com/E4Warning/mwi>

- <https://e4warning.github.io/mwi/>

- Report bugs at <https://github.com/E4Warning/mwi/issues>

## Author

**Maintainer**: John R. B. Palmer <john.palmer@upf.edu>
([ORCID](https://orcid.org/0000-0002-2648-7860))

Authors:

- Antonios Michaelakis ([ORCID](https://orcid.org/0000-0002-3075-5020))

- Georgios Balatsos ([ORCID](https://orcid.org/0000-0002-3973-068X))

- Vasileios Karras

- Dimitrios Papachristos

- Rachel Lowe

- Frederic Bartumeus

- Ioannis Lemesios

- Christos Giannakopoulos

- Konstantinos Lagouvardos
