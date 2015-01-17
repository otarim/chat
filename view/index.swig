{%extends 'block/layout.swig'%}
{%block title-%}
ws demo
{%-endblock%}
{%block content-%}
<div class="container">
<header>
	<div class="unread">提醒</div>
</header>
<style>
	html,body {width: 100%;height: 100%;}
	* {box-sizing: border-box;}
	.container {height: 100%;position: relative;}
	header,footer {position: absolute;width: 100%;background: #ccc;}
	header {top: 0;left: 0;height: 3rem;padding: 0 10px;}
	.unread {position: relative;display: inline-block;width: 3rem;/* padding: 5px; */height: 36px;line-height: 36px;margin-top: 5px;}
	.unread i {position: absolute;width: 20px;height: 20px;background: #c00;top: -5px;border-radius: 20px;color: #fff;line-height: 20px;text-align: center;font-style: normal;font-size: 10px;}
	.unread-list {position: absolute;border: 1px solid #ccc;font-size: 10px;z-index: 100;background: #fff;line-height: 28px;padding: 0 5px;}
	.unread-list p {white-space: nowrap;}
	footer {bottom: 0;left: 0;height: 10rem;}
	section {position: absolute;width: 100%;top: 3rem;bottom: 10rem;left: 0;right: 0;one;-webkit-overflow-scrolling:touch;overflow: hidden;overflow-y: scroll;}
	.chat {padding: 10px 0;}
	.chat .audio {background: url(/public/img/mic.png) no-repeat center center;display: inline-block;width: 26px;height: 26px;background-size: contain;}
	.msg {font-size: 14px;margin: 20px 10px;}
	.msg span {color: #1abc9c;}
	.msg img {float: left;margin-right: 5px;}
	.msg .emotion {float: none;}
	.msg::after {content: '';display: table;clear: both;}
	.msg p:nth-of-type(2) {float: left;color: #fff;padding: 5px;border-radius: 3px;line-height: 1;max-width: 50%;}
	.msg p:nth-of-type(2) img {margin: 0;max-width: 100%;}
	.msg.fr img {float: right;margin-left: 5px;}
	.msg.fr p {text-align: right;}
	.msg.fr p:nth-of-type(2) {float: right;text-align: left;}
	.editor {padding: 10px;}
	.editor textarea,.editor .hiddenContent {width: 100%;border: 1px solid;height: 5rem;resize: none;}
	.hiddenContent {position: relative;display: none;}
	.tool-emotion {position: relative;}
	.tool span {display: inline-block;width: 2rem;height: 2rem;line-height: 2rem;cursor: pointer;position: relative;vertical-align: top;}
	.tool-pic {overflow: hidden;}
	.tool span > a {display: block;}
	.tool input[type='file'] {opacity: 0;width: 2rem;cursor: pointer;height: 2rem;vertical-align: top;position: absolute;z-index: 10;top: 0;left: 0;}
	.emotionList {position: absolute;top: -150px;width: 200px;height: 150px;word-spacing: 0;letter-spacing: 0;font-size: 0;background: #fff;box-shadow: 0 0 3px #ccc;display: none;-webkit-overflow-scrolling:touch;overflow: hidden;overflow-y: scroll;}
	.tool-emotion.active .emotionList {display: block;}
	.emotionList img {width: 50px;height: 50px;vertical-align: top;}
	/*.bigPic {max-width: 80%;}*/
	/*.bigPic img {max-width: 100%;}*/
/*	.msg::after {content: '';display: table;clear: both;}
	.msg p {float: left;}
	.msg .fr {float: right;}*/
	.tr {text-align: right;}
	.tc {text-align: center;font-size: 10px;}
	.tc i {color: #999;}
	/*.hiddenContent span:last-of-type {color: red;}*/
</style>
<section>
	<div class="chat"></div>
</section>
<footer>
	<div class="editor">
		<div class="tool">
			<span class="tool-pic">
				<a href="" class="insertPic">图片</a>
				<input type="file" name="pic" id="choosePic" class="choosePic">
			</span>
			<span class="tool-emotion">
				<a href="" class="toggleEmotion">表情</a>
				<div class="emotionList">
					{%for img in emotions-%}
						<img src="{{staticsRoot}}emotions/{{img}}" data-code="[{{img}}]">
					{%-endfor%}
				</div>
			</span>
			<span class="tool-voice">
				<a href="">声音</a>
			</span>
		</div>
		<textarea name="content" id="content"></textarea>
		<div class="hiddenContent"></div>
	</div>
</footer>
</div>
{%-endblock%}
{%block script-%}
<script src="{{staticsRoot}}bower_components/ota.js/src/loader.js"></script>
<script src="{{staticsRoot}}bower_components/blockies/blockies.min.js"></script>
<script src="{{staticsRoot}}js/popbox.min.js"></script>
<script src="{{staticsRoot}}js/socket.io.js"></script>
<script>
	require('core',function(ota){
		var $ = ota.get
		var $textContent = $('#content'),
			// $btn = $('#post'),
			$chat = $('.chat')
		// var socket = io.connect('http://127.0.0.1:{{port}}')
		var socket = io.connect('http://192.168.199.208:{{port}}')
		// var socket = io.connect('http://192.168.17.150:{{port}}')
		socket.binaryType = 'arraybuffer'
		var me = {}
		var support = {
			getUserMedia: navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia,
			URL: window.URL || window.webkitURL || window.mozURL
		}
		// $btn.on('click',function(e){
		// 	chat.send()
		// })
		$textContent.on('keypress',function(e){
			if(e.which === 13){
				chat.send()
				return false
			}
		})
		// $('.insertVoice').on('click',function(){
		// 	chat.insertVoice()
		// 	return false
		// })
		$('.tool').on('click','.toggleEmotion',function(){
			$(this).closest('.tool-emotion').toggleClass('active')
			return false
		}).on('click','.tool-voice',function(){
			chat.insertVoice()
			return false
		}).on('click','.insertPic',function(){
			return false
		}).on('change','.choosePic',function(){
			chat.insertPic(this.files)
		})
		$('.emotionList').on('click','img',function(){
			chat.insert(' ' + $(this).data('code') + ' ')
			$('.toggleEmotion').trigger('click')
		})
		socket.on('_connect',function(e){
			me.name = e.name
			me.color = randomColor()
			me.icon = blockies.create({ // All options are optional
			    seed: me.name, // seed used to generate icon data, default: random
			    color: me.color, // to manually specify the icon color, default: random
			    bgcolor: '#fff', // choose a different background color, default: white
			    size: 18, // width/height of the icon in blocks, default: 10
			    scale: 3 // width/height of each block in pixels, default: 5
			}).toDataURL()
		}).on('msg',function(e){
			var className = 'msg',sign = ''
			if(e.name !== me.name){
				className = 'msg fr'
			}
			if(e.sign.length){
				sign = ' data-sign="' + e.sign.join('#') + '"'
			}
			var $msg = $('<div class="'+className+'"'+sign+'><img src="'+e.avator+'"><p><em>'+e.name+'</em></p><p style="background: '+e.color+'">'+e.msg+'</p></div>')
			chat.render($msg)
		}).on('voice',function(e){
			var className = 'msg'
			var dataView = new DataView(e.buf),
				blob = new Blob([dataView], { type:'audio/wav' });
			if(e.name !== me.name){
				className = 'msg fr'
			}
			var $msg = $('<div class="'+className+'"><img src="'+e.avator+'"><p><em>'+e.name+'</em></p><p style="background: '+e.color+'"><span class="audio"><audio src="'+window.URL.createObjectURL(blob)+'"></audio><span></p></div>')
			chat.render($msg)
		}).on('pic',function(e){
			var className = 'msg'
			if(e.name !== me.name){
				className = 'msg fr'
			}
			var $msg = $('<div class="'+className+'"><img src="'+e.avator+'"><p><em>'+e.name+'</em></p><p style="background: '+e.color+'"><img src="'+e.pic+'" /></p></div>')
			chat.render($msg)
		}).on('enter',function(e){
			var $msg = $('<p class="tc"><em>'+e.name+'加入聊天室</em></p>')
			chat.render($msg)
		}).on('leave',function(e){
			var $msg = $('<p class="tc"><i>'+e.name+'离开了聊天室</i></p>')
			chat.render($msg)
		}).on('@user',function(e){
			var list = e.userlist.map(function(list){
				return '<p>'+list+'</p>'
			}).join('')
			userList.show(list)
		}).on('yo',function(e){
			// $('div[data-sign*="'+e.sign+'"]')
			// console.log(e.from + '发来了私信：' + e.msg)
			unreadList.update(e)
		})
		// $(window).on('beforeunload',function(){
		// 	socket.emit('leave')
		// })
		$textContent.on('keypress',function(e){
			if(e.shiftKey && e.which === 64){
				setTimeout(function(){
					userList.async()
					socket.emit('@user')
				},1)
			}
		}).on('input',function(e){
			$('.hiddenContent').html(this.value)
		})

		$chat.on('click','.audio',function(){
			$(this).children('audio')[0].play()
		}).on('click','.msg p:nth-of-type(2) img',function(){
			bigPic.show(this)
		})

		var userList = (function(){
			var $hiddenContent = $('.hiddenContent')
			var $textContent = $('#content')
			var pos = {}
			var $userList
			return {
				show: function(list){
					var self = this
					$hiddenContent.css({
						display: 'block'
					})
					var sign = $('.hiddenContent span')[0],
						offset = $textContent.offset()
					pos = {
						x: sign.offsetLeft + 26,
						y: sign.offsetTop + offset.top + 20
					}
					$userList = $('<div>'+list+'</div>').css({
						position: 'absolute',
						top: pos.y + 'px',
						left: pos.x + 'px',
						border: '1px solid #999',
						'font-size': '12px',
						padding: '3px',
						cursor: 'pointer'
					})
					$hiddenContent.css({
						display: 'none'
					})
					$('body').append($userList)
					$userList.on('click',function(e){
						var target
						if((target = e.target).tagName.toLowerCase() === 'p'){
							$textContent.val($textContent.val() + target.innerHTML + ' ')
							// socket.emit('yo',{
							// 	name: target.innerHTML,
							// 	msg: '你妹'
							// })
							self.hide()
							$textContent[0].focus()
						}
					})
					$textContent.on('input',function(e){
						if(this.value.indexOf('@') !== this.value.length - 1){
							$textContent.off('input',arguments.callee)
							$hiddenContent.html($hiddenContent.html().replace('<span>@</span>','@'))
							$userList && self.hide()
						}
					})
				},
				hide: function(){
					$userList.remove()
					$userList = pos = null
				},
				async: function(){
					$hiddenContent.html($hiddenContent.html().replace(/@$/,'<span>@</span>'))
				}
			}
		})()

		var randomColor = (function(){
			var c = ['0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f'],
				len = c.length
			var random = function(c){
				return Math.floor(Math.random() * c)
			}
			return function(){
				var ret = '#'
				for(var i=0,l=3;i<l;i++){
					ret += c[random(len)]
				}
				return ret
			}
		})()

		var chat = (function(){
			var $chat = $('.chat'),
				$textContent = $('#content')
			return {
				render: function(msg){
					$chat.append(msg)
					msg[0].scrollIntoView()
				},
				send: function(){
					socket.emit('msg',{
						msg: $textContent.val(),
						avator: me.icon,
						color: me.color
					})
					setTimeout(function(){
						$textContent.val('')
					},1)
				},
				insertVoice: (function(){
					var status = 'pause',init = false
					var context = new (window.webkitAudioContext || window.AudioContext)()
        			var createScript = context.createScriptProcessor || context.createJavaScriptNode
       				var recorder = createScript.apply(context, [4096, 1, 1]),data = [],audioInput = null,localStream = null,config = {}
			        config.sampleBits = config.sampleBits || 8;      //采样数位 8, 16
			        config.sampleRate = config.sampleRate || (44100 / 6);   //采样率(1/6 44100)
					var audioData = {
			            size: 0          //录音文件长度
			            , buffer: []     //录音缓存
			            , inputSampleRate: context.sampleRate    //输入采样率
			            , inputSampleBits: 16       //输入采样数位 8, 16
			            , outputSampleRate: config.sampleRate    //输出采样率
			            , oututSampleBits: config.sampleBits       //输出采样数位 8, 16
			            , input: function (data) {
			                this.buffer.push(new Float32Array(data));
			                this.size += data.length;
			            }
			            , compress: function () { //合并压缩
			                //合并
			                var data = new Float32Array(this.size);
			                var offset = 0;
			                for (var i = 0; i < this.buffer.length; i++) {
			                    data.set(this.buffer[i], offset);
			                    offset += this.buffer[i].length;
			                }
			                //压缩
			                var compression = parseInt(this.inputSampleRate / this.outputSampleRate);
			                var length = data.length / compression;
			                var result = new Float32Array(length);
			                var index = 0, j = 0;
			                while (index < length) {
			                    result[index] = data[j];
			                    j += compression;
			                    index++;
			                }
			                return result;
			            }
			            , encodeWAV: function () {
			                var sampleRate = Math.min(this.inputSampleRate, this.outputSampleRate);
			                var sampleBits = Math.min(this.inputSampleBits, this.oututSampleBits);
			                var bytes = this.compress();
			                var dataLength = bytes.length * (sampleBits / 8);
			                var buffer = new ArrayBuffer(44 + dataLength);
			                var data = new DataView(buffer);

			                var channelCount = 1;//单声道
			                var offset = 0;

			                var writeString = function (str) {
			                    for (var i = 0; i < str.length; i++) {
			                        data.setUint8(offset + i, str.charCodeAt(i));
			                    }
			                }

			                // 资源交换文件标识符 
			                writeString('RIFF'); offset += 4;
			                // 下个地址开始到文件尾总字节数,即文件大小-8 
			                data.setUint32(offset, 36 + dataLength, true); offset += 4;
			                // WAV文件标志
			                writeString('WAVE'); offset += 4;
			                // 波形格式标志 
			                writeString('fmt '); offset += 4;
			                // 过滤字节,一般为 0x10 = 16 
			                data.setUint32(offset, 16, true); offset += 4;
			                // 格式类别 (PCM形式采样数据) 
			                data.setUint16(offset, 1, true); offset += 2;
			                // 通道数 
			                data.setUint16(offset, channelCount, true); offset += 2;
			                // 采样率,每秒样本数,表示每个通道的播放速度 
			                data.setUint32(offset, sampleRate, true); offset += 4;
			                // 波形数据传输率 (每秒平均字节数) 单声道×每秒数据位数×每样本数据位/8 
			                data.setUint32(offset, channelCount * sampleRate * (sampleBits / 8), true); offset += 4;
			                // 快数据调整数 采样一次占用字节数 单声道×每样本的数据位数/8 
			                data.setUint16(offset, channelCount * (sampleBits / 8), true); offset += 2;
			                // 每样本数据位数 
			                data.setUint16(offset, sampleBits, true); offset += 2;
			                // 数据标识符 
			                writeString('data'); offset += 4;
			                // 采样数据总数,即数据总大小-44 
			                data.setUint32(offset, dataLength, true); offset += 4;
			                // 写入采样数据 
			                if (sampleBits === 8) {
			                    for (var i = 0; i < bytes.length; i++, offset++) {
			                        var s = Math.max(-1, Math.min(1, bytes[i]));
			                        var val = s < 0 ? s * 0x8000 : s * 0x7FFF;
			                        val = parseInt(255 / (65535 / (val + 32768)));
			                        data.setInt8(offset, val, true);
			                    }
			                } else {
			                    for (var i = 0; i < bytes.length; i++, offset += 2) {
			                        var s = Math.max(-1, Math.min(1, bytes[i]));
			                        data.setInt16(offset, s < 0 ? s * 0x8000 : s * 0x7FFF, true);
			                    }
			                }

			                return new Blob([data], { type: 'audio/wav' });
			            },
			            clean: function(){
			            	this.buffer = []
			            	this.size = 0
			            }
			        }
					var mediaCallback = function(stream){
						localStream = stream
						audioInput = context.createMediaStreamSource(stream)
						if(status === 'pause'){
							status = 'record'
							recode()
						}else{
							status = 'pause'
							pause()
						}
					}
					var fallback = function(err){
						console.log(err)
					}
					var recode = function(stream){
						audioInput.connect(recorder)
						recorder.connect(context.destination)
					}
					var pause = function(){
						recorder.disconnect()
						// var $audio = $('<audio></audio>')
						// $audio[0].src = window.URL.createObjectURL(audioData.encodeWAV())
						// $('body').append($audio)
						// $audio[0].play()
						socket.emit('voice',{
							voice: audioData.encodeWAV(),
							avator: me.icon,
							color: me.color
						})
						audioData.clean()
					}
					recorder.onaudioprocess = function(e){
						console.log('xxx')
						// data.push(e.inputBuffer.getChannelData(0))
						audioData.input(e.inputBuffer.getChannelData(0))
					}
					return function(){
						if(!init){
							init = true
							support.getUserMedia.call(navigator,{audio: true},mediaCallback,fallback)
						}else{
							mediaCallback(localStream)
						}
						
					}
				})(),
				insertPic: (function(){
					var fileReader = new FileReader
					fileReader.onload = function(e){
						if(e.total > 1024 * 1024){
							alert('图片超过大小')
						}else{
							socket.emit('pic',{
								pic: this.result,
								avator: me.icon,
								color: me.color
							})
						}
					}
					return function(files){
						files = files[0]
						fileReader.readAsDataURL(files)
					}
				})(),
				insert: function(input){
					$textContent.val($textContent.val() + input)
					$textContent[0].focus()
				}
			}
		})()

		var unreadList = (function(){
			var init = false,
				$placeHolder = $('.unread'),
				unread = 0,
				$count,$list
			var render = function(e){
				return '<p data-sign="'+e.sign+'">'+e.from + '提到了你</p>'
			}
			var bind = function(el){
				el.on('click','p',function(){
					var sign = $(this).data('sign'),
						self = $(this)
					$('div[data-sign*="'+sign+'"]')[0].scrollIntoView()
					--unread
					if(!unread){
						$count.remove()
						$count = null
					}else{
						$count.text(unread)
					}
					setTimeout(function(){
						self.fadeOut(function(){
							self.remove()
							if(!unread){
								init = false
								$list.remove()
								$list = null
							}
						})
					},1)
				})
			}
			return {
				update: function(e){
					if(!init){
						init = true
						$list = $('<div class="unread-list"></div>')
						$count = $('<i></i>')
						$placeHolder.append($count)
						$placeHolder.append($list)
						bind($list)
					}
					$list.append(render(e))
					unread++
					$count.text(unread)
				}
			}
		})()

		var bigPic = (function(){
			var init,box
			var render = function(el){
				return function(){
					return '<div class="bigPic"><img src="'+el.src+'" width="'+el.offsetWidth+'" height="'+el.offsetHeight+'" /></div>'
				}
			}
			return {
				show: function(el){
					if(!init){
						init = true
						box = new Popbox
					}
					box.reDraw(render(el)).show()
				}
			}
		})()
	})
</script>
{%-endblock%}