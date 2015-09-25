React = require 'react'
DetectResize = require 'detect-element-resize'
gensym = require './gensym'
utils = require '../lib/utils'


### searchable list ###
ItemList = React.createClass
  render: ->
    <div className='list-group'>
      {<a href='#' className='list-group-item' key={i}
        onClick={((e) => => @props.selectFn e)(el)}>
        {el}
      </a> for el,i in @props.items}
    </div>

# make fuzzy search regex by inserting wildcards between every letter
quoteRegex = (str) ->
  (str + '').replace /[.?*+^$[\]\\(){}|-]/g, "\\$&"
transformInputText = (text) ->
  quoteRegex(text).split('').join('.*')
# used to have this split into two components, the search bar and the ItemList,
# and couldn't figure out how to allow the user to input text, but also allow me
# to input text when changing state. this is less modular, but it works.
SearchList = React.createClass
  getInitialState: ->
    inputText: ''
  clearAndFocusInput: ->
    inp = React.findDOMNode(@refs.textInput)
    inp.value = ''
    inp.focus()
    @setState inputText: ''
    @props.fn null
  render: ->
    <div>
      <label className="spaced">{@props.name}</label>
      <div className={@props.classes}>
        <div className="input-group">
          <input type="text" className="form-control"
            placeholder={@props.defaultInput} value={@state.inputText}
            ref="textInput" onChange={=>
              val = React.findDOMNode(@refs.textInput).value
              @setState inputText: val}>
          </input>
          <span className="input-group-btn">
            <button className="btn btn-default" type="button"
              onClick={@clearAndFocusInput}>
              <span className="glyphicon glyphicon-remove"></span>
            </button>
          </span>
        </div>
        <ItemList items={if @state.inputText then @props.items.filter (el) =>
            el.match new RegExp transformInputText(@state.inputText), 'i'
          else @props.items}
          selectFn={(selectedElement) =>
            @setState inputText: selectedElement
            @props.fn selectedElement} />
      </div>
    </div>


### text panel ###
LabeledPanel = React.createClass
  getInitialState: ->
    bodyHeight: null
    resizeListener: null
  componentDidMount: ->
    node = React.findDOMNode @refs.panelBody
    listen = =>
      @setState bodyHeight: node.clientHeight
    @setState
      bodyHeight: node.clientHeight
      resizeListener: listen
    DetectResize.addResizeListener node, listen
  componentWillUnmount: ->
    node = React.findDOMNode @refs.panelBody
    DetectResize.removeResizeListener node, @state.resizeListener
  render: ->
    <div>
      <label className="spaced">{@props.labelTitle}</label>
      <div className={@props.outerClasses}>
        <div className="panel panel-default">
          <div className="panel-heading">{@props.headers}</div>
          <div className="panel-body" ref="panelBody">
            {
              React.Children.map @props.children, (child) =>
                React.cloneElement child, parentHeight: @state.bodyHeight
            }
          </div>
        </div>
      </div>
    </div>

# chrome doesn't like making textareas as large as their container. we rerender
# height as a function of the parent's height
MagicTextHeightPercentage = .105
TextSection = React.createClass
  render: ->
    <textarea className="form-control" ref="txtInput"
      readOnly={@props.textReadOnly} value={@props.text}
      style={do =>
        h = @props.parentHeight
        {height: (h * MagicTextHeightPercentage) + "ex"} if h?}
      onChange={=> if @props.fn
        @props.fn React.findDOMNode(@refs.txtInput).value}>
    </textarea>

MagicOutputTextHeightPercentage = .109
ScrollingDiv = React.createClass
  render: ->
    <div className="output-seq" style={do =>
      h = @props.parentHeight
      {height: (h * MagicOutputTextHeightPercentage) + "ex"} if h?}>
      {@props.txt}
    </div>

OutputTextPanel = React.createClass
  getInitialState: ->
    outputText: ''
  render: ->
    headers = [
      <p key="1">{@props.text}</p>
      <button key="2" type="button" className="btn btn-success"
        onClick={=> @setState outputText: @props.getOutputFn()}>
        {@props.buttonText}
      </button>
      ]
    <LabeledPanel labelTitle={@props.name} outerClasses={@props.classes}
      headers={headers}>
      <ScrollingDiv txt={@state.outputText}/>
    </LabeledPanel>


### just a buncha buttons ###
ButtonGroupBase = 'btn '
ButtonSelected = ButtonGroupBase + 'btn-primary'
ButtonNonSelected = ButtonGroupBase + 'btn-default'

makeButtonClass = (ind1, ind2) ->
  if ind1 is ind2 then ButtonSelected else ButtonNonSelected

ButtonArray = React.createClass
  render: ->
    <div className='btn-group'>
      {<button type='button' key={key}
               className={makeButtonClass @props.selectedButton, key}
               onClick={((k) => => @props.onClickFn k)(key)}>
         {key}
       </button> for key, val of @props.texts}
    </div>

InputTextPanel = React.createClass
  render: ->
    headers = [
        <p key="1">{@props.buttons[@props.selectedButton]}</p>
        <ButtonArray key="2" texts={@props.buttons}
          selectedButton={@props.selectedButton}
          onClickFn={@props.typeFn} />
      ]
    <LabeledPanel labelTitle={@props.name} outerClasses={@props.classes}
      headers={headers}>
      <TextSection textReadOnly=false fn={@props.inputFn} />
    </LabeledPanel>


### option elements ###
CheckboxOption = React.createClass
  getInitialState: ->
    # id required for proper label placement with font-awesome
    id: gensym()
  onChangeFn: (ev) ->
    @props.fn React.findDOMNode(@refs.checkInput).checked
  render: ->
    <div className="option-switch">
      <input type="checkbox" onChange={@onChangeFn} ref="checkInput"
        id={@state.id}></input>
      <label htmlFor={@state.id} className="checkbox-label">
        {@props.heading}
      </label>
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
      <label className="spaced">{@props.labelText}</label>
      <div className="option-pane advanced-options">
        {@props.children}
      </div>
    </div>


### parameterized options ###
OptionsBox = React.createClass
  getInitialState: ->
    disabled: @props.disabled
  render: ->
    <div className={"options-box row " + @props.newClasses}>
      {
        React.Children.map @props.children, (child) =>
          React.cloneElement child, disabled: @props.disabled
      }
    </div>

NumericPlaceholder = "0.0"
makeInputAddon = (el) ->
  <span className="input-group-addon">{el}</span> if el?
makeLabel = (text, disabled) ->
  str = text
  <label className="parameter-label">{str}</label>
ParameterizedOption = React.createClass
  render: ->
    <div className="parameterized-option">
      {makeLabel @props.text, @props.disabled}
      <div className="input-group input-group-sm">
        {makeInputAddon @props.children?[0]}
        <input type={@props.inputType or "text"} className="form-control num"
          placeholder={@props.initialInput}
          disabled={@props.disabled}
          onChange={(ev) => @props.fn(ev.target.value)}></input>
        {makeInputAddon @props.children?[1]}
      </div>
    </div>

DisableableItem = React.createClass
  getInitialState: ->
    disabled: false
  onCheckBox: (checked) ->
    @setState disabled: checked
    @props.fn checked
  render: ->
    <AdvancedOptions labelText={@props.labelText}>
      <CheckboxWithContext heading={@props.heading} fn={@onCheckBox}>
        {
          React.Children.map @props.children, (child) =>
            React.cloneElement child, disabled: @state.disabled
        }
      </CheckboxWithContext>
    </AdvancedOptions>


module.exports = {
  ItemList
  SearchList
  TextSection
  ScrollingDiv
  OutputTextPanel
  InputTextPanel
  CheckboxOption
  CheckboxWithContext
  AdvancedOptions
  OptionsBox
  ParameterizedOption
  DisableableItem
}
