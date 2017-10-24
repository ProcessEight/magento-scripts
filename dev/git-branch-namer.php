<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName = "    EBR-183

Setup maintenance.ip";

$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n", "\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/', ':'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim($branchName, '-') . "\n";
