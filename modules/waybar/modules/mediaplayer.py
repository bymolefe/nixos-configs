#!/usr/bin/env python3
import json
import subprocess
import sys

def get_player_status():
    try:
        # Get current player status
        status = subprocess.check_output(
            ["playerctl", "status"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()

        if status not in ["Playing", "Paused"]:
            return None

        # Get metadata
        artist = subprocess.check_output(
            ["playerctl", "metadata", "artist"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()

        title = subprocess.check_output(
            ["playerctl", "metadata", "title"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()

        player = subprocess.check_output(
            ["playerctl", "metadata", "playerName"],
            stderr=subprocess.DEVNULL
        ).decode("utf-8").strip()

        # Format output
        if artist and title:
            text = f"{title} - {artist}"
        elif title:
            text = title
        else:
            text = "No media playing"

        output = {
            "text": text,
            "tooltip": f"{player}: {text}",
            "class": player.lower(),
            "alt": player
        }

        return output

    except (subprocess.CalledProcessError, FileNotFoundError):
        return None

if __name__ == "__main__":
    result = get_player_status()
    if result:
        print(json.dumps(result))
    else:
        print(json.dumps({"text": ""}))
