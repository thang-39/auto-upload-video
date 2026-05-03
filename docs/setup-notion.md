# Notion Setup Guide

## Step 1: Create a Notion Integration

1. Go to **https://www.notion.so/my-integrations**
2. Click **"New integration"**
3. Give it a name (e.g. `n8n Auto Uploader`) and select your workspace
4. Click **"Submit"**
5. Copy the **Internal Integration Token** (starts with `secret_...`) — you'll need this in n8n

---

## Step 2: Set Up Your Notion Database

Create a new Notion database (or use an existing one) with **exactly** these properties:

| Property Name | Type    | Notes                                      |
|---------------|---------|--------------------------------------------|
| `Title`       | Title   | Default title field — the video name       |
| `FB Link`     | URL     | The full Facebook video URL                |
| `Public Date` | Date    | Scheduled upload date (no time needed)     |
| `Status`      | Select  | Add options: `Ready`, `Downloading`, `Downloaded`, `Error` |

> **Important:** Property names are case-sensitive. They must match exactly.

---

## Step 3: Connect the Integration to Your Database

1. Open your Notion database
2. Click the **"..."** (three dots) menu in the top right
3. Go to **Connections** → **Connect to** → select your integration (`n8n Auto Uploader`)
4. Confirm the connection

---

## Step 4: Find Your Database ID

Your database URL looks like this:
```
https://www.notion.so/yourworkspace/YOUR-DATABASE-ID?v=...
```

The **Database ID** is the 32-character string between the last `/` and the `?`.

Example:
```
https://www.notion.so/myworkspace/abc123def456abc123def456abc12345?v=xyz
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                                   This is your Database ID
```

---

## Step 5: Add Notion Credentials in n8n

> **n8n v2.x (2.0+):** Credentials are no longer under Settings. They live in the **left sidebar**.

1. Open n8n at **http://localhost:5678**
2. In the **left sidebar**, click the **"Credentials"** icon/label  
   *(If the sidebar is collapsed, look for the key 🔑 icon)*
3. Click **"Add Credential"** (top right button)
4. Search for **"Notion API"** and select it
5. Paste your **Internal Integration Token** from Step 1
6. Click **Save**

**Alternative — add credentials directly from a node:**
1. Open the imported workflow
2. Click any **Notion** node → find the **Credential** dropdown
3. Click **"Create New Credential"** and paste your token there

---

## Step 6: Import the Workflow

1. In n8n, go to **Workflows → Import from file**
2. Select `workflows/notion-download.json` from this project
3. Open the workflow and update these placeholders in each Notion node:
   - **Database ID** → replace `REPLACE_WITH_YOUR_DATABASE_ID` with your ID from Step 4
   - **Credentials** → select your saved `Notion account` credential
4. Save the workflow

---

## Step 7: Test the Workflow

### Isolation test (confirm yt-dlp works first)
```bash
# Run from your host machine
docker exec -it n8n_auto_uploader yt-dlp \
  --no-playlist \
  --merge-output-format mp4 \
  -o "/home/node/downloads/test.%(ext)s" \
  "YOUR_FACEBOOK_VIDEO_URL"

# Check the file appeared
ls ./downloads/
```

### Test the Notion query node
1. Open the workflow in n8n
2. Click the **"Get Today's Videos"** node
3. Click **"Test step"** — verify it returns your Notion entries

### Run the full workflow manually
1. Make sure you have a Notion entry with:
   - `Status = Ready`
   - `Public Date = today's date`
   - A valid Facebook video URL in `FB Link`
2. Click **"Test workflow"** in n8n

---

## Workflow Node Reference

| Node              | Purpose                                      |
|-------------------|----------------------------------------------|
| Schedule Trigger  | Runs daily at 8:00 PM (cron: `0 20 * * *`)  |
| Get Today's Videos | Queries Notion: Status=Ready, Date=Today    |
| Has Videos?       | Skips execution if no entries found          |
| Mark Downloading  | Updates Notion Status → `Downloading`        |
| Download Video    | Runs `yt-dlp` inside the container          |
| Download OK?      | Checks the command exit code                 |
| Mark Downloaded   | Updates Notion Status → `Downloaded` ✅      |
| Mark Error        | Updates Notion Status → `Error` ❌           |
