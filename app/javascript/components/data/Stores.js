import React from "react";
import {
  Braces,
  ALargeSmall,
  Calendar1,
  CalendarClock,
  Hash,
  Brackets,
  ListOrdered,
  ToggleRight,
  Binary,
  LetterText,
  Bolt,
  Package,
  CirclePlus,
  CircleMinus,
  RefreshCw,
} from "lucide-react";

const Stores = () => {
  const COLUMN_TYPES = window.COLUMN_TYPES;
  const COLUMN_INDEXES = window.COLUMN_INDEXES;
  const COLUMN_DEFAULTS = window.COLUMN_DEFAULTS;
  const APP_MODELS = window.APP_MODELS;

  const modelsForSelect = () => {
    return APP_MODELS.map((model) => ({
      value: model.underscore,
      label: (
        <div className="flex flex-row gap-2">
          <div className="py-1 flex justify-center items-center text-localtower-50">
            {model.name}
          </div>
          <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
            {model.table_name}
          </div>
        </div>
      ),
    }));
  };

  const actionsForSelect = () => {
    return COLUMN_ACTIONS.map((action) => ({
      value: action.name,
      label: (
        <div className="flex flex-row gap-2">
          <div className="py-1 flex justify-center items-center w-5 text-localtower-300">
            {iconForAction(action.name)}
          </div>
          <div className="py-1 flex justify-center items-center text-localtower-50">
            {action.label}
          </div>
          <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
            {action.example}
          </div>
        </div>
      ),
    }));
  };

  const modelsForSelectWithout = (excludedModelNames) => {
    return modelsForSelect().filter((entry) => {
      return !excludedModelNames.includes(entry.value);
    });
  };

  const snakeCase = (str) => {
    return str
      .replace(/\ /g, "_")
      .replace(/[^a-zA-Z0-9\_]/g, "")
      .replace(/\_\_/g, "_")
      .toLowerCase();
  };

  const modelByValue = (value) => {
    return APP_MODELS.find((model) => model.underscore === value);
  };

  const filterAttributes = (row) => {
    let model = modelByValue(row.model_name);

    return model ? model.attributes_list : [];
  };

  const filterIndexes = (row) => {
    let model = modelByValue(row.model_name);

    let indexes = [];

    if (model) {
      let attributes_with_index = model.attributes_list.filter(
        (attribute) => attribute.index.length > 0
      );

      attributes_with_index.map((attribute) => {
        attribute.index.map((index) => {
          let columns = [index.columns.map((column) => column).join(", ")];

          indexes.push({
            value: index.name,
            label: (
              <div className="flex flex-row gap-2">
                <div className="py-1 flex justify-center items-center">
                  {columns}
                </div>
                <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
                  {index.name}{" "}
                  {index.unique && (
                    <span className="bg-localtower-300 text-xs font-sans mx-2 px-2 text-localtower-700 rounded-full">
                      unique
                    </span>
                  )}
                </div>
              </div>
            ),
          });
        });
      });
    }

    return indexes;
  };

  const attributesForSelect = (attributes_list, additional = []) => {
    // "additional" is used to add columns that are already in the migration file
    const existingColumns = additional
      .filter((row) => row.action_name === "add_column")
      .filter((row) => row.column_name.length)
      .map((row) => {
        return {
          name: row.column_name,
          type: row.column_type,
          index: [],
        };
      });

    const list = existingColumns.concat(attributes_list);

    return list.map((attr) => ({
      value: attr.name,
      label: (
        <div className="flex flex-row gap-2">
          <div className="py-1 flex justify-center items-center">
            {attr.name}
          </div>
          <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
            {attr.type}{" "}
            {attr.index.length > 0 && (
              <span className="bg-localtower-300 text-xs font-sans mx-2 px-2 text-localtower-700 rounded-full">
                index
              </span>
            )}
          </div>
        </div>
      ),
    }));
  };

  const iconForAction = (action) => {
    const size = 17;
    const strokeWidth = 1;

    if (action.indexOf("add") !== -1 || action === "belongs_to") {
      return <CirclePlus strokeWidth={strokeWidth} size={size} />;
    }

    if (action.indexOf("remove") !== -1 || action === "drop_table") {
      return <CircleMinus strokeWidth={strokeWidth} size={size} />;
    }

    if (action.indexOf("change") !== -1 || action === "rename_column") {
      return <RefreshCw strokeWidth={strokeWidth} size={size} />;
    }

    return;
  };

  const iconForType = (type) => {
    const size = 17;
    const strokeWidth = 1;

    if (type === "string") {
      return <ALargeSmall strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "text") {
      return <LetterText strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "datetime") {
      return <CalendarClock strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "date") {
      return <Calendar1 strokeWidth={strokeWidth} size={size} />;
    }

    if (
      type === "integer" ||
      type === "bigint" ||
      type === "float" ||
      type === "numeric" ||
      type === "decimal"
    ) {
      return <Hash strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "array") {
      return <Brackets strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "uuid") {
      return <ListOrdered strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "json" || type === "jsonb") {
      return <Braces strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "boolean") {
      return <ToggleRight strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "binary") {
      return <Binary strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "blob") {
      return <Package strokeWidth={strokeWidth} size={size} />;
    }

    if (type === "references") {
      return <Bolt strokeWidth={strokeWidth} size={size} />;
    }

    return;
  };

  const typesForSelect = () => {
    return COLUMN_TYPES.map((type) => ({
      value: type.name,
      label: (
        <div className="flex flex-row gap-2 items-center">
          <div className="py-1 flex justify-center items-center w-5 text-localtower-300">
            {iconForType(type.name)}
          </div>
          <div className="py-1 flex justify-center items-center text-localtower-50">
            {type.name}
          </div>
          <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
            {type.example}
          </div>
        </div>
      ),
    }));
  };

  const indexesForSelect = () => {
    return [{ value: "", label: "(none)" }].concat(
      COLUMN_INDEXES.map((type) => ({
        value: type.name,
        label: (
          <div className="flex flex-row gap-2 items-center">
            <div className="py-1 flex justify-center items-center text-localtower-50">
              {type.label || type.name}
            </div>
            <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
              {type.example}
            </div>
          </div>
        ),
      }))
    );
  };

  return {
    actionsForSelect: actionsForSelect,
    modelsForSelect: modelsForSelect,
    typesForSelect: typesForSelect,
    attributesForSelect: attributesForSelect,
    indexesForSelect: indexesForSelect,
    modelsForSelectWithout: modelsForSelectWithout,
    modelByValue: modelByValue,
    filterAttributes: filterAttributes,
    filterIndexes: filterIndexes,
    snakeCase: snakeCase,
    APP_MODELS: APP_MODELS,
    COLUMN_DEFAULTS: COLUMN_DEFAULTS,
    COLUMN_TYPES: COLUMN_TYPES,
    COLUMN_INDEXES: COLUMN_INDEXES,
  };
};

export default Stores;
