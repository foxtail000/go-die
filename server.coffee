server = require './index.coffee'
config = require './config.coffee'
cluster = require 'cluster'
http = require 'http'
os = require('os')
numCPUs = Math.min(os.cpus().length, 14)
port = config.run_port   #server.get('port')

#console.log "【server.get】",server.get
#console.log "【port】",port

exec = require('child_process').exec

#MailService = loadService('mail')

ips = []
for key, ip of os.networkInterfaces()
	if not ip?[0]
		continue
	ips.push ip[0].address
httpServer = ()->
	http.createServer(server).listen port, ()->
		console.log 'Express server listening on port ' + port

if numCPUs is 1 or not config.productENV

	httpServer()

else
	if cluster.isMaster
		console.log '[master] ' + "start master..."



		for i in [0...numCPUs]
			wk = cluster.fork()
			wk.send '[master] ' + 'hi worker' + wk.id

		cluster.on 'fork', (worker)->
			console.log '[master] ' + 'online: worker' + worker.id

		cluster.on 'online', (worker) ->
			console.log '[master] ' + 'online: worker' + worker.id

		cluster.on 'disconnect', (worker) ->
			console.log '[master] ' + 'disconnect: worker' + worker.id

		cluster.on 'exit', (worker, code, signal) ->
			console.log '[master] ' + 'exit worker' + worker.id + ' died'
			# refork one worker
			if config.errorMail
				cmd = 'echo /root/.forever/`ls -1t /root/.forever/ |head -n 1` |xargs tail -n 50'
				exec cmd, (error, stdout, stderr)->
					opts = {
						to: config.errorMail
						subject: "[服务器错误]进程-#{worker.id}异常关闭"
						html: "<p>服务器错误:</p>
									<p>服务器IP:#{ips.join(';')}</p>
									<p>发生时间:#{(new Date()).toLocaleString()}</p>
									<p>异常标记:#{signal}</p>
									<p>stdout:#{stdout}</p>
									<p>stderr:#{stderr}</p>"
					}
					#MailService.send 'INNER', opts, (error, mailresult)->
			setTimeout ()->
				cluster.fork()
			, 3000

	else if cluster.isWorker
		console.log '[worker] ' + "start worker ..." + cluster.worker.id

		httpServer()