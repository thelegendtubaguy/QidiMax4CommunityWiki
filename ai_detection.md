# AI Detection
`algo_app` is a bundled local AI/video service that Qidi ships alongside Klipper, Moonraker, and the touchscreen stack. It is not just a model binary; it is a full application with its own API, video pipeline, printer-state integration, and on-device inference stack.

## What it is
- A packaged Python app, likely frozen with PyInstaller or similar.
- Uses FastAPI/uvicorn for its HTTP API.
- Uses websockets to subscribe to Moonraker.
- Uses OpenCV for video/frame handling.
- Uses ONNX Runtime for local ML inference.
- Ships internal modules for detection_deal, foreign_check, pei_detector, moonraker_subscribe, video_input_deal, klipper_g28_detector, and ONNX/YOLO target detection.

## What it talks to
- Moonraker on port 7125.
- Its own HTTP API on port 9010.
- Likely the camera stack via local video input.
- Likely Qidi's UI client, directly or indirectly, for status/config/results.

## What is running inside it
- PrinterStatusControl thread
- video_input_deal thread
- DetectionDeal thread
- detect_pos thread
- MoonrakerSubscribe thread
- api thread

That means it stays alive as a multi-threaded service even when the printer is idle.

## How it runs
- Managed by systemd as `algo_app.service`
- Starts after `network.target` and `moonraker.service`
- Auto-restarts on failure with `Restart=always`
- Runs as `root`
- Working directory: `/usr/local/bin/algo_app`
- `PYTHONPATH` points at the app dir
- `LD_LIBRARY_PATH` points at `/usr/local/bin/algo_app/_internal/lib`

## Resource policy
- `Nice=19` - intentionally deprioritized
- `CPUAffinity=3` - pinned to CPU core 3 only
- `MemoryHigh=200M`
- `MemoryMax=250M`
- `CPUQuota` is commented out, so no hard CPU cap is active

## What the logs show
- It keeps polling while not printing: "Printer has not started printing, waiting..."
- It self-reports around 40 MB RAM and 13-15% CPU even while idle.

## What is exposed
- LAN-accessible HTTP on port 9010
- OpenAPI schema is publicly readable
- There is an HTML interface if you browse to it, but it seems to not actually be enabled
- Exposed endpoints include:
  - POST `/login`
  - GET/POST `/config`
  - GET `/capture`
  - GET `/detection_res`
  - GET `/history_frames`
  - GET `/get-video-list`
  - GET `/download-video/{filename}`
  - DELETE `/delete-video/{filename}`
  - POST `/notify`
  - GET `/version`
  - POST `/set_homing_state`

## Observed config/state when not printing
- Version: 1.1.0
- Current config says detection features are off:
  - `is_detect_flag=False`
  - `is_pei_check=False`
  - `is_foreign_check=False`
  - `is_md_check=False`
- Actions are also off:
  - no alarm
  - no pause
  - no cancel
- `/detection_res` confirms idle/non-printing state with zero counters.
- `/get-video-list` is empty.
- Raw video saving is configured on, but no saved videos currently show up from that endpoint.

## Security/exposure notes
- The API is exposed on your LAN
- The config includes plaintext management credentials:
  - user `qidi`
  - password `qiditech`
