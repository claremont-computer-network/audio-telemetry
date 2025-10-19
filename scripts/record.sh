#!/usr/bin/env bash
# audio-telemetry: continuous audio capture → timestamped FLAC files every N seconds.

set -euo pipefail

MIC_SRC=${MIC_SRC:-alsa_input.pci-0000_00_1f.3.analog-stereo.3}
# e.g. "default" or from `pactl list short sources`
SEGMENT_TIME=${SEGMENT_TIME:-180}     # seconds per file
OUTDIR=${OUTDIR:-"$(dirname "$0")/../audio/recordings"}
RATE=${RATE:-16000}                   # sample rate (Hz)
CHANNELS=${CHANNELS:-1}               # 1 = mono

mkdir -p "$OUTDIR"

echo "== audio-telemetry =="
echo "Source:        $MIC_SRC"
echo "Segment time:  ${SEGMENT_TIME}s"
echo "Out dir:       $OUTDIR"
echo "Rate/Channels: ${RATE} Hz / ${CHANNELS} ch"
echo

# Helpful: ensure you're not pointing at a speaker monitor
if [[ "$MIC_SRC" == *".monitor"* ]]; then
  echo "WARNING: '$MIC_SRC' looks like a speaker monitor (records output, not mic)." >&2
fi

# Run FFmpeg; be explicit about the audio codec and keep logs visible  
# Add comprehensive metadata for precise telemetry reconstruction
START_TIME_UTC=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
START_TIME_UNIX=$(date +%s.%3N)

exec ffmpeg -v info -hide_banner -nostdin \
  -f pulse -i "$MIC_SRC" \
  -ac "$CHANNELS" -ar "$RATE" -c:a flac \
  -f segment -segment_time "$SEGMENT_TIME" -reset_timestamps 1 -strftime 1 \
  -metadata creation_time="$START_TIME_UTC" \
  -metadata recording_start_utc="$START_TIME_UTC" \
  -metadata recording_start_unix="$START_TIME_UNIX" \
  -metadata segment_duration="$SEGMENT_TIME" \
  -metadata source_device="$MIC_SRC" \
  -metadata sample_rate="$RATE" \
  -metadata channels="$CHANNELS" \
  -metadata telemetry_version="1.0" \
  -metadata comment="Audio telemetry segment - use metadata for reconstruction" \
  "$OUTDIR/%Y%m%d_%H%M%S.flac"
