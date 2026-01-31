import os
import time

import requests
from dotenv import load_dotenv

print("Starting RSS feed updater for Sonarr")

load_dotenv()

TIMEOUT = 120

time.sleep(TIMEOUT)

try:
    BASE_URL = "http://sonarr:8989"
    requests.get(BASE_URL, timeout=2).raise_for_status()
except Exception:
    BASE_URL = "http://localhost:8989"

print(f"Updating RSS feed for Sonarr at {BASE_URL}")

HEADERS = {"X-Api-Key": os.getenv("SONARR_API_KEY")}


def sonarr_req(endpoint, data=None, method="GET"):
    try:
        req = requests.post if method == "POST" else requests.get
        return req(f"{BASE_URL}/{endpoint}", headers=HEADERS, json=data)
    except Exception:
        return None


def sonarr_api_req(endpoint, data=None, method="GET"):
    return sonarr_req(f"api/v3/{endpoint}", data=data, method=method)


def sonarr_rss_sync():
    data = {"name": "RssSync"}
    return sonarr_api_req("command", data=data, method="POST")


while True:
    req = sonarr_req("api")
    if req is not None and req.status_code == 200:
        print("Sonarr API is up and running!")
        break
    else:
        time.sleep(5)

while True:
    try:
        last_run = time.time()
        result = sonarr_rss_sync()
        if result is not None and 200 <= result.status_code <= 202:
            # print(result.json())
            pass
        else:
            print("Failed to sync RSS feed")
        while (time.time() - last_run) < TIMEOUT:
            time.sleep(1)
    except KeyboardInterrupt:
        exit(0)
    except Exception:
        time.sleep(5)
