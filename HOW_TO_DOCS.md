# How To Update/Maintain px-docs
(Sept 22, 2016)

This doc site is developed using [jekyll](https://jekyllrb.com/) and hosted on [github pages](https://pages.github.com/)
The default branch is "gh-pages", which means that any updates to the content will get immediately rendered by gh-pages/jekyll and reflected onto [docs.portworx.com](http://docs.portworx.com).   Real-time doc site maintainence for now.

The template for this site is based on [this documentation template](http://idratherbewriting.com/documentation-theme-jekyll/) for jekyll

There are lots of files from the original template that have been left here for reference, but which aren't actually being used.

Most important things to know:

  + For now, the content is all flat.   All 'md' files are at this top level directory.   There are no subdirectories
  + The main sidebar is _data/sidebars/home_sidebar.yml.   If you create a new page, find an appropriate header under which to place it.  As of now, this is the only sidebar being used
  + Local references to files in this directory take the following form:  
 ```
 
[Create a PX-Enterprise Cluster](create-px-enterprise-cluster.html)  <br/>
 
 ```
Note the reference to a **".html"** file, which gets generated automatically by jekyll from the **".md"** file.
