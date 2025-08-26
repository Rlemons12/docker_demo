param([string]$ProjectName = "docker_demo")

$proj = Join-Path (Get-Location).Path $ProjectName
$app  = Join-Path $proj "app"
$tpl  = Join-Path $app  "templates"
$css  = Join-Path $app  "static\css"

# Create folders
$dirs = @($proj,$app,$tpl,$css)
foreach ($d in $dirs) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null } }

# Write files (simple strings, no here-strings)
Set-Content "$proj\.dockerignore" "__pycache__`n.venv`n.git"
Set-Content "$proj\requirements.txt" "Flask==3.0.3`nGunicorn==22.0.0"
Set-Content "$proj\.env" "FLASK_APP=app.app:create_app`nFLASK_ENV=development`nFLASK_DEBUG=1`nPORT=5000"

Set-Content "$app\__init__.py" "from .app import create_app"
Set-Content "$app\log_config.py" "import logging,os;logging.basicConfig(level=logging.INFO)"
Set-Content "$app\app.py" @"
import os,logging
from flask import Flask, render_template
from .log_config import *

def create_app():
    app = Flask(__name__, template_folder="templates", static_folder="static")
    @app.route("/")
    def index(): return render_template("index.html", title="Home")
    @app.route("/about")
    def about(): return render_template("about.html", title="About")
    @app.get("/healthz")
    def healthz(): return {"status":"ok"},200
    return app

if __name__ == "__main__":
    create_app().run(host="0.0.0.0",port=int(os.getenv("PORT","5000")),debug=True)
"@

Set-Content "$tpl\base.html" "<!doctype html><html><head><title>{{ title }}</title></head><body>{% block content %}{% endblock %}</body></html>"
Set-Content "$tpl\index.html" "{% extends 'base.html' %}{% block content %}<h1>Home</h1>{% endblock %}"
Set-Content "$tpl\about.html" "{% extends 'base.html' %}{% block content %}<h1>About</h1>{% endblock %}"
Set-Content "$css\main.css" "body{font-family:sans-serif;margin:0}h1{color:#333}"

Set-Content "$proj\Dockerfile" "FROM python:3.11-slim`nWORKDIR /app`nCOPY requirements.txt .`nRUN pip install -r requirements.txt`nCOPY app/ ./app/`nEXPOSE 5000`nCMD [""python"",""-m"",""flask"",""run"",""--host=0.0.0.0"",""--port=5000""]"
Set-Content "$proj\docker-compose.yml" "version: '3'`nservices:`n  web:`n    build: .`n    ports:`n      - '5000:5000'`n    env_file: .env`n    volumes:`n      - ./app:/app/app"

# Create virtualenv & install requirements
if (-not (Test-Path "$proj\.venv")) { python -m venv "$proj\.venv" }
& "$proj\.venv\Scripts\python.exe" -m pip install --upgrade pip
& "$proj\.venv\Scripts\pip.exe" install -r "$proj\requirements.txt"

Write-Host "Project created in $proj"
Write-Host "Activate venv with: .\.venv\Scripts\Activate"
Write-Host "Run locally with: flask run"
Write-Host "Or run Docker with: docker compose up --build"
