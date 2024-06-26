% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/save_load.R
\name{save_model}
\alias{save_model}
\title{Save model}
\usage{
save_model(tuner, trial_id, model, step = 1)
}
\arguments{
\item{tuner}{A tuner object}

\item{trial_id}{The ID of the `Trial` that corresponds to this Model.}

\item{model}{The trained model.}

\item{step}{For models that report intermediate results to the `Oracle`, the 
step that this saved file should correspond to. For example, for Keras models 
this is the number of epochs trained.}
}
\value{
None
}
\description{
Saves a Model for a given trial
}
