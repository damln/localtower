// import './styles/tailwind.css'

import React from 'react'
import ReactDOM from 'react-dom'
import NewModelForm from './components/NewModelForm'
import NewMigrationForm from './components/NewMigrationForm'

document.addEventListener('DOMContentLoaded', () => {
  const container1 = document.getElementById('react-container-new-model')
  if (container1) {
    ReactDOM.render(<NewModelForm />, container1)
  }

  const container2 = document.getElementById('react-container-new-migration')
  if (container2) {
    ReactDOM.render(<NewMigrationForm />, container2)
  }
})
