<?php
require_once 'config/config.php';
require_once 'classes/RealEstateDatabase.php';

if (!isset($_SESSION['user']) || $_SESSION['user']['userType'] === 'agent') {
    die("Access denied.");
}

$db = new RealEstateDatabase();
$message = '';

$propertyId = (int)($_GET['propertyId'] ?? 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $userId = $_SESSION['user']['userID'];
    $messageText = trim($_POST['message'] ?? '');

    if ($messageText) {
        if ($db->addInquiry($userId, $propertyId, $messageText)) {
            $message = "Inquiry sent successfully!";
        } else {
            $message = "Error sending inquiry.";
        }
    } else {
        $message = "Please enter a message.";
    }
}
?>
<?php include 'includes/header.php'; ?>

<h2>Submit Inquiry</h2>

<?php if ($message): ?>
    <p><?= htmlspecialchars($message) ?></p>
<?php endif; ?>

<form method="POST">
    <label>Your Message</label>
    <textarea name="message" required></textarea>

    <button type="submit">Send Inquiry</button>
</form>

<?php include 'includes/footer.php'; ?>