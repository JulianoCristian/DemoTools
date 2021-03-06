% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LTidentities.R
\name{mxax2qx}
\alias{mxax2qx}
\title{Derive nqx from nMx and nax.}
\usage{
mxax2qx(nMx, nax, AgeInt, closeout = TRUE, IMR)
}
\arguments{
\item{nMx}{numeric. Vector of age-specific death rates.}

\item{nax}{numeric. Vector of average time spent in interval by those dying in interval.}

\item{AgeInt}{integer. Vector of age class widths.}

\item{closeout}{logical. Set to 1 if TRUE. Identity otherwise. Default \code{TRUE}.}

\item{IMR}{numeric. Optional q0 to impute, in case available separately.}
}
\value{
nqx vector of age specific death probabilities derived via identity.
}
\description{
This is the standard identity to derive nqx from nax and nMx.
This is a more full-service wrapper of \code{mx2qx()}, with closeout options and optional age 0 
treatment.
}
\details{
qx values calculated as greater than 1 are imputed with 1.
}
\references{
\insertRef{preston2000demography}{DemoTools}
}
