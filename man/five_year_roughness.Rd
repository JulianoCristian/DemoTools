% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/AGEHEAP.R
\name{five_year_roughness}
\alias{five_year_roughness}
\title{Evaluate roughness of data in 5-year age groups}
\usage{
five_year_roughness(Value, Age, ageMin = 20, ageMax = max(Age[Age\%\%5
  == 0]))
}
\arguments{
\item{Value}{numeric. A vector of demographic counts by single age.}

\item{Age}{numeric. A vector of ages corresponding to the lower integer bound of the counts.}

\item{ageMin}{integer evenly divisible by 5. Lower bound of evaluated age range, default 20.}

\item{ageMax}{integer evently divisibly by 5. Upper bound of evaluated age range, defaults to highest age evenly divisible by 10.}
}
\description{
For a given age-structured vector of counts, how rough is data after grouping to 5-year age bins?
 Data may require smoothing even if there is no detectable sawtooth pattern. It is best to use the value in this 
 method together with visual evidence to gauage whether use of \code{agesmth()} is recommended.
}
\details{
First we group data to 5-year age bins. Then we take first differences (d1) of these within the evaluated
 age range. Then we smooth first differences (d1s) using a generic smoother (\code{ogive()}).
  Roughness is defined as the mean of the absolute differences between \code{mean(abs(d1 - d1s) / abs(d1s))}. 
  Higher values indicate rougher data, and may suggest more aggressive smoothing. Just eyeballing, one could consider
   smoothing if the returned value is greater than ca 0.2, and values greater than 0.5 already highly recommend
    it (pending visual verification).
}
\examples{
Age <- 0:99
smoothed <- sprague(
		agesmth(pop1m_pasex, 
				Age, 
				method = "Strong", 
				OAG = FALSE, 
				young.tail = "Arriaga"),
		OAG = FALSE)
# not very rough, no need to smooth more
five_year_roughness(smoothed, Age)
 # quite rough, even after grouping to 5-year ages
five_year_roughness(pop1m_pasex, Age)
# heaped, but no 0>5 preference
h1 <- heapify(smoothed, Age, p0 = 1, p5 = 1)
# heaping progressively worse
h2 <- heapify(smoothed, Age, p0 = 1.2, p5 = 1.2)
h3 <- heapify(smoothed, Age, p0 = 1.5, p5 = 1.5)
h4 <- heapify(smoothed, Age, p0 = 2, p5 = 2)
h5 <- heapify(smoothed, Age, p0 = 2.5, p5 = 2)
\dontrun{
#cols <- RColorBrewer::brewer.pal(7,"Reds")[3:7]
 cols <-  c("#FC9272", "#FB6A4A", "#EF3B2C", "#CB181D", "#99000D")
 A5 <- seq(0,95,by=5)
	plot(A5, groupAges(smoothed), type='l',xlim=c(20,80),ylim=c(0,3e5))
lines(A5, groupAges(h1),col=cols[1])
	lines(A5, groupAges(h2),col=cols[2])
	lines(A5, groupAges(h3),col=cols[3])
lines(A5, groupAges(h4),col=cols[4])
lines(A5, groupAges(h5),col=cols[5])
}
five_year_roughness(smoothed, Age)
five_year_roughness(h1, Age)
five_year_roughness(h2, Age)
five_year_roughness(h3, Age)
five_year_roughness(h4, Age)
five_year_roughness(h5, Age)

}
