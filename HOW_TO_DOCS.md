# How To Update/Maintain px-docs
(Sept 22, 2016)

This doc site is developed using [jekyll](https://jekyllrb.com/) and hosted on [github pages](https://pages.github.com/)
The default branch is "gh-pages", which means that any updates to the content will get immediately rendered by gh-pages/jekyll and reflected onto [docs.portworx.com](http://docs.portworx.com).   Real-time doc site maintenance for now.

The template for this site is based on [this documentation template](http://idratherbewriting.com/documentation-theme-jekyll/) for jekyll

There are lots of files from the original template that have been left here for reference, but which aren't actually being used.

Most important things to know:

  + The main sidebar is _data/sidebars/home_sidebar.yml.   If you create a new page, find an appropriate header under which to place it.  As of now, this is the only sidebar being used
  + Links should not be relative as files can be moved around (all links should have a leading slash).
  + All images must include a width and height in order to be valid on the AMP version of the documentation. For example:
```
![Configure Admin User](/images/jenkins3.png){:width="1992px" height="1156px"}
```
  + Local references to files in this directory take the following form:  
 ```
 
[Create a PX-Enterprise Cluster](create-px-enterprise-cluster.html)  <br/>
 
 ```
Note the reference to a **".html"** file, which gets generated automatically by jekyll from the **".md"** file.


## Navigation

The sidebar for both the normal and AMP documentation is generated based on the contents of the menu datafile located at `_data/sidebars/home_sidebar.yml`. 
It is possible to nest (indefinitely) the contents of the navigation.

In order to have a new submenu rather than a link in a submenu the item must contain `folderitems`. 
Refer to the existing yaml file for more information.


## Table of Contents

Each Markdown page can have its own table of contents (a list which will anchor to every header in the document).

To add this to the documentation, add the following where you would like the list:

```
* TOC
{:toc}
```


## AMP Version

There is an AMP version of the documentation which is effectively a drop in replacement for the `page.html` layout. 
When you wish to generate the AMP documentation manually (production generation and deployment is automated), you must replace the `page.html` file in `_layouts/` with `amp.html` - this process may change in the future.

Documentation for AMP is built using Travis and is pushed to the `portworx/px-docs-amp` repository on Github. 
This repository is accessible at [https://docs-amp.portworx.com/](https://docs-amp.portworx.com/). 
Travis will only build upon new commits to the `gh-pages` branch (this will happen when you merge in using a Github pull request) and it may take a few minutes to build and push which means that the time to update AMP may be longer than that of the standard documentation.

Due to the limitations of AMP, there is no Javascript and therefore no Algolia Docsearch, this is replaced by a simple Google search form.


## Build px-docs locally

```
sudo gem install jekyll bundler
bundle install
bundle exec jekyll serve
```
Docs site will now be served locally at [http://127.0.0.1:4005/](http://127.0.0.1:4005/)


## Marketing Navigation

The navbar is copied from the top of the Portworx marketing website. 
To update the navigation, three steps are required:

 1. Copy the entire content of the `<nav>` from portworx.com (including the nav tag itself) to `_includes/topnav.html`.
 2. Copy the entire 6th section of [the Portworx marketing website's CSS file](https://portworx.com/wp-content/themes/portworx/css/master.css) to `_sass/marketing-nav.scss`.
 3. Build the site and test.

During the initial build there was numerous errors which needed to manually be addressed (these are at the bottom of the master CSS file). 
These should be checked: 

 * Font and text capitalisation
 * Elements disappearing on certain viewports

