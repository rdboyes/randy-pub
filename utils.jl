function hfun_bar(vname)
    val = Meta.parse(vname[1])
    return round(sqrt(val), digits=2)
end

function hfun_m1fill(vname)
    var = vname[1]
    return pagevar("index", var)
end

function lx_baz(com, _)
    # keep this first line
    brace_content = Franklin.content(com.braces[1]) # input string
    # do whatever you want here
    return uppercase(brace_content)
end

function hfun_recent_posts(m::Vector{String})
    @assert length(m) == 1 "only one argument allowed for recent posts (the number of recent posts to pull)"
    n = parse(Int64, m[1])
    list = readdir("posts")
    filter!(f -> endswith(f, ".md") && f != "index.md", list)
    posts = []
    df = DateFormat("mm/dd/yyyy")
    for (k, post) in enumerate(list)
        fi = "posts/" * splitext(post)[1]
        title = pagevar(fi, :title)
        datestr = pagevar(fi, :date)
        if !isnothing(datestr)
            date = Date(datestr, df)
            push!(posts, (title=title, link=fi, date=date))
        end
    end

    markdown = "Dict{Date, String} with " *
        string(n >= 0 ? n : length(posts)) *
        " entrys:\n\n"

    # pull all posts if n <= 0
    n = n >= 0 ? n : length(posts) + 1

    for ele in sort(posts, by=x -> x.date, rev=true)[1:min(length(posts), n)]
        markdown *= "[$(ele.date) => \"$(ele.title)](../$(ele.link))\"\n\n"
    end

    return fd2html(markdown, internal=true)
end

function hfun_add_bsky_comments(post_url::Vector{String})
    post = post_url[1]
    html = "
        <script src=\"../bsky-comments.js\"></script>
        <bsky-comments post=\"$(post)\"></bsky-comments>
    "
    return html
end

@delay function hfun_all_posts()
    return hfun_recent_posts(["-1"])
end

@delay function hfun_tag_landing_page()
    PAGE_TAGS = Franklin.globvar("fd_page_tags")
    TAG_COUNT = Franklin.invert_dict(PAGE_TAGS)
    markdown = ""
    for k in sort(collect(keys(TAG_COUNT)))
        markdown *= "* [" * k * "](" * Franklin.joinpath("/tags/", k) * ") (" * string(length(TAG_COUNT[k])) * ")\n"
    end
    return fd2html(markdown, internal=true)
end
