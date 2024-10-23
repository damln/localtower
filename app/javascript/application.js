import React from 'react'
import NewModelForm from './components/NewModelForm'
import NewMigrationForm from './components/NewMigrationForm'

import { createRoot } from 'react-dom/client';

document.addEventListener('DOMContentLoaded', () => {
  const container1 = document.getElementById('react-container-new-model')
  if (container1) {
    const root1 = createRoot(container1); // createRoot(container!) if you use TypeScript
    root1.render(<NewModelForm />);
  }

  const container2 = document.getElementById('react-container-new-migration')
  if (container2) {
    const root2 = createRoot(container2); // createRoot(container!) if you use TypeScript
    root2.render(<NewMigrationForm />);
  }
});

$(document).ready(function () {
  $(".grid").masonry({
    itemSelector: ".grid-item",
    percentPosition: true,
    columnWidth: ".grid-sizer",
  });

  hljs.highlightAll();
});
