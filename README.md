# 23
Analysis script for 23&me results.

## Usage

```shell
perl analyze.pl $RAW_DATA_FILE
```

This script reads a pair of CSV files, `mag.csv` and `minus.csv`, expected to be found in
the current directory.  These files were scraped from [SNPedia](https://snpedia.com)'s semantic
search.  The rows contain a genotype (consisting of an SNP ID, e.g. `Rs1007371`, followed by a
pair of bases, e.g. `(A;C)`), a magnitude from 0 to 10, the repute ("Good", "Bad", or ""), and
finally a textual explanation of the genotype.  There are two files because the data in
`minus.csv` came from minus-orientation SNPs, so the bases were flipped (A↔T, C↔G) before storing.
Only a subset of genotypes were scraped, giving preference to higher magnitude and (if I recall
correctly) presence on 23&me chips.  The specific query has unfortunately been lost in the sands
of time.

The input file is expected to be a file containing genotypes of the same format as the CSVs (case
insensitive), one per line, with `#`-delimited comments ignored.

All matching genotypes are printed, sorted by magnitude and color-coded by repute.
