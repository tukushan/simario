# Simulation support functions.
#
# Requires support.r
# 
# Author: Oliver Mannion
###############################################################################

#' Creates a set of run outputs. 
#' 
#' @param freqvars
#' 			frequency variable names, or NULL
#' @param cfreqvars
#' 			continuous frequency variable names, or NULL
#' @param meanvars
#' 			mean variable names, or NULL
#' @param freqs.args
#' 			frequency variable args, or NULL
#' @param means.args
#' 			mean variable args, or NULL
#' @return
#'  	list(freq = freq, cfreq = cfreq, mean.sets = mean.sets, mean.grouped = mean.grouped)
#' 		each element of the list is a list of empty catvar or convar elements, either grouped
#' 		into sets (mean.grouped and mean.sets) or listed straight.
#' 
#' @examples 
#' \dontrun{
#' catvars <- NULL
#' convars <- NULL
#' means.args <- NULL
#' mean.grouped.spec <- NULL
#'  
#' catvars <- c("msmoke", "fsmoke", "single", "kids", "householdsize", "welfare", "mhrswrk", "fhrswrk", "accom", "homeown", "bedrooms",	"chpar", "chres")
#' convars <- c("gptotvis", "hadmtot", "houtptot", "gpresp", "gpmorb", "gpprev")
#' 
#' freqs.args <- list( by.ethnicity = list(grpbycoding=codings$r1stchildethn) )
#' means.args <- list(	all = list(), males = list(logiset=childsets$males),	females = list(logiset=childsets$females),pacific = list(logiset=childsets$pacific),	maori = list(logiset=childsets$maori))
#' 
#' freqvars <- catvars
#' runstats <- createRunOutputs(catvars, convars, means.args, mean.grouped.spec)
#' }
createRunOutputs <- function(freqvars, cfreqvars, meanvars, freqs.args, means.args) {
	# Frequency tables for categorical variables
	freqslist <- namedList(freqvars)
	
	# Frequency tables for continuous variables
	cfreqs <- namedList(cfreqvars)
	
	# Mean tables for continuous variables
	meanslist <- namedList(meanvars)
	
	freqs <- lapply(freqs.args, function(x) freqslist)
	attr(freqs, "args.list") <- freqs.args
	
	means <- lapply(means.args, function(x) meanslist)
	attr(means, "args.list") <- means.args
	
	list(freqs = freqs, 
			cfreqs = cfreqs, 
			means = means, 
			summaries = meanslist,
			quantiles = meanslist
	)
	
}

#' Loads and merges a CSV/XLS file with the supplied values (keys). ie:
#' returns a dataframe (excluding key_column_name) for the supplied 
#' values that exist in key_column_name of the file 
#' 
#' @param filedir
#'  file directory, with or without trailing slash
#' @param filename
#'  file name. File type is determined from the file extension, eg: ".csv", ".xls", ".xlsx" 
#' @param  key_column_name 
#'  a column in the propensity files to merge on, and select
#'  those values that appear in selected_keys
#' 
#' @param selected_keys
#'  a vector of selected keys that are to be retained in the propensities
#' 
#' @return 
#' a dataframe
#'
#' @export 
#' @examples
#' \dontrun{
#' selected_keys <- children$A0
#' key_column_name <- "A0"
#' filedir <- "D:/workspace.sim/MELC/CHDS/propensityFiles/"
#' loadMergedFile(key_column_name, selected_keys, propensityfiledir)
#' }
loadMergedFile <- function(filedir, filename, key_column_name, selected_keys) {
	dataframe <- read_file(filedir, filename)
	mergeAndRemoveKeyColumn(dataframe, key_column_name, selected_keys)
}

#' Takes a result row and returns the means and error amounts as separate vectors in a matrix or list.
#' 
#' @param result.row
#'  a result row, ie: a vector with values named Mean and Lower eg:
#' 
#'>  envs$`Scenario 1`$years1_5$runstats.collated$means$all$kids["Total",]
#'     Mean    Lower    Upper 
#' 10.99488 10.62256 11.36721 
#' 
#'  if there are no values named Mean, then it will be assumed that all values
#'  are Means and that Lower is 0.
#' 
#' @param simplify
#'  if TRUE (default), returns a matrix instead of a list. 
#' 
#' @return
#'  a matrix/list of means and errs. The first row/means vector is the means from the result row, and the
#'  second row/errs vector is the difference between each mean and it's lower value.
#' 
#' @examples
#' \dontrun{
#' 
#' result.row <- envs$`Scenario 1`$years1_5$runstats.collated$means$all$kids["Total",]
#' \dontrun{
#' > result.row
#'     Mean    Lower    Upper 
#' 10.99488 10.62256 11.36721
#'  
#' > result.as.means.and.errs(result.row)
#' $means
#' 
#' 10.99488 
#' 
#' $errs
#' 
#' 0.3723213 
#'
#' }
#' result.row <- c("0%"=5,"20%"=5,"40%"=9,"60%"=11,"80%"=15,"100%"=50)
#' result.row <- structure(c(5, 5, 5, 5, 5, 5, 9, 9, 9, 11, 11, 11, 15, 15, 15,50.5, 6.02828342338857, 94.9717165766114), .Names = c("0% Mean","0% Lower", "0% Upper", "20% Mean", "20% Lower", "20% Upper","40% Mean", "40% Lower", "40% Upper", "60% Mean", "60% Lower","60% Upper", "80% Mean", "80% Lower", "80% Upper", "100% Mean","100% Lower", "100% Upper"))
#' 
#' result.row <- env.base$modules$years1_5$runstats.collated$quantiles$kids["All Years",]
#' result.row <- env.scenario$modules$years1_5$runstats.collated$quantiles$kids["All Years",]
#' result.row <- env.scenario$modules$years1_5$runstats.collated$means$all$kids["All Years",]
#' result.row <- na.omit(env.scenario$modules$years6_13$runstats.collated$histo[["cond"]]["All Years",])
#' 
#' result.as.means.and.errs(result.row.scenario)
#' 
#' result.as.means.and.errs(result.row)
#' }
result.as.means.and.errs <- function(result.row, simplify = T) {
	ind.means <- grep("Mean", names(result.row))
	ind.lowers <- grep("Lower", names(result.row))
	
	assert(length(ind.means) == length(ind.lowers))
	
	has_CIs <- length(ind.lowers) > 0
	if(!has_CIs) {
		result.row.means <- result.row
		result.row.err <- structure(rep(0, length(result.row.means)), .Names = names(result.row.means))
	} else {
		result.row.means <- result.row[ind.means]
		names(result.row.means) <- trim(gsub("Mean", "", names(result.row.means)))
		
		result.row.err <- result.row.means - result.row[ind.lowers]
	}
	
	if (simplify) {
		rbind(means=result.row.means, errs=result.row.err)
	} else {
		list(means=result.row.means, errs=result.row.err)
	}
}	

#' Produce a proportioned table for x, using
#' the specified coding as names and 
#' setting the "meta" attribute to "varname"
#' of coding.
#' 
#' @param x
#'  vector of values
#' @param coding
#'  a coding variable. names(coding) is the labels
#'  attr(coding, "varname") is a named element in xlist
#' @return 
#'  a table (proportions) with names specified by coding 
#' @examples
#' \dontrun{
#' table.catvar(children$SESBTH, codings$SESBTH)
#' x <- simframe$z1singleLvl1 ; coding <- codings$z1singleLvl1
#' table.catvar(simframe$z1singleLvl1, codings$z1singleLvl1)
#' }
table.catvar <- function (x, coding) {
	
	varname <- attr(coding, "varname")
	
	tbl <- prop.table(table(x)) * 100
	
	# match names into codings
	codings.indices <- match(names(tbl), coding)
	names(tbl) <- paste(names(coding)[codings.indices], "(%)")
	
	attr(tbl, "meta") <- c("varname" = varname)
	
	tbl
}

#' Display a vector of continuous values in a table using the
#' breaks supplied.
#' Attachs a meta attribute with varname
#' 
#' @param x
#'  vector of continous values
#' 
#' @param breaks
#' a numeric vector of two or more cut points
#' NB: note that the cut point value is not included in the bin 
#' (ie: include.lowest = FALSE)
#' Therefore the very first cut point must be less than min(x)
#' 
#' @param varname
#'  added as a tag on the meta attribute
#' 
#' @examples
#' \dontrun{
#' x <- env.scenario$simframe$bwkg
#' breaks <- binbreaks$bwkg
#' 
#' table.contvar(env.scenario$simframe$bwkg, binbreaks$bwkg, "bwkg")
#' }
table.contvar <- function (x, breaks, varname) {
	tbl <- prop.table(table(bin(x, breaks, breaklast=NULL), useNA='ifany')) * 100
	attr(tbl, "meta") <- c("varname" = varname)
	tbl
}

cat("Loaded simulate\n")
