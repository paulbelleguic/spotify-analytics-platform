import json

from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine
from src.spotify_analytics.spotify.client import SpotifyClient


INSERT_SQL = text(
    """
    INSERT INTO raw.spotify_top_tracks (
        time_range,
        rank,
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
        :time_range,
        :rank,
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
    """
)


def build_row(track: dict, rank: int, time_range: str) -> dict:
    album = track.get("album") or {}
    artists = track.get("artists") or [{}]
    main_artist = artists[0] if artists else {}

    return {
        "time_range": time_range,
        "rank": rank,
        "track_id": track["id"],
        "track_name": track.get("name"),
        "artist_id": main_artist.get("id"),
        "artist_name": main_artist.get("name"),
        "album_id": album.get("id"),
        "album_name": album.get("name"),
        "duration_ms": track.get("duration_ms"),
        "popularity": track.get("popularity"),
        "explicit": track.get("explicit"),
        "payload": json.dumps(track),
    }


def main() -> None:
    spotify = SpotifyClient()
    engine = get_engine()

    time_ranges = ["short_term", "medium_term", "long_term"]

    with engine.begin() as connection:
        total_rows = 0

        for time_range in time_ranges:
            tracks = spotify.get_top_items("tracks", time_range=time_range, limit=50)
            rows = [
                build_row(track, rank=index + 1, time_range=time_range)
                for index, track in enumerate(tracks)
            ]

            for row in rows:
                connection.execute(INSERT_SQL, row)

            total_rows += len(rows)

    print(f"Loaded {total_rows} rows into raw.spotify_top_tracks.")


if __name__ == "__main__":
    main()
