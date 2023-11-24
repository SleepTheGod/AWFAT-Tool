AWFAT-Tool
Advanced Windows Forensic Analysis Tool
The "Advanced Windows Forensic Analysis Tool" (AWFAT) is a PowerShell script designed to conduct comprehensive forensic analysis on Windows systems. AWFAT enables users to perform advanced examination and data extraction from target processes, including memory disassembly, network traffic monitoring, and registry hive analysis. The tool's modular structure ensures compatibility across various Windows versions while providing detailed artifact documentation for forensic investigations. AWFAT assists in generating comprehensive reports aiding in incident response, forensic investigations, and system analysis.

PowerShell Script Overview
Module Imports: Imports necessary PowerShell modules like Net.Sockets, System.Net.NetworkInformation, and Microsoft.PowerShell.Security.
Attribution: Sets the variable $attribution to indicate the creator of the script.
Defining Target: Sets the variable $targetProcessName to "notepad" as the process to analyze.
Checking IDA Pro Installation: Checks if IDA Pro (a disassembler/debugger) is installed. If not, it attempts to download and run the installer.
Checking Target Process: Checks if the target process (in this case, "notepad") is running. If not found, it stops further execution.
Creating Artifacts Folder: Creates a folder in the temp directory to store artifacts.
Extracting Process Memory: Tries to extract the memory content of the target process.
Disassembling Memory Contents: Attempts to disassemble the extracted memory content using IDA Pro.
Saving Disassembled Code: Saves the disassembled code into a text file for documentation.
Analyzing Network Activity: Monitors and captures network traffic associated with the target process using NetMon (Network Monitor).
Analyzing Registry Hives: Analyzes registry hives associated with the target process and exports them to files.
Generating Forensic Report: Creates a comprehensive forensic report summarizing various aspects like the target process, disassembled code location, captured network traffic file path, registry hives, and the attribution. The report is saved in a text file within the artifacts folder.
Completion Message: Outputs a message indicating the completion of the forensic analysis and prompts the user to refer to the artifacts folder for detailed information.
Purpose and Functionality
This script automates the process of collecting information related to a specific process, including its memory content, network activity, and associated registry hives. It compiles this information into a forensic report for further analysis.
