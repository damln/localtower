import React, { useState, useEffect } from 'react';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';

const NewMigrationForm = () => {
  const COLUMN_TYPES = window.COLUMN_TYPES;
  const COLUMN_INDEXES = window.COLUMN_INDEXES;
  const COLUMN_INDEXES_ALGORITHMS = window.COLUMN_INDEXES_ALGORITHMS;
  const COLUMN_DEFAULTS = window.COLUMN_DEFAULTS;
  const MODELS = window.APP_MODELS;
  const COLUMN_ACTIONS = window.COLUMN_ACTIONS.map((i) => ({ value: i.name, label: i.name }));

  const VISIBLE_FIELDS = {
    add_column: ['model_name', 'action_name', 'column_name', 'column_type', 'default', 'nullable', 'unique', 'index', 'index_algorithm', 'foreign_key'],
    remove_column: ['model_name', 'action_name', 'list_attributes'],
    rename_column: ['model_name', 'action_name', 'list_attributes', 'new_column_name'],
    change_column_type: ['model_name', 'action_name', 'list_attributes', 'new_column_type'],
    belongs_to: ['model_name', 'action_name', 'list_models', 'foreign_key'],
    add_index_to_column: ['model_name', 'action_name', 'list_attributes', 'unique', 'index', 'index_algorithm'],
    remove_index_to_column: ['model_name', 'action_name', 'list_indexes'],
    drop_table: ['model_name', 'action_name'],
  }

  const snakeCase = (str) => {
    return str
      .replace(/\ /g, "_")
      .replace(/[^a-zA-Z0-9\_]/g, "")
      .replace(/\_\_/g, "_")
      .toLowerCase();
  }

  const DEFAULT_LINE = {
    model_name: MODELS[0] ? MODELS[0].name : '',
    model_underscore: MODELS[0] ? MODELS[0].underscore : '',
    table_name: MODELS[0] ? MODELS[0].table_name : '',
    action_name: 'add_column',
    column_type: 'string',
    column_name: '',
    new_column_name: '',
    new_column_type: '',
    default: '',
    unique: false,
    foreign_key: false,
    index: '',
    index_algorithm: 'default',
    index_name: '',
    nullable: true
  };

  const [formRows, setFormRows] = useState([DEFAULT_LINE]);
  const [showOptions, setShowOptions] = useState({});

  const handleAddRow = (event) => {
    event.preventDefault();

    setFormRows([...formRows, { ...DEFAULT_LINE }]);
  };

  const handleDeleteRow = (index, event) => {
    event.preventDefault();

    // Don't delete if there is only one row:
    if (formRows.length === 1) { return; }

    setFormRows(formRows.filter((row, rowIndex) => rowIndex !== index));
  };

  const shouldBeVisible = (row, td_name) => {
    if (row.action_name === '') {
      return false;
    }

    return VISIBLE_FIELDS[row.action_name].includes(td_name);
  }

  //=======

  const handleInputChange = (index, event) => {
    const { name, value } = event.target;
    const updatedRows = [...formRows];

    let newValue = value;

    updatedRows[index][name] = newValue;

    // Reset default if change.
    if (name === 'column_type') {
      // result default:
      updatedRows[index].column_name = undefined;
      updatedRows[index].foreign_key = false;
      updatedRows[index].unique = false;
      updatedRows[index].index = undefined;
      updatedRows[index].default = undefined;
      // close modal:
      setShowOptions({ [index]: false });
    }

    // Add "column_name" on belongs too relation:
    if (name === 'action_name' && newValue === 'belongs_to') {
      let current = (filterModels(updatedRows[index])[0] || {});

      if (current.underscore) {
        updatedRows[index].column_name = current.underscore;
      }
    }

    // set the table
    if (name === 'model_name' && newValue !== '') {
      MODELS.map((model) => {
        if (index && (model.name === newValue)) {
          updatedRows[index].table_name = model.table_name;
          updatedRows[index].model_underscore = model.underscore;
        }
      });
    }

    if (name === 'default' && newValue !== '') {
      updatedRows[index].nullable = false;
    }

    // For the selector of the referenced model:
    if (name === 'column_type' && value === 'references' && MODELS[0]) {
      updatedRows[index].column_name = MODELS[0].name;
      updatedRows[index].foreign_key = true;
    }

    if (updatedRows[index].column_type !== 'references' && updatedRows[index].foreign_key === true) {
      updatedRows[index].foreign_key = false;
    }

    setFormRows(updatedRows);
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
  };

  const filterModels = (row) => {
    return MODELS.filter((model) => model.table_name !== row.table_name);
  }

  const filterAttributes = (row) => {
    let model = MODELS.find((model) => model.table_name === row.table_name);

    return model ? model.attributes_list : [];
  }

  const filterIndexes = (row) => {
    let model = MODELS.find((model) => model.table_name === row.table_name);

    let indexes = [];

    if (model) {
      let attributes_with_index = model.attributes_list.filter((attribute) => attribute.index.length > 0);

      attributes_with_index.map((attribute) => {
        attribute.index.map((index) => {
          let label = [index.columns.map((column) => column).join(', '), `(${index.name})`].join(' ');
          indexes.push({ value: index.name, label: label });
        });
      });
    }

    return indexes;
  }

  const handleOptionClick = (index, option) => {
    const updatedRows = [...formRows];
    updatedRows[index].default = option.value;
    updatedRows[index].nullable = !(updatedRows[index].default !== '')

    setShowOptions({ [index]: false });
    setFormRows(updatedRows);
  };

  const handleShowOptions = (index, event) => {
    event.preventDefault();

    setShowOptions({ [index]: !showOptions[index] });
  };

  const addToForm = () => {
    // Add the form to the hidden input:
    document.getElementById("form_attributes").value = JSON.stringify(formRows);
  };

  const onDragEnd = (result) => {
    if (!result.destination) {
      return;
    }

    const items = Array.from(formRows);
    const [reorderedItem] = items.splice(result.source.index, 1);
    items.splice(result.destination.index, 0, reorderedItem);

    setFormRows(items);
  };

  useEffect(() => {
    addToForm();
  }, [formRows]); // This effect depends on formRows

  return (
    <div>
      <DragDropContext onDragEnd={onDragEnd}>
        <Droppable droppableId="formRows">
          {(provided) => (
            <table {...provided.droppableProps} ref={provided.innerRef}>
              <thead>
                <tr>
                  <th></th>
                  <th>Model Name</th>
                  <th>Action</th>
                  <th></th>
                  <th></th>
                </tr>
              </thead>
              <tbody>
                {formRows.map((row, index) => (
                  <Draggable key={index} draggableId={`row-${index}`} index={index}>
                    {(provided) => (
                      <tr ref={provided.innerRef} {...provided.draggableProps}>
                        <td>
                          <div {...provided.dragHandleProps} style={{ cursor: 'move' }}>
                            &#8942;
                          </div>
                        </td>
                        <td>
                          <select
                            name="model_name"
                            value={row.column_name}
                            onChange={(event) => handleInputChange(index, event)}
                          >
                            { MODELS.map((model, index) => (
                              <option value={model.value} key={index}>{model.name}</option>
                            ))}
                          </select>
                        </td>
                        <td>
                          <select
                            name="action_name"
                            value={row.action_name}
                            onChange={(event) => handleInputChange(index, event)}
                          >
                            { COLUMN_ACTIONS.map((model, index) => (
                              <option value={model.value} key={index}>{model.label}</option>
                            ))}
                          </select>
                        </td>
                        <td>
                          <div style={{ display: shouldBeVisible(row, 'list_models') ? 'block' : 'none' }}>
                            <select
                              name="column_name"
                              value={row.column_name}
                              onChange={(event) => handleInputChange(index, event)}
                            >
                              { filterModels(row).map((model, index) => (
                                <option value={model.underscore} key={index}>{model.name}</option>
                              ))}
                            </select>
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'list_attributes') ? 'block' : 'none' }}>
                            <select
                              name="column_name"
                              value={row.column_name}
                              onChange={(event) => handleInputChange(index, event)}
                            >
                              { filterAttributes(row).map((model, index) => (
                                <option value={model.name} key={index}>{model.name} ({model.type_clean})</option>
                              ))}
                            </select>
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'column_name') ? 'block' : 'none' }}>
                            <input
                              type="text"
                              name="column_name"
                              value={row.column_name}
                              onChange={(event) => handleInputChange(index, event)}
                            />
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'new_column_name') ? 'block' : 'none' }}>
                            <input
                              type="text"
                              name="new_column_name"
                              value={row.new_column_name}
                              onChange={(event) => handleInputChange(index, event)}
                            />
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'column_type') ? 'block' : 'none' }}>
                            <select
                              name="column_type"
                              value={row.column_type}
                              onChange={(event) => handleInputChange(index, event)}
                            >
                              { COLUMN_TYPES.map((type, index) => (
                                <option value={type.name} key={index}>{type.name}</option>
                              ))}
                            </select>

                          </div>
                          <div style={{ display: shouldBeVisible(row, 'new_column_type') ? 'block' : 'none' }}>
                            <select
                              name="new_column_type"
                              value={row.new_column_type}
                              onChange={(event) => handleInputChange(index, event)}
                            >
                              { COLUMN_TYPES.map((type, index) => (
                                <option value={type.name} key={index}>{type.name}</option>
                              ))}
                            </select>

                          </div>
                          <div style={{ display: shouldBeVisible(row, 'default') ? 'block' : 'none' }}>
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
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'nullable') ? 'block' : 'none' }}>
                                <label>Can be null:</label>
                                <input
                                  type="checkbox"
                                  name="nullable"
                                  checked={row.nullable}
                                  onChange={(event) => handleCheckboxChange(index, event)}
                                  />
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'unique') ? 'block' : 'none' }}>
                            <label>Unique:</label>
                            <input
                              type="checkbox"
                              name="unique"
                              checked={row.unique}
                              onChange={(event) => handleCheckboxChange(index, event)}
                            />
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'foreign_key') ? 'block' : 'none' }}>
                            <label>Foreign Key:</label>
                            <input
                              type="checkbox"
                              name="foreign_key"
                              checked={row.foreign_key}
                              onChange={(event) => handleCheckboxChange(index, event)}
                            />
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'list_indexes') ? 'block' : 'none' }}>
                            <label>Indexes:</label>
                            <select
                              name="index_name"
                              value={row.index_name}
                              onChange={(event) => handleInputChange(index, event)}
                            >
                              <option value="">-</option>
                              { filterIndexes(row).map((model, i) => (
                                <option value={model.value} key={i}>{model.label}</option>
                              ))}
                            </select>
                          </div>
                          <div style={{ display: shouldBeVisible(row, 'index') ? 'block' : 'none' }}>
                            <label>Index:</label>
                            <select
                              name="index"
                              value={row.index}
                              onChange={(event) => handleInputChange(index, event)}
                              >
                              <option value="">(none)</option>
                              { COLUMN_INDEXES.map((i, index) => (
                                <option value={i} key={index}>{i}</option>
                              ))}
                            </select>
                          </div>
                          { row.index && (
                          <div style={{ display: shouldBeVisible(row, 'index') ? 'block' : 'none' }}>
                            <label>Index Algorithm:</label>
                            <select
                              name="index_algorithm"
                              value={row.index_algorithm}
                              onChange={(event) => handleInputChange(index, event)}
                              >
                              <option value="default">default</option>
                              { COLUMN_INDEXES_ALGORITHMS.map((i, index) => (
                                <option value={i} key={index}>{i}</option>
                              ))}
                            </select>
                          </div>
                          )}
                        </td>
                        <td>
                          <button onClick={(event) => handleDeleteRow(index, event)} disabled={formRows.length === 1}>Delete</button>
                        </td>
                      </tr>
                    )}
                  </Draggable>
                ))}
                {provided.placeholder}
              </tbody>
            </table>
          )}
        </Droppable>
      </DragDropContext>
      <button onClick={handleAddRow}>Add</button>
    </div>
  );
};

export default NewMigrationForm;
