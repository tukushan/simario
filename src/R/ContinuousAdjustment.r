#' Continuous adjustments
#' 
#' Before or during the simulation the user may wish to specify changes to continuous variables.
#' Eg: a user may wish to decrease the number of cigarettes smoked per day by 20 for every 
#' child with a mother who smokes 40 or more cigarettes a day) 
#' The user specifies from the user interface desired increments (or decrements) for all micro units
#' in particular categories.  
#' 
#' Create empty continuous variable adjustment matrices.
#' Initial matrix values are NA (i.e: no adjustment).
#'
#' @param num.categories
#' the number of categories for the particular continuous variable
#' 
#' @param numiterations
#' The number of iterations in the simulation
#' 
#' @export
#' @examples
#' \dontrun{
#' numiterations=NUM_ITERATIONS
#' num.categories=5
#' createContAdjustmentMatrix(num.categories, numiterations)
#' }
#' createContAdjustmentMatrix <- function(num.categories, numiterations) {
	#' colnames = c("Presimulation", paste("Iteration",1:numiterations))
	#' namedMatrix(num.categories, cols=colnames)
#' }


#Oman's take on it ... but we don't actually need it at all!!
#' @examples
#' \dontrun{
#' #vector
#' unitRuns=c(1:15)
#' binbreaks=c(0,4,8,15)
#' breakLast=NULL
#' createContTypicalDistAcrossRuns(unitRuns, binbreaks, breakLast)
#' 
#' #matrix
#' unitRuns=matrix(1:15, nrow = 5)
#' binbreaks=c(0,4,8,15)
#' breakLast=NULL
#' createContTypicalDistAcrossRuns(unitRuns, binbreaks, breakLast)
#' }

#createContTypicalDistAcrossRuns <- function(unitRuns, binbreaks, breakLast = NULL) {
#	if(is.vector(unitRuns)) {
#		prop.table(table(bin(unitRuns, binbreaks, breakLast), useNA = 'ifany'))
#	}
	
#	else {
#		unitRunsPropsBinned <- apply(unitRuns, COL, function(units) {
#			prop.table(table(bin(units, binbreaks, breakLast), useNA = 'ifany'))
#		})
#		rowMeans(unitRunsPropsBinned)
#	}
#}