<?php

use Symfony\Component\Console\Input\InputOption;

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
     * @param        $projectRoot
     */
    public function gitBranchifyJiraIssueTitle($issueTitle, $projectRoot)
    {
        $branchName = $this->getGitAcceptableBranchName($issueTitle);

        $this->taskGitStack()
            ->dir($projectRoot)
            ->stopOnFail()
            ->checkout('-b ' . $branchName)
            ->run();
    }

    /**
     * Convert JIRA issue title into git-compatible string and then create new git branch with it
     *
     * @param $jiraIssueUrl
     * @param $projectRoot
     *
     * @internal param string $jiraIssueUrl
     */
    public function gitBranchifyJiraIssueTitleFromUrl($jiraIssueUrl, $projectRoot)
    {
        $issueTitle = $this->parseJiraIssueTitleFromHtml($jiraIssueUrl);

        $branchName = $this->getGitAcceptableBranchName($issueTitle);

        $this->taskGitStack()
             ->dir($projectRoot)
             ->stopOnFail()
             ->checkout('-b ' . $branchName)
             ->run();
    }

    /**
     * @param string $jiraIssueUrl
     *
     * @return string
     */
    protected function parseJiraIssueTitleFromHtml($jiraIssueUrl)
    {
        // Create curl resource
        $ch = curl_init();

        // Set url
        curl_setopt($ch, CURLOPT_URL, $jiraIssueUrl);

        // Set headers
        curl_setopt($ch, CURLOPT_HTTPHEADER, array (
            ':authority:purenet.atlassian.net',
            ':method:GET',
            ':scheme:https',
            'accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'accept-language:en-US,en;q=0.8',
            'cache-control:no-cache',
            'cookie:_csrf=dOGawWxnF73vChkPI_s81FwF; atlassian.xsrf.token=B9NG-TJAZ-Y7H8-2FFZ|f146fbbde9f8e2971167636cf483a3c8ccff647b|lin; cloud.session.token=eyJraWQiOiJzZXNzaW9uLXNlcnZpY2VcL3Nlc3Npb24tc2VydmljZSIsImFsZyI6IlJTMjU2In0.eyJzdWIiOiI1NTcwNTg6YzY0YjQ5NzAtOTA3OC00ZWNmLTk5NzgtMzJhYWIyNjkyMWU1IiwiYXVkIjoiYXRsYXNzaWFuIiwiaW1wZXJzb25hdGlvbiI6W10sIm5iZiI6MTUxMTQ2OTE0MSwicmVmcmVzaFRpbWVvdXQiOjE1MTE0Njk3NDEsImlzcyI6InNlc3Npb24tc2VydmljZSIsInNlc3Npb25JZCI6IjdkZjExYTJhLWNjY2YtNDM1Ni1iY2U3LWZiNDY1ZjEyMmZiNiIsImV4cCI6MTUxNDA2MTE0MSwiaWF0IjoxNTExNDY5MTQxLCJlbWFpbCI6InNpbW9uLmZyb3N0QHB1cmVuZXQuY28udWsiLCJqdGkiOiI3ZGYxMWEyYS1jY2NmLTQzNTYtYmNlNy1mYjQ2NWYxMjJmYjYifQ.IeNHVNNLvhyppmaEze5M-xGlCEiBoDZhbwu3I8YdEw-8bZyiW8L2xZUftdIdOGoRvCg4ClhiCvFcHptakrRmD5Mp-QFduof_qKdlQshQ1a55Tot27F9Vs2-GtjwKjeS_shMjKX52gkRWdUYtTWs8FstrsxKulBUYxtJPJaCxaYLDLeyUmPUAYGZJZOKqJ8WRDVJIGp1LBobr8-PI8vlifoUAPz1cCCPeGpxLQslJBWJuHAS6VXvuksZ91d2qCf7IurJDJF9iXnK-8qN8COH0q0UBgMJx2LsWTnHzgGC8-8ukU2B8S0AOGztia0VNIJq0JYKQNwqtvc-nLjC3lNxrWA',
            'dnt:1',
            'pragma:no-cache',
            'upgrade-insecure-requests:1',
            'user-agent:Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.79 Safari/537.36',
        ));

        // Return the transfer as a string
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

        // $html contains the output string
        $html = curl_exec($ch);

        // Close curl resource to free up system resources
        curl_close($ch);

        $start = stripos($html, '<title>');
        $limit = stripos($html, '</title>');
        $title = substr($html, $start, $limit - $start);

        return $title;
    }

    /**
     * @param $issueTitle
     *
     * @return string
     */
    protected function getGitAcceptableBranchName($issueTitle)
    {
        $branchName = trim($issueTitle, '.');

        $branchName = str_replace(['    '], '', $branchName);

        $branchName = str_replace([
            '[',
            ']',
            "\n",
            "\n\n",
            ' - ',
            ' ',
            '.',
            '£',
            '$',
            '#',
            '~',
            ',',
            '\'',
            '/',
            ':',
            'JIRA',
            '@',
            '<title>'
        ], '-', $branchName);

        $branchName = str_replace('--', '-', $branchName);

        $branchName = trim($branchName, '-');

        return $branchName;
    }
}