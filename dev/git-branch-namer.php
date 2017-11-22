<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName = "FRB-557
IE Not accepting Option on College Forms";

$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n", "\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/', ':'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim($branchName, '-') . "\n";
