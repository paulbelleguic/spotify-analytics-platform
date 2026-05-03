import json

from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine
from src.spotify_analytics.spotify.client import SpotifyClient


INSERT_SQL = text(
    """
    INSERT INTO raw.spotify_recently_played (
        played_at,
        track_id,
        track_name,
        artist_id,
        artist_name,
        album_id,
        album_name,
        duration_ms,
        popularity,
        explicit,
        payload
    )
    VALUES (
        :played_at,
        :track_id,
        :track_name,
        :artist_id,
        :artist_name,
        :album_id,
        :album_name,
        :duration_ms,
        :popularity,
        :explicit,
        CAST(:payload AS jsonb)
    )
    ON CONFLICT (played_at, track_id) DO NOTHING
    """
)


def build_row(item: dict) -> dict:
    track = item["track"]
    album = track.get("album") or {}
    artists = track.get("artists") or [{}]
    main_artist = artists[0] if artists else {}

    return {
        "played_at": item["played_at"],
        "track_id": track["id"],
        "track_name": track.get("name"),
        "artist_id": main_artist.get("id"),
        "artist_name": main_artist.get("name"),
        "album_id": album.get("id"),
        "album_name": album.get("name"),
        "duration_ms": track.get("duration_ms"),
        "popularity": track.get("popularity"),
        "explicit": track.get("explicit"),
        "payload": json.dumps(item),
    }


def main() -> None:
    spotify = SpotifyClient()
    engine = get_engine()

    items = spotify.get_recently_played(limit=50)
    rows = [build_row(item) for item in items if item.get("track", {}).get("id")]

    with engine.begin() as connection:
        for row in rows:
            connection.execute(INSERT_SQL, row)

    print(f"Loaded {len(rows)} rows into raw.spotify_recently_played.")


if __name__ == "__main__":
    main()
