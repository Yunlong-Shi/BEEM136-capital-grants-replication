
clear all
set more off, perm

* Setting directories

global  maindir		"/Users/yunlongshi/Downloads/3-replication-package"

global	tabdir		"${maindir}/Results/Tables"
global	graphdir	"${maindir}/Results/Graphs"
global	datadir		"${maindir}/Data"
global	int_data 	"${maindir}/Results/IntData"
global	log			"${maindir}/Results/Logs"

* Setting starting file names
global  SLfile 	"SriLankaReplciationMaster_with_depreciation.dta"
global  GHfile 	"GhanaReplicationMaster_with_depreciation.dta"

* Create output folder structure

mkdir 	Results
mkdir 	"$tabdir"
mkdir 	"$graphdir"
mkdir 	"$int_data"
mkdir 	"$log"

* Create starting files from original RCT's replication packages

do "${maindir}/SL_main_dataset_generation_2025.do"
do "${maindir}/Ghana_main_dataset_generation_2025.do"

* Run auxiliary data preparation files
do "${maindir}/Dataprep_customers.do"
do "${maindir}/Dataprep_ExtraWavesSL.do"
do "${maindir}/Dataprep_unitvalues.do"
do "${maindir}/GH_depreciation_data_preparation.do"
do "${maindir}/SL_depreciation_data_preparation.do"


/*
* Install necessary additional packages
ssc install qreg2
ssc install xtpattern
ssc install reghdfe
ssc install estout
ssc install winsor
ssc install xtabond2
ssc install ivreg2
ssc install leebounds

display "********************************************************************"
display "*** NOW CHECK THAT sg71 IS INSTALLED; IF NOT, PLEASE INSTALL IT. ***"
display "********************************************************************"

set more on
more
net search sg71
more
set more off
*/

* Main text Tables and Figures

cd "$tabdir"
do "${maindir}/_Table1.do" 			// Table 1: PF estimates (first stage)

cd "${maindir}"
do "${maindir}/Calculate_TFP.do" 	// Calculate TFP from first stage (intermediate step)

cd "$tabdir"
do "${maindir}/_Table2.do" 			// Table 2: Productivity estimates

do "${maindir}/_Figure1.do" 		// Figure 1: TFP CDFs and rank-sum tests 

cd "$tabdir"
do "${maindir}/_Table3.do" 			// Table 3: Decomposition of revenue treatment effect into channels
do "${maindir}/_Table4.do" 			// Table 4: Long-term effects on productivity, capital and materials
do "${maindir}/_Table5.do" 			// Table 5: Treatment effect onto capital categories
do "${maindir}/_Figure2.do" 		// Figure 2: Asset ownership over time 
do "${maindir}/_Table6.do" 			// Table 6: Treatment effect on business practices
do "${maindir}/_Table7.do" 			// Table 7: ACDE

* Appendix Tables
do "${maindir}/_TableA1.do" 			// Table A1: Attrition analysis
do "${maindir}/_TableA2.do" 			// Table A2: More PF for SL
do "${maindir}/_TableA3.do" 			// Table A3: PF SL split by treatment status
do "${maindir}/_TableA4.do" 			// Table A4: PF SL split by sector
do "${maindir}/_TableA5.do" 			// Table A5: More PF for GH
do "${maindir}/_TableA6.do" 			// Table A6: PF GH split by treatment status
do "${maindir}/_TableA7.do" 			// Table A7: PF GH split by sector	
do "${maindir}/_TableA8.do" 			// Table A8: TFP Effects alternative PF estimators
do "${maindir}/_TableA9.do" 			// Table A9: TFP Effects translog
do "${maindir}/_TableA10.do"			// Table A10: Translog PF estimation
do "${maindir}/_TablesA11-A15.do" 		// Tables A11 - A15: TFP Effects depreciation
do "${maindir}/_TableA16.do" 			// Table A16: TFP Effects Sri Lanka
do "${maindir}/_TableA17.do" 			// Table A17: TFP Effects Ghana
do "${maindir}/_TableA18.do" 			// Table A18: TFP Effects gender SL
do "${maindir}/_TableA19.do" 			// Table A19: TFP Effects gender GH
do "${maindir}/_TableA20.do" 			// Table A20: TFP Effects treatment arm SL
do "${maindir}/_TableA21.do" 			// Table A21: TFP Effects treatment arm GH
do "${maindir}/_TableA22.do" 			// Table A22: Lee Bounds
do "${maindir}/_TableA23.do" 			// Table A23: Intensive and extensive margin SL
do "${maindir}/_TableA24.do" 			// Table A24: Long term effects SL
do "${maindir}/_TableA26.do" 			// Table A26: TFP effects by business location SL

* Appendix Figures
do "${maindir}/_FigureA1.do" 			// Figure A1: Effects on sales margins (Sri Lanka)
do "${maindir}/_FigureA2.do" 			// Figure A2: Investments upon treatment and follow-up investments (Sri Lanka)
do "${maindir}/_FigureA3.do" 			// Figure A3: Unit value of new asset purchases (Sri Lanka)


exit
