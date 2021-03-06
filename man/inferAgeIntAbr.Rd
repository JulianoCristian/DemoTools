% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utilsAge.R
\name{inferAgeIntAbr}
\alias{inferAgeIntAbr}
\title{Infer abridged age groups widths.}
\usage{
inferAgeIntAbr(Age, vec, OAG = FALSE, OAvalue = NA)
}
\arguments{
\item{Age}{integer. Vector of lower bound of each age group.}

\item{vec}{Any vector, presumably a count, rate, or similar.}

\item{OAG}{logical. Whether or not the final age group open. Default \code{FALSE}.}

\item{OAvalue}{numeric or integer. The value to use for the final age interval if \code{OAG = TRUE}. Default \code{NA}.}
}
\value{
An integer vector of \code{length(vec)} indicating the width of the abridged age group that each 
vector element corresponds to.
}
\description{
This function is an auxiliary used by top level functions where it is 
guaranteed that age groups are standard abridged age groups. If \code{Age} is specified,
this will work as well for other age groupings.
}
\details{
If based solely on the length of a vector, this will give erroneous results if ages 
are anything other than standard abridged ages groups. If the final age group is open, the 
interval width is defined as \code{NA}. \code{Inf} or \code{-1} would have 
also been a good choice, but we went with \code{NA}.
}
\examples{
vec <- runif(20)
inferAgeIntAbr(vec = vec)
inferAgeIntAbr(vec = vec, OAG = TRUE)
}
