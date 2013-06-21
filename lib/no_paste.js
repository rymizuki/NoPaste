(function () {
  "use strict";  

  no_paste.ContentModel = Backbone.Model.extend({
    "urlRoot": "/api/content",
    "validate": function (attr, option) {
      var errors = [];
      if (!attr.body) {
        errors.push({"attr": "body", "msg": "body is required."});
      }

      if (errors.length > 0) {
        return errors;
      }
    }
  });

  no_paste.ContentView = Backbone.View.extend({
    "events": {
    },
    "initialize": function (args) {
      _.bindAll(this, 'render');
    },
    "show": function (id) {
      var model = new no_paste.ContentModel({"id": id});
      model.on("change", this.render);
      model.fetch();
    },
    "render" : function (model) {
      var template = _.template($('#tmpl-show').html());
      this.$el.html(template(model.attributes));

      prettyPrint();
    }
  });
  no_paste.RegistrationView = Backbone.View.extend({
    "events": {
      "click [data-submit=register]": "submit"
    },
    "initialize": function () {
      _.bindAll(this, 'set_error', 'show');
    },
    "render" : function () {
      var template = _.template($('#tmpl-register').html());
      this.$el.html(template({}));
    },
    "submit": function (e) {
      e.preventDefault();

      var content = new no_paste.ContentModel({
        "subject": $('#input-subject').val() || '',
        "body":    $('#input-body').val()
      });

      content.on("invalid", this.set_error);
      content.on("change", this.show);

      content.save({}, {
        "error": function () { alert('エラーが発生しました'); }
      });
    },
    "show": function (model) {
      location.hash = "#"+model.get('id');
    },
    "set_error": function (model, errors) {
      _(errors).each(function (error) {
        var $input = $("#input-"+error.attr);
        var $group = $input.parents('.control-group');

        if (!$group.hasClass('error')) {
          $input.after(_.template('<p class="help-block"><%= msg %></p>', error));
          $group.addClass('error');
        }
      });
    }
  });

  no_paste.Router = Backbone.Router.extend({
    "routes": {
      "":         "register",
      "register": "register",
      ":id":    "show"
    },
    "initialize": function () {
      this.register_view = new no_paste.RegistrationView({"el": "#page-content"});
      this.content_view  = new no_paste.ContentView({"el": "#page-content"});
    },
    "register": function () {
      this.register_view.render();
    },
    "show": function (id) {
      this.content_view.show(id);
    }
  });

  $(function () {
    var router = new no_paste.Router();

    Backbone.history.start({});
  });
})();
