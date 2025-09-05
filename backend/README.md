# Backend Directory

This directory contains Firebase Cloud Functions that provide server-side logic for the Flutter applications.

## Purpose

The `backend/` directory houses Firebase Cloud Functions that handle server-side operations, API endpoints, and business logic that cannot be performed on the client side.

## Structure

```
backend/
├── functions/              # Firebase Cloud Functions
│   ├── src/               # Source code
│   │   ├── auth/          # Authentication functions
│   │   ├── users/         # User management functions
│   │   ├── products/      # Product management functions
│   │   ├── orders/        # Order processing functions
│   │   └── utils/         # Utility functions
│   ├── package.json       # Node.js dependencies
│   ├── tsconfig.json      # TypeScript configuration
│   └── firebase.json      # Firebase configuration
├── scripts/               # Build and deployment scripts
└── docs/                  # API documentation
```

## Function Types

### HTTP Functions
REST API endpoints for client applications:

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

export const createUser = functions.https.onCall(async (data, context) => {
  try {
    // Verify authentication
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
    
    const { email, name, role } = data;
    
    // Create user in Firestore
    const userRef = admin.firestore().collection('users').doc();
    await userRef.set({
      id: userRef.id,
      email,
      name,
      role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
    
    return { success: true, userId: userRef.id };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Failed to create user');
  }
});
```

### Firestore Triggers
Functions triggered by Firestore document changes:

```typescript
export const onUserCreated = functions.firestore
  .document('users/{userId}')
  .onCreate(async (snap, context) => {
    const userData = snap.data();
    
    // Send welcome email
    await sendWelcomeEmail(userData.email, userData.name);
    
    // Create user profile
    await admin.firestore().collection('profiles').doc(context.params.userId).set({
      userId: context.params.userId,
      email: userData.email,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
```

### Authentication Triggers
Functions triggered by Firebase Auth events:

```typescript
export const onUserSignUp = functions.auth.user().onCreate(async (user) => {
  // Create user profile in Firestore
  await admin.firestore().collection('users').doc(user.uid).set({
    id: user.uid,
    email: user.email,
    name: user.displayName || '',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
});
```

## Development Guidelines

- **Strong Typing**: Use TypeScript for all functions with explicit types
- **Error Handling**: Implement comprehensive error handling and logging
- **Authentication**: Verify user authentication for sensitive operations
- **Validation**: Validate all input data before processing
- **Security**: Follow Firebase security best practices
- **Testing**: Write unit tests for all functions
- **Documentation**: Document all functions and their parameters

## Example Function

```typescript
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

interface CreateProductRequest {
  name: string;
  description: string;
  price: number;
  category: string;
  imageUrl?: string;
}

interface CreateProductResponse {
  success: boolean;
  productId?: string;
  error?: string;
}

/**
 * Creates a new product in the system
 * 
 * @param data - Product data including name, description, price, and category
 * @param context - Firebase function context containing authentication info
 * @returns Promise<CreateProductResponse> - Success status and product ID or error
 */
export const createProduct = functions.https.onCall(
  async (data: CreateProductRequest, context): Promise<CreateProductResponse> => {
    try {
      // Verify authentication
      if (!context.auth) {
        return {
          success: false,
          error: 'User must be authenticated',
        };
      }
      
      // Validate input data
      if (!data.name || !data.description || !data.price || !data.category) {
        return {
          success: false,
          error: 'Missing required fields: name, description, price, category',
        };
      }
      
      if (data.price <= 0) {
        return {
          success: false,
          error: 'Price must be greater than 0',
        };
      }
      
      // Check if user has admin role
      const userDoc = await admin.firestore().collection('users').doc(context.auth.uid).get();
      const userData = userDoc.data();
      
      if (!userData || userData.role !== 'admin') {
        return {
          success: false,
          error: 'Insufficient permissions. Admin role required.',
        };
      }
      
      // Create product in Firestore
      const productRef = admin.firestore().collection('products').doc();
      await productRef.set({
        id: productRef.id,
        name: data.name,
        description: data.description,
        price: data.price,
        category: data.category,
        imageUrl: data.imageUrl || '',
        createdBy: context.auth.uid,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      return {
        success: true,
        productId: productRef.id,
      };
      
    } catch (error) {
      console.error('Error creating product:', error);
      return {
        success: false,
        error: 'Internal server error',
      };
    }
  }
);
```

## Setup Instructions

1. **Install Firebase CLI**:
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase project**:
   ```bash
   firebase login
   firebase init functions
   ```

3. **Install dependencies**:
   ```bash
   cd functions
   npm install
   ```

4. **Deploy functions**:
   ```bash
   firebase deploy --only functions
   ```

## Best Practices

1. **Security**: Always verify authentication and authorization
2. **Validation**: Validate all input data thoroughly
3. **Error Handling**: Implement proper error handling and logging
4. **Performance**: Optimize functions for cold start times
5. **Monitoring**: Use Firebase Console for monitoring and debugging
6. **Testing**: Write comprehensive unit tests
7. **Documentation**: Document all functions and their usage
8. **Environment Variables**: Use environment variables for configuration 