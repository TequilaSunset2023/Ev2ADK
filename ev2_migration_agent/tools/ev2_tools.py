import os
import re
import subprocess

ev2_target_folder_env_name = "EV2_TARGET_FOLDER"
servicegroup_prefix_env_name = "SERVICE_GROUP_PREFIX"
service_identifier_env_name = "SERVICE_IDENTIFIER"
service_display_name_env_name = "SERVICE_DISPLAY_NAME"

def get_params_from_bicep_content(bicep_content: str) -> list:
  """
  Extracts parameters from Bicep content.

  Args:
      bicep_content (str): The Bicep file content as a string.

  Returns:
      list: A list of dictionaries containing parameter information with keys: name, type, default_value, and line_no.
  """
  # Regex to extract param_name, param_type, and optional default_value
  re_param = re.compile(
    r"param\s+(?P<param_name>\w+)\s+(?P<param_type>\w+)(?:\s*=\s*(?P<default_value>[^#\n]+))?"
  )
  params = []
  param_matches = re_param.finditer(bicep_content)
  for match in param_matches:
    param_name = match.group("param_name")
    param_type = match.group("param_type")
    default_value = match.group("default_value") or ""
    line_number = bicep_content.count("\n", 0, match.start()) + 1
    params.append({
      "name": param_name,
      "type": param_type,
      "default_value": default_value,
      "line_no": line_number,
    })

  return params

def get_resources_from_bicep_content(bicep_content: str) -> list:
  """
  Extracts resources from Bicep content.

  Args:
      bicep_content (str): The Bicep file content as a string.

  Returns:
      list: A list of dictionaries containing resource information with keys: resource_name, resource_type, resource_api_version, line_no, and content.
  """
  # resource example: resource <resource_name> '<resource_type>@<resource_api_version>' = { <resource_properties> }
  re_resource = re.compile(
    r"resource\s+(?P<resource_name>[\w\d_]+)\s+'(?P<resource_type>[\w\.\/]+)@(?P<resource_api_version>[\d\.\-\w]+)'\s*=\s*{"
  )
  re_resource_close = re.compile(r"}\n\n")
  
  # find all resources = [{ resource_name, resource_type, resource_api_version, line_number }]
  # line_number = "<start_line>:<end_line>"
  resources = []
  resource_matches = re_resource.finditer(bicep_content)
  for match in resource_matches:
    resource_name = match.group("resource_name")
    resource_type = match.group("resource_type")
    resource_api_version = match.group("resource_api_version")
    start_line = bicep_content.count("\n", 0, match.start()) + 1
    end_match = re_resource_close.search(bicep_content, match.end())
    end_line = bicep_content.count("\n", 0, end_match.start()) + 1 if end_match else start_line
    content = bicep_content[match.start():end_match.end()] if end_match else bicep_content[match.start():]
    resources.append({
      "resource_name": resource_name,
      "resource_type": resource_type,
      "resource_api_version": resource_api_version,
      "line_no": f"{start_line}:{end_line}",
      "content": content.strip(),
    })

  return resources

def get_bicep_templates(
  workspace_root: str,
  start_row_number: int,
  end_row_number: int,
) -> str:
  """
  Gets content from Bicep template files within specified line range.

  Args:
      workspace_root (str): The root path of the workspace.
      start_row_number (int): The starting row number for the search.
      end_row_number (int): The ending row number for the search.

  Returns:
      str: The content from the specified line range, or empty string if no file found or error occurs.
  """
  ext = "main.bicep"
  bicep_file_path = ""
  for root, _, files in os.walk(workspace_root):
    for file in files:
      if file.endswith(ext):
        bicep_file_path = os.path.join(root, file)
        break
    if bicep_file_path:
      break
  
  if not bicep_file_path:
    return ""
  
  # Read the file and extract the specified line range
  try:
    with open(bicep_file_path, "r", encoding="utf-8") as file:
      lines = file.readlines()
    
    # Convert to 0-based indexing and validate range
    start_idx = max(0, start_row_number - 1)
    end_idx = min(len(lines), end_row_number)
    
    if start_idx >= len(lines) or start_idx >= end_idx:
      return ""
    
    # Extract the specified line range
    selected_lines = lines[start_idx:end_idx]
    return "".join(selected_lines)
    
  except Exception as e:
    return f"Error reading file: {str(e)}"

def get_bicep_digest(
  bicep_file_path: str,
) -> dict:
  """
  Gets the digest of a Bicep file.

  Args:
      bicep_file_path (str): The path to the Bicep file.

  Returns:
      dict: A dictionary containing bicep_file_path, params, resources, params_count, and resources_count.
  """
  # param example: param <param_name> <param_type>[=<default_value>]

  # Read the Bicep file
  with open(bicep_file_path, "r") as file:
    bicep_content = file.read()

  params = get_params_from_bicep_content(bicep_content)

  resources = get_resources_from_bicep_content(bicep_content)

  # extrat parent and name from resource, resource -> {... name, parant}
  for resource in resources:
    # find in content the resource name and parent
    content = resource["content"]
    name_match = re.search(r"name\s*:\s*'([^']+)'", content)
    parent_match = re.search(r"parent\s*:\s*'([^']+)'", content)
    resource["name"] = name_match.group(1) if name_match else ""
    resource["parent"] = parent_match.group(1) if parent_match else ""

  # remove content from resource
  for resource in resources:
    resource.pop("content", None)

  return dict(
    bicep_file_path=bicep_file_path,
    params=params,
    resources=resources,
    params_count=len(params),
    resources_count=len(resources),
  )

def get_ev2_migration_settings() -> str:
  """
  Retrieves EV2 migration settings from environment variables.

  Returns:
      dict: A dictionary containing ev2_target_folder, servicegroup_prefix, service_identifier, and service_display_name.

  Raises:
      ValueError: If any required environment variable is not set or target folder doesn't exist.
  """
  ev2_target_folder = os.getenv(ev2_target_folder_env_name, "")
  if not ev2_target_folder:
    raise ValueError(f"Environment variable '{ev2_target_folder_env_name}' is not set.")
  
  if not os.path.exists(ev2_target_folder):
    raise ValueError(f"Target folder '{ev2_target_folder}' does not exist.")

  servicegroup_prefix = os.getenv(servicegroup_prefix_env_name, "")
  if not servicegroup_prefix:
    raise ValueError(f"Environment variable '{servicegroup_prefix_env_name}' is not set.")
  
  serviceid = os.getenv(service_identifier_env_name, "")
  if not serviceid:
    raise ValueError(f"Environment variable '{service_identifier_env_name}' is not set.")
  
  servicedisplayname = os.getenv(service_display_name_env_name, "")
  if not servicedisplayname:
    raise ValueError(f"Environment variable '{service_display_name_env_name}' is not set.")
  
  return dict(
    ev2_target_folder=ev2_target_folder,
    servicegroup_prefix=servicegroup_prefix,
    service_identifier=serviceid,
    service_display_name=servicedisplayname,
  )

def build_bicep_to_arm(
  bicep_file: str,
  template_file: str,
) -> dict:
  """
  Executes az bicep build command to convert Bicep to ARM template and captures console logs.

  Args:
      bicep_file (str): The path to the Bicep file to build.
      template_file (str): The output path for the ARM template file.

  Returns:
      dict: Dictionary containing execution results, logs, and status with keys: success, return_code, command, stdout, stderr, bicep_file, template_file, template_created, and console_logs.
  """
  command = f"az bicep build --file \"{bicep_file}\" --outfile \"{template_file}\""
  
  try:
    # Execute the command and capture output
    result = subprocess.run(
      command,
      shell=True,
      capture_output=True,
      text=True,
      timeout=300  # 5 minutes timeout
    )
    
    # Prepare response
    response = {
      "success": result.returncode == 0,
      "return_code": result.returncode,
      "command": command,
      "stdout": result.stdout.strip() if result.stdout else "",
      "stderr": result.stderr.strip() if result.stderr else "",
      "bicep_file": bicep_file,
      "template_file": template_file,
    }
    
    # Check if output file was created
    if result.returncode == 0:
      response["template_created"] = os.path.exists(template_file)
    else:
      response["template_created"] = False
      
    # Combine all console logs
    all_logs = []
    if result.stdout:
      all_logs.append(f"STDOUT:\n{result.stdout}")
    if result.stderr:
      all_logs.append(f"STDERR:\n{result.stderr}")
    
    response["console_logs"] = "\n".join(all_logs) if all_logs else "No console output"
    
    return response
    
  except subprocess.TimeoutExpired:
    return {
      "success": False,
      "return_code": -1,
      "command": command,
      "error": "Command timed out after 5 minutes",
      "console_logs": "Command execution timed out",
      "bicep_file": bicep_file,
      "template_file": template_file,
      "template_created": False,
    }
    
  except Exception as e:
    return {
      "success": False,
      "return_code": -1,
      "command": command,
      "error": str(e),
      "console_logs": f"Error executing command: {str(e)}",
      "bicep_file": bicep_file,
      "template_file": template_file,
      "template_created": False,
    }
