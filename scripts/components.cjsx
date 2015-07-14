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
  render: ->
    id = gensym()
    <div className="option-switch">
      <input type="checkbox" onChange={@props.fn} id={id}></input>
      <label htmlFor={id}>{@props.heading}</label>
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
      <label>{@props.labelText}</label>
      <div className='option-pane short-object'>
        {@props.children}
      </div>
    </div>


### parameterized options ###
OptionsBox = React.createClass
  render: ->
    <div className="options-box">{@props.children}</div>

NumericPlaceholder = "00.00"
ParameterizedOption = React.createClass
  render: ->
    <div className="parameterized-option">
      <label>{@props.text}</label>
      <div className="input-group input-group-sm">
        {if @props.children?[0]
           <span className="input-group-addon">{@props.children[0]}</span>}
        <input type={@props.inputType or "text"} className="form-control"
          placeholder={@props.initialInput or NumericPlaceholder}></input>
        {if @props.children?[1]
           <span className="input-group-addon">{@props.children[1]}</span>}
      </div>
    </div>

DisableableItem = React.createClass
  render: ->
    <AdvancedOptions labelText={@props.labelText}>
      <CheckboxWithContext heading="aa" fn={@props.fn}>
        {@props.children}
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
