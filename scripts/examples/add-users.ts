/**
 * Example script for adding 10 sample users to Firestore "users" collection
 * 
 * This script demonstrates:
 * - Proper TypeScript typing for Firestore operations
 * - Error handling for database operations
 * - Batch operations for efficient writes
 * - User data structure with firstName, lastName, and age
 */

import * as admin from 'firebase-admin';
import * as path from 'path';

// Interface defining the structure of a user document
interface UserData {
  firstName: string;
  lastName: string;
  age: number;
  createdAt: admin.firestore.Timestamp;
  id?: string;
}

// Configuration interface for Firebase initialization
interface FirebaseConfig {
  projectId: string;
  serviceAccountPath: string;
  collectionName: string;
}

// Sample user data with explicit typing
const sampleUsers: Omit<UserData, 'createdAt' | 'id'>[] = [
  { firstName: 'Jan', lastName: 'Kowalski', age: 28 },
  { firstName: 'Anna', lastName: 'Nowak', age: 34 },
  { firstName: 'Piotr', lastName: 'Wiśniewski', age: 22 },
  { firstName: 'Maria', lastName: 'Wójcik', age: 41 },
  { firstName: 'Tomasz', lastName: 'Kowalczyk', age: 29 },
  { firstName: 'Katarzyna', lastName: 'Kamińska', age: 26 },
  { firstName: 'Michał', lastName: 'Lewandowski', age: 35 },
  { firstName: 'Magdalena', lastName: 'Zielińska', age: 31 },
  { firstName: 'Paweł', lastName: 'Szymański', age: 27 },
  { firstName: 'Agnieszka', lastName: 'Woźniak', age: 33 }
];

/**
 * Initialize Firebase Admin SDK with service account
 * @param config - Firebase configuration object
 * @returns Promise<admin.app.App> - Initialized Firebase app instance
 */
async function initializeFirebase(config: FirebaseConfig): Promise<admin.app.App> {
  try {
    const serviceAccountPath: string = path.resolve(__dirname, config.serviceAccountPath);
    
    const app: admin.app.App = admin.initializeApp({
      credential: admin.credential.cert(serviceAccountPath),
      projectId: config.projectId
    });

    console.log(`✅ Firebase initialized successfully for project: ${config.projectId}`);
    return app;
  } catch (error: unknown) {
    if (error instanceof Error) {
      throw new Error(`Failed to initialize Firebase: ${error.message}`);
    }
    throw new Error('Unknown error occurred during Firebase initialization');
  }
}

/**
 * Add a single user to Firestore collection
 * @param db - Firestore database instance
 * @param collectionName - Name of the collection to add user to
 * @param userData - User data to be added
 * @returns Promise<string> - Document ID of the added user
 */
async function addUser(
  db: admin.firestore.Firestore,
  collectionName: string,
  userData: Omit<UserData, 'createdAt' | 'id'>
): Promise<string> {
  try {
    const userWithTimestamp: Omit<UserData, 'id'> = {
      ...userData,
      createdAt: admin.firestore.Timestamp.now()
    };

    const docRef: admin.firestore.DocumentReference = await db
      .collection(collectionName)
      .add(userWithTimestamp);

    console.log(`✅ User added: ${userData.firstName} ${userData.lastName} (ID: ${docRef.id})`);
    return docRef.id;
  } catch (error: unknown) {
    if (error instanceof Error) {
      throw new Error(`Failed to add user ${userData.firstName} ${userData.lastName}: ${error.message}`);
    }
    throw new Error(`Unknown error occurred while adding user ${userData.firstName} ${userData.lastName}`);
  }
}

/**
 * Add multiple users to Firestore using batch operations for efficiency
 * @param db - Firestore database instance
 * @param collectionName - Name of the collection to add users to
 * @param users - Array of user data to be added
 * @returns Promise<string[]> - Array of document IDs of the added users
 */
async function addUsersBatch(
  db: admin.firestore.Firestore,
  collectionName: string,
  users: Omit<UserData, 'createdAt' | 'id'>[]
): Promise<string[]> {
  try {
    const batch: admin.firestore.WriteBatch = db.batch();
    const docRefs: admin.firestore.DocumentReference[] = [];

    // Prepare batch operations
    users.forEach((userData: Omit<UserData, 'createdAt' | 'id'>) => {
      const docRef: admin.firestore.DocumentReference = db.collection(collectionName).doc();
      const userWithTimestamp: Omit<UserData, 'id'> = {
        ...userData,
        createdAt: admin.firestore.Timestamp.now()
      };
      
      batch.set(docRef, userWithTimestamp);
      docRefs.push(docRef);
    });

    // Execute batch operation
    await batch.commit();

    const userIds: string[] = docRefs.map((docRef: admin.firestore.DocumentReference) => docRef.id);
    
    console.log(`✅ Successfully added ${users.length} users to ${collectionName} collection`);
    users.forEach((user: Omit<UserData, 'createdAt' | 'id'>, index: number) => {
      console.log(`   - ${user.firstName} ${user.lastName} (Age: ${user.age}) - ID: ${userIds[index]}`);
    });

    return userIds;
  } catch (error: unknown) {
    if (error instanceof Error) {
      throw new Error(`Failed to add users in batch: ${error.message}`);
    }
    throw new Error('Unknown error occurred during batch user creation');
  }
}

/**
 * Main function to execute the user creation script
 */
async function main(): Promise<void> {
  const config: FirebaseConfig = {
    projectId: process.env.FIREBASE_PROJECT_ID || 'your-project-id',
    serviceAccountPath: '../keys/service-account-key.json',
    collectionName: 'users'
  };

  try {
    console.log('🚀 Starting user creation script...');
    console.log(`📊 Planning to add ${sampleUsers.length} users to "${config.collectionName}" collection`);

    // Initialize Firebase
    const app: admin.app.App = await initializeFirebase(config);
    const db: admin.firestore.Firestore = admin.firestore();

    // Add users using batch operation for better performance
    const userIds: string[] = await addUsersBatch(db, config.collectionName, sampleUsers);

    console.log('\n🎉 Script completed successfully!');
    console.log(`📈 Total users added: ${userIds.length}`);
    console.log('📋 Summary:');
    console.log(`   - Collection: ${config.collectionName}`);
    console.log(`   - Project: ${config.projectId}`);
    console.log(`   - User IDs: ${userIds.join(', ')}`);

  } catch (error: unknown) {
    console.error('❌ Script failed:');
    if (error instanceof Error) {
      console.error(`   Error: ${error.message}`);
    } else {
      console.error('   Unknown error occurred');
    }
    process.exit(1);
  }
}

// Execute the script if run directly
if (require.main === module) {
  main()
    .then(() => {
      console.log('\n✨ Exiting script gracefully');
      process.exit(0);
    })
    .catch((error: unknown) => {
      console.error('💥 Unhandled error:', error);
      process.exit(1);
    });
}

// Export for potential use as a module
export { addUser, addUsersBatch, UserData, FirebaseConfig };
