# Replication Package for Smart Contract Security Study

## Overview
This repository provides the replication package for a study evaluating the effectiveness of smart contract security analysis tools and developer perceptions of their usability and trust. The study benchmarks five widely-used tools (Confuzzius, Mythril v0.24.7, Osiris, Oyente, and Slither v0.10.4) on a dataset of 653 real-world Ethereum smart contracts, assessing metrics such as precision, recall, false positive rate (FPR), and false negative rate (FNR) for vulnerabilities including reentrancy, suicide, and integer overflow/underflow. Additionally, a survey of 150 smart contract developers explores factors affecting trust, reasons for ignoring reported vulnerabilities, and preferences for vulnerability explanations. This package includes the dataset, tool evaluation scripts, survey data, and analysis code to facilitate replication and verification of the study’s findings, adhering to the principles of open science for the ICSE 2026 Research Track submission.

## Repository Structure
The repository is organized as follows:

- **`Empirical Evaluation of Security Analyzers/`**: Contains the curated dataset of 653 Ethereum smart contracts retrieved from Etherscan, including source code and vulnerability labels. In addition to the evaluation results of the five widely-used tools (Confuzzius, Mythril, Osiris, Oyente, and Slither):
  - `Etherscan/`: Collected Etherscan files (.json).
  - `Solidity/`: Extracted Solidity source code files (.sol).
  - `Tools_Labels/`: Results and summary of all tools.

- **`Surveying Smart Contract Developers/`**: Anonymized survey data and analysis scripts.
  - `raw_data.csv`: Anonymized responses from 150 developers (Q1–Q25), excluding personally identifiable information.
  - `qualitative_analysis.py`: Python script for coding open-ended responses (e.g., Q20) with inter-rater reliability (Cohen’s κ = 0.866).
  - `results/`: Aggregated survey results (e.g., percentages for RQ5–RQ7).
- **`analysis/`**: Scripts for computing evaluation metrics and generating results.
  - `metrics.py`: Computes precision, recall, FPR, and FNR for tool performance.
  - `visualizations.py`: Generates figures (e.g., precision-recall curves, FPR distributions).
  - `results/`: Output tables and figures (e.g., F1-scores, survey theme frequencies).
- **`requirements.txt`**: Lists Python dependencies for analysis scripts (e.g., pandas, matplotlib).
- **`LICENSE`**: Specifies the MIT License for the replication package.

## Prerequisites
To replicate the study, ensure the following are installed:
- **Python 3.8+**: For running analysis scripts.
- **Security Tools**:
  - Confuzzius (v1.0.0)
  - Mythril (v0.24.7)
  - Osiris (v0.2.1)
  - Oyente (v0.2.7)
  - Slither (v0.10.4)
- **Dependencies**: Install Python dependencies using:
  ```bash
  pip install -r requirements.txt
  ```
- **Ethereum Node**: Access to an Ethereum node or Etherscan API for transaction history validation (optional for full replication).

Detailed installation instructions for each tool are provided in `tools/README.md`.

## Replication Instructions
1. **Clone the Repository**:
   ```bash
   git clone https://github.com/blockchain-security-artifacts/sc-developer-study-1.git
   cd sc-developer-study-1
   ```

2. **Set Up Environment**:
   - Install Python dependencies: `pip install -r requirements.txt`.
   - Install security tools as per `tools/README.md`.

3. **Run Tool Evaluations**:
   - Execute the tool evaluation script:
     ```bash
     python tools/run_tools.py --dataset dataset/contracts --output tools/outputs
     ```
   - This runs each tool on the 653 contracts with a 900-second timeout, saving outputs to `tools/outputs`.

4. **Compute Metrics**:
   - Calculate precision, recall, FPR, and FNR:
     ```bash
     python analysis/metrics.py --tool-outputs tools/outputs --labels dataset/labels.csv --output analysis/results
     ```
   - Results (e.g., F1-scores, FPRs) are saved in `analysis/results`.

5. **Analyze Survey Data**:
   - Process quantitative and qualitative survey responses:
     ```bash
     python survey/qualitative_analysis.py --input survey/raw_data.csv --output survey/results
     ```
   - Outputs include theme frequencies (e.g., 33.33% cite false positives for ignoring warnings) and visualizations.

6. **Generate Visualizations**:
   - Create figures (e.g., precision-recall curves):
     ```bash
     python analysis/visualizations.py --input analysis/results --output analysis/results/figures
     ```

7. **Verify Results**:
   - Compare generated metrics and survey results with those reported in the paper (e.g., FPR of 17.8% for Slither on reentrancy, 33.33% of developers citing false positives).

## Dataset Details
- **Source**: 653 Ethereum smart contracts from Etherscan, validated for vulnerability labels using transaction histories and literature [2–5].
- **Vulnerabilities**: Reentrancy, suicide, integer overflow/underflow, with labels indicating exploited or unexploited status.
- **Validation**: Contracts were manually inspected for vulnerability patterns (e.g., \texttt{call()} before state updates for reentrancy) and cross-referenced with security audits and transaction logs.

## Survey Details
- **Participants**: 150 Ethereum developers recruited via Prolific, with varied roles (developers, auditors) and experience (1–5 years).
- **Questions**: 25 questions (Q1–Q25), including closed-ended (e.g., Q19 on ignoring warnings) and open-ended (e.g., Q20 on rationales).
- **Analysis**: Qualitative coding of Q20 responses achieved high inter-rater reliability (Cohen’s κ = 0.866).

## Expected Results
- **Tool Evaluation**: Precision, recall, FPR, and FNR for each tool across vulnerabilities (e.g., Slither’s F1-score ~0.82 for reentrancy, FPR ~17.8%).
- **Survey Findings**:
  - RQ5: False positives and unclear explanations erode trust (87.33% prefer clear reports).
  - RQ6: 33.33% cite false positives, 18.67% unclear explanations for ignoring warnings.
  - RQ7: Developers prefer brief explanations with fix suggestions (82% preference).

## Limitations
- **Tool Versions**: Results are specific to the tool versions listed. Newer versions may yield different outcomes.
- **Dataset Scope**: Limited to Ethereum contracts; other blockchains may differ.
- **Survey Anonymity**: Responses are anonymized to comply with ethical guidelines, limiting traceability to individual participants.

## License
This replication package is licensed under the MIT License (see `LICENSE`).

## References
1. Perez, D., & Livshits, B. (2021). Smart Contract Vulnerabilities: Vulnerable Does Not Imply Exploited. *USENIX Security Symposium*.
2. SmartbugsUnhandelEx. (2020). SmartBugs Dataset.
3. Chen, T., et al. (2021). A Survey on Ethereum Smart Contract Security.
4. Hu, T., et al. (2024). A Survey on Smart Contract Vulnerabilities.
5. Abdelaziz, A., et al. (2023). Smart Contract Security: A Survey.

## Contact
For issues or questions, please open a GitHub issue or contact the repository maintainers anonymously via the ICSE 2026 submission system.
