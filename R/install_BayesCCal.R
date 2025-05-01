#' Install BayesCCal Python Dependencies
#'
#' Creates a virtualenv and installs the BayesCCal Python package.
#' @param envname Name of the virtualenv to create/use.
#' @param python Optional path to a Python 3 executable. If NULL, one is auto-detected.
#' @param type Installation type: "miniconda" or "virtualenv"
#' @import cli
#' @import rlang
#' @import reticulate
#' @importFrom stats predict
#' @export
install_BayesCCal <- function(envname = "BCCenv", python = NULL, type = c("miniconda", "virtualenv")) {
	type = match.arg(type)

	if (type == "miniconda") {
		miniconda = reticulate::miniconda_path()

		if (!file.exists(miniconda)) {
			message("Installing Miniconda...")
			reticulate::install_miniconda()
		}

		if (!reticulate::condaenv_exists(envname)) {
			reticulate::conda_create(envname, packages = "python>=3.8")
		}

		cli::cli_inform("Installing BayesCCal into conda environment: {.val envname}")

		tryCatch({
			reticulate::conda_install(envname, packages = "BayesCCal", pip = TRUE)
		}, error = function(e) {
			cli::cli_alert_danger("Installation of {.pkg BayesCCal} failed: {e$message}")
			stop(e)
		})

		reticulate::use_condaenv(envname, required = TRUE)

		envdir = paste0(reticulate::miniconda_path(), "/envs/", envname)
		cli::cli_alert_success("Installation of miniconda successfull. Using environment {.val {envdir}}")
	} else {
		# Create virtualenv if needed
		if (!reticulate::virtualenv_exists(envname)) {
			cli::cli_inform("Creating virtualenv {.strong {envname}}")
			if (is.null(python)) {
				python_config = reticulate::py_discover_config()
				cli::cli_inform("Using Python {python_config$version} found at {.val {python}}")
			}
			reticulate::virtualenv_create(envname, python = python)
		}
		reticulate::virtualenv_install(envname, packages = "BayesCCal")
		reticulate::use_virtualenv(envname)

		envdir = paste0(reticulate::virtualenv_root(), "/", envname)
		cli::cli_alert_success("Installation via virtualenv successful. Using environment {.val {envdir}}")
	}
	source_BCC_py()
	.BCC$env_name = envname
	.BCC$env_set = TRUE
}

