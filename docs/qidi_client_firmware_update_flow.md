# QIDI Client Firmware Update Flow

This note records how the Max 4 checks for online firmware updates.

It is written so future reverse-engineering work can start from facts instead of redoing the same static analysis and replay tests.

## Summary

- Opening the firmware page triggers the online version check immediately.
- The client binary is `QIDI_Client/bin/qidiclient`.
- The firmware check endpoint is `GET /backend/v1/fireware/upgrade-info`.
- The path uses QIDI's misspelling `fireware`, not `firmware`.
- `currentVersion` comes from the local SOC firmware version.
- `deviceId` is the uppercase CPU serial from `/proc/cpuinfo`.
- The same value is sent in both the query string `deviceId` and the `X-DeviceId` header.
- The request includes QIDI-specific headers: `X-DeviceType`, `X-Nonce`, `X-Platform`, `X-Region`, `X-Signature`, `X-Timestamp`, `X-Timezone`, and `X-Version`.
- `X-Signature` is generated locally by the client with `HMAC-SHA256`, hex-encoded.
- The key string embedded in the client is `qid3d-from-2025-CAFE-BABE`.
- The replayable signing payload that worked in testing is `qidi3d null`.
- For this endpoint, the backend currently appears to only require `X-Signature` to be present and non-empty. It did not reject a dummy signature in live tests.
- A clearly fake `currentVersion` such as `00.00.00.00` does not reliably return the latest firmware.
- A plausible older firmware version such as `01.01.05.01` does return the current version `01.01.06.01`.
- The returned package URL points at `https://public-cdn.qidimaker.com`.
- The returned `description` URL is not necessarily the release notes for the returned firmware package.
- The downloaded package is written to `/home/qidi/download/online_update.zip` before the client starts the online update flow.

## Confirmed Working Result

Using:

- `hardware=QD_MAX4`
- `currentVersion=01.01.05.01`
- `deviceId=<UPPERCASE_CPU_SERIAL>`
- `X-DeviceType: X-MAX4`
- `X-Platform: 3DPrinter`
- `X-Region: NA`
- `X-Timezone: +00:00`
- `X-Version: 01.01`
- `User-Agent: xindi/4.4.23`
- `X-Signature: 6cdc129f40dc668a61f190fe19f71d2fcaef2554f72855f604559f3f1135ae01`

the endpoint returned:

```json
{
  "code": 200,
  "message": "返回成功",
  "data": {
    "version": "01.01.06.01",
    "url": "https://public-cdn.qidimaker.com/upgrade/3DPrinter/QD_MAX4/01.01.06.01/ezhm9tcgyk/QD_MAX4_01.01.06.01_20260312_Release.zip",
    "description": "https://wiki.qidi3d.com/en/software/qidi-studio/release-notes/release-note-02-04-01-11",
    "needUpdate": true,
    "title": "update",
    "isForce": false,
    "apkSize": "243.88 MB"
  }
}
```

Using the same request shape with `currentVersion=01.01.06.01` returned `needUpdate: false`.

## High-Level Flow

1. Opening the firmware page triggers the check immediately.
2. `qidiclient` reads `/home/qidi/update/firmware_manifest.json`.
3. The client takes the local SOC firmware version and uses it as `currentVersion`.
4. The client reads the CPU serial from `/proc/cpuinfo`, uppercases it, and uses it as `deviceId`.
5. The client builds a GET request to `/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=<...>&deviceId=<...>`.
6. The client attaches the QIDI headers listed below.
7. The API returns update metadata including `version`, `url`, `description`, `needUpdate`, `isForce`, and `apkSize`.
8. If an update is needed, the client downloads the ZIP to `/home/qidi/download/online_update.zip`.
9. The client starts the online update from the downloaded ZIP.

## Evidence Sources

These findings come from:

- string inspection of `QIDI_Client/bin/qidiclient`
- targeted static disassembly of the request path
- targeted pseudocode recovery with `radare2`
- live replay tests against QIDI's API
- live client logs
- packet captures

## Function Map

These addresses are the useful entry points inside `QIDI_Client/bin/qidiclient`.

| Address | Role | Notes |
| --- | --- | --- |
| `0x00621f44` | firmware request builder | Builds `/backend/v1/fireware/upgrade-info?...` |
| `0x0061d0c0` | common header builder | Appends the QIDI request headers |
| `0x006991c0` | device ID retrieval path | Called by the firmware request builder before appending `deviceId` |
| `0x006b9790` | CPU serial reader | Shells out to read `/proc/cpuinfo` |
| `0x006b9124` | uppercase helper | Uppercases the serial with `toupper` |
| `0x0065ab00` | signature wrapper | High-level `X-Signature` helper |
| `0x0065a8a0` | HMAC helper | Calls `EVP_sha256` and `HMAC(...)` |
| `0x0065a4f0` | digest formatter | Hex-encodes the digest via `std::stringstream` |
| `0x0061b280` | signature input canonicalizer | Normalizes whitespace and prefixes `qidi3d ` |

## Firmware Page Trigger

The live client log showed:

```text
page to -> Page_Firmware
[HTTP] Func: [版本请求]
[HTTP] Func: [版本请求成功]
```

So the online firmware check happens when the firmware page is opened.

## Endpoint Path

The request builder at `0x00621f44` contains these literal fragments:

```text
/backend/v1/fireware/upgrade-info?hardware=
QD_MAX4
&currentVersion=
&deviceId=
```

So the request path is:

```text
<api-base>/backend/v1/fireware/upgrade-info?hardware=QD_MAX4&currentVersion=<...>&deviceId=<...>
```

The path name is spelled `fireware` in both the client and the server API.

## API Hosts

The binary contains both of these base hosts:

```text
https://api.qidimaker.com
https://api-cn.qidi3dprinter.com
```

The live replay work in this repo used `https://api.qidimaker.com`.

## Where `currentVersion` Comes From

The client references:

```text
/home/qidi/update/
/home/qidi/update/firmware_manifest.json
firmware_manifest.json
```

The manifest contained values like:

```text
SOC.version = 01.01.06.01
SOC.region = NA
MCU.version = 02.01.01.09
THR.version = 02.02.01.08
BOX.version = 02.03.01.21
CLOSED_LOOP_MOTOR.version = 03.01.10.13
```

`currentVersion` is the SOC package version

## Where `deviceId` Comes From

The helper at `0x006b9790` shells out with this exact command string:

```text
cat /proc/cpuinfo | grep Serial| awk '{printf "%s", substr($0, index($0, ":") + 2)}'
```

The next helper at `0x006b9124` uppercases the result with `toupper`.

So the firmware request `deviceId` is the uppercase CPU serial.

You can read the raw serial on the printer with:

```bash
grep -m1 '^Serial' /proc/cpuinfo
```

The firmware request uses the uppercase form of that value.

On the observed machine, the same uppercase CPU serial appeared in both:

- query string `deviceId`
- header `X-DeviceId`


## Observed Request Shape

The request shape, with machine-unique values redacted, is:

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

## Header Semantics

What is now confirmed:

- `X-DeviceId` is the uppercase CPU serial.
- `X-DeviceType` is `X-MAX4`.
- `X-Platform` is `3DPrinter`.
- `X-Region` was `NA` in the observed device profile.
- `X-Timezone` was `+00:00` in the observed request.
- `X-Version` is `01.01` in the observed request.
- `User-Agent` is `xindi/4.4.23` in the observed request.
- `Accept-Language` is `zh_CN` in the observed request.

What `X-Version` is not:

- It is not the current SOC firmware version.
- It remained `01.01` while `currentVersion` was `01.01.06.01`.

Treat `X-Version` as a client or API profile version.

## Signature Generation

### Crypto Primitive

The signature helper chain is:

- `0x0065ab00` high-level wrapper
- `0x0065a8a0` HMAC helper
- `0x0065a4f0` digest formatter

`0x0065a8a0` calls `EVP_sha256` and then `HMAC(...)`.

So `X-Signature` is an `HMAC-SHA256` digest.

`0x0065a4f0` formats the digest as lowercase hex text.

### Embedded Key Material

The firmware request path at `0x00621f44` loads this hardcoded string before calling the common header builder:

```text
qid3d-from-2025-CAFE-BABE
```

### Canonicalized Input

The helper at `0x0061b280` canonicalizes the signing input by trimming and compacting whitespace and then prefixing:

```text
qidi3d 
```

The replayable input that matched the client path and worked against the live endpoint is:

```text
qidi3d null
```

From that, the reproducible signature is:

```text
6cdc129f40dc668a61f190fe19f71d2fcaef2554f72855f604559f3f1135ae01
```

Equivalent shell command:

```bash
printf '%s' 'qidi3d null' | \
  openssl dgst -sha256 -hmac 'qid3d-from-2025-CAFE-BABE' -binary | \
  od -An -tx1 | tr -d ' \n'
```

### Important Server-Side Behavior

The client clearly implements HMAC generation, but the `upgrade-info` endpoint currently does not appear to verify it strictly.

The backend doesn't appear to validate this signature value in any way, other than that it exists.

- no `X-Signature` header: rejected
- non-empty dummy `X-Signature`: accepted
- reproduced HMAC `X-Signature`: also accepted

## Replay Matrix

### Signature Presence

Without `X-Signature`, the API returned `401` with:

```json
{"code":2009,"message":"X-Signature missing in request header"}
```

With a dummy non-empty signature, the request was accepted.

With the reproduced HMAC signature, the request was also accepted.

### Version Plausibility

Using a fake version such as:

```text
00.00.00.00
```

returned:

```json
{"needUpdate":false,"version":null,"url":null}
```

Using real older version such as:

```text
01.01.05.01
```

returned the current package:

```text
01.01.06.01
```

### Region Handling

These region results were observed against the live endpoint:

- `NA`: accepted
- `APAC`: accepted
- `EEA`: accepted
- `CN`: rejected with `code: 2018`
- `OTHERS`: rejected with `code: 2018`

The binary still contains the separate China API base host, so host selection and header region selection are likely related but not identical concerns.

## Exact curl Reproduction

```bash
DEVICE_ID="<UPPERCASE_CPU_SERIAL>"
TS=$(($(date +%s%N)/1000000))
NONCE=$(openssl rand -hex 16)
SIG=$(printf '%s' 'qidi3d null' | \
  openssl dgst -sha256 -hmac 'qid3d-from-2025-CAFE-BABE' -binary | \
  od -An -tx1 | tr -d ' \n')

curl -sS --get "https://api.qidimaker.com/backend/v1/fireware/upgrade-info" \
  --data-urlencode "hardware=QD_MAX4" \
  --data-urlencode "currentVersion=01.01.05.01" \
  --data-urlencode "deviceId=${DEVICE_ID}" \
  -H "User-Agent: xindi/4.4.23" \
  -H "Accept: */*" \
  -H "Accept-Language: zh_CN" \
  -H "Content-Type: application/json" \
  -H "X-DeviceId: ${DEVICE_ID}" \
  -H "X-DeviceType: X-MAX4" \
  -H "X-Nonce: ${NONCE}" \
  -H "X-Platform: 3DPrinter" \
  -H "X-Region: NA" \
  -H "X-Signature: ${SIG}" \
  -H "X-Timestamp: ${TS}" \
  -H "X-Timezone: +00:00" \
  -H "X-Version: 01.01"
```

## Response Shape

The metadata response includes:

- `version`
- `url`
- `description`
- `needUpdate`
- `title`
- `isForce`
- `apkSize`

Example:

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

The package host and the metadata host are different.

- metadata host: `api.qidimaker.com`
- package host: `public-cdn.qidimaker.com`

## Release Notes URL Mismatch

The `description` field is not a trustworthy firmware-release-notes pointer.

In the successful replay above, the API returned:

```text
https://wiki.qidi3d.com/en/software/qidi-studio/release-notes/release-note-02-04-01-11
```

That is a QIDI Studio page, not a printer firmware release notes page for `01.01.06.01`.

## Download And Apply Behavior

The binary logs contain these update-flow strings:

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

That supports this sequence:

1. call `upgrade-info`
2. parse update metadata
3. download the returned ZIP
4. save it as `/home/qidi/download/online_update.zip`
5. start the online update flow from that ZIP
