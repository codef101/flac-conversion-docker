#!/bin/sh

input_dir="/app/input"
output_dir="/app/output"
failed_dir="/app/failed"

convert_flac_to_alac() {
  local dir="$1"
  local top_dir="$2"

  for item in "$dir"/*; do

    if [ -f "$item" ]; then

      if [ "${item##*.}" = "flac" ]; then
        local filename=$(basename "$item" .flac)
        if ffmpeg -y -i "$item" -c:a alac "$output_dir/$filename.m4a"; then
          rm "$item"
          echo "Converted $item"
        else
          mv "$item" "$failed_dir"
          echo "Failed to convert $item. Moved to $failed_dir"
        fi
      else
        mv "$item" "$failed_dir"
        echo "File is not a .flac: $item. Moved to $failed_dir"
      fi

    elif [ -d "$item" ]; then

      convert_flac_to_alac "$item" "$top_dir"
      if [ -z "$(ls -A "$item")" ]; then
        directory="$(echo "$item" | sed 's|/\*$||')"
        rm -rf "$directory"
        echo "Deleted empty directory: $directory"

        if [ "$item" != "$top_dir" ]; then
          echo "Changing to parent dir"
          cd ..
        fi
      fi

    fi
  done
}

# Convert existing files at container start up
convert_flac_to_alac "$input_dir" "$input_dir"

while true; do
  convert_flac_to_alac "$input_dir" "$input_dir"
  sleep 1
done
