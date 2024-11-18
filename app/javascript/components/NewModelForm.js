import React, { useState, useEffect, CSSProperties } from "react";
import { X, Plus, TableOfContents } from "lucide-react";
// import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';

import DarkSelect from "./DarkSelect.js";
import ModernTooltip from "./ModernTooltip.js";
import Stores from "./data/Stores.js";

const NewModelForm = () => {
  const COLUMN_DEFAULTS = window.COLUMN_DEFAULTS;

  const DEFAULT_LINE = {
    column_type: "string",
    column_name: "",
    default: "",
    unique: false,
    foreign_key: false,
    index: "",
    index_algorithm: "default",
    nullable: true,
  };

  const [formRows, setFormRows] = useState([DEFAULT_LINE]);
  const [showOptions, setShowOptions] = useState({});

  const handleAddRow = (event) => {
    event.preventDefault();

    // Don't add if the name is empty:
    if (formRows.at(-1).column_name === "") {
      return;
    }

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
    if (name === "index" && newValue === "") {
      updatedRows[index].unique = false;
      updatedRows[index].index_algorithm = "default";
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

  return (
    <div>
      <table className="w-full max-w-screen-xl">
        <thead className="text-xs h-8">
          <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Default value</th>
            <th>Index</th>
            <th>Options</th>
            <th></th>
          </tr>
        </thead>
        <tbody className="border-b border-localtower-600">
          {formRows.map((row, index) => (
            <tr
              key={`row-${index}`}
              className="border-t border-localtower-600 transition-colors"
            >
              {row.column_type === "references" ? (
                <td className="w-60 py-2 pr-3">
                  <div className="w-60">
                    <DarkSelect
                      options={Stores().modelsForSelect()}
                      defaultValue={Stores().modelsForSelect()[0]}
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
                </td>
              ) : (
                <td className="w-60 py-2 pr-3">
                  <div className="w-60">
                    <input
                      type="text"
                      className="px-2 py-1.5 rounded bg-localtower-600 border border-localtower-500 inline-block w-full outline-none focus:border-localtower-400 transition-colors text-localtower-100"
                      name="column_name"
                      value={row.column_name}
                      onChange={(event) => handleInputChange(index, event)}
                    />
                  </div>
                </td>
              )}
              <td className="w-48 py-2 pr-3">
                <div className="w-48">
                  <DarkSelect
                    options={Stores().typesForSelect()}
                    defaultValue={Stores().typesForSelect()[0]}
                    onChange={(selectedOption) => {
                      if (selectedOption && selectedOption.value) {
                        const syntheticEvent = {
                          target: {
                            name: "column_type",
                            value: selectedOption.value,
                          },
                        };
                        handleInputChange(index, syntheticEvent);
                      }
                    }}
                  />
                </div>
              </td>
              <td className="w-40 py-2 pr-3">
                {row.column_type !== "references" && (
                  <div style={{ position: "relative" }} className="w-40">
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
                              className="hover:bg-localtower-900 p-2 active:opacity-60 cursor-pointer flex flex-row gap-2 items-center"
                            >
                              <div className="py-1 flex justify-center items-center text-localtower-50">
                                {option.label}
                              </div>
                              <div className="text-localtower-400 py-1 flex justify-center items-center text-xss font-mono">
                                {option.example}
                              </div>
                            </div>
                          ))}
                      </div>
                    )}
                  </div>
                )}
              </td>
              <td className="py-2 pr-3 w-40">
                {row.column_type !== "references" && (
                  <div className="w-40">
                    <DarkSelect
                      options={Stores().indexesForSelect()}
                      value={row.index}
                      defaultValue={Stores().indexesForSelect()[0]}
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
                )}
              </td>
              <td className="py-2 pr-3">
                <div className="flex flex-row gap-1">
                  {row.column_type !== "references" && (
                    <ModernTooltip
                      content="Use the 'Nullable' option to allow null values."
                      title="Nullable"
                    >
                      <label
                        className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none group"
                        style={{
                          opacity: row.default === "" ? 1 : 0.33,
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
                  )}
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
                        onChange={(event) => handleCheckboxChange(index, event)}
                      />
                      <span>FK</span>
                    </label>
                  </ModernTooltip>
                  {row.column_type !== "references" && (
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
                  )}
                  <ModernTooltip
                    content="Use the 'Index Concurrently' option to create indexes without blocking writes to the table."
                    title="Index Concurrently"
                  >
                    <label
                      className="inline-flex items-center align-middle gap-2 px-2 py-1 rounded hover:bg-localtower-900 cursor-pointer active:opacity-60 transition-all select-none"
                      style={{
                        backgroundColor:
                          row.index_algorithm === "concurrently" ? "black" : "",
                        opacity: row.index != "" ? 1 : 0.33,
                      }}
                    >
                      <input
                        type="checkbox"
                        name="index_algorithm"
                        value="concurrently"
                        checked={row.index_algorithm === "concurrently"}
                        onChange={(event) => handleCheckboxChange(index, event)}
                      />
                      <span>IC</span>
                    </label>
                  </ModernTooltip>
                </div>
              </td>
              <td className="p-2 flex flex-row justify-end items-center">
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
          className="text-xs px-1.5 py-1.5 pr-2.5 rounded bg-localtower-800 text-localtower-100 border border-localtower-500 outline-none hover:border-localtower-450 hover:bg-900 active:opacity-60 transition-colors inline-flex gap-1 disabled:opacity-60 disabled:cursor-not-allowed"
          onClick={handleAddRow}
          disabled={formRows.at(-1).column_name === ""}
        >
          <Plus strokeWidth={1} size={16} />
          Add column
        </button>
      </div>
    </div>
  );
};

export default NewModelForm;
