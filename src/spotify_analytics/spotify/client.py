import base64
from typing import Any

import requests

from src.spotify_analytics.config import get_settings


TOKEN_URL = "https://accounts.spotify.com/api/token"
API_BASE_URL = "https://api.spotify.com/v1"


class SpotifyClient:
    def __init__(self) -> None:
        self.settings = get_settings()
        self.access_token = self._refresh_access_token()

    def _refresh_access_token(self) -> str:
        if not self.settings.spotify_refresh_token:
            raise RuntimeError("SPOTIFY_REFRESH_TOKEN is missing in .env")

        auth_value = (
            f"{self.settings.spotify_client_id}:"
            f"{self.settings.spotify_client_secret}"
        )
        encoded_auth = base64.b64encode(auth_value.encode("utf-8")).decode("utf-8")

        response = requests.post(
            TOKEN_URL,
            data={
                "grant_type": "refresh_token",
                "refresh_token": self.settings.spotify_refresh_token,
            },
            headers={
                "Authorization": f"Basic {encoded_auth}",
                "Content-Type": "application/x-www-form-urlencoded",
            },
            timeout=30,
        )
        response.raise_for_status()
        return response.json()["access_token"]

    def get(self, endpoint: str, params: dict[str, Any] | None = None) -> dict[str, Any]:
        response = requests.get(
            f"{API_BASE_URL}{endpoint}",
            headers={"Authorization": f"Bearer {self.access_token}"},
            params=params,
            timeout=30,
        )

        if response.status_code == 401:
            self.access_token = self._refresh_access_token()
            response = requests.get(
                f"{API_BASE_URL}{endpoint}",
                headers={"Authorization": f"Bearer {self.access_token}"},
                params=params,
                timeout=30,
            )

        response.raise_for_status()
        return response.json()

    def get_recently_played(self, limit: int = 50) -> list[dict[str, Any]]:
        payload = self.get("/me/player/recently-played", params={"limit": limit})
        return payload.get("items", [])

    def get_top_items(
        self,
        item_type: str,
        time_range: str = "medium_term",
        limit: int = 50,
    ) -> list[dict[str, Any]]:
        payload = self.get(
            f"/me/top/{item_type}",
            params={"time_range": time_range, "limit": limit},
        )
        return payload.get("items", [])
