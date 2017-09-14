function parse_git_dirty {
  [[ $(git status 2> /dev/null | tail -n1) != "nothing to commit, working tree clean" ]] && echo "*"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}

BRANCH=$(parse_git_branch)
if [ $BRANCH == "(development*)" ]; then
  echo "$BRANCH 尚未完成本地提交。"
elif [ $BRANCH != "(development)" ]; then
  echo "当前 $BRANCH 不是 development 分支，请先执行 git checkout development 切换分支"
else
  echo "正在提交到远程 development 分支..."
  git push origin development
  echo "正在与 master 分支合并..."
  git checkout master
  git merge development --no-ff --quiet
  echo "正在提交到远程 master 分支..."
  git push origin master
  echo "已完成 master 分支合并，并已触发云端打包发布流程"
  git checkout development
  echo "已返回 development 分支"
  echo
  echo "请在 Travis Dashboard 中查看结果"
  echo "https://www.travis-ci.org/MagicCube/cdn-pub-automation/"
  echo
  echo "Travis 可能会应高峰而延迟打包，你也可以在这里查看最新结果"
  echo "https://www.travis-ci.org/MagicCube/cdn-pub-automation/branches"
fi
