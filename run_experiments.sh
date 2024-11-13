#!/bin/bash

show_help() {
    echo "Usage: $0 <experiment_name> [options]"
    echo
    echo "Options:"
    echo "  -h, --help    Show this help message and exit"
    echo "  -c, --confirm  set if you are sure that you have configured the config file for main experiment"

    echo
    echo

    echo "There are two implemented experiments: "
    echo "   1. Main experiment. Name -- main"
    echo "       Usage: ./run_experiments.sh main" 
    echo "   2. Experiment with filtering non-working servers. Name -- filters"
    echo "       Usage: ./run_experiments.sh filters" 

    exit 0
}

PATH_TO_MAIN_EXP=./src/experiment
PATH_TO_FILTERS_EXP=./src/experiment_2

if [ "$#" -lt 1 ]; then
    echo "Error: Experiment name is required."
    show_help
fi

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            ;;
        -c|--confirm)
            FLAG=true
            shift
            ;;
        *)
            if [ -z "$EXPERIMENT_NAME" ]; then
                EXPERIMENT_NAME=$1
            else
                echo "Error: Unknown argument '$1'"
                show_help
            fi
            shift
            ;;
    esac
done

if [ -z "$EXPERIMENT_NAME" ]; then
    echo "Error: Experiment name is required."
    show_help
fi


if [ "$FLAG" == true ]; then
    echo "Using flag of confirm config"
else
    echo "Flag is not set to confirm config"
    echo

    if [ "$EXPERIMENT_NAME" == "main" ]; then
        echo "To start main experiment you need to fill out the confiпg located in <paste_config_path>"
        echo "  After filling out the config, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh main -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh main --confirm"
        exit 1
    fi 

    if [ "$EXPERIMENT_NAME" == "filters" ]; then
        echo "To start filters experiment you need to fill out the confiпg located in <paste_config_path>"
        echo "  After filling out the config, run this script via --confirm flag"
        echo "    Usage: ./run_experiments.sh filters -c"
        echo "  or"
        echo "    Usage: ./run_experiments.sh filters --confirm"
        exit 1
    fi 

fi


# At this stage, the user has specified the name of the experiment and confirmed that they have filled out the config

if [ "$EXPERIMENT_NAME" == "main" ]; then
    cd $PATH_TO_MAIN_EXP
    echo "starting"
    # here gotta be start of main experiment
    exit 0
fi 

 if [ "$EXPERIMENT_NAME" == "filters" ]; then
    cd $PATH_TO_FILTERS_EXP
    echo "starting"
    # here gotta be start of filters experiment
    exit 0
fi 

