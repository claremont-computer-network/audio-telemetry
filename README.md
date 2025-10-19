# audio-telemetry

A resourceful system of tools and documentation for turning readily available Linux-capable devices into always-on audio-telemetry nodes for capture and storage, to be processed later on more powerful machines.

---

## What it does

- Records audio continuously from a connected microphone.  
- Saves the audio in timestamped files at fixed intervals (default: every 3 minutes).  
- Runs locally using `ffmpeg`, without external dependencies.  
- Can be paused or stopped manually at any time.  

This project only handles **audio capture and storage**. Processing or transcription happens elsewhere.

---

## Requirements

### Hardware
- A computer capable of running a modern Linux distribution (e.g., Ubuntu 20.04 or newer).  
- Sufficient storage to hold recorded audio files.  
- A microphone supported by the Linux audio stack (USB, 3.5 mm analog, or built-in).  
- A stable power supply for continuous recording.  

These machines can be low-cost or repurposed systems, but they must support the Linux kernel, PulseAudio or PipeWire, and FFmpeg.

### Software
- A Linux operating system with access to a terminal.  
- `ffmpeg` for recording and segmentation.  
- Optional: `pulseaudio-utils` or PipeWire utilities to list and select microphones.  

### Permissions
- A standard user account with terminal access.  
- `sudo` privileges for the initial installation of required packages.

---

## Design rationale

- **FFmpeg** was chosen because it’s stable, efficient, and packaged for nearly all Linux systems.  
- **Segmented recording** prevents data loss and simplifies later processing.  
- **Local capture** keeps the setup private and independent of network connectivity.  
- **Accessible hardware** ensures the system can run on reused or inexpensive machines, as long as they meet the basic Linux and FFmpeg requirements.  
- **Explicit simplicity** keeps the system transparent—every operation is visible and reproducible from the command line.

---

## Usage

### Find your microphone
```bash
pactl list short sources
```
Look for `alsa_input.*` (not `.monitor` which is speaker output).

### Run the script
```bash
./scripts/record.sh
```

### Configuration (optional)
Set environment variables before running:

```bash
MIC_SRC="your_microphone_name" SEGMENT_TIME=30 ./scripts/record.sh
```

**Available variables:**
- `MIC_SRC` - Microphone source name (default: `alsa_input.pci-0000_00_1f.3.analog-stereo.3`)
- `SEGMENT_TIME` - Seconds per file (default: `180`)
- `OUTDIR` - Output directory (default: `audio/recordings/`)
- `RATE` - Sample rate in Hz (default: `16000`)
- `CHANNELS` - Channels, 1=mono 2=stereo (default: `1`)

Press `Ctrl+C` to stop recording.

---

## License

MIT License — simple, permissive, and suited for reuse.