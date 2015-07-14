React = require 'react'
gensym = require './gensym'


### searchable list ###
ItemList = React.createClass
  getInitialState: ->
    items: [0..10]
    str: @props.str or "b"
  addItem: ->
    items = @state.items
    @setState items: items.concat items.length
  render: ->
    <div className='list-group'>
      {<a href='#' onClick={@addItem} className='list-group-item' key={el}>
        {"#{el}:#{@state.str}"}
      </a> for el in @state.items}
    </div>

SearchBar = React.createClass
  render: ->
    <div className="input-group">
      <input type="text" className="form-control" placeholder="Search for...">
      </input>
      <span className="input-group-btn">
        <button className="btn btn-default" type="button">
          <span className="glyphicon glyphicon-search"></span>
        </button>
      </span>
    </div>

SearchList = React.createClass
  render: ->
    <div>
      <label>{@props.name}</label>
      <div className={@props.classes}>
        <SearchBar/>
        <ItemList str="a"/>
      </div>
    </div>


### text panel ###
TextSection = React.createClass
  render: ->
    <textarea className="form-control" readOnly={@props.textReadOnly}>
    </textarea>

LabeledPanel = React.createClass
  render: ->
    <div>
      <label>{@props.labelTitle}</label>
      <div className={@props.outerClasses}>
        <div className="panel panel-default">
          <div className="panel-heading">{@props.headers}</div>
          <div className="panel-body">{@props.children}</div>
        </div>
      </div>
    </div>

OutputTextPanel = React.createClass
  getInitialState: ->
    discussionText: @props.text or ""
    panelClass: @props.panelClass or 'panel-default'
  render: ->
    headers = <p>{@state.discussionText}</p>
    <LabeledPanel labelTitle={@props.name} outerClasses={@props.classes}
      headers={headers}>
      <TextSection textReadOnly=true />
    </LabeledPanel>


### just a buncha buttons ###
ButtonSelected = 'btn btn-primary'
ButtonNonSelected = 'btn btn-default'

makeButtonClass = (ind1, ind2) ->
  if ind1 is ind2 then ButtonSelected else ButtonNonSelected

ButtonArray = React.createClass
  getInitialState: ->
    selectedIndex: @props.initialIndex or 0
  makeOnClick: (index) ->
    =>
      @setState selectedIndex: index
      @props.onClickFn? index
  render: ->
    <div className='btn-group'>
      {<button type='button' key={index}
               className={makeButtonClass @state.selectedIndex, index}
               onClick={@makeOnClick index}>
         {text}
       </button> for text, index in @props.texts}
    </div>

InputTextPanel = React.createClass
  getInitialState: ->
    discussionText: @props.text or ""
    panelClass: @props.panelClass or 'panel-default'
    buttonPressed: "left"
  render: ->
    headers = [
        <p key="1">{@state.discussionText}</p>
        <ButtonArray key="2" texts={["a","b"]} initialIndex={0}
          onClickFn={(ind) -> console.log ind} />
      ]
    <LabeledPanel labelTitle={@props.name} outerClasses={@props.classes}
      headers={headers}>
      <TextSection textReadOnly=false />
    </LabeledPanel>


### option elements ###
CheckboxOption = React.createClass
  getInitialState: ->
    id: gensym()
  onChangeFn: (ev) ->
    @props.fn document.getElementById(@state.id).checked
  render: ->
    <div className="option-switch">
      <input type="checkbox" onChange={@onChangeFn} id={@state.id}></input>
      <label htmlFor={@state.id}>{@props.heading}</label>
    </div>

CheckboxWithContext = React.createClass
  render: ->
    <div className={"display-item option-box " + (@props.classes or "")}>
      <CheckboxOption fn={@props.fn} heading={@props.heading} />
      {@props.children}
    </div>

AdvancedOptions = React.createClass
  render: ->
    <div>
      <label className={@props.labelClasses or ""}>{@props.labelText}</label>
      <div className='option-pane short-object'>
        {@props.children}
      </div>
    </div>


### parameterized options ###
OptionsBox = React.createClass
  getInitialState: ->
    disabled: @props.isDisabled
  render: ->
    console.log @props
    console.log @state
    <div className="options-box">
      {
        React.Children.map @props.children, (child) =>
          React.cloneElement child, isDisabled: @state.disabled
      }
    </div>

NumericPlaceholder = "0.0"
makeInputAddon = (el) ->
  <span className="input-group-addon">{el}</span> if el
ParameterizedOption = React.createClass
  getInitialState: ->
    disabled: @props.isDisabled
  render: ->
    <div className="parameterized-option">
      <label>{@props.text}</label>
      <div className="input-group input-group-sm">
        {makeInputAddon @props.children?[0]}
        <input type={@props.inputType or "text"} className="form-control num"
          placeholder={@props.initialInput or NumericPlaceholder}
          disabled={@state.disabled}></input>
        {makeInputAddon @props.children?[0]}
      </div>
    </div>

DisableableItem = React.createClass
  getInitialState: ->
    disabled: false
  onCheckBox: (unchecked) ->
    @setState disabled: unchecked
  render: ->
    <AdvancedOptions labelText={@props.labelText}
      labelClasses={@props.labelClasses}>
      <CheckboxWithContext heading={@props.heading} fn={@onCheckBox}>
        {
          console.log @state.disabled
          React.Children.map @props.children, (child) =>
            React.cloneElement child, isDisabled: @state.disabled
        }
      </CheckboxWithContext>
    </AdvancedOptions>


module.exports =
  ItemList: ItemList
  SearchBar: SearchBar
  SearchList: SearchList
  TextSection: TextSection
  OutputTextPanel: OutputTextPanel
  InputTextPanel: InputTextPanel
  CheckboxOption: CheckboxOption
  CheckboxWithContext: CheckboxWithContext
  AdvancedOptions: AdvancedOptions
  OptionsBox: OptionsBox
  ParameterizedOption: ParameterizedOption
  DisableableItem: DisableableItem
