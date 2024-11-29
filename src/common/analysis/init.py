from pathlib import Path
import sys

repo_path = Path(__file__).parent.absolute()
while repo_path.name != "os_profiling":
    repo_path = repo_path.parent

    if (repo_path == repo_path.home()) or (str(repo_path) == repo_path.anchor) or (str(repo_path) == repo_path.root):
        raise OSError(f"Unexpected path for {__file__}, it will be inside \"os_profiling\" repo")

sys.path.append(str(repo_path / "tests"))

from results.graph_tests import GraphTest
from results.ranking_tests import RankingTest