# John Verzani's gWidgets example found here:
# http://wiener.math.csi.cuny.edu/pmg/gWidgets/Examples/ProtoExample-II-ex.html

options("guiToolkit" = "RGtk2")
library(proto)
library(gWidgets)

BasicGUI = proto(
  new = function(., message = "Basic GUI", ...) {
    ## pre proto-0.4-0
    #    .$proto(message=message,
    #            props=list(),widgetList=list(), widgets = list(),...)
    .$proto(message = message,...)
  },
  Show = function(.) {
    if (is.null(.$window))
      .$window <- gwindow(.$message)
    g = ggroup(horizontal = FALSE, cont = .$window)
    .$makeBody(container = g)
    .$makeButtons(container = g)
  },
  makeBody = function(., container) {
    glabel(.$message, cont = container)
    if (length(.$widgetList) > 0) {
      tbl <- glayout(cont = container)
      ctr = 1;
      for (i in names(.$widgetList)) {
        tmp = .$widgetList[[i]]
        FUN = tmp[[1]]
        tmp[[1]] <- NULL
        tbl[ctr,1] = i
        tbl[ctr,2] <-
          (.$widgets[[i]] <- do.call(FUN, c(tmp, container = tbl)))
        ctr = ctr + 1
      }
      visible(tbl) <- TRUE
    }
  },
  makeButtons = function(., container) {
    gseparator(cont = container)
    bg = ggroup(cont = container)
    addSpring(bg)
    ## for these we take advantage of the fact that when we call
    ## the handlers this way the "." gets passed in via the first argument
    cancelButton = gbutton(
      "cancel", cont = bg,
      action = list(self = ., super = super()),
      handler = .$cancelButtonHandler
    )
    okButton = gbutton(
      "ok", cont = bg,
      action = list(self = ., super = super()),
      handler = .$okButtonHandler
    )
  },
  ## Notice, the signature includes the initial "."
  okButtonHandler = function(.,h,...) {
    for (i in names(.$widgetList))  {
      ## store vals in props of super
      #      .$.super$props[[i]] <- svalue(.$widgets[[i]]) # pre 0.4-0
      h$action$super$props[[i]] <- svalue(.$widgets[[i]])
    }
    dispose(.$window)
  },
  cancelButtonHandler = function(.,h,...) {
    dispose(.$window)
    ## others?
  },
  window = NULL,                      # top-level gwindow
  message = "Basic widget",
  props = list(),                     # for storing properties of widgets
  widgetList =  list(),
  widgets = list()
)


BGTest = BasicGUI$new(
  message = "Basic Widget Test",
  widgetList = list(
    edit = list(type = "gedit",text = "starting text"),
    droplist = list(type = "gdroplist", items = letters),
    slider = list(type = "gslider", value = 10),
    radio = list(
      type = "gradio", items = 1:3, horizontal = FALSE
    )
  )
)
## override handler so we don't set values in parent
BGTest$okButtonHandler = function(.,handler,...) {
  print(sapply(.$widgets,svalue)) ## or whatever else
  dispose(.$window)
}
BGTest$Show()  ## show the widget

Parent = BasicGUI$new(message = "Just a parent, not shown")
MainChild = Parent$new(
  message = "Plot a histogram",
  makeBody = function(., container) {
    glabel("Plot a histogram of a variable", cont = container)
    g1 = ggroup(cont = container)
    tbl = glayout(cont = g1)
    tbl[1,1] = "numeric vector:"
    tbl[1,2] <- (.$widgets[[1]] = gedit("", cont = tbl))
    ## others
    visible(tbl) <- TRUE                # RGtk2
    ## more button to create child
    moreButton = gbutton(
      "Labels",cont = g1,
      #      action = .$.super,                       # pass in super
      action = list(self = .,super = parent.env(.)),        # pass in super
      handler = function(h,...) {
        ## make a child of the Parent. This uses
        ## the plain BasicGUI style where we specify a
        ## widget list to produce the GUI.
        child <-
          h$action$super$proto(
            window = gwindow("Adjust plot labels"),
            message = "Plot labels",
            widgetList = list(
              "main" = list(type = "gedit",
                text = "main title"),
              "xlab" = list(type = "gedit",
                text = "xlab")
            )
          )
        child$Show()
        ##  Could add other buttons here for other variables.
      }
    )
  },
  ## Override the default ok button  handler. In this case to
  ## gather arguments and then plot the histogram.
  okButtonHandler = function(.,h,...) {
    lst = list(x = svalue(svalue(.$widgets[[1]]))) ## get values from var name
    #  lst = c(lst, .$.super$props)
    lst = c(lst, h$action$super$props)
    do.call("hist",lst)
    dispose(.$window)
  }

)

## add defaults
Parent$props$main = "Main title"
Parent$props$xlab = "xlab"


## Now show the parent
MainChild$Show()
