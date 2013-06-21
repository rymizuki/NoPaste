"use strict";

module.exports = function (grunt) {
  grunt.initConfig({
    "pkg": grunt.file.readJSON("package.json"),

    "watch": {
    },

    "concat": {
      "components": {
        "dest": "public/js/components.js",
        "src": [
          "components/bootstrap/docs/assets/js/bootstrap.min.js",
          "components/bootstrap/docs/assets/js/google-code-prettify/prettify.js",
          "components/underscore/underscore-min.js",
          "components/backbone/backbone-min.js"
        ],
      },
      "app": {
        "dest": "public/js/main.js",
        "options": {
          "banner": "/* */\nvar no_paste = {};"
        },
        "src": [
          "lib/no_paste.js"
        ]
      }
    },

    "concat_css": {
      "components": {
        "dest": "public/css/components.css",
        "src": [
          "components/bootstrap/docs/assets/css/bootstrap.css",
          "components/bootstrap/docs/assets/css/bootstrap-responsive.css",
          "components/bootstrap/docs/assets/js/google-code-prettify/prettify.css"
        ],
      }
    },

    "cssmin": {
      "components": {
        "files": {
          "public/css/components.min.css": "public/css/components.css"
        }
      }
    },

    "uglify": {
      "components": {
        "files": {
          "public/js/components.min.js": "public/js/components.js"
        }
      },
      "app": {
        "files": {
          "public/js/main.min.js": "public/js/main.js"
        }
      }
    },

    "copy" : {
    }
  });

  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-concat");
  grunt.loadNpmTasks("grunt-contrib-copy");
  grunt.loadNpmTasks("grunt-contrib-cssmin");
  grunt.loadNpmTasks("grunt-contrib-uglify");
  grunt.loadNpmTasks("grunt-concat-css");

  grunt.registerTask("components", [
    "concat:components",
    "concat_css:components",
    "cssmin",
    "uglify"
  ]);
  grunt.registerTask("app", ["concat:app", "uglify:app"]);
};
