############################
# Input
############################
mmmst = require 'minimist'

argv = mmmst process.argv.slice(2)
if not argv.q or not argv.n
	console.log "please -q and -n options"
	return

queryWord = argv.q
if isNaN(argv.n) is true
	console.log "please -q input int number 1-100"
	return

searchNumber = Math.ceil argv.n
if 100 < searchNumber or searchNumber < 1
	console.log "oh error number"
	return

############################
# Accesser
############################
URI = require 'URIjs'
http = require "http"
util = require "util"
apiBaseURI = 'http://ajax.googleapis.com/ajax/services/search/images'
separator = argv.s or '\n'
downloadUrls = []

apiAccess = (i = 0) ->
	url = new URI apiBaseURI
	url.addSearch
		q: queryWord
		v: "1.0"
		hl: "ja"
		safe: "off"
		start: i * 4
	http
		.get url.toString(), (res) ->
			body = ''
			res.setEncoding 'utf8'
			res.on 'data', (chunk) ->
				body += chunk
			res.on 'end', (res) ->
				ret = JSON.parse body
				for result in ret.responseData.results
					if result.unescapedUrl
						util.print  result.unescapedUrl + separator
						downloadUrls.push result.unescapedUrl
				if i is searchNumber
					downloading()
				else apiAccess(i + 1)
		.on 'error', (err) ->
			console.log err. messege
			return

############################
# Download
############################
fs = require "fs"
https = require "https"
downloading = () ->
	if not argv.d then return
	intToArrangedString = (i) ->
		if i >= 100 then return "" + i
		if 100 > i >= 10 then return "0" + i
		if 10 > i then return  "00" + i
	imgDownload = (i) ->
		i = i or 0
		if not downloadUrls[i]
			return console.log "done."
		urlString = downloadUrls[i]
		url = new URI urlString
		if url.protocol() is "https"
			httpAccess = https
		else
			httpAccess = http
		req = httpAccess.get urlString, (res) ->
			savePath = queryWord + intToArrangedString(i) + "." + url.suffix()
			console.log savePath
			outFile = fs.createWriteStream savePath
			res.pipe outFile
			res.on 'end', () ->
				outFile.close()
				i += 1
				imgDownload i
		req.on 'error', (err) ->
			console.dir err
	imgDownload()


############################
# Fire
############################

apiAccess()