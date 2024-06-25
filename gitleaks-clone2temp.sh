#!/bin/bash



# Prompt user for the repository URL

read -p "Enter the repository URL: " REPO_URL



# Prompt user for redacted mode

read -p "Do you want to run in redacted mode? (yes/no): " REDACTED_MODE



# Create a temporary directory

TEMP_DIR=$(mktemp -d)



# Function to clean up temporary directory on exit

cleanup() {

  rm -rf "$TEMP_DIR"

}

trap cleanup EXIT



# Clone the repository into the temporary directory

git clone "$REPO_URL" "$TEMP_DIR"

if [ $? -ne 0 ]; then

  echo "Failed to clone the repository. Exiting."

  exit 1

fi

REPO_DIR="$TEMP_DIR"



# Set gitleaks options based on redacted mode

if [ "$REDACTED_MODE" == "yes" ]; then

  GITLEAKS_OPTIONS="--redact"

else

  GITLEAKS_OPTIONS=""

fi



# Determine if .gitleaks.toml exists and set config option

if [ -f ".gitleaks.toml" ]; then

  GITLEAKS_CONFIG="--config=.gitleaks.toml"

else

  GITLEAKS_CONFIG=""

fi



# Run gitleaks with comprehensive scan options on the repository

gitleaks detect \

  --source="$REPO_DIR" \

  --report-format=json \

  --report-path=gitleaks_report.json \

  --verbose \

  --log-level=debug \

  $GITLEAKS_OPTIONS \

  $GITLEAKS_CONFIG



# Check if the gitleaks scan was successful

if [ $? -ne 0 ]; then

  echo "gitleaks scan failed. Exiting."

  exit 1

fi



# Filter out results that contain "test" using jq

jq '[.[] | select(.file | test("test"; "i") | not)]' gitleaks_report.json > filtered_report.json



# Convert filtered JSON report to CSV format

jq -r '.[] | [.rule, .file, .line, .offender, .commit, .repo, .author, .email, .date, .message, .tags] | @csv' filtered_report.json > gitleaks_report.csv



# Convert filtered JSON report to JUnit format (basic conversion)

echo '<?xml version="1.0" encoding="UTF-8"?>' > gitleaks_report.xml

echo '<testsuites>' >> gitleaks_report.xml

echo '  <testsuite name="gitleaks" tests="1">' >> gitleaks_report.xml

jq -r '.[] | "    <testcase classname=\"" + .repo + "\" name=\"" + .rule + "\"><failure message=\"" + .offender + "\"><![CDATA[" + .file + ":" + (.line|tostring) + "]]></failure></testcase>"' filtered_report.json >> gitleaks_report.xml

echo '  </testsuite>' >> gitleaks_report.xml

echo '</testsuites>' >> gitleaks_report.xml



# Convert filtered JSON report to SARIF format

jq -n --argjson data "$(jq '[.[] | {ruleId: .rule, message: {text: .offender}, locations: [{physicalLocation: {artifactLocation: {uri: .file}, region: {startLine: .line}}}], properties: {commit: .commit, repo: .repo, author: .author, email: .email, date: .date, message: .message, tags: .tags}}]' filtered_report.json)" '{version: "2.1.0", runs: [{tool: {driver: {name: "gitleaks", informationUri: "https://github.com/zricethezav/gitleaks"}}, results: $data}]}' > gitleaks_report.sarif



echo "Reports generated successfully."



# Clean up temporary directory

cleanup

