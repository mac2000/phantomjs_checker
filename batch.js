var child_process = require('child_process'),
    os = require('os'),
    fs = require('fs'),
    items = [],
    results = [],
    running = 0,
    limit = 2 * os.cpus().length, // limit parallel execution
    red = '\033[31m',
    green = '\033[32m',
    reset = '\033[0m',
    t = Date.now();

// PROCESS COMMAND LINE ARGUMENTS
if(process.argv.length < 3) {
    console.log('Usage: node run.js <File with links or URL>');
    process.exit();
}

if(process.argv[2].indexOf('http') === 0) {
    items.push(process.argv[2]);
} else {
    if(fs.existsSync(process.argv[2])) {
        fs.readFileSync(process.argv[2], 'utf-8').split('\n').forEach(function(line){
            if(line.trim().indexOf('http') === 0) items.push(line.trim());
        });
    } else {
        console.log('File ' + process.argv[2] + ' does not exists');
        process.exit();
    }
}

// PROCESS ITEMS IN PARALLEL
// http://book.mixu.net/ch7.html
function async(arg, callback) {
    console.log('[>] ' + arg);
    child_process.exec('phantomjs check.js "' + arg + '"', function(error, stdout, stderr){
        var result = JSON.parse(stdout);
        console.log(green + '[<] ' + arg + reset);
        callback(result);
    });
}

function final() {
    console.log('');
    t = ((Date.now() - t) / 1000).toFixed();
    console.log(green + '[+] ' + results.length + ' URLs processed in ' + t + ' seconds' + reset);

    var errors = results.filter(function(result){
        return result.javascript_errors.length > 0 || result.network_errors.length > 0 || result.status != 'success';
    });

    if(errors.length > 0) {
        console.log(red + '[!] ' + errors.length + ' errors found' + reset);

        var statuses = [];
        var js = [];

        errors.forEach(function(error){
            if(error.status != 'success') {
                if(typeof statuses[error.status] === 'undefined') {
                    statuses[error.status] = [];
                }
                statuses[error.status].push(error.url);
            }

            if(error.network_errors.length > 0) {
                error.network_errors.forEach(function(network_error){
                    if(typeof statuses[network_error.status] === 'undefined') {
                        statuses[network_error.status] = [];
                    }
                    statuses[network_error.status].push(network_error.url);
                });
            }

            if(error.javascript_errors.length > 0) {
                error.javascript_errors.forEach(function(javascript_error){
                    if(typeof js[error.url] === 'undefined') {
                        js[error.url] = [];
                    }
                    js[error.url].push(javascript_error);
                });
            }
        });

        if(Object.keys(statuses).length > 0) {
            console.log('');
            console.log(red + '[!] Bad status errors' + reset);
            Object.keys(statuses).forEach(function(key){
                console.log(red + '[!] ' + key + reset);
                statuses[key].forEach(function(url){
                    console.log('    ' + url);
                });
            });
        }

        if(Object.keys(js).length > 0) {
            console.log('');
            console.log(red + '[!] java script errors' + reset);
            Object.keys(js).forEach(function(url){
                console.log(red + '[!] ' + url + reset);
                js[url].forEach(function(err){
                    console.log('    ' + err);
                    console.log('');
                });
            });
        }
    } else {
        console.log(green + '[+] There is no errors' + reset);
    }
}

function launcher() {
    while(running < limit && items.length > 0) {
        var item = items.shift();
        async(item, function(result){
            results.push(result);
            running--;
            if(items.length > 0) {
                launcher();
            } else if(running == 0) {
                final();
            }
        });
        running++;
    }
}

launcher();
