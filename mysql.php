<?php
$servername = "mysql-studyvore.alwaysdata.net";
$username = "studyvore_33610";
$password = "Football33610@";
$dbname = "studyvore_33610";

// Créer la connexion
$conn = new mysqli($servername, $username, $password, $dbname);

// Vérifier la connexion
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
