# Author: sean
# edited by TR 9-Dec-2017
###############################################################################

#' Interpolate between two population age distributions.
#' @description The interpolation is done by age (not cohort) using a linear or exponential function. This comes from the PAS spreadsheet called ADJINT.

#' @param Pop1   numeric. A vector of demographic population counts for an earlier date.
#' @param Pop2   numeric. A vector of demographic population counts for a later date.
#' @param Date1 date (See details for ways to express it). The date corresponding to the earlier population age distribution.
#' @param Date2 date (See details for ways to express it). The date corresponding to the later population age distribution.
#' @param DesiredDate date (See details for ways to express it). The desired date of the output population age distribution.
#' @param method string. The method to use for the interpolation, either "linear" or "exponential". Default "Linear".
#' @param round. logical. defaul \code{FALSE}. Should we return integers?

#' @details The age group structure of the output is the same as that of the input. Ideally, the DesiredDate should be between the Date1 and Date2. Dates can be given in three ways 1) a \code{Date} class object, 2) an unambiguous character string in the format \code{"YYYY-MM-DD"}, or 3) as a decimal date consisting in the year plus the fraction of the year passed as of the given date.

#' @return a vector of the interpolated population for the requested date.
#' @author Sean Fennel
#' @export
#' 
#' @examples 
#' EarlyPop      <- c(100958, 466275, 624134, 559559, 446736, 370653, 301862, 249409, 247473, 223014, 172260, 149338, 127242, 105715, 79614, 53660, 31021, 34596)
#' LaterPop    <- c(201916, 932550, 1248268, 1119118, 893472, 741306, 603724, 498818, 494946, 446028, 344520, 298676, 254484, 211430, 159228, 107320, 62042, 69192)
#' # YYYY-MM-DD dates as character
#' EarlyDate       <- "1980-04-07"
#' LaterDate       <- "1990-10-06"
#' DesiredDate     <- "1990-07-01"
#' 
#' interpolatePop(EarlyPop, LaterPop, EarlyDate, LaterDate, DesiredDate)
#' interpolatePop(EarlyPop, LaterPop, EarlyDate, LaterDate, DesiredDate, method = "exponential")

interpolatePop <- function(Pop1, Pop2, Date1, Date2, DesiredDate, method = "linear", round = FALSE){
  
  stopifnot(length(Pop1) == length(Pop2))
	
  earlyDateDec      <- dec.date(Date1)
  laterDateDec      <- dec.date(Date2)
  desireDateDec     <- dec.date(DesiredDate)
  
  interpolateFactor <- (desireDateDec - earlyDateDec) / (laterDateDec - earlyDateDec)
  
  if (method == "exponential"){
    adjustedPop   <- Pop1 * exp(interpolateFactor * log(Pop2 / Pop1))
  }
  else {
    adjustedPop   <- Pop1 + (Pop2 - Pop1) * interpolateFactor
  }
  if (round){
	  adjustedPop <- round(adjustedPop)
  }
  return(adjustedPop)
}
