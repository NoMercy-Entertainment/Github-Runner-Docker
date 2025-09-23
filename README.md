

# GitHub Actions Self-Hosted Runner (Docker)

This project provides a Dockerized GitHub Actions runner that supports scaling, custom labels, runner groups, and Docker-in-Docker (DinD) for CI/CD workflows.

## Quick Start

### 1. Clone and configure

Clone this repo and copy `.env.example` to `.env`:

```sh
cp .env.example .env
```

Edit `.env` and set:

- `GH_TOKEN` — GitHub PAT with admin:org or repo scope
- `GITHUB_ORG` — Your GitHub organization name
- `RUNNER_LABELS` — (Optional) Comma-separated labels for your runner (e.g. `yourname,team,customtag`)
- `RUNNER_GROUP` — (Optional) Runner group name (must exist in your org)

### 2. Build and run with Docker Compose

```sh
docker compose up --build -d
```

#### To scale runners:

```sh
docker compose up -d --scale github-runner=5
```

### 3. Docker-in-Docker (DinD)

The container mounts the host Docker socket (`/var/run/docker.sock`) so your jobs can run Docker commands inside the runner.

## Environment Variables

Set these in your `.env` file:

| Variable        | Description                                      |
|-----------------|--------------------------------------------------|
| **GH_TOKEN**        | GitHub PAT (admin:org or repo scope)             |
| **GITHUB_ORG**      | GitHub organization name                         |
| **RUNNER_LABELS**   | (Optional) Comma-separated runner labels         |
| **RUNNER_GROUP**    | (Optional) Runner group name                     |


## Compose Configuration

See the included `docker-compose.yml` file in this repository for the latest and recommended configuration example.

## Token Verification

You can verify your token with:

```sh
curl -L -X POST \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer {token}" \
	https://api.github.com/orgs/{org}/actions/runners/registration-token
```

## Notes
- The runner name is randomized per instance.
- The container must run as root to access Docker socket.
- For repository-level runners, adjust the API endpoint and variables accordingly.