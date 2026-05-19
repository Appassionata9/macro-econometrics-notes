Andrea Carriero, Todd E. Clark, and Massimiliano Marcellino, "Bayesian 
VARs: Specification Choices and Forecast Accuracy," Journal of Applied 
Econometrics, Vol. 30, No. 1, 2015, pp. 46-73.

This file details the (1) data and (2) RATS program files used to 
produce the results in the paper. The programs can be run in whatever 
directory this file has been unzipped (the data files will be in the 
same directory, which is what the provided programs require).

Contact information:  todd.clark@clev.frb.org, (216)579-2015.

**********
DATA FILES:  
**********

The following files contain the various time series of data used in the 
article (all at the quarterly frequency), with rows corresponding to 
dates and columns to variables.  The first column in each file provides 
the dates of the observation.  The first row lists the variables.

file       #obs    #var
US.txt      447      18
CAN.txt     472       9
FRA.txt     473       9
UK.txt      423       9

For those who may it find it more convenient, the archive includes 
corresponding Excel spreadsheets (same file names but with extensions of 
.xls instead of .txt) with the same contents and layout.  The RATS
programs call the data from the Excel files.

The file US.txt (or US.xls) provides the monthly time series for the 
U.S. used to produce all of the U.S.-based results in the paper.  The 
other files provide the data used to produce results for other countries 
(these results are summarized in the paper but not included in the 
figures).

The text files, which are ASCII files in DOS format, are zipped in 
ccm-data-txt.zip. The XLS files are zipped in ccm-data-xls.zip


*************
PROGRAM FILES:
*************

The program files consist of files ending in .prg that read in and 
transform the data, set up aspects of the model, call procedures that do 
most of the model estimation and forecast processing, and then compile 
summary statistics of the results for the given model.  The procedure 
files have names ending with .src.

The program files, which are ASCII files in DOS format, are zipped in
ccm-programs.zip. Unix/Linux users should use "unzip -a".

BVARnormalWishart.src   Forms estimates and forecasts of VAR under 
   Normal-Wishart prior and posterior, using Minnesota-type prior as 
   specified in such sources as Kadiyala and Karlsson (1997).

BVARnormalWishart.dumobs.src   Forms estimates and forecasts of VAR under 
   Normal-Wishart prior and posterior, with prior captured by dummy 
   observations.  Prior includes Minnesota component, sums of coefficients, 
   and initial observations.

directBVARnormalWishart.src   Using direct multi-step spec., forms 
   estimates and forecasts of VAR under Normal-Wishart prior and posterior, 
   using Minnesota-type prior as specified in such sources as Kadiyala and 
   Karlsson (1997).

BVAR.ridge.withsim.src   Uses ridge regression approach to estimate VAR 
   and forecast under Litterman prior.

fcmoments.src   Processes draws of forecasts to compute point forecasts 
   and average log predictive scores.

baselineVAR.prg   Using BVARnormalWishart.dumobs.src, this program 
   generates forecasts from the benchmark VAR model.

figure1.opttightness.prg   Using BVARnormalWishart.dumobs.src, this 
   program generates forecasts from the VAR specification optimized to pick 
   (at each forecast origin) the marginal-likelihood maximizing overall 
   tightness (lambda1). Figure 1 shows results for this approach compared 
   to the benchmark VAR.

figure2.optlag.prg   Using BVARnormalWishart.dumobs.src, this program 
   generates forecasts from the VAR specification optimized to pick (at 
   each forecast origin) the marginal-likelihood maximizing lag order. 
   Figure 2 shows results for this approach compared to the benchmark VAR.

figure3.opttightandlag.prg   Using BVARnormalWishart.dumobs.src, this 
   program generates forecasts from the VAR specification optimized to pick 
   (at each forecast origin) the marginal-likelihood maximizing tightness 
   and lag order. Figure 3 shows results for this approach compared to the 
   benchmark VAR.

figure4.growth.prg   Using BVARnormalWishart.src, this program generates 
   forecasts from the model with most variables in growth rates form.  
   Figure 4 shows results for this approach compared to the benchmark VAR.

figure5.pseudoiterated.prg   Using BVARnormalWishart.dumobs.src, this 
   program generates pseudo-iterated point forecasts from the baseline VAR 
   specification without simulation, using just the posterior mean 
   coefficients (no simulation).  Figure 5 shows results for this approach 
   compared to the benchmark VAR.

figure6.direct.prg   Using directBVARnormalWishart.src, this program 
   generates forecasts from models specified in direct multi-step form, 
   without simulation.  Figure 6 shows results for this approach compared 
   to the benchmark VAR.

figure7.Litterman.prg   Using BVAR.ridge.withsim.src, this program 
   generates forecasts from models specified in levels with a Litterman 
   prior, simulating forecasts on an equation by equation basis.  Figure 6 
   shows results for this approach compared to the benchmark VAR.

figure8.rolling.prg   Using BVARnormalWishart.dumobs.src, this program 
   generates forecasts from the benchmark VAR model, but with a rolling 
   sample for estimation, with sample size held fixed at that used to 
   generate the first forecast. Figure 8 shows results compared to the 
   benchmark model estimated recursively.

figure9.7variables.prg   Using BVARnormalWishart.dumobs.src, this program 
   generates forecasts from a model with just 7 variables, using the same 
   prior as in benchmark VAR model.  Figure 9 shows results from the 
   smaller model compared to the benchmark larger model.



