<?php
require_once 'config/config.php';
require_once 'includes/auth.php';
require_once 'classes/RealEstateDatabase.php';

requireRole(['buyer', 'renter']);

$db = new RealEstateDatabase();

$userId = $_SESSION['user']['userID'];

$conn = new PDO(
    "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME,
    DB_USER,
    DB_PASS
);

$sql = "SELECT p.*
        FROM Favorites f
        JOIN Properties p ON f.propertyId = p.propertyID
        WHERE f.userId = :userId";

$stmt = $conn->prepare($sql);
$stmt->execute([':userId' => $userId]);

$favorites = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<?php include 'includes/header.php'; ?>

<h2>My Favorite Properties</h2>

<?php if (!$favorites): ?>
    <p>No favorite properties saved yet.</p>
<?php endif; ?>

<?php foreach ($favorites as $property): ?>
    <div class="card">
        <h3><?= htmlspecialchars($property['title']) ?></h3>

        <p><strong>Type:</strong>
        <?= htmlspecialchars($property['propertyType']) ?></p>

        <p><strong>City:</strong>
        <?= htmlspecialchars($property['city']) ?></p>

        <p><strong>Price:</strong>
        $<?= htmlspecialchars($property['price']) ?></p>

        <a href="property_details.php?id=<?= (int)$property['propertyID'] ?>">
            View Details
        </a>
    </div>
<?php endforeach; ?>

<?php include 'includes/footer.php'; ?>