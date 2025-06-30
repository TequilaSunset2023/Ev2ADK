import os
import re
from typing import Annotated

ev2_target_folder_env_name = "EV2_TARGET_FOLDER"
servicegroup_prefix_env_name = "SERVICE_GROUP_PREFIX"
service_identifier_env_name = "SERVICE_IDENTIFIER"
service_display_name_env_name = "SERVICE_DISPLAY_NAME"

def get_params_from_bicep_content(bicep_content: str) -> list:
  """
  Extract parameters from Bicep content.
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
  Extract resources from Bicep content.
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
  workspace_root: Annotated[str, "The root path of the workspace"],
) -> dict:
  """
  Get Bicep template file paths inside the workspace.
  """
  ext = ".bicep"
  bicep_files = []
  for root, _, files in os.walk(workspace_root):
    for file in files:
      if file.endswith(ext):
        bicep_files.append(os.path.join(root, file))
  
  return dict(
    bicep_files=bicep_files,
    bicep_files_count=len(bicep_files),
  )

def get_bicep_digest(
  bicep_file_path: Annotated[str, "The path to the Bicep file"],
) -> dict:
  """
  Get the digest of a Bicep file.
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

def get_ev2_migration_target_folder() -> str:
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