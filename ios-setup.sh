#!/usr/bin/env bash

# iOS Project env setup

set -e

RUBY_VERSION="3.1.2"
COCOAPODS_VERSION="1.11.3"
FASTLANE_VERSION="2.206.2"

# 判断一个命令是否存在
function installed() {
    local cmd="$1"
    which "$cmd" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        return 0
    fi
    return 1
}

# 使用homebrew来安装后续依赖，如rbenv
echo "checking brew..."
if installed brew; then
    echo "installed"
else
    echo "not found! installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# rbenv管理多个ruby版本
echo "checking rbenv..."
if installed rbenv; then
    echo "installed"
else
    echo "not found! installing..."
    brew install rbenv
fi

# ruby的依赖包的环境
echo "checking rbenv-gemset..."
if installed rbenv-gemset; then
    echo "installed"
else
    echo "not found! installing..."
    brew install rbenv-gemset
fi

# 安装对应版本的ruby
echo "checking ruby version $RUBY_VERSION"
#rbenv local
echo $RUBY_VERSION >.ruby-version
ruby_version=$(cat .ruby-version)
if [[ -d "$HOME/.rbenv/versions/$ruby_version" ]]; then
    echo "installed"
else
    echo "not found! installing..."
    rbenv install $ruby_version
fi

echo "checking gemset..."
if [[ -f ".rbenv-gemsets" ]]; then
    echo "installed"
else
    echo "not found! installing..."
    rbenv gemset init
fi

# 安装bundler
echo "checking bundler..."
if installed bundle; then
    echo "installed"
else
    echo "not found! installing..."
    gem install bundler
fi

# bundle init
echo "checking Gemfile..."
if [[ -f "Gemfile" ]]; then
    echo "installed"
else
    echo "not found! installing..."

    cat >Gemfile <<EOF
source "https://rubygems.org"

gem "cocoapods", "$COCOAPODS_VERSION"
gem "fastlane", "$FASTLANE_VERSION"

EOF

fi

echo "installing gems..."
bundle install

echo "checking Podfile..."
if [[ -f "Podfile" ]]; then
    echo "found a Podfile, using it"
else
    echo "not found! installing..."
    bundle exec pod init
fi
bundle exec pod install

# Makefile
echo "checking Makefile..."
if [[ -f "Makefile" ]]; then
    echo "found a Makefile, using it"
else
    echo "not found! installing..."

    cat >Makefile <<EOF
.PHONY: install

install:
	bundle exec pod install

EOF
echo "now you can use 'make install' to install ios pods."

fi

# tips
echo "💪 useful tips:"

echo "1. add next code to your shell env to enable ruby version auto set when you change dir in terminal"
echo 'export PATH="$HOME/.rbenv/bin:$PATH"'
echo 'eval "$(rbenv init -)"'

echo "2. rbenv homempage: https://github.com/rbenv/rbenv#readme"
echo "3. rbenv-gemset homepage: https://github.com/jf/rbenv-gemset#readme"
