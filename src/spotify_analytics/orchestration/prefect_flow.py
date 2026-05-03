from pathlib import Path

from prefect import flow, task
from sqlalchemy import text

from src.spotify_analytics.db.connection import get_engine
from src.spotify_analytics.jobs.extract_recently_played import main as extract_recently_played
from src.spotify_analytics.jobs.extract_top_artists import main as extract_top_artists
from src.spotify_analytics.jobs.extract_top_tracks import main as extract_top_tracks
from src.spotify_analytics.jobs.import_streaming_history import main as import_streaming_history


PROJECT_ROOT = Path(__file__).resolve().parents[3]

SQL_STEPS = [
    PROJECT_ROOT / "sql" / "004_create_staging_schema.sql",
    PROJECT_ROOT / "sql" / "005_rebuild_analytics_star_schema.sql",
    PROJECT_ROOT / "sql" / "006_create_analytics_kpi_views.sql",
]


@task
def extract_recently_played_task() -> None:
    extract_recently_played()


@task
def extract_top_tracks_task() -> None:
    extract_top_tracks()


@task
def extract_top_artists_task() -> None:
    extract_top_artists()


@task
def run_sql_file_task(path: str) -> None:
    sql_path = Path(path)
    sql = sql_path.read_text(encoding="utf-8")
    engine = get_engine()

    with engine.begin() as connection:
        connection.execute(text(sql))

@task
def import_streaming_history_task() -> None:
    import_streaming_history()

@flow(name="spotify-personal-analytics-pipeline")
def spotify_personal_analytics_pipeline() -> None:
    extract_recently_played_task()
    extract_top_tracks_task()
    extract_top_artists_task()
    import_streaming_history_task()

    for sql_file in SQL_STEPS:
        run_sql_file_task(str(sql_file))



if __name__ == "__main__":
    spotify_personal_analytics_pipeline()
