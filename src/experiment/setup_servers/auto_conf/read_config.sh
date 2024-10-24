function process_config() {

    if [ ! -f "$1" ]; then
    echo "Error: File $1 not found."
    exit 1
    fi    

    # Чтобы работать с одним файлом и в python и в bash сделаем костыль - временный файл, в котором преведен python синтаксис конфиг файлам к bash конфиг файлам
    cp "$1" temp_config.sh

    sed -i '/^\[.*\]$/d' temp_config.sh
    sed -i '/^#.*$/d' temp_config.sh
    sed -i '/^$/d' temp_config.sh
    sed -i 's/ *= */=/g' temp_config.sh

    source temp_config.sh
    rm temp_config.sh
}

# Экспортируем функцию
export -f process_config
