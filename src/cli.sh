cli_deploy() {
	if [ $# -eq 0 ]; then
		print_warning "Nothing to deploy."
	fi
	for item in $@
	do
		deploy $item || print_error "Failed to deploy $item. Ignoring..."
	done
}

cli_recover() {
	if [ $# -eq 0 ]; then
		print_warning "Nothing to recover."
	fi
	for item in $@
	do
		recover $item || print_error "Failed to recover $item. Ignoring..."
	done
}

cli_autorecover() {
	set_mirror_recover_list no
	for item in $ready_to_uninstall
	do
		recover $item || print_error "Failed to recover $item. Ignoring..."
	done
}

cli_main() {
	# parse arguments
	case "$1" in
		autodeploy | ad)
			[ "$2" = "-y" ] && silent_input="y"
			set_mirror_list no
			cli_deploy $ready_to_install
			unset silent_input
			;;
		deploy | d)
			shift 1
			cli_deploy $@
			;;
		list | l)
			set_mirror_list no
			;;
		recover | r)
			shift 1
			cli_recover $@
			;;
		install | i | update | up)
			install
			;;
		autorecover | ar)
			cli_autorecover
			;;
		*)
			print_error "Unknown argument $1, exit."
			;;
	esac
}

# vim: set filetype=sh ts=4 sw=4 noexpandtab:
