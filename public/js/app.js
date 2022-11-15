window.MainApp = {};

MainApp = {
  init: function() {
  },

  ready: function() {
    $('.grid').masonry({
      itemSelector: '.grid-item',
      percentPosition: true,
      columnWidth: '.grid-sizer',
    });

    MainApp.whenActionOnElement("click", "duplicate", function(e) {
      e.preventDefault();
      MainApp.duplicateLine();
      return false;
    });

    MainApp.whenActionOnElement("click", "remove", function(e) {
      e.preventDefault();
      MainApp.removeLine(e.currentTarget);
      return false;
    });

    MainApp.whenActionOnElement("click", "submit", function(e) {
      var current = $(e.currentTarget);
      $(".full-message").show();

      if (current.val() === "false") {
        $(".full-message-migrate").show();
      }

    });

    MainApp.whenActionOnElement("change", "action", function(e) {
      MainApp.adaptLines();
    });

    MainApp.adaptLines();
    MainApp.sanitizeInputs();

    hljs.highlightAll();
  },

  // INSTANCE --------------------------------------------------
  sanitizeInputs: function() {
    $('[data-sain]').keyup(function(el) {
      var currentInputValue = $(el.currentTarget).val();
      var cleanInputValue = currentInputValue.replace(/[^a-zA-Z0-9]/g, '');
      $(el.currentTarget).val(cleanInputValue);
    })
  },



  // This is a little bit dirty but it works well for the moment:
  // We dynamically show/hide fields
  adaptLines: function() {
    $.each(MainApp.bySelector("tr"), function() {
      var $tr = $(this);

      var action_input = $tr.find("[data-selector='action']");
      var action = action_input.val();

      var belongs_to_input = $tr.find("[data-selector='belongs_to']");
      var belongs_to_label = MainApp.bySelector('belongs_to_label');

      var column_text_input = $tr.find("[data-selector='column_text']");
      var column_text_label = MainApp.bySelector('column_text_label');

      var column_input = $tr.find("[data-selector='column_list']");
      var column_label = MainApp.bySelector('column_label');

      var new_column_name_input = $tr.find("[data-selector='new_column_name']");
      var new_column_name_label = MainApp.bySelector('new_column_name_label');

      var column_type_input = $tr.find("[data-selector='column_type']");
      var column_type_label = MainApp.bySelector('column_type_label');

      var index_input = $tr.find("[data-selector='index']");
      var index_label = MainApp.bySelector('index_label');

      var nullable_input = $tr.find("[data-selector='nullable']");
      var nullable_label = MainApp.bySelector('nullable_label');

      $.each(
        [
          belongs_to_input,
          belongs_to_label,

          column_text_input,
          column_text_label,

          column_input,
          column_label,

          new_column_name_input,
          new_column_name_label,

          column_type_input,
          column_type_label,

          index_input,
          index_label,

          nullable_input,
          nullable_label,
        ],
        function(i, el) {
          el.hide();
        });

      var mapping = {
        add_column: [
          column_text_input,
          column_text_label,
          column_type_input,
          column_type_label,
          index_input,
          index_label,
          nullable_input,
          nullable_label,
        ],
        remove_column: [
          column_input,
          column_label,
        ],
        rename_column: [
          column_input,
          column_label,
          new_column_name_input,
          new_column_name_label,
        ],
        change_column_type: [
          column_input,
          column_label,
          column_type_input,
          column_type_label,
        ],
        belongs_to: [
          belongs_to_input,
          belongs_to_label,
        ],
        add_index_to_column: [
          column_input,
          column_label,
        ],
        remove_index_to_column: [
          column_input,
          column_label,
        ],
        drop_table: [],
      }

      inputs_to_show = mapping[action];

      if (inputs_to_show) {
        $.each(inputs_to_show, function(i, el) {
          el.show();
        });
      }
    });
  },

  duplicateLine: function() {
    var tr = MainApp.bySelector("tbody").find("tr").last().clone();
    MainApp.bySelector("tbody").append(tr);
    MainApp.bySelector("tbody").find("tr").last().find('[name="models[attributes][][attribute_name]"]').val('').focus();
  },

  removeLine: function(target) {
    if ($(target).parents("tbody").find("tr").length > 1) {
      $(target).parents("tr").remove();
    }
  },

  // PRIVATE
  bySelector: function(selector) {
    return $("[data-selector='" + selector + "']");
  },

  whenActionOnElement: function(action, selector, callback) {
    $(document).on(action, "[data-selector='" + selector + "']", callback);
  }
}

MainApp.init();

$(document).ready(function() {
  MainApp.ready();
});
