// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }
  
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
  
    echo("require(WeibullR)\n");
    echo("wblr_obj <- WeibullR::wblr(x = " + time + ", s = " + event + ")\n");
    echo("wblr_obj <- WeibullR::wblr.fit(wblr_obj, method.fit = \"" + method + "\")\n");
    echo("wblr_obj <- WeibullR::wblr.conf(wblr_obj, ci = " + conf + ", method.conf = \"" + method_conf + "\")\n");
    echo("plot(wblr_obj)\n");
  
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(WeibullR)){stop(" + i18n("Preview not available, because package WeibullR is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(WeibullR)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }
  
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
  
    // Create wblr object
    echo("wblr_obj <- WeibullR::wblr(x = " + time + ", s = " + event + ")\n");

    // Fit the model
    echo("wblr_obj <- WeibullR::wblr.fit(wblr_obj, method.fit = \"" + method + "\")\n");

    // Add confidence bounds
    echo("wblr_obj <- WeibullR::wblr.conf(wblr_obj, ci = " + conf + ", method.conf = \"" + method_conf + "\")\n");
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Life Data Analysis results")).print();	
	}
    function parseVar(fullPath) {
        if (!fullPath) return {df: '', col: '', raw_col: ''};
        return fullPath;
    }
  
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
  
    var save_name = getValue("lda_save.objectname");

    echo("require(WeibullR)\n");
    echo("rk.header(\"Life Data Analysis (Weibull)\", level=3);\n");

    // Extract parameters from the *last* fit
    echo("fit_list <- wblr_obj$fit[[length(wblr_obj$fit)]]$fit_vec\n");
    echo("param_table <- data.frame(Parameter = names(fit_list), Value = as.numeric(fit_list))\n");

    echo("rk.header(\"Parameter Estimates (" + method.toUpperCase() + ")\", level=4);\n");
    echo("rk.results(param_table)\n");

    echo("rk.graph.on()\n");
    echo("plot(wblr_obj, main = \"Weibull Probability Plot\")\n");
    echo("rk.graph.off()\n");

    if (save_name != "") {
        echo("assign(\"" + save_name + "\", wblr_obj, envir = .GlobalEnv)\n");
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var ldaSave = getValue("lda_save");
		var ldaSaveActive = getValue("lda_save.active");
		var ldaSaveParent = getValue("lda_save.parent");
		// assign object to chosen environment
		if(ldaSaveActive) {
			echo(".GlobalEnv$" + ldaSave + " <- wblr_obj\n");
		}	
	}

}

