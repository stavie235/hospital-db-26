const state = {
  queries: [],
  activeQueryId: null,
  activeResult: null,
  activeCategory: "All",
  resultFilter: "",
  currentPage: 1,
  pageSize: 50,
  schema: [],
};

const palette = ["#f59e0b", "#2dd4bf", "#60a5fa", "#f87171", "#a78bfa", "#34d399"];

const elements = {
  savedQueryList: document.getElementById("saved-query-list"),
  queryFilter: document.getElementById("query-filter"),
  categoryFilter: document.getElementById("category-filter"),
  schemaFilter: document.getElementById("schema-filter"),
  schemaList: document.getElementById("schema-list"),
  refreshSchema: document.getElementById("refresh-schema"),
  activeQueryTitle: document.getElementById("active-query-title"),
  activeQueryDescription: document.getElementById("active-query-description"),
  connectionStatus: document.getElementById("connection-status"),
  sqlEditor: document.getElementById("sql-editor"),
  runQuery: document.getElementById("run-query"),
  resetQuery: document.getElementById("reset-query"),
  copySql: document.getElementById("copy-sql"),
  lastRunMeta: document.getElementById("last-run-meta"),
  resultsSummary: document.getElementById("results-summary"),
  resultFilter: document.getElementById("result-filter"),
  pageSize: document.getElementById("page-size"),
  exportCsv: document.getElementById("export-csv"),
  prevPage: document.getElementById("prev-page"),
  nextPage: document.getElementById("next-page"),
  pageMeta: document.getElementById("page-meta"),
  resultsTableHead: document.querySelector("#results-table thead"),
  resultsTableBody: document.querySelector("#results-table tbody"),
  visualization: document.getElementById("visualization"),
  jsonOutput: document.getElementById("json-output"),
  queryNotes: document.getElementById("query-notes"),
  tabs: Array.from(document.querySelectorAll(".tab")),
  tabPanels: {
    table: document.getElementById("table-tab"),
    visual: document.getElementById("visual-tab"),
    json: document.getElementById("json-tab"),
  },
};

async function loadInitialState() {
  const queriesResponse = await fetchJson("/api/queries");
  state.queries = queriesResponse.queries;
  state.activeQueryId = queriesResponse.defaultQueryId;

  renderCategories();
  renderSavedQueries();
  applyActiveQuery(state.activeQueryId);
  await refreshSchema();
}

async function fetchJson(url, options = {}) {
  const response = await fetch(url, options);
  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error || "Request failed.");
  }
  return data;
}

function getActiveQuery() {
  return state.queries.find((query) => query.id === state.activeQueryId) || null;
}

function applyActiveQuery(queryId) {
  state.activeQueryId = queryId;
  const query = getActiveQuery();
  if (!query) {
    return;
  }

  elements.activeQueryTitle.textContent = query.title;
  elements.activeQueryDescription.textContent = query.description;
  elements.sqlEditor.value = query.sql;
  renderSavedQueries();
  renderNotes(query);
}

function renderCategories() {
  const categories = ["All", ...new Set(state.queries.map((query) => query.category))];
  elements.categoryFilter.innerHTML = "";

  categories.forEach((category) => {
    const button = document.createElement("button");
    button.className = "segment";
    button.type = "button";
    button.textContent = category;
    button.classList.toggle("is-active", category === state.activeCategory);
    button.addEventListener("click", () => {
      state.activeCategory = category;
      renderCategories();
      renderSavedQueries();
    });
    elements.categoryFilter.appendChild(button);
  });
}

function renderSavedQueries() {
  const template = document.getElementById("saved-query-template");
  const filter = elements.queryFilter.value.trim().toLowerCase();
  elements.savedQueryList.innerHTML = "";

  const filteredQueries = state.queries
    .filter((query) => {
      if (state.activeCategory !== "All" && query.category !== state.activeCategory) {
        return false;
      }
      if (!filter) {
        return true;
      }
      return [query.title, query.description, query.category].join(" ").toLowerCase().includes(filter);
    });

  if (!filteredQueries.length) {
    elements.savedQueryList.innerHTML = `<div class="empty-state compact">No saved searches match.</div>`;
    return;
  }

  filteredQueries.forEach((query) => {
      const fragment = template.content.cloneNode(true);
      const button = fragment.querySelector(".saved-query-card");
      fragment.querySelector(".saved-query-category").textContent = query.category;
      fragment.querySelector(".saved-query-title").textContent = query.title;
      fragment.querySelector(".saved-query-description").textContent = query.description;
      if (query.id === state.activeQueryId) {
        button.classList.add("is-active");
      }
      button.addEventListener("click", () => applyActiveQuery(query.id));
    elements.savedQueryList.appendChild(fragment);
  });
}

function renderSchema() {
  const filter = elements.schemaFilter.value.trim().toLowerCase();
  elements.schemaList.innerHTML = "";

  const filteredTables = state.schema
    .map((table) => ({
      ...table,
      columns: table.columns.filter((column) => {
        if (!filter) {
          return true;
        }
        return `${table.name} ${column.name} ${column.type}`.toLowerCase().includes(filter);
      }),
    }))
    .filter((table) => !filter || table.name.toLowerCase().includes(filter) || table.columns.length);

  if (!filteredTables.length) {
    elements.schemaList.innerHTML = `<div class="empty-state compact">No schema entries found.</div>`;
    return;
  }

  filteredTables.forEach((table) => {
    const group = document.createElement("div");
    group.className = "schema-group";

    const toggle = document.createElement("button");
    toggle.className = "schema-toggle";
    toggle.type = "button";
    toggle.appendChild(makeSpan(table.name));
    toggle.appendChild(makeSpan(`${table.columns.length} cols`));

    const columns = document.createElement("div");
    columns.className = "schema-columns";
    columns.hidden = !filter;

    table.columns.forEach((column) => {
      const row = document.createElement("button");
      row.className = "schema-column schema-toggle";
      row.type = "button";
      row.appendChild(makeSpan(column.name));
      row.appendChild(makeSpan(column.type));
      row.addEventListener("click", () => {
        elements.sqlEditor.value = `SELECT ${quoteIdentifier(column.name)}\nFROM ${quoteIdentifier(table.name)}\nLIMIT 100;`;
      });
      columns.appendChild(row);
    });

    toggle.addEventListener("click", (event) => {
      if (event.target === toggle || toggle.contains(event.target)) {
        columns.hidden = !columns.hidden;
      }
    });
    toggle.addEventListener("dblclick", () => {
      elements.sqlEditor.value = buildTablePreviewSql(table);
    });

    group.appendChild(toggle);
    group.appendChild(columns);
    elements.schemaList.appendChild(group);
  });
}

function renderNotes(query) {
  const visualization = query.visualization?.type || "auto";
  elements.queryNotes.innerHTML = `
    <section class="notes-section">
      <h3>Saved Query</h3>
      <p>${query.description}</p>
    </section>
    <section class="notes-section">
      <h3>Category</h3>
      <p>${query.category}</p>
    </section>
    <section class="notes-section">
      <h3>Visualization Mode</h3>
      <p>${visualization}</p>
    </section>
    <section class="notes-section">
      <h3>Editor Hint</h3>
      <p>The app only accepts read-only SQL: <code>SELECT</code>, <code>WITH</code>, <code>SHOW</code>, <code>DESCRIBE</code>, and <code>EXPLAIN</code>.</p>
    </section>
  `;
}

async function runQuery() {
  const query = getActiveQuery();
  const sql = elements.sqlEditor.value;
  setRunning(true);
  elements.lastRunMeta.textContent = "Running query...";

  try {
    const result = await fetchJson("/api/query", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ queryId: query?.id, sql }),
    });

    state.activeResult = result;
    state.currentPage = 1;
    state.resultFilter = "";
    elements.resultFilter.value = "";
    renderResult(result, query);
  } catch (error) {
    state.activeResult = null;
    renderError(error.message);
  } finally {
    setRunning(false);
  }
}

function setRunning(isRunning) {
  elements.runQuery.disabled = isRunning;
  elements.runQuery.textContent = isRunning ? "Running..." : "Run Query";
}

function renderResult(result, query) {
  const meta = `${result.rowCount} rows in ${result.durationMs} ms${result.truncated ? " (preview truncated)" : ""}`;
  elements.lastRunMeta.textContent = meta;
  elements.jsonOutput.textContent = JSON.stringify(result, null, 2);
  elements.exportCsv.disabled = !(result.columns || []).length;

  renderCurrentTable();
  renderVisualization(result, query);
}

function renderError(message) {
  elements.lastRunMeta.textContent = "Query failed.";
  elements.resultsSummary.textContent = message;
  elements.resultsTableHead.innerHTML = "";
  elements.resultsTableBody.innerHTML = "";
  elements.jsonOutput.textContent = JSON.stringify({ error: message }, null, 2);
  elements.visualization.innerHTML = `<div class="empty-state">${escapeHtml(message)}</div>`;
  elements.exportCsv.disabled = true;
  elements.prevPage.disabled = true;
  elements.nextPage.disabled = true;
  elements.pageMeta.textContent = "Page 0 of 0";
}

function renderCurrentTable() {
  if (!state.activeResult) {
    return;
  }

  const columns = state.activeResult.columns || [];
  const rows = getFilteredRows();
  const pageCount = Math.max(1, Math.ceil(rows.length / state.pageSize));
  state.currentPage = Math.min(state.currentPage, pageCount);
  const startIndex = (state.currentPage - 1) * state.pageSize;
  const pagedRows = rows.slice(startIndex, startIndex + state.pageSize);

  renderTable(columns, pagedRows);

  const totalRows = state.activeResult.rows?.length || 0;
  const rowLabel = state.resultFilter ? `${rows.length} of ${totalRows} preview rows` : `${totalRows} preview rows`;
  elements.resultsSummary.textContent = `${state.activeResult.rowCount} total rows, ${rowLabel}`;
  elements.pageMeta.textContent = columns.length ? `Page ${state.currentPage} of ${pageCount}` : "Page 0 of 0";
  elements.prevPage.disabled = !columns.length || state.currentPage <= 1;
  elements.nextPage.disabled = !columns.length || state.currentPage >= pageCount;
}

function getFilteredRows() {
  const rows = state.activeResult?.rows || [];
  const filter = state.resultFilter.trim().toLowerCase();
  if (!filter) {
    return rows;
  }
  return rows.filter((row) =>
    Object.values(row).some((value) => String(value ?? "").toLowerCase().includes(filter))
  );
}

function renderTable(columns, rows) {
  elements.resultsTableHead.innerHTML = "";
  elements.resultsTableBody.innerHTML = "";

  if (!columns.length) {
    elements.resultsTableBody.innerHTML = `<tr><td>No columns returned.</td></tr>`;
    return;
  }

  const headerRow = document.createElement("tr");
  columns.forEach((column) => {
    const th = document.createElement("th");
    th.textContent = column;
    headerRow.appendChild(th);
  });
  elements.resultsTableHead.appendChild(headerRow);

  if (!rows.length) {
    const row = document.createElement("tr");
    const td = document.createElement("td");
    td.colSpan = columns.length;
    td.textContent = state.resultFilter ? "No rows match the filter." : "Query returned no rows.";
    row.appendChild(td);
    elements.resultsTableBody.appendChild(row);
    return;
  }

  rows.forEach((record) => {
    const row = document.createElement("tr");
    columns.forEach((column) => {
      const td = document.createElement("td");
      td.textContent = record[column] ?? "";
      row.appendChild(td);
    });
    elements.resultsTableBody.appendChild(row);
  });
}

function renderVisualization(result, query) {
  const rows = result.rows || [];
  const columns = result.columns || [];
  elements.visualization.innerHTML = "";

  if (!rows.length) {
    elements.visualization.innerHTML = `<div class="empty-state">No rows to visualize.</div>`;
    return;
  }

  const visualization = query?.visualization || inferVisualization(columns, rows);
  const metrics = maybeRenderMetrics(rows);
  if (metrics) {
    elements.visualization.appendChild(metrics);
  }

  if (!visualization || visualization.type === "table") {
    const message = document.createElement("div");
    message.className = "empty-state";
    message.textContent = "This saved search is best inspected as a table.";
    elements.visualization.appendChild(message);
    return;
  }

  if (visualization.type === "bar") {
    elements.visualization.appendChild(renderBarChart(rows, visualization.xKey, visualization.yKeys));
    return;
  }

  if (visualization.type === "line") {
    elements.visualization.appendChild(renderLineChart(rows, visualization.xKey, visualization.yKeys));
    return;
  }

  if (visualization.type === "donut") {
    elements.visualization.appendChild(renderDonutChart(rows, visualization.labelKey, visualization.valueKey));
    return;
  }

  const message = document.createElement("div");
  message.className = "empty-state";
  message.textContent = "Visualization mode not recognized.";
  elements.visualization.appendChild(message);
}

async function refreshSchema() {
  elements.refreshSchema.disabled = true;
  elements.connectionStatus.textContent = "Checking database";
  try {
    const schemaResponse = await fetchJson("/api/schema");
    state.schema = schemaResponse.tables;
    renderSchema();
    elements.connectionStatus.textContent = "MariaDB ready";
  } catch (error) {
    state.schema = [];
    renderSchema();
    elements.connectionStatus.textContent = "Database offline";
    elements.lastRunMeta.textContent = error.message;
  } finally {
    elements.refreshSchema.disabled = false;
  }
}

function maybeRenderMetrics(rows) {
  if (rows.length !== 1) {
    return null;
  }
  const numericEntries = Object.entries(rows[0]).filter(([, value]) => Number.isFinite(Number(value)));
  if (!numericEntries.length) {
    return null;
  }

  const card = document.createElement("section");
  card.className = "chart-card";
  card.innerHTML = `<h3 class="chart-title">Key Metrics</h3>`;

  const grid = document.createElement("div");
  grid.className = "metric-grid";
  numericEntries.forEach(([label, value]) => {
    const metric = document.createElement("div");
    metric.className = "metric";
    metric.innerHTML = `
      <div class="metric-label">${escapeHtml(label)}</div>
      <div class="metric-value">${formatNumber(value)}</div>
    `;
    grid.appendChild(metric);
  });
  card.appendChild(grid);
  return card;
}

function inferVisualization(columns, rows) {
  if (columns.length >= 2) {
    const yKeys = columns.slice(1).filter((column) => rows.every((row) => Number.isFinite(Number(row[column]))));
    if (yKeys.length) {
      return { type: "bar", xKey: columns[0], yKeys };
    }
  }
  return { type: "table" };
}

function renderBarChart(rows, xKey, yKeys) {
  const card = document.createElement("section");
  card.className = "chart-card";
  card.innerHTML = `<h3 class="chart-title">Comparison View</h3>`;

  const width = 880;
  const height = 360;
  const margin = { top: 20, right: 20, bottom: 90, left: 60 };
  const chartWidth = width - margin.left - margin.right;
  const chartHeight = height - margin.top - margin.bottom;
  const maxValue = Math.max(
    ...rows.flatMap((row) => yKeys.map((key) => Number(row[key]) || 0)),
    1
  );
  const groupWidth = chartWidth / rows.length;
  const barWidth = Math.max(14, (groupWidth - 20) / Math.max(yKeys.length, 1));

  const svgParts = [
    `<svg viewBox="0 0 ${width} ${height}" class="chart-svg" role="img" aria-label="bar chart">`,
    `<rect x="0" y="0" width="${width}" height="${height}" fill="transparent"></rect>`,
  ];

  for (let tick = 0; tick <= 4; tick += 1) {
    const value = (maxValue / 4) * tick;
    const y = margin.top + chartHeight - (value / maxValue) * chartHeight;
    svgParts.push(`<line x1="${margin.left}" y1="${y}" x2="${width - margin.right}" y2="${y}" stroke="#243756" stroke-width="1"></line>`);
    svgParts.push(`<text x="${margin.left - 12}" y="${y + 4}" fill="#8da1c6" font-size="11" text-anchor="end">${formatNumber(value)}</text>`);
  }

  rows.forEach((row, rowIndex) => {
    const baseX = margin.left + rowIndex * groupWidth + 10;
    const label = String(row[xKey]);
    yKeys.forEach((key, keyIndex) => {
      const value = Number(row[key]) || 0;
      const barHeight = (value / maxValue) * chartHeight;
      const x = baseX + keyIndex * barWidth;
      const y = margin.top + chartHeight - barHeight;
      svgParts.push(
        `<rect x="${x}" y="${y}" width="${barWidth - 4}" height="${barHeight}" rx="3" fill="${palette[keyIndex % palette.length]}"></rect>`
      );
    });
    svgParts.push(
      `<text x="${baseX + (groupWidth - 20) / 2}" y="${height - 20}" fill="#8da1c6" font-size="11" text-anchor="end" transform="rotate(-35 ${baseX + (groupWidth - 20) / 2} ${height - 20})">${escapeHtml(label)}</text>`
    );
  });

  svgParts.push("</svg>");
  card.innerHTML += svgParts.join("");
  card.appendChild(renderLegend(yKeys));
  return card;
}

function renderLineChart(rows, xKey, yKeys) {
  const card = document.createElement("section");
  card.className = "chart-card";
  card.innerHTML = `<h3 class="chart-title">Trend View</h3>`;

  const width = 880;
  const height = 360;
  const margin = { top: 20, right: 20, bottom: 80, left: 60 };
  const chartWidth = width - margin.left - margin.right;
  const chartHeight = height - margin.top - margin.bottom;
  const maxValue = Math.max(
    ...rows.flatMap((row) => yKeys.map((key) => Number(row[key]) || 0)),
    1
  );
  const stepX = rows.length > 1 ? chartWidth / (rows.length - 1) : chartWidth / 2;
  const svgParts = [`<svg viewBox="0 0 ${width} ${height}" class="chart-svg" role="img" aria-label="line chart">`];

  for (let tick = 0; tick <= 4; tick += 1) {
    const value = (maxValue / 4) * tick;
    const y = margin.top + chartHeight - (value / maxValue) * chartHeight;
    svgParts.push(`<line x1="${margin.left}" y1="${y}" x2="${width - margin.right}" y2="${y}" stroke="#243756" stroke-width="1"></line>`);
    svgParts.push(`<text x="${margin.left - 12}" y="${y + 4}" fill="#8da1c6" font-size="11" text-anchor="end">${formatNumber(value)}</text>`);
  }

  yKeys.forEach((key, keyIndex) => {
    const points = rows.map((row, rowIndex) => {
      const x = margin.left + stepX * rowIndex;
      const y = margin.top + chartHeight - ((Number(row[key]) || 0) / maxValue) * chartHeight;
      return { x, y, label: String(row[xKey]), value: row[key] };
    });
    const path = points.map((point, index) => `${index === 0 ? "M" : "L"} ${point.x} ${point.y}`).join(" ");
    svgParts.push(`<path d="${path}" fill="none" stroke="${palette[keyIndex % palette.length]}" stroke-width="3"></path>`);
    points.forEach((point) => {
      svgParts.push(`<circle cx="${point.x}" cy="${point.y}" r="4" fill="${palette[keyIndex % palette.length]}"></circle>`);
    });
  });

  rows.forEach((row, rowIndex) => {
    const x = margin.left + stepX * rowIndex;
    svgParts.push(
      `<text x="${x}" y="${height - 18}" fill="#8da1c6" font-size="11" text-anchor="middle">${escapeHtml(String(row[xKey]))}</text>`
    );
  });

  svgParts.push("</svg>");
  card.innerHTML += svgParts.join("");
  card.appendChild(renderLegend(yKeys));
  return card;
}

function renderDonutChart(rows, labelKey, valueKey) {
  const card = document.createElement("section");
  card.className = "chart-card";
  card.innerHTML = `<h3 class="chart-title">Distribution View</h3>`;

  const total = rows.reduce((sum, row) => sum + (Number(row[valueKey]) || 0), 0);
  let current = 0;
  const segments = rows.map((row, index) => {
    const value = Number(row[valueKey]) || 0;
    const start = current;
    current += total ? (value / total) * 100 : 0;
    return `${palette[index % palette.length]} ${start}% ${current}%`;
  });

  const wrap = document.createElement("div");
  wrap.className = "donut-wrap";

  const donut = document.createElement("div");
  donut.className = "donut";
  donut.style.background = `conic-gradient(${segments.join(", ")})`;
  wrap.appendChild(donut);

  const legend = document.createElement("div");
  legend.className = "chart-legend";
  rows.forEach((row, index) => {
    const item = document.createElement("div");
    item.className = "legend-item";
    item.innerHTML = `
      <span class="legend-swatch" style="background:${palette[index % palette.length]}"></span>
      <span>${escapeHtml(String(row[labelKey]))}: ${formatNumber(row[valueKey])}</span>
    `;
    legend.appendChild(item);
  });
  wrap.appendChild(legend);
  card.appendChild(wrap);
  return card;
}

function renderLegend(labels) {
  const legend = document.createElement("div");
  legend.className = "chart-legend";
  labels.forEach((label, index) => {
    const item = document.createElement("div");
    item.className = "legend-item";
    item.innerHTML = `
      <span class="legend-swatch" style="background:${palette[index % palette.length]}"></span>
      <span>${escapeHtml(label)}</span>
    `;
    legend.appendChild(item);
  });
  return legend;
}

function makeSpan(text) {
  const span = document.createElement("span");
  span.textContent = text;
  return span;
}

function quoteIdentifier(identifier) {
  return `\`${String(identifier).replaceAll("`", "``")}\``;
}

function buildTablePreviewSql(table) {
  const columns = table.columns.slice(0, 8).map((column) => quoteIdentifier(column.name)).join(",\n       ");
  return `SELECT ${columns || "*"}\nFROM ${quoteIdentifier(table.name)}\nLIMIT 100;`;
}

function exportCsv() {
  if (!state.activeResult) {
    return;
  }

  const columns = state.activeResult.columns || [];
  const rows = getFilteredRows();
  const csv = [
    columns.map(csvCell).join(","),
    ...rows.map((row) => columns.map((column) => csvCell(row[column])).join(",")),
  ].join("\n");
  const blob = new Blob([csv], { type: "text/csv;charset=utf-8" });
  const url = URL.createObjectURL(blob);
  const link = document.createElement("a");
  link.href = url;
  link.download = `${state.activeResult.queryId || "hospital-query"}.csv`;
  document.body.appendChild(link);
  link.click();
  link.remove();
  URL.revokeObjectURL(url);
}

function csvCell(value) {
  const text = String(value ?? "");
  return `"${text.replaceAll('"', '""')}"`;
}

function escapeHtml(text) {
  return text
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}

function formatNumber(value) {
  const number = Number(value);
  if (!Number.isFinite(number)) {
    return value;
  }
  return new Intl.NumberFormat("en-US", { maximumFractionDigits: 2 }).format(number);
}

function activateTab(nextTab) {
  elements.tabs.forEach((tab) => {
    tab.classList.toggle("is-active", tab.dataset.tab === nextTab);
  });
  Object.entries(elements.tabPanels).forEach(([name, panel]) => {
    panel.classList.toggle("is-active", name === nextTab);
  });
}

elements.tabs.forEach((tab) => {
  tab.addEventListener("click", () => activateTab(tab.dataset.tab));
});

elements.queryFilter.addEventListener("input", renderSavedQueries);
elements.schemaFilter.addEventListener("input", renderSchema);
elements.runQuery.addEventListener("click", runQuery);
elements.resetQuery.addEventListener("click", () => {
  const query = getActiveQuery();
  if (query) {
    elements.sqlEditor.value = query.sql;
  }
});
elements.copySql.addEventListener("click", async () => {
  await navigator.clipboard.writeText(elements.sqlEditor.value);
  elements.lastRunMeta.textContent = "SQL copied to clipboard.";
});
elements.refreshSchema.addEventListener("click", refreshSchema);
elements.resultFilter.addEventListener("input", () => {
  state.resultFilter = elements.resultFilter.value;
  state.currentPage = 1;
  renderCurrentTable();
});
elements.pageSize.addEventListener("change", () => {
  state.pageSize = Number(elements.pageSize.value);
  state.currentPage = 1;
  renderCurrentTable();
});
elements.prevPage.addEventListener("click", () => {
  state.currentPage -= 1;
  renderCurrentTable();
});
elements.nextPage.addEventListener("click", () => {
  state.currentPage += 1;
  renderCurrentTable();
});
elements.exportCsv.addEventListener("click", exportCsv);
elements.sqlEditor.addEventListener("keydown", (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
    event.preventDefault();
    runQuery();
  }
});

loadInitialState().catch((error) => {
  elements.resultsSummary.textContent = error.message;
  elements.visualization.innerHTML = `<div class="empty-state">${escapeHtml(error.message)}</div>`;
  elements.queryNotes.innerHTML = "";
});
