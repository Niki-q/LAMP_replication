<?php
// Подключение к базам данных
$db_master = new mysqli("mysql-master", "root", "rootpass", "db_app");
$db_slave = new mysqli("mysql-slave", "root", "rootpass", "db_app");

// Проверка соединения с master
if ($db_master->connect_error) {
    die("Database Connection Error (Master): " . $db_master->connect_error);
}

// Проверка соединения с slave
if ($db_slave->connect_error) {
    die("Database Connection Error (Slave): " . $db_slave->connect_error);
}

// Если отправлен POST-запрос
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $action = $_POST['action'] ?? '';

    // Добавление записи
    if ($action === 'add') {
        $title = trim($_POST['title'] ?? '');
        $year = trim($_POST['year'] ?? '');
        $director = trim($_POST['director'] ?? '');

        if (!empty($title) || !empty($year) || !empty($director)) {
            $stmt = $db_master->prepare("INSERT INTO Movie (title, year, director) VALUES (?, ?, ?)");
            $stmt->bind_param("sis", $title, $year, $director);
            $stmt->execute();
        }

        // Перенаправление
        header("Location: " . $_SERVER['PHP_SELF']);
        exit(); // Остановка дальнейшего кода
    }

    // Редактирование записи
    if ($action === 'update') {
        $id = (int) $_POST['id'];
        $title = trim($_POST['title'] ?? '');
        $year = trim($_POST['year'] ?? '');
        $director = trim($_POST['director'] ?? '');

        if (!empty($title) || !empty($year) || !empty($director)) {
            $stmt = $db_master->prepare("UPDATE Movie SET title = ?, year = ?, director = ? WHERE mID = ?");
            $stmt->bind_param("sisi", $title, $year, $director, $id);
            $stmt->execute();
        }

        // Перенаправление
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    }

    // Удаление записи
    if ($action === 'delete') {
        $id = (int) $_POST['id'];

        $stmt = $db_master->prepare("DELETE FROM Movie WHERE mID = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();

        // Перенаправление
        header("Location: " . $_SERVER['PHP_SELF']);
        exit();
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LAMP CRUD Application</title>
    <link rel="stylesheet" href="styles.css">
    <script src="scripts.js" defer></script>
</head>
<body>
<div class="container">
    <!-- Современный переключатель -->
    <div class="switch-container">
        <span>Editing Mode</span>
        <label class="switch">
            <input type="checkbox" id="editing-switch">
            <span class="slider"></span>
        </label>
    </div>

    <h1>Movie Ratings</h1>
    <?php
    // Отображение записей из slave базы
    $result = $db_slave->query("SELECT * FROM Movie");

    echo '<table>
            <tr>
                <th>Title</th>
                <th>Year</th>
                <th>Director</th>
                <th style="display: none;">Actions</th> <!-- Колонка скрыта по умолчанию -->
            </tr>';

    while ($row = $result->fetch_assoc()) {
        echo "<tr id='row-{$row['mID']}'>
                <td data-editable data-name='title'>{$row['title']}</td>
                <td data-editable data-name='year'>{$row['year']}</td>
                <td data-editable data-name='director'>{$row['director']}</td>
                <td style='display: none;'> <!-- Колонка Actions скрыта по умолчанию -->
                    <form method='post' class='update-form' style='display: inline;'>
                        <input type='hidden' name='id' value='{$row['mID']}'>
                        <input type='hidden' name='title' value='{$row['title']}'>
                        <input type='hidden' name='year' value='{$row['year']}'>
                        <input type='hidden' name='director' value='{$row['director']}'>
                        <input type='hidden' name='action' value='update'>
                        <button type='submit' class='btn btn-success save-btn' style='display: none;'>Save</button>
                    </form>
                    <button class='btn btn-warning edit-btn' onclick='enableEdit({$row['mID']})'>Edit</button>
                    <form method='post' style='display: inline;'>
                        <input type='hidden' name='id' value='{$row['mID']}'>
                        <input type='hidden' name='action' value='delete'>
                        <button type='submit' class='btn btn-danger'>Delete</button>
                    </form>
                </td>
             </tr>";
    }

    // Строка для добавления
    echo "<tr id='add-row' style='display: none;'> <!-- Скрыта по умолчанию -->
            <form method='post'>
                <input type='hidden' name='action' value='add'>
                <td><input type='text' name='title' placeholder='Enter title'></td>
                <td><input type='number' name='year' placeholder='Enter year'></td>
                <td><input type='text' name='director' placeholder='Enter director'></td>
                <td>
                    <button type='submit' class='btn btn-success'>Add</button>
                </td>
            </form>
        </tr>";

    echo '</table>';
    ?>
</div>
</body>
</html>