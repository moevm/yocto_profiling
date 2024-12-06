from pathlib import Path
import sys

repo_path = Path(__file__).parent.absolute()
while repo_path.name != "os_profiling":
    repo_path = repo_path.parent

    if (repo_path == repo_path.home()) or (str(repo_path) == repo_path.anchor) or (str(repo_path) == repo_path.root):
        raise OSError(f"Unexpected path for {__file__}, it will be inside \"os_profiling\" repo")

sys.path.append(str(repo_path / "src" / "common"))

from analysis.dep_graph.src.analyze_graph import analyze_graph
from analysis.statistics_analyzer.src.ranking import ranking_task_info
