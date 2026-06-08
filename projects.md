+++
title = "Projects"
hascode = true
date = Date(2025, 11, 10)
rss = "A list of selected projects."
+++

~~~
<div class="repl" id="repl">
  <div class="repl-history" id="repl-history">
    <div class="repl-comment"># try: TidierPlots (or `?` for the full list)</div>
  </div>
  <div class="repl-inputline">
    <span class="jl-green">julia></span>
    <input type="text" id="repl-input" class="repl-input" autocomplete="off"
           autocorrect="off" autocapitalize="off" spellcheck="false" aria-label="Julia prompt" />
  </div>
  <noscript>
    Enable JavaScript for the interactive prompt, or see the links below.
    <ul>
      <li><a href="https://presagegroup.com/">PresageWebsite</a></li>
      <li><a href="https://presagegroup.com/pages/services/fit-for-flight/">FitForFlight</a></li>
      <li><a href="https://github.com/TidierOrg/TidierPlots.jl">TidierPlots</a></li>
      <li><a href="https://github.com/TidierOrg/positron-julia">positron-julia</a></li>
      <li><a href="https://github.com/rboyes/Firebase.jl">Firebase.jl</a></li>
      <li><a href="https://github.com/Presage-Group/Sentry.jl">Sentry.jl</a></li>
      <li><a href="https://github.com/Presage-Group/lineaR">lineaR</a></li>
      <li><a href="https://github.com/rdboyes/forester">forester</a></li>
    </ul>
  </noscript>
</div>

<script>
(function () {
  const projects = {
    presagewebsite: {
      name: "PresageWebsite",
      category: "Website",
      language: "Astro",
      link: "https://presagegroup.com/",
      linktext: "presagegroup.com",
      year: 2026,
      desc: "The corporate website for Presage Group Inc., built with Astro for fast, content-driven static delivery."
    },
    fitforflight: {
      name: "FitForFlight",
      category: "Website",
      language: "Next.js",
      link: "https://presagegroup.com/pages/services/fit-for-flight/",
      linktext: "Fit for Flight",
      year: 2025,
      desc: "A Next.js web application supporting Presage Group's Fit for Flight aviation safety service."
    },
    tidierplots: {
      name: "TidierPlots",
      category: "GitHub",
      language: "Julia",
      link: "https://github.com/TidierOrg/TidierPlots.jl",
      linktext: "TidierPlots.jl",
      year: 2024,
      desc: "A Julia plotting package implementing a ggplot2-style grammar of graphics on top of Makie."
    },
    positronjulia: {
      name: "positron-julia",
      category: "GitHub",
      language: "Julia",
      link: "https://github.com/TidierOrg/positron-julia",
      linktext: "positron-julia",
      year: 2026,
      desc: "A Julia language extension for the Positron IDE."
    },
    firebasejl: {
      name: "Firebase.jl",
      category: "GitHub",
      language: "Julia",
      link: "https://github.com/rboyes/Firebase.jl",
      linktext: "Firebase.jl",
      year: 2025,
      desc: "A Julia wrapper for the Firebase REST API (maintainer)."
    },
    sentryjl: {
      name: "Sentry.jl",
      category: "GitHub",
      language: "Julia",
      link: "https://github.com/Presage-Group/Sentry.jl",
      linktext: "Sentry.jl",
      year: 2025,
      desc: "A Julia SDK for the Sentry error-tracking platform."
    },
    linear: {
      name: "lineaR",
      category: "GitHub",
      language: "R",
      link: "https://github.com/Presage-Group/lineaR",
      linktext: "lineaR",
      year: 2025,
      desc: "An R wrapper for the Linear GraphQL API."
    },
    forester: {
      name: "forester",
      category: "GitHub",
      language: "R",
      link: "https://github.com/rdboyes/forester",
      linktext: "forester",
      year: 2021,
      desc: "An R package for easy, publication-ready forest plots."
    }
  };

  const history = document.getElementById("repl-history");
  const input = document.getElementById("repl-input");
  const repl = document.getElementById("repl");

  const norm = (s) => s.toLowerCase().replace(/[^a-z0-9]/g, "");
  const esc = (s) => s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  const pad = (s) => (s + "        ").slice(0, 8);

  function el(html) {
    const d = document.createElement("div");
    d.innerHTML = html.trim();
    return d.firstChild;
  }

  function echo(text) {
    history.appendChild(
      el('<div class="repl-line"><span class="jl-green">julia&gt;</span> ' + esc(text) + "</div>")
    );
  }

  function field(key, value) {
    return '<div>  ' + pad(key) + ' : ' + value + '</div>';
  }

  function showProject(p) {
    const html =
      '<div class="repl-result">' +
        '<div><span class="jl-yellow">Project</span>(<span class="jl-string">"' + esc(p.name) + '"</span>)</div>' +
        field("category", esc(p.category)) +
        field("language", esc(p.language)) +
        field("link", '<a href="' + esc(p.link) + '" target="_blank" rel="noopener">' + esc(p.linktext) + "</a>") +
        field("year", '<span class="jl-magenta">' + p.year + "</span>") +
        '<div class="repl-desc">' + esc(p.desc) + "</div>" +
      "</div>";
    history.appendChild(el(html));
  }

  function showList() {
    history.appendChild(el(
      '<div class="repl-result">' +
        Object.values(projects)
          .map((p) => '<div>  <span class="jl-blue repl-cmd" data-cmd="' + esc(p.name) + '">' + esc(p.name) + "</span> &mdash; " + esc(p.language) + " (" + p.year + ")</div>")
          .join("") +
      "</div>"
    ));
  }

  // Authentic Symbol display: bare :name when it's a valid identifier,
  // Symbol("name") otherwise (e.g. dotted or hyphenated names).
  function symbolRepr(name) {
    return /^[A-Za-z_][A-Za-z0-9_!]*$/.test(name)
      ? ":" + esc(name)
      : 'Symbol("' + esc(name) + '")';
  }

  function showNames() {
    const vals = Object.values(projects);
    history.appendChild(el(
      '<div class="repl-result">' +
        "<div>" + vals.length + "-element Vector{Symbol}:</div>" +
        vals.map((p) => "<div> " + symbolRepr(p.name) + "</div>").join("") +
      "</div>"
    ));
  }

  function error(msg) {
    history.appendChild(el('<div class="repl-result repl-error"><span class="jl-red">ERROR:</span> ' + esc(msg) + "</div>"));
  }

  function run(raw) {
    const cmd = raw.trim();
    echo(cmd);
    if (cmd === "") return;

    const key = norm(cmd);
    if (key === "" || key === "help") {
      showList();
      return;
    }
    if (key === "namesmain" || key === "names") {
      showNames();
      return;
    }
    if (key === "clear" || key === "cls") {
      history.innerHTML = "";
      return;
    }

    const p = projects[key];
    if (p) {
      showProject(p);
    } else {
      error("UndefVarError: `" + cmd + "` not defined");
    }
  }

  input.addEventListener("keydown", function (e) {
    if (e.key === "Enter") {
      run(input.value);
      input.value = "";
      input.scrollIntoView({ block: "nearest" });
    }
  });

  // Clicking a name in the list runs it as if it were typed at the prompt;
  // clicking anywhere else in the terminal just focuses the prompt.
  repl.addEventListener("click", function (e) {
    const cmd = e.target.closest(".repl-cmd");
    if (cmd) {
      run(cmd.getAttribute("data-cmd"));
      input.value = "";
      input.scrollIntoView({ block: "nearest" });
    }
    if (e.target.tagName !== "A") input.focus();
  });
})();
</script>
~~~
