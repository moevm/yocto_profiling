import argparse
import sys
import json
import subprocess

from subprocess import CalledProcessError
from typing import Optional
from pathlib import Path


def validate_path(poky_path: Optional[str], dir_path: Optional[str], patches_filename: str) -> tuple[Path, Path]:
	if poky_path is None:
		raise ValueError("[Error] The poky path was not received. Use --poky-path to pass this value.")
	if dir_path is None:
		raise ValueError("[Error] The path was not received. Use --dir-path to pass this value.")
	if not ".json" in patches_filename:
		raise ValueError("[Error] Json file was expected.")
	
	poky_dir = Path(poky_path)
	patches_dir = Path(dir_path)
	patches_file = patches_dir / patches_filename
	
	if not (poky_dir.exists() and poky_dir.is_dir()):
		raise ValueError(f"[Error] This directory does not exist, or the path does not point to a directory: {poky_dir}")
	if not (patches_dir.exists() and patches_dir.is_dir()):
		raise ValueError(f"[Error] This directory does not exist, or the path does not point to a directory: {dir_path}")
	if not patches_file.exists():
		raise ValueError(f"[Error] This file does not exist: {str(patches_file)}")
	return poky_dir, patches_dir, patches_file


def applying(patches: list[tuple[str, str, str]], patches_dir: Path, poky_dir: Path, reverse: bool) -> None:
    flag = "-N"
    if reverse:
        flag = "-R"

    for patch_tuple in patches:
        patch, path, file_to = patch_tuple
        
        cwd = f"{poky_dir}{path}"
        cmd = [
            "patch",
            flag,
            "-p1"
        ]
        if file_to:
            cmd.append(file_to)
        cmd.extend(["-i", f"{patches_dir}/{patch}"])
        print(f"WORKDIR: {cwd}")
        print(f"RUN: {' '.join(cmd)}")

        try:
            result = subprocess.run(cmd, cwd=cwd, check=True, encoding='utf-8')
        except subprocess.CalledProcessError as e:
            print(f"\nApplying was failed, patch: {patch}. Carefully check the list of patches to apply, maybe some of them are trying to change the same file.")
            raise e


def verify_applying(patches: list[tuple[str, str, str]], patches_dir: Path, poky_dir: Path, reverse: bool) -> None:
    for patch_tuple in patches:
        patch, path, _ = patch_tuple
        
        cwd = f"{poky_dir}{path}"
        cmd = [
            "git",
            "apply",
            "--check"
        ]
        if reverse:
            cmd.append("-R")
        cmd.append(f"{patches_dir}/{patch}")
        print(f"WORKDIR: {cwd}")
        print(f"RUN: {' '.join(cmd)}")
        
        try:
            result = subprocess.run(cmd, cwd=cwd, check=True, encoding='utf-8')
        except subprocess.CalledProcessError as e:
            print(f"\nVerifying was failed, patch: {patch}")
            raise e


def get_patches(args, patches_file: Path) -> Optional[list[tuple[str, str, str]]]:
    with open(str(patches_file), 'r') as f:
        patches_data = json.load(f)
    assert isinstance(patches_data, dict)
	
    if args.patches_list:
        print("Available patches:\n\t" + '\n\t'.join(list(patches_data.keys())))
        return

    patches = args.patches
    print(f"Received patches: {patches}")
    if not patches:
        print("Nothing to patch!")
        return
	
    patches_to_apply = []
    for patch in patches:
        if not patch in patches_data:
            print(f"[WARNING] No such patch was found in available list: {patch}")
            continue
        patches_to_apply.append((patch, patches_data[patch]["path"], patches_data[patch]["file"]))

    return patches_to_apply


if __name__ == "__main__":
	parser = argparse.ArgumentParser()
	parser.add_argument('--poky-path', dest="poky_path", type=str, default=None)
	parser.add_argument('--dir-path', dest="dir_path", type=str, default=None)
	parser.add_argument('--patches-filename', dest="patches_filename", type=str, default="patches.json")
	parser.add_argument('-p', '--patch', dest="patches", nargs='*', help="Patches to be applied")
	parser.add_argument('-l', '--patches-list', dest="patches_list", action="store_true", help="Print list of available patches")
	parser.add_argument('-r', '--reverse', dest="reverse", action="store_true", help="Reverse received patches if they are already applied")
	args, unknown = parser.parse_known_args()
	args.patches.extend(unknown)

	poky_dir, patches_dir, patches_file = validate_path(args.poky_path, args.dir_path, args.patches_filename)
	print("VALIDATING PATHS: successfully passed!\n")
	patches = get_patches(args, patches_file)
	
	if not patches:
		sys.exit(0)
	
	verify_applying(patches, patches_dir, poky_dir, args.reverse)
	print("VERIFYING PATCHES: successfully passed!\n")
	
	applying(patches, patches_dir, poky_dir, args.reverse)
	print("APPLYING PATCHES: successfully passed!")

