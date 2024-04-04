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
