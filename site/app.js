const capabilityCopy = {
  resolve: {
    title: "Deterministic transitive resolution",
    body:
      "Parse registry rows, match version requirements, select compatible package versions, and write stable lock output for downstream tools.",
    points: [
      "Semantic version and requirement parsing",
      "Stable lock format with readback",
      "Text graph and Graphviz DOT output",
    ],
  },
  explain: {
    title: "Conflict reports reviewers can follow",
    body:
      "Convert resolver failures into structured reports that preserve package name, requirement, selected version, dependency path, and available candidates.",
    points: [
      "Missing package and no-matching-version cases",
      "Selected-version conflict paths",
      "Candidate versions sorted for review",
    ],
  },
  upgrade: {
    title: "Exact bounded upgrade planning",
    body:
      "Plan add, remove, upgrade, and downgrade changes with either highest-compatible or minimal-change strategies.",
    points: [
      "Minimal changed-package count",
      "Deterministic higher-version tie breaker",
      "SearchLimitExceeded instead of false optimums",
    ],
  },
};

const panel = document.querySelector("#capability-panel");
document.querySelectorAll(".tab").forEach((button) => {
  button.addEventListener("click", () => {
    const key = button.dataset.tab;
    const content = capabilityCopy[key];
    if (!content || !panel) return;

    document.querySelectorAll(".tab").forEach((tab) => {
      const active = tab === button;
      tab.classList.toggle("is-active", active);
      tab.setAttribute("aria-selected", String(active));
    });

    panel.innerHTML = `
      <h3>${content.title}</h3>
      <p>${content.body}</p>
      <ul>${content.points.map((point) => `<li>${point}</li>`).join("")}</ul>
    `;
  });
});

document.querySelectorAll(".copy-button").forEach((button) => {
  button.addEventListener("click", async () => {
    const id = button.dataset.copy;
    const block = id ? document.getElementById(id) : null;
    const text = block ? block.innerText.trim() : "";
    if (!text) return;

    try {
      await navigator.clipboard.writeText(text);
      const original = button.textContent;
      button.textContent = "Copied";
      setTimeout(() => {
        button.textContent = original;
      }, 1200);
    } catch {
      button.textContent = "Select";
    }
  });
});
