check() {
	source_os_release
	[ "$NAME" = "Ubuntu" ]
}

install() {
	config_file="/etc/apt/sources.list"
	source_os_release
	codename=${VERSION_CODENAME}
	set_sudo

	$sudo cp ${config_file} ${config_file}.bak || {
		print_error "Backup ${config_file} failed"
		return 1
	}

	secure_url="${http}://${domain}/ubuntu/"
	confirm_y "Use official secure source? (Strongly recommended)" && \
		secure_url="http://security.ubuntu.com/ubuntu/"

	propoesd_prefix="# "
	confirm "Use proposed source?" && \
		propoesd_prefix=""

	src_prefix="# "
	confirm "Use source code?" && \
		src_prefix=""

	$sudo sh -e -c "cat <<EOF > ${config_file}
# ${gen_tag}
deb ${http}://${domain}/ubuntu/ ${codename} main restricted universe multiverse
${src_prefix}deb-src ${http}://${domain}/ubuntu/ ${codename} main restricted universe multiverse
deb ${http}://${domain}/ubuntu/ ${codename}-updates main restricted universe multiverse
${src_prefix}deb-src ${http}://${domain}/ubuntu/ ${codename}-updates main restricted universe multiverse
deb ${http}://${domain}/ubuntu/ ${codename}-backports main restricted universe multiverse
${src_prefix}deb-src ${http}://${domain}/ubuntu/ ${codename}-backports main restricted universe multiverse

deb ${secure_url} ${codename}-security main restricted universe multiverse
${src_prefix}deb-src ${secure_url} ${codename}-security main restricted universe multiverse

${propoesd_prefix}deb ${http}://${domain}/ubuntu/ ${codename}-proposed main restricted universe multiverse
${propoesd_prefix}deb-src ${http}://${domain}/ubuntu/ ${codename}-proposed main restricted universe multiverse
EOF" || {
		print_error "Write ${config_file} failed"
		return 1
	}

	confirm_y "Do you want to apt update?" && {
		$sudo apt update || {
			print_error "apt update failed"
			return 1
		}
	}

	true
}

uninstall() {
	config_file="/etc/apt/sources.list"
	set_sudo
	$sudo mv ${config_file}.bak ${config_file} || {
		print_error "Failed to recover ${config_file}"
		return 1
	}
}

is_deployed() {
	config_file="/etc/apt/sources.list"
	result=0
	$sudo grep -q "${gen_tag}" ${config_file} || result=$?
	return $result
}

can_recover() {
	bak_file="/etc/apt/sources.list.bak"
	result=0
	test -f $bak_file || result=$?
	return $result
}

# vim: set filetype=sh ts=4 sw=4 noexpandtab:
