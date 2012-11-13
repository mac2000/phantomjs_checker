system = require 'system'

Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output

try
    page = require('webpage').create()

    result = {
        javascript_errors: [],
        network_errors: [],
        links: []
    }

    if system.args.length < 2 or system.args[1].indexOf('http') is not 0
        console.log 'Usage: phantomjs check.coffee <URL>'
        phantom.exit()

    page.onError = (error) ->
        result.javascript_errors.push error

    page.onResourceReceived = (response) ->
        if response.status >= 400
            result.network_errors.push({
                url: response.url,
                status: response.status
            })

    page.open system.args[1], (status) ->
        result.status = status
        result.url = system.args[1]

        if status is "success"
            result.location = page.evaluate ->
                document.location.toString()

            result.links = page.evaluate ->
                items = []
                anchors = document.getElementsByTagName 'A'
                for anchor in anchors
                    href = anchor.getAttribute('href')
                    if href
                        href = href.trim()
                        href = href.replace('https://', 'http://')
                        if (href.indexOf('http') is 0) or (href.indexOf('/') is 0) or (href.indexOf('..') is 0)
                            if href.indexOf('http') is 0
                                items.push href
                            else if href.indexOf('/') is 0
                                items.push (("http://#{document.location.host}/#{href}").replace(/\/+/g, '/'))
                            else
                                path = document.location.pathname
                                if path is '/'
                                    items.push((document.location + href).replace(/\/+/g, '/'))
                                else
                                    path = path.split('/')
                                    path.pop()
                                    path = path.join('/')
                                    if path.length is 0
                                        items.push (("http://#{document.location.host}/#{href}").replace(/\/+/g, '/'))
                                    else
                                        items.push ("http://#{document.location.host}#{path}#{href}")

                return items

            result.links = result.links.unique()

        console.log(JSON.stringify(result, null, "\t"))
        phantom.exit()

catch error
    error.url = system.args[1]
    error.status = "fail"
    console.log(JSON.stringify(error, null, "\t"))
    phantom.exit()
