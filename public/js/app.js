window.MainApp = {};

Array.prototype.unique = function () {
  return this.filter(function (value, index, self) {
    return self.indexOf(value) === index;
  });
};

MainApp = {
  init: function () {},

  ready: function () {
    $(".grid").masonry({
      itemSelector: ".grid-item",
      percentPosition: true,
      columnWidth: ".grid-sizer",
    });

    MainApp.whenActionOnElement("click", "duplicateLineNewModel", function (e) {
      e.preventDefault();

      if (MainApp.modelNameAndAttributesAreFilled()) {
        MainApp.duplicateLine();
      } else {
        MainApp.notFilled();
      }

      return false;
    });

    MainApp.whenActionOnElement(
      "click",
      "duplicateLineNewMigration",
      function (e) {
        e.preventDefault();
        MainApp.duplicateLineMigration();
        return false;
      }
    );

    MainApp.whenActionOnElement("click", "removeLineModel", function (e) {
      e.preventDefault();
      MainApp.removeLineModel(e.currentTarget);
      return false;
    });

    MainApp.whenActionOnElement("click", "removeLineMigration", function (e) {
      e.preventDefault();
      MainApp.removeLineMigration(e.currentTarget);
      return false;
    });

    // New Model
    MainApp.whenActionOnElement("click", "submitNewModel", function (e) {
      if (!MainApp.modelNameAndAttributesAreFilled()) {
        MainApp.notFilled();
        e.preventDefault();
        return false;
      }

      var current = $(e.currentTarget);
      $(".full-message").show();

      if (current.val() === "false") {
        $(".full-message-migrate").show();
      }
    });

    // New Migration
    MainApp.whenActionOnElement("click", "submitNewMigration", function (e) {
      var current = $(e.currentTarget);
      $(".full-message").show();

      if (current.val() === "false") {
        $(".full-message-migrate").show();
      }
    });

    MainApp.whenActionOnElement("change", "action", function (e) {
      MainApp.adaptLines();
    });

    MainApp.adaptLines();
    MainApp.sanitizeInputs();
    hljs.highlightAll();
  },

  // INSTANCE --------------------------------------------------
  sanitizeInputs: function () {
    function camelize(str) {
      return str
        .replace(/(?:^\w|[A-Z]|\b\w)/g, function (word, index) {
          return word.toUpperCase();
        })
        .replace(/\s+/g, "");
    }

    function snakeCase(str) {
      return str
        .replace(/\ /g, "_")
        .replace(/[^a-zA-Z0-9\_]/g, "")
        .replace(/\_\_/g, "_")
        .toLowerCase();
    }

    // Model name
    MainApp.whenActionOnElement("keyup", "modelName", function (e) {
      var currentInputValue = $(e.currentTarget).val();
      var cleanInputValue = currentInputValue.replace(/[^a-zA-Z0-9]/g, "");
      cleanInputValue = camelize(cleanInputValue);
      $(e.currentTarget).val(cleanInputValue);
    });

    // Model attributes
    MainApp.whenActionOnElement("keyup", "attributeName", function (e) {
      var currentInputValue = $(e.currentTarget).val();
      $(e.currentTarget).val(snakeCase(currentInputValue));
    });

    // Migration
    MainApp.whenActionOnElement("keyup", "column_text", function (e) {
      var currentInputValue = $(e.currentTarget).val();
      $(e.currentTarget).val(snakeCase(currentInputValue));
    });
  },

  modelNameAndAttributesAreFilled: function () {
    // attributes name:
    var valuesForAttributes = [];
    MainApp.bySelector("attributeName").each(function (el) {
      valuesForAttributes.push($(this).val());
    });
    // model name:
    valuesForAttributes.push(MainApp.bySelector("modelName").first().val());

    return (
      valuesForAttributes.filter(function (n) {
        return n === "";
      }).length === 0
    );
  },

  notFilled: function () {
    alert("Please fill all the fields");
  },

  // This is a little bit dirty but it works well for the moment:
  // We dynamically show/hide fields
  adaptLines: function () {
    $.each(MainApp.bySelector("table").find("table"), function (table) {
      var $table = $(this);

      var action_input = $table.find("[data-selector='action']");
      var action = action_input.val();

      var belongs_to_input = $table.find("[data-selector='belongs_to']");
      var belongs_to_label = $table.find("[data-selector='belongs_to_label']");

      var column_text_input = $table.find("[data-selector='column_text']");
      var column_input = $table.find("[data-selector='column_list']");
      var column_label = $table.find("[data-selector='column_label']");

      var new_column_name_input = $table.find(
        "[data-selector='new_column_name']"
      );
      var new_column_name_label = $table.find(
        "[data-selector='new_column_name_label']"
      );

      var column_type_input = $table.find("[data-selector='column_type']");
      var column_type_label = $table.find(
        "[data-selector='column_type_label']"
      );

      var index_options_inputs = $table.find("[data-selector='index_options']");
      var index_options_label = $table.find(
        "[data-selector='index_options_label']"
      );

      var default_input = $table.find("[data-selector='default_input']");
      var default_label = $table.find("[data-selector='default_label']");

      var nullable_input = $table.find("[data-selector='nullable_input']");
      var nullable_label = $table.find("[data-selector='nullable_label']");

      $.each(
        [
          belongs_to_input,
          belongs_to_label,

          column_text_input,
          column_input,
          column_label,

          new_column_name_input,
          new_column_name_label,

          column_type_input,
          column_type_label,

          index_options_inputs,
          index_options_label,

          default_input,
          default_label,

          nullable_input,
          nullable_label,
        ],
        function (i, el) {
          el.hide();
        }
      );

      var mapping = {
        add_column: [
          column_text_input,
          column_label,
          column_type_input,
          column_type_label,
          default_input,
          default_label,
          nullable_input,
          nullable_label,
        ],
        remove_column: [column_input, column_label],
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
        belongs_to: [belongs_to_input, belongs_to_label],
        add_index_to_column: [
          column_input,
          column_label,
          index_options_inputs,
          index_options_label,
        ],
        remove_index_to_column: [column_input, column_label],
        drop_table: [],
      };

      inputs_to_show = mapping[action];

      if (inputs_to_show) {
        $.each(inputs_to_show, function (i, el) {
          el.show();
        });
      }
    });
  },

  duplicateLine: function () {
    var tr = MainApp.bySelector("tbody").find("tr").last().clone();
    MainApp.bySelector("tbody").append(tr);
    MainApp.bySelector("tbody")
      .find("tr")
      .last()
      .find('[name="model[attributes][][attribute_name]"]')
      .val("")
      .focus();
  },

  duplicateLineMigration: function () {
    var table = MainApp.bySelector("table").find("table").last().clone();
    MainApp.bySelector("table").append(table);
    MainApp.adaptLines();

    // Populate select/option for column list:
    var allAttributes = [];
    MainApp.bySelector("table")
      .find('[data-selector="column_text"]')
      .each(function (i, el) {
        allAttributes.push(el.value);
      });
    allAttributes = allAttributes.unique();

    var columnSelector = MainApp.bySelector("table")
      .find("table")
      .last()
      .find('[data-selector="column_list"]')
      .last();

    var currentValues = [];
    columnSelector.find("option").each(function (i, el) {
      currentValues.push(el.value);
    });

    currentValues = currentValues.concat(allAttributes).unique().sort();

    columnSelector.empty(); // remove old options
    $.each(currentValues, function (i, value) {
      columnSelector.append(
        $("<option></option>").attr("value", value).text(value)
      );
    });

    MainApp.bySelector("table")
      .find("table")
      .last()
      .find('[name="migrations[][column]"]')
      .val("")
      .focus();
  },

  removeLineModel: function (target) {
    if ($(target).parents("tbody").find("tr").length > 1) {
      $(target).parents("tr").remove();
    }
  },

  removeLineMigration: function (target) {
    if ($(target).parents(".container-table").find("table").length > 1) {
      $(target).parents("table").remove();
    }
  },

  // PRIVATE
  bySelector: function (selector) {
    return $("[data-selector='" + selector + "']");
  },

  whenActionOnElement: function (action, selector, callback) {
    $(document).on(action, "[data-selector='" + selector + "']", callback);
  },
};

$(document).ready(function () {
  MainApp.ready();
});
