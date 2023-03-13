#!/bin/bash

dir="$(cd `dirname $0`; pwd)"
echo "Workdir: $dir"

# 用 jq 来解析
version=`curl -s https://api.github.com/repos/getlantern/lantern/releases | jq '.[0]' | jq '.tag_name'`
# version=`curl -s https://api.github.com/repos/getlantern/lantern-binaries/commits \
#     | grep '"message": "' \
#     | grep 'Lantern [0-9\.]\+' \
#     | head -1 \
#     | sed 's/.*\(Lantern [0-9\.]*\).*/\1/g'`

if [[ -z $version ]]; then
    echo "Get latest version: error"
    exit 1
fi
echo "Get latest version: $version"

if [ ! -f "$dir/version" ]; then
    touch "$dir/version"
fi

oldver=`cat "$dir/version"`
echo "Get old version: $oldver"

if [ "$oldver" = "$version" ]; then
    echo 'Version not change.'
    exit 0
fi

echo 'Version change.'

# 地址变了
# https://media.githubusercontent.com/media/getlantern/lantern-binaries/main/lantern-installer-64-bit.deb

# 等下载完,你再更改 version 文件吧
wget -o /tmp/wget.log -O ./binaries/lantern-installer-64-bit.deb https://media.githubusercontent.com/media/getlantern/lantern-binaries/main/lantern-installer-64-bit.deb

sed -i "1c # Docker 运行 $version，科学上网" README.MD
echo $version > "$dir/version"
git status
git add .
git status
git commit -m "Travis CI auto update $version ()." &
git log

tag=`echo $version | sed 's/Lantern //g'`
echo "Latest tag: $tag"

if [ `git tag | grep $tag | wc -l` = 0 ]; then
    echo "New tag: $tag"
    git tag "$tag"
else
    echo "Tag: $tag exist"
fi
