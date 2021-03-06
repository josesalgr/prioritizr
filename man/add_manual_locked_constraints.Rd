% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_manual_locked_constraints.R
\name{add_manual_locked_constraints}
\alias{add_manual_locked_constraints}
\alias{add_manual_locked_constraints,ConservationProblem,data.frame-method}
\alias{add_manual_locked_constraints,ConservationProblem,tbl_df-method}
\title{Add manually specified locked constraints}
\usage{
add_manual_locked_constraints(x, data)

\S4method{add_manual_locked_constraints}{ConservationProblem,data.frame}(x, data)

\S4method{add_manual_locked_constraints}{ConservationProblem,tbl_df}(x, data)
}
\arguments{
\item{x}{\code{\link{ConservationProblem-class}} object.}

\item{data}{\code{data.frame} or \code{\link[tibble]{tibble}} object. See
the Details section for more information.}
}
\value{
\code{\link{ConservationProblem-class}} object with the constraints
  added to it.
}
\description{
Add constraints to a conservation planning \code{\link{problem}} to ensure
that solutions allocate (or do not allocate) specific planning units to
specific management zones. This function offers more fine-grained control
than the \code{\link{add_locked_in_constraints}} and
\code{\link{add_locked_out_constraints}} functions.
}
\details{
The argument to \code{data} must contain the following fields
  (columns):

  \describe{

  \item{\code{"pu"}}{\code{integer} planning unit identifier.}

  \item{\code{"zone"}}{\code{character} names of zones. Note that this
    argument is optional for arguments to \code{x} that contain a single
    zone.}

  \item{\code{"status"}}{\code{numeric} values indicating how much
    of each planning unit should be allocated to each zone in the solution.
    For example, the \code{numeric} values could be binary values (i.e. zero
    or one) for problems containing binary-type decision variables
    (using the \code{\link{add_binary_decisions}} function). Alternatively,
    the \code{numeric} values could be proportions (e.g. 0.5) for problems
    containing proportion-type decision variables (using the
    \code{\link{add_proportion_decisions}}).}

  }
}
\examples{
# set seed for reproducibility
set.seed(500)

# load data
data(sim_pu_polygons, sim_features, sim_pu_zones_polygons,
     sim_features_zones)

# create minimal problem
p1 <- problem(sim_pu_polygons, sim_features, "cost") \%>\%
      add_min_set_objective() \%>\%
      add_relative_targets(0.2) \%>\%
      add_binary_decisions()

# create problem with locked in constraints using add_locked_constraints
p2 <- p1 \%>\% add_locked_in_constraints("locked_in")

# create identical problem using add_manual_locked_constraints
locked_data <- data.frame(pu = which(sim_pu_polygons$locked_in),
                          status = 1)

p3 <- p1 \%>\% add_manual_locked_constraints(locked_data)
\donttest{
# solve problems
s1 <- solve(p1)
s2 <- solve(p2)
s3 <- solve(p3)

# plot solutions
par(mfrow = c(1,3), mar = c(0, 0, 4.1, 0))
plot(s1, main = "none locked in")
plot(s1[s1$solution_1 == 1, ], col = "darkgreen", add = TRUE)

plot(s2, main = "add_locked_in_constraints")
plot(s2[s2$solution_1 == 1, ], col = "darkgreen", add = TRUE)

plot(s3, main = "add_manual_constraints")
plot(s3[s3$solution_1 == 1, ], col = "darkgreen", add = TRUE)
}
# create minimal problem with multiple zones
p4 <- problem(sim_pu_zones_polygons, sim_features_zones,
              c("cost_1", "cost_2", "cost_3")) \%>\%
      add_min_set_objective() \%>\%
      add_relative_targets(matrix(runif(15, 0.1, 0.2), nrow = 5,
                                  ncol = 3)) \%>\%
      add_binary_decisions()

# create data.frame with the following constraints:
# planning units 1, 2, and 3 must be allocated to zone 1 in the solution
# planning units 4, and 5 must be allocated to zone 2 in the solution
# planning units 8 and 9 must not be allocated to zone 3 in the solution
locked_data2 <- data.frame(pu = c(1, 2, 3, 4, 5, 8, 9),
                           zone = c(rep("zone_1", 3), rep("zone_2", 2),
                                    rep("zone_3", 2)),
                           status = c(rep(1, 5), rep(0, 2)))

# print locked constraint data
print(locked_data2)

# create problem with added constraints
p5 <- p4 \%>\% add_manual_locked_constraints(locked_data2)
\donttest{
# solve problem
s4 <- solve(p4)
s5 <- solve(p5)

# create two new columns representing the zone id that each planning unit
# was allocated to in the two solutions
s4$solution <- category_vector(s4@data[, c("solution_1_zone_1",
                                           "solution_1_zone_2",
                                           "solution_1_zone_3")])
s4$solution <- factor(s4$solution)

s4$solution_locked <- category_vector(s5@data[, c("solution_1_zone_1",
                                                  "solution_1_zone_2",
                                                  "solution_1_zone_3")])
s4$solution_locked <- factor(s4$solution_locked)

# plot solutions
spplot(s4, zcol = c("solution", "solution_locked"), axes = FALSE,
       box = FALSE)
}
}
\seealso{
\code{\link{constraints}}.
}
