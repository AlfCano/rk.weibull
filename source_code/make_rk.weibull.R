local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.weibull",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard plugin for Life Data Analysis and Warranty Prediction using the 'WeibullR' package.",
      version = "0.0.2",
      url = "https://github.com/AlfCano/rk.weibull",
      license = "GPL (>= 3)"
    )
  )

  # Menu Hierarchy
  common_hierarchy <- list("analysis", "Industrial Stats", "Reliability")

  # =========================================================================================
  # JS Helper
  # =========================================================================================
  js_parse_helper <- "
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }
  "

  # =========================================================================================
  # COMPONENT 1: Life Data Analysis (Weibull)
  # =========================================================================================

  help_lda <- rk.rkh.doc(
    title = rk.rkh.title(text = "Life Data Analysis (Weibull)"),
    summary = rk.rkh.summary(text = "Fit a 2-parameter Weibull distribution to life data (time-to-failure) and generate probability plots."),
    usage = rk.rkh.usage(text = "Select the Time variable and the Event/Censor variable (1=Failure, 0=Suspension). Choose the fitting method (RR or MLE).")
  )

  lda_selector <- rk.XML.varselector(id.name = "lda_selector")

  lda_time <- rk.XML.varslot(label = "Time to Failure / Suspension", source = "lda_selector", required = TRUE, id.name = "lda_time")
  lda_event <- rk.XML.varslot(label = "Event Status (1=Fail, 0=Suspension)", source = "lda_selector", required = TRUE, id.name = "lda_event")

  lda_method <- rk.XML.dropdown(label = "Analysis Method", options = list(
      "Rank Regression (RR)" = list(val = "rr", chk = TRUE),
      "Maximum Likelihood (MLE)" = list(val = "mle")
  ), id.name = "lda_method")

  lda_conf <- rk.XML.spinbox(label = "Confidence Level (0-1)", min = 0.5, max = 0.99, initial = 0.95, id.name = "lda_conf")
  lda_plot_type <- rk.XML.cbox(label = "Show Confidence Bounds on Plot", value = "1", chk = TRUE, id.name = "lda_plot_type")

  # Handshake Name: wblr_obj
  lda_save <- rk.XML.saveobj(label = "Save Weibull Object", chk = TRUE, initial = "wblr_obj", id.name = "lda_save")
  lda_preview <- rk.XML.preview(mode = "plot")

  dialog_lda <- rk.XML.dialog(
    label = "Life Data Analysis",
    child = rk.XML.row(
        lda_selector,
        rk.XML.col(
            lda_time,
            lda_event,
            rk.XML.frame(lda_method, lda_conf, lda_plot_type, label = "Analysis Settings"),
            lda_save,
            lda_preview
        )
    )
  )

  js_body_lda <- '
    var time = getValue("lda_time");
    var event = getValue("lda_event");
    var method = getValue("lda_method");
    var conf = getValue("lda_conf");
    var show_conf = getValue("lda_plot_type");

    var method_conf = "";
    if (method == "mle") {
        method_conf = "fm";
    } else {
        method_conf = "pivotal-rr";
    }
  '

  # CALC
  js_calc_lda <- paste0(js_parse_helper, js_body_lda, '
    // Create wblr object
    echo("wblr_obj <- WeibullR::wblr(x = " + time + ", s = " + event + ")\\n");

    // Fit the model
    echo("wblr_obj <- WeibullR::wblr.fit(wblr_obj, method.fit = \\"" + method + "\\")\\n");

    // Add confidence bounds
    echo("wblr_obj <- WeibullR::wblr.conf(wblr_obj, ci = " + conf + ", method.conf = \\"" + method_conf + "\\")\\n");
  ')

  # PRINT
  js_print_lda <- paste0(js_parse_helper, js_body_lda, '
    var save_name = getValue("lda_save.objectname");

    echo("require(WeibullR)\\n");
    echo("rk.header(\\"Life Data Analysis (Weibull)\\", level=3);\\n");

    // Extract parameters from the *last* fit
    echo("fit_list <- wblr_obj$fit[[length(wblr_obj$fit)]]$fit_vec\\n");
    echo("param_table <- data.frame(Parameter = names(fit_list), Value = as.numeric(fit_list))\\n");

    echo("rk.header(\\"Parameter Estimates (" + method.toUpperCase() + ")\\", level=4);\\n");
    echo("rk.results(param_table)\\n");

    echo("rk.graph.on()\\n");
    echo("plot(wblr_obj, main = \\"Weibull Probability Plot\\")\\n");
    echo("rk.graph.off()\\n");

    if (save_name != "") {
        echo("assign(\\\"" + save_name + "\\\", wblr_obj, envir = .GlobalEnv)\\n");
    }
  ')

  js_preview_lda <- paste0(js_parse_helper, js_body_lda, '
    echo("require(WeibullR)\\n");
    echo("wblr_obj <- WeibullR::wblr(x = " + time + ", s = " + event + ")\\n");
    echo("wblr_obj <- WeibullR::wblr.fit(wblr_obj, method.fit = \\"" + method + "\\")\\n");
    echo("wblr_obj <- WeibullR::wblr.conf(wblr_obj, ci = " + conf + ", method.conf = \\"" + method_conf + "\\")\\n");
    echo("plot(wblr_obj)\\n");
  ')

  component_lda <- rk.plugin.component(
    "Life Data Analysis",
    xml = list(dialog = dialog_lda),
    js = list(require="WeibullR", calculate=js_calc_lda, printout=js_print_lda, preview=js_preview_lda),
    hierarchy = common_hierarchy,
    rkh = list(help = help_lda)
  )

  # =========================================================================================
  # COMPONENT 2: Warranty / B-Life Prediction
  # =========================================================================================

  help_war <- rk.rkh.doc(
    title = rk.rkh.title(text = "Warranty Prediction (B-Life)"),
    summary = rk.rkh.summary(text = "Calculate B-Life metrics (e.g., B10 life) based on a previously fitted Weibull object."),
    usage = rk.rkh.usage(text = "Select a saved 'wblr' object from the Life Data Analysis step. Specify the probability of failure (Unreliability).")
  )

  war_selector <- rk.XML.varselector(id.name = "war_selector")

  war_obj <- rk.XML.varslot(label = "Fitted Weibull Object", source = "war_selector", classes = "wblr", required = TRUE, id.name = "war_obj")
  war_prob <- rk.XML.input(label = "Probability of Failure (e.g. 0.1 for B10)", initial = "0.1", id.name = "war_prob")

  dialog_war <- rk.XML.dialog(
    label = "Warranty Prediction",
    child = rk.XML.row(
        war_selector,
        rk.XML.col(
            war_obj,
            war_prob,
            rk.XML.stretch()
        )
    )
  )

  js_body_war <- '
    var obj = getValue("war_obj");
    var prob = getValue("war_prob");
  '

  js_calc_war <- '// Calculation performed in printout'

  # PRINT: Updated with Case-Insensitive Search
  js_print_war <- paste0(js_parse_helper, js_body_war, '
    echo("require(WeibullR)\\n");
    echo("rk.header(\\"Warranty Prediction (B-Life)\\", level=3);\\n");

    // Helper function: Case-Insensitive parameter search
    echo("get_weibull_params <- function(obj) {\\n");
    echo("  if(is.null(obj$fit)) return(NULL)\\n");
    echo("  for(i in length(obj$fit):1) {\\n");
    echo("    vec <- obj$fit[[i]]$fit_vec\\n");
    echo("    if(!is.null(vec)) {\\n");
    echo("      nm <- tolower(names(vec))\\n");
    echo("      # Check for beta/eta (handling capitalization)\\n");
    echo("      if(all(c(\\"beta\\", \\"eta\\") %in% nm)) {\\n");
    echo("         beta_val <- unname(vec[match(\\"beta\\", nm)])\\n");
    echo("         eta_val  <- unname(vec[match(\\"eta\\", nm)])\\n");
    echo("         return(list(beta=beta_val, eta=eta_val))\\n");
    echo("      }\\n");
    echo("    }\\n");
    echo("  }\\n");
    echo("  return(NULL)\\n");
    echo("}\\n");

    echo("params <- get_weibull_params(" + obj + ")\\n");
    echo("p <- " + prob + "\\n");

    echo("if (!is.null(params)) {\\n");
    echo("  b_life <- params$eta * (-log(1 - p))^(1/params$beta)\\n");
    echo("  res_table <- data.frame(Metric = c(\\"Unreliability (P)\\", \\"Predicted Life (Time)\\"), Value = c(p, round(b_life, 4)))\\n");
    echo("  rk.results(res_table)\\n");
    echo("} else {\\n");
    echo("  rk.print(\\"Error: Could not find valid Weibull parameters (beta/eta) in the selected object.\\")\\n");
    echo("  rk.print(paste(\\"Object contains fits:\\", length(" + obj + "$fit)))\\n");
    echo("}\\n");
  ')

  component_war <- rk.plugin.component(
    "Warranty Prediction",
    xml = list(dialog = dialog_war),
    js = list(require="WeibullR", calculate=js_calc_war, printout=js_print_war),
    hierarchy = common_hierarchy,
    rkh = list(help = help_war)
  )

  # =========================================================================================
  # BUILD SKELETON
  # =========================================================================================

  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_lda), # Main dialog
    js = list(require="WeibullR", calculate=js_calc_lda, printout=js_print_lda, preview=js_preview_lda),
    rkh = list(help = help_lda),
    components = list(
        component_war
    ),
    pluginmap = list(
        name = "Life Data Analysis",
        hierarchy = common_hierarchy
    ),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.weibull' generated successfully.\n")
  cat("To complete installation:\n")
  cat("  1. rk.updatePluginMessages(path=\".\")\n")
  cat("  2. devtools::install(\".\")\n")
})
