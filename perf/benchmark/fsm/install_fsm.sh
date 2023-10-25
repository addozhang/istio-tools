#!/bin/bash

set -e

log() { echo "$1" >&2; }
fail() { log "$1"; exit 1; }

FSM_VERSION=${1:-${FSM_VERSION:-v1.1.3}}
INSTALLROOT=${INSTALLROOT:-"${HOME}/.fsm"}

happyexit() {
  echo ""
  echo "Add the FSM CLI to your path with:"
  echo ""
  echo "  export PATH=\$PATH:${INSTALLROOT}/bin"
  echo ""
  echo "Now run:"
  echo ""
  echo "  fsm version                     # check FSM cli version and control plane version if installed"
  echo "  fsm install                     # install FSM"
  echo "Looking for more? Visit https://fsm-docs.flomesh.io/getting_started/"
  echo ""
  exit 0
}

log "Installing FSM version $FSM_VERSION"

tmpdir=$(mktemp -d /tmp/fsm.XXXXXX)

# To install FSM CLI
system=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m | sed -E 's/x86_/amd/' | sed -E 's/aarch/arm/')
release=${FSM_VERSION}
srcfile="fsm-${release}-${system}-${arch}"
dstfile="${INSTALLROOT}/bin/fsm"
(
  cd "${tmpdir}"
  log "Downloading ${srcfile}"
  curl -L https://github.com/flomesh-io/fsm/releases/download/${release}/${srcfile}.tar.gz | tar -vxzf -
  log "Download complete!"
)

(
  mkdir -p "${INSTALLROOT}/bin"
  mv "${tmpdir}/$system-$arch/fsm" "${dstfile}"
  chmod +x "${dstfile}"
)

rm -r "$tmpdir"

log "FSM ${FSM_VERSION} was successfully installed 🎉"
log ""
happyexit