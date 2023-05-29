
# Github Runner Docker Image

```bash
docker build --tag github-runner .
```

```bash
docker run -e GH_TOKEN="{token}" -e GITHUB_ORG="{org}" -d github-runner
```

Token must have admin rights to the organization.</br>
You can verify if your token is working by running:

```bash
curl -L -X POST \
-H "Accept: application/vnd.github+json" \
-H "Authorization: Bearer {token}" \
-H "X-GitHub-Api-Version: 2022-11-28" \
https://api.github.com/orgs/{org}/actions/runners/registration-token
```