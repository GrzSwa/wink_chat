# REST API Plan

## 1. Resources

- User: Represents a user's anonymous profile. Corresponds to the `users` collection in Firestore.
- Chat: Represents a conversation request or an active chat's metadata. Corresponds to the `chats` collection in Firestore.
- Message: Represents an individual chat message during an active conversation. Stored temporarily in Realtime Database. (No standard REST endpoints for real-time messages, handled by RTDB SDK).
- Report: Represents a user's report against another user. Corresponds to the `reports` collection in Firestore.
- ArchivedMessage: Represents a message moved from Realtime Database to cold storage. Corresponds to the `chatMessagesArchive` collection in Firestore.

## 2. Endpoints

### User Endpoints

- Method: POST

  - URL: `/users`
  - Description: Create a new user profile after Firebase Authentication registration.
  - Request Body:
    ```json
    {
      "pseudonym": "string", // required, unique
      "gender": "string", // required, "M", "F", "Other"
      "location": {
        // required
        "type": "string", // "city", "country", "voivodeship"
        "value": "string" // name of the location
      }
    }
    ```
  - Response Body:
    ```json
    {
      "id": "string", // The user's UID
      "pseudonym": "string",
      "gender": "string",
      "location": {
        "type": "string",
        "value": "string"
      },
      "lastSeen": "timestamp",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
    ```
  - Success Codes: 201 Created
  - Error Codes: 400 Bad Request, 401 Unauthorized, 409 Conflict (Pseudonym taken), 500 Internal Server Error

- Method: PUT

  - URL: `/users/{userId}`
  - Description: Update the authenticated user's profile information. `{userId}` must match the authenticated user's UID.
  - Request Body:
    ```json
    {
      "pseudonym": "string", // optional, unique
      "gender": "string", // optional, "M", "F", "Other"
      "location": {
        // optional
        "type": "string", // "city", "country", "voivodeship"
        "value": "string" // name of the location
      },
      "lastSeen": "timestamp" // Optional, for updating active status
    }
    ```
  - Response Body:
    ```json
    {
      "id": "string", // The user's UID
      "pseudonym": "string",
      "gender": "string",
      "location": {
        "type": "string",
        "value": "string"
      },
      "lastSeen": "timestamp",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
    ```
  - Success Codes: 200 OK
  - Error Codes: 400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found, 409 Conflict (Pseudonym taken), 500 Internal Server Error

- Method: GET

  - URL: `/users/me` or `/users/{userId}` (where `{userId}` is authenticated user's UID)
  - Description: Get the authenticated user's full profile details.
  - Response Body:
    ```json
    {
      "id": "string", // The user's UID
      "pseudonym": "string",
      "gender": "string",
      "location": {
        "type": "string",
        "value": "string"
      },
      "lastSeen": "timestamp",
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
      // Add reportCount if visible to self? Probably not in MVP.
    }
    ```
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 404 Not Found, 500 Internal Server Error

- Method: GET
  - URL: `/users`
  - Description: Search for active users in a specific administrative location. Returns limited profile data.
  - Query Parameters:
    - `locationType`: string (required, "city", "country", or "voivodeship")
    - `locationValue`: string (required, name of the location)
    - `minLastSeen`: timestamp (optional, filter for users active since this time)
    - `limit`: integer (optional, default 50 or 100) - For pagination
    - `orderBy`: string (optional, e.g., "lastSeen:desc") - For sorting
  - Response Body:
    ```json
    [
      {
        "id": "string", // The user's UID
        "pseudonym": "string",
        "gender": "string",
        "lastSeen": "timestamp"
        // Only limited public fields returned
      }
      // ... more users
    ]
    ```
  - Success Codes: 200 OK
  - Error Codes: 400 Bad Request, 401 Unauthorized, 500 Internal Server Error

### Chat Endpoints

- Method: POST

  - URL: `/chats`
  - Description: Initiate a new conversation request.
  - Request Body:
    ```json
    {
      "recipientId": "string" // required, UID of the user to send the request to
    }
    ```
  - Response Body:
    ```json
    {
      "id": "string", // The new chat document ID
      "participantIds": ["string", "string"], // [initiatorId, recipientId]
      "status": "pending",
      "initiatorId": "string", // UID of authenticated user
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
    ```
  - Success Codes: 201 Created
  - Error Codes: 400 Bad Request, 401 Unauthorized, 404 Not Found (Recipient not found), 409 Conflict (Chat already exists/pending), 500 Internal Server Error

- Method: GET

  - URL: `/chats`
  - Description: Get a list of the authenticated user's chats (active, pending, etc.).
  - Query Parameters:
    - `status`: string (optional, filter by status, e.g., "pending", "active", "ended". Can be comma-separated for multiple statuses).
    - `limit`: integer (optional) - Pagination
    - `orderBy`: string (optional, e.g., "updatedAt:desc") - Sorting
  - Response Body:
    ```json
    [
      {
        "id": "string", // Chat document ID
        "participantIds": ["string", "string"],
        "status": "string",
        "initiatorId": "string",
        "createdAt": "timestamp",
        "updatedAt": "timestamp",
        "endedAt": "timestamp" // Included if exists
        // Include limited info about the other participant? E.g., otherParticipantPseudonym. Denormalization might be needed for performance on chat list screen.
      }
      // ... more chats
    ]
    ```
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 500 Internal Server Error

- Method: GET

  - URL: `/chats/{chatId}`
  - Description: Get details for a specific chat. Limited access (only participants).
  - Response Body:
    ```json
    {
      "id": "string", // Chat document ID
      "participantIds": ["string", "string"],
      "status": "string",
      "initiatorId": "string",
      "createdAt": "timestamp",
      "updatedAt": "timestamp",
      "endedAt": "timestamp" // Included if exists
      // No message data here - messages are in RTDB/Archive
    }
    ```
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 403 Forbidden (Not a participant), 404 Not Found, 500 Internal Server Error

- Method: PUT

  - URL: `/chats/{chatId}/accept`
  - Description: Accept a pending chat request. User must be the recipient and status must be 'pending'.
  - Response Body: Updated Chat document.
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 403 Forbidden (Not recipient or not pending), 404 Not Found, 500 Internal Server Error

- Method: PUT

  - URL: `/chats/{chatId}/reject`
  - Description: Reject a pending chat request. User must be the recipient and status must be 'pending'. (Decision needed: delete chat document or set status to 'rejected'). Assuming status change for now.
  - Response Body: Updated Chat document (status 'rejected').
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 403 Forbidden (Not recipient or not pending), 404 Not Found, 500 Internal Server Error

- Method: PUT
  - URL: `/chats/{chatId}/end`
  - Description: Manually end an active chat. User must be a participant and status must be 'active'. (Trigger for archival).
  - Response Body: Updated Chat document (status 'ended').
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 403 Forbidden (Not participant or not active), 404 Not Found, 500 Internal Server Error

### Message Endpoints (Realtime Database - No Standard REST)

- Note: Active chat messages are handled via Firebase Realtime Database SDK with listeners, not traditional REST endpoints for sending/receiving.
  - Client SDK writes to `/messages/{chatId}/{messageId}` (POST equivalent).
  - Client SDK listens to `/messages/{chatId}/` (GET equivalent, but real-time stream).

### Report Endpoints

- Method: POST
  - URL: `/reports`
  - Description: File a report against another user.
  - Request Body:
    ```json
    {
      "reportedUserId": "string", // required, UID of the user being reported
      "type": "string" // required, "Hejt", "Spam", "Rasizm", "Agresja słowna", "Oszust"
      // reportingUserId is taken from authenticated user's UID
    }
    ```
  - Response Body:
    ```json
    {
      "id": "string", // The new report document ID
      "reportingUserId": "string",
      "reportedUserId": "string",
      "type": "string",
      "timestamp": "timestamp",
      "status": "new"
    }
    ```
  - Success Codes: 201 Created
  - Error Codes: 400 Bad Request, 401 Unauthorized, 404 Not Found (Reported user not found?), 500 Internal Server Error

### Archived Message Endpoints (For potential future Moderator/Admin UI - Outside MVP User Flow)

- Method: GET
  - URL: `/chats/{chatId}/messages/archive` (Alternative: `/archived-messages?chatId={chatId}`)
  - Description: Retrieve archived messages for a specific chat. Requires Moderator/Admin authorization.
  - Response Body: Array of archived message objects.
  - Success Codes: 200 OK
  - Error Codes: 401 Unauthorized, 403 Forbidden (Not authorized), 404 Not Found (Chat or archive not found), 500 Internal Server Error

## 3. Authentication and Authorization

- **Authentication:** Firebase Authentication will be used for user registration and login via email and password. All API endpoints (implemented via Cloud Functions or accessed directly via client SDK + Security Rules) will require a valid authenticated user. The user's UID will be available from the authentication context.
- **Authorization:** Access control will be primarily enforced using Firebase Security Rules for both Firestore and Realtime Database.
  - Users can only read/write their own `/users/{userId}` document (except limited public fields on others).
  - Users can query `/users` collection but receive only limited public fields and are filtered by location/activity.
  - Users can create documents in the `/chats` collection (sending a request).
  - Users can read/update chat documents in `/chats` only if their UID is in the `participantIds` array. Special rules for accepting/rejecting (must be the recipient, status 'pending').
  - Users can create documents in the `/reports` collection.
  - Users cannot read/modify documents in the `/reports` collection after creation (except possibly for moderators/admins via separate rules or Cloud Functions).
  - In Realtime Database, rules for `/messages/{chatId}/` will ensure reads/writes are only allowed if the authenticated user's UID is one of the participants implied by `{chatId}`.
  - Admin/Moderator access to `reports` and `chatMessagesArchive` will require specific authorization logic (e.g., Firebase Auth Custom Claims or checking against an admin UID list) enforced by Security Rules or within Cloud Functions if endpoints are implemented there.

## 4. Validation and Business Logic

- **Validation:**

  - All required fields in request payloads must be present.
  - Data types must match schema definition (e.g., string, timestamp).
  - String fields may have length constraints (TBD).
  - Enum fields (`gender`, `location.type`, `chat.status`, `report.type`) must use allowed values.
  - `pseudonym` must be unique across all users (enforced server-side, likely via Cloud Function or transaction on user creation/update).
  - `location` structure must be valid.
  - `participantIds` array in `chats` must contain exactly two valid UIDs.
  - `reportedUserId` in `reports` must be a valid existing user UID.
  - Timestamp fields (`lastSeen`, `createdAt`, `updatedAt`, `endedAt`, `timestamp`, `archivedAt`, `messageData.time`) must be valid timestamps.

- **Business Logic Implementation:**
  - **Profile Creation/Update:** Handled via POST/PUT `/users`. Server-side logic ensures pseudonym uniqueness and validates input. `createdAt` and `updatedAt` timestamps are managed server-side.
  - **Nearby Search:** Handled via GET `/users` with query parameters. Server-side logic performs the filtering by `location.type`, `location.value`, and `lastSeen` using Firestore queries and indexes. Limits public fields in the response.
  - **Chat Initiation:** Handled via POST `/chats`. Server-side logic creates the initial chat document with status "pending" and the initiator's UID. Checks if a pending/active chat already exists between participants.
  - **Chat Request Management (Accept/Reject):** Handled via PUT `/chats/{chatId}/accept` and `/chats/{chatId}/reject`. Server-side logic verifies the user is the recipient and the chat status is 'pending' before updating the status to 'active' or 'rejected'. Uses transactions for atomic updates if needed.
  - **Chat Ending:** Handled via PUT `/chats/{chatId}/end`. Server-side logic verifies the user is a participant and status is 'active' before setting status to 'ended'. This action triggers the archival process (see below).
  - **Real-time Chat Messaging:** Handled directly by Firebase Realtime Database SDK. Server-side logic (Security Rules) ensures only participants can write messages.
  - **Reporting:** Handled via POST `/reports`. Server-side logic creates the report document. A Cloud Function triggered by this creation will increment the `reportCount` on the `reportedUserId`'s user document atomically using a transaction.
  - **10-Report Threshold:** Logic triggered by the Cloud Function monitoring the `reportCount` on user documents. When the count reaches 10, it initiates the manual verification procedure (details of notification/workflow for "responsible persons" are outside this API plan scope).
  - **Chat Archival:** A separate server-side process (likely Firebase Cloud Functions scheduled or triggered by chat ending) runs periodically (every 30 days as per decision) to move messages from RTDB to the `chatMessagesArchive` collection in Firestore for chats marked as 'ended' or inactive for a period. Requires robust logic to read from RTDB, write to Firestore (batched writes recommended), and delete from RTDB atomically and reliably.
  - **Active Status Update:** Handled via PUT `/users/{userId}` updating the `lastSeen` field periodically from the client. Server-side logic (Security Rules) ensures only the user can update their own status. Consider optimizing write frequency or using RTDB Presence.
  - **Moderation Workflow (Basic):** Access to view and update reports (e.g., status) requires specific authorization. This is handled by Security Rules or logic within Cloud Functions if dedicated moderator endpoints were built.
