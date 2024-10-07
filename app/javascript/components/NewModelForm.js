import React, { useState } from 'react';

const NewModelForm = () => {
  const COLUMN_TYPES = window.COLUMN_TYPES;
  const COLUMN_INDEXES = window.COLUMN_INDEXES;
  const COLUMN_INDEXES_ALGORITHMS = window.COLUMN_INDEXES_ALGORITHMS;
  const COLUMN_DEFAULTS = window.COLUMN_DEFAULTS;
  const MODELS = window.APP_MODELS.map((model) => ({ value: model.underscore, label: model.name }));

  const snakeCase = (str) => {
    return str
      .replace(/\ /g, "_")
      .replace(/[^a-zA-Z0-9\_]/g, "")
      .replace(/\_\_/g, "_")
      .toLowerCase();
  }

  const DEFAULT_LINE = {
    column_type: 'string',
    column_name: '',
    default: '',
    unique: false,
    foreign_key: false,
    index: '',
    index_algorithm: 'default',
    nullable: true
  };

  const [formRows, setFormRows] = useState([DEFAULT_LINE]);
  const [showOptions, setShowOptions] = useState({});

  const handleAddRow = (event) => {
    event.preventDefault();

    // Don't add if the name is empty:
    if (formRows.at(-1).column_name === '') { return; }

    setFormRows([...formRows, DEFAULT_LINE]);

    addToForm();
  };

  const handleDeleteRow = (index, event) => {
    event.preventDefault();

    // Don't delete if there is only one row:
    if (formRows.length === 1) { return; }

    setFormRows(formRows.filter((row, rowIndex) => rowIndex !== index));

    addToForm();
  };

  const handleInputChange = (index, event) => {
    const { name, value } = event.target;
    const updatedRows = [...formRows];

    let newValue = value;

    // Sanitise default input:
    if (name === "column_name") {
      newValue = snakeCase(newValue);
      newValue = newValue.trim();
    }

    updatedRows[index][name] = newValue;

    // Reset default if change.
    if (name === 'column_type') {
      // result index:
      // result default:
      updatedRows[index].index = '';
      updatedRows[index].default = '';
      // close modal:
      setShowOptions({ [index]: false });
    }

    if (name === 'default' && newValue !== '') {
      updatedRows[index].nullable = false;
    }

    // For the selector of the referenced model:
    if (name === 'column_type' && value === 'references' && APP_MODELS[0]) {
      updatedRows[index].column_name = APP_MODELS[0].name;
      updatedRows[index].foreign_key = true;
    }

    if (updatedRows[index].column_type !== 'references' && updatedRows[index].foreign_key === true) {
      updatedRows[index].foreign_key = false;
    }

    // Reset unique if no index is selected:
    if (name === 'index' && newValue === '' && updatedRows[index].unique === true) {
      updatedRows[index].unique = false;
    }

    setFormRows(updatedRows);

    addToForm();
  };

  const handleCheckboxChange = (index, event) => {
    const { name, checked } = event.target;
    const updatedRows = [...formRows];

    if (name === 'nullable' && checked && updatedRows[index].default !== '') {
      return false;
    }

    if (name === 'unique' && checked && updatedRows[index].index === '') {
      updatedRows[index].index = 'default';
    }

    updatedRows[index][name] = checked;

    setFormRows(updatedRows);

    addToForm();
  };

  const handleOptionClick = (index, option) => {
    const updatedRows = [...formRows];
    updatedRows[index].default = option.value;
    setFormRows(updatedRows);
    setShowOptions({ [index]: false });

    if (updatedRows[index].default !== '') {
      updatedRows[index].nullable = false;
    } else {
      updatedRows[index].nullable = true;
    }

    addToForm();
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

  return (
    <div>
      <table>
        <thead>
          <tr>
            <th>Column Name</th>
            <th>Column Type</th>
            <th>Default Value</th>
            <th>Options</th>
            <th>Index</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          {formRows.map((row, index) => (
            <tr key={index}>
              { row.column_type === 'references' ? (
                  <td>
                    <select
                      name="column_name"
                      value={row.column_name}
                      onChange={(event) => handleInputChange(index, event)}
                    >
                      { MODELS.map((model) => (
                        <option value={model.value} key={model.value}>{model.label}</option>
                      ))}
                    </select>
                  </td>
                ) : (
                  <td>
                    <input
                      type="text"
                      name="column_name"
                      value={row.column_name}
                      onChange={(event) => handleInputChange(index, event)}
                    />
                  </td>
                )
              }
              <td>
                <select
                  name="column_type"
                  value={row.column_type}
                  onChange={(event) => handleInputChange(index, event)}
                >
                  { COLUMN_TYPES.map((type) => (
                    <option value={type.name} key={type.name}>{type.name}</option>
                  ))}
                </select>
              </td>
              <td>
              { (row.column_type !== 'references') && (
                <div style={{ position: 'relative' }}>
                  <input
                    type="text"
                    name="default"
                    value={row.default}
                    placeholder="NULL"
                    onChange={( event) => handleInputChange(index, event)}
                  />
                  {COLUMN_DEFAULTS[row.column_type] && (
                    <button onClick={(event) => handleShowOptions(index, event)}>Options</button>
                  )}
                  {COLUMN_DEFAULTS[row.column_type] && showOptions[index] && (
                    <div className="options-popup" style={{ display: showOptions[index] ? 'block' : 'none', position: 'absolute', top: '100%', left: '0', right: '0' }}>
                      {COLUMN_DEFAULTS[row.column_type] && COLUMN_DEFAULTS[row.column_type].map((option) => (
                        <div key={option.value} onClick={() => handleOptionClick(index, option)}>
                          {option.label}
                        </div>
                      ))}
                    </div>
                  )}
                </div>
              )}
              </td>
              <td>
                { (row.column_type !== 'references') && (
                  <div>
                    <div>
                      <label>Can be null:</label>
                      <input
                        type="checkbox"
                        name="nullable"
                        checked={row.nullable}
                        onChange={(event) => handleCheckboxChange(index, event)}
                        />
                    </div>
                    <div>
                      <label>Unique:</label>
                      <input
                        type="checkbox"
                        name="unique"
                        checked={row.unique}
                        onChange={(event) => handleCheckboxChange(index, event)}
                      />
                    </div>
                  </div>
                )}
                <div>
                  <label>Foreign Key:</label>
                  <input
                    type="checkbox"
                    name="foreign_key"
                    checked={row.foreign_key}
                    onChange={(event) => handleCheckboxChange(index, event)}
                  />
                </div>
              </td>
              <td>
              { (row.column_type !== 'references') && (
                <div>
                <div>
                  <label>Index:</label>
                  <select
                    name="index"
                    value={row.index}
                    onChange={(event) => handleInputChange(index, event)}
                    >
                    <option value="">(none)</option>
                    { COLUMN_INDEXES.map((i) => (
                      <option value={i} key={i}>{i}</option>
                    ))}
                  </select>
                </div>
                { row.index && (
                <div>
                  <label>Index Algorithm:</label>
                  <select
                    name="index_algorithm"
                    value={row.index_algorithm}
                    onChange={(event) => handleInputChange(index, event)}
                  >
                    <option value="default">default</option>
                    { COLUMN_INDEXES_ALGORITHMS.map((i) => (
                      <option value={i} key={i}>{i}</option>
                    ))}
                  </select>
                </div>
                )}
                </div>
              )}
              </td>
              <td>
                <button onClick={(event) => handleDeleteRow(index, event)} disabled={formRows.length === 1}>Delete</button>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <button onClick={handleAddRow} disabled={formRows.at(-1).name === ''}>Add</button>
    </div>
  );
};

export default NewModelForm;
