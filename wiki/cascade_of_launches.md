# Схема запуска сборки (пересборки)

lib/bb/main.py (bitbake_main) -> (setup_bitbake) 
```python
...
# we start a server with a given featureset
                    logger.info("Starting bitbake server...")
                    # Clear the event queue since we already displayed messages
                    bb.event.ui_queue = []
                    server = bb.server.process.BitBakeServer(...
...
```
/lib/bb/server/process.py class BitBakeServer (def __init__) ``` ... bb.daemonize.createDaemon(self._startServer, logfile) ... ``` -> ``` _startServer -> serverscript = os.path.realpath(os.path.dirname(__file__) + "/../../../bin/bitbake-server") ```
-> /lib/bb/server/process.py (bb.server.process.execServer) -> 
```python 
server = ProcessServer(bitbake_lock, lockname, sock, sockname, server_timeout, xmlrpcinterface)
...
featureset = []
cooker = bb.cooker.BBCooker(featureset, server)
cooker.configuration.profile = profile
...
server.cooker = cooker
server.run()  # это тот, который ProcessServer
```
-> server.run() -> self.main() # имеется ввиду ProcessServer : ``` while not self.quit ... ``` <- вот тут вот основное действие происходит


и вот тут внутри из канала задач происходит выполнение задач из `self.command_channel`.

сверка сигнатур делает **что-то**, а потом вызывается задача с логами: 
```
35 13:42:32.022365 Running command ['buildTargets', ['core-image-minimal'], 'build']
35 13:42:32.022387 Registering idle function <bound method Command.runAsyncCommand of <bb.command.Command object at 0x7f06360f4dc0>>
35 13:42:32.022390 Sending reply (True, None)
35 13:42:32.022399 Command Completed (socket: True)
35 13:42:32.078766 Parsing started
```

а точка входа в эту задачу находится в updateCache из BBCooker из /bitbake/lib/bb/cooker.py  
