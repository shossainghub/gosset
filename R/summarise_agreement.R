#' Agreement between rankings
#' 
#' Summarise the concordance between one or more caracteristics from a baseline
#' ranking
#' 
#' @author Nicolas Greliche, Sam Dumble and Kauê de Sousa
#' @family summarise functions
#' @param baseline an object of class 'rankings' or 'grouped_rankings' 
#' that serves as baseline for comparing the other characteristics
#' @param compare.to a list of objects of same class and dimensions of 
#' \code{baseline} to be compared
#' @param labels a character to specify the name of compared chacteristics
#' @param x object of class 'gosset_agree' for the plotting method. 
#' Generates a 'ggplot' object that can be passed to any ggplot2 method
#' @param ... further arguments passed to methods. Not enabled yet
#' @return A data.frame with summary of agreement:
#' \item{labels}{the labels for each characteristic}
#' \item{kendall}{relative Kendall rank correlation coefficient}
#' \item{first}{relative agreement of the first item in the baseline being 
#' ranked first in compare.to}
#' \item{last}{relative agreement of the last item in the baseline being 
#' ranked last in compare.to}
#' @seealso \code{\link{kendallTau}} 
#' @examples 
#' # from the breadwheat data
#' # Compare the overall performance against
#' # rankings on germination, grain quality and yield
#' 
#' data("breadwheat", package = "gosset")
#'  
#' R <- rank_tricot(data = breadwheat,
#'                  items = c("variety_a", "variety_b", "variety_c"),
#'                  input = c("overall_best", "overall_worst"))
#' 
#' 
#' compare <- list()
#' 
#' compare[[1]] <- rank_tricot(data = breadwheat,
#'                             items = c("variety_a", "variety_b", "variety_c"),
#'                             input = c("germination_best","germination_worst"))
#' 
#' compare[[2]] <- rank_tricot(data = breadwheat,
#'                             items = c("variety_a", "variety_b", "variety_c"),
#'                             input = c("grainquality_best", "grainquality_worst"))
#' 
#' 
#' compare[[3]] <- rank_tricot(data = breadwheat,
#'                             items = c("variety_a", "variety_b", "variety_c"),
#'                             input = c("yield_best", "yield_worst"))
#' 
#' 
#' labels <- c("Germination", "Grain quality", "Yield")
#' 
#' 
#' summarise_agreement(R,
#'                     compare.to = compare,
#'                     labels = labels)
#'  
#' @importFrom methods addNextMethod asMethodDefinition assignClassDef
#' @importFrom ggplot2 ggplot aes geom_bar facet_wrap coord_flip 
#' geom_text scale_y_continuous theme element_text labs
#' @importFrom tibble tibble
#' @export
summarise_agreement <- function(baseline, compare.to, labels = NULL){

  B <- baseline
  CC <- compare.to
  
  # check if both objects have the same class
  same_class <- lapply(CC, function (x) {
    .same_class(B, x)
  })
  
  # if not, stop
  if (!any(unlist(same_class))) {
    stop("baseline and compare.to are objects of different class \n")
  }
  
  
  if(.is_grouped_rankings(B)) {
    B <- B[1:length(B),, as.grouped_rankings = FALSE]
    
    CC <- lapply(CC, function(x) {
      x[1:length(x),,as.grouped_rankings = FALSE]
    })
    
  }
  
  
  if(.is_rankings(B)) {
    
    B <- B[1:length(B),, as.rankings = FALSE]
    
    CC <- lapply(CC, function(x) {
      x[1:length(x),,as.rankings = FALSE]
    })
    
  }
  
  # number of rows 
  n <- nrow(B)
  
  # calculate Kendall correlation
  Kendall <- lapply(CC, function(x) {
    kendallTau(x, B)[[1]]
  })
  
  # take the first ranked item in B
  B_first <- apply(B, 1, function(x) {
    
    names(x)[which(x == 1)]
    
  })
  
  # take the last ranked item in B
  B_last <- apply(B, 1, function(x) {
    
    names(x)[which.max(x)]
    
  })
  
  
  # take the first ranked item in CC
  CC_first <- lapply(CC, function(y) {
    apply(y, 1, function(x) {
      
      names(x)[which(x == 1)]
      
    })
  })
  
  
  # take the first ranked item in CC
  CC_last <- lapply(CC, function(y) {
    apply(y, 1, function(x) {
      
      names(x)[which.max(x)]
      
    })
  })
  
  
  # compare first and last from B and CC
  first <- lapply(CC_first, function (x) {
    
    a <- x == B_first
    
    sum(a) / n
    
  })
  
  last <- lapply(CC_last, function (x) {
    
    a <- x == B_last
    
    sum(a) / n
    
  })
  
  if (is.null(labels)) {
    labels <- paste0("Characteristic ", 1:length(CC))
  }
  
  result <- tibble::tibble(labels = labels,
                           kendall = unlist(Kendall) * 100,
                           first = unlist(first) * 100,
                           last = unlist(last) * 100)
  
  class(result) <- c('gosset_agree', class(result))
  
  return(result)
 
}



#' @rdname summarise_agreement
#' @method plot gosset_agree
#' @export
plot.gosset_agree <- function(x, ...) {

  # force labels to be in the order as provided by input
  labels_lv <- x$labels
  
  # force capital letter in type
  names(x) <- c("labels","Kendall","First","Last")
  
  # keep <- !is.na(x$Kendall) & !is.na(x$First) & !is.na(x$Last)
  # 
  # x <- x[keep, ]
  
  # put data in a long format
  x <- split(x, x$labels)
  x <- lapply(x, function(z) {
    ag <- as.vector(t(z[2:4]))
    ty <- as.vector(names(z[2:4]))
    la <- unlist(rep(z[[1]], 3))
    data.frame(labels = la, 
               type = ty, 
               agreement = ag,
               stringsAsFactors = FALSE)
  })
  
  x <- do.call("rbind", x)
  
  # convert type into factor 
  x$type <- factor(x$type,
                   levels = c("Kendall","First","Last"))

  # and labels into factor
  x$labels <- factor(x$labels,
                     levels = labels_lv)
  
  # plot
  p <- 
  ggplot2::ggplot(x,
                  ggplot2::aes(
                    y = x$agreement,
                    x = x$labels,
                    alpha = x$agreement,
                    fill = x$type
                  )) +
    ggplot2::geom_bar(
      stat = "identity",
      position = "dodge",
      col = "gray50",
      show.legend = FALSE
    ) +
    ggplot2::facet_wrap(. ~ x$type) +
    ggplot2::coord_flip() +
    ggplot2::geom_text(
      ggplot2::aes(y = x$agreement / 2,
                   label = round(x$agreement, 0)),
      fontface = 2,
      size = 8,
      alpha = 1
    ) +
    ggplot2::scale_y_continuous(
      labels = paste0(seq(0, 100, by = 25), "%"),
      breaks = seq(0, 100, by = 25),
      limits = c(0, 100)
    ) +
    ggplot2::theme(
      axis.text.y = ggplot2::element_text(size = 15, face = 2),
      strip.text = ggplot2::element_text(size = 15, face = 2)
    ) +
    ggplot2::labs(x = "", y = "")

  return(p)
}