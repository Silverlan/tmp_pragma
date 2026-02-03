from scripts.shared import *

def main():
	build_config_tp = config.build_config_tp
	deps_dir = config.deps_dir
	generator = config.generator
    build_tools_dir = config.build_tools_dir
	chdir_mkdir(build_tools_dir)
	
	# Download
	os.chdir(build_tools_dir)
	commit_sha = "7d5ebf5705ba31baed06f768ccd9d3030300b42b" # v1.2
	nocache_root = os.getcwd() +"/nocache"
	if not check_repository_commit(nocache_root, commit_sha, "nocache"): 
		if not Path(nocache_root).is_dir():
			print_msg("nocache not found. Downloading...")
			git_clone("https://github.com/Feh/nocache.git")
			os.chdir("nocache")
			reset_to_commit(commit_sha)

			os.chdir("../")
		os.chdir("nocache")

		# Build
		print_msg("Building nocache...")
        subprocess.run(["make"],check=True)

    shutil.move(str(Path(nocache_root) / "nocache"), str(Path(build_tools_dir) / "nocache/nocache"))
    
	return {
		"buildDir": nocache_root
	}

if __name__ == "__main__":
	main()
