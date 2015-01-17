var fs = require('fs'),
	mime = require('mime'),
	path = require('path'),
	url = require('url')

var sendRes = function(req,res,statusCode,headers){
	res.writeHead(statusCode,headers)
	if(req.file){
		return fs.createReadStream(req.file).pipe(res)
	}else{
		return res.end(new Buffer(statusCode+''))
	}
}

module.exports = function(staticPath,options){
	options = options || {}
	var root = options.root || '/public'
	return function(req,res,next){
		if ('GET' != req.method && 'HEAD' != req.method) return next()
		var reqUrl = url.parse(req.url)
		var paths = reqUrl.pathname.split(path.sep),
			dirname = '/' + paths[1],
			basename = paths.splice(2).join(path.sep)
		if(reqUrl.pathname === root){
			return sendRes(req,res,403,{})
		}
		if(dirname === root){
			basename = path.resolve(staticPath,basename)
			fs.exists(basename,function(exists){
				if(exists){
					var stat = fs.statSync(basename)
					if(stat.isFile()){
						req.file = basename
						sendRes(req,res,200,{
							// 304...
							'Content-Type': mime.lookup(basename),
							'Content-Length': stat.size
						})
					}else{
						sendRes(req,res,403,{})
					}
				}else{
					// handle 404
					sendRes(req,res,404,{})
				}
			})
		}else{
			next()
		}	
	}
}