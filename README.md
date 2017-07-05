# Portworx Documentation

This repository contains the files required to generate the Portworx Documentation (located at [docs.portworx.com](https://docs.portworx.com)). 
Building this repository locally is documented below and we welcome all pull requests from the community!


## Website and Reposotiry Configuration

The Portworx documentation is built on top of [Jekyll](https://jekyllrb.com/) and is current hosted on [GitHub Pages](https://pages.github.com/).
GitHub pages is aware of our domain name as it is specified in the `CNAME` file located in the base of this repository.

Sitting in front of Github Pages we use Cloudflare. 
This is added to allow us to serve the documentation over HTTPS and provide the Portworx documentation with a free CDN.

This repository serves the contents of the `gh-pages` branch. 
Changes should be merged into here for it to appear on the live documentation.


## Building the Documentation Locally

Building locally can be useful for contributing to the documentation and debugging. 
To build locally you will require Jekyll (we recommend the version which Github pages provides in order to prevent inconsistencies).

Ruby will be required before running these steps.

```
sudo gem install bundler
```

Once you're done, navigate to the checked out repository and install the locally required packages with Bundler.

```
bundle install
```

That's all! 
From now yon you can serve the documentation by running:

```
bundle exec jekyll serve
```

The documentation will now be accessible locally at [http://127.0.0.1:4005/](http://127.0.0.1:4005/).


## Useful Development Notes

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


### Navigation

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


### AMP Version

There is an AMP version of the documentation which is effectively a drop in replacement for the `page.html` layout. 
When you wish to generate the AMP documentation manually (production generation and deployment is automated), you must replace the `page.html` file in `_layouts/` with `amp.html` - this process may change in the future.

Documentation for AMP is built using Travis and is pushed to the `portworx/px-docs-amp` repository on Github. 
This repository is accessible at [https://docs-amp.portworx.com/](https://docs-amp.portworx.com/). 
Travis will only build upon new commits to the `gh-pages` branch (this will happen when you merge in using a Github pull request) and it may take a few minutes to build and push which means that the time to update AMP may be longer than that of the standard documentation.

Due to the limitations of AMP, there is no Javascript and therefore no Algolia Docsearch, this is replaced by a simple Google search form.


## Template

The initial implementation of this documentation design comes from [I'd Rather Be Writing](http://idratherbewriting.com/documentation-theme-jekyll/).
