import React, { useState, useEffect } from "react";
import { X, Plus, TableOfContents } from "lucide-react";
// import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';

import DarkSelect from "./DarkSelect.js";
import ModernTooltip from "./ModernTooltip.js";
import Stores from "./data/Stores.js";

const NewMigrationForm = () => {
  const COLUMN_DEFAULTS = window.COLUMN_DEFAULTS;

  const VISIBLE_FIELDS = {
    add_column: [
      "model_name",
      "action_name",
      "column_name",
      "column_type",
      "default",
      "nullable",
      "unique",
      "index",
      "index_algorithm",
      "foreign_key",
    ],
    remove_column: ["model_name", "action_name", "list_attributes"],
    rename_column: [
      "model_name",
      "action_name",
      "list_attributes",
      "new_column_name",
    ],
    change_column_type: [
      "model_name",
      "action_name",
      "list_attributes",
      "new_column_type",
    ],
    belongs_to: ["model_name", "action_name", "list_models", "foreign_key"],
    add_index_to_column: [
      "model_name",
      "action_name",
      "list_attributes",
      "unique",
      "index",
      "index_algorithm",
    ],
    remove_index_to_column: ["model_name", "action_name", "list_indexes"],
    drop_table: ["model_name", "action_name"],
  };

  const DEFAULT_LINE = {
    table_name: Stores().APP_MODELS[0] ? Stores().APP_MODELS[0].table_name : "",
    model_name: Stores().APP_MODELS[0] ? Stores().APP_MODELS[0].underscore : "",
    action_name: Stores().actionsForSelect()[0]
      ? Stores().actionsForSelect()[0].value
      : "",
    column_type: "string",
    column_name: "",
    new_column_name: "",
    new_column_type: "",
    default: "",
    unique: false,
    foreign_key: false,
    index: "",
    index_algorithm: "default",
    index_name: "",
    nullable: true,
  };

  const [formRows, setFormRows] = useState([DEFAULT_LINE]);
  const [showOptions, setShowOptions] = useState({});

  const shouldBeVisible = (row, td_name) => {
    return VISIBLE_FIELDS[row.action_name].includes(td_name) ? "block" : "none";
  };

  const handleAddRow = (event) => {
    event.preventDefault();

    setFormRows([...formRows, { ...DEFAULT_LINE }]);
  };

  const handleDeleteRow = (index, event) => {
    event.preventDefault();

    // Don't delete if there is only one row:
    if (formRows.length === 1) {
      return;
    }

    setFormRows(formRows.filter((row, rowIndex) => rowIndex !== index));
  };

  const handleInputChange = (index, event) => {
    const { name, value } = event.target;
    const updatedRows = [...formRows];

    let newValue = value;

    // Sanitise default input:
    if (name === "column_name") {
      newValue = Stores().snakeCase(newValue);
      newValue = newValue.trim();
    }

    updatedRows[index][name] = newValue;

    if (name === "model_name") {
      updatedRows[index].table_name =
        Stores().modelByValue(newValue).table_name;
      updatedRows[index].column_name = "";
      updatedRows[index].index_name = "";
      updatedRows[index].index = "";
      updatedRows[index].index_algorithm = "";
      updatedRows[index].default = "";
    }

    if (name === "action_name") {
      updatedRows[index].column_name = "";
      updatedRows[index].index_name = "";
    }

    if (name === "action_name" && newValue === "add_index_to_column") {
      updatedRows[index].index = "default";
    }

    // Reset default if change.
    if (name === "column_type") {
      // result index:
      // result default:
      updatedRows[index].index = "";
      updatedRows[index].default = "";
      // close modal:
      setShowOptions({ [index]: false });
    }

    if (name === "default" && newValue !== "") {
      updatedRows[index].nullable = false;
    }

    // For the selector of the referenced model:
    if (
      name === "column_type" &&
      value === "references" &&
      Stores().APP_MODELS[0]
    ) {
      updatedRows[index].column_name = Stores().APP_MODELS[0].underscore;
      updatedRows[index].foreign_key = true;
    }

    if (
      updatedRows[index].column_type !== "references" &&
      updatedRows[index].foreign_key === true
    ) {
      updatedRows[index].foreign_key = false;
    }

    // Reset unique if no index is selected:
    if (
      name === "index" &&
      newValue === "" &&
      updatedRows[index].unique === true
    ) {
      updatedRows[index].unique = false;
    }

    setFormRows(updatedRows);
  };

  const handleCheckboxChange = (index, event) => {
    const { name, checked, value } = event.target;
    const updatedRows = [...formRows];

    let finalValue = checked;

    if (name === "nullable" && checked && updatedRows[index].default !== "") {
      return false;
    }

    if (name === "unique" && checked && updatedRows[index].index === "") {
      updatedRows[index].index = "default";
    }

    if (
      name === "index_algorithm" &&
      checked &&
      updatedRows[index].index != ""
    ) {
      finalValue = value === "concurrently" ? "concurrently" : "default";
    }

    updatedRows[index][name] = finalValue;

    setFormRows(updatedRows);
  };

  const handleOptionClick = (index, option) => {
    const updatedRows = [...formRows];
    updatedRows[index].default = option.value;

    if (updatedRows[index].default !== "") {
      updatedRows[index].nullable = false;
    } else {
      updatedRows[index].nullable = true;
    }

    setFormRows(updatedRows);
    setShowOptions({ [index]: false });
  };

  const handleShowOptions = (index, event) => {
    event.preventDefault();

    if (showOptions[index]) {
      setShowOptions({ [index]: false });
    } else {
      setShowOptions({ [index]: true });
    }
  };

  const addToForm = () => {
    // Add the form to the hidden input:
    document.getElementById("form_attributes").value = JSON.stringify(formRows);
  };

  useEffect(() => {
    addToForm();
  }, [formRows]); // This effect depends on formRows

  if (Stores().APP_MODELS.length === 0) {
    return <div className="flex flex-col gap-2"></div>;
  }

  return (
    <div>
      <table className="w-full max-w-screen-xl">
        <tbody className="border-b border-localtower-500">
          {formRows.map((row, index) => (
            <tr key={`$row-${index}`} className="pb-2">
              <td className="w-40 py-2 pr-3">
                {/* ============== */}
                {/* LIST MODELS / TABLES */}
                <div className="w-40">
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Model
                  </div>
                  <DarkSelect
                    keySuffix={"model_name" + row.table_name}
                    options={Stores().modelsForSelect()}
                    defaultValue={Stores().modelsForSelect()[0]}
                    value={row.model_name}
                    onChange={(selectedOption) => {
                      if (selectedOption && selectedOption.value) {
                        const syntheticEvent = {
                          target: {
                            name: "model_name",
                            value: selectedOption.value,
                          },
                        };
                        handleInputChange(index, syntheticEvent);
                      }
                    }}
                  />
                </div>
              </td>
              <td className="w-56 py-2 pr-3">
                {/* ============== */}
                {/* LIST ACTIONS */}
                <div className="w-56">
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Action
                  </div>
                  <DarkSelect
                    keySuffix={"action_name" + row.table_name}
                    options={Stores().actionsForSelect()}
                    defaultValue={Stores().actionsForSelect()[0]}
                    customClassNamesOverrides={{ menu: "!w-[450px]" }}
                    onChange={(selectedOption) => {
                      if (selectedOption && selectedOption.value) {
                        const syntheticEvent = {
                          target: {
                            name: "action_name",
                            value: selectedOption.value,
                          },
                        };
                        handleInputChange(index, syntheticEvent);
                      }
                    }}
                  />
                </div>
              </td>
              <td className="py-2 pr-3 flex flex-row gap-2">
                {/* ============== */}
                {/* LIST ATTRIBUTES */}
                <div
                  className="w-48"
                  style={{ display: shouldBeVisible(row, "list_attributes") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Column
                  </div>
                  <DarkSelect
                    keySuffix={"column_name" + row.table_name}
                    options={Stores().attributesForSelect(
                      Stores().filterAttributes(row)
                    )}
                    defaultValue=""
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "column_name",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* LIST INDEXES */}
                <div
                  className="w-80"
                  style={{ display: shouldBeVisible(row, "list_indexes") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Index to remove
                  </div>
                  <DarkSelect
                    keySuffix={"list_indexes" + row.table_name}
                    options={Stores()
                      .filterIndexes(row)
                      .map((attr) => ({
                        value: attr.value,
                        label: attr.label,
                      }))}
                    defaultValue=""
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "index_name",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* LIST MODELS (COLUMN NAME) */}
                <div
                  className="w-40"
                  style={{ display: shouldBeVisible(row, "list_models") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Models
                  </div>
                  <DarkSelect
                    keySuffix={"list_models" + row.table_name}
                    options={Stores().modelsForSelectWithout([row.model_name])}
                    value={row.column_name}
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "column_name",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* COLUMN NAME */}
                <div
                  className="w-48"
                  style={{ display: shouldBeVisible(row, "column_name") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Column name
                  </div>
                  <input
                    type="text"
                    className="px-2 py-1.5 rounded bg-localtower-600 border border-localtower-500 inline-block w-full outline-none focus:border-localtower-400 transition-colors text-localtower-100"
                    name="column_name"
                    value={row.column_name}
                    onChange={(event) => handleInputChange(index, event)}
                  />
                </div>
                {/* ============== */}
                {/* COLUMN TYPE */}
                <div
                  className="w-48"
                  style={{ display: shouldBeVisible(row, "column_type") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Column type
                  </div>
                  <DarkSelect
                    keySuffix={"column_type" + row.table_name}
                    options={Stores().typesForSelect()}
                    defaultValue={Stores().typesForSelect()[0]}
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "column_type",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* NEW COLUMN TYPE */}
                <div
                  className="w-40"
                  style={{ display: shouldBeVisible(row, "new_column_type") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    New column type
                  </div>
                  <DarkSelect
                    keySuffix={"new_column_type" + row.table_name}
                    options={Stores().typesForSelect()}
                    defaultValue={Stores().typesForSelect()[0]}
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "new_column_type",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* DEFAULT VALUES */}
                <div style={{ display: shouldBeVisible(row, "default") }}>
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Default value
                  </div>
                  <div className="relative">
                    <input
                      type="text"
                      name="default"
                      className="px-2 py-1.5 pr-8 rounded bg-localtower-600 border border-localtower-500 block w-full outline-none focus:border-localtower-400 transition-colors text-localtower-100"
                      value={row.default}
                      placeholder="NULL"
                      onChange={(event) => handleInputChange(index, event)}
                    />
                    {COLUMN_DEFAULTS[row.column_type] && (
                      <div className="absolute inset-y-0 right-0 pl-3 pr-1 flex space-x-1 items-center">
                        <button
                          className="bg-localtower-600 p-1 rounded-sm border border-localtower-500 outline-none hover:border-localtower-450 hover:bg-locatower-900 active:opacity-60 transition-colors cursor-pointer"
                          onClick={(event) => handleShowOptions(index, event)}
                        >
                          <TableOfContents
                            strokeWidth={1}
                            size={17}
                            className="text-localtower-200"
                          />
                        </button>
                      </div>
                    )}
                    {COLUMN_DEFAULTS[row.column_type] && showOptions[index] && (
                      <div
                        className="options-popup bg-localtower-600 border border-localtower-500 text-localtower-100 rounded flex flex-col gap-2 overflow-hidden z-30 w-60"
                        style={{
                          display: showOptions[index] ? "block" : "none",
                          position: "absolute",
                          top: "100%",
                          left: "0",
                          right: "0",
                        }}
                      >
                        {COLUMN_DEFAULTS[row.column_type] &&
                          COLUMN_DEFAULTS[row.column_type].map((option) => (
                            <div
                              key={option.value}
                              onClick={() => handleOptionClick(index, option)}
                              className="hover:bg-localtower-900 p-2 active:opacity-60 cursor-pointer"
                            >
                              {option.label}
                            </div>
                          ))}
                      </div>
                    )}
                  </div>
                </div>
                {/* ============== */}
                {/* NEW COLUMN NAME */}
                <div
                  className="w-48"
                  style={{ display: shouldBeVisible(row, "new_column_name") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    New column name
                  </div>
                  <input
                    type="text"
                    className="px-2 py-1.5 rounded bg-localtower-600 border border-localtower-500 inline-block w-full outline-none focus:border-localtower-400 transition-colors text-localtower-100"
                    name="new_column_name"
                    value={row.new_column_name}
                    onChange={(event) => handleInputChange(index, event)}
                  />
                </div>
                {/* ============== */}
                {/* INDEX */}
                <div
                  className="w-40"
                  style={{ display: shouldBeVisible(row, "index") }}
                >
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    Index
                  </div>
                  <DarkSelect
                    options={Stores().indexesForSelect()}
                    value={row.index}
                    customClassNamesOverrides={{ menu: "!w-40" }}
                    onChange={(selectedOption) => {
                      const syntheticEvent = {
                        target: {
                          name: "index",
                          value: selectedOption.value,
                        },
                      };
                      handleInputChange(index, syntheticEvent);
                    }}
                  />
                </div>
                {/* ============== */}
                {/* CHECKBOXES */}
                <div>
                  <div className="text-xs text-localtower-450 pb-0.5 font-medium">
                    &nbsp;
                  </div>
                  <div>
                    <div className="w-64 flex flex-row gap-0.5 h-8 items-center">
                      {row.column_type !== "references" && (
                        <div
                          style={{ display: shouldBeVisible(row, "nullable") }}
                        >
                          <ModernTooltip
                            content="Use the 'Nullable' option to allow null values."
                            title="Nullable"
                          >
                            <label
                              className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none group"
                              style={{
                                opacity: row.default === "" ? 1 : 0.5,
                                backgroundColor: row.nullable ? "black" : "",
                              }}
                            >
                              <input
                                type="checkbox"
                                name="nullable"
                                checked={row.nullable}
                                onChange={(event) =>
                                  handleCheckboxChange(index, event)
                                }
                              />
                              <span>NULL</span>
                            </label>
                          </ModernTooltip>
                        </div>
                      )}
                      <div
                        style={{ display: shouldBeVisible(row, "foreign_key") }}
                      >
                        <ModernTooltip
                          content="Use the 'Foreign Key' option to create a foreign key to another table."
                          title="Foreign Key"
                        >
                          <label
                            className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none"
                            style={{
                              backgroundColor: row.foreign_key ? "black" : "",
                            }}
                          >
                            <input
                              type="checkbox"
                              name="foreign_key"
                              checked={row.foreign_key}
                              onChange={(event) =>
                                handleCheckboxChange(index, event)
                              }
                            />
                            <span>FK</span>
                          </label>
                        </ModernTooltip>
                      </div>
                      {row.column_type !== "references" && (
                        <div
                          style={{ display: shouldBeVisible(row, "unique") }}
                        >
                          <ModernTooltip
                            content="Use the 'Unique' option to create a unique index."
                            title="Index Unique"
                          >
                            <label
                              className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none"
                              style={{
                                backgroundColor: row.unique ? "black" : "",
                              }}
                            >
                              <input
                                type="checkbox"
                                name="unique"
                                checked={row.unique}
                                onChange={(event) =>
                                  handleCheckboxChange(index, event)
                                }
                              />
                              <span>IU</span>
                            </label>
                          </ModernTooltip>
                        </div>
                      )}
                      <div
                        style={{
                          display: shouldBeVisible(row, "index_algorithm"),
                        }}
                      >
                        <ModernTooltip
                          content="Use the 'Index Concurrently' option to create indexes without blocking writes to the table."
                          title="Index Concurrently"
                        >
                          <label
                            className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none"
                            style={{
                              backgroundColor:
                                row.index_algorithm === "concurrently"
                                  ? "black"
                                  : "",
                              opacity: row.index != "" ? 1 : 0,
                            }}
                          >
                            <input
                              type="checkbox"
                              name="index_algorithm"
                              value="concurrently"
                              checked={row.index_algorithm === "concurrently"}
                              onChange={(event) =>
                                handleCheckboxChange(index, event)
                              }
                            />
                            <span>IC</span>
                          </label>
                        </ModernTooltip>
                      </div>
                    </div>
                  </div>
                </div>
              </td>
              <td className="p-2">
                <span
                  className="rounded bg-localtower-800 text-localtower-100 border border-localtower-500 outline-none hover:border-localtower-450 hover:bg-900 active:opacity-60 transition-colors inline-flex gap-1 cursor-pointer"
                  style={{
                    opacity: formRows.length === 1 ? 0.5 : 1,
                    cursor: formRows.length === 1 ? "not-allowed" : "pointer",
                  }}
                >
                  <X
                    onClick={(event) => handleDeleteRow(index, event)}
                    className="text-xs px-1.5 py-1.5"
                  />
                </span>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div className="flex justify-start py-4">
        <button
          className="text-xs px-1.5 py-1.5 pr-2.5 rounded bg-localtower-800 text-localtower-100 border border-localtower-500 outline-none hover:border-localtower-450 hover:bg-900 active:opacity-60 transition-colors inline-flex gap-1"
          onClick={handleAddRow}
        >
          <Plus strokeWidth={1} size={16} />
          Add action
        </button>
      </div>
    </div>
  );
};

export default NewMigrationForm;
