import argparse as _argparse
from typing import Optional as _Optional
import sys as _sys
import json as _json
from pathlib import Path as _Path


def _validate_path(poky_path: _Optional[str], dir_path: _Optional[str], patches_filename: str) -> tuple[_Path, _Path]:
	if poky_path is None:
		raise ValueError("Error: The poky path was not received. Use --poky-path to pass this value.")
	if dir_path is None:
		raise ValueError("Error: The path was not received. Use --dir-path to pass this value.")
	if not ".json" in patches_filename:
		raise ValueError("Error: Json file was expected.")
	
	poky_dir = _Path(poky_path)
	patches_dir = _Path(dir_path)
	patches_file = patches_dir / patches_filename
	
	if not poky_dir.exists() and poky_dir.isdir():
		raise ValueError(f"Error: This directory does not exist, or the path does not point to a directory: {poky_dir}")
	if not patches_dir.exists() and patches_dir.isdir():
		raise ValueError(f"Error: This directory does not exist, or the path does not point to a directory: {dir_path}")
	if not patches_file.exists():
		raise ValueError(f"Error: This file does not exist: {str(patches_file)})
	return poky_dir, patches_dir, patches_file


def patching(args) -> _Optional[list[tuple[str, str, str]]]:
	poky_path = args.poky_path
	dir_path = args.dir_path
	patches_filename = args.patches_filename
	patches = args.patches
		
	poky_dir, patches_dir, patches_file = _validate_path(poky_path, dir_path, patches_filename)
	
	if not patches:
		return
	
	with open(str(patches_file), 'r') as f:
		patches_data = json.load(f)
	assert isinstance(patches_data, dict)
	
	patches_to_apply = []
	for patch, data in patches.items():
		if not patch in patches_data:
			print(f"Error: No such patch was found in available list: {patch}")
			continue
		patches_to_apply.append((patch, data["path"], data["file"]))
	
	return patches_to_apply


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument('--poky-path', dest="poky_path", type=str, default=None)
	parser.add_argument('--dir-path', dest="dir_path", type=str, default=None)
	parser.add_argument('--patches-filename', dest="patches_filename", type=str, default="patches.json")
	parser.add_argument('--patch', dest="patches", action='append', type=str, default=None)

	args = parser.parse_args()
	patches = patching(args)
	
	if patches is None:
		print("Nothing to patch!")
		sys.exit(0)
		
	# TODO MOVE PATCH TO HIS PATH LIKE .../poky/bitbake/lib/bb/
	# TODO APPLY PATCH: patch -p1 file < file.patch

	
