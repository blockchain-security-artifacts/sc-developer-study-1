# Replication Package for Smart Contract Security Study

## Overview
This repository provides the replication package for a study evaluating the effectiveness of smart contract security analysis tools and developer perceptions of their usability and trust. The study benchmarks five widely-used tools (Confuzzius, Mythril v0.24.7, Osiris, Oyente, and Slither v0.10.4) on a dataset of 653 real-world Ethereum smart contracts, assessing metrics such as precision, recall, false positive rate (FPR), and false negative rate (FNR) for vulnerabilities including reentrancy, suicide, and integer overflow/underflow. Additionally, a survey of 150 smart contract developers explores factors affecting trust, reasons for ignoring reported vulnerabilities, and preferences for vulnerability explanations. This package includes the dataset, tool evaluation scripts, survey data, and analysis code to facilitate replication and verification of the study’s findings, adhering to the principles of open science for the  Research Track submission.

## Repository Structure
The repository is organized as follows:

- **`Empirical Evaluation of Security Analyzers/`**: Contains the curated dataset of 653 Ethereum smart contracts retrieved from Etherscan, including source code and vulnerability labels. In addition to the evaluation results of the five widely-used tools (Confuzzius, Mythril, Osiris, Oyente, and Slither):
  - `Etherscan/`: Collected Etherscan files (.json).
  - `Solidity/`: Extracted Solidity source code files (.sol).
  - `Tools_Labels/`: Results and summary of all tools.

- **`Surveying Smart Contract Developers/`**: Anonymized survey data and analysis scripts.
  - `Developer Confidence in Smart Contract Security Analyzers - Google Forms.pdf`: Anonymized survey (Q1–Q25).
  - `Developer Confidence in Smart Contract Security Analyzers (Responses).xlsx`: Anonymized responses from 150 developers (Q1–Q25), excluding personally identifiable information.
  - `Card Sorting Q20 and Q25 XaD.xlsx`: The card sorting results.
  - `survey_analysis_results.txt`: The survey results.

- **`LICENSE`**: Specifies the MIT License for the replication package.

## Prerequisites
To replicate the study, ensure the following are installed:
- **Python 3.12+**: For running analysis scripts.
- **Security Tools**:
  - Confuzzius (v1.0.0)
  - Mythril (v0.24.7)
  - Osiris (v0.2.1)
  - Oyente (v0.2.7)
  - Slither (v0.10.4)

Detailed installation instructions for each tool are provided in https://smartbugs.github.io/. Ensure that the specified versions are used, as newer versions may produce different results. No additional configurations beyond the defaults are required unless specified in the tool documentation.

## Replication Instructions
Follow these steps to replicate the study:

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/blockchain-security-artifacts/sc-developer-study-1.git
   cd sc-developer-study-1
   ```
   This retrieves the full replication package and sets your working directory.

2. **Run Tool Evaluations**:
   - Extract Solidity code and clean the dataset:
     ```bash
     python3 2_Extract_Solidity.py
     ```
     This processes the Etherscan JSON files into usable Solidity files.
   - Summarize the cleaned dataset:
     ```bash
     python3 3_DatasetSummary.py
     ```
     This generates a summary of the dataset for verification.
   - Install and run the security tools:
     ```bash
     python3 4_Run_SA_tools.py
     ```
     This executes each tool on the 653 contracts with a 900-second timeout per tool, saving raw outputs to `Tools_Labels/results.csv`.

3. **Compute Metrics**:
   - Extract tool labels for each vulnerability type:
     ```bash
     python3 5_Extract_labels_SA_tools.py
     ```
     Results are saved in `Tools_Labels/Reentrancy_labels.csv`, `Tools_Labels/Suicide_labels.csv`, and `Tools_Labels/IntegerOU_labels.csv`.
   - Calculate performance metrics (precision, recall, FPR, FNR):
     ```bash
     python3 6_Tools_performance.py
     ```
     Results (e.g., F1-scores, FPRs) are saved in `Tools_Labels/Reentrancy_summary.csv`, `Tools_Labels/Suicide_summary.csv`, and `Tools_Labels/IntegerOU_summary.csv`.

4. **Analyze Survey Data**:
   - Review the survey results in `survey_analysis_results.txt`. This file contains the processed outcomes from the developer survey, including statistical summaries and key findings.

## License
This replication package is licensed under the MIT License (see `LICENSE`).

## Contact
For issues or questions, please open a GitHub issue or contact the repository maintainers anonymously via the  submission system.