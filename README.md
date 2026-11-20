# SIMS – Student Information Management System

## How to run (Windows)

1. Click **Code → Download ZIP** above, then extract it.
2. Open the extracted folder. Click the address bar at the top, type this and press **Enter**:

   ```
   powershell -ExecutionPolicy Bypass -File .\setup.ps1
   ```

   If Windows asks for permission, click **Yes**. The first time can take 20-40 minutes.
3. When Visual Studio opens, press **F5**.

## Log in

Password: **`Test@123`**

- Admin: `admin@sims.edu`
- Lecturer: `lecturer@sims.edu`
- Student: `student1@sims.edu`

## Can't log in?

Run this the same way as step 2. It sets every password to `Test@123`:

```
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -ResetPasswords
```

## Database errors?

Start with a clean database. This **deletes** your old SIMS_DB:

```
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -FreshDatabase
```
