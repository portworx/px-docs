# How To Update/Maintain px-docs
(Sept 22, 2016)

This doc site is developed using [jekyll](https://jekyllrb.com/) and hosted on [github pages](https://pages.github.com/)
The default branch is "gh-pages", which means that any updates to the content will get immediately rendered by gh-pages/jekyll and reflected onto [docs.portworx.com](http://docs.portworx.com).   Real-time doc site maintenance for now.

The template for this site is based on [this documentation template](http://idratherbewriting.com/documentation-theme-jekyll/) for jekyll

There are lots of files from the original template that have been left here for reference, but which aren't actually being used.

Most important things to know:

  + For now, the content is all flat.   All 'md' files are at this top level directory.   There are no subdirectories
  + The main sidebar is _data/sidebars/home_sidebar.yml.   If you create a new page, find an appropriate header under which to place it.  As of now, this is the only sidebar being used
  + All images must include a width and height in order to be valid on the AMP version of the documentation. For example:
```
![Configure Admin User](/images/jenkins3.png){:width="1992px" height="1156px"}
```
  + Local references to files in this directory take the following form:  
 ```
 
[Create a PX-Enterprise Cluster](create-px-enterprise-cluster.html)  <br/>
 
 ```
Note the reference to a **".html"** file, which gets generated automatically by jekyll from the **".md"** file.


## AMP Version

There is an AMP version of the documentation which is effectively a drop in replacement for the `page.html` layout. 
When you wish to generate the AMP documentation manually (production generation and deployment is automated), you must replace the `page.html` file in `_layouts/` with `amp.html` - this process may change in the future.

Documentation for AMP is built using Travis and is pushed to the `portworx/px-docs-amp` repository on Github. 
This repository is accessible at [https://docs-amp.portworx.com/](https://docs-amp.portworx.com/). 
Travis will only build upon new commits to the `gh-pages` branch (this will happen when you merge in using a Github pull request) and it may take a few minutes to build and push which means that the time to update AMP may be longer than that of the standard documentation.

Due to the limitations of AMP, there is no Javascript and therefore no Algolia Docsearch, this is replaced by a simple Google search form.
