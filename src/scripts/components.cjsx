React = require 'react'

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
        <button className="btn btn-default" type="button">Go!</button>
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

CheckboxOption = React.createClass
  render: ->
    <div className="option-box">
      <div className="option-switch">
        <input type="checkbox" onChange={@props.fn}></input>
      </div>
      <p>{@props.text}</p>
    </div>

OptionPaneFactory = (classes, panelItems) ->
  <div className={"display-item " + classes}>
    {panelItems}
  </div>

AdvancedOptions = React.createClass
  render: ->
    <div className='display-item option-pane short-object'>
      <CheckboxOption text="hey" fn={-> console.log "ya"} />
      <CheckboxOption text="lol" fn={-> console.log "yar"} />
    </div>

module.exports =
  ItemList: ItemList
  SearchBar: SearchBar
  SearchList: SearchList
  TextSection: TextSection
  OutputTextPanel: OutputTextPanel
  InputTextPanel: InputTextPanel
  CheckboxOption: CheckboxOption
  AdvancedOptions: AdvancedOptions
