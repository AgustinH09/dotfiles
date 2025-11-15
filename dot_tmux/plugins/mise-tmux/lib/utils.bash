#!/usr/bin/env bash

set -euo pipefail

GH_REPO="https://github.com/tmux/tmux"
TOOL_NAME="tmux"
TOOL_TEST="tmux -V"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# NOTE: You might want to remove this if tmux is not hosted on GitHub releases.
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
fi

download_libevent() {
	local libevent_version libevent_filename libevent_url
	libevent_version="$1"
	libevent_filename="$2"

	libevent_url="https://github.com/libevent/libevent/releases/download/release-${libevent_version}-stable/libevent-${libevent_version}-stable.tar.gz"

	curl "${curl_opts[@]}" -o "$libevent_filename" -C - "$libevent_url" || fail "Could not download $libevent_url"
}

install_libevent() {
	local install_path
	install_path="$1"

	# Default configure options to --disable-openssl
	LIBEVENT_EXTRA_CONFIGURE_OPTIONS=${LIBEVENT_EXTRA_CONFIGURE_OPTIONS:-"--disable-openssl"}

	# Build libevent
	cd "$ASDF_DOWNLOAD_PATH/libevent"
	./configure "$LIBEVENT_EXTRA_CONFIGURE_OPTIONS" --prefix="$install_path"
	make -j "${ASDF_CONCURRENCY:-2}"
	if make -j "${ASDF_CONCURRENCY:-2}"; then
		make install
	else
		exit 2
	fi
}

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3-
}

list_all_versions() {
	list_github_tags
}

download_release() {
	local version filename url
	version="$1"
	filename="$2"

	url="$GH_REPO/releases/download/${version}/tmux-${version}.tar.gz"

	echo "* Downloading $TOOL_NAME release $version..."
	curl "${curl_opts[@]}" -o "$filename" -C - "$url" || fail "Could not download $url"
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_root="${3%/bin}"
	local install_path="${install_root}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_root"

		# Install libevent
		install_libevent "$install_root"

		# Default configure options to --disable-utf8proc
		TMUX_EXTRA_CONFIGURE_OPTIONS=${TMUX_EXTRA_CONFIGURE_OPTIONS:-"--disable-utf8proc"}

		# Build tmux
		cd "$ASDF_DOWNLOAD_PATH/$TOOL_NAME"
		./configure "$TMUX_EXTRA_CONFIGURE_OPTIONS" --prefix="$install_root" CFLAGS="-I${install_root}/include" LDFLAGS="-L${install_root}/lib -Wl,-rpath,${install_root}/lib"
		if ! make -j "${ASDF_CONCURRENCY:-2}"; then
			exit 2
		fi
		make install

		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_root"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
