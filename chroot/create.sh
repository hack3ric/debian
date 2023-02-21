#!/bin/sh

set -e

help_msg() {
  echo "Usage: ./create-chroot.sh [-h] [-m mirror] [-a arch] [--] <target>" >&2
  exit $1
}

mirror=http://deb.debian.org
arch=riscv64
user=debian

while getopts "hm:a:u:" opt; do
  case $opt in
    h)
      help_msg 0
      ;;
    m)
      mirror=$OPTARG
      ;;
    a)
      arch=$OPTARG
      ;;
    u)
      user=$OPTARG
      ;;
    \?)
      help_msg 1
      ;;
  esac
done

shift $((OPTIND-1))
[ "${1:-}" = "--" ] && shift

if [ -z $1 ]; then
  help_msg 1
fi

if [ $UID -ne 0 ]; then
  echo "You need to be root in order to run this script." >&2
  exit 1
fi

echo Use mirror $mirror
echo Directory path $1
# read -n1 -rsp "Press any key to continue..." key
echo

mmdebstrap --architectures=$arch --mode=root \
  --include=debian-ports-archive-keyring,ca-certificates,bash-completion,git,quilt,devscripts,sudo,reportbug,auto-apt-proxy \
  sid $1 \
  "deb $mirror/debian-ports sid main" \
  "deb-src $mirror/debian sid main" \
  "deb $mirror/debian-ports unreleased main" && :

base_name=$(basename $1)

/sbin/chroot $1 <<EOF
apt update
echo $base_name > /etc/hostname
echo "127.0.0.1	$base_name" >> /etc/hosts
/sbin/useradd -m -s /bin/bash $user
echo $user:$user | /sbin/chpasswd
echo root:root | /sbin/chpasswd
echo "debian ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
EOF

cd $1

# From https://www.debian.org/doc/manuals/maint-guide/modify.html#quiltrc
cat <<EOF >> home/$user/.bashrc
alias dquilt="quilt --quiltrc=\${HOME}/.quiltrc-dpkg"
. /usr/share/bash-completion/completions/quilt
complete -F _quilt_completion -o filenames dquilt
EOF
cat <<EOF > home/$user/.quiltrc-dpkg
d=. ; while [ ! -d \$d/debian -a \$(readlink -e $d) != / ]; do d=\$d/..; done
if [ -d \$d/debian ] && [ -z \$QUILT_PATCHES ]; then
  # if in Debian packaging tree with unset \$QUILT_PATCHES
  QUILT_PATCHES="debian/patches"
  QUILT_PATCH_OPTS="--reject-format=unified"
  QUILT_DIFF_ARGS="-p ab --no-timestamps --no-index --color=auto"
  QUILT_REFRESH_ARGS="-p ab --no-timestamps --no-index"
  QUILT_COLORS="diff_hdr=1;32:diff_add=1;34:diff_rem=1;31:diff_hunk=1;33:diff_ctx=35:diff_cctx=33"
  if ! [ -d \$d/debian/patches ]; then mkdir \$d/debian/patches; fi
fi
EOF
