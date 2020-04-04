#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

filename=$0

usage() {
cat << USAGE
  Usage: 
  ${filename} -c <chart_name> [-dir <directory>] [-n <namespace>] [-o <override>] [--force] [--debug] [--dry-run]

  Required Args:
    -c <chart_name>, --chart-name <chart_name>
        The name of the helm chart. This will be the name of the helm chart release.

  Optional Args:
    -dir <directory>, --dir <directory> (default "")
        The directory the chart resides in (e.g. path/to/dir). This is not the chart name.

    -n <namespace>, --namespace <namespace> (default "default")
        The kubernetes namespace in which to deploy the chart.

    -o <override>, --override <override> (default "")
	Helm chart options overrides. This can be variables set (e.g. "--set foo.bar=baz"), or passing values
	files  (e.g. "-f override-values.yaml"). Can be used multiple times.

    -f, --force
	Disables --atomic flag in deploy_chart() which is set by default. --atomic ensures the deployed chart is running properly
        (i.e the livenessProbe passes), else it will roll back the deployment.
    
    --debug
        Enables debug mode. Does not perform a dry-run. Disabled by default.

    --dry-run
        Performs a dry run. Best used with --debug. Disabled by default.

  Examples:
    ./deploy-chart.sh -c model-builder --debug --dry-run

    ./deploy-chart.sh -c model-builder --dir /path/to/charts --debug
    
    ./deploy-chart.sh -c model-builder -n asserts --force

    ./deploy-chart.sh -c fluentd -n monitoring -o "--set image.tag=v1.0" -o "-f myvalues.yaml"
USAGE
  exit  
}

die() {
    echo "ERROR: ${1}" >&2
    usage
    exit 1
}

# upgrade chart, else install if it does not exist.
# set revision history limit to 20 in order to limit the number of objects kubernetes manages for the chart
# atomic flag will roll back the deployment if it fails
# wait will wait until the deployment is up and running healthy
deploy_chart() {
  local atomic
  local command

  if [ "${force}" = true ]; then
    atomic=""
  else
    atomic="--atomic"
  fi
  
  command="helm upgrade --install ${chart_name} ${directory}${chart_name} --namespace ${namespace} --history-max 20 --wait ${atomic} ${override} ${debug} ${dry_run}"
  echo "Running: ${command}"
  eval ${command}
}

# initialize/defaults
chart_name=""
directory=""
namespace="default"
override=""
force=false
debug=""
dry_run=""

while [ $# -gt 0 ];
do
  case $1 in
    -h|-\?|--help)
      usage
      ;;

    # helm chart name (required).
    -c|--chart-name)
      chart_name=$2
      shift
      ;;

    # directory chart resides (default to current working dir)
    -dir|--dir)
      directory="${2}/"
      if [ ! -d $directory ];
      then
        die "directory ${directory} does not exist."
      else
        shift
      fi
      ;;

    # namespace to run in, context will be set here (default to default namespace)
    -n|--namespace)
      namespace=$2
      kubectl config set-context --current --namespace=$namespace
      shift
      ;;

    # helm chart option override
    -o|--override)
      override="${override} ${2}"
      shift 
      ;;

    # debug chart / high verbosity (does not dry-run)
    -f|--force)
      force=true
      ;;
    
    # debug chart / high verbosity (does not dry-run)
    --debug)
      debug="--debug"
      ;;

    # dry-run
    --dry-run)
      dry_run="--dry-run"
      ;;

    # Invalid option
    \?)
      die "invalid option $2"
      ;;
    
    # default case, break
    *)
      break
  esac
  shift
done

if [ -n "${chart_name}" ]; then
  deploy_chart
else
  die "-c chart_name required."
fi
