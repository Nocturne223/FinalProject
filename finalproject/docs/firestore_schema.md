# Firestore Database Schema

## Collections & Fields

### Products

id: string (doc ID)
name: string
categoryId: string (ref to Categories)
sku: string (stock keeping unit, optional)
description: string (optional)
quantity: number
reorderLevel: number (threshold for low inventory)
price: number
unit: string (e.g., pcs, kg, box)
imageUrl: string (optional)
isActive: boolean
createdAt: timestamp
updatedAt: timestamp

### Categories

- id: string (doc ID)
- name: string
- description: string (optional)
- createdAt: timestamp

### Transactions

- id: string (doc ID)
- productId: string (ref to Products)
- quantity: number
- type: string (sale, restock, etc.)
- timestamp: timestamp
- userId: string (ref to Users)
- notes: string (optional)

### Users

- id: string (doc ID, matches Firebase Auth UID)
- email: string
- displayName: string
- role: string (admin, staff, etc.)
- createdAt: timestamp
- isActive: boolean

## Relationships

- Products reference Categories
- Transactions reference Products and Users
- Users are linked to Auth via UID
