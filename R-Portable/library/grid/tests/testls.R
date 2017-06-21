library(grid)

# Test hole in DL (deleted grob)
grid.lines(name="foo")
grid.lines(x=1:0, name="foo2")
grid.ls()
grid.remove("foo")
grid.ls()
# New blank page
grid.newpage()


#######
# GROBS
#######
# Plain grob
grid.ls(grob(name="g1"))
# gList
grid.ls(gList(grob(name="gl1"), grob(name="gl2")))
# gTree
grid.ls(gTree(children=gList(grob(name="child")),
              name="parent"))
grid.ls(gTree(children=gList(grob(name="child1"), grob(name="child1")),
              name="parent"))

###########
# VIEWPORTS
###########
# Plain viewport
grid.ls(viewport(name="vp1"),
        view=TRUE)
# vpList
grid.ls(vpList(viewport(name="vpl1")),
        view=TRUE)
grid.ls(vpList(viewport(name="vpl1"), viewport(name="vpl2")),
        view=TRUE)
grid.ls(vpList(viewport(name="vpl1"), viewport(name="vpl2"),
               viewport(name="vpl3")),
        view=TRUE)
# vpStack
grid.ls(vpStack(viewport(name="vps1"), viewport(name="vps2")),
        view=TRUE)
grid.ls(vpStack(viewport(name="vps1"), viewport(name="vps2"),
                viewport(name="vps3")),
        view=TRUE)
# vpTrees
grid.ls(vpTree(viewport(name="parentvp"), vpList(viewport(name="childvp"))),
        view=TRUE)
grid.ls(vpTree(viewport(name="parentvp"),
               vpList(viewport(name="cvp1"), viewport(name="cvp2"))),
        view=TRUE)
# vpPaths
grid.ls(vpPath("A"),
        view=TRUE)
grid.ls(vpPath("A", "B"),
        view=TRUE)
grid.ls(vpPath("A", "B", "C"),
        view=TRUE)

##########
# MIXTURES
##########
# grob with vp viewport
g1 <- grob(vp=viewport(name="gvp"), name="g1")
grid.ls(g1, view=TRUE, full=TRUE)
grid.ls(g1, view=TRUE, full=TRUE, grob=FALSE)
# grob with vp vpList
grid.ls(grob(vp=vpList(viewport(name="vpl")), name="g1"),
        view=TRUE, full=TRUE)
grid.ls(grob(vp=vpList(viewport(name="vpl1"), viewport(name="vpl2")),
             name="g1"),
        view=TRUE, full=TRUE)
# grob with vp vpStack
grid.ls(grob(vp=vpStack(viewport(name="vps1"), viewport(name="vps2")),
             name="g1"),
        view=TRUE, full=TRUE)
grid.ls(grob(vp=vpStack(viewport(name="vps1"), viewport(name="vps2"),
               viewport(name="vps3")),
             name="g1"),
        view=TRUE)
# grob with vp vpTree
grid.ls(grob(vp=vpTree(viewport(name="parentvp"),
               vpList(viewport(name="cvp"))),
             name="g1"),
        view=TRUE, full=TRUE)
grid.ls(grob(vp=vpTree(viewport(name="parentvp"),
               vpList(viewport(name="cvp1"), viewport(name="cvp2"))),
             name="g1"),
        view=TRUE, full=TRUE)
# gTree with vp viewport
# and child grob with vp viewport
grid.ls(gTree(children=gList(grob(vp=viewport(name="childvp"), name="cg1"),
                grob(name="cg2")),
              name="parent",
              vp=viewport(name="parentvp")),
        view=TRUE)
# gTree with childrenvp viewport
grid.ls(gTree(childrenvp=viewport(name="vp"), name="gtree"),
        view=TRUE, full=TRUE)
grid.ls(gTree(childrenvp=viewport(name="vp"), name="gtree"),
        view=TRUE, full=TRUE, grob=FALSE)
grid.ls(gTree(children=gList(grob(name="child")),
              name="parent",
              childrenvp=viewport(name="vp")),
        view=TRUE, full=TRUE)
grid.ls(gTree(children=gList(grob(name="child1"), grob(name="child2")),
              name="parent",
              childrenvp=viewport(name="vp")),
        view=TRUE, full=TRUE)
grid.ls(gTree(children=gList(grob(name="child")),
              childrenvp=viewport(name="vp"),
              name="parent"), 
        view=TRUE, full=TRUE)
grid.ls(gTree(children=gList(grob(name="child1"), grob(name="child2")),
              name="parent",
              childrenvp=viewport(name="vp")),
        view=TRUE, full=TRUE, grob=FALSE)
# gTree with childrenvp vpTree
grid.ls(gTree(childrenvp=vpTree(parent=viewport(name="vp1"),
                children=vpList(viewport(name="vp2"))),
              name="gtree"),
        view=TRUE, full=TRUE)
grid.ls(gTree(children=gList(grob(name="child")),
              name="parent",
              childrenvp=vpTree(parent=viewport(name="vp1"),
                children=vpList(viewport(name="vp2")))),
        view=TRUE, full=TRUE)
# gTree with childrenvp vpTree
# and child grob with vp vpPath
# A gTree, called "parent", with childrenvp vpTree (vp2 within vp1)
# and child grob, called "child", with vp vpPath (down to vp2)
sampleGTree <- gTree(name="parent",
                     children=gList(grob(name="child", vp="vp1::vp2")),
                     childrenvp=vpTree(parent=viewport(name="vp1"),
                                       children=vpList(viewport(name="vp2"))))
grid.ls(sampleGTree)
# Show viewports too
grid.ls(sampleGTree, view=TRUE)
# Only show viewports
grid.ls(sampleGTree, view=TRUE, grob=FALSE)
# Alternate displays
# nested listing, custom indent
grid.ls(sampleGTree, view=TRUE, print=nestedListing, gindent="--")
# path listing
grid.ls(sampleGTree, view=TRUE, print=pathListing)
# path listing, without grobs aligned
grid.ls(sampleGTree, view=TRUE, print=pathListing, gAlign=FALSE)
# grob path listing 
grid.ls(sampleGTree, view=TRUE, print=grobPathListing)
# path listing, grobs only
grid.ls(sampleGTree, print=pathListing)
# path listing, viewports only
grid.ls(sampleGTree, view=TRUE, grob=FALSE, print=pathListing)
# raw flat listing
str(grid.ls(sampleGTree, view=TRUE, print=FALSE))



