import React from 'react';
import Select from 'react-select';

const DarkSelect = ({ options, value, onChange, defaultValue, keySuffix = '', placeholder = "Select", isMulti = false, isSearchable = false, isClearable = false, customClassNamesOverrides = {}, setValue = null }) => {
  // const customStyles = {
  //   control: (provided, state) => ({
  //     ...provided,
  //     backgroundColor: '#1a1a1a',
  //     borderColor: state.isFocused ? '#4a4a4a' : '#333333',
  //     '&:hover': {
  //       borderColor: '#4a4a4a'
  //     },
  //     borderRadius: '0.375rem',
  //     padding: '2px'
  //   }),
  //   menu: (provided) => ({
  //     ...provided,
  //     // backgroundColor: '#1a1a1a',
  //     border: '1px solid #333333',
  //   }),
  //   option: (provided, state) => ({
  //     ...provided,
  //     backgroundColor: state.isSelected
  //       ? '#2d2d2d'
  //       : state.isFocused
  //         ? '#262626'
  //         : '#1a1a1a',
  //     color: '#e5e5e5',
  //     '&:active': {
  //       backgroundColor: '#333333'
  //     },
  //     cursor: 'pointer'
  //   }),
  //   singleValue: (provided) => ({
  //     ...provided,
  //     color: '#e5e5e5'
  //   }),
  //   input: (provided) => ({
  //     ...provided,
  //     color: '#e5e5e5'
  //   }),
  //   placeholder: (provided) => ({
  //     ...provided,
  //     color: '#6b7280'
  //   }),
  //   dropdownIndicator: (provided, state) => ({
  //     ...provided,
  //     color: state.isFocused ? '#6b7280' : '#4a4a4a',
  //     '&:hover': {
  //       color: '#6b7280'
  //     }
  //   }),
  //   clearIndicator: (provided, state) => ({
  //     ...provided,
  //     color: state.isFocused ? '#6b7280' : '#4a4a4a',
  //     '&:hover': {
  //       color: '#6b7280'
  //     }
  //   }),
  //   indicatorSeparator: (provided) => ({
  //     ...provided,
  //     backgroundColor: '#333333'
  //   })
  // };

  const customClassNames = {
    control: (state) => `
      !min-h-[24px] !h-[34px] !rounded !bg-localtower-600 !border !border-localtower-500 !outline-none !focus:border-localtower-400 !transition-colors !text-localtower-100 !cursor-pointer
      ${state.isFocused ? '!border-localtower-300 !shadow-none' : ''}
      ${state.isDisabled ? 'opacity-50 cursor-not-allowed' : 'hover:!border-localtower-300'}
      ${customClassNamesOverrides.control}
    `,
    menu: () => `!mt-0 !text-localtower-100 !border !border-localtower-500 !bg-localtower-600 !p-0 !rounded-md !m-0 !w-96 ${customClassNamesOverrides.menu}`,
    menuList: () => `!p-0 !text-localtower-100 !border !border-localtower-500 !bg-localtower-600 !rounded-md !m-0 !cursor-pointer ${customClassNamesOverrides.menuList}`,
    option: (state) => `
      !px-2.5 !py-1.5
      !bg-localtower-600
      !text-localtower-100
      ${state.isSelected ? '!bg-localtower-900 !text-white' : ''}
      hover:!bg-localtower-900 hover:!text-white !cursor-pointer active:opacity-70
    `,
    // input: () => '!text-blue-200',
    // placeholder: () => '!text-gray-500',
    singleValue: () => '!text-localtower-100',
    // valueContainer: () => 'px-2',
    // dropdownIndicator: (state) => `
    //   !text-gray-500 !p-2 hover:!text-gray-300
    //   ${state.isFocused ? '!text-gray-400' : ''}
    // `,
    // clearIndicator: () => '!text-gray-500 !p-2 hover:!text-gray-300',
    indicatorSeparator: () => '!mt-1 !bg-localtower-500'
  };

  const key = options.map((_) => _.value).join('-') + keySuffix;

  return (
    <Select
      key={key}
      options={options}
      value={options.find((option) => option.value === value)}
      defaultValue={defaultValue}
      // setValue={setValue}
      onChange={onChange}
      // isMulti={isMulti}
      // styles={customStyles}
      classNames={customClassNames}
      placeholder={placeholder}
      isSearchable={isSearchable}
      isClearable={isClearable}
      // menuIsOpen={true}
    />
  );
};

export default DarkSelect;
