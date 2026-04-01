# QIDI Client Firmware Update Flow

This note summarizes what can be confirmed about how the Max 4 checks for and applies online firmware updates.

The version string `01.01.06.01` is used below as a concrete example because it appears directly in observed client data.

## Summary

- opening the firmware page triggers the update check immediately
- `qidiclient` reads `/home/qidi/update/firmware_manifest.json` on firmware-page entry
- `currentVersion` is most likely the local `SOC.version` from that manifest
- `deviceId` is most likely derived locally from machine hardware identity and matched the uppercase CPU serial on the observed printer
- the request goes to `/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=<...>&deviceId=<...>`
- in the observed session, the request went to `https://api.qidimaker.com`
- the request uses signed QIDI headers and is not just a bare public GET
- `X-Version` appears to be a client or API version, not the printer firmware version
- `X-Signature` is required, but does not appear to be directly bound to `X-Timestamp`, `X-Nonce`, or `currentVersion`
- the response includes update metadata plus separate URLs for release notes and the actual firmware ZIP
- the returned `description` URL was not actually the release notes for the returned printer firmware version
- the observed package URL used `https://public-cdn.qidimaker.com`
- the ZIP is then downloaded to `/home/qidi/download/online_update.zip` and applied from there

## High-Level Flow

1. Opening the firmware page triggers a version check immediately.
2. `qidiclient` reads `/home/qidi/update/firmware_manifest.json`.
3. It uses the local `SOC.version` from that manifest as `currentVersion`.
4. It builds a signed request to `/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=<...>&deviceId=<...>`.
5. In the observed session, that request went to `https://api.qidimaker.com` over HTTPS.
6. The API returned update metadata including firmware version, package URL, release-notes URL, `needUpdate`, `isForce`, and package size.
7. If an update is needed, the client downloads the package to `/home/qidi/download/online_update.zip`.
8. The client then starts the online update from that ZIP.

## What Is Still Unconfirmed

- the exact signature algorithm
- the exact canonicalized input used for `X-Signature`
- whether any canonicalized signing input includes fields beyond the ones already ruled out by live replay tests
- whether all firmware revisions derive `deviceId` the same way

## Technical Details

### Evidence Source

These findings come from:

- string inspection of `qidi_client/bin/qidiclient`
- live `qidiclient` logs while opening the firmware page
- a live packet capture while opening the firmware page
- a live `openat` trace of `qidiclient`
- targeted static disassembly of the request-construction path
- readable request and state strings recovered from live process memory

### Firmware Page Trigger

The live client log shows that entering the firmware page triggers the request:

```text
page to -> Page_Firmware
[HTTP] Func: [版本请求]
[HTTP] Func: [版本请求成功]
```

So the version request happens when the firmware page is opened, not only after pressing a separate update button.

### Update Check Path

The binary contains this exact path string:

```text
/backend/v1/fireware/upgrade-info?hardware=
```

The same string cluster also contains:

```text
QD_MAX4
&currentVersion=
&deviceId=
```

So the request shape is:

```text
<api-base>/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=<...>&deviceId=<...>
```

The endpoint uses QIDI's `fireware` spelling rather than `firmware`.

### API Hosts

The binary contains these API base hosts:

```text
https://api.qidimaker.com
https://api-cn.qidi3dprinter.com
```

The observed live session used `https://api.qidimaker.com`.

### Where `currentVersion` Comes From

The client binary directly references:

```text
/home/qidi/update/
/home/qidi/update/firmware_manifest.json
firmware_manifest.json
```

An `openat` trace shows `qidiclient` reading that file when the firmware page is opened.

On the observed printer, the manifest contained:

```text
SOC.version = 01.01.06.01
SOC.region = NA
MCU.version = 02.01.01.09
THR.version = 02.02.01.08
BOX.version = 02.03.01.21
CLOSED_LOOP_MOTOR.version = 03.01.10.13
```

That is the strongest current evidence that `currentVersion` comes from the local SOC package version in `firmware_manifest.json`, not from one of the individual component versions.

### Where `deviceId` Comes From

The observed live request used the same value in both places:

- the query-string `deviceId`
- the `X-DeviceId` request header

On the observed machine, that value matched the uppercase CPU serial recovered from live process memory.

So the best current read is:

- the printer derives `deviceId` locally from machine hardware identity
- on the observed Max 4, that identity matched the uppercase CPU serial

The actual device ID is intentionally omitted here.

This is stronger evidence than earlier guesses involving Moonraker's `instance_id` or a purely cloud-assigned identifier.

### Observed Request Shape

Readable strings recovered from live process memory exposed this request form, with machine-unique identifiers redacted:

```text
GET https://api.qidimaker.com/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=01.01.06.01&deviceId=DEVICE_ID_REDACTED
Host: api.qidimaker.com
User-Agent: xindi/4.4.23
Accept: */*
Accept-Language: zh_CN
Content-Type: application/json
X-DeviceId: DEVICE_ID_REDACTED
X-DeviceType: X-MAX4
X-Nonce: NONCE_REDACTED
X-Platform: 3DPrinter
X-Region: NA
X-Signature: SIGNATURE_REDACTED
X-Timestamp: TIMESTAMP_REDACTED
X-Timezone: +00:00
X-Version: 01.01
```

The same recovered request fragments also showed HTTP/2.

### Request Validation And Auth

The endpoint is not a bare public URL. Direct probes without the expected headers returned HTTP `401` errors and complained about missing headers in this order:

```text
X-Timestamp
X-DeviceType
X-Signature
X-Platform
Accept-Language
X-Timezone
```

That shows the firmware check uses a signed request profile.

The binary supports `Authorization: Bearer <accessToken>`, but the observed printer was unbound and the captured firmware-check request did not include an `Authorization` header. In that observed case, the request relied on the signed QIDI headers instead.

### What The Live Replay Tests Clarify

Two points are now much clearer from live testing:

- `X-Version` is not the printer firmware version
- `X-Signature` is not tied to `X-Timestamp`, `X-Nonce`, or `currentVersion` in the obvious way

#### `X-Signature`

The exact signature algorithm is still unknown.

But live testing showed that the same `X-Signature` still worked after changing all of the following:

- `X-Timestamp` to a fresh value
- `X-Nonce` to a fresh value
- `currentVersion` from `01.01.06.01` to `01.01.05.04`

That means `X-Signature` is very likely not a simple hash or HMAC over:

- `X-Timestamp`
- `X-Nonce`
- `currentVersion`

The best current possibilities are:

- a static app-secret-derived token
- a signature over a smaller fixed set of fields
- a value derived from some device-level state that does not change per request

#### `X-Version`

`X-Version` appears to be a client or API version, not the firmware package version.

Evidence:

- live request fragments consistently showed `X-Version: 01.01`
- `currentVersion` came from the local firmware manifest and was `01.01.06.01`
- the API still returned a valid response when `currentVersion` was changed to `01.01.05.04` while `X-Version` remained `01.01`

So `X-Version` should be treated as independent of the printer firmware version.

### Observed Response Shape

Using the recovered request shape and headers, the endpoint returned update metadata like this:

```json
{
  "code": 200,
  "message": "返回成功",
  "data": {
    "version": "01.01.06.01",
    "url": "https://public-cdn.qidimaker.com/upgrade/3DPrinter/QD_MAX4/01.01.06.01/.../QD_MAX4_01.01.06.01_20260312_Release.zip",
    "description": "https://wiki.qidi3d.com/en/software/qidi-studio/release-notes/release-note-02-04-01-11",
    "needUpdate": true,
    "title": "update",
    "isForce": false,
    "apkSize": "243.88 MB"
  }
}
```

In the observed response, the `description` field pointed to:

```text
https://wiki.qidi3d.com/en/software/qidi-studio/release-notes/release-note-02-04-01-11
```

That is not actually the release notes page for the returned printer firmware version. The best current read is that QIDI populated `description` with an unrelated or generic QIDI Studio release-notes page.

That confirms the split between:

- the update metadata endpoint
- the release-notes URL
- the actual firmware ZIP download URL

That separation is normal for this kind of update flow.

### Download Host

In the observed live response, the actual package URL used:

```text
https://public-cdn.qidimaker.com
```

So the update metadata host and the package download host are separate, which is normal.

### Download And Apply Behavior

The binary logs contain:

```text
Starting incremental online update from url: {}
Starting downloading update package
Download completed
/home/qidi/download/
online_update.zip
Starting online update
Online update completed
Online update failed
```

That supports this behavior:

1. call the `upgrade-info` endpoint
2. parse the metadata response
3. take the package URL from that response
4. download the ZIP to `/home/qidi/download/online_update.zip`
5. start the online update from the downloaded ZIP
