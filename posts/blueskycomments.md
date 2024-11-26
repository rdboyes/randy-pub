@def title = "Bluesky comments sections in Franklin.jl"
@def date = "11/26/2024"
@def tags = ["julia", "BlueSky"]

@def rss_pubdate = Date(2024, 11, 26)

## Adding a comments section from BlueSky

This [post](https://emilyliu.me/blog/comments) shows how you can add Bluesky posts as blog comments in general, and the code was added to an npm package [here](https://www.npmjs.com/package/bluesky-comments). We can steal that code to add it to a Franklin.jl site easily. Download the bsky-comments.js file [here](https://gist.githubusercontent.com/LoueeD/b7dec10b2ea56c825cbb0b3a514720ed/raw/1caceb84ec7612503db3a955a55af4501bcf0150/bsky-comments.js) (or grab my slightly modified one from this website's github repo under posts/bsky-comments.js) and add the following function to your utils.jl file:

```
function hfun_add_bsky_comments(post_url::Vector{String})
    post = post_url[1]
    html = "
        <script src=\"../bsky-comments.js\"></script>
        <bsky-comments post=\"$(post)\"></bsky-comments>
    "
    return html
end
```

Now add the following to the end of your post markdown (data-bluesky-uri can be seen if you click "embed post" on any post, amoung other places):

```
{{ add_bsky_comments data-bluesky-uri_of_your_post_in_quotes }}
```

Which should give you:

{{ add_bsky_comments "at://did:plc:2h5e6whhbk5vnnerqqoi256k/app.bsky.feed.post/3lbupbkcn4s2n" }}

---
