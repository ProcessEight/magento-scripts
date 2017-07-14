<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName ="    SPF-751

Product Category Assignments";

$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\''], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim($branchName) . "\n";
