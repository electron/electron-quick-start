
# igraph 1.2.1

- The GLPK library is optional, if it is not available, then the
  `cluster_optimal()` function does not work. Unfortunately we cannot
  bundle the GLPK library into igraph on CRAN any more, because CRAN
  maintainers forbid the pragmas in its source code.
- Removed the NMF package dependency, and related functions.
- Fix compilation without libxml2

# igraph 1.1.2

Jul 20, 2017

- Fix compilation on Solaris


# igraph 1.1.1

Jul 13, 2017

- Graph id is printed in the header, and a `graph_id` function was added
- Fix `edge_attr` for some index values
- Fix a `bfs()` bug, `restricted` argument was zero-based
- `match_vertices` is exported now
- `%>%` is re-exported in a better way, to avoid interference with other
  packages
- `ego_` functions default to `order = 1` now
- New function `igraph_with_opt` to run code with temporary igraph 
  options settings
- Fix broken `sample_asym_pref` function
- Fix `curve_multiple` to avoid warnings for graphs with self-loops.
- The `NMF` package is only suggested now, it is not a hard 
  dependency
- Fix gen_uid.c _SVID_SOURCE issues
- Avoid drawing straight lines as Bezier curves
- Use the `pkgconfig` package for options. This allows setting options
  on a per-package basis. E.g. a package using igraph can set `return.vs.es`
  to `FALSE` in its `.onLoad()` function, and then igraph will return
  plain numeric vectors instead of vertex/edge sequences
  *if called from this package*.
- `igraph_options()` returns the *old* values of the updated options,
  this is actually useful, returning the new values was not.
- `with_igraph_opt()` function to temporarily change values of
  igraph options.
- `get.edge()` is deprecated, use `ends()` instead. (This was already the case
  for igraph 1.0.0, but we forgot to add a NEWS point for it.)
- Do not redefine `.Call()`, to make native calls faster.
- Speed up special cases of indexing vertex sequences.
- Removed an `anyNA()` call, to be compatible with older R versions.
- Fixed a fast-greedy community finding bug,
  https://github.com/igraph/igraph/issues/836
- Fixed `head_of()` and `tail_of()`, they were mixed up.
- Plot: make `label.dist` independent of label lengths, fixes #63.
- Plot: no error for unknown graphical parameters.
- Import functions from base packages, to eliminate
  `R CMD check` `NOTE`s.
- Readd support for edge weights in Fruchterman-Reingold layout
- Check membershiph vector in `modularity()`.
- Rename `str.igraph()` to `print_all()`.
- Use the igraph version in exported graphs, instread of @VERSION@ #75.
- Functions that can be used inside a `V()` or `E()` indexing
  now begin with a dot. Old names are deprecated.
  New names: `.nei()`, `.innei()`, `.outnei()`, `.inc()`, `.from()`,
  `.to()`. #22
- Fix packages that convert graphs to graph::graphNEL: they
  don't need to attach 'graph' manually any more.
- Fix a bugs in `layout_with_dh`, `layout_with_gem` and
  `layout_with_sugiyama`. They crashed in some cases.

# igraph 1.0.1

June 26, 2015

Some minor updates:

- Documentation fixes.
- Do not require a C++-11 compiler any more.
- Fedora, Solaris and Windows compilation fixes.

# igraph 1.0.0

June 21, 2015

## Release notes

This is a new major version of igraph, and then why not call
it 1.0.0. This does not mean that it is ready, it'll never be
ready.

The biggest changes in the release are
- the new function names. Most functions were renamed to
  make them more consistent and readable. (Relax, old names
  can still be used, no need to update any code.)
- Better operations for vertex and edge sequences. Most functions
  return proper vertex/edge sequences instead of numeric ids.
- The versatile `make_()` and `make_graph()` functions to
  create graphs.

## Major changes

- Many functions were renamed. Old names are not documented,
  but can still be used.
- A generic `make_graph()` function to create graphs.
- A generic `layout_()` (not the underscore!) function
  to create graph layouts, see also `add_layout_()`.
- The igraph data type has changed. You need to call
  `upgrade_graph()` on graphs created with previous igraph
  versions.
- Vertex and edge sequence operations: union, intersection, etc.
- Vertex and edge sequences can only be used with the graphs they
  belong to. This is now strictly checked.
- Most functions that return a (sub)set of vertices
  or edges return vertex or edge sequences instead.
- Vertex and edge sequences have a `[[` operator now,
  for easy viewing of vertex/edge metadata.
- Vertex and edge sequences are implemented as weak references.
  See also the `as_ids()` function to convert them to simple ids.
- Vertex order can be specified for the circle layout now.
- Davidson-Harel layout algorithm `layout_with_dh()`.
- GEM layout algorithm `layout_with_gem()`.
- Neighborhood functions have a `mindist` parameter for the
  smallest distance to consider.
- `all_simple_paths()` function to list all simple paths in a graph.
- `triangles()` lists all triangles in a graph.
- Fruchterman-Reingold and Kamada-Kawai layout algorithms
  rewritten from scratch. They are much faster and follow the
  original publications closely.
- Nicer printing of graphs, vertex and edge sequences.
- `local_scan()` function calculates scan statistics.
- Embeddings: `embed_adjacency_matrix()` and `embed_laplacian_matrix()`.
- Product operator: `*`, the same graph multiple times. Can be also
  used as `rep()`.
- Better default colors, color palettes for vertices.
- Random walk on a graph: `random_walk()`
- `adjacenct_vertices()` and `incident_edges()` functions,
  they are vectorized, as opposed to `neighhors()` and `incident()`.
- Convert a graph to a _long_ data frame with `as_long_data_frame()`.

## Bug fixes

Too many to list. Please try if your issue was fixed and (re-)report
it if not. Thanks!

# igraph 0.7.1

April 21, 2014

## Release Notes

Some bug fixes, to make sure that the code included in
'Statistical Analysis of Network Data with R' works. See
https://github.com/kolaczyk/sand

## Detailed changes:

- Graph drawing: fix labels of curved edges, issue #181.
- Graph drawing: allow fixing edge labels at given positions,
  issue #181.
- Drop the 'type' vertex attribute after bipartite projection,
  the projections are not bipartite any more, issue #255.
- Print logical attributes in header properly (i.e. encoded by `l`,
  not `x`,  which is for complex attributes. Issue #578.
- Add a constructor for `communities` objects, see `create.communities()`.
  Issue #547.
- Better error handling in the GraphML parser.
- GraphML reader is a bit more lenient now; makes it possible to read
  GraphML files saved from yWorks apps.
- Fixed a bug in `constaint()`, issue #580.
- Bipartite projection now detects invalid edges instead of giving
  a cryptic error, issue #543.
- Fixed the `simplify` argument of `graph.formula()`, which was
  broken, issue #586.
- The function `crossing()` adds better names to the result,
  fixes issue #587.
- The `sir()` function gives an error if the input graph is
  not simple, fixes issue #582.
- Calling igraph functions from igraph callbacks is not allowed now,
  fixes issue #571.

# igraph 0.7.0

February 4, 2014

## Release Notes

There are a bunch of new features in the library itself, and 
other important changes in the life of the project. Thanks everyone
for sending code and reporting bugs!

### igraph @ github

igraph's development has moved from Launchpad to github. 
This has actually happened several month ago, but never 
announced officially. The place for reporting bugs is 
at https://github.com/igraph/igraph/issues.

### New homepage

igraph's homepage is now hosted at http://igraph.org, and it is 
brand new. We wanted to make it easier to use and modern.

### Better nightly downloads

You can download nightly builds from igraph at 
http://igraph.org/nightly. Source and binary R packages (for windows
and OSX), are all built.

## New features and bug fixes

- Added a demo for hierarchical random graphs, invoke it via
  `demo(hrg)`.
- Make attribute prefixes optional when writing a GraphML file.
- Added function `mod.matrix()`.
- Support edge weights in leading eigenvector community detection.
- Added the LAD library for checking (sub)graph isomorphism, version 1.
- Logical attributes.
- Added `layout.bipartite()` function, a simple two-column layout
  for bipartite graphs.
- Support incidence matrices in bipartite Pajek files.
- Pajek files in matrix format are now directed by default, unless they
  are bipartite.
- Support weighted (and signed) networks in Pajek when file is in
  matrix format.
- Fixed a bug in `barabasi.game()`, algorithm psumtree-multiple 
  just froze.
- Function `layout.mds()` by default returns a layout matrix now.
- Added support for Boolean attributes in the GraphML and GML readers
  and writer.
- Change MDS layout coordinates, first dim is according to first
  eigenvalue, etc.
- `plot.communities()` (`plot.igraph()`, really) draws a border
  around the marked groups by default.
- printing graphs now converts the `name` graph attribute to character
- Convenience functions to query and set all attributes at once:
  `vertex.attriubutes()`, `graph.attributes()` and `edge.attributes()`.
- Function `graph.disjoint.union()` handles attributes now.
- Rewrite `graph.union()` to handle attributes properly.
- `rewire()`: now supports the generation and destruction of loops.
- Erdos-Renyi type bipartite random graphs: `bipartite.random.game()`.
- Support the new options (predecessors and inbound_edges) of
  `get_shortest_paths()`, reorganized the output of
  `get.shortest.paths()` completely. 
- Added `graphlets()` and related functions.
- Fix modularity values of multilevel community if there are no merges
  at all.
- Fixed bug when deleting edges with FALSE in the matrix notation.
- Fix `bonpow()` and `alpha.centrality()` and make sure that the
  sparse solver is called.
- `tkplot()` news: enable setting coordinates from the command line
  via `tkplot.setcoords()` and access to the canvas via 
  `tkplot.canvas()`.
- Fixed a potential crash in `igraph_edge_connectivity()`, because of an
  un-initialized variable in the C code.
- Avoiding overflow in `closeness()` and related functions.
- Check for NAs after converting 'type' to logical in 
  `bipartite.projection()`.
- `graphNEL` conversion functions only load the 'graph' package if it was 
  not loaded before and they load it at the end of the search path, 
  to minimize conflicts.
- Fixed a bug when creating graphs from adjacency matrices, we now convert
  them to double, in case they are integers.
- Fixed an invalid memory read (and a potential crash) in the infomap
  community detection.
- Fixed a memory leak in the functions with attribute combinations.
- Removed some memory leaks from the SCG functions.
- Fixed some memory leaks in the ray tracer.
- Fixed memory leak in `graph.bfs()` and `graph.dfs()`.
- Fix a bug in triad census that set the first element of the result
  to NaN.
- Fixed a crash in `is.chordal()`.
- Fixed a bug in weighted mudularity calculation, sum of the weights
  was truncated to an integer.
- Fixed a bug in weighted multilevel communtiies, the maximum weight
  was rounded to an integer.
- Fixed a bug in `centralization.closeness.tmax()`.
- Reimplement push-relabel maximum flow with gap heuristics.
- Maximum flow functions now return some statistics about the push
  relabel algorithm steps.
- Function `arpack()` now gives error message if unknown options are
  given.
- Fixed missing whitespace in Pajek writer when the ID attribute was
  numeric.
- Fixed a bug that caused the GML reader to crash when the ID
  attribute was non-numeric.
- Fixed issue #500, potential segfault if the two graphs in BLISS
  differ in the number of vertices or edges.
- Added `igraphtest()` function.
- Fix dyad census instability, sometimes incorrect results were
  reported.
- Dyad census detects integer overflow now and gives a warning.
- Function `add.edges()` does not allow now zeros in the vertex set.
- Added a function to count the number of adjacent triangles:
  `adjacenct.triangles()`.
- Added `graph.eigen()` function, eigenproblems on adjacency matrices.
- Added some workarounds for functions that create a lot of
  graphs, `decompose.graph()` and `graph.neighborhood()` use it. 
  Fixes issue #508.
- Added weights support for `optimal.community()`, closes #511.
- Faster maximal clique finding.
- Added a function to count maximum cliques.
- Set operations: union, intersection, disjoint, union, difference,
  compose now work based on vertex names (if they are present) and
  keep attributes, closes #20.
- Removed functions `graph.intersection.by.name()`,
  `graph.union.by.name()`, `graph.difference.by.name()`.
- The `+` operator on graphs now calls `graph.union()` if both 
  argument graphs are named, and calls `graph.disjoint.union()`
  otherwise.
- Added function `igraph.version()`.
- Generate graphs from a stochastic block model: `sbm.game()`.
- Do not suggest the stats, XML, jpeg and png packages any more.
- Fixed a `set.vertex/edge.attribute` bug that changed both
  graph objects, after copying (#533)
- Fixed a bug in `barabasi.game` that caused crashes.
- We use PRPACK to calculate PageRank scores
  see https://github.com/dgleich/prpack
- Added`'which` argument to `bipartite.projection` (#307).
- Add `normalized` argument to closeness functions, fixes issue #3.
- R: better handling of complex attributes, `[[` on vertex/edge sets,
  fixes #231.
- Implement the `start` argument in `hrg.fit` (#225).
- Set root vertex in Reingold-Tilford layout, solves #473.
- Fix betweenness normalization for directed graphs.
- Fixed a bug in `graph.density` that resulted in incorrect values for
  undirected graphs with loops
- Fixed a bug when many graphs were created in one C call
  (e.g. by `graph.decompose`), causing #550.
- Fixed sparse `graph.adjacency` bugs for graphs with one edge,
  and graphs with zero edges.
- Fixed a bug that made Bellman-Ford shortest paths calculations fail.
- Fixed a `graph.adjacency` bug for undirected, weighted graphs and
  sparse matrices.
- `main`, `sub`, `xlab` and `ylab` are proper graphics parameters
  now (#555).
- `graph.data.frame` coerces arguments to data frame (#557).
- Fixed a minimum cut bug for weighted undirected graphs (#564).
- Functions for simulating epidemics (SIR model) on networks,
  see the `sir` function.
- Fixed argument ordering in `graph.mincut` and related functions.
- Avoid copying attributes in query functions and print (#573),
  these functions are much faster now for graphs with many
  vertices/edges and attributes.
- Speed up writing GML and GraphML files, if some attributes are
  integer. It was really-really slow.
- Fix multiple root vertices in `graph.bfs` (#575).

# igraph 0.6.6

Released Oct 28, 2013

Some bugs fixed:

- Fixed a potential crash in the infomap.community() function.
- Various fixed for the operators that work on vertex names (#136).
- Fixed an example in the arpack() manual page.
- arpack() now gives error message if unknown options
  are supplied (#492).
- Better arpack() error messages.
- Fixed missing whitespace in Pajek writer when ID attribute
  was numeric.
- Fixed dyad census instability, sometimes incorrect 
  results were reported (#496).
- Fixed a bug that caused the GML reader to crash when the ID
  attribute was non-numeric
- Fixed a potential segfault if the two graphs in BLISS
  differ in the number of vertices or edges (#500).
- Added the igraphtest() function to run tests from R (#485).
- Dyad census detects integer overflow now and gives a warning (#497).
- R: add.edges() does not allow now zeros in the vertex set (#503).
- Add C++ namespace to the files that didn't have one. 
  Fixes some incompatibility with other packages (e.g. rgl) 
  and mysterious crashes (#523).
- Fixed a bug that caused a side effect in set.vertex.attributes(),
  set.edge.attributes() and set.graph.attributes() (#533).
- Fixed a bug in degree.distribution() and cluster.distribution()
  (#257).

# igraph 0.6.5-2

Released May 16, 2013

Worked two CRAN check problems, and a gfortran bug (string bound
checking does not work if code is called from C and without string
length arguments at the "right" place).

Otherwise identical to 0.6.5-1.

# igraph 0.6.5-1

Released February 27, 2013

Fixing an annoying bug, that broke two other packages on CRAN:

- Setting graph attributes failed sometimes, if the attributes were 
  lists or other complex objects.

# igraph 0.6.5

Released February 24, 2013

This is a minor release, to fix some very annoying bugs in 0.6.4:

- igraph should now work well with older R versions.
- Eliminate gap between vertex and edge when plotting an edge without an arrow.
  Fixes #1118448.
- Fixed an out-of-bounds array indexing error in the DrL layout, that
  potentially caused crashes.
- Fixed a crash in weighted betweenness calculation.
- Plotting: fixed a bug that caused misplaced arrows at rectangle 
  vertex shapes. 

# igraph 0.6.4

Released February 2, 2013

The version number is not a mistake, we jump to 0.6.4 from 0.6, 
for technical reasons. This version was actually never really
released, but some R packages of this version were uplodaded to 
CRAN, so we include this version in this NEW file.

# New features and bug fixes

- Added a vertex shape API for defining new vertex shapes, and also 
  a couple of new vertex shapes.
- Added the get.data.frame() function, opposite of graph.data.frame().
- Added bipartite support to the Pajek reader and writer, closes bug
  #1042298.
- degree.sequence.game() has a new method now: "simple_no_multiple".
- Added the is.degree.sequence() and is.graphical.degree.sequence()
  functions.
- rewire() has a new method: "loops", that can create loop edges.
- Walktrap community detection now handles isolates.
- layout.mds() returns a layout matrix now.
- layout.mds() uses LAPACK instead of ARPACK.
- Handle the '~' character in write.graph and read.graph. Bug
  #1066986.
- Added k.regular.game().
- Use vertex names to plot if no labels are specified in the function
  call or as vetex attributes. Fixes issue #1085431.
- power.law.fit() can now use a C implementation.

- Fixed a bug in barabasi.game() when out.seq was an empty vector.
- Fixed a bug that made functions with a progress bar fail if called 
  from another package.
- Fixed a bug when creating graphs from a weighted integer adjacency 
  matrix via graph.adjacency(). Bug #1019624.
- Fixed overflow issues in centralization calculations.
- Fixed a minimal.st.separators() bug, some vertex sets were incorrectly
  reported as separators. Bug #1033045.
- Fixed a bug that mishandled vertex colors in VF2 isomorphism
  functions. Bug #1032819.
- Pajek exporter now always quotes strings, thanks to Elena Tea Russo.
- Fixed a bug with handling small edge weights in shortest paths 
  calculation in shortest.paths() (Dijkstra's algorithm.) Thanks to 
  Martin J Reed.
- Weighted transitivity uses V(graph) as 'vids' if it is NULL.
- Fixed a bug when 'pie' vertices were drawn together with other 
  vertex shapes.
- Speed up printing graphs.
- Speed up attribute queries and other basic operations, by avoiding 
  copying of the graph. Bug #1043616.
- Fixed a bug in the NCV setting for ARPACK functions. It cannot be
  bigger than the matrix size.
- layout.merge()'s DLA mode has better defaults now.
- Fixed a bug in layout.mds() that resulted vertices on top of each
  other.
- Fixed a bug in layout.spring(), it was not working properly.
- Fixed layout.svd(), which was completely defunct.
- Fixed a bug in layout.graphopt() that caused warnings and on 
  some platforms crashes.
- Fixed community.to.membership(). Bug #1022850.
- Fixed a graph.incidence() crash if it was called with a non-matrix
  argument.
- Fixed a get.shortest.paths bug, when output was set to "both".
- Motif finding functions return NA for isomorphism classes that are
  not motifs (i.e. not connected). Fixes bug #1050859. 
- Fixed get.adjacency() when attr is given, and the attribute has some
  complex type. Bug #1025799. 
- Fixed attribute name in graph.adjacency() for dense matrices. Bug
  #1066952. 
- Fixed erratic behavior of alpha.centrality().
- Fixed igraph indexing, when attr is given. Bug #1073705.
- Fixed a bug when calculating the largest cliques of a directed
  graph. Bug #1073800.
- Fixed a bug in the maximal clique search, closes #1074402.
- Warn for negative weights when calculating PageRank.
- Fixed dense, unweighted graph.adjacency when diag=FALSE. Closes
  issue #1077425. 
- Fixed a bug in eccentricity() and radius(), the results were often
  simply wrong.
- Fixed a bug in get.all.shortest.paths() when some edges had zero weight.
- graph.data.frame() is more careful when vertex names are numbers, to
  avoid their scientific notation. Fixes issue #1082221. 
- Better check for NAs in vertex names. Fixes issue #1087215
- Fixed a potential crash in the DrL layout generator.
- Fixed a bug in the Reingold-Tilford layout when the graph is
  directed and mode != ALL.

# igraph 0.6

Released June 11, 2012

See also the release notes at 
http://igraph.sf.net/relnotes-0.6.html

# R: Major new features

- Vertices and edges are numbered from 1 instead of 0. 
  Note that this makes most of the old R igraph code incompatible
  with igraph 0.6. If you want to use your old code, please use 
  the igraph0 package. See more at http://igraph.sf.net/relnotes-0.6.html.
- The '[' and '[[' operators can now be used on igraph graphs, 
  for '[' the graph behaves as an adjacency matrix, for '[[' is 
  is treated as an adjacency list. It is also much simpler to
  manipulate the graph structure, i.e. add/remove edges and vertices, 
  with some new operators. See more at ?graph.structure.
- In all functions that take a vector or list of vertices or edges, 
  vertex/edge names can be given instead of the numeric ids.
- New package 'igraphdata', contains a number of data sets that can
  be used directly in igraph.
- Igraph now supports loading graphs from the Nexus online data
  repository, see nexus.get(), nexus.info(), nexus.list() and 
  nexus.search().
- All the community structure finding algorithm return a 'communities'
  object now, which has a bunch of useful operations, see 
  ?communities for details.
- Vertex and edge attributes are handled much better now. They 
  are kept whenever possible, and can be combined via a flexible API.
  See ?attribute.combination.
- R now prints igraph graphs to the screen in a more structured and 
  informative way. The output of summary() was also updated
  accordingly.

# R: Other new features

- It is possible to mark vertex groups on plots, via
  shading. Communities and cohesive blocks are plotted using this by
  default.
- Some igraph demos are now available, see a list via 
  'demo(package="igraph")'.
- igraph now tries to select the optimal layout algorithm, when
  plotting a graph.
- Added a simple console, using Tcl/Tk. It contains a text area
  for status messages and also a status bar. See igraph.console().
- Reimplemented igraph options support, see igraph.options() and 
  getIgraphOpt().
- Igraph functions can now print status messages.

# R: New or updated functions

## Community detection

- The multi-level modularity optimization community structure detection 
  algorithm by Blondel et al. was added, see multilevel.community().
- Distance between two community structures: compare.communities().
- Community structure via exact modularity optimization,
  optimal.community().
- Hierarchical random graphs and community finding, porting the code
  from Aaron Clauset. See hrg.game(), hrg.fit(), etc.
- Added the InfoMAP community finding method, thanks to Emmanuel
  Navarro for the code. See infomap.community().

## Shortest paths

- Eccentricity (eccentricity()), and radius (radius()) calculations.
- Shortest path calculations with get.shortest.paths() can now 
  return the edges along the shortest paths.
- get.all.shortest.paths() now supports edge weights.

## Centrality

- Centralization scores for degree, closeness, betweenness and 
  eigenvector centrality. See centralization.scores().
- Personalized Page-Rank scores, see page.rank().
- Subgraph centrality, subgraph.centrality().
- Authority (authority.score()) and hub (hub.score()) scores support 
  edge weights now.
- Support edge weights in betweenness and closeness calculations.
- bonpow(), Bonacich's power centrality and alpha.centrality(), 
  Alpha centrality calculations now use sparse matrices by default.
- Eigenvector centrality calculation, evcent() now works for 
  directed graphs.
- Betweenness calculation can now use arbitrarily large integers,
  this is required for some lattice-like graphs to avoid overflow.

## Input/output and file formats

- Support the DL file format in graph.read(). See 
  http://www.analytictech.com/networks/dataentry.htm.
- Support writing the LEDA file format in write.graph().

## Plotting and layouts

- Star layout: layout.star().
- Layout based on multidimensional scaling, layout.mds().
- New layouts layout.grid() and layout.grid.3d().
- Sugiyama layout algorithm for layered directed acyclic graphs, 
  layout.sugiyama().

## Graph generators

- New graph generators: static.fitness.game(), static.power.law.game().
- barabasi.game() was rewritten and it supports three algorithms now,
  the default algorithm does not generate multiple or loop edges.
  The graph generation process can now start from a supplied graph.
- The Watts-Strogatz graph generator, igraph_watts_strogatz() can 
  now create graphs without loop edges.

## Others

- Added the Spectral Coarse Graining algorithm, see scg(). 
- The cohesive.blocks() function was rewritten in C, it is much faster
  now. It has a nicer API, too. See demo("cohesive").
- Added generic breadth-first and depth-first search implementations
  with many callbacks, graph.bfs() and graph_dfs().
- Support vertex and edge coloring in the VF2 (sub)graph isomorphism 
  functions (graph.isomorphic.vf2(), graph.count.isomorphisms.vf2(), 
  graph.get.isomorphisms.vf2(), graph.subisomorphic.vf2(), 
  graph.count.subisomorphisms.vf2(), graph.get.subisomorphisms.vf2()).
- Assortativity coefficient, assortativity(), assortativity.nominal()
  and assortativity.degree().
- Vertex operators that work by vertex names: 
  graph.intersection.by.name(), graph.union.by.name(), 
  graph.difference.by.name(). Thanks to Magnus Torfason for 
  contributing his code!
- Function to calculate a non-induced subraph: subgraph.edges().
- More comprehensive maximum flow and minimum cut calculation, 
  see functions graph.maxflow(), graph.mincut(), stCuts(), stMincuts().
- Check whether a directed graph is a DAG, is.dag().
- has.multiple() to decide whether a graph has multiple edges.
- Added a function to calculate a diversity score for the vertices,
  graph.diversity().
- Graph Laplacian calculation (graph.laplacian()) supports edge 
  weights now.
- Biconnected component calculation, biconnected.components() 
  now returns the components themselves.
- bipartite.projection() calculates multiplicity of edges.
- Maximum cardinality search: maximum.cardinality.search() and 
  chordality test: is.chordal()
- Convex hull computation, convex.hull().
- Contract vertices, contract.vertices().

# igraph 0.5.3

Released November 22, 2009

## Bugs corrected in the R interface

- Some small changes to make 'R CMD check' clean
- Fixed a bug in graph.incidence, the 'directed' and 'mode' arguments 
  were not handled correctly
- Betweenness and edge betweenness functions work for graphs with
  many shortest paths now (up to the limit of long long int)
- When compiling the package, the configure script fails if there is
  no C compiler available
- igraph.from.graphNEL creates the right number of loop edges now
- Fixed a bug in bipartite.projection() that caused occasional crashes 
  on some systems

# igraph 0.5.2

Released April 10, 2009

See also the release notes at
http://igraph.sf.net/relnotes-0.5.2.html

## New in the R interface

- Added progress bar support to beweenness() and
  betweenness.estimate(), layout.drl()
- Speeded up betweenness estimation
- Speeded up are.connected()
- Johnson's shortest paths algorithm added
- shortest.paths() has now an 'algorithm' argument to choose from the
  various implementations manually
- Always quote symbolic vertex names when printing graphs or edges
- Average nearest neighbor degree calculation, graph.knn()
- Weighted degree (also called strength) calculation, graph.strength()
- Some new functions to support bipartite graphs: graph.bipartite(),
  is.bipartite(), get.indicence(), graph.incidence(),
  bipartite.projection(), bipartite.projection.size()
- Support for plotting curved edges with plot.igraph() and tkplot()
- Added support for weighted graphs in alpha.centrality()
- Added the label propagation community detection algorithm by
  Raghavan et al., label.propagation.community()
- cohesive.blocks() now has a 'cutsetHeuristic' argument to choose
  between two cutset algorithms
- Added a function to "unfold" a tree, unfold.tree()
- New tkplot() arguments to change the drawing area
- Added a minimal GUI, invoke it with tkigraph()
- The DrL layout generator, layout.drl() has a three dimensional mode
  now.

## Bugs corrected in the R interface

- Fixed a bug in VF2 graph isomorphism functions
- Fixed a bug when a sparse adjacency matrix was requested in
  get.adjacency() and the graph was named
- VL graph generator in degree.sequence.game() checks now that
  the sum of the degrees is even
- Many fixes for supporting various compilers, e.g. GCC 4.4 and Sun's
  C compiler
- Fixed memory leaks in graph.automorphisms(), Bellman-Ford
  shortest.paths(), independent.vertex.sets()
- Fix a bug when a graph was imported from LGL and exported to NCOL
  format (#289596)
- cohesive.blocks() creates its temporary file in the session
  temporary directory
- write.graph() and read.graph() now give error messages when unknown
  arguments are given
- The GraphML reader checks the name of the attributes to avoid adding
  a duplicate 'id' attribute
- It is possible to change the 'ncv' ARPACK parameter for
  leading.eigenvector.community()
- Fixed a bug in path.length.hist(), 'unconnected' was wrong
  for unconnected and undirected graphs
- Better handling of attribute assingment via iterators, this is now
  also clarified in the manual
- Better error messages for unknown vertex shapes
- Make R package unload cleanly if unloadNamespace() is used
- Fixed a bug in plotting square shaped vertices (#325244)
- Fixed a bug in graph.adjacency() when the matrix is a sparse matrix
  of class "dgTMatrix"

# igraph 0.5.1

Released July 14, 2008

See also the release notes at 
http://igraph.sf.net/relnotes-0.5.1.html

## New in the R interface

- A new layout generator called DrL.
- Uniform sampling of random connected undirected graphs with a 
  given degree sequence.
- Edge labels are plotted at 1/3 of the edge, this is better if 
  the graph has mutual edges.
- Initial and experimental vertex shape support in 'plot'.
- New function, 'graph.adjlist' creates igraph graphs from
  adjacency lists.
- Conversion to/from graphNEL graphs, from the 'graph' R package.
- Fastgreedy community detection can utilize edge weights now, this 
  was missing from the R interface.
- The 'arrow.width' graphical parameter was added.
- graph.data.frame has a new argument 'vertices'.
- graph.adjacency and get.adjacency support sparse matrices, 
  the 'Matrix' package is required to use this functionality.
- graph.adjacency adds column/row names as 'name' attribute.
- Weighted shortest paths using Dijkstra's or the Belmann-Ford 
  algorithm.
- Shortest path functions return 'Inf' for unreachable vertices.
- New function 'is.mutual' to find mutual edges in a directed graph.
- Added inverse log-weighted similarity measure (a.k.a. Adamic/Adar
  similarity).
- preference.game and asymmetric.preference.game were 
  rewritten, they are O(|V|+|E|) now, instead of O(|V|^2).
- Edge weight support in function 'get.shortest.paths', it uses 
  Dijkstra's algorithm.

## Bugs corrected in the R interface
  
- A bug was corrected in write.pajek.bgraph.
- Several bugs were corrected in graph.adjacency.
- Pajek reader bug corrected, used to segfault if '*Vertices' 
  was missing.
- Directedness is handled correctly when writing GML files.
  (But note that 'correct' conflicts the standard here.)
- Corrected a bug when calculating weighted, directed PageRank on an 
  undirected graph. (Which does not make sense anyway.)
- Several bugs were fixed in the Reingold-Tilford layout to avoid 
  edge crossings.
- A bug was fixed in the GraphML reader, when the value of a graph
  attribute was not specified.
- Fixed a bug in the graph isomorphism routine for small (3-4 vertices)
  graphs.
- Corrected the random sampling implementation (igraph_random_sample),
  now it always generates unique numbers. This affects the 
  Gnm Erdos-Renyi generator, it always generates simple graphs now.
- The basic igraph constructor (igraph_empty_attrs, all functions 
  are expected to call this internally) now checks whether the number
  of vertices is finite.
- The LGL, NCOL and Pajek graph readers handle errors properly now.
- The non-symmetric ARPACK solver returns results in a consistent form
  now.
- The fast greedy community detection routine now checks that the graph
  is simple.
- The LGL and NCOL parsers were corrected to work with all 
  kinds of end-of-line encodings.
- Hub & authority score calculations initialize ARPACK parameters now.
- Fixed a bug in the Walktrap community detection routine, when applied 
  to unconnected graphs.
- Several small memory leaks were removed, and a big one from the Spinglass
  community structure detection function

# igraph 0.5

Released February 14, 2008

See also the release notes at http://igraph.sf.net/relnotes-0.5.html

## New in the R interface

- The 'rescale', 'asp' and 'frame' graphical parameters were added
- Create graphs from a formula notation (graph.formula)
- Handle graph attributes properly
- Calculate the actual minimum cut for undirected graphs
- Adjacency lists, get.adjlist and get.adjedgelist added
- Eigenvector centrality computation is much faster now
- Proper R warnings, instead of writing the warning to the terminal
- R checks graphical parameters now, the unknown ones are not just
  ignored, but an error message is given  
- plot.igraph has an 'add' argument now to compose plots with multiple
  graphs
- plot.igraph supports the 'main' and 'sub' arguments
- layout.norm is public now, it can normalize a layout
- It is possible to supply startup positions to layout generators
- Always free memory when CTRL+C/ESC is pressed, in all operating
  systems
- plot.igraph can plot square vertices now, see the 'shape' parameter
- graph.adjacency rewritten when creating weighted graphs
- We use match.arg whenever possible. This means that character scalar 
  options can be abbreviated and they are always case insensitive

- VF2 graph isomorphism routines can check subgraph isomorphism now,
  and they are able to return matching(s)
- The BLISS graph isomorphism algorithm is included in igraph now. See
  canonical.permutation, graph.isomorphic.bliss
- We use ARPACK for eigenvalue/eigenvector calculation. This means that the
  following functions were rewritten: page.rank,
  leading.eigenvector.community.*, evcent. New functions based on
  ARPACK: hub.score, authority.score, arpack.
- Edge weights for Fruchterman-Reingold layout (layout.fruchterman.reingold).
- Line graph calculation (line.graph)
- Kautz and de Bruijn graph generators (graph.kautz, graph.de.bruijn)
- Support for writing graphs in DOT format
- Jaccard and Dice similarity coefficients added (similarity.jaccard,
  similarity.dice)
- Counting the multiplicity of edges (count.multiple)
- The graphopt layout algorithm was added, layout.graphopt
- Generation of "famous" graphs (graph.famous).
- Create graphs from LCF notation (graph.cf).
- Dyad census and triad cencus functions (dyad.census, triad.census)
- Cheking for simple graphs (is.simple)
- Create full citation networks (graph.full.citation)
- Create a histogram of path lengths (path.length.hist)
- Forest fire model added (forest.fire.game)
- DIMACS reader can handle different file types now
- Biconnected components and articulation points (biconnected.components,
  articulation.points)
- Kleinberg's hub and authority scores (hub.score, authority.score)
- as.undirected handles attributes now
- Geometric random graph generator (grg.game) can return the
  coordinates of the vertices
- Function added to convert leading eigenvector community structure result to
  a membership vector (community.le.to.membership)
- Weighted fast greedy community detection
- Weighted page rank calculation
- Functions for estimating closeness, betweenness, edge betweenness by 
  introducing a cutoff for path lengths (closeness.estimate,
  betweenness.estimate, edge.betweenness.estimate)
- Weighted modularity calculation
- Function for permuting vertices (permute.vertices)
- Betweenness and closeness calculations are speeded up
- read.graph can handle all possible line terminators now (\r, \n, \r\n, \n\r)
- Error handling was rewritten for walktrap community detection,
  the calculation can be interrupted now
- The maxflow/mincut functions allow to supply NULL pointer for edge
  capacities, implying unit capacities for all edges

## Bugs corrected in the R interface

- Fixed a bug in cohesive.blocks, cohesive blocks were sometimes not
  calculated correctly

# igraph 0.4.5

Released January 1, 2008

New:
- Cohesive block finding in the R interface, thanks to Peter McMahan
  for contributing his code. See James Moody and Douglas R. White,
  2003, in Structural Cohesion and Embeddedness: A Hierarchical
  Conception of Social Groups American Sociological Review 68(1):1-25 
- Biconnected components and articulation points.
- R interface: better printing of attributes.
- R interface: graph attributes can be used via '$'.

Bug fixed:
- Erdos-Renyi random graph generators rewritten.

# igraph 0.4.4

Released October 3, 2007

This release should work seemlessly with the new R 2.6.0 version.
Some other bugs were also fixed:
- A bug was fixed in the Erdos-Renyi graph generator, which sometimes
  added an extra vertex.

# igraph 0.4.3

Released August 13, 2007

The next one in the sequence of bugfix releases. Thanks to many people
sending bug reports. Here are the changes:
- Some memory leaks removed when using attributes from R or Python.
- GraphML parser: entities and character data in multiple chunks are
  now handled correctly. 
- A bug corrected in edge betweenness community structure detection,
  it failed if called many times from the same program/session.
- Edge betweeness community structure: handle unconnected graphs properly.
- Fixed bug related to fast greedy community detection in unconnected graphs.
- Use a different kind of parser (Push) for reading GraphML
  files. This is almost invisible for users but fixed a
  nondeterministic bug when reading in GraphML files.
- R interface: plot now handles properly if called with a vector as
  the edge.width argument for directed graphs.
- R interface: bug (typo) corrected for walktrap.community and
  weighted graphs. 

# igraph 0.4.2

Released June 7, 2007

This is another bugfix release, as there was a serious bug in the 
R package of the previous version: it could not read and write graphs
to files in any format under MS Windows.

Some other bits added: 
- circular Reingold-Tilford layout generator for trees
- corrected a bug, Pajek files are written properly under MS Windows now.
- arrow.size graphical edge parameter added in the R interface.

# igraph 0.4.1

Released May 23, 2007

This is a minor release, it corrects a number of bugs, mostly in the 
R package.

# igraph 0.4

Released May 21, 2007

The major new additions in this release is a bunch of community
detection algorithms and support for the GML file format. Here 
is the complete list of changes:

## New in the R interface

- as the internal representation changed, graphs stored with 'save' 
  with an older igraph version cannot be read back with the new
  version reliably.
- neighbors returns ordered lists
- is.loop and is.multiple were added

- topological sorting
- VF2 isomorphism algorithm
- support for reading graphs from the Graph Database for isomorphism
- graph.mincut can calculate the actual minimum cut
- girth calculation added, thanks to Keith Briggs
- support for reading and writing GML files

- Walktrap community detection algorithm added, thanks to Matthieu Latapy 
  and Pascal Pons
- edge betweenness based community detection algorithm added
- fast greedy algorithm for community detection by Clauset et al. added
  thanks to Aaron Clauset for sharing his code  
- leading eigenvector community detection algorithm by Mark Newman added
- functions for creating dendrograms from the output of the 
  community detection algorithms added
- community.membership supporting function added, creates 
  a membership vector from a community structure merge tree
- modularity calculation added

- graphics parameter handling is completely rewritten, uniform handling 
  of colors and fonts, make sure you read ?igraph.plotting
- new plotting parameter for edges: arrow.mode
- a bug corrected when playing a nonlinear barabasi.game
- better looking plotting in 3d using rglplot: edges are 3d too
- rglplot layout is allowed to be two dimensional now
- rglplot suspends updates while drawing, this makes it faster
- loop edges are correctly plotted by all three plotting functions

- better printing of attributes when printing graphs
- summary of a graph prints attribute names
- is.igraph rewritten to make it possible to inherit from the 'igraph' class
- somewhat better looking progress meter for functions which support it

## Others

- many functions benefit from the new internal representation and are 
  faster now: transitivity, reciprocity, graph operator functions like 
  intersection and union, etc.

## Bugs corrected

- corrected a bug when reading Pajek files: directed graphs were read
  as undirected 

# igraph 0.3.2

Released Dec 19, 2006

This is a new major release, it contains many new things:

## Changes in the R interface

- bonpow function ported from SNA to calculate Bonacich power centrality
- get.adjacency supports attributes now, this means that it sets the
  colnames  and rownames attributes and can return attribute values in
  the matrix instead of 0/1
- grg.game, geometric random graphs
- graph.density, graph density calculation
- edge and vertex attributes can be added easily now when added new
  edges with add.edges or new vertices with add.vertices
- graph.data.frame creates graph from data frames, this can be used to 
  create graphs with edge attributes easily
- plot.igraph and tkplot can plot self-loop edges now
- graph.edgelist to create a graph from an edge list, can also handle 
  edge lists with symbolic names
- get.edgelist has now a 'names' argument and can return symbolic
  vertex names instead of vertex ids, by default id uses the 'name'
  vertex attribute is returned 
- printing graphs on screen also prints symbolic symbolic names
  (the 'name' attribute if present)
- maximum flow and minimum cut functions: graph.maxflow, graph.mincut
- vertex and edge connectivity: edge.connectivity, vertex.connectivity
- edge and vertex disjoint paths: edge.disjoint.paths, 
  vertex.disjoint.paths
- White's cohesion and adhesion measure: graph.adhesion, graph.cohesion
- dimacs file format added
- as.directed handles attributes now
- constraint corrected, it handles weighted graphs as well now
- weighted attribute to graph.adjacency
- spinglass-based community structure detection, the Joerg Reichardt --
  Stefan Bornholdt algorithm added: spinglass.community
- graph.extended.chordal.ring, extended chordal ring generation
- no.clusters calculates the number of clusters without calculating
  the clusters themselves
- minimum spanning tree functions updated to keep attributes
- transitivity can calculate local transitivity as well
- neighborhood related functions added: neighborhood,
  neighborhood.size, graph.neighborhood
- new graph generators based on vertex types: preference.game and
  asymmetric.preference.game

## Bugs corrected

- attribute handling bug when deleting edges corrected
- GraphML escaping and NaN handling corrected
- bug corrected to make it possible compile the R package without the 
  libxml2 library
- a bug in Erdos-Renyi graph generation corrected: it had problems 
  with generating large directed graphs
- bug in constraint calculation corrected, it works well now
- fixed memory leaks in the GraphML reader
- error handling bug corrected in the GraphML reader
- bug corrected in R version of graph.laplacian when normalized
  Laplacian is requested
- memory leak corrected in get.all.shortest.paths in the R package

# igraph 0.2.1

Released Aug 23, 2006

This is a bug-fix release. Bugs fixed:
- reciprocity corrected to avoid segfaults
- some docs updates
- various R package updates to make it conform to the CRAN rules

# igraph 0.2

Released Aug 18, 2006

Release time at last! There are many new things in igraph 0.2, the
most important ones:
- reading writing Pajek and GraphML formats with attributes
  (not all Pajek and GraphML files are supported, see documentation
  for details)
- the RANDEDU fast motif search algorithm is implemented
- many new graph generators, both games and regular graphs
- many new structural properties: transitivity, reciprocity, etc.
- graph operators: union, intersection, difference, structural holes, etc.
- conversion between directed and undirected graphs
- new layout algorithms for trees and large graphs, 3D layouts
and many more.

New things specifically in the R package:
- support for CTRL+C
- new functions: Graph Laplacian, Burt's constraint, etc.
- vertex/edge sequences totally rewritten, smart indexing (see manual)
- new R manual and tutorial: `Network Analysis with igraph', still 
  under development but useful
- very basic 3D plotting using OpenGL

Although this release was somewhat tested on Linux, MS Windows, Mac
OSX, Solaris 8 and FreeBSD, no heavy testing was done, so it might
contain bugs, and we kindly ask you to send bug reports to make igraph
better.

# igraph 0.1

Released Jan 30, 2006

After about a year of development this is the first "official" release 
of the igraph library. This release should be considered as beta 
software, but it should be useful in general. Please send your 
questions and comments.


