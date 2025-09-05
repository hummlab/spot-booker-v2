# Scripts

This folder contains utility scripts for working with Firestore database operations.

## Purpose

This directory is designed to hold helper scripts that facilitate quick and efficient work with Firestore database. These scripts can be used for:

- Data seeding and population
- Database maintenance tasks
- Testing data generation
- Bulk operations
- Data migration utilities

## Structure

- `keys/` - Contains Firebase service account keys and API configurations
- `examples/` - Example scripts demonstrating common Firestore operations
- Individual script files for specific database tasks

## Usage

1. Place your Firebase service account key in the `keys/` directory
2. Install required dependencies (typically Firebase Admin SDK)
3. Run scripts as needed for your database operations

## Security Note

The `keys/` directory is ignored by git to prevent accidentally committing sensitive credentials. Always ensure your service account keys remain secure and never commit them to version control.

## Requirements

- Node.js
- Firebase Admin SDK
- Valid Firebase service account key

## Getting Started

1. Download your Firebase service account key from the Firebase Console
2. Place it in the `keys/` directory
3. Update script configurations to point to your key file
4. Run the desired scripts

## Examples

See the `examples/` directory for common Firestore operations and script templates.
