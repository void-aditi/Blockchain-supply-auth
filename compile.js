import path from 'path';
import fs from 'fs-extra';
import solc from 'solc';
import { fileURLToPath } from 'url';

// Resolve the current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Define paths
const buildPath = path.resolve(__dirname, 'build');
const contractsPath = path.resolve(__dirname, 'contracts');
const inboxPath = path.resolve(contractsPath, 'Inbox.sol');

// Ensure the Solidity file exists
if (!fs.existsSync(inboxPath)) {
    console.error("Error: Inbox.sol not found in contracts directory.");
    process.exit(1);
}

// Remove the existing build directory
fs.removeSync(buildPath);

// Read the Solidity contract source code
const source = fs.readFileSync(inboxPath, 'utf-8');

// Define Solidity compiler input format
const input = {
    language: 'Solidity',
    sources: {
        'Inbox.sol': {
            content: source
        }
    },
    settings: {
        outputSelection: {
            '*': {
                '*': ['abi', 'evm.bytecode.object']
            },
        },
    },
};

// Compile the Solidity contract
const output = JSON.parse(solc.compile(JSON.stringify(input)));

// Check for compilation errors
if (output.errors) {
    console.error("Compilation Errors:", output.errors);
    process.exit(1);
}

// Ensure the build directory exists
fs.ensureDirSync(buildPath);

// Extract and save compiled contracts
for (let contractName in output.contracts['Inbox.sol']) {
    fs.outputJSONSync(
        path.resolve(buildPath, contractName.replace(':', '') + '.json'),
        output.contracts['Inbox.sol'][contractName]
    );
}

console.log("✅ Compilation completed successfully.");
