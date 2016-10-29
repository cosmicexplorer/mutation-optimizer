var MutationOptimizerApp, React, S, UI, appStateValid, stringToColor, worker;

React = require('react');

S = require('./strings');

UI = require('./components');

worker = null;

if (typeof Worker === void 0) {
  alert("This page uses Web Workers, a feature your browser does not support. To use this application, please upgrade your web browser.");
} else {
  worker = new Worker('scripts/optimize-worker-out.js');
}

appStateValid = function(state) {
  var inputs, k, opt, ref, typeValid, val;
  inputs = (function() {
    var results;
    results = [];
    for (k in S.InputButtonTitlesDirections) {
      results.push(k);
    }
    return results;
  })();
  typeValid = inputs.some(function(k) {
    return k === state.inputType;
  });
  if (!typeValid) {
    return "sequence type invalid";
  }
  if (!state.isDefaultChecked) {
    ref = state.parameterizedOptions;
    for (opt in ref) {
      val = ref[opt];
      if (isNaN(parseFloat(val))) {
        return opt + " argument cannot be parsed as a number";
      }
    }
  }
  return null;
};

stringToColor = function(str) {
  var a, color, hash, i, j, l, len, ref;
  hash = 0;
  ref = str.split('');
  for (j = 0, len = ref.length; j < len; j++) {
    a = ref[j];
    hash = a.charCodeAt(0) + ((hash << 7) - hash);
  }
  color = '#';
  for (i = l = 0; l <= 2; i = ++l) {
    color += ('00' + ((hash << i * 3) & 0xFF).toString(16)).slice(-2);
  }
  return color;
};

MutationOptimizerApp = React.createClass({displayName: "MutationOptimizerApp",
  getInitialState: function() {
    return {
      selectedElement: null,
      inputText: '',
      inputType: S.InitialButtonTitle,
      advancedOptions: (function() {
        var k, res, v;
        res = JSON.parse(JSON.stringify(S.AdvancedOptions));
        for (k in res) {
          v = res[k];
          res[k] = false;
        }
        return res;
      })(),
      parameterizedOptions: (function() {
        var k, res, v;
        res = JSON.parse(JSON.stringify(S.ParameterizedOptions));
        for (k in res) {
          v = res[k];
          res[k] = parseFloat(v);
        }
        return res;
      })(),
      isDefaultChecked: false,
      pcntMutable: null,
      pcntChange: null
    };
  },
  render: function() {
    var k, key, optsList, v, val;
    return React.createElement("div", null, React.createElement("nav", {
      "className": "navbar navbar-default navbar-static-top"
    }, React.createElement("div", {
      "className": "container-fluid"
    }, React.createElement("div", {
      "className": "navbar-header"
    }, React.createElement("a", {
      "className": "navbar-brand",
      "href": "#",
      "target": "_blank"
    }, S.VersionName), (function() {
      var ref, results;
      ref = S.NavbarButtons;
      results = [];
      for (key in ref) {
        val = ref[key];
        results.push(React.createElement("a", {
          "href": val,
          "target": "_blank",
          "key": key
        }, React.createElement("button", {
          "type": "button",
          "className": "btn btn-default navbar-btn"
        }, key)));
      }
      return results;
    })()), React.createElement("p", {
      "id": "speciesSelected",
      "style": (this.state.selectedElement ? {
        color: stringToColor(this.state.selectedElement)
      } : {
        color: S.DefaultSpeciesColor
      }),
      "className": "navbar-text species-selected navbar-right"
    }, this.state.selectedElement || S.DefaultSpeciesText))), React.createElement("div", {
      "className": "container-fluid"
    }, React.createElement("div", {
      "className": "row"
    }, React.createElement("div", {
      "className": "col-md-2"
    }, React.createElement(UI.SearchList, {
      "classes": "display-item tall-object listing",
      "name": S.SearchPanelHeading,
      "defaultInput": S.SearchPanelDefault,
      "items": S.SpeciesToSearch,
      "fn": ((function(_this) {
        return function(obj) {
          _this.setState({
            selectedElement: obj
          });
          return alert(S.NoSpeciesText);
        };
      })(this))
    })), React.createElement("div", {
      "className": "col-md-5"
    }, React.createElement(UI.InputTextPanel, {
      "name": S.InputPanelHeading,
      "classes": "display-item tall-object",
      "typeFn": ((function(_this) {
        return function(val) {
          return _this.setState({
            inputType: val
          });
        };
      })(this)),
      "inputFn": ((function(_this) {
        return function(val) {
          return _this.setState({
            inputText: val.toUpperCase().replace(/\s/g, "")
          });
        };
      })(this)),
      "buttons": S.InputButtonTitlesDirections,
      "selectedButton": this.state.inputType
    })), React.createElement("div", {
      "className": "col-md-5"
    }, React.createElement(UI.OutputTextPanel, {
      "text": S.OutputDirections,
      "name": S.OutputPanelHeading,
      "classes": "display-item tall-object",
      "goButtonText": S.OutputButtonText,
      "clearButtonText": S.ClearButtonText,
      "worker": worker,
      "getStateFn": ((function(_this) {
        return function() {
          var res;
          res = appStateValid(_this.state);
          if (res) {
            alert(JSON.stringify(res));
            return {
              invalidState: true
            };
          } else {
            return _this.state;
          }
        };
      })(this)),
      "percentageFn": ((function(_this) {
        return function(arg) {
          return _this.setState(arg);
        };
      })(this)),
      "clearFn": ((function(_this) {
        return function() {
          return _this.setState({
            pcntMutable: null,
            pcntChange: null
          });
        };
      })(this))
    }))), React.createElement("div", {
      "className": "row"
    }, React.createElement("div", {
      "className": "col-md-2 more-padding"
    }, React.createElement(UI.AdvancedOptions, {
      "labelText": S.AdvancedOptionsHeading
    }, ((function() {
      var ref, results;
      ref = this.state.advancedOptions;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push([k, v]);
      }
      return results;
    }).call(this)).map((function(_this) {
      return function(arg1) {
        var key, val;
        key = arg1[0], val = arg1[1];
        return React.createElement(UI.CheckboxWithContext, {
          "key": key,
          "heading": key,
          "fn": (function(key) {
            return function(checked) {
              var newOptions;
              newOptions = _this.state.advancedOptions;
              newOptions[key] = checked;
              return _this.setState({
                advancedOptions: newOptions
              });
            };
          })(key)
        }, React.createElement("p", {
          "className": "explanation-text"
        }, S.AdvancedOptions[key]));
      };
    })(this)))), React.createElement("div", {
      "className": "col-md-8"
    }, React.createElement(UI.DisableableItem, {
      "heading": S.DefaultParamLabel,
      "fn": ((function(_this) {
        return function(checked) {
          return _this.setState({
            isDefaultChecked: checked
          });
        };
      })(this)),
      "labelText": S.ParameterOptionsHeading
    }, React.createElement(UI.OptionsBox, {
      "newClasses": "params-holder"
    }, (optsList = (function() {
      var ref, results;
      ref = this.state.parameterizedOptions;
      results = [];
      for (k in ref) {
        v = ref[k];
        results.push([k, v]);
      }
      return results;
    }).call(this), optsList.map((function(_this) {
      return function(arg1) {
        var key, val;
        key = arg1[0], val = arg1[1];
        return React.createElement(UI.ParameterizedOption, {
          "key": key,
          "text": key,
          "fn": (function(e) {
            return function(value) {
              var newOptions;
              newOptions = _this.state.parameterizedOptions;
              newOptions[e] = value;
              return _this.setState({
                parameterizedOptions: newOptions
              });
            };
          })(key),
          "initialInput": val,
          "isDisabled": false
        });
      };
    })(this)))))), React.createElement("div", {
      "className": "col-md-2"
    }, React.createElement(UI.MutabilityScoreboard, {
      "lbl": S.MutabilityScoreboardLabel,
      "pcntMutable": this.state.pcntMutable,
      "pcntChange": this.state.pcntChange,
      "mutableDisplay": S.MutabilityLabel,
      "changeDisplay": S.ChangeLabel
    })))));
  }
});

React.render(React.createElement(MutationOptimizerApp, null), document.getElementById('root'));
