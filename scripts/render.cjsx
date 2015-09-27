React = require 'react'
S = require './strings'
UI = require './components'


worker = null
if typeof Worker is undefined
  alert "This page uses Web Workers, a feature your browser does not support. To
  use this application, please upgrade your web browser."
else
  worker = new Worker 'scripts/optimize-worker-out.js'

# returns non-null on error
appStateValid = (state) ->
  inputs = (k for k of S.InputButtonTitlesDirections)
  typeValid = inputs.some((k) -> k is state.inputType)
  return "sequence type invalid" unless typeValid
  if not state.isDefaultChecked
    for opt, val of state.parameterizedOptions
      if isNaN parseFloat val
        return "#{opt} argument cannot be parsed as a number"
  null

stringToColor = (str) ->
  hash = 0
  for a in str.split ''
    hash = a.charCodeAt(0) + ((hash << 7) - hash)
  color = '#'
  for i in [0..2]
    color += ('00' + ((hash << i * 3) & 0xFF).toString(16)).slice(-2)
  color

MutationOptimizerApp = React.createClass
  getInitialState: ->
    selectedElement: null
    inputText: ''
    inputType: S.InitialButtonTitle
    advancedOptions: do ->
      res = JSON.parse JSON.stringify S.AdvancedOptions
      res[k] = no for k, v of res
      res
    parameterizedOptions: JSON.parse JSON.stringify S.ParameterizedOptions
    isDefaultChecked: no
    pcntMutable: null
    pcntChange: null
  render: ->
    <div>
      <nav className="navbar navbar-default navbar-static-top">
        <div className="container-fluid">
          <div className="navbar-header">
            <a className="navbar-brand" href="#" target="_blank">
              {S.VersionName}
            </a>
            {
              <a href={val} target="_blank" key={key}>
                <button type="button" className="btn btn-default navbar-btn">
                  {key}
                </button>
              </a> for key, val of S.NavbarButtons
            }
          </div>
          <p id="speciesSelected" style={
            if @state.selectedElement
              color: stringToColor @state.selectedElement
            else
              color: S.DefaultSpeciesColor}
            className="navbar-text species-selected navbar-right">
              {@state.selectedElement or S.DefaultSpeciesText}
          </p>
        </div>
      </nav>
      <div className="container-fluid">
        <div className="row">
          <div className="col-md-2">
            <UI.SearchList classes="display-item tall-object listing"
              name={S.SearchPanelHeading} defaultInput={S.SearchPanelDefault}
              items={S.SpeciesToSearch}
              fn={(obj) =>
                @setState selectedElement: obj
                alert S.NoSpeciesText} />
          </div>
          <div className="col-md-5">
            <UI.InputTextPanel name={S.InputPanelHeading}
              classes="display-item tall-object"
              typeFn={(val) => @setState inputType: val}
              inputFn={(val) => @setState inputText: val}
              buttons={S.InputButtonTitlesDirections}
              selectedButton={@state.inputType} />
          </div>
          <div className="col-md-5">
            <UI.OutputTextPanel text={S.OutputDirections}
              name={S.OutputPanelHeading} classes="display-item tall-object"
              goButtonText={S.OutputButtonText}
              clearButtonText={S.ClearButtonText}
              worker={worker} getStateFn={=>
                res = appStateValid @state
                if res
                  alert JSON.stringify res
                  {invalidState: yes}
                else @state}
              percentageFn={(arg) => @setState arg}
              clearFn={=> @setState
                pcntMutable: null
                pcntChange: null}/>
          </div>
        </div>
        <div className="row">
          <div className="col-md-2 more-padding">
            <UI.AdvancedOptions labelText={S.AdvancedOptionsHeading}>
            {
              ([k, v] for k, v of @state.advancedOptions).map ([key, val]) =>
                <UI.CheckboxWithContext key={key} heading={key}
                  fn={do (key) => (checked) =>
                    newOptions = @state.advancedOptions
                    newOptions[key] = checked
                    @setState advancedOptions: newOptions}>
                  <p className="explanation-text">
                    {S.AdvancedOptions[key]}
                  </p>
                </UI.CheckboxWithContext>
            }
            </UI.AdvancedOptions>
          </div>
          <div className="col-md-8">
            <UI.DisableableItem heading={S.DefaultParamLabel}
              fn={(checked) => @setState isDefaultChecked: checked}
              labelText={S.ParameterOptionsHeading}>
              {
                <UI.OptionsBox newClasses="params-holder">
                  {
                    optsList = ([k, v] for k, v of @state.parameterizedOptions)
                    optsList.map ([key, val]) =>
                      <UI.ParameterizedOption key={key} text={key}
                        fn={((e) => (value) =>
                          newOptions = @state.parameterizedOptions
                          newOptions[e] = value
                          @setState parameterizedOptions: newOptions)(key)}
                        initialInput={val}
                        isDisabled=false />
                  }
                </UI.OptionsBox>
              }
            </UI.DisableableItem>
          </div>
          <div className="col-md-2">
            <UI.MutabilityScoreboard lbl={S.MutabilityScoreboardLabel}
              pcntMutable={@state.pcntMutable} pcntChange={@state.pcntChange}
              mutableDisplay={S.MutabilityLabel}
              changeDisplay={S.ChangeLabel}/>
          </div>
        </div>
      </div>
    </div>

React.render <MutationOptimizerApp />, document.getElementById 'root'
