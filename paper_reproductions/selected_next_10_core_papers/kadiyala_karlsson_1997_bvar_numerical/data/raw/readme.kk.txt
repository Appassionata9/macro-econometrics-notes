K. Rao Kadiyala and Sune Karlsson "Numerical Methods for Estimation and
Inference in Bayesian VAR-models", Journal of Applied Econometrics, Vol.
12, No. 2, 1997, pp. 99-132.

The source for the Fortran program is in var.zip (see below for exact
contents) The file README.VAR gives instructions for compiling and running
the program. SYNTAX.TXT gives additional information on the commands used
within the program. 

The data and some example files which (with slight modifications, i.e.,
uncommenting the relevant parts) reproduces the results in the paper are
in data.zip.

All files are in DOS format.

Sune Karlsson, stsk@hhs.se


Content of the archive DATA.ZIP:

LITTDIF  CMD      1393 95-12-17   21.50  * Forecasting experiments with the
LITTDIF  OUT      7725 95-07-13   12.30  * Litterman model. Files are currently
LITTENGI CMD      1530 95-12-17   21.50  * set up to obtain the posterior
LITTENGI OUT      9883 95-07-13   12.30  * distribution of the forecasts. As is
LITTMIN  CMD      2499 95-12-17   21.50  * the .CMD files will write auxilliary
LITTNDGI CMD      1684 95-12-17   21.49  * output files of several MB
LITTNDGI OUT     62195 95-12-17   21.07  * .OUT files are corresponding output
LITTNW   CMD      1455 95-12-17   21.11  * files, these can be used to verify
LITTNW   OUT      7763 95-07-13   12.30  * the operation of the program.
LITTOLS  CMD      1138 95-12-17   21.17  *

LITTERMA DAT     12320 95-11-19   18.19  * US Data file for the Litterman model
   * The variables are organized as columns with one observation per row.
   * Quarterly data starting 1948:1.
   * The variables are OBS RGNPG INFLA UNEMP LM1 INVEST CPRATE CBI
   * i.e. Observation number, Real growth rate of GNP (annualized quarterly
   * changes in real GNP), Inflation rate (annualized quarterly changes in the
   * implicit GNP deflator), Unemployment (percent of civilian labor force),
   * Log of average of monthly M1 data, Gross Private Domestic Investment
   * (nominal), 4-6 month commerical paper rate (averages of daily rates),
   * Changes in Business Inventory (nominal at annual rates).
   * RGNPG is obtained from from seasonally adjusted nominal GNP and the
   * seasonally adjusted GNP deflator. M1, UNEMP, INVEST and CBI are seasonally
   * adjusted.


README   TXT      5530 96-10-22   23.35  * This file

SWEV4DI  CMD      1430 96-10-22   21.57  * Forecasting experiments with the
SWEV4DI  MS     101398 96-10-22   22.10  * Swedish unemployment model.
SWEV4DI  OUT    101578 96-10-23    1.37  * .CMD files are input files for the
SWEV4E2  CMD      1532 96-10-22   21.57  * VAR program.
SWEV4EN  CMD      1602 96-10-22   22.06  * .MS and .OUT files are corresponding
SWEV4EN  MS      20052 96-10-22   22.10  *  output files, these can be used to
SWEV4EN  OUT     20240 96-10-23    1.37  * verify the operation of the program.
SWEV4MI  CMD      2624 96-10-23    1.45  * .MS are output from the Windows NT
SWEV4MI  MS     145227 96-10-23    1.49  * version of the program and .OUT are
SWEV4MI  OUT    145387 96-10-23    2.09  * from the VAX/VMS version (the
SWEV4ND  CMD      1548 96-10-22   22.05  * used in the paper). The output
SWEV4ND  MS      14274 96-10-22   22.13  * differs slightly between the versions
SWEV4ND  OUT     14438 96-10-23    1.37  * (see discussion in README.VAR)
SWEV4NW  CMD      1486 96-10-22   22.04  *
SWEV4NW  MS     101403 96-10-22   22.14  *
SWEV4NW  OUT    101595 96-10-23    1.37  *
SWEV4OL  CMD      1017 95-06-25   22.13  *
SWEV4OL  MS      42994 96-10-22   22.14  *
SWEV4OL  OUT     43070 96-10-23    1.37  *
SWEVE24A CMD       894 95-12-17   21.22 * Examples of searching over the hyper
SWEVEN4A CMD       873 95-12-17   21.22 * parameters to determine the values
SWEVMI4A CMD       786 95-12-17   21.21 * used with the prior distributions
SWEVMI4A OUT     27870 95-12-17   21.21 *
SWEVND4A CMD       856 95-12-17   21.20 *
SWEVNW4A CMD       912 95-12-17   21.19 *

SWEVAR3A DAT      9048 93-11-10   23.16 * Data file for the Swedish
 * Unemployment model.
 * The variables are organized as columns with one observation per row.
 * Quarterly data starting 1964:1.
 * The variables are LIPSWE, UNEMP, S1, S2, S3, S4.
 * LIPSWE is the logarithm of the Swedish industrial production index (average
 * of monthly data), UNEMP is the three month average of the unemployment rate
 * (0.5 is added to observations 87:1 - 90:4 to account for a change in the
 * collection of data). S1 - S4 are seasonal dummies.


Content of the archive VAR.ZIP:

BAYES    FOR     89162 96-10-20   20.34
COMPARSE FOR     89706 96-10-21   13.46
COMPILE  COM       486 96-10-22   22.16
DALL     INC       186 95-12-17   18.28
DWORK    INC       136 95-12-15   17.49
ENCGIBB  FOR      7169 96-10-20   20.34
FIXIMSL  FOR       679 96-10-21   18.59
FUNC     FOR     19244 96-10-20   20.34
GIBBS    FOR     20283 96-10-20   20.34
IO       FOR     22061 96-10-20   20.34
IOCOM    INC       702 95-12-15   17.49
LINFOR   INC       112 95-12-15   17.49
LINMOD   FOR     25944 96-10-20   20.34
LINMOD   INC      1350 95-12-17   19.48
LOOP     INC       210 96-02-23   23.57
MATRIX   FOR     71870 96-10-20   20.34
MCIDO    FOR     84265 96-10-20   20.34
MCINT    FOR     38499 96-10-20   20.34
MCISHELL FOR     46856 96-10-20   20.34
MEM      INC       310 95-12-17   18.41
MEMMAN   FOR     51362 96-10-20   20.34
MSPS4    FOR     10522 96-10-22   20.51
PARSCOM  INC       113 95-12-15   17.49
PARSE    FOR     35330 96-10-20   20.34
RANDOM   FOR     59848 96-10-20   20.34
README   TXT      5318 95-12-21   19.47
README   VAR      5214 96-10-22   23.25
STRCOM   INC        55 95-12-15   17.49
SUBSTCOM INC       282 95-12-15   17.49
SYNTAX   TXT     13609 95-12-21   19.01
TIMING   FOR      1634 96-10-20   20.34
VAR      COM       317 95-12-16   21.49
VAR      FOR     38075 96-10-22   21.06
VARS     INC       385 95-12-17   19.09
VMS      FOR      6698 96-10-21   18.24
