# zsh-github-issues

Subscribe to your projects of interest on Github and receive **within shell** (under
prompt) notifications about new issues.

# Usage

The tool currently needs Zsh and [zplugin](https://github.com/zdharma/zplugin).

The notificator load:
```zsh
zplugin ice lucid id-as'GitHub-notify' \
        ice on-update-of'~/.cache/zsh-github-issues/new_titles.log' \
        notify'New issue: $NOTIFY_MESSAGE'
zplugin light zdharma/zsh-github-issues
```

Background daemon load (it pulls the issues, by default every 2 minutes):
```zsh
# GIT stands for 'Github Issue Tracker', the future name of the project
GIT_PROJECTS=zdharma/zsh-github-issues:zdharma/zplugin

zplugin ice service"GIT" pick"zsh-github-issues.service.zsh" wait'1' lucid
zplugin light zdharma/zsh-github-issues
```

<!-- vim:tw=89
-->
