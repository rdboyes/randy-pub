+++
title = "Publications"
hascode = true
date = Date(2019, 3, 22)
rss = "A list of working papers and publications."
+++

~~~
<span style="color:#70C66B;">julia></span>
<span style="color:#5BC5E2;">print</span>(Publications)
~~~

**GroupedDataFrame with 4 groups based on key: type**

### First Group (5 rows): type = "Open Source Software"

{{ make_table

    "Julia" "Firebase.jl (Maintaining)"
    "https://github.com/rboyes/Firebase.jl" "GitHub" "2025"

    "R" "lineaR: Linear GraphQL API Wrapper for R"
    "https://github.com/Presage-Group/lineaR" "GitHub" "2025"

    "Julia" "Sentry.jl: Julia Sentry SDK"
    "https://github.com/Presage-Group/Sentry.jl" "GitHub" "2025"

    "Julia" "TidierPlots.jl: ggplot2 for julia"
    "https://github.com/TidierOrg/TidierPlots.jl" "GitHub" "2024"

    "R" "Forester: Easy publication-ready forest plots"
    "https://github.com/rdboyes/forester" "GitHub" "2021"
}}

### Second Group (3 rows): type = "Preprints"

{{ make_table

  "Aviation"
  "Optimizing Aerospace Sustainability Outputs: Understanding How Negative Emotions from Barriers to Personal Achievement Affect Researchers, Product Developers, Trainers, and Recruiters"
  "https://osf.io/preprints/socarxiv/ys32x_v1"
  "OSF"
  "2025"

  "Play"
  "Development of a Neighbourhood Playability Index"
  "https://qspace.library.queensu.ca/items/2b30c32e-0a13-4929-ae2a-7bd2fc0c34cd"
  "Thesis"
  "2023"

  "Play"
  "Development and Validation of a Canadian Index of Neighbourhood Playability"
  "https://qspace.library.queensu.ca/items/2b30c32e-0a13-4929-ae2a-7bd2fc0c34cd"
  "Thesis"
  "2023"
}}

### Third Group (12 rows): type = "Published Work ([Google Scholar](https://scholar.google.ca/citations?hl=en&user=T7SV6T0AAAAJ&view_op=list_works&sortby=pubdate))"

{{ make_table_from_csv "_assets/pubs.csv"}}

### Last Group (2 rows): type = "Talks"

{{ make_table
    "Software"
    "What's New in TidierPlots.jl"
    "https://www.youtube.com/live/HMdBi9Lrbes?si=G1oNC_ibjsfMbAK7&t=376"
    "Juliacon"
    "2025"

    "Software"
    "Introduction to TidierPlots.jl"
    "https://www.youtube.com/watch?v=33yik1ciUWE"
    "Juliacon"
    "2024"
}}

---
