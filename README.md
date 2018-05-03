# Portworx Documentation

This repository contains the files required to generate the Portworx Documentation (located at [docs.portworx.com](https://docs.portworx.com)). 
Building this repository locally is documented below and we welcome all pull requests from the community!


## Website and Repository Configuration

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

>**NOTE**:<br>
If you ancounter _"Liquid Exception: invalid byte sequence in US-ASCII in ..."_ error,
you should set the LC_CTYPE/LANG environment variables to UTF-8, like so:<br>
`env LC_CTYPE=en_US.UTF-8 LANG=en_US.UTF-8 bundle exec jekyll serve --port 8088 --host 0.0.0.0`

## Useful Development Notes

There are lots of files from the original template that have been left here for reference, but which aren't actually being used.

Most important things to know:

 - The main sidebar is `_data/sidebars/home_sidebar.yml`. 
   If you create a new page, find an appropriate header under which to place it. 
   As of now, this is the only sidebar being used.d
 - Links should not be relative as files can be moved around (all links should have a leading slash).
 - All images must include a width and height in order to be valid on the AMP version of the documentation. 
   For example:
```
![Configure Admin User](/images/jenkins3.png){:width="1992px" height="1156px"}
```
 - Local references to files in this directory take the following form:  
``` 
[Create a PX-Enterprise Cluster](create-px-enterprise-cluster.html)  <br/>
```
Note the reference to a **".html"** file, which gets generated automatically by jekyll from the **".md"** file.
 - When CSS is changed, so should the "critical" inline CSS. 
   This is used to ensure that the page loads essential CSS quickly, documentation on this is below.


### Navigation

The sidebar for both the normal and AMP documentation is generated based on the contents of the menu datafile located at `_data/sidebars/home_sidebar.yml`. 
It is possible to nest (indefinitely) the contents of the navigation.

In order to have a new submenu rather than a link in a submenu the item must contain `folderitems`. 
Refer to the existing yaml file for more information.


### Table of Contents

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


### Critical CSS

The Portworx documentation tries to load essential CSS inline with each page, this is to improve initial page load speed and to avoid the page re-rendering whilst it loads. 
To achieve this we use [critical](https://github.com/addyosmani/critical).

#### Generate a New Critical File

```
$ # First empty the existing critical file
$ echo '' > _includes/critical.css
$ # Allow the documentation to finish building with no inline styles
$ npm install --save critical # NodeJS must be installed, refer to https://nodejs.org/en/download/
$ critical _site/index.html --base _site/ > _includes/critical.css
```

Once the site is built again, ensure responsiveness works correctly by adjusting the page width a few times.

If you encounter issues with Critical, ensure PhantomJS is installed on your system.


### Blocks From Marketing Website

Currently there are two blocks from the marketing website; the header and footer. 
These are relatively simply to update and should be done in two phases, the content block itself and then the CSS.

The content of `_sass/marketing-styles.scss` is exactly the same content from that of the [`master.css` file on the marketing 
website](https://portworx.com/wp-content/themes/portworx/css/master.css) however it has the "charset" property stripped out. 
This is included by the documentation CSS bundle and wrapped in the `.marketing-styles` class.

`_includes/footer.html` contains a 1:1 copy of the `<footer>` block from portworx.com. 
This can be copied as-is.

The same applies for `_includes/topnav.html` and the `<nav>` block. 
This can also be copied as-is.

When these two files are included they should be wrapped in a `div` containing the `.marketing-styles` class to ensure they inherit the relevant CSS styles.

It's also possible for inconsistencies between the marketing site due to global styles in the marketing CSS itself. 
These should be overwritten in `_sass/marketing-nav.scss` and `_sass/marketing-footer.scss`.

To avoid malformed content, do not copy these blocks from a page which passed through Cloudflare. 
Either bypass Cloudflare or run the website locally if possible.

> **Note:** A script to do this from MacOS is included at `./build/marketing-blocks.sh`.


### External Videos

There are helpers to correctly load in videos from Youtube and Vimeo. 
Whenever adding a new video, these should be used to ensure that the video renders correctly and works well on the AMP representation of the documentation.

To include a Youtube video:

```
{%
    include youtubePlayer.html
    id = "<Youtube video ID>"
    date = "2017-03-17"
    title = "Title of the video (H2 above the video and description))"
    description = "Description of the video which is below the title"
%}
```

Identical syntax can be used for Vimeo (however replace `youtubePlayer.html` with `vimeoPlayer.html`).

The date *must* be in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.


## Template

The initial implementation of this documentation design comes from [I'd Rather Be Writing](http://idratherbewriting.com/documentation-theme-jekyll/).


## Testing

Tests take place on Travis and can be ran locally. 
Refer to the `build/` directory for more information and test scripts.
