Phantom.js Checker
==================

Example set of scripts to check site for 404 and java script errors that can be run on cron or event better as your version control system hook.

How it works
============

check.js
--------

Loads desired url and logs all java script errors and resources that was not loaded.

Usage example:

    phantomjs check.js http://rabota.ua

    {
        "javascript_errors":[],
        "network_errors":[],
        "status":"success",
        "url":"http://rabota.ua"
    }

batch.js
--------

Loads butch of urls from file and calls `check.js` for each of them in parallel.

Usage example:

    node batch.js links.txt
    [>] http://rabota.ua
    [>] http://rabota.ua/broken.html
    [<] http://rabota.ua/broken.html
    [<] http://rabota.ua

    [+] 2 URLs processed in 3 seconds
    [!] 1 errors found

    [!] Bad status errors
    [!] 404
        http://rabota.ua/app.js
        http://rabota.ua/app.js

    [!] java script errors
    [!] http://rabota.ua/broken.html
        TypeError: 'null' is not an object (evaluating 'document.getElementsByTagName('P').item(1).innerHTML = 'World'')


Install
=======

Windows
-------

Download and install [node.js](http://nodejs.org/).
Download and extract [pahntom.js](http://phantomjs.org).

Both `node.exe` and `phantomjs.exe` must be accessible from console, so check that their folders are in your environment path.

Linux
-----

Node installation:

    sudo apt-get install python-software-properties
    sudo add-apt-repository ppa:chris-lea/node.js
    sudo apt-get update
    sudo apt-get install nodejs npm

Phantom installation (make sure to get fresh link for phantom):

    sudo apt-get install fontconfig # needed for 1.7.0
    wget http://phantomjs.googlecode.com/files/phantomjs-1.7.0-linux-i686.tar.bz2
    tar -jxvf phantomjs-1.7.0-linux-i686.tar.bz2
    sudo mv phantomjs-1.7.0-linux-i686/bin/phantomjs /usr/local/bin/
    rm -rf phantomjs-1.7.0-linux-i686*

To check that all installed just run:

    node -v
    v0.8.14

    phantomjs -v
    1.7.0
