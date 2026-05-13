# inventory_app

A new Flutter project.

## Getting Started
1. View 'dart-defines/app_config_sample.json' file to get correct format. Must use publict domain for Base URL API (you can use NgRok or Cloudfare tunnel).
2. Add config file to environment folder: 'dart-defines/dev/app_config.json' for debug and 'dart-defines/release/app_config.json' for release.
3. Run flutter app with '--dart-define-from-file=dart-defines/*/app_config.json' or use VS Code 'Run and Debug' configuration to run with selected environment.