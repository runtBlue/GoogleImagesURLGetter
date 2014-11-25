// Generated by CoffeeScript 1.8.0
(function() {
  var URI, apiAccess, apiBaseURI, argv, downloadUrls, downloading, fs, http, mmmst, queryWord, searchNumber, separator, util;

  mmmst = require('minimist');

  argv = mmmst(process.argv.slice(2));

  if (!argv.q || !argv.n) {
    console.log("please -q and -n options");
    return;
  }

  queryWord = argv.q;

  if (isNaN(argv.n) === true) {
    console.log("please -q input int number 1-100");
    return;
  }

  searchNumber = Math.ceil(argv.n);

  if (100 < searchNumber || searchNumber < 1) {
    console.log("oh error number");
    return;
  }

  URI = require('URIjs');

  http = require("http");

  util = require("util");

  apiBaseURI = 'http://ajax.googleapis.com/ajax/services/search/images';

  separator = argv.s || '\n';

  downloadUrls = [];

  apiAccess = function(i) {
    var url;
    if (i == null) {
      i = 0;
    }
    url = new URI(apiBaseURI);
    url.addSearch({
      q: queryWord,
      v: "1.0",
      hl: "ja",
      safe: "off",
      start: i * 4
    });
    return http.get(url.toString(), function(res) {
      var body;
      body = '';
      res.setEncoding('utf8');
      res.on('data', function(chunk) {
        return body += chunk;
      });
      return res.on('end', function(res) {
        var result, ret, _i, _len, _ref;
        ret = JSON.parse(body);
        _ref = ret.responseData.results;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          result = _ref[_i];
          if (result.unescapedUrl) {
            util.print(result.unescapedUrl + separator);
            downloadUrls.push(result.unescapedUrl);
          }
        }
        if (i === searchNumber) {
          return downloading();
        } else {
          return apiAccess(i + 1);
        }
      });
    }).on('error', function(err) {
      console.log(err.messege);
    });
  };

  fs = require("fs");

  downloading = function() {
    var imgDownload, intToArrangedString;
    if (!argv.d) {
      return;
    }
    intToArrangedString = function(i) {
      if (i >= 100) {
        return "" + i;
      }
      if ((100 > i && i >= 10)) {
        return "0" + i;
      }
      if (10 > i) {
        return "00" + i;
      }
    };
    imgDownload = function(i) {
      var req, urlString;
      i = i || 0;
      if (!downloadUrls[i]) {
        return console.log("done.");
      }
      urlString = downloadUrls[i];
      req = http.get(urlString, function(res) {
        var outFile, savePath, url;
        url = new URI(urlString);
        savePath = queryWord + intToArrangedString(i) + "." + url.suffix();
        console.log(savePath);
        outFile = fs.createWriteStream(savePath);
        res.pipe(outFile);
        return res.on('end', function() {
          outFile.close();
          i += 1;
          return imgDownload(i);
        });
      });
      return req.on('error', function(err) {
        return console.dir(err);
      });
    };
    return imgDownload();
  };

  apiAccess();

}).call(this);
