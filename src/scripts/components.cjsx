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
  getInitialState: ->
    # TODO: find better way to do this
    idEl: Math.random()
  render: ->
    <div>
      <label htmlFor={@state.idEl}>{@props.name}</label>
      <div className={@props.classes} id={@state.idEl}>
        <SearchBar/>
        <ItemList str="a"/>
      </div>
    </div>

### text panel ###
TextSection = React.createClass
  render: ->
    <textarea className="form-control" readOnly={@props.textReadOnly}>
    </textarea>

TextPanel = React.createClass
  getInitialState: ->
    discussionText: @props.text or ""
    idEl: Math.random()
  render: ->
    panelClass = @props.panelClass or 'panel-default'
    panelClasses = "panel #{panelClass}"
    <div>
      <label htmlFor={@state.idEl}>{@props.name}</label>
      <div className={@props.classes}>
        <div className={panelClasses} id={@state.idEl}>
          <div className="panel-heading">
            <p>{@state.discussionText}</p>
          </div>
          <div className="panel-body">
            <TextSection readOnly={@props.textReadOnly} />
          </div>
        </div>
      </div>
    </div>

module.exports =
  ItemList: ItemList
  SearchBar: SearchBar
  SearchList: SearchList
  TextSection: TextSection
  TextPanel: TextPanel
