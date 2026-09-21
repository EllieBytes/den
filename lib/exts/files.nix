final: prev:
let
  matchesAny = regexes: string:
    builtins.elem true (map (r: builtins.match r string));
in {
  fs = rec {
    # nameToPath :: Path -> String -> Path
    # Converts a file name to an absolute path, relative to a base directory.
    nameToPath = base: name: base + "/${name}";

    # allNamesIn :: Path -> [String]
    # Lists all file/directory/symlink names in a directory.
    allNamesIn = dir: builtins.attrNames (builtins.readDir dir);

    # allPathsIn :: Path -> [Path]
    # Lists all file/directory/symlink paths in a directory.
    allPathsIn = dir: map (nameToPath dir) (allNamesIn dir);

    # allNamesInByPred :: (String -> String -> Bool) -> Path -> [String]
    # Lists all file/directory/symlink names in a directory which follow a predicate.
    allNamesInByPred = pred: dir:
      builtins.attrNames (prev.filterAttrs pred (builtins.readDir dir));

    # allPathsInByPred :: (String -> String -> Bool) -> Path -> [Path]
    # Lists all file/directory/symlink paths in a directory which follow a predicate.
    allPathsInByPred = pred: dir:
      map (nameToPath dir) (allNamesInByPred pred dir);

    # allNamesInMatching :: String -> Path -> [String]
    # Lists all file/directory/symlink names that match a regular expression.
    allNamesInMatching = regex: allNamesInByPred (name: _: builtins.match regex name);

    # allPathsInMatching :: String -> Path -> [Path]
    # Lists all file/directory/symlink names that match a regular expression.
    allPathsInMatching = regex: dir: map (nameToPath dir) (allNamesInMatching regex dir);

    # allNamesInByKind :: Enum [ "regular" "directory" "symlink" ] -> Path -> [String]
    # Lists all names of either regular files, directories, or symlinks within a directory.
    allNamesInByKind = kind: allNamesInByPred (_: kind': kind' == kind);

    # allPathsInByKind :: Enum [ "regular" "directory" "symlink" ] -> Path -> [Path]
    # Lists all paths of either regular files, directories, or symlinks within a directory.
    allPathsInByKind = kind: allPathsInByPred (_: kind': kind' == kind);

    # allFileNamesInExcluding :: [String] -> Path -> [String]
    # Lists all file names in a directory excluding names specified.
    allFileNamesInExcluding = exclude:
      allNamesInByPred (name: kind: (!builtins.elem name exclude) && (kind == "directory"));

    # allFilePathsInExcluding :: [String] -> Path -> [Path]
    # Lists all file paths in a directory excluding names specified.
    allFilePathsInExcluding = exclude: dir: map (nameToPath dir) (allFileNamesInExcluding exclude);

    # isHidden :: String -> Bool
    # Returns whether a file is hidden by name.
    isHidden = name: (builtins.match "^\\..*") name != null;

    # allNamesPresentIn :: [String] -> Path -> [String]
    # Returns a list of all candidates names present within a directory.
    allNamesPresentIn = candidates: dir:
      let
        all = allNamesIn dir;
      in builtins.filter (name: builtins.elem name candidates) all;

    # allPathsPresentIn :: [String] -> Path -> [Path]
    # Returns a list of all candidates paths present within a directory.
    allPathsPresentIn = candidates: dir: map (nameToPath dir) (allNamesPresentIn candidates dir);

    # Aliases, I'm not going to bother annotating with types.
    allFileNamesIn = allNamesInByKind "regular"; # All regular file names
    allFilePathsIn = allPathsInByKind "regular"; # All regular file paths
    allDirectoryNamesIn = allNamesInByKind "directory"; # All directory names
    allDirectoryPathsIn = allPathsInByKind "directory"; # All directory paths
    subdirNames = allDirectoryNamesIn; # Alias for `allDirectoryNamesIn`
    subdirs = allDirectoryPathsIn; # Alias for `allDirectoryPathsIn`
  };
}
