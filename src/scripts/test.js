var NeatComponent, React;

React = require('react');

NeatComponent = React.createClass({displayName: "NeatComponent",
  render: function() {
    var n;
    return React.createElement("div", {
      "className": "neat-component"
    }, (this.props.showTitle ? React.createElement("h1", null, "A Component is I") : void 0), React.createElement("hr", null), (function() {
      var i, results;
      results = [];
      for (n = i = 1; i <= 5; n = ++i) {
        results.push(React.createElement("p", {
          "key": n
        }, "This line has been printed ", n, " times"));
      }
      return results;
    })());
  }
});

React.render(React.createElement(NeatComponent, {
  "showTitle": "true"
}), document.getElementById('root'));
