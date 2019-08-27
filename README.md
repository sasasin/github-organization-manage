# github-organization-manage
github-organization-manage

# 使用準備

GitHubで Personal Access Token を発行し、環境変数 `GITHUB_ACCESS_TOKEN` に入れてください。

```
export GITHUB_ACCESS_TOKEN=${さっき発行したGitHub PAT}
```

調査対象の調査対象のGitHub Organization名を、環境変数 `GITHUB_ORG_NAME` に入れてください。

```
export GITHUB_ORG_NAME=${調査対象のGitHub Organization名}
```

リポジトリをcloneし、ライブラリをインストールしたら、利用可能になります。

```
git clone git@github.com:sasasin/github-organization-manage.git
cd github-organization-manage
bundle install
bundle exec ./github-organization-manage.rb
Commands:
  github-organization-manage.rb get_client                # internal method for this cli program
  github-organization-manage.rb help [COMMAND]            # Describe available commands or one specific command
  github-organization-manage.rb org_collabs               # Get organization collaborators
  github-organization-manage.rb org_members               # Get organization members
  github-organization-manage.rb org_repos                 # List organization repositories
  github-organization-manage.rb org_teams                 # Get organization teams
  github-organization-manage.rb repos_collabs_permission  # listup collaborators have permissions to repositories
  github-organization-manage.rb repos_member_permission   # listup who have permissions to repositories?
  github-organization-manage.rb repos_team_permission     # listup what team have permissions to repositories?
  github-organization-manage.rb team_members              # List team members
```

# 使用方法

各サブコマンドから、CSV形式で出ますので、Excelにペタペタする、RDBにインポートする、joinコマンドで頑張る、などして、GitHub Organizationの管理に活用してください。

# 参考

* https://github.com/settings/tokens
* https://developer.github.com/v3/
* https://www.rubydoc.info/gems/octokit/4.14.0/Octokit
* https://jhawthorn.github.io/curl-to-ruby/
* https://github.com/erikhuda/thor
