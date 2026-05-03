from pathlib import Path

from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine
from src.spotify_analytics.jobs.extract_recently_played import main as extract_recently_played
from src.spotify_analytics.jobs.extract_top_artists import main as extract_top_artists
from src.spotify_analytics.jobs.extract_top_tracks import main as extract_top_tracks


PROJECT_ROOT = Path(__file__).resolve().parents[3]

SQL_STEPS = [
    PROJECT_ROOT / "sql" / "004_create_staging_schema.sql",
    PROJECT_ROOT / "sql" / "005_rebuild_analytics_star_schema.sql",
    PROJECT_ROOT / "sql" / "006_create_analytics_kpi_views.sql",
]


def run_sql_file(path: Path) -> None:
    print(f"Running SQL file: {path.name}")
    sql = path.read_text(encoding="utf-8")
    engine = get_engine()

    with engine.begin() as connection:
        connection.execute(text(sql))


def main() -> None:
    print("Starting Spotify analytics pipeline...")

    print("Step 1/6 - Extract recently played")
    extract_recently_played()

    print("Step 2/6 - Extract top tracks")
    extract_top_tracks()

    print("Step 3/6 - Extract top artists")
    extract_top_artists()

    print("Step 4/6 - Rebuild staging layer")
    run_sql_file(SQL_STEPS[0])

    print("Step 5/6 - Rebuild analytics star schema")
    run_sql_file(SQL_STEPS[1])

    print("Step 6/6 - Rebuild KPI views")
    run_sql_file(SQL_STEPS[2])

    print("Pipeline completed successfully.")


if __name__ == "__main__":
    main()
