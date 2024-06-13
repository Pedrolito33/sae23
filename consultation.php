<?php
include 'mysql.php';

// Requête pour récupérer la dernière mesure de chaque capteur
$sql = "
SELECT c.nom_capteur, m.valeur, m.date, m.horaire
FROM mesure m
INNER JOIN (
    SELECT capteur, MAX(CONCAT(date, ' ', horaire)) as max_datetime
    FROM mesure
    GROUP BY capteur
) latest
ON m.capteur = latest.capteur
AND CONCAT(m.date, ' ', m.horaire) = latest.max_datetime
INNER JOIN capteur c ON m.capteur = c.id_capteur
";

$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html>
<head>
    <title>Consultation des mesures</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
    </style>
</head>
<body>
    <h1>Dernières mesures de tous les capteurs</h1>
    <table>
        <tr>
            <th>Nom du Capteur</th>
            <th>Valeur</th>
            <th>Date</th>
            <th>Horaire</th>
        </tr>
        <?php
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                echo "<tr><td>" . $row["nom_capteur"] . "</td><td>" . $row["valeur"] . "</td><td>" . $row["date"] . "</td><td>" . $row["horaire"] . "</td></tr>";
            }
        } else {
            echo "<tr><td colspan='4'>Aucune mesure trouvée</td></tr>";
        }
        $conn->close();
        ?>
    </table>
</body>
</html>