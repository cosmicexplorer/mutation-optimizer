React = require 'react'
UI = require './components'

React.render <UI.SearchList classes="display-item tall-object"
  name="Search Species" />,
  document.getElementById 'species-search-list'

React.render <UI.OutputTextPanel text="output directions"
  name="output panel" classes="display-item tall-object" />,
  document.getElementById 'output-panel'

React.render <UI.InputTextPanel text="input directions"
  name="input panel" classes="display-item tall-object" />,
  document.getElementById 'input-panel'

React.render <UI.AdvancedOptions labelText="advanced options">
    <UI.CheckboxWithContext heading="hey" fn={-> console.log "ya"}>
      <p>explanation</p>
    </UI.CheckboxWithContext>
    <UI.CheckboxWithContext heading="lol" fn={-> console.log "yar"}>
      <p>EXPLAIN</p>
    </UI.CheckboxWithContext>
  </UI.AdvancedOptions>,
  document.getElementById 'advanced-options'

React.render <UI.DisableableItem heading="aa" fn={-> console.log "mucho"}
  labelText="ee">
    <UI.OptionsBox>
      <UI.ParameterizedOption text="lol" isDisabled=false />
      <UI.ParameterizedOption text="lol" isDisabled=false />
      <UI.ParameterizedOption text="lol" isDisabled=false />
      <UI.ParameterizedOption text="lol" isDisabled=false />
      <UI.ParameterizedOption text="lol" isDisabled=false />
      <UI.ParameterizedOption text="lol" isDisabled=false />
    </UI.OptionsBox>
  </UI.DisableableItem>,
  document.getElementById 'output-options'
