React = require 'react'
gensym = require './gensym'


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
transformInputText = (text) ->
  text.split('').join('.*')
# used to have this split into two components, the search bar and the ItemList,
# and couldn't figure out how to allow the user to input text, but also allow me
# to input text when changing state. this is less modular, but it works.
SearchList = React.createClass
  getInitialState: ->
    inputText: ''
    selectedElement: null
  clearAndFocusInput: ->
    inp = React.findDOMNode(@refs.textInput)
    inp.value = ''
    inp.focus()
    @setState
      selectedElement: null
      inputText: ''
    @props.fn
      key: @props.listKey
      value: null
  render: ->
    <div>
      <label className="spaced">{@props.name}</label>
      {
        <div className="display-item species-selection pull-right">
          <p>{@state.selectedElement or "No species selected."}</p>
        </div>
      }
      <div className={@props.classes}>
        <div className="input-group">
          <input type="text" className="form-control"
            placeholder={@props.defaultInput} value={@state.inputText}
            ref="textInput" onChange={=>
              val = React.findDOMNode(@refs.textInput).value
              console.log val
              @setState inputText: val}>
          </input>
          <span className="input-group-btn">
            <button className="btn btn-default" type="button"
              onClick={@clearAndFocusInput}>
              <span className="glyphicon glyphicon-remove"></span>
            </button>
          </span>
        </div>
        <ItemList items={@props.items.filter (el) =>
          el.match new RegExp transformInputText(@state.inputText), 'i'}
          selectFn={(obj) =>
            @setState
              selectedElement: obj
              inputText: obj
            @props.fn
              key: @props.listKey
              value: obj} />
      </div>
    </div>


### text panel ###
LabeledPanel = React.createClass
  render: ->
    <div>
      <label className="spaced">{@props.labelTitle}</label>
      <div className={@props.outerClasses}>
        <div className="panel panel-default">
          <div className="panel-heading">{@props.headers}</div>
          <div className="panel-body">{@props.children}</div>
        </div>
      </div>
    </div>

TextSection = React.createClass
  render: ->
    <textarea className="form-control" ref="txtInput"
      readOnly={@props.textReadOnly} value={@props.text}
      onChange={=> if @props.fn
        @props.fn React.findDOMNode(@refs.txtInput).value}></textarea>

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
      <TextSection textReadOnly=true text={@state.outputText} />
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
         {text.heading}
       </button> for text, index in @props.texts}
    </div>

InputTextPanel = React.createClass
  getInitialState: ->
    buttonIndex: 0
    inputText: ''
  render: ->
    headers = [
        <p key="1">{@props.children[@state.buttonIndex].text}</p>
        <ButtonArray key="2" texts={@props.children}
          initialIndex={@state.buttonIndex}
          onClickFn={(ind) =>
            @setState buttonIndex: ind
            @props.fn
              key: @props.buttonKey
              value: @props.children[ind].heading} />
      ]
    <LabeledPanel labelTitle={@props.name} outerClasses={@props.classes}
      headers={headers}>
      <TextSection textReadOnly=false fn={(txt) =>
        @setState inputText: txt
        @props.fn
          key: @props.sectionKey
          value: txt} />
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
      <div className='option-pane short-object'>
        {@props.children}
      </div>
    </div>


### parameterized options ###
OptionsBox = React.createClass
  getInitialState: ->
    disabled: @props.disabled
  render: ->
    <div className="options-box">
      {
        React.Children.map @props.children, (child) =>
          React.cloneElement child, disabled: @props.disabled
      }
    </div>

NumericPlaceholder = "0.0"
makeInputAddon = (el) ->
  <span className="input-group-addon">{el}</span> if el?
makeLabel = (text, disabled, defaultValue) ->
  str = text
  str += " (#{defaultValue})" if disabled
  <label className="parameter-label">{str}</label>
ParameterizedOption = React.createClass
  render: ->
    <div className="parameterized-option">
      {makeLabel @props.text, @props.disabled, @props.initialInput}
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
  onCheckBox: (unchecked) ->
    @setState disabled: unchecked
    console.log unchecked
    @props.fn unchecked
  render: ->
    <AdvancedOptions labelText={@props.labelText}>
      <CheckboxWithContext heading={@props.heading} fn={@onCheckBox}>
        {
          React.Children.map @props.children, (child) =>
            React.cloneElement child, disabled: @state.disabled
        }
      </CheckboxWithContext>
    </AdvancedOptions>


module.exports =
  ItemList: ItemList
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
