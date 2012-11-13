Links checker
=============

Script gets set of links to check from given sitemaps and links, then it checks that all pages are work and have no errors or broken links on them.

How it works
============

batch.coffee
------------

You can:

check one link: `coffee batch.coffee http://rabota.ua`
check many links: `coffee batch.coffee http://mac-blog.org.ua/sitemap.xml`
check links from file: `coffee batch.coffee links.txt`

Notice that file can contain both links to pages and links to sitemaps.

Usage example:

    coffee batch.coffee links.txt
    [+] 4 link(s) to check retrieved
    [HTTP:404] http://php.mac.rabota.ua/index.html > http://php.mac.rabota.ua/xxx.js
    [JS] http://php.mac.rabota.ua/broken.html > TypeError: 'null' is not an object (evaluating 'document.getElementsByTagName('P').item(1).innerHTML = 'World'')
    [HTTP:404] http://php.mac.rabota.ua/index.html > http://mac-blog.org.ua/aaa/bbbb/ccc.html
    [HTTP:500] http://rabota.ua > http://top.rabota.ua/
    [+] All done

check.coffee
------------

`batch.coffee` uses this script to check page for javascript errors, missed resources and to get all links on page.

Usage example:

    phantomjs check.coffee http://rabota.ua

    {
        "javascript_errors":[],
        "network_errors":[],
        "status":"success",
        "location":"http://rabota.ua",
        "url":"http://rabota.ua",
        "links":[
            "http://rabota.ua/jobsearch/cvbuilder",
            "http://rabota.ua/jobsearch/login"
        ]
    }


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
