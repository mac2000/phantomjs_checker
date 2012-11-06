var page = require('webpage').create(),
    system = require('system'),
    result = {
        javascript_errors: [],
        network_errors: []
    };

// PROCESS COMMAND LINE ARGUMENTS
if(system.args.length < 2 || system.args[1].indexOf('http') !== 0) {
    console.log('Usage: phantomjs check.js http://rabota.ua')
    phantom.exit();
}

// CONFIGURE PHANTOM.JS
page.settings.loadImages = false;
page.onError = function(error){
    result.javascript_errors.push(error);
};
page.onResourceReceived = function(response) {
    if(response.status > 400) {
        result.network_errors.push({
            url: response.url,
            status: response.status
        });
    }
}

// OPEN GIVEN URL
page.open(system.args[1], function(status){
    result.status = status;
    result.url = system.args[1];
    console.log(JSON.stringify(result));
    phantom.exit();
});
