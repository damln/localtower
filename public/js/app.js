window.MainApp = {};

MainApp = {
  init: function() {

  },

  ready: function() {
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
      $(".full-message").show();
    });

    MainApp.whenActionOnElement("change", "action", function(e) {
      MainApp.adaptLines();
    });

    MainApp.adaptLines();
  },

  // INSTANCE

  // This is a little bit dirty but it works well for the moment:
  // We dynamically show/hide fields
  adaptLines: function() {
    $.each(MainApp.bySelector("tr"), function() {
      var $tr = $(this);

      var action_input = $tr.find("[name='migrations[migrations][][action]']");

      var table_name_input = $tr.find("[name='migrations[migrations][][table_name]']");

      var column_text_input = $tr.find("[data-selector='column_text']");
      var column_input = $tr.find("[data-selector='column_list']");

      var new_column_name_input = $tr.find("[name='migrations[migrations][][new_column_name]']");
      var column_type_input = $tr.find("[name='migrations[migrations][][column_type]']");
      var index_input = $tr.find("[name='migrations[migrations][][index]']");
      var nullable_input = $tr.find("[name='migrations[migrations][][nullable]']");

      var action = action_input.val();


      $.each([column_text_input, column_input, new_column_name_input, column_type_input, index_input, nullable_input], function(i, el) {
        el.hide();
      });


      var mapping = {
        add_column: [column_text_input, column_type_input, index_input, nullable_input],
        remove_column: [column_input],
        rename_column: [column_input, new_column_name_input],
        change_column_type: [column_input, column_type_input],
        add_index_to_column: [column_input],
        remove_index_to_column: [column_input],
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
    var tr = MainApp.bySelector("tbody").find("tr").first().clone();
    MainApp.bySelector("tbody").append(tr);
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
