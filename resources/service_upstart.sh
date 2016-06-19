# == Name
#
# service.upstart
#
# === Description
#
# Manages upstart services
#
# === Parameters
#
# * state: The state of the service. Required. Default: running.
# * name: The name of the service. Required.
#
# === Example
#
# ```shell
# service.upstart --name memcached
# ```
#
service.upstart() {
  # Declare the resource
  waffles_resource="service.upstart"

  # Resource Options
  local -A options
  waffles.options.create_option state "running"
  waffles.options.create_option name  "__required__"
  waffles.options.parse_options "$@"
  if [[ $? != 0 ]]; then
    return $?
  fi


  # Process the resource
  waffles.resource.process $waffles_resource "${options[name]}"
}

service.upstart.read() {
  if [[ ! -f "/etc/init/${options[name]}.conf" ]]; then
    log.error "/etc/init/${options[name]}.conf does not exist."
    waffles_resource_current_state="error"
    return
  else
    local _status=$(status ${options[name]})
    if [[ $_status =~ "stop" ]]; then
      waffles_resource_current_state="stopped"
      return
    fi
  fi

  waffles_resource_current_state="running"
}

service.upstart.create() {
  exec.capture_error start ${options[name]}
}

service.upstart.update() {
  exec.capture_error restart ${options[name]}
}

service.upstart.delete() {
  exec.capture_error stop ${options[name]}
}
