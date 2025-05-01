#' Model prediction and calibration
#'
#' Predictions and calibrations for a binary classifier
#'
#' @param model trained model. Either a `caret::train()` object or a `tidymodels::workflow()` object.
#' @param new_data new data
#' @param train_data train data
#' @param train_labels train labels
#' @example examples/predict_calibrated.R
#' @export
predict_calibrated <- function(model, new_data, train_data, train_labels) {
	# Determine outcome variable name
	outcome_var <- NULL

	if (inherits(model, "train")) {
		rlang::check_installed("caret", "caret required")
		outcome_var <- tryCatch({
			if (!is.null(model$terms)) {
				as.character(model$terms[[2]])
			} else if (!is.null(model$finalModel$terms)) {
				as.character(model$finalModel$terms[[2]])
			} else if (!is.null(model$trainingData)) {
				".outcome"
			} else {
				NULL
			}
		}, error = function(e) NULL)

	} else if (inherits(model, "workflow")) {
		rlang::check_required("tidymodels", "tidymodels required")
		outcome_var <- tryCatch({
			blueprint <- model$pre$mold$blueprint
			names(blueprint$ptypes$outcomes)[1]
		}, error = function(e) NULL)
	}

	# Remove outcome column from new_data if present
	if (!is.null(outcome_var) && outcome_var %in% names(new_data)) {
		new_data <- new_data[, setdiff(names(new_data), outcome_var), drop = FALSE]
	}

	# Predict probabilities on training data
	if (inherits(model, "workflow")) {
		probabilities <- stats::predict(model, new_data = train_data, type = "prob")
	} else {
		probabilities <- stats::predict(model, newdata = train_data, type = "prob")
	}

	# Convert labels to binary 0/1 (1 = positive class)
	train_labels <- factor(train_labels)
	positive_class <- levels(train_labels)[1]
	negative_class <- setdiff(levels(train_labels), positive_class)
	y <- as.integer(!(train_labels == positive_class))  # 1 = positive class

	# Calibrate
	cal <- .BCC$Rcalibrator_binary()
	if (inherits(model, "workflow")) {
		cal$calcDensities(as.numeric(probabilities[[paste0(".pred_", positive_class)]]), y)
	} else {
		cal$calcDensities(as.numeric(probabilities[[positive_class]]), y)
	}

	# Predict on new data
	if (inherits(model, "workflow")) {
		predict_probas <- as.data.frame(predict(model, new_data = new_data, type = "prob"))
		names(predict_probas) = gsub(".pred_", "", names(predict_probas), fixed = TRUE)
		pred_probs <- as.numeric(predict_probas[[positive_class]])
	} else {
		predict_probas <- predict(model, newdata = new_data, type = "prob")
		pred_probs <- as.numeric(predict_probas[[positive_class]])
	}

	calibrated_probs <- cal$predict_proba(pred_probs)

	# Return original + calibrated output (with clean names)
	calibrated_df <- as.data.frame(calibrated_probs)
	names(calibrated_df) = c(positive_class, negative_class)


	list(
		probs_orig = predict_probas,
		probs_cali = calibrated_df,
		proportion = cal$getProportion(pred_probs)
	)
}
