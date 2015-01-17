var swig = require('swig'),
	http = require('http'),
	fs = require('fs'),
	path = require('path'),
	Router = require('router'),
	statics = require('./statics')
	// db = require('./db')

var error = fs.createWriteStream('../log/error.log',{flags: 'a'});//手动记录日志

const PORT = 10086

swig.setFilter('getfilename',function(input){
	return '[' + input.replace(path.extname(input),'') + ']'
})

var tpl = swig.compileFile('../view/index.swig')
var router = Router()
var emotions = fs.readdirSync('../public/emotions/')
router.use(statics('../public/',{
	root: '/public'
}))
router.route('/').get(function(req,res,next){
	res.writeHead(200,{
		'Content-Type': 'text/html'
	})
	res.end(tpl({
		port: PORT,
		staticsRoot: '/public/',
		emotions: emotions
	}))
	next()
})

router.use(function(err,req,res,next){
	var errlog = '[' + new Date() + ']: ' + req.url + '\n'
	error.write(errlog + err.stack + '\n')
	next()
})

var server = http.createServer(function(req,res){
	router(req,res,function(){})
})

server.listen(PORT)

module.exports = server


