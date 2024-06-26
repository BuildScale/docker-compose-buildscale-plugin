#!/bin/bash

# Check agent meta-data exists
function plugin_check_metadata_exists() {
  buildscale-agent meta-data exists "$1"
}

# Read agent metadata for the plugin
function plugin_get_metadata() {
  local key="docker-compose-plugin-$1"
  if plugin_check_metadata_exists "$key"; then
    plugin_prompt buildscale-agent meta-data get "$key"
    buildscale-agent meta-data get "$key"
  else
	exit 1
  fi
}

# Write agent metadata for the plugin
function plugin_set_metadata() {
  local key="docker-compose-plugin-$1"
  local value="$2"
  plugin_prompt_and_must_run buildscale-agent meta-data set "$key" "$value"
}

# The service name, and the docker-compose config files, are the uniqueness key
# for the pre-built image meta-data tag
function prebuilt_image_meta_data_key() {
  local service="$1"
  local config_key=""

  for file in $(docker_compose_config_files) ; do
    config_key+="-$file"
  done

  # If they just use the default config, we use the old-style (non-suffixed)
  # style key
  if [[ "$config_key" == "-docker-compose.yml" ]]; then
    echo "built-image-tag-$service"
  else
    echo "built-image-tag-$service$config_key"
  fi
}

# Sets a prebuilt image for a service name
function set_prebuilt_image() {
  local service="$1"
  local image="$2"
  plugin_set_metadata "$(prebuilt_image_meta_data_key "$service")" "$image"
}

# Gets a prebuilt image for a service name
function get_prebuilt_image() {
  local service="$1"
  plugin_get_metadata "$(prebuilt_image_meta_data_key "$service")"
}
