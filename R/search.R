#' @title Search
#' @description  Start the search for the best hyperparameter configuration. 
#' The call to search has the same signature as ```model.fit()```.
#' Models are built iteratively by calling the model-building function, which populates the hyperparameter space 
#' (search space) tracked by the hp object. The tuner progressively explores the space, recording metrics for 
#' each configuration.
#' 
#' @param tuner A tuner object
#' @param x	Vector, matrix, or array of training data (or list if the model has multiple inputs). 
#' If all inputs in the model are named, you can also pass a list mapping input names to data. x can be NULL
#'  (default) if feeding from framework-native tensors (e.g. TensorFlow data tensors).
#' @param y Vector, matrix, or array of target (label) data (or list if the model has multiple outputs). 
#' If all outputs in the model are named, you can also pass a list mapping output names to data. y can be 
#' NULL (default) if feeding from framework-native tensors (e.g. TensorFlow data tensors).
#' @param steps_per_epoch Integer. Total number of steps (batches of samples) to yield from generator before 
#' declaring one epoch finished and starting the next epoch. It should typically be equal to 
#' ceil(num_samples / batch_size). Optional for Sequence: if unspecified, will use the len(generator) 
#' as a number of steps.
#' @param batch_size Integer or `NULL`. Number of samples per gradient update.
#' If unspecified, `batch_size` will default to 32.
#' @param epochs to train the model. Note that in conjunction with initial_epoch, 
#' epochs is to be understood as "final epoch". The model is not trained for a number of iterations
#'  given by epochs, but merely until the epoch of index epochs is reached.
#' @param validation_data Data on which to evaluate the loss and any model metrics at the end of each epoch. 
#' The model will not be trained on this data. validation_data will override validation_split. 
#' validation_data could be: - tuple (x_val, y_val) of Numpy arrays or 
#' tensors - tuple (x_val, y_val, val_sample_weights) of Numpy arrays - dataset or a dataset iterator
#' @param validation_steps Only relevant if steps_per_epoch is specified. Total number of steps (batches of samples)
#'  to validate before stopping.
#' @param ... Some additional arguments
#' @return performs a search for best hyperparameter configuations
#' @importFrom reticulate tuple
#' @examples
#' 
#' \dontrun{
#' 
#' library(keras)
#' x_data <- matrix(data = runif(500,0,1),nrow = 50,ncol = 5) 
#' y_data <-  ifelse(runif(50,0,1) > 0.6, 1L,0L) %>% as.matrix()
#' x_data2 <- matrix(data = runif(500,0,1),nrow = 50,ncol = 5)
#' y_data2 <-  ifelse(runif(50,0,1) > 0.6, 1L,0L) %>% as.matrix()
#' 
#' 
#' HyperModel <- PyClass(
#'   'HyperModel',
#'   inherit = HyperModel_class(),
#'   list(
#'     
#'     `__init__` = function(self, num_classes) {
#'       
#'       self$num_classes = num_classes
#'       NULL
#'     },
#'     build = function(self,hp) {
#'       model = keras_model_sequential() 
#'       model %>% layer_dense(units = hp$Int('units',
#'                                            min_value = 32,
#'                                            max_value = 512,
#'                                            step = 32),
#'                             input_shape = ncol(x_data),
#'                             activation = 'relu') %>% 
#'         layer_dense(as.integer(self$num_classes), activation = 'softmax') %>% 
#'         compile(
#'           optimizer = tf$keras$optimizers$Adam(
#'             hp$Choice('learning_rate',
#'                       values = c(1e-2, 1e-3, 1e-4))),
#'           loss = 'sparse_categorical_crossentropy',
#'           metrics = 'accuracy')
#'     }
#'   )
#' )
#' 
#' hypermodel = HyperModel(num_classes=10L)
#' 
#' 
#' tuner = RandomSearch(hypermodel = hypermodel,
#'                      objective = 'val_accuracy',
#'                      max_trials = 2,
#'                     executions_per_trial = 1,
#'                      directory = 'my_dir5',
#'                      project_name = 'helloworld')
#'                      
#' tuner %>% fit_tuner(x_data, y_data, epochs = 1, validation_data = list(x_data2,y_data2)) 
#' }
#' @importFrom stats setNames
#' @export
fit_tuner <- function(tuner, x = NULL, y = NULL, steps_per_epoch = NULL, batch_size = NULL, epochs = NULL, 
                        validation_data = NULL, validation_steps = NULL, ...) {
  
  args = list(x = x, y = y, steps_per_epoch = steps_per_epoch,
           batch_size =  batch_size,
           epochs = epochs,
           validation_data = validation_data,
           validation_steps = validation_steps, ...)
  
  args$x <- x
  args$y <- y
  
  if(is.null(args$steps_per_epoch)) 
    args$steps_per_epoch <- steps_per_epoch
  else
    args$steps_per_epoch <- as.integer(steps_per_epoch)
  
  if(is.null(args$batch_size)) 
    args$batch_size <- batch_size
  else
    args$batch_size <- as.integer(batch_size)
  
  if(is.null(args$epochs)) 
    args$epochs <- epochs
  else
    args$epochs <- as.integer(epochs)
  
  if(is.null(validation_data)) 
    args$validation_data <- NULL
  else
    args$validation_data <- tuple(args$validation_data)
  
  if (is.null(args$validation_steps))
    args$validation_steps <- validation_steps
  else
    args$validation_steps <- as.integer(validation_steps)
  
  do.call(tuner$search, args)
  
}

#' @title Get best models
#' @description The function for retrieving the top best models with hyperparameters
#' Returns the best model(s), as determined by the tuner's objective.
#' The models are loaded with the weights corresponding to their best checkpoint (at the end of the best epoch of best trial).
#' This method is only a convenience shortcut. For best performance, It is recommended to retrain your Model on the full 
#' dataset using the best hyperparameters found during search.
#' 
#' @param tuner A tuner object
#' @param num_models When search is over, one can retrieve the best model(s)
#' @return the list of best model(s)
#' @export
get_best_models = function(tuner = NULL,num_models = NULL) {
  tuner = tuner
  tuner$get_best_models(num_models = as.integer(num_models))
}

