
temp = (require 'temp').track()
path = require 'path'

chokidar = require 'chokidar'
Pathwatcher = require 'pathwatcher'
gaze = require 'gaze'
fs = require 'fs'
watchr = require 'watchr'

loglevel = require 'loglevel'
loglevel.setDefaultLevel('trace')
loglevel.setLevel('trace')
log = loglevel.getLogger('filewatcher-spec')


testWatcher = (watcherFunc) -> (expectedFile) ->
  spy = jasmine.createSpy('callback')
  watcherFunc(spy, expectedFile)
  fs.writeFile(expectedFile, 'Hello Gaze, see me!',
    (err) -> throw err if (err))
  waitsFor( (-> spy.callCount > 0), "callback wasn't called in time", 1000)


chokidarWatcher = (spy, expectedFile) ->
  watcher = chokidar.watch(expectedFile, {
    persistent: true
  }).on('add', (path) ->
    spy()
    watcher.close()
  )
  
fsWatcher = (spy, expectedFile) ->
  watcher = fs.watch(expectedFile, (event, filename) ->
    spy()
    watcher.close()
  )
  
gazeWatcher = (spy, expectedFile) ->
  {dir, base} = path.parse expectedFile
    
  gaze(base, {cwd: dir}, (err, watcher) ->
    watcher.on('added', (event, path) ->
      spy()
      watcher.close()
    )
  )

pathWatcher = (spy, expectedFile) ->
  pathwatcher = Pathwatcher.watch(expectedFile, (event, path) ->
    spy()
    pathwatcher.close()
  )
  
watchrWatcher = (spy, expectedFile) ->
  w = watchr.watch(
    path: expectedFile
    listeners:
      change: (changeType,filePath,fileCurrentStat,filePreviousStat) ->
        spy()
    next: (err, watchers) ->
      if err
        log.error err
      else
        if watchers
          setTimeout (-> watchers[0].close()), 60 * 1000
  )

        
describe 'Chokidar', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice a file added from temp", ->
    testWatcher(chokidarWatcher)(temp.path({suffix: '.txt'}))
    
  it "should notice a file added", ->
    testWatcher(chokidarWatcher)(path.join process.cwd(), 'foo')
      
describe 'PathWatcher', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice a file added from temp", ->
    testWatcher(pathWatcher)(temp.path({suffix: '.txt'}))

  it "should notice a file added", ->
    testWatcher(pathWatcher)(path.join process.cwd(), 'foo')
  
describe 'fs.watch', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice a file added from temp", ->
    testWatcher(fsWatcher)(temp.path({suffix: '.txt'}))

  it "should notice a file added", ->
    testWatcher(fsWatcher)(path.join process.cwd(), 'foo')
  
describe 'Gaze', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice a file added from temp", ->
    testWatcher(gazeWatcher)(temp.path({suffix: '.txt'}))

  it "should notice a file added", ->
    testWatcher(gazeWatcher)(path.join process.cwd(), 'foo')
  
describe 'watchr', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice a file added from temp", ->
    testWatcher(watchrWatcher)(temp.path({suffix: '.txt'}))

  it "should notice a file added", ->
    testWatcher(watchrWatcher)(path.join process.cwd(), 'foo')
