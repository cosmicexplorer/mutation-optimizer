React = require 'react'
S = require './strings'
UI = require './components'
Opt = require '../lib/mutation-optimizer'

AdvancedOptionsPerLine = 2
WeightedOptionsPerLine = 6

# returns non-null on error
appStateValid = (state) ->
  inputs = (k for k of S.InputButtonTitlesDirections)
  typeValid = inputs.some((k) -> k is state.inputType)
  return "sequence type invalid" unless typeValid
  for opt, val in state.parameterizedOptions
    if isNaN parseFloat val
      return "#{opt} argument cannot be parsed as a number"
  null

getSequenceOpt = (state) ->
  aminoSeq = switch state.inputType
    when 'DNA' then (new Opt.DNASequence state.inputText).toAminoSeq()
    when 'Amino' then new Opt.AminoAcidSequence @state.inputText
    else throw new Opt.SequenceError "sequence type invalid", "bad seq type"
  weights = if state.isDefaultChecked then null else state.parameterizedOptions
  minSeq = aminoSeq.minimizeMutation weights
  switch state.inputType
    when 'DNA' then diffSequence state.inputText, minSeq.seq
    when 'Amino' then <span className="seq-no-highlight">{minSeq.seq}</span>

createSequenceHighlight = (oldCodon, newCodon, ind) ->
  <span title={"#{oldCodon}->#{newCodon}"} className="seq-highlight" key={ind}>
    {newCodon}
  </span>

diffSequence = (oldInput, newInput) ->
  for i in [0..(newInput.length / 3)] by 1
    oldCodon = oldInput[i..(i + 2)].toUpperCase()
    newCodon = newInput[i..(i + 2)].toUpperCase()
    if oldCodon isnt newCodon then createSequenceHighlight oldCodon, newCodon, i
    else <span className="seq-no-highlight" key={i}>{newCodon}</span>

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
              fn={(obj) => @setState selectedElement: obj} />
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
              buttonText={S.OutputButtonText}
              getOutputFn={=>
                console.log @state
                res = appStateValid @state
                if res
                  # TODO: display modal or some error text?
                  console.error res
                  null
                else
                  try (getSequenceOpt @state) catch err
                    console.error err} />
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
          <div className="col-md-10">
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
                          @setState(parameterizedOptions: newOptions))(key)}
                        initialInput={val}
                        isDisabled=false />
                  }
                </UI.OptionsBox>
              }
            </UI.DisableableItem>
          </div>
        </div>
      </div>
    </div>

React.render <MutationOptimizerApp />, document.getElementById 'root'
