# TikTok API Setup Guide

## Step 1: Create a TikTok Developer Account

1.  Go to the [TikTok For Developers](https://developers.tiktok.com/) portal.
2.  Log in with your TikTok account.
3.  Complete the developer registration if you haven't already.

## Step 2: Create a New App

1.  Click **"Manage apps"** and then **"Connect an app"**.
2.  Fill in the app details (Name, Description, Icon).
3.  Under **"Capabilities"**, ensure you request access to the **"Content Posting API"** (specifically **Direct Post**).
4.  **Important:** In the **"Redirect URI"** field, add your n8n callback URL:
    `https://<your-n8n-domain>/rest/oauth2-callback`
    *(If running locally, use `http://localhost:5678/rest/oauth2-callback`)*

## Step 3: Get Your Credentials

1.  Once your app is created, go to the **"App Details"** page.
2.  Copy your **Client Key** and **Client Secret**.

## Step 4: Add TikTok Credentials in n8n

1.  Open n8n and go to **Credentials**.
2.  Click **"Add Credential"**.
3.  Search for **"TikTok API"** (or use generic **"OAuth2"** if the TikTok node is not available).
4.  Enter the following details:
    *   **Grant Type:** Authorization Code
    *   **Authorization URL:** `https://www.tiktok.com/v2/auth/authorize/`
    *   **Access Token URL:** `https://open.tiktokapis.com/v2/oauth/token/`
    *   **Client ID:** (Your Client Key)
    *   **Client Secret:** (Your Client Secret)
    *   **Scope:** `video.publish,video.upload`
    *   **Auth URI Query Parameters:** `client_key=<YOUR_CLIENT_KEY>&scope=video.publish,video.upload&response_type=code`

## Step 5: Update the Workflow

1.  Open the imported workflow in n8n.
2.  Find the **"Initiate TikTok Upload"** node.
3.  In the **"Credential for TikTok API"** dropdown, select your newly created TikTok account.
4.  Save the workflow.

## Notes on "Direct Post" vs "Drafts"
*   **Direct Post:** Automatically publishes the video to your profile.
*   **Upload to Inbox:** Saves the video as a draft in the user's TikTok app for manual publishing.
*   This workflow is configured for **Direct Post**. If your app is not yet audited by TikTok, uploads may default to "Private" (Self Only).
