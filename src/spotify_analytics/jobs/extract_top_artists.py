import json

from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine
from src.spotify_analytics.spotify.client import SpotifyClient


INSERT_SQL = text(
    """
    INSERT INTO raw.spotify_top_artists (
        time_range,
        rank,
        artist_id,
        artist_name,
        genres,
        popularity,
        followers,
        payload
    )
    VALUES (
        :time_range,
        :rank,
        :artist_id,
        :artist_name,
        :genres,
        :popularity,
        :followers,
        CAST(:payload AS jsonb)
    )
    """
)


def build_row(artist: dict, rank: int, time_range: str) -> dict:
    return {
        "time_range": time_range,
        "rank": rank,
        "artist_id": artist["id"],
        "artist_name": artist.get("name"),
        "genres": artist.get("genres", []),
        "popularity": artist.get("popularity"),
        "followers": (artist.get("followers") or {}).get("total"),
        "payload": json.dumps(artist),
    }


def main() -> None:
    spotify = SpotifyClient()
    engine = get_engine()

    time_ranges = ["short_term", "medium_term", "long_term"]

    with engine.begin() as connection:
        total_rows = 0

        for time_range in time_ranges:
            artists = spotify.get_top_items("artists", time_range=time_range, limit=50)
            rows = [
                build_row(artist, rank=index + 1, time_range=time_range)
                for index, artist in enumerate(artists)
            ]

            for row in rows:
                connection.execute(INSERT_SQL, row)

            total_rows += len(rows)

    print(f"Loaded {total_rows} rows into raw.spotify_top_artists.")


if __name__ == "__main__":
    main()
