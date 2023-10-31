function git_sparse_clone() (
  rurl="$1" localdir="$2" clonedir="$3" && shift 3

  tmpdir="tmpdir/"
  initialdir=$PWD

  git clone --no-checkout --depth=1 --filter=tree:0 "$rurl" "$tmpdir"
  cd "$tmpdir"

  git sparse-checkout set "$clonedir"

  # Loops over remaining args
  for arg in $@; do
    echo "$arg"
    git sparse-checkout add "$arg"
  done

  git checkout

  cd "$initialdir"
  mkdir "$localdir"

  # Remove double slashes
  pathtofiles=$(echo "$tmpdir/$clonedir/*" | sed 's#/\{2,\}#/#g')

  mv $pathtofiles "$localdir"
  rm -rf "$tmpdir"
)
