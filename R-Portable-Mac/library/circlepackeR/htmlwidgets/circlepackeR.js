HTMLWidgets.widget({

  name: 'circlepackeR',

  type: 'output',

  initialize: function(el, width, height) {

    return {

    }

  },

  renderValue: function(el, x, instance) {

    console.log(x)
    // remove previous in case of dynamic/Shiny
    d3.select(el).selectAll('*').remove();

    // much of this code is based on this example by Mike Bostock
    //   https://gist.github.com/mbostock/7607535

    var margin = 20,
    // use getBoundingClientRect since width and height
    //  might not be in pixels
    diameter = Math.min(el.getBoundingClientRect().width,
                        el.getBoundingClientRect().height);

    var color = d3.scale.linear()
        .domain([-1, 5])
        .range([x.options.color_min, x.options.color_max])
        .interpolate(d3.interpolateHcl);

    var color_col = null;
    if(x.options.color_col){
      color_col = x.options.color_col;
    }

    var quartileColorCodes = ["rgb(241,238,246,0.3)", "rgb(215,181,216,0.5)", "rgb(221,28,119,0.7)", "rgb(152,0,20,1)"];
    if(x.options.quartile_colors && x.options.quartile_colors.length == 4){
      //an array of three colors
      quartileColorCodes = x.options.quartile_colors;
    } else if(x.options.quartile_colors && x.options.quartile_colors.length != 4){
      throw new Error("quartile_colors must be of length 4");
    }

    var quartileColorValues = [0.25, 0.50, 0.75];
    if(x.options.quartile_values){
      //a named numeric list of values for cut offs 25%, 50%, 75%
      quartileColorValues = [x.options.quartile_values["25%"], x.options.quartile_values["50%"], x.options.quartile_values["75%"]];
    }

    // Define the div for the tooltip
    var tooltip = d3.select("body").append("div")
        .attr("class", "tooltip")
        .style("opacity", 0);

    var pack = d3.layout.pack()
        .padding(2)
        .size([diameter - margin, diameter - margin])
        .value(function(d) { return d[x.options.size]; });

    var svg = d3.select(el).append("svg")
        .attr("width", diameter)
        .attr("height", diameter)
      .append("g")
        .attr("transform", "translate(" + diameter / 2 + "," + diameter / 2 + ")");

    function createViz(root) {
      var focus = root,
          nodes = pack.nodes(root),
          view;

      var circle = svg.selectAll("circle")
          .data(nodes)
        .enter().append("circle")
          .attr("class", function(d) { return d.parent ? d.children ? "node" : "node node--leaf" : "node node--root"; })
          .style("fill", function(d) {
            if(color_col){
              let v = parseFloat(d[color_col]);
              if(isNaN(v) || v <= quartileColorValues[0]){
                 return quartileColorCodes[0];
              }else if(v > quartileColorValues[0] && v <= quartileColorValues[1]){
                return quartileColorCodes[1];
              }else if(v > quartileColorValues[1] && v <= quartileColorValues[2]){
                return quartileColorCodes[2];
              }
              return quartileColorCodes[3];
            } else {
              return d.children ? color(d.depth) : null;
            }

          })
          .on("click", function(d) { if (focus !== d) zoom(d), d3.event.stopPropagation(); })
          .on("mouseover", function(d) {
            tooltip.transition()
                .duration(200)
                .style("opacity", 0.9);
            let str = "";
            for(let prop in d){
                //show all properties except for parent object and chidlren objects
                if(prop != "parent" && prop != "children"){
                  str += prop+"&nbsp;"+(d[prop] + "</br>");
                }
            }
            tooltip.html(str)
              .style("left", (d3.event.pageX + 28) + "px")
              .style("top", (d3.event.pageY - 28) + "px");
          })
          .on("mouseout", function(d) {
            tooltip.transition()
                .duration(500)
                .style("opacity", 0);

          });
      var text = svg.selectAll("text")
          .data(nodes)
        .enter().append("text")
          .attr("class", "label")
          .style("fill-opacity", function(d) { return d.parent === root ? 1 : 0; })
          .style("display", function(d) { return d.parent === root ? null : "none"; })
          .text(function(d) { return d.name; });

      var node = svg.selectAll("circle,text");

      d3.select(el)
          .on("click", function() { zoom(root); });

      zoomTo([root.x, root.y, root.r * 2 + margin]);

      function zoom(d) {
        var focus0 = focus; focus = d;

        var transition = d3.transition()
            .duration(d3.event.altKey ? 7500 : 750)
            .tween("zoom", function(d) {
              var i = d3.interpolateZoom(view, [focus.x, focus.y, focus.r * 2 + margin]);
              return function(t) { zoomTo(i(t)); };
            });

        transition.selectAll("text")
          .filter(function(d) { return d.parent === focus || this.style.display === "inline"; })
            .style("fill-opacity", function(d) { return d.parent === focus ? 1 : 0; })
            .each("start", function(d) { if (d.parent === focus) this.style.display = "inline"; })
            .each("end", function(d) { if (d.parent !== focus) this.style.display = "none"; });
      }

      function zoomTo(v) {
        var k = diameter / v[2]; view = v;
        node.attr("transform", function(d) { return "translate(" + (d.x - v[0]) * k + "," + (d.y - v[1]) * k + ")"; });
        circle.attr("r", function(d) { return d.r * k; });
      }
    }

    createViz(x.data)

    d3.select(self.frameElement).style("height", diameter + "px");

  },

  resize: function(el, width, height, instance) {

  }

});
