utils = exports? and @ or @utils = {}

os = require 'os'
fs = require 'fs'
http = require 'http'
child_process = require 'child_process'

red = `'\033[0;31m'`
green = `'\033[0;32m'`
yellow = `'\033[0;33m'`
reset = `'\033[0m'`

Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output

utils.warn = (msg, sign = '!') ->
    console.log "#{yellow}[#{sign}] #{msg}#{reset}"

utils.err = (msg, sign = '!') ->
    console.log "#{red}[#{sign}] #{msg}#{reset}"

utils.success = (msg, sign = '+') ->
    console.log "#{green}[#{sign}] #{msg}#{reset}"


utils.limited = (items, async, final, limit = 4 * os.cpus().length) ->
    results = []
    running = 0

    launcher = () ->
        while running < limit and items.length > 0
            item = items.shift()

            async(item, (result) ->
                results.push result
                running--
                if items.length > 0
                    launcher()
                else if running is 0
                    final(results)
            )
            running++

    launcher()

utils.read_links = (file_name) ->
    links = []
    if fs.existsSync file_name
        links = fs.readFileSync file_name, 'utf-8'
        links = (link.trim() for link in links.split("\n")).filter (x) -> x.length > 0 and x.indexOf('http') is 0
        return links
    else
        return links

utils.get_sitemap_contents = (url, callback) ->
    result = {url: url, status: null, links: []}
    req = http.get url, (res) ->
        result.status = res.statusCode
        if res.statusCode > 400
            utils.err "#{url}", "HTTP:#{res.statusCode}"
        data = ''
        res.on 'data', (chunk) ->
            data += chunk.toString()
        res.on 'end', () ->
            for link in data.match(/<loc>[^<]+<\/loc>/gi)
                link = link.replace(/<\/?loc>/g, '').trim()
                if link.indexOf('https://') is 0
                    link = link.replace('https://', 'http://')

                if link.indexOf('http') is 0
                    result.links.push link

            callback(result)
    req.on 'error', (err) ->
        utils.err "#{url}", "HTTP:#{err.errno}"
        result.status = err.errno
        callback(result)

utils.check_link_with_phantomjs = (arg, callback) ->
    child_process.exec 'phantomjs check.coffee "' + arg + '"', (error, stdout, stderr) ->
        result = JSON.parse(stdout)

        if not(result.status is 'success')
            utils.err "#{result.url}", "HTTP:#{result.status}"

        if result.network_errors.length > 0
            for err in result.network_errors
                utils.err "#{result.url} > #{err.url}", "HTTP:#{err.status}"

        if result.javascript_errors.length > 0
            for err in result.javascript_errors
                utils.err "#{result.url} > #{err}", "JS"

        if result.links.length > 0
            utils.limited result.links, utils.check_link_response_code, (results = []) ->
                result.links = results
                for link in result.links
                    if link.status > 400
                        utils.err "#{result.url} > #{link.url}", "HTTP:#{link.status}"
                callback(result)
        else
            callback(result)

utils.check_link_response_code = (arg, callback) ->
    result = {url: arg, status: null}
    req = http.get arg, (res) ->
        result.status = res.statusCode
        callback(result)
    req.on 'error', (err) ->
        result.status = err.errno
        callback(result)
