#' Create the Grabill coefficient matrix.
#' 
#' @description The resulting coefficient matrix is based on the number of rows in \code{popmat}
#' where we assume that each row of data is a 5-year age group and the final row is an open age group
#' to be preserved as such.
#' 
#' @param popmat numeric. Matrix of age-period population counts in 5-year age groups.
#' @param OAG logical. Whether or not the final age group open. Default \code{TRUE}.
#' 
#' @details The \code{popmat} matrix is really just a placeholder in this case. This function is 
#' a utility called by the Grabill family of functions, where it is most convenient to just pass
#' in the same matrix being used in those calculations to determine the layout of the coefficient matrix.
#' Note that these coefficients do not constrain population counts to their year totals. This function 
#' is called by \code{grabill()}, which ensures matching marginals by 1) blending boundary ages 
#' into the Sprague estimated population, and 2) a second constraint on the middle age groups to enforce
#' matching sums.
#' 
#' @references
#' \insertRef{shryock1973methods}{DemoTools}
#' 
#' @export
#' @examples 
#' grabillExpand(pop5_mat, OAG = TRUE)
#' grabillExpand(pop5_mat, OAG = FALSE)
grabillExpand <- function(popmat, OAG = TRUE){
	popmat            <- as.matrix(popmat)
	
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
	
	# primary grabill coef block
	g3g              <- matrix(
			c(
					0.0111,	0.0816,	 0.0826,	0.0256,	-0.0009,
					0.0049,	0.0673,	 0.0903,	0.0377,	-0.0002,
					0.0015,	0.0519,	 0.0932,	0.0519,	 0.0015,
					-0.0002,	0.0377,	 0.0903,	0.0673,	 0.0049,
					-0.0009,	0.0256,	 0.0826,	0.0816,	 0.0111),
			5, 5, byrow = TRUE)
	## create a Grabill coefficient matrix for 5-year age groups
	gm               <- matrix(0, nrow = n, ncol =  m)
	
	
	fr                <- nrow(gm) - ifelse(OAG,10,9)
	lr                <- fr + 9
	fc                <- ncol(gm) - ifelse(OAG, 5, 4)
	lc                <- fc + 4
	
	# ----------------------------------------------------------
	# Note: for the boundary ages we keep shuffling in g3g, the same grabill
	# coefs. The columns on the boundaries will NOT sum to 1. These coefs are
	# used just for the firs pass, then results blend into the Sprague boundary
	# estimates.
	# ----------------------------------------------------------
	# the young age coefficients
	g1g2g              <- matrix(0,nrow=10,ncol=5)
	g1g2g[1:5, 1:3]    <- g3g[,3:5]
	g1g2g[6:10, 1:4]   <- g3g[,2:5]
	# the old age coefficients
	g4g5g              <- matrix(0,nrow=10,ncol=5)
	g4g5g[1:5, 2:5]    <- g3g[,1:4]
	g4g5g[6:10, 3:5]   <- g3g[,1:3]
	
	gm[1:10, 1:5]    <- g1g2g
	gm[fr:lr,fc:lc]  <- g4g5g
	
	
	# determine positions of middle blocks
	rowpos             <- matrix(11:((MP*5) + 10), ncol = 5, byrow = TRUE)
	colpos             <- row(rowpos) + col(rowpos) - 1
	for (i in (1:MP)) {
		# calculate the slices and add middle panels accordingly
		gm[rowpos[i,], colpos[i, ]] <- g3g
	}
	
	if (OAG){
		# preserve open ended age group
		gm[nrow(gm), ncol(gm)]    <- 1
	}
	
	# return coefficient matrix
	gm
}

#' The basic Grabill age-splitting method
#' 
#' @description This method uses Grabill's redistribution of middle ages and blends into
#' Sprague estimated single-age population counts for the first and final ten ages. Open age groups
#' are preserved, as are annual totals.
#' 
#' @param popmat numeric. Matrix of age-period population counts in 5-year age groups with integer-labeled 
#' margins (age in rows and year in columns). 
#' @param Age integer. A vector of ages corresponding to the lower integer bound of the counts. Detected from row names of \code{popmat} if missing.
#' @param OAG logical. Whether or not the final age group open. Default \code{TRUE}.
#' @details  Dimension labelling is necessary. There must be at least six age groups (including the open group). One year of data will 
#' work as well, as long as it's given as a single-column matrix. Data may be given in either single or grouped ages.
#' 
#' If the highest age does not end in a 0 or 5, and \code{OAG == TRUE}, then the open age will be grouped down to the next 
#' highest age ending in 0 or 5. If the highest age does not end in a 0 or 5, and \code{OAG == FALSE}, then results extend
#' to single ages covering the entire 5-year age group. 
#' 
#' @return An age-period matrix of split population counts with the same number of 
#' columns as \code{popmat}, and single ages in rows.
#' 
#' @references 
#' \insertRef{shryock1973methods}{DemoTools}
#' 
#' @export
#' 
#' @examples 
#' p5 <- pop5_mat
#' head(p5) # this is the entire matrix
#' p1g <- grabill(p5)
#' head(p1g); tail(p1g)
#' colSums(p1g) - colSums(p5) 
#' p1s <- sprague(p5)
#' \dontrun{
#' plot(seq(0,100,by=5),p5[,1]/5,type = "s", col = "gray", xlab = "Age", ylab = "Count")
#' lines(0:100, p1g[,1], col = "red", lwd = 2)
#' lines(0:100, p1s[,1], col = "blue", lty = 2, lwd =2)
#' legend("topright", 
#'		lty = c(1,1,2), 
#'		col = c("gray","red","blue"), 
#'		lwd = c(1,2,1), 
#'		legend = c("grouped","Grabill", "Sprague"))
#' }
#' 
#' # also works for single ages:
#' names(pop1m_ind) <- 0:100
#' grab1 <- grabill(pop1m_ind)
#' \dontrun{
#' plot(0:100, pop1m_ind)
#' lines(0:100, c(grab1))
#' }
grabill <- function(
		popmat,
		Age = as.integer(rownames(as.matrix(popmat))), 
		OAG = TRUE){
	popmat            <- as.matrix(popmat)
	
	# this is innocuous if ages are already grouped
	pop5              <- apply(popmat, 2, groupAges, Age = Age, N = 5, shiftdown = 0)
	
	
	# get coefficient matrices for Sprague and Grabill
	scmg              <- grabillExpand(pop5, OAG = OAG)
	scm               <- spragueExpand(pop5, OAG = OAG)
	
	# split pop counts
	pops              <- scm %*% pop5
	popg              <- scmg %*% pop5
	
	# ---------------------------------------------
	# now we graft the two estimates together,
	# preserving the middle part for grabill, and blending
	# aggressively into the young and closeout parts of Sprague
	# weights for grafting in grabill
	m                 <- nrow(pops)
	lr                <- m - 1
	fr                <- lr - 9
	
	# these weights do much better than linear weights.
	w10               <- exp(row(pops[1:10, , drop = FALSE]) ) / exp(10.1)
	
	# blend together young ages
	popg[1:10, ]      <- w10 * popg[1:10, ] + (1 - w10) * pops[1:10, ]
	
	# blend together old ages
	popg[fr:lr, ]     <- w10[10:1, ] * popg[fr:lr, ] + (1 - w10[10:1, ]) * pops[fr:lr, ]
	
	# ---------------------------------------------
	# now we take care of the marginal constraint problem
	# make weighting matrix 
	wr                <- pops * 0 + 1
	wr[1:10, ]        <- w10
	wr[fr:lr, ]       <- w10[10:1, ]
	wr[nrow(wr), ]    <- 0
	
	# weighted marginal sums. The difference we need to redistribute
	redist            <- colSums(pops) - colSums(popg)
	
	middle.part       <- popg * wr
	
	# the difference to redistribute
	add.in            <- t(t(prop.table(middle.part,2)) * redist)
	popg              <- popg + add.in
	# ---------------------------------------------
	# label dims and return
    AgeOut            <- min(Age):(min(Age) + nrow(popg) - 1)
	dimnames(popg)    <- list(AgeOut, colnames(popmat))
	
	popg
}



