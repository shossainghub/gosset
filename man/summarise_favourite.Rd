% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summarise_favourite.R
\name{summarise_favourite}
\alias{summarise_favourite}
\alias{summarise_favorite}
\alias{plot.gosset_fvrt}
\title{Favourability scores}
\usage{
summarise_favourite(data = NULL, items = NULL, input = NULL, reorder = TRUE)

\method{plot}{gosset_fvrt}(x, ...)
}
\arguments{
\item{data}{a data.frame with columns specified by items and input values}

\item{items}{a character or numerical vector for indexing the column(s) 
containing the item names in \code{data}}

\item{input}{a character or numerical vector for indexing the column(s) 
containing the values in \code{data} to be ranked}

\item{reorder}{logical, if items should be reordered from higher 
favourability score to least favourability score}

\item{x}{an object of class 'gosset_fvrt' for the plotting method. 
Generates a 'ggplot' object that can be passed to any ggplot2 method}

\item{...}{additional arguments passed to methods. See details}
}
\value{
A data.frame with the descriptive statistics:
\item{N}{number of times the given item was evaluated}
\item{best}{relative number of times (in percentage) the given item was
 ranked as first}
\item{worst}{relative number of times (in percentage) the given item was 
ranked as worst}
\item{wins}{relative number of times (in percentage) the given item wins 
against the others}
\item{fav_score}{the favourability score, which is the difference between 
best and worst performance}
}
\description{
Summarise favourability scores from tricot data
}
\examples{
data("breadwheat", package = "gosset")
 
fv <- summarise_favourite(data = breadwheat,
                      items = c("variety_a", "variety_b", "variety_c"),
                      input = c("overall_best", "overall_worst"))

 
}
\seealso{
Other summarise functions: 
\code{\link{summarise_agreement}()},
\code{\link{summarise_dominance}()},
\code{\link{summarise_victories}()}
}
\concept{summarise functions}