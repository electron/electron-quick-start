HTMLWidgets.widget({

  name: 'reactjson',

  type: 'output',

  factory: function(el, width, height) {

    // TODO: define shared variables for this instance

    return {

      renderValue: function(x) {

          // add scroll to widget container for better sizing behavior
          el.style.overflow = "auto";

          ReactDOM.render(
            React.createElement(
              reactJsonView.default,
              {
                src: (typeof(x.data)==="string") ? JSON.parse(x.data) : x.data,
                name: null,
                onAdd: logChange,
                onEdit: logChange,
                onDelete: logChange
              }
            ),
            el
          );

          function logChange( value ){
            if(typeof(Shiny) !== "undefined" && Shiny.onInputChange){
              Shiny.onInputChange(el.id + "_change", {value:value});
            }
          }

      },

      resize: function(width, height) {

        // TODO: code to re-render the widget with a new size

      }

    };
  }
});
