# Lumio Example

This example demonstrates all the features of the Lumio debugging framework for Flutter applications.

## Features Demonstrated

- 🔍 **Network Monitoring**: Automatic HTTP request/response logging
- 🚨 **Crash Detection**: Automatic crash capture and logging
- ⏱️ **ANR Monitoring**: Application Not Responding detection
- 📱 **Debug UI**: Comprehensive interface to inspect all logs
- 🔔 **Notification Access**: Persistent notification in debug mode
- 💾 **Local Storage**: Log persistence using SharedPreferences

## How to Run

1. **Install dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the example**:
   ```bash
   flutter run
   ```

3. **Test the features**:
   - The app will show a persistent notification in debug mode
   - Tap the notification to open the debug UI
   - Use the buttons in the app to test different scenarios
   - Use the bug icon in the app bar to manually open debug UI

## Testing Scenarios

### Network Testing
- **Successful API Call**: Makes a GET request to JSONPlaceholder API
- **Failed API Call**: Makes a request to a 404 endpoint
- **Slow API Call**: Makes a request to a delayed endpoint
- **Multiple Calls**: Makes multiple concurrent API calls

### Crash Testing
- **Trigger Exception**: Throws a test exception
- **Trigger Assertion**: Triggers a test assertion

### Manual Logging
- **Log API Response**: Manually logs an API response
- **Log Crash**: Manually logs a crash
- **Log ANR**: Manually logs an ANR event
- **Export Data**: Exports all logged data

## Debug Interface

When you open the debug UI, you'll see four tabs:

1. **Network Calls**: All HTTP requests with details
2. **API Responses**: All API responses with status codes and bodies
3. **Crashes**: All captured crashes with stack traces
4. **ANRs**: All ANR events with timing information

## Expected Behavior

1. **Notification**: A persistent notification should appear in debug mode
2. **Automatic Logging**: All network calls and crashes are automatically logged
3. **Real-time Updates**: The notification updates with log counts every 5 seconds
4. **Debug UI**: Tap the notification or use the bug icon to open the debug interface
5. **Data Persistence**: Logs are stored locally and persist between app restarts

## Troubleshooting

- **Notification not showing**: Ensure you're running in debug mode
- **Debug UI not opening**: Check that Lumio is properly initialized
- **No logs appearing**: Verify that you're using `Lumio.httpClient` for network calls
- **Permission issues**: Grant notification permissions when prompted

## Integration Notes

This example shows how to:
- Initialize Lumio with all features enabled
- Use the HTTP client with automatic logging
- Manually log events
- Access the debug UI programmatically
- Export and clear logs
- Handle different types of errors and crashes
