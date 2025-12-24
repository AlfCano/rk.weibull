// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!



function preprocess(is_preview){
	// add requirements etc. here
	echo("require(WeibullR)\n");
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated
// Calculation performed in printout
}

function printout(is_preview){
	// printout the results
	new Header(i18n("Warranty Prediction results")).print();

    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }
  
    var obj = getValue("war_obj");
    var prob = getValue("war_prob");
  
    echo("require(WeibullR)\n");
    echo("rk.header(\"Warranty Prediction (B-Life)\", level=3);\n");

    // Helper function: Case-Insensitive parameter search
    echo("get_weibull_params <- function(obj) {\n");
    echo("  if(is.null(obj$fit)) return(NULL)\n");
    echo("  for(i in length(obj$fit):1) {\n");
    echo("    vec <- obj$fit[[i]]$fit_vec\n");
    echo("    if(!is.null(vec)) {\n");
    echo("      nm <- tolower(names(vec))\n");
    echo("      # Check for beta/eta (handling capitalization)\n");
    echo("      if(all(c(\"beta\", \"eta\") %in% nm)) {\n");
    echo("         beta_val <- unname(vec[match(\"beta\", nm)])\n");
    echo("         eta_val  <- unname(vec[match(\"eta\", nm)])\n");
    echo("         return(list(beta=beta_val, eta=eta_val))\n");
    echo("      }\n");
    echo("    }\n");
    echo("  }\n");
    echo("  return(NULL)\n");
    echo("}\n");

    echo("params <- get_weibull_params(" + obj + ")\n");
    echo("p <- " + prob + "\n");

    echo("if (!is.null(params)) {\n");
    echo("  b_life <- params$eta * (-log(1 - p))^(1/params$beta)\n");
    echo("  res_table <- data.frame(Metric = c(\"Unreliability (P)\", \"Predicted Life (Time)\"), Value = c(p, round(b_life, 4)))\n");
    echo("  rk.results(res_table)\n");
    echo("} else {\n");
    echo("  rk.print(\"Error: Could not find valid Weibull parameters (beta/eta) in the selected object.\")\n");
    echo("  rk.print(paste(\"Object contains fits:\", length(" + obj + "$fit)))\n");
    echo("}\n");
  

}

