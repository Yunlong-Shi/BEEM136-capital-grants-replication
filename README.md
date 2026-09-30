# BEEM136 Capital Grants Replication

This repository contains my replication work for BEEM136 Research Methods I.

The replication focuses on selected main results from the paper by Janes, Koelle and Quinn on capital grants and microenterprise productivity.

## Replication target

I reproduced:
- Table 2: Capital Grant Treatment Effects across All Measures of Productivity
- Figure 1: Capital Grant Treatment Effects on Productivity

## Environment

The replication was conducted on:
- macOS
- StataNow/SE 19.5

Additional user-written Stata packages were required during replication, including:
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

## Workflow

The main replication workflow was:

Raw Sri Lanka and Ghana data
→ country-specific data preparation
→ country-level master datasets
→ Calculate_TFP.do
→ TFPpooled.dta
→ _Table2.do and _Figure1.do
→ reproduced tables, figures and logs

## Replication results

### Table 2

The three panels of Table 2 were successfully reproduced:
- Panel A: Blundell-Bond TFP
- Panel B: GNR TFP
- Panel C: Labour productivity

The reproduced coefficients, standard errors, significance levels, observations and number of microenterprises matched the published table.

### Figure 1

The four empirical CDF figures were successfully reproduced:
- Sri Lanka, Blundell-Bond
- Ghana, Blundell-Bond
- Sri Lanka, GNR
- Ghana, GNR

## Problems encountered

The original replication package did not run immediately on macOS.

Main issues encountered were:
- Windows-style file paths required modification for macOS.
- The main project directory had to be updated to the local file location.
- Several user-written Stata packages and dependencies had to be installed.
- Table 2 output files were generated in the project root rather than the intended Results/Tables folder.
- Figure 1 required 100,000 randomisation replications and therefore took substantially longer to run than Table 2.

## Repository contents

Key files and folders include:
- README.pdf: original replication instructions
- README.md: summary of my replication work
- MY_REPLICATION_NOTES.md: detailed notes from the replication process
- Data/: replication datasets
- Results/: reproduced outputs and logs
- Calculate_TFP.do: construction of productivity measures
- _Table2.do: code for reproducing Table 2
- _Figure1.do: code for reproducing Figure 1