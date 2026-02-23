# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A single-file Ruby CLI tool for auditing and exporting GitHub organization access control data as CSV. Used by org admins to analyze team membership, repository permissions, and collaborator access.

## Setup

```bash
bundle install
```

Required environment variables:
- `GITHUB_ACCESS_TOKEN` — Personal Access Token with org-level read permissions
- `GITHUB_ORG_NAME` — Target GitHub organization name

## Running the Tool

```bash
bundle exec ./github-organization-manage.rb <command>
```

Available commands: `org_repos`, `org_members`, `org_collabs`, `org_teams`, `team_members`, `repos_member_permission`, `repos_team_permission`, `repos_collabs_permission`

Typical workflow — export all data to sorted CSV files:
```bash
mkdir tmp/
bundle exec ./github-organization-manage.rb org_teams | sort > tmp/org_teams.csv
bundle exec ./github-organization-manage.rb org_repos | sort > tmp/org_repos.csv
bundle exec ./github-organization-manage.rb org_members | sort > tmp/org_members.csv
bundle exec ./github-organization-manage.rb org_collabs | sort > tmp/org_collabs.csv
bundle exec ./github-organization-manage.rb team_members | sort > tmp/team_members.csv
bundle exec ./github-organization-manage.rb repos_collabs_permission | sort > tmp/repos_collabs_permission.csv
bundle exec ./github-organization-manage.rb repos_team_permission | sort > tmp/repos_team_permission.csv
bundle exec ./github-organization-manage.rb repos_member_permission | sort > tmp/repos_member_permission.csv
```

## Architecture

The entire application is in [github-organization-manage.rb](github-organization-manage.rb) — a single **Thor CLI class** (`GithubTeamManage::CUI`) wrapping the Octokit GitHub API client.

Key implementation details:
- `Octokit.configure { c.auto_paginate = true }` handles API pagination automatically
- `org_collabs` uses raw `Net::HTTP` instead of Octokit (the external collaborators endpoint was not available in the Octokit version used)
- Permission levels (Read, Triage, Write, Maintain, Admin) are detected via nested boolean checks on Octokit permission objects
- All output is CSV printed to stdout; callers pipe and sort as needed

## Dependencies

- **Octokit** — GitHub Ruby SDK (API calls for repos, members, teams, permissions)
- **Thor** — CLI subcommand framework
- **Faraday** — HTTP client (transitive dependency of Octokit)
