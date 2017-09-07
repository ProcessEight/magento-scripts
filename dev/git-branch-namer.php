<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName ="    FRB-548

Orders stuck at pending payment";
$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim($branchName) . "\n";
