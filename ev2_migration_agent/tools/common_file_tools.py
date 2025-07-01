import os
import re
from typing import Annotated
import subprocess


def read_file(file_path: str) -> str:
    """
    Read the contents of a file and return as a string.
    
    Args:
        file_path (str): Path to the file to read
        
    Returns:
        str: Contents of the file
        
    Raises:
        FileNotFoundError: If the file doesn't exist
        IOError: If there's an error reading the file
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as file:
            return file.read()
    except FileNotFoundError:
        raise FileNotFoundError(f"File not found: {file_path}")
    except Exception as e:
        raise IOError(f"Error reading file {file_path}: {str(e)}")
    



def update_file(file_path: str, content: str, backup: bool = True) -> bool:
    """
    Update a file with new content.
    
    Args:
        file_path (str): Path to the file to update
        content (str): New content to write to the file
        backup (bool): Whether to create a backup of the original file (default: True)
        
    Returns:
        bool: True if the file was updated successfully
        
    Raises:
        IOError: If there's an error writing to the file
    """
    try:
        # Create backup if requested
        if backup and os.path.exists(file_path):
            backup_path = f"{file_path}.backup"
            with open(file_path, 'r', encoding='utf-8') as original:
                with open(backup_path, 'w', encoding='utf-8') as backup_file:
                    backup_file.write(original.read())
        
        # Create directory if it doesn't exist
        os.makedirs(os.path.dirname(file_path), exist_ok=True)
        
        # Write new content
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(content)
            
        return True
    except Exception as e:
        raise IOError(f"Error updating file {file_path}: {str(e)}")


def list_directory_contents(directory_path: str, recursive: bool = False) -> dict:
    """
    List all files and folders in a directory.
    
    Args:
        directory_path (str): Path to the directory to list
        recursive (bool): Whether to list contents recursively (default: False)
        
    Returns:
        dict: Dictionary containing 'files' and 'folders' lists
        
    Raises:
        FileNotFoundError: If the directory doesn't exist
        IOError: If there's an error accessing the directory
    """
    try:
        if not os.path.exists(directory_path):
            raise FileNotFoundError(f"Directory not found: {directory_path}")
        
        if not os.path.isdir(directory_path):
            raise IOError(f"Path is not a directory: {directory_path}")
        
        files = []
        folders = []
        
        if recursive:
            for root, dirs, filenames in os.walk(directory_path):
                # Add folders
                for dirname in dirs:
                    folder_path = os.path.join(root, dirname)
                    relative_path = os.path.relpath(folder_path, directory_path)
                    folders.append(relative_path)
                
                # Add files
                for filename in filenames:
                    file_path = os.path.join(root, filename)
                    relative_path = os.path.relpath(file_path, directory_path)
                    files.append(relative_path)
        else:
            for item in os.listdir(directory_path):
                item_path = os.path.join(directory_path, item)
                if os.path.isfile(item_path):
                    files.append(item)
                elif os.path.isdir(item_path):
                    folders.append(item)
        
        return {
            'files': sorted(files),
            'folders': sorted(folders)
        }
    except FileNotFoundError:
        raise
    except Exception as e:
        raise IOError(f"Error listing directory contents {directory_path}: {str(e)}")













