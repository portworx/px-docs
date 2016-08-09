# Git-flavored Markdown

## Inline formatting

Paragraph with *italics* and **bold** and combined **_italic bold_**.

Paragraph with `code phrase` inline.

Two tildes to show ~~strikethrough~~.

<h2>Code</h2>

```
code sample
    code sample
    code sample
```

These indicate the language type for syntax highlighting.

```javascript
var s = "JavaScript syntax highlighting";
alert(s);
```

## Bullets
* Bullet
 * Sub-bullet <p>Indent</p>
* Bullet <p>Indent</p>


## Numbered Lists

1. numbered<p>indent</p>
2. numbered

### Blockquotes (use for Notes and Tips and Important)

> **Note:** <br/> This is something to pay attention to. This is something to pay attention to. This is something to pay attention to. This is something to pay attention to.

## Tables


|Table head|Table head 2|
|---|---|
|Table body|body|
|Table body|body|

Specify alignment with colons.

|Table head|Table head|
|---:|:---:|
|Table body|cell with a bit more text|
|Table |body|

## Links

[Inline-style link](https://www.google.com)

[Inline-style link with title](https://www.google.com "Google's Homepage")

[Reference-style link][Arbitrary case-insensitive reference text]

[Relative reference to a repository file](../blob/master/LICENSE)

Link to a heading within a page:

[Heading Text](#heading-text)

## Images

![alt text](https://nnn.com/logo.png "Logo Title Text 1")

### Videos

They can't be added directly but you can add an image with a link to the video like this:

<a href="http://www.youtube.com/watch?feature=player_embedded&v=YOUTUBE_VIDEO_ID_HERE
" target="_blank"><img src="http://img.youtube.com/vi/YOUTUBE_VIDEO_ID_HERE/0.jpg"
alt="IMAGE ALT TEXT HERE" width="96" height="72" border="10" /></a>

## Definition Lists

<dl>
  <dt>Definition list</dt>
  <dd>Is something people use sometimes.</dd>

  <dt>Markdown in HTML</dt>
  <dd>Does *not* work **very** well. Use HTML <em>tags</em>.</dd>
</dl>

## HRs
Use triple asterisks, dashes, or underlines.

***

---

___

## Experiments

|[This is a button](https://www.google.com)|
|---|

![Screen shot of Clusters page](/images/clusters.png)
