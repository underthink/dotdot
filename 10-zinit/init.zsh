zinit_wd="${DOTDOT_WD}/zinit"

mkdir -p "${zinit_wd}"

declare -A ZINIT

ZINIT[BIN_DIR]="${0:a:h}/bin"
ZINIT[HOME_DIR]="${zinit_wd}"

source "${ZINIT[BIN_DIR]}/zinit.zsh"
