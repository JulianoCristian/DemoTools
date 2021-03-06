
# Author: tim
###############################################################################

#' The basic Sprague age-splitting method.
#' 
#' @description This method is used to interpolate counts based on the Sprague formula. It is based on the first stage of the Sprague R 
#' script prepared by Thomas Buettner and Patrick Gerland, itself based on the description
#' in Siegel and Swanson, 2004, p. 727.
#' 
#' @param popmat numeric. A matrix of population counts in 5-year age groups with integer-labeled 
#' margins (age in rows and year in columns).
#' @param Age integer. Vector of lower age bound of age groups. Detected from row names of \code{popmat} if missing.
#' @param OAG logical. Whether or not the final age group open. Default \code{TRUE}.
#' @details Ages should refer to lower age bounds, ending in the open age group in the last row (not a closed terminal age). Dimension labelling is necessary. There must be at least six age groups (including the open group). One year of data will work as well, as long as it's given as or coercible to a single-column matrix. This method may produce negative values, most likely in the youngest or oldest ages.
#' 
#' If the highest age does not end in a 0 or 5, and \code{OAG == TRUE}, then the open age will be grouped down to the next 
#' highest age ending in 0 or 5. If the highest age does not end in a 0 or 5, and \code{OAG == FALSE}, then results extend
#' to single ages covering the entire 5-year age group. 
#' 
#' @return An age-period matrix of split population counts with the same number of 
#' columns as \code{popmat}, and single ages in rows.
#' 
#' @references 
#' \insertRef{sprague1880explanation}{DemoTools}
#' \insertRef{shryock1973methods}{DemoTools}
#' \insertRef{siegel2004methods}{DemoTools}
#' @export
#' 
#' @examples 
#' head(pop5_mat) # this is the entire matrix
#' # the last value is an open age group, preserve as such:
#' p1 <- sprague(pop5_mat, OAG = TRUE)
#' head(p1); tail(p1)
#' colSums(p1) - colSums(pop5_mat) 
#' 
#' # another case, starting with single ages
#' Age         <- 0:100
#' # notice how this particular case produces a negative value in the last age
#' # before OAG:
#' pops <- sprague(popmat = pop1m_ind, Age = Age, OAG = TRUE)
#' 
#' \dontrun{
#' yrs <- as.character(1950:1954)
#'matplot(0:100,p1, type = 'l', col = 5:9,lty = 1,xlab = 'Age',ylab = 'Counts',
#'main= 'Ungrouped counts')
#'legend('topright',
#'title = 'Year',
#'lty=1,
#'col=5:9,
#'legend = yrs
#')
#' }

sprague <- function(
		popmat, 
		Age = as.integer(rownames(as.matrix(popmat))), 
		OAG = TRUE){
	popmat            <- as.matrix(popmat)
	

	punif1            <- apply(popmat, 2, splitUniform, Age = Age, OAG = OAG)
	# this is innocuous if ages are already grouped
	pop5              <- apply(punif1, 2, groupAges, Age = as.integer(rownames(punif1)), N = 5, shiftdown = 0)
	# depending on OAG, highest age may shift down.
	punif1            <- apply(pop5, 2, splitUniform, Age = as.integer(rownames(pop5)), OAG = OAG)
	# generate coefficient matrix
	scm               <- spragueExpand(pop5, OAG = OAG)
	
	# redistribute
	pop1              <- scm %*% pop5
	
	# label and return
	AgeOut            <- as.integer(rownames(punif1))
	dimnames(pop1)    <- list(AgeOut, colnames(popmat))
	
	# no sense adding closeout behavior here, when it isn't offered
	# in grabill or beers. Better make wrapper with this sugar.
	
#	# default closeout with monoCloseout().
#	# set to FALSE to turn off, write "mono"
#	if (is.logical(closeout)){
#		if (!closeout){
#			return(pop1)
#		}
#		closeout <- "mono"
#	}
#	if (closeout == "mono"){
#		
#		# note, if OAG = FALSE and Age %% 5 != 0, 
#		# then we need to group popmat to next lowest
#		# age divisible by 5...
#		if (nrow(popmat) > nrow(pop1)){
#			n <- nrow(pop1)
#			popmat[n, ] <- colSums(popmat[n:nrow(popmat), ,drop = FALSE])
#			popmat <- popmat[1:n, , drop = FALSE]
#		}
#		
#		pop1 <- monoCloseout(
#				popmat = popmat, 
#				pops = pop1, 
#				OAG = OAG, 
#				pivotAge = pivotAge)
#	}
	pop1
}

#' Create the Sprague coefficient matrix.
#' 
#' @description The resulting coefficient matrix is based on the number of rows in \code{popmat}
#' where is assumed that each row of data is a 5-year age group. The final row may be an open 
#' or closed age group, as indicated by the \code{OAG} argument.
#' 
#' @param popmat numeric. A matrix of population counts in 5-year age groups with integer-labeled 
#' margins (age in rows and year in columns).
#' @param OAG logical. Whether or not the final age group open. Default \code{TRUE}.
#' 
#' @details The \code{popmat} matrix is really just a placeholder in this case. This function is 
#' a utility called by the Sprague family of functions, where it is most convenient to just pass
#' in the same matrix being used in those calculations to determine the layout of the coefficient matrix.
#' 
#' @export
#' 
#' @references 
#' \insertRef{sprague1880explanation}{DemoTools}
#' \insertRef{shryock1973methods}{DemoTools}
#' \insertRef{siegel2004methods}{DemoTools}
#' @examples
#' coefsOA     <- spragueExpand(pop5_mat, TRUE)
#' coefsclosed <- spragueExpand(pop5_mat, FALSE)
#' dim(coefsOA)
#' dim(coefsclosed)

spragueExpand <- function(popmat, OAG = TRUE){
	popmat <- as.matrix(popmat)
	
	# figure out ages and years
	Age5   <- as.integer(rownames(popmat))
	Age1   <- min(Age5):max(Age5)
	yrs    <- as.integer(colnames(popmat))
	
	# nr 5-year age groups
	m      <- nrow(popmat)
	# nr rows in coef mat.
	n      <- m * 5 - ifelse(OAG, 4, 0)
	# number of middle blocks
	MP     <- m - ifelse(OAG, 5, 4) 
	
	# get the split coefficients
	# block for ages 0-9
	g1g2 <- matrix(c(
					0.3616, -0.2768,  0.1488, -0.0336,  0.0000, 
					0.2640, -0.0960,  0.0400, -0.0080,  0.0000, 
					0.1840,  0.0400, -0.0320,  0.0080,  0.0000, 
					0.1200,  0.1360, -0.0720,  0.0160,  0.0000, 
					0.0704,  0.1968, -0.0848,  0.0176,  0.0000, 
					0.0336,  0.2272, -0.0752,  0.0144,  0.0000, 
					0.0080,  0.2320, -0.0480,  0.0080,  0.0000, 
					-0.0080,  0.2160, -0.0080,  0.0000,  0.0000, 
					-0.0160,  0.1840,  0.0400, -0.0080,  0.0000, 
					-0.0176,  0.1408,  0.0912, -0.0144,  0.0000), 
			nrow = 10, ncol = 5, byrow = TRUE)
	# block for middle ages
	
	
	g3 <- matrix(c(-0.0128,   0.0848,  0.1504,   -0.0240,  0.0016, 
					-0.0016,   0.0144,  0.2224,   -0.0416,  0.0064, 
					0.0064,  -0.0336,  0.2544,   -0.0336,  0.0064, 
					0.0064,  -0.0416,  0.2224,    0.0144, -0.0016, 
					0.0016,  -0.0240,  0.1504,    0.0848, -0.0128),
			5, 5, byrow = TRUE) 
	
	# block prior to closeout
	g4g5 <- matrix(c(0.0000, -0.0144,  0.0912,  0.1408, -0.0176, 
					0.0000, -0.0080,  0.0400,  0.1840, -0.0160, 
					0.0000,  0.0000, -0.0080,  0.2160, -0.0080, 
					0.0000,  0.0080, -0.0480,  0.2320,  0.0080, 
					0.0000,  0.0144, -0.0752,  0.2272,  0.0336, 
					0.0000,  0.0176, -0.0848,  0.1968,  0.0704, 
					0.0000,  0.0160, -0.0720,  0.1360,  0.1200, 
					0.0000,  0.0080, -0.0320,  0.0400,  0.1840, 
					0.0000, -0.0080,  0.0400, -0.0960,  0.2640, 
					0.0000, -0.0336,  0.1488, -0.2768,  0.3616), 
			nrow = 10, ncol = 5, byrow = TRUE)
	
	
	
	## create a Sprague coefficient matrix for 5-year age groups
	bm               <- matrix(0, nrow = n, ncol =  m)
	## insert upper left block
	bm[1:10, 1:5]    <- g1g2
	
	# determine positions of middle blocks
	rowpos           <- matrix(11:((MP * 5) + 10), ncol = 5, byrow = TRUE)
	colpos           <- row(rowpos) + col(rowpos) - 1
	for (i in (1:MP)) {
		# calculate the slices and add middle panels accordingly
		bm[rowpos[i, ], colpos[i, ]] <- g3
	}
	
	## insert last two panels
	
	fr                <- nrow(bm) - ifelse(OAG,10,9)
	lr                <- fr + 9
	fc                <- ncol(bm) - ifelse(OAG, 5, 4)
	lc                <- fc + 4
	bm[fr:lr,fc:lc]   <- g4g5
	
	if (OAG){
		# preserve open ended age group
		bm[nrow(bm), ncol(bm)]    <- 1
	}
	
	bm
}


#' An oscillatory average of age splits.
#' @description Single ages can be grouped into 5-year age groups in 5 ways by staggering terminal digits.
#' This method is a bit smoother than the standard Sprague or Beers methods, but not as smooth as \code{grabill()}.
#' 
#' @details This function works on a single vector of single-age counts, not on a matrix. Results are not
#' constrained to any particular age group, but are constrained to the total count. Negatives, \code{NA}, or \code{NaN} 
#' values are ignored in averaging. This can happen in older ages . It is recommended to run \code{monoCloseout()} or 
#' similar after the oscillatory split in such situations.
#' 
#' @param Value numeric. Vector of single age counts.
#' @param Age integer. Vector of single ages.
#' @param OAG logical. Whether or not the last value is the open age group. Default \code{TRUE}.
#' @param splitfun function used to split at each digit grouping. Default \code{sprague()}.
#' @param closeout logical or character. Default \code{"mono"}.
#' @param pivotAge integer. Age to start blending in closeout values.
#' @param ... optional arguments passed to \code{splitfun()}.
#' 
#' @return Numeric vector of smoothed counts.
#' @references 
#' \insertRef{booth2015demographic}{DemoTools}
#' @export
#' @examples
#' # code currently breaking, needs to be revisited and updates completed, sorry
#' \dontrun{
#' 
#' Value <- structure(pop1m_ind, .Names = 0:100)
#' #barplot(Value, main = "yup, these have heaping!")
#' # this is the basic case we compare with:
#' pop0    <- sprague(groupAges(Value),  OAG = TRUE)
#' # note: this function needs single ages to work because
#' # ages are grouped into 5-year age groups in 5 different ways.
#' # breaks
#' #pop1    <- splitOscillate(Value, OAG = TRUE, splitfun = sprague)
#' pop2    <- splitOscillate(Value, OAG = TRUE, splitfun = beers)
#' # what's smoother, splitOscillate() or grabill()?
#' # note, same closeout problem, can be handled by monoCloseout()
#' pop3    <- grabill(Value, OAG = TRUE)
#' # and technically you could give grabill as splitfun too
#' pop4   <- splitOscillate(Value, OAG = TRUE, splitfun = grabill)
#' 
#' Age <- 0:100
#' plot(Age, Value)
#' lines(Age, pop0, col = "blue")
#' # slightly smoother (also shifted though)
#' lines(Age, pop1)
#' # only different at very high ages, small nrs
#' lines(Age, pop2, col = "red", lty = 2, lwd = 2) 
#' lines(Age, pop3, col = "magenta")
#' lines(Age, pop4, col = "orange", lty = 2)
#' legend("topright", 
#' lty = c(1,1,2,1,2), 
#' lwd = c(1,1,2,1,1), 
#' col = c("blue","black","red","magenta","orange"),
#' 		legend = c("sprague()",
#'                 "splitOscillate(splitfun = sprague)", 
#' 				   "splitOscillate(splitfun = beers)",
#' 				   "grabill()",
#'                 "splitOscillate(splitfun = grabill)"))
#' 
#' # index of dissimilarity
#' ID(Value, pop0) # original vs sprague
#' ID(pop0,pop1) # sprague vs sprague osc
#' ID(pop1,pop2) # sprague osc vs beers osc
#' ID(pop2,pop3) # beers osc vs grabill
#' ID(pop3,pop4) # grabill vs grabill osc
#' # measre of smoothness:
#' mean(abs(diff(Value)))
#' mean(abs(diff(pop0)))
#' mean(abs(diff(pop1)))
#' mean(abs(diff(pop2)))
#' mean(abs(diff(pop3)))
#' mean(abs(diff(pop4)))
#' }
splitOscillate <- function(
		Value, 
		Age = 1:length(Value) - 1, 
		OAG = TRUE, 
		splitfun = sprague, 
		closeout = "mono", 
		pivotAge = 90, ...){
	
	N     <- length(Value)
	if (OAG){
		open   <- Value[N]
		OA     <- Age[N]
		Value  <- Value[-N]
		Age    <- Age[-N]
		N      <- N - 1
	} 
	TOT    <- sum(Value)
# select which ages to keep:
	p1x1   <- matrix(nrow = N, ncol = 5)
	rownames(p1x1) <- Age
	for (i in 0:4){
		# regroup ages
		Age.i.5             <- calcAgeN(Age, shiftdown = i)
		# only use age groups w 5 single ages represented
		keep.i              <- rep(rle(Age.i.5)$leng, rle(Age.i.5)$leng) == 5
		# cut vector down to those cases
		Age.i.5             <- Age.i.5[keep.i]
		# cut counts down to those cases
		Val.i               <- Value[keep.i]
		# group ages into said 5-year age groups
		Val.i.5             <- groupAges(Val.i, AgeN = Age.i.5)
	
		# get first run estimate
		pop.est             <- splitfun(Val.i.5, OAG = FALSE, ...)
#        a                   <- rownames(pop.est)
#		if (closeout){
#			a.fake  <- (1:nrow(pop.est) - 1) * 5
#			pop.est <- monoCloseout(Val.i.5, Age = a.fake, pops = pop.est, OAG = FALSE)
#		}
		
		pop.est[pop.est < 0] <- 0
		p1x1[keep.i, i + 1]  <- pop.est
	}
	# take average per age
	p.out <- rowMeans(p1x1, na.rm = TRUE)
	# rescale to proper total
	p.out <- rescale.vector(p.out, TOT)
	# re-append the open age group if needed
	if (OAG){
		Age          <- c(Age, OA)
		p.out        <- c(p.out, open)
		names(p.out) <- Age
	}
	if (is.logical(closeout)){
		if (!closeout){
			return(p.out)
		}
		closeout <- "mono"
	}
	if (closeout == "mono"){
		p.out <- monoCloseout(popmat = Value, pops = p.out, OAG = OAG, pivotAge = 90)
	}
	
	p.out
}
