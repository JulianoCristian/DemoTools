% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LTidentities.R
\name{lx2dx}
\alias{lx2dx}
\title{Derive lifetable deaths from survivorship.}
\usage{
lx2dx(lx)
}
\arguments{
\item{lx}{numeric.  Vector of age-specific lifetable survivorship.}
}
\value{
ndx vector of lifetable deaths.
}
\description{
This lifetable identity is the same no matter what kind of lifetable is required.
 You can find it in any demography textbook.
}
\details{
The vector returned is the same length as \code{lx} and it sums to the lifetable radix. 
If the radix is one then this is the discrete deaths distribution.
}
\references{
\insertRef{preston2000demography}{DemoTools}
}
