# Running Audio Telemetry Scripts

This guide assumes you have already cloned the repository to your Linux device and completed the basic system setup.

---

## Prerequisites

Ensure the following packages are installed:

```bash
sudo apt update
sudo apt install -y ffmpeg pulseaudio-utils
```

---

## 1. Identify Your Microphone Device

Before recording, you need to find the correct microphone input source.

### List Available Audio Sources

```bash
pactl list short sources
```

Example output:
```
76	alsa_output.pci-0000_00_1f.3.analog-stereo.monitor	PipeWire	s32le 2ch 48000Hz	SUSPENDED
77	alsa_input.pci-0000_00_1f.3.analog-stereo.3	PipeWire	s32le 2ch 48000Hz	SUSPENDED
```

### Choose the Correct Source

- **Use:** `alsa_input.*` entries (microphone inputs)
- **Avoid:** `.monitor` entries (speaker outputs)

In the example above, use: `alsa_input.pci-0000_00_1f.3.analog-stereo.3`

### Test Your Microphone

Verify the microphone works by recording a 3-second test:

```bash
arecord -D alsa_input.pci-0000_00_1f.3.analog-stereo.3 -d 3 test.wav
aplay test.wav
```

You should hear your recorded audio played back.

---

## 2. Navigate to the Project Directory

```bash
cd /path/to/audio-telemetry
```

Make sure the script is executable:

```bash
chmod +x scripts/record.sh
```

---

## 3. Run the Recording Script

### Basic Usage (Default Settings)

Records 3-minute segments using the default microphone:

```bash
./scripts/record.sh
```

### Specify Your Microphone

Use your identified microphone source:

```bash
MIC_SRC="alsa_input.pci-0000_00_1f.3.analog-stereo.3" ./scripts/record.sh
```

### Common Configurations

**Test recording (30-second segments):**
```bash
SEGMENT_TIME=30 MIC_SRC="your_microphone_name" ./scripts/record.sh
```

**Production recording (10-minute segments):**
```bash
SEGMENT_TIME=600 MIC_SRC="your_microphone_name" ./scripts/record.sh
```

**High-quality stereo recording:**
```bash
MIC_SRC="your_microphone_name" RATE=48000 CHANNELS=2 ./scripts/record.sh
```

---

## 4. Configuration Variables

Set any of these environment variables before running:

- **`MIC_SRC`** - Audio input source name (required if default doesn't work)
- **`SEGMENT_TIME`** - Seconds per file (default: 180)
- **`OUTDIR`** - Output directory (default: `audio/recordings/`)
- **`RATE`** - Sample rate in Hz (default: 16000)
- **`CHANNELS`** - Number of channels: 1=mono, 2=stereo (default: 1)

---

## 5. Monitor Recording

The script will show output like this:

```
== audio-telemetry ==
Source:        alsa_input.pci-0000_00_1f.3.analog-stereo.3
Segment time:  180s
Out dir:       ./audio/recordings
Rate/Channels: 16000 Hz / 1 ch

Input #0, pulse, from 'alsa_input.pci-0000_00_1f.3.analog-stereo.3':
[segment @ 0x...] Opening './audio/recordings/20251018_143025.flac' for writing
```

Files are created with timestamps: `20251018_143025.flac`, `20251018_143325.flac`, etc.

---

## 6. Stop Recording

Press `Ctrl+C` to stop recording cleanly:

```
^C[out#0/segment @ 0x...] Exiting normally, received signal 2.
```

---

## 7. Background Recording

For long-term recording, run in the background:

```bash
nohup MIC_SRC="your_microphone_name" ./scripts/record.sh > recording.log 2>&1 &
```

Check if it's still running:
```bash
ps aux | grep ffmpeg
```

Stop background recording:
```bash
pkill -f "ffmpeg.*audio/recordings"
```

---

## 8. Verify Recorded Files

Check that files were created:

```bash
ls -la audio/recordings/
```

Verify file metadata:

```bash
ffprobe -v quiet -show_format audio/recordings/20251018_143025.flac
```

Play a file to test:

```bash
aplay audio/recordings/20251018_143025.flac
```

---

## Common Issues

### "No such device" Error
- Run `pactl list short sources` again
- Verify the exact microphone name (case-sensitive)
- Check if PulseAudio/PipeWire is running: `systemctl --user status pulseaudio`

### "Permission denied" on Audio Device
- Add user to audio group: `sudo usermod -aG audio $USER`
- Log out and back in, or reboot

### Files Not Created
- Check disk space: `df -h`
- Verify output directory exists and is writable
- Look for error messages in the ffmpeg output

### No Audio in Files
- Test microphone with `arecord` as shown above
- Check if microphone is muted in system settings
- Verify you're not using a `.monitor` device (speaker output)
