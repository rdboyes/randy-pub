class BskyComments extends HTMLElement {
  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this.visibleCount = 3;
    this.thread = null;
    this.error = null;
  }

  connectedCallback() {
    const postUri = this.getAttribute("post");
    if (!postUri) {
      this.renderError("Post URI is required");
      return;
    }
    this.loadThread(postUri);
  }

  async loadThread(uri) {
    try {
      const thread = await this.fetchThread(uri);
      this.thread = thread;
      this.render();
    } catch (err) {
      this.renderError("Error loading comments");
    }
  }

  async fetchThread(uri) {
    if (!uri || typeof uri !== "string") {
      throw new Error("Invalid URI: A valid string URI is required.");
    }

    const params = new URLSearchParams({ uri });
    const url = `https://public.api.bsky.app/xrpc/app.bsky.feed.getPostThread?${params.toString()}`;

    try {
      const response = await fetch(url, {
        method: "GET",
        headers: {
          Accept: "application/json",
        },
        cache: "no-store",
      });

      if (!response.ok) {
        const errorText = await response.text();
        console.error("Fetch Error: ", errorText);
        throw new Error(`Failed to fetch thread: ${response.statusText}`);
      }

      const data = await response.json();

      if (!data.thread || !data.thread.replies) {
        throw new Error("Invalid thread data: Missing expected properties.");
      }

      return data.thread;
    } catch (error) {
      console.error("Error fetching thread:", error.message);
      throw error;
    }
  }

  render() {
    if (!this.thread || !this.thread.replies) {
      this.renderError("No comments found");
      return;
    }

    const sortedReplies = this.thread.replies.sort(
      (a, b) => (b.post.likeCount ?? 0) - (a.post.likeCount ?? 0),
    );

    const container = document.createElement("div");
    container.innerHTML = `
      <comments>
        <p class="reply-info">
          Reply on Bluesky
          <a href="https://bsky.app/profile/${this.thread.post?.author?.did}/post/${this.thread.post?.uri.split("/").pop()}" target="_blank" rel="noopener noreferrer">
            here
          </a> to join the conversation.
        </p>
        <div id="comments"></div>
        <button id="show-more">
          Show more comments
        </button>
      </comments>
    `;

    const commentsContainer = container.querySelector("#comments");
    sortedReplies.slice(0, this.visibleCount).forEach((reply) => {
      commentsContainer.appendChild(this.createCommentElement(reply));
    });

    const showMoreButton = container.querySelector("#show-more");
    if (this.visibleCount >= sortedReplies.length) {
      showMoreButton.style.display = "none";
    }
    showMoreButton.addEventListener("click", () => {
      this.visibleCount += 5;
      this.render();
    });

    this.shadowRoot.innerHTML = "";
    this.shadowRoot.appendChild(container);

    if (!this.hasAttribute("no-css")) {
      this.addStyles();
    }
  }

  escapeHTML(htmlString) {
    return htmlString
      .replace(/&/g, "&amp;") // Escape &
      .replace(/</g, "&lt;") // Escape <
      .replace(/>/g, "&gt;") // Escape >
      .replace(/"/g, "&quot;") // Escape "
      .replace(/'/g, "&#039;"); // Escape '
  }

  createCommentElement(reply) {
    const comment = document.createElement("div");
    comment.classList.add("comment");

    const author = reply.post.author;
    const text = reply.post.record?.text || "";

    comment.innerHTML = `
      <div class="author">
        <a href="https://bsky.app/profile/${author.did}" target="_blank" rel="noopener noreferrer">
          ${author.avatar ? `<img width="22px" src="${author.avatar}" />` : ""}
          ${author.displayName ?? author.handle} @${author.handle}
        </a>
        <p class="comment-text">${this.escapeHTML(text)}</p>
        <small class="comment-meta">
          ${reply.post.likeCount ?? 0} likes • ${reply.post.replyCount ?? 0} replies
        </small>
      </div>
    `;

    if (reply.replies && reply.replies.length > 0) {
      const repliesContainer = document.createElement("div");
      repliesContainer.classList.add("replies-container");

      reply.replies
        .sort((a, b) => (b.post.likeCount ?? 0) - (a.post.likeCount ?? 0))
        .forEach((childReply) => {
          repliesContainer.appendChild(this.createCommentElement(childReply));
        });

      comment.appendChild(repliesContainer);
    }

    return comment;
  }

  renderError(message) {
    this.shadowRoot.innerHTML = `<p class="error">${message}</p>`;
  }

  addStyles() {
    const style = document.createElement("style");
    style.textContent = `
      :host {
        --text-color: white;
        --link-color: gray;
        --link-hover-color: white;
        --comment-meta-color: white;
        --error-color: red;
        --reply-border-color: #ccc;
        --button-background-color: white;
        --button-hover-background-color: #1185FE;
        --author-avatar-border-radius: 100%;
      }

      comments {
        margin: 0 auto;
        padding: 1.2em;
        max-width: 720px;
        display: block;
        background-color: #242635;
        color: var(--text-color);
      }
      .reply-info {
        font-size: 14px;
        color: var(--text-color);
      }
      #show-more {
        text-color: white;
        margin-top: 10px;
        width: 100%;
        padding: 1em;
        font: inherit;
        box-sizing: border-box;
        background: var(--button-background-color);
        border-radius: 0.8em;
        cursor: pointer;
        border: 0;

        &:hover {
          background: var(--button-hover-background-color);
        }
      }
      .comment {
        margin-bottom: 2em;
      }
      .author {
        a {
          font-size: 0.9em;
          margin-bottom: 0.4em;
          display: inline-block;
          color: var(--link-color);

          &:not(:hover) {
            text-decoration: none;
          }

          &:hover {
            color: var(--link-hover-color);
          }

          img {
            margin-right: 0.4em;
            border-radius: var(--author-avatar-border-radius);
            vertical-align: middle;
          }
        }
      }
      .comment-text {
        margin: 5px 0;
        white-space: pre-line;
      }
      .comment-meta {
        color: var(--comment-meta-color);
        display: block;
        margin: 1em 0 2em;
      }
      .replies-container {
        border-left: 1px solid var(--reply-border-color);
        margin-left: 1.6em;
        padding-left: 1.6em;
      }
      .error {
        color: var(--error-color);
      }
    `;
    this.shadowRoot.appendChild(style);
  }
}

customElements.define("bsky-comments", BskyComments);
