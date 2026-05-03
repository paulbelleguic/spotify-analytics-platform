# Spotify Personal Analytics Platform

End-to-end Data Engineering and Analytics Engineering project inspired by Stats.fm.

The goal of this project is to build a personal analytics platform that extracts Spotify listening data, stores it in PostgreSQL, models it into analytics-ready tables, orchestrates the pipeline with Prefect, and prepares the data for a Power BI dashboard.

## Project Objectives

This project demonstrates how to build a modern data pipeline using real API data and analytics engineering best practices.

Main objectives:

- Extract personal Spotify data using the Spotify Web API
- Store raw API responses in PostgreSQL
- Build a clean staging layer
- Model listening data into a star schema
- Create analytics KPI views
- Add data quality checks
- Orchestrate the pipeline with Prefect
- Prepare a Power BI dashboard similar to a personal Stats.fm

## Architecture

```text
Spotify Web API
      |
      v
Python ETL
      |
      v
PostgreSQL raw layer
      |
      v
dbt staging models
      |
      v
dbt marts / star schema
      |
      v
SQL KPI views
      |
      v
Power BI dashboard
```

Future historical backfill:

```text
Spotify Extended Streaming History Export
      |
      v
Python import job
      |
      v
PostgreSQL raw layer
      |
      v
Analytics model
```

## Tech Stack

- Python
- Spotify Web API
- OAuth 2.0
- PostgreSQL
- Docker Compose
- SQLAlchemy
- dbt
- Prefect
- Power BI
- GitHub

## Data Sources

Current sources:

- Spotify recently played tracks
- Spotify top tracks
- Spotify top artists

Planned source:

- Spotify Extended Streaming History export

## Repository Structure

```text
spotify-analytics-platform/
|-- dbt_spotify_analytics/
|   |-- models/
|   |   |-- staging/
|   |   `-- marts/
|   `-- dbt_project.yml
|-- docs/
|-- dashboards/
|   `-- powerbi/
|-- sql/
|-- src/
|   `-- spotify_analytics/
|       |-- db/
|       |-- jobs/
|       |-- orchestration/
|       `-- spotify/
|-- tests/
|   `-- sql/
|-- docker-compose.yml
|-- requirements.txt
`-- README.md
```

## Data Pipeline

The pipeline performs the following steps:

1. Extract recently played tracks from the Spotify API
2. Extract top tracks from the Spotify API
3. Extract top artists from the Spotify API
4. Import Spotify Extended Streaming History export when available
5. Build dbt staging and marts models
6. Rebuild analytics KPI views
7. Run SQL data quality checks

Run the full Python pipeline:

```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.jobs.run_pipeline
```

Run the Prefect flow:

```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.orchestration.prefect_flow
```

## Database Layers

### Raw Layer

Raw data is stored in PostgreSQL with minimal transformation.

Examples:

- `raw.spotify_recently_played`
- `raw.spotify_top_tracks`
- `raw.spotify_top_artists`
- `raw.spotify_streaming_history_export`

### Staging Layer

The staging layer cleans and standardizes source data.

Example:

- `staging.stg_recently_played`

### Analytics Layer

The analytics layer contains a star schema designed for reporting.

Dimensions:

- `analytics.dim_tracks`
- `analytics.dim_artists`
- `analytics.dim_albums`
- `analytics.dim_time`

Fact table:

- `analytics.fact_listening_history`

## Analytics KPIs

The project prepares KPIs such as:

- Total plays
- Unique tracks
- Unique artists
- Unique albums
- Total minutes listened
- Total hours listened
- Top tracks
- Top artists
- Listening activity by day
- Listening activity by hour
- Listening heatmap
- Listening by day period

## Data Quality

SQL quality checks validate that:

- The fact table is not empty
- Track IDs are not null
- Listening duration is not negative
- Dimension tables are not empty
- Raw listening events are not duplicated

Run checks manually with:

```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.jobs.run_data_quality_checks
```

## dbt

dbt is used for Analytics Engineering workflows:

```powershell
.\.venv\Scripts\python.exe -m dbt run --project-dir dbt_spotify_analytics --profiles-dir dbt_spotify_analytics
```

```powershell
.\.venv\Scripts\python.exe -m dbt test --project-dir dbt_spotify_analytics --profiles-dir dbt_spotify_analytics
```

## Local Setup

### 1. Clone the repository

```powershell
git clone https://github.com/paulbelleguic/spotify-analytics-platform.git
cd spotify-analytics-platform
```

### 2. Start PostgreSQL

```powershell
docker compose up -d
```

### 3. Create a virtual environment

```powershell
py -3.12 -m venv .venv
.\.venv\Scripts\Activate.ps1
```

### 4. Install dependencies

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

### 5. Configure environment variables

Create a `.env` file from `.env.example` and fill in Spotify credentials:

```text
SPOTIFY_CLIENT_ID=
SPOTIFY_CLIENT_SECRET=
SPOTIFY_REDIRECT_URI=http://127.0.0.1:8888/callback
SPOTIFY_REFRESH_TOKEN=
```

### 6. Run OAuth flow

```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.spotify.oauth
```

### 7. Run the pipeline

```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.orchestration.prefect_flow
```

## Power BI Dashboard

The Power BI dashboard will include:

- Overview page
- Listening habits page
- Top tracks and artists page
- Time-based listening analysis
- Heatmap by day and hour

Dashboard screenshots will be added once the final dashboard is completed.

## Spotify API Limitation

Spotify's Web API only exposes recent listening activity through the recently played endpoint.

For long-term historical analysis, this project supports importing Spotify Extended Streaming History export files once they are available.

## Roadmap

- [x] PostgreSQL Docker setup
- [x] Spotify OAuth
- [x] Spotify API ingestion
- [x] Raw PostgreSQL storage
- [x] Staging layer
- [x] Star schema
- [x] KPI views
- [x] Data quality checks
- [x] Prefect orchestration
- [x] dbt project setup
- [ ] Spotify Extended Streaming History import with real export files
- [ ] Power BI dashboard final version
- [ ] Dashboard screenshots
- [ ] Automated scheduling
- [ ] Cloud deployment
