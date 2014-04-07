module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")
    coffee:
      compile:
        options:
          join: true
          sourceMap: false
        files: 
          'app/assets/javascripts/dest/src.js' : 'app/assets/javascripts/src/**/*.coffee'
    coffeelint:
      compile:
        options:
          max_line_length: 
            level: "ignore"
          no_trailing_whitespace:
            level: "ignore"
          indentation:
            level: "ignore"
        files: 
          'app/assets/javascripts/dest/src.js' : 'app/assets/javascripts/src/**/*.coffee'
    haml:
      options:
        language: 'coffee'
        target: 'js'
        includePath: true
        pathRelativeTo: "app/assets/javascripts/src/templates"
        namespace: "window.JST"
        bare: true
        dependencies:
          $: 'jquery'
          _: 'underscore',
          App: 'App'
        customHtmlEscape: 'HAML.escape'
        customCleanValue: 'HAML.cleanValue'
        customPreserve: 'HAML.preserve'
        customFindAndPreserve: 'HAML.findAndPreserve'
        customSurround: 'HAML.surround'
        customSucceed: 'HAML.succeed'
        customPrecede: 'HAML.precede'
        customReference: 'HAML.reference'
      compile:
        files:
          'app/assets/javascripts/dest/0_templates.js' : 'app/assets/javascripts/src/templates/**/*.hamlc'
    concat:
      compile:
        files: 
          'app/assets/javascripts/app.js' : ['app/assets/javascripts/src/lib/*.js','app/assets/javascripts/dest/*.js']

    watch:
      files: ['app/assets/javascripts/src/**/*.*']
      tasks: ['coffeelint','coffee','concat']
          
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-haml'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'

  grunt.registerTask 'default', ['coffee','concat']
