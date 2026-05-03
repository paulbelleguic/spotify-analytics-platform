import json
from pathlib import Path

from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine


PROJECT_ROOT = Path(__file__).resolve().parents[3]
DEFAULT_EXPORT_DIR = PROJECT_ROOT / "data" / "spotify_export"

INSERT_SQL = text(
    """
    INSERT INTO raw.spotify_streaming_history_export (
        played_at,
        ms_played,
        track_name,
        artist_name,
        album_name,
        spotify_track_uri,
        track_id,
        platform,
        country,
        reason_start,
        reason_end,
        shuffle,
        skipped,
        offline,
        incognito_mode,
        source_file,
        payload
    )
    VALUES (
        :played_at,
        :ms_played,
        :track_name,
        :artist_name,
        :album_name,
        :spotify_track_uri,
        :track_id,
        :platform,
        :country,
        :reason_start,
        :reason_end,
        :shuffle,
        :skipped,
        :offline,
        :incognito_mode,
        :source_file,
        CAST(:payload AS jsonb)
    )
    ON CONFLICT (played_at, spotify_track_uri, ms_played) DO NOTHING
    """
)


def extract_track_id(uri: str | None) -> str | None:
    if not uri or not uri.startswith("spotify:track:"):
        return None
    return uri.split(":")[-1]


def build_row(item: dict, source_file: str) -> dict:
    track_uri = item.get("spotify_track_uri")

    return {
        "played_at": item.get("ts"),
        "ms_played": item.get("ms_played"),
        "track_name": item.get("master_metadata_track_name"),
        "artist_name": item.get("master_metadata_album_artist_name"),
        "album_name": item.get("master_metadata_album_album_name"),
        "spotify_track_uri": track_uri,
        "track_id": extract_track_id(track_uri),
        "platform": item.get("platform"),
        "country": item.get("conn_country"),
        "reason_start": item.get("reason_start"),
        "reason_end": item.get("reason_end"),
        "shuffle": item.get("shuffle"),
        "skipped": item.get("skipped"),
        "offline": item.get("offline"),
        "incognito_mode": item.get("incognito_mode"),
        "source_file": source_file,
        "payload": json.dumps(item),
    }


def import_file(path: Path) -> int:
    items = json.loads(path.read_text(encoding="utf-8"))
    rows = [
        build_row(item, path.name)
        for item in items
        if item.get("ts") and item.get("master_metadata_track_name")
    ]

    engine = get_engine()
    with engine.begin() as connection:
        for row in rows:
            connection.execute(INSERT_SQL, row)

    return len(rows)


def main() -> None:
    files = sorted(DEFAULT_EXPORT_DIR.glob("Streaming_History_Audio_*.json"))

    if not files:
        print(f"No Spotify export files found in {DEFAULT_EXPORT_DIR}")
        return

    total_rows = 0
    for file in files:
        loaded_rows = import_file(file)
        total_rows += loaded_rows
        print(f"Loaded {loaded_rows} rows from {file.name}")

    print(f"Imported {total_rows} Spotify streaming history rows.")


if __name__ == "__main__":
    main()
