<?php
/**
 * Run it:
 * php -f git-branch-namer.php
 */

$branchName ="    FRB-545

College Kit MOTO - College shipping options not appearing";

$branchName = trim($branchName, '.');

$branchName = str_replace(['    '], '', $branchName);

$branchName = str_replace(["\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/'], '-', $branchName);

$branchName = str_replace('--', '-', $branchName);

echo trim($branchName) . "\n";
