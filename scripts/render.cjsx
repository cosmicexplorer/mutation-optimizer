React = require 'react'
UI = require './components'
S = require './strings'


### global state ###
# keys
ParameterizedOptionsKey = 'parameterized-options'
AdvancedOptionsKey = 'advanced-options'
GeneticInputKey = 'genetic-input'
SpeciesSearchKey = 'species-search'

# global objects
Options = {}
Listeners = {}

# setup
[
  ParameterizedOptionsKey
  AdvancedOptionsKey
  GeneticInputKey
  SpeciesSearchKey].forEach (key) ->
  Options[key] = {}
  Listeners[key] = []

# accessors
UpdateOptions = (key, obj) ->
  Options[key][obj.key] = obj.value
  Listeners[key].forEach (cb) -> cb obj
AddListener = (key, fn) ->
  Listeners[key].push fn


# setup defaults
SearchListKey = 'species'
UpdateOptions SpeciesSearchKey,
  key: SearchListKey
  value: null
React.render <UI.SearchList classes="display-item tall-object listing"
  name={S.SearchPanelHeading} defaultInput={S.SearchPanelDefault}
  items={S.SpeciesToSearch} listKey={SearchListKey}
  fn={(obj) -> UpdateOptions SpeciesSearchKey, obj} />,
  document.getElementById 'species-search-list'

AddListener SpeciesSearchKey, (obj) -> console.log obj


# setup defaults
InputTextButtonKey = 'input-type'
InputTextSectionKey = 'input-text'
UpdateOptions GeneticInputKey,
  key: InputTextButtonKey
  value: S.InputButtonTitlesDirections[0].heading
UpdateOptions GeneticInputKey,
  key: InputTextSectionKey
  value: ''

React.render <UI.InputTextPanel name={S.InputPanelHeading}
  classes="display-item tall-object" buttonKey={InputTextButtonKey}
  sectionKey={InputTextSectionKey}
  fn={(obj) -> UpdateOptions GeneticInputKey, obj}>
    {S.InputButtonTitlesDirections}
  </UI.InputTextPanel>,
  document.getElementById 'input-panel'

AddListener GeneticInputKey, (obj) -> console.log obj


# no listeners required here since we only output to this pane
React.render <UI.OutputTextPanel text={S.OutputDirections}
  name={S.OutputPanelHeading} classes="display-item tall-object"
  buttonText={S.OutputButtonText} getOutputFn={-> JSON.stringify Options}/>,
  document.getElementById 'output-panel'


# setup defaults
S.AdvancedOptions.forEach (e) -> UpdateOptions AdvancedOptionsKey,
  key: e.heading
  value: no

React.render <UI.AdvancedOptions labelText={S.AdvancedOptionsHeading}>
  {
    <UI.CheckboxWithContext key={i} heading={el.heading}
      fn={((e) -> (checked) -> UpdateOptions AdvancedOptionsKey,
        key: e.heading
        value: checked)(el)}>
      <p className="explanation-text">{el.text}</p>
    </UI.CheckboxWithContext> for el, i in S.AdvancedOptions
  }
  </UI.AdvancedOptions>,
  document.getElementById 'advanced-options'

AddListener AdvancedOptionsKey, (obj) -> console.log obj


# setup defaults
CheckboxKey = 'use-default'
S.ParameterizedOptions.forEach (e) -> UpdateOptions ParameterizedOptionsKey,
  key: e.label
  value: e.default

UpdateOptions ParameterizedOptionsKey,
  key: CheckboxKey
  value: no

React.render <UI.DisableableItem heading={S.DefaultParamLabel}
  fn={(unchecked) -> UpdateOptions ParameterizedOptionsKey,
    key: CheckboxKey
    value: unchecked}
  labelText={S.ParameterOptionsHeading}>
    <UI.OptionsBox>
      {
        <UI.ParameterizedOption key={i} text={el.label}
          fn={((e) -> (value) -> UpdateOptions ParameterizedOptionsKey,
            key: e.label
            value: value)(el)}
          initialInput={el.default}
          isDisabled=false /> for el, i in S.ParameterizedOptions
      }
    </UI.OptionsBox>
  </UI.DisableableItem>,
  document.getElementById 'output-options'

AddListener ParameterizedOptionsKey, (obj) -> console.log obj
