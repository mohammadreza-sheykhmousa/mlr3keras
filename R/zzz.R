#' @import data.table
#' @import keras
#' @import paradox
#' @import mlr3misc
#' @import mlr3
#' @import checkmate
#' @importFrom R6 R6Class
#' @importFrom stats setNames
#' @description
#' A package that connects mlr3 to keras.
"_PACKAGE"


#' @title Reflections mechanism for keras
#'
#' @details
#' Used to store / extend available hyperparameter levels for options used throughout keras,
#' e.g. the available 'loss' for a given Learner.
#'
#' @format [environment].
#' @export
keras_reflections = new.env(parent = emptyenv())



register_mlr3 = function() { #nocov start
  x = utils::getFromNamespace("mlr_learners", ns = "mlr3")
  x$add("classif.kerasff", LearnerClassifKerasFF)
  x$add("classif.keras", LearnerClassifKeras)
  x$add("regr.kerasff", LearnerRegrKerasFF)
  x$add("regr.keras", LearnerRegrKeras)
  x$add("classif.tabnet", LearnerClassifTabNet)
  x$add("regr.tabnet", LearnerRegrTabNet)

  local({
    keras_reflections$loss = list(
        classif = c("binary_crossentropy", "categorical_crossentropy", "sparse_categorical_crossentropy"),
        regr = c("cosine_proximity", "cosine_similarity", "mean_absolute_error", "mean_squared_error",
          "poison", "squared_hinge", "mean_squared_logarithmic_error")
      )
  })
}

.onLoad = function(libname, pkgname) {
  register_mlr3()
  setHook(packageEvent("mlr3", "onLoad"), function(...) register_mlr3(), action = "append")
}

.onUnload = function(libpath) {
  event = packageEvent("mlr3", "onLoad")
  hooks = getHook(event)
  pkgname = vapply(hooks, function(x) environment(x)$pkgname, NA_character_)
  setHook(event, hooks[pkgname != "mlr3keras"], action = "replace")
}

# silence R CMD check for callbacks:
utils::globalVariables("model") # nocov end
