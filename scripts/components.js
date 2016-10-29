var AdvancedOptions, ButtonArray, ButtonGroupBase, ButtonNonSelected, ButtonSelected, CheckboxOption, CheckboxWithContext, DetectResize, DisableableItem, InputTextPanel, ItemList, LabeledPanel, MagicOutputTextHeightPercentage, MagicTextHeightPercentage, MeterDisplay, MutabilityScoreboard, NumericPlaceholder, OptionsBox, OutputTextPanel, ParameterizedOption, React, ScrollingDiv, SearchList, Spinner, TextSection, _, createSequenceHighlight, diffSequence, gensym, makeButtonClass, makeInputAddon, makeLabel, percentRound, quoteRegex, spinCfg, transformInputText, utils;

_ = require('lodash');

React = require('react');

Spinner = require('react-spin');

DetectResize = require('detect-element-resize');

gensym = require('./gensym');

utils = require('../lib/utils');


/* searchable list */

ItemList = React.createClass({displayName: "ItemList",
  render: function() {
    var el, i;
    return React.createElement("div", {
      "className": 'list-group'
    }, (function() {
      var l, len, ref, results;
      ref = this.props.items;
      results = [];
      for (i = l = 0, len = ref.length; l < len; i = ++l) {
        el = ref[i];
        results.push(React.createElement("a", {
          "href": '#',
          "className": 'list-group-item',
          "key": i,
          "onClick": ((function(_this) {
            return function(e) {
              return function() {
                return _this.props.selectFn(e);
              };
            };
          })(this))(el)
        }, el));
      }
      return results;
    }).call(this));
  }
});

quoteRegex = function(str) {
  return (str + '').replace(/[.?*+^$[\]\\(){}|-]/g, "\\$&");
};

transformInputText = function(text) {
  return quoteRegex(text).split('').join('.*');
};

SearchList = React.createClass({displayName: "SearchList",
  getInitialState: function() {
    return {
      inputText: ''
    };
  },
  clearAndFocusInput: function() {
    var inp;
    inp = React.findDOMNode(this.refs.textInput);
    inp.value = '';
    inp.focus();
    this.setState({
      inputText: ''
    });
    return this.props.fn(null);
  },
  render: function() {
    return React.createElement("div", null, React.createElement("label", {
      "className": "spaced"
    }, this.props.name), React.createElement("div", {
      "className": this.props.classes
    }, React.createElement("div", {
      "className": "input-group"
    }, React.createElement("input", {
      "type": "text",
      "className": "form-control",
      "placeholder": this.props.defaultInput,
      "value": this.state.inputText,
      "ref": "textInput",
      "onChange": ((function(_this) {
        return function() {
          var val;
          val = React.findDOMNode(_this.refs.textInput).value;
          return _this.setState({
            inputText: val
          });
        };
      })(this))
    }), React.createElement("span", {
      "className": "input-group-btn"
    }, React.createElement("button", {
      "className": "btn btn-default",
      "type": "button",
      "onClick": this.clearAndFocusInput
    }, React.createElement("span", {
      "className": "glyphicon glyphicon-remove"
    })))), React.createElement(ItemList, {
      "items": (this.state.inputText ? this.props.items.filter((function(_this) {
        return function(el) {
          return el.match(new RegExp(transformInputText(_this.state.inputText), 'i'));
        };
      })(this)) : this.props.items),
      "selectFn": ((function(_this) {
        return function(selectedElement) {
          _this.setState({
            inputText: selectedElement
          });
          return _this.props.fn(selectedElement);
        };
      })(this))
    })));
  }
});


/* text panel */

LabeledPanel = React.createClass({displayName: "LabeledPanel",
  getInitialState: function() {
    return {
      bodyHeight: null,
      resizeListener: null
    };
  },
  componentDidMount: function() {
    var listen, node;
    node = React.findDOMNode(this.refs.panelBody);
    listen = (function(_this) {
      return function() {
        return _this.setState({
          bodyHeight: node.clientHeight
        });
      };
    })(this);
    this.setState({
      bodyHeight: node.clientHeight,
      resizeListener: listen
    });
    return DetectResize.addResizeListener(node, listen);
  },
  componentWillUnmount: function() {
    var node;
    node = React.findDOMNode(this.refs.panelBody);
    return DetectResize.removeResizeListener(node, this.state.resizeListener);
  },
  render: function() {
    return React.createElement("div", null, React.createElement("label", {
      "className": "spaced"
    }, this.props.labelTitle), React.createElement("div", {
      "className": this.props.outerClasses
    }, React.createElement("div", {
      "className": "panel panel-default"
    }, React.createElement("div", {
      "className": "panel-heading"
    }, this.props.headers), React.createElement("div", {
      "className": "panel-body",
      "ref": "panelBody"
    }, React.Children.map(this.props.children, (function(_this) {
      return function(child) {
        return React.cloneElement(child, {
          parentHeight: _this.state.bodyHeight
        });
      };
    })(this))))));
  }
});

MagicTextHeightPercentage = .105;

TextSection = React.createClass({displayName: "TextSection",
  render: function() {
    return React.createElement("textarea", {
      "className": "form-control",
      "ref": "txtInput",
      "readOnly": this.props.textReadOnly,
      "value": this.props.text,
      "style": (function(_this) {
        return function() {
          var h;
          h = _this.props.parentHeight;
          if (h != null) {
            return {
              height: (h * MagicTextHeightPercentage) + "ex"
            };
          }
        };
      })(this)(),
      "onChange": ((function(_this) {
        return function() {
          if (_this.props.fn) {
            return _this.props.fn(React.findDOMNode(_this.refs.txtInput).value);
          }
        };
      })(this))
    });
  }
});

MagicOutputTextHeightPercentage = .109;

ScrollingDiv = React.createClass({displayName: "ScrollingDiv",
  render: function() {
    var h;
    return React.createElement("div", {
      "className": "output-seq",
      "style": (h = this.props.parentHeight, h != null ? {
        height: (h * MagicOutputTextHeightPercentage) + "ex"
      } : void 0)
    }, this.props.txt);
  }
});

spinCfg = {
  lines: 13,
  length: 28,
  width: 14,
  radius: 42,
  scale: 1,
  corners: 1,
  color: '#000',
  opacity: 0.25,
  rotate: 0,
  direction: 1,
  speed: 1,
  trail: 60,
  fps: 20,
  zIndex: 2e9,
  className: 'spinner',
  top: '50%',
  left: '50%',
  shadow: false,
  hwaccel: false,
  position: 'absolute'
};

createSequenceHighlight = function(oldCodon, newCodon, ind) {
  var i, l, ref, results;
  results = [];
  for (i = l = 0, ref = newCodon.length - 1; l <= ref; i = l += 1) {
    results.push(React.createElement("span", {
      "title": oldCodon + "->" + newCodon,
      "className": "seq-highlight",
      "key": ind + "." + i
    }, newCodon[i]));
  }
  return results;
};

diffSequence = function(oldInput, newInput) {
  var i, j, l, newCodon, oldCodon, ref, results;
  results = [];
  for (i = l = 0, ref = newInput.length; l <= ref; i = l += 3) {
    oldCodon = oldInput.slice(i, +(i + 2) + 1 || 9e9).toUpperCase();
    newCodon = newInput.slice(i, +(i + 2) + 1 || 9e9).toUpperCase();
    results.push(_.flatten((function() {
      var m, ref1, results1;
      if (oldCodon !== newCodon) {
        return createSequenceHighlight(oldCodon, newCodon, i);
      } else {
        results1 = [];
        for (j = m = 0, ref1 = newCodon.length - 1; m <= ref1; j = m += 1) {
          results1.push(React.createElement("span", {
            "className": "seq-no-highlight",
            "key": i + "." + j
          }, newCodon[j]));
        }
        return results1;
      }
    })()));
  }
  return results;
};

OutputTextPanel = React.createClass({displayName: "OutputTextPanel",
  getInitialState: function() {
    return {
      outputText: '',
      spinning: false
    };
  },
  workerFn: function(msg) {
    var err, newSeqObj, oldSeqObj, ref, txt, type;
    ref = msg.data, err = ref.err, txt = ref.txt, oldSeqObj = ref.oldSeqObj, newSeqObj = ref.newSeqObj, type = ref.type;
    if (err) {
      if (txt.message) {
        alert(txt.message);
      }
      this.setState({
        spinning: false,
        outputText: React.createElement("span", null, "ERROR")
      });
      return this.props.clearFn();
    } else {
      this.setState({
        spinning: false,
        outputText: (function() {
          switch (type) {
            case 'DNA':
              return diffSequence(oldSeqObj.seq, newSeqObj.seq);
            case 'Amino':
              return React.createElement("span", {
                "className": "seq-no-highlight"
              }, newSeqObj.seq);
          }
        })()
      });
      return this.props.percentageFn({
        pcntMutable: newSeqObj.score / newSeqObj.seq.length * 100,
        pcntChange: (oldSeqObj.score - newSeqObj.score) / oldSeqObj.score * 100
      });
    }
  },
  componentDidMount: function() {
    return this.props.worker.addEventListener('message', this.workerFn);
  },
  componentWillUnmount: function() {
    return this.props.worker.removeEventListener('message', this.workerFn);
  },
  render: function() {
    var headers;
    headers = [
      React.createElement("p", {
        "key": "1"
      }, this.props.text), React.createElement("button", {
        "key": "2",
        "type": "button",
        "className": "btn btn-danger panel-btn",
        "onClick": ((function(_this) {
          return function() {
            _this.setState({
              spinning: false,
              outputText: ''
            });
            return _this.props.clearFn();
          };
        })(this))
      }, this.props.clearButtonText), React.createElement("button", {
        "key": "3",
        "type": "button",
        "className": "btn btn-success panel-btn",
        "onClick": ((function(_this) {
          return function() {
            _this.setState({
              spinning: true
            });
            return _this.props.worker.postMessage(_this.props.getStateFn());
          };
        })(this))
      }, this.props.goButtonText)
    ];
    return React.createElement(LabeledPanel, {
      "labelTitle": this.props.name,
      "outerClasses": this.props.classes,
      "headers": headers
    }, (this.state.spinning ? React.createElement(Spinner, {
      "config": spinCfg
    }) : React.createElement(ScrollingDiv, {
      "txt": this.state.outputText
    })));
  }
});


/* just a buncha buttons */

ButtonGroupBase = 'btn ';

ButtonSelected = ButtonGroupBase + 'btn-primary';

ButtonNonSelected = ButtonGroupBase + 'btn-default';

makeButtonClass = function(ind1, ind2) {
  if (ind1 === ind2) {
    return ButtonSelected;
  } else {
    return ButtonNonSelected;
  }
};

ButtonArray = React.createClass({displayName: "ButtonArray",
  render: function() {
    var key, val;
    return React.createElement("div", {
      "className": 'btn-group'
    }, (function() {
      var ref, results;
      ref = this.props.texts;
      results = [];
      for (key in ref) {
        val = ref[key];
        results.push(React.createElement("button", {
          "type": 'button',
          "key": key,
          "className": makeButtonClass(this.props.selectedButton, key),
          "onClick": ((function(_this) {
            return function(k) {
              return function() {
                return _this.props.onClickFn(k);
              };
            };
          })(this))(key)
        }, key));
      }
      return results;
    }).call(this));
  }
});

InputTextPanel = React.createClass({displayName: "InputTextPanel",
  render: function() {
    var headers;
    headers = [
      React.createElement("p", {
        "key": "1"
      }, this.props.buttons[this.props.selectedButton]), React.createElement(ButtonArray, {
        "key": "2",
        "texts": this.props.buttons,
        "selectedButton": this.props.selectedButton,
        "onClickFn": this.props.typeFn
      })
    ];
    return React.createElement(LabeledPanel, {
      "labelTitle": this.props.name,
      "outerClasses": this.props.classes,
      "headers": headers
    }, React.createElement(TextSection, {
      "textReadOnly": false,
      "fn": this.props.inputFn
    }));
  }
});


/* option elements */

CheckboxOption = React.createClass({displayName: "CheckboxOption",
  getInitialState: function() {
    return {
      id: gensym()
    };
  },
  onChangeFn: function(ev) {
    return this.props.fn(React.findDOMNode(this.refs.checkInput).checked);
  },
  render: function() {
    return React.createElement("div", {
      "className": "option-switch"
    }, React.createElement("input", {
      "type": "checkbox",
      "onChange": this.onChangeFn,
      "ref": "checkInput",
      "id": this.state.id
    }), React.createElement("label", {
      "htmlFor": this.state.id,
      "className": "checkbox-label"
    }, this.props.heading));
  }
});

CheckboxWithContext = React.createClass({displayName: "CheckboxWithContext",
  render: function() {
    return React.createElement("div", {
      "className": "display-item option-box " + (this.props.classes || "")
    }, React.createElement(CheckboxOption, {
      "fn": this.props.fn,
      "heading": this.props.heading
    }), this.props.children);
  }
});

AdvancedOptions = React.createClass({displayName: "AdvancedOptions",
  render: function() {
    return React.createElement("div", null, React.createElement("label", {
      "className": "spaced"
    }, this.props.labelText), React.createElement("div", {
      "className": "option-pane advanced-options"
    }, this.props.children));
  }
});


/* parameterized options */

OptionsBox = React.createClass({displayName: "OptionsBox",
  render: function() {
    return React.createElement("div", {
      "className": "options-box row " + this.props.newClasses
    }, React.Children.map(this.props.children, (function(_this) {
      return function(child) {
        return React.cloneElement(child, {
          disabled: _this.props.disabled
        });
      };
    })(this)));
  }
});

NumericPlaceholder = "0.0";

makeInputAddon = function(el) {
  if (el != null) {
    return React.createElement("span", {
      "className": "input-group-addon"
    }, el);
  }
};

makeLabel = function(text, disabled) {
  var str;
  str = text;
  return React.createElement("label", {
    "className": "parameter-label"
  }, str);
};

ParameterizedOption = React.createClass({displayName: "ParameterizedOption",
  render: function() {
    var ref, ref1;
    return React.createElement("div", {
      "className": "parameterized-option"
    }, makeLabel(this.props.text, this.props.disabled), React.createElement("div", {
      "className": "input-group input-group-sm"
    }, makeInputAddon((ref = this.props.children) != null ? ref[0] : void 0), React.createElement("input", {
      "type": this.props.inputType || "text",
      "className": "form-control num",
      "placeholder": this.props.initialInput,
      "disabled": this.props.disabled,
      "onChange": ((function(_this) {
        return function(ev) {
          return _this.props.fn(ev.target.value);
        };
      })(this))
    }), makeInputAddon((ref1 = this.props.children) != null ? ref1[1] : void 0)));
  }
});

DisableableItem = React.createClass({displayName: "DisableableItem",
  getInitialState: function() {
    return {
      disabled: false
    };
  },
  onCheckBox: function(checked) {
    this.setState({
      disabled: checked
    });
    return this.props.fn(checked);
  },
  render: function() {
    return React.createElement(AdvancedOptions, {
      "labelText": this.props.labelText
    }, React.createElement(CheckboxWithContext, {
      "heading": this.props.heading,
      "fn": this.onCheckBox
    }, React.Children.map(this.props.children, (function(_this) {
      return function(child) {
        return React.cloneElement(child, {
          disabled: _this.state.disabled
        });
      };
    })(this))));
  }
});

percentRound = function(num) {
  return Math.round(num * 100) / 100;
};

MeterDisplay = React.createClass({displayName: "MeterDisplay",
  render: function() {
    var numDisp, val;
    numDisp = this.props.numDisplay ? percentRound(this.props.numDisplay) : 0;
    if (!isFinite(numDisp)) {
      numDisp = 0;
    }
    val = isFinite(this.props.val) ? this.props.val : 0;
    return React.createElement("div", {
      "className": "meter-container"
    }, React.createElement("label", null, this.props.lbl), React.createElement("meter", {
      "max": this.props.limits.max,
      "low": this.props.limits.low,
      "value": val,
      "optimum": this.props.limits.opt,
      "className": "meter-score"
    }, val, ": ", this.props.lbl), React.createElement("span", {
      "className": "meter-display"
    }, "" + numDisp + (this.props.decorator || '')));
  }
});

MutabilityScoreboard = React.createClass({displayName: "MutabilityScoreboard",
  render: function() {
    return React.createElement(AdvancedOptions, {
      "labelText": this.props.lbl
    }, React.createElement("div", {
      "className": "display-item option-box mut-scoreboard"
    }, React.createElement(MeterDisplay, {
      "lbl": this.props.mutableDisplay.label,
      "limits": this.props.mutableDisplay,
      "val": (this.props.pcntMutable ? 1 / this.props.pcntMutable : void 0),
      "numDisplay": this.props.pcntMutable
    }), React.createElement(MeterDisplay, {
      "lbl": this.props.changeDisplay.label,
      "limits": this.props.changeDisplay,
      "val": this.props.pcntChange,
      "numDisplay": this.props.pcntChange,
      "decorator": "%"
    })));
  }
});

module.exports = {
  ItemList: ItemList,
  SearchList: SearchList,
  TextSection: TextSection,
  ScrollingDiv: ScrollingDiv,
  OutputTextPanel: OutputTextPanel,
  InputTextPanel: InputTextPanel,
  CheckboxOption: CheckboxOption,
  CheckboxWithContext: CheckboxWithContext,
  AdvancedOptions: AdvancedOptions,
  OptionsBox: OptionsBox,
  ParameterizedOption: ParameterizedOption,
  DisableableItem: DisableableItem,
  MutabilityScoreboard: MutabilityScoreboard
};
