# Chat API Integration

This document explains how the chat functionality has been integrated into the application to load conversations from the API instead of using hardcoded data.

## Overview

The chat system now includes:
- API-based conversation loading
- Real-time unread message count
- Pagination support
- Error handling and retry functionality
- Proper state management

## Components

### 1. Models (`lib/models/`)

#### `conversation.dart`
- `Conversation` class: Represents a chat conversation
- `Message` class: Represents individual messages
- `MessageType` enum: Different types of messages (text, image, video, etc.)

#### `user.dart`
- Updated `User` class with id, email, phone fields
- JSON serialization support

#### `chat_preview.dart`
- `ChatPreviewModel` class for displaying conversation previews
- Factory constructor to convert from `Conversation` to `ChatPreviewModel`
- Time formatting utilities

### 2. API Layer (`lib/api/`)

#### `chat_repository.dart`
- `ChatRepository` class: Handles all chat-related API calls
- Methods:
  - `getConversations()`: Load conversations with pagination
  - `getConversationById()`: Get specific conversation
  - `getMessages()`: Load messages for a conversation
  - `sendMessage()`: Send a new message
  - `createConversation()`: Create new conversation
  - `getUnreadMessageCount()`: Get total unread count
  - `updateLastSeen()`: Mark conversation as read

### 3. Controller (`lib/controllers/`)

#### `chat_controller.dart`
- `ChatController` class: Manages chat state using `ChangeNotifier`
- Features:
  - Conversation list management
  - Pagination support
  - Loading states
  - Error handling
  - Unread count tracking

### 4. UI Components (`lib/custom_widgets/`)

#### `chat_list_widget.dart`
- Updated to use `ChatController`
- Displays conversations from API
- Pull-to-refresh functionality
- Infinite scroll for pagination
- Error states with retry option

#### `layouts/home_widget.dart`
- Creates and provides `ChatController` to `ChatListWidget`
- Uses global `apiService` instance

## Usage

### Setting up Authentication

The chat functionality requires an authenticated user. Make sure the API token is set:

```dart
// After successful login
apiService.token = "your_auth_token_here";
```

### Loading Conversations

The chat list automatically loads when the widget is displayed:

```dart
// In ChatListWidget initialization
widget.chatController.loadConversations(refresh: true);
widget.chatController.loadUnreadCount();
```

### API Endpoints

The following endpoints are expected (using `Constance.chatUrl`):

- `GET /room` - Get conversations list
- `GET /room/{id}` - Get specific conversation
- `GET /message/{conversationId}` - Get messages
- `POST /message/{conversationId}` - Send message
- `POST /room` - Create conversation
- `GET /user/unread-count` - Get unread count
- `PATCH /room/{id}/last-seen` - Mark as read

### Response Format

Expected API response formats:

#### Conversations List
```json
{
  "rooms": [
    {
      "id": "conversation_id",
      "name": "Conversation Name",
      "avatar": "avatar_url",
      "members": [...],
      "lastMessage": {...},
      "isGroup": false,
      "unreadCount": 3,
      "createdAt": "2023-01-01T00:00:00Z",
      "updatedAt": "2023-01-01T00:00:00Z"
    }
  ]
}
```

#### Messages List
```json
{
  "messages": [
    {
      "id": "message_id",
      "conversationId": "conversation_id",
      "content": "Message content",
      "type": "text",
      "senderId": 123,
      "sender": {...},
      "createdAt": "2023-01-01T00:00:00Z"
    }
  ]
}
```

## Error Handling

The system includes comprehensive error handling:
- Network errors are caught and displayed
- Retry functionality for failed requests
- Loading states during API calls
- Empty states when no data is available

## Troubleshooting

### Debug Information

The chat repository now includes extensive debug logging. Check the Flutter console for detailed information:

```
Fetching conversations from: https://chat.xintel.info/api/room?skip=0&limit=20
Headers: {Content-Type: application/json, Accept: application/json, Authorization: Bearer your_token}
Response status: 200
Response body: {"rooms": [...]}
```

### Common Issues

#### 1. Authentication Errors

**Symptom**: Getting 401 errors or unexpected responses
**Solution**: Ensure the API token is properly set:

```dart
// Check if token is set
print('API Token: ${apiService.token}');

// Set token after login
apiService.token = loginResponse.token;
```

#### 2. Wrong Response Format

**Symptom**: Error like "type 'String' is not a subtype of type 'Map<String, dynamic>'"
**Solution**: The API is returning a different format than expected. Check the debug logs to see the actual response format.

#### 3. API Endpoint Issues

**Symptom**: 404 errors or unexpected responses
**Solution**: Verify the API endpoints are correct:

```dart
// Check the base URL
print('Chat URL: ${Constance.chatUrl}');
```

#### 4. Network Issues

**Symptom**: Connection timeouts or network errors
**Solution**: Check network connectivity and API server status.

### Response Format Flexibility

The chat repository now handles multiple response formats:

- Standard format: `{"rooms": [...]}` or `{"data": [...]}`
- Direct array: `[{...}, {...}]`
- Different field names: `conversations`, `data`, `rooms`
- Error responses: Proper error message extraction

### Debugging Steps

1. **Enable debug logging** - Check Flutter console for detailed API logs
2. **Verify authentication** - Ensure the token is valid and properly set
3. **Check API responses** - Look at the actual response format in logs
4. **Test endpoints manually** - Use tools like Postman to test the API directly
5. **Check network** - Ensure the device can reach the API server

### Example Debug Output

```
Fetching conversations from: https://chat.xintel.info/api/room?skip=0&limit=20
Response status: 200
Response body: "336"
Parsed response data: 336
Response data type: String
Unexpected response format: String
```

This shows the API is returning a string "336" instead of JSON, indicating a server-side issue.

## Future Enhancements

Potential improvements:
1. WebSocket integration for real-time updates
2. Message caching for offline support
3. Search functionality
4. Message encryption
5. File upload support
6. Push notifications

## Dependencies

The implementation uses only Flutter's built-in packages:
- `http` for API calls
- `flutter/material.dart` for UI components

No external state management libraries are required as the implementation uses `ChangeNotifier` which is part of Flutter's core. 