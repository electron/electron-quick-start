\name{NEWS}
\title{News for Package 'psych'}
\section{Changes in psych version 1.8.4 (2018-04-01)}{
  \subsection{Introduction}{
    \itemize{
      \item Version 1.8.4 is the development release of the psych package. It is available as a source file for Macs or PCs in the repository at \url{http://personality-project.org/r}. The released version on CRAN is 1.8.3.  The second digit reflects the year (i.e., 2018), the third set the month (i.e., 1.8.3 was released in March of 2018, the last two digits of development versions reflect  either an minor change or the day of any modifications, e.g. 1.8.3.2 was the second attempt to get 1.8.3 released.  1.7.8 was  released in August, 2017.
    \item To install this development version, use the command: install.packages("psych", repos="http://personality-project.org/r", type="source"). Remember to restart R and library(psych) to make the new version active.
       
      \item The psych package includes functions and data sets to do classic and modern psychometrics and to analyze personality  and experimental psychological data sets. The psych package has been developed as a supplement to courses in research methods in psychology, personality research, and graduate level psychometric theory. The functions are a supplement to the text (in progress): An introduction to psychometric theory with applications in R. 
      \item Additional functions are added sporadically.
      \item This news file reports changes that have been made as the package has been developed.
      \item To report bugs, send email to \url{mailto:revelle@northwestern.edu} using bug.report.
    }
  }
  \subsection{To do}{
    \itemize{
      \item Suggestions are welcome, but the current list includes the following(and has included for a long time, so lets be patient):
      \item Add confirmatory clustering to ICLUST
      \item Get cluster scores in ICLUST -- analogous to factor scores (requested by Ben Shalet)
     
      \item Add the ability to create multiple groups in sim.irt functions
      \item Find canonical loadings in set.cor     
      \item Add omega factor extension figure option (requested by Sylia Wilson)     
     \item Add option to do subject density and item density plot to IRT plot.
      \item add the ability to scale radar plots of raw data from min to max, and add a scale to radar and spider plots (e.g. circular histograms)
      \item add the ability to add labels to lavaan.diagram  
      \item clean up lavaan diagram so that the output is more readable    
     \item Add the ability to return the true scores for subjects when simulating structures.  This will help fitting reliability models but will require not using mvrnorm 
     \item To help those who want to simulate a bifactor model, make it explicit  
     
     \item Check the bias in bootstrap resampling using cor.ci  
     
     \item Start to use the drop=FALSE when doing subsetting (doing this more and more)
   
     \item add symmetric=TRUE to eigen calls, think about only.values=TRUE for some cases 
     \item Add an analysis if DIF to the irt functions  (requested by David Condon)
     \item Add some power functions
     
     \item Add CIs for means and skews as an option (for describe as well as describeBy)  Requested by Aaron Wichman
     \item Fix statsBy to handle the case of NULL groups.  (particularly for the cors=TRUE option).
     \item Add a function for the Meng, Rosenthal, Rubin tests for multiple comparisons of correlations.
     \item Clean up the various sim functions so that they are better documented
     \item Clean up documentation of score.irt etc.  (partly done)
     \item Add complexity  to omega solution
     \item Add statistic to fa to report max fa. (partly done with fm = minrank)
     \item Parallize iterations for confidence intervals in omega 
     \item Probably should drop much of the stats when doing iterations with fa or omega
     \item Find unbiased cis when doing bootstrap
    
     \item Allow  the choice between regression vs. correlation in esem between X and Y sets.
     \item Allow for different rotation options in X and Y sets in esem, allow omega style hierarchical structure for x (and y)
     \item Fix bug in esem.diagram for ability- bifactor 3,3 simple=FALSE,cut=.2
     \item Improve documentation for esem

      \item Add interbattery diagram to the structure.    
      \item fix bug in lavaan.diagram for lr=FALSE   
     \item Make sure that output is "tidy" 
      \item Add Krippendorf's alpha?
      \item Add Neil's Waller bifactor solution (see Psychometrika 2017)
      \item Add the ability to weight factor residuals to allow WLMS
      \item Add the ability to get factor scores for higher order factors (requested by Brandon Vaughn)
    
    
  }
  } 
  }
  
    \section{Changes in psych version 1.8.3 (2018-03-21)}{
    \subsection{Additions}{
          \itemize{ 
          \item Minor changes in documentation (e.g. in alpha, violinBy, corr.test, ...)
          \item digits option to print(x, all=TRUE) in print.psych
          \item Modified violinBy to treat character variables as numeric  (with notification) and to adjust the minimum and maximum in the case of groups. (Following some suggestions by Christie Nothelfer.)
          \item Added  the omit option to describe to just describe numeric data (another suggestion by  Christie Nothelfe)
          \item Modified p values in corr.test to allow for very small p by using the log.p option (suggested by Nicholas Clark)
          \item Modified read.file and write.file (etc) to allow file= as well as f=.  This is to make it more obviously compatible with save.file().
          \item Dropped all sex > 2 values in spi.
          \item Improved the dictionary for spi to include the demographic codes.
          \item Added the density option to error.bars  (suggested by Anne Zola).
          \item Added the na.rm=TRUE option to dummy.code  (suggested by Elizabeth Knowlton)
          \item Added the ability to have criteria as a separate object in bestScales
          \item Added formula option to setCor
          \item Improved the input to setCor and mediate to allow for formula input.  Also allowed interaction terms in setCor for parallelism with mediate. 
           \item Improved bestScales so that it summarizes the results of iterations. Fixed a problem with the overlap option so that it correctly chooses the number of items.
           \item Improved dfOrder so that it sorts dataframes more readily.
           \item Greatly improved setCor and mediate to allow for multiple interaction terms  and to include higher level interactions.  Both functions now return the transformed data when doing interaction terms.  Improved  the print.psych function for setCor.
           \item Added a HowTo for mediation and moderation, cleaned up the other HowTos to allow them to cross reference each other.
           \item Added the Garcia and Tal_Or data sets for demonstrations of moderation and mediation. 
           \item Added the ability to partial out variables in mediate.  
           \item Switched to using the log option in pnorm  for probabilities in pt and pf
             \item parallelize iterations when bootstrapping fa   (did this some time earlier, but had not taken if off the to do list)
        \item Added alpha option to corPlot (to allow semi-transparent plots)
        \item Dropped the density =50 option and changed to alpha=1 in violinBy.  This leads to much faster plotting.
        \item Added the densityBy function to draw multiple histogram/density plots to show the overlap between two or more distributions. Can also just draw the density for one distribution.
        \item Modified the call for bi.bars to be consistent with densityBy and violinby calls. 
        \item Minor improvement in vignette documentation 
        \item Added the AUC (area under the Curve) function. This basically adds signal detetection capability as an option for dichotmous data (and reports such measures as sensitivity and specificity as well as d'). 
        \item Added alpha.ci to calculate confidence intervals for alpha based upon Feldt (1987)
        \item Added confidence intervals to splitHalf function. 
         \item Added the df in mediate 
         \item Modified the call sequence to matReg to make it more transparent in mediatethe individual ab paths in the mediate function (requested by Heather Urry)
          \item Added the describeFast function for quick counts of large data sets.
        \item Added the filesList function to display all the files in a directory (using file.choose to find the directory).
        \item Added the fileCreate function to do what file.choose() should do for RStudio
         \item Added the filetype option to read.file and the ability to write without a suffix to write.file
         \item Added filesInfo for information about the files in a directory
         \item Completely rewrote the dfOrder function after finally understanding the help menu for order.
         \item Added testRetest to do test-retest reliability and a number of related statistics.
         \item Added checks for non-numeric data and data with no variances to mixedCor.
         \item Added a check in mlr so that it will only find within subject alpha if n.times > 2  (This was throwing a warning if using mlr to check testRetest results.)
         \item Serious rewriting of mixedCor with the hope of making it faster (and more robust to cases where we have unequal number of categories in polytomous data). Perhaps solved the problem of poly.di blowing up if the polytomous have a different number of categories.
           \item Fixed the degrees of freedom in setCor and mediate to reflect the actual numbers of subjects in the correlations, not the number of cases in the file.
           \item Modified ICC to use lmer from lme4 to handle missing data and to report variance components.  Set the default to use lmer.  This is particularly useful if doing large files.
           \item Added the theta parameter to the sim.irt family of functions to allow for specification of the theta across simulations.  (Requested by Yuming Liu.)
        \item Added DAT as a possible data file type to read.file.
        \item Cleaned up the diagram.Rd file demonstrations to look nicer.
        \item Added a min.length parameter to corPlot to allow for abbreviations of row and column names.
        \item Added the sai and tai data sets (state anxiety and trait anxiety measures from the PMC lab) for demonstrations of test-retest reliability, validity, etc. 
        \item Changed all the http:// references to https:// to get around problems with failure to read http:// files.
        
        
         }
          }
       \subsection{Bugs Fixed}{
          \itemize{
          \item  Added  ci <-  sef <- ci.adj <- NULL in corr.test to fix problem reported by  Nicholas Clark  9/13/17
          \item Fixed an inconsistency in mssd between the single vector case and the matrix/data.frame case.  Was dividing by n-lag -1 instead of n- lag.
          \item Clarified documentation for mssd (problem raised by Dennis Mongin)
          \item Discovered that write.file(new=TRUE)  works only in R.app and not in RStudio.  This seems to be because core-R ignores the new=TRUE option.  
          \item Correct was not being passed correctly in fa for doing polychoric or tetrachoric correlations  (detected by Jason French, 10/10/17)
          \item Fixed improper error message bug in cohen.kappa reported by Johannes Bracher 
          \item Fixed spi.dictionary so that it labels variables correctly.
   		  \item Fixed a print error in mediate for the a path (probabilities were displaying incorrectly.)
          \item Made the digits option actually work in pairs.panels (reported by Federico Filipponi)
		  \item Fixed a bug in fa for some problems (e.g. fa(bfi[1:5], covar=TRUE) 
		   \item Fixed a problem with diagram.curve and another in diagram.curved.arrow
		\item Fixed a problem with plot.fa.parallel for the case of plotting just one line. (reported by Daniel Morillo).
        \item Fixed the lavaan and sem models for omegaSem to handle reversed items properly (this involves gsub for - signs in names).
        \item Fixed the ab boot values in mediate when we partial out variables (reported by Dan Molden)
        \item Corrected the BDI scores in the affect data set.  They had been incorrectly the EA1 scores. 
        \item Modified the help file for read.file to explain more clearly how to read .rda files. 
        \item Modified polychoric so that when it tests for number of categories, it is not limited by 1-5 or so, and can handle 0,20,40,80, 100  if these are few enough categories. 
        \item Changed the (1-alpha) "\% confidence" to (1-alpha)*100 "\% confidence " in error.bars.by (requested by Victor González Fernández)
         \item Fixed the residuals reported in fa.extend (not giving correct values for uncorrelated factors --reported by Deon DuBruin) (and modified the print statement
        \item Changed the degrees of freedom in paired.r to be n-3 to match r.test (and Steiger 1980)
        \item Fixed setCor so that the ruw values are correct in the case of negative correlations. (reported by David Condon).  
    \item Added left and right brackets to variable names in df2latex to allow stars to print correctly in LaTex
    \item Corrected the definition of the objective function in principal (error pointed out by Andre Beauducei) 
    \item Fixed cor2latex (and df2latex) so that large negative correlations can be bold faced as well as large positive correlations (pointed out by Anne Zola).
    \item Fixed the label option in error.dots so that it actually works.
          }
           }
    
     }
     
     
     
    \section{Changes in psych version 1.7.8 (2017-08-31)}{
    \subsection{Additions}{
          \itemize{ 
          \item Completely rewrote partial.r for readability and also to add the ability  to find the anti-image (that is to say, to partial all the variables from each other in correlation matrix.) 
          \item Added some options to autoR. 
          \item Added the gr option (for color gradients) to corPlot following a suggestion from Anne Zola and Lorien Elleman
          \item Added fa.random to start doing random effects factor analysis. 
          \item Added cohen.d  to find cohen.d statistic for two groups on a number of variables. Also reports the Mahalanobis distance.
          \item Added Mahalanobis distance for groups (see del Giudice, MBR, 2017) 
          \item Added d.ci (cohen.d.ci) to find confidence intervals for effect sizes.
          \item Added d2t, t2d to do basic conversions of effect size.
          \item Rewrote bestItems and bestScales to allow raw data or correlation matrix input and to be much faster. 
          \item Added the pc option to fa.diagram to allow the arrows to come from the observed variables if the data are a principal components solution. (suggested by Michael Wood).
          \item Added selectFromKeys to allow selecting items based upon a keys.list
          \item Added fa.sapa to allow iterated  factor solutions across random subsets of subjects.  Basically just a tool to examine the stability of sapa based solutions. 
          \item Completely rewrote pairs.panels to a) add confidence regions for regressions and for loess fits. Changed the smooth function to be loess rather than lowess. Adjusted the histograms so that values line up with the labels.  Changes suggested by Julian Martin.  
            \item Added alpha factor analysis as an option to the fa function.
          \item Converted package to be byte-compiled.  This seems to result in a 7 - 10 \% improvement for e.g., factoring a 1000 x 100 categorical data matrix (mean of 61 elapsed vs. 65 secs).
          \item added sem.diagram and sem.graph which call structure.diagram and structure graph with sem output.  Still having problems sporadically with RGraphviz.
          \item Added in cross validation as an option to best.scales/bestItems.  
        \item Modified alpha so that it can just select a small subset of items to score   
          \item Added a comment to the r.test function about precision of p values (suggested by Julia Rohrer).
          \item Add an additional object to corr.test and corr.p to give Bonferonni and Holm (default) adjusted cis (requested by Lorien Elleman)
          \item Added the name for corPlotUpperLowerCi to be the camel case equivalent of cor.plot.UpperLowerCi
          \item Changed the se.bars=TRUE to se.bars=FALSE in fa.parallel to make the decision rule more transparent
         \item Modified fa so that it will not die if nfactors = nvar 
         \item Changed messages to warnings in polychoric.  This allows fa.parallel to run in parallel (and therefore much faster) without crashing. (Based upon a problem reported by Guido Biele). 
         \item Added the diag option to residuals and resid.
         \item Added the blant data set to show factor analytic problems.
         
                  }
          }
       \subsection{Bugs Fixed}{
          \itemize{ 
           \item Fixed problem in cohen.kappa to correctly find the variances of weighted kappa (reported by Lisa Avery).
          \item Fixed mssd to correctly divide by number of cases-lag instead of n.obs - l - lag  (reported by Charlotte Vrijen)
          \item Fixed problem with alpha for two item scales (I was not correctly reporting the alpha if one item was dropped.)  Reported by Daniel Zingaro.
          \item Patched cohen.kappa so that it warns instead of breaking if given identical ratings for everyone (reported by Caroline Wehner).
          \item Added the factor names for old.min(res) solutions.  
          \item Fixed (finally?) a bug in mixedCor (coming from polydi) that was incorrectly reporting half of the correlations as 1.0.  This was causing improper solutions in any data set that had more than 1 dichotomous variable and more than 1 polytomous variable.
          \item Fixed scoreIRT.2pl so that it does not choke on 1 items scales
           \item Modified fa so that it will report the factor score correlations for the chosen scoring method as well as the regression based scores.  Although factor.scores was reporting the correct R2 values, fa was always reporting the regression based R2 values. Also deprecated the oblique.score option.   (Based upon trying to answer a question from Jeannette Samuelsen.)
       
 
       
        
           }
          }
    }  
  
  
    \section{Changes in psych version 1.7.5 (2017-05-01)}{
    \subsection{Additions}{
          \itemize{ 
        \item Added read.xport to the read.file so we can read SAS export files. Also added the widths parameter so that read.file can read a fixed width file.  
        \item Added select option to  scoreItems and scoreOverlap to just score the items selected (to enhance speed for big sets of items and short scales).
        \item Added a private function (selectFromKeyslist)  to handle numeric and character keys.lists when doing selection.
        \item Added irt.se  to find standard errors based upon the test information
        \item Added show = FALSE to setCor to allow the option of showing the unweighted matrix correlation (Had removed this in prior release, but decided for teaching purposes, is is convenient.)
        \item Added the ability to define the separator when reading csv files in read.file
        \item Added breaks=21 to multi.hist to allow for better plotting control
        \item Added the ability to plot asymmetric correlation matrices in corPlot (requested by Anne Zola)
        \item Added the correction option to fa.parallel when doing tetrachoric or polychoric correlations.  It had been set to .5 without the ability to set it to 0. (Inspired by a question from Ismail Cukadar).
        \item Added stars as an option to pairs.panels and corPlot.  This is for those people who insist on showing 'significance' values.  Also added scale as an option when showing the numbers (to show significance by number size.)
        \item Added quickView to complement headTail and topBottom.  Added from and to parameters to all three functions.
        \item Added top=4 and bottom=4 to replace hlength and tlength in headTail and topBottom. Makes more obvious code.
        \item Added Vaccounted for fa and pca (as requested by various stackoverflow users).
        \item Dropped the message about matrices not being square in cortest.  (Just an irritant when doing R CMD check and testing the intro.rnw file)#Adapted from the help for pairs
#modified December 15, 2011 to add the rug option
#further modified March 30, 2012 to add the method of correlation option (suggested by Carsten Dormann).
#Fixed a bug in show.points on  March 18, 2017  (reported by Matthew Labrum)
#by moving all the little functions to be outside the main function, this allows method and rug to be passed to these lower order functions.
#this should allow for somewhat cleaner code for the other functions
#modified March 15, 2015 to add the ability to control the size of the correlation separately from the cex variable in the points
#also added the ability to set the number of breaks in the histograms
#Also completely reorganized the main function to be much cleaner
#would like to add the smoothScatter function as an option


        \item Modified plot.parallel to go from ymin rather than 0.  Suggested by Hao Wu.
        \item Added confidence intervals for the ICC1 and ICC2 to the output for statsBy (requested by Lorien Elleman)
        \item Added mixedCor as an improvement to mixed.cor.  Somewhat cleaner interface.
       
        }
        
          }
      \subsection{Bugs Fixed}{
          \itemize{ 
            \item Modified the minres solution in fa following very helpful suggestions from Hao Wu.  Basically, the first derivative wrong and the solution was slightly incorrect.  This has now been fixed for minres.  fm="old.min" keeps the old solution.  The fm="uls" uses  empirical first derivatives works to give the unweighted least squares  solution.   This is discussed in the fa help page as well.  
              \item Fixed RMSEA error  (as reported by Hao Wu). In version 1.6.12 I had changed the RMSEA formula  from the Tucker formula to the one used in sem and now have reverted to the Tucker formula (as described in the help page.) 
              \item Fixed cor.plot.upperLowerCi so that it works again and also reports replications
              \item patch to mixed.cor for figuring out what kind of data we have. Basically, set all minima to 1 so that polydi won't croak
              \item moderate.diagram was drawing incorrect X paths.
              \item plot.irt was not labelling factor numbers 
              \item t2r was not taking the sqrt and thus was giving much to small rs.  fixed.
              \item In describeBy, changed nrow to NROW to correct error thrown by the affect data set for the development versin of linux (although that seems to have been a temporary error.)
              \item Modified isCorrelation yet again to treat the case of symmetric correlation matrices stored as data frames.  (Used in some class examples!)
              }
              }
             }
  
   \section{Changes in psych version 1.7.3.21 (2017-03-21)}{
    \subsection{Additions}{
          \itemize{ 
        \item Added sim.multi to simulate and draw within subject data. 
        \item Minor modifications to corPlot for labelling (and added a comment to the help file to show how to do multiple plots to answer a query from Yuji Shimohira Calvo)
        \item Modified cohen.kappa so that the number of levels can be specified if there are some levels that are missing completely (requested by Amy Finnegan).
         \item Added multilevel.reliability (mlr) to find various generalizability coefficients for three way (subjects x time x items) data following chapters by Pat Shrout and Sean Lane.
        \item Added a helper function (mlArrange) to convert semi-wide data into long data.  Useful for multilevel analyses of three way data sets.
        \item Added mlPlot to plot multilevel (id x time * item) data.
        \item Added a plot option to fa.parallel to allow suppression of plotting (requested by David Copndon)
        \item Added autoR to find autocorrelations based upon mssd. This is useful for multiple time points.  
         \item Added a trivial helper function r2c (and cor2cov) to convert a correlation matrix to a covariance matrix.
        \item Added VIF (Variance Inflation Factor) which is just 1/(1-smc)  to setCor.
        \item Added a note to alpha about the dplyr problem and added a fix to the problem (as reported by Adam Liter).
        \item Added a discussion to the fa.rd documentation discussing the problem of estimating the minimum residual.  (Inspired by correspondence with Hao Wu and Mikko Ronkko).
        \item Added a new vignette (intro) and modified the overview vignette.  Meant to make the introduction and overvies easier to read.
        \item Added a new function:  unidim  to estimate the unidimensionality of a set of items. 
        \item Inspired by a question from Jared Smith, added several new features to scatter.hist, as well as removed a few bugs.
        \item While patching pairs.panels (see bugs fixed), add smoother option to all the other options.
        \item Added cor2cov (and then temporarily removed because of conflict with lavaan.shiny call to lavaan::cor2cov).  
        }
        
          }
      \subsection{Bugs Fixed}{
          \itemize{ 
              \item ScoreIrt: corrected cut so that it passes through to lower level functions (reported by David Condon)
              \item rownames for corr.p$ci were incorrectly labeled (reported by Lorien Elleman)
             \item Fixed a bug in finding RMSEA and the confidence intervals thereof.  (Reported by Hao Wu).  Possibly the error was introduced in 1.6.12 
     \item Fixed plotIrt so that it correctly rescales ylim for each factor rather than just the first factor.
     \item The lag parameter in mssd was not being used.  Fixed.
     \item The handling of missing data by groups in statsBy is fixed for finding ICC1. This was producing seriously incorrect ICC1 and ICC2s with a great deal of missing data. That is for SAPA data, when grouping by ZCTA, many items were missing.  (Reported by Lorien Elleman). 
     \item Fixed a bug in scoreItems and scoreOverlap when keys are already a data.frame rather than a matrix.  (Reported by Jeromy Anglim).
     \item Cleaned up various problems in mediate and print.psych.mediate so more complicate problems will work.
     \item Modified isCorrelation to test for symmetric matices but dropping colnames and rownames.  (This led to a problem with the neo data set.  Reported by Hao Wu.)
     \item Changed the neo data set from data.frame to matrix.
     \item Fixed omegaFromSem and print.psych.omega to handle case of 1 factor sem model (which would normally be thought of as inappropriate, but some people wanted.)
     \item Fixed a problem with printing describeBy  output. (Reported by David Uttall.)
     \item Fixed a problem with esem for the case of having more variables in the correlation matrix than being analyzed in the esem statement. 
    \item Fixed a bug in pairs.panels where it was ignoring the show.points option in several option cases.  (Reported by Matthew Labrum).
  
              }
              }
             }
  
 \section{Changes in psych version 1.6.12 (2016-12-31)}{
    \subsection{Additions}{
          \itemize{ 
            \item allow scaling of circles in error.circles (suggested by Josh Wilt)
             \item Added char2numeric to solve a problem of categorical data from a questionnaire.
               \item Added a helper function dfOrder to sort data.frames on multiple columns.
             \item Added interbattery for interbattery factor analysis.
             \item Changed the print line for MLE chi square to say model based chi square.
             \item Added Promax as a possible rotation in kaiser, and added the m = option to it as well. (In response to some correspondence with Stefan Dombroski).
         \item Clarified the KMO and cortest.bartlett help pages.
          \item Started to get rid of all of the deprecated functions.  (or at least move to them to unique help files).
             \item Added a trivial but useful function isCorrelation to improve the tests in alpha, scoreItems, etc.
    \item Serious reworking of omegaSem and omegaFromSem to allow the use of lavaan or sem to do cfa as part of omega.  Also, it is now possible to do omega directly from a sem/lavaan run.
     \item Added lavaan as a source of omegaSem and omegaFromSem.  Also, for omegaFromSem, added some of the normal omegasubscale output (suggested by  André Kretzschmar).
  \item fixed alpha, principal, fa, kmo and omega to check if the input is a symmetric correlation matrix or just a strange case of raw data (following a suggestion by Adam Liter).
  \item Modified cohen.kappa to truncate confidence limits to +/- 1 and added a discussion to the help page describing how to do a boot strap of cohen.kappa to examine the distribution of cohen.kappa (suggested by Andreas Spitzmueller).
  \item allowed scoreItems to handle variables that are factors.  Added a warning when scoring total scores with impute="none" when missing data are found.
  \item Added a parameter to densityBy (violinBy0 to allow for scaling the widths by sample size.
  \item Added a helper function, dfOrder to sort (order) a data.frame by multiple columns
  \item Completely revised scoreIrt (and the associated functions) to get around problems with all 0 or all 1s and to make the function faster, and perhaps more accurate.
  \item Changed the sort option in irt.fa to be FALSE (makes scoring easier).
    \item Fixed VSS so that it reports not the biggest, but also the first where the sign changes.
     \item Allow imputation in factor scores (e.g. median or mean imputation for items) (requested by Stephan Daus).  Also report the number of missing observations per subject when doing factor scores.
   
     }
   }
      \subsection{Bugs Fixed}{
          \itemize{ 
              \item  Fixed the RMSEA in fa.stats.  Although the confidence intervals were correct, the RMSEA value was slightly inflated.  Reported chi squares were correct, just the RMSEA was slightly off. 
        \item omega and schmid incorrectly estimated total variance in case of being given a factor loading matrix and correlation matrix as input instead of the more normal case of a raw data set or a correlation matrix. 
        \item Bug fixed in scoreIrt where the values for the scores for people who gave all of the highest possible scores was incorrect (reported by Roland Leeuwen ).  In addition, the scoreIrt.poly was not properly doing normal scoring but was in fact just doing logistic scoring.  Fixed.  This bug was affecting those people with max or min responses, and thus was particularly a problem for short scales.
        \item Fixed a bug in scoreItems for cases where some variables (not scored) are categorical (Reported by Ronald Fischer). 
         \item Fixed bug in fa.parallel where it is not drawing both resampled and simulated lines.  (reported by Alexander Weiss). This was intentionally added in about March to make a cleaner diagram, but now I am discussing this in the help file. 
   \item Allow specification of the direction of items in the scoreIrt.2pl to match the keys.list (previously it would match the factor analysis which could be backwards for some scales with many reversed items).
       \item Did not need to fix bug in wtd.table in polychoric by adding in minx and maxx, etc. (reported by Jeovani Schmitt) because this can be handled by settting global=FALSE.
       
    \item Minor fix in the default labels for the fa.parallel function (suggested by Meik Michalke)
     
             }
           }
     }
   
          
  
  \section{Changes in psych version 1.6.9 (2016-09-18)}{
  \subsection{Additions}{
          \itemize{ 
          \item Made it clearer that score.irt with the keys option is basically a Rasch model.That is,  tau and equal loadings are specified by keys.
          \item Serious rewriting of scoreIrt  (both for dichtonous and polytomous items) to make it able to use multiple cores (speeding up at least 8 times) and making the code more efficient when scoring multiple scales.
           \item Added scoreIrt.1pl and scoreIrt.2pl to more easily find Rasch like and 2 parameter solutions. 
          \item Added scoreFast to (very) rapidly find mean or total scores with or without imputation (ala scoreItems) but not to bother finding all the complicated statistics which take a lot longer to find. In addition, it just bothers to look at the items that to be scored, rather than all the items in the items set.  
          \item Added a trivial function (cor2) to correlate two or more sets of data (x and y), round to 2 decimals, save and print the results.  Truly trivial, but a time saver when comparing solutions.
            \item Added more functionality to dotchart and created error.dots.
            \item Added r2t,t2r,chi2r,r2chi as trivial conversion functions
        \item Added read.file, write.file, read.file.csv, write.file.csv as helper functions for input/output
        \item Added the ability to do Minimum Rank Factor Analysis (following a request by Michael Paul Grosz)
        \item Added an option to print.psych to allow significant digits to be controlled for describe (requested by Jeremy Biesanz)
        \item Added an exploratory structural equation function (esem) to  do exploratory modeling, and esem.diagram to show it. 
        \item Added keys2list  which converts a scoring key matrix to a list form.
        \item Added the ability to just pass a keys.list to scoreItems, scoreOverlap, scoreIrt.1pl.  This clearly simplifies the call.
        \item Added another helper function: keys.lookup that takes a keys.list and a dictionary and displays the content of the items to be scored. 
         \item Did to cor2latex what we did in df2latex (i.e., add cut and big options)
          \item Fixed vss to do any kind of rotation (that is, just pass the rotation to fa).
          \item Modified error.crosses to  allow specifying text, point, and error arrows separately (suggested  and with help from Arnaud Defaye)
          \item Minor change to tr to allow it consider na.rm=TRUE, and for cohen.kappa to handle cases of items with no variance. 
        
       }  
   }
\subsection{Bugs Fixed}{

   \itemize{
         \item Fixed subtle problem when handling missing data for score.irt for raw scores. Prior versions (< 1.6.7) would report incorrect total scores for cases with missing items that were to be scored negative. 
         \item Corrected the reference to Revelle, Wilt and Rosenthal in the bfi data set.
        \item Fixed a subtle problem in print.psych.iclust that was causing errors in the development version of R for PCs.  
        \item Added mu backinto sim.hierarchical (thanks for Alan Robinson for noticing it was gone).
        \item fixed bug in cor.wt for the problem of a vector of weights rather than a matrix of weights (Reported by Emil Kirkegaard)
               } 
      }
  }
  
\section{Changes in psych version 1.6.6 (2016-06-20)}{
  \subsection{Additions}{
          \itemize{
         \item Added an iterative option to cosinor so that it can do phase adjustment.
         \item Added error.bars.tab to do plots of tabular data with error bars
         \item Added a sort option to irt.fa so that items are sorted by factor loading.
         \item Added pca as an alias to principal
         \item Added the cut and big option to df2latex
         \item Added a few cross references to make it easier to find functions.
         \item Modified describe to take character vectors and matrices
          \item Added labels to factor.plot for more than 2 factors.  Not as hard as I thought. Added a show.names options to plot the labels without overwriting a point. 
          \item Modified corPlot to find correlations if input is a non square matrix or data.frame (but not an object from fa or omega).
         \item Modified describe (and therefore, describeBy) so that it can take more options (including interquartile range) and quantiles (requested by Gilbert Gregory).  
         \item Added a weight option to fa to weight subjects by a weighting vector (requested by Mike Hammer).
         \item Added anova.psych  to allow for tests for chisquare differences between factor solutions. 
         \item Serious modifications to biplot.psych, fa.plot, and cluster.plot to allow names (labels) in the multi-panel (more than 2 factor) option.  Also added the choose option to plot just one selected pair of factors from a larger set.  This is useful if showing a 3 or 4 factor biplot  and then "blowing up" one of the pairs. 
         \item Serious analysis of the use of global and correct for examples of small data sets provided by Gabriele Cantaluppi.  Some resulting improvement in documentation and options. 
       }  
   }
\subsection{Bugs Fixed}{

   \itemize{
         \item Changed principal (and fa) so that when it calls GPA::rotation(Varimax) it passes options (such as eps=1e-7) to get more accuracy. (Reported by Gottfried Helms)
         \item Fixed error.bars.by to handle the case of a single variable
         \item Fixed plot.irt.poly so that it communicates correctly with irt2latex for multiple factor case
         \item Fixed irt2latex so that it handles results from plotting irt as well as directly from irt.fa
         \item Fixed polychoric so that it returns meaningful tau values in the presence of missing categories (reported by Gabriele Cantaluppi).  polychoric was returning incorrect values of correlations and tau for the case of item responses differing in the number of alternatives, or with different minima.  Particularly a problem with very small sample sizes.  Also generally improved polychoric.
      } 
      }
  }
  
     \section{Changes in psych version 1.6.4 (2016-04-20)}{
  \subsection{Additions}{
          \itemize{
          \item To make the distinction between Principal Components and Rotated Components and Transformed Components, I have labeled them as PCi, RCi and TCi. I said I did that back in 2013 but I did not seem to have done it!
          \item Modified principal so that it will now handle the covar option correctly when finding principal scores.
          \item Modified bi.bars so that both the left and right panel are positive numbers (requested by Lorien Elleman).  Also added the ability to label the columns/rows.
           \item Modified omega.diagram so that labels can be applied to the factors. 
           \item Added the use option to splitHalf.  
           \item Minor tweak to output of fa.extend for the case of extending to one variable.
           \item Modified fa.congruence to consider the case of missing loadings (requested by Emil Ole William Kirkegaard)
           \item Modified documentation to cortest.bartlett to reflect test residual matrices from fa.
           \item Modified alpha to all the specification of n.obs if using correlation matrix.  This allows for finding the s.e. of alpha even from a correlation matrix.
           \item Modified cor.wt to handle the problem of missing data 
           \item Modified pairs.panels to allow plotting the raw data points but the weighted correlations
            \item Add the ability to do two level hierarchical factor analysis (i.e, taking out n at level 1, m at level 2.  Currently we do this with m=1 for omega)
           \item Added a warnings option to the alpha function as requested (repeatedly) by Markus Graf.
           \item Added two experimental measures of unidimensionality/goodness of fit to alpha.
           \item Modified mediate so that it handles moderation as well
           \item Added the diag and upper option to corPlot and cor.plot to allow for blanking out the diagonal or upper off diagonal (Suggested by David Condon).
           \item Added a number of options to plot.residuals to give more helpful displays
           \item Added (improved) error.bars for taking in data from an external source.
           \item Completely rewrote the mediate function to be more general and to have better graphics.  Added the ability to have multiple y variables.
       }  
   }
\subsection{Bugs Fixed}{

   \itemize{
          \item Modified principal so that it will now handle the covar option correctly when finding principal scores. 
          \item Corrected a bug in alpha (reported by Tamaki Hattori) to correctly find the s.e. of alpha.  I was slightly overestimating the correct values.   
           \item Fixed a bug in setCor that was given incorrect SE for regressions in the case of std=TRUE (the other stats were correct, but the t and p values of the betas were wrong) 
          \item Fixed a bug in error.bars that led to not drawing catseyes when importing using the stats option. Reported by Niall Bolger  
          \item Fixed read.clipboard.upper so that it works properly with names=TRUE  
          \item Fixed a bug in fa.parallel that would not report just fa=fa in the case of correlation matrices  (reported by Aaron Weidman)   
      } 
      }
  }
 
  
   \section{Changes in psych version 1.5.8 (2015-8-29)}{
  \subsection{Additions}{
          \itemize{
          \item Added rot.mat as an output to the fa and principal objects.  Cleaned up the fa and principal rotations so they all work.
          \item Added amplitude, mean, and intercept to cosinor
       }  
   }
\subsection{Bugs Fixed}{

   \itemize{
           \item alpha:  fixed the warning about reverse keying when keys have been specified (reported by Marc Heerdink)
           \item Fixed the LaTeX bug in the vignettes (I was trying to float htdp instead of htpb) (as requested by CRAN)
           \item Fixed the LaTex bug in df2latex  (same problem)
            }
                       } 
  }
 
 


  
  \section{Changes in psych version 1.5.6 (2015-6-20)}{
  \subsection{Additions}{
          \itemize{
      \item statsBy: Added the ability to find within group and between group covariances instead of just correlations.  This also allows the type of correlation to be specified.
      \item mediate: Can now do more general mediation of x -> M  -> Y for multiple X variables and multiple M variables. 
      \item mediate.diagram and moderate.diagram are now more functional
      \item fa:  Added the option to reject weird solutions when doing iterations of factor solutions (suggested by Vencislav Popov)
       \item fa, principal:  Improved documentation of principal and fa to explain the com variable.
       \item alpha:  Changed the default for check.keys to be FALSE.  This will result in a warning saying that you probably want to reverse keys, and tells you how to do so. In response to comments by Oliver John saying that we were making it too easy to find alpha.
       \item dia.arrow:  Added the both option to allow curved arrows to have heads at both ends (useful for setCor and mediate diagrams)  
       \item plot.irt and plot.poly: Added the option to plot different colors for each item. (requested by Yanna Weisberg).
       \item Explicitly declared all functions input from the stats, graphics, etc. cor R packages. 
       \item pairs.panels can now draw multiple plot characters (see the second iris example).
      \item faBy added a free or fixed option to force loadings to the pooled solution (if possible)
    }  
   }
\subsection{Bugs Fixed}{

   \itemize{
           \item Fixed fa so that the bifactor, TargetT, equamax and varimin rotations return correctly (they were returning the unrotated solution). (Reported by Matthias Bellmann.)
           \item describe: changed describe so that it will give (with *) stats for factors (replacing a functionality that disappeared sometime ago)
              The resolves the problem reported by Alan Kelly.
            \item Fixed a bug in fa2latex so it will boldface "big values" and cut small values instead of one or the other.  (Reported by Simon Kiss)
            \item df2latex and fa2latex: corrected the location of font.size to be inside the table to work correctly (Reported by Simon Kiss).
            \item pairs.panels  the cor option now works correctly (as specified in the help file) when showing the regression line (it had been reversed) 
            }
                       } 
  }
 
 


 \section{Changes in psych version 1.5.4 (2015-4-15)}{
  \subsection{Additions}{
          \itemize{
          \item  principal: Fixed principal to be compatible with changes in fa wrt rotations
          \item Fixed schmid and omega to compatible with all rotations
          \item Modified setCor and mediate so that they just read in the relevant variables when finding the covariance matrix.
          \item Added a simulate data option to mediate to handle mediation models based upon covariance matrices.
          \item Added a density option to error.bars.by so that transparency is easier.
          \item Cleaned up faBy to handle missing data
          \item Modified setCor so that variables can be specified by name or number.
          \item Modified scoreOverlap to handle the case of NAs in the correlation matrix. 
          \item Added the ability to find and print item by scale correlations (corrected for item overlap and scale reliability) in scoreOverlap.
          \item Added the ID number used for grouping to be the rowname for the output in cosinor (requested by Ashley Kendall)
          \item Added circadian.stats and circadian.F  to do basic circadian stats and group comparisons.
           \item Added circadian.sd  to work with circadian.mean to allow t-tests.
          \item Added circadian.reliability to find the split half reliability of phases found by cosinor or circadian.phase.  
          \item Renamed best.items and best.scales to bestItems and bestScale.  Change the call to be more consistent.
          \item Added two new features to pairs.panels.  One allows it to handle character variables (which will be translated to numeric levels) as requested by Richard Cotton.  Added the ability to specify the number of breaks in the histogram as requested by Philipp Thomas. Also added the ability to change plot character size independently of correlation print size (cex.cor).
          \item Did a drastic rewrite of the pairs.panels function so that is much cleaner (partly in response to a bug reported  by Valdar Tammik and a request by Richard Cotten).
        \item treat character as factor in pairs.panels. Requested by Richard Cotten.
        \item Modified dia.arrow and het.diagram to allow control over the gap and label sizes. (Requested by David Condon).
        \item Added a MAR parameter to cor.plot so long labels will fit
        \item Changed the output of the principal function to not give MLE chi square based fit statistics.  (Which really did not make sense.)
        \item Added the sim.correlation function to simulate sample correlation matrices from a population correlation matrix.
        \item Added invisible return from fa2latex and df2latex to allow for capture as a file to put into a latex document. (Requested by David Condon.)
        \item Did a major rewrite of fa.parallel to make the structure more clear and to allow for choosing mean or quantile values of the eigen value comparisons. 
        \item Modified fa so that it allows (without warning) for smcs in case nf > n.var/2.  This case will still report a df problem in terms of fit statistics.  It will still throw a warning if using an oblique transformation. 
        \item Modified splitHalf so the splits reported are keyed appropriately if some items need to be reversed.
        \item Added the cta.15 function to lock down cta as published by Revelle and Condon.  cta is now the development version, cta.15 is the version reported in R and C.
        \item The smc function has been modified for the case of correlation matrices with some missing values.  SMCs are found based upon the complete correlations, and alternative estimates are found for those with missing values.
        \item Added warning message to fa, principal, and iclust so that they stop if there are NA values in the correlation matrix.  
          }
          
   }
\subsection{Bugs Fixed}{

   \itemize{
           \item Fixed mat.regress bug by implementing it as part of setCor.
           \item Fixed faBy to handle the case of bad data more elegantly
           \item Fixed a bug in sim (seemingly introduced when I changed the way of finding simulated correlation matrices.  Bug also affected the other sim.functions)
           \item In factor.stats, sometimes the RMSEA limits do not include RMSEA.  Rather than reporting non-sensical values, just report NAs. 
            \item fixed bug in bestScales that would cause an error if items were missing in the dictionary.
            \item Fixed a bug in fa.plot where it would not handle data without a title.
            \item Fixed a long standing problem in biplot to allow multiple graphs in the same window, and then, discovered and fixed a problem with the margins getting progressively smaller.
            \item Fixed a bug (reported by Isabelle Rivals) in cohen.kappa (just for weighted kappa) when working with raw data with more than 9 categories.
            \item splitHalf failed for n > 32.  Fixed.  (Thanks to Tom Booth for having the data set that produced this error.)
         \item test for weird correlation matrices failed in the presence of NA fields in scoreOverlap (reported by Lorien Elleman).  Fixed.
            
            }
                       } 
  }
 
 

 \section{Changes in psych version 1.5.1 (2015-1-20)}{
  \subsection{Additions}{
          \itemize{
          \item Added the cor option to fa so that it can find tetrachoric, polychoric, or mixed correlations. Cleaned up the fa code a bit by using switch instead of convoluted if statements. 
          \item changed cor.smooth to detect any eigenvalue < 10^-12  This had been 10^-15
          \item Added the Bonett generalization to the Yule coefficient and added confidence intervals as well. (Suggested by Barry Dwight).
          \item Changed tetrachoric and polychoric to use sadmvn from the mnormt package instead of mvtnorm.  This seems to result in a speed up of a factor of 2!  For complete data, the results match that of lavCor (from lavaan) exactly (or at least to the 3 decimals that lavCor reports) but seem to be four times faster for dichotomous data and 20\% faster for polychorics than lavCor.
           \item Added a message to fa if a Heywood case is detected. Suggested by Sagnik Chakravarty.
           \item Added a covariance option to omega and to schmid.  Requested by Qingping He.
           \item Modified describe to add a fast option for larger data sets.  Added a discussion about how to speed up descriptions for very large data sets.
           \item Added mediate function to estimate mediation and moderation models.
            (requested by Dan Molden).
            \item Added mediate.diagram to show the results of mediation models.
            \item Added regression.diagram to show regression and set.cor models.
            \item Modified phi.demo to compare phis with tetrachorics and Yules.
            \item Modified fa.parallel to allow it to use tetrachoric, polychoric, or Yule coefficents (similar to the change in fa).
            \item Added a number of if(requireNamespaceGPArotation) GPArotation:: blah blah to make it more compatible with the new namespace checking and error complaints
          \item Modified scoreOverlap to allow for finding correlations from any non-square data matrix (had been limited to case of non-square where the data were outside a 0 1 range).
          \item Added documentation to alpha and scoreOverlap justifying the r.cor statistic. 
          }
   }
\subsection{Bugs Fixed}{

   \itemize{
   \item Corrected cor.ci to fix a capitalized rho (which led to a failure if not using keys. And, then more importantly, fixed it again so that it will work for overlapping scales as advertised. 
   \item Corrected r.test to use df = n-3 instead of n-2. Thanks to Bruno Ernande for reporting this. 
   \item Corrected the documentation to fa wrt oblique.scores to correctly represent what it does (I had had it backwards)  Thanks to Mark Seeto for reporting this.
   \item Added a message to principal if rotation is not correctly specified and defaulting to "none".  Suggested by Sagnik Chakravarty.
  \item Fixed describeData so that it doesn't choke on string variables.
  \item Modified the print.psych function so that irt information is printed for every unit rather than every .1 unit.  The data are still there in the plot.info object.
  \item Fixed cor.plot to properly add labels to the plot when plotting factor loadings.
 \item Fixed phi.demo to compare phis with tetrachorics and Yules.
 \item Fixed a print problem for fa.parallel
 \item Fixed a rare case in fa.stats for the case of singular matrices 
 \item Fixed the way missing is handled in fa so that it actually works! (problem found by Elizabeth Barrett-Cheetham)
 \item Modified error circles to pass just the x and y values to statsBy.
            }
                       } 
  }
 
 
  
 \section{Changes in psych version 1.4.8 (2014-08-10)}{
  \subsection{Additions}{
          \itemize{
          \item Added the ability to find polychoric correlations within groups in statsBy (requested by Aidan Wright).
          \item Modified cor.ci to allow for cluster overlap corrections. 
          \item Added het.diagram to allow for diagrams of heterarchical structures.
          \item Modified dia.arrow to allow for adjusting where the label appears.  Applied this fix to fa.diagram.
          \item Modified fa.sort so that it will sort the results of a principal components analysis (requested by Popov Oleg).
          \item Added the outlier function to find Mahalanobis distance measures for a data matrix and flag those cases that are unusual.
          \item Added draw.cor to show how bivariate densities estimates are used in finding tetrachoric correlations.
          \item Added faBy to allow for factor analysis by groups.
          \item Removed inactive calls to the polycor package
          }
          
   }
\subsection{Bugs Fixed}{

   \itemize{
    \item Fixed alpha so that it properly returns the average correlation if given a correlation matrix (reported by Franziska Zuber).
   \item A stylistic change in tetrachoric so that it is easier to read.
   \item Fixed two examples in tetrachoric that were impossible
   \item Changed a test condition that was not allowing  vector input to be processed in tetrachoric.
   \item Fixed a bug that would lead polychoric to break if there were no cell entries (bad data condition).  Missing cells are now given NA. (Reported by Elina Zaonegina.)
            }
                       } 
  }
 
 
  
 \section{Changes in psych version 1.4.6.20 (2014-06-20)}{
  \subsection{Additions}{
          \itemize{
          \item Added read.https function
          \item Added the ability to specify group by name or variable location to describeBy, error.bars.by, violinBy, mssd and rmssd. 
          \item Added the equamax rotation option in fa. (requested by Sagnik Chakravarty, with solution by Gunter Nickel)
          \item Added the ability to do factor.extensions for omega analyses. 
          \item Added some error checking in polychoric for case of bad data (requested by Simon Kiss)
          \item Added the ability to specify the base pch in error.bars.by (requested by Tham Tran)
          \item Modified tetrachoric and multi.cor to use correct = .5 (that is, to make the correction for continuity a variable rather than a logical to do or not do corrections.)  In addition, modified multi.cor to do polytomous by dichotomous variables using a generalization of polychoric (polydi).
        \item Modified plot.irt and plot.poly to work together better and to allow specifications of the xlim and ylim across plots.
        \item Added histBy to draw multiple histograms on a single plot
        \item Added scoreOverlap to adjust correlations between overlapping sets of items.
        \item Modified error.bars.by to draw semi-transarent catseyes and to allow for settings of pch, lty, and color for each variable.
        \item Modified fa2latex to boldface abs(loadings) > cut. 
        \item Added the varimin rotation from Suitbert Ertl to principal and fa.
          }
   }
\subsection{Bugs Fixed}{

   \itemize{
     \item fixed print.psych.vss to properly print the minimum eBIC value. (reported by Lorien Elleman)
      \item made x a matrix in mssd to fix a problem of finding mssd of a single variable (reported by Aidan Wright).
      \item fixed con2cat so that it will handle missing data  (correctly)
      \item Modified error.bars.by so that it will not break if there is only one case in a group.
            }
                       } 
  }
 
 
 \section{Changes in psych version 1.4.5 (2014-05-11)}{
  \subsection{Additions}{
          \itemize{
          \item Added con2cat to allow making discrete categories from continuous data.
          \item  Modified the cats eyes in error.bars so that colors can be specified (requested by Lauren Tindal).
          \item Modified set.cor so that calls by name or location work equally well.
          \item Added the option to change the size of the correlation numbers in cor.plot to reflect the probability values.  
          \item Added a default so that cor.ci automatically draws the scaled cor.plot (requested by David Condon).
          \item Changed the structure of the fa return when we have confidence intervals.  It has been forming another fa object, but this leads to confusion when sorting.
          \item Modified print.psych.fa.ci so that it handles the revised fa output.
          \item Modified vss so that it doesn't find factor scores on each iteration.
          \item Added the plot.cor.upperLowerCi function to plot the confidence boundaries for correlations (requested by David Condon)
          \item Modified fa.sort so that it will handle confidence intervals for loadings (requested by Jason French).
          \item Modified fa2latex to boldface significant loadings based upon the confidence intervals (requested by Jason French).
          \item Modified score.irt so that it will change the sign to match the direction of the keys (if supplied)
          \item modified error.bars to that x axis labels can be rotated to be vertical (requested by Greg Miller).
          }
   }
\subsection{Bugs Fixed}{

   \itemize{
         \item Fixed cor.ci so that it handles case of missing correlations (reported by David Condon)
         \item Modified plot.irt so that labels are applied for multiple factor solutions (reported by Jason French).
    \item Modified fa2latex so that it will not blank out h2 and u2 values for cut >0  (suggested by Daniel Zingaro).    
            }
                       } 
  }
 
  
  
\section{Changes in psych version 1.4.4 (2014-04-15)}{
  \subsection{Additions}{
          \itemize{
          \item A few tweaks to corr.p to be compatible with corr.test
          \item Improved statsBy so that it can properly handle two grouping variables.  statsBy also labels the columns in the within object.
          \item Added pairwise names for factor intercorrelations in print.psych.fa.ci.
          }
   }
\subsection{Bugs Fixed}{
   \itemize{
         \item Two bugs were introduced into corr.test in version 1.4.3. Both fixed. (reported by louis-charles vannier and Clemens Fell) 
         \item Fixed print.psych.fa so that it properly sorts the complexities (bug reported by Kai Horstman)
         \item Fixed fa so that if a non-available rotation is requested, a warning is issued. 
         \item Fixed alpha for case of 2 variables.
         \item Fixed the naming of correlations in cor.ci
         \item Fixed the empirical confidence intervals for alpha in alpha.
          
            }
                       } 
  }

  
\section{Changes in psych version 1.4.3 (2014-03-24)}{
  \subsection{Additions}{
          \itemize{
          \item Added best.scale to empirically combine the best items for a scale to predict  particular criteria.
          \item Changed the call to best.items to match fa.lookup. 
          \item Added a warning for cor.ci if some of the correlations are NA as would be the resulting scales.  Will still find the other correlations but be careful.
          \item Added empirical estimates of fit to the fa and fa.stats functions.  These are more robust to misfit for matrices that are not positive definite. (Requested by David Condon and Lorien Elleman).
          \item Added these empirical estimates of fit to vss.
          \item Added the nfactors function to do a call to vss and then do nice graphics
          \item Added fa.organize to hand sort factor output by factor number and by item order. 
          \item Added item.lookup to organize items by factor and then by item mean. 
          \item Added densityBy to show violin plots.  Will do this by groups.
          \item Added cats eyes to error.bars and error.bars.by. 
          \item Added normal theory confidence intervals to corr.test. (Suggested by Alexander Weiss)
           \item Added the ability to just resample and not simulate in fa.parallel.  (Requested by Ashley Kendall.) 
            \item Fixed fa.parallel and fa.parallel.poly for case of very low frequency data.  We now resample until we get a matrix with no NA values. (Problem reported by Eric Green). 
           \item Added a modification to error bars to print a dark circle at the mean. ( Suggested by Jaroslaw Arlet.) 
          \item Add significance and confidence intervals to partial.r (Suggested by Elizabeth Schubach).   
          }
   }
\subsection{Bugs Fixed}{
   \itemize{
         \item  cor.plot was incorrectly plotting the numbers by col instead of row.  Just a problem for asymmetric matrices. Reported by David Condon.
         \item corr.p was not printing correctly.  Reported by Robin Beaumount.
            }
                       } 
  }
  
  \section{Changes in psych version 1.4.2.1 (2014-02-03)}{
  
   \subsection{Bugs Fixed}{
   \itemize{
 \item Fixed print.psych.fa to cover several weird cases of no x$R2 or stats.df that were causing HDMD package to fail. 
  
   }
   } 
  }
  \section{Changes in psych version 1.4.2 (2014-02-01)}{
   \subsection{Additions}{
  \itemize{ 
    \item Added the epi data set and epi.dictionary  of items.
    \item Added bfi.dictionary to show the item contents of the bfi example.
    \item Added BIC, SABIC, RMSEA, and complexity for each factor model in VSS (vss) (requested by David Condon)
    \item added the alias of fa.congruence and fa.stats as calls to factor.congruence and factor.stats in a slow move to consistency
    \item Added fa.lookup to allow for sorted factor loadings with item contents if using a dictionary for the items.
    \item Modified print.psych.fa so that warnings about how factor score correlations are improper are suppressed (as is the printing of the improper correlations).
  }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
  \item defined global=TRUE as default in fa.parallel.poly (reported by  Koji E. Kosugi)
  \item changed if(max(R2 > 1) to if(any(max(R2 > 1)) in print.psych.fa (reported by David Condon)
  \item Fixed the se calculation in describe which had been incorrectly changed in version 1.4.1.  Thanks to Terry Jorgensen and others for reporting this.
  \item Fixed fa.sort so the that communalities and complexities are sorted as well
  
   }
   } 
  }
  
    \section{Changes in psych version 1.4.1 (2014-1-20)}{
   \subsection{Additions}{
\itemize{
   \item Substantial improvements in speed through the use of the parallel package and some coding improvements.  
   \item Added parallel processing (multicores) to polychoric, tetrachoric, and mixed.cor.  With 2 cores this saves 50\%, but this is not a linear function of the number of cores:  with 4 cores the savings seems to be 67\% and with 8 cores 75\%.  Requires the parallel package which seems to be supplied with core R. Apparently this benefit will not help  those running PCs which don't implement forking.
   \item Added parallel processing using multicores to fa when calculating confidence intervals.  Basically changed the interation loop to an lapply and then made that a mclapply. 
   \item Added parallel processing using multicores to fa.parallel, cor.ci and alpha (for the empirical bootstrap). 
   \item Yet another speed improvement by introducing tableF: a cut down/speeded up version of table.  This works only for tabulating two integer vectors, but by reducing error checking, is at least twice as fast.  This is used in particular in polychoric and tetrachoric, and therefore in mixed.cor as well.
   \item Changed fa so that confidence intervals are raw rather than fisherz transformed before averaging.  
    \item Modified ICLUST to increase speed by about 50\% by doing the smcs once instead of every iteration. This does not use multicores so the savings will be for PCs as well as OS X and Unix.  50\% of time is now spent doing matrix multiplication -- can we speed this up by not rescoring all clusters each time, but rather doing incremental changes?
    \item Minor tweaks to increase speed when creating lists and matrices.
    \item Added omega2latex and modified fa2latex to allow not printing small values.
    \item Added ICC2latex.
    \item Changed score.items to scoreItems in a continuing switch to camelCase. score.items will eventually be deprecated unless the entire score. functions are integrated somehow.
    \item Added option to sim.congeneric (and others) to do multiple simulations with same theta values. (Actually, it was there all along. Just set.seed(some value) before each run).
    \item A minor tweak to r.test to better report the call in the case of a correlated correlation. 
    \item A minor tweak to corr.test so that if all the sample sizes are the same, just report one number.
    \item Reduced the number of executable examples to speed up compilation.  The examples are just commented out.  Worth running for understanding.
    \item Added the Gleser data set for an example of generalizability theory.
    \item Added the ability to find scores automatically in omega. 
    \item Added the ability data set (just the iqitems data set scored for correct/incorrect).  This is more convenient for demonstrations.
    \item Added the check option in describe (turning it off increases speed drastically, but at the risk of not detecting logical or factor data).
    \item Added the describeData helper to do a quick pass to list the data types in a data.frame. 
    \item Rewrote the summary function to use switch rather than a series of ifs.
    \item Added a parameter to factor.scores to allow the data and a correlation matrix to both be passed for scoring.
    \item Added Structure as an output for principal (requested by Emeka Egbuna) 
    \item Added best.items and lookup as two helper functions.
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
      \item sim.cor.poly  -- fixed so that it actually works.
      \item Fixed alpha so that it will properly reverse key if given correlations. (Not sure when this stopped working.)
      \item Corrected the sign of at.rest in the TA scoring key for the msq.Rd file
      \item Corrected reverse.code to not add a constant to positive items (reported by Jian Jin)
       \item Perhaps finally fixed pairs.panels so it will not change options for graphics window. 
       \item Fixed polychoric so that it will not blow up if the number of response alternatives are not equal.  (Reported by Jeanette Lim )
       \item Fixed fa.poly so that the scores are calculated based upon the polychoric correlations rather than the Pearson correlations (based partly on trying to solve another problem reported by Jeanette Lim)
    \item Fixed scoreItems for the case of an unnamed keys vector  (reported by Sara Weston)
      }
   } 
  }
  
  
  
   \section{Changes in psych version 1.3.12 (2013-12-10)}{
   \subsection{Additions}{
\itemize{

  \item Added a brief wrapper function (corFiml) to call FIML procedures taken from lavaan. Inspired by some code from Joshua Wiley and with the help of Ashley Brown. The lavaan functions necessary for this are not exported from lavaan and hence have been partially moved (with adaptations) to psych.
   \item Completely modified guttman to use the splitHalf function.  This provides much more accurate estimates of the greatest lower bound.
   \item Added the splitHalf function to find all possible split halves of scales of up to 16 items, and to sample repeatedly random splits for more than 16 items.
   \item Modified plot.parallel.poly and fa.parallel.poly to allow choice in plotting between both, fa, and pc. (Matches the fa.parallel function).
   \item Added the weight option to fa.poly, polychoric, tetrachoric, and mixed cor. This allows for cases to be given unequal weights.  Requested by Fabricio Flalho. 
   \item Enhanced the documentation for irt.fa and plot.irt to explain when to use plot.irt vs. plot.poly (Requested by David Condon).
   \item Enhanced cor2latex with the help of Davide Morselli.  Now can find correlations directly and can also (if desired) show probability stars.
   \item Added standard errors and 95\% confidence boundaries to alpha and score.items (suggested by Doug Lawson)
  \item Minor tweaks to irt2latex and fa2latex.
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
       \item Corrected the documentation to fa to specify that it allows targetT and targetQ rotation.
       \item Corrected kaiser to return as class "psych" and "fa" so that solutions can be used in fa.diagram.  (Reported by Gouri Shankar Mishra)
    \item Corrected alpha so that it reports r.drop in the case of working from a correlation matrix.  (Reported by Nicolas Hubner)
      }
   } 
  }
 
  
 \section{Changes in psych version 1.3.10.12 (2013-10-12)}{
   \subsection{Additions}{
\itemize{
    \item A serious speedup to tetrachoric and polychoric was initiated with the help of Jason French.  The increase in speed is roughly 1- (nc-1)^2/nc^2 where nc is the number of categories.  Thus, for tetrachorics where nc=2, this is a 75\% reduction, whereas for polychorics of 6 item responses this is just a 30\% reduction.
    \item Added the ability to rotate the numbers in cor.plot by specifying srt. (Thanks to a suggestion on Stack OverFlow by shujaa).
    \item Added the use parameter to the fa function to allow for other than pairwise correlations.
    \item Added an invisible return from the print.psych.fa function to include the variances accounted for and the cumulative variance accounted for. (Requested by Eric Green).
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
      \item Fixed a bug in print.psych.fa so that it did not always work with the HDMD package. 
      \item Modified fa.parallel.poly so that the progress bar is not called during the tetrachorics or polychoric simulations. 
      \item print.psych.fa did not work for covariance input when adding the complexity option.
      }
   } 
  }
 
  
\section{Changes in psych version 1.3.10 (2013-10-03)}{
   \subsection{Additions}{
\itemize{
     \item Added Yule2phi and Yule2tetra to convert Yule Q coefficients to phis or tetrachorics.  Completely rewrote Yule.inv and Yule2phi.
     \item Added sim.poly.mat to generate polytomous or dichotomous items given a particular item structure.
     \item Modified describeBy to allow specification of digits in the matrix output.
     \item Modified multi.hist to allow one more control over graphic output. (Requested by Lars Carlsen).
     \item added iclust.sort to documentation of iclust.
     \item Added label option to fa2latex (requested by Robert Carlisie)
     \item Added sanitize.latex function to all the latex functions so that they properly escape underscore and ampersand.
     \item Added method option to scatter.hist to allow for other correlation methods
     \item Modified tetrachoric and polychoric so that (0,1) and (1,2) data can be mixed together.  tetrachoric and polychoric agree for dichotomous data (as they should)
     \item Added an option to the mixed.cor function to allow for spearman or kendall correlations.
     \item Added Hoffman's complexity index for the factor analyses output
     \item Modified make.keys to allow addressing items by name rather than location.
     \item Modified alpha to allow for specify items to reverse by name or location.
     \item Modified the msq data set Rd file to address by name rather than location
     \item Minor tweaks to fa.plot and cluster.plot to allow more graphic control
      \item modify structure  diagram so that the error arrows are to the left for lr printing 
      \item Modified fa.plot and cluster.plot to allow positioning and sizing of item labels for two dimensional plots.
      \item Made sure all usage and example lines are less than 90 characters.
      \item Added the ability to calculate factors scores in fa.poly. 
      \item Significant improvement in biplot.psych to allow much greater control over plotting.
      \item Added cor.ci to find bootstrapped confidence intervals for raw and synthetic correlations. 
      \item Added group reliability calculation for omega.
      \item return (invisibly) the eigen values of the factors and components from scree. 
      \item Added unit weighted multiple correlation and unit weighted set correlation to set.cor.
      \item Added test.all to allow for testing whether other packages work (or at least their examples) when psych is loaded.  (Can be used for any set of packages.)
      \item Added the ability to simulate as well as resample dichotomous data in fa.parallel.poly (requested by Balal Izanloo).
      \item Drop (with a warning) items that have no variance in alpha (requested by Eric Green).  This feature has also been added to score.items.
      \item Modified upperLower so that the rownames come from the lower diagonal matrix, and the column names from the upper diagonal matrix.
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item fixed statsBy so that it correctly reports the pooled values (reported by John Rauthman)
   \item corrected a problem with fa that was leading to errors when handling very non-positive matrices
   \item fixed a bug in Yule.inv that was leading to impossible values being reported
   \item fixed the way that biplot.psych returns the op$mfrow parameter
   \item applied the same fix to pairs.panels to perhaps fix the recurring problem
   \item Fixed fa.parallel to not break if just principal components output is requested
   \item Identified and fixed bug in mixed.cor for case of improper data.
   \item Identified and fixed? bug in mixed.cor so it will treat randomly mixed data
   \item Corrected corr.test and cor.p to properly pass the adjust option (reported by David Weisman and Russell Pierce)
   \item Corrected error.bars,  error.bars.by and errorCircles to use n-1 for df in the call to qt.  Modified the documentation to point out that we are using the t-distribution.  (Thanks to Trevor Dodds)
   \item Fixed fa.parallel so that it correctly prints out the legend for the case of fa="pc" or fa="fa" (reported by Andrew Hsiao and others)
   \item Corrected the way confidence intervals were found in fa.poly
   \item Correctly name the scored variables in case of impute = 'none'  (reported by David Condon
   \item Complains, rather than blows up when doing irt.fa and plot.poly for Heywood cases.
   \item Added column names to factor scores.
   \item Corrected the way that data are randomized in the fa.parallel.poly function so that each variable retains (roughly) the original difficulty.  Also did this for fa.parallel.  Reported by Balal Izanloo.
   \item Fixed (?) progressBar so that it does not freeze the R.Gui for Mac.
      }
   } 
  }
  
    \section{Changes in psych version 1.3.2 (2013-2-28)}{
   \subsection{Additions}{
\itemize{
  \item Cleaned up help files so that lines don't over run the page in the pdf version. (Suggested  by  Jennie Miller).  Still seems to be a problem.
  \item Fixed factor.stats so that it does not complain when finding scores for principal
  \item Fixed fa2latex so that the apa option correctly puts in the last cr
  \item Added ECV to omega to give an estimate of unidimensionality
  \item Add a parameter to set.cor and mat.regress to allow for square data matrices (suggested by Thomas Richardson).
  \item Changed the default in principal to find scores (scores=TRUE).  This makes it compatible with fa.
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item Fixed principal so that it labels the components as rotated or transformed (as documented and previously implemented.  Somehow this feature went away.
   \item Fixed fa so that specifying SMC=FALSE will replace the diagonals with 1s instead of 0s.  (Seems to have been an error introduced when the SMC= a vector option was introduced)
   \item Minor bug fix to sim.omega so that it will not choke on badly structured sem commands.
   }
   } 
  }
  
    \section{Changes in psych version 1.2.12 (2013-1-20)}{
   \subsection{Additions}{
\itemize{
  \item Added fa2irt to convert factor analysis output to Item Response Theory type output.  (Basically doing what irt.fa already does, but from a separate factor analysis.
  \item Added fa.extend to make factor extension easier to do.
  \item Added an overall goodness of fit tests for fa.extension applied to the extension variables. 
  \item Cleaned up factor.stats to make it do fm="minchi" more readily.
  \item Added two trivial helper functions r2d and d2r to convert from correlations to effect sizes and back.  
 \item added the von Neumann test of successive differences (mssd and rmssd). This is useful for studying within subject changes in mood. 
 \item Changed the help files for test.psych, irt.fa, iqitems to dontrun the examples (cutting down time to compile and test the functions) 
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item fix the output in the example for fa.  Fixed by noticing that:  
   \item in fa, fm="pa" did not return labels for the factors.
   \item in statsBy, fixed a problem if the by returned NULL values for some group values 
   \item Finally fixed bug in describeBy for the case of NULL categories for the by variable. (Reported by Nipa Phojanamongkolkij).
   \item fixed bug in smc for case of missing values of diag(smc)
   \item added an error message to cor.smooth for the case of NA eigen values
   \item Changed the random seed in overview.rnw for the example of omegaSem to 17 (from 42).  The previous seed was generating a bad omega solution which in turn caused sem to fail. 
   \item fixed the call function in ICLUST to properly report the parameters being called. 
       
   }
   } 
  }
  
   \section{Changes in psych version 1.2.11 (2012-11-22)}{
   \subsection{Additions}{
\itemize{
  \item Added the rangeCorrection function to correct for range restriction.
  \item Added a new factor method (minchi) to the fa function. This weights residual correlations by the pairwise sample size.  The minimum weighted residual is then found.  This will give OLS (minres) solutions for the case of equal sample sizes, but slightly better (weighted) fits for unequal sample sizes.  Most appropriate for the Massively Missing Completely at Random structure of SAPA data.
 \item Added a measure of the Kaiser-Meyer-Olkin index of factoring adequacy
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item None yet
       
   }
   } 
  }
  
  \section{Changes in psych version 1.2.8 (2012-8-25)}{
   \subsection{Additions}{
\itemize{
 \item Updated the overview vignette
 \item Added the ability to do target rotations (TargetQ) in omega.
  \item Improved documentation of fa to explain how oblique SS are found.
  \item A better set of items is used for the iq example (iqitems).
  \item add CVE estimate to fa (see Reise 2010) (had already done this for omega).
  \item Changed ICLUST.sort so that it can sort the loadings of principal (requested by Gudmundur Arnkelsson and then print them with the number of digits requested in the print command. 
  \item Modified score.irt so that subjects who miss all items or pass all items are given an estimate based upon the (product) of the difficulty of the items they miss (pass) and then adjusted based upon half the quantile difference from 0 (if they miss all items) and 100 (if they pass all items).
  \item Modified sim.omega to allow for specifying a general factor.  This allows for tests of not just the bias in the case of no general factor, but also the ability to detect a general factor.  Also modified it to include calls to omegaSem.
   \item modified iclust.diagram so that cluster names can be specified rather than all start with C1 ... Cn  (requested by Michael Kubovy)
   \item Slightly improved the documentation for r.test so it is clear which correlation is which. 
   \item Modified iclust so that the fit statistic is based upon the off-diagonal elements unless otherwise specified.  Use diagonal =TRUE to get fits matching previous analyses. 
   \item Modified the print.psych.iclust function to print out the Root Mean Square Residual correlation.  (It was previously reported in iclust output, but not printed.)
    }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
       \item  fixed a bug in score.items, such that if the number of subjects is equal to the number of items, no scores were returned.  Reported by Jeromy Anglim. 
    \item Modified factor.stats so that rare condition of an exact fit in omega does not lead to an error.
    \item Fixed plot.irt so that item labels are correct
    \item Modified omegaSem to pass n.obs to sem 
    \item Fixed df2latex so that it will on text variables as well as numeric variables   
   }
   } 
  }
  
  \section{Changes in psych version 1.2.7 (2012-7-31)}{
   \subsection{Additions}{
\itemize{
  \item Improved statsBy to find within and between group correlations.
  \item Added a data set, withinBetween, to graphically show the issue of multilevel correlations.
  \item Added a simulation function to generate multilevel data (sim.multilevel)
  \item Added a function (irt.responses) to plot responses as a function of the latent score for multiple choice alternatives.
  \item Modified progressBar so that it only shows dots when using the console, but not when using a text file for output (i.e., with Sweave).
    }
  
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
       \item fixed plot.poly and plot.irt so that multiple scales for one factor can be plotted.
   }
   } 
  }
  
\section{Changes in psych version 1.2.6 (2012-6-20)}{
   \subsection{Additions}{
\itemize{
   \item Slight modification to cor.plot to allow for better control of multiple plots on the same page. 
   \item Added the ability to put values into the cor.plot output (numbers=TRUE)
   \item Added a function (lowerUpper) to combine two symmetric matrices and output one as the above diagonal entries, and the other as the below diagonal entries of a square matrix. 
   \item Added a function (topBottom) to act like headTail but to do it without ellipses. 
   \item In a gradual switch to camelCase, changed the name of headtail to headTail, and describe.by to describeBy. Warning messages are issued about the change.
   \item Added a function, statsBy, to find summary statistics (means, sample sizes, standard deviations) by a grouping variable.  Similar to describeBy but somewhat easier to use. Also will report (as an option) the pooled within group correlations. 
   \item Added a function to find sample size weighted correlations, cor.wt.  Useful for SAPA types of analysis. 
   \item Modified superMatrix to take list input so that more than two matrices can be combined at once (suggested by David Condon).
   \item Added errorCircles, a greatly improved version of error.crosses. 
   \item Added the option to specify starting communalities in the fa function (requested by David Gosar). 
    }
  
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
\item cor.plot was actually switching row and colnames (but since it is mainly used on symmetric matrices, this was not a problem).  Fixed.
\item principal failed when handling missing data in data.frame. Fixed. (reported by Neil Stewart)

   }
   } 
  }
  
   \section{Changes in psych version 1.2.4 (2012-4-30)}{
   \subsection{Additions}{
\itemize{
 \item (Note that 1.2.3 was not released but was replaced with 1.2.4)
 \item fixed ICLUST so that it converts covar matrices to correlations. 
 \item Modified pairs.panels so that the method of correlation can be specified (suggested by Carsten Dormann)
 \item added error values to the structure.diagram/lavaan diagram as an option (suggested by José Luis Cañadas )
 \item Changed the oblique.scores option in fa to be FALSE (use the structure the matrix) following a request by Niels Waller.
   \item Fixed the size of the boxes in dia.rect so that omega.diagram and  fa.diagram provide reasonable size boxes for long names (requested by Erich Studerus)
    \item modified output of corr.test so that it announces whether or not it is adjusting the probability values for multiple tests.
  \item added the ability to export dot.plot commands without requiring Rgraphviz. (requested by Erich Studerus).  Although just implemented for fa.graph, omega.diagram functions can be exported using fa.graph applied to the schmid$sl object from omega.
  \item Added 3 options to the skew and kurtosis functions, and thus to the describe and describe.by functions as well.  (Suggested by Bruce Dudek).
  \item Added the ability to plot general factors (ala omega) in the fa.diagram function.
  \item Added the function lowerCor to find correlations (with pairwise deletion as a default) and print out the lowerMat of the results.
    }
  
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
\item A documentation error in r.test was fixed (reported by Nicholas S. Holtzman).  The example of Steiger case B was incorrectly ordered and thus led to incorrect results. Specifying by name (rather than location) is now recommended.
 \item In fa, the rotation was not returned, fixed.  (reported by Niels Waller)
 \item predict.psych would not work for a single case (reported by Jonathan Williams).  Fixed.  Also made the documentation a bit clearer to explain the way the factor scores are standardized.
 \item By adding a global-local parameter to mixed.cor it now seems to work on those data sets with badly distributed polytomous data. (Reported by Eric Smith and David Condon.)
   }
   } 
  }
  
  \section{Changes in psych version 1.2.1 (2012-1-31)}{
   \subsection{Additions}{
  \itemize{
    \item Modified scrub to be a bit easier to use (suggested by Josh Wilt)
   \item Added a check in mixed.cor so that if the data are incorrect, announce it first, rather than waiting until late in the process. 
   \item Added a progress indicator to particularly slow functions (e.g. tetrachoric, polychoric, biserial).  This will show up when using these functions in other functions (such as irt.fa or mixed.cor). 
   \item Modified cluster.cor so that in the case of correlations that are NA, it will not find smcs of the raw correlation matrix.  In addition, it will impute scale level correlations based upon the average between scale correlation (previously it was reporting an NA).  Requested by David Condon.
   \item Added the helper function lowerMat to print the lower submatrix.  Added this as an option to the print.psych function.
   \item Modified mixed.cor so that it will automatically (if desired) find the Pearson, polychoric, and tetrachoric correlation matrices and then reorganize the matrix back to the original form.
   \item Minor modifications to tetrachoric and polychoric to give slightly more helpful error messages in the case of missing data and corrections for continuity.
   \item Minor modifications to summary to give cleaner summary stats for fa and irt.fa analyses.
   \item Added a residual and plot.residuals function to plot either qq plots of the residuals, or a cor.plot of the residuals.
  }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item Fixed a few references that were working but doing partial matching in print.psych, test.psych, pairs.panels (e.g, in print.psych digit=digits was changed to digits=digits, test.psych nf was changed to nfactors, col was changed to col.smooth in pairs.panels). This had been flagged by linux checking as a note about "partial matching" for a long time. Finally figured out what it meant.
 \item corrected biplot.psych to properly take the xlim and ylim parameters (reported by Andreas M. Brandmaier)
 \item Correction to tetrachoric (and related functions) to return NA in the case of no cases for x or y.  (Reported by David Condon)
 \item Fixed fa so that the score.oblique option actually works. (Reported by Jessica Jaynes).
   }
   } 
  }
  
  \section{Changes in psych version 1.1.12 (2011-12-30)}{
   \subsection{Additions}{
  \itemize{ 
 
  \item Modified scrub to be more general.
  \item Added factor structure as an object in the fa function and modified the print.psych.fa function to note that it is the pattern matrix being reported. 
  \item Modified the ICLUST output so that the eigenvalues reflect the independent contribution of each cluster. 
  \item Added a comment and an option to ICLUST.sort about the order in which clusters are sorted (suggested by Gudmundur Arnkelsson).
  \item Added the rug option to pairs.panels.  This will, by default draw a rug underneath the histograms.
  \item Added a covar option to principal to find principal components from covariance matrices as well as correlation matrices.
  \item Cleaned up the objects returned from fa.parallel.poly to more closely match those from fa.parallel. 
  \item Added the ability to find and report residual correlations in set.cor. Minor formatting corrections to set.cor and mat.regress.
  
  }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
  \item  Fixed a bug in fa such that the oblique.scores option did not work. 
  \item  fa.parallel.poly was ignoring the fm parameter and was not printing correctly.
   }
   } 
  }


\section{Changes in psych version 1.1.1122 (2011-11-22)}{
   \subsection{Additions}{
  \itemize{ 
  \item Added various rotation options to principal to match those in fa.
  \item Added "components" as an option to factor score to  score principal components using just the component loadings.  This is most appropriate when not rotating the components.
  \item Added the Harman.5 (socio-demographic) data set to allow comparisons with SAS. 
  }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
  \item The way component scores were found had changed from "regression" to "tenBerge" without being documented.  Changed the documentation and added the method of scoring as an option.  Problem reported by Alexander Weiss.  
   }
   } 
  }
  
\section{Changes in psych version 1.1.1111 (2011-11-11)}{
  \subsection{Additions}{
  \itemize{ 
  \item This is basically a rerelease of version 1.1.10 trying to solve a problem with 32 bit machines and one test that fails. Originally call 1.11.01 but that one still failed the tests.
  \item Added ... as an option in multi.hist (following a suggestion by Rui Barradas)
  \item Added the all=FALSE option to test.psych.  This turns off one test to avoid a problem in the testing on Solaris 32 bit machines.
  }
  }
  
   \subsection{Bugs Fixed}{
   \itemize{
   \item factor.scores and factor.stats were failing in tests for Linux operating systems, but not Macs or PCs.  Added some protection against complex eigen values.  
   \item fixed problem in irt.scores reported by David Condon 
   \item fixed irt.fa so it will properly plot for polytomous items
   }
   }
  
  }
\section{Changes in psych version 1.1.10 (2011-10-15)}{
  \subsection{Additions}{
  \itemize{ 
  \item Started to modify all calls to sd and mean to use apply to respond to their deprecation for data.frames and matrices
  \item Changed the release numbering system to reflect year and month of release.  
  \item Added a parcels function to form item parcels of size 2 or size 3.
  \item Added a jitter option to the factor.plot function.
  \item Added 3 more factor scoring options to the factor.scores function and changed the default scoring option in fa to be the tenBerge
  \item Added the kaiser function to do kaiser normalization.
  \item Added the df2latex function to make LaTeX tables.
    \item Added plot.circular to draw radar and spider plots
  	\item Added a short function to create dummy codes (dummy.code)
    \item Added a score.irt function to find IRT based scores. 
    \item Added a table of information by attribute level to be (silently) produced  in the plot(irt.fa) function.
    \item Added bifactor and biquartimin as  rotation options to fa (based on the Jennrich and Bentler 2011 papers).
    \item Implemented an improvement to print.psych function to use switch.  (Following a suggestion by Joshua Wiley ). This does not change the functionality, but makes the code easier to debug and to change.
     \item Added an option to alpha  to automatically flip items if they seem to be negatively correlated with total score.  (Suggested by Jeremy Miles).
     \item Serious modification to cor.plot to allow for colorRamp data.  Makes much prettier correlation plots. (Suggested by David Condon and Joshua Wilt).
 	 \item Modified sim and sim.simplex to create State Trait Auto Regressive simplex structures (suggested by Deepika Anand).
     \item Added a correct option to irt.fa (passes correct to tetrachoric).
     \item Added the ability for omega to be rerun on the same correlation matrix found by previous omega runs.  This speeds up analyses of large matrices but particularly that of tetrachoric/polychoric matrices.
     \item Modified headtail so that it will not choke on mixed numeric and string data
     \item Added a smoothing option to the tetachoric correlation function to smooth the resulting matrix if it is not positive definite.
     \item Added cor.smooth to do a principal components based smoothing for correlations.
     \item Added global=TRUE option to polychoric (and tetrachoric) correlations. If global=FALSE, each correlation is found using the pairwise taus.  This seems to match John Fox's polycor function.  If global=TRUE, the taus are the datawise values. This will differ from polycor in the case of a great deal of missing data.  Somewhat faster and perhaps more appropriate given that we are trying to find a global solution. 
     \item Added a correction for multiple tests to the p values in the \code{\link{corr.test}} function and added a new function to just report probabilities \code{\link{corr.p}}
     }
     }
   \subsection{Bugs Fixed}{
   \itemize{
   \item Fixed a very subtle bug in score.items for the case of impute="none" where some subjects have no non-missing data. This affected the estimate of the average number of items (num.ob.item) per scale. Reported by Ben Schalet.
    \item Fixed bug in factor.stats that gave much too narrow confidence intervals for RMSEA (Thanks to Rick Zinbarg and Ashley Kendall for pointing out the problem).
    \item revised factor extension to properly handle oblique solutions
    \item fa now reports the call correctly -- since introduction of iterations it had reported the wrong call
    \item Fixed mixed.cor so that it can handle several special cases.
    \item Perhaps finally fixed pairs.panels so it leaves us with the original parameter settings
    \item Fixed a problem in print.psych such that mat.regress output would not print.  (Reported by Ben Schalet.)
    \item Fixed plot.poly so that it correctly plots the ICC results, particularly for negatively keyed items.
    \item Fixed fa so that the covar option works.  (It had been killed when iterations were introduced.)
    \item Modified fa, fa.irt, factor.stats, factor.scores so that they handle bad data more gracefully.  
   }
  }
}
\section{Changes in psych version 1.0.98 (2011-06-10)}{
  \subsection{Additions}{
  \itemize{
 	 \item Improvements to set.cor to report the canonical correlations and their chi squares.  Also added a plot function to set.cor so that it will plot the eigen values of the canonical correllations.
 	 \item Added the cushny data set to show the original drug data from student.
     }
  }
   \subsection{Bugs Fixed}{
   \itemize{
    \item Resolved why the denomiator df in set.cor does not precisely match the Cohen example.  This seems to be because Systat is doing an unbiased estimator and is thus multiplying by (u+v)/v.
   }
  }
  }  
\section{Changes in psych version 1.0.97 (2011-05-15)}{
  \subsection{Additions}{
  \itemize{
  \item Added a polychoric and tetrachoric option to fa.parallel
  \item Added a keys option to plot.psych  (plot.poly and plot.irt) to allow for plotting information functions for selected items while retaining the factor loadings from the complete set. (Requested by Ben Schalet.)
  \item Added a summary of the graphic output for irt.fa that includes the average information for each item as well as where the item is most informative. (Suggested by David Condon.)
  \item Integrated the interactions between fa, fa.poly, irt.fa, fa.diagram, plot, etc. to make commands more consistent.
  \item added a factor analysis for tetrachoric or polychoric correlations (fa.poly) that will work without doing an irt analysis using irt.fa.
  \item Added bootstrapped confidence intervals for loadings and correlations in factor  analysis (fa), for reliability estimates in omega (omega) and fa.poly.(Originally requested by Steve Miller and Renee Engeln-Maddox for polychoric correlations, extended to the omega case.)
   \item Modified fa.diagram to include graphic output for fa.extension.
  \item Added Cohen's set correlation to the mat.regress function. (Requested by Amanda Uliaszek.)
  \item Changed the order of the parameters in the mat.regress function to be more consistent with the y~x notation of most regression functions.
  \item  Added an oblique.scores option to principal.  This means that if oblique rotations are done (not the default) then the scores from principal will be oblique as well.  
   }
  }
  \subsection{Bugs Fixed}{
   \itemize{
    \item None yet
   }
  }
  }
  \section{Changes in psych version 1.0.96 (2011-04-04)}{
  \subsection{Additions}{
  \itemize{
   \item Factor extension (fa.extension) now can extend an omega as well as a normal factor analysis.
    \item Modified fa so that the factor scores are found for the oblique factors rather than the orthogonal factors. This now produces factor scores that have roughly the same correlations as do the factors.  Factor score statistics remain the same. This leads to a different set of factor scores than factanal finds, for it reports the factor scores for the orthogonal factors. 
   
    \item Modified response.frequencies to incorporate a very nice suggestion by Joshua Wiley to identify unique item responses that are not necessarily integers.  
   }
  }
  \subsection{Bugs Fixed}{
   \itemize{
      \item Modified fa.extension to correctly find extended oblique loadings.
      \item check added to omega for bizarre case of 1 factor extracted through PC.  (This should not be done, for it makes no sense, but nonetheless, it was leading to omega_h > omega_t.) A warning for this condition is now issued and omega_h = omega_t.  Reported by Alison Lewis.
   }
  }
  }
\section{Changes in psych version 1.0.95 (2011-03-30)}{
  \subsection{Additions}{
 \itemize{
 \item Fixed News so that it works as a NEWS.rd file
 \item Added an example to msq
 \item Added a function to perform factor extension (fa.extension)
 \item Added the Dwyer and Gorsuch data sets as examples of fa.extension.
 \item Added lavaan.diagram to the set of diagram functions.  Modified to work with lavaan 0.4-7
 \item Added scatter.hist to draw a scatter plot and associated histograms and densities.  
\item Modified score.items so that it reports the number of missing responses for each person for each scale.  It had previously reported the total number of missing responses but did not break this down by scale.  Requested by Ryne Sherman.  Changed the documentation to reflect that missing is calculated.
\item Modified error.bars.by so that it can not draw lines (lines=FALSE) if desired. (Requested by Ryne Sherman.)
\item Added to  error.bars.Rd to describe how to supply means and standard errrors. 
\item Made various data files available as separate rather than collated. (e.g., Thurstone, Bechtoldt,Holzinger) in the bifactor data set (they remain there as well). (Requested by Michael Friendly.) 
\item Changed VSS.scree and scree to provide a few more options.
\item Cleaned up circ.tests to be more compatible with rest of psych.
\item Clean up output from schmid to more match other functions.
\item Used tools::compactPDF on the vignettes to make them smaller.  Also switched to using png instead of pdf for some of the graphics in the vignettes. This reduced the size drastically.
  }
 }
\subsection{Bugs Fixed}{ 
\itemize{
	\item fixed error.bars.by so that it draws the alpha level instead of 2 alpha level error bars.
	\item fixed fa for special case of 3 x 3 matrix with correlations of exactly .5 which would lead to a non-conforming array problem
 	\item fixed partial.r to not round output.  For rounded output, the print.psych function defaults to 2 digits (reported by David Freedman)     
 	\item Finally fixed the output of print.psych.fa so that it labels sorted factors independent of cut (Reported by Reinhold Hatzinger )
   }
}
}
\section{Changes in psych version 1.0.94 (2011-01-01)}{
  \subsection{Additions}{
    \itemize{
      \item Eliminated references to polychor in Yule2poly, 
    }
  }
  \subsection{Bugs Fixed }{
    \itemize{
      \item fixed read.clipboard.upper so that it will read labels
      \item fixed  mat.regress so that it can work with a single predictor
    }
  }
}
\section{Changes in psych version 1.0.93 (2010-12-22)}{
  \subsection{Additions}{
    \itemize{
      \item Added mixed.cor to do mixtures of Pearson, polychoric and tetrachoric correlations
      \item Added legends to error.bars.by  bar graph
      \item Modified score.items so it will work on correlation matrices as well as raw data.
      \item Improved the plot.irt and plot.poly functions to plot irt output.  Called by plot.psych or generic plot call.
      \item Added a trivial little function, bi.bars to do paired histograms
      \item Modified irt.fa to allow for multiple factors
      \item Modified scrub to be a general recoding function
      \item Modified error.bars.by to allow for ... parameters to be passed into axis
      \item Modified diagram so it will dispatch a number of diagram functions (fa, prinicpal, omega, iclust, lavaan).
      \item Added a biplot.psych function to do biplots of fa or principal results.
      \item Added an unbiased estimate of kurtosis in the kurtosi function.
      \item Added a predict function to fa and principal (predict.fa and predict.principal, both called from predict.psych) 
      \item Added lavaan.diagram to draw the output from a cfa or sem from the lavaan package.
      \item Added a function to calculate Mardia's test for multivariate normality
      \item Added lengends and improved the examples for pairs.panels.by
      \item Removed the "short" option in score.items
      \item Added the ability to score scales with greatly missing data (for SAPA). Modified the impute option to include = "none"
      \item Added the term KR20 and KR21 to documentation of alpha
      \item Modified pairs.panels so that with the cor option it can draw regressions and give correlations.
      \item Modified the documentation for error.crosses to give a better example.
      \item Added the ability to read rownumbers (variable names?) in first column of read.clipboard.lower and read.clipboard.upper
      \item Tweaked the zlim default for cor.plot to be c(-1,1) rather than c(0,1)
      \item Minor adjustments to Yule and phi.demo to call tetrachoric instead of polycor, thus making the package work with fewer dependencies.
      \item Cleaned up the fa summary output 
    }
  }
  \subsection{Bugs Fixed }{
    \itemize{
      \item Fixed dia.curved.arrow to draw one headed curved arrows (as documented)
      \item Fixed a problem with fa.print option sort  -- Although giving the correct communalities and uniquenesses in the unsorted option, when sorted, it was not sorting h2 or u2. 
    }
  }
}
\section{Changes in psych version 1.0.92 (2010-09-22)}{
  \subsection{Additions}{
    \itemize{
      \item Added omega total from sem to the omegaSem function.
    }
  }
  \subsection{Bugs Fixed }{
    \itemize{
      \item error.bars.by was ignoring the user supplied ylim.  (reported by Helena Chui)  Fixed.
      \item Was drawing incorrect  sl solution in omega.graph (reported by Mark Difford).fixed.
      \item omega.Rd and schmid.Rd incorrectly referred to fm=ml as fm=mle. Fixed.
    }
  }
}
\section{Changes in psych version 1.0.91 (2010-09-15)}{
  \subsection{Additions}{
    \itemize{
      \item Added iclust and vss as an alternative names to ICLUST and vss to be consistent with most naming conventions.
      \item Added the simple utility scrub to do data cleaning.
      \item Added biserial and polyserial to do biserial/polyserial correlations (not to be confused with point biserial)
      \item Modified score.multiple.choice so that it handles missing data without using imputation
      \item Changed the bfi data set to include more subjects and to correctly define the Openness scale.
      \item Modified score.multiple.choice and score.items to report response frequencies for each item (frequencies based upon number of non-missing responses).
      \item Added the burt data set of 11 emotional variables (from Burt, 1915) 
      \item Added draw.tetra to draw tetrachoric correlations for fixed tau values (teaching demo)
      \item Added plot.irt and plot.poly to the plot.psych function. These have options to draw the item characteristic function, the item information function, and the test information.
      \item Added irt.fa to do factor analysis of dichotomous or discrete items by first forming a tetrachoric or polychoric correlation matrix. Then convert the results to IRT form. 
      \item Added tetrachoric and polychoric functions to find tetrachoric/polychoric correlations as well as item discrimination parameters.
      \item Added omegaSem and omegaFromSem to calculate omega from a confirmatory factor model using John Fox's sem package.
      \item Added (with permission) Bond's Logical Operations Test (BLOT) data set.
    }
  }
  \subsection{Bugs Fixed}{
    \itemize{
      \item sim.irt was not properly handling vectors of item discrimination or guessing parameters.  Fixed.
      \item Minor problem in fa.stats that would lead to an error message if chisquare was NaN. 
      \item Minor bug in reverse.code for case of 1 variable (why one would want to use 1 the function for one variable is unclear.)
      \item tetrachoric would not apply the correction for continuity when given a table input but would when given normal data.  Fixed.
    }
  }
}
\section{Changes in psych version 1.0.90 (2010-07-07)}{
  \subsection{Additions}{
    \itemize{
      \item Added a few parameters to fa.parallel to a) set the y label and b) to show or not show a legend. Useful for multipanel displays.
      \item Minor improvements to fa.diagram to allow for input of factor loadings and intercorrelations from other functions.
      \item Added sim.omega to simulate multifactorial hierarchical structures as a test (and demonstration) of omega.
      \item Minor changes to the parameter call list for sim.minor to be compatible with sim.omega.
    }
  }
  \subsection{Bugs Fixed}{
    \itemize{
      \item Fixed a problem in ICLUST where it would sometimes not stop at the right number of clusters for n.clus = 1
      \item Fixed problem in omega.diagram where it would sometimes use the incorrect line type for hierarchical (non-Schmid-Leiman) diagrams.
      \item Fixed bug in schmid where it would not rotate exactly orthogonal factors and find exactly omega = 0.
      \item Added a warning message that oblique rotation does not work, and does a cluster based rotation instead in the case of exactly orthogonal factors.  This is just a problem for artificial data sets.
      \item History (Both of these are probably due to a problem in GPArotation which has since been fixed.)
    }
  }
}
\section{Changes in psych version 1.0.89 (2010-06-21)}{
  \subsection{Additions}{
    \itemize{
      \item Rearranged the order of parameters for fa so that it is easier to call.
      \item Added various sem stats to fa output (e.g. RMSEA, BIC, rms, crms).  These are also provided for omega output.
      \item Add fit statistics to omega for g solution only.  
      \item Added a measure of general factor adequacy in Omega.  This is just the percent of common variance that is general factor variance for each item. High values and low variances suggest a more meaningful estimate than lower average values or higher variances.
      \item Various clean up of output of ICLUST and iclust.diagram.  Added color option for positive and negative loadings.
      \item Changed ICC to work on complete data (i.e., using na.omit) as the default (following a question) by Ross Culloch
      \item Changed pairs.panels to allow for color choice of histogram (requested by Elaine Kuo) 
      \item Changed describe to handle numeric but annotated vectors (suggested by Soeren Vogel)
      \item Clarified documentation of cohen.kappa and allowed for  using explicitly non-numerical categories  (as suggested by Peter Ehlers  and Scot McNary)
      \item Increased the usefulness of error.bars to allow for input of x values, y values, and confidence interval. Also added the ability to use 1 standard deviation.   
      \item Minor change to print.psych.fa to round before using formatting. 
      \item Removed the cut <- min(cut,max(abs(load))/2)  following a request by  Reinhold Hatzinger to be consisent with factanal
      \item Added an option to omega to allow for analysis of data sets from just the factor loadings and correlation matrices. 
      \item Add a scree function to replace VSS.scree
    }
  }
  \subsection{Bugs Fixed}{
    \itemize{
      \item Fixed a bug in pairs.panels for the case of not smoothing but with data ellipses (reported by Hirayuki Sato)
      \item Fixed a serious bug in omega for the case of non-positive manifold items (e.g., personality items). The sign of the group factors was not correctly being set which would lead to incorrect estimates of the multiple R2.
      \item Fixed bug in ICLUST.diagram  where it would draw on top of other figures in rare cases.
      \item Fix bug in ICLUST for the path coefficients -- in the case of negative loadings, some of these were much too small.
      \item Correctly color the paths in omega.diagram. 
      \item Fixed print.psych.fa to correctly showing item numbers for sorted output. 
      \item Corrected tetrachor so it would not inappropriately claim that some cells had no data (this did not affect the correlations, just gave an inappropriate warning).
    }
  }
}
\section{Changes in psych version 1.0.88 (2010-04-24)}{
  \subsection{Additions}{
    \itemize{
      \item Added within option for error.bars and error.bars.by to allow for within subject error estimates.
      \item Reformatted this file (NEWS) so that the command  (e.g.,) news(query=Version > "1.0.85",package="psych")  provides nice information.
      \item Added more detail to the overview vignette to discuss how to find omega.
      \item Added the block.random function to block randomize for experimental designs.
    }
  }
  \subsection{Bugs Fixed}{
    \itemize{
      \item Corrected schmid (and thus, omega) so that it finds orthogonal factors before rotating them obliquely.  This corrected an error introduced in version 1.0.86 when the default rotation for fa was switched to be oblimin. 
      \item correct=FALSE option in tetrachor actually works
    }
  }
}
\section{Changes in psych version 1.0.87 (2010-04-04)}{
  \subsection{Bugs fixed}{
    \itemize{
      \item error.bars (and error.bars.by) would not properly draw < 3 variables
    }
  }
}
\section{Changes in psych version 1.0.86 (2010-03-26)}{
  \subsection{Additions}{
    \itemize{
      \item Added logit, logistic and logistic.grm functions to help teach about IRT.
      \item Added the ability to factor analyze covariance matrices (with resulting loadings of covariances rather than correlations) (suggested by Andreas Moeltner)
      \item Added two new functions to estimate the greatest lower bound (glb.algebraic, written by Andreas Moeltner) and glb.fa.  
      \item Added read.clipboard.fwf to allow reading of fixed width files from clipboard. (Originally this required adding a patch to the read.fwf function but that was subsequentally fixed.)
      \item Minor adjustment to ICLUST.cluster so that it will produce fewer clusters (if desired) than it thinks are appropriate.  That is, if n.clus is less than the appropriate solution, a warning is issued, but n.clus clusters are found.
      \item Changed the default rotation in fa to be oblimin.  (Subsequently discovered that this introduced a bug into schmid and therefore omega.)
      \item Added the glb.communality function to calculate the greatest lower bound by using factor communality estimates (based upon correspondece with Andreas Moeltner, although his algorithm (glb.algebraic, which is now included) which uses the Rcsdp provides slightly different estimates).
      \item added names to communalities in principal (requested by Gumundur Arnkelsson).
      \item Minor change to headtail
      \item Added the sim.rasch function to simulate 1 parameter IRT Rasch models.
      \item Added the data sets bock and income. bock is the source of the lsat data,income is US family income from 2008.
      \item Seriously modified the estimation of Cohen's Kappa in the wkappa function and added a new function: cohen.kappa to calculate kappa from raw data or from similarity matrices.  Also calculates the variances following Fleiss, Cohen, and Blashfield, and then find the confidence limits.
      \item Modified the sim.minor function to simulate correlation matrices with nfact major factors and nvar/2 minor factors with larger number of variables.   
    }
  }
  \subsection{Bugs fixed}{
    \itemize{
      \item Fixed print.psych.fa to give correct communalities for sorted factors (had been not sorting the communalities, although it had the factor loadings).
      \item Minor change to comorbidity to clean up output (using print.psych)
      \item Fixed guttman to correctly estimate lambda 4 (error pointed out by Andreas Moeltner). 
    }
  }
}
\section{Changes in psych version 1.0.85 (2009-12-20)}{
  \subsection{Additions}{
    \itemize{
      \item Modified the output from fa.parallel to print summary statistics.  Also added an option to use smcs as communality estimates.
      \item Added the sim.minor function to generate major and minor factor structures. 
      \item Modified fa to use first derivatives based upon the model rather than just empirically derived.  This results in an impressive speed improvement.
      \item Continued to improve the dia.x functions.  Labeled the entire set of functions diagram (for easier search).
    }
  }
}
\section{Changes in psych version 1.0.84 (2009-11-30)}{
  \subsection{Additions}{
    \itemize{
      \item Improved documentation for the dia functions to show the power of structure diagrams
      \item Improved structure.diagram to allow graphs to go left to right (default) or bottom to top (which means causal arrows go left to right)
      \item Added the affect data set which includes data from two experimental studies of affect.
      \item Added some features from pairs to allow group coloring in pairs.panels
      \item Modified factor.parallel to allow for other factoring models (including minres)
      \item Modified fa to give eigenvalues of the correlation matrix, and of the common factor space.
      \item Modified pairs.panels so it can plot even if the correlations are NA
      \item Added a legend and improved the output of cor.plot.
      \item Having learned how to use strwidth, have cleaned up the dia.rect, fa.diagram, structure.diagram, and iclust.diagram functions.
      \item Changed the way fa.parallel handles correlation matrices if the number of subjects is not specified. Rather than issuing a warning and proceeding as if n.obs = nvars, it now assumes n.obs =100.
      \item Improved documentation for fa to explain minimum correlation of factor score estimates. 
    }
  }
  \subsection{Bugs fixed}{
    \itemize{
      \item Fixed a problem with printing of the principal (components) results
      \item Fixed bug in the print.psych.vss function that returned the wrong value (although identifying the correct number) for the  Velicer MAP criterion. (Reported by Maike Luhmann).
    }
  }
}
\section{Changes in psych version 1.0.83 (2009-10-26)}{
  \subsection{Additions}{
    \itemize{
      \item Added Suggests Rgraphviz to DESCRIPTION file to get around CRAN test for 2.10 (as I should have done according to documentation for packages).  Removed all tests of functions which require RGraphviz for 2.9.2 because Rgraphviz does not work on SnowLeopard. 
    }
  }
}
\section{Changes in psych version 1.0.82 (2009-10-26)}{
  \subsection{Additions}{
    \itemize{
      \item Improved the output for mat.regress to allow print() and summary().    
      \item Corrected problem in describe.by to properly identify the matrix output 
    }
  }
  
\subsection{Bugs fixed}{
    \itemize{
      \item Corrected bug to fa for case of oblique and negatively correlated factors (reported by Erich Studerus).
      \item Minor improvements to the dia.x functions 
      \item Fixed the formatting of the news file to follow the appropriate format
      \item Removed the old supplementary  manual from the docs folder to make for a cleaner installation
    }
  }
}
\section{Changes in psych version 1.0.81 (2009-10-04)}{
  \subsection{Additions}{
    \itemize{
      \item Improved the documentation for the dia.X functions and made some of the calls simpler.  
    }
  }
}
\section{Changes in psych version 1.0.80 (2009-09-30)}{
  \subsection{Additions}{
    \itemize{
      \item Added the ability to draw "diagrams" to replace the functions that required Rgraphviz.  These are path diagrams with rectangles for observed variables and ellipses for latent variables.  A set of graphic functions for drawing diagrams includes dia.ellipse, dia.rect, dia.arrow, dia.curve and dia.self.  This allows the  function omega and ICLUST to draw structural diagrams without using Rgraphviz.
      \item The documentation for these new functions is a bit less than desirable and the dia primitives will be modified slightly for the next release.
    }
  }
}
\section{Changes in psych version 1.0.79 (2009-08-25)}{
  \subsection{Additions}{
    \itemize{
      \item added the Schmid data set which includes the original Schmid-Leiman correlation matrix as well as data from Chen, West, and Sousa (2006).
      \item modified geometric.mean and harmonic.mean to allow for missing data.
      \item Cleaned up describe.by so that it can handle matrix output of multiple grouping variables and then print correctly.
    }
  }
}
\section{Changes in psych version 1.0.78 (2009-07-28)}{
  \subsection{Additions}{
    \itemize{
      \item Modified factor.stats to allow for statistics even if the matrix is very singular (i.e., N var >> n.obs).
    }
  }
  \subsection{Bugs fixed}{
    \itemize{
      \item Corrected bug to ICLUST introduced in version 74 that can, in some conditions, produce negative betas. 
    }
  }
}
\section{Changes in psych version 1.0.77}{
  \subsection{Bugs fixed}{
    \itemize{
      \item Fixed an error in printing communalities for rotated factor solutions reported by Tamaki Hattori. Also resolved a problem of extra lines appearing in error.bars.  Minor revision to polar. 
    }
  }
}
\section{Changes in psych version 1.0.76}{
  \subsection{Bugs fixed}{
    \itemize{
      \item Finally resolved the problem of not passing the CRAN tests for Mac (even though developed on a Mac, the test package assumes no other packages).
    }
  }
}
\section{Changes in psych version 1.0.75 (2009-07-01)}{
  \subsection{Additions}{
    \itemize{
      \item Reinstituted reporting communalities and uniquenesses for principal components and for factor analysis.  This feature had been dropped sometime in the past and reported missing by Ista Zahn.
      \item Added two new data sets: Harman.Holzinger and Harman.Burt.  The former is used by Peter Bentler as an example of alternative methods for estimating   reliability, the latter is a nice example of what happens if the correlation matrix is singular.  smc estimates are inappropriate in this case and need to be checked.
    }
  }
}
\section{Changes in psych version 1.0.74 (2009-06-25)}{
  \subsection{Additions}{
    \itemize{
      \item Added a weighting option to ICLUST.  Weighted beta finds the average between cluster correlation and takes the ratio of the  n ^2 * average between cluster correlation to the total variance of the pooled clusters as a measure of the general factor.  That is, Unweighted beta calculates beta based upon the correlation between  two clusters, corrected for test length using the Spearman-Brown prophecy formala, while weighted beta finds the average interitem correlation between the items  within two clusters and then finds beta from this.  That is, for two clusters A and B of size N and M with between average correlation rb, weighted beta is (N+M)^2 rb/(Va +Vb + 2Cab).  Raw (unweighted) beta is 2rab/(1+rab) where rab = Cab/sqrt(VaVb).   Weighted beta seems a more appropriate estimate and is now the default.  Unweighted beta is still available for consistency with prior versions. (Unfortunately, in doing this, a bug was introduced that could produce negative betas.  Fixed in Version 78).
      \item Modified the fa function to include maximimum likelihood factor analysis.
    }
  }
}
\section{Changes in psych version 1.0.73 (2009-06-08)}{
  \subsection{Additions}{
    \itemize{
      \item Added gls fit option to fa
      \item Added mat.sort to sort correlation matrices by factor loadings.  
      \item Revised the overview vignette to make more readable.
      \item Fixed (I hope) the documentation error that has been preventing being loaded onto CRAN for Mac.
    }
  }
}
\section{Changes in psych version 1.0.72 (2009-06-02)}{
  \subsection{Additions}{
    \itemize{
      \item Added factor stats to omega
    }
  }
  \subsection{Bugs fixed}{
    \itemize{
      \item Minor fix to print.psych.omega to correct printing error introduced in .71
    }
  }
}
\section{Changes in psych version 1.0.71 (2009-06-01)}{
  \subsection{Additions}{
    \itemize{
      \item Combined principal axis, unweighted least squares (minres) and weighted least squares into one combined function (fa). Eventually the three other functions (factor.pa,factor.wls, and factor.minres) will be phased out. Added more rotation and transformation options (basically by making calls to the GPArotation package).
      \item factor.stats now reports the factor weights matrix for factor scores.
      \item A new factor analysis function factor.wls will give weighted least squares (wls).
      \item Omega will now give an estimate for  1  factor and a message about how there are alternatives for 2 factors.
    }
  }
  \subsection{Bugs fixed}{
    \itemize{
      \item Fixed a bug in print.psych.omega so that it will now report the item numbers correctly when sorting.
      \item Fixed call in phi.demo so that it checks if the polycor package is installed.  This was causing problems in the Mac version on CRAN.
    }
  }
}
\section{Changes in psych version 1.0.70 (2009-05-25)}{
  \subsection{Additions}{
    \itemize{
      \item Added factor.stats function to report a variety of statistics for factors or components.  In particular, added measures of factorial adequacy.  factor.stats is now called by the factor.pa, factor.minres, and principal, so it is easier to adjust all three of these functions.
      \item Added a new rotation option to target.rot -- if keys are not specified, it will rotate to a cluster solution.
      \item minor tweak to sim.hierarchical to make it consistent with the Jensen and Weng paper
      \item added to omega to calculate omege_infinity
      \item corrected bug in principal for case of singular matrices (reported by Gudmundur Arnkelsson) 
      \item corrected bug in print.psych so that it now sorts by factor loadings correctly 
    }
  }
}
\section{Changes in psych version 1.0.69 (2009-04-25)}{
  \subsection{Additions}{
    \itemize{
      \item added cor.plot to graphically display correlation structures
      \item modified cosinor to do regression as well as optimization for fits
      \item minor correction to ICLUST to catch non-invertible matrices
    }
  }
}
\section{Changes in psych version 1.0.68 (2009-04-15)}{
  \subsection{Additions}{
    \itemize{
      \item Added method="minres" to do minimal residual (ULS) factor analysis to the factor.pa function. 
      \item Added the target.rot function to do targeted rotation.
      \item Added the sim.anova function to simulate 3 way ANOVA or linear models.
      \item Minor cleanups of code in other functions
    }
  }
}
\section{Changes in psych version 1.0.67 (2009-03-15)}{
  \subsection{Additions}{
    \itemize{
      \item Have included the vignettes in the package
      \item Serious modifications to mat.regress to allow for raw data and covariances to be used.
      \item Added corrections for item overlap to use estimated communalities of items to alpha, cluster.cor, etc.
      \item Added estimates of G6+  (Modified Guttman 6) reliabililty to alpha, score.items
    }
  }
}
\section{Changes in psych version 1.0.66 (2009-02-15)}{
  \subsection{Additions}{
    \itemize{
      \item Introduced two package vignettes (overview and psych_for_sem)
      \item minor modification to ICLUST with respect to labeling
      \item addition to factor.congruence to allow for comparing omega solutions with factor solutions
      \item modified describe to allow for descriptions of categorical variables.
    }
  }
}
\section{Changes in psych version 1.0.64 (2009-02-01)}{
  \subsection{Additions}{
    \itemize{
      \item Added the function alpha to find Cronbach's alpha and Guttman's Lambda 6 for total scales as well as with single item deleted.
      \item Minor enhancements to the structure.graph and structure.sem functions. Further refinements to the psych_for_sem.pdf tutorial.  
    }
  }
}
\section{Changes in psych version 1.0.63 (2009-01-15)}{
  \subsection{Additions}{
    \itemize{
      \item Added structure.graph and structure.sem to create graphical output and pre-sem commands for sem.
      \item Modified omega.graph to return sem commands for running the sem function from John Fox.
      \item Added Promax to report factor intercorrelations for promax rotations.
      \item bug fix in VSS and omega to allow for promax rotations.
      \item correction to winsor so that it does not sort the vectors of the input data.frame.
      \item bug fix in principal (for problem of oblique rotations)
      \item continued improvements in the print.psych and summary.psych functions 
      \item cleaned up sim.congeneric to reduce the amount of output (now handled through print.psych)
      \item added super.matrix function (to combine two matrices -- useful for constructing keys and for doing examples in structure.graph)
      \item Improvements to structure graph.
    }
  }
}
\section{Changes in psych version 1.0.62 (2008-12-31)}{
  \subsection{Additions}{
    \itemize{
      \item added the structure.graph function
      \item added circadian functions 
      \item renamed some functions to make the index order easier to follow.
    }
  }
}
\section{Changes in psych version 1.0.58 (2008-09-15)}{
  \subsection{Additions}{
    \itemize{
      \item Introduced the guttman function to estimate the 6 Guttman (1945) estimates (as well as a few others).
    }
  }
}
\section{Changes in psych version 1.0.54 (2008-08-15)}{
  \subsection{Additions}{
    \itemize{
      \item Added print.psych and summary.psych generic functions to clean up the output of many of the functions. 
    }
  }
}
\section{Changes in psych version 1.0.50 (2008-06-30)}{
  \subsection{Additions}{
    \itemize{
      \item Introduced several new functions:
      \item headtail   (combines head and tail functions to produce the first N and last M rows of a matrix or dataframe)
      \item error.bars and 
      \item error.bars.by     plot means with error bars by a grouping variable
      \item omega revised to allow for negatively keyed items.  Detects items that should be reversed.
    }
  }
}

\section{Changes in psych version 1.0.42 (2008-03-24)}{
  \subsection{Additions}{
    \itemize{
      \item A relatively stable release.
      \item Passed the tests for R 2.6.2 
    }
  }
}

\section{Changes in psych version 1.0.40 (2008-02-15)}{
  \subsection{Additions}{
    \itemize{
      \item score.multiple.choice   provides scores and item statistics for multiple choice items.
      \item circ.sim modified to be more general item simulations
      \item circ.simulation
      \item item.sim
      \item polar converts two dimensional factor loadings to polar coordinates.
    }
  }
}
\section{Changes in psych version 1.0.33 (2007-10-11)}{
  \subsection{Additions}{
    \itemize{
      \item A relatively stable release. 
    }
  }
}

\section{Changes in psych version 1.0.30 (2007-09-09)}{
  \subsection{Additions}{
    \itemize{
      \item A relatively stable release. 
    }
  }
}

\section{Changes in psych version 1.0.27 (2007-07-31)}{
  \subsection{Additions}{
    \itemize{
      \item Another upgrade.
      \item Passed tests for R 2.5
    }
  }
}

\section{Changes in psych version 1.0.17 (2007-05-06)}{
  \subsection{Additions}{
    \itemize{
      \item The first release to CRAN.  Prior versions had been tested at NU.
      \item Included pairs.panels, describe, read.clipboard, iclust, vss, principal.

    }
  }
}

\section{Changes in psych version 1.0-14 (2006-09-11)}{
  \subsection{Additions}{
    \itemize{
      \item Another release
    }
  }
}


\section{Changes in psych version 1.0-9 (2006-08-26)}{
  \subsection{Additions}{
    \itemize{
      \item Another release
    }
  }
}

\section{Changes in psych version 1.0-1 (2005-05-19)}{
  \subsection{Additions}{
    \itemize{
      \item The first package version on the personality-project.org repository.
      \item included some of the functions previously in the "useful R" source file.
      \item worked with R 2.1.0
    }
  }
}