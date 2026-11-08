# MadPharma peptide post: widget and script

The public files for MadPharma's November 2026 post on the HHS policy for six unapproved peptides: the interactive widget, and the script that recomputes the Semax numbers.

## Three routes to one vial

[index.html](index.html) is the interactive widget. For BPC-157, Semax and epitalon, it compares three ways the same peptide can reach a patient: a "research purposes only" website, a pharmacy compounding under the HHS policy, and an FDA-approved drug. For each of the nine combinations it shows which of seven checks is met, partly met or not met: identity, impurities, endotoxin, evidence that it works, human safety data, who makes the powder, and adverse-event reporting. Each answer gives the record behind it and its source. A grid at the top shows all nine combinations at once.

Met means the route requires the check and the record shows it done. Partly met means only part of it is required, or it rests on the supplier's certificate, or the record shows only part. Not met means neither, or, on the FDA route, that no approved product exists. No FDA-approved drug contains any of the three, so each FDA cell says what approval would require.

It's self-contained: no external scripts or fonts, light and dark mode, and it works at phone width. Open it in a browser, or serve it with GitHub Pages (Settings, Pages, deploy from the `main` branch, root folder) at <https://anika1861.github.io/peptides_widget/>.

Sources: the HHS enforcement-discretion policy (conditions 3–5, testing standard, Appendix B) and its notice, 91 FR 68526; FDA's briefing documents for the Pharmacy Compounding Advisory Committee meeting of 23–24 July 2026; ICH Q3A(R2); 21 CFR 211.167, 314.50, 314.80, 314.125 and 314.126; CBS News, 28 October 2026. As of 8 November 2026.

## Recomputing the Semax numbers

[analysis/semax-recompute.sh](analysis/semax-recompute.sh) recomputes headline numbers in two Russian Semax texts from the authors' own figures:

- the mortality claim in the 2011 guideline on Semax 1% in acute stroke, with both of Fisher's tests, since the guideline doesn't say which one it used: the exact test and the angular transformation, φ*;
- the late-rehabilitation Barthel comparison and the mean age in [Gusev et al. 2018](https://doi.org/10.17116/jnevro20181183261-68).

It needs only bash and awk, and reads no files:

```
bash analysis/semax-recompute.sh
```

The comment at the top of the script explains each calculation and gives the expected output.
