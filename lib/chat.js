var IO = require('socket.io'),
	server = require('./ws'),
	Emitter = require('events').EventEmitter,
	randomName = require('chinese-random-name'),
	fs = require('fs'),
	swig = require('swig'),
	crypto = require('crypto')
var io = IO(server),
	users = io.sockets

var sockets = []

io.on('connection',function(socket){
	console.log(socket.conn.remoteAddress)
	socket.username = assignName(socket.client.id)
	chat.emit('enter',socket)
	socket.on('msg',function(recive){
		chat.emit('msg',socket,recive)
	}).on('@user',function(){
		chat.emit('@user',socket)
	}).on('voice',function(recive){
		chat.emit('voice',socket,recive)
	}).on('pic',function(recive){
		chat.emit('pic',socket,recive)
	}).on('disconnect',function(){
		chat.emit('leave',socket)
	})
})

// 进入聊天室，随机分配名字 √
// 聊天开始，@用户，推送私信 √
// 点击私信，跳转到楼层 √
// @返回当前房间的所有用户 √

var chat = new Emitter,
	room = 'chat'

chat.on('enter',function(socket,username){
	socket.join(room)
	// sockets.push(socket)
	users.in(room).emit('enter',{
		name: socket.username, //随机名字 不重复，唯一 id
		time: Date.now()
	})
	socket.emit('_connect',{
		name: socket.username
	})
}).on('msg',function(socket,recive){
	handleMsg(recive.msg,function(msg,to){
		users.in(room).emit('msg',{
			msg: msg,
			avator: recive.avator,
			name: socket.username,
			color: recive.color,
			time: Date.now(),
			sign: to.sign
		})	
		if(to.length){
			to.from = socket.username
			chat.emit('yo',to)
		}
	})
	
}).on('voice',function(socket,recive){
	// TODO
	users.in(room).emit('voice',{
		buf: recive.voice,
		avator: recive.avator,
		name: socket.username,
		color: recive.color,
		time: Date.now()
	})
}).on('pic',function(socket,recive){
	// TODO
	users.in(room).emit('pic',{
		pic: recive.pic,
		avator: recive.avator,
		name: socket.username,
		color: recive.color,
		time: Date.now()
	})
}).on('leave',function(socket){
	users.in(room).emit('leave',{
		name: socket.username,
		time: Date.now()
	})
	socket.leave(room)
	// sockets.splice(sockets.indexOf(socket),1)
}).on('@user',function(socket){
	socket.emit('@user',{
		userlist: getUserList(users,socket.username)
	})
}).on('yo',function(to){
	// if return obj is too big ,i would cause RangeError: Maximum call stack size exceeded
	getSocket(to).forEach(function(socket,index){
		socket.emit('yo',{
			from: to.from,
			msg: to.from + '刚刚提到了你',
			sign: to.sign[index]
		})
	})
})

function assignName(name){
	return randomName.generate()
}

function handleMsg(msg,callback) {
	var msg = swig.render('{{msg}}',{locals:{
		msg: msg
	}})
	var to = []
	to.sign = []
	if(msg.indexOf('@') !== -1){
		// 存在@,包裹
		msg = msg.replace(/@([a-zA-Z0-9\u4e00-\u9fa5_]*)/g,function(m,r){
			to.push(r)
			to.sign.push(generatorNum(r))
			return '<span>'+m+'</span>'
		})
	}
	// 处理 emotion
	msg = msg.replace(/\s\[([^\]]*)\]\s/g,function(m,r){
		return trans2Img(r)
	})
	callback && callback(msg,to)
}

function getUserList(users,hideName){
	return users.sockets.map(function(socket){
		if(hideName !== socket.username){
			return socket.username
		}else{
			return ''
		}
	})
}

function getSocket(names){
	return users.sockets.filter(function(socket){
		return names.indexOf(socket.username) !== -1
	})
}

function randomRange(lower,upper){
     return Math.round(Math.random() * (upper - lower) + lower);
}

function generatorNum(r){
	return crypto.createHash('md5').update(r).update(Date.now()+'').digest('hex')
}

function trans2Img(r){
	return '<img src="/public/emotions/' + r +'" class='+'"emotion"/>'
}