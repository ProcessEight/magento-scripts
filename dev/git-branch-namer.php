<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$issueTitle = "Goes here";

$branchName = trim($issueTitle, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = htmlspecialchars_decode($branchName, ENT_QUOTES|ENT_HTML5);

$branchName = str_replace(["\n", "\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/', ':', '&', '!', '"', '%', '^', '*', '(', ')', '+', '=', '{', '}', '[', ']', ';', '@', '<', '>', '?', '|', '`', '¬', 'JIRA', 'title'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim(strtolower($branchName), '-') . "\n";
