<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName = "Add People Section: PNCR02801";

$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n", "\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/', ':', '&', '!', '"', '%', '^', '*', '(', ')', '+', '=', '{', '}', '[', ']', ';', '@', '<', '>', '?', '|', '`', '¬'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim(strtolower($branchName), '-') . "\n";
