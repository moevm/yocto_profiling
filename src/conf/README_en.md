## Configs
**YOU MUST PASS THE CONFIG TO THE SCRIPT BEFORE EACH RUN**
- `default.conf` – the base config that will be used if you don’t explicitly set another config.
- `original.conf` – the config for the updated build (with all layers); it will be used by default unless the `--no-layers` flag is set.
- `experiment.conf` – the config used as a template for creating an experiment-specific config.

> If you need to run a scenario not covered by the predefined options, you can provide a custom config path using the `--conf-file <path>` option.
