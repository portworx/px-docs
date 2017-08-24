# Portworx Documentation Testing

The Portworx documentation is tested to prevent new issues from occuring such as broken links and errors in AMP.

Testing currently occurs on Travis as it is a free service for open source projects. 
The test manifest can be found at the root of this repository in `.travis.yml`.


## Common Failures

If you see an error along the lines of "The implied layout 'CONTAINER' is not supported by tag 'amp-img'", this means an image's width and height attribute have not been
set. These are required for AMP validity.

If you see "The tag 'xxx' is disallowed.' then it's likely that "<" and ">" have been used to quote some text in the markdown document being generated. These are interpreted
as HTML tags and should be replaced with the relevant HTML entities (`&lt;` and `&gt;`).

Redirects are removed before link checking. This is to ensure that people are not being directed to pages indirectly. It's possible to fail a link check if something is
linked to a redirect, all referenced pages should simply be updated to point to the redirects target.


## Test Flow

 - Build site normally
 - Remove redirect pages
 - Run tests
 - Build AMP version of docs
 - Validate AMP
 - Push AMP to Git (if commit to `gh-pages`)
