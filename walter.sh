#!bin/bash
THEME_DIR="./themes"
WORK_DIR="."
FULL_PATH=$WORK_DIR
DEPENDANCIES=('devilspie' 'xdotool', 'chromium-browser')
DEBUG=false
INDEX_HTML_PATH="file://${PWD}/index.html"
chromium_windows=$(xdotool search --onlyvisible --class chromium | wc -l)

function show_banner {
	clear
	echo "
-------------------------------------------------------------
- Stellae                                                   -
-------------------------------------------------------------
"
}

function is_devilspie_conf_applyed {
	echo '(if(is (window_class) "Chromium")(begin(set_workspace 1)(below)(undecorate)(skip_pager)(skip_tasklist)(wintype "utility")(geometry "2560x1440")(maximize)(fullscreen)))' | tee $WORK_DIR/temp_devilspie.ds &>/dev/null
	mkdir ~/.devilspie &>/dev/null
	yes | cp -rf $WORK_DIR/temp_devilspie.ds ~/.devilspie/DesktopStellae.ds
}

function is_package_installed {
	for index in ${!DEPENDANCIES[@]}; do
		if [ "$DEBUG" = true ]; then echo "$index - Check if installed : ${DEPENDANCIES[$index]}"; fi
		if [ $(dpkg-query -W -f='${Status}' ${DEPENDANCIES[$index]} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
			if [ "$DEBUG" = true ]; then echo "Error ${DEPENDANCIES[$index]} is not installed"; fi
			return 1
		fi
	done
	if [ "$DEBUG" = true ]; then echo "All package are already installed [ OK ]"; fi
}

# start function for chromium and background function
function start_chromium {
	if [[ $(pgrep -cl devilspie) -ge 1 ]]; then
		if [ "$DEBUG" = true ]; then echo 'An devilspie instance for stellae is already running. Try to kill it.'; fi
		pkill devilspie
	else
		if [ $chromium_windows -eq 0 ]; then
			chromium &>/dev/null &
		fi
		if [ "$DEBUG" = true ]; then echo "Devilspie isn't running we launch it"; fi
		$FULL_PATH &>/dev/null &
		if [ "$DEBUG" = true ]; then echo 'Waiting for chromium'; fi
		echo 'Launching Stellae Wallpaper'
		devilspie &>/dev/null &
		sleep 0.5
		pkill devilspie
		if [ "$DEBUG" = true ]; then echo 'Refresh Chromium'; fi
		key='ctrl+l'
		interact_chromium
		xdotool search --onlyvisible --class chromium type 'https://www.youtube.com/watch?v=BucWqUtIVEc'
		key='Return'
		interact_chromium
		sleep 1
		key='f'
		interact_chromium
	fi
}

# Interact with chromium via xdotool
function interact_chromium {
	xdotool search --onlyvisible --class chromium windowactivate key $key
}

# fetch all preset on $THEME_DIR (default ./themes")
function fetch_preset {
	i=0
	while read line; do
		array[$i]="$line"
		((i++))
	done < <(ls $THEME_DIR/)
}

# show all preset to the user
function show_preset {
	show_banner
	fetch_preset
	if [ "$DEBUG" = true ]; then echo "Number of directory detected : ${#array[@]}"; fi
	echo "Number of preset available :"
	for index in ${!array[@]}; do
		echo "$index - ${array[$index]}"
	done
	set_preset
}

function set_preset {
	echo "Choose your preset >"
	read choice
	echo "Choice - ${array[$choice]}"
	# Concatenate path
	FILE_PATH=$(echo "$FILE_PATH" | sed 's/ /\\ /g')
	# Copy the file
	echo $path
	yes | cp -rfv "$THEME_DIR/${array[$choice]}/"* $FULL_PATH
	# Refresh chromium
	key='ctrl+r'
	interact_chromium && echo "Applying preset : [ OK ]"
}

function show_help {
	show_banner
	echo "Type '${0} start'	for run Stellae Wallpaper
Type '${0} stop'	for stop Stellae Wallpaper
Type '${0} preset	for a detailled config menu
Type '${0} help	show this help
"
}

### main		-----------------------------------------------------------------
is_devilspie_conf_applyed
is_package_installed
case "$1" in
start)
	echo "Chromium start"
	start_chromium
	;;
stop)
	echo "Chromium stop"
	key='alt+F4'
	interact_chromium
	;;
preset)
	if [ "$DEBUG" = true ]; then echo "Preset Selection"; fi
	show_preset
	;;
help)
	show_help
	;;
*)
	echo "Type ${0} help for more information"
	;;
esac
