module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON('package.json')
    coffeelint:
      options:
        no_empty_param_list:
          level: 'error'
        max_line_length:
          level: 'ignore'
        indentation:
          level: 'ignore'

      src: ['src/*.coffee']
      test: ['spec/*.coffee']
      gruntfile: ['Gruntfile.coffee']
    
    
    shell:
      test:
        command: 'node --harmony node_modules/jasmine-focused/bin/jasmine-focused --verbose --coffee --captureExceptions spec'
        options:
          stdout: true
          stderr: true
          failOnError: true
    watch:
      test:
        files: './spec/**/*.coffee'
        tasks: ['shell:test']

  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-shell')
  grunt.loadNpmTasks('grunt-coffeelint')
  
  grunt.registerTask 'clean', ->
    require('rimraf').sync('lib')
  grunt.registerTask('test', ['shell:test'])
