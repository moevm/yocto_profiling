function process_config() {

    if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
    fi    

    # To work with a single file in both Python and Bash, we'll make a workaround — a temporary file where Python syntax config files are converted to Bash config files
    cp "$1" temp_config.sh

    sed -i '/^\[.*\]$/d' temp_config.sh
    sed -i '/^#.*$/d' temp_config.sh
    sed -i '/^$/d' temp_config.sh
    sed -i 's/ *= */=/g' temp_config.sh

    source temp_config.sh
    rm temp_config.sh
}

# Export the function
export -f process_config
