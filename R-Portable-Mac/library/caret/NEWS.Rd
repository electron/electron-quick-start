\name{NEWS}
\title{News for Package \pkg{caret}}
\newcommand{\cpkg}{\href{https://CRAN.R-project.org/package=#1}{\pkg{#1}}}
\newcommand{\issue}{\href{https://github.com/topepo/caret/issues/#1}{(issue #1)}}

\section{Changes in version 6.0-79}{
  \itemize{
    \item \code{keras} and \code{mxnet} models have better initialization of parameters \href{https://github.com/topepo/caret/pull/765/files}{pr 765}
    \item The range preprocessing method can scale the data to an arbitrary range. Thanks to Sergey Korop.
    \item The spatial sign transformation will now operation on all non-missing predictors. Thanks to Markus Peter Auer \issue{789}.
    \item A variety of small changes were made to work with the new version of the \cpkg{gam} package \issue{828}.
    \item The package vignette was changed to HTML.
    \item A big was fixed for computing variable importance scores with the various PLS methods \issue{848}.
    \item Fixed a \code{drop = FALSE} bug that occurred when computing class probabilities \issue{849}.
    \item An issue with predicting probabilities with \code{multinom} and one observation was fixed \issue{827}.
    \item A bug in the threshold calculation for choosing the number of PCA components was resolved \issue{825}.
    \item Models \code{mlpML} and \code{mlpWeightDecayML} now ignore layers with zero units. For example, if the number of layers was specified to be \code{c(5, 0, 3)} a warning is issued and the architecture is converted to \code{c(5, 3)} \issue{829}.
    \item \code{svmLinearWeights2} and \code{svmLinear3} may have chosen the incorrect SVM loss function. This was found by Dirk Neumann \issue{826}
    \item \cpkg{bnclassify} models \code{awtan} and \code{awnb} were updated since they previously used deprecated functions. All \cpkg{bnclassify} models now require version 0.3.3 of that package or greater \issue{815}.
    \item \code{confusionMatrix.default} not requires \code{data} and \code{reference} to be factors and will throw an error otherwise. Previously, the vectors were converted to factors but this resulted in too many bug reports and misuse.
    \item \code{xyplot.resample} did not pass the dots to the underlying plot function \issue{853}.
  }
}

\section{Changes in version 6.0-78}{
  \itemize{
    \item A number of changes were made to the underlying model code to repair problems caused by the previous version. In essence, unless the modeling package was formally loaded, the model code would fail in some cases.  In the vast majority of cases, \code{train} will not load the package (but will load the namespace). There are some exceptions where this is not possible, including \code{bam}, \code{earth}, \code{gam}, \code{gamLoess}, \code{gamSpline}, \code{logicBag}, \code{ORFlog}, \code{ORFpls}, \code{ORFridge}, \code{ORFsvm}, \code{plsRglm}, \code{RSimca}, \code{rrlda}, \code{spikeslab}, and others. These are noted in \code{?models} and in the model code itself. The regression tests now catch these issues.
    \item The option to control the minimum node size to models \code{ranger} and \code{Rborist} was added by \code{hadjipantelis} \issue{732}.
    \item The rule-based model \code{GFS.GCCL} was removed from the model library.
    \item A bug was fixed affecting models using the \pkg{sparsediscrim} package (i.e. \code{dda} and \code{rlda}) where the class probability values were reversed. \issue{761}.
    \item The \code{keras} models now clear the session prior to each model fit to avoid problems. Also, on the last fit, the model is serialized so that it can be used between sessions. The \code{predict} code will automatically undo this encoding so that the user does not have to manually intervene.
    \item A bug in \code{twoClassSummary} was fixed that prevents failure when the class level includes "y" \issue{770}.
    \item The \code{preProcess} function can now scale variables to a range where the user can set the high and low values \issue{730}. Thanks to Sergey Korop.
    \item Erwan Le Pennec fixed some issues when \code{train} was run using some parallel processing backends (e.g. \code{doFuture} and \code{doAzureParallel}) \issue{748}.
    \item Waleed Muhanna found and fixed a bug in \code{twoClassSim} when irrelevant variables were generated. \issue{744}.
    \item \code{hadjipantelis} added the DART model (aka "Dropouts meet Multiple Additive Regression Trees") with the model code \code{xgbDART } \issue{742}.
    \item Vadim Khotilovich updated \code{predict.dummyVars} to run faster with large datasets with many factors \issue{727}.
    \item \code{spatialSign} now has the option of removing missing data prior to computing the norm \issue{789}.
    \item The various \cpkg{earth} models have been updated to work with recent versions of that package, including multi-class \code{glm} models \issue{779}.
    }
}

\section{Changes in version 6.0-77}{
  \itemize{
    \item Two neural network models (containing up to three hidden layers) using \code{mxnet} were added; \code{mxnet} (optimiser: SGD) and \code{mxnetAdam} (optimiser: ADAM).
    \item A new method was added for \code{train} so that \cpkg{recipes} can be used to specify the model terms and preprocessing. Alexis Sardá provided a great deal of help converting the bootstrap optimism code to the new workflows. A new chapter was added to the package website related to recipes.
    \item The Yeo-Johnson transformation parameter estimation code was rewritten and not longer requires the \code{car} package.
    \item The leave-one-out cross-validation workflow for \code{train} has been harmonized with the other resampling methods in terms of fault tolerance and prediction trimming.
    \item \code{train} now uses different random numbers to make resamples. Previously, setting the seed prior to calling \code{train} should result in getting the same resamples. However, if \code{train} loaded or imported a namespace from another package, and that startup process used random numbers, it could lead to different random numbers being used. See \issue{452} for details. Now, \code{train} gets a separate (and more reproducible) seed that will be used to generate the resamples. However, this may effect random number reproducibility between this version and previous versions. Otherwise, this change should increase the reproducibility of results.
    \item Erwan Le Pennec conducted the herculean task of modifying all of the model code to call by namespace (instead of fully loading each required package). This should reduce naming conflicts \issue{701}.
    \item MAE was added as output metric for regression tasks through \code{postResample} and \code{defaultSummary} by hadjipantelis. The function is now exposed to the users. \issue{657}.
    \item More average precision/recall statistics were added to \code{multiClassSummary} \issue{697}.
    \item The package website code was updated to use version 4 of the D3 JS library and now uses \cpkg{heatmaply} to make the interactive heatmap.
    \item Added a \code{ggplot} method for lift objects (and fixed a bug in the \code{lattice} version of the code) for \issue{656}.
    \item Vadim Khotilovich made a change to speed up \code{predict.dummyVars} \issue{727}.
    \item The model code for \code{ordinalNet} was updated for recent changes to that package.
    \item \code{oblique.tree}  was removed from the model library.
    \item The default grid generation for rotation forest models now provides better values of \code{K}.
    \item The parameter ranges for \code{AdaBag} and \code{AdaBoost.M1} were changed; the number of iterations in the default grids have been lowered.
    \item Switched to non-formula interface in ranger. Also, another tuning parameter was added to ranger (\code{splitrule}) that can be used to change the splitting procedure and includes extremely randomized trees. This requires version 0.8.0 of the \cpkg{ranger} package. \issue{581}
    \item A simple "null model" was added. For classification, it predictors using the most prevalent level and, for regression, fits an intercept only model. \issue{694}
    \item A function \code{thresholder} was added to analyze the resample results for two class problems to choose an appropriate probability cutoff a la \url{https://topepo.github.io/caret/using-your-own-model-in-train.html#Illustration5} \issue{224}.
    \item Two neural network models (containing a single hidden layers) using \code{tensorflow}/\code{keras} were added.  \code{mlpKerasDecay} uses standard weight decay while \code{mlpKerasDropout} uses dropout for regularization. Both use RMSProp optimizer and have a lot of tuning parameters. Two additional models, \code{mlpKerasDecayCost} and \code{mlpKerasDropoutCost}, are classification only and perform cost-sensitive learning. Note that these models will not run in parallel using \cpkg{caret}'s parallelism and also will not give reproducible results from run-to-run (see \url{https://github.com/rstudio/keras/issues/42}).
    \item The range for one parameter (\code{gamma}) was modified in the \code{mlpSGD} model code.
    \item A bug in classification models with all missing predictions was fixed (found by andzandz11). \issue{684}
    \item A bug preventing preprocessing to work properly when the preprocessing transformations are related to individual columns only fixed by Mateusz Kobos in \issue{679}.
    \item A prediction bug in \code{glm.nb} that was found by jpclemens0 was fixed \issue{688}.
    \item A bug was fixed in Self-Organizing Maps via \code{xyf} for regression models.
    \item A bug was fixed in \code{rpartCost} related to how the tuning parameter grid was processed.
    \item A bug in negative-binomial GLM models (found by jpclemens0)  was fixed \issue{688}.
    \item In \code{trainControl}, if \code{repeats} is used on methods other than \code{"repeatedcv"} or \code{"adaptive_cv"}, a warning is issued. Also, for method other than these two, a new default (\code{NA}) is given to \code{repeats}. \issue{720}.
    \item \code{rfFuncs} now computes importance on the first and last model fit. \issue{723}
  }
}


\section{Changes in version 6.0-76}{
	\itemize{
		\item Monotone multi-layer perceptron neural network models from the \cpkg{monmlp} package were added \issue{489}.
		\item A new resampling function (\code{groupKFold}) was added \issue{540}.
		\item The bootstrap optimism estimate was added by Alexis Sarda \issue{544}.
		\item Bugs in \code{glm}, \code{glm.nb}, and \code{lm} variable importance methods that occur when a single variable is in the model \issue{543}.
		\item A bug in \code{filterVarImp} was fixed where the ROC curve AUC could be much less than 0.50 because the directionality of the predictor was not taken into account. This will artificially increase the importance of some non-informative predictors. However, the bug might report the AUC for an important predictor to be 0.20 instead of 0.80 \issue{565}.
		\item \code{multiClassSummary} now reports the average F score \issue{566}.
		\item The \code{RMSE} and \code{R2} are now (re)exposed to the users \issue{563}.
		\item A \cpkg{caret} bug was discovered by Jiebiao Wang where \code{glmboost}, \code{gamboost}, and \code{blackboost} models incorrectly reported the class probabilities \issue{560}.
		\item Training data weights support was added to \code{xgbTree} model by schistyakov.
		\item Regularized logistic regression through Liblinear (\code{LiblineaR::LiblineaR}) using L1 or  L2 regularization were added by hadjipantelis.
		\item A bug related to the ordering of axes labels in the heatmap plot of training results was fixed by Mateusz Dziedzic in \issue{620}.
		\item A variable importance method for model averaged neural networks was added.
		\item More logic was added so that the \code{predict} method behaves well when a variable is subtracted from a model formula from \issue{574}.
		\item More documentation was added for the \code{class2ind} function (\issue{592}).
		\item Fixed the formatting of the design matrices in the \code{dummyVars} man file.
		\item A note was added to \code{?trainControl} about using custom resampling methods (\issue{584}).
		\item A bug was fixed related to SMOTE and ROSE sampling with one predictor (\issue{612}).
		\item Due to changes in the \cpkg{kohonen} package, the \code{bdk} model is no longer available and the code behind the \code{xyf} model has changes substantially (including the tuning parameters). Also, when using \code{xyf}, a check is conducted to make sure that a recent version of the \cpkg{kohonen} package is being used.
		\item Changes to \code{xgbTree} and \code{xgbLinear} to help with sparse matrix inputs for \issue{593}. Sparse matrices are not allowed when preprocessing or subsampling are used.
		\item Several PLS models were using the classical orthogonal scores algorithm when discriminant analysis was conducted (despite using \code{simpls}, \code{widekernelpls}, or \code{kernelpls}). Now, the PLSDA model estimation method is consistent with the method requested (\issue{610}).
		\item Added Multi-Step Adaptive MCP-Net (\code{method = "msaenet"}) for \issue{561}.
		\item The variable importance score for linear regression was modified so that missing values in the coefficients are converted to zero.
		\item In \code{train}, \code{x} is now required to have column names.

	}
}

\section{Changes in version 6.0-73}{
	\itemize{
		\item Negative binomial generalized linear models (\code{MASS:::glm.nb}) were added \issue{476}
		\item \code{mnLogLoss} now returns a named vector (\issue{514}, bug found by Jay Qi)
		\item A bunch of method/class related bugs induced by the previous version were fixed.
	}
}

\section{Changes in version 6.0-72}{
	\itemize{
		\item The inverse hyperbolic sine transformation was added to \code{preProcess} \issue{56}
		\item Tyler Hunt moved the ROC code from the \cpkg{pROC} package to the \cpkg{ModelMetrics} package which should make the computations more efficient \issue{482}.
		\item \code{train} does a better job of respecting the original format of the input data \issue{474}
		\item A bug in \code{bdk} and \code{xyf} models was fixed where the appropriate number of parameter combinations are tested during random search.
		\item A bug in \code{rfe} was fixed related to neural networks found by david-machinelearning \issue{485}
		\item Neural networks via stochastic gradient descent (\code{method = "mlpSGD"}) was adapted for classification and a variable importance calculation was added.
		\item \href{http://www.h2o.ai/}{h2o} versions of glmnet and gradient boosting machines were added with methods \code{"glmnet\_h2o"} and \code{"gbm\_h2o"}. These methods are not currently optimized.  \issue{283}
		\item The fuzzy rule-based models (\code{WM}, \code{SLAVE}, \code{SBC}, \code{HYFIS}, \code{GFS.THRIFT}, \code{GFS.LT.RS}, \code{GFS.GCCL}, \code{GFS.FR.MOGUL}, \code{FS.HGD}, \code{FRBCS.W}, \code{FRBCS.CHI}, \code{FIR.DM}, \code{FH.GBML}, \code{DENFIS}, and \code{ANFIS}) were modified so that the user can pass in the predictor ranges using the \code{range.data} argument to those functions. \issue{498}
		\item A variable importance method was added for boosted generalized linear models \issue{493}
		\item \code{preProcess} now has an option to filter out highly correlated predictors.
		\item \code{trainControl} now has additional options to modify the parameters of near-zero variance and correlation filters. See the \code{preProcOptions} argument.
		\item The \code{rotationForest} and \code{rotationForestCp} methods were revised to evaluate only \emph{feasible} values of the parameter \code{K} (the number of variable subsets). The underlying \code{rotationForest} function reduces this parameter until values of \code{K} divides evenly into the number of parameters.
		\item The \code{skip} option from \code{createTimeSlices} was added to \code{trainControl} \issue{491}
		\item \code{xgb.train}'s option \code{subsample} was added to the \code{xgbTree} model \issue{464}
	}
}

\section{Changes in version 6.0-71}{
	\itemize{
		\item Precision, recall, and F measure functions were added along with one called \code{prSummary} that is analogous to \code{twoClassSummary}. Also, \code{confusionMatrix} gains an argument called \code{mode} that dictates what output is shown.
		\item schistyakov added additional tuning parameters to the robust linear model code \issue{454}. Also for \code{rlm} and \code{lm} schistyakov added the ability to tune over the intercept/no intercept model.
		\item Generalized additive models for very large datasets (\code{bam} in \cpkg{mgcv}) was added \issue{453}
		\item Two more linear SVM models were added from the \cpkg{LiblineaR} package with model codes \code{svmLinear3} and \code{svmLinearWeights2} (\issue{441})
		\item The \code{tau} parameter was added to all of the least square SVM models (\issue{415})
		\item A new data set (called \code{scat}) on animal droppings was added.
		\item A significant bug was fixed where the internals of how R creates a model matrix was ignoring \code{na.action} when the default was set to \code{na.fail} \issue{461}. This means that \code{train} will now immediately fail if there are any missing data. To use imputation, use \code{na.action = na.pass} and the imputation method of your choice in the \code{preProcess} argument. Also, a warning is issued if the user asks for imputation but uses the formula method and excludes missing data in \code{na.action}

	}
}

\section{Changes in version 6.0-70}{
	\itemize{
		\item Based on a comment by Alexis Sarda, \code{method = "ctree2"} does not fix \code{mincriterion = 0} and tunes over this parameter. For a fixed depth, \code{mincriterion} can further prune the tree \issue{409}.
		\item A bug in KNN imputation was fixed (found by saviola777) that occurred when a factor predictor was in the data set \issue{404}.
		\item Infrastructure changes were made so that \code{train} tries harder to respect the original class of the outcome. For example, if an ordered factor is used as the outcome with a modeling function that treats is as an unordered factor, the model still produces an ordered factor during prediction.
		\item The \code{ranger} code now allows for case weights \issue{414}.
		\item \code{twoClassSim} now has an option to compute ordered factors.
		\item High-dimensional regularized discriminant analysis and, regularized linear discriminant analysis, and several variants of diagonal discriminant analysis  from the \cpkg{sparsediscrim} package were added (\code{method = "hdrda"}, \code{method = "rlda"}, and \code{method = "dda"}, respectively) \issue{313}.
		\item A neural network regression model optimized by stochastic gradient decent from the \cpkg{FCNN4R} package was added. The model code is \code{mlpSGD}.
		\item Several models for ordinal outcomes were added: \code{rpartScore} (from the \cpkg{rpartScore} package), \code{ordinalNet} (\cpkg{ordinalNet}), \code{vglmAdjCat} (\cpkg{VGAM}), \code{vglmContRatio} (\cpkg{VGAM}), and \code{vglmCumulative} (\cpkg{VGAM}). Note that, for models that load \cpkg{VGAM}, there is a conflict such that the \code{predictors} class code from \cpkg{caret} is masked. To use that method, you can use \code{caret:::predictors.train()} instead of \code{predictors()}.
		\item Another high performance random forest package (\cpkg{Rborist}) was exposed through \cpkg{caret}. The model code is \code{method = "Rborist"} \issue{418}
		\item Xavier Robin fixed a bug related to the area under the ROC curve in \issue{431}.
		\item A bug in \code{print.train} was fixed when LOO CV was used \issue{435}
		\item With RFE, a better error message drafted by mikekaminsky is printed when the number of importance measures is off \issue{424}
		\item Another bug was fixed in estimating the prediction time when the formula method was used \issue{420}.
		\item A linear SVM model was added that uses class weights.
		\item The linear SVM model using the \cpkg{e1071} package (\code{method = "svmLinear2"}) had the \code{gamma} parameter for the RBF kernel removed.
		\item Xavier Robin committed changes to make sure that the area under the ROC is accurately estimated \issue{431}
 	}
}


\section{Changes in version 6.0-68}{
	\itemize{
		\item \code{print.train} no longer shows the standard deviation of the resampled values unless the new option is used (\code{print.train(, showSD = TRUE)}). When shown, they are within parentheses (e.g. "4.24 (0.493)").
 		\item An adjustment the innards of adaptive resampling was changed so that the test for linear dependencies is more stringent.
		\item A bug in the bootstrap 632 estimate was found and fixed by Alexis Sarda \issue{349} \issue{353}.
		\item The \code{cforest} module's \code{oob} element was modified based on another bug found by Alexis Sarda \issue{351}.
		\item The methods for \code{bagEarth}, \code{bagEarthGCV}, \code{bagFDA}, \code{bagFDAGCV}, \code{earth}, \code{fda}, and \code{gcvEarth} models have been updates so that case-weights can be used.
		\item The \code{rda} module contained a bug found by Eric Czech \issue{369}.
		\item A bug was fixed for printing out the resampling details with LGOCV found by github user zsharpm \issue{366}
		\item A new data set was added (\code{data(Sacramento)}) with sale prices of homes.
		\item Another adaboost algorithm (\code{method = "adaboost"} from the \cpkg{fastAdaboost} package) was added \issue{284}.
		\item Yet another boosting algorithm (\code{method = "deepboost"} from the \cpkg{deepboost} package) was added \issue{388}.
		\item Alexis Sarda made changes to the confusion matrix code for \code{train}, \code{rfe}, and \code{sbf} objects that more rationally normalizes the resampled tables \issue{355}.
		\item A bug in how \cpkg{RSNNS} perceptron models were tuned (found by github user smlek) was fixed \issue{392}.
		\item A bug in computing the bootstrap 632 estimate was fixed (found by Stu) \issue{382}.
		\item John Johnson contributed an update to \code{xgbLinear} \issue{372}.
		\item Resampled confusion matrices are not automatically computed when there are 50 or more classes due to the storage requirements (\issue{356}). However, the relevant functions have been updated to use the out-of-sample predictions instead (when the user asks for them to be returned by the function).
		\item Some changes were made to \code{predict.train} to error trap (and fix) cases when predictions are requested without referencing a \code{newdata} object \issue{347}.
		\item Github user pverspeelt identified a bug in our model code for \code{glmboost} (and \code{gamboost}) related to the \code{mstop} function modifying the model object in memory. It was fixed \issue{396}.
		\item For \issue{346}, an option to select which samples are used to fit the final model, called \code{indexFinal}, was added to \code{trainControl}.
		\item For issue \issue{390} found by JanLauGe, a bug was fixed in \code{dummyVars} related to the names of the resulting data set.
		\item Models \code{rknn} and \code{rknnBel} were removed since their package is no longer on CRAN.
	}
}

\section{Changes in version 6.0-66}{
	\itemize{
		\item Model averaged naive Bayes (\code{method = "manb"}) from the \cpkg{bnclassify} package was added.
		\item \code{blackboost} was updated to work with outcomes with 3+ classes.
		\item A new model \code{rpart1SE} was added. This has no tuning parameters and resamples the internal \cpkg{rpart} procdure of pruning using the one standard error method.
		\item Another model (\code{svmRadialSigma}) tunes over the cost parameter and the RBF kernel parameter sigma. In the latter case, using \code{tuneLength} will, at most, evaluate six values of the kernel parameter. This enables a broad search over the cost parameter and a relatively narrow search over \code{sigma}.
		\item Additional model tags for "Accepts Case Weights", "Two Class Only", "Handle Missing Predictor Data", "Categorical Predictors Only", and "Binary Predictors Only" were added. In some cases, a new model element called "notes" was added to the model code.
		\item A pre-processing method called "conditionalX" was added that eliminates predictors where the conditional distribution (X|Y) for that predictor has a single value. See the \code{checkConditionalX} function for details. This is only used for classification.  \issue{334}
		\item A bug in the naive Bayes prediction code was found by github user pverspeelt and was fixed. \issue{345}
		\item Josh Brady (doublej2) found and fixed an issue with \code{DummyVars} \issue{344}
		\item A bug related to recent changes to the \cpkg{ranger} package was fixed \issue{320}
		\item Dependencies on external software can now be checked in the model code. See \href{https://github.com/topepo/caret/blob/master/models/deprecated/pythonKnnReg.R}{\code{pythonKnnReg}} for an example. This also removes the overall package dependency on \cpkg{rPython} \issue{328}.
		\item The tuning parameter grid for \code{enpls} and \code{enpls.fs} were changed to avoid errors.
		\item A bug was fixed \issue{342} where the data used for prediction was inappropriately converted from its original class.
		\item Matt (aka washcycle) added option to return column names to \code{nearZeroVar} function
		\item Homer Strong fixed \code{varImp} for \code{glmnet} models so that they return the absolute value of the regression coefficients \issue{173} \issue{190}
		\item The basic naive Bayes method (\code{method = "nb"}) gained a tuning parameter, \code{adjust}, that adjusts the bandwidth (see \code{?density}). The parameter is ignored when \code{usekernel = FALSE}.
	}
}


\section{Changes in version 6.0-62}{
	\itemize{
		\item From the \cpkg{randomGLM} package, a model of the same name was added.
		\item From \cpkg{monomvn} package, models for the Bayesian lasso and ridge regression were added. In the latter case, two methods were added. \code{blasso} creates predictions using the mean of the posterior distributions but sets some parameters specifically to zero based on the tuning parameter called \code{sparsity}. For example, when \code{sparsity = .5}, only coefficients where at least half the posterior estimates are nonzero are used. The other model,  \code{blassoAveraged}, makes predictions across all of the realizations in the posterior distribution without coercing any coefficients to zero. This is more consistent with Bayesian model averaging, but is unlikely to produce very sparse solutions.
		\item From the \cpkg{spikeslab} package, a regression model was added that emulates the procedure used by \code{cv.spikeslab} where the tuning variable is the number of retained predictors.
		\item A bug was fixed in adaptive resampling (found by github user elephann) \issue{304}
		\item Fixed another adaptive resampling bug flagged by github user elephann related to the latest version of the \cpkg{BradleyTerry2} package. Thanks to Heather Turner for the fix \issue{310}
		\item Yuan (Terry) Tang added more tuning parameters to \code{xgbTree} models.
		\item Model \code{svmRadialWeights} was updated to allow for class probabilities. Previously, \cpkg{kernlab} did not change the probability estimates when weights were used.
		\item A \cpkg{ggplot2} method for \code{varImp.train} was added \issue{231}
		\item Changes were made for the package to work with the next version of \cpkg{ggplot2} \issue{317}
		\item Github user \code{fjeze} added new models \code{mlpML} and \code{mlpWeightDecayML} that extend the existing \cpkg{RSNNS} models to multiple layers. \code{fjeze} also added the \code{gamma} parameter to the \code{svmLinear2} model.
		\item A function for generating data for learning curves was added.
		\item The range of SVM cost values explored in random search was expanded.
	}
}

\section{Changes in version 6.0-58}{
	\itemize{
		\item A major bug was fixed (found by Harlan Harris) where pre-processing objects created from versions of the package prior to 6.0-57 can give incorrect results when run with 6.0-57 \issue{282}.
		\item \code{preProcess} can now remove predictors using zero- and near zero-variance filters via (\code{method} values of \code{"zv"} and \code{"nzv"}). When used, these filters are applied to numeric predictors prior to all other pre-processing operations.
		\item \code{train} now throws an error for classification tasks where the outcome has a factor level with no observed data \issue{260}.
		\item Character outcomes passed to \code{train} are not converted to factors.
		\item A bug was found and fixed in this package's class probability code for \code{gbm} models when a single multinomial observation is predicted \issue{274}.
		\item A new option to \code{ggplot.train} was added that highlights the optimal tuning parameter setting in the cases where grid search is used (thanks to Balaji Iyengar (github: bdanalytics)).
		\item In \code{trainControl}, the argument \code{savePredictions} can now be character values (\code{"final"}, \code{"all"} or \code{"none"}). Logicals can still be used and match to  \code{"all"} or \code{"none"}.
	}
}


\section{Changes in version 6.0-57}{
	\itemize{
		\item Hyperparameter optimization via random search is now availible. See the new \href{http://topepo.github.io/caret/random-hyperparameter-search.html}{help page} for examples and syntax.
		\item \code{preProcess} now allows (but ignores) non-numeric predictor columns.
		\item Models were added for optimal weighted and stabilized nearest neighbor classifiers from the \cpkg{snn} package were added with model codes \code{snn} and \code{ownn}
		\item Random forests using the excellent \cpkg{ranger} package were added (\code{method = "ranger"})
		\item An additional variation of rotation forests was added (\code{rotationForest2}) that also tunes over \code{cp}. Unfortunately, the sub-model trick can't be utilized in this instance.
		\item Kernelized distance weighted discriminant analysis models from \cpkg{kerndwd} where added (\code{dwdLieanr}, \code{dwdPoly}, and \code{dwdRadial})
		\item A bug was fixed with \code{rfe} when \code{train} was used to generate a classification model but class probabilities were not (or could not be) generated \issue{234}.
		\item Can Candan added a python model \code{sklearn.neighbors.KNeighborsRegressor} that can be accessed via \code{train} using the \cpkg{rPython} package. The python modules \code{sklearn} and \code{pandas} are required for this to run.
		\item Jason Aizkalns fixed a bunch of typos.
		\item MarwaNabil found a bug with \code{lift} and missing values \issue{225}. This was fixed such that missing values are removed prior to the calculations (within each model)
		\item Additional options were added to \code{LPH07_1} so that two class data can also be simulated and predictors are converted to factors.
		\item The model-specific code for computing out-of-bag performance estimates were moved into the model code library \issue{230}.
		\item A variety of naive Bayes and tree augmented naive Bayes classifier from the \cpkg{bnclassify} package were added. Variations include simple models (methods labeled as \code{"nbDiscrete"} and \code{"tan"}), models using attribute weighting (\code{"awnb"} and \code{"awtan"}), and wrappers that use search methods to optimize the network structure (\code{"nbSearch"} and \code{"tanSearch"}). In each case, the predictors and outcomes must all be factor variables; for that reason, using the non-formula interface to \code{train} (e.g. \code{train(x, y)}) is critical to preserve the factor structure of the data.
		\item A function called \code{multiClassSummary} was added to compute performance values for problems with three or more classes. It works with or without predicted class probabilities \issue{107}.
		\item \code{confusionMatrix} was modified to deal with name collisions between this package and \cpkg{RSNNS} \issue{256}.
		\item A bug in how the LVQ tune grid is filtered was fixed.
		\item A bug in \code{preProcess} for ICA and PCA was fixed.
		\item Bugs in \code{avNNet} and \code{pcaNNet} when predicting class probabilities were fixed \issue{#261}.
	}
}


\section{Changes in version 6.0-52}{
	\itemize{
		\item A new model using the \cpkg{randomForest} and \cpkg{inTrees} packages called \code{rfRules} was added. A basic random forest model is used and then is decomposed into rules (of user-specified complexity). The \cpkg{inTrees} package is used to prune and optimize the rules. Thanks to Mirjam Jenny who suggested the workflow.
		\item Other new models (and their packages): \code{bartMachine} (\cpkg{bartMachine}), \code{rotationForest} (\cpkg{rotationForest}), \code{sdwd} (\cpkg{sdwd}), \code{loclda} (\cpkg{klaR}), \code{nnls} (\cpkg{nnls}), \code{svmLinear2} (\cpkg{e1071}), \code{rqnc} (\cpkg{rqPen}), and \code{rqlasso} (\cpkg{rqPen})
		\item When specifying your own resampling indices, a value of \code{method = "custom"} can be used with \code{trainControl} for better printing.
		\item Tim Lucas fixed a bug in \code{avNNet} when \code{bag = TRUE}
		\item Fixed a bug found by \code{ruggerorossi} in \code{method = "dnn"} with classification.
		\item A new option called \code{sampling} was added to \code{trainControl} that allows users to subsample their data in the case of a class imbalance. Another \href{http://topepo.github.io/caret/sampling.html}{help page} was added to explain the features.
		\item Class probabilities can be computed for \code{extraTrees} models now.
		\item When PCA pre-processing is conducted, the variance trace is saved in an object called \code{trace}.
		\item More error traps were added for common mistakes (e.g. bad factor levels in classification).
		\item An internal function (\code{class2ind}) that can be used to make dummy variables for a single factor vector is now documented and exported.
		\item A bug was fixed in the \code{xyplot.lift} where the reference line was incorrectly computed. Thanks to Einat Sitbon for finding this.
		\item A bug related to calculating the Box-Cox transformation found by John Johnson was fixed.
		\item github user \code{EdwinTh} developed a faster version of \code{findCorrelation} and found a bug in the original code. \code{findCorrelation} has two new arguments, one of which is called \code{exact} which defaults to use the original (fixed) function. Using \code{exact = FALSE} uses the faster version. The fixed version of the "exact" code is, on average, 26-fold slower than the current version (for 250x250 matrices) although the average time for matrices of this size was only 26s. The exact version yields subsets that are, one average, 2.4 percent smaller than the other versions. This difference will be more significant for smaller matrices. The faster ("approximate") version of the code is 8-fold faster than the current version.
		\item github user \code{slyuee} found a bug in the \code{gam} model fitting code.
		\item Chris Kennedy fixed a bug in the \code{bartMachine} variable importance code.
		}
}

\section{Changes in version 6.0-47}{
	\itemize{
		\item CHAID from the R-Forge package \href{http://r-forge.r-project.org/projects/chaid/}{\pkg{CHAID}}
		\item Models \code{xgbTree} amd \code{xgbLinear} from the \code{xgboost} package were added. That package is not on CRAN  and can be installed from github using the \cpkg{devtools} package and \code{install_github('dmlc/xgboost',subdir='R-package')}.
		\item \code{dratewka} enabled \code{rbf} models for regression.
		\item A summary function for the multinomial likelihood called \code{mnLogLoss} was added.
		\item The total object size for \code{preProces} objects that used bagged imputation was reduced almost 5-fold.
		\item A new option to \code{trainControl} called \code{trim} was added where, if implemented, will reduce the model's footprint. However, features beyond simple prediction may not work.
		\item A rarely occurring bug in \code{gbm} model code was fixed (thanks to Wade Cooper)
		\item \code{splom.resamples} now respects the \code{models} argument
		\item A new argument to \code{lift} called \code{cuts} was added to allow more control over what thresholds are used to calculate the curve.
		\item The \code{cuts} argument of \code{calibration} now accepts a vector of cut points.
		\item Jason Schadewald noticed and fixed a bug in the man page for \code{dummyVars}
		\item Call objects were removed from the following models: \code{avNNet}, \code{bagFDA}, \code{icr}, \code{knn3}, \code{knnreg}, \code{pcaNNet}, and \code{plsda}.
		\item An argument was added to \code{createTimeSlices} to thin the number of resamples
		\item The RFE-related functions \code{lrFuncs}, \code{lmFuncs}, and \code{gamFuncs} were updated so that \code{rfe} accepts a matrix \code{x} argument.
		\item Using the default grid generation with \code{train} and \code{glmnet}, an initial \code{glmnet} fit is created with \code{alpha = 0.50} to define the \code{lambda} values.
		\item \code{train} models for \code{"gbm"}, \code{"gam"}, \code{"gamSpline"}, and \code{"gamLoess"} now allow their respective arguments for the outcome probability distribution to be passed to the underlying function.
		\item A bug in \code{print.varImp.train} was fixed.
		\item \code{train} now returns an additional column called \code{rowIndex} that is exposed when calling the summary function during resampling.
		\item The ability to compute class probabilities was removed from the \code{rpartCost} model since they are unlikely to agree with the class predictions.
		\item \code{extractProb} no longer redundantly calls \code{extractPrediction} to generate the class predictions.
		\item A new function called \code{var_seq} was added that finds a sequence of integers that can be useful for some tuning parameters such as random forests \code{mtry}. Model modules were update to use the new function.
		\item \code{n.minobsinnode} was added as a tuning parameter to \code{gbm} models.
		\item For models using out-of-bag resampling, \code{train} now properly checks the \code{metric} argument against the names of the measured outcomes.
		\item Both \code{createDataParition} and \code{createFolds} were modified to better handle cases where one or more class have very low numbers of data points.
	}
}

\section{Changes in version 6.0-41}{
	\itemize{
		\item The license was changed to GPL (>= 2) to accommodate new code from the GA package.
		\item New feature selection functions \code{gafs} and \code{safs} were added, along with helper functions and objects, were added. The package HTML was updated to expand more about feature selection.
		\item From the \cpkg{adabag} package, two new models were added: \code{AdaBag} and \code{AdaBoost.M1}.
		\item Weighted subspace random forests from the \cpkg{wsrf} package was added.
		\item Additional bagged FDA and MARS models were added (model codes \code{bagFDAGCV} and \code{bagEarthGCV}) were added that use the GCV statistic to prune the model. This leads to memory reductions during training.
		\item The model code for \code{ada} had a bug fix applied and the code was adapted to use the "sub-model trick" so it should train faster.
		\item A bug was fixed related to imputation when the formula method is used with \code{train}
		\item The old \code{drop = FALSE} bug was fixed in \code{getTrainPerf}
		\item A bug was fixed for custom models with no labels.
		\item A bug fix was made for bagged MARS models when predicting probabilities.
		\item In \code{train}, the argument \code{last} was being incorrectly set for the last model.
		\item Reynald Lescarbeau refactored \code{findCorrelation} to make it faster.
		\item The apparent performance values are not reported by  \code{print.train} when the bootstrap 632 estimate is used.
		\item When a required package is missing, the code stops earlier with a more explicit error message.
	}
}

\section{Changes in version 6.0-37}{
	\itemize{
		\item Brenton Kenkel added ordered logistic or probit regression to \code{train} using \code{method = "polr"} from \cpkg{MASS}
		\item \code{LPH07_1} now encodes the noise variables as binary
		\item Both \code{rfe} and \code{sbf} get arguments for \code{indexOut} for their control functions.
		\item A reworked version of \code{\link{nearZerVar}} based on code from Michael Benesty was added the old version is now called \code{nzv} that uses less memory and can be used in parallel.
		\item The adaptive mixture discriminant model from the \cpkg{adaptDA} package was added as well as a robust mixture discriminant model from the \cpkg{robustDA} package.
		\item The multi-class discriminant model using binary predictors in the \cpkg{binda} package was added.
		\item Ensembles of partial least squares models (via the \cpkg{enpls}) package was added.
		\item A bug using \code{gbm} with Poisson data was fixed (thanks to user eriklampa)
		\item \code{sbfControl} now has a \code{multivariate} option where all the predictors are exposed to the scoring function at once.
		\item A function \code{compare_models} was added that is a simple comparison of models via \code{diff.resamples)}.
		\item The row names for the \code{variables} component of \code{rfe} objects were simplified.
		\item Philipp Bergmeir found a bug that was fixed where \code{bag} would not run in parallel.
		\item \code{predictionBounds} was not implemented during resampling.
	}
}

\section{Changes in version 6.0-35}{
	\itemize{
		\item A few bug fixes to \code{preProcess} were made related to KNN imputation.
		\item The parameter labels for polynomial SVM models were fixed
		\item The tags for \code{dnn} models were fixed.
		\item The following functions were removed from the package: \code{generateExprVal.method.trimMean}, \code{normalize.AffyBatch.normalize2Reference}, \code{normalize2Reference}, and \code{PLS}. The original code and the man files can be found at \href{https://github.com/topepo/caret/tree/master/deprecated}{https://github.com/topepo/caret/tree/master/deprecated}.
		\item A number of changes to comply with section 1.1.3.1 of "Writing R Extensions" were made.
	}
}

\section{Changes in version 6.0-34}{
\itemize{

\item For the input data \code{x} to \code{train}, we now  respect the class of the input value to accommodate other data types (such as sparse matrices). There are some complications though; for pre-processing we throw a
warning if the data are not simple matrices or data frames since there is some infrastructure that does not exist for other classes( e.g. \code{complete.cases}). We also throw a warning if \code{returnData <- TRUE} and it cannot be converted to a data frame. This allows the use of sparse matrices and text corpus to be used as inputs into that function.


\item \code{plsRglm} was added.

\item From the \cpkg{frbs}, the following rule-based models were added: \code{ANFIS}, \code{DENFIS}, \code{FH.GBML}, \code{FIR.DM}, \code{FRBCS.CHI}, \code{FRBCS.W}, \code{FS.HGD}, \code{GFS.FR.MOGAL}, \code{GFS.GCCL}, \code{GFS.LTS}, \code{GFS.THRIFT}, \code{HYFIS}, \code{SBC} and \code{WM}. Thanks to Lala Riza for suggesting these and facilitating their addition to the package.

\item From the \cpkg{kernlab} package, SVM models using string kernels were added: \code{svmBoundrangeString}, \code{svmExpoString}, \code{svmSpectrumString}

\item A function \code{update.rfe} was added.

\item \code{cluster.resamples} was added to the namespace.

\item An option to choose the \code{metric} was added to \code{summary.resamples}.

\item \code{prcomp.resamples} now passed  \code{...} to \code{prcomp}.  Also the call to  \code{prcomp} uses the formula method so that  \code{na.action} can be used.

\item The function \code{resamples} was enhanced so that \code{train} and \code{rfe} models that used \code{returnResamp="all"} subsets the resamples to get the appropriate values and issues a warning. The function also fills in missing model names if one or more are not given.

\item Several regression simulation functions were added: \code{SLC14_1}, \code{SLC14_2}, \code{LPH07_1} and \code{LPH07_2}

\item \code{print.train} was re-factored so that \code{format.data.frame} is now used. This should behave better when using \cpkg{knitr}.

\item The error message in \code{train.formula} was improved to provide more helpful feedback in cases where there is at least one missing value in each row of the data set.


\item \code{ggplot.train} was modified so that groups are distinguished by color and shape.

\item Options were added to \code{plot.train} and \code{ggplot.train} called \code{nameInStrip} that will print the name and value of any tuning parameters shown in panels.

\item A bug was fixed by Jia Xu within the knn imputation code used by \code{preProcess}.
}
}

\section{Changes in version 6.0-30}{
\itemize{
\item A missing piece of documentation in \code{trainControl} for adaptive models was filled in.

\item A warning was added to \code{plot.train} and \code{ggplot.train} to note that the relationship between the resampled performance measures and the tuning parameters can be deceiving when using adaptive resampling.

\item A check was added to \code{trainControl} to make sure that a value of \code{min} makes sense when using adaptive resampling.

}
}

\section{Changes in version 6.0-29}{
\itemize{
\item  A man page with the list of models available via \code{train} was added back into the package. See \code{?models}.

\item  Thoralf Mildenberger found and fixed a bug in the variable importance
calculation for neural network models.

\item The output of \code{varImp} for \code{pamr} models was updated to clarify the ordering of the importance scores.

\item \code{getModelInfo} was updated to generate a more informative error message if the user looks for a model that is not in the package's model library.

\item A bug was fixed related to how seeds were set inside of \code{train}.

\item The model \code{"parRF"} (parallel random forest) was added back into the library.

\item When case weights are specified in \code{train}, the hold-out weights are exposed when computing the summary function.

\item A check was made to convert a \code{data.table} given to \code{train} to a data frame (see \url{http://stackoverflow.com/questions/23256177/r-caret-renames-column-in-data-table-after-training}).

}
}

\section{Changes in version 6.0-25}{
\itemize{
\item Changes were made that stopped execution of \code{train} if there are no rows in the data (changes suggested by Andrew Ziem)

\item Andrew Ziem also helped improve the documentation.
}
}

\section{Changes in version 6.0-24}{
\itemize{
\item Several models were updated to work with case weights.

\item A bug in \code{rfe} was found where the largest subset size have the same results as the full model. Thanks to Jose Seoane for reporting the bug.
}
}

\section{Changes in version 6.0-22}{
\itemize{
\item For some parallel processing technologies, the package now export
more internal functions.

\item A bug was fixed in \code{rfe} that occurred when LOO CV was used.

\item Another bug was fixed that occurred for some models when
\code{tuneGrid} contained only a single model.
 }
}


\section{Changes in version 6.0-21}{
\itemize{
\item A new system for user-defined models has been added. See
\href{http://caret.r-forge.r-project.org/custom_models.html}{http://caret.r-forge.r-project.org/custom_models.html}.

\item When creating the grid of tuning parameter values, the column
names no longer need to be preceded by a period. Periods can still be
used as before but are not required. This isn't guaranteed to break
backwards compatibility but it may in some cases.

\item \code{trainControl} now has a \code{method = "none"} resampling
option that bypasses model tuning and fits the model to the entire
training set. Note that if more than one model is specified an error
will occur.

 \item \code{logicForest} models were removed since the package is
 now archived.

 \item \code{CSimca} and \code{RSimca} models from the \cpkg{rrcovHD}
 package were added.

 \item  Model \code{elm} from the \cpkg{elmNN}
 package was added.

  \item  Models \code{rknn} and \code{rknnBel} from the \cpkg{rknn}
 package were added

  \item  Model \code{brnn} from the \cpkg{brnn}
 package was added.

 \item \code{panel.lift2} and \code{xyplot.lift} now have an argument
 called \code{values} that show the percentages of samples found for
 the specified percentages of samples tested.

\item \code{train}, \code{rfe} and \code{sbf} should no longer throw
a warning that "executing %dopar% sequentially: no parallel backend registered".

\item A \code{ggplot} method for \code{train} was added.

\item Imputation via medians was added to \code{preProcess} by Zachary Mayer.

\item A small change was made to \code{rpart} models. Previously, when the
final model is determined, it would be fit by specifying the model using the
\code{cp} argument of \code{rpart.control}. This could lead to duplicated Cp
values in the final list of possible Cp values. The current version fits the
final model slightly different. An initial model is fit using \code{cp = 0}
then it is pruned using \code{prune.rpart} to the desired depth. This
shouldn't be different for the vast majority of data sets. Thanks to Jeff
Evans for pointing this out.

\item The method for estimating sigma for SVM and RVM models was slightly
changed to make them consistent with how \code{ksvm} and \code{rvm} does the
estimation.

\item The default behavior for \code{returnResamp} in \code{rfeControl} and
 \code{sbfControl} is now \code{returnResamp = "final"}.

\item \code{cluster} was added as a general class with a specific method
for \code{resamples} objects.

\item The refactoring of model code resulted in a number of packages being
eliminated from the depends field. Additionally, a few were moved to exports.

}
}

\section{Changes in version 5.17-07}{
\itemize{
 \item A bug in \code{spatialSign} was fixed for data frames with
 a single column.

 \item Pre-processing was not applied to the training data set
 prior to grid creation. This is now done but only for models
 that use the data when defining the grid. Thanks to Brad Buchsbaum
 for finding the bug.

 \item Some code was added to \code{rfe} to truncate the subset
 sizes in case the user over-specified them.

 \item A bug was fixed in \code{gamFuncs} for the \code{rfe}
 function.

 \item Option in \code{trainControl}, \code{rfeControl} and
 \code{sbfControl} were added so that the user can set the
 seed at each resampling iteration (most useful for parallel
 processing). Thanks to Allan Engelhardt for the recommendation.

 \item Some internal refactoring of the data was done to prepare
 for some upcoming resampling options.

 \item \code{predict.train} now has an explicit \code{na.action}
 argument defaulted to \code{na.omit}. If imputation is used in
 \code{train}, then \code{na.action = na.pass} is recommended.

 \item A bug was fixed in \code{dummyVars} that occured when
 missing data were in \code{newdata}. The function
 \code{contr.dummy} is now deprecated and \code{contr.ltfr}
 should be used (if you are using it at all). Thanks to
 stackexchange user mchangun for finding the bug.

 \item A check is now done inside \code{dummyVars} when
 \code{levelsOnly = TRUE} to see if any predictors share common
 levels.

 \item A new option \code{fullRank} was added to \code{dummyVars}.
 When true, \code{contr.treatment} is used. Otherwise,
 \code{contr.ltfr} is used.

 \item A bug in \code{train} was fixed with \code{gbm} models
 (thanks to stackoverflow user screechOwl for finding it).

 }
 }


\section{Changes in version 5.16-24}{
\itemize{
 \item The \code{protoclass} function in the \cpkg{protoclass}
 package was added. The model uses a distance matrix as input and
 the \code{train} method also uses the \cpkg{proxy} package to
 compute the distance using the Minkowski distance. The two tuning
 parameters is the neighborhood size (\code{eps}) and the Minkowski
 distance parameter (\code{p}).

 \item A bug was (hopefully) fixed that occurred when some type of
 parallel processing was used with \code{train}. The problem is
 that the \code{methods} package was not being loaded in the workers.
 While reproducible, it is unknown why this occurs and why it is
 only for some technologies and systems. The \code{methods} package
 is now a formal dependency and we coerce the workers to load it
 remotely.

 \item A bug was fixed where some calls were printed twice.

 \item For \code{rpart}, \code{C5.0} and \code{ksvm}, cost-sensitive
 versions of these models for two classes were added to \code{train}.
 The method values are \code{rpartCost}, \code{C5.0Cost} and
 \code{svmRadialWeights}.

 \item The prediction code for the \code{ksvm} models was changed. There
are some cases where the class predictions and the predicted class
probabilities disagree. This usually happens when the probabilities are
close to 0.50 (in the two class case). A \cpkg{kernlab} bug has been
filed. In the meantime, if the \code{ksvm} model uses a probability
model, the class probabilities are generated first and the predicted
class is assigned to the probability with the largest value. Thanks to
Kjell Johnson for finding that one.

\item \code{print.train} was changed so that tune parameters that are
logicals are printed well.

 }
 }


\section{Changes in version 5.16-13}{
\itemize{
 \item Added a few exemptions to the logic that determines whether a model call should be scrubbed.

 \item An error trap was created to catch issues with missing importance scores in \code{rfe}.

 }
 }

\section{Changes in version 5.16-03}{
\itemize{
 \item A function \code{twoClassSim} was added for benchmarking classification models.

 \item A bug was fixed in \code{predict.nullModel} related to predicted class probabilities.

 \item The version requirement for \cpkg{gbm} was updated.

 \item The function \code{getTrainPerf} was made visible.

 \item The automatic tuning grid for \code{sda} models from the \cpkg{sda} package was changed to include \code{lambda}.

 \item When \code{randomForests} is used with \code{train} and \code{tuneLength == 1}, the \code{randomForests} default value for \code{mtry} is used.

 \item Maximum uncertainty linear discriminant analysis (\code{Mlda}) and factor-based linear discriminant analysis (\code{RFlda}) from the \cpkg{HiDimDA} package were added to \code{train}.
}
}

\section{Changes in version 5.15-87}{
\itemize{

\item Added the Yeo-Johnson power transformation from the \cpkg{car}
package to the \code{preProcess} function.

\item A \code{train} bug was fixed for the \code{rrlda} model (found
by Tiago Branquinho Oliveira).

\item The \code{extraTrees} model in the \cpkg{extraTrees} package was
added.

\item The \code{kknn.train} model in the \cpkg{kknn} package was
added.

\item A bug was fixed in \code{lrFuncs} where the class threshold was
improperly set (thanks to David Meyer).

\item A bug related to newer versions of the \cpkg{gbm} package were fixed.
Another \cpkg{gbm} bug was fixed related to using non-Bernoulli distributions
with two class outcomes (thanks to Zachary Mayer).

\item The old funciton \code{getTrainPerf} was finally made visible.

\item Some models are created using "do.call" and may contain the
entire data set in the call object. A function to "scrub" some model call
objects was added to reduce their size.

\item The tuning process for \code{sda:::sda} models was changed to
add the \code{lambda} parameter.

}
}

\section{Changes in version 5.15-60}{
\itemize{

\item A bug in \code{predictors.earth}, discovered by Katrina Bennett,
was fixed.

\item A bug induced by version 5.15-052 for the bootstrap 632 rule was
fixed.

\item The DESCRIPTION file as of 5.15-048 should have used a
version-specific lattice dependency.

\item \code{lift} can compute gain and lift charts (and defaults to
gain)

\item The \cpkg{gbm} model was updated to handle 3 or more classes.

\item For bagged trees using \cpkg{ipred}, the code in \code{train}
defaults to \code{keepX = FALSE} to save space. Pass in \code{keepX =
TRUE} to use out-of-bag sampling for this model.

\item Changes were made to support vector machines for classification
models due to bugs with class probabilities in the latest version of
\cpkg{kernlab}. The \code{prob.model} will default to the value of
\code{classProbs} in the \code{trControl} function. If
\code{prob.model} is passed in as an argument to \code{train}, this
specification over-rides the default. In other words, to avoid
generating a probability model, set either \code{classProbs = FALSE}
or \code{prob.model = FALSE}.

}
}

\section{Changes in version 5.15-052}{
\itemize{

\item Added \code{bayesglm} from the \cpkg{arm} package.

\item A few bugs were fixed in \code{bag}, thanks to Keith
Woolner. Most notably, out-of-bag estimates are now computed when the
prediction function includes a column called \code{pred}.

\item Parallel processing was implemented in \code{bag} and
\code{avNNet}, which can be turned off using an optional arguments.

\item \code{train}, \code{rfe}, \code{sbf}, \code{bag} and
\code{avNNet} were given an additional argument in their respective
control files called \code{allowParallel} that defaults to
\code{TRUE}. When \code{Code}, the code will be executed in parallel
if a parallel backend (e.g. \cpkg{doMC}) is registered. When
\code{allowParallel = FALSE}, the parallel backend is always
ignored. The use case is when \code{rfe} or \code{sbf} calls
\code{train}. If a parallel backend with P processors is being used,
the combination of these functions will create P^2 processes. Since
some operations benefit more from parallelization than others, the
user has the ability to concentrate computing resources for specific
functions.

\item A new resampling function called \code{createTimeSlices} was
contributed by Tony Cooper that generates cross-validation indices for
time series data.

\item A few more options were added to
\code{trainControl}. \code{initialWindow}, \code{horizon} and
\code{fixedWindow} are applicable for when \code{method =
"timeslice"}. Another, \code{indexOut} is an optional list of
resampling indices for the hold-out set. By default, these values are
the unique set of data points not in the training set.

\item A bug was fixed in multiclass \code{glmnet} models when
generating class probabilities (thanks to Bradley Buchsbaum for
finding it).
}
}


\section{Changes in version  5.15-048}{
\itemize{

\item The three vignettes were removed and two things were added: a
smaller vignette and a large collection of help pages at
\url{http://caret.r-forge.r-project.org/}.

\item Minkoo Seo found a bug where \code{na.action} was not being properly
set with train.formula().

\item \code{parallel.resamples} was changed to properly account for
missing values.

\item Some testing code was removed from \code{probFunction} and
\code{predictionFunction}.

\item Fixed a bug in \code{sbf} exposed by a new version of \cpkg{plyr}.

\item Changed the package dependency on \cpkg{reshape} to \cpkg{reshape2}.

\item To be more consistent with recent versions of \cpkg{lattice},
the \code{parallel.resamples} function was changed to
\code{parallelplot.resamples}.

\item Since \code{ksvm} now allows probabilities when class weights
are used, the default behavior in \code{train} is to set
\code{prob.model = TRUE} unless the user explicitly sets it to
\code{FALSE}. However, I have reported a bug in \code{ksvm} that gives
inconsistent results with class weights, so this is not advised at
this point in time.

\item Bugs were fix in \code{predict.bagEarth} and
\code{predict.bagFDA}.

\item When using \code{rfeControl(saveDetails = TRUE)} or
\code{sbfControl(saveDetails = TRUE)} an additional column is
added to \code{object$pred} called \code{rowIndex}. This indicates the
row from the original data that is being held-out.

}
}

\section{Changes in version  5.15-045}{
\itemize{

\item A bug was fixed that induced \code{NA} values in SVM model predictions.
}
}

\section{Changes in version  5.15-042}{
\itemize{

\item Many examples are wrapped in dontrun to speed up cran checking.

\item The \code{scrda} methods were removed from the package (on
6/30/12, R Core sent an email that "since we haven't got fixes for
long standing warnings of the rda packages since more than half a year
now, we set the package to ORPHANED.")

\item \cpkg{C50} was added (model codes \code{C5.0}, \code{C5.0Tree} and
\code{C5.0Rules}).

\item Fixed a bug in \code{train} with NaiveBayes when \code{fL != 0}
was used

\item The output of \code{train} with \code{verboseIter = TRUE} was
modified to show the resample label as well as logging when the worker
started and stopped the task (better when using parallel processing).

\item Added a long-hidden function \code{downSample} for class imbalances

\item An \code{upSample} function was added for class imbalances.

\item A new file, aaa.R, was added to be compiled first that tries to
eliminate the dreaded 'no visible binding for global variable' false
positives. Specific namespaces were used with several functions for
avoid similar warnings.

\item A bug was fixed with \code{icr.formula} that was so ridiculous,
I now know that nobody has ever used that function.

\item Fixed a bug when using \code{method = "oob"} with \code{train}

\item Some exceptions were added to \code{plot.train} so that some
tuning parameters are better labeled.

\item \code{dotplot.resamples} and \code{bwplot.resamples} now order
the models using the first metric.

\item A few of the lattice plots for the \code{resamples} class were
changed such that when only one metric is shown: the strip is not
shown and the x-axis label displays the metric

\item When using \code{trainControl(savePredictions = TRUE)} an
additional column is added to \code{object$pred} called
\code{rowIndex}. This indicates the row from the original data that is
being held-out.

\item A variable importance function for \code{nnet} objects was
created based on Gevrey, M., Dimopoulos, I., & Lek, S. (2003). Review
and comparison of methods to study the contribution of variables in
artificial neural network models. ecological modelling, 160(3),
249–264.

\item The \code{predictor} function for \code{glmnet} was update and a
variable importance function was also added.

\item Raghu Nidagal found a bug in \code{predict.avNNet} that was
fixed.

\item \code{sensitivity} and \code{specificity} were given an
\code{na.rm} argument.

\item A first attempt at fault tolerance was added to \code{train}. If
a model fit fails, the predictions are set to \code{NA} and a warning
is issued (eg "model fit failed for Fold04: sigma=0.00392,
C=0.25"). When \code{verboseIter = TRUE}, the warning is also printed
to the log. Resampled performance is calculated on only the
non-missing estimates. This can also be done during predictions, but
must be done on a model by model basis. Fault tolerance was added for
\cpkg{kernlab} models only at this time.

\item \code{lift} was modified in two ways. First, \code{cuts} is no
longer an argument. The function always uses cuts based on the number
of unique probability estimates. Second, a new argument called
\code{label} is available to use alternate names for the models
(e.g. names that are not valid R variable names).

\item A bug in \code{print.bag} was fixed.

\item Class probabilities were not being generated for sparseLDA
models.

\item Bugs were fixed in the new varImp methods for PART and RIPPER

\item Starting using namespaces for \code{ctree} and \code{cforest} to
avoid conflicts between duplicate function names in the \cpkg{party}
and \cpkg{partykit} package

\item A set of functions for RFE and logistic regression
(\code{lrFuncs}) was added.

\item A bug in \code{train} with \code{method="glmStepAIC"} was fixed
so that \code{direction} and other \code{stepAIC} arguments were
honored.

\item A bug was fixed in \code{preProcess} where the number of ICA
components was not specified. (thanks to Alexander Lebedev)

\item Another bug was fixed for oblique random forest methods in
\code{train}. (thanks to Alexander Lebedev)

}
}

\section{Changes in version  5.15-023}{
\itemize{

\item The list of models that can accept factor inputs directly was
expanded to include the \cpkg{RWeka} models, \code{ctree},
\code{cforest} and custom models.

\item Added model \code{lda2}, which tunes by the number of functions
used during prediction.

\item \code{predict.train} allows probability predictions for custom
models now (thanks to Peng Zhang)

\item \code{confusionMatrix.train} was updated to use the default
\code{confusionMatrix} code when \code{norm = "none"} and only a
single hold-out was used.

\item Added  variable importance  metrics for PART  and RIPPER  in the
\cpkg{RWeka} package.

\item vignettes were moved from /inst/doc to /vignettes

}
}


\section{Changes in version  5.14-023}{
\itemize{

\item The model details in \code{?train} was changed to be more
readable

\item Added two models from the \cpkg{RRF} package. \code{RRF} uses a
penalty for each predictor based on the scaled variable importance
scores from a prior random forest fit. \code{RRFglobal} sets a common,
global penalty across all predictors.

\item Added two models from the \cpkg{KRLS} package: \code{krlsRadial}
and \code{krlsPoly}. Both have kernel parameters (\code{sigma} and
\code{degree}) and a common regularization parameter
\code{lambda}. The default for \code{lambda} is \code{NA}, letting the
\code{krls} function estimate it internally. \code{lambda} can also be
specified via \code{tuneGrid}.

\item \code{twoClassSummary} was modified to wrap the call to
\code{pROC:::roc} in a \code{try} command. In cases where the hold-out
data are only from one class, this produced an error. Now it generates
\code{NA} values for the AUC when this occurs and a general warning is
issued.

\item The underlying workflows for \code{train} were modified so that
missing values for performance measures would not throw an error (but
will issue a warning).

}
}


\section{Changes in version  5.13-037}{
\itemize{

\item Models \code{mlp}, \code{mlpWeightDecay}, \code{rbf} and
\code{rbfDDA} were added from \cpkg{RSNNS}.

\item Functions \code{roc}, \code{rocPoint} and \code{aucRoc} finally
met their end. The cake was a lie.

\item This NEWS file was converted over to Rd format.
}
}


\section{Changes in version 5.13-020}{
\itemize{

\item \code{\link{lift}} was expanded into \code{\link{lift.formula}}
   for calculating the plot points and \code{\link{xyplot.lift}} to
   create the plot.

\item The package vignettes were altered to stop loading external
   RData files.

\item A few \code{match.call} changes were made to pass new R CMD
check tests.

\item \code{\link{calibration}}, \code{\link{calibration.formula}} and
   \code{\link{xyplot.calibration}} were created to make probability
   calibration plots.

\item Model types \code{xyf} and \code{bdk} from the \cpkg{kohonen}
package were added.

\item \code{\link{update.train}} was added so that tuning parameters
   can be manually set if the automated approach to setting their
   values is insufficient.

 }
}

\section{Changes in version 5.11-006}{
\itemize{

\item When using \code{method = "pls"} in \code{\link{train}}, the
   \code{\link[pls]{plsr}} function used the default PLS algorithm
   ("kernelpls"). Now, the full orthogonal scores method is used. This
   results in the same model, but a more extensive set of values are
   calculated that enable VIP calculations (without much of a loss in
   computational efficient).

\item A check was added to \code{\link{preProcess}} to ensure valid
   values of \code{method} were used.

\item  A new method, \code{kernelpls}, was added.

\item \code{residuals} and \code{summary} methods were added to
   \code{\link{train}} objects that pass the final model to their
   respective functions.

 }
}

\section{Changes in version 5.11-006}{
\itemize{

\item  Bugs were fixed that prevented hold-out predictions from being
   returned.

 }
}

\section{Changes in version 5.11-003}{
\itemize{

\item A bug in \code{roc} was found when the classes were completely
   separable.

\item The ROC calculations for \code{\link{twoClassSummary}} and
   \code{\link{filterVarImp}} were changed to use the \cpkg{pROC}
   package. This, and other changes, have increased efficiency. For
   \code{\link{filterVarImp}} on the cell segmentation data lead to a
   54-fold decrease in execution time. For the Glass data in the
   \cpkg{mlbench} package, the speedup was 37-fold. Warnings were
   added for \code{roc}, \code{aucRoc} and
   \code{rocPoint} regarding their deprecation.

\item random ferns (package \cpkg{rFerns}) were added

\item Another sparse LDA model (from the penalizedLDA) was also added

 }
}

\section{Changes in version 5.09-002}{
\itemize{

\item Fixed a bug which occurred when \code{\link[pls]{plsda}} models were used with class
   probabilities

\item As of 8/15/11, the \code{\link[glmnet]{glmnet}} function was
   updated to return a character vector. Because of this,
   \code{\link{train}} required modification and a version requirement
   was put in the package description file.

 }
}

\section{Changes in version 5.09-006}{
\itemize{

\item Shea X made a suggestion and provided code to improve the speed
   of prediction when sequential parameters are used for
   \code{\link[gbm]{gbm}} models.

\item Andrew Ziem suggested an error check with \code{metric = "ROC"} and
   \code{classProbs = FALSE}.

\item Andrew Ziem found a bug in how \code{\link{train}} obtained
   \code{\link[earth]{earth}} class probabilities

 }
}

\section{Changes in version 5.08-011}{
\itemize{

\item Andrew Ziem found another small bug with parallel processing and
   \code{\link{train}} (functions in the caret namespace cannot be found).

\item Ben Hoffman found a bug in \code{\link{pickSizeTolerance}} that was fixed.

\item Jiaye Yu found (and fixed) a bug in getting predictions back from
   \code{\link{rfe}}

 }
}

\section{Changes in version 5.07-024}{
\itemize{

\item Using \code{saveDetails = TRUE} in \code{\link{sbfControl}} or
   \code{\link{rfeControl}} will save the predictions on the hold-out
   sets (Jiaye Yu wins the prize for finding that one).

\item \code{\link{trainControl}} now has a logical to save the hold-out predictions.

 }
}

\section{Changes in version 5.07-005}{
\itemize{

\item \code{type = "prob"} was added for \code{\link{avNNet}} prediction.

\item A warning was added when a model from \cpkg{RWeka} is used with
   \code{\link{train}} and (it appears that) \cpkg{multicore} is being
   used for parallel processing. The session will crash, so don't do
   that.

\item A bug was fixed where the extrapolation limits were being
   applied in \code{\link{predict.train}} but not in
   \code{\link{extractPrediction}}. Thanks to Antoine Stevens for
   finding this.

\item Modifications were made to some of the workflow code to expose
   internal functions. When parallel processing was used with
   \cpkg{doMPI} or \cpkg{doSMP}, \cpkg{foreach} did not find some
   \cpkg{caret} internals (but \cpkg{doMC} did).


 }
}

\section{Changes in version 5.07-001}{
\itemize{

\item changed calls to \code{\link[pls]{predict.mvr}} since the \cpkg{pls} package now has a
   namespace.

 }
}

\section{Changes in version 5.06-002}{
\itemize{

\item a beta version of custom models with \code{\link{train}} is included. The
   "caretTrain" vignette was updated with a new section that defines
   how to make custom models.

 }
}

\section{Changes in version 5.05-004}{
\itemize{

\item laying some of the groundwork for custom models

\item updates to get away from deprecated (mean and sd on data frames)

\item The pre-processing in \code{\link{train}} bug of the last
   version was not entirely squashed. Now it is.

 }
}

\section{Changes in version 5.04-007}{
\itemize{

\item \code{\link{panel.lift}} was moved out of the examples in \code{?lift} and into the
   package along with another function, \code{\link{panel.lift2}}.

\item \code{\link{lift}} now uses \code{\link{panel.lift2}} by default

\item  Added robust regularized linear discriminant analysis from the
   \cpkg{rrlda} package

\item Added \code{evtree} from \cpkg{evtree}

\item A weird bug was fixed that occurred when some models were run with
   sequential parameters that were fixed to single values (thanks to
   Antoine Stevens for finding this issue).

item Another bug was fixed where pre-processing with \code{\link{train}} could fail

 }
}

\section{Changes in version 5.03-003}{
\itemize{

\item  pre-processing in \code{\link{train}} did not occur for the final model fit

 }
}

\section{Changes in version 5.02-011}{
\itemize{

\item A function, \code{\link{lift}}, was added to create lattice
objects for lift plots.

\item Several models were added from the \cpkg{obliqueRF} package:
   'ORFridge' (linear combinations created using L2 regularization),
   'ORFpls' (using partial least squares), 'ORFsvm' (linear support
   vector machines), and 'ORFlog' (using logistic regression). As of
   now, the package only support classification.

\item Added regression models \code{simpls} and
   \code{widekernelpls}. These are new models since both
   \code{\link{train}} and \code{\link[pls]{plsr}} have an argument
   called \code{method}, so the computational algorithm could not be
   passed through using the three dots.

\item Model \code{rpart} was added that uses \code{cp} as the tuning
   parameter. To make the model codes more consistent, \code{rpart}
   and \code{ctree} correspond to the nominal tuning parameters
   (\code{cp} and \code{mincriterion}, respectively) and \code{rpart2}
   and \code{ctree2} are the alternate versions using \code{maxdepth}.

\item The text for \code{ctree}'s tuning parameter was changed to '1 -
P-Value Threshold'

\item The argument \code{controls} was not being properly passed
   through in models \code{ctree} and \code{ctree2}.

 }
}

\section{Changes in version 5.01-001}{
\itemize{

\item \code{controls} was not being set properly for \code{cforest}
models in \code{\link{train}}

\item The print methods for \code{\link{train}}, \code{\link{rfe}} and
\code{\link{sbf}} did not recognize LOOCV

\item \code{\link{avNNet}} sometimes failed with categorical outcomes with \code{bag = FALSE}

\item A bug in \code{\link{preProcess}} was fixed that was triggered by matrices without
   dimnames (found by Allan Engelhardt)

\item bagged MARS models with factor outcomes now work

\item \code{cforest} was using the argument \code{control} instead of \code{controls}

\item A few bugs for class probabilities were fixed for  \code{slda},  \code{hdda},
    \code{glmStepAIC},  \code{nodeHarvest},  \code{avNNet} and  \code{sda}

\item When looping over models and resamples, the \cpkg{foreach}
   package is now being used. Now, when using parallel processing, the
   \cpkg{caret} code stays the same and parallelism is invoked using
   one of the "do" packages (eg. \cpkg{doMC}, \cpkg{doMPI}, etc). This
   affects \code{\link{train}}, \code{\link{rfe}} and
   \code{\link{sbf}}.  Their respective man pages have been revised to
   illustrate this change.

\item The order of the results produced by \code{\link{defaultSummary}} were changed
   so that the ROC AUC is first

\item A few man and C files were updated to eliminate R CMD check warnings

\item Now that we are using foreach, the verbose option in \code{\link{trainControl}},
   \code{\link{rfeControl}} and \code{\link{sbfControl}} are now defaulted to \code{FALSE}

\item \code{\link{rfe}} now returns the variable ranks in a single data frame (previously
   there were data frames in lists of lists) for each of use. This will
   will break code from previous versions. The built-in RFE functions
   were also modified

\item confusionMatrix methods for \code{\link{rfe}} and \code{\link{sbf}} were added

\item NULL values of 'method' in \code{\link{preProcess}} are no longer allowed

\item a model for ridge regression was added (\code{method = 'ridge'}) based on \code{\link[eslasticnet]{enet}}.


 }
}

\section{Changes in version 4.98}{
\itemize{

\item  A bug was fixed in a few of the bagging aggregation
   functions (found by Harlan Harris).

\item Fixed a bug spotted by Richard Marchese Robinson in createFolds
   when the outcome was numeric. The issue is that
   \code{\link{createFolds}} is trying to randomize \code{n/4} numeric
   samples to \code{k} folds. With less than 40 samples, it could not
   always do this and would generate less than \code{k} folds in some
   cases. The change will adjust the number of groups based on
   \code{n} and \code{k}.  For small samples sizes, it will not use
   stratification. For larger data sets, it will at most group the
   data into quartiles.

\item A function  \code{\link{confusionMatrix.train}} was added to get an average
   confusion matrices across resampled hold-outs when using the
   \code{\link{train}} function for classification.

\item Added another model,  \code{\link{avNNet}}, that fits several neural networks
   via the \cpkg{nnet} package using different seeds, then averages the
   predictions of the networks. There is an additional bagging
   option.

\item  The default value of the 'var' argument of  \code{\link{bag}} was changed.

\item As requested, most options can be passed from
   \code{\link{train}} to \code{\link{preProcess}}. The
   \code{\link{trainControl}} function was re-factored and several
   options (e.g. \code{k}, \code{thresh}) were combined into a single
   list option called \code{preProcOptions}. The default is consistent
   with the original configuration: \code{preProcOptions = list(thresh
   = 0.95, ICAcomp = 3, k = 5)}

\item nother option was added to \code{\link{preProcess}}. The \code{pcaComp}
   option can be used to set exactly how many components are used
   (as opposed to just a threshold). It defaults to \code{NULL} so that
   the threshold method is still used by default, but a non-null
   value of \code{pcaComp} over-rides \code{thresh}.

\item  When created within \code{\link{train}}, the call for \code{\link{preProcess}} is now
   modified to be a text string ("scrubed") because the call could
   be very large.

\item Removed two deprecated functions: \code{applyProcessing} and
\code{processData}.

\item A new version of the cell segmentation data was saved and the
   original version was moved to the package website (see
   \code{\link{segmentationData}} for location). First, several
   discrete versions of some of the predictors (with the suffix
   \code{"Status"}) were removed. Second, there are several skewed
   predictors with minimum values of zero (that would benefit from
   some transformation, such as the log). A constant value of 1 was
   added to these fields: \code{AvgIntenCh2}, \code{FiberAlign2Ch3},
   \code{FiberAlign2Ch4}, \code{SpotFiberCountCh4} and
   \code{TotalIntenCh2}.


 }
}

\section{Changes in version 4.92}{
\itemize{

\item Some tweaks were made to \code{\link{plot.train}} in a effort to get the group
key to look less horrid.

\item \code{\link{train}}, \code{\link{rfe}} and \code{\link{sbf}} are
now able to estimate the time that these models take to predict new
samples. Their respective control objects have a new option,
\code{timingSamps}, that indicates how many of the training set samples
should be used for prediction (the default of zero means do not
estimate the prediction time).

\item \code{\link{xyplot.resamples}} was modified. A new argument,
\code{what}, has values: \code{"scatter"} plots the resampled
performance values for two models; \code{"BlandAltman"} plots the
difference between two models by the average (aka a MA plot) for two
models; \code{"tTime"}, \code{"mTime"}, \code{"pTime"} plot the total
model building and tuning; time (\code{"t"}) or the final model
building time (\code{"m"}) or the time to produce predictions
(\code{"p"}) against a confidence interval for the average
performance. 2+ models can be used.

\item Three new model types were added to \code{\link{train}} using
 \code{\link[leaps]{regsubsets}} in the \cpkg{leaps} package:
 \code{"leapForward"}, \code{"leapBackward"} and \code{"leapSeq"}. The
 tuning parameter, \code{nvmax}, is the maximum number of terms in the
 subset.

\item The seed was accidentally set when \code{\link{preProcess}} used ICA (spotted
    by Allan Engelhardt)

\item \code{\link{preProcess}} was always being called (even to do nothing)
    (found by Guozhu Wen)

 }
}

\section{Changes in version 4.91}{
\itemize{

\item Added a few new models associated with the \cpkg{bst} package: bstTree,
bstLs and bstSm.

\item A model denoted as \code{"M5"} that combines M5P and M5Rules from the
\cpkg{RWeka} package. This new model uses either of these functions
depending on the tuning parameter \code{"rules"}.

 }
}

\section{Changes in version 4.90}{
\itemize{

\item Fixed a bug with \code{\link{train}} and \code{method = "penalized"}. Thanks to
Fedor for finding it.

 }
}

\section{Changes in version 4.89}{
\itemize{

\item A new tuning parameter was added for \code{M5Rules} controlling smoothing.

\item The Laplace correction value for Naive Bayes was also added as a
tuning parameter.

\item \code{\link{varImp.RandomForest}} was updated to work. It now requires a recent
version of the \cpkg{party} package.

 }
}

\section{Changes in version 4.88}{
\itemize{

\item A variable importance method was created for \cpkg{Cubist} models.

 }
}

\section{Changes in version 4.87}{
\itemize{

\item Altered the earth/MARS/FDA labels to be more exact.

\item Added cubist models from the \cpkg{Cubist} package.

\item A new option to \code{\link{trainControl}} was added to allow
users to constrain the possible predicted values of the model to the
range seen in the training set or a user-defined range. One-sided
ranges are also allowed.

 }
}

\section{Changes in version 4.85}{
\itemize{

\item Two typos fixed in \code{\link{print.rfe}} and
\code{\link{print.sbf}} (thanks to Jan Lammertyn)

 }
}

\section{Changes in version 4.83}{
\itemize{

\item \code{\link{dummyVars}} failed with formulas using \code{"."}
   (\code{all.vars} does not handle this well)

\item \code{tree2} was failing for some classification models

\item When SVM classification models are used with \code{class.weights}, the
options \code{prob.model} is automatically set to \code{FALSE} (otherwise, it
is always set to \code{TRUE}). A warning is issued that the model will
not be able to create class probabilities.

\item Also for SVM classification models, there are cases when the
probability model generates negative class probabilities. In
these cases, we assign a probability of zero then coerce the
probabilities to sum to one.

\item Several typos in the help pages were fixed (thanks to Andrew Ziem).

\item Added a new model, \code{svmRadialCost}, that fits the SVM model
and estimates the \code{sigma} parameter for each resample (to
properly capture the uncertainty).

\item \code{\link{preProcess}} has a new method called \code{"range"} that scales the predictors
to [0, 1] (which is approximate for new samples if the training set
ranges is narrow in comparison).

\item A check was added to \code{\link{train}} to make sure that, when the user passes
a data frame to  \code{\link{tuneGrid}}, the names are correct and complete.

\item \code{\link{print.train}} prints the number of classes and levels for classification
models.

 }
}

\section{Changes in version 4.78}{
\itemize{

\item Added a few bagging modules. See ?bag.

\item Added basic timings of the entire call to \code{\link{train}}, \code{\link{rfe}} and \code{\link{sbf}}
as well as the fit time of the final model. These are stored in an element
called "times".

\item The data files were updated to use better compression, which added a
higher R version dependency.

\item \code{\link{plot.train}} was pretty much re-written to more effectively use trellis theme
defaults and to allow arguments (e.g. axis labels, keys, etc) to be passed
in to over-ride the defaults.

\item Bug fix for lda bagging function

\item Bug fix for \code{\link{print.train}} when \code{preProc} is \code{NULL}

\item \code{\link{predict.BoxCoxTrans}} would go all klablooey if there were missing
    values

\item \code{\link{varImp.rpart}} was failing with some models (thanks to Maria Delgado)

 }
}

\section{Changes in version 4.77}{
\itemize{

\item A new class was added or estimating and applying the Box-Cox
transformation to data called BoxCoxTrans. This is also included as an
option to transform predictor variables. Although the Box-Tidwell
transformation was invented for this purpose, the Box-Cox transformation
is more straightforward, less prone to numerical issues and just as
effective. This method was also added to \code{\link{preProcess}}.

\item Fixed mis-labelled x axis in \code{\link{plot.train}} when a
transformation is applied for models with three tuning parameters.

\item When plotting a \code{\link{train}} object with \code{method ==
"gbm"} and multiple values of the shrinkage parameter, the ordering of
panels was improved.

\item Fixed bugs for regression prediction using \code{partDSA} and
\code{qrf}.

\item Another bug, reported by Jan Lammertyn, related to
\code{\link{extractPrediciton}} with a single predictor was also
fixed.

 }
}

\section{Changes in version 4.76}{
\itemize{

\item Fixed a bug where linear SVM models were not working for classification

 }
}

\section{Changes in version 4.75}{
\itemize{

\item \code{'gcvEearth'} which is the basic MARS model. The pruning procedure
    is the nominal one based on GCV; only the degree is tuned by \code{\link{train}}.

\item \code{'qrnn'} for quantile regression neural networks from the \cpkg{qrnn} package.

\item \code{'Boruta'} for random forests models with feature selection via the
    \cpkg{Boruta} package.

 }
}

\section{Changes in version 4.74}{
\itemize{

\item Some changes to \code{\link{print.train}}: the call is not automatically
   printed (but can be when \code{\link{print.train}} is explicitly invoked); the
   "Selected" column is also not automatically printed (but can be);
   non-table text now respects \code{options("width")}; only significant
   digits are now printed when tuning parameters are kept at a
   constant value

 }
}

\section{Changes in version 4.73}{
\itemize{

\item Bug fixes to \code{\link{preProcess}} related to complete.cases and a single predictor.

\item For knn models (knn3 and knnreg), added automatic conversion of data frames
to matrices

 }
}

\section{Changes in version 4.72}{
\itemize{

\item A new function for \code{\link{rfe}} with \cpkg{gam} was added.

\item "Down-sampling" was implemented with \code{\link{bag}} so that, for
classification models, each class has the same number of classes
as the smallest class.

\item Added a new class, \code{\link{dummyVars}}, that creates an entire set of
binary dummy variables (instead of the reduced, full rank set).
The initial code was suggested by Gabor Grothendieck on R-Help.
The predict method is used to create dummy variables for any
data set.

\item Added \code{\link{R2}} and \code{\link{RMSE}} functions for evaluating regression models

\item \code{\link{varImp.gam}} failed to recognize objects from \cpkg{mgcv}

\item a small fix to test a logical vector \code{\link{filterVarImp}}

\item When \code{\link{diff.resamples}} calculated the number of comparisons,
   the \code{"models"} argument was ignored.

\item \code{\link{predict.bag}} was ignoring \code{type = "prob"}

\item Minor updates to conform to R 2.13.0

 }
}

\section{Changes in version 4.70}{
\itemize{

\item Added a warning to \code{\link{train}} when class levels are not
valid R variable names.

\item Fixed a bug in the variable importance function for
\code{multinom} objects.

\item Added p-value adjustments to
\code{\link{summary.diff.resamples}}. Confidence intervals in
\code{\link{dotplot.diff.resamples}} are adjusted accordingly if the
Bonferroni is used.

\item For \code{\link{dotplot.resamples}}, no point was plotted when
the upper and/or lower interval values were NaN. Now, the point is
plotted but without the interval bars.

\item Updated \code{\link{print.rfe}} to correctly describe new
resampling methods.

 }
}

\section{Changes in version 4.69}{
\itemize{

\item Fixed a bug in \code{\link{predict.rfe}} where an error was
thrown even though the required predictors were in \code{newdata}.

\item Changed \code{\link{preProcess}} so that centering and scaling are both automatic
when PCA or ICA are requested.

 }
}

\section{Changes in version 4.68}{
\itemize{

\item Added two functions, \code{\link{checkResamples}} and
\code{\link{checkConditionalX}} that identify predictor data with
degenerate distributions when conditioned on a factor.

\item Added a high content screening data set (\code{\link{segmentedData}}) from Hill et
al. Impact of image segmentation on high-content screening data quality
for SK-BR-3 cells. BMC bioinformatics (2007) vol. 8 (1) pp. 340.

\item Fixed bugs in how \code{\link{sbf}} objects were printed (when using repeated
CV) and classification models with \cpkg{earth} and \code{classProbs = TRUE}.


 }
}

\section{Changes in version 4.67}{
\itemize{

\item Added \code{\link{predict.rfe}}

\item Added imputation using bagged regression trees to
\code{\link{preProcess}}.

\item Fixed bug in \code{\link{varImp.rfe}} that caused incorrect
results (thanks to Lawrence Mosley for the find).

 }
}

\section{Changes in version 4.65}{
\itemize{

\item Fixed a bug where \code{\link{train}} would not allow knn imputation.

\item \code{\link{filterVarImp}} and \code{roc} now check for missing values and
use complete data for each predictor (instead of case-
wise deletion across all predictors).

 }
}

\section{Changes in version 4.64}{
\itemize{

\item Fixed bug introduced in the last version with
\code{createDataPartition(... list = FALSE)}.

\item Fixed a bug predicting class probabilities when using
\cpkg{earth}/glm models

\item Fixed a bug that occurred when \code{\link{train}} was used with
\code{ctree} or \code{tree2} methods.

\item Fixed bugs in \code{\link{rfe}} and \code{\link{sbf}} when running in
parallel; not all the resampling results were saved

 }
}

\section{Changes in version 4.63}{
\itemize{

\item A p-value from McNemar's test was added to \code{\link{confusionMatrix}}.

\item Updated \code{\link{print.train}} so that constant parameters are not
  shown in the table (but a note is written below the table
  instead). Also, the output was changed slightly to be
  more easily read (I hope)

\item Adapted \code{\link{varImp.gam}} to work with either \cpkg{mgcv} or \cpkg{gam} packages.

\item Expanded the tuning parameters for \code{lvq}.

\item Some of the examples in the Model Building vignette were changed

\item Added bootstrap 632 rule and repeated cross-validation
  to \code{\link{trainControl}}.

\item A new function, \code{\link{createMultiFolds}}, is
  used to generate indices for repeated CV.

\item The various resampling functions now have *named* lists
  as output (with prefixes "Fold" for cv and repeated cv
  and "Resample" otherwise)

\item Pre-processing has been added to \code{\link{train}} with the
  \code{\link{preProcess}} argument. This has been tested when caret
  function are used with \code{\link{rfe}} and \code{\link{sbf}} (via
  \code{\link{caretFuncs}} and \code{\link{caretSBF}}, respectively).

\item When \code{preProcess(method = "spatialSign")}, centering and
  scaling is done automatically too. Also, a bug was fixed
  that stopped the transformation from being executed.

\item knn imputation was added to \code{\link{preProcess}}. The \cpkg{RANN} package
  is used to find the neighbors (the knn impute function in
  the impute library was consistently generating segmentation
  faults, so we wrote our own).

\item Changed the behavior of \code{\link{preProcess}} in situations where
  scaling is requested but there is no variation in the
  predictor. Previously, the method would fail. Now a
  warning is issued and the value of the standard
  deviation is coerced to be one (so that scaling has
  no effect).

 }
}

\section{Changes in version 4.62}{
\itemize{

\item Added \code{gam} from \cpkg{mgcv} (with smoothing splines and feature
selection) and \code{gam} from \cpkg{gam} (with basic splines and loess)
smoothers. For these models, a formula is derived
from the data where "near zero variance" predictors
(see \code{\link{nearZerVar}}) are excluded and predictors with
less than 10 distinct values are entered as linear
(i.e. unsmoothed) terms.

 }
}

\section{Changes in version 4.61}{
\itemize{

\item Changed \cpkg{earth} fit for classification models to use the
\code{glm} argument with a binomial family.

\item Added \code{\link{varImp.multinom}}, which is based on the absolute
values of the model coefficients

 }
}

\section{Changes in version 4.60}{
\itemize{

\item The feature selection vignette was updated slightly (again).

 }
}

\section{Changes in version 4.59}{
\itemize{

\item Updated \code{\link{rfe}} and \code{\link{sbf}} to include class probabilities
in performance calculations.

\item Also, the names of the resampling indices were harmonized
across \code{\link{train}}, \code{\link{rfe}} and \code{\link{sbf}}.

\item The feature selection vignette was updated slightly.

 }
}

\section{Changes in version 4.58}{
\itemize{

\item Added the ability to include class probabilities in
performance calculations. See \code{\link{trainControl}} and
\code{\link{twoClassSummary}}.

\item Updated and restructured the main vignette.

 }
}

\section{Changes in version 4.57}{
\itemize{

\item Internal changes related to how predictions from models are
stored and summarized. With the exception of loo, the model
performance values are calculated by the workers instead of
the main program. This should reduce i/o and lay some
groundwork for upcoming changes.

\item The default grid for \cpkg{relaxo} models were changed based on
and initial model fit.

\item \cpkg{partDSA} model predictions were modified; there were cases
where the user might request X partitions, but the model
only produced Y < X. In these cases, the partitions for
missing models were replaced with the largest model
that was fit.

\item The function \code{\link{modelLookup}} was put in the namespace and
a man file was added.

\item The names of the resample indices are automatically
reset, even if the user specified them.

 }
}

\section{Changes in version 4.56}{
\itemize{

\item Fixed a bug generated a few versions ago where \code{\link{varImp}}
for \code{plsda} and \code{fda} objects crashed.

 }
}

\section{Changes in version 4.55}{
\itemize{

\item When computing the scale parameter for RBF kernels, the
option to automatically scale the data was changed to \code{TRUE}

 }
}

\section{Changes in version 4.54}{
\itemize{

\item Added \code{logic.bagging} in \pkg{logicFT} with \code{method  = "logicBag"}

 }
}

\section{Changes in version 4.53}{
\itemize{

\item Fixed a bug in \code{\link{varImp.train}} related to nearest shrunken
centroid models.

\item Added logic regression and logic forests

 }
}

\section{Changes in version 4.51}{
\itemize{

\item Added an option to \code{\link{splom.resamples}} so that the variables in the
scatter plots are models or metrics.

 }
}

\section{Changes in version 4.50}{
\itemize{

\item Added \code{\link{dotplot.resamples}} plus acknowledgements to Hothorn et al.
(2005) and Eugster et al. (2008)

 }
}

\section{Changes in version 4.49}{
\itemize{

\item Enhanced the \code{tuneGrid} option to allow a function
to be passed in.
 }
}

\section{Changes in version 4.48}{
\itemize{

\item Added a \code{prcomp} method for the \code{resamples} class

 }
}

\section{Changes in version 4.47}{
\itemize{

\item Extended \code{\link{resamples}} to work with \code{\link{rfe}} and \code{\link{sbf}}
 }
}

\section{Changes in version 4.46}{
\itemize{

\item Cleaned up some of the man files for the resamples class
and added \code{\link{parallel.resamples}}.

\item Fixed a bug in \code{\link{diff.resamples}} where \code{...} were
not being passed to the test statistic function.

\item Added more log messages in \code{\link{train}} when running verbose.

\item Added the German credit data set.
 }
}

\section{Changes in version 4.45}{
\itemize{

\item Added a general framework for bagging models via the
\code{\link{bag}} function. Also, model type \code{"hdda"} from the
\cpkg{HDclassif} package was added.

 }
}

\section{Changes in version 4.44}{
\itemize{

\item Added \cpkg{neuralnet}, \code{quantregForest} and \code{rda}
(from \cpkg{rda}) to \code{\link{train}}.  Since there is a naming
conflict with \code{rda} from \cpkg{mda}, the \cpkg{rda} model was
given a method value of \code{"scrda"}.  } }

\section{Changes in version 4.43}{
\itemize{

\item Tthe resampling estimate of the standard deviation given
  by \code{\link{train}} since v 4.39 was wrong

\item A new field was added to \code{\link{varImp.mvr}} called
  \code{"estimate"}.  In cases where the mvr model had multiple
  estimates of performance (e.g. training set, CV, etc) the user can
  now select which estimate they want to be used in the importance
  calculation (thanks to Sophie Bréand for finding this)
}
}

\section{Changes in version 4.42}{
\itemize{

\item Added \code{\link{predict.sbf}} and modified the structure of
the \code{\link{sbf}} helper functions. The \code{"score"} function
only computes the metric used to filter and the filter function does
the actual filtering. This was changed so that FDR corrections or
other operations that use all of the p-values can be computed.

\item Also, the formatting of p-values in \code{\link{print.confusionMatrix}}
was changed

\item An argument was added to \code{\link{maxDissim}}
so that the variable name is returned instead of the index.

\item Independent component analysis was added to the list of
pre-processing operations and a new model ("icr") was
added to fit a pcr-like model with the ICA components.

 }
}

\section{Changes in version 4.40}{
\itemize{

\item Added \code{hda} and cleaned up the \cpkg{caret} training vignette

 }
}

\section{Changes in version 4.39}{
\itemize{

\item Added several classes for examining the resampling results. There
are methods for estimating pair-wise differences and lattice
functions for visualization. The training vignette has a new
section describing the new features.

 }
}

\section{Changes in version 4.38}{
\itemize{

\item Added \cpkg{partDSA} and \code{stepAIC} for linear models and
generalized linear models

 }
}

\section{Changes in version 4.37}{
\itemize{

\item Fixed a new bug in how resampling results are exported

 }
}

\section{Changes in version 4.36}{
\itemize{

\item Added penalized linear models from the \cpkg{foba} package

 }
}

\section{Changes in version 4.35}{
\itemize{

\item Added \code{rocc} classification and fixed a typo.
 }
}

\section{Changes in version 4.34}{
\itemize{

\item Added two new data sets: \code{\link{dhfr}} and \code{\link{cars}}

 }
}

\section{Changes in version 4.33}{
\itemize{

\item Added GAMens (ensembles using gams)

\item Fixed a bug in \code{roc} that, for some data cases, would reverse the "positive"
class and report sensitivity as specificity and vice-versa.

 }
}

\section{Changes in version 4.32}{
\itemize{

\item Added a parallel random forest method in \code{\link{train}} using the \cpkg{foreach} package.

\item Also added penalized logistic regression using the \code{plr} function in the
\cpkg{stepPlr} package.
 }
}

\section{Changes in version 4.31}{
\itemize{

\item Added a new feature selection function, \code{\link{sbf}} (for selection by filter).

\item Fixed bug in \code{\link{rfe}} that did not affect the results, but did produce
a warning.

\item A new model function, \code{\link{nullModel}}, was added. This model fits either the
mean only model for regression or the majority class model for classification.

\item Also, ldaFuncs had a bug fixed.

\item Minor changes to Rd files

 }
}

\section{Changes in version 4.30}{
\itemize{

\item For whatever reason, there is now a function in the \cpkg{spls} package
by the name of splsda that does the same thing. A few functions
and a man page were changed to ensure backwards compatibility.

 }
}

\section{Changes in version 4.29}{
\itemize{

\item Added stepwise variable selection for \code{lda} and \code{qda} using the
\code{stepclass} function in \cpkg{klaR}

 }
}

\section{Changes in version 4.28}{
\itemize{

\item Added robust linear and quadratic discriminant analysis functions
from \cpkg{rrcov}.

\item Also added another column to the output of
\code{\link{extractProb}} and \code{\link{extractPrediction}} that
saves the name of the model object so that you can have multiple
models of the same type and tell which predictions came from which
model.

\item Changes were made to \code{plotClassProbs}: new parameters were added
and densityplots can now be produced.

 }
}

\section{Changes in version 4.27}{
\itemize{

\item Added \cpkg{nodeHarvest}

 }
}

\section{Changes in version 4.26}{
\itemize{

\item Fixed a bug in \code{\link{caretFunc}} that led to NaN variable rankings, so
that the first k terms were always selected.

 }
}

\section{Changes in version 4.25}{
\itemize{

\item Added parallel processing functionality for \code{\link{rfe}}

 }
}

\section{Changes in version 4.24}{
\itemize{

\item Added the ability to use custom metrics with \code{\link{rfe}}

 }
}

\section{Changes in version 4.22}{
\itemize{

\item Many Rd changes to work with updated parser.

 }
}

\section{Changes in version 4.21}{
\itemize{

\item Re-saved data in more compressed format

 }
}

\section{Changes in version 4.20}{
\itemize{

\item Added \code{pcr} as a method

 }
}

\section{Changes in version 4.19}{
\itemize{

\item Weights argument was added to \code{\link{train}} for models that accept weights

\item Also, a bug was fixed for lasso regression (wrong lambda
specification) and other for prediction in naive Bayes models
with a single predictor.
 }
}

\section{Changes in version 4.18}{
\itemize{

\item Fixed bug in new \code{\link{nearZeroVar}} and updated \code{format.earth} so that it
does not automatically print the formula
 }
}

\section{Changes in version 4.17}{
\itemize{

\item Added a new version of \code{\link{nearZeroVar}} from Allan Engelhardt that is
much faster
 }
}

\section{Changes in version 4.16}{
\itemize{

\item Fixed bugs in \code{\link{extractProb}} (for glmnet) and \code{\link{filterVarImp}}.

\item For glmnet, the user can now pass in their own value of family to
\code{\link{train}} (otherwise \code{\link{train}} will set it depending on the mode of the
outcome). However, glmnet doesn't have much support for families at
this time, so you can't change links or try other distributions.
 }
}

\section{Changes in version 4.15}{
\itemize{

\item Fixed bug in \code{\link{createFolds}} when the smallest y value is more than 25%
of the data

 }
}

\section{Changes in version 4.14}{
\itemize{

\item Fixed bug in \code{\link{print.train}}
 }
}

\section{Changes in version 4.13}{
\itemize{

\item Added vbmp from \cpkg{vbmp} package
 }
}

\section{Changes in version 4.12}{
\itemize{

\item Added additional error check to \code{\link{confusionMatrix}}

\item Fixed an absurd typo in \code{\link{print.confusionMatrix}}

 }
}

\section{Changes in version 4.11}{
\itemize{

\item Added: linear kernels for svm, rvm and Gaussian processes; \code{rlm} from \cpkg{MASS}; a knn regression model, knnreg

\item A set of functions (class "\code{\link{classDist}}") to computes the class
    centroids and covariance matrix for a training set for
    determining Mahalanobis distances of samples to each class
    centroid was added

\item a set of functions (\code{\link{rfe}}) for doing recursive feature selection
    (aka backwards selection). A new vignette was added for more
    details
 }
}

\section{Changes in version 4.10}{
\itemize{

\item Added \code{OneR} and \code{PART} from \cpkg{RWeka}

 }
}

\section{Changes in version 4.09}{
\itemize{

\item Fixed error in documentation for \code{confusionMatrix}. The old doc had \code{"Detection Prevalence = A/(A+B)"} and the new one has \code{"Detection Prevalence =(A+B)(A+B+C+D)"}. The underlying code was correct.

\item  Added \code{lars} (\code{fraction} and \code{step} as parameters)

 }
}

\section{Changes in version 4.08}{
\itemize{

\item Updated \code{\link{train}} and \code{bagEarth} to allow \code{earth}
for classification models

 }
}



\section{Changes in version 4.07}{
\itemize{

\item Added \cpkg{glmnet} models

 }
}

\section{Changes in version 4.06}{
\itemize{

\item Added code for sparse PLS classification.

\item Fix a bug in prediction for \code{caTools::LogitBoost}

 }
}

\section{Changes in version 4.05}{
\itemize{

\item Updated again for more stringent R CMD check tests in R-devel 2.9

 }
}



\section{Changes in version 4.04}{
\itemize{

\item Updated for more stringent R CMD check tests in R-devel 2.9

 }
}

\section{Changes in version 4.03}{
\itemize{

\item Significant internal changes were made to how the models are
fit. Now, the function used to compute the models is passed in as a
parameter (defaulting to \code{lapply}). In this way, users can use
their own parallel processing software without new versions of
\cpkg{caret}. Examples are given in \code{\link{train}}.

\item Also, fixed a bug where the MSE (instead of RMSE) was reported
for random forest OOB resampling

\item There are more examples in \code{\link{train}}.

\item Changes to \code{confusionMatrix}, \code{sensitivity},
\code{specificity} and the predictive value functions: each was made
more generic with default and \code{table} methods;
\code{confusionMatrix} "extractor" functions for matrices and tables
were added; the pos/neg predicted value computations were changed to
incorporate prevalence; prevalence was added as an option to several
functions; detection rate and prevalence statistics were added to
\code{confusionMatrix}; and the examples were expanded in the help
files.

\item This version of caret will break compatibility with
\pkg{caretLSF} and \pkg{caretNWS}. However, these packages will not be
needed now and will be deprecated.

 }
}

\section{Changes in version 3.51}{
\itemize{

\item Updated the man files and manuals.

 }
}

\section{Changes in version 3.50}{
\itemize{

\item Added \code{qda}, \code{mda} and \code{pda}.

 }
}


\section{Changes in version 3.49}{
\itemize{

\item Fixed bug in \code{resampleHist}. Also added a check in the \code{\link{train}} functions
that error trapped with \code{glm} models and > 2 classes

 }
}


\section{Changes in version 3.48}{
\itemize{

\item Added \code{glm}s. Also, added \code{varImp.bagEarth} to the
namespace.

 }
}

\section{Changes in version 3.47}{
\itemize{

\item Added \code{sda} from the \cpkg{sda} package. There was a naming
conflict between \code{sda::sda} and \code{sparseLDA:::sda}. The
method value for \code{sparseLDA} was changed from "sda" to
"sparseLDA".

 }
}


\section{Changes in version 3.46}{
\itemize{

\item Added \code{spls} from the \cpkg{spls} package

 }
}

\section{Changes in version 3.45}{
\itemize{

\item Added caching of \cpkg{RWeka} objects to that they can be saved
to the file system and used in other sessions. (changes per Kurt
Hornik on 2008-10-05)

 }
}

\section{Changes in version 3.44}{
\itemize{

\item Added \code{sda} from the \cpkg{sparseLDA} package (not on
CRAN).

\item Also, a bug was fixed where the ellipses were not passed into a
few of the newer models (such as \code{penalized} and \code{ppr})

 }
}

\section{Changes in version 3.43}{
\itemize{

\item Added the penalized model from the \cpkg{penalized} package. In
\cpkg{caret}, it is regression only although the package allows for
classification via glm models. However, it does not allow the user to
pass the classes in (just an indicator matrix). Because of this, it
doesn't really work with the rest of the classification tools in the
package.

 }
}

\section{Changes in version 3.42}{
\itemize{

\item Added a little more formatting to \code{\link{print.train}}

 }
}

\section{Changes in version 3.41}{
\itemize{

\item For \code{gbm}, let the user over-ride the default value of the
\code{distribution} argument (brought us by Peter Tait via RHelp).

 }
}



\section{Changes in version 3.40}{
\itemize{

\item Changed \code{predict.preProcess} so that it doesn't crash if
\code{newdata} does not have all of the variables used to originally
pre-process *unless* PCA processing was requested.

 }
}



\section{Changes in version 3.39}{
\itemize{

\item Fixed bug in \code{varImp.rpart} when the model had only primary
splits.

\item Minor changes to the Affy normalization code

\item Changed typo in \code{predictors} man page

 }
}

\section{Changes in version 3.38}{
\itemize{

\item Added a new class called \code{predictors} that returns the
names of the predictors that were used in the final model.

\item Also added \code{ppr} from the \code{stats} package.

\item Minor update to the project web page to deal with IE issues


 }
}

\section{Changes in version 3.37}{
\itemize{

\item Added the ability of \code{\link{train}} to use custom made performance
functions so that the tuning parameters can be chosen on the basis of
things other than RMSE/R-squared and Accuracy/Kappa.

\item A new argument was added to \code{\link{trainControl}} called
    "summaryFunction" that is used to specify the function used to
    compute performance metrics. The default function preserves the
    functionality prior to this new version

\item a new argument to \code{\link{train}} is "maximize" which is a logical
    for whether the performance measure specified in the "metric"
    argument to \code{\link{train}} should be maximized or minimized.

\item The selection function specified in \code{\link{trainControl}} carries
     the maximize argument with it so that customized performance
     metrics can be used.

\item A bug was fixed in \code{confusionMatrix} (thanks to Gabor
Grothendieck)

\item Another bug was fixed related to predictions from least square
SVMs

 }
}


\section{Changes in version 3.36}{
\itemize{

\item Added \code{superpc} from the \cpkg{superpc} package. One note:
the \code{data} argument that is passed to \code{superpc} is saved in
the object that results from \code{superpc.train}. This is used later
in the prediction function.

 }
}

\section{Changes in version 3.35}{
\itemize{

\item Added \code{slda} from \cpkg{ipred}.

 }
}


\section{Changes in version 3.34}{
\itemize{

\item Fixed a few bugs related to the lattice plots from version 3.33.

\item Also added the ripper (aka \code{JRip}) and logistic model trees
from \cpkg{RWeka}

 }
}

\section{Changes in version 3.33}{
\itemize{

\item Added \code{xyplot.train}, \code{densityplot.train},
\code{histogram.train} and \code{stripplot.train}. These are all
functions to plot the resampling points. There is some overlap between
these functions, \code{plot.train} and
\code{resampleHist}. \code{plot.train} gives the average metrics only
while these plot all of the resampled performance
metrics. \code{resampleHist} could plot all of the points, but only
for the final optimal set of predictors.

\item To use these functions, there is a new argument in
\code{\link{trainControl}} called \code{\link{returnResamp}} which should have
values "none", "final" and "all". The default is "final" to be
consistent with previous versions, but "all" should be specified to
use these new functions to their fullest.

 }
}

\section{Changes in version 3.32}{
\itemize{

\item The functions \code{\link{predict.train}} and \code{\link{predict.list}} were
added to use as alternatives to the \code{\link{extractPrediction}} and
\code{\link{extractProbs}} functions.

\item Added C4.5 (aka \code{J48}) and rules-based models (M5 prime) from
\cpkg{RWeka}.

\item Also added \code{logitBoost} from the \cpkg{caTools}
package. This package doesn't have a namespace and \cpkg{RWeka} has a
function with the same name. It was suggested to use the "::" prefix
to differentiate them (but we'll see how this works).

 }
}



