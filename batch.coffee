utils = require './utils'

if process.argv.length < 3
    console.log "Usage: coffee batch.coffee <URL or FILE>"
    process.exit()

links = []
sitemaps = []

if process.argv[2].indexOf('http') is 0
    if process.argv[2].split('/').pop() is 'sitemap.xml'
        sitemaps.push process.argv[2]
    else
        links.push process.argv[2]
else
    for url in utils.read_links('links.txt')
        if url.split('/').pop() is 'sitemap.xml'
            sitemaps.push url
        else
            links.push url

all_links_retrieved = (results = []) ->
    if results.length > 0
        results = results.filter (x) -> x.status is 200
        if results.length > 0
            results = results.map (x) -> x.links
            if results.length > 0
                results = [].concat.apply([], results)
                links = links.concat results

    links = links.unique().filter (x) -> not( x.split('/').pop() is 'sitemap.xml' )

    utils.success "#{links.length} link(s) to check retrieved"
    utils.limited links, utils.check_link_with_phantomjs, (results = []) ->
        utils.success "All done"

if sitemaps.length > 0
    utils.limited sitemaps, utils.get_sitemap_contents, all_links_retrieved
else
    all_links_retrieved()
