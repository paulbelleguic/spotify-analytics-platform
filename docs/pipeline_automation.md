# Pipeline Automation
This project supports two pipeline execution modes.
## Manual pipeline execution
Run the full ETL and analytics refresh pipeline:
```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.jobs.run_pipeline
```
This command runs:
1. Spotify recently played extraction
2. Spotify top tracks extraction
3. Spotify top artists extraction
4. Staging layer rebuild
5. Analytics star schema rebuild
6. KPI views rebuild
## Prefect orchestration
Run the Prefect flow locally:
```powershell
.\.venv\Scripts\python.exe -m src.spotify_analytics.orchestration.prefect_flow
```
The Prefect flow orchestrates the same pipeline with task-level logging.
## Future scheduling
The target production-like setup is:
```text
Scheduled Prefect flow
    -> Spotify API extraction
    -> PostgreSQL raw layer
    -> staging SQL layer
    -> analytics star schema
    -> KPI views
    -> Power BI refresh
```
Recommended schedule:
```text
Every 1 hour for recently played data
Daily for top tracks and top artists
```
## Spotify API limitation
Spotify's Web API recently played endpoint only exposes recent listening activity.
For long-term historical analysis, this project will support importing Spotify Extended Streaming History export files.