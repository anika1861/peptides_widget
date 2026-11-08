# MadPharma peptide post: widget and script

The public files for MadPharma's November 2026 post on the HHS policy for six unapproved peptides: the interactive widget, and the script that recomputes the Semax numbers.

## Three routes to one vial

[index.html](index.html) is the interactive widget. For BPC-157, Semax and epitalon, it compares three ways the same peptide can reach a patient: a "research purposes only" website, a pharmacy compounding under the HHS policy, and an FDA-approved drug. For each route it shows whether anyone has to check identity, impurities, endotoxin, evidence of benefit, human safety data, the maker and adverse-event reporting, with a source for each cell.

It's self-contained: no external scripts or fonts, light and dark mode, and it works at phone width. Open it in a browser, or serve it with GitHub Pages (Settings, Pages, deploy from the `main` branch, root folder) at <https://anika1861.github.io/peptides_widget/>.

Sources: the HHS enforcement-discretion policy, 91 FR 68526, and its Appendix B; FDA's briefing documents for the Pharmacy Compounding Advisory Committee meeting of 23–24 July 2026; 21 CFR 314.80 and 314.126. As of 4 November 2026.

## Recomputing the Semax numbers

[analysis/semax-recompute.sh](analysis/semax-recompute.sh) recomputes headline numbers in two Russian Semax texts from the authors' own figures:

- the mortality claim in the 2011 guideline on Semax 1% in acute stroke, with both of Fisher's tests, since the guideline doesn't say which one it used: the exact test and the angular transformation, φ*;
- the late-rehabilitation Barthel comparison and the mean age in [Gusev et al. 2018](https://doi.org/10.17116/jnevro20181183261-68).

It needs only bash and awk, and reads no files:

```
bash analysis/semax-recompute.sh
```

The comment at the top of the script explains each calculation and gives the expected output.
