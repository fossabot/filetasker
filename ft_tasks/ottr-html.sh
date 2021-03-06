#!/bin/bash
# -----------
# FileTasker Task for OTTR Debug
# -----------
# CMDLine Inputs: NIL
# -----------
# First run: symlink files from old location and old name to new location and new name
# Upon new storage, unlink old names, move & rename files to new location.
#
# -----------
# Filename Inputs:
# -----------
# Filename Outputs:
# -----------
# End Program Information
# -----------

# -----------
# Variables
# -----------

# -----------
# Arrays
# -----------
task_subtasks=( debug link copy move )

# -----------
# Strings
# -----------
task_name="ottr-html"

# Look for files of type...
file_ext=".html"

file_name_prefix="ottr."

# filename segments are seperated by...
#parse_seperator="."
# Defaults to "."

# For tasks with files in multiple directories.
ft_multidir=1

# Turn on output compression for this task
ft_output_compression="gzip"

# Gzip prompts by default if we don't force compression.
compress_flags="-9f"

# -----------
# Paths
# -----------

# Source files are here
source_base_path="${source_path_prefix}weather/ottr/"
source_path="${source_base_path}"
# Target files are here
target_base_path="${target_path_prefix}data/ottr/"
target_path="${target_base_path}"

# -----------
# End Variables
# -----------

# Parses ottr dates from 20090402 to Epoch
parse_to_epoch_from_date_ottr()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  local file_datestamp=${1}
  file_epoch=`date +%s -d "${file_datestamp:0:4}-${file_datestamp:4:2}-${file_datestamp:6:2} UTC"`
  file_timestamp=`date -u -d @${file_epoch}`
  message_output ${MSG_INFO} " Parsed Filedate: ${file_datestamp} - Date: ${file_datestamp:0:4}-${file_datestamp:4:2}-${file_datestamp:6:2} UTC - Epoch: @${file_epoch} or ${file_timestamp}"
}

# -----------
# Main Task
# -----------
task_pre()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  match_take_snapshot ${file_name}; # Take a snapshot of the file
  # Set the right dated source path
  if [[ "$ft_multidir" -eq "1" ]]; then source_path="${source_base_path}${dir_name}/"; fi
  # Parse the dated pathname into $ar_path_name
  parse_pathname ${dir_name};
  # Parse the filename into an array
  parse_filename ${file_name};
  # Check for precompressed files
  if [[ "${ar_file_name[@]:(-1):1}" == "gz" ]]; then 
    date_ottr=${ar_file_name[@]:(-4):1}; # Take the 3rd to last element
  else 
    date_ottr=${ar_file_name[@]:(-3):1}; # Take the 2nd to last element
  fi
  # Get the date from the filename element
  parse_to_epoch_from_date_ottr ${date_ottr};
  return 0; # Success
}

task()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi

  make_line_header "OTTR Working on ${1}";
  
  local my_file_name=${file_name};
  task_pre ${my_file_name};

  # Build the filename from ar_file_name
  build_filename;

  task_post;
  # End of Task
  return 0; # Success
}

task_post()
{
  if [[ -e "${script_path}/ft_config/ft_config_tracing.on" ]]; then
  message_output ${MSG_TRACE} "FuncDebug:" `basename ${BASH_SOURCE}` "now executing:" ${FUNCNAME[@]} "with ${#@} params:" ${@}; fi
  if match_check_snapshot ${file_name}; then :; else return ${E_MISMATCH}; fi # Bail out early

  # Dated Directory needs to be generated from the timestamp.
  generate_yyyy_mm_dd_date_dir_from_epoch ${file_epoch};
  # Set the right dated target path (date_dir has trailing /)
  target_path="${target_path}${date_dir}";
  # Perform the file operation (takes care of all paths for us)
  perform_fileop ${selected_subtask} ${orig_file_name} ${new_file_name};
  # Set the original source & target path
  source_path="${source_base_path}";
  target_path="${target_base_path}";

  return 0; # Success
}
# -----------
# End Main Task
# -----------

# -----------
# Main Program
# -----------

# Output Loader information
my_name=`basename ${BASH_SOURCE}` # What's this script's name?
parent_script=`basename ${0}` # Who called me?
if [[ "${parent_script}" == "${my_name}" ]]
then
    echo "   Supported Subtasks in ${my_name}: ${task_subtasks[@]}";
else
    echo "   FileTasker OTTR Operations Module Loaded at ${SECONDS} seconds.";
fi

# -----------
# End Main Program
# -----------
