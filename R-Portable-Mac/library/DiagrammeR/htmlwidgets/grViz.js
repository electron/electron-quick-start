HTMLWidgets.widget({

  name: 'grViz',

  type: 'output',

  initialize: function(el, width, height) {
        
    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    // use this to sort of make our diagram responsive
    //  or at a minimum fit within the bounds set by htmlwidgets
    //  for the parent container
    function makeResponsive(el){
       var svg = el.getElementsByTagName("svg")[0];
       if(svg){
        if(svg.width) {svg.removeAttribute("width")};
        if(svg.height) {svg.removeAttribute("height")};
        svg.style.width = "100%";
        svg.style.height = "100%";
       }
    };
    
    if ( x.diagram != "" ) {
      
      if ( typeof x.config === "undefined" ){
        x.config = {};
        x.config.engine = "dot";
        x.config.options = {};
      }
      
      try {
        el.innerHTML = Viz( x.diagram, format="svg", engine=x.config.engine, options=x.config.options );
        
        makeResponsive(el);
        
        // set up a container for tasks to perform after completion
        //  one example would be add callbacks for event handling
        //  styling
        if (!(typeof x.tasks === "undefined") ){
          if ( (typeof x.tasks.length === "undefined") ||
           (typeof x.tasks === "function" ) ) {
             // handle a function not enclosed in array
             // should be able to remove once using jsonlite
             x.tasks = [x.tasks];
          }
          x.tasks.map(function(t){
            // for each tasks add it to the mermaid.tasks with el
            t.call(el);
          })
        }        
      } catch(e){
        var p = document.createElement("pre")
        p.innerText = e;
        el.appendChild(p);
      }
    }
    
  },

  resize: function(el, width, height, instance) {
    
  }
  

});
