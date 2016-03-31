
temp = (require 'temp').track()
path = require 'path'
chokidar = require 'chokidar'
Pathwatcher = require 'pathwatcher'
gaze = require 'gaze'
fs = require 'fs'

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

describe 'PathWatcher', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice absolute paths if relativized, even from temp", ->
    testWatcher(pathWatcher)(temp.path({suffix: '.txt'}))

  it "should notice absolute paths if relativized", ->
    testWatcher(pathWatcher)(path.join process.cwd(), 'foo')
  
describe 'Chokidar', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice absolute paths if relativized, even from temp", ->
    testWatcher(chokidarWatcher)(temp.path({suffix: '.txt'}))

  it "should notice absolute paths if relativized", ->
    testWatcher(chokidarWatcher)(path.join process.cwd(), 'foo')
  
describe 'fs.watch', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice absolute paths if relativized, even from temp", ->
    testWatcher(fsWatcher)(temp.path({suffix: '.txt'}))

  it "should notice absolute paths if relativized", ->
    testWatcher(fsWatcher)(path.join process.cwd(), 'foo')
  
describe 'Gaze', ->
  afterEach ->
    temp.cleanupSync()
    
  it "should notice absolute paths if relativized, even from temp", ->
    testWatcher(gazeWatcher)(temp.path({suffix: '.txt'}))

  it "should notice absolute paths if relativized", ->
    testWatcher(gazeWatcher)(path.join process.cwd(), 'foo')
