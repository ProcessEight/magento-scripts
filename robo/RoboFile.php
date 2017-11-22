<?php
/**
 * This is project's console commands configuration for Robo task runner.
 *
 * @see http://robo.li/
 */
class RoboFile extends \Robo\Tasks
{
    /**
     * Convert JIRA issue title into git-compatible string and then create new git branch with it
     *
     * @param string $issueTitle
     */
    public function gitBranchifyJiraIssueTitle($issueTitle)
    {
        $branchName = trim($issueTitle, '.');

        $branchName = str_replace(['    '], '', $branchName);

        $branchName = str_replace(["\n", "\n\n", ' - ', ' ', '.', '£', '$', '#', '~', ',', '\'', '/', ':'], '-', $branchName);

        $branchName = str_replace('--', '-', $branchName);

        $this->taskGitStack()
            ->stopOnFail()
            ->checkout('-b ' . $branchName)
            ->run();
    }
}