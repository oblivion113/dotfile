. "$HOME/.cargo/env"

# arkcli: 跳过 npm postinstall（防止安装/升级时自动把 25 个 skill 灌进各 harness 全局目录）。
# skill 刷新改为手动: arkcli +connect --refresh --path ~/code/arkcli-skills/skills
export ARKCLI_SKIP_POSTINSTALL=1
