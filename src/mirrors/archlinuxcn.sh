_synonyms_arch="archlinuxcn"
_archlinuxcn_config_file="/etc/pacman.conf"

check() {
	source_os_release
	[ "$NAME" = "Arch Linux" ]
}

install() {
	config_file=$_archlinuxcn_config_file
	set_sudo

	$sudo cp ${config_file} ${config_file}.bak || {
		print_error "Failed to backup ${config_file}"
		return 1
	}

	old_config=$(cat ${config_file})
	{
		cat << EOF | $sudo tee ${config_file} > /dev/null
${old_config}
# ${gen_tag}
[archlinuxcn]
Server = ${http}://${domain}/archlinuxcn/\$arch
EOF
	} || {
		print_error "Failed to add mirror to ${config_file}"
		return 1
	}
}

is_deployed() {
	config_file=$_archlinuxcn_config_file
	pattern="^[^#]*Server\s*=\s*${http}://${domain}/archlinuxcn/\\\$arch"
	grep -qE "${pattern}" ${config_file} 
}

can_recover() {
	bak_file=${_archlinuxcn_config_file}.bak
	result=0
	test -f $bak_file || result=$?
	return $result
}

uninstall() {
	config_file=$_archlinuxcn_config_file
	set_sudo
	$sudo mv ${config_file}.bak ${config_file} || {
		print_error "Failed to recover ${config_file}"
		return 1
	}
}

# vim: set filetype=sh ts=4 sw=4 noexpandtab:
