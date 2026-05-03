CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

CREATE TABLE IF NOT EXISTS raw.spotify_recently_played (
    id BIGSERIAL PRIMARY KEY,
    played_at TIMESTAMPTZ NOT NULL,
    track_id TEXT NOT NULL,
    track_name TEXT,
    artist_id TEXT,
    artist_name TEXT,
    album_id TEXT,
    album_name TEXT,
    duration_ms INTEGER,
    popularity INTEGER,
    explicit BOOLEAN,
    payload JSONB NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (played_at, track_id)
);

CREATE TABLE IF NOT EXISTS raw.spotify_top_tracks (
    id BIGSERIAL PRIMARY KEY,
    time_range TEXT NOT NULL,
    rank INTEGER NOT NULL,
    track_id TEXT NOT NULL,
    track_name TEXT,
    artist_id TEXT,
    artist_name TEXT,
    album_id TEXT,
    album_name TEXT,
    duration_ms INTEGER,
    popularity INTEGER,
    explicit BOOLEAN,
    payload JSONB NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS raw.spotify_top_artists (
    id BIGSERIAL PRIMARY KEY,
    time_range TEXT NOT NULL,
    rank INTEGER NOT NULL,
    artist_id TEXT NOT NULL,
    artist_name TEXT,
    genres TEXT[],
    popularity INTEGER,
    followers INTEGER,
    payload JSONB NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
