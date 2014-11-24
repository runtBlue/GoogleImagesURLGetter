############################
# Input
############################

mmmst = require 'minimist'
argv = mmmst process.argv.slice(2)
# console.log argv
if not argv.q or not argv.n
	console.log "please -q and -n options"
	return
queryWord = argv.q
if isNaN(argv.n) is true
	console.log "please -q input number"
searchNumber = argv.n
if 100 < searchNumber
	console.log "oh big number"
searchNumber = Math.ceil searchNumber
############################
# Accesser
############################

URI = require 'URIjs'

for i in [1..searchNumber]
	url = new URI 'http://ajax.googleapis.com/ajax/services/search/images'
	url.addSearch
		q: queryWord
		v: "1.0"
		hl: "ja"
		safe: "off"
		start: i
	request = require "request"
	request url.toString(), (err, res, body) ->
		if not err or res.statusCode is 200
			data = JSON.parse(body)
			for result in data.responseData.results
				console.log result.unescapedUrl
		else
			console.log "error: " + res.statusCode
			return