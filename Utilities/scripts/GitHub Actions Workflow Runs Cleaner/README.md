# GitHub Actions Workflow Runs Cleaner

A Bash script to delete all GitHub Actions workflow runs for specified workflows in a given repository.

## 🛠 What It Does

- Fetches the list of workflow runs for each specified workflow name.
- Deletes them using GitHub CLI (`gh api`).
- Logs each action with a timestamp.
- Supports a `--dry-run` mode to preview which runs would be deleted without actually deleting them.

## ⚙️ Requirements

- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated:
  
  ```bash
  gh auth login
  ```

- Write access or higher to the repository.
- Bash-compatible shell (bash/zsh).

## 🔧 Configuration

Edit these variables inside the script:

```bash
REPO="your-organization/your-repo-name"
WORKFLOWS="Your Workflow Name A, Your Workflow Name B"
```

- `REPO`: repository name in `owner/repo` format.
- `WORKFLOWS`: comma-separated list of GitHub Actions workflow names.

## 🚀 Usage

### Delete workflow runs

```bash
chmod +x delete-workflow-runs.sh
./delete-workflow-runs.sh
```

### 📝 Example Output

```text
2025-03-29 10:20:01 - Fetching list of workflow runs...
2025-03-29 10:20:01 - Processing workflow: Your Workflow Name A
2025-03-29 10:20:02 - Found 42 runs to delete for workflow 'Your Workflow Name A'.
2025-03-29 10:20:02 - Deleting run ID: 13914392794
2025-03-29 10:20:03 - Deleting run ID: 13914392700
...
2025-03-29 10:20:12 - Workflow run deletion completed.
```

### Dry run (preview only)

```bash
./delete-workflow-runs.sh --dry-run
```

### 📝 Example Output (preview only)

```text
2025-03-29 10:15:01 - Fetching list of workflow runs...
2025-03-29 10:15:01 - Processing workflow: Your Workflow Name A
2025-03-29 10:15:02 - Found 42 runs to delete for workflow 'Your Workflow Name A'.
2025-03-29 10:15:02 - [DRY-RUN] Would delete run ID: 13914392794
...
2025-03-29 10:15:12 - Workflow run deletion completed.
```

## ❗️Important

- Deleted workflow runs cannot be restored.
- The script does not delete workflow `.yml` files in `.github/workflows/`.

## 📄 License

MIT
