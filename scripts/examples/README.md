# Examples Directory

This directory contains example scripts demonstrating common Firestore operations with proper TypeScript typing and error handling.

## Available Examples

### add-users.ts
Demonstrates how to add multiple users to a Firestore collection with the following features:
- **Proper TypeScript typing** for all variables and functions
- **Batch operations** for efficient database writes
- **Error handling** with typed exceptions
- **User data structure** with firstName, lastName, and age fields
- **Timestamp handling** for createdAt field
- **Logging** for operation tracking

#### Usage
```bash
# Install dependencies first
npm install

# Run the script
npm run add-users

# Or use ts-node directly
npx ts-node add-users.ts
```

#### Configuration
Before running the script:
1. Place your Firebase service account key in `../keys/service-account-key.json`
2. Set your project ID as an environment variable or update the script
3. Ensure your Firestore database is set up

#### Environment Variables
```bash
export FIREBASE_PROJECT_ID="your-project-id"
```

## Script Features

### Type Safety
All scripts follow strict TypeScript typing requirements:
- Explicit type annotations for all variables
- Interface definitions for data structures
- Typed function parameters and return values
- Proper error handling with typed exceptions

### Error Handling
- Try-catch blocks for all async operations
- Meaningful error messages
- Graceful script termination on errors
- Proper logging for debugging

### Performance
- Batch operations for multiple writes
- Efficient data structures
- Minimal database calls
- Proper resource cleanup

## Creating New Scripts

When creating new scripts in this directory:

1. **Use TypeScript** with explicit type annotations
2. **Follow the naming convention**: descriptive-action.ts
3. **Include proper documentation** with JSDoc comments
4. **Implement error handling** for all operations
5. **Add logging** for operation tracking
6. **Export functions** for potential reuse
7. **Follow the .cursorrules** requirements

### Template Structure
```typescript
/**
 * Script description and purpose
 */

import * as admin from 'firebase-admin';

// Define interfaces
interface YourDataType {
  field1: string;
  field2: number;
  // ... other fields
}

// Main function
async function main(): Promise<void> {
  try {
    // Implementation
  } catch (error: unknown) {
    // Error handling
  }
}

// Execute if run directly
if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error: unknown) => {
      console.error('Error:', error);
      process.exit(1);
    });
}
```

## Security Considerations

- Never hardcode credentials in scripts
- Use environment variables for configuration
- Ensure service account keys are in the ignored `keys/` directory
- Validate input data before database operations
- Use appropriate Firestore security rules
