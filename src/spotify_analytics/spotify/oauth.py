import base64
import secrets
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

import requests

from src.spotify_analytics.config import get_settings


AUTH_URL = "https://accounts.spotify.com/authorize"
TOKEN_URL = "https://accounts.spotify.com/api/token"

SCOPES = [
    "user-read-recently-played",
    "user-top-read",
    "user-read-private",
    "user-read-email",
]


class CallbackHandler(BaseHTTPRequestHandler):
    authorization_code: str | None = None
    expected_state: str | None = None

    def do_GET(self) -> None:
        query = urllib.parse.urlparse(self.path).query
        params = urllib.parse.parse_qs(query)

        state = params.get("state", [""])[0]
        if state != self.expected_state:
            self.send_response(400)
            self.end_headers()
            self.wfile.write(b"Invalid state. You can close this tab.")
            return

        type(self).authorization_code = params.get("code", [None])[0]

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Spotify authorization complete. You can close this tab.")


def build_authorization_url(state: str) -> str:
    settings = get_settings()

    params = {
        "client_id": settings.spotify_client_id,
        "response_type": "code",
        "redirect_uri": settings.spotify_redirect_uri,
        "scope": " ".join(SCOPES),
        "state": state,
    }

    return f"{AUTH_URL}?{urllib.parse.urlencode(params)}"


def exchange_code_for_tokens(code: str) -> dict:
    settings = get_settings()
    auth_value = f"{settings.spotify_client_id}:{settings.spotify_client_secret}"
    encoded_auth = base64.b64encode(auth_value.encode("utf-8")).decode("utf-8")

    response = requests.post(
        TOKEN_URL,
        data={
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": settings.spotify_redirect_uri,
        },
        headers={
            "Authorization": f"Basic {encoded_auth}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        timeout=30,
    )
    response.raise_for_status()
    return response.json()


def main() -> None:
    state = secrets.token_urlsafe(24)
    CallbackHandler.expected_state = state

    authorization_url = build_authorization_url(state)

    print("Open this URL in your browser:")
    print(authorization_url)
    print("\nWaiting for Spotify callback on http://127.0.0.1:8888/callback ...")

    server = HTTPServer(("127.0.0.1", 8888), CallbackHandler)
    server.handle_request()

    code = CallbackHandler.authorization_code
    if not code:
        raise RuntimeError("No authorization code received.")

    tokens = exchange_code_for_tokens(code)

    print("\nAdd this value to your .env file:")
    print(f"SPOTIFY_REFRESH_TOKEN={tokens['refresh_token']}")


if __name__ == "__main__":
    main()
