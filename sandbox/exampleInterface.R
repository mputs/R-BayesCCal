library(caret)

# Load data
url <- "https://archive.ics.uci.edu/ml/machine-learning-databases/00267/data_banknote_authentication.txt"
data <- read.csv(url, header = FALSE)
colnames(data) <- c("variance", "skewness", "kurtosis", "entropy", "class")

# Convert class to factor and relabel levels
data$class <- as.factor(data$class)
levels(data$class) <- c("genuine", "forged") # <--- fix levels here!

# Split data
set.seed(123)
trainIndex <- createDataPartition(data$class, p = 0.8, list = FALSE)
trainData <- data[trainIndex, ]
testData  <- data[-trainIndex, ]

# Train model
set.seed(123)
model <- train(
  class ~ ., # now it's safe
  data = trainData,
  method = "glm",
  family = "binomial",
  trControl = trainControl(
    method = "cv",
    number = 5,
    classProbs = TRUE
  )
)

# Predict probabilities
probabilities <- predict(model, newdata = trainData, type = "prob")

source_python("RBayesCCal.py")
cal = Rcalibrator_binary()
y <- ifelse(trainData$class == "genuine", 1L, 0L)
cal$calcDensities(probabilities$genuine, y)
predict_probas <- predict(model, newdata = testData, type = "prob")
cal$getProportion(predict_probas$genuine)
cal$predict_proba(predict_probas$genuine)
