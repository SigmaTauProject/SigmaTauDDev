##rsync -r --del --delete-excluded --exclude=".git/" src/packages/* build/
shopt -s nullglob dotglob
mkdir -p ../dist/public/terminal
for group in src/*; do
	for package in "$group"/*; do
		rsync -r --exclude=".git/" "$package"/* ../dist/public/terminal
	done
done

