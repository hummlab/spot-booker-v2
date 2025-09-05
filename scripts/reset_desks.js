#!/usr/bin/env node

const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin SDK with service account
const serviceAccount = require('./keys/service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Collection names
const COLLECTIONS = {
  DESKS: 'desks'
};

/**
 * Script to reset all desks in Firestore
 * This script will:
 * 1. Delete all existing desks from Firestore
 * 2. Add four example desks based on the Desk model
 */
async function main() {
  console.log('🚀 Starting desk reset process...');

  try {
    // Step 1: Delete all existing desks
    await deleteAllDesks();
    
    // Step 2: Add example desks
    await addExampleDesks();
    
    console.log('✅ Desk reset completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error during desk reset:', error);
    process.exit(1);
  }
}

/**
 * Deletes all existing desks from Firestore
 */
async function deleteAllDesks() {
  console.log('🗑️  Deleting all existing desks...');
  
  try {
    // Get all desk documents
    const snapshot = await db.collection(COLLECTIONS.DESKS).get();
    
    if (snapshot.empty) {
      console.log('   No existing desks found to delete.');
      return;
    }
    
    // Delete all desks in batches (Firestore batch limit is 500)
    const batch = db.batch();
    let deleteCount = 0;
    
    snapshot.forEach(doc => {
      batch.delete(doc.ref);
      deleteCount++;
    });
    
    await batch.commit();
    console.log(`   ✅ Successfully deleted ${deleteCount} desks.`);
  } catch (error) {
    console.log('   ❌ Error deleting desks:', error);
    throw error;
  }
}

/**
 * Adds four example desks to Firestore
 */
async function addExampleDesks() {
  console.log('➕ Adding example desks...');
  
  const now = admin.firestore.Timestamp.now();
  
  const exampleDesks = [
    {
      id: generateId(),
      name: 'Desk by Window',
      code: 'A1',
      enabled: true,
      notes: 'Great natural lighting, overlooking the garden',
      createdAt: now,
      updatedAt: now,
    },
    {
      id: generateId(),
      name: 'Standing Desk',
      code: 'B2',
      enabled: true,
      notes: 'Height adjustable, ergonomic setup with monitor arm',
      createdAt: now,
      updatedAt: now,
    },
    {
      id: generateId(),
      name: 'Conference Room Desk',
      code: 'C3',
      enabled: true,
      notes: 'Private space for calls and meetings',
      createdAt: now,
      updatedAt: now,
    },
    {
      id: generateId(),
      name: 'Quiet Zone Desk',
      code: 'D4',
      enabled: false,
      notes: 'Currently under maintenance - will be available next week',
      createdAt: now,
      updatedAt: now,
    },
  ];
  
  try {
    const batch = db.batch();
    
    for (const desk of exampleDesks) {
      const docRef = db.collection(COLLECTIONS.DESKS).doc(desk.id);
      batch.set(docRef, desk);
      
      console.log(`   📝 Preparing to add: ${desk.name} (${desk.code}) - ${desk.enabled ? "Enabled" : "Disabled"}`);
    }
    
    await batch.commit();
    console.log(`   ✅ Successfully added ${exampleDesks.length} example desks.`);
    
    // Print summary
    console.log('\n📋 Summary of added desks:');
    for (const desk of exampleDesks) {
      const status = desk.enabled ? '🟢 Enabled' : '🔴 Disabled';
      const displayName = `${desk.name} (${desk.code})`;
      console.log(`   • ${displayName} - ${status}`);
      if (desk.notes) {
        console.log(`     Notes: ${desk.notes}`);
      }
    }
  } catch (error) {
    console.log('   ❌ Error adding example desks:', error);
    throw error;
  }
}

/**
 * Generate a unique ID for Firestore documents
 */
function generateId() {
  return db.collection('_').doc().id;
}

// Run the script
if (require.main === module) {
  main();
}

module.exports = { main, deleteAllDesks, addExampleDesks };