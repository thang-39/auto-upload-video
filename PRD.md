# PRD: Auto-Video Uploader (n8n Workflow)

## Problem Statement
Manually downloading videos from Facebook and re-uploading them to multiple platforms (YouTube, TikTok, Instagram, FB Reels) is time-consuming and tedious, especially when managing a schedule in Notion.

## Solution
An n8n workflow that automatically checks a Notion database daily, downloads the scheduled Facebook video using yt-dlp, and distributes it across all target social media platforms using their official APIs.

## User Stories

### Phase 1: Infrastructure & Environment
1. As a developer, I want to create a custom Dockerfile that includes n8n, yt-dlp, and ffmpeg, so that the environment has all necessary tools for video processing.
2. As a developer, I want to configure a docker-compose.yaml file, so that I can easily spin up and manage the n8n service with persistent storage.
3. As a developer, I want to verify that yt-dlp and ffmpeg are accessible from within the n8n container, so that the workflow can execute shell commands for downloading videos.

### Phase 2: Platform Integration (API Setup)
4. As a user, I want to create a Notion Integration and a specific database template (Title, FB Link, Public Date, Status), so that the workflow has a structured source of truth.
5. As a developer, I want to configure Google Cloud OAuth2 credentials for YouTube, so that the workflow can securely upload videos to YouTube Shorts.
6. As a developer, I want to set up TikTok Developer API access, so that the workflow can use the Direct Post API for automated TikTok uploads.
7. As a developer, I want to configure Meta Graph API credentials, so that the workflow can post to Facebook Reels and Instagram Reels simultaneously.

### Phase 3: n8n Workflow Logic
8. As a user, I want a Cron Trigger in n8n set to 8:00 PM daily, so that the automation runs consistently during peak engagement hours.
9. As a system, I want to query Notion for entries where `Status = "Ready"` and `Public Date = Today`, so that I only process the content scheduled for the current day.
10. As a system, I want to use an "Execute Command" node to run `yt-dlp` on the Facebook link, so that the video file is downloaded to a temporary local path.
11. As a system, I want to pass the downloaded video binary to the YouTube, TikTok, and Meta nodes, so that the content is distributed to all platforms in one go.

### Phase 4: Error Handling & Cleanup
12. As a system, I want to update the Notion entry status to "Completed" and store the live video URLs upon successful upload, so that I have a record of the work done.
13. As a system, I want to update the Notion entry to "Error" and log the specific failure message if any part of the process fails, so that I can troubleshoot quickly.
14. As a system, I want to delete the temporary video file from the container after all uploads are finished, so that I don't run out of disk space.

## Implementation Decisions
- **Containerization:** Use a custom Alpine-based n8n image to keep the footprint small while including `yt-dlp`.
- **Downloader:** Use `yt-dlp` because it is the most frequently updated tool for bypassing changes in Facebook's video delivery.
- **API Choice:** Always prefer official APIs (OAuth2) over web scraping/Puppeteer to ensure long-term stability and account safety.
- **Temporary Storage:** Use the `/home/node/.n8n/tmp` directory inside the container for transient video files.

## Testing Decisions
- **Isolation Testing:** Test the `yt-dlp` command independently inside the container before connecting it to n8n logic.
- **Draft Mode:** Initially configure platform nodes to upload as "Private" or "Draft" to verify formatting before going live.
- **Empty State:** Verify the workflow handles days with 0 scheduled videos without erroring.

## Out of Scope
- Automated video editing or caption generation.
- Handling videos longer than 60 seconds (Shorts/Reels limits).
- Instagram/TikTok "Trending Sound" integration (requires manual mobile interaction).
