k8s_bin_dir="${DOTDOT_WD}/k8s/bin"
krew_dir="${DOTDOT_WD}/k8s/krew"
mkdir -p "${k8s_bin_dir}" "${krew_dir}"

export KREW_ROOT="${krew_dir}"

function k8s_update_kubectl() {
  cd "${k8s_bin_dir}";
  latest="$(curl -sL https://storage.googleapis.com/kubernetes-release/release/stable.txt)";
  echo "Grabbing kubectl ${latest} to $(pwd)/kubectl...";
  curl -LO https://storage.googleapis.com/kubernetes-release/release/${latest}/bin/${DOTDOT_OSTYPE}/amd64/kubectl;
  chmod +x kubectl;
}

export PATH="${k8s_bin_dir}:${krew_dir}/bin:$PATH"


function k8s_install_kubectl_plugins() {
  echo "Installing kubectl plugins...";

  set -x; cd "$(mktemp -d)" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.{tar.gz,yaml}" && \
    tar zxvf krew.tar.gz && \
    KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_amd64" && \
    "$KREW" install --manifest=krew.yaml --archive=krew.tar.gz && \
    "$KREW" update;

  kubectl krew install ctx;
  kubectl krew install ns;
  kubectl krew install ketall;
  kubectl krew install spy;
}

if [ ! -f "${k8s_bin_dir}"/kubectl ]; then
  echo "Local kubectl install missing? Trying to grab it.";
  k8s_update_kubectl;
  echo "Installing krew and plugins...";
  k8s_install_kubectl_plugins;
fi;

alias kcx='kubectl ctx'
alias kns='kubectl ns'
alias k='kubectl'
alias kg='kubectl get'
alias ke='kubectl get events -w'
alias kl='kubectl logs'
alias ka='kubectl apply -f'
alias kd='kubectl describe'

function kls() {
  kubectl get "${1:-all}"
}

function ksh() {
  user="${2}";
  if [ -n "$user" ]; then
    kubectl exec-as -u "$user" "${@}" sh;
  else
    kubectl exec -ti "${@}" sh;
  fi;
}

function kts() {
  if [[ "${1}" == --pod=* ]]; then
    spypod="${1#--pod=}"
    shift;
  fi;
  img="${1:-nicolaka/netshoot@sha256:99d15e34efe1e3c791b0898e05be676084638811b1403fae59120da4109368d4}";
  if [ -n "${spypod}" ]; then
    echo "Spinning up ${img} inside ${spypod}, one sec..."
    kubectl spy ${spypod} --spy-image "${img}";
  else
    echo "Spinning up ${img}, one sec..."
    kubectl run robn-shell-diagnostics --generator=run-pod/v1 -ti --rm --image="${img}";
  fi;
}

function kaliases() {
  for n in kcx kns k kg ke kl kls ka kd ksh kts; do
    echo -n "$n => "
    whence -f $n;
  done
  echo "kts [--pod=] [img] => start a trouleshooting pod";
}
