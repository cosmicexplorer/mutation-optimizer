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

LabeledPanelFactory = (labelTitle, outerClasses, panelClasses, headerContent,
  bodyContent) ->
  <div>
    <label>{labelTitle}</label>
    <div className={outerClasses}>
      <div className={"panel " + panelClasses}>
        <div className="panel-heading">{headerContent}</div>
        <div className="panel-body">{bodyContent}</div>
      </div>
    </div>
  </div>

OutputTextPanel = React.createClass
  getInitialState: ->
    discussionText: @props.text or ""
    panelClass: @props.panelClass or 'panel-default'
  render: ->
    LabeledPanelFactory @props.name, @props.classes, @state.panelClass,
      <p>{@state.discussionText}</p>,
      <TextSection textReadOnly=true />

InputTextPanel = React.createClass
  getInitialState: ->
    discussionText: @props.text or ""
    panelClass: @props.panelClass or 'panel-default'
  render: ->
    LabeledPanelFactory @props.name, @props.classes, @state.panelClass,
      [
        <p key="1">{@state.discussionText}</p>
        <div key="2" className="btn-group">
          <button htmlType="button" className="btn btn-primary">a</button>
          <button htmlType="button" className="btn btn-default">b</button>
        </div>
      ],
      <TextSection textReadOnly=false />

module.exports =
  ItemList: ItemList
  SearchBar: SearchBar
  SearchList: SearchList
  TextSection: TextSection
  LabeledPanelFactory: LabeledPanelFactory
  OutputTextPanel: OutputTextPanel
  InputTextPanel: InputTextPanel
