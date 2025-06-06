% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/install_BayesCCal.R
\name{install_BayesCCal}
\alias{install_BayesCCal}
\title{Install BayesCCal Python Dependencies}
\usage{
install_BayesCCal(
  envname = "BCCenv",
  python = NULL,
  type = c("miniconda", "virtualenv")
)
}
\arguments{
\item{envname}{Name of the virtualenv to create/use.}

\item{python}{Optional path to a Python 3 executable. If NULL, one is auto-detected.}

\item{type}{Installation type: "miniconda" or "virtualenv"}
}
\description{
Creates a virtualenv and installs the BayesCCal Python package.
}
