# Replication Notes

## Paper
Janes, Koelle and Quinn (2025/2026)
Do Capital Grants Improve Microenterprise Productivity?

## My replication target
I focused on the main productivity results in Section 3:
- Table 2: Capital Grant Treatment Effects across All Measures of Productivity
- Figure 1: Capital Grant Treatment Effects on Productivity

I did not attempt to reproduce every table and appendix result in the paper.

## Environment
- macOS
- StataNow/SE 19.5

## Data
Sri Lanka:
- SLMS survey rounds

Ghana:
- Ghana Single-enterprise datasets

## Main workflow

Raw Sri Lanka and Ghana data
→ country-specific data preparation
→ Sri Lanka and Ghana master datasets
→ Calculate_TFP.do
→ TFPpooled.dta
→ _Table2.do
→ Table2A.tex, Table2B.tex, Table2C.tex

TFP data
→ _Figure1.do
→ four empirical CDF figures
→ randomisation simulations

## Outputs successfully reproduced

### Table 2
Panel A: Blundell-Bond TFP
Panel B: GNR TFP
Panel C: Labour productivity

The coefficients, standard errors, significance levels,
observations and number of microenterprises matched the published table.

### Figure 1
Four CDF figures reproduced:
- Sri Lanka, Blundell-Bond
- Ghana, Blundell-Bond
- Sri Lanka, GNR
- Ghana, GNR

Rank-sum p-values displayed by the code:
- Sri Lanka, Blundell–Bond: 0.00029572
- Sri Lanka, GNR: 0.49492182
- Ghana, Blundell–Bond: 0.02182397
- Ghana, GNR: 0.020006

The code also performs 100,000 randomisation replications for each
distribution test. The relationship between the displayed rank-sum
p-values and the randomisation-inference results will be checked
separately before the presentation.

## Problems / fixes encountered

1. File paths
The replication package contained Windows-style paths that did not
run directly on macOS. Some path separators had to be changed.

2. Main directory
The maindir path had to be changed to the local location of the
replication package.

3. Missing Stata dependencies
Several user-written Stata packages were not initially installed.
Packages installed during replication included:
- qreg2
- xtpattern
- reghdfe
- estout
- winsor
- xtabond2
- ivreg2
- leebounds
- amoeba
- ftools
- require

Some packages also had additional dependencies. For example,
reghdfe required ftools and require in the installed version.
4. Output directory inconsistency
_Table2.do generated Table2A.tex, Table2B.tex and Table2C.tex in the
project root rather than Results/Tables.

5. Computational requirement
_Figure1.do runs 100,000 randomisation replications for its
distribution tests and therefore takes substantially longer to run
than Table 2.

## Replication status
Table 2: successfully reproduced
Figure 1: successfully reproduced