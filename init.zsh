if [[ "${OSTYPE}" == darwin* ]]; then
  export DOTDOT_OSTYPE="darwin";
else
  export DOTDOT_OSTYPE="linux";
fi;

export DOTDOT_DIR="${DOTDOT_DIR:-${0:a:h}}";
export DOTDOT_WD="${DOTDOT_WD:-${HOME}/.dot-wd}";

mkdir -p "${DOTDOT_WD}"

for init_script in $(ls ${DOTDOT_DIR}/*-*.zsh ${DOTDOT_DIR}/*/init.zsh); do
  source "${init_script}";
done
