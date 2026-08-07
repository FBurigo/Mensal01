const API_URL = "/api/books";

const state = { books: [], searchTimer: null };
const elements = {
  grid: document.querySelector("#book-grid"),
  loading: document.querySelector("#loading"),
  empty: document.querySelector("#empty-state"),
  search: document.querySelector("#search"),
  filter: document.querySelector("#status-filter"),
  dialog: document.querySelector("#book-dialog"),
  form: document.querySelector("#book-form"),
  formError: document.querySelector("#form-error"),
  toast: document.querySelector("#toast"),
};

const statusLabels = {
  QUERO_LER: "Quero ler",
  LENDO: "Lendo",
  LIDO: "Lido",
};

function escapeHtml(value = "") {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

async function apiRequest(url, options = {}) {
  const response = await fetch(url, {
    headers: { "Content-Type": "application/json", ...(options.headers || {}) },
    ...options,
  });
  if (!response.ok) {
    let message = "Não foi possível concluir a operação.";
    try {
      const body = await response.json();
      message = typeof body.detail === "string" ? body.detail : message;
    } catch (_) {
      // Mantém a mensagem padrão para respostas sem JSON.
    }
    throw new Error(message);
  }
  return response.status === 204 ? null : response.json();
}

async function loadBooks() {
  elements.loading.hidden = false;
  elements.grid.innerHTML = "";
  elements.empty.hidden = true;
  const params = new URLSearchParams();
  if (elements.search.value.trim()) params.set("q", elements.search.value.trim());
  if (elements.filter.value) params.set("reading_status", elements.filter.value);

  try {
    state.books = await apiRequest(`${API_URL}?${params.toString()}`);
    renderBooks();
  } catch (error) {
    elements.loading.textContent = "A API está indisponível. Tente novamente em instantes.";
    showToast(error.message, true);
    return;
  }
  elements.loading.hidden = true;
}

function renderBooks() {
  elements.grid.innerHTML = state.books.map(bookCard).join("");
  elements.empty.hidden = state.books.length > 0;
  updateStats();

  document.querySelectorAll("[data-edit]").forEach((button) =>
    button.addEventListener("click", () => openEditDialog(Number(button.dataset.edit)))
  );
  document.querySelectorAll("[data-delete]").forEach((button) =>
    button.addEventListener("click", () => removeBook(Number(button.dataset.delete)))
  );
  document.querySelectorAll(".status-select").forEach((select) =>
    select.addEventListener("change", () => changeStatus(Number(select.dataset.status), select.value))
  );
}

function bookCard(book) {
  const stars = book.rating ? "★".repeat(book.rating) + "☆".repeat(5 - book.rating) : "Sem avaliação";
  const options = Object.entries(statusLabels)
    .map(([value, label]) => `<option value="${value}" ${book.reading_status === value ? "selected" : ""}>${label}</option>`)
    .join("");

  return `
    <article class="book-card" data-status="${book.reading_status}">
      <div class="card-top">
        <span class="category">${escapeHtml(book.category)}</span>
      </div>
      <h3>${escapeHtml(book.title)}</h3>
      <p class="author">por ${escapeHtml(book.author)}</p>
      ${book.notes ? `<p class="notes">${escapeHtml(book.notes)}</p>` : ""}
      <div class="stars" aria-label="${book.rating ? `${book.rating} de 5 estrelas` : "Sem avaliação"}">${stars}</div>
      ${book.isbn ? `<div class="isbn">ISBN ${escapeHtml(book.isbn)}</div>` : ""}
      <div class="card-actions">
        <select class="status-select" data-status="${book.id}" aria-label="Situação de ${escapeHtml(book.title)}">${options}</select>
        <div class="action-group">
          <button class="icon-button" data-edit="${book.id}" type="button" aria-label="Editar ${escapeHtml(book.title)}">✎</button>
          <button class="icon-button danger" data-delete="${book.id}" type="button" aria-label="Excluir ${escapeHtml(book.title)}">⌫</button>
        </div>
      </div>
    </article>`;
}

function updateStats() {
  document.querySelector("#stat-total").textContent = state.books.length;
  document.querySelector("#stat-reading").textContent = state.books.filter((book) => book.reading_status === "LENDO").length;
  document.querySelector("#stat-read").textContent = state.books.filter((book) => book.reading_status === "LIDO").length;
}

function openCreateDialog() {
  elements.form.reset();
  document.querySelector("#book-id").value = "";
  document.querySelector("#category").value = "Geral";
  document.querySelector("#dialog-title").textContent = "Adicionar livro";
  elements.formError.textContent = "";
  elements.dialog.showModal();
  document.querySelector("#title").focus();
}

function openEditDialog(id) {
  const book = state.books.find((item) => item.id === id);
  if (!book) return;
  document.querySelector("#book-id").value = book.id;
  document.querySelector("#title").value = book.title;
  document.querySelector("#author").value = book.author;
  document.querySelector("#category").value = book.category;
  document.querySelector("#isbn").value = book.isbn || "";
  document.querySelector("#reading-status").value = book.reading_status;
  document.querySelector("#rating").value = book.rating || "";
  document.querySelector("#notes").value = book.notes || "";
  document.querySelector("#dialog-title").textContent = "Editar livro";
  elements.formError.textContent = "";
  elements.dialog.showModal();
}

async function saveBook(event) {
  event.preventDefault();
  const id = document.querySelector("#book-id").value;
  const rating = document.querySelector("#rating").value;
  const payload = {
    title: document.querySelector("#title").value,
    author: document.querySelector("#author").value,
    category: document.querySelector("#category").value,
    isbn: document.querySelector("#isbn").value || null,
    reading_status: document.querySelector("#reading-status").value,
    rating: rating ? Number(rating) : null,
    notes: document.querySelector("#notes").value || null,
  };

  const button = document.querySelector("#save-book");
  button.disabled = true;
  elements.formError.textContent = "";
  try {
    await apiRequest(id ? `${API_URL}/${id}` : API_URL, {
      method: id ? "PUT" : "POST",
      body: JSON.stringify(payload),
    });
    elements.dialog.close();
    showToast(id ? "Livro atualizado com sucesso." : "Livro adicionado à estante.");
    await loadBooks();
  } catch (error) {
    elements.formError.textContent = error.message;
  } finally {
    button.disabled = false;
  }
}

async function changeStatus(id, readingStatus) {
  try {
    await apiRequest(`${API_URL}/${id}/status`, {
      method: "PATCH",
      body: JSON.stringify({ reading_status: readingStatus }),
    });
    showToast("Situação de leitura atualizada.");
    await loadBooks();
  } catch (error) {
    showToast(error.message, true);
    await loadBooks();
  }
}

async function removeBook(id) {
  const book = state.books.find((item) => item.id === id);
  if (!book || !window.confirm(`Excluir “${book.title}” da sua estante?`)) return;
  try {
    await apiRequest(`${API_URL}/${id}`, { method: "DELETE" });
    showToast("Livro removido da estante.");
    await loadBooks();
  } catch (error) {
    showToast(error.message, true);
  }
}

function showToast(message, isError = false) {
  elements.toast.textContent = message;
  elements.toast.classList.toggle("error", isError);
  elements.toast.classList.add("visible");
  window.setTimeout(() => elements.toast.classList.remove("visible"), 2800);
}

document.querySelector("#new-book").addEventListener("click", openCreateDialog);
document.querySelector("#empty-add").addEventListener("click", openCreateDialog);
document.querySelector("#close-dialog").addEventListener("click", () => elements.dialog.close());
document.querySelector("#cancel-dialog").addEventListener("click", () => elements.dialog.close());
elements.form.addEventListener("submit", saveBook);
elements.filter.addEventListener("change", loadBooks);
elements.search.addEventListener("input", () => {
  window.clearTimeout(state.searchTimer);
  state.searchTimer = window.setTimeout(loadBooks, 300);
});

loadBooks();
