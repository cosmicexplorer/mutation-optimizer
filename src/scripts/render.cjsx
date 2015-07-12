React = require 'react'

UI = require './components'

React.render <UI.SearchList classes="display-item tall-object"
  name="Search Species"/>,
  document.getElementById 'species-search-list'

React.render <UI.TextPanel textReadOnly="true" text="output directions"
  name="output panel" classes="display-item tall-object"/>,
  document.getElementById 'output-panel'
