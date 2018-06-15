% System Rd macros

% These macros are automatically loaded whenever R processes an Rd file.

% Packages may define their own macros, which are stored in man/macros/*.Rd in
% the source, help/macros/*.Rd after installation.  Those will be processed after
% this file but before every Rd file in a package.

% Packages may request inclusion of macros from other packages using the 
% LoadRdMacros line in the DESCRIPTION file, e.g.
%  LoadRdMacros:  pkgA 
% These are loaded after the system macros and before the current package macros.

% Individual Rd files may define their own macros.



% To refer to a package on CRAN
\newcommand{\CRANpkg}{\href{https://CRAN.R-project.org/package=#1}{\pkg{#1}}}

% To refer to a bug report by number
\newcommand{\PR}{\Sexpr[results=rd]{tools:::Rd_expr_PR(#1)}}

% To avoid a double space after a period in LaTeX output
\newcommand{\sspace}{\ifelse{latex}{\out{~}}{ }}

% To get the package title at build time from the DESCRIPTION file
\newcommand{\packageTitle}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_title("#1")}}

% To get the package description at build time from the DESCRIPTION file
\newcommand{\packageDescription}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_description("#1")}}

% To get the package author at build time from the DESCRIPTION file
\newcommand{\packageAuthor}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_author("#1")}}

% To get the package maintainer at build time from the DESCRIPTION file
\newcommand{\packageMaintainer}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_maintainer("#1")}}

% To get a formatted copy of the whole DESCRIPTION file
\newcommand{\packageDESCRIPTION}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_DESCRIPTION("#1")}}

% To include various indices about an installed package

\newcommand{\packageIndices}{\Sexpr[results=rd,stage=build]{tools:::Rd_package_indices("#1")}}

% To indicate a DOI.
\newcommand{\doi}{\Sexpr[results=rd,stage=build]{tools:::Rd_expr_doi("#1")}}

% To indicate LaTeX.
\newcommand{\LaTeX}{\ifelse{latex}{\out{{\LaTeX}}}{LaTeX}}

