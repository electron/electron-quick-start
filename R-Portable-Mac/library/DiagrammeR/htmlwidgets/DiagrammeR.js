HTMLWidgets.widget({

  name: 'DiagrammeR',

  type: 'output',

  initialize: function(el, width, height) {
    
    /* wait to initialize until renderValue
        since x not provided until then
        and mermaid will try to build the diagram
        as soon as class of the div is set to "mermaid"
    */
    
    /* to prevent auto init() by mermaid
        not documented but
        see lines https://github.com/knsv/mermaid/blob/master/src/main.js#L100-L109
          mermaid_config in global with mermaid_config.startOnLoad = false
        appears to turn off the auto init behavior
        allowing us to callback after manually init and then callback
        after complete
    */
    window.mermaid.startOnLoad = false;
    
    // set config options for Gantt
    //   undocumented but these can be provided
    //   so from R
    //   m1 <- mermaid(spec)
    //   m1$x$config = list(ganttConfig = list( barHeight = 100 ) )
    mermaid.ganttConfig = {
        titleTopMargin:25,
        barHeight:20,
        barGap:4,
        topPadding:50,
        sidePadding:100,
        gridLineStartPadding:35,
        fontSize:11,
        numberSectionStyles:4,
        axisFormatter: [
            // Within a day
            ["%I:%M", function (d) {
                return d.getHours();
            }],
            // Monday a week
            ["w. %U", function (d) {
                return d.getDay() == 1;
            }],
            // Day within a week (not monday)
            ["%a %d", function (d) {
                return d.getDay() && d.getDate() != 1;
            }],
            // within a month
            ["%b %d", function (d) {
                return d.getDate() != 1;
            }],
            // Month
            ["%m-%y", function (d) {
                return d.getMonth();
            }]
        ]
    };

    return {
      // TODO: add instance fields as required
    }

  },

  renderValue: function(el, x, instance) {
    
    // if no diagram provided then assume
    // that the diagrams are provided through htmltools tags
    // and DiagrammeR was just used for dependencies 
    if ( x.diagram != "" ) {
      el.innerHTML = x.diagram;
      //if dynamic such as shiny remove data-processed
      // so mermaid will reprocess and redraw
      el.removeAttribute("data-processed");
      el.classList.add('mermaid');
      //make sure if shiny that we turn display back on
      el.style.display = "";
      //again if dynamic such as shiny
      //  explicitly run mermaid.init()
    } else {
      // set display to none
      // should we remove instead??
      el.style.display = "none";
    }
    
    // check for undocumented ganttConfig
    //   to override the defaults manually entered
    //   in initialize above
    //   note this is really sloppy and will not
    //   work well if multiple gantt charts
    //   with custom configs here
    if( typeof x.config !== "undefined" && 
         typeof x.config.ganttConfig !== "undefined" ){
      Object.keys(x.config.ganttConfig).map(function(k){
        window.mermaid.ganttConfig[k] = x.config.ganttConfig[k];
      })
    }
    
    
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


    // get all DiagrammeR mermaids widgets
    dg = document.getElementsByClassName("DiagrammeR");
    // run mermaid.init
    //  but use try catch block
    //  to send error to the htmlwidget for display
    try{
      mermaid.init( el );
      
      // sort of make our diagram responsive
      //   should we make this an option?
      //   if so, then could easily add to list of post process tasks
      makeResponsive( el );
      
      /*
      // change the id of our SVG assigned by mermaid to prevent conflict
      //   mermaid.init has a counter that will reset to 0
      //   and cause duplication of SVG id if multiple
      d3.select(el).select("svg")
        .attr("id", "mermaidChart-" + el.id);
      // now we have to change the styling assigned by mermaid
      //   to point to our new id that we have assigned
      //   will add if since sequence diagrams do not have stylesheet
      if(d3.select(el).select("svg").select("style")[0][0]){
        d3.select(el).select("svg").select("style")[0][0].innerHTML = d3.select(el).select("svg")
          .select("style")[0][0].innerHTML
      */ 
      /// sep comment for / in regex    .replace(/mermaidChart[0-9]*/gi, "mermaidChart-" + el.id);
      /*}
      */
        
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

    } catch(e) {
      // if error look for last processed DiagrammeR
      //  and send error to the container div
      //  with pre containing the errors
      var processedDg = d3.selectAll(".DiagrammeR[data-processed=true]");
      // select the last
      processedDg = d3.select(processedDg[0][processedDg[0].length - 1])
      // remove the svg
      processedDg.select("svg").remove();
      
      //if dynamic such as shiny remove data-processed
      // so mermaid will reprocess and redraw
      if (HTMLWidgets.shinyMode) {
        el.removeAttribute("data-processed")
      }
      
      processedDg.append("pre").html( ["parse error with " + x.diagram, e.message].join("\n") )
    }

  },

  resize: function(el, width, height, instance) {

  }
  

});
