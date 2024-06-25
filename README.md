# gitleaks-clone2tmp

This script automates the process of scanning a Git repository for secrets using [Gitleaks](https://github.com/zricethezav/gitleaks). It allows for optional redaction of sensitive information in the output and generates reports in JSON, CSV, JUnit, and SARIF formats.

## Prerequisites

- [Git](https://git-scm.com/)
- [Gitleaks](https://github.com/zricethezav/gitleaks)
- [jq](https://stedolan.github.io/jq/)

Ensure these tools are installed and available in your `PATH`.

## Usage

1. Clone this repository or download the script file.
2. Make the script executable:

   ```bash
   chmod +x gitleaks_scanner.sh



       Follow the prompts to enter the repository URL and choose whether to run in redacted mode.

Script Workflow

    Prompts the user for the Git repository URL and redacted mode preference.
    Creates a temporary directory for cloning the repository.
    Clones the repository into the temporary directory.
    Sets Gitleaks options based on the redacted mode.
    Checks if a .gitleaks.toml configuration file exists and includes it if found.
    Runs Gitleaks with comprehensive scan options on the repository.
    Filters out results that contain "test" using jq.
    Converts the filtered JSON report to CSV, JUnit, and SARIF formats.
    Cleans up the temporary directory.

Reports

The script generates the following reports:

    gitleaks_report.json: Full JSON report from Gitleaks.
    filtered_report.json: Filtered JSON report excluding files containing "test".
    gitleaks_report.csv: CSV format of the filtered report.
    gitleaks_report.xml: Basic JUnit format of the filtered report.
    gitleaks_report.sarif: SARIF format of the filtered report.




  
