// Показать строку для добавления новой записи
function toggleAddRow() {
    const addRow = document.getElementById('add-row');
    addRow.style.display = addRow.style.display === 'none' ? 'table-row' : 'none';
}

// Включить режим редактирования строки
function enableEdit(rowId) {
    const row = document.getElementById(`row-${rowId}`);
    const saveButton = row.querySelector('.save-btn');
    const editButton = row.querySelector('.edit-btn');
    const form = row.querySelector('.update-form');

    // Превратить текстовые ячейки в поля ввода
    row.querySelectorAll('[data-editable]').forEach(cell => {
        const input = document.createElement('input');
        input.type = 'text';
        input.name = cell.dataset.name;
        input.value = cell.textContent.trim();
        input.classList.add('form-input');
        cell.dataset.original = cell.textContent.trim(); // Сохранить оригинальное значение
        cell.textContent = '';
        cell.appendChild(input);
    });

    // Показать кнопку "Save", скрыть кнопку "Edit"
    saveButton.style.display = 'inline';
    editButton.style.display = 'none';

    // Слушатель для обновления hidden input при изменении значений в edit input
    row.querySelectorAll('input.form-input').forEach(input => {
        input.addEventListener('input', () => {
            form.querySelector(`input[name="${input.name}"]`).value = input.value.trim();
        });
    });
}

// Отключить режим редактирования, вернуть исходный вид
function disableEdit(rowId) {
    const row = document.getElementById(`row-${rowId}`);
    row.querySelectorAll('[data-editable]').forEach(cell => {
        const originalValue = cell.dataset.original;
        cell.textContent = originalValue; // Вернуть исходное значение
    });

    // Вернуть кнопки "Edit" и скрыть "Save"
    row.querySelector('.save-btn').style.display = 'none';
    row.querySelector('.edit-btn').style.display = 'inline';
}
// Инициализация переключателя и таблицы
document.addEventListener("DOMContentLoaded", () => {
    // Проверяем сохраненное значение из localStorage
    const editingMode = localStorage.getItem("editingMode") === "true";
    const switchToggle = document.getElementById("editing-switch");

    // Устанавливаем начальное состояние переключателя и таблицы
    switchToggle.checked = editingMode;
    setEditingMode(editingMode);

    // Добавляем слушателя переключения
    switchToggle.addEventListener("change", () => {
        const isEnabled = switchToggle.checked;
        localStorage.setItem("editingMode", isEnabled);
        setEditingMode(isEnabled);
    });
});

// Установка режимов таблицы
function setEditingMode(isEnabled) {
    const addRow = document.getElementById("add-row");
    const actionColumns = document.querySelectorAll("td:nth-child(4), th:nth-child(4)"); // Колонка Actions

    if (isEnabled) {
        addRow.style.display = "";
        actionColumns.forEach((col) => (col.style.display = ""));
    } else {
        addRow.style.display = "none";
        actionColumns.forEach((col) => (col.style.display = "none"));
    }
}